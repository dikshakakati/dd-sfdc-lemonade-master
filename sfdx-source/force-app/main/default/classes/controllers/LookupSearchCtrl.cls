/**
 * @description Controller for the `lookupSearch` LWC
 * @author BizApps
 * @date 25-April-2024
 **/
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity, PMD.ExcessivePublicCount')
public with sharing class LookupSearchCtrl {
    private static final String FIELD_TYPE_MAIN = 'main';
    private static final String FIELD_TYPE_SUBFIELDS = 'subFields';

    private static final String CONTACT_OBJECT_API_NAME = 'Contact';
    private static final String PAYMENT_ACCOUNT_OBJECT_API_NAME = 'Payment_Account__c';
    private static final String RECORD_TYPE_INVOICE = 'RecordType.Name != \'Invoice\'';
    private static final String DECISION_MAKER_QUERY_FIELDS = 'Id, Name, Title, Email, Phone, MobilePhone';
    private static final String DECISION_MAKER_MAIN_FIELD = 'Name';
    private static final String DECISION_MAKER_SECONDARY_FIELDS = 'Email';
    private static final String PAYMENT_ACCOUNT_QUERY_FIELDS = 'Id, Name, Entity_Type__c, Business_Account__c, Business_Account__r.Name';
    private static final String PAYMENT_ACCOUNT_MAIN_FIELD = 'Name';
    private static final String PAYMENT_ACCOUNT_SECONDARY_FIELDS = 'Entity_Type__c,Business_Account__r.Name';
    private static final Integer DEFAULT_RECORDS_LIMIT = 7;

    private static Map<String, String> fieldsToQueryByObjectName {
        get {
            if (fieldsToQueryByObjectName == null) {
                fieldsToQueryByObjectName = new Map<String, String>{
                    PAYMENT_ACCOUNT_OBJECT_API_NAME => PAYMENT_ACCOUNT_QUERY_FIELDS,
                    CONTACT_OBJECT_API_NAME => DECISION_MAKER_QUERY_FIELDS
                };
            }

            return fieldsToQueryByObjectName;
        }
        set;
    }

    private static Map<String, Map<String, String>> fieldsToShowByObjectName {
        get {
            if (fieldsToShowByObjectName == null) {
                fieldsToShowByObjectName = new Map<String, Map<String, String>>();
                fieldsToShowByObjectName.put(
                    PAYMENT_ACCOUNT_OBJECT_API_NAME,
                    new Map<String, String>{
                        FIELD_TYPE_MAIN => PAYMENT_ACCOUNT_MAIN_FIELD,
                        FIELD_TYPE_SUBFIELDS => PAYMENT_ACCOUNT_SECONDARY_FIELDS
                    }
                );
                fieldsToShowByObjectName.put(
                    CONTACT_OBJECT_API_NAME,
                    new Map<String, String>{
                        FIELD_TYPE_MAIN => DECISION_MAKER_MAIN_FIELD,
                        FIELD_TYPE_SUBFIELDS => DECISION_MAKER_SECONDARY_FIELDS
                    }
                );
            }

            return fieldsToShowByObjectName;
        }
        set;
    }

    @TestVisible
    private static List<SObject> mockRecords = new List<SObject>();

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
            Set<String> allFieldsToQuery = new Set<String>{ 'Id' };
            if (String.isNotBlank(inputWrapper.primaryFieldToSearch)) {
                allFieldsToQuery.add(inputWrapper.primaryFieldToSearch);
            }
            if (String.isNotBlank(inputWrapper.secondaryField)) {
                allFieldsToQuery.add(inputWrapper.secondaryField);
            }
            if (String.isNotBlank(inputWrapper.fieldsToQuery)) {
                allFieldsToQuery.addAll(inputWrapper.fieldsToQuery.split(','));
            }

            String fieldsToQuery = String.join(allFieldsToQuery, ', ');
            String objectApiName = String.escapeSingleQuotes(inputWrapper.objectApiName);
            String query = 'SELECT ' + fieldsToQuery + ' FROM ' + objectApiName;

            List<String> whereClauses = new List<String>();
            if (objectApiName == PAYMENT_ACCOUNT_OBJECT_API_NAME) {
                whereClauses.add(RECORD_TYPE_INVOICE);
            }
            if (String.isNotBlank(inputWrapper.searchString)) {
                whereClauses.add(
                    inputWrapper.primaryFieldToSearch +
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

            query += ' ORDER BY LastViewedDate DESC NULLS LAST LIMIT ' + inputWrapper.recordsLimit;

            List<ResultWrapper> returnWrapperList = new List<ResultWrapper>();
            for (SObject s : getRecords(query, null)) {
                ResultWrapper wrap = new ResultWrapper();
                wrap.mainField = (String) s.get(inputWrapper.primaryFieldToSearch);
                wrap.subField = getSubFieldValue(s, inputWrapper.secondaryField);
                wrap.record = s;
                returnWrapperList.add(wrap);
            }

            return returnWrapperList;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
     * @description Retrieves a `ResultWrapper` for a given record
     * @param recordId
     * @return ResultWrapper
     **/
    @AuraEnabled
    public static ResultWrapper fetchRecordById(Id recordId) {
        if (recordId == null) {
            throw new AuraHandledException('Invalid ID provided');
        }

        String objectName = String.valueOf(recordId.getSObjectType());
        String fieldsToQuery = fieldsToQueryByObjectName.get(objectName);
        String mainFieldToUse = fieldsToShowByObjectName.get(objectName).get(FIELD_TYPE_MAIN);
        String subFieldToUse = fieldsToShowByObjectName.get(objectName).get(FIELD_TYPE_SUBFIELDS);

        Set<Id> recordIds = new Set<Id>{ recordId };

        // Get the object API name and fields dynamically...
        String query =
            'SELECT ' +
            fieldsToQuery +
            ' FROM ' +
            objectName +
            ' WHERE Id IN :recordIds';

        SObject record;
        try {
            List<SObject> results = getRecords(query, recordIds);
            record = !results.isEmpty() ? results[0] : null;

            if (record == null) {
                throw new AuraHandledException('Failed to fetch record: ' + recordId);
            }
        } catch (Exception ex) {
            throw new AuraHandledException('Error while retrieving data: ' + ex.getMessage());
        }

        // Populate the result wrapper
        ResultWrapper wrapper = new ResultWrapper();
        wrapper.mainField = (String) record.get(mainFieldToUse);
        wrapper.subField = getSubFieldValue(record, subFieldToUse);
        wrapper.record = record;

        return wrapper;
    }

    /**
     * @description Returns array of `ResultWrapper` objects for a given set of record IDs
     * @param recordIds
     * @return List<ResultWrapper>
     **/
    public static List<ResultWrapper> retrieveResultsByIds(Set<Id> recordIds) {
        try {
            List<ResultWrapper> results = new List<ResultWrapper>();

            if (recordIds == null || recordIds.isEmpty()) {
                return results;
            }

            // Get SObject Type
            String objectName;

            for (Id thisId : recordIds) {
                // Get the first ID from the Set and break
                objectName = thisId.getSobjectType().getDescribe().getName();
                break;
            }

            String fieldsToQuery = fieldsToQueryByObjectName.get(objectName);
            String mainFieldToUse = fieldsToShowByObjectName.get(objectName).get(FIELD_TYPE_MAIN);
            String subFieldToUse = fieldsToShowByObjectName.get(objectName)
                .get(FIELD_TYPE_SUBFIELDS);

            if (String.isBlank(fieldsToQuery) || mainFieldToUse == null) {
                throw new SearchQueryException('No fields selected for SObject: ' + objectName);
            }

            String queryString = 'SELECT ' + fieldsToQuery + ' FROM ' + objectName + ' ';
            queryString += 'WHERE Id IN :recordIds ORDER BY LastViewedDate DESC';

            for (SObject s : getRecords(queryString, recordIds)) {
                ResultWrapper wrap = new ResultWrapper();
                wrap.mainField = (String) s.get(mainFieldToUse);
                wrap.subField = getSubFieldValue(s, subFieldToUse);
                wrap.record = s;
                results.add(wrap);
            }

            return results;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
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
        List<String> splittedFieldNames = fieldAPINames.split(',');
        for (String eachSubField : splittedFieldNames) {
            currentFieldValue = '';
            if (eachSubField.contains('.')) {
                //This currently consider only 1 level-up field scenario
                //but it can be extended to multiple level-up field as per the future rquirement.
                currentFieldValue = ((String) sObjectInstance.getSObject(
                        eachSubField.split('\\.')[0]
                    )
                    ?.get(eachSubField.split('\\.')[1]));
            } else {
                currentFieldValue = ((String) sObjectInstance.get(eachSubField));
            }
            if (String.isNotBlank(currentFieldValue)) {
                subFieldValue += ' • ' + currentFieldValue;
            }
        }
        return subFieldValue;
    }

    /**
     * @description Queries SObject records OR returns mock values in a test context
     * @param query
     * @param recordIds
     * @return List<SObject>
     **/
    @SuppressWarnings('PMD.ApexSOQLInjection')
    private static List<SObject> getRecords(String query, Set<Id> recordIds) {
        if (Test.isRunningTest() && !mockRecords.isEmpty()) {
            return mockRecords;
        }

        // Include the recordId in the method scope to ensure it's available for binding
        return Database.query(query);
    }

    /**
     * @description Aggregating search details before passing them to methods.
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
        public String primaryFieldToSearch { get; set; }
        /**
         * @description getter/setter for API Name of optional secondary field to search
         **/
        @AuraEnabled
        public String secondaryField { get; set; }

        /**
         * @description getter/setter for API Name of optional secondary field to search
         **/
        @AuraEnabled
        public String fieldsToQuery { get; set; }

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

        /**
         * @description getter/setter number of records to limit in search
         **/
        @AuraEnabled
        public Integer recordsLimit {
            get {
                if (recordsLimit == null) {
                    recordsLimit = DEFAULT_RECORDS_LIMIT;
                }
                return recordsLimit;
            }
            set;
        }
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
        public SObject record { get; set; }
    }

    /**
     * @description Exception type thrown if we cannot construct a proper SOQL query with the given inputs
     **/
    public class SearchQueryException extends Exception {
    }
}