/**
 * @author Salesforce Steve Chao
 * @date 13/11/2023
 * @description Fetching Account fields for LWC
 */
//Supressing CRUD validations because we are doing updates to Custom Settings, not the database.
@SuppressWarnings('PMD.ApexCRUDViolation')
public with sharing class DisplayAccountsController {

    /**
     * @description select feilds from Account object
     * @param ids
     * @return List<Account>
    **/
    @AuraEnabled(cacheable=true)
    public static List<Account> fetchAccountResultsList(List<Id> ids) {
        // Hours_of_Operation__c, Legal_Business_Name__c, Shopping_Protocol__c are needed; the rest are from
        // the AccountsSelector by default
        return AccountsSelector.newInstance().selectFilteredAccount(new Set<String>{
            'Hours_of_Operation__c',
            'Legal_Business_Name__c',
            'Shopping_Protocol__c'        
        }, ids);
    }
}