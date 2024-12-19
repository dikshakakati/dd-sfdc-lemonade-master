/**
 * @author Deloitte
 * @date 10/30/2023
 * @description Test class for PaymentAccountFieldsValidations class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class PaymentAccountFieldsValidationsTest {
    private static final String ACCOUNT_BILLING_COUNTRY_CODE_ALIAS = 'accountBillingCountryCode';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String BANK_ACCOUNT_NUMBER_MAX_DIGITS = '1234567891011';
    private static final String BANK_ACCOUNT_NUMBER_MIN_DIGITS = '123';
    private static final String CA = 'CA';
    private static final String ERROR_MESSAGE_NOT_FIRED = 'No error messages fired';
    private static final String INSTITUTION_NUMBER_INVALID_DIGITS = '1234';
    private static final String PAYMENT_ACCOUNT_ID_ALIAS = 'paymentAccountId';
    private static final string PAYMENT_ACCOUNT_PAYMENTS_RECORD_TYPE_ID = Schema.SObjectType.Payment_Account__c.getRecordTypeInfosByName()
        .get('Payments')
        .getRecordTypeId();
    private static final String ROUTING_NUMBER_INVALID_DIGITS = '4234';
    private static final String US = 'US';
    private static final String VERTICAL = 'Floral';

    /**
     * @description It is used to validate the bank account number by the passed values.
     */
    @isTest
    private static void testWhenPaymentAccountWithInvalidBankAccountNumberAssociatedThenValidationErrorThrown() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id paymentAccountId = fflib_IDGenerator.generate(Payment_Account__c.SObjectType);

        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Id, businessAccountId)
            .setField(Account.BillingCountryCode, US)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake paymentAccountFakeInstance = new Fake(Payment_Account__c.class)
            .setField(Payment_Account__c.Id, paymentAccountId)
            .setField(Payment_Account__c.RecordTypeId, PAYMENT_ACCOUNT_PAYMENTS_RECORD_TYPE_ID)
            .setField(Payment_Account__c.Bank_Account_Number__c, BANK_ACCOUNT_NUMBER_MIN_DIGITS)
            .setField(Payment_Account__c.Institution_Number__c, INSTITUTION_NUMBER_INVALID_DIGITS)
            .setField(Payment_Account__c.RoutingNumber__c, ROUTING_NUMBER_INVALID_DIGITS);

        Payment_Account__c paymentAccounts = (Payment_Account__c) ServiceMockDataBuilder.convertToSObject(
            paymentAccountFakeInstance
        );

        Fake accountPaymentAccountRelationFakeInstance = new Fake(
                Account_Payment_Account_Relation__c.class
            )
            .setField(
                Account_Payment_Account_Relation__c.Account_Record_Type__c,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setParent('Account__r', businessAccountFakeInstance)
            .setFakeId();

        accountPaymentAccountRelationFakeInstance
            .setField(Account_Payment_Account_Relation__c.Account__c, businessAccount.Id)
            .setField(Account_Payment_Account_Relation__c.Payment_Account__c, paymentAccountId)
            .setField(
                Account_Payment_Account_Relation__c.Record_Type__c,
                PAYMENT_ACCOUNT_PAYMENTS_RECORD_TYPE_ID
            );
        Account_Payment_Account_Relation__c accountPaymentAccountRelation = (Account_Payment_Account_Relation__c) ServiceMockDataBuilder.convertToSObject(
            accountPaymentAccountRelationFakeInstance
        );

        Aggregate mockAPARAggregate = new Aggregate();
        mockAPARAggregate.put(PAYMENT_ACCOUNT_ID_ALIAS, paymentAccountId);
        mockAPARAggregate.put(ACCOUNT_BILLING_COUNTRY_CODE_ALIAS, US);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountPaymentAccountRelationsSelector mockAccountPaymentAccountRelationsSelector = (IAccountPaymentAccountRelationsSelector) mocks.mock(
            IAccountPaymentAccountRelationsSelector.class
        );

        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IPaymentAccountsSelector mockPaymentAccountsSelector = (IPaymentAccountsSelector) mocks.mock(
            IPaymentAccountsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockAccountPaymentAccountRelationsSelector.sObjectType())
            .thenReturn(Account_Payment_Account_Relation__c.SObjectType);
        mocks.when(
                mockAccountPaymentAccountRelationsSelector.selectCountOfAccountPaymentAccountRelationsByAccountBillingCountryCode(
                    new Set<Id>{ paymentAccountId }
                )
            )
            .thenReturn(new List<Aggregate>{ mockAPARAggregate });
        mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(mockAccountsSelector.selectById(new Set<Id>{ businessAccountId }))
            .thenReturn(new List<Account>{ businessAccount });
        mocks.when(mockPaymentAccountsSelector.sObjectType())
            .thenReturn(Payment_Account__c.SObjectType);
        mocks.when(mockPaymentAccountsSelector.selectById(new Set<Id>{ paymentAccountId }))
            .thenReturn(new List<Payment_Account__c>{ paymentAccounts });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockAccountPaymentAccountRelationsSelector);
        Application.SELECTOR.setMock(mockAccountsSelector);
        Application.SELECTOR.setMock(mockPaymentAccountsSelector);

        PaymentAccountFieldsValidationsImpl paymentAccountFieldsValidationsImpl = new PaymentAccountFieldsValidationsImpl();
        paymentAccountFieldsValidationsImpl.validateAccountToPaymentAccountRelation(
            new List<Account_Payment_Account_Relation__c>{ accountPaymentAccountRelation }
        );

        System.assertEquals(1, ApexPages.getMessages().size(), ERROR_MESSAGE_NOT_FIRED);
    }

    /**
     * @description It is used to validate the uniqueness of the account based on the
     * billing country code getting associated with the APAR.
     */
    @isTest
    private static void testWhenAPARCreatedOnAccountWithDifferentBillingCountryThenValidationErrorThrown() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id paymentAccountId = fflib_IDGenerator.generate(Payment_Account__c.SObjectType);

        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Id, businessAccountId)
            .setField(Account.BillingCountryCode, US)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );

        Fake paymentAccountFakeInstance = new Fake(Payment_Account__c.class)
            .setField(Payment_Account__c.Id, paymentAccountId)
            .setField(Payment_Account__c.RecordTypeId, PAYMENT_ACCOUNT_PAYMENTS_RECORD_TYPE_ID)
            .setField(Payment_Account__c.Bank_Account_Number__c, BANK_ACCOUNT_NUMBER_MAX_DIGITS)
            .setField(Payment_Account__c.Institution_Number__c, INSTITUTION_NUMBER_INVALID_DIGITS)
            .setField(Payment_Account__c.RoutingNumber__c, ROUTING_NUMBER_INVALID_DIGITS);

        Payment_Account__c paymentAccounts = (Payment_Account__c) ServiceMockDataBuilder.convertToSObject(
            paymentAccountFakeInstance
        );

        Fake accountPaymentAccountRelationFakeInstance = new Fake(
                Account_Payment_Account_Relation__c.class
            )
            .setField(
                Account_Payment_Account_Relation__c.Account_Record_Type__c,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setParent('Account__r', businessAccountFakeInstance)
            .setFakeId();

        accountPaymentAccountRelationFakeInstance
            .setField(Account_Payment_Account_Relation__c.Account__c, businessAccount.Id)
            .setField(Account_Payment_Account_Relation__c.Payment_Account__c, paymentAccountId)
            .setField(
                Account_Payment_Account_Relation__c.Record_Type__c,
                PAYMENT_ACCOUNT_PAYMENTS_RECORD_TYPE_ID
            );
        Account_Payment_Account_Relation__c accountPaymentAccountRelation = (Account_Payment_Account_Relation__c) ServiceMockDataBuilder.convertToSObject(
            accountPaymentAccountRelationFakeInstance
        );

        Aggregate mockAPARAggregate = new Aggregate();
        mockAPARAggregate.put(PAYMENT_ACCOUNT_ID_ALIAS, paymentAccountId);
        mockAPARAggregate.put(ACCOUNT_BILLING_COUNTRY_CODE_ALIAS, CA);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountPaymentAccountRelationsSelector mockAccountPaymentAccountRelationsSelector = (IAccountPaymentAccountRelationsSelector) mocks.mock(
            IAccountPaymentAccountRelationsSelector.class
        );

        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IPaymentAccountsSelector mockPaymentAccountsSelector = (IPaymentAccountsSelector) mocks.mock(
            IPaymentAccountsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockAccountPaymentAccountRelationsSelector.sObjectType())
            .thenReturn(Account_Payment_Account_Relation__c.SObjectType);
        mocks.when(
                mockAccountPaymentAccountRelationsSelector.selectCountOfAccountPaymentAccountRelationsByAccountBillingCountryCode(
                    new Set<Id>{ paymentAccountId }
                )
            )
            .thenReturn(new List<Aggregate>{ mockAPARAggregate });
        mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(mockAccountsSelector.selectById(new Set<Id>{ businessAccountId }))
            .thenReturn(new List<Account>{ businessAccount });
        mocks.when(mockPaymentAccountsSelector.sObjectType())
            .thenReturn(Payment_Account__c.SObjectType);
        mocks.when(mockPaymentAccountsSelector.selectById(new Set<Id>{ paymentAccountId }))
            .thenReturn(new List<Payment_Account__c>{ paymentAccounts });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockAccountPaymentAccountRelationsSelector);
        Application.SELECTOR.setMock(mockAccountsSelector);
        Application.SELECTOR.setMock(mockPaymentAccountsSelector);

        PaymentAccountFieldsValidationsImpl paymentAccountFieldsValidationsImpl = new PaymentAccountFieldsValidationsImpl();
        paymentAccountFieldsValidationsImpl.validateAccountToPaymentAccountRelation(
            new List<Account_Payment_Account_Relation__c>{ accountPaymentAccountRelation }
        );

        System.assertEquals(1, ApexPages.getMessages().size(), ERROR_MESSAGE_NOT_FIRED);
    }

    /**
     * @description It is used to validate whether the payment account is updated with the correct
     * field values.
     */
    @isTest
    private static void testWhenPaymentAccountUpdatedWithInvalidFieldValuesThenValidationErrorThrown() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id paymentAccountId = fflib_IDGenerator.generate(Payment_Account__c.SObjectType);

        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Id, businessAccountId)
            .setField(Account.BillingCountryCode, US)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );

        Fake paymentAccountFakeInstance = new Fake(Payment_Account__c.class)
            .setField(Payment_Account__c.Id, paymentAccountId)
            .setField(Payment_Account__c.RecordTypeId, PAYMENT_ACCOUNT_PAYMENTS_RECORD_TYPE_ID)
            .setField(Payment_Account__c.Bank_Account_Number__c, BANK_ACCOUNT_NUMBER_MAX_DIGITS)
            .setField(Payment_Account__c.Institution_Number__c, INSTITUTION_NUMBER_INVALID_DIGITS)
            .setField(Payment_Account__c.RoutingNumber__c, ROUTING_NUMBER_INVALID_DIGITS);

        Payment_Account__c paymentAccounts = (Payment_Account__c) ServiceMockDataBuilder.convertToSObject(
            paymentAccountFakeInstance
        );

        Fake accountPaymentAccountRelationFakeInstance = new Fake(
                Account_Payment_Account_Relation__c.class
            )
            .setField(
                Account_Payment_Account_Relation__c.Account_Record_Type__c,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setParent('Account__r', businessAccountFakeInstance)
            .setFakeId();

        accountPaymentAccountRelationFakeInstance
            .setField(Account_Payment_Account_Relation__c.Account__c, businessAccount.Id)
            .setField(Account_Payment_Account_Relation__c.Payment_Account__c, paymentAccountId)
            .setField(
                Account_Payment_Account_Relation__c.Record_Type__c,
                PAYMENT_ACCOUNT_PAYMENTS_RECORD_TYPE_ID
            );

        Aggregate mockAPARAggregate = new Aggregate();
        mockAPARAggregate.put(PAYMENT_ACCOUNT_ID_ALIAS, paymentAccountId);
        mockAPARAggregate.put(ACCOUNT_BILLING_COUNTRY_CODE_ALIAS, US);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountPaymentAccountRelationsSelector mockAccountPaymentAccountRelationsSelector = (IAccountPaymentAccountRelationsSelector) mocks.mock(
            IAccountPaymentAccountRelationsSelector.class
        );
        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IPaymentAccountsSelector mockPaymentAccountsSelector = (IPaymentAccountsSelector) mocks.mock(
            IPaymentAccountsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockAccountPaymentAccountRelationsSelector.sObjectType())
            .thenReturn(Account_Payment_Account_Relation__c.SObjectType);
        mocks.when(
                mockAccountPaymentAccountRelationsSelector.selectCountOfAccountPaymentAccountRelationsByAccountBillingCountryCode(
                    new Set<Id>{ paymentAccountId }
                )
            )
            .thenReturn(new List<Aggregate>{ mockAPARAggregate });
        mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(mockAccountsSelector.selectById(new Set<Id>{ businessAccountId }))
            .thenReturn(new List<Account>{ businessAccount });
        mocks.when(mockPaymentAccountsSelector.sObjectType())
            .thenReturn(Payment_Account__c.SObjectType);
        mocks.when(mockPaymentAccountsSelector.selectById(new Set<Id>{ paymentAccountId }))
            .thenReturn(new List<Payment_Account__c>{ paymentAccounts });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockAccountPaymentAccountRelationsSelector);
        Application.SELECTOR.setMock(mockAccountsSelector);
        Application.SELECTOR.setMock(mockPaymentAccountsSelector);

        PaymentAccountFieldsValidationsImpl paymentAccountFieldsValidationsImpl = new PaymentAccountFieldsValidationsImpl();
        paymentAccountFieldsValidationsImpl.validatePaymentAccountFields(
            new List<Payment_Account__c>{ paymentAccounts }
        );

        System.assertEquals(1, ApexPages.getMessages().size(), ERROR_MESSAGE_NOT_FIRED);
    }

    /**
     * @description It is used to validate the payment account's routing number for Canada.
     */
    @isTest
    private static void testWhenPaymentAccountUpdatedWithInvalidRoutingNumberForCanadaUpdatedThenValidationErrorThrown() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id paymentAccountId = fflib_IDGenerator.generate(Payment_Account__c.SObjectType);

        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Id, businessAccountId)
            .setField(Account.BillingCountryCode, CA)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );

        Fake paymentAccountFakeInstance = new Fake(Payment_Account__c.class)
            .setField(Payment_Account__c.Id, paymentAccountId)
            .setField(Payment_Account__c.RecordTypeId, PAYMENT_ACCOUNT_PAYMENTS_RECORD_TYPE_ID)
            .setField(Payment_Account__c.Bank_Account_Number__c, BANK_ACCOUNT_NUMBER_MIN_DIGITS)
            .setField(Payment_Account__c.Institution_Number__c, INSTITUTION_NUMBER_INVALID_DIGITS)
            .setField(Payment_Account__c.RoutingNumber__c, ROUTING_NUMBER_INVALID_DIGITS);

        Payment_Account__c paymentAccounts = (Payment_Account__c) ServiceMockDataBuilder.convertToSObject(
            paymentAccountFakeInstance
        );

        Fake accountPaymentAccountRelationFakeInstance = new Fake(
                Account_Payment_Account_Relation__c.class
            )
            .setField(
                Account_Payment_Account_Relation__c.Account_Record_Type__c,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setParent('Account__r', businessAccountFakeInstance)
            .setFakeId();

        accountPaymentAccountRelationFakeInstance
            .setField(Account_Payment_Account_Relation__c.Account__c, businessAccount.Id)
            .setField(Account_Payment_Account_Relation__c.Payment_Account__c, paymentAccountId)
            .setField(
                Account_Payment_Account_Relation__c.Record_Type__c,
                PAYMENT_ACCOUNT_PAYMENTS_RECORD_TYPE_ID
            );

        Aggregate mockAPARAggregate = new Aggregate();
        mockAPARAggregate.put(PAYMENT_ACCOUNT_ID_ALIAS, paymentAccountId);
        mockAPARAggregate.put(ACCOUNT_BILLING_COUNTRY_CODE_ALIAS, CA);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountPaymentAccountRelationsSelector mockAccountPaymentAccountRelationsSelector = (IAccountPaymentAccountRelationsSelector) mocks.mock(
            IAccountPaymentAccountRelationsSelector.class
        );
        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IPaymentAccountsSelector mockPaymentAccountsSelector = (IPaymentAccountsSelector) mocks.mock(
            IPaymentAccountsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockAccountPaymentAccountRelationsSelector.sObjectType())
            .thenReturn(Account_Payment_Account_Relation__c.SObjectType);
        mocks.when(
                mockAccountPaymentAccountRelationsSelector.selectCountOfAccountPaymentAccountRelationsByAccountBillingCountryCode(
                    new Set<Id>{ paymentAccountId }
                )
            )
            .thenReturn(new List<Aggregate>{ mockAPARAggregate });
        mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(mockAccountsSelector.selectById(new Set<Id>{ businessAccountId }))
            .thenReturn(new List<Account>{ businessAccount });
        mocks.when(mockPaymentAccountsSelector.sObjectType())
            .thenReturn(Payment_Account__c.SObjectType);
        mocks.when(mockPaymentAccountsSelector.selectById(new Set<Id>{ paymentAccountId }))
            .thenReturn(new List<Payment_Account__c>{ paymentAccounts });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockAccountPaymentAccountRelationsSelector);
        Application.SELECTOR.setMock(mockAccountsSelector);
        Application.SELECTOR.setMock(mockPaymentAccountsSelector);

        PaymentAccountFieldsValidationsImpl paymentAccountFieldsValidationsImpl = new PaymentAccountFieldsValidationsImpl();
        paymentAccountFieldsValidationsImpl.validatePaymentAccountFields(
            new List<Payment_Account__c>{ paymentAccounts }
        );
        System.assertEquals(1, ApexPages.getMessages().size(), ERROR_MESSAGE_NOT_FIRED);
    }

    /**
     * @description It is used to validate the maximum digits of the bank account number by
     * the passed values.
     */
    @isTest
    private static void testWhenPaymentAccountWithBankAccountNumberExceedingMaximumDigitsUpdatedThenValidationErrorThrown() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id paymentAccountId = fflib_IDGenerator.generate(Payment_Account__c.SObjectType);

        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Id, businessAccountId)
            .setField(Account.BillingCountryCode, CA)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake paymentAccountFakeInstance = new Fake(Payment_Account__c.class)
            .setField(Payment_Account__c.Id, paymentAccountId)
            .setField(Payment_Account__c.RecordTypeId, PAYMENT_ACCOUNT_PAYMENTS_RECORD_TYPE_ID)
            .setField(Payment_Account__c.Bank_Account_Number__c, BANK_ACCOUNT_NUMBER_MAX_DIGITS)
            .setField(Payment_Account__c.RoutingNumber__c, ROUTING_NUMBER_INVALID_DIGITS);

        Payment_Account__c paymentAccounts = (Payment_Account__c) ServiceMockDataBuilder.convertToSObject(
            paymentAccountFakeInstance
        );

        Fake accountPaymentAccountRelationFakeInstance = new Fake(
                Account_Payment_Account_Relation__c.class
            )
            .setField(
                Account_Payment_Account_Relation__c.Account_Record_Type__c,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setParent('Account__r', businessAccountFakeInstance)
            .setFakeId();

        accountPaymentAccountRelationFakeInstance
            .setField(Account_Payment_Account_Relation__c.Account__c, businessAccount.Id)
            .setField(Account_Payment_Account_Relation__c.Payment_Account__c, paymentAccountId)
            .setField(
                Account_Payment_Account_Relation__c.Record_Type__c,
                PAYMENT_ACCOUNT_PAYMENTS_RECORD_TYPE_ID
            );
        Aggregate mockAPARAggregate = new Aggregate();
        mockAPARAggregate.put(PAYMENT_ACCOUNT_ID_ALIAS, paymentAccountId);
        mockAPARAggregate.put(ACCOUNT_BILLING_COUNTRY_CODE_ALIAS, CA);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountPaymentAccountRelationsSelector mockAccountPaymentAccountRelationsSelector = (IAccountPaymentAccountRelationsSelector) mocks.mock(
            IAccountPaymentAccountRelationsSelector.class
        );
        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IPaymentAccountsSelector mockPaymentAccountsSelector = (IPaymentAccountsSelector) mocks.mock(
            IPaymentAccountsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockAccountPaymentAccountRelationsSelector.sObjectType())
            .thenReturn(Account_Payment_Account_Relation__c.SObjectType);
        mocks.when(
                mockAccountPaymentAccountRelationsSelector.selectCountOfAccountPaymentAccountRelationsByAccountBillingCountryCode(
                    new Set<Id>{ paymentAccountId }
                )
            )
            .thenReturn(new List<Aggregate>{ mockAPARAggregate });
        mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(mockAccountsSelector.selectById(new Set<Id>{ businessAccountId }))
            .thenReturn(new List<Account>{ businessAccount });
        mocks.when(mockPaymentAccountsSelector.sObjectType())
            .thenReturn(Payment_Account__c.SObjectType);
        mocks.when(mockPaymentAccountsSelector.selectById(new Set<Id>{ paymentAccountId }))
            .thenReturn(new List<Payment_Account__c>{ paymentAccounts });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockAccountPaymentAccountRelationsSelector);
        Application.SELECTOR.setMock(mockAccountsSelector);
        Application.SELECTOR.setMock(mockPaymentAccountsSelector);

        PaymentAccountFieldsValidationsImpl paymentAccountFieldsValidationsImpl = new PaymentAccountFieldsValidationsImpl();
        paymentAccountFieldsValidationsImpl.validatePaymentAccountFields(
            new List<Payment_Account__c>{ paymentAccounts }
        );
        System.assertEquals(1, ApexPages.getMessages().size(), ERROR_MESSAGE_NOT_FIRED);
    }
}