/**
 * @author Deloitte
 * @date 08/08/2024
 * @description Selector interface for the Staging_Bulk_Upload_Request_Mapping__mdt custom metadata
**/
public interface IStagingBulkUploadReqMappingsSelector extends fflib_ISObjectSelector {
    /**
     * @description Fetches all Active records of Staging_Bulk_Upload_Request_Mapping__mdt
     * @return List<Staging_Bulk_Upload_Request_Mapping__mdt> - Returns list of metadata records
     */
    List<Staging_Bulk_Upload_Request_Mapping__mdt> getAllActiveRequestValues();
}