/**
 * @author Deloitte
 * @date 10/26/2023
 * @description Interface to add PaymentAccountFieldsValidations service class methods.
 */
public interface IPaymentAccountFieldsValidations {
    /**
     * @description It is used to validate the values on the payment account fields.
     * @param paymentAccounts
     */
    void validatePaymentAccountFields(List<Payment_Account__c> paymentAccounts);

    /**
     * @description It is used to validate the account to payment account relations association
     * with the eligible payment account.
     * @param accountPaymentAccountRelations
     */
    void validateAccountToPaymentAccountRelation(
        List<Account_Payment_Account_Relation__c> accountPaymentAccountRelations
    );
}