/**
 * @author Deloitte
 * @date 14/09/2023
 * @description SubscriptionService Class.
 */
public class SubscriptionService {
    /**
     * @description This method is used to update active rates on Subscription based on Subscription Rate change.
     * @param approvedAndEffectiveSRCs
     */
    public static void updateSubscriptionActiveRatesFromSRC(
        List<Subscription_Rate_Change__c> approvedAndEffectiveSRCs
    ) {
        service().updateSubscriptionActiveRatesFromSRC(approvedAndEffectiveSRCs);
    }

    /**
     * @description It creates instance of SubscriptionRateChangeServiceImpl class.
     * @return ISubscriptionRateChangeService - return instance of SubscriptionRateChangeServiceImpl
     */
    private static ISubscriptionService service() {
        return (ISubscriptionService) Application.SERVICE.newInstance(ISubscriptionService.class);
    }
}