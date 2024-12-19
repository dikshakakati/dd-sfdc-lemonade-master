/**
 * @description This is test class for Payment Account Trigger handler class
 * @author Deloitte
 * @date 10/17/2022
 */
@isTest(seeAllData=false)
public class PaymentAccountsHandlerTest {
    private static final string ACCOUNT_BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Business')
        .getRecordTypeId();

    /**
     * @description To test method call on instantiation
     */
    @IsTest
    private static void testWhenClassInstantiatesThenCheck() {
        //Constructor Call
        List<Payment_Account__c> paymentAccountList = new List<Payment_Account__c>();
        PaymentAccountsHandler paymentAccountHandlerObject = new PaymentAccountsHandler(
            paymentAccountList
        );
        //Inner Class Constructor Call
        PaymentAccountsHandler.Constructor objConstructor = new PaymentAccountsHandler.Constructor();
        objConstructor.construct(paymentAccountList);
        System.assertNotEquals(
            paymentAccountHandlerObject,
            objConstructor.construct(paymentAccountList),
            'The two constructs should not be similar'
        );
    }

    /**
     * @description To test method call on Business account update on payment account
     * @JIRA# LEM-3121
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenBusinessAccountOfPaymentAccountUpdatedThenCall() {
        Account[] accounts = new List<Account>{
            new Account(
                Id = Fake.generateId(Account.class),
                Name = 'Test 1',
                RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID,
                CurrencyIsoCode = 'USD'
            ),
            new Account(
                Id = Fake.generateId(Account.class),
                Name = 'Test 2',
                RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID,
                CurrencyIsoCode = 'AUD'
            ),
            new Account(
                Id = Fake.generateId(Account.class),
                Name = 'Test 3',
                RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID,
                CurrencyIsoCode = 'HKT'
            )
        };
        Id paymentAccountId1 = Fake.generateId(Payment_Account__c.class);
        Id paymentAccountId2 = Fake.generateId(Payment_Account__c.class);
        Payment_Account__c[] newPaymentAccounts = new List<Payment_Account__c>{
            new Payment_Account__c(Id = paymentAccountId1, Business_Account__c = accounts[2].Id),
            new Payment_Account__c(Id = paymentAccountId2, Business_Account__c = accounts[1].Id)
        };

        Payment_Account__c[] oldPaymentAccounts = new List<Payment_Account__c>{
            new Payment_Account__c(Id = paymentAccountId1, Business_Account__c = accounts[0].Id),
            new Payment_Account__c(Id = paymentAccountId2, Business_Account__c = accounts[1].Id)
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_IDomainConstructor constructor = (fflib_IDomainConstructor) mocks.mock(
            fflib_IDomainConstructor.class
        );
        PaymentAccounts constructorMock = (PaymentAccounts) mocks.mock(PaymentAccounts.class);

        mocks.startStubbing();
        mocks.when(constructor.construct(fflib_Match.anyList())).thenReturn(constructorMock);
        mocks.when(constructorMock.getType()).thenReturn(Schema.Payment_Account__c.SObjectType);
        mocks.stopStubbing();

        PaymentAccounts.setConstructorMock(constructor);

        fflib_SObjectDomain.Test.Database.onUpdate(
            newPaymentAccounts,
            new Map<Id, SObject>(oldPaymentAccounts)
        );
        fflib_SObjectDomain.triggerHandler(PaymentAccountsHandler.class);
        ((fflib_IDomainConstructor) mocks.verify(constructor, 1))
            .construct(new List<Payment_Account__c>{ newPaymentAccounts[0] });
    }

    /**
     * @description To test method call on payment account update
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenPaymentAccountUpdatedThenCall() {
        Account[] accounts = new List<Account>{
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Test 1',
                RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID,
                CurrencyIsoCode = 'USD'
            ),
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Test 2',
                RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID,
                CurrencyIsoCode = 'AUD'
            )
        };
        Payment_Account__c[] newPaymentAccounts = new List<Payment_Account__c>{
            new Payment_Account__c(
                Id = fflib_IDGenerator.generate(Payment_Account__c.SObjectType),
                Business_Account__c = accounts[1].Id
            )
        };
        Payment_Account__c[] oldPaymentAccounts = new List<Payment_Account__c>{
            new Payment_Account__c(
                Id = fflib_IDGenerator.generate(Payment_Account__c.SObjectType),
                Business_Account__c = accounts[0].Id
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IPaymentAccounts paymentAccountsMock = (IPaymentAccounts) mocks.mock(
            IPaymentAccounts.class
        );
        mocks.startStubbing();
        mocks.when(paymentAccountsMock.getType()).thenReturn(Schema.Payment_Account__c.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(paymentAccountsMock);

        fflib_SObjectDomain.Test.Database.onUpdate(
            newPaymentAccounts,
            new Map<Id, SObject>(oldPaymentAccounts)
        );
        fflib_SObjectDomain.triggerHandler(PaymentAccountsHandler.class);

        ((IPaymentAccounts) mocks.verify(paymentAccountsMock, 1))
            .populateCurrencyByBusinessAccount();
        ((IPaymentAccounts) mocks.verify(paymentAccountsMock, 1))
            .setEntityTypeForPaymentsRecordType();
    }

    /**
     * @description To test method call on payment account insert
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenPaymentAccountInsertedThenCall() {
        Account[] accounts = new List<Account>{
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Test 1',
                RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID,
                CurrencyIsoCode = 'USD'
            )
        };
        Payment_Account__c[] paymentAccounts = new List<Payment_Account__c>{
            new Payment_Account__c(
                Id = fflib_IDGenerator.generate(Payment_Account__c.SObjectType),
                Business_Account__c = accounts[0].Id
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IPaymentAccounts paymentAccountsMock = (IPaymentAccounts) mocks.mock(
            IPaymentAccounts.class
        );
        mocks.startStubbing();
        mocks.when(paymentAccountsMock.getType()).thenReturn(Schema.Payment_Account__c.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(paymentAccountsMock);

        fflib_SObjectDomain.Test.Database.onInsert(paymentAccounts);
        fflib_SObjectDomain.triggerHandler(PaymentAccountsHandler.class);

        ((IPaymentAccounts) mocks.verify(paymentAccountsMock, 1))
            .populateCurrencyByBusinessAccount();
        ((IPaymentAccounts) mocks.verify(paymentAccountsMock, 1))
            .setEntityTypeForPaymentsRecordType();
    }

    /**
     * @description To test method call on Is_Parent_Account_Merged Field updation.
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenIsParentAccountMergedFieldChangedThenPopulateCurrencyByBusinessAccountIsCalled() {
        Account parentAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            Name = 'Test 1',
            RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID
        );
        Payment_Account__c[] newPaymentAccounts = new List<Payment_Account__c>{
            new Payment_Account__c(
                Id = fflib_IDGenerator.generate(Payment_Account__c.SObjectType),
                Business_Account__c = parentAccount.Id,
                Is_Parent_Account_Merged__c = false
            )
        };
        Payment_Account__c[] oldPaymentAccounts = new List<Payment_Account__c>{
            new Payment_Account__c(
                Id = fflib_IDGenerator.generate(Payment_Account__c.SObjectType),
                Business_Account__c = parentAccount.Id,
                Is_Parent_Account_Merged__c = true
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IPaymentAccounts paymentAccountsMock = (IPaymentAccounts) mocks.mock(
            IPaymentAccounts.class
        );
        mocks.startStubbing();
        mocks.when(paymentAccountsMock.getType()).thenReturn(Schema.Payment_Account__c.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(paymentAccountsMock);

        fflib_SObjectDomain.Test.Database.onUpdate(
            newPaymentAccounts,
            new Map<Id, SObject>(oldPaymentAccounts)
        );
        fflib_SObjectDomain.triggerHandler(PaymentAccountsHandler.class);

        ((IPaymentAccounts) mocks.verify(paymentAccountsMock, 1))
            .populateCurrencyByBusinessAccount();
    }

    /**
     * @description To test Payment Accounts Trigger
     */
    @isTest
    private static void testWhenPaymentAccountsTriggerIsCalledThenPaymentAccountIsInserted() {
        Payment_Account__c paymentAccount = new Payment_Account__c();
        insert paymentAccount;
        System.assertNotEquals(null, paymentAccount.Id, 'Id is null');
    }

