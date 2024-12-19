/**
 * @author Deloitte
 * @date 04/28/2024
 * @description Service Class for Merchant Order Items.
 */
public inherited sharing class MerchantOrderItemsService {
    /**
     * @description It is used to create Mx Order Items
     * @param merchantOrders
     */
    public static void createMxOrderItems(List<MX_Order__c> merchantOrders) {
        service().createMxOrderItems(merchantOrders);
    }

    /**
     * @description It creates instance of MerchantOrderItemServiceImpl instance.
     * @return IMerchantOrderItemsService
     */
    private static IMerchantOrderItemsService service() {
        return (IMerchantOrderItemsService) Application.SERVICE.newInstance(
            IMerchantOrderItemsService.class
        );
    }
}