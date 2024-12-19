/**
 * @author Deloitte
 * @date 04/23/2024
 * @description Interface of service class for Interface Transactions related logic.
 */
public interface IInterfaceTransactionsService {
    /**
     * @description This method is used to handle the published onboardingActivationsEvents.
     * @param onboardingActivationsEvents List of platform events with payload.
     */
    void handleOnboardingActivationsEvents(
        List<Onboarding_Activation__e> onboardingActivationsEvents
    );

    /**
     * @description It initiates outbound integration process
     * based on Interface Transaction records.
     * @param interfaceTransactions
     */
    void initiateOutboundIntegrationForinterfaceTransactions(
        List<Interface_Transaction__c> interfaceTransactions
    );

    /**
     * @description It updates Interface Transaction status based on Email payload REST API callout response.
     * @param failedInterfaceTransactionIds
     * @param passedInterfaceTransactionIds
     */
    void updateInterfaceTransactionStatusByOutboundCalloutResponse(
        Set<String> failedInterfaceTransactionIds,
        Set<String> passedInterfaceTransactionIds
    );

    /**
     * @description It updates Interface Transaction status based on REST API callout response.
     * @param failedMxOrderIds
     * @param passedMxOrderIds
     */
    void updateInterfaceTransactionStatusByResponse(
        Set<String> failedMxOrderIds,
        Set<String> passedMxOrderIds
    );
}