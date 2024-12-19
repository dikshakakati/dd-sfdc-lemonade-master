/**
 * @author Deloitte
 * @date 10/30/2023
 * @description This is the test class for Account Payment Account Relation Trigger handler class.
 */
@isTest(seeAllData=false)
public class APARHandlerTest {
    private static final String CONSTRUCTOR_ERROR_MESSAGE = 'The two constructs should not be similar';
    /**
     * @description It is used to test method call on Instantiation.
     */
    @IsTest
    private static void testWhenClassInstantiatesThenCheck() {
        //Constructor Call
        List<Account_Payment_Account_Relation__c> accountPaymentAccountRelationList = new List<Account_Payment_Account_Relation__c>();
        AccountPaymentAccountRelationsHandler accountPaymentAccountRelationHandlerObject = new AccountPaymentAccountRelationsHandler(
            accountPaymentAccountRelationList
        );
        //Inner Class Constructor Call
        AccountPaymentAccountRelationsHandler.Constructor objConstructor = new AccountPaymentAccountRelationsHandler.Constructor();
        objConstructor.construct(accountPaymentAccountRelationList);
        System.assertNotEquals(
            accountPaymentAccountRelationHandlerObject,
            objConstructor.construct(accountPaymentAccountRelationList),
            CONSTRUCTOR_ERROR_MESSAGE
        );
    }

    /**
     * @description It is used to test whether the trigger handler is called on insert.
     * Suppressed Warnings since mock verify method does not require system assert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAccountPaymentAccountRelationTriggerIsCalledThenAccountPaymentAccountRelationIsInserted() {
        Id paymentAccountId = Fake.generateId(Payment_Account__c.class);
        Id accountId = Fake.generateId(Account.class);
        Account_Payment_Account_Relation__c accountPaymentAccountRelation = new Account_Payment_Account_Relation__c(
            Payment_Account__c = paymentAccountId,
            Account__c = accountId
        );

        List<Account_Payment_Account_Relation__c> accountPaymentAccountRelations = new List<Account_Payment_Account_Relation__c>();
        accountPaymentAccountRelations.add(accountPaymentAccountRelation);

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IPaymentAccountFieldsValidations paymentAccountFieldsValidationsMock = (IPaymentAccountFieldsValidations) mocks.mock(
            IPaymentAccountFieldsValidations.class
        );
        Application.SERVICE.setMock(
            IPaymentAccountFieldsValidations.class,
            paymentAccountFieldsValidationsMock
        );

        fflib_SObjectDomain.Test.Database.onInsert(accountPaymentAccountRelations);
        fflib_SObjectDomain.triggerHandler(AccountPaymentAccountRelationsHandler.class);

        ((IPaymentAccountFieldsValidations) mocks.verify(paymentAccountFieldsValidationsMock, 1))
            .validateAccountToPaymentAccountRelation(accountPaymentAccountRelations);
    }
}