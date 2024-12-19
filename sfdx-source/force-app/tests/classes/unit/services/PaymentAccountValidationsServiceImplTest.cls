/**
 * @author Deloitte
 * @date 11/27/2022
 * @description Test class for PaymentAccountValidationsServiceImpl class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts,PMD.MethodNamingConventions')
private class PaymentAccountValidationsServiceImplTest {
  private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
  private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
  private static final String CONTRACT_SIGNED = 'Contract Signed';
  private static final String CORRECT_INSTITUTION_NUMBER = '123';
  private static final String CUSTOM_METADATA_ERROR_MESSAGE_BILLING_CONTACT_NAME = 'Please ensure Stripe Account Owner/Billing Contact Name is populated on payment account on the store.';
  private static final String CUSTOM_METADATA_ERROR_MESSAGE_INSTITUTION_NUMBER = 'Please ensure Institution Number on the Payment Account related to the store is populated.';
  private static final String CUSTOM_METADATA_ERROR_MESSAGE_NETSUITE_ID = 'Please ensure the Netsuite ID is populated by clicking on Sync with Netsuite button to sync the payment account.';
  private static final String CUSTOM_METADATA_ERROR_MESSAGE_PAYMENT_ACCOUNT_ON_BUSINESS = 'Please ensure a Payment Account is associated to the business account';
  private static final String CUSTOM_METADATA_ERROR_MESSAGE_PAYMENT_ACCOUNT_ON_STORE = 'Please ensure a Payment Account is associated to the store account.';
  private static final String DASHER_PICK_SHOPPING_PROTOCOL = 'Dasher Pick';
  private static final String FIELD_LABEL_BILLING_CONTACT_NAME = 'Billing Contact Name';
  private static final String FIELD_LABEL_INSTITUTION_NUMBER = 'Institution Number';
  private static final String FIELD_LABEL_NETSUITE_ID = 'NetSuite ID';
  private static final String FIELD_NAME_BILLING_CONTACT_NAME = 'Billing_Contact_Name__c';
  private static final String FIELD_NAME_INSTITUTION_NUMBER = 'Institution_Number__c';
  private static final String FIELD_NAME_NETSUITE_ID = 'NetSuite_ID__c';
  private static final String INCORRECT_INSTITUTION_NUMBER = '3219';
  private static final String INSTITUTION_NUMBER_ELIGIBILITY_CRITERIA = System.Label.InstitutionNumOnPAReadinessCheckCriteria;
  private static final String LINK = 'Link';
  private static final String NETSUITE_ID = '12345';
  private static final String PAYMENT_ACCOUNT_OBJECT_NAME = 'Payment Account';
  private static final String PAYMENT_ACCOUNT_OBJECT_API_NAME = 'Payment_Account__c';
  private static final string PAYMENT_ACCOUNT_INVOICE_RECORD_TYPE_ID = Schema.SObjectType.Payment_Account__c.getRecordTypeInfosByName()
    .get('Invoice')
    .getRecordTypeId();
  private static final string PAYMENT_ACCOUNT_PAYMENTS_RECORD_TYPE_ID = Schema.SObjectType.Payment_Account__c.getRecordTypeInfosByName()
    .get('Payments')
    .getRecordTypeId();
  private static final String PAYMENT_ACCOUNT_RECORD_TYPE_INVOICE = 'Invoice';
  private static final String PAYMENT_ACCOUNT_RECORD_TYPE_PAYMENTS = 'Payments';
  private static final String SEGMENT_SMB = 'SMB';
  private static final String SEPARATOR = System.Label.Separator;
  private static final String SERVICE_CLASS_NAME = 'IPaymentAccountValidationsService';
  private static final String SERVICE_METHOD_VALIDATE_INSTITUTION_NUMBER = 'validateInstitutionNumberOnPaymentAccounts';
  private static final String SERVICE_METHOD_VALIDATE_NULL_FIELD_VALUES_ON_INVOICE_RECORD_TYPE = 'validateNullFieldValuesOnInvoiceRecordType';
  private static final String SERVICE_METHOD_VALIDATE_NULL_FIELD_VALUES_ON_PAYMENTS_RECORD_TYPE = 'validateNullFieldValuesOnPaymentsRecordType';
  private static final String SERVICE_METHOD_VALIDATE_PAYMENT_ACCOUNT_ON_BUSINESS = 'validatePaymentAccountsOnBusiness';
  private static final String SERVICE_METHOD_VALIDATE_PAYMENT_ACCOUNT_ON_STORE = 'validatePaymentAccountsOnStore';
  private static final String DEVELOPER_NAME_PAYMENT_ACCOUNT_REQUIRED_ON_STORE = 'Payment_Account_required_on_Store';
  private static final String DEVELOPER_NAME_BILLING_CONTRACT_REQ_ON_PAYMENT_ACCOUNT = 'Billing_Contact_req_on_Payment_Account';
  private static final String VERTICAL = 'Floral';
  private static final String WORKORDER_TYPE_COO = 'COO';
  private static final String WORKORDER_TYPE_DRIVE = 'Drive';
  private static final String WORKORDER_TYPE_MARKETPLACE = 'Marketplace';
  private static final String WORKORDER_TYPE_STOREFRONT = 'Storefront';

  /**
   * @description To test validation of "NetSuite ID" field with blank value on the Invoice
   * Payment Account related to business Account associated with parent Work Order.
   */
  @isTest
  private static void testWhenPaymentAccountNetSuiteIdBlankOnBusinessThenReadinessCheckFailuresCreated() {
    Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
    Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id paymentAccountId = fflib_IDGenerator.generate(
      Payment_Account__c.SObjectType
    );
    List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
      (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
        ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
          CUSTOM_METADATA_ERROR_MESSAGE_NETSUITE_ID,
          FIELD_LABEL_NETSUITE_ID,
          SERVICE_METHOD_VALIDATE_NULL_FIELD_VALUES_ON_INVOICE_RECORD_TYPE,
          PAYMENT_ACCOUNT_OBJECT_NAME,
          SERVICE_CLASS_NAME
        )
      )
    };
    storeReadinessValidationRules[0].Field_Name__c = FIELD_NAME_NETSUITE_ID;
    Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
        VERTICAL,
        ACCOUNT_RECORD_TYPE_NAME_BUSINESS
      )
      .setField(Account.Id, businessAccountId)
      .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
    Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
      businessAccountFakeInstance
    );
    Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
        businessAccount.Id,
        VERTICAL
      )
      .setField(Account.Id, storeAccountId)
      .setParent('Parent', businessAccountFakeInstance);
    Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
      storeAccountFakeInstance
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
    Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
        businessAccount.Id,
        WORKORDER_TYPE_MARKETPLACE
      )
      .setField(WorkOrder.Id, parentWorkOrderId)
      .setField(
        WorkOrder.Account_Record_Type_Name__c,
        ACCOUNT_RECORD_TYPE_NAME_BUSINESS
      )
      .setParent('Account', businessAccountFakeInstance);
    WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
      parentWorkOrderFakeInstance
    );
    Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
        storeAccount.Id,
        WORKORDER_TYPE_MARKETPLACE,
        parentWorkOrder.Id
      )
      .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
      .setParent('Account', storeAccountFakeInstance)
      .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
    WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
      childWorkOrderFakeInstance
    );
    accountPaymentAccountRelationFakeInstance
      .setField(
        Account_Payment_Account_Relation__c.Account__c,
        businessAccount.Id
      )
      .setField(
        Account_Payment_Account_Relation__c.Payment_Account__c,
        paymentAccountId
      )
      .setField(
        Account_Payment_Account_Relation__c.Record_Type__c,
        PAYMENT_ACCOUNT_RECORD_TYPE_INVOICE
      )
      .setParent(
        'Payment_Account__r',
        new Fake(Payment_Account__c.class)
          .setField(Payment_Account__c.Id, paymentAccountId)
          .setField(
            Payment_Account__c.RecordTypeId,
            PAYMENT_ACCOUNT_INVOICE_RECORD_TYPE_ID
          )
      );
    Account_Payment_Account_Relation__c accountPaymentAccountRelation = (Account_Payment_Account_Relation__c) ServiceMockDataBuilder.convertToSObject(
      accountPaymentAccountRelationFakeInstance
    );
    List<Readiness_Check_Failure__c> mockReadinessValidationRuleFailureRecords = new List<Readiness_Check_Failure__c>{
      new Readiness_Check_Failure__c(
        Object_Name__c = storeReadinessValidationRules[0].Object_Label__c,
        Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
        Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
        Parent_Work_Order__c = parentWorkOrder.Id,
        Account_Name__c = parentWorkOrder.AccountId,
        Payment_Account_Name__c = paymentAccountId,
        Child_Work_Order__c = parentWorkOrder.Id
      )
    };

    List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

    fflib_ApexMocks mocks = new fflib_ApexMocks();
    IAccountPaymentAccountRelationsSelector mockSelector = (IAccountPaymentAccountRelationsSelector) mocks.mock(
      IAccountPaymentAccountRelationsSelector.class
    );
    fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
      fflib_ISObjectUnitOfWork.class
    );
    mocks.startStubbing();
    mocks.when(mockSelector.sObjectType())
      .thenReturn(Account_Payment_Account_Relation__c.SObjectType);
    mocks.when(
        mockSelector.selectByAccountIdsAndPaymentAccountRecordTypes(
          new Set<Id>{ businessAccount.Id, storeAccount.Id },
          new Set<String>{
            PAYMENT_ACCOUNT_RECORD_TYPE_INVOICE,
            PAYMENT_ACCOUNT_RECORD_TYPE_PAYMENTS
          }
        )
      )
      .thenReturn(
        new List<Account_Payment_Account_Relation__c>{
          accountPaymentAccountRelation
        }
      );
    mocks.stopStubbing();
    Application.UNITOFWORK.setMock(mockUOW);
    Application.SELECTOR.setMock(mockSelector);
    PaymentAccountValidationsServiceImpl paymentAccountValidationsServiceImplInstance = new PaymentAccountValidationsServiceImpl();
    paymentAccountValidationsServiceImplInstance.validate(
      new List<WorkOrder>{ childWorkOrder },
      new List<WorkOrder>{ parentWorkOrder },
      storeReadinessValidationRules,
      mockExistingReadinessCheckFailures,
      PAYMENT_ACCOUNT_OBJECT_API_NAME
    );
    ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
      .registerNew(mockReadinessValidationRuleFailureRecords);
    ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
  }

  /**
   * @description To test when "NetSuite ID" field is populated on the Invoice Payment Account
   * related to business Account associated with parent Work Order then
   * Readiness Check Failures are not created.
   */
  @isTest
  private static void testWhenPaymentAccountNetSuiteIdOnBusinessPopulatedThenReadinessCheckFailuresNotCreated() {
    Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
    Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id paymentAccountId = fflib_IDGenerator.generate(
      Payment_Account__c.SObjectType
    );
    List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
      (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
        ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
          CUSTOM_METADATA_ERROR_MESSAGE_NETSUITE_ID,
          FIELD_LABEL_NETSUITE_ID,
          SERVICE_METHOD_VALIDATE_NULL_FIELD_VALUES_ON_INVOICE_RECORD_TYPE,
          PAYMENT_ACCOUNT_OBJECT_API_NAME,
          SERVICE_CLASS_NAME
        )
      )
    };
    storeReadinessValidationRules[0].Field_Name__c = FIELD_NAME_NETSUITE_ID;
    Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
        VERTICAL,
        ACCOUNT_RECORD_TYPE_NAME_BUSINESS
      )
      .setField(Account.Id, businessAccountId)
      .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
    Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
      businessAccountFakeInstance
    );
    Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
        businessAccount.Id,
        VERTICAL
      )
      .setField(Account.Id, storeAccountId)
      .setParent('Parent', businessAccountFakeInstance);
    Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
      storeAccountFakeInstance
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
    Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
        businessAccount.Id,
        WORKORDER_TYPE_MARKETPLACE
      )
      .setField(WorkOrder.Id, parentWorkOrderId)
      .setField(
        WorkOrder.Account_Record_Type_Name__c,
        ACCOUNT_RECORD_TYPE_NAME_BUSINESS
      )
      .setParent('Account', businessAccountFakeInstance);
    WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
      parentWorkOrderFakeInstance
    );
    Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
        storeAccount.Id,
        WORKORDER_TYPE_MARKETPLACE,
        parentWorkOrder.Id
      )
      .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
      .setParent('Account', storeAccountFakeInstance)
      .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
    WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
      childWorkOrderFakeInstance
    );
    accountPaymentAccountRelationFakeInstance
      .setField(
        Account_Payment_Account_Relation__c.Account__c,
        businessAccount.Id
      )
      .setField(
        Account_Payment_Account_Relation__c.Payment_Account__c,
        paymentAccountId
      )
      .setField(
        Account_Payment_Account_Relation__c.Record_Type__c,
        PAYMENT_ACCOUNT_RECORD_TYPE_INVOICE
      )
      .setParent(
        'Payment_Account__r',
        new Fake(Payment_Account__c.class)
          .setField(Payment_Account__c.Id, paymentAccountId)
          .setField(Payment_Account__c.NetSuite_ID__c, NETSUITE_ID)
          .setField(
            Payment_Account__c.RecordTypeId,
            PAYMENT_ACCOUNT_INVOICE_RECORD_TYPE_ID
          )
      );
    Account_Payment_Account_Relation__c accountPaymentAccountRelation = (Account_Payment_Account_Relation__c) ServiceMockDataBuilder.convertToSObject(
      accountPaymentAccountRelationFakeInstance
    );
    List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

    fflib_ApexMocks mocks = new fflib_ApexMocks();
    IAccountPaymentAccountRelationsSelector mockSelector = (IAccountPaymentAccountRelationsSelector) mocks.mock(
      IAccountPaymentAccountRelationsSelector.class
    );
    fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
      fflib_ISObjectUnitOfWork.class
    );
    mocks.startStubbing();
    mocks.when(mockSelector.sObjectType())
      .thenReturn(Account_Payment_Account_Relation__c.SObjectType);
    mocks.when(
        mockSelector.selectByAccountIdsAndPaymentAccountRecordTypes(
          new Set<Id>{ businessAccount.Id, storeAccount.Id },
          new Set<String>{
            PAYMENT_ACCOUNT_RECORD_TYPE_INVOICE,
            PAYMENT_ACCOUNT_RECORD_TYPE_PAYMENTS
          }
        )
      )
      .thenReturn(
        new List<Account_Payment_Account_Relation__c>{
          accountPaymentAccountRelation
        }
      );
    mocks.stopStubbing();
    Application.UNITOFWORK.setMock(mockUOW);
    Application.SELECTOR.setMock(mockSelector);
    PaymentAccountValidationsServiceImpl paymentAccountValidationsServiceImplInstance = new PaymentAccountValidationsServiceImpl();
    paymentAccountValidationsServiceImplInstance.validate(
      new List<WorkOrder>{ childWorkOrder },
      new List<WorkOrder>{ parentWorkOrder },
      storeReadinessValidationRules,
      mockExistingReadinessCheckFailures,
      PAYMENT_ACCOUNT_OBJECT_API_NAME
    );
    ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
  }

  /**
   * @description To test validation of "Billing Contact Name" field with blank value on the Payment Account
   * of Payments record type related to store Account associated with child Work Order.
   */
  @isTest
  private static void testWhenBillingContactNameBlankOnPaymentAccountWithPaymentsRecordTypeThenReadinessCheckFailuresCreated() {
    Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
    Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id paymentAccountId = fflib_IDGenerator.generate(
      Payment_Account__c.SObjectType
    );
    List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
      (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
        ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
          CUSTOM_METADATA_ERROR_MESSAGE_BILLING_CONTACT_NAME,
          FIELD_LABEL_BILLING_CONTACT_NAME,
          SERVICE_METHOD_VALIDATE_NULL_FIELD_VALUES_ON_PAYMENTS_RECORD_TYPE,
          PAYMENT_ACCOUNT_OBJECT_NAME,
          SERVICE_CLASS_NAME
        )
      )
    };
    storeReadinessValidationRules[0]
      .Field_Name__c = FIELD_NAME_BILLING_CONTACT_NAME;
    Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
        VERTICAL,
        ACCOUNT_RECORD_TYPE_NAME_BUSINESS
      )
      .setField(Account.Id, businessAccountId)
      .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
    Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
      businessAccountFakeInstance
    );
    Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
        businessAccount.Id,
        VERTICAL
      )
      .setField(Account.Id, storeAccountId)
      .setParent('Parent', businessAccountFakeInstance);
    Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
      storeAccountFakeInstance
    );
    Fake accountPaymentAccountRelationFakeInstance = new Fake(
        Account_Payment_Account_Relation__c.class
      )
      .setField(
        Account_Payment_Account_Relation__c.Account_Record_Type__c,
        ACCOUNT_RECORD_TYPE_NAME_STORE
      )
      .setParent('Account__r', storeAccountFakeInstance)
      .setFakeId();
    Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
        businessAccount.Id,
        WORKORDER_TYPE_MARKETPLACE
      )
      .setField(WorkOrder.Id, parentWorkOrderId)
      .setField(
        WorkOrder.Account_Record_Type_Name__c,
        ACCOUNT_RECORD_TYPE_NAME_BUSINESS
      )
      .setParent('Account', businessAccountFakeInstance);
    WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
      parentWorkOrderFakeInstance
    );
    Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
        storeAccount.Id,
        WORKORDER_TYPE_MARKETPLACE,
        parentWorkOrder.Id
      )
      .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
      .setParent('Account', storeAccountFakeInstance)
      .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
    WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
      childWorkOrderFakeInstance
    );
    accountPaymentAccountRelationFakeInstance
      .setField(Account_Payment_Account_Relation__c.Account__c, storeAccount.Id)
      .setField(
        Account_Payment_Account_Relation__c.Payment_Account__c,
        paymentAccountId
      )
      .setField(
        Account_Payment_Account_Relation__c.Record_Type__c,
        PAYMENT_ACCOUNT_RECORD_TYPE_PAYMENTS
      )
      .setParent(
        'Payment_Account__r',
        new Fake(Payment_Account__c.class)
          .setField(Payment_Account__c.Id, paymentAccountId)
          .setField(
            Payment_Account__c.RecordTypeId,
            PAYMENT_ACCOUNT_PAYMENTS_RECORD_TYPE_ID
          )
      );
    Account_Payment_Account_Relation__c accountPaymentAccountRelation = (Account_Payment_Account_Relation__c) ServiceMockDataBuilder.convertToSObject(
      accountPaymentAccountRelationFakeInstance
    );
    List<Readiness_Check_Failure__c> mockReadinessValidationRuleFailureRecords = new List<Readiness_Check_Failure__c>{
      new Readiness_Check_Failure__c(
        Object_Name__c = storeReadinessValidationRules[0].Object_Label__c,
        Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
        Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
        Parent_Work_Order__c = parentWorkOrder.Id,
        Account_Name__c = storeAccount.Id,
        Payment_Account_Name__c = paymentAccountId,
        Child_Work_Order__c = childWorkOrder.Id
      )
    };

    List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

    fflib_ApexMocks mocks = new fflib_ApexMocks();
    IAccountPaymentAccountRelationsSelector mockSelector = (IAccountPaymentAccountRelationsSelector) mocks.mock(
      IAccountPaymentAccountRelationsSelector.class
    );
    fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
      fflib_ISObjectUnitOfWork.class
    );
    mocks.startStubbing();
    mocks.when(mockSelector.sObjectType())
      .thenReturn(Account_Payment_Account_Relation__c.SObjectType);
    mocks.when(
        mockSelector.selectByAccountIdsAndPaymentAccountRecordTypes(
          new Set<Id>{ businessAccount.Id, storeAccount.Id },
          new Set<String>{
            PAYMENT_ACCOUNT_RECORD_TYPE_INVOICE,
            PAYMENT_ACCOUNT_RECORD_TYPE_PAYMENTS
          }
        )
      )
      .thenReturn(
        new List<Account_Payment_Account_Relation__c>{
          accountPaymentAccountRelation
        }
      );
    mocks.stopStubbing();
    Application.UNITOFWORK.setMock(mockUOW);
    Application.SELECTOR.setMock(mockSelector);
    PaymentAccountValidationsServiceImpl paymentAccountValidationsServiceImplInstance = new PaymentAccountValidationsServiceImpl();
    paymentAccountValidationsServiceImplInstance.validate(
      new List<WorkOrder>{ childWorkOrder },
      new List<WorkOrder>{ parentWorkOrder },
      storeReadinessValidationRules,
      mockExistingReadinessCheckFailures,
      PAYMENT_ACCOUNT_OBJECT_API_NAME
    );
    ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
      .registerNew(mockReadinessValidationRuleFailureRecords);
    ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
  }

  /**
   * @description To test when "Billing Contact Name" field is populated on the Payment Account
   * of Payments record type related to store Account associated with child Work Order then
   * Readiness Check Failures are not created.
   */
  @isTest
  private static void testWhenBillingContactNameOnPaymentAccountPopulatedThenReadinessCheckFailuresNotCreated() {
    Id billingContactId = fflib_IDGenerator.generate(Contact.SObjectType);
    Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
    Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id paymentAccountId = fflib_IDGenerator.generate(
      Payment_Account__c.SObjectType
    );
    List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
      (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
        ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
          CUSTOM_METADATA_ERROR_MESSAGE_BILLING_CONTACT_NAME,
          FIELD_LABEL_BILLING_CONTACT_NAME,
          SERVICE_METHOD_VALIDATE_NULL_FIELD_VALUES_ON_PAYMENTS_RECORD_TYPE,
          PAYMENT_ACCOUNT_OBJECT_NAME,
          SERVICE_CLASS_NAME
        )
      )
    };
    storeReadinessValidationRules[0]
      .Field_Name__c = FIELD_NAME_BILLING_CONTACT_NAME;
    Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
        VERTICAL,
        ACCOUNT_RECORD_TYPE_NAME_BUSINESS
      )
      .setField(Account.Id, businessAccountId)
      .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
    Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
      businessAccountFakeInstance
    );
    Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
        businessAccount.Id,
        VERTICAL
      )
      .setField(Account.Id, storeAccountId)
      .setParent('Parent', businessAccountFakeInstance);
    Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
      storeAccountFakeInstance
    );
    Fake accountPaymentAccountRelationFakeInstance = new Fake(
        Account_Payment_Account_Relation__c.class
      )
      .setField(
        Account_Payment_Account_Relation__c.Account_Record_Type__c,
        ACCOUNT_RECORD_TYPE_NAME_STORE
      )
      .setParent('Account__r', storeAccountFakeInstance)
      .setFakeId();
    Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
        businessAccount.Id,
        WORKORDER_TYPE_MARKETPLACE
      )
      .setField(WorkOrder.Id, parentWorkOrderId)
      .setField(
        WorkOrder.Account_Record_Type_Name__c,
        ACCOUNT_RECORD_TYPE_NAME_BUSINESS
      )
      .setParent('Account', businessAccountFakeInstance);
    WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
      parentWorkOrderFakeInstance
    );
    Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
        storeAccount.Id,
        WORKORDER_TYPE_MARKETPLACE,
        parentWorkOrder.Id
      )
      .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
      .setParent('Account', storeAccountFakeInstance)
      .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
    WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
      childWorkOrderFakeInstance
    );
    accountPaymentAccountRelationFakeInstance
      .setField(Account_Payment_Account_Relation__c.Account__c, storeAccount.Id)
      .setField(
        Account_Payment_Account_Relation__c.Payment_Account__c,
        paymentAccountId
      )
      .setField(
        Account_Payment_Account_Relation__c.Record_Type__c,
        PAYMENT_ACCOUNT_RECORD_TYPE_PAYMENTS
      )
      .setParent(
        'Payment_Account__r',
        new Fake(Payment_Account__c.class)
          .setField(Payment_Account__c.Id, paymentAccountId)
          .setField(
            Payment_Account__c.Billing_Contact_Name__c,
            billingContactId
          )
          .setField(
            Payment_Account__c.RecordTypeId,
            PAYMENT_ACCOUNT_PAYMENTS_RECORD_TYPE_ID
          )
      );
    Account_Payment_Account_Relation__c accountPaymentAccountRelation = (Account_Payment_Account_Relation__c) ServiceMockDataBuilder.convertToSObject(
      accountPaymentAccountRelationFakeInstance
    );
    List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

    fflib_ApexMocks mocks = new fflib_ApexMocks();
    IAccountPaymentAccountRelationsSelector mockSelector = (IAccountPaymentAccountRelationsSelector) mocks.mock(
      IAccountPaymentAccountRelationsSelector.class
    );
    fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
      fflib_ISObjectUnitOfWork.class
    );
    mocks.startStubbing();
    mocks.when(mockSelector.sObjectType())
      .thenReturn(Account_Payment_Account_Relation__c.SObjectType);
    mocks.when(
        mockSelector.selectByAccountIdsAndPaymentAccountRecordTypes(
          new Set<Id>{ businessAccount.Id, storeAccount.Id },
          new Set<String>{
            PAYMENT_ACCOUNT_RECORD_TYPE_INVOICE,
            PAYMENT_ACCOUNT_RECORD_TYPE_PAYMENTS
          }
        )
      )
      .thenReturn(
        new List<Account_Payment_Account_Relation__c>{
          accountPaymentAccountRelation
        }
      );
    mocks.stopStubbing();
    Application.UNITOFWORK.setMock(mockUOW);
    Application.SELECTOR.setMock(mockSelector);
    PaymentAccountValidationsServiceImpl paymentAccountValidationsServiceImplInstance = new PaymentAccountValidationsServiceImpl();
    paymentAccountValidationsServiceImplInstance.validate(
      new List<WorkOrder>{ childWorkOrder },
      new List<WorkOrder>{ parentWorkOrder },
      storeReadinessValidationRules,
      mockExistingReadinessCheckFailures,
      PAYMENT_ACCOUNT_OBJECT_API_NAME
    );
    ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
  }

  /**
   * @description To test when "Billing Contact Name" field is not populated on the Payment Account
   * of Invoice record type related to store Account associated with child Work Order then
   * Readiness Check Failures are not created.
   */
  @isTest
  private static void testWhenBillingContactNameOnInvoicePaymentAccountNotPopulatedThenReadinessCheckFailuresNotCreated() {
    Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
    Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id paymentAccountId = fflib_IDGenerator.generate(
      Payment_Account__c.SObjectType
    );
    List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
      (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
        ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
          CUSTOM_METADATA_ERROR_MESSAGE_BILLING_CONTACT_NAME,
          FIELD_LABEL_BILLING_CONTACT_NAME,
          SERVICE_METHOD_VALIDATE_NULL_FIELD_VALUES_ON_PAYMENTS_RECORD_TYPE,
          PAYMENT_ACCOUNT_OBJECT_NAME,
          SERVICE_CLASS_NAME
        )
      )
    };
    storeReadinessValidationRules[0]
      .Field_Name__c = FIELD_NAME_BILLING_CONTACT_NAME;
    Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
        VERTICAL,
        ACCOUNT_RECORD_TYPE_NAME_BUSINESS
      )
      .setField(Account.Id, businessAccountId)
      .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
    Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
      businessAccountFakeInstance
    );
    Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
        businessAccount.Id,
        VERTICAL
      )
      .setField(Account.Id, storeAccountId)
      .setParent('Parent', businessAccountFakeInstance);
    Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
      storeAccountFakeInstance
    );
    Fake accountPaymentAccountRelationFakeInstance = new Fake(
        Account_Payment_Account_Relation__c.class
      )
      .setField(
        Account_Payment_Account_Relation__c.Account_Record_Type__c,
        ACCOUNT_RECORD_TYPE_NAME_STORE
      )
      .setParent('Account__r', storeAccountFakeInstance)
      .setFakeId();
    Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
        businessAccount.Id,
        WORKORDER_TYPE_MARKETPLACE
      )
      .setField(WorkOrder.Id, parentWorkOrderId)
      .setField(
        WorkOrder.Account_Record_Type_Name__c,
        ACCOUNT_RECORD_TYPE_NAME_BUSINESS
      )
      .setParent('Account', businessAccountFakeInstance);
    WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
      parentWorkOrderFakeInstance
    );
    Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
        storeAccount.Id,
        WORKORDER_TYPE_MARKETPLACE,
        parentWorkOrder.Id
      )
      .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
      .setParent('Account', storeAccountFakeInstance)
      .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
    WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
      childWorkOrderFakeInstance
    );
    accountPaymentAccountRelationFakeInstance
      .setField(Account_Payment_Account_Relation__c.Account__c, storeAccount.Id)
      .setField(
        Account_Payment_Account_Relation__c.Payment_Account__c,
        paymentAccountId
      )
      .setField(
        Account_Payment_Account_Relation__c.Record_Type__c,
        PAYMENT_ACCOUNT_RECORD_TYPE_INVOICE
      )
      .setParent(
        'Payment_Account__r',
        new Fake(Payment_Account__c.class)
          .setField(Payment_Account__c.Id, paymentAccountId)
          .setField(
            Payment_Account__c.RecordTypeId,
            PAYMENT_ACCOUNT_INVOICE_RECORD_TYPE_ID
          )
      );
    Account_Payment_Account_Relation__c accountPaymentAccountRelation = (Account_Payment_Account_Relation__c) ServiceMockDataBuilder.convertToSObject(
      accountPaymentAccountRelationFakeInstance
    );

    List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

    fflib_ApexMocks mocks = new fflib_ApexMocks();
    IAccountPaymentAccountRelationsSelector mockSelector = (IAccountPaymentAccountRelationsSelector) mocks.mock(
      IAccountPaymentAccountRelationsSelector.class
    );
    fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
      fflib_ISObjectUnitOfWork.class
    );
    mocks.startStubbing();
    mocks.when(mockSelector.sObjectType())
      .thenReturn(Account_Payment_Account_Relation__c.SObjectType);
    mocks.when(
        mockSelector.selectByAccountIdsAndPaymentAccountRecordTypes(
          new Set<Id>{ businessAccount.Id, storeAccount.Id },
          new Set<String>{
            PAYMENT_ACCOUNT_RECORD_TYPE_INVOICE,
            PAYMENT_ACCOUNT_RECORD_TYPE_PAYMENTS
          }
        )
      )
      .thenReturn(
        new List<Account_Payment_Account_Relation__c>{
          accountPaymentAccountRelation
        }
      );
    mocks.stopStubbing();
    Application.UNITOFWORK.setMock(mockUOW);
    Application.SELECTOR.setMock(mockSelector);
    PaymentAccountValidationsServiceImpl paymentAccountValidationsServiceImplInstance = new PaymentAccountValidationsServiceImpl();
    paymentAccountValidationsServiceImplInstance.validate(
      new List<WorkOrder>{ childWorkOrder },
      new List<WorkOrder>{ parentWorkOrder },
      storeReadinessValidationRules,
      mockExistingReadinessCheckFailures,
      PAYMENT_ACCOUNT_OBJECT_API_NAME
    );
    ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
  }

  /**
   * @description To test when "Billing Contact Name" field is not populated on the Payment Account
   * of Payments record type related to store Account associated with child Work Order with "Storefront"
   * type then Readiness Check Failures are not created.
   */
  @isTest
  private static void testWhenBillingContactNameOnPaymentAccountNotPopulatedOnStorefrontWorkOrderThenReadinessCheckFailuresNotCreated() {
    Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
    Id paymentAccountId = fflib_IDGenerator.generate(
      Payment_Account__c.SObjectType
    );
    Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id storeReadinessValidationRuleId = fflib_IDGenerator.generate(
      Store_Readiness_Validation_Rule__mdt.SObjectType
    );
    Id sobjectTypeSubTypeMappingId = fflib_IDGenerator.generate(
      Sobject_Type_Sub_Type_Mapping__mdt.SObjectType
    );
    Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule = (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
      ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
          CUSTOM_METADATA_ERROR_MESSAGE_BILLING_CONTACT_NAME,
          FIELD_LABEL_BILLING_CONTACT_NAME,
          SERVICE_METHOD_VALIDATE_NULL_FIELD_VALUES_ON_PAYMENTS_RECORD_TYPE,
          PAYMENT_ACCOUNT_OBJECT_NAME,
          SERVICE_CLASS_NAME
        )
        .setField(
          Store_Readiness_Validation_Rule__mdt.Id,
          storeReadinessValidationRuleId
        )
        .setChildren(
          'ReadinessValidationSobjectTypeBindings__r',
          new List<Fake>{
            new Fake(ReadinessValidation_SobjectType_Binding__mdt.class)
              .setField(
                ReadinessValidation_SobjectType_Binding__mdt.Store_Readiness_Validation_Rule__c,
                storeReadinessValidationRuleId
              )
              .setField(
                ReadinessValidation_SobjectType_Binding__mdt.Sobject_Type_Sub_Type_Mapping__c,
                sobjectTypeSubTypeMappingId
              )
              .setParent(
                'Sobject_Type_Sub_Type_Mapping__r',
                new Fake(Sobject_Type_Sub_Type_Mapping__mdt.class)
                  .setField(
                    Sobject_Type_Sub_Type_Mapping__mdt.Type__c,
                    WORKORDER_TYPE_MARKETPLACE
                  )
              ),
            new Fake(ReadinessValidation_SobjectType_Binding__mdt.class)
              .setField(
                ReadinessValidation_SobjectType_Binding__mdt.Store_Readiness_Validation_Rule__c,
                storeReadinessValidationRuleId
              )
              .setField(
                ReadinessValidation_SobjectType_Binding__mdt.Sobject_Type_Sub_Type_Mapping__c,
                sobjectTypeSubTypeMappingId
              )
              .setParent(
                'Sobject_Type_Sub_Type_Mapping__r',
                new Fake(Sobject_Type_Sub_Type_Mapping__mdt.class)
                  .setField(
                    Sobject_Type_Sub_Type_Mapping__mdt.Type__c,
                    WORKORDER_TYPE_COO
                  )
              )
          }
        )
    );
    storeReadinessValidationRule.Field_Name__c = FIELD_NAME_BILLING_CONTACT_NAME;
    Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
        VERTICAL,
        ACCOUNT_RECORD_TYPE_NAME_BUSINESS
      )
      .setField(Account.Id, businessAccountId)
      .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
    Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
      businessAccountFakeInstance
    );
    Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
        businessAccount.Id,
        VERTICAL
      )
      .setField(Account.Id, storeAccountId)
      .setParent('Parent', businessAccountFakeInstance);
    Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
      storeAccountFakeInstance
    );
    Fake accountPaymentAccountRelationFakeInstance = new Fake(
        Account_Payment_Account_Relation__c.class
      )
      .setField(
        Account_Payment_Account_Relation__c.Account_Record_Type__c,
        ACCOUNT_RECORD_TYPE_NAME_STORE
      )
      .setParent('Account__r', storeAccountFakeInstance)
      .setFakeId();
    Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
        businessAccount.Id,
        WORKORDER_TYPE_STOREFRONT
      )
      .setField(WorkOrder.Id, parentWorkOrderId)
      .setField(
        WorkOrder.Account_Record_Type_Name__c,
        ACCOUNT_RECORD_TYPE_NAME_BUSINESS
      )
      .setParent('Account', businessAccountFakeInstance);
    WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
      parentWorkOrderFakeInstance
    );
    Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
        storeAccount.Id,
        WORKORDER_TYPE_STOREFRONT,
        parentWorkOrder.Id
      )
      .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
      .setParent('Account', storeAccountFakeInstance)
      .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
    WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
      childWorkOrderFakeInstance
    );
    accountPaymentAccountRelationFakeInstance
      .setField(Account_Payment_Account_Relation__c.Account__c, storeAccount.Id)
      .setField(
        Account_Payment_Account_Relation__c.Payment_Account__c,
        paymentAccountId
      )
      .setField(
        Account_Payment_Account_Relation__c.Record_Type__c,
        PAYMENT_ACCOUNT_RECORD_TYPE_PAYMENTS
      )
      .setParent(
        'Payment_Account__r',
        new Fake(Payment_Account__c.class)
          .setField(Payment_Account__c.Id, paymentAccountId)
          .setField(Payment_Account__c.Billing_Contact_Name__c, null)
          .setField(
            Payment_Account__c.RecordTypeId,
            PAYMENT_ACCOUNT_PAYMENTS_RECORD_TYPE_ID
          )
      );
    Account_Payment_Account_Relation__c accountPaymentAccountRelation = (Account_Payment_Account_Relation__c) ServiceMockDataBuilder.convertToSObject(
      accountPaymentAccountRelationFakeInstance
    );

    List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

    fflib_ApexMocks mocks = new fflib_ApexMocks();
    IAccountPaymentAccountRelationsSelector mockSelector = (IAccountPaymentAccountRelationsSelector) mocks.mock(
      IAccountPaymentAccountRelationsSelector.class
    );
    fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
      fflib_ISObjectUnitOfWork.class
    );
    mocks.startStubbing();
    mocks.when(mockSelector.sObjectType())
      .thenReturn(Account_Payment_Account_Relation__c.SObjectType);
    mocks.when(
        mockSelector.selectByAccountIdsAndPaymentAccountRecordTypes(
          new Set<Id>{ businessAccount.Id, storeAccount.Id },
          new Set<String>{
            PAYMENT_ACCOUNT_RECORD_TYPE_INVOICE,
            PAYMENT_ACCOUNT_RECORD_TYPE_PAYMENTS
          }
        )
      )
      .thenReturn(
        new List<Account_Payment_Account_Relation__c>{
          accountPaymentAccountRelation
        }
      );
    mocks.stopStubbing();
    Application.UNITOFWORK.setMock(mockUOW);
    Application.SELECTOR.setMock(mockSelector);
    PaymentAccountValidationsServiceImpl paymentAccountValidationsServiceImplInstance = new PaymentAccountValidationsServiceImpl();
    paymentAccountValidationsServiceImplInstance.validate(
      new List<WorkOrder>{ childWorkOrder },
      new List<WorkOrder>{ parentWorkOrder },
      new List<Store_Readiness_Validation_Rule__mdt>{
        storeReadinessValidationRule
      },
      mockExistingReadinessCheckFailures,
      PAYMENT_ACCOUNT_OBJECT_API_NAME
    );
    ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
  }

  /**
   * @description To test Readiness Check Failure is not created when Payment Account
   * exists on the store Account.
   */
  @isTest
  private static void testWhenPaymentsPaymentAccountExistsOnStoreThenReadinessCheckFailuresNotCreated() {
    Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
    Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id paymentAccountId = fflib_IDGenerator.generate(
      Payment_Account__c.SObjectType
    );
    List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
      (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
        ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
          CUSTOM_METADATA_ERROR_MESSAGE_PAYMENT_ACCOUNT_ON_STORE,
          '',
          SERVICE_METHOD_VALIDATE_PAYMENT_ACCOUNT_ON_STORE,
          PAYMENT_ACCOUNT_OBJECT_NAME,
          SERVICE_CLASS_NAME
        )
      )
    };
    Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
        VERTICAL,
        ACCOUNT_RECORD_TYPE_NAME_BUSINESS
      )
      .setField(Account.Id, businessAccountId)
      .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
    Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
      businessAccountFakeInstance
    );
    Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
        businessAccount.Id,
        VERTICAL
      )
      .setField(Account.Id, storeAccountId)
      .setParent('Parent', businessAccountFakeInstance);
    Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
      storeAccountFakeInstance
    );
    Fake accountPaymentAccountRelationFakeInstance = new Fake(
        Account_Payment_Account_Relation__c.class
      )
      .setField(
        Account_Payment_Account_Relation__c.Account_Record_Type__c,
        ACCOUNT_RECORD_TYPE_NAME_STORE
      )
      .setParent('Account__r', storeAccountFakeInstance)
      .setFakeId();
    Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
        businessAccount.Id,
        WORKORDER_TYPE_MARKETPLACE
      )
      .setField(WorkOrder.Id, parentWorkOrderId)
      .setField(
        WorkOrder.Account_Record_Type_Name__c,
        ACCOUNT_RECORD_TYPE_NAME_BUSINESS
      )
      .setParent('Account', businessAccountFakeInstance);
    WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
      parentWorkOrderFakeInstance
    );
    Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
        storeAccount.Id,
        WORKORDER_TYPE_MARKETPLACE,
        parentWorkOrder.Id
      )
      .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
      .setParent('Account', storeAccountFakeInstance)
      .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
    WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
      childWorkOrderFakeInstance
    );
    accountPaymentAccountRelationFakeInstance
      .setField(Account_Payment_Account_Relation__c.Account__c, storeAccount.Id)
      .setField(
        Account_Payment_Account_Relation__c.Payment_Account__c,
        paymentAccountId
      )
      .setField(
        Account_Payment_Account_Relation__c.Record_Type__c,
        PAYMENT_ACCOUNT_RECORD_TYPE_PAYMENTS
      )
      .setParent(
        'Payment_Account__r',
        new Fake(Payment_Account__c.class)
          .setField(Payment_Account__c.Id, paymentAccountId)
          .setField(
            Payment_Account__c.RecordTypeId,
            PAYMENT_ACCOUNT_PAYMENTS_RECORD_TYPE_ID
          )
      );
    Account_Payment_Account_Relation__c accountPaymentAccountRelation = (Account_Payment_Account_Relation__c) ServiceMockDataBuilder.convertToSObject(
      accountPaymentAccountRelationFakeInstance
    );

    List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

    fflib_ApexMocks mocks = new fflib_ApexMocks();
    IAccountPaymentAccountRelationsSelector mockSelector = (IAccountPaymentAccountRelationsSelector) mocks.mock(
      IAccountPaymentAccountRelationsSelector.class
    );
    IReadinessValidationRulesService mockReadinessValidationRulesService = (IReadinessValidationRulesService) mocks.mock(
      IReadinessValidationRulesService.class
    );
    fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
      fflib_ISObjectUnitOfWork.class
    );
    mocks.startStubbing();
    mocks.when(mockSelector.sObjectType())
      .thenReturn(Account_Payment_Account_Relation__c.SObjectType);
    mocks.when(
        mockSelector.selectByAccountIdsAndPaymentAccountRecordTypes(
          new Set<Id>{ businessAccount.Id, storeAccount.Id },
          new Set<String>{
            PAYMENT_ACCOUNT_RECORD_TYPE_INVOICE,
            PAYMENT_ACCOUNT_RECORD_TYPE_PAYMENTS
          }
        )
      )
      .thenReturn(
        new List<Account_Payment_Account_Relation__c>{
          accountPaymentAccountRelation
        }
      );
    mocks.when(
        mockReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
          null,
          storeReadinessValidationRules[0],
          childWorkOrder
        )
      )
      .thenReturn(true);
    mocks.stopStubbing();
    Application.UNITOFWORK.setMock(mockUOW);
    Application.SELECTOR.setMock(mockSelector);
    Application.SERVICE.setMock(
      IReadinessValidationRulesService.class,
      mockReadinessValidationRulesService
    );
    PaymentAccountValidationsServiceImpl paymentAccountValidationsServiceImplInstance = new PaymentAccountValidationsServiceImpl();
    paymentAccountValidationsServiceImplInstance.validate(
      new List<WorkOrder>{ childWorkOrder },
      new List<WorkOrder>{ parentWorkOrder },
      storeReadinessValidationRules,
      mockExistingReadinessCheckFailures,
      PAYMENT_ACCOUNT_OBJECT_API_NAME
    );
    // Readiness check failure not created as Payment Account exists on Store Account.
    ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
  }

  /**
   * @description To test Readiness Check Failure creation when Payment Account does not exist
   * on the store Account.
   */
  @isTest
  private static void testWhenPaymentAccountDoesNotExistOnStoreThenReadinessCheckFailuresCreated() {
    Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
    Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Fake storeReadinessValidationRuleMdtFakeInstance = new Fake(Store_Readiness_Validation_Rule__mdt.class)
      .setField(Store_Readiness_Validation_Rule__mdt.Field_Label__c, '')
      .setField(Store_Readiness_Validation_Rule__mdt.Error_Message__c, CUSTOM_METADATA_ERROR_MESSAGE_PAYMENT_ACCOUNT_ON_STORE)
      .setField(Store_Readiness_Validation_Rule__mdt.Is_Active__c, true)
      .setField(Store_Readiness_Validation_Rule__mdt.Object_Label__c, PAYMENT_ACCOUNT_OBJECT_NAME)
      .setField(Store_Readiness_Validation_Rule__mdt.Service_Class_Name__c, SERVICE_CLASS_NAME)
      .setField(Store_Readiness_Validation_Rule__mdt.Service_Method_Name__c, SERVICE_METHOD_VALIDATE_PAYMENT_ACCOUNT_ON_STORE)
      .setField(Store_Readiness_Validation_Rule__mdt.DeveloperName, DEVELOPER_NAME_PAYMENT_ACCOUNT_REQUIRED_ON_STORE)
      .setFakeId();

    Fake storeReadinessValidationRuleMdtFakeInstance1 = new Fake(Store_Readiness_Validation_Rule__mdt.class)
      .setField(Store_Readiness_Validation_Rule__mdt.Field_Label__c, FIELD_LABEL_BILLING_CONTACT_NAME )
      .setField(Store_Readiness_Validation_Rule__mdt.Error_Message__c, CUSTOM_METADATA_ERROR_MESSAGE_BILLING_CONTACT_NAME )
      .setField(Store_Readiness_Validation_Rule__mdt.Is_Active__c, true)
      .setField(Store_Readiness_Validation_Rule__mdt.Object_Label__c, PAYMENT_ACCOUNT_OBJECT_NAME)
      .setField(Store_Readiness_Validation_Rule__mdt.Service_Class_Name__c, SERVICE_CLASS_NAME)
      .setField(Store_Readiness_Validation_Rule__mdt.Service_Method_Name__c, SERVICE_METHOD_VALIDATE_NULL_FIELD_VALUES_ON_PAYMENTS_RECORD_TYPE )
      .setField(Store_Readiness_Validation_Rule__mdt.DeveloperName, DEVELOPER_NAME_BILLING_CONTRACT_REQ_ON_PAYMENT_ACCOUNT)
      .setFakeId();

    List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
      (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
        storeReadinessValidationRuleMdtFakeInstance
      ),
      (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
        storeReadinessValidationRuleMdtFakeInstance1
      )
    };
    Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
        VERTICAL,
        ACCOUNT_RECORD_TYPE_NAME_BUSINESS
      )
      .setField(Account.Id, fflib_IDGenerator.generate(Account.SObjectType))
      .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
    Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
      businessAccountFakeInstance
    );
    Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
        businessAccount.Id,
        VERTICAL
      )
      .setField(Account.Id, storeAccountId)
      .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
      .setParent('Parent', businessAccountFakeInstance);
    Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
      storeAccountFakeInstance
    );
    Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
        businessAccount.Id,
        WORKORDER_TYPE_MARKETPLACE
      )
      .setField(WorkOrder.Id, parentWorkOrderId)
      .setField(
        WorkOrder.Account_Record_Type_Name__c,
        ACCOUNT_RECORD_TYPE_NAME_BUSINESS
      )
      .setParent('Account', businessAccountFakeInstance);
    WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
      parentWorkOrderFakeInstance
    );
    Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
        storeAccount.Id,
        WORKORDER_TYPE_MARKETPLACE,
        parentWorkOrder.Id
      )
      .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
      .setField(
        WorkOrder.Account_Record_Type_Name__c,
        ACCOUNT_RECORD_TYPE_NAME_STORE
      )
      .setParent('Account', storeAccountFakeInstance)
      .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
    WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
      childWorkOrderFakeInstance
    );
    List<Readiness_Check_Failure__c> mockReadinessValidationRuleFailureRecords = new List<Readiness_Check_Failure__c>{
      new Readiness_Check_Failure__c(
        Object_Name__c = storeReadinessValidationRules[0].Object_Label__c,
        Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
        Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
        Parent_Work_Order__c = parentWorkOrder.Id,
        Account_Name__c = storeAccount.Id,
        Payment_Account_Name__c = null,
        Child_Work_Order__c = childWorkOrder.Id
      )
    };

    Map<Id, List<SBQQ__QuoteLine__c>> accountIdToQuoteLineMap = new Map<Id, List<SBQQ__QuoteLine__c>>();
    List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>{
      new Readiness_Check_Failure__c(
        Object_Name__c = storeReadinessValidationRules[1].Object_Label__c,
        Field_Name__c = storeReadinessValidationRules[1].Field_Label__c,
        Error_Message__c = storeReadinessValidationRules[1].Error_Message__c,
        Parent_Work_Order__c = parentWorkOrder.Id,
        Child_Work_Order__c = childWorkOrder.Id,
        Account_Name__c = childWorkOrder.AccountId
        )
      };

    fflib_ApexMocks mocks = new fflib_ApexMocks();
    IAccountPaymentAccountRelationsSelector mockSelector = (IAccountPaymentAccountRelationsSelector) mocks.mock(
      IAccountPaymentAccountRelationsSelector.class
    );
    IReadinessValidationRulesService mockReadinessValidationRulesService = (IReadinessValidationRulesService) mocks.mock(
      IReadinessValidationRulesService.class
    );
    fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
      fflib_ISObjectUnitOfWork.class
    );
    mocks.startStubbing();
    mocks.when(mockSelector.sObjectType())
      .thenReturn(Account_Payment_Account_Relation__c.SObjectType);
    mocks.when(
        mockSelector.selectByAccountIdsAndPaymentAccountRecordTypes(
          new Set<Id>{ businessAccount.Id, storeAccount.Id },
          new Set<String>{
            PAYMENT_ACCOUNT_RECORD_TYPE_INVOICE,
            PAYMENT_ACCOUNT_RECORD_TYPE_PAYMENTS
          }
        )
      )
      .thenReturn(new List<Account_Payment_Account_Relation__c>{});
    mocks.when(
        mockReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
          null,
          storeReadinessValidationRules[0],
          childWorkOrder
        )
      )
      .thenReturn(true);
    mocks.when(
        mockReadinessValidationRulesService.isAccountShoppingProtocolDasherPickWithAlcoholOrNotShopperPick(
          childWorkOrder,
          accountIdToQuoteLineMap
        )
      )
      .thenReturn(true);
      mocks.when(
        mockReadinessValidationRulesService.isBypassedBySegmentTypeSubType(
          DEVELOPER_NAME_PAYMENT_ACCOUNT_REQUIRED_ON_STORE,
          childWorkOrder
        )
      )
      .thenReturn(false);
      mocks.when(
        mockReadinessValidationRulesService.isBypassedBySegmentTypeSubType(
          DEVELOPER_NAME_BILLING_CONTRACT_REQ_ON_PAYMENT_ACCOUNT,
          childWorkOrder
        )
      )
      .thenReturn(false);
    mocks.stopStubbing();
    Application.UNITOFWORK.setMock(mockUOW);
    Application.SELECTOR.setMock(mockSelector);
    Application.SERVICE.setMock(
      IReadinessValidationRulesService.class,
      mockReadinessValidationRulesService
    );
    PaymentAccountValidationsServiceImpl paymentAccountValidationsServiceImplInstance = new PaymentAccountValidationsServiceImpl();
    paymentAccountValidationsServiceImplInstance.validate(
      new List<WorkOrder>{ childWorkOrder },
      new List<WorkOrder>{ parentWorkOrder },
      storeReadinessValidationRules,
      mockExistingReadinessCheckFailures,
      PAYMENT_ACCOUNT_OBJECT_API_NAME
    );
    ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
      .registerNew(mockReadinessValidationRuleFailureRecords);
    ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
  }

  /**
   * @description To test when the Payment Account exists on business Account associated
   * with parent Work Order of 'Drive' type then Readiness Check Failures are not created.
   */
  @isTest
  private static void testWhenPaymentAccountExistsOnBusinessAccountByDriveWorkOrderTypeThenReadinessCheckFailureNotCreated() {
    Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
    Id paymentAccountId = fflib_IDGenerator.generate(
      Payment_Account__c.SObjectType
    );
    Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id storeReadinessValidationRuleId = fflib_IDGenerator.generate(
      Store_Readiness_Validation_Rule__mdt.SObjectType
    );
    Id sobjectTypeSubTypeMappingId = fflib_IDGenerator.generate(
      Sobject_Type_Sub_Type_Mapping__mdt.SObjectType
    );
    Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule = (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
      ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
          CUSTOM_METADATA_ERROR_MESSAGE_PAYMENT_ACCOUNT_ON_BUSINESS,
          '',
          SERVICE_METHOD_VALIDATE_PAYMENT_ACCOUNT_ON_BUSINESS,
          PAYMENT_ACCOUNT_OBJECT_NAME,
          SERVICE_CLASS_NAME
        )
        .setField(
          Store_Readiness_Validation_Rule__mdt.Id,
          storeReadinessValidationRuleId
        )
        .setChildren(
          'ReadinessValidationSobjectTypeBindings__r',
          new List<Fake>{
            new Fake(ReadinessValidation_SobjectType_Binding__mdt.class)
              .setField(
                ReadinessValidation_SobjectType_Binding__mdt.Store_Readiness_Validation_Rule__c,
                storeReadinessValidationRuleId
              )
              .setField(
                ReadinessValidation_SobjectType_Binding__mdt.Sobject_Type_Sub_Type_Mapping__c,
                sobjectTypeSubTypeMappingId
              )
              .setParent(
                'Sobject_Type_Sub_Type_Mapping__r',
                new Fake(Sobject_Type_Sub_Type_Mapping__mdt.class)
                  .setField(
                    Sobject_Type_Sub_Type_Mapping__mdt.Type__c,
                    WORKORDER_TYPE_DRIVE
                  )
              )
          }
        )
    );
    Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
        VERTICAL,
        ACCOUNT_RECORD_TYPE_NAME_BUSINESS
      )
      .setField(Account.Id, businessAccountId)
      .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
    Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
      businessAccountFakeInstance
    );
    Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
        businessAccount.Id,
        VERTICAL
      )
      .setField(Account.Id, storeAccountId)
      .setParent('Parent', businessAccountFakeInstance);
    Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
      storeAccountFakeInstance
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
    Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
        businessAccount.Id,
        WORKORDER_TYPE_DRIVE
      )
      .setField(WorkOrder.Id, parentWorkOrderId)
      .setField(
        WorkOrder.Account_Record_Type_Name__c,
        ACCOUNT_RECORD_TYPE_NAME_BUSINESS
      )
      .setParent('Account', businessAccountFakeInstance);
    WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
      parentWorkOrderFakeInstance
    );
    Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
        storeAccount.Id,
        WORKORDER_TYPE_DRIVE,
        parentWorkOrder.Id
      )
      .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
      .setParent('Account', storeAccountFakeInstance)
      .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
    WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
      childWorkOrderFakeInstance
    );
    accountPaymentAccountRelationFakeInstance
      .setField(
        Account_Payment_Account_Relation__c.Account__c,
        businessAccount.Id
      )
      .setField(
        Account_Payment_Account_Relation__c.Payment_Account__c,
        paymentAccountId
      )
      .setField(
        Account_Payment_Account_Relation__c.Record_Type__c,
        PAYMENT_ACCOUNT_RECORD_TYPE_INVOICE
      )
      .setParent(
        'Payment_Account__r',
        new Fake(Payment_Account__c.class)
          .setField(Payment_Account__c.Id, paymentAccountId)
      );
    Account_Payment_Account_Relation__c accountPaymentAccountRelation = (Account_Payment_Account_Relation__c) ServiceMockDataBuilder.convertToSObject(
      accountPaymentAccountRelationFakeInstance
    );

    List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

    fflib_ApexMocks mocks = new fflib_ApexMocks();
    IAccountPaymentAccountRelationsSelector mockSelector = (IAccountPaymentAccountRelationsSelector) mocks.mock(
      IAccountPaymentAccountRelationsSelector.class
    );
    fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
      fflib_ISObjectUnitOfWork.class
    );
    mocks.startStubbing();
    mocks.when(mockSelector.sObjectType())
      .thenReturn(Account_Payment_Account_Relation__c.SObjectType);
    mocks.when(
        mockSelector.selectByAccountIdsAndPaymentAccountRecordTypes(
          new Set<Id>{ businessAccount.Id, storeAccount.Id },
          new Set<String>{
            PAYMENT_ACCOUNT_RECORD_TYPE_INVOICE,
            PAYMENT_ACCOUNT_RECORD_TYPE_PAYMENTS
          }
        )
      )
      .thenReturn(
        new List<Account_Payment_Account_Relation__c>{
          accountPaymentAccountRelation
        }
      );
    mocks.stopStubbing();
    Application.UNITOFWORK.setMock(mockUOW);
    Application.SELECTOR.setMock(mockSelector);
    PaymentAccountValidationsServiceImpl paymentAccountValidationsServiceImplInstance = new PaymentAccountValidationsServiceImpl();
    paymentAccountValidationsServiceImplInstance.validate(
      new List<WorkOrder>{ childWorkOrder },
      new List<WorkOrder>{ parentWorkOrder },
      new List<Store_Readiness_Validation_Rule__mdt>{
        storeReadinessValidationRule
      },
      mockExistingReadinessCheckFailures,
      PAYMENT_ACCOUNT_OBJECT_API_NAME
    );
    ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
  }

  /**
   * @description To test when a Payment Account does not exist on business Account associated
   * with parent Work Order of 'Drive' type then Readiness Check Failures are created.
   */
  @isTest
  private static void testWhenPaymentAccountDoesNotExistOnBusinessAccountByDriveWorkOrderTypeThenReadinessCheckFailureCreated() {
    Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
    Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id storeReadinessValidationRuleId = fflib_IDGenerator.generate(
      Store_Readiness_Validation_Rule__mdt.SObjectType
    );
    Id sobjectTypeSubTypeMappingId = fflib_IDGenerator.generate(
      Sobject_Type_Sub_Type_Mapping__mdt.SObjectType
    );
    Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule = (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
      ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
          CUSTOM_METADATA_ERROR_MESSAGE_PAYMENT_ACCOUNT_ON_BUSINESS,
          '',
          SERVICE_METHOD_VALIDATE_PAYMENT_ACCOUNT_ON_BUSINESS,
          PAYMENT_ACCOUNT_OBJECT_NAME,
          SERVICE_CLASS_NAME
        )
        .setField(
          Store_Readiness_Validation_Rule__mdt.Id,
          storeReadinessValidationRuleId
        )
        .setChildren(
          'ReadinessValidationSobjectTypeBindings__r',
          new List<Fake>{
            new Fake(ReadinessValidation_SobjectType_Binding__mdt.class)
              .setField(
                ReadinessValidation_SobjectType_Binding__mdt.Store_Readiness_Validation_Rule__c,
                storeReadinessValidationRuleId
              )
              .setField(
                ReadinessValidation_SobjectType_Binding__mdt.Sobject_Type_Sub_Type_Mapping__c,
                sobjectTypeSubTypeMappingId
              )
              .setParent(
                'Sobject_Type_Sub_Type_Mapping__r',
                new Fake(Sobject_Type_Sub_Type_Mapping__mdt.class)
                  .setField(
                    Sobject_Type_Sub_Type_Mapping__mdt.Type__c,
                    WORKORDER_TYPE_DRIVE
                  )
              )
          }
        )
    );
    Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
        VERTICAL,
        ACCOUNT_RECORD_TYPE_NAME_BUSINESS
      )
      .setField(Account.Id, businessAccountId)
      .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
    Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
      businessAccountFakeInstance
    );
    Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
        businessAccount.Id,
        VERTICAL
      )
      .setField(Account.Id, storeAccountId)
      .setParent('Parent', businessAccountFakeInstance);
    Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
      storeAccountFakeInstance
    );
    Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
        businessAccount.Id,
        WORKORDER_TYPE_DRIVE
      )
      .setField(WorkOrder.Id, parentWorkOrderId)
      .setField(
        WorkOrder.Account_Record_Type_Name__c,
        ACCOUNT_RECORD_TYPE_NAME_BUSINESS
      )
      .setParent('Account', businessAccountFakeInstance);
    WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
      parentWorkOrderFakeInstance
    );
    Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
        storeAccount.Id,
        WORKORDER_TYPE_DRIVE,
        parentWorkOrder.Id
      )
      .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
      .setParent('Account', storeAccountFakeInstance)
      .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
    WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
      childWorkOrderFakeInstance
    );

    List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

    fflib_ApexMocks mocks = new fflib_ApexMocks();
    IAccountPaymentAccountRelationsSelector mockSelector = (IAccountPaymentAccountRelationsSelector) mocks.mock(
      IAccountPaymentAccountRelationsSelector.class
    );
    fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
      fflib_ISObjectUnitOfWork.class
    );
    mocks.startStubbing();
    mocks.when(mockSelector.sObjectType())
      .thenReturn(Account_Payment_Account_Relation__c.SObjectType);
    mocks.when(
        mockSelector.selectByAccountIdsAndPaymentAccountRecordTypes(
          new Set<Id>{ businessAccount.Id, storeAccount.Id },
          new Set<String>{
            PAYMENT_ACCOUNT_RECORD_TYPE_INVOICE,
            PAYMENT_ACCOUNT_RECORD_TYPE_PAYMENTS
          }
        )
      )
      .thenReturn(new List<Account_Payment_Account_Relation__c>{});
    mocks.stopStubbing();
    Application.UNITOFWORK.setMock(mockUOW);
    Application.SELECTOR.setMock(mockSelector);
    PaymentAccountValidationsServiceImpl paymentAccountValidationsServiceImplInstance = new PaymentAccountValidationsServiceImpl();
    paymentAccountValidationsServiceImplInstance.validate(
      new List<WorkOrder>{ childWorkOrder },
      new List<WorkOrder>{ parentWorkOrder },
      new List<Store_Readiness_Validation_Rule__mdt>{
        storeReadinessValidationRule
      },
      mockExistingReadinessCheckFailures,
      PAYMENT_ACCOUNT_OBJECT_API_NAME
    );
    ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
  }

  /**
   * @description To test when "Billing Contact Name" field is not populated on the Payment Accounts
   * of Payments record type related to store Account associated with child Work Order then
   * Readiness Check Failure created with recently updated Payment Account.
   */
  @isTest
  private static void testWhenBillingContactNameBlankOnPaymentAccountsWithPaymentsRecordTypeThenReadinessCheckFailuresCreatedOnRecentlyUpdatedPaymentAccount() {
    Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
    Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id paymentAccountId = fflib_IDGenerator.generate(
      Payment_Account__c.SObjectType
    );
    Id recentlyUpdatedPaymentAccountId = fflib_IDGenerator.generate(
      Payment_Account__c.SObjectType
    );
    List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
      (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
        ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
          CUSTOM_METADATA_ERROR_MESSAGE_BILLING_CONTACT_NAME,
          FIELD_LABEL_BILLING_CONTACT_NAME,
          SERVICE_METHOD_VALIDATE_NULL_FIELD_VALUES_ON_PAYMENTS_RECORD_TYPE,
          PAYMENT_ACCOUNT_OBJECT_NAME,
          SERVICE_CLASS_NAME
        )
      )
    };
    storeReadinessValidationRules[0]
      .Field_Name__c = FIELD_NAME_BILLING_CONTACT_NAME;
    Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
        VERTICAL,
        ACCOUNT_RECORD_TYPE_NAME_BUSINESS
      )
      .setField(Account.Id, businessAccountId)
      .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
    Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
      businessAccountFakeInstance
    );
    Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
        businessAccount.Id,
        VERTICAL
      )
      .setField(Account.Id, storeAccountId)
      .setParent('Parent', businessAccountFakeInstance);
    Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
      storeAccountFakeInstance
    );
    Fake accountPaymentAccountRelationFakeInstance = new Fake(
        Account_Payment_Account_Relation__c.class
      )
      .setField(
        Account_Payment_Account_Relation__c.Account_Record_Type__c,
        ACCOUNT_RECORD_TYPE_NAME_STORE
      )
      .setParent('Account__r', storeAccountFakeInstance)
      .setFakeId();
    Fake recentlyUpdatedAccountPaymentAccountRelationFakeInstance = new Fake(
        Account_Payment_Account_Relation__c.class
      )
      .setField(
        Account_Payment_Account_Relation__c.Account_Record_Type__c,
        ACCOUNT_RECORD_TYPE_NAME_STORE
      )
      .setParent('Account__r', storeAccountFakeInstance)
      .setFakeId();
    Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
        businessAccount.Id,
        WORKORDER_TYPE_MARKETPLACE
      )
      .setField(WorkOrder.Id, parentWorkOrderId)
      .setField(
        WorkOrder.Account_Record_Type_Name__c,
        ACCOUNT_RECORD_TYPE_NAME_BUSINESS
      )
      .setParent('Account', businessAccountFakeInstance);
    WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
      parentWorkOrderFakeInstance
    );
    Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
        storeAccount.Id,
        WORKORDER_TYPE_MARKETPLACE,
        parentWorkOrder.Id
      )
      .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
      .setParent('Account', storeAccountFakeInstance)
      .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
    WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
      childWorkOrderFakeInstance
    );
    accountPaymentAccountRelationFakeInstance
      .setField(Account_Payment_Account_Relation__c.Account__c, storeAccount.Id)
      .setField(
        Account_Payment_Account_Relation__c.Payment_Account__c,
        paymentAccountId
      )
      .setField(
        Account_Payment_Account_Relation__c.Record_Type__c,
        PAYMENT_ACCOUNT_RECORD_TYPE_PAYMENTS
      )
      .setParent(
        'Payment_Account__r',
        new Fake(Payment_Account__c.class)
          .setField(Payment_Account__c.Id, paymentAccountId)
          .setField(
            Payment_Account__c.RecordTypeId,
            PAYMENT_ACCOUNT_PAYMENTS_RECORD_TYPE_ID
          )
      );
    recentlyUpdatedAccountPaymentAccountRelationFakeInstance
      .setField(Account_Payment_Account_Relation__c.Account__c, storeAccount.Id)
      .setField(
        Account_Payment_Account_Relation__c.Payment_Account__c,
        recentlyUpdatedPaymentAccountId
      )
      .setField(
        Account_Payment_Account_Relation__c.Record_Type__c,
        PAYMENT_ACCOUNT_RECORD_TYPE_PAYMENTS
      )
      .setParent(
        'Payment_Account__r',
        new Fake(Payment_Account__c.class)
          .setField(Payment_Account__c.Id, recentlyUpdatedPaymentAccountId)
          .setField(
            Payment_Account__c.RecordTypeId,
            PAYMENT_ACCOUNT_PAYMENTS_RECORD_TYPE_ID
          )
      );
    Account_Payment_Account_Relation__c accountPaymentAccountRelation = (Account_Payment_Account_Relation__c) ServiceMockDataBuilder.convertToSObject(
      accountPaymentAccountRelationFakeInstance
    );
    Account_Payment_Account_Relation__c recentlyUpdatedAccountPaymentAccountRelation = (Account_Payment_Account_Relation__c) ServiceMockDataBuilder.convertToSObject(
      recentlyUpdatedAccountPaymentAccountRelationFakeInstance
    );
    List<Readiness_Check_Failure__c> mockReadinessValidationRuleFailureRecords = new List<Readiness_Check_Failure__c>{
      new Readiness_Check_Failure__c(
        Object_Name__c = storeReadinessValidationRules[0].Object_Label__c,
        Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
        Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
        Parent_Work_Order__c = parentWorkOrder.Id,
        Account_Name__c = storeAccount.Id,
        Payment_Account_Name__c = recentlyUpdatedPaymentAccountId,
        Child_Work_Order__c = childWorkOrder.Id
      )
    };

    List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

    fflib_ApexMocks mocks = new fflib_ApexMocks();
    IAccountPaymentAccountRelationsSelector mockSelector = (IAccountPaymentAccountRelationsSelector) mocks.mock(
      IAccountPaymentAccountRelationsSelector.class
    );
    fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
      fflib_ISObjectUnitOfWork.class
    );
    mocks.startStubbing();
    mocks.when(mockSelector.sObjectType())
      .thenReturn(Account_Payment_Account_Relation__c.SObjectType);
    mocks.when(
        mockSelector.selectByAccountIdsAndPaymentAccountRecordTypes(
          new Set<Id>{ businessAccount.Id, storeAccount.Id },
          new Set<String>{
            PAYMENT_ACCOUNT_RECORD_TYPE_INVOICE,
            PAYMENT_ACCOUNT_RECORD_TYPE_PAYMENTS
          }
        )
      )
      .thenReturn(
        new List<Account_Payment_Account_Relation__c>{
          recentlyUpdatedAccountPaymentAccountRelation,
          accountPaymentAccountRelation
        }
      );
    mocks.stopStubbing();
    Application.UNITOFWORK.setMock(mockUOW);
    Application.SELECTOR.setMock(mockSelector);
    PaymentAccountValidationsServiceImpl paymentAccountValidationsServiceImplInstance = new PaymentAccountValidationsServiceImpl();
    paymentAccountValidationsServiceImplInstance.validate(
      new List<WorkOrder>{ childWorkOrder },
      new List<WorkOrder>{ parentWorkOrder },
      storeReadinessValidationRules,
      mockExistingReadinessCheckFailures,
      PAYMENT_ACCOUNT_OBJECT_API_NAME
    );
    ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
      .registerNew(mockReadinessValidationRuleFailureRecords);
    ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
  }

  /**
   * @description To test Readiness Check Failure is not created when Payment Account
   * does not exist on the store Account having Shopping Protocol value as 'Dasher Pick'.
   */
  @isTest
  private static void testWhenPaymentAccountDoesNotExistOnStoreWithShoppingProtocolAsDasherPickThenReadinessCheckFailuresNotCreated() {
    Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
    Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Fake storeReadinessValidationRuleMdtFakeInstance = new Fake(Store_Readiness_Validation_Rule__mdt.class)
      .setField(Store_Readiness_Validation_Rule__mdt.Field_Label__c, '')
      .setField(Store_Readiness_Validation_Rule__mdt.Error_Message__c, CUSTOM_METADATA_ERROR_MESSAGE_PAYMENT_ACCOUNT_ON_STORE)
      .setField(Store_Readiness_Validation_Rule__mdt.Is_Active__c, true)
      .setField(Store_Readiness_Validation_Rule__mdt.Object_Label__c, PAYMENT_ACCOUNT_OBJECT_NAME)
      .setField(Store_Readiness_Validation_Rule__mdt.Service_Class_Name__c, SERVICE_CLASS_NAME)
      .setField(Store_Readiness_Validation_Rule__mdt.Service_Method_Name__c, SERVICE_METHOD_VALIDATE_PAYMENT_ACCOUNT_ON_STORE)
      .setField(Store_Readiness_Validation_Rule__mdt.DeveloperName, DEVELOPER_NAME_PAYMENT_ACCOUNT_REQUIRED_ON_STORE)
      .setFakeId();
    List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
        (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(storeReadinessValidationRuleMdtFakeInstance)
      };
    Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
        VERTICAL,
        ACCOUNT_RECORD_TYPE_NAME_BUSINESS
      )
      .setField(Account.Id, fflib_IDGenerator.generate(Account.SObjectType))
      .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
    Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
      businessAccountFakeInstance
    );
    Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
        businessAccount.Id,
        VERTICAL
      )
      .setField(Account.Id, storeAccountId)
      .setField(Account.Shopping_Protocol__c, DASHER_PICK_SHOPPING_PROTOCOL)
      .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
      .setParent('Parent', businessAccountFakeInstance);
    Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
      storeAccountFakeInstance
    );
    Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
        businessAccount.Id,
        WORKORDER_TYPE_MARKETPLACE
      )
      .setField(WorkOrder.Id, parentWorkOrderId)
      .setField(
        WorkOrder.Account_Record_Type_Name__c,
        ACCOUNT_RECORD_TYPE_NAME_BUSINESS
      )
      .setParent('Account', businessAccountFakeInstance);
    WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
      parentWorkOrderFakeInstance
    );
    Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
        storeAccount.Id,
        WORKORDER_TYPE_MARKETPLACE,
        parentWorkOrder.Id
      )
      .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
      .setParent('Account', storeAccountFakeInstance)
      .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
    WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
      childWorkOrderFakeInstance
    );

    Map<Id, List<SBQQ__QuoteLine__c>> accountIdToQuoteLineMap = new Map<Id, List<SBQQ__QuoteLine__c>>();

    List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

    fflib_ApexMocks mocks = new fflib_ApexMocks();
    IAccountPaymentAccountRelationsSelector mockSelector = (IAccountPaymentAccountRelationsSelector) mocks.mock(
      IAccountPaymentAccountRelationsSelector.class
    );
    IReadinessValidationRulesService mockReadinessValidationRulesService = (IReadinessValidationRulesService) mocks.mock(
      IReadinessValidationRulesService.class
    );
    fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
      fflib_ISObjectUnitOfWork.class
    );
    mocks.startStubbing();
    mocks.when(mockSelector.sObjectType())
      .thenReturn(Account_Payment_Account_Relation__c.SObjectType);
    mocks.when(
        mockSelector.selectByAccountIdsAndPaymentAccountRecordTypes(
          new Set<Id>{ businessAccount.Id, storeAccount.Id },
          new Set<String>{
            PAYMENT_ACCOUNT_RECORD_TYPE_INVOICE,
            PAYMENT_ACCOUNT_RECORD_TYPE_PAYMENTS
          }
        )
      )
      .thenReturn(new List<Account_Payment_Account_Relation__c>{});
    mocks.when(
        mockReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
          null,
          storeReadinessValidationRules[0],
          childWorkOrder
        )
      )
      .thenReturn(true);
    mocks.when(
        mockReadinessValidationRulesService.isAccountShoppingProtocolDasherPickWithAlcoholOrNotShopperPick(
          childWorkOrder,
          accountIdToQuoteLineMap
        )
      )
      .thenReturn(false);
    mocks.when(
        mockReadinessValidationRulesService.isBypassedBySegmentTypeSubType(
             DEVELOPER_NAME_PAYMENT_ACCOUNT_REQUIRED_ON_STORE,
             childWorkOrder
        )
      )
      .thenReturn(true);
    mocks.stopStubbing();
    Application.UNITOFWORK.setMock(mockUOW);
    Application.SELECTOR.setMock(mockSelector);
    Application.SERVICE.setMock(
      IReadinessValidationRulesService.class,
      mockReadinessValidationRulesService
    );
    PaymentAccountValidationsServiceImpl paymentAccountValidationsServiceImplInstance = new PaymentAccountValidationsServiceImpl();
    paymentAccountValidationsServiceImplInstance.validate(
      new List<WorkOrder>{ childWorkOrder },
      new List<WorkOrder>{ parentWorkOrder },
      storeReadinessValidationRules,
      mockExistingReadinessCheckFailures,
      PAYMENT_ACCOUNT_OBJECT_API_NAME
    );

    ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
  }

  /**
   * @description To test Readiness Check Failure creation when Payment Account does not exist
   * on the store Account when Shopping Protocol is Dasher Pick and Alcohol Delivery Quote Line
   * is present ont the quote.
   */
  @isTest
  private static void testWhenStoreWithDasherPickShoppingProtocolAndAlcoholQuoteLineDoesNotHavePaymentAccountThenReadinessCheckFailuresCreated() {
    Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
    Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
    Id quoteLineId = Fake.generateId(SBQQ__QuoteLine__c.class);

    Fake productFakeInstance = ServiceMockDataBuilder.createProductFakeInstance(
      'Alcohol Delivery'
    );

    Product2 alcoholDeliveryProduct = (Product2) ServiceMockDataBuilder.convertToSObject(
      productFakeInstance
    );

    Fake storeReadinessValidationRuleMdtFakeInstance = new Fake(Store_Readiness_Validation_Rule__mdt.class)
      .setField(Store_Readiness_Validation_Rule__mdt.Field_Label__c, '')
      .setField(Store_Readiness_Validation_Rule__mdt.Error_Message__c, CUSTOM_METADATA_ERROR_MESSAGE_PAYMENT_ACCOUNT_ON_STORE)
      .setField(Store_Readiness_Validation_Rule__mdt.Is_Active__c, true)
      .setField(Store_Readiness_Validation_Rule__mdt.Object_Label__c, PAYMENT_ACCOUNT_OBJECT_NAME)
      .setField(Store_Readiness_Validation_Rule__mdt.Service_Class_Name__c, SERVICE_CLASS_NAME)
      .setField(Store_Readiness_Validation_Rule__mdt.Service_Method_Name__c, SERVICE_METHOD_VALIDATE_PAYMENT_ACCOUNT_ON_STORE)
      .setField(Store_Readiness_Validation_Rule__mdt.DeveloperName, DEVELOPER_NAME_PAYMENT_ACCOUNT_REQUIRED_ON_STORE)
      .setFakeId();
    Fake storeReadinessValidationRuleMdtFakeInstance1 = new Fake(Store_Readiness_Validation_Rule__mdt.class)
      .setField(Store_Readiness_Validation_Rule__mdt.Field_Label__c, FIELD_LABEL_BILLING_CONTACT_NAME )
      .setField(Store_Readiness_Validation_Rule__mdt.Error_Message__c, CUSTOM_METADATA_ERROR_MESSAGE_BILLING_CONTACT_NAME )
      .setField(Store_Readiness_Validation_Rule__mdt.Is_Active__c, true)
      .setField(Store_Readiness_Validation_Rule__mdt.Object_Label__c, PAYMENT_ACCOUNT_OBJECT_NAME)
      .setField(Store_Readiness_Validation_Rule__mdt.Service_Class_Name__c, SERVICE_CLASS_NAME)
      .setField(Store_Readiness_Validation_Rule__mdt.Service_Method_Name__c, SERVICE_METHOD_VALIDATE_NULL_FIELD_VALUES_ON_PAYMENTS_RECORD_TYPE )
      .setField(Store_Readiness_Validation_Rule__mdt.DeveloperName, DEVELOPER_NAME_BILLING_CONTRACT_REQ_ON_PAYMENT_ACCOUNT)
      .setFakeId();
    List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
        (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(storeReadinessValidationRuleMdtFakeInstance),
        (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(storeReadinessValidationRuleMdtFakeInstance1)
      };

    Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
        VERTICAL,
        ACCOUNT_RECORD_TYPE_NAME_BUSINESS
      )
      .setField(Account.Id, businessAccountId)
      .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);

    SBQQ__Quote__c quote = (SBQQ__Quote__c) new Fake(SBQQ__Quote__c.class)
      .setField(SBQQ__Quote__c.Id, quoteId)
      .setField(SBQQ__Quote__c.SBQQ__Account__c, businessAccountId)
      .setField(SBQQ__Quote__c.SBQQ__Primary__c, true)
      .setField(SBQQ__Quote__c.SBQQ__Status__c, CONTRACT_SIGNED)
      .setField(SBQQ__Quote__c.Signed_Contract_link__c, LINK)
      .setField(SBQQ__Quote__c.Contract_Signed_Date__c, System.today() - 5)
      .setChildren(
        'SBQQ__LineItems__r',
        new List<Fake>{
          new Fake(SBQQ__QuoteLine__c.class)
            .setField(SBQQ__QuoteLine__c.Id, quoteLineId)
            .setField(SBQQ__QuoteLine__c.SBQQ__Quote__c, quoteId)
            .setField(
              SBQQ__QuoteLine__c.SBQQ__Product__c,
              alcoholDeliveryProduct.Id
            )
            .setParent(
              'SBQQ__Quote__r',
              new Fake(SBQQ__Quote__c.class)
                .setField(SBQQ__Quote__c.Id, quoteId)
                .setField(SBQQ__Quote__c.SBQQ__Account__c, businessAccountId)
            )
        }
      )
      .toSObject();

    Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
        businessAccountId,
        VERTICAL
      )
      .setField(Account.Id, storeAccountId)
      .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
      .setField(Account.Shopping_Protocol__c, DASHER_PICK_SHOPPING_PROTOCOL)
      .setParent('Parent', businessAccountFakeInstance);
    Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
      storeAccountFakeInstance
    );

    Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
        businessAccountId,
        WORKORDER_TYPE_MARKETPLACE
      )
      .setField(WorkOrder.Id, parentWorkOrderId)
      .setField(
        WorkOrder.Account_Record_Type_Name__c,
        ACCOUNT_RECORD_TYPE_NAME_BUSINESS
      )
      .setParent('Account', businessAccountFakeInstance);
    WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
      parentWorkOrderFakeInstance
    );

    Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
        storeAccountId,
        WORKORDER_TYPE_MARKETPLACE,
        parentWorkOrder.Id
      )
      .setField(WorkOrder.ParentWorkOrderId, parentWorkOrderId)
      .setField(
        WorkOrder.Account_Record_Type_Name__c,
        ACCOUNT_RECORD_TYPE_NAME_STORE
      )
      .setParent('Account', storeAccountFakeInstance)
      .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
    WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
      childWorkOrderFakeInstance
    );

    List<Readiness_Check_Failure__c> mockReadinessValidationRuleFailureRecords = new List<Readiness_Check_Failure__c>{
      new Readiness_Check_Failure__c(
        Object_Name__c = storeReadinessValidationRules[0].Object_Label__c,
        Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
        Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
        Parent_Work_Order__c = parentWorkOrder.Id,
        Account_Name__c = storeAccount.Id,
        Payment_Account_Name__c = null,
        Child_Work_Order__c = childWorkOrder.Id
      )
    };

    Map<Id, List<SBQQ__QuoteLine__c>> accountIdToQuoteLineMap = new Map<Id, List<SBQQ__QuoteLine__c>>{
      businessAccountId => new List<SBQQ__QuoteLine__c>{
        quote.SBQQ__LineItems__r
      }
    };

    List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>{
      new Readiness_Check_Failure__c(
          Object_Name__c = storeReadinessValidationRules[1].Object_Label__c,
          Field_Name__c = storeReadinessValidationRules[1].Field_Label__c,
          Error_Message__c = storeReadinessValidationRules[1].Error_Message__c,
          Parent_Work_Order__c = parentWorkOrder.Id,
          Child_Work_Order__c = childWorkOrder.Id,
          Account_Name__c = childWorkOrder.AccountId
      )
  };

    fflib_ApexMocks mocks = new fflib_ApexMocks();
    IQuoteLineItemsSelector mockQuoteLineSelector = (IQuoteLineItemsSelector) mocks.mock(
      IQuoteLineItemsSelector.class
    );
    IReadinessValidationRulesService mockReadinessValidationRulesService = (IReadinessValidationRulesService) mocks.mock(
      IReadinessValidationRulesService.class
    );
    fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
      fflib_ISObjectUnitOfWork.class
    );
    mocks.startStubbing();

    mocks.when(mockQuoteLineSelector.sObjectType())
      .thenReturn(SBQQ__QuoteLine__c.SObjectType);
    mocks.when(
        mockQuoteLineSelector.selectAlcoholDeliveryQuoteLineItemByAccounts(
          new Set<Id>{ businessAccountId }
        )
      )
      .thenReturn(new List<SBQQ__QuoteLine__c>{ quote.SBQQ__LineItems__r });
    mocks.when(
        mockReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
          null,
          storeReadinessValidationRules[0],
          childWorkOrder
        )
      )
      .thenReturn(true);

    mocks.when(
        mockReadinessValidationRulesService.isAccountShoppingProtocolDasherPickWithAlcoholOrNotShopperPick(
          childWorkOrder,
          accountIdToQuoteLineMap
        )
      )
      .thenReturn(true);
    mocks.when(
        mockReadinessValidationRulesService.isBypassedBySegmentTypeSubType(
          DEVELOPER_NAME_PAYMENT_ACCOUNT_REQUIRED_ON_STORE,
          childWorkOrder
        )
      )
      .thenReturn(false);
    mocks.stopStubbing();
    Application.UNITOFWORK.setMock(mockUOW);
    Application.SELECTOR.setMock(mockQuoteLineSelector);
    Application.SERVICE.setMock(
      IReadinessValidationRulesService.class,
      mockReadinessValidationRulesService
    );

    PaymentAccountValidationsServiceImpl paymentAccountValidationsServiceImplInstance = new PaymentAccountValidationsServiceImpl();
    paymentAccountValidationsServiceImplInstance.validate(
      new List<WorkOrder>{ childWorkOrder },
      new List<WorkOrder>{ parentWorkOrder },
      storeReadinessValidationRules,
      mockExistingReadinessCheckFailures,
      PAYMENT_ACCOUNT_OBJECT_API_NAME
    );
    ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
      .registerNew(mockReadinessValidationRuleFailureRecords);
    ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
  }

  /**
   * @description To test validation of "Institution Number" field on Payment Account and
   * associated with store account of child work orders with 'Marketplace'
   * OR 'COO' type where country is 'Canada' and value is blank.
   */
  @isTest
  private static void testWhenPaymentAccountOnCanadianStoreAccountWithBlankInstitutionNumberThenReadinessCheckFailuresCreated() {
    Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
    Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id paymentAccountId = fflib_IDGenerator.generate(
      Payment_Account__c.SObjectType
    );
    List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
      (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
        ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
          CUSTOM_METADATA_ERROR_MESSAGE_INSTITUTION_NUMBER,
          FIELD_LABEL_INSTITUTION_NUMBER,
          SERVICE_METHOD_VALIDATE_INSTITUTION_NUMBER,
          PAYMENT_ACCOUNT_OBJECT_NAME,
          SERVICE_CLASS_NAME
        )
      )
    };
    storeReadinessValidationRules[0]
      .Field_Name__c = FIELD_NAME_INSTITUTION_NUMBER;
    Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
        VERTICAL,
        ACCOUNT_RECORD_TYPE_NAME_BUSINESS
      )
      .setField(Account.Id, businessAccountId)
      .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
    Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
      businessAccountFakeInstance
    );
    Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
        businessAccount.Id,
        VERTICAL
      )
      .setField(Account.Id, storeAccountId)
      .setField(
        Account.BillingCountryCode,
        INSTITUTION_NUMBER_ELIGIBILITY_CRITERIA.split(SEPARATOR)[0]
      )
      .setParent('Parent', businessAccountFakeInstance);
    Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
      storeAccountFakeInstance
    );
    Fake accountPaymentAccountRelationFakeInstance = new Fake(
        Account_Payment_Account_Relation__c.class
      )
      .setField(
        Account_Payment_Account_Relation__c.Account_Record_Type__c,
        ACCOUNT_RECORD_TYPE_NAME_STORE
      )
      .setParent('Account__r', storeAccountFakeInstance)
      .setFakeId();
    Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
        businessAccount.Id,
        WORKORDER_TYPE_MARKETPLACE
      )
      .setField(WorkOrder.Id, parentWorkOrderId)
      .setField(
        WorkOrder.Account_Record_Type_Name__c,
        ACCOUNT_RECORD_TYPE_NAME_BUSINESS
      )
      .setParent('Account', businessAccountFakeInstance);
    WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
      parentWorkOrderFakeInstance
    );
    Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
        storeAccount.Id,
        WORKORDER_TYPE_MARKETPLACE,
        parentWorkOrder.Id
      )
      .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
      .setParent('Account', storeAccountFakeInstance)
      .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
    WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
      childWorkOrderFakeInstance
    );
    accountPaymentAccountRelationFakeInstance
      .setField(Account_Payment_Account_Relation__c.Account__c, storeAccount.Id)
      .setField(
        Account_Payment_Account_Relation__c.Payment_Account__c,
        paymentAccountId
      )
      .setField(
        Account_Payment_Account_Relation__c.Record_Type__c,
        PAYMENT_ACCOUNT_RECORD_TYPE_PAYMENTS
      )
      .setParent(
        'Payment_Account__r',
        new Fake(Payment_Account__c.class)
          .setField(Payment_Account__c.Id, paymentAccountId)
          .setField(
            Payment_Account__c.RecordTypeId,
            PAYMENT_ACCOUNT_PAYMENTS_RECORD_TYPE_ID
          )
      );
    Account_Payment_Account_Relation__c accountPaymentAccountRelation = (Account_Payment_Account_Relation__c) ServiceMockDataBuilder.convertToSObject(
      accountPaymentAccountRelationFakeInstance
    );
    List<Readiness_Check_Failure__c> mockReadinessValidationRuleFailureRecords = new List<Readiness_Check_Failure__c>{
      new Readiness_Check_Failure__c(
        Object_Name__c = storeReadinessValidationRules[0].Object_Label__c,
        Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
        Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
        Parent_Work_Order__c = parentWorkOrder.Id,
        Account_Name__c = storeAccount.Id,
        Payment_Account_Name__c = paymentAccountId,
        Child_Work_Order__c = childWorkOrder.Id
      )
    };

    List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

    fflib_ApexMocks mocks = new fflib_ApexMocks();
    IAccountPaymentAccountRelationsSelector mockSelector = (IAccountPaymentAccountRelationsSelector) mocks.mock(
      IAccountPaymentAccountRelationsSelector.class
    );
    fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
      fflib_ISObjectUnitOfWork.class
    );
    mocks.startStubbing();
    mocks.when(mockSelector.sObjectType())
      .thenReturn(Account_Payment_Account_Relation__c.SObjectType);
    mocks.when(
        mockSelector.selectByAccountIdsAndPaymentAccountRecordTypes(
          new Set<Id>{ businessAccount.Id, storeAccount.Id },
          new Set<String>{
            PAYMENT_ACCOUNT_RECORD_TYPE_INVOICE,
            PAYMENT_ACCOUNT_RECORD_TYPE_PAYMENTS
          }
        )
      )
      .thenReturn(
        new List<Account_Payment_Account_Relation__c>{
          accountPaymentAccountRelation
        }
      );
    mocks.stopStubbing();
    Application.UNITOFWORK.setMock(mockUOW);
    Application.SELECTOR.setMock(mockSelector);
    PaymentAccountValidationsServiceImpl paymentAccountValidationsServiceImplInstance = new PaymentAccountValidationsServiceImpl();
    paymentAccountValidationsServiceImplInstance.validate(
      new List<WorkOrder>{ childWorkOrder },
      new List<WorkOrder>{ parentWorkOrder },
      storeReadinessValidationRules,
      mockExistingReadinessCheckFailures,
      PAYMENT_ACCOUNT_OBJECT_API_NAME
    );
    ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
      .registerNew(mockReadinessValidationRuleFailureRecords);
    ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
  }

  /**
   * @description To test when "Institution Number" field on Payment Account doesn't have
   * three digits and associated with store account for child work orders of 'Marketplace'
   * OR 'COO' type where country is 'Canada' then readiness check failures created.
   */
  @isTest
  private static void testWhenPaymentAccountOnCanadianStoreAccountWithGreaterThanThreeDigitsInstitutionNumberThenReadinessCheckFailuresCreated() {
    Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
    Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id paymentAccountId = fflib_IDGenerator.generate(
      Payment_Account__c.SObjectType
    );
    List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
      (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
        ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
          CUSTOM_METADATA_ERROR_MESSAGE_INSTITUTION_NUMBER,
          FIELD_LABEL_INSTITUTION_NUMBER,
          SERVICE_METHOD_VALIDATE_INSTITUTION_NUMBER,
          PAYMENT_ACCOUNT_OBJECT_NAME,
          SERVICE_CLASS_NAME
        )
      )
    };
    storeReadinessValidationRules[0]
      .Field_Name__c = FIELD_NAME_INSTITUTION_NUMBER;
    Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
        VERTICAL,
        ACCOUNT_RECORD_TYPE_NAME_BUSINESS
      )
      .setField(Account.Id, businessAccountId)
      .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
    Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
      businessAccountFakeInstance
    );
    Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
        businessAccount.Id,
        VERTICAL
      )
      .setField(Account.Id, storeAccountId)
      .setField(
        Account.BillingCountryCode,
        INSTITUTION_NUMBER_ELIGIBILITY_CRITERIA.split(SEPARATOR)[0]
      )
      .setParent('Parent', businessAccountFakeInstance);
    Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
      storeAccountFakeInstance
    );
    Fake accountPaymentAccountRelationFakeInstance = new Fake(
        Account_Payment_Account_Relation__c.class
      )
      .setField(
        Account_Payment_Account_Relation__c.Account_Record_Type__c,
        ACCOUNT_RECORD_TYPE_NAME_STORE
      )
      .setParent('Account__r', storeAccountFakeInstance)
      .setFakeId();
    Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
        businessAccount.Id,
        WORKORDER_TYPE_MARKETPLACE
      )
      .setField(WorkOrder.Id, parentWorkOrderId)
      .setField(
        WorkOrder.Account_Record_Type_Name__c,
        ACCOUNT_RECORD_TYPE_NAME_BUSINESS
      )
      .setParent('Account', businessAccountFakeInstance);
    WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
      parentWorkOrderFakeInstance
    );
    Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
        storeAccount.Id,
        WORKORDER_TYPE_MARKETPLACE,
        parentWorkOrder.Id
      )
      .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
      .setParent('Account', storeAccountFakeInstance)
      .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
    WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
      childWorkOrderFakeInstance
    );
    accountPaymentAccountRelationFakeInstance
      .setField(Account_Payment_Account_Relation__c.Account__c, storeAccount.Id)
      .setField(
        Account_Payment_Account_Relation__c.Payment_Account__c,
        paymentAccountId
      )
      .setField(
        Account_Payment_Account_Relation__c.Record_Type__c,
        PAYMENT_ACCOUNT_RECORD_TYPE_PAYMENTS
      )
      .setParent(
        'Payment_Account__r',
        new Fake(Payment_Account__c.class)
          .setField(Payment_Account__c.Id, paymentAccountId)
          .setField(
            Payment_Account__c.RecordTypeId,
            PAYMENT_ACCOUNT_PAYMENTS_RECORD_TYPE_ID
          )
          .setField(
            Payment_Account__c.Institution_Number__c,
            INCORRECT_INSTITUTION_NUMBER
          )
      );
    Account_Payment_Account_Relation__c accountPaymentAccountRelation = (Account_Payment_Account_Relation__c) ServiceMockDataBuilder.convertToSObject(
      accountPaymentAccountRelationFakeInstance
    );
    List<Readiness_Check_Failure__c> mockReadinessValidationRuleFailureRecords = new List<Readiness_Check_Failure__c>{
      new Readiness_Check_Failure__c(
        Object_Name__c = storeReadinessValidationRules[0].Object_Label__c,
        Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
        Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
        Parent_Work_Order__c = parentWorkOrder.Id,
        Account_Name__c = storeAccount.Id,
        Payment_Account_Name__c = paymentAccountId,
        Child_Work_Order__c = childWorkOrder.Id
      )
    };

    List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

    fflib_ApexMocks mocks = new fflib_ApexMocks();
    IAccountPaymentAccountRelationsSelector mockSelector = (IAccountPaymentAccountRelationsSelector) mocks.mock(
      IAccountPaymentAccountRelationsSelector.class
    );
    fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
      fflib_ISObjectUnitOfWork.class
    );
    mocks.startStubbing();
    mocks.when(mockSelector.sObjectType())
      .thenReturn(Account_Payment_Account_Relation__c.SObjectType);
    mocks.when(
        mockSelector.selectByAccountIdsAndPaymentAccountRecordTypes(
          new Set<Id>{ businessAccount.Id, storeAccount.Id },
          new Set<String>{
            PAYMENT_ACCOUNT_RECORD_TYPE_INVOICE,
            PAYMENT_ACCOUNT_RECORD_TYPE_PAYMENTS
          }
        )
      )
      .thenReturn(
        new List<Account_Payment_Account_Relation__c>{
          accountPaymentAccountRelation
        }
      );
    mocks.stopStubbing();
    Application.UNITOFWORK.setMock(mockUOW);
    Application.SELECTOR.setMock(mockSelector);
    PaymentAccountValidationsServiceImpl paymentAccountValidationsServiceImplInstance = new PaymentAccountValidationsServiceImpl();
    paymentAccountValidationsServiceImplInstance.validate(
      new List<WorkOrder>{ childWorkOrder },
      new List<WorkOrder>{ parentWorkOrder },
      storeReadinessValidationRules,
      mockExistingReadinessCheckFailures,
      PAYMENT_ACCOUNT_OBJECT_API_NAME
    );
    ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
      .registerNew(mockReadinessValidationRuleFailureRecords);
    ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
  }

  /**
   * @description To test when "Institution Number" field on Payment Account has three
   * digits and associated with store account of child work orders of 'Marketplace' OR 'COO'
   * type where country is 'Canada' then readiness check failures not created.
   */
  @isTest
  private static void testWhenPaymentAccountOnCanadianStoreAccountWithThreeDigitsInstitutionNumberThenReadinessCheckFailuresCreated() {
    Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
    Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id paymentAccountId = fflib_IDGenerator.generate(
      Payment_Account__c.SObjectType
    );
    List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
      (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
        ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
          CUSTOM_METADATA_ERROR_MESSAGE_INSTITUTION_NUMBER,
          FIELD_LABEL_INSTITUTION_NUMBER,
          SERVICE_METHOD_VALIDATE_INSTITUTION_NUMBER,
          PAYMENT_ACCOUNT_OBJECT_NAME,
          SERVICE_CLASS_NAME
        )
      )
    };
    storeReadinessValidationRules[0]
      .Field_Name__c = FIELD_NAME_INSTITUTION_NUMBER;
    Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
        VERTICAL,
        ACCOUNT_RECORD_TYPE_NAME_BUSINESS
      )
      .setField(Account.Id, businessAccountId)
      .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
    Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
      businessAccountFakeInstance
    );
    Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
        businessAccount.Id,
        VERTICAL
      )
      .setField(Account.Id, storeAccountId)
      .setField(
        Account.BillingCountryCode,
        INSTITUTION_NUMBER_ELIGIBILITY_CRITERIA.split(SEPARATOR)[0]
      )
      .setParent('Parent', businessAccountFakeInstance);
    Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
      storeAccountFakeInstance
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
    Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
        businessAccount.Id,
        WORKORDER_TYPE_MARKETPLACE
      )
      .setField(WorkOrder.Id, parentWorkOrderId)
      .setField(
        WorkOrder.Account_Record_Type_Name__c,
        ACCOUNT_RECORD_TYPE_NAME_BUSINESS
      )
      .setParent('Account', businessAccountFakeInstance);
    WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
      parentWorkOrderFakeInstance
    );
    Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
        storeAccount.Id,
        WORKORDER_TYPE_MARKETPLACE,
        parentWorkOrder.Id
      )
      .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
      .setParent('Account', storeAccountFakeInstance)
      .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
    WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
      childWorkOrderFakeInstance
    );
    accountPaymentAccountRelationFakeInstance
      .setField(
        Account_Payment_Account_Relation__c.Account__c,
        businessAccount.Id
      )
      .setField(
        Account_Payment_Account_Relation__c.Payment_Account__c,
        paymentAccountId
      )
      .setField(
        Account_Payment_Account_Relation__c.Record_Type__c,
        PAYMENT_ACCOUNT_RECORD_TYPE_PAYMENTS
      )
      .setParent(
        'Payment_Account__r',
        new Fake(Payment_Account__c.class)
          .setField(Payment_Account__c.Id, paymentAccountId)
          .setField(
            Payment_Account__c.RecordTypeId,
            PAYMENT_ACCOUNT_PAYMENTS_RECORD_TYPE_ID
          )
          .setField(
            Payment_Account__c.Institution_Number__c,
            CORRECT_INSTITUTION_NUMBER
          )
      );
    Account_Payment_Account_Relation__c accountPaymentAccountRelation = (Account_Payment_Account_Relation__c) ServiceMockDataBuilder.convertToSObject(
      accountPaymentAccountRelationFakeInstance
    );

    List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

    fflib_ApexMocks mocks = new fflib_ApexMocks();
    IAccountPaymentAccountRelationsSelector mockSelector = (IAccountPaymentAccountRelationsSelector) mocks.mock(
      IAccountPaymentAccountRelationsSelector.class
    );
    fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
      fflib_ISObjectUnitOfWork.class
    );
    mocks.startStubbing();
    mocks.when(mockSelector.sObjectType())
      .thenReturn(Account_Payment_Account_Relation__c.SObjectType);
    mocks.when(
        mockSelector.selectByAccountIdsAndPaymentAccountRecordTypes(
          new Set<Id>{ businessAccount.Id, storeAccount.Id },
          new Set<String>{
            PAYMENT_ACCOUNT_RECORD_TYPE_INVOICE,
            PAYMENT_ACCOUNT_RECORD_TYPE_PAYMENTS
          }
        )
      )
      .thenReturn(
        new List<Account_Payment_Account_Relation__c>{
          accountPaymentAccountRelation
        }
      );
    mocks.stopStubbing();
    Application.UNITOFWORK.setMock(mockUOW);
    Application.SELECTOR.setMock(mockSelector);
    PaymentAccountValidationsServiceImpl paymentAccountValidationsServiceImplInstance = new PaymentAccountValidationsServiceImpl();
    paymentAccountValidationsServiceImplInstance.validate(
      new List<WorkOrder>{ childWorkOrder },
      new List<WorkOrder>{ parentWorkOrder },
      storeReadinessValidationRules,
      mockExistingReadinessCheckFailures,
      PAYMENT_ACCOUNT_OBJECT_API_NAME
    );
    ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
  }

  /**
   * @description To test validation of "NetSuite ID" field with blank value on the Invoice
   * Payment Account related to store Account associated with Marketplace parent Work Order.
   */
  @isTest
  private static void testWhenPaymentAccountNetSuiteIdBlankOnStoreAccountsOfMarketplaceWorkOrderThenReadinessCheckFailuresCreated() {
    Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
    Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id paymentAccountId = fflib_IDGenerator.generate(
      Payment_Account__c.SObjectType
    );
    List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
      (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
        ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
          CUSTOM_METADATA_ERROR_MESSAGE_NETSUITE_ID,
          FIELD_LABEL_NETSUITE_ID,
          SERVICE_METHOD_VALIDATE_NULL_FIELD_VALUES_ON_INVOICE_RECORD_TYPE,
          PAYMENT_ACCOUNT_OBJECT_NAME,
          SERVICE_CLASS_NAME
        )
      )
    };
    storeReadinessValidationRules[0].Field_Name__c = FIELD_NAME_NETSUITE_ID;
    Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
        VERTICAL,
        ACCOUNT_RECORD_TYPE_NAME_BUSINESS
      )
      .setField(Account.Id, businessAccountId)
      .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
    Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
      businessAccountFakeInstance
    );
    Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
        businessAccount.Id,
        VERTICAL
      )
      .setField(Account.Id, storeAccountId)
      .setParent('Parent', businessAccountFakeInstance);
    Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
      storeAccountFakeInstance
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
    Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
        businessAccount.Id,
        WORKORDER_TYPE_MARKETPLACE
      )
      .setField(WorkOrder.Id, parentWorkOrderId)
      .setField(
        WorkOrder.Account_Record_Type_Name__c,
        ACCOUNT_RECORD_TYPE_NAME_BUSINESS
      )
      .setField(WorkOrder.Segment__c, SEGMENT_SMB)
      .setParent('Account', businessAccountFakeInstance);
    WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
      parentWorkOrderFakeInstance
    );
    Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
        storeAccount.Id,
        WORKORDER_TYPE_MARKETPLACE,
        parentWorkOrder.Id
      )
      .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
      .setParent('Account', storeAccountFakeInstance)
      .setField(WorkOrder.Segment__c, SEGMENT_SMB)
      .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
    WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
      childWorkOrderFakeInstance
    );
    accountPaymentAccountRelationFakeInstance
      .setField(Account_Payment_Account_Relation__c.Account__c, storeAccount.Id)
      .setField(
        Account_Payment_Account_Relation__c.Payment_Account__c,
        paymentAccountId
      )
      .setField(
        Account_Payment_Account_Relation__c.Record_Type__c,
        PAYMENT_ACCOUNT_RECORD_TYPE_INVOICE
      )
      .setParent(
        'Payment_Account__r',
        new Fake(Payment_Account__c.class)
          .setField(Payment_Account__c.Id, paymentAccountId)
          .setField(
            Payment_Account__c.RecordTypeId,
            PAYMENT_ACCOUNT_INVOICE_RECORD_TYPE_ID
          )
      );
    Account_Payment_Account_Relation__c accountPaymentAccountRelation = (Account_Payment_Account_Relation__c) ServiceMockDataBuilder.convertToSObject(
      accountPaymentAccountRelationFakeInstance
    );
    List<Readiness_Check_Failure__c> mockReadinessValidationRuleFailureRecords = new List<Readiness_Check_Failure__c>{
      new Readiness_Check_Failure__c(
        Object_Name__c = storeReadinessValidationRules[0].Object_Label__c,
        Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
        Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
        Parent_Work_Order__c = parentWorkOrder.Id,
        Account_Name__c = parentWorkOrder.AccountId,
        Payment_Account_Name__c = paymentAccountId,
        Child_Work_Order__c = parentWorkOrder.Id
      )
    };

    List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

    fflib_ApexMocks mocks = new fflib_ApexMocks();
    IAccountPaymentAccountRelationsSelector mockSelector = (IAccountPaymentAccountRelationsSelector) mocks.mock(
      IAccountPaymentAccountRelationsSelector.class
    );
    fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
      fflib_ISObjectUnitOfWork.class
    );
    mocks.startStubbing();
    mocks.when(mockSelector.sObjectType())
      .thenReturn(Account_Payment_Account_Relation__c.SObjectType);
    mocks.when(
        mockSelector.selectByAccountIdsAndPaymentAccountRecordTypes(
          new Set<Id>{ businessAccount.Id, storeAccount.Id },
          new Set<String>{
            PAYMENT_ACCOUNT_RECORD_TYPE_INVOICE,
            PAYMENT_ACCOUNT_RECORD_TYPE_PAYMENTS
          }
        )
      )
      .thenReturn(
        new List<Account_Payment_Account_Relation__c>{
          accountPaymentAccountRelation
        }
      );
    mocks.stopStubbing();
    Application.UNITOFWORK.setMock(mockUOW);
    Application.SELECTOR.setMock(mockSelector);
    PaymentAccountValidationsServiceImpl paymentAccountValidationsServiceImplInstance = new PaymentAccountValidationsServiceImpl();
    paymentAccountValidationsServiceImplInstance.validate(
      new List<WorkOrder>{ childWorkOrder },
      new List<WorkOrder>{ parentWorkOrder },
      storeReadinessValidationRules,
      mockExistingReadinessCheckFailures,
      PAYMENT_ACCOUNT_OBJECT_API_NAME
    );
    ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
      .registerNew(mockReadinessValidationRuleFailureRecords);
    ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
  }

  /**
   * @description To test when "NetSuite ID" field is populated on the Invoice Payment Account
   * related to store Accounts associated to Marketplace parent Work Order then
   * Readiness Check Failures are not created.
   */
  @isTest
  private static void testWhenPaymentAccountNetSuiteIdPopulatedOnStoreAccountsOfMarketplaceWorkOrderThenReadinessCheckFailuresNotCreated() {
    Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
    Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id paymentAccountId = fflib_IDGenerator.generate(
      Payment_Account__c.SObjectType
    );
    List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
      (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
        ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
          CUSTOM_METADATA_ERROR_MESSAGE_NETSUITE_ID,
          FIELD_LABEL_NETSUITE_ID,
          SERVICE_METHOD_VALIDATE_NULL_FIELD_VALUES_ON_INVOICE_RECORD_TYPE,
          PAYMENT_ACCOUNT_OBJECT_API_NAME,
          SERVICE_CLASS_NAME
        )
      )
    };
    storeReadinessValidationRules[0].Field_Name__c = FIELD_NAME_NETSUITE_ID;
    Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
        VERTICAL,
        ACCOUNT_RECORD_TYPE_NAME_BUSINESS
      )
      .setField(Account.Id, businessAccountId)
      .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
    Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
      businessAccountFakeInstance
    );
    Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
        businessAccount.Id,
        VERTICAL
      )
      .setField(Account.Id, storeAccountId)
      .setParent('Parent', businessAccountFakeInstance);
    Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
      storeAccountFakeInstance
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
    Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
        businessAccount.Id,
        WORKORDER_TYPE_MARKETPLACE
      )
      .setField(WorkOrder.Id, parentWorkOrderId)
      .setField(
        WorkOrder.Account_Record_Type_Name__c,
        ACCOUNT_RECORD_TYPE_NAME_BUSINESS
      )
      .setField(WorkOrder.Segment__c, SEGMENT_SMB)
      .setParent('Account', businessAccountFakeInstance);
    WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
      parentWorkOrderFakeInstance
    );
    Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
        storeAccount.Id,
        WORKORDER_TYPE_MARKETPLACE,
        parentWorkOrder.Id
      )
      .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
      .setParent('Account', storeAccountFakeInstance)
      .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
    WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
      childWorkOrderFakeInstance
    );
    accountPaymentAccountRelationFakeInstance
      .setField(Account_Payment_Account_Relation__c.Account__c, storeAccount.Id)
      .setField(
        Account_Payment_Account_Relation__c.Payment_Account__c,
        paymentAccountId
      )
      .setField(
        Account_Payment_Account_Relation__c.Record_Type__c,
        PAYMENT_ACCOUNT_RECORD_TYPE_INVOICE
      )
      .setParent(
        'Payment_Account__r',
        new Fake(Payment_Account__c.class)
          .setField(Payment_Account__c.Id, paymentAccountId)
          .setField(Payment_Account__c.NetSuite_ID__c, NETSUITE_ID)
          .setField(
            Payment_Account__c.RecordTypeId,
            PAYMENT_ACCOUNT_INVOICE_RECORD_TYPE_ID
          )
      );
    Account_Payment_Account_Relation__c accountPaymentAccountRelation = (Account_Payment_Account_Relation__c) ServiceMockDataBuilder.convertToSObject(
      accountPaymentAccountRelationFakeInstance
    );
    List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

    fflib_ApexMocks mocks = new fflib_ApexMocks();
    IAccountPaymentAccountRelationsSelector mockSelector = (IAccountPaymentAccountRelationsSelector) mocks.mock(
      IAccountPaymentAccountRelationsSelector.class
    );
    fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
      fflib_ISObjectUnitOfWork.class
    );
    mocks.startStubbing();
    mocks.when(mockSelector.sObjectType())
      .thenReturn(Account_Payment_Account_Relation__c.SObjectType);
    mocks.when(
        mockSelector.selectByAccountIdsAndPaymentAccountRecordTypes(
          new Set<Id>{ businessAccount.Id, storeAccount.Id },
          new Set<String>{
            PAYMENT_ACCOUNT_RECORD_TYPE_INVOICE,
            PAYMENT_ACCOUNT_RECORD_TYPE_PAYMENTS
          }
        )
      )
      .thenReturn(
        new List<Account_Payment_Account_Relation__c>{
          accountPaymentAccountRelation
        }
      );
    mocks.stopStubbing();
    Application.UNITOFWORK.setMock(mockUOW);
    Application.SELECTOR.setMock(mockSelector);
    PaymentAccountValidationsServiceImpl paymentAccountValidationsServiceImplInstance = new PaymentAccountValidationsServiceImpl();
    paymentAccountValidationsServiceImplInstance.validate(
      new List<WorkOrder>{ childWorkOrder },
      new List<WorkOrder>{ parentWorkOrder },
      storeReadinessValidationRules,
      mockExistingReadinessCheckFailures,
      PAYMENT_ACCOUNT_OBJECT_API_NAME
    );
    ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
  }
  /**
   * @description To test when multiple WorkOrders are tagged to Store Account
   */
  @isTest
  private static void testWhenMultipleWorkOrdersTaggedToAccountScenario() {
    Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id marketPlaceParentWorkOrderId = fflib_IDGenerator.generate(
      WorkOrder.SObjectType
    );
    Id storeFrontParentWorkOrderId = fflib_IDGenerator.generate(
      WorkOrder.SObjectType
    );
    Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id paymentAccountId = fflib_IDGenerator.generate(
      Payment_Account__c.SObjectType
    );
    List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
      (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
        ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
          CUSTOM_METADATA_ERROR_MESSAGE_NETSUITE_ID,
          FIELD_LABEL_NETSUITE_ID,
          SERVICE_METHOD_VALIDATE_NULL_FIELD_VALUES_ON_INVOICE_RECORD_TYPE,
          PAYMENT_ACCOUNT_OBJECT_API_NAME,
          SERVICE_CLASS_NAME
        )
      )
    };
    storeReadinessValidationRules[0].Field_Name__c = FIELD_NAME_NETSUITE_ID;
    Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
        VERTICAL,
        ACCOUNT_RECORD_TYPE_NAME_BUSINESS
      )
      .setField(Account.Id, businessAccountId)
      .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
    Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
      businessAccountFakeInstance
    );
    Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
        businessAccount.Id,
        VERTICAL
      )
      .setField(Account.Id, storeAccountId)
      .setParent('Parent', businessAccountFakeInstance);
    Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
      storeAccountFakeInstance
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
    Fake marketPlaceParentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
        businessAccount.Id,
        WORKORDER_TYPE_MARKETPLACE
      )
      .setField(WorkOrder.Id, marketPlaceParentWorkOrderId)
      .setField(
        WorkOrder.Account_Record_Type_Name__c,
        ACCOUNT_RECORD_TYPE_NAME_BUSINESS
      )
      .setParent('Account', businessAccountFakeInstance);
    WorkOrder marketPlaceParentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
      marketPlaceParentWorkOrderFakeInstance
    );
    Fake marketPlaceChildWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
        storeAccount.Id,
        WORKORDER_TYPE_MARKETPLACE,
        marketPlaceParentWorkOrder.Id
      )
      .setField(WorkOrder.ParentWorkOrderId, marketPlaceParentWorkOrder.Id)
      .setParent('Account', storeAccountFakeInstance)
      .setParent('ParentWorkOrder', marketPlaceParentWorkOrderFakeInstance);
    WorkOrder marketPlaceChildWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
      marketPlaceChildWorkOrderFakeInstance
    );
    Fake storeFrontParentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
        businessAccount.Id,
        WORKORDER_TYPE_STOREFRONT
      )
      .setField(WorkOrder.Id, storeFrontParentWorkOrderId)
      .setField(
        WorkOrder.Account_Record_Type_Name__c,
        ACCOUNT_RECORD_TYPE_NAME_BUSINESS
      )
      .setParent('Account', businessAccountFakeInstance);
    WorkOrder storeFrontParentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
      storeFrontParentWorkOrderFakeInstance
    );
    Fake storeFrontChildWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
        storeAccount.Id,
        WORKORDER_TYPE_STOREFRONT,
        storeFrontParentWorkOrder.Id
      )
      .setField(WorkOrder.ParentWorkOrderId, storeFrontParentWorkOrder.Id)
      .setParent('Account', storeAccountFakeInstance)
      .setParent('ParentWorkOrder', storeFrontParentWorkOrderFakeInstance);
    WorkOrder storeFrontChildWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
      storeFrontChildWorkOrderFakeInstance
    );

    accountPaymentAccountRelationFakeInstance
      .setField(
        Account_Payment_Account_Relation__c.Account__c,
        businessAccount.Id
      )
      .setField(
        Account_Payment_Account_Relation__c.Payment_Account__c,
        paymentAccountId
      )
      .setField(
        Account_Payment_Account_Relation__c.Record_Type__c,
        PAYMENT_ACCOUNT_RECORD_TYPE_INVOICE
      )
      .setParent(
        'Payment_Account__r',
        new Fake(Payment_Account__c.class)
          .setField(Payment_Account__c.Id, paymentAccountId)
          .setField(Payment_Account__c.NetSuite_ID__c, NETSUITE_ID)
          .setField(
            Payment_Account__c.RecordTypeId,
            PAYMENT_ACCOUNT_INVOICE_RECORD_TYPE_ID
          )
      );
    Account_Payment_Account_Relation__c accountPaymentAccountRelation = (Account_Payment_Account_Relation__c) ServiceMockDataBuilder.convertToSObject(
      accountPaymentAccountRelationFakeInstance
    );
    List<Readiness_Check_Failure__c> mockExistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

    fflib_ApexMocks mocks = new fflib_ApexMocks();
    IAccountPaymentAccountRelationsSelector mockSelector = (IAccountPaymentAccountRelationsSelector) mocks.mock(
      IAccountPaymentAccountRelationsSelector.class
    );
    fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
      fflib_ISObjectUnitOfWork.class
    );
    mocks.startStubbing();
    mocks.when(mockSelector.sObjectType())
      .thenReturn(Account_Payment_Account_Relation__c.SObjectType);
    mocks.when(
        mockSelector.selectByAccountIdsAndPaymentAccountRecordTypes(
          new Set<Id>{ businessAccount.Id, storeAccount.Id },
          new Set<String>{
            PAYMENT_ACCOUNT_RECORD_TYPE_INVOICE,
            PAYMENT_ACCOUNT_RECORD_TYPE_PAYMENTS
          }
        )
      )
      .thenReturn(
        new List<Account_Payment_Account_Relation__c>{
          accountPaymentAccountRelation
        }
      );
    mocks.stopStubbing();
    Application.UNITOFWORK.setMock(mockUOW);
    Application.SELECTOR.setMock(mockSelector);
    PaymentAccountValidationsServiceImpl paymentAccountValidationsServiceImplInstance = new PaymentAccountValidationsServiceImpl();
    Test.StartTest();
    paymentAccountValidationsServiceImplInstance.validate(
      new List<WorkOrder>{
        marketPlaceChildWorkOrder,
        storeFrontChildWorkOrder
      },
      new List<WorkOrder>{
        marketPlaceParentWorkOrder,
        storeFrontParentWorkOrder
      },
      storeReadinessValidationRules,
      mockExistingReadinessCheckFailures,
      PAYMENT_ACCOUNT_OBJECT_API_NAME
    );
    Test.StopTest();
    ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
  }
}