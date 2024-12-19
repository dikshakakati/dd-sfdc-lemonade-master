/**
 * @author Deloitte
 * @date   04/26/2022
 * @description This is the controller for hierarchy component.
 */
public with sharing class AccountHierarchyController {
    /**
     * @description To retrieve related metadata record
     * @param metadataName
     * @return List<Static_Configurations__mdt>
     */
    @AuraEnabled(cacheable=true)
    public static Static_Configurations__mdt getMetadataRecord(String metadataName) {
        List<Static_Configurations__mdt> staticConfiguration = StaticConfigurationsSelector.newInstance()
            .selectByDeveloperName(metadataName);

        if (!staticConfiguration.isEmpty()) {
            return staticConfiguration[0];
        }
        return null;
    }

    /**
     * @description To get selected account details
     * @param columns
     * @param recordId
     * @return List<Account>
     */
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccountDetails(List<String> columns, Id recordId) {
        try {
            List<Id> recordIds = new List<Id>{ recordId };
            Set<String> fieldNames = new Set<String>(columns);
            List<String> selectedAccountsFields = new List<String>{
                'Id',
                'RecordType.DeveloperName',
                'ParentId',
                'Parent.ParentId',
                'Parent.Parent.ParentId',
                'Parent.Parent.Parent.ParentId',
                'Ultimate_Parent_Account__c',
                'Franchise_Parent__c',
                'Franchise_Parent__r.ParentId',
                'Franchise_Parent__r.Parent.ParentId',
                'Franchise_Parent__r.Parent.Parent.ParentId',
                'Franchise_Parent__r.Ultimate_Parent_Account__c'
            };
            fieldNames.addAll(selectedAccountsFields);
            return (List<Account>) Security.stripInaccessible(
                    AccessType.READABLE,
                    AccountsSelector.newInstance().selectFilteredAccount(fieldNames, recordIds)
                )
                .getRecords();
        } catch (Exception e) {
            AuraHandledException ex = new AuraHandledException(
                System.Label.Failed_Retrieve_Account
            );
            ex.setMessage(System.Label.Failed_Retrieve_Account);
            throw ex;
        }
    }

    /**
     * @description To get child account records
     * @param columns
     * @param parentField
     * @param recordIds
     * @return List<Account>
     */
    @AuraEnabled
    public static List<Account> getChildAccounts(
        List<String> columns,
        String parentField,
        List<Id> recordIds
    ) {
        try {
            Set<String> fieldNames = new Set<String>(columns);
            List<String> childAccountFields = new List<String>{
                'Id',
                'ParentId',
                'Franchise_Parent__c',
                'RecordType.DeveloperName'
            };
            fieldNames.addAll(childAccountFields);

            Map<String, SObjectField> fieldMap = Account.getSObjectType()
                .getDescribe()
                .fields.getMap();
            Schema.SObjectField parentSObjectField = fieldMap.get(parentField);

            return (List<Account>) Security.stripInaccessible(
                    AccessType.READABLE,
                    AccountsSelector.newInstance()
                        .selectHierachyChildAccounts(fieldNames, parentSObjectField, recordIds)
                )
                .getRecords();
        } catch (Exception e) {
            AuraHandledException ex = new AuraHandledException(
                System.Label.Failed_Retrieve_Child_Accounts
            );
            ex.setMessage(System.Label.Failed_Retrieve_Child_Accounts);
            throw ex;
        }
    }
}