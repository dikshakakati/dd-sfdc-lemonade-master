/**
 * @author Deloitte
 * @date 03/27/2024
 * @description Handler class to process inbound emails.
 */
public class InboundLeadEmailHandler implements Messaging.InboundEmailHandler {
    /**
     * @description It is used to process inbound emails and create leads utilising
     * Email To Lead Service class.
     * @JIRA LEM-13420
     * @param inboundEmail
     * @param inboundEnvelope
     * @return Messaging.InboundEmailResult
     */
    public Messaging.InboundEmailResult handleInboundEmail(
        Messaging.InboundEmail inboundEmail,
        Messaging.InboundEnvelope inboundEnvelope
    ) {
        Messaging.InboundEmailResult inboundEmailResult = new Messaging.InboundEmailResult();
        EmailToLeadService.initiateLeadCreationFromInboundEmail(inboundEmail);
        inboundEmailResult.success = true;
        return inboundEmailResult;
    }
}