/**
 * @author Deloitte
 * @date 11/22/2022
 * @description Service class for merchant support inbound email related logic.
 */
public inherited sharing class MerchantSupportInboundEmailService {
    /**
     * @description It creates Email Message records on Work Orders based on
     * the received inbound emails.
     * @JIRA# LEM-3548
     * @param inboundEmails
     */
    public static void createEmailMessagesOnWorkOrders(List<Messaging.InboundEmail> inboundEmails) {
        service().createEmailMessagesOnWorkOrders(inboundEmails);
    }

    /**
     * @description It creates instance of MerchantSupportInboundEmailServiceImpl class.
     * @JIRA# LEM-3548
     * @return IMerchantSupportInboundEmailService - return instance of MerchantSupportInboundEmailServiceImpl
     */
    private static IMerchantSupportInboundEmailService service() {
        return (IMerchantSupportInboundEmailService) Application.SERVICE.newInstance(
            IMerchantSupportInboundEmailService.class
        );
    }
}