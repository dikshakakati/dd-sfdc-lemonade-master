/**
 * @author Deloitte
 * @date 28/02/2022
 * @description This is test class for Payment Accounts class
 */
@isTest(seeAllData=false)
public class PaymentAccountsTest {
    private static final string ACCOUNT_NAME = 'Pizza Business';
    private static final string ACCOUNT_CURRENCY = 'USD';
    private static final string ACCOUNT_BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Business')
        .getRecordTypeId();
    private static final string PAYMENT_ACCOUNT_INVOICE_RECORD_TYPE_ID = Schema.SObjectType.Payment_Account__c.getRecordTypeInfosByName()
        .get('Invoice')
        .getRecordTypeId();
    private static final string PAYMENT_ACCOUNT_PAYMENT_RECORD_TYPE_ID = Schema.SObjectType.Payment_Account__c.getRecordTypeInfosByName()
        .get('Payments')
        .getRecordTypeId();
    private static final string PAYMENT_ACCOUNT_ENTITY_TYPE_COMPANY = 'Company';
    private static final string PAYMENT_ACCOUNT_ENTITY_TYPE_PARTNERSHIPS = 'Partnerships';
    private static final string PAYMENT_ACCOUNT_ASSERT_MESSAGE = 'Entity Type should be set to Company for blank Entity Type with Payments Record Type';
     private static final string PAYMENT_ACCOUNT_ASSERT_ERROR_MESSAGE = 'Entity Type should not be set to Company for other record types and blank entity type';
    private static final String NINTEX_USER_NAME = 'Nintex Integration User';
    private static final String ERROR_MESSAGE =
        'Payment Terms is required in order to sync payment account record with NetSuite.,' +
        'DoorDash Legal Entity is required in order to sync payment account record with Netsuite,' +
        'Email address is required on the Billing Contact Name in order to sync payment account record with NetSuite.,' +
        'Bill to company name is required in order to sync payment account record with NetSuite.,' +
        'A Business Unit value is needed in order to sync with NetSuite.,' +
        'Currency is required in order to sync payment account record with NetSuite.,' +
        'Address Line 1, City, State & Postal code are required in order to sync payment account record with NetSuite.,' +
        'Country is required in order to sync payment account record with NetSuite.';

    /**
     * @description To test on instantiation
     */
    @isTest
    private static void testWhenClassInstantiatesThenRun() {
        List<Payment_Account__c> paymentAccountsList = new List<Payment_Account__c>();
        //IPaymentAccounts Instance Creation Call
        PaymentAccounts.newInstance(paymentAccountsList);
        //Default Constructor Call
        PaymentAccounts paymentAccountsObject = new PaymentAccounts(paymentAccountsList);
        //fflib_IDomainConstructor call
        PaymentAccounts.Constructor constructorObject = new PaymentAccounts.Constructor();
        constructorObject.construct(paymentAccountsList);
        System.assertNotEquals(
            PaymentAccounts.newInstance(paymentAccountsList),
            paymentAccountsObject,
            'These objects should not be similar'
        );
    }

