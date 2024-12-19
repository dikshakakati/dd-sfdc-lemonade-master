/**
 * @author Deloitte
 * @date 10/03/2022
 * @description Interface of service class for Notifier Events payload generation related logic.
 */
public interface INotifierEventsPayloadGenerationService {
    /**
     * @description It creates payload with the passed sObject Ids according to the passed
     * chunk size.
     * @param sObjectIds
     * @param chunkSize
     * @return List<String>
     */
    List<String> generateChunkedPayloadsBySobjectIds(Set<Id> sObjectIds, Integer chunkSize);

    /**
     * @description It creates payload with the passed objects according to the passed
     * chunk size.
     * @param objs
     * @param chunkSize
     * @return List<String>
     */
    List<String> generateChunkedPayloadsByObjects(Set<Object> objs, Integer chunkSize);

    /**
     * @description It creates payload with the passed SObjects according to the passed
     * chunk size.
     * @param sObjects
     * @param chunkSize
     * @return List<String>
     */
    List<String> generateChunkedPayloadsBySObjects(Set<SObject> sObjects, Integer chunkSize);
}