/**
 * @author Deloitte
 * @date 10/0y/2022
 * @description Test class for AccountPaymentAccountRelationsSelector class.
 */
@isTest(seeAllData=false)
private class AccountPaymentAccountRelationsSelectTest {
    private static final String ACCOUNT_NAME = AccountPaymentAccountRelationsSelectTest.class
        .getName();
    private static final String FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: mismatch in field list';
    private static final String OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: the object type must be Account_Payment_Account_Relation__c';
    private static final Id PAYMENT_ACCOUNT_INVOICE_RECORD_TYPE_ID = Schema.SObjectType.Payment_Account__c.getRecordTypeInfosByDeveloperName()
        .get('Invoice')
        .getRecordTypeId();
    private static final Id PAYMENT_ACCOUNT_PAYMENTS_RECORD_TYPE_ID = Schema.SObjectType.Payment_Account__c.getRecordTypeInfosByDeveloperName()
        .get('Payments')
        .getRecordTypeId();
    private static final String PAYMENT_ACCOUNT_RECORD_TYPE_INVOICE = 'Invoice';
    private static final String PAYMENT_ACCOUNT_RECORD_TYPE_PAYMENTS = 'Payments';
    private static final String PAYMENT_TERMS_NET_15 = 'Net 15';
    private static final String ERROR_LIST_SIZE_DOES_NOT_MATCH = 'Unexpected result: mismatch in field list size';
    private static final String ERROR_PAYMENT_TERMS_DOES_NOT_MATCH = 'Unexpected result: mismatch in field payment terms';

    /**
     * @description To test Contructor instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCheckSObjectTypeAndFieldList() {
        AccountPaymentAccountRelationsSelector accountPaymentAccountRelationsSelectorInstance = (AccountPaymentAccountRelationsSelector) AccountPaymentAccountRelationsSelector.newInstance();
        Schema.SObjectType typeOfObject = accountPaymentAccountRelationsSelectorInstance.getSObjectType();
        List<Schema.SObjectField> sObjectFields = accountPaymentAccountRelationsSelectorInstance.getSObjectFieldList();
        System.assertEquals(
            Schema.Account_Payment_Account_Relation__c.SObjectType,
            typeOfObject,
            OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
                Account_Payment_Account_Relation__c.Id,
                Account_Payment_Account_Relation__c.Account__c,
                Account_Payment_Account_Relation__c.Payment_Account__c,
                Account_Payment_Account_Relation__c.Payment_Terms__c
            },
            sObjectFields,
            FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description Tests select by id with payment account payment terms
     */
    @isTest
    private static void testWhenSelectByIdCalledThenReturn() {
        Payment_Account__c paymentAccount = new Payment_Account__c(
            Payment_Terms__c = PAYMENT_TERMS_NET_15
        );

        insert paymentAccount;

        Account_Payment_Account_Relation__c accountToPaymentAccountRelation = new Account_Payment_Account_Relation__c(
            Payment_Account__c = paymentAccount.Id
        );

        insert accountToPaymentAccountRelation;

        List<Account_Payment_Account_Relation__c> accountToPaymentAccountRelations = AccountPaymentAccountRelationsSelector.newInstance()
            .selectById(new Set<Id>{ accountToPaymentAccountRelation.Id });

        System.assert(accountToPaymentAccountRelations.size() == 1, ERROR_LIST_SIZE_DOES_NOT_MATCH);
        System.assert(
            accountToPaymentAccountRelations[0].Payment_Terms__c == PAYMENT_TERMS_NET_15,
            ERROR_PAYMENT_TERMS_DOES_NOT_MATCH
        );
    }

    /**
     * @description To test query on Account To Payment Account relations
     * associated with the passed Account Ids having Payment Accounts with Invoice record type.
     */
    @isTest
    private static void testWhenSelectByAccountIdsCalledThenAccountPaymentAccountRelationsWithInvoicePaymentAccountsReturned() {
        Payment_Account__c paymentAccount = new Payment_Account__c(
            Payment_Terms__c = PAYMENT_TERMS_NET_15,
            RecordTypeId = PAYMENT_ACCOUNT_INVOICE_RECORD_TYPE_ID
        );
        insert paymentAccount;
        Account account = new Account(Name = ACCOUNT_NAME, Segment__c = 'Enterprise');
        insert account;
        Account_Payment_Account_Relation__c accountToPaymentAccountRelation = new Account_Payment_Account_Relation__c(
            Payment_Account__c = paymentAccount.Id,
            Account__c = account.Id
        );
        insert accountToPaymentAccountRelation;
        List<Account_Payment_Account_Relation__c> accountToPaymentAccountRelations = AccountPaymentAccountRelationsSelector.newInstance()
            .selectByAccountIdsAndPaymentAccountRecordTypes(
                new Set<Id>{ account.Id },
                new Set<String>{ PAYMENT_ACCOUNT_RECORD_TYPE_INVOICE }
            );
        System.assertEquals(
            1,
            accountToPaymentAccountRelations.size(),
            ERROR_LIST_SIZE_DOES_NOT_MATCH
        );
    }

    /**
     * @description To test query on Account To Payment Account relations
     * associated with the passed Account Ids having Payment Accounts with Payments record type.
     */
    @isTest
    private static void testWhenAccountIdsAndPaymentsRecordTypePassedThenAccountPaymentAccountRelationsWithPaymentAccountsOfPaymentsRecordTypeReturned() {
        Payment_Account__c paymentAccount = new Payment_Account__c(
            Payment_Terms__c = PAYMENT_TERMS_NET_15,
            RecordTypeId = PAYMENT_ACCOUNT_PAYMENTS_RECORD_TYPE_ID
        );
        insert paymentAccount;
        Account account = new Account(Name = ACCOUNT_NAME, Segment__c = 'Enterprise');
        insert account;
        Account_Payment_Account_Relation__c accountToPaymentAccountRelation = new Account_Payment_Account_Relation__c(
            Payment_Account__c = paymentAccount.Id,
            Account__c = account.Id
        );
        insert accountToPaymentAccountRelation;
        List<Account_Payment_Account_Relation__c> accountToPaymentAccountRelations = AccountPaymentAccountRelationsSelector.newInstance()
            .selectByAccountIdsAndPaymentAccountRecordTypes(
                new Set<Id>{ account.Id },
                new Set<String>{ PAYMENT_ACCOUNT_RECORD_TYPE_PAYMENTS }
            );
        System.assertEquals(
            1,
            accountToPaymentAccountRelations.size(),
            ERROR_LIST_SIZE_DOES_NOT_MATCH
        );
    }
}