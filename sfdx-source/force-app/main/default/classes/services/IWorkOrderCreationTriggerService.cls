/**
 * @author Deloitte
 * @date 06/04/2024
 * @description Service Interface for Parent Work Orders creation related logic.
 */
public interface IWorkOrderCreationTriggerService {
    /**
     * @description It fires platform events for Storefront
     * and Marketplace Subscriptions.
     * @JIRA# LEM-15362
     * @param sObjectIds
     * @param eventTopicName
     */
    void initiateWorkOrderCreation(Set<Id> sObjectIds, String eventTopicName);

    /**
     * @description It is used to fire Onboarding Events Platform Event for
     * Work Order creation.
     * @param sObjectIds
     * @param eventTopicName
     */
    void fireonboardingActivationsEventsForWorkOrderCreation(
        Set<Id> sObjectIds,
        String eventTopicName
    );
}