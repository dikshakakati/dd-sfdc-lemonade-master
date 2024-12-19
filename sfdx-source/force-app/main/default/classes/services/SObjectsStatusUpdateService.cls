/**
 * @author Deloitte
 * @date 05/11/2024
 * @description Service class for SOjectsStatusUpdateServieImpl related logic.
 */
public inherited sharing class SObjectsStatusUpdateService implements IHandleNotifierEvents {
    /**
     * @description It is used for getting Work Steps Ids from the payload
     * received via Platform Event.
     * @JIRA# LEM-15269
     * @param events
     */
    public static void execute(List<Notifier__e> events) {
        service().handleNotifierEvents(events);
    }

    /**
     * @description It is used to update Status for the passed SObjects.
     * @param sObjects
     */
    public static void updateSObjectsStatusFieldValue(List<SObject> sObjects) {
        service().updateSObjectsStatusFieldValue(sObjects);
    }

    /**
     * @description - Calling Unit Of Work Framework
     * @JIRA# LEM-15269
     * @return ISObjectsStatusUpdateService
     */
    private static ISObjectsStatusUpdateService service() {
        return (ISObjectsStatusUpdateService) Application.Service.newInstance(
            ISObjectsStatusUpdateService.class
        );
    }
}