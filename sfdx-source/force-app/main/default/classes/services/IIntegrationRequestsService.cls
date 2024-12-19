/**
 * @author DoorDash
 * @date 06/03/2023
 * @description Service impl class for processing integration requests.
 */
public interface IIntegrationRequestsService {
    /**
     * @description sync child with ir sfdc_status__c and Product_Status__c with the parent integration requests.
     * called from integration request handler
     * @param oldIntReq old integration requests
     * @param newIntReq new int requests.
     */
    void updateParentIntRequest(
        Map<Id, Integration_Request__c> oldIntReq,
        List<Integration_Request__c> newIntReq
    );

    /**
     * @description Publishes events for processing the Integration Requests.
     * @param oldIntReq A map of old Integration_Request__c records.
     * @param newIntReq A list of new Integration_Request__c records.
     * @param retrying Specifies if the method is called from the scheduler.
     */
    void publishEventsForProcessing(
        Map<Id, Integration_Request__c> oldIntReq,
        List<Integration_Request__c> newIntReq,
        Boolean retrying
    );

    /**
     * @description delete old integration request records based on configuration
     */
    void deleteOldRecords();

    /**
     * @description It updates the Integration Requests SFDC Status based on passed Status value.
     * @param integrationRequestIds
     * @param statusToUpdate
     */
    void updateIntegrationRequestsSFDCStatus(Set<Id> integrationRequestIds, String statusToUpdate);
}