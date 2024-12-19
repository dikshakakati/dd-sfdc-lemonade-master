/**
 * @author Deloitte
 * @date 10/26/2023
 * @description Service Class.
 */
public inherited sharing class PaymentAccountFieldsValidations {
    /**
     * @description It is used to validate the values on the payment account fields.
     * @JIRA# LEM-10692
     * @param paymentAccounts
     */
    public static void validatePaymentAccountFields(List<Payment_Account__c> paymentAccounts) {
        service().validatePaymentAccountFields(paymentAccounts);
    }

    /**
     * @description It is used to validate the account to payment account relations association
     * with the eligible payment account.
     * @param accountPaymentAccountRelations
     */
    public static void validateAccountToPaymentAccountRelation(
        List<Account_Payment_Account_Relation__c> accountPaymentAccountRelations
    ) {
        service().validateAccountToPaymentAccountRelation(accountPaymentAccountRelations);
    }

    /**
     * @description It creates instance of PaymentAccountFieldsValidations class.
     * @return IPaymentAccountFieldsValidations - return instance of PaymentAccountFieldsValidationsImpl
     */
    private static IPaymentAccountFieldsValidations service() {
        return (IPaymentAccountFieldsValidations) Application.SERVICE.newInstance(
            IPaymentAccountFieldsValidations.class
        );
    }
}