/**
 * @author Doordash
 * @date   02/27/2024
 * @description This is the service class for MDS Sync Events service related logic
 */
public with sharing class MDSSyncEventsService {

    private static IMDSSyncEventsService service() {
        return (IMDSSyncEventsService) Application.Service.newInstance(IMDSSyncEventsService.class);
    }

     /**
     * @description Process MDS Updates method
     * @param integrationRequestIdsToProcess
     */
    public static void processMDSUpdates(Set<Id> integrationRequestIdsToProcess) {
        service().processMDSUpdates(integrationRequestIdsToProcess);
    }
}