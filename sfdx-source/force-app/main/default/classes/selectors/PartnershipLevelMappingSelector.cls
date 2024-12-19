/**
 * @author Deloitte
 * @date 06/07/2024
 * @description Selector class for partnership level mapping metadata
 */
public inherited sharing class PartnershipLevelMappingSelector extends fflib_SObjectSelector implements IPartnershipLevelMappingSelector {
    /**
     * @description default constructor for the class
     * @return IPartnershipLevelMappingSelector - interface of PartnershipLevelMappingSelector
     */
    public static IPartnershipLevelMappingSelector newInstance() {
        return (IPartnershipLevelMappingSelector) Application.Selector.newInstance(
            Partnership_Level_Mapping__mdt.SObjectType
        );
    }

    /**
     * @description override default getSObjectType method
     * @return SObjectType - object type of metadata
     */
    public Schema.SObjectType getSObjectType() {
        return Partnership_Level_Mapping__mdt.SObjectType;
    }

    /**
     * @description Method fetches all metadata records
     * @return List<Partnership_Level_Mapping__mdt> - returns list of metadata records
     */
    public List<Partnership_Level_Mapping__mdt> getAllValues() {
        fflib_QueryFactory query = newQueryFactory();
        query.addOrdering('DeveloperName', fflib_QueryFactory.SortOrder.ASCENDING);
        return (List<Partnership_Level_Mapping__mdt>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is for getting the fields on Partnership_Level_Mapping__mdt
     * @return List<Schema.SObjectField>- Partnership_Level_Mapping__mdt fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Partnership_Level_Mapping__mdt.Label,
            Partnership_Level_Mapping__mdt.DeveloperName,
            Partnership_Level_Mapping__mdt.Custom_Partnership_Type__c,
            Partnership_Level_Mapping__mdt.Partnership_Level__c
        };
    }
}