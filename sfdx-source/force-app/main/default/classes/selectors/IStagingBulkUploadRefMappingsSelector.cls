/**
 * @author Deloitte
 * @date 08/08/2024
 * @description Selector interface for the Staging_Bulk_Upload_Reference_Mapping__mdt custom metadata
**/
public interface IStagingBulkUploadRefMappingsSelector extends fflib_ISObjectSelector {
    /**
     * @description Fetches all Active records of Staging_Bulk_Upload_Reference_Mapping__mdt
     * @param referenceType
     * @param referenceRequestType
     * @return List<Staging_Bulk_Upload_Reference_Mapping__mdt> - Returns list of metadata records
     */
    List<Staging_Bulk_Upload_Reference_Mapping__mdt> getAllActiveReferenceAndRequestValues(String referenceType, String referenceRequestType);
}