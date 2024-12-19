/**
 * @author Deloitte
 * @date 06/04/2024
 * @description Service class for Parent Work Orders creation related logic.
 */
public inherited sharing class WorkOrderCreationTriggerService {
    /**
     * @description It is used to create platform event for Storefront
     * and Marketplace Subscriptions.
     * @JIRA# LEM-15362
     * @param sObjectIds
     * @param eventTopicName
     */
    public static void initiateWorkOrderCreation(Set<Id> sObjectIds, String eventTopicName) {
        service().initiateWorkOrderCreation(sObjectIds, eventTopicName);
    }

    /**
     * @description It is used to fire Onboarding Events Platform Event for
     * Work Order creation.
     * @param sObjectIds
     * @param eventTopicName
     */
    public static void fireonboardingActivationsEventsForWorkOrderCreation(
        Set<Id> sObjectIds,
        String eventTopicName
    ) {
        service().fireonboardingActivationsEventsForWorkOrderCreation(sObjectIds, eventTopicName);
    }

    /**
     * @description It creates instance of WorkOrderCreationTriggerServiceImpl class.
     * @return IWorkOrderCreationTriggerService
     */
    private static IWorkOrderCreationTriggerService service() {
        return (IWorkOrderCreationTriggerService) Application.SERVICE.newInstance(
            IWorkOrderCreationTriggerService.class
        );
    }
}