/**
 * @author Deloitte
 * @date 08/08/2024
 * @description Selector class for the Staging_Bulk_Upload_Reference_Mapping__mdt custom metadata
**/
public inherited sharing class StagingBulkUploadRefMappingsSelector extends fflib_SObjectSelector implements IStagingBulkUploadRefMappingsSelector{
    /**
     * @description Default constructor for the class.
     * @return IStagingBulkUploadRefMappingsSelector - Returns interface of StagingBulkUploadRefMappingsSelector
     */
    public static IStagingBulkUploadRefMappingsSelector newInstance() {
        return (IStagingBulkUploadRefMappingsSelector) Application.Selector.newInstance(Staging_Bulk_Upload_Reference_Mapping__mdt.SObjectType);
    }

    /**
     * @description Used for getting object type
     * @return SObjectType - Returns object type of metadata
     */
    public Schema.SObjectType getSObjectType() {
        return Staging_Bulk_Upload_Reference_Mapping__mdt.SObjectType;
    }
    
    /**
     * @description Used for getting the fields of Staging_Bulk_Upload_Reference_Mapping__mdt
     * @return List<Schema.SObjectField> - Staging_Bulk_Upload_Reference_Mapping__mdt fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Staging_Bulk_Upload_Reference_Mapping__mdt.Type__c,
            Staging_Bulk_Upload_Reference_Mapping__mdt.Request_Type__c,
            Staging_Bulk_Upload_Reference_Mapping__mdt.Record_Limit__c,
            Staging_Bulk_Upload_Reference_Mapping__mdt.Active__c,
            Staging_Bulk_Upload_Reference_Mapping__mdt.Error_Message__c
        };
    }

    /**
     * @description Returns a List of "Active" Staging_Bulk_Upload_Reference_Mapping__mdt
     * @param referenceType
     * @param referenceRequestType
     * @return List<Staging_Bulk_Upload_Reference_Mapping__mdt>
     */
    public List<Staging_Bulk_Upload_Reference_Mapping__mdt> getAllActiveReferenceAndRequestValues(String referenceType, String referenceRequestType) {
        fflib_QueryFactory query = newQueryFactory()
        	.setCondition('Active__c = true And Type__c = :referenceType And Request_Type__c = :referenceRequestType');
        new StagingBulkUploadReqMappingsSelector()
            .addQueryFactorySubselect(query, 'Staging_Bulk_Upload_Request_Mappings__r')
            .setCondition('Active__c = true');
        return (List<Staging_Bulk_Upload_Reference_Mapping__mdt>) Database.query(query.toSOQL());
    }
}