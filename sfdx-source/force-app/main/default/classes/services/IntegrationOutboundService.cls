/**
 * @author Deloitte
 * @date 04/02/2024
 * @description Service class for outbound integrations with external systems.
 */
public inherited sharing class IntegrationOutboundService implements IHandleOnboardingActivationsEvents {
    /**
     * @description It enables manual retry of interface transactions.
     * @JIRA# LEM-13497
     * @param mxInterfaceTransactions
     */
    @InvocableMethod(label='Retry Interface Transactions')
    public static void retryInterfaceTransactions(List<String> mxInterfaceTransactions) {
        service().retryInterfaceTransactions(mxInterfaceTransactions);
    }

    /**
     * @description It handles and process published Onboarding Activations Events
     * based on event topic and paylaod.
     * @JIRA# LEM-13497
     * @param onboardingActivationsEvents
     */
    public static void execute(List<Onboarding_Activation__e> onboardingActivationsEvents) {
        service().handleOnboardingActivationsEvents(onboardingActivationsEvents);
    }

    /**
     * @description It sends REST API callout to Mulesoft using named credentials
     * to initiate Activations checklist validation.
     * @JIRA# LEM-13305
     * @param integrationUseCase
     * @param outboundPayloads
     */
    public static void sendAPICalloutWithRequestPayload(
        String integrationUseCase,
        List<String> outboundPayloads
    ) {
        service().sendAPICalloutWithRequestPayload(integrationUseCase, outboundPayloads);
    }

    /**
     * @description It creates instance of IntegrationOutboundServiceImpl class.
     * @JIRA# LEM-13305
     * @return IIntegrationOutboundService - return instance of IntegrationOutboundServiceImpl
     */
    private static IIntegrationOutboundService service() {
        return (IIntegrationOutboundService) Application.SERVICE.newInstance(
            IIntegrationOutboundService.class
        );
    }
}