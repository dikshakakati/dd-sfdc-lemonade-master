/**
 * @author Deloitte
 * @date 05/17/2024
 * @description Interface of service class for sending return label emails to Merchants.
 */
public interface IMxReturnLabelEmailService {
    /**
     * @description It generates email messages based on Return labels
     * (Shipping label, AWB label and Invoice) attached to the merchant orders
     * and sends the email message to the merchants.
     * @param mxOrdersWithReturnLabels
     */
    void sendReturnLabelEmailsToMerchants(List<MX_Order__c> mxOrdersWithReturnLabels);
}