/**
 * @author BizApps
 * @date 17-April-2024
 * @description Helper class for the Jurisdiction Service
 **/
public class JurisdictionServiceHelper {
    public static final String CITY = 'city';
    public static final String STATE = 'state';
    public static final String COUNTRY = 'country';
    public static final String POSTAL_CODE = 'postalCode';

    // Define a map where each sObject type maps to another map of jurisdiction attributes to field API names
    private static Map<String, Map<String, String>> fieldMappings = new Map<String, Map<String, String>>{
        'Account' => new Map<String, String>{
            CITY => 'BillingCity',
            STATE => 'BillingState',
            COUNTRY => 'BillingCountry',
            POSTAL_CODE => 'BillingPostalCode'
        },
        'Contact' => new Map<String, String>{
            CITY => 'MailingCity',
            STATE => 'MailingState',
            COUNTRY => 'MailingCountry',
            POSTAL_CODE => 'MailingPostalCode'
        },
        'Lead' => new Map<String, String>{
            CITY => 'City',
            STATE => 'State',
            COUNTRY => 'Country',
            POSTAL_CODE => 'PostalCode'
        }
    };

    /**
     * @description Gets a Map of Field Names based on an inputted SObject Type String
     * @param sObjectType
     * @return Map<String, String>
     **/
    public static Map<String, String> getFieldMap(String sObjectType) {
        return fieldMappings.get(sObjectType);
    }

    /**
     * @description Takes in a Set of Record IDs and dynamically queries the correct Selector with the right fields
     * @param ids
     * @return Map<String, List<sObject>>
     **/
    public static Map<String, List<sObject>> fetchDataByType(Set<Id> ids) {
        Map<String, Set<Id>> idsByType = new Map<String, Set<Id>>();
        Map<String, List<sObject>> recordsByType = new Map<String, List<sObject>>();

        for (Id recordId : ids) {
            String sObjectType = String.valueOf(recordId.getSObjectType());
            if (!idsByType.containsKey(sObjectType)) {
                idsByType.put(sObjectType, new Set<Id>());
            }
            idsByType.get(sObjectType).add(recordId);
        }

        for (String type : idsByType.keySet()) {
            switch on type {
                when 'Account' {
                    recordsByType.put(type, fetchAccountData(idsByType.get(type)));
                }
                when 'Contact' {
                    recordsByType.put(
                        type,
                        ContactsSelector.newInstance()
                            .selectContactsByIdAndFieldSet(
                                SObjectType.Contact.FieldSets.Address_Details,
                                idsByType.get(type)
                            )
                    );
                }
                when 'WorkOrder' {
                    recordsByType.put(type, fetchWorkOrderData(idsByType.get(type)));
                }
            }
        }

        return recordsByType;
    }

    /**
     * @description Takes in a single Record IDs and dynamically queries the correct Selector with the right fields
     * @param recordId
     * @return SObject
     **/
    public static SObject fetchDataById(Id recordId) {
        Map<String, List<SObject>> results = fetchDataByType(new Set<Id>{ recordId });
        List<SObject> recordsList = results.get(String.valueOf(recordId.getSObjectType()));
        return recordsList != null && !recordsList.isEmpty() ? recordsList[0] : null;
    }

    /**
     * @description Converts a Map of parent IDs and children IDs to a flat Set of IDs for querying
     * @param parentAndChildrenMap
     * @return Set<Id>
     **/
    public static Set<Id> convertParentChildMapToSetOfIds(Map<Id, Set<Id>> parentAndChildrenMap) {
        Set<Id> allRecordIds = new Set<Id>();

        if (parentAndChildrenMap == null) {
            return allRecordIds;
        }

        // First, add all the parents/children to a single Set of IDs to retrieve the records
        // in a single query.
        for (Id thisParentId : parentAndChildrenMap.keySet()) {
            allRecordIds.add(thisParentId);
            for (Id thisChildId : parentAndChildrenMap.get(thisParentId)) {
                allRecordIds.add(thisChildId);
            }
        }

        return allRecordIds;
    }

    /**
     * @description Converts a Map of Account Jurisdiction Results to the inputted Set of Work Order IDs
     * @param allRecordIds
     * @param accountsWithJurisdictionStatus
     * @return Map<Id, Boolean>
     **/
    public static Map<Id, Boolean> convertAccountResultsToWorkOrders(
        Set<Id> allRecordIds,
        Map<Id, Boolean> accountsWithJurisdictionStatus
    ) {
        Map<Id, Boolean> results = accountsWithJurisdictionStatus;

        if (String.valueOf(new List<Id>(allRecordIds)[0].getSObjectType()) == 'WorkOrder') {
            Map<Id, Boolean> workOrderResults = new Map<Id, Boolean>();

            List<WorkOrder> workOrders = WorkOrdersSelector.newInstance().selectById(allRecordIds);
            for (WorkOrder thisWorkOrder : workOrders) {
                workOrderResults.put(
                    thisWorkOrder.Id,
                    accountsWithJurisdictionStatus.get(thisWorkOrder.AccountId)
                );
            }

            results = workOrderResults;
        }

        return results;
    }

    /**
     * @description Returns a List of Account records associated with inputted Account IDs
     * @param accountIds
     * @return List<SObject>
     **/
    private static List<SObject> fetchAccountData(Set<Id> accountIds) {
        List<SObject> results = new List<SObject>();

        if (accountIds != null && !accountIds.isEmpty()) {
            Schema.FieldSet accFieldSet = SObjectType.Account.FieldSets.Address_Details;
            results = AccountsSelector.newInstance()
                .selectAccountsByIdAndFieldSet(accFieldSet, accountIds);
        }

        return results;
    }

    /**
     * @description Returns a List of Account records associated with inputted WorkOrder IDs
     * @param workOrderIds
     * @return List<SObject>
     **/
    private static List<SObject> fetchWorkOrderData(Set<Id> workOrderIds) {
        List<SObject> results = new List<SObject>();
        if (workOrderIds != null && !workOrderIds.isEmpty()) {
            Set<Id> accountIds = new Set<Id>();

            for (
                WorkOrder thisWorkOrder : WorkOrdersSelector.newInstance().selectById(workOrderIds)
            ) {
                accountIds.add(thisWorkOrder.AccountId);
            }

            results = fetchAccountData(accountIds);
        }

        return results;
    }
}