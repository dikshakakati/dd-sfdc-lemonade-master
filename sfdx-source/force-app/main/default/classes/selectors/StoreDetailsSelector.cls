/**
 * @author Deloitte
 * @date 07/03/2024
 * @description Selector class for Store Details.
 */
public inherited sharing class StoreDetailsSelector extends fflib_SObjectSelector implements IStoreDetailsSelector {
    /**
     * @description Default constructor for the class.
     * @return IStoreDetailsSelector
     */
    public static IStoreDetailsSelector newInstance() {
        return (IStoreDetailsSelector) Application.Selector.newInstance(
            Store_Detail__c.SObjectType
        );
    }

    /**
     * @description It is used for getting the object type.
     * @return SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Store_Detail__c.SObjectType;
    }

    /**
     * @description It is used for getting Store Detail records by Ids.
     * @param ids
     * @return List<Store_Detail__c>
     */
    public List<Store_Detail__c> selectById(Set<Id> ids) {
        return (List<Store_Detail__c>) selectSObjectsById(ids);
    }

    /**
     * @description It is used for getting the fields of Status_Reason_And_Details_Mapping__mdt.
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Store_Detail__c.Menu_Setup_Method__c,
            Store_Detail__c.Menu_to_be_Completed_By__c,
            Store_Detail__c.Sales_Notes_for_Menu_Team__c,
            Store_Detail__c.Address_Verification_Status__c,
            Store_Detail__c.Mx_Onboarding_Link__c,
            Store_Detail__c.Address__CountryCode__s,
            Store_Detail__c.Address__StateCode__s,
            Store_Detail__c.Address__City__s,
            Store_Detail__c.Address__PostalCode__s,
            Store_Detail__c.Address__Street__s,
            Store_Detail__c.Address__c
        };
    }
}