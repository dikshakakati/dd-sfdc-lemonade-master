/**
 * @author Deloitte
 * @date 08/08/2024
 * @description Selector Class for Staging_Bulk_Upload_Request__c Object
 */
public interface IStagingBulkUploadRequestSelector extends fflib_ISObjectSelector {
    
    /**
     * @description It is used for getting Staging_Bulk_Upload_Request__c records by referenceIds
     * @param referenceIds
     * @return Database.QueryLocator
     */
    Database.QueryLocator selectStagingRequestsByReferenceIds(Set<String> referenceIds);
}