/**
 * @author Deloitte
 * @date 06/20/2024
 * @description Merchant Orders interface to add domain class methods.
 */
public interface IMerchantOrders extends fflib_ISObjects {
    /**
     * @description It is used to update Merchant Order fields based on newly updated Vendor.
     * @JIRA# LEM-20315
     * @param merchantOrders
     */
    void resetMerchantOrdersOnVendorChange(List<MX_Order__c> merchantOrders);

    /**
     * @description It is used to update Status of Merchant Order to 'Not Applicable' for Merchant Order
     * where Vendor is 'Denali' and Type of Request is 'Return'.
     * @JIRA# LEM-14703
     * @param merchantOrders
     */
    void updateMerchantOrderStatus(List<MX_Order__c> merchantOrders);
}