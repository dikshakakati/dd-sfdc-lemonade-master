/**
 * @author Deloitte
 * @date 05/17/2024
 * @description Service class for sending return label emails to Merchants.
 */
public inherited sharing class MxReturnLabelEmailService {
    /**
     * @description It generates email messages based on Return labels
     * (Shipping label, AWB label and Invoice) attached to the merchant orders
     * and sends the email message to the merchants.
     * @JIRA# LEM-14703
     * @param mxOrdersWithReturnLabels
     */
    public static void sendReturnLabelEmailsToMerchants(
        List<MX_Order__c> mxOrdersWithReturnLabels
    ) {
        service().sendReturnLabelEmailsToMerchants(mxOrdersWithReturnLabels);
    }

    /**
     * @description It creates instance of MxReturnLabelEmailServiceImpl class.
     * @JIRA# LEM-14703
     * @return IMxReturnLabelEmailService - return instance of MxReturnLabelEmailServiceImpl
     */
    private static IMxReturnLabelEmailService service() {
        return (IMxReturnLabelEmailService) Application.SERVICE.newInstance(
            IMxReturnLabelEmailService.class
        );
    }
}