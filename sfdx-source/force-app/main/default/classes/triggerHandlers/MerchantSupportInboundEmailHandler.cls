/**
 * @author Deloitte
 * @date 11/22/2022
 * @description Handler class to process inbound emails.
 */
public class MerchantSupportInboundEmailHandler implements Messaging.InboundEmailHandler {
    /**
     * @description It is used to process inbound emails sent to
     * Merchant Support email service address.
     * @JIRA LEM-3548
     * @param inboundEmail
     * @param inboundEnvelope
     * @return Messaging.InboundEmailResult
     */
    public Messaging.InboundEmailResult handleInboundEmail(
        Messaging.InboundEmail inboundEmail,
        Messaging.InboundEnvelope inboundEnvelope
    ) {
        Messaging.InboundEmailResult inboundEmailResult = new Messaging.InboundEmailResult();
        MerchantSupportInboundEmailService.createEmailMessagesOnWorkOrders(
            new List<Messaging.InboundEmail>{ inboundEmail }
        );
        inboundEmailResult.success = true;
        return inboundEmailResult;
    }
}