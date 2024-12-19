/**
 * @author Deloitte
 * @date 03/27/2024
 * @description Service class for merchant support inbound email related logic.
 */
public inherited sharing class EmailToLeadService {
    /**
     * @description It creates Email Message records on Leads based on
     * the received inbound email.
     * @JIRA# LEM-13420
     * @param inboundEmail
     */
    public static void initiateLeadCreationFromInboundEmail(Messaging.InboundEmail inboundEmail) {
        service().initiateLeadCreationFromInboundEmail(inboundEmail);
    }

    /**
     * @description It creates instance of EmailToLeadServiceImpl class.
     * @JIRA# LEM-13420
     * @return IEmailToLeadService - return instance of EmailToLeadServiceImpl
     */
    private static IEmailToLeadService service() {
        return (IEmailToLeadService) Application.SERVICE.newInstance(IEmailToLeadService.class);
    }
}