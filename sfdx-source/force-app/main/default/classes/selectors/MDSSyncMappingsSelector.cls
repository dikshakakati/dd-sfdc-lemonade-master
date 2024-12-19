/**
 * @description MDS_Sync_Mapping__mdt Selector class
 */
public inherited sharing class MDSSyncMappingsSelector extends fflib_SObjectSelector implements IMDSSyncMappingsSelector {
    /**
     * @description Default constructor for the MDSSyncMappingsSelector class.
     * @return IMDSSyncMappingsSelector
     */
    public static IMDSSyncMappingsSelector newInstance() {
        return (IMDSSyncMappingsSelector) Application.SELECTOR.newInstance(
            MDS_Sync_Mapping__mdt.SObjectType
        );
    }
    /**
     * @description override default getSObjectType method
     * @return SObjectType - object type
     */
    public Schema.SObjectType getSObjectType() {
        return MDS_Sync_Mapping__mdt.SObjectType;
    }

    /**
     * @description This method is for getting the fields on Work Order
     * @return List<Schema.SObjectField> - MDS Sync Mapping fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            MDS_Sync_Mapping__mdt.Active__c,
            MDS_Sync_Mapping__mdt.MasterLabel,
            MDS_Sync_Mapping__mdt.DeveloperName,
            MDS_Sync_Mapping__mdt.DDMx_Update_Type__c,
            MDS_Sync_Mapping__mdt.DDMx_Object_Name__c,
            MDS_Sync_Mapping__mdt.DDMx_Field_to_Update__c,
            MDS_Sync_Mapping__mdt.Target_Field_Data_Type__c
        };
    }

     /**
    * @description this method is for querying all MDS sync Mappings
    * @return List<MDS_Sync_Mapping__mdt>
    */
    public List<MDS_Sync_Mapping__mdt> getActiveMDSSyncMappings() {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Active__c = true');
        return (List<MDS_Sync_Mapping__mdt>) Database.query(query.toSOQL());
    }
}
