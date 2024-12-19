/**
 * @author Deloitte
 * @date 03/27/2024
 * @description Interface of service class for Email to Lead Service.
 */
public interface IEmailToLeadService {
    /**
     * @description It creates Email Message and Lead record based on
     * the received inbound email.
     * @param inboundEmail
     */
    void initiateLeadCreationFromInboundEmail(Messaging.InboundEmail inboundEmail);
}