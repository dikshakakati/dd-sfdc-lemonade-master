/**
 * @description used to build a OAuth1 request given a generic set of parameters
 */
public without sharing class OAuth1RequestGenerator {
    /**
     * @description It is used to generate OAuth 1 request
     * @param describeName
     * @param recordId
     * @param sobjectName
     * @return HttpRequest - the request
     */
    public static HttpRequest generateRequest(
        String describeName,
        String recordId,
        String sobjectName
    ) {
        Map<String, String> dataMap = getOutboundDataMap(describeName);
        SObject record = PaymentAccountsSelector.newInstance()
            .selectPaymentAccountByIdForNetsuiteIntegration(recordId);
        Map<String, Object> keyValues = record.getPopulatedFieldsAsMap();
        Map<String, Object> bodyContent = resolveRequestBodyContent(keyValues, dataMap);
        return generateRequest(describeName, bodyContent);
    }

    /**
     * @description It is used to generate OAuth 1 request
     * @param describeName
     * @param data
     * @param hasDataMap
     * @return HttpRequest - the request
     */
    public static HttpRequest generateRequest(
        String describeName,
        Map<String, Object> data,
        boolean hasDataMap
    ) {
        if (hasDataMap) {
            return generateRequest(describeName, resolveRequestBodyContent(data, describeName));
        }
        return generateRequest(describeName, data);
    }

    @SuppressWarnings('PMD.ApexSuggestUsingNamedCred')
    @testVisible
    static HttpRequest generateRequest(String describeName, Map<String, Object> bodyContent) {
        Map<String, OAuth_Config__c> attrs = new Map<String, OAuth_Config__c>();

        for (
            OAuth_Config__c config : OAuth1ConfigsSelector.newInstance()
                .getNetsuiteIntegrationHeaders()
        ) {
            if (config.Value_Generated__c) {
                generateRunTimeValue(config);
            }
            attrs.put(config.Key__c, config);
        }
        generateSignature(attrs);
        generateAuthorization(attrs);
        HttpRequest req = new HttpRequest();
        req.setMethod(attrs.get('method').Value__c);
        req.setEndpoint(attrs.get('url').Value__c);
        req.setBody(JSON.serialize(bodyContent));
        req.setHeader('Content-Type', attrs.get('content_type').Value__c);
        req.setHeader('Authorization', attrs.get('authorization').Value__c);
        return req;
    }

    @testVisible
    static Map<String, Object> resolveRequestBodyContent(
        Map<String, Object> data,
        String describeName
    ) {
        Map<String, String> dataMap = getOutboundDataMap(describeName);
        return resolveRequestBodyContent(data, dataMap);
    }

    @testVisible
    static Map<String, Object> resolveRequestBodyContent(
        Map<String, Object> data,
        Map<String, String> dataMap
    ) {
        Map<String, Object> bodyContent = new Map<String, Object>();
        String val;
        List<String> hierarchicalKeys;
        Map<String, Map<String, Object>> nestedAttrs = new Map<String, Map<String, Object>>();

        for (String key : dataMap.keySet()) {
            val = dataMap.get(key);
            if (!val.contains('.')) {
                bodyContent.put(val, data.get(key));
                continue;
            }
            hierarchicalKeys = val.split('\\.');
            if (hierarchicalKeys.size() == 2) {
                if (nestedAttrs.containsKey(hierarchicalKeys[0])) {
                    nestedAttrs.get(hierarchicalKeys[0]).put(hierarchicalKeys[1], data.get(key));
                    continue;
                }
                nestedAttrs.put(
                    hierarchicalKeys[0],
                    new Map<String, Object>{ hierarchicalKeys[1] => data.get(key) }
                );
            }
        }
        for (String key : nestedAttrs.keySet()) {
            bodyContent.put(key, nestedAttrs.get(key));
        }
        return bodyContent;
    }

    @testVisible
    static Map<String, String> getOutboundDataMap(String describeName) {
        Map<String, String> dataMap = new Map<String, String>();

        for (
            OAuth_Config__c config : OAuth1ConfigsSelector.newInstance()
                .getNetsuiteIntegrationDatamap()
        ) {
            dataMap.put(config.Key__c, config.Value__c);
        }
        return dataMap;
    }

    @testVisible
    static void generateAuthorization(Map<String, OAuth_Config__c> keyToValues) {
        String value = '', authorization = 'OAuth ';

        for (OAuth_Config__c config : keyToValues.values()) {
            if (!config.Include_In_Authorization__c) {
                continue;
            }
            value = config.Value_Encrypted__c ? config.Encrypted_Value__c : config.Value__c;
            authorization += config.Key__c + '="' + value + '", ';
        }
        // remove trailing ','
        authorization = authorization.removeEnd(',');
        keyToValues.get('authorization').Value__c = authorization;
    }

    @testVisible
    static void generateSignature(Map<String, OAuth_Config__c> keyToValues) {
        String concatSortedParamValues = '', signature = '', signatureBase = '';
        Map<String, String> oauthParams = new Map<String, String>();
        String endpointHost = keyToValues.get('url').Value__c;
        String method = keyToValues.get('method').Value__c;
        String tokenSecret = keyToValues.get('tokenSecret').Encrypted_Value__c;
        String consumerSecret = keyToValues.get('consumerSecret').Encrypted_Value__c;
        String signatureMethod = keyToValues.get('oauth_signature_method').Value__c;
        boolean endpointHostHasQueryParams = endpointHost.contains('?');
        boolean isBodyAFormEncodedUrl =
            keyToValues.get('body') != null &&
            method.equalsIgnoreCase('post') &&
            keyToValues.get('content_type').Value__c == 'application/x-www-form-urlencoded';

        // add oauth params
        String value;
        for (OAuth_Config__c config : keyToValues.values()) {
            value = config.Value_Encrypted__c ? config.Encrypted_Value__c : config.Value__c;
            if (config.Key__c != 'url' && config.Include_In_Signature__c) {
                oauthParams.put(config.key__c, value);
            }
        }
        if (endpointHostHasQueryParams) {
            oauthParams.putAll(getEncodedQueryParamsAsMap(endpointHost.substringAfter('?')));
            endpointHost = endpointHost.substringBefore('?');
        }
        if (isBodyAFormEncodedUrl) {
            oauthParams.putAll(getEncodedQueryParamsAsMap(keyToValues.get('body').Value__c));
        }
        // concatenate sorted auth params
        List<String> sortedKeys = new List<String>();
        sortedKeys.addAll(oauthParams.keySet());
        sortedKeys.sort();
        for (Integer keyIndex = 0; keyIndex < sortedKeys.size(); keyIndex++) {
            concatSortedParamValues +=
                sortedKeys[keyIndex] +
                '=' +
                oauthParams.get(sortedKeys[keyIndex]) +
                '&';
        }
        // remove trailing '&'
        concatSortedParamValues = concatSortedParamValues.removeEnd('&');
        signatureBase =
            method.toUpperCase() +
            '&' +
            EncodingUtil.urlEncode(endpointHost, 'UTF-8') +
            '&' +
            EncodingUtil.urlEncode(concatSortedParamValues, 'UTF-8');
        // sign
        signature = EncodingUtil.urlEncode(
            EncodingUtil.base64encode(
                Crypto.generateMac(
                    signatureMethod,
                    Blob.valueOf(signatureBase),
                    Blob.valueOf(consumerSecret + '&' + (tokenSecret != null ? tokenSecret : ''))
                )
            ),
            'UTF-8'
        );
        keyToValues.get('oauth_signature').Value__c = signature;
    }

    @testVisible
    static Map<String, String> getEncodedQueryParamsAsMap(String url) {
        Map<String, String> encodedUrlParams = new Map<String, String>();
        if (String.isEmpty(url)) {
            return encodedUrlParams;
        }
        for (String param : url.split('&')) {
            List<String> kv = param.split('=');
            if (kv.size() > 1) {
                String encName = EncodingUtil.urlEncode(
                        EncodingUtil.urlDecode(kv[0], 'UTF-8'),
                        'UTF-8'
                    )
                    .replace('+', '%20');
                String encValue = EncodingUtil.urlEncode(
                        EncodingUtil.urlDecode(kv[1], 'UTF-8'),
                        'UTF-8'
                    )
                    .replace('+', '%20');
                encodedUrlParams.put(encName, encValue);
            }
        }
        return encodedUrlParams;
    }

    @testVisible
    static void generateRunTimeValue(OAuth_Config__c attr) {
        switch on attr.Key__c {
            when 'oauth_nonce' {
                attr.Value__c = String.valueOf(Crypto.getRandomLong());
                return;
            }
            when 'oauth_timestamp' {
                attr.Value__c = String.valueOf(DateTime.now().getTime() / 1000);
                return;
            }
            when else {
                return;
            }
        }
    }
}