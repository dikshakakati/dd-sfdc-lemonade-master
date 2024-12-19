/**
 * @author Deloitte
 * @date 14/09/2023
 * @description ISubscriptionService Class.
 */
public interface ISubscriptionService {
    /**
     * @description This method is used to update active rates on Subscription based on Subscription Rate change.
     * @param approvedAndEffectiveSRCs
     */
    void updateSubscriptionActiveRatesFromSRC(
        List<Subscription_Rate_Change__c> approvedAndEffectiveSRCs
    );
}