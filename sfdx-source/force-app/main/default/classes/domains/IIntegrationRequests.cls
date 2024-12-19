/**
 * @author DoorDash
 * @date 03/08/2023
 * @description Interface to add domain class methods
 */
public interface IIntegrationRequests extends fflib_ISObjects{
    /** 
        @description Validates existing store records and transfers them to Figment for processing.
    */
    void validateAndPrePopulateFields();
    /**
     * @description Filters the Integration Requests by the specified Product Status.
     * @param productStatus The Product Status to filter by.
     * @return An instance of IIntegrationRequests containing the filtered Integration Requests.
     */
    IIntegrationRequests filterByProductStatus(String productStatus);
     /**
     * @description Filters the batch IDs of Integration_Request__c records that are not in the specified product status.
     * @param productStatus  A Set of product status values to filter.
     * @return Set<String> A Set of batch IDs of Integration_Request__c records not in the specified product status.
     */
    Set<String> filterBatchIdsIrNotInProductStatus(Set<String> productStatus);
    /**
     * @description Retrieves the set of store Ids from the Integration_Request__c records.
     * @return The set of store Ids.
     */
    Set<String> getStoreIds();
     /**
     * @description Retrieves the set of business Ids from the Integration_Request__c records.
     * @return The set of business Ids.
     */
    Set<String> getBusinessIds();
    /**
     * @description Filters the Integration Requests by the specified Salesforce (SFDC) Status.
     * @param status The SFDC Status to filter by.
     * @return An instance of IIntegrationRequests containing the filtered Integration Requests.
     */
    IIntegrationRequests filterBySfdcStatus(String status);
}