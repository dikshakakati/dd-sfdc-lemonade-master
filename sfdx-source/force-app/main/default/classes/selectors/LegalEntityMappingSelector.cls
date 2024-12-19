/**
 * @author Deloitte
 * @date 05/24/2022
 * @description Selector class for legal entity mapping metadata
 */
public inherited sharing class LegalEntityMappingSelector extends fflib_SObjectSelector implements ILegalEntityMappingSelector {
    /**
     * @description default constructor for the class
     * @return ILegalEntityMappingSelector - interface of LegalEntityMappingSelector
     */
    public static ILegalEntityMappingSelector newInstance() {
        return (ILegalEntityMappingSelector) Application.Selector.newInstance(
            Legal_Entity_Mapping__mdt.SObjectType
        );
    }

    /**
     * @description override default getSObjectType method
     * @return SObjectType - object type of metadata
     */
    public Schema.SObjectType getSObjectType() {
        return Legal_Entity_Mapping__mdt.SObjectType;
    }

    /**
     * @description Method fetches all metadata records
     * @return List<Legal_Entity_Mapping__mdt> - returns list of metadata records
     */
    public List<Legal_Entity_Mapping__mdt> getAllValues() {
        fflib_QueryFactory query = newQueryFactory();
        query.addOrdering('DeveloperName', fflib_QueryFactory.SortOrder.ASCENDING);
        return (List<Legal_Entity_Mapping__mdt>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is for getting the fields on Legal_Entity_Mapping__mdt
     * @return List<Schema.SObjectField>- Legal_Entity_Mapping__mdt fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Legal_Entity_Mapping__mdt.Label,
            Legal_Entity_Mapping__mdt.DeveloperName,
            Legal_Entity_Mapping__mdt.Legal_Entity_Name__c,
            Legal_Entity_Mapping__mdt.Billing_State_Code__c,
            Legal_Entity_Mapping__mdt.Primary_Vertical__c,
            Legal_Entity_Mapping__mdt.Record_Type_Name__c,
            Legal_Entity_Mapping__mdt.Currency_ISO_Code__c
        };
    }
}