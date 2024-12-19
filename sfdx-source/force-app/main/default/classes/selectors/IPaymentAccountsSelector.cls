/**
 * @author Deloitte
 * @date 15/07/2022
 * @description Interface for PaymentAccountsSelector class methods.
 */
public interface IPaymentAccountsSelector extends fflib_ISObjectSelector {
    /**
     * @description It is used for getting Payment Accounts by the passed Ids.
     * @param paymentAccountId
     * @return List<Payment_Account__c>
     */
    List<Payment_Account__c> selectById(Set<Id> paymentAccountId);

    /**
     * @description Return Payment Account record by Id for Netsuite integration
     * @param paymentAccountId
     * @return Payment_Account__c
     */
    Payment_Account__c selectPaymentAccountByIdForNetsuiteIntegration(Id paymentAccountId);

    /**
     * @description It is used for getting related payment accounts
     * @JIRA# LEM-3121
     * @param accountIds
     * @return List<Payment_Account__c>
     */
    List<Payment_Account__c> selectRelatedBusinessAccounts(Set<Id> accountIds);

    /**
     * @description It queries Payment Accounts with 'Invoice' record type by passed list of Ids
     * @JIRA# LEM-10203
     * @param paymentAccountIds
     * @return List<Payment_Account__c>
     */
    List<Payment_Account__c> selectInvoicePaymentAccountsByIds(Set<Id> paymentAccountIds);
}