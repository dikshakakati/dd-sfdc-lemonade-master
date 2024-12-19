/**
 * @author Deloitte
 * @date 10/03/2022
 * @description Service implementation class for Notifier Events payload generation related logic.
 * It is currently being used for generating multiple payloads for the Notifier Events.
 * It can be extended for generating payloads for other integrations in the future.
 */
public inherited sharing class NotifierEventsPayloadGenerationSrvcImpl implements INotifierEventsPayloadGenerationService {
    /**
     * @description It creates payload with the passed sObject Ids according to the passed
     * chunk size.
     * @JIRA# LEM-3255
     * @param sObjectIds
     * @param chunkSize
     * @return List<String>
     */
    public List<String> generateChunkedPayloadsBySobjectIds(Set<Id> sObjectIds, Integer chunkSize) {
        List<String> payloads = new List<String>();
        Integer iterator = 0;
        Integer endIndex = chunkSize;
        List<Id> sObjectIdsToProcess = new List<Id>(sObjectIds);
        List<Id> tempIds;
        while (iterator < sObjectIdsToProcess.size()) {
            tempIds = new List<Id>();
            for (Object obj : filterObjsByChunkSize(endIndex, iterator, sObjectIdsToProcess)) {
                tempIds.add((Id) String.valueOf(obj));
            }
            payloads.add(JSON.serialize(tempIds));
            iterator += chunkSize;
            endIndex += chunkSize;
        }
        return payloads;
    }

    /**
     * @description It creates payload with the passed objects according to the passed
     * chunk size.
     * @param objs
     * @param chunkSize
     * @return List<String>
     */
    public List<String> generateChunkedPayloadsByObjects(Set<Object> objs, Integer chunkSize) {
        List<String> payloads = new List<String>();
        Integer iterator = 0;
        Integer endIndex = chunkSize;
        List<Object> objsToProcess = new List<Object>(objs);
        while (iterator < objsToProcess.size()) {
            payloads.add(JSON.serialize(filterObjsByChunkSize(endIndex, iterator, objsToProcess)));
            iterator += chunkSize;
            endIndex += chunkSize;
        }
        return payloads;
    }

    /**
     * @description It creates payload with the passed SObjects according to the passed
     * chunk size.
     * @param sObjects
     * @param chunkSize
     * @return List<String>
     */
    public List<String> generateChunkedPayloadsBySObjects(
        Set<SObject> sObjects,
        Integer chunkSize
    ) {
        List<String> payloads = new List<String>();
        Integer iterator = 0;
        Integer endIndex = chunkSize;
        List<SObject> sObjectsToProcess = new List<SObject>(sObjects);
        while (iterator < sObjectsToProcess.size()) {
            payloads.add(
                JSON.serialize(filterObjsByChunkSize(endIndex, iterator, sObjectsToProcess))
            );
            iterator += chunkSize;
            endIndex += chunkSize;
        }
        return payloads;
    }

    /**
     * @description It is used to filter the Ids according to the chunk size.
     * @param endIndex
     * @param startIndex
     * @param objsToProcess
     * @return List<Object>
     */
    private List<Object> filterObjsByChunkSize(
        Integer endIndex,
        Integer startIndex,
        List<Object> objsToProcess
    ) {
        List<Object> filteredObjs = new List<Object>();
        for (Integer index = startIndex; index < endIndex; index++) {
            if (index >= objsToProcess.size()) {
                continue;
            }
            filteredObjs.add(objsToProcess[index]);
        }
        return filteredObjs;
    }
}