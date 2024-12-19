/**
 * @author Deloitte
 * @date 04/21/2024
 * @description Service class for Integration Templates related logic.
 */
public inherited sharing class IntegrationTemplatesService implements IHandleEmailOutboundIntegrationsEvents {
    /**
     * @description It is used to handle the published Email_Outbound_Integration__e events.
     * @param emailOutboundIntegrationEvents list of platform events with payload
     */
    public static void execute(List<Email_Outbound_Integration__e> emailOutboundIntegrationEvents) {
        service().handleEmailOutboundIntegrationEvents(emailOutboundIntegrationEvents);
    }

    /**
     * @description It initiates criteria evaluation process based on
     * SObject type of received SObject Ids.
     * @JIRA# LEM-13778
     * @param sObjectIds
     */
    public static void initiateIntegrationTemplateCriteriaEvaluation(Set<Id> sObjectIds) {
        service().initiateIntegrationTemplateCriteriaEvaluation(sObjectIds);
    }

    /**
     * @description - Creates and returns instance of IIntegrationTemplatesService
     * to call methods from IntegrationTemplatesServiceImpl.
     * @JIRA# LEM-13778
     * @return IIntegrationTemplatesService
     */
    private static IIntegrationTemplatesService service() {
        return (IIntegrationTemplatesService) Application.SERVICE.newInstance(
            IIntegrationTemplatesService.class
        );
    }
}