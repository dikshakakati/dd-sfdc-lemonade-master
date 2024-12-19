/**
 * @author Doordash
 * @date 09/27/2023
 * @description Selector class for Business_Friendly_Mapping__mdt custom metadata
 */
public inherited sharing class BusinessFriendlyMappingSelector extends fflib_SObjectSelector implements IBusinessFriendlyMappingSelector {
    /**
     * @description default constructor for the class
     * @return IBusinessFriendlyMappingSelector - interface of IBusinessFriendlyMappingSelector
     */
    public static IBusinessFriendlyMappingSelector newInstance() {
        return (IBusinessFriendlyMappingSelector) Application.Selector.newInstance(
            Business_Friendly_Mapping__mdt.SObjectType
        );
    }

    /**
     * @description override default getSObjectType method
     * @return SObjectType - object type of metadata
     */
    public Schema.SObjectType getSObjectType() {
        return Business_Friendly_Mapping__mdt.SObjectType;
    }

    /**
     * @description This method is for getting the fields on Business_Friendly_Mapping__mdt
     * @return List<Schema.SObjectField>- Business_Friendly_Mapping__mdt fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Business_Friendly_Mapping__mdt.Order__c,
            Business_Friendly_Mapping__mdt.Active__c,
            Business_Friendly_Mapping__mdt.MasterLabel,
            Business_Friendly_Mapping__mdt.DeveloperName,
            Business_Friendly_Mapping__mdt.Message_Category__c,
            Business_Friendly_Mapping__mdt.Integration_Type__c,
            Business_Friendly_Mapping__mdt.Integration_Key_String__c,
            Business_Friendly_Mapping__mdt.Business_Friendly_Message__c
        };
    }

    /**
    * @description this method is for querying the business friendly messages mapping by Integration Type
    * @param integrationType
    * @return List<Business_Friendly_Mapping__mdt>
    */
    public List<Business_Friendly_Mapping__mdt> selectByIntegrationType(string integrationType) {
        fflib_QueryFactory query = newQueryFactory()
        .setCondition('Integration_Type__c =: integrationType AND Active__c = true')
        .setOrdering('Order__c', fflib_QueryFactory.SortOrder.ASCENDING);
        return (List<Business_Friendly_Mapping__mdt>) Database.query(query.toSOQL());
    }
}