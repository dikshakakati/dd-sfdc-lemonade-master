/**
 * @author Deloitte
 * @date 05/28/2024
 * @description Interface for SObjectsStatusUpdateService.
 */
public interface ISObjectsStatusUpdateService {
    /**
     * @description It is used to handle Notifier Events to further process Ironclad Workflow Ids
     * from the received payload via Platform Event.
     * @param events
     */
    void handleNotifierEvents(List<Notifier__e> events);

    /**
     * @description It is used to update Status for the passed SObjects.
     * @param sObjects
     */
    void updateSObjectsStatusFieldValue(List<SObject> sObjects);
}