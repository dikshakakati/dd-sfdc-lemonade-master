/**
 * @author Deloitte
 * @date 08/08/2024
 * @description Selector class for the Staging_Bulk_Upload_Request_Mapping__mdt custom metadata
**/
public inherited sharing class StagingBulkUploadReqMappingsSelector extends fflib_SObjectSelector implements IStagingBulkUploadReqMappingsSelector{
    /**
     * @description Default constructor for the class.
     * @return IStagingBulkUploadReqMappingsSelector - Returns interface of StagingBulkUploadReqMappingsSelector
     */
    public static IStagingBulkUploadReqMappingsSelector newInstance() {
        return (IStagingBulkUploadReqMappingsSelector) Application.Selector.newInstance(Staging_Bulk_Upload_Request_Mapping__mdt.SObjectType);
    }

    /**
     * @description Used for getting object type.
     * @return SObjectType - Returns object type of metadata
     */
    public Schema.SObjectType getSObjectType() {
        return Staging_Bulk_Upload_Request_Mapping__mdt.SObjectType;
    }
    
    /**
     * @description Used for getting the fields of Staging_Bulk_Upload_Request_Mapping__mdt
     * @return List<Schema.SObjectField> - Staging_Bulk_Upload_Request_Mapping__mdt fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Staging_Bulk_Upload_Request_Mapping__mdt.CSV_Column_Name__c,
            Staging_Bulk_Upload_Request_Mapping__mdt.API_Name__c,
            Staging_Bulk_Upload_Request_Mapping__mdt.Datatype__c,
            Staging_Bulk_Upload_Request_Mapping__mdt.Active__c
        };
    }

    /**
     * @description Returns a List of "Active" Staging_Bulk_Upload_Request_Mapping__mdt
     * @return List<Staging_Bulk_Upload_Request_Mapping__mdt>
     */
    public List<Staging_Bulk_Upload_Request_Mapping__mdt> getAllActiveRequestValues() {
        fflib_QueryFactory query = newQueryFactory()
        	.setCondition ('Active__c = true');
        return (List<Staging_Bulk_Upload_Request_Mapping__mdt>) Database.query(query.toSOQL());
    }
}