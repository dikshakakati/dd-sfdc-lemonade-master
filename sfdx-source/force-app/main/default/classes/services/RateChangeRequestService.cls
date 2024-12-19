/**
 * @author Deloitte
 * @date 09/4/2023
 * @description Service class for RateChangeRequestServiceImpl.
 */
public class RateChangeRequestService implements IHandleNotifierEvents {
    /**
     * @description This method is used to complete the Rate Change Request based on Subscription Rate change.
     * @param completedSRCs
     */
    public static void setRateChangeRequestComplete(
        List<Subscription_Rate_Change__c> completedSRCs
    ) {
        service().setRateChangeRequestComplete(completedSRCs);
    }

    /**
     * @description This method is used to update the Rate Change Request Store Update Flag to true
     * once all the store Accounts are updated in AccountUpdateForActiveRatesBatch.
     * @param rateChangeRequestId
     */
    public static void setRateChangeRequestStoreUpdatedFlagTrue(Id rateChangeRequestId) {
        service().setRateChangeRequestStoreUpdatedFlagTrue(rateChangeRequestId);
    }

    /**
     * @description Generates Activation Order Creation Event once Rate Change Request Activation Status is set to Ready For Activation.
     * @param rcrIds
     */
    public static void publishCreateActivationOrdersNotifierEvent(Set<Id> rcrIds) {
        service().publishCreateActivationOrdersNotifierEvent(rcrIds);
    }

    /**
     * @description This method is used to handle the published Notifier events.
     * @param notifierEvents list of platform events with payload
     */
    public static void execute(List<Notifier__e> notifierEvents) {
        service().handleNotifierEvents(notifierEvents);
    }

    /**
     * @description It creates instance of RateChangeRequestServiceImpl class.
     * @return IRateChangeRequestService - return instance of RateChangeRequestServiceImpl
     */
    private static IRateChangeRequestService service() {
        return (IRateChangeRequestService) Application.SERVICE.newInstance(
            IRateChangeRequestService.class
        );
    }

    /**
     * @description It is used to update Rate Change Requests
     * to cancel status.
     * @param rateChangeRequests List of Rate Change Requests.
     */
    public static void updateRateChangeRequestToCancelled(
        List<Rate_Change_Request__c> rateChangeRequests
    ) {
        service().updateRateChangeRequestToCancelled(rateChangeRequests);
    }
}