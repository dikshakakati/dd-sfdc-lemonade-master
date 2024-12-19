/**
 * @author Deloitte
 * @date 11/22/2022
 * @description Interface of service class for merchant support inbound email related logic.
 */
public interface IMerchantSupportInboundEmailService {
    /**
     * @description It creates Email Message records on Work Orders based on
     * the received inbound emails.
     * @param inboundEmails
     */
    void createEmailMessagesOnWorkOrders(List<Messaging.InboundEmail> inboundEmails);
}