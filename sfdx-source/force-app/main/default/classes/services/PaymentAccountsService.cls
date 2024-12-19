/**
 * @author Deloitte
 * @date 10/07/2022
 * @description This is the service class for Payment Account related functionality.
 */
public inherited sharing class PaymentAccountsService {
    /**
     * @description Update Payment Account record for selected record Id.
     * @param paymentAccountRecord
     */
    public static void updatePaymentAccountWithSyncWithNetsuiteResponse(
        Payment_Account__c paymentAccountRecord
    ) {
        service().updatePaymentAccountWithSyncWithNetsuiteResponse(paymentAccountRecord);
    }

    /**
     * @description To process merged account child records
     * @param paymentAccounts
     */
    public static void processMergedAccountsRelatedRecords(
        List<Payment_Account__c> paymentAccounts
    ) {
        service().processMergedAccountsRelatedRecords(paymentAccounts);
    }

    /**
     * @description It creates Payment Accounts for the Business/Store Accounts received
     * with Mx Onboarding details.
     * @JIRA# LEM-15113
     * @param mxOnboardingLinks
     * @param mxBusinessAccountWrapper
     * @param mxStoreAccountWrapper
     */
    public static void createPaymentAccountsByMxOnboardingLinks(
        List<Mx_Onboarding_Link__c> mxOnboardingLinks,
        Map<Id, BusinessAccountWrapper> mxBusinessAccountWrapper,
        Map<Id, StoreDetailsWrapper> mxStoreAccountWrapper
    ) {
        service()
            .createPaymentAccountsByMxOnboardingLinks(
                mxOnboardingLinks,
                mxBusinessAccountWrapper,
                mxStoreAccountWrapper
            );
    }

    /**
     * @description It creates instance of PaymentAccountsServiceImpl  class.
     * @return IPaymentAccountsService
     */
    private static IPaymentAccountsService service() {
        return (IPaymentAccountsService) Application.Service.newInstance(
            IPaymentAccountsService.class
        );
    }
}