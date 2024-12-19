/**
 * @author Deloitte
 * @date 27/05/2022
 * @description Service class for Tablet Case payload generation related logic.
 */
public inherited sharing class TabletCasePayloadGenerationService {
    /**
     * @description It is used for generating payload for Tablet Case integration
     * using the passed Store Account Ids.
     * It also passes the generated payload and topic for futher processing.
     * @param storeAccountIds
     * @param topicName
     */
    public static void generatePayloadUsingStoreAccountIds(
        Set<Id> storeAccountIds,
        String topicName
    ) {
        service().generatePayloadUsingStoreAccountIds(storeAccountIds, topicName);
    }

    /**
     * @description It is used for generating payload for Tablet Case integration
     * using the passed WorkStep
     * It also passes the generated payload and topic for futher processing.
     * @param workSteps
     * @param topicName
     */
    public static void generatePayloadUsingWorkSteps(List<WorkStep> workSteps, String topicName) {
        service().generatePayloadUsingWorkSteps(workSteps, topicName);
    }

    /**
     * @description It creates instance of TabletCasePayloadGenerationServiceImpl class.
     * @return ITabletCasePayloadGenerationService - return instance of TabletCasePayloadGenerationServiceImpl
     */
    private static ITabletCasePayloadGenerationService service() {
        return (ITabletCasePayloadGenerationService) Application.Service.newInstance(
            ITabletCasePayloadGenerationService.class
        );
    }
}