/**
 * @author Deloitte
 * @date 04/23/2024
 * @description Interface of service class for Merchant Order related logic.
 */
public interface IMerchantOrdersService {
    /**
     * @description It initiates the tablet integration process based on the passed orders.
     * @param mxOrders
     */
    void initiateTabletIntegrationOnOrderCreation(List<MX_Order__c> mxOrders);

    /**
     * @description It reevaluates the Mx Order Items based on Vendor change.
     * @param merchantOrders
     */
    void reevaluateMerchantOrderItemsOnVendorChange(List<MX_Order__c> merchantOrders);

    /**
     * @description It is used to get static configurations.
     * @param merchantOrders
     */
    void updateStatusModifiedDate(List<MX_Order__c> merchantOrders);

    /**
     * @description It updates MxOrders 'Return_Label_Status__c' value based on email results.
     * @param failedMxOrderIds
     * @param passedMxOrderIds
     */
    void updateMxOrdersReturnLabelStatusBasedOnEmailResults(
        Set<Id> failedMxOrderIds,
        Set<Id> passedMxOrderIds
    );

    /**
     * @description It enables manual retry of interface transactions.
     * @JIRA# LEM-13497
     * @param mxOrders
     */
    void retryPayloadGeneration(List<MX_Order__c> mxOrders);
}