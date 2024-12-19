/**
 * @author Deloitte
 * @date 04/23/2024
 * @description Service class for Interface Transactions related logic.
 */
public inherited sharing class InterfaceTransactionsService implements IHandleOnboardingActivationsEvents {
    public static Boolean isManualRetry = false;

    /**
     * @description It is used to handle the published Onboarding_Activation__e events.
     * @JIRA# LEM-13506
     * @param onboardingActivationEvents list of platform events with payload
     */
    public static void execute(List<Onboarding_Activation__e> onboardingActivationEvents) {
        service().handleOnboardingActivationsEvents(onboardingActivationEvents);
    }

    /**
     * @description It initiates the tablet integration process based on the passed orders.
     * @JIRA# LEM-13506
     * @param interfaceTransactions
     */
    public static void initiateOutboundIntegrationForinterfaceTransactions(
        List<Interface_Transaction__c> interfaceTransactions
    ) {
        service().initiateOutboundIntegrationForinterfaceTransactions(interfaceTransactions);
    }

    /**
     * @description - Returns an instance of IInterfaceTransactionsService.
     * @JIRA# LEM-13506
     * @return IInterfaceTransactionsService
     */
    private static IInterfaceTransactionsService service() {
        return (IInterfaceTransactionsService) Application.SERVICE.newInstance(
            IInterfaceTransactionsService.class
        );
    }

    /**
     * @description It updates Interface Transaction status based on Email payload REST API callout response.
     * @JIRA# LEM-13778
     * @param failedInterfaceTransactionIds
     * @param passedInterfaceTransactionIds
     */
    public static void updateInterfaceTransactionStatusByOutboundCalloutResponse(
        Set<String> failedInterfaceTransactionIds,
        Set<String> passedInterfaceTransactionIds
    ) {
        service()
            .updateInterfaceTransactionStatusByOutboundCalloutResponse(
                failedInterfaceTransactionIds,
                passedInterfaceTransactionIds
            );
    }

    /**
     * @description It updates Interface Transaction status based on REST API callout response.
     * @JIRA# LEM-13506
     * @param failedMxOrderIds
     * @param passedMxOrderIds
     */
    public static void updateInterfaceTransactionStatusByResponse(
        Set<String> failedMxOrderIds,
        Set<String> passedMxOrderIds
    ) {
        service().updateInterfaceTransactionStatusByResponse(failedMxOrderIds, passedMxOrderIds);
    }
}