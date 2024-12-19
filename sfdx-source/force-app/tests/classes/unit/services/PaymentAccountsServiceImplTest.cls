/**
 * @author  Deloitte
 * @date 12/10/2022
 * @description Test class for PaymentAccountsServiceImpl class.
 * Suppressed Warnings since mock verify method does not require System Assert statements.
 */
@isTest(seeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class PaymentAccountsServiceImplTest {
  private static final String EXCEPTION_MISMATCH_ASSERT_MESSAGE = 'Unexpected Error: The Exception fired was not a TestCommitException';
  private static final String MOCK_BANK_ACCOUNT_NUMBER = '12354';
  private static final String MOCK_CITY = 'Mock City';
  private static final String MOCK_EXCEPTION_MESSAGE = 'Exception occurred while performing DML operation';
  private static final String MOCK_REPRESENTATIVE_EMAIL = 'mockRepEmail@PaymentAccountsServiceImplTest.com';
  private static final String MOCK_REPRESENTATIVE_FIRST_NAME = 'Mock First Name';
  private static final String MOCK_REPRESENTATIVE_LAST_NAME = 'Mock Last Name';
  private static final String MOCK_STREET = 'Mock Street';
  private static final String ONBOARDING_SCENARIO_NET_NEW = 'Net-New Mx Onboarding';
  private static final String ONBOARDING_SCENARIO_PRODUCT_ADDITION = 'Product Addition';
  private static final String PAYMENT_ACCOUNT_NETSUITE_ID = 'PaymentAccountsServiceImplTestNetsuiteId';
  private static final String PAYMENT_ACCOUNT_NETSUITE_SYNC_RESPONSE = 'PaymentAccountsServiceImplTestNetsuiteSyncResponse';
  private static final String PAYMENT_METHOD_INVOICING = 'Invoicing';
  private static final String PAYMENT_METHOD_WITHHOLDING = 'Withholding';
  private static final String PAYMENT_STREET = 'Mock Street';
  private static final String PAYMENT_CITY = 'Mock City';
  private static final String PAYMENT_STATECODE = 'AL';
  private static final String PAYMENT_COUNTRYCODE = 'US';
  private static final String PAYMENT_POSTAL_CODE = '12435';
  private static final String PLUS_KEY = '+';
  private static final String PRODUCT_DRIVE = 'Drive';
  private static final String PRODUCT_MARKETPLACE = 'Marketplace';
  private static final String UNIQUE_IDENTIFIER = '92108a53-e8d9-4a0c-9193-9152aeb86fe4';
  /**
   * @description To test update on Payment Account 'Syn With Netsuite Response' field value
   * when payment account record is received.
   */
  @isTest
  private static void testWhenPaymentAccountReceivedThenUpatePaymentAccount() {
    Id paymentAccountId = fflib_IDGenerator.generate(
      Payment_Account__c.SObjectType
    );
    Fake paymentAccountFakeInstance = new Fake(Payment_Account__c.class)
      .setField(Payment_Account__c.Id, paymentAccountId)
      .setField(Payment_Account__c.NetSuite_ID__c, PAYMENT_ACCOUNT_NETSUITE_ID)
      .setField(
        Payment_Account__c.NetSuite_Sync_Response__c,
        PAYMENT_ACCOUNT_NETSUITE_SYNC_RESPONSE
      );
    Payment_Account__c paymentAccount = (Payment_Account__c) ServiceMockDataBuilder.convertToSObject(
      paymentAccountFakeInstance
    );
    fflib_ApexMocks mocks = new fflib_ApexMocks();
    fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
      fflib_ISObjectUnitOfWork.class
    );
    Application.UNITOFWORK.setMock(mockUOW);
    PaymentAccountsService.updatePaymentAccountWithSyncWithNetsuiteResponse(
      paymentAccount
    );
    ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
      .registerDirty(
        fflib_Match.sObjectWith(
          new Map<SObjectField, Object>{
            Payment_Account__c.Id => paymentAccountId,
            Payment_Account__c.NetSuite_ID__c => PAYMENT_ACCOUNT_NETSUITE_ID,
            Payment_Account__c.NetSuite_Sync_Response__c => PAYMENT_ACCOUNT_NETSUITE_SYNC_RESPONSE
          }
        )
      );
    ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
  }
  /**
   * @description To test update on Payment Account 'Syn With Netsuite Response' field value
   * when payment account record is received.
   */
  @isTest
  private static void testWhenPaymentAccountReceivedThenUpatePaymentAccountWithException() {
    Id paymentAccountId = fflib_IDGenerator.generate(
      Payment_Account__c.SObjectType
    );
    String exceptionMessage;
    Fake paymentAccountFakeInstance = new Fake(Payment_Account__c.class)
      .setField(Payment_Account__c.Id, paymentAccountId)
      .setField(Payment_Account__c.NetSuite_ID__c, PAYMENT_ACCOUNT_NETSUITE_ID)
      .setField(Payment_Account__c.Payment_Terms__c, 'Default')
      .setField(
        Payment_Account__c.NetSuite_Sync_Response__c,
        PAYMENT_ACCOUNT_NETSUITE_SYNC_RESPONSE
      );
    Payment_Account__c paymentAccount = (Payment_Account__c) ServiceMockDataBuilder.convertToSObject(
      paymentAccountFakeInstance
    );
    fflib_ApexMocks mocks = new fflib_ApexMocks();
    fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
      fflib_ISObjectUnitOfWork.class
    );
    mocks.startStubbing();
    ((fflib_ISObjectUnitOfWork) mocks.doThrowWhen(
        new TestCommitException(MOCK_EXCEPTION_MESSAGE),
        mockUOW
      ))
      .commitWork();
    mocks.stopStubbing();
    Application.UNITOFWORK.setMock(mockUOW);
    try {
      PaymentAccountsService.updatePaymentAccountWithSyncWithNetsuiteResponse(
        paymentAccount
      );
      ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
        .registerDirty(
          fflib_Match.sObjectWith(
            new Map<SObjectField, Object>{
              Payment_Account__c.Id => paymentAccountId,
              Payment_Account__c.NetSuite_ID__c => PAYMENT_ACCOUNT_NETSUITE_ID,
              Payment_Account__c.NetSuite_Sync_Response__c => PAYMENT_ACCOUNT_NETSUITE_SYNC_RESPONSE
            }
          )
        );
      ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    } catch (Exception mockException) {
      exceptionMessage = mockException.getMessage();
    }
    System.assertEquals(
      MOCK_EXCEPTION_MESSAGE,
      exceptionMessage,
      EXCEPTION_MISMATCH_ASSERT_MESSAGE
    );
  }

  /**
   * @description Tests when PaymentAccounts are provided then IsParentAccountMerged field set to True.
   */
  @isTest
  @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
  private static void testWhenPaymentAccountsAreProvidedThenIsParentAccountMergedFieldSetToTrue() {
    Payment_Account__c paymentAccount1 = (Payment_Account__c) new Fake(
        Payment_Account__c.class
      )
      .setFakeId()
      .setField(Payment_Account__c.Is_Parent_Account_Merged__c, false)
      .toSObject();

    Payment_Account__c paymentAccount2 = (Payment_Account__c) new Fake(
        Payment_Account__c.class
      )
      .setFakeId()
      .setField(Payment_Account__c.Is_Parent_Account_Merged__c, false)
      .toSObject();

    List<Payment_Account__c> paymentAccounts = new List<Payment_Account__c>{
      paymentAccount1,
      paymentAccount2
    };
    fflib_ApexMocks mocks = new fflib_ApexMocks();
    fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
      fflib_ISObjectUnitOfWork.class
    );
    Application.UNITOFWORK.setMock(mockUOW);
    PaymentAccountsService.processMergedAccountsRelatedRecords(paymentAccounts);

    ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2))
      .registerDirty(fflib_Match.anySObject());
    ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
      .registerDirty(
        fflib_Match.sObjectWith(
          new Map<SObjectField, Object>{
            Payment_Account__c.Id => paymentAccount1.Id,
            Payment_Account__c.Is_Parent_Account_Merged__c => true
          }
        )
      );
    ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
      .registerDirty(
        fflib_Match.sObjectWith(
          new Map<SObjectField, Object>{
            Payment_Account__c.Id => paymentAccount2.Id,
            Payment_Account__c.Is_Parent_Account_Merged__c => true
          }
        )
      );
  }
 /**
   * @description Tests when Exception occurs on DML then Exception is Thrown
   */
  @isTest
  @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
  private static void testWhenExceptionOccursOnDMLThenExceptionIsThrown() {
    Payment_Account__c paymentAccount1 = (Payment_Account__c) new Fake(
        Payment_Account__c.class
      )
      .setFakeId()
      .setField(Payment_Account__c.Is_Parent_Account_Merged__c, false)
      .toSObject();

    Payment_Account__c paymentAccount2 = (Payment_Account__c) new Fake(
        Payment_Account__c.class
      )
      .setFakeId()
      .setField(Payment_Account__c.Is_Parent_Account_Merged__c, false)
      .toSObject();

    List<Payment_Account__c> paymentAccounts = new List<Payment_Account__c>{
      paymentAccount1,
      paymentAccount2
    };
    fflib_ApexMocks mocks = new fflib_ApexMocks();
    fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
      fflib_ISObjectUnitOfWork.class
    );
    mocks.startStubbing();
    ((fflib_ISObjectUnitOfWork) mocks.doThrowWhen(
        new TestCommitException(
          'Exception occurred while performing DML operation'
        ),
        mockUOW
      ))
      .commitWork();
    mocks.stopStubbing();
    Application.UNITOFWORK.setMock(mockUOW);

    try {
      PaymentAccountsService.processMergedAccountsRelatedRecords(
        paymentAccounts
      );
      ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    } catch (Exception mockException) {
      System.assertEquals(
        'Exception occurred while performing DML operation',
        mockException.getMessage(),
        'Unexpected Error: The Exception fired was not a TestCommitException.'
      );
    }
  }

  /**
   * @description To test Payment Accounts of payment record type are created
   * when Mx Onboarding Details received for Marketplace scenario.
   */
  @isTest
  @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
  private static void testWhenMxOnboardingDetailsWithMarketplaceScenarioReceivedThenPaymentAccountsCreated() {
    Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
    Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
    Id mxOnboardingLinkId = fflib_IDGenerator.generate(
      Mx_Onboarding_Link__c.SObjectType
    );
    Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id storeDetailId = fflib_IDGenerator.generate(Store_Detail__c.SObjectType);
    Map<Id, StoreDetailsWrapper> mxStoreAccountDetails = new Map<Id, StoreDetailsWrapper>();
    StoreDetailsWrapper newStoreDetails = new StoreDetailsWrapper();
    newStoreDetails.representativeEmail = MOCK_REPRESENTATIVE_EMAIL;
    newStoreDetails.representativeFirstName = MOCK_REPRESENTATIVE_FIRST_NAME;
    newStoreDetails.representativeLastName = MOCK_REPRESENTATIVE_LAST_NAME;
    newStoreDetails.bankAccountNumber = MOCK_BANK_ACCOUNT_NUMBER;
    newStoreDetails.routingNumber = MOCK_BANK_ACCOUNT_NUMBER;
    newStoreDetails.institutionNumber = MOCK_BANK_ACCOUNT_NUMBER;
    newStoreDetails.paymentDescriptor = MOCK_STREET;
    newStoreDetails.Street = MOCK_STREET;
    newStoreDetails.City = MOCK_CITY;
    mxStoreAccountDetails.put(storeDetailId, newStoreDetails);
    OIFormPayloadWrapper newOIFormPayloadDetails = new OIFormPayloadWrapper(
      contractId
    );
    newOIFormPayloadDetails.paymentMethod = PAYMENT_METHOD_WITHHOLDING;
    Mx_Onboarding_Link__c mxOnboardingLink = (Mx_Onboarding_Link__c) new Fake(
        Mx_Onboarding_Link__c.class
      )
      .setField(Mx_Onboarding_Link__c.Id, mxOnboardingLinkId)
      .setField(
        Mx_Onboarding_Link__c.Onboarding_Scenario__c,
        ONBOARDING_SCENARIO_NET_NEW
      )
      .setField(
        Mx_Onboarding_Link__c.Product_on_Contract__c,
        PRODUCT_MARKETPLACE
      )
      .setField(
        Mx_Onboarding_Link__c.Payload__c,
        JSON.serialize(newOIFormPayloadDetails)
      )
      .setField(Mx_Onboarding_Link__c.Business_Account__c, businessAccountId)
      .setField(Mx_Onboarding_Link__c.UUID__c, UNIQUE_IDENTIFIER)
      .setChildren(
        'Store_Details__r',
        new List<Fake>{
          new Fake(Store_Detail__c.class)
            .setField(
              Store_Detail__c.Bank_Account_Number__c,
              MOCK_BANK_ACCOUNT_NUMBER
            )
            .setField(Store_Detail__c.Id, storeDetailId)
        }
      )
      .toSObject();
    Account storeAccount = (Account) new Fake(Account.class)
      .setField(Account.Id, storeAccountId)
      .setField(Account.BillingCity, MOCK_CITY)
      .setField(Account.BillingStreet, MOCK_STREET)
      .toSObject();
    fflib_ApexMocks mocks = new fflib_ApexMocks();
    fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
      fflib_ISObjectUnitOfWork.class
    );
    IContactsSelector mockContactsSelector = (IContactsSelector) mocks.mock(
      IContactsSelector.class
    );
    IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
      IAccountsSelector.class
    );
    mocks.startStubbing();
    mocks.when(mockAccountsSelector.sObjectType())
      .thenReturn(Account.SObjectType);
    mocks.when(
        mockAccountsSelector.selectAccountsByMxOnboardingLinkIds(
          new Set<String>{ UNIQUE_IDENTIFIER }
        )
      )
      .thenReturn(new List<Account>{ storeAccount });
    mocks.when(mockContactsSelector.sObjectType())
      .thenReturn(Contact.SObjectType);
    mocks.when(
        mockContactsSelector.selectContactByEmailFirstNameLastName(
          new Set<String>{ MOCK_REPRESENTATIVE_FIRST_NAME },
          new Set<String>{ MOCK_REPRESENTATIVE_LAST_NAME },
          new Set<String>{ MOCK_REPRESENTATIVE_EMAIL }
        )
      )
      .thenReturn(
        new List<Contact>{
          new Contact(
            Id = contactId,
            Email = MOCK_REPRESENTATIVE_EMAIL,
            FirstName = MOCK_REPRESENTATIVE_FIRST_NAME,
            LastName = MOCK_REPRESENTATIVE_LAST_NAME
            )
        }
      );
    mocks.stopStubbing();
    Application.SELECTOR.setMock(mockAccountsSelector);
    Application.SELECTOR.setMock(mockContactsSelector);
    Application.UNITOFWORK.setMock(mockUOW);
    Test.startTest();
    PaymentAccountsService.createPaymentAccountsByMxOnboardingLinks(
      new List<Mx_Onboarding_Link__c>{ mxOnboardingLink },
      new Map<Id, BusinessAccountWrapper>(),
      mxStoreAccountDetails
    );
    Test.stopTest();
    ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0))
      .registerNew(
        fflib_Match.sObjectWith(
          new Map<SObjectField, Object>{
            Payment_Account__c.Bank_Account_Number__c => MOCK_BANK_ACCOUNT_NUMBER
          }
        )
      );
    ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
  }

  /**
   * @description To test Payment Accounts of payment record type are created
   * when Mx Onboarding Details received for Drive 'Withholding' scenario.
   */
  @isTest
  @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
  private static void testWhenMxOnboardingDetailsWithDriveWithholdingScenarioReceivedThenPaymentAccountsCreated() {
    Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
    Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
    Id mxOnboardingLinkId = fflib_IDGenerator.generate(
      Mx_Onboarding_Link__c.SObjectType
    );
    Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id businessOnboardingDetailId = fflib_IDGenerator.generate(
      Business_Onboarding_Detail__c.SObjectType
    );
    Map<Id, BusinessAccountWrapper> mxBusinessAccountDetails = new Map<Id, BusinessAccountWrapper>();
    BusinessAccountWrapper newBusinessAccountDetails = new BusinessAccountWrapper();
    newBusinessAccountDetails.representativeEmail = MOCK_REPRESENTATIVE_EMAIL;
    newBusinessAccountDetails.representativeFirstName = MOCK_REPRESENTATIVE_FIRST_NAME;
    newBusinessAccountDetails.representativeLastName = MOCK_REPRESENTATIVE_LAST_NAME;
    newBusinessAccountDetails.bankAccountNumber = MOCK_BANK_ACCOUNT_NUMBER;
    newBusinessAccountDetails.routingNumber = MOCK_BANK_ACCOUNT_NUMBER;
    newBusinessAccountDetails.institutionNumber = MOCK_BANK_ACCOUNT_NUMBER;
    newBusinessAccountDetails.paymentDescriptor = MOCK_STREET;
    newBusinessAccountDetails.Street = MOCK_STREET;
    newBusinessAccountDetails.City = MOCK_CITY;
    mxBusinessAccountDetails.put(
      businessOnboardingDetailId,
      newBusinessAccountDetails
    );
    OIFormPayloadWrapper newOIFormPayloadDetails = new OIFormPayloadWrapper(
      contractId
    );
    newOIFormPayloadDetails.paymentMethod = PAYMENT_METHOD_WITHHOLDING;
    Mx_Onboarding_Link__c mxOnboardingLink = (Mx_Onboarding_Link__c) new Fake(
        Mx_Onboarding_Link__c.class
      )
      .setField(Mx_Onboarding_Link__c.Id, mxOnboardingLinkId)
      .setField(
        Mx_Onboarding_Link__c.Onboarding_Scenario__c,
        ONBOARDING_SCENARIO_PRODUCT_ADDITION
      )
      .setField(
        Mx_Onboarding_Link__c.Product_on_Contract__c,
        String.valueOf(PRODUCT_MARKETPLACE + PLUS_KEY + PRODUCT_DRIVE)
      )
      .setField(
        Mx_Onboarding_Link__c.Payload__c,
        JSON.serialize(newOIFormPayloadDetails)
      )
      .setField(Mx_Onboarding_Link__c.Business_Account__c, businessAccountId)
      .setField(Mx_Onboarding_Link__c.UUID__c, UNIQUE_IDENTIFIER)
      .setChildren(
        'Business_Onboarding_Details__r',
        new List<Fake>{
          new Fake(Business_Onboarding_Detail__c.class)
            .setField(
              Business_Onboarding_Detail__c.Bank_Account_Number__c,
              MOCK_BANK_ACCOUNT_NUMBER
            )
            .setField(
              Business_Onboarding_Detail__c.Id,
              businessOnboardingDetailId
            )
        }
      )
      .toSObject();
    Account storeAccount = (Account) new Fake(Account.class)
      .setField(Account.Id, storeAccountId)
      .setField(Account.BillingCity, MOCK_CITY)
      .setField(Account.BillingStreet, MOCK_STREET)
      .toSObject();
    fflib_ApexMocks mocks = new fflib_ApexMocks();
    fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
      fflib_ISObjectUnitOfWork.class
    );
    IContactsSelector mockContactsSelector = (IContactsSelector) mocks.mock(
      IContactsSelector.class
    );
    IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
      IAccountsSelector.class
    );
    mocks.startStubbing();
    mocks.when(mockAccountsSelector.sObjectType())
      .thenReturn(Account.SObjectType);
    mocks.when(
        mockAccountsSelector.selectAccountsByMxOnboardingLinkIds(
          new Set<String>{ UNIQUE_IDENTIFIER }
        )
      )
      .thenReturn(new List<Account>{ storeAccount });
    mocks.when(mockContactsSelector.sObjectType())
      .thenReturn(Contact.SObjectType);
    mocks.when(
        mockContactsSelector.selectContactByEmailFirstNameLastName(
          new Set<String>{ MOCK_REPRESENTATIVE_FIRST_NAME },
          new Set<String>{ MOCK_REPRESENTATIVE_LAST_NAME },
          new Set<String>{ MOCK_REPRESENTATIVE_EMAIL }
        )
      )
      .thenReturn(
        new List<Contact>{
          new Contact(
            Id = contactId,
            Email = MOCK_REPRESENTATIVE_EMAIL,
            FirstName = MOCK_REPRESENTATIVE_FIRST_NAME,
            LastName = MOCK_REPRESENTATIVE_LAST_NAME
            )
        }
      );
    mocks.stopStubbing();
    Application.SELECTOR.setMock(mockAccountsSelector);
    Application.SELECTOR.setMock(mockContactsSelector);
    Application.UNITOFWORK.setMock(mockUOW);
    Test.startTest();
    PaymentAccountsService.createPaymentAccountsByMxOnboardingLinks(
      new List<Mx_Onboarding_Link__c>{ mxOnboardingLink },
      mxBusinessAccountDetails,
      new Map<Id, StoreDetailsWrapper>()
    );
    Test.stopTest();
    ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
      .registerNew(
        fflib_Match.sObjectWith(
          new Map<SObjectField, Object>{
            Payment_Account__c.Bank_Account_Number__c => MOCK_BANK_ACCOUNT_NUMBER
          }
        )
      );
    ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
  }

  /**
   * @description To test Payment Accounts of invoice record type are created
   * when Mx Onboarding Details received for Drive 'Invoicing' scenario.
   */
  @isTest
  @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
  private static void testWhenMxOnboardingDetailsWithDriveInvoicingScenarioReceivedThenInvoicePaymentAccountsCreated() {
    Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
    Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
    Id mxOnboardingLinkId = fflib_IDGenerator.generate(
      Mx_Onboarding_Link__c.SObjectType
    );
    Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id businessOnboardingDetailId = fflib_IDGenerator.generate(
      Business_Onboarding_Detail__c.SObjectType
    );
    Map<Id, BusinessAccountWrapper> mxBusinessAccountDetails = new Map<Id, BusinessAccountWrapper>();
    BusinessAccountWrapper newBusinessAccountDetails = new BusinessAccountWrapper();
    newBusinessAccountDetails.billingContactEmail = MOCK_REPRESENTATIVE_EMAIL;
    newBusinessAccountDetails.billingContactFirstName = MOCK_REPRESENTATIVE_FIRST_NAME;
    newBusinessAccountDetails.billingContactLastName = MOCK_REPRESENTATIVE_LAST_NAME;
    newBusinessAccountDetails.representativeEmail = MOCK_REPRESENTATIVE_EMAIL;
    newBusinessAccountDetails.paymentStreet = PAYMENT_STREET;
    newBusinessAccountDetails.paymentCity = PAYMENT_CITY;
    newBusinessAccountDetails.paymentStateCode = PAYMENT_STATECODE;
    newBusinessAccountDetails.paymentZipPostalCode = PAYMENT_POSTAL_CODE;
    mxBusinessAccountDetails.put(
      businessOnboardingDetailId,
      newBusinessAccountDetails
    );
    OIFormPayloadWrapper newOIFormPayloadDetails = new OIFormPayloadWrapper(
      contractId
    );
    newOIFormPayloadDetails.paymentMethod = PAYMENT_METHOD_INVOICING;
    Mx_Onboarding_Link__c mxOnboardingLink = (Mx_Onboarding_Link__c) new Fake(
        Mx_Onboarding_Link__c.class
      )
      .setField(Mx_Onboarding_Link__c.Id, mxOnboardingLinkId)
      .setField(
        Mx_Onboarding_Link__c.Onboarding_Scenario__c,
        ONBOARDING_SCENARIO_PRODUCT_ADDITION
      )
      .setField(
        Mx_Onboarding_Link__c.Product_on_Contract__c,
        String.valueOf(PRODUCT_MARKETPLACE + PLUS_KEY + PRODUCT_DRIVE)
      )
      .setField(
        Mx_Onboarding_Link__c.Payload__c,
        JSON.serialize(newOIFormPayloadDetails)
      )
      .setField(Mx_Onboarding_Link__c.Business_Account__c, businessAccountId)
      .setField(Mx_Onboarding_Link__c.UUID__c, UNIQUE_IDENTIFIER)
      .setChildren(
        'Business_Onboarding_Details__r',
        new List<Fake>{
          new Fake(Business_Onboarding_Detail__c.class)
            .setField(
              Business_Onboarding_Detail__c.Bank_Account_Number__c,
              MOCK_BANK_ACCOUNT_NUMBER
            )
            .setField(
              Business_Onboarding_Detail__c.Billing_Contact_First_Name__c,
              MOCK_REPRESENTATIVE_FIRST_NAME
            )
            .setField(
              Business_Onboarding_Detail__c.Billing_Contact_Last_Name__c,
              MOCK_REPRESENTATIVE_LAST_NAME
            )
            .setField(
              Business_Onboarding_Detail__c.Billing_Contact_Email__c,
              MOCK_REPRESENTATIVE_EMAIL
            )
            .setField(
              Business_Onboarding_Detail__c.Id,
              businessOnboardingDetailId
            )
        }
      )
      .toSObject();
    Account storeAccount = (Account) new Fake(Account.class)
      .setField(Account.Id, storeAccountId)
      .setField(Account.BillingCity, MOCK_CITY)
      .setField(Account.BillingStreet, MOCK_STREET)
      .toSObject();
    fflib_ApexMocks mocks = new fflib_ApexMocks();
    fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
      fflib_ISObjectUnitOfWork.class
    );
    IContactsSelector mockContactsSelector = (IContactsSelector) mocks.mock(
      IContactsSelector.class
    );
    IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
      IAccountsSelector.class
    );
    mocks.startStubbing();
    mocks.when(mockAccountsSelector.sObjectType())
      .thenReturn(Account.SObjectType);
    mocks.when(
        mockAccountsSelector.selectAccountsByMxOnboardingLinkIds(
          new Set<String>{ UNIQUE_IDENTIFIER }
        )
      )
      .thenReturn(new List<Account>{ storeAccount });
    mocks.when(mockContactsSelector.sObjectType())
      .thenReturn(Contact.SObjectType);
    mocks.when(
        mockContactsSelector.selectContactByEmailFirstNameLastName(
          new Set<String>{ MOCK_REPRESENTATIVE_FIRST_NAME },
          new Set<String>{ MOCK_REPRESENTATIVE_LAST_NAME },
          new Set<String>{ MOCK_REPRESENTATIVE_EMAIL }
        )
      )
      .thenReturn(
        new List<Contact>{
          new Contact(
            Id = contactId,
            Email = MOCK_REPRESENTATIVE_EMAIL,
            firstName = MOCK_REPRESENTATIVE_FIRST_NAME,
            lastName = MOCK_REPRESENTATIVE_LAST_NAME
          )
        }
      );
    mocks.stopStubbing();
    Application.SELECTOR.setMock(mockAccountsSelector);
    Application.SELECTOR.setMock(mockContactsSelector);
    Application.UNITOFWORK.setMock(mockUOW);
    Test.startTest();
    PaymentAccountsService.createPaymentAccountsByMxOnboardingLinks(
      new List<Mx_Onboarding_Link__c>{ mxOnboardingLink },
      mxBusinessAccountDetails,
      new Map<Id, StoreDetailsWrapper>()
    );
    Test.stopTest();
    ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
      .registerNew(
        fflib_Match.sObjectWith(
          new Map<SObjectField, Object>{
            Payment_Account__c.Business_Account__c => businessAccountId
          }
        )
      );
    ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
  }
}
