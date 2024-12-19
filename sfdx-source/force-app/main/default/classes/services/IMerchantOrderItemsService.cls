/**
 * @author Deloitte
 * @date 04/28/2024
 * @description Service Interface for Merchant Order Items Service.
 */
public interface IMerchantOrderItemsService {
    /**
     * @description It is used to create Mx Order Items
     * @param merchantOrders
     */
    void createMxOrderItems(List<MX_Order__c> merchantOrders);
}