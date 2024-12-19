/**
 * @author Deloitte
 * @date 10/07/2022
 * @description Interface for Account_Payment_Account_Relation__c selector class methods.
 */
public interface IAccountPaymentAccountRelationsSelector extends fflib_ISObjectSelector {
    /**
     * @description select account to payment account relation
     * @param accountToPaymentRelationIds
     * @return List<Account_Payment_Account_Relation__c>
     */
    List<Account_Payment_Account_Relation__c> selectById(Set<Id> accountToPaymentRelationIds);

    /**
     * @description It queries Account To Payment Account Relations associated with the passed
     * Account Ids and Payment Account Record Types.
     * @param accountIds
     * @param paymentAccountRecordTypes
     * @return List<Account_Payment_Account_Relation__c>
     */
    List<Account_Payment_Account_Relation__c> selectByAccountIdsAndPaymentAccountRecordTypes(
        Set<Id> accountIds,
        Set<String> paymentAccountRecordTypes
    );

    /**
     * @description It is used to select the aggregate count of account to payment account relation
     * with account's billing country code by the passed payment account ids.
     * @param paymentAccountIds
     * @return Aggregate[]
     */
    Aggregate[] selectCountOfAccountPaymentAccountRelationsByAccountBillingCountryCode(
        Set<Id> paymentAccountIds
    );
}