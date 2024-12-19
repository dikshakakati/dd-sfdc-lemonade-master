/**
 * @author Deloitte
 * @date 09/4/2023
 * @description Service class for SubscriptionRateChangeService.
 */
public class SubscriptionRateChangeService {
    /**
     * @description This method is used to set Subscription Rate change to Complete once associated
     * Subscription and Primary Order Products are updated with correct active rates.
     * @param arpAppliedPrimaryOrderItems
     */
    public static void setSubscriptionRateChangeComplete(
        List<OrderItem> arpAppliedPrimaryOrderItems
    ) {
        service().setSubscriptionRateChangeComplete(arpAppliedPrimaryOrderItems);
    }

    /**
     * @description It creates instance of SubscriptionRateChangeServiceImpl class.
     * @return ISubscriptionRateChangeService - return instance of SubscriptionRateChangeServiceImpl
     */
    private static ISubscriptionRateChangeService service() {
        return (ISubscriptionRateChangeService) Application.SERVICE.newInstance(
            ISubscriptionRateChangeService.class
        );
    }
}