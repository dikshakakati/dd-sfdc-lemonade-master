/**
 * @author Deloitte
 * @date 04/23/2024
 * @description Service class for Merchant Order related logic.
 */
public inherited sharing class MerchantOrdersService {
    /**
     * @description It initiates the tablet integration process based on the passed orders.
     * @JIRA# LEM-13506
     * @param mxOrders
     */
    public static void initiateTabletIntegrationOnOrderCreation(List<MX_Order__c> mxOrders) {
        service().initiateTabletIntegrationOnOrderCreation(mxOrders);
    }

    /**
     * @description It reevaluates the Mx Order Items based on Vendor change.
     * @JIRA# LEM-20315
     * @param merchantOrders
     */
    public static void reevaluateMerchantOrderItemsOnVendorChange(
        List<MX_Order__c> merchantOrders
    ) {
        service().reevaluateMerchantOrderItemsOnVendorChange(merchantOrders);
    }

    /**
     * @description It is used to get static configurations.
     * @param merchantOrders
     */
    public static void updateStatusModifiedDate(List<MX_Order__c> merchantOrders) {
        service().updateStatusModifiedDate(merchantOrders);
    }

    /**
     * @description It updates MxOrders 'Return_Label_Status__c' value based on email results.
     * @JIRA# LEM-14703
     * @param failedMxOrderIds
     * @param passedMxOrderIds
     */
    public static void updateMxOrdersReturnLabelStatusBasedOnEmailResults(
        Set<Id> failedMxOrderIds,
        Set<Id> passedMxOrderIds
    ) {
        service()
            .updateMxOrdersReturnLabelStatusBasedOnEmailResults(failedMxOrderIds, passedMxOrderIds);
    }

    /**
     * @description It enables manual retry of interface transactions.
     * @JIRA# LEM-13497
     * @param mxOrders
     */
    @InvocableMethod(label='Retry Payload Generation')
    public static void retryPayloadGeneration(List<MX_Order__c> mxOrders) {
        service().retryPayloadGeneration(mxOrders);
    }

    /**
     * @description - Returns an instance of IMerchantOrdersService.
     * @JIRA# LEM-13506
     * @return IMerchantOrdersService
     */
    private static IMerchantOrdersService service() {
        return (IMerchantOrdersService) Application.SERVICE.newInstance(
            IMerchantOrdersService.class
        );
    }
}