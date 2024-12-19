/**
 * @author DoorDash
 * @date 06/03/2023
 * @description Service impl class for processing integration requests.
 */
public with sharing class IntegrationRequestsService {
    private static IIntegrationRequestsService service() {
        return (IIntegrationRequestsService) Application.SERVICE.newInstance(
            IIntegrationRequestsService.class
        );
    }
    /**
     * @description sync child with ir sfdc_status__c and Product_Status__c with the parent integration requests.
     * called from integration request handler
     * @param oldIntReq old integration requests
     * @param newIntReq new int requests.
     */
    public static void updateParentIntRequest(
        Map<Id, Integration_Request__c> oldIntReq,
        List<Integration_Request__c> newIntReq
    ) {
        service().updateParentIntRequest(oldIntReq, newIntReq);
    }
    /**
     * @description Publishes events for processing the Integration Requests.
     * @param oldIntReq A map of old Integration_Request__c records.
     * @param newIntReq A list of new Integration_Request__c records.
     * @param fromScheduler Specifies if the method is called from the scheduler.
     */
    public static void publishEventsForProcessing(
        Map<Id, Integration_Request__c> oldIntReq,
        List<Integration_Request__c> newIntReq,
        Boolean fromScheduler
    ) {
        service().publishEventsForProcessing(oldIntReq, newIntReq, fromScheduler);
    }

    /**
     * @description It updates the Integration Requests SFDC Status based on passed Status value.
     * @JIRA# LEM-17497
     * @param integrationRequestIds
     * @param statusToUpdate
     */
    public static void updateIntegrationRequestsSFDCStatus(
        Set<Id> integrationRequestIds,
        String statusToUpdate
    ) {
        service().updateIntegrationRequestsSFDCStatus(integrationRequestIds, statusToUpdate);
    }

    /**
     * @description delete old integration request records based on configuration..
     */
    public static void deleteOldRecords() {
        service().deleteOldRecords();
    }
}