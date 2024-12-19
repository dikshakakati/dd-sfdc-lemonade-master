/**
 * @description used to build a OAuth1 request given a generic set of parameters
 */
@isTest
private class OAuth1ConfigsSelectorTest {
    @isTest
    static void testWhenNewInstanceThenReturnCorrectObject() {
        system.assert(
            OAuth1ConfigsSelector.newInstance() instanceof OAuth1ConfigsSelector,
            'Expected true'
        );
    }

    @isTest
    static void testWhenGetSObjectFieldListThenReturnCorrectList() {
        // system.assert(OAuth1ConfigsSelector.newInstance());
        Set<Schema.SObjectField> expectedFields = new Set<Schema.SObjectField>{
            OAuth_Config__c.Id,
            OAuth_Config__c.Name,
            OAuth_Config__c.Encrypted_Value__c,
            OAuth_Config__c.Include_In_Authorization__c,
            OAuth_Config__c.Include_In_Header__c,
            OAuth_Config__c.Include_In_Signature__c,
            OAuth_Config__c.Key__c,
            OAuth_Config__c.Value__c,
            OAuth_Config__c.Value_Encrypted__c,
            OAuth_Config__c.Value_Generated__c
        };
        Set<Schema.SObjectField> fields = new Set<Schema.SObjectField>();
        fields.addAll((new OAuth1ConfigsSelector()).getSObjectFieldList());

        system.assert(expectedFields.containsAll(fields), 'Expected true');
    }

    @isTest
    static void testWhenGetNetsuiteIntegrationDatamapThenReturnMap() {
        List<OAuth_Config__c> configs = new List<OAuth_Config__c>{
            new OAuth_Config__c(Key__c = 'Address_Line_1__c', Value__c = 'address.addr1'),
            new OAuth_Config__c(Key__c = 'Postal_Code__c', Value__c = 'address.zip'),
            new OAuth_Config__c(Key__c = 'Country_Code_Alpha_2__c', Value__c = 'address.country'),
            new OAuth_Config__c(Key__c = 'Billing_Contact_Email__c', Value__c = 'email'),
            new OAuth_Config__c(Key__c = 'NetSuite_Subsidiary__c', Value__c = 'subsidiaryId'),
            new OAuth_Config__c(Key__c = 'NetSuite_Currency__c', Value__c = 'currencyId'),
            new OAuth_Config__c(Key__c = 'Bill_To_Company_Name__c', Value__c = 'company_name'),
            new OAuth_Config__c(Key__c = 'State__c', Value__c = 'address.state'),
            new OAuth_Config__c(Key__c = 'NetSuite_Payment_Terms__c', Value__c = 'term_id'),
            new OAuth_Config__c(Key__c = 'City__c', Value__c = 'address.city')
        };
        insert configs;
        Map<Id, OAuth_Config__c> expectedIdToConfig = new Map<Id, OAuth_Config__c>(configs);
        List<OAuth_Config__c> dataMap = OAuth1ConfigsSelector.newInstance()
            .getNetsuiteIntegrationDatamap();
        for (OAuth_Config__c config : dataMap) {
            system.assert(expectedIdToConfig.containsKey(config.Id), 'Expected true');
        }
    }