    /**
     * @description To test when business account is updated currency of payment account is updated
     * @JIRA# LEM-3121
     */
    @IsTest
    private static void testWhenBusinessAccountUpdatedThenUpdateCurrencyOfPaymentAccount() {
        Account account1 = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Test 1')
            .setField(Account.RecordTypeId, ACCOUNT_BUSINESS_RECORD_TYPE_ID)
            .setField(Account.CurrencyIsoCode, 'USD')
            .setFakeId()
            .toSObject();
        Payment_Account__c paymentAccount1 = (Payment_Account__c) new Fake(Payment_Account__c.class)
            .setField(Payment_Account__c.Business_Account__c, account1.Id)
            .setField(Payment_Account__c.RecordTypeId, PAYMENT_ACCOUNT_INVOICE_RECORD_TYPE_ID)
            .setFakeId()
            .toSObject();
        Payment_Account__c paymentAccount2 = (Payment_Account__c) new Fake(Payment_Account__c.class)
            .setField(Payment_Account__c.Business_Account__c, account1.Id)
            .setField(Payment_Account__c.RecordTypeId, PAYMENT_ACCOUNT_PAYMENT_RECORD_TYPE_ID)
            .setFakeId()
            .toSObject();
        List<Payment_Account__c> paymentAccountList = new List<Payment_Account__c>{
            paymentAccount1,
            paymentAccount2
        };
        List<Account> accounts = new List<Account>{ account1 };

        Set<Id> accountIdSet = new Set<Id>{ account1.Id };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectById(accountIdSet)).thenReturn(accounts);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        //Act
        PaymentAccounts.newInstance(paymentAccountList).populateCurrencyByBusinessAccount();
        //Assert
        System.assertEquals(
            paymentAccountList[0].CurrencyIsoCode,
            'USD',
            'Currency does not match'
        );
        System.assertNotEquals(paymentAccountList[1].CurrencyIsoCode, 'USD', 'Invalid scenario');
    }

    /**
     * @description To test when business account is updated currency of payment account is updated
     * @JIRA# LEM-3121
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenInvoicePaymentAccountCreatedThenSyncWithNetSuite() {
        Account account1 = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Test 1')
            .setField(Account.RecordTypeId, ACCOUNT_BUSINESS_RECORD_TYPE_ID)
            .setField(Account.CurrencyIsoCode, 'USD')
            .setFakeId()
            .toSObject();
        Payment_Account__c paymentAccount1 = (Payment_Account__c) new Fake(Payment_Account__c.class)
            .setField(Payment_Account__c.Business_Account__c, account1.Id)
            .setField(Payment_Account__c.RecordTypeId, PAYMENT_ACCOUNT_INVOICE_RECORD_TYPE_ID)
            .setFakeId()
            .toSObject();
        Payment_Account__c paymentAccount2 = (Payment_Account__c) new Fake(Payment_Account__c.class)
            .setField(Payment_Account__c.Business_Account__c, account1.Id)
            .setField(Payment_Account__c.RecordTypeId, PAYMENT_ACCOUNT_PAYMENT_RECORD_TYPE_ID)
            .setFakeId()
            .toSObject();
        List<Payment_Account__c> paymentAccountList = new List<Payment_Account__c>{
            paymentAccount1,
            paymentAccount2
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        INetSuiteSync mockNetSuiteSync = (INetSuiteSync) mocks.mock(INetSuiteSync.class);
        IPaymentAccountsSelector selectorMock = (IPaymentAccountsSelector) mocks.mock(
            IPaymentAccountsSelector.class
        );
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Payment_Account__c.SObjectType);
        mocks.when(selectorMock.selectById(new Set<Id>{ paymentAccount1.Id }))
            .thenReturn(new List<Payment_Account__c>{ paymentAccount1 });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(INetSuiteSync.class, mockNetSuiteSync);
        //Act
        System.runAs(getSyncWithNetSuiteUser()) {
            PaymentAccounts.newInstance(paymentAccountList).syncWithNetSuite();
        }

        //Assert
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Payment_Account__c.NetSuite_Sync_Response__c => ERROR_MESSAGE,
                        Payment_Account__c.NetSuite_Sync_Status__c => 'Fail',
                        Payment_Account__c.Id => paymentAccount1.Id
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    private static User getSyncWithNetSuiteUser() {
        PermissionSet netSuitePermissionSet = [
            SELECT Id
            FROM PermissionSet
            WHERE Name = 'Allow_PA_Sync_With_Netsuite'
            LIMIT 1
        ];
        PermissionSet autoSyncPermissionSet = [
            SELECT Id
            FROM PermissionSet
            WHERE Name = 'Allow_Automated_Sync_With_NetSuite'
        ];
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User testUser = new User(
            Alias = 'test',
            Email = 'testUser1@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'TestLastName',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = testProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'netsuitetestuser@test.com'
        );
        insert testUser;
        insert new PermissionSetAssignment(
            AssigneeId = testUser.id,
            PermissionSetId = netSuitePermissionSet.Id
        );
        insert new PermissionSetAssignment(
            AssigneeId = testUser.id,
            PermissionSetId = autoSyncPermissionSet.Id
        );
        return testUser;
    }

     /**
     * @description To test when Payment Account Record Type set to 'Payments' then update blank EntityType to 'Company'.
     * @JIRA# LEM-25466
     */
    @isTest
     private static void testWhenRecordTypeSetToPaymentsThenUpdateBlankEntityTypeToCompany() {
     Account account = (Account) new Fake(Account.class)
            .setField(Account.Name, ACCOUNT_NAME)
            .setField(Account.RecordTypeId, ACCOUNT_BUSINESS_RECORD_TYPE_ID)
            .setField(Account.CurrencyIsoCode, ACCOUNT_CURRENCY)
            .setFakeId()
            .toSObject();
    Payment_Account__c paymentAccount = (Payment_Account__c) new Fake(Payment_Account__c.class)
        .setField(Payment_Account__c.Business_Account__c, account.Id)
        .setField(Payment_Account__c.RecordTypeId, PAYMENT_ACCOUNT_PAYMENT_RECORD_TYPE_ID)
        .setFakeId()
        .toSObject();
    List<Payment_Account__c> paymentAccountList = new List<Payment_Account__c>{paymentAccount};
    Test.startTest();
    PaymentAccounts.newInstance(paymentAccountList).setEntityTypeForPaymentsRecordType();
    Test.stopTest();

    System.assertEquals(
        PAYMENT_ACCOUNT_ENTITY_TYPE_COMPANY,
        paymentAccount.Entity_Type__c,
        PAYMENT_ACCOUNT_ASSERT_MESSAGE
    );
    }

    /**
     * @description To test when Payment Account Record Type set to 'Payments' but entity type not blank then don't update to 'Company'.
     * @JIRA# LEM-25466
     */
    @isTest
     private static void testWhenRecordTypeSetToPaymentsThenDoNotUpdateEntityTypeToCompanyIfNotBlank() {
     Account account = (Account) new Fake(Account.class)
            .setField(Account.Name, ACCOUNT_NAME)
            .setField(Account.RecordTypeId, ACCOUNT_BUSINESS_RECORD_TYPE_ID)
            .setField(Account.CurrencyIsoCode, ACCOUNT_CURRENCY)
            .setFakeId()
            .toSObject();
    Payment_Account__c paymentAccount = (Payment_Account__c) new Fake(Payment_Account__c.class)
        .setField(Payment_Account__c.Business_Account__c, account.Id)
        .setField(Payment_Account__c.RecordTypeId, PAYMENT_ACCOUNT_PAYMENT_RECORD_TYPE_ID)
        .setField(Payment_Account__c.Entity_Type__c, PAYMENT_ACCOUNT_ENTITY_TYPE_PARTNERSHIPS)
        .setFakeId()
        .toSObject();

    List<Payment_Account__c> paymentAccountList = new List<Payment_Account__c>{paymentAccount};
    Test.startTest();
    PaymentAccounts.newInstance(paymentAccountList).setEntityTypeForPaymentsRecordType();
    Test.stopTest();
    System.assertEquals(
        PAYMENT_ACCOUNT_ENTITY_TYPE_PARTNERSHIPS,
        paymentAccount.Entity_Type__c,
        PAYMENT_ACCOUNT_ASSERT_ERROR_MESSAGE
    );
    }

    /**
     * @description To test when Payment Account Record Type set to 'Invoice' then don't update blank EntityType to 'Company'.
     * @JIRA# LEM-25466
     */
    @isTest
     private static void testWhenRecordTypeSetToInvoiceThenDoNotUpdateBlankEntityTypeToCompany() {
     Account account = (Account) new Fake(Account.class)
            .setField(Account.Name, ACCOUNT_NAME)
            .setField(Account.RecordTypeId, ACCOUNT_BUSINESS_RECORD_TYPE_ID)
            .setField(Account.CurrencyIsoCode, ACCOUNT_CURRENCY)
            .setFakeId()
            .toSObject();
    Payment_Account__c paymentAccount = (Payment_Account__c) new Fake(Payment_Account__c.class)
        .setField(Payment_Account__c.Business_Account__c, account.Id)
        .setField(Payment_Account__c.RecordTypeId, PAYMENT_ACCOUNT_INVOICE_RECORD_TYPE_ID)
        .setField(Payment_Account__c.Entity_Type__c, null)
        .setFakeId()
        .toSObject();
    List<Payment_Account__c> paymentAccountList = new List<Payment_Account__c>{paymentAccount};
    Test.startTest();
    PaymentAccounts.newInstance(paymentAccountList).setEntityTypeForPaymentsRecordType();
    Test.stopTest();
    System.assertEquals(
        null,
        paymentAccount.Entity_Type__c,
        PAYMENT_ACCOUNT_ASSERT_ERROR_MESSAGE
    );
}

}