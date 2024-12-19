/**
 * @author Deloitte
 * @date 10/03/2022
 * @description Service class for Notifier Events payload generation related logic.
 */
public inherited sharing class NotifierEventsPayloadGenerationService {
    /**
     * @description It creates payload with the passed sObject Ids according to the passed
     * chunk size.
     * @JIRA# LEM-3255
     * @param sObjectIds
     * @param chunkSize
     * @return List<String>
     */
    public static List<String> generateChunkedPayloadsBySobjectIds(
        Set<Id> sObjectIds,
        Integer chunkSize
    ) {
        return service().generateChunkedPayloadsBySobjectIds(sObjectIds, chunkSize);
    }

    /**
     * @description It creates payload with the passed objects according to the passed
     * chunk size.
     * @param objs
     * @param chunkSize
     * @return List<String>
     */
    public static List<String> generateChunkedPayloadsByObjects(
        Set<Object> objs,
        Integer chunkSize
    ) {
        return service().generateChunkedPayloadsByObjects(objs, chunkSize);
    }

    /**
     * @description It creates payload with the passed SObjects according to the passed
     * chunk size.
     * @param sObjects
     * @param chunkSize
     * @return List<String>
     */
    public static List<String> generateChunkedPayloadsBySObjects(
        Set<SObject> sObjects,
        Integer chunkSize
    ) {
        return service().generateChunkedPayloadsBySObjects(sObjects, chunkSize);
    }
    /**
     * @description It creates instance of NotifierEventsPayloadGenerationSrvcImpl class.
     * @return INotifierEventsPayloadGenerationService - instance of NotifierEventsPayloadGenerationSrvcImpl
     */
    private static INotifierEventsPayloadGenerationService service() {
        return (INotifierEventsPayloadGenerationService) Application.Service.newInstance(
            INotifierEventsPayloadGenerationService.class
        );
    }
}