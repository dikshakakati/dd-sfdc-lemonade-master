/**
 * @author deloitte
 * @date 26/03/2024
 * @description Class to get data for the Manage Pricing Screen ARP lightning component.
 */
@SuppressWarnings('PMD.ApexSOQLInjection, PMD.ExcessivePublicCount')
public with sharing class ManagePricingScreenController {
    @TestVisible
    private static Id rateChangeRequestId;
    private static final String DELIMETER_COMMA = ',';
    private static final String PAYMENT_ACCOUNT_OBJECT_API_NAME = 'Payment_Account__c';
    private static final String RECORD_TYPE_INVOICE = 'RecordType.Name != \'Invoice\'';
    private static final String DELIMETER_PERIOD = '.';
    private static final String SPLIT_BY_PERIOD = '\\.';
    private static final String SUB_FIELDS_UI_DELIMETER = ' • ';

    /**
     * @description Creates a content version from a given file's base64 and name
     * @param managePricingWrapper
     */
    @AuraEnabled
    public static void createRateChangeRequest(String managePricingWrapper) {
        Set<Id> existingAccountsToProcessIds;
        List<ManagePricingWrapper> managePricingWrappers = (List<ManagePricingWrapper>) JSON.deserialize(
            managePricingWrapper,
            List<ManagePricingWrapper>.class
        );
        Integer size = managePricingWrappers.size();
        rateChangeRequestId = ManagePricingRateChangeReqService.createRateChangeRequest(managePricingWrappers[size-1]);
        List<Id> strList = (List<Id>) managePricingWrappers[size-1].existingAccountsToUpdate.split(',');
        existingAccountsToProcessIds = new Set<Id>(strList);
        //existingAccountsToProcess = managePricingWrappers[size-1].existingAccountsToUpdate;
        if(rateChangeRequestId != null && !existingAccountsToProcessIds.isEmpty()){
            Database.executeBatch(new AccountUpdateForActiveRatesBatch(existingAccountsToProcessIds, rateChangeRequestId), 200);
        }
    }

	/**
     * @description Creates a content version from a given file's base64 and name
     * @param base64
     * @param filename filename - full file name with extension, i.e. 'products.csv'
     * @param recordId - Id of the record you want to attach this file to
     */
    @AuraEnabled
    public static void uploadFile(String base64, String filename, Id recordId) {
        try {
            ContentVersionService.createContentVersion(base64, filename, recordId);
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
     * @description Get existing Subscriptions with Groups
     * @param parentId
     * @return Map<String,SBQQ__Subscription__c>
     */
    @AuraEnabled(cacheable=true)
    public static List<GroupSubscriptionsWrapper> selectExistingSubscriptionsWithGroup(Id parentId) {
        List<SBQQ__Subscription__c> returnList = new List<SBQQ__Subscription__c>();
        List<GroupSubscriptionsWrapper> wrapperList = new List<GroupSubscriptionsWrapper>();
        Map<SBQQ__QuoteLineGroup__c,List<SBQQ__Subscription__c>> mapGroupSubscription = new Map<SBQQ__QuoteLineGroup__c,List<SBQQ__Subscription__c>>();

        try {
            returnList = SubscriptionSelector.newInstance()
                .selectSubscriptionRecordsByContract(new Set<Id>{parentId});
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        for(SBQQ__Subscription__c subs : returnList){
        SBQQ__QuoteLineGroup__c subsGroup = new SBQQ__QuoteLineGroup__c(Name = subs.Quote_Line_Group__r.Name, Id = subs.Quote_Line_Group__c);
            if(mapGroupSubscription.get(subsGroup) == null){
                mapGroupSubscription.put(subsGroup, new List<SBQQ__Subscription__c>{subs});
            } else {
                mapGroupSubscription.get(subsGroup).add(subs);
            }
        }
        for(SBQQ__QuoteLineGroup__c qLineGroup : mapGroupSubscription.keyset()){
            wrapperList.add(new GroupSubscriptionsWrapper(qLineGroup.Id, qLineGroup.Name, mapGroupSubscription.get(qLineGroup)));
        }
        return wrapperList;
    }

    /**
     * @description Called from the `lookupSearch` component to allow for complex type-ahead record lookups
     * @param inputWrapper - SearchWrapper that aggregates input information from the LWC
     * @return ResultWrapper
     **/
    @AuraEnabled
    public static List<ResultWrapper> fetchRecords(SearchWrapper inputWrapper) {
        // The following code uses dynamic SOQL queries, which triggers a security warning regarding the
        // injection of variables into the DML query. While we have used String.escapeSingleQuotes()
        // to mitigate SOQL injection risks, the warning still persist. Currently, the access controls
        // surrounding this method are strict, and we've taken steps to mitigate injection risks. A complete
        // fix would require a more significant refactoring to eliminate all dynamic query parts, which may not
        // be feasible or preferable in this context. We propose an upcoming refactor of the `lookupSearch` LWC
        // to further mitigate these risks and include the logic in a separate controller.
        try {
            if (inputWrapper == null) {
                return null;
            }
            List<String> fieldsToQueryList = new List<String>{ 'Id' };
            if (String.isNotBlank(inputWrapper.fieldApiName)) {
                fieldsToQueryList.add(inputWrapper.fieldApiName);
            }
            if (String.isNotBlank(inputWrapper.otherFieldApiName)) {
                fieldsToQueryList.addAll(inputWrapper.otherFieldApiName.split(DELIMETER_COMMA));
            }

            String fieldsToQuery = String.join(fieldsToQueryList, ', ');
            String objectApiName = String.escapeSingleQuotes(inputWrapper.objectApiName);
            String query = 'SELECT ' + fieldsToQuery + ' FROM ' + objectApiName;

            List<ResultWrapper> returnWrapperList = new List<ResultWrapper>();
            returnWrapperList = createWhereClause(fieldsToQuery, objectApiName, query, inputWrapper);
            return returnWrapperList;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
     * @description Called from the `lookupSearch` component to allow for complex type-ahead record lookups
     * @param fieldsToQuery
     * @param objectApiName
     * @param query
     * @param inputWrapper
     * @return ResultWrapper
     **/
    @AuraEnabled
    public static List<ResultWrapper> createWhereClause(String fieldsToQuery, String objectApiName, String query, SearchWrapper inputWrapper) {
            List<String> whereClauses = new List<String>();
            if (objectApiName == PAYMENT_ACCOUNT_OBJECT_API_NAME) {
                whereClauses.add(RECORD_TYPE_INVOICE);
            }
            if (String.isNotBlank(inputWrapper.searchString)) {
                whereClauses.add(
                    inputWrapper.fieldApiName +
                        ' LIKE \'%' +
                        String.escapeSingleQuotes(inputWrapper.searchString.trim()) +
                        '%\''
                );
            }
            if (String.isNotBlank(inputWrapper.selectedRecordId)) {
                whereClauses.add(
                    'Id = \'' + String.escapeSingleQuotes(inputWrapper.selectedRecordId) + '\''
                );
            } else if (
                String.isNotBlank(inputWrapper.parentFieldApiName) &&
                String.isNotBlank(inputWrapper.parentRecordId)
            ) {
                whereClauses.add(
                    inputWrapper.parentFieldApiName +
                        ' = \'' +
                        String.escapeSingleQuotes(inputWrapper.parentRecordId) +
                        '\''
                );
            }

            if (whereClauses.size() > 0) {
                query += ' WHERE ' + String.join(whereClauses, ' AND ');
            }

            query += ' ORDER BY LastViewedDate DESC NULLS LAST LIMIT 7';
            List<ResultWrapper> returnWrapperList = new List<ResultWrapper>();
            for (SObject s : Database.query(query)) {
                ResultWrapper wrap = new ResultWrapper();
                wrap.mainField = (String) s.get(inputWrapper.fieldApiName);
                wrap.subField = getSubFieldValue(s, inputWrapper.otherFieldApiName);
                wrap.id = (String) s.get('Id');
                returnWrapperList.add(wrap);
            }

            return returnWrapperList;
    }

    /**
     * @description It gets the sub field values for the passed SObject instance.
     * @param sObjectInstance
     * @param fieldAPINames
     * @return String
     **/
    private static String getSubFieldValue(SObject sObjectInstance, String fieldAPINames) {
        String currentFieldValue;
        String subFieldValue = '';
        if (String.isBlank(fieldAPINames)) {
            return subFieldValue;
        }
        List<String> splittedFieldNames = fieldAPINames.split(DELIMETER_COMMA);
        for (String eachSubField : splittedFieldNames) {
            currentFieldValue = '';
            if (eachSubField.contains(DELIMETER_PERIOD)) {
                //This currently consider only 1 level-up field scenario
                //but it can be extended to multiple level-up field as per the future rquirement.
                currentFieldValue = ((String) sObjectInstance.getSObject(
                        eachSubField.split(SPLIT_BY_PERIOD)[0]
                    )
                    ?.get(eachSubField.split(SPLIT_BY_PERIOD)[1]));
            } else {
                currentFieldValue = ((String) sObjectInstance.get(eachSubField));
            }
            if (String.isNotBlank(currentFieldValue)) {
                subFieldValue += SUB_FIELDS_UI_DELIMETER + currentFieldValue;
            }
        }
        return subFieldValue;
    }

    /**
     * @description Returned in the `lookupSearch` component, contains multiple string values.
     **/
    public class ResultWrapper {
        /**
         * @description getter/setter for main field from query
         **/
        @AuraEnabled
        public String mainField { get; set; }
        /**
         * @description getter/setter for main field for optional secondary field from query
         **/
        @AuraEnabled
        public String subField { get; set; }
        /**
         * @description getter/setter for ID of returned record
         **/
        @AuraEnabled
        public String id { get; set; }
    }

    /**
     * @description Used in the `lookupSearch` component for aggregating search details before
     *              passing them to the Apex methods.
     **/
    public class SearchWrapper {
        /**
         * @description getter/setter for object API name to SOQL
         **/
        @AuraEnabled
        public String objectApiName { get; set; }
        /**
         * @description getter/setter for API Name of main field to search
         **/
        @AuraEnabled
        public String fieldApiName { get; set; }
        /**
         * @description getter/setter for API Name of optional secondary field to search
         **/
        @AuraEnabled
        public String otherFieldApiName { get; set; }
        /**
         * @description getter/setter for search string entered by the user
         **/
        @AuraEnabled
        public String searchString { get; set; }
        /**
         * @description getter/setter for selected record Id
         **/
        @AuraEnabled
        public String selectedRecordId { get; set; }
        /**
         * @description getter/setter for Id of parent record
         **/
        @AuraEnabled
        public String parentRecordId { get; set; }
        /**
         * @description getter/setter for API Name of parent relationship field
         **/
        @AuraEnabled
        public String parentFieldApiName { get; set; }
    }

    /**
    * @author deloitte
    * @date 15/03/2024
    * @description Class to get data for group wrapper
    */
    public class GroupSubscriptionsWrapper{
        /**
         * @description getter/setter for Id of group record
        **/
        @AuraEnabled public Id groupId{get;set;}
        /**
         * @description getter/setter for Name of pargroupent record
        **/
        @AuraEnabled public String groupName{get;set;}
        /**
         * @description getter/setter for List of Subscriptions record
        **/
        @AuraEnabled public List<SBQQ__Subscription__c> subsList{get;set;}

        /**
        * @description Constrictor for GroupSubscriptionsWrapper
        * @param groupId
        * @param groupName
        * @param subscrpList
        */
        public GroupSubscriptionsWrapper(Id groupId, String groupName, List<SBQQ__Subscription__c> subscrpList){
            this.groupId = groupId;
            this.groupName = groupName;
            this.subsList = subscrpList;
        }
    }
}