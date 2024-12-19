/**
 * @author Deloitte
 * @date 09/4/2023
 * @description Interface for SubscriptionRateChangeService.
 */
public interface ISubscriptionRateChangeService {
    /**
     * @description This method is used to set Subscription Rate change to Complete once associated
     * Subscription and Primary Order Products are updated with correct active rates.
     * @param arpAppliedPrimaryOrderItems
     */
    void setSubscriptionRateChangeComplete(List<OrderItem> arpAppliedPrimaryOrderItems);
}