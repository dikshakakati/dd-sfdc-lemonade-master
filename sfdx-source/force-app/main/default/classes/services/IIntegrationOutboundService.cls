/**
 * @author Deloitte
 * @date 04/02/2024
 * @description Interface of service class for outbound integrations with external systems.
 */
public interface IIntegrationOutboundService extends IRetryableService {
    /**
     * @description It enables manual retry of interface transactions.
     * @param interfaceTransactionIds
     */
    void retryInterfaceTransactions(List<String> interfaceTransactionIds);

    /**
     * @description It handles and process published Onboarding Activations Events
     * based on event topic and paylaod.
     * @param onboardingActivationsEvents
     */
    void handleOnboardingActivationsEvents(
        List<Onboarding_Activation__e> onboardingActivationsEvents
    );

    /**
     * @description It sends REST API callout to Mulesoft using named credentials
     * to initiate Activations checklist validation.
     * @param integrationUseCase
     * @param outboundPayloads
     */
    void sendAPICalloutWithRequestPayload(String integrationUseCase, List<String> outboundPayloads);

    /**
     * @description method to be implemented in child class.
     * @param interfaceTransactionsForRetry - Interface_Transaction__c records for retry.
     */
    void retry(List<Interface_Transaction__c> interfaceTransactionsForRetry);

    /**
     * @description method to be implemented in child class.
     * @param interfaceTransactionId - Interface_Transaction__c record Id for retry.
     */
    void retry(String interfaceTransactionId);
}