    @isTest
    static void testWhenGetNetsuiteIntegrationHeadersThenReturnHeaders() {
        List<OAuth_Config__c> headers = new List<OAuth_Config__c>{
            new OAuth_Config__c(
                Include_In_Authorization__c = true,
                Include_In_Header__c = false,
                Include_In_Signature__c = false,
                Key__c = 'realm',
                Value__c = '',
                Encrypted_Value__c = 'therealm',
                Value_Encrypted__c = true,
                Value_Generated__c = false
            ),
            new OAuth_Config__c(
                Include_In_Authorization__c = true,
                Include_In_Header__c = false,
                Include_In_Signature__c = false,
                Key__c = 'oauth_signature',
                Value__c = '',
                Encrypted_Value__c = '',
                Value_Encrypted__c = false,
                Value_Generated__c = true
            ),
            new OAuth_Config__c(
                Include_In_Authorization__c = true,
                Include_In_Header__c = false,
                Include_In_Signature__c = true,
                Key__c = 'oauth_signature_method',
                Value__c = 'HMAC-SHA256',
                Encrypted_Value__c = '',
                Value_Encrypted__c = false,
                Value_Generated__c = false
            ),
            new OAuth_Config__c(
                Include_In_Authorization__c = false,
                Include_In_Header__c = false,
                Include_In_Signature__c = false,
                Key__c = 'consumerSecret',
                Value__c = '',
                Encrypted_Value__c = 'theconsumersecret',
                Value_Encrypted__c = true,
                Value_Generated__c = false
            ),
            new OAuth_Config__c(
                Include_In_Authorization__c = true,
                Include_In_Header__c = false,
                Include_In_Signature__c = true,
                Key__c = 'oauth_timestamp',
                Value__c = '',
                Encrypted_Value__c = '',
                Value_Encrypted__c = false,
                Value_Generated__c = true
            ),
            new OAuth_Config__c(
                Include_In_Authorization__c = false,
                Include_In_Header__c = false,
                Include_In_Signature__c = false,
                Key__c = 'method',
                Value__c = 'POST',
                Encrypted_Value__c = '',
                Value_Encrypted__c = false,
                Value_Generated__c = false
            ),
            new OAuth_Config__c(
                Include_In_Authorization__c = true,
                Include_In_Header__c = false,
                Include_In_Signature__c = true,
                Key__c = 'oauth_consumer_key',
                Value__c = '',
                Encrypted_Value__c = 'theoauthconsumerkey',
                Value_Encrypted__c = true,
                Value_Generated__c = false
            ),
            new OAuth_Config__c(
                Include_In_Authorization__c = false,
                Include_In_Header__c = false,
                Include_In_Signature__c = false,
                Key__c = 'tokenSecret',
                Value__c = '',
                Encrypted_Value__c = 'thetokensecret',
                Value_Encrypted__c = true,
                Value_Generated__c = false
            ),
            new OAuth_Config__c(
                Include_In_Authorization__c = true,
                Include_In_Header__c = false,
                Include_In_Signature__c = true,
                Key__c = '1.0',
                Value__c = 'oauth_version',
                Encrypted_Value__c = '',
                Value_Encrypted__c = false,
                Value_Generated__c = false
            ),
            new OAuth_Config__c(
                Include_In_Authorization__c = true,
                Include_In_Header__c = false,
                Include_In_Signature__c = true,
                Key__c = 'oauth_token',
                Value__c = '',
                Encrypted_Value__c = 'theoauthtoken',
                Value_Encrypted__c = true,
                Value_Generated__c = false
            ),
            new OAuth_Config__c(
                Include_In_Authorization__c = false,
                Include_In_Header__c = true,
                Include_In_Signature__c = false,
                Key__c = 'authorization',
                Value__c = '',
                Encrypted_Value__c = '',
                Value_Encrypted__c = false,
                Value_Generated__c = true
            ),
            new OAuth_Config__c(
                Include_In_Authorization__c = false,
                Include_In_Header__c = true,
                Include_In_Signature__c = false,
                Key__c = 'content_type',
                Value__c = 'application/json',
                Encrypted_Value__c = '',
                Value_Encrypted__c = false,
                Value_Generated__c = false
            ),
            new OAuth_Config__c(
                Include_In_Authorization__c = false,
                Include_In_Header__c = true,
                Include_In_Signature__c = false,
                Key__c = 'oauth_nonce',
                Value__c = '',
                Encrypted_Value__c = '',
                Value_Encrypted__c = false,
                Value_Generated__c = true
            ),
            new OAuth_Config__c(
                Include_In_Authorization__c = false,
                Include_In_Header__c = false,
                Include_In_Signature__c = true,
                Key__c = 'url',
                Value__c = 'https://3938860-sb4.restlets.api.netsuite.com/app/site/hosting/restlet.nl?script=592&deploy=1',
                Encrypted_Value__c = '',
                Value_Encrypted__c = false,
                Value_Generated__c = false
            )
        };
        insert headers;
        Map<Id, OAuth_Config__c> expectedIdToheader = new Map<Id, OAuth_Config__c>(headers);
        List<OAuth_Config__c> dataMap = OAuth1ConfigsSelector.newInstance()
            .getNetsuiteIntegrationHeaders();
        for (OAuth_Config__c config : dataMap) {
            system.assert(expectedIdToheader.containsKey(config.Id), 'Expected true');
        }
    }
}