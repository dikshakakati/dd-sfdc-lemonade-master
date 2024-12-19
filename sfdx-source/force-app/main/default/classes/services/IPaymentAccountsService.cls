/**
 * @author Deloitte
 * @date 10/07/2022
 * @description Interface for Payment Account Object.
 */
public interface IPaymentAccountsService {
    /**
     * @description Update Payment Account record for selected record Id.
     * @param paymentAccountRecord
     */
    void updatePaymentAccountWithSyncWithNetsuiteResponse(Payment_Account__c paymentAccountRecord);

    /**
     * @description To process merged account child records
     * @param paymentAccounts
     */
    void processMergedAccountsRelatedRecords(List<Payment_Account__c> paymentAccounts);

    /**
     * @description It creates Payment Accounts for the Business/Store Accounts received
     * with Mx Onboarding details.
     * @param mxOnboardingLinks
     * @param mxBusinessAccountWrapper
     * @param mxStoreAccountWrapper
     */
    void createPaymentAccountsByMxOnboardingLinks(
        List<Mx_Onboarding_Link__c> mxOnboardingLinks,
        Map<Id, BusinessAccountWrapper> mxBusinessAccountWrapper,
        Map<Id, StoreDetailsWrapper> mxStoreAccountWrapper
    );
}