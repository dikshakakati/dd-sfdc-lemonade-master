/**
 * @author Deloitte
 * @date 27/05/2022
 * @description Interface of service class for Tablet Case payload generation related logic.
 */
public interface ITabletCasePayloadGenerationService {
    /**
     * @description It is used for generating payload for Tablet Case integration
     * using the passed Store Account Ids.
     * It also passes the generated payload and topic for futher processing.
     * @param storeAccountIds
     * @param topicName
     */
    void generatePayloadUsingStoreAccountIds(Set<Id> storeAccountIds, String topicName);

    /**
     * @description It is used for generating payload for Tablet Case integration
     * using the passed WorkStep
     * It also passes the generated payload and topic for futher processing.
     * @param workSteps
     * @param topicName
     */
    void generatePayloadUsingWorkSteps(List<WorkStep> workSteps, String topicName);
}