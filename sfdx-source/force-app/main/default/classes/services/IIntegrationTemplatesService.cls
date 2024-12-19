/**
 * @author Deloitte
 * @date 04/21/2024
 * @description Interface of service class for Integration Templates related logic.
 */
public interface IIntegrationTemplatesService {
    /**
     * @description This method is used to handle the published emailOutboundIntegrationEvents.
     * @param emailOutboundIntegrationEvents List of platform events with payload.
     */
    void handleEmailOutboundIntegrationEvents(
        List<Email_Outbound_Integration__e> emailOutboundIntegrationEvents
    );

    /**
     * @description It initiates criteria evaluation process based on
     * SObject type of received SObject Ids.
     * @param sObjectIds
     */
    void initiateIntegrationTemplateCriteriaEvaluation(Set<Id> sObjectIds);
}