/**
 * @author Deloitte
 * @date 09/4/2023
 * @description Interface for RateChangeRequestService.
 */
public interface IRateChangeRequestService {
    /**
     * @description This method is used to complete the Rate Change Request based on Subscription Rate change.
     * @param completedSRCs
     */
    void setRateChangeRequestComplete(List<Subscription_Rate_Change__c> completedSRCs);

    /**
     * @description This method is used to update the Rate Change Request Store Update Flag to true
     * once all the store Accounts are updated in AccountUpdateForActiveRatesBatch.
     * @param rateChangeRequestId
     */
    void setRateChangeRequestStoreUpdatedFlagTrue(Id rateChangeRequestId);

    /**
     * @description Generates Activation Order Creation Event once Rate Change Request Activation Status is set to Ready For Activation.
     * @param rcrIds
     */
    void publishCreateActivationOrdersNotifierEvent(Set<Id> rcrIds);

    /**
     * @description This method is used to handle the published Notifier events.
     * @param notifierEvents list of platform events with payload
     */
    void handleNotifierEvents(List<Notifier__e> notifierEvents);

    /**
     * @description It is used to update Rate Change Requests
     * to cancel status.
     * @param rateChangeRequests List of Rate Change Requests.
     */
    void updateRateChangeRequestToCancelled(List<Rate_Change_Request__c> rateChangeRequests);
}