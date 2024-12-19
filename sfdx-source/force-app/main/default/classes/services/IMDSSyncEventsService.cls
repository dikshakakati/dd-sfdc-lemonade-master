/**
 * @author Doordash
 * @date   02/27/2024
 * @description This is the service interface for MDS Sync events service
 */
public interface IMDSSyncEventsService {
    /**
     * @description Process MDS Updates method
     * @param integrationRequestIdsToProcess
     */
    void processMDSUpdates(Set<Id> integrationRequestIdsToProcess);
}