    /**
     * @description It is used to check whether the method to validate the payment account
     * fields is called.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenPaymentAccountsUpdatedThenMethodToValidateFieldsCalled() {
        Id paymentAccountId = Fake.generateId(Payment_Account__c.class);

        Account parentAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            Name = 'Test 1',
            RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID
        );

        Payment_Account__c[] paymentAccounts = new List<Payment_Account__c>{
            new Payment_Account__c(Id = paymentAccountId)
        };

        Payment_Account__c[] oldPaymentAccounts = new List<Payment_Account__c>{
            new Payment_Account__c(Id = paymentAccountId, Business_Account__c = parentAccount.Id)
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IPaymentAccountFieldsValidations paymentAccountFieldsValidationsMock = (IPaymentAccountFieldsValidations) mocks.mock(
            IPaymentAccountFieldsValidations.class
        );
        Application.SERVICE.setMock(
            IPaymentAccountFieldsValidations.class,
            paymentAccountFieldsValidationsMock
        );

        fflib_SObjectDomain.Test.Database.onUpdate(
            paymentAccounts,
            new Map<Id, Sobject>(oldPaymentAccounts)
        );
        fflib_SObjectDomain.triggerHandler(PaymentAccountsHandler.class);

        ((IPaymentAccountFieldsValidations) mocks.verify(paymentAccountFieldsValidationsMock, 1))
            .validatePaymentAccountFields(paymentAccounts);
    }
}