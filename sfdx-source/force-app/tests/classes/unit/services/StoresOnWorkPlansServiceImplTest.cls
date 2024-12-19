/**
 * @author Deloitte
 * @date 05/05/2022
 * @description Test class for StoresOnWorkPlansServiceImpl class.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.MethodNamingConventions')
private class StoresOnWorkPlansServiceImplTest {
  private static final String ACCOUNT_BILLING_STREET = '221B Baker Street';
  private static final String ACCOUNT_NAME = 'Test KFC Account';
  private static final String ACCOUNT_OBJECT_NAME = 'Account';
  private static final String ACCOUNT_PARTNERSHIP_STATUS = 'Prospective Partner';
  private static final String ACCOUNT_PAYMENT_ACCOUNT_RELATION_RELATIONSHIP_NAME = 'Account_Payment_Account_Relations__r';
  private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
  private static final String ACCOUNT_TYPE_FRANCHISEE = 'Franchisee';
  private static final String ACCOUNT_BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
    .get(ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
    .getRecordTypeId();
  private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
  private static final String ACCOUNT_STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
    .get(ACCOUNT_RECORD_TYPE_NAME_STORE)
    .getRecordTypeId();
  private static final String ACTIVATE_CENTRALLY = 'Yes';
  private static final String AGREEMENT_TYPE_FRANCHISE = 'Franchise Agreement';
  private static final String ASSERT_MESSAGE = 'Unexpected result: WorkSteps list is null.';
  private static final String ASSERT_MESSAGE_CONTACT_ID_DO_NOT_MATCH = 'Unexpected result: Incorrect Contact Id returned in section wrapper.';
  private static final String ASSERT_MESSAGE_CONTRACT_DETAILS_SECTION_IS_NOT_DISPLAYED = 'Unexpected result: Contract Details section is not displayed.';
  private static final String ASSERT_MESSAGE_ID_DO_NOT_MATCH = 'Unexpected result: query on WorkPlan with WorkOrder returned incorrect Id.';
  private static final String ASSERT_MESSAGE_INCORRECT_NUMBER_OF_SECTION_WRAPPER = 'Unexpected result: Incorrect number of section wrappers are returned.';
  private static final String ASSERT_MESSAGE_INCORRECT_SECTION_NAME_RETURNED = 'Unexpected result: Incorrect section name is returned.';
  private static final String ASSERT_MESSAGE_WORK_PLAN_NAME = 'Unexpected result: WorkPlan Name is not matching';
  private static final String BANKING_INFORMATION_SECTION_NAME = 'Banking Details';
  private static final String BUSINESS_ACCOUNT_DETAILS_SECTION_NAME = 'Business Account Details';
  private static final String BUSINESS_ACCOUNT_NAME = 'Test McDonald Account';
  private static final String CONTACT_DETAILS_SECTION_NAME = 'Contact Details';
  private static final String CONTACT_OBJECT_NAME = 'Contact';
  private static final String CONTRACT_OBJECT_NAME = 'Contract';
  private static final String CONTRACT_DETAILS_SECTION_NAME = 'Contract Details';
  private static final String MENU_COMPLETED_BY = 'Account Owner';
  private static final String ORDER_PROTOCOL = 'Email';
  private static final String ORDER_ITEM_OBJECT_NAME = 'OrderItem';
  private static final String PAYMENT_ACCOUNT_FIELDSET_NAME = 'Banking_Information';
  private static final String PAYMENT_ACCOUNT_OBJECT_NAME = 'Payment_Account__c';
  private static final String PAYMENT_ACCOUNT_RECORD_TYPE_PAYMENTS = 'Payments';
  private static final String PAYMENT_ACCOUNT_RELATIONSHIP_NAME = 'Payment_Account__r';
  private static final String PHOTOSHOOT_ROLE = 'Photoshoot Contact';
  private static final string ROLE = 'Decision Maker';
  private static final String STATUS_CONFIRMED = 'Confirmed';
  private static final String STORE_ACCOUNT_NAME = 'Test Account';
  private static final String TABLET_DETAILS_FIELDSET_NAME = 'Tablet_Details';
  private static final String TABLET_DETAILS_SECTION_NAME = 'Tablet Details';
  private static final String TYPE_ADS_AND_PROMOS = 'Ads & Promos';
  private static final String TYPE_DRIVE = 'Drive';
  private static final String TYPE_MARKETPLACE = 'Marketplace';
  private static final String TYPE_PHOTOSHOOT = 'Photoshoot';
  private static final String VENDOR_PHOTOSHOOT = 'Vendor Photoshoot';
  private static final String VERTICAL = 'Floral';
  private static final String WORK_PLAN_NAME = 'Onboarding';
  private static final String WORK_PLAN_NAME_ADS = 'Ads';
  private static final String WORK_PLAN_NAME_MENU_UPDATES = 'Menu Updates';
  private static final String WORK_PLAN_NAME_SETUP_BANKING = 'Setup Banking';
  private static final String WORK_PLAN_NAME_TABLET = 'Tablet';
  private static final String WORK_PLAN_STATUS_NOT_STARTED = 'Not Started';
  private static final String WORK_STEP_NAME_DELIVER_TABLET = 'Deliver Tablet';
  private static final String WORK_STEP_OBJECT_NAME = 'WorkStep';
  private static final String XREF_BUSINESS_ID_VALUE = 'BusinessIdTest';
  private static final String XREF_DETAILS_SECTION_NAME = 'Xref Details (scroll to store section if unavailable)';
  private static final String ORDER_ITEM_SECTION_NAME = 'Ads and Promo Details';
  private static final String ORDER_ITEM_ERROR_MESSAGE = 'Error - Section not found!';
  private static final String XREF_EXTERNAL_ID_SOURCE_DRIVEDB = 'DriveDb';
  private static final String XREF_OBJECT_NAME = 'Xref__c';
  private static final String STATUS_DEAD = 'Dead';
  private static final String WORK_ORDER_TYPE_PHOTOSHOOT = 'Photoshoot';

  /**
   * @description To test Work Order's related Store Account from parent WorkPlan Id.
   */
  @isTest
  private static void testWhenFetchStoresByWorkPlanThenReturnRelatedUniqueStores() {
    Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id childWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
    Id childWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
    Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
    Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
    Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
    WorkPlan parentWorkPlan = (WorkPlan) new Fake(WorkPlan.class)
      .setField(WorkPlan.Id, workPlanId)
      .setField(WorkPlan.Status__c, WORK_PLAN_STATUS_NOT_STARTED)
      .setField(WorkPlan.Name, WORK_PLAN_NAME)
      .setField(WorkPlan.ParentRecordId, parentWorkOrderId)
      .setField(WorkPlan.WorkOrderId, parentWorkOrderId)
      .toSObject();
    WorkPlan childWorkPlan = (WorkPlan) new Fake(WorkPlan.class)
      .setField(WorkPlan.Id, childWorkPlanId)
      .setField(WorkPlan.Status__c, WORK_PLAN_STATUS_NOT_STARTED)
      .setField(WorkPlan.Name, WORK_PLAN_NAME)
      .setField(WorkPlan.ParentRecordId, childWorkOrderId)
      .setField(WorkPlan.WorkOrderId, childWorkOrderId)
      .setField(WorkPlan.Parent_Work_Plan__c, workPlanId)
      .setParent(
        'WorkOrder',
        new Fake(WorkOrder.class)
          .setField(WorkOrder.Status, STATUS_CONFIRMED)
          .setField(WorkOrder.Type__c, TYPE_DRIVE)
          .setField(WorkOrder.AccountId, storeAccountId)
          .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
          .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
          .setField(WorkOrder.Menu_to_be_Completed_By__c, MENU_COMPLETED_BY)
          .setField(WorkOrder.Vertical__c, VERTICAL)
          .setField(WorkOrder.Id, childWorkOrderId)
          .setField(WorkOrder.Contract__c, null)
          .setParent(
            'Account',
            new Fake(Account.class)
              .setField(Account.Id, storeAccountId)
              .setField(Account.Name, STORE_ACCOUNT_NAME)
              .setField(Account.RecordTypeId, ACCOUNT_STORE_RECORD_TYPE_ID)
              .setField(Account.BillingStreet, ACCOUNT_BILLING_STREET)
              .setField(
                Account.Partnership_Status__c,
                ACCOUNT_PARTNERSHIP_STATUS
              )
              .setField(Account.ParentId, businessAccountId)
          )
      )
      .toSObject();
    fflib_ApexMocks mocks = new fflib_ApexMocks();
    IWorkPlansSelector workPlansSelector = (IWorkPlansSelector) mocks.mock(
      IWorkPlansSelector.class
    );
    fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
      fflib_ISObjectUnitOfWork.class
    );
    mocks.startStubbing();
    mocks.when(workPlansSelector.sObjectType())
      .thenReturn(WorkPlan.SObjectType);
    mocks.when(workPlansSelector.selectById(new Set<Id>{ workPlanId }))
      .thenReturn(new List<WorkPlan>{ parentWorkPlan });
    mocks.when(
        workPlansSelector.selectByIdAndStoreAccountRecordType(workPlanId)
      )
      .thenReturn(new List<WorkPlan>{ childWorkPlan });
    mocks.stopStubbing();
    Application.UNITOFWORK.setMock(mockUOW);
    Application.SELECTOR.setMock(workPlansSelector);
    Test.startTest();
    StoresOnWorkPlansService.fetchStoresByWorkPlan(workPlanId);
    Test.stopTest();
    System.assertEquals(
      WORK_PLAN_NAME,
      childWorkPlan.Name,
      ASSERT_MESSAGE_WORK_PLAN_NAME
    );
  }

  /**
   * @description To test Work Order's related store Account from child Work Plan Id.
   */
  @isTest
  private static void testWhenFetchStoresFromChildWorkPlanThenReturnRelatedUniqueStore() {
    Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id childWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
    Id childWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
    Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
    WorkPlan childWorkPlan = (WorkPlan) new Fake(WorkPlan.class)
      .setField(WorkPlan.Id, childWorkPlanId)
      .setField(WorkPlan.Status__c, WORK_PLAN_STATUS_NOT_STARTED)
      .setField(WorkPlan.Name, WORK_PLAN_NAME)
      .setField(WorkPlan.ParentRecordId, childWorkOrderId)
      .setField(WorkPlan.WorkOrderId, childWorkOrderId)
      .setParent(
        'WorkOrder',
        new Fake(WorkOrder.class)
          .setField(WorkOrder.Status, STATUS_CONFIRMED)
          .setField(WorkOrder.Type__c, TYPE_DRIVE)
          .setField(WorkOrder.AccountId, storeAccountId)
          .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
          .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
          .setField(WorkOrder.Menu_to_be_Completed_By__c, MENU_COMPLETED_BY)
          .setField(WorkOrder.Vertical__c, VERTICAL)
          .setField(WorkOrder.Id, childWorkOrderId)
          .setField(WorkOrder.Contract__c, null)
          .setParent(
            'Account',
            new Fake(Account.class)
              .setField(Account.Id, storeAccountId)
              .setField(Account.Name, STORE_ACCOUNT_NAME)
              .setField(Account.RecordTypeId, ACCOUNT_STORE_RECORD_TYPE_ID)
              .setField(Account.BillingStreet, ACCOUNT_BILLING_STREET)
              .setField(
                Account.Partnership_Status__c,
                ACCOUNT_PARTNERSHIP_STATUS
              )
              .setField(Account.ParentId, businessAccountId)
          )
      )
      .toSObject();
    fflib_ApexMocks mocks = new fflib_ApexMocks();
    IWorkPlansSelector workPlansSelector = (IWorkPlansSelector) mocks.mock(
      IWorkPlansSelector.class
    );
    fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
      fflib_ISObjectUnitOfWork.class
    );
    mocks.startStubbing();
    mocks.when(workPlansSelector.sObjectType())
      .thenReturn(WorkPlan.SObjectType);
    mocks.when(workPlansSelector.selectById(new Set<Id>{ childWorkPlanId }))
      .thenReturn(new List<WorkPlan>{ childWorkPlan });
    mocks.when(
        workPlansSelector.selectByIdAndStoreAccountRecordType(childWorkPlanId)
      )
      .thenReturn(new List<WorkPlan>{ childWorkPlan });
    mocks.stopStubbing();
    Application.UNITOFWORK.setMock(mockUOW);
    Application.SELECTOR.setMock(workPlansSelector);
    Test.startTest();
    StoresOnWorkPlansService.fetchStoresByWorkPlan(childWorkPlanId);
    Test.stopTest();
    System.assertEquals(
      WORK_PLAN_NAME,
      childWorkPlan.Name,
      ASSERT_MESSAGE_WORK_PLAN_NAME
    );
    System.assertEquals(
      storeAccountId,
      childWorkPlan.WorkOrder.AccountId,
      ASSERT_MESSAGE_ID_DO_NOT_MATCH
    );
  }

  /**
   * @description To test fetch store data when a section is changed on UI.
   * Suppressed Warnings since mock verify method does not require system assert statements.
   */
  @isTest
  @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
  private static void testWhenFetchStoreDataThenReturnStoreData() {
    Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
    Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
    Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
    Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
    Account parentAccount = new Account(
      Id = businessAccountId,
      Name = BUSINESS_ACCOUNT_NAME,
      RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID
    );
    List<Account> storeAccounts = new List<Account>{
      new Account(
        Id = storeAccountId,
        BillingStreet = ACCOUNT_BILLING_STREET,
        Name = STORE_ACCOUNT_NAME,
        ParentId = parentAccount.Id,
        Partnership_Status__c = ACCOUNT_PARTNERSHIP_STATUS,
        RecordTypeId = ACCOUNT_STORE_RECORD_TYPE_ID
      )
    };
    WorkOrder newMockWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
      .setField(WorkOrder.Status, STATUS_CONFIRMED)
      .setField(WorkOrder.Type__c, TYPE_DRIVE)
      .setField(WorkOrder.AccountId, storeAccountId)
      .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
      .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
      .setField(WorkOrder.Menu_to_be_Completed_By__c, MENU_COMPLETED_BY)
      .setField(WorkOrder.Vertical__c, VERTICAL)
      .setField(WorkOrder.Id, workOrderId)
      .setField(WorkOrder.Opportunity__c, opportunityId)
      .setField(WorkOrder.Contract__c, null)
      .toSObject();
    WorkPlan mockWorkPlan = new WorkPlan(
      Id = workPlanId,
      Name = WORK_PLAN_NAME,
      WorkOrderId = newMockWorkOrder.Id
    );
    AccountWrapper accountWrapper = new AccountWrapper(
      storeAccountId,
      ACCOUNT_NAME,
      opportunityId,
      workOrderId
    );
    accountWrapper.parentWorkOrderId = null;
    accountWrapper.workOrderType = TYPE_DRIVE;
    accountWrapper.workPlanType = mockWorkPlan.Name;
    accountWrapper.businessAccountId = businessAccountId;
    List<WorkOrder> workOrders = new List<WorkOrder>{
      new WorkOrder(
        Id = workOrderId,
        AccountId = storeAccountId,
        Opportunity__c = opportunityId,
        Type__c = TYPE_DRIVE,
        ParentWorkOrderId = null,
        Contract__c = null
      )
    };
    fflib_ApexMocks mocks = new fflib_ApexMocks();
    IAccountsSelector accountsSelector = (IAccountsSelector) mocks.mock(
      IAccountsSelector.class
    );
    IDecisionMakerCalculationService decisionMakerService = (IDecisionMakerCalculationService) mocks.mock(
      IDecisionMakerCalculationService.class
    );
    fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
      fflib_ISObjectUnitOfWork.class
    );
    mocks.startStubbing();
    mocks.when(accountsSelector.sObjectType()).thenReturn(Account.SObjectType);
    mocks.when(
        accountsSelector.selectRelatedChildsById(new Set<Id>{ storeAccountId })
      )
      .thenReturn(storeAccounts);
    mocks.when(decisionMakerService.getDecisionMakers(workOrders))
      .thenReturn(
        new Map<Id, List<Id>>{ opportunityId => new List<Id>{ contactId } }
      );
    mocks.stopStubbing();
    Application.UNITOFWORK.setMock(mockUOW);
    Application.SELECTOR.setMock(accountsSelector);
    Application.SERVICE.setMock(
      IDecisionMakerCalculationService.class,
      decisionMakerService
    );
    Test.startTest();
    StoresOnWorkPlansService.fetchStoresData(
      JSON.serialize(new List<AccountWrapper>{ accountWrapper })
    );
    Test.stopTest();
    ((IDecisionMakerCalculationService) mocks.verify(decisionMakerService, 1))
      .getDecisionMakers(workOrders);
  }

  /**
   * @description To test fetch store data when a section is changed on UI.
   * Suppressed Warnings since mock verify method does not require System Assert statements.
   */
  @isTest
  @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
  private static void testWhenNoDecisionMakerThenReturnNull() {
    Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
    Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
    Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
    Account parentAccount = new Account(
      Id = businessAccountId,
      Name = BUSINESS_ACCOUNT_NAME,
      RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID
    );
    List<Account> storeAccounts = new List<Account>{
      new Account(
        Id = storeAccountId,
        BillingStreet = ACCOUNT_BILLING_STREET,
        Name = STORE_ACCOUNT_NAME,
        ParentId = parentAccount.Id,
        Partnership_Status__c = ACCOUNT_PARTNERSHIP_STATUS,
        RecordTypeId = ACCOUNT_STORE_RECORD_TYPE_ID
      )
    };
    WorkOrder newMockWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
      .setField(WorkOrder.Status, STATUS_CONFIRMED)
      .setField(WorkOrder.Type__c, TYPE_DRIVE)
      .setField(WorkOrder.AccountId, storeAccountId)
      .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
      .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
      .setField(WorkOrder.Menu_to_be_Completed_By__c, MENU_COMPLETED_BY)
      .setField(WorkOrder.Vertical__c, VERTICAL)
      .setField(WorkOrder.Opportunity__c, opportunityId)
      .setField(WorkOrder.Id, workOrderId)
      .setField(WorkOrder.Contract__c, null)
      .toSObject();
    WorkPlan mockWorkPlan = new WorkPlan(
      Id = workPlanId,
      Name = WORK_PLAN_NAME,
      WorkOrderId = newMockWorkOrder.Id
    );
    AccountWrapper accountWrapper = new AccountWrapper(
      storeAccountId,
      ACCOUNT_NAME,
      opportunityId,
      workOrderId
    );
    accountWrapper.parentWorkOrderId = null;
    accountWrapper.workOrderType = TYPE_DRIVE;
    accountWrapper.workPlanType = mockWorkPlan.Name;
    accountWrapper.businessAccountId = businessAccountId;
    List<WorkOrder> workOrders = new List<WorkOrder>{
      new WorkOrder(
        Id = workOrderId,
        AccountId = storeAccountId,
        Opportunity__c = opportunityId,
        Type__c = TYPE_DRIVE,
        ParentWorkOrderId = null,
        Contract__c = null
      )
    };
    fflib_ApexMocks mocks = new fflib_ApexMocks();
    IAccountsSelector accountsSelector = (IAccountsSelector) mocks.mock(
      IAccountsSelector.class
    );
    IDecisionMakerCalculationService decisionMakerService = (IDecisionMakerCalculationService) mocks.mock(
      IDecisionMakerCalculationService.class
    );
    fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
      fflib_ISObjectUnitOfWork.class
    );
    mocks.startStubbing();
    mocks.when(accountsSelector.sObjectType()).thenReturn(Account.SObjectType);
    mocks.when(
        accountsSelector.selectRelatedChildsById(new Set<Id>{ storeAccountId })
      )
      .thenReturn(storeAccounts);
    mocks.when(decisionMakerService.getDecisionMakers(workOrders))
      .thenReturn(new Map<Id, List<Id>>());
    mocks.stopStubbing();
    Application.UNITOFWORK.setMock(mockUOW);
    Application.SELECTOR.setMock(accountsSelector);
    Application.SERVICE.setMock(
      IDecisionMakerCalculationService.class,
      decisionMakerService
    );
    Test.startTest();
    StoresOnWorkPlansService.fetchStoresData(
      JSON.serialize(new List<AccountWrapper>{ accountWrapper })
    );
    Test.stopTest();
    ((IDecisionMakerCalculationService) mocks.verify(decisionMakerService, 1))
      .getDecisionMakers(workOrders);
  }

  /**
   * @description To test Contract Details section is displayed for Menu Updates Work Plan.
   */
  @isTest
  private static void testWhenMenuUpdatesWorkPlanTypeReceivedThenContractDetailsSectionNotSkipped() {
    Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
    Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
    Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
    Account parentAccount = new Account(
      Id = businessAccountId,
      Name = BUSINESS_ACCOUNT_NAME,
      RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID
    );
    List<Account> storeAccounts = new List<Account>{
      new Account(
        Id = storeAccountId,
        BillingStreet = ACCOUNT_BILLING_STREET,
        Name = STORE_ACCOUNT_NAME,
        ParentId = parentAccount.Id,
        Partnership_Status__c = ACCOUNT_PARTNERSHIP_STATUS,
        RecordTypeId = ACCOUNT_STORE_RECORD_TYPE_ID
      )
    };
    WorkOrder newMockWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
      .setField(WorkOrder.Status, STATUS_CONFIRMED)
      .setField(WorkOrder.Type__c, TYPE_DRIVE)
      .setField(WorkOrder.AccountId, storeAccountId)
      .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
      .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
      .setField(WorkOrder.Menu_to_be_Completed_By__c, MENU_COMPLETED_BY)
      .setField(WorkOrder.Vertical__c, VERTICAL)
      .setField(WorkOrder.Opportunity__c, opportunityId)
      .setField(WorkOrder.Id, workOrderId)
      .setField(WorkOrder.Contract__c, null)
      .toSObject();
    WorkPlan mockWorkPlan = new WorkPlan(
      Id = workPlanId,
      Name = WORK_PLAN_NAME_MENU_UPDATES,
      WorkOrderId = newMockWorkOrder.Id
    );
    AccountWrapper accountWrapper = new AccountWrapper(
      storeAccountId,
      ACCOUNT_NAME,
      opportunityId,
      workOrderId
    );
    accountWrapper.parentWorkOrderId = null;
    accountWrapper.workOrderType = TYPE_DRIVE;
    accountWrapper.workPlanType = mockWorkPlan.Name;
    accountWrapper.businessAccountId = businessAccountId;
    List<WorkOrder> workOrders = new List<WorkOrder>{
      new WorkOrder(
        Id = workOrderId,
        AccountId = storeAccountId,
        Opportunity__c = opportunityId,
        Type__c = TYPE_DRIVE,
        ParentWorkOrderId = null,
        Contract__c = null
      )
    };
    fflib_ApexMocks mocks = new fflib_ApexMocks();
    IAccountsSelector accountsSelector = (IAccountsSelector) mocks.mock(
      IAccountsSelector.class
    );
    IDecisionMakerCalculationService decisionMakerService = (IDecisionMakerCalculationService) mocks.mock(
      IDecisionMakerCalculationService.class
    );
    fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
      fflib_ISObjectUnitOfWork.class
    );
    mocks.startStubbing();
    mocks.when(accountsSelector.sObjectType()).thenReturn(Account.SObjectType);
    mocks.when(
        accountsSelector.selectRelatedChildsById(new Set<Id>{ storeAccountId })
      )
      .thenReturn(storeAccounts);
    mocks.when(decisionMakerService.getDecisionMakers(workOrders))
      .thenReturn(new Map<Id, List<Id>>());
    mocks.stopStubbing();
    Application.UNITOFWORK.setMock(mockUOW);
    Application.SELECTOR.setMock(accountsSelector);
    Application.SERVICE.setMock(
      IDecisionMakerCalculationService.class,
      decisionMakerService
    );
    Test.startTest();
    List<SectionWrapper> sectionWrappers = StoresOnWorkPlansService.fetchStoresData(
      JSON.serialize(new List<AccountWrapper>{ accountWrapper })
    );
    Test.stopTest();
    for (SectionWrapper eachSectionWrapper : sectionWrappers) {
      if (eachSectionWrapper.objectName == CONTRACT_OBJECT_NAME) {
        System.assertEquals(
          true,
          eachSectionWrapper.sectionName == CONTRACT_DETAILS_SECTION_NAME,
          ASSERT_MESSAGE_CONTRACT_DETAILS_SECTION_IS_NOT_DISPLAYED
        );
      }
    }
  }

  /**
   * @description To test Contact encrypted fields are retrieved from Billing Contact
   * on Payment Account.
   */
  @isTest
  private static void testWhenFetchStoreRelatedContactDataThenReturnPaymentAccountBillingContactEncryptedFields() {
    Id billingContactId = fflib_IDGenerator.generate(Contact.SObjectType);
    Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
    Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
    Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
    Id paymentAccountId = fflib_IDGenerator.generate(
      Payment_Account__c.SObjectType
    );
    Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
      VERTICAL,
      ACCOUNT_RECORD_TYPE_NAME_BUSINESS
    );
    Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
      parentBusinessAccountFakeInstance
    );
    Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
        parentBusinessAccount.Id,
        VERTICAL
      )
      .setField(Account.Id, storeAccountId)
      .setChildren(
        ACCOUNT_PAYMENT_ACCOUNT_RELATION_RELATIONSHIP_NAME,
        new List<Fake>{
          new Fake(Account_Payment_Account_Relation__c.class)
            .setField(
              Account_Payment_Account_Relation__c.Account__c,
              storeAccountId
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
              PAYMENT_ACCOUNT_RELATIONSHIP_NAME,
              new Fake(Payment_Account__c.class)
                .setField(
                  Payment_Account__c.Billing_Contact_Name__c,
                  billingContactId
                )
            )
        }
      );
    Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
      storeAccountFakeInstance
    );
    List<Account> storeAccounts = new List<Account>{ storeAccount };
    Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
        storeAccount.Id,
        TYPE_MARKETPLACE
      )
      .setField(WorkOrder.Opportunity__c, opportunityId)
      .setField(WorkOrder.Contract__c, null);
    WorkOrder workOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
      workOrderFakeInstance
    );
    WorkPlan mockWorkPlan = new WorkPlan(
      Id = workPlanId,
      Name = WORK_PLAN_NAME_SETUP_BANKING,
      WorkOrderId = workOrder.Id
    );
    AccountWrapper accountWrapper = new AccountWrapper(
      storeAccount.Id,
      ACCOUNT_NAME,
      opportunityId,
      workOrder.Id
    );
    accountWrapper.parentWorkOrderId = null;
    accountWrapper.workOrderType = TYPE_DRIVE;
    accountWrapper.workPlanType = mockWorkPlan.Name;
    accountWrapper.businessAccountId = parentBusinessAccount.Id;
    List<WorkOrder> workOrders = new List<WorkOrder>{
      new WorkOrder(
        Id = workOrder.Id,
        AccountId = storeAccount.Id,
        Opportunity__c = opportunityId,
        Type__c = TYPE_DRIVE,
        ParentWorkOrderId = null,
        Contract__c = null
      )
    };
    Stores_List_View_Configuration__mdt storesListViewConfigurations = (Stores_List_View_Configuration__mdt) ServiceMockDataBuilder.convertToSObject(
      new Fake(Stores_List_View_Configuration__mdt.class)
        .setField(
          Stores_List_View_Configuration__mdt.Applicable_Account_Record_Type__c,
          ACCOUNT_RECORD_TYPE_NAME_STORE
        )
        .setField(
          Stores_List_View_Configuration__mdt.FieldSet_Name__c,
          PAYMENT_ACCOUNT_FIELDSET_NAME
        )
        .setField(
          Stores_List_View_Configuration__mdt.Object_Name__c,
          PAYMENT_ACCOUNT_OBJECT_NAME
        )
        .setField(
          Stores_List_View_Configuration__mdt.Section_Name__c,
          BANKING_INFORMATION_SECTION_NAME
        )
        .setField(Stores_List_View_Configuration__mdt.Section_Sequence__c, 1)
        .setField(
          Stores_List_View_Configuration__mdt.Show_Section_Header__c,
          true
        )
        .setField(
          Stores_List_View_Configuration__mdt.Type__c,
          WORK_PLAN_NAME_SETUP_BANKING
        )
        .setFakeId()
    );
    fflib_ApexMocks mocks = new fflib_ApexMocks();
    IAccountsSelector accountsSelector = (IAccountsSelector) mocks.mock(
      IAccountsSelector.class
    );
    IStoresListViewConfigurationsSelector storesListViewConfigurationsSelector = (IStoresListViewConfigurationsSelector) mocks.mock(
      IStoresListViewConfigurationsSelector.class
    );
    IDecisionMakerCalculationService decisionMakerService = (IDecisionMakerCalculationService) mocks.mock(
      IDecisionMakerCalculationService.class
    );
    fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
      fflib_ISObjectUnitOfWork.class
    );
    mocks.startStubbing();
    mocks.when(accountsSelector.sObjectType()).thenReturn(Account.SObjectType);
    mocks.when(
        accountsSelector.selectRelatedChildsById(new Set<Id>{ storeAccount.Id })
      )
      .thenReturn(storeAccounts);
    mocks.when(decisionMakerService.getDecisionMakers(workOrders))
      .thenReturn(
        new Map<Id, List<Id>>{ opportunityId => new List<Id>{ contactId } }
      );
    mocks.when(storesListViewConfigurationsSelector.sObjectType())
      .thenReturn(Stores_List_View_Configuration__mdt.SObjectType);
    mocks.when(
        storesListViewConfigurationsSelector.selectByWorkPlanTypeAndAccountRecordType(
          WORK_PLAN_NAME_SETUP_BANKING,
          ACCOUNT_RECORD_TYPE_NAME_STORE
        )
      )
      .thenReturn(
        new List<Stores_List_View_Configuration__mdt>{
          storesListViewConfigurations
        }
      );
    mocks.stopStubbing();
    Application.UNITOFWORK.setMock(mockUOW);
    Application.SELECTOR.setMock(accountsSelector);
    Application.SELECTOR.setMock(storesListViewConfigurationsSelector);
    Application.SERVICE.setMock(
      IDecisionMakerCalculationService.class,
      decisionMakerService
    );
    Test.startTest();
    List<SectionWrapper> sectionWrappers = StoresOnWorkPlansService.fetchStoresData(
      JSON.serialize(new List<AccountWrapper>{ accountWrapper })
    );
    Test.stopTest();
    for (SectionWrapper eachSectionWrapper : sectionWrappers) {
      if (
        eachSectionWrapper.objectName == CONTACT_OBJECT_NAME &&
        eachSectionWrapper.sectionName == BANKING_INFORMATION_SECTION_NAME
      ) {
        System.assertEquals(
          billingContactId,
          eachSectionWrapper.recordId,
          ASSERT_MESSAGE_CONTACT_ID_DO_NOT_MATCH
        );
      }
    }
  }

  /**
   * @description To test business Account data is fetched when fetchStoresData is called
   * on work plan of type "Drive" without associated stores.
   * Suppressed Warnings since mock verify method does not require system assert statements.
   */
  @isTest
  @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
  private static void testWhenFetchStoreDataOnDriveParentWorkPlanWithoutStoresCalledThenReturnBusinessAccountData() {
    Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
    Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
    Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
    Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
    Account parentAccount = (Account) new Fake(Account.class)
      .setField(Account.Id, businessAccountId)
      .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
      .setField(Account.RecordTypeId, ACCOUNT_BUSINESS_RECORD_TYPE_ID)
      .setChildren(
        'Account_Payment_Account_Relations__r',
        new List<Fake>{
          new Fake(Account_Payment_Account_Relation__c.class)
            .setFakeId()
            .setParent(
              'Payment_Account__r',
              new Fake(Payment_Account__c.class)
                .setField(Payment_Account__c.Billing_Contact_Name__c, contactId)
            )
        }
      )
      .setChildren(
        'Contracts',
        new List<Fake>{ new Fake(Contract.class).setFakeId() }
      )
      .setChildren(
        'Xrefs__r',
        new List<Fake>{
          new Fake(Xref__c.class)
            .setFakeId()
            .setField(Xref__c.BusinessID__c, XREF_BUSINESS_ID_VALUE)
            .setField(
              Xref__c.External_ID_Source__c,
              XREF_EXTERNAL_ID_SOURCE_DRIVEDB
            )
        }
      )
      .toSObject();
    List<Account> businessAccounts = new List<Account>{ parentAccount };
    WorkOrder newMockWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
      .setField(WorkOrder.Status, STATUS_CONFIRMED)
      .setField(WorkOrder.Type__c, TYPE_DRIVE)
      .setField(WorkOrder.AccountId, businessAccountId)
      .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
      .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
      .setField(WorkOrder.Menu_to_be_Completed_By__c, MENU_COMPLETED_BY)
      .setField(WorkOrder.Vertical__c, VERTICAL)
      .setField(WorkOrder.Id, workOrderId)
      .setField(WorkOrder.Opportunity__c, opportunityId)
      .setField(WorkOrder.Contract__c, null)
      .toSObject();
    WorkPlan mockWorkPlan = new WorkPlan(
      Id = workPlanId,
      Name = TYPE_DRIVE,
      WorkOrderId = newMockWorkOrder.Id
    );
    AccountWrapper accountWrapper = new AccountWrapper(
      businessAccountId,
      ACCOUNT_NAME,
      opportunityId,
      workOrderId
    );
    accountWrapper.parentWorkOrderId = null;
    accountWrapper.workOrderType = TYPE_DRIVE;
    accountWrapper.workPlanType = mockWorkPlan.Name;
    accountWrapper.businessAccountId = businessAccountId;
    List<WorkOrder> workOrders = new List<WorkOrder>{
      new WorkOrder(
        Id = workOrderId,
        AccountId = businessAccountId,
        Opportunity__c = opportunityId,
        Type__c = TYPE_DRIVE,
        ParentWorkOrderId = null,
        Contract__c = null
      )
    };
    fflib_ApexMocks mocks = new fflib_ApexMocks();
    IAccountsSelector accountsSelector = (IAccountsSelector) mocks.mock(
      IAccountsSelector.class
    );
    IDecisionMakerCalculationService decisionMakerService = (IDecisionMakerCalculationService) mocks.mock(
      IDecisionMakerCalculationService.class
    );
    fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
      fflib_ISObjectUnitOfWork.class
    );
    mocks.startStubbing();
    mocks.when(accountsSelector.sObjectType()).thenReturn(Account.SObjectType);
    mocks.when(
        accountsSelector.selectRelatedChildsById(
          new Set<Id>{ businessAccountId }
        )
      )
      .thenReturn(businessAccounts);
    mocks.when(decisionMakerService.getDecisionMakers(workOrders))
      .thenReturn(
        new Map<Id, List<Id>>{ opportunityId => new List<Id>{ contactId } }
      );
    mocks.stopStubbing();
    Application.UNITOFWORK.setMock(mockUOW);
    Application.SELECTOR.setMock(accountsSelector);
    Application.SERVICE.setMock(
      IDecisionMakerCalculationService.class,
      decisionMakerService
    );
    Test.startTest();
    List<SectionWrapper> result = StoresOnWorkPlansService.fetchStoresData(
      JSON.serialize(new List<AccountWrapper>{ accountWrapper })
    );
    Test.stopTest();
    ((IDecisionMakerCalculationService) mocks.verify(decisionMakerService, 1))
      .getDecisionMakers(workOrders);
    System.assertEquals(
      6,
      result.size(),
      ASSERT_MESSAGE_INCORRECT_NUMBER_OF_SECTION_WRAPPER
    );
    for (SectionWrapper eachSectionWrapper : result) {
      if (eachSectionWrapper.objectName == ACCOUNT_OBJECT_NAME) {
        System.assertEquals(
          BUSINESS_ACCOUNT_DETAILS_SECTION_NAME,
          eachSectionWrapper.sectionName,
          ASSERT_MESSAGE_INCORRECT_SECTION_NAME_RETURNED
        );
      }
      if (eachSectionWrapper.objectName == CONTRACT_OBJECT_NAME) {
        System.assertEquals(
          CONTRACT_DETAILS_SECTION_NAME,
          eachSectionWrapper.sectionName,
          ASSERT_MESSAGE_INCORRECT_SECTION_NAME_RETURNED
        );
      }
      if (eachSectionWrapper.objectName == XREF_OBJECT_NAME) {
        System.assertEquals(
          XREF_DETAILS_SECTION_NAME,
          eachSectionWrapper.sectionName,
          ASSERT_MESSAGE_INCORRECT_SECTION_NAME_RETURNED
        );
      }
      if (eachSectionWrapper.objectName == CONTACT_OBJECT_NAME) {
        System.assertEquals(
          CONTACT_DETAILS_SECTION_NAME,
          eachSectionWrapper.sectionName,
          ASSERT_MESSAGE_INCORRECT_SECTION_NAME_RETURNED
        );
      }
      if (eachSectionWrapper.objectName == PAYMENT_ACCOUNT_OBJECT_NAME) {
        System.assertEquals(
          BANKING_INFORMATION_SECTION_NAME,
          eachSectionWrapper.sectionName,
          ASSERT_MESSAGE_INCORRECT_SECTION_NAME_RETURNED
        );
      }
    }
  }

  /**
   * @description To test franchisee Account data is fetched when fetchStoresData is called
   * on work plan of type "Drive" without associated stores.
   * Suppressed Warnings since mock verify method does not require system assert statements.
   */
  @isTest
  @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
  private static void testWhenFetchStoreDataOnDriveParentWorkPlanWithoutStoresCalledThenReturnFranchiseeAccountData() {
    Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
    Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
    Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
    Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
    Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
    Account parentAccount = (Account) new Fake(Account.class)
      .setField(Account.Id, businessAccountId)
      .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
      .setField(Account.RecordTypeId, ACCOUNT_BUSINESS_RECORD_TYPE_ID)
      .setField(Account.Type, ACCOUNT_TYPE_FRANCHISEE)
      .setChildren(
        'Account_Payment_Account_Relations__r',
        new List<Fake>{
          new Fake(Account_Payment_Account_Relation__c.class)
            .setFakeId()
            .setParent(
              'Payment_Account__r',
              new Fake(Payment_Account__c.class)
                .setField(Payment_Account__c.Billing_Contact_Name__c, contactId)
            )
        }
      )
      .setChildren(
        'Agreements__r',
        new List<Fake>{
          new Fake(Agreement__c.class)
            .setFakeId()
            .setField(Agreement__c.Contract__c, contractId)
            .setField(Agreement__c.Type__c, AGREEMENT_TYPE_FRANCHISE)
            .setParent(
              'Contract__r',
              new Fake(Contract.class).setField(Contract.Id, contractId)
            )
        }
      )
      .setChildren(
        'Xrefs__r',
        new List<Fake>{
          new Fake(Xref__c.class)
            .setFakeId()
            .setField(Xref__c.BusinessID__c, XREF_BUSINESS_ID_VALUE)
            .setField(
              Xref__c.External_ID_Source__c,
              XREF_EXTERNAL_ID_SOURCE_DRIVEDB
            )
        }
      )
      .toSObject();
    List<Account> businessAccounts = new List<Account>{ parentAccount };
    WorkOrder newMockWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
      .setField(WorkOrder.Status, STATUS_CONFIRMED)
      .setField(WorkOrder.Type__c, TYPE_DRIVE)
      .setField(WorkOrder.AccountId, businessAccountId)
      .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
      .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
      .setField(WorkOrder.Menu_to_be_Completed_By__c, MENU_COMPLETED_BY)
      .setField(WorkOrder.Vertical__c, VERTICAL)
      .setField(WorkOrder.Id, workOrderId)
      .setField(WorkOrder.Opportunity__c, opportunityId)
      .setField(WorkOrder.Contract__c, null)
      .toSObject();
    WorkPlan mockWorkPlan = new WorkPlan(
      Id = workPlanId,
      Name = TYPE_DRIVE,
      WorkOrderId = newMockWorkOrder.Id
    );
    AccountWrapper accountWrapper = new AccountWrapper(
      businessAccountId,
      ACCOUNT_NAME,
      opportunityId,
      workOrderId
    );
    accountWrapper.parentWorkOrderId = null;
    accountWrapper.workOrderType = TYPE_DRIVE;
    accountWrapper.workPlanType = mockWorkPlan.Name;
    accountWrapper.businessAccountId = businessAccountId;
    List<WorkOrder> workOrders = new List<WorkOrder>{
      new WorkOrder(
        Id = workOrderId,
        AccountId = businessAccountId,
        Opportunity__c = opportunityId,
        Type__c = TYPE_DRIVE,
        ParentWorkOrderId = null,
        Contract__c = null
      )
    };
    fflib_ApexMocks mocks = new fflib_ApexMocks();
    IAccountsSelector accountsSelector = (IAccountsSelector) mocks.mock(
      IAccountsSelector.class
    );
    IDecisionMakerCalculationService decisionMakerService = (IDecisionMakerCalculationService) mocks.mock(
      IDecisionMakerCalculationService.class
    );
    fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
      fflib_ISObjectUnitOfWork.class
    );
    mocks.startStubbing();
    mocks.when(accountsSelector.sObjectType()).thenReturn(Account.SObjectType);
    mocks.when(
        accountsSelector.selectRelatedChildsById(
          new Set<Id>{ businessAccountId }
        )
      )
      .thenReturn(businessAccounts);
    mocks.when(decisionMakerService.getDecisionMakers(workOrders))
      .thenReturn(
        new Map<Id, List<Id>>{ opportunityId => new List<Id>{ contactId } }
      );
    mocks.stopStubbing();
    Application.UNITOFWORK.setMock(mockUOW);
    Application.SELECTOR.setMock(accountsSelector);
    Application.SERVICE.setMock(
      IDecisionMakerCalculationService.class,
      decisionMakerService
    );
    Test.startTest();
    List<SectionWrapper> result = StoresOnWorkPlansService.fetchStoresData(
      JSON.serialize(new List<AccountWrapper>{ accountWrapper })
    );
    Test.stopTest();
    ((IDecisionMakerCalculationService) mocks.verify(decisionMakerService, 1))
      .getDecisionMakers(workOrders);
    System.assertEquals(
      6,
      result.size(),
      ASSERT_MESSAGE_INCORRECT_NUMBER_OF_SECTION_WRAPPER
    );
    for (SectionWrapper eachSectionWrapper : result) {
      if (eachSectionWrapper.objectName == ACCOUNT_OBJECT_NAME) {
        System.assertEquals(
          BUSINESS_ACCOUNT_DETAILS_SECTION_NAME,
          eachSectionWrapper.sectionName,
          ASSERT_MESSAGE_INCORRECT_SECTION_NAME_RETURNED
        );
      }
      if (eachSectionWrapper.objectName == CONTRACT_OBJECT_NAME) {
        System.assertEquals(
          CONTRACT_DETAILS_SECTION_NAME,
          eachSectionWrapper.sectionName,
          ASSERT_MESSAGE_INCORRECT_SECTION_NAME_RETURNED
        );
      }
      if (eachSectionWrapper.objectName == XREF_OBJECT_NAME) {
        System.assertEquals(
          XREF_DETAILS_SECTION_NAME,
          eachSectionWrapper.sectionName,
          ASSERT_MESSAGE_INCORRECT_SECTION_NAME_RETURNED
        );
      }
      if (eachSectionWrapper.objectName == CONTACT_OBJECT_NAME) {
        System.assertEquals(
          CONTACT_DETAILS_SECTION_NAME,
          eachSectionWrapper.sectionName,
          ASSERT_MESSAGE_INCORRECT_SECTION_NAME_RETURNED
        );
      }
      if (eachSectionWrapper.objectName == PAYMENT_ACCOUNT_OBJECT_NAME) {
        System.assertEquals(
          BANKING_INFORMATION_SECTION_NAME,
          eachSectionWrapper.sectionName,
          ASSERT_MESSAGE_INCORRECT_SECTION_NAME_RETURNED
        );
      }
    }
  }

  /**
   * @description To test Tablet related fields are retrieved from Work Steps
   * on onboarding details component under Tablet Details section.
   */
  @isTest
  private static void testWhenTabletWorkPlanPresentThenReturnTabletFields() {
    Id accountContactRelationId = fflib_IDGenerator.generate(
      AccountContactRelation.SObjectType
    );
    Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
    Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id childWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
    Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
    Id opportunityContactRoleId = fflib_IDGenerator.generate(
      OpportunityContactRole.SObjectType
    );
    Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
    Id parentWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
    Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
    Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
      VERTICAL,
      ACCOUNT_RECORD_TYPE_NAME_BUSINESS
    );
    Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
      parentBusinessAccountFakeInstance
    );
    Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
        parentBusinessAccount.Id,
        VERTICAL
      )
      .setField(Account.Id, storeAccountId);
    Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
      storeAccountFakeInstance
    );
    List<Account> storeAccounts = new List<Account>{ storeAccount };
    AccountContactRelation mockAccountContactRelation = (AccountContactRelation) new Fake(
        AccountContactRelation.class
      )
      .setField(AccountContactRelation.Id, accountContactRelationId)
      .setField(AccountContactRelation.AccountId, storeAccount.Id)
      .setField(AccountContactRelation.ContactId, contactId)
      .setField(AccountContactRelation.Roles, ROLE)
      .toSObject();
    OpportunityContactRole mockOpportunityContactRole = (OpportunityContactRole) new Fake(
        OpportunityContactRole.class
      )
      .setField(OpportunityContactRole.Id, opportunityContactRoleId)
      .setField(OpportunityContactRole.OpportunityId, opportunityId)
      .setField(OpportunityContactRole.ContactId, contactId)
      .setField(OpportunityContactRole.IsPrimary, true)
      .toSObject();
    Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
        parentBusinessAccount.Id,
        TYPE_MARKETPLACE
      )
      .setField(WorkOrder.Opportunity__c, opportunityId);
    WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
      parentWorkOrderFakeInstance
    );
    Fake workOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
        storeAccount.Id,
        TYPE_MARKETPLACE
      )
      .setField(WorkOrder.Opportunity__c, opportunityId)
      .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id);
    WorkOrder workOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
      workOrderFakeInstance
    );
    WorkPlan parentWorkPlan = new WorkPlan(
      Id = parentWorkPlanId,
      Name = WORK_PLAN_NAME_TABLET,
      WorkOrderId = parentWorkOrder.Id
    );
    WorkPlan childWorkPlan = new WorkPlan(
      Id = workPlanId,
      Name = WORK_PLAN_NAME_TABLET,
      WorkOrderId = workOrder.Id,
      Parent_Work_Plan__c = parentWorkPlan.Id
    );
    WorkStep parentWorkStep = new WorkStep(
      Id = parentWorkStepId,
      Name = WORK_STEP_NAME_DELIVER_TABLET,
      WorkPlanId = parentWorkPlan.Id,
      Status__c = WORK_PLAN_STATUS_NOT_STARTED
    );
    WorkStep childWorkStep = new WorkStep(
      Id = childWorkStepId,
      Name = WORK_STEP_NAME_DELIVER_TABLET,
      WorkPlanId = childWorkPlan.Id,
      Store_Account__c = storeAccount.Id,
      Status__c = WORK_PLAN_STATUS_NOT_STARTED,
      Parent_Work_Step__c = parentWorkStep.Id
    );
    AccountWrapper accountWrapper = new AccountWrapper(
      storeAccount.Id,
      ACCOUNT_NAME,
      opportunityId,
      parentWorkOrder.Id
    );
    accountWrapper.workPlanType = parentWorkPlan.Name;
    accountWrapper.workPlanId = parentWorkPlan.Id;
    accountWrapper.businessAccountId = parentBusinessAccount.Id;
    Stores_List_View_Configuration__mdt storesListViewConfigurations = (Stores_List_View_Configuration__mdt) ServiceMockDataBuilder.convertToSObject(
      new Fake(Stores_List_View_Configuration__mdt.class)
        .setField(
          Stores_List_View_Configuration__mdt.Applicable_Account_Record_Type__c,
          ACCOUNT_RECORD_TYPE_NAME_STORE
        )
        .setField(
          Stores_List_View_Configuration__mdt.FieldSet_Name__c,
          TABLET_DETAILS_FIELDSET_NAME
        )
        .setField(
          Stores_List_View_Configuration__mdt.Object_Name__c,
          WORK_STEP_OBJECT_NAME
        )
        .setField(
          Stores_List_View_Configuration__mdt.Section_Name__c,
          TABLET_DETAILS_SECTION_NAME
        )
        .setField(Stores_List_View_Configuration__mdt.Section_Sequence__c, 1)
        .setField(
          Stores_List_View_Configuration__mdt.Show_Section_Header__c,
          true
        )
        .setField(
          Stores_List_View_Configuration__mdt.Type__c,
          WORK_PLAN_NAME_TABLET
        )
        .setFakeId()
    );
    fflib_ApexMocks mocks = new fflib_ApexMocks();
    IAccountsSelector accountsSelector = (IAccountsSelector) mocks.mock(
      IAccountsSelector.class
    );
    IStoresListViewConfigurationsSelector storesListViewConfigurationsSelector = (IStoresListViewConfigurationsSelector) mocks.mock(
      IStoresListViewConfigurationsSelector.class
    );
    IWorkStepsSelector workStepsSelector = (IWorkStepsSelector) mocks.mock(
      IWorkStepsSelector.class
    );
    IAccountContactRelationsSelector accountContactRelationsSelector = (IAccountContactRelationsSelector) mocks.mock(
      IAccountContactRelationsSelector.class
    );
    IOpportunityContactRoleSelector opportunityContactRolesSelector = (IOpportunityContactRoleSelector) mocks.mock(
      IOpportunityContactRoleSelector.class
    );
    fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
      fflib_ISObjectUnitOfWork.class
    );
    mocks.startStubbing();
    mocks.when(accountsSelector.sObjectType()).thenReturn(Account.SObjectType);
    mocks.when(
        accountsSelector.selectRelatedChildsById(new Set<Id>{ storeAccount.Id })
      )
      .thenReturn(storeAccounts);
    mocks.when(storesListViewConfigurationsSelector.sObjectType())
      .thenReturn(Stores_List_View_Configuration__mdt.SObjectType);
    mocks.when(
        storesListViewConfigurationsSelector.selectByWorkPlanTypeAndAccountRecordType(
          WORK_PLAN_NAME_TABLET,
          ACCOUNT_RECORD_TYPE_NAME_STORE
        )
      )
      .thenReturn(
        new List<Stores_List_View_Configuration__mdt>{
          storesListViewConfigurations
        }
      );
    mocks.when(workStepsSelector.sObjectType())
      .thenReturn(WorkStep.SObjectType);
    mocks.when(
        workStepsSelector.selectByStoreAccountAndWorkOrderIds(
          new Set<Id>{ storeAccount.Id },
          new Set<Id>{ parentWorkOrder.Id },
          new Set<String>{ WORK_STEP_NAME_DELIVER_TABLET }
        )
      )
      .thenReturn(new List<WorkStep>{ childWorkStep });
    mocks.when(accountContactRelationsSelector.sObjectType())
      .thenReturn(AccountContactRelation.SObjectType);
    mocks.when(
        accountContactRelationsSelector.selectByAccountIds(
          new Set<Id>{ storeAccountId }
        )
      )
      .thenReturn(
        new List<AccountContactRelation>{ mockAccountContactRelation }
      );
    mocks.when(opportunityContactRolesSelector.sObjectType())
      .thenReturn(OpportunityContactRole.SObjectType);
    mocks.when(
        opportunityContactRolesSelector.selectByOpportunity(
          new Set<Id>{ opportunityId }
        )
      )
      .thenReturn(
        new List<OpportunityContactRole>{ mockOpportunityContactRole }
      );
    mocks.stopStubbing();
    Application.UNITOFWORK.setMock(mockUOW);
    Application.SELECTOR.setMock(accountsSelector);
    Application.SELECTOR.setMock(storesListViewConfigurationsSelector);
    Application.SELECTOR.setMock(workStepsSelector);
    Application.SELECTOR.setMock(accountContactRelationsSelector);
    Application.SELECTOR.setMock(opportunityContactRolesSelector);
    Test.startTest();
    List<SectionWrapper> sectionWrappers = StoresOnWorkPlansService.fetchStoresData(
      JSON.serialize(new List<AccountWrapper>{ accountWrapper })
    );
    Test.stopTest();
    System.assertEquals(
      1,
      sectionWrappers.size(),
      ASSERT_MESSAGE_INCORRECT_NUMBER_OF_SECTION_WRAPPER
    );
    for (SectionWrapper eachSectionWrapper : sectionWrappers) {
      if (eachSectionWrapper.objectName == WORK_STEP_OBJECT_NAME) {
        System.assertEquals(
          TABLET_DETAILS_SECTION_NAME,
          eachSectionWrapper.sectionName,
          ASSERT_MESSAGE_INCORRECT_SECTION_NAME_RETURNED
        );
      }
    }
  }

  /**
   * @description To test store Account data is fetched when fetchStoresData is called
   * on work plan of type "Vendor Photoshoot".
   */
  @isTest
  private static void testWhenFetchStoreDataOnPhotoshootParentWorkPlanCalledThenReturnPhotoshootDetails() {
    Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
    Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
    Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
    Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
    Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
    Account storeAccount = (Account) new Fake(Account.class)
      .setField(Account.Id, storeAccountId)
      .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
      .setField(Account.RecordTypeId, ACCOUNT_STORE_RECORD_TYPE_ID)
      .setChildren(
        'Account_Payment_Account_Relations__r',
        new List<Fake>{
          new Fake(Account_Payment_Account_Relation__c.class)
            .setFakeId()
            .setParent(
              'Payment_Account__r',
              new Fake(Payment_Account__c.class)
                .setField(Payment_Account__c.Billing_Contact_Name__c, contactId)
            )
        }
      )
      .setChildren(
        'Contracts',
        new List<Fake>{ new Fake(Contract.class).setFakeId() }
      )
      .setChildren(
        'Xrefs__r',
        new List<Fake>{
          new Fake(Xref__c.class)
            .setFakeId()
            .setField(Xref__c.BusinessID__c, XREF_BUSINESS_ID_VALUE)
            .setField(
              Xref__c.External_ID_Source__c,
              XREF_EXTERNAL_ID_SOURCE_DRIVEDB
            )
        }
      )
      .toSObject();
    List<Account> storeAccounts = new List<Account>{ storeAccount };
    WorkOrder newMockWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
      .setField(WorkOrder.Status, STATUS_CONFIRMED)
      .setField(WorkOrder.Type__c, TYPE_PHOTOSHOOT)
      .setField(WorkOrder.AccountId, storeAccountId)
      .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
      .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
      .setField(WorkOrder.Menu_to_be_Completed_By__c, MENU_COMPLETED_BY)
      .setField(WorkOrder.Vertical__c, VERTICAL)
      .setField(WorkOrder.Id, workOrderId)
      .setField(WorkOrder.Opportunity__c, opportunityId)
      .toSObject();
    WorkPlan mockWorkPlan = new WorkPlan(
      Id = workPlanId,
      Name = VENDOR_PHOTOSHOOT,
      WorkOrderId = newMockWorkOrder.Id
    );
    AccountWrapper accountWrapper = new AccountWrapper(
      storeAccountId,
      ACCOUNT_NAME,
      opportunityId,
      workOrderId
    );
    accountWrapper.parentWorkOrderId = parentWorkOrderId;
    accountWrapper.workOrderType = TYPE_PHOTOSHOOT;
    accountWrapper.workPlanType = mockWorkPlan.Name;
    List<WorkOrder> workOrders = new List<WorkOrder>{
      new WorkOrder(
        Id = workOrderId,
        AccountId = storeAccountId,
        Opportunity__c = opportunityId,
        Type__c = TYPE_PHOTOSHOOT,
        ParentWorkOrderId = parentWorkOrderId
      )
    };
    MX_Order__c mxOrder = new MX_Order__c(
      Id = fflib_IDGenerator.generate(MX_Order__c.SObjectType),
      Contact__c = contactId,
      Work_Order__c = parentWorkOrderId
    );
    fflib_ApexMocks mocks = new fflib_ApexMocks();
    IAccountsSelector accountsSelector = (IAccountsSelector) mocks.mock(
      IAccountsSelector.class
    );
    IDecisionMakerCalculationService decisionMakerService = (IDecisionMakerCalculationService) mocks.mock(
      IDecisionMakerCalculationService.class
    );
    IMerchantOrdersSelector merchantOrderSelector = (IMerchantOrdersSelector) mocks.mock(
      IMerchantOrdersSelector.class
    );
    IOrderItemsSelector orderItemsSelector = (IOrderItemsSelector) mocks.mock(
      IOrderItemsSelector.class
    );
    fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
      fflib_ISObjectUnitOfWork.class
    );
    mocks.startStubbing();
    mocks.when(accountsSelector.sObjectType()).thenReturn(Account.SObjectType);
    mocks.when(
        accountsSelector.selectRelatedChildsById(new Set<Id>{ storeAccountId })
      )
      .thenReturn(storeAccounts);
    mocks.when(decisionMakerService.getDecisionMakers(workOrders))
      .thenReturn(
        new Map<Id, List<Id>>{ opportunityId => new List<Id>{ contactId } }
      );
    mocks.when(merchantOrderSelector.sObjectType())
      .thenReturn(MX_Order__c.SObjectType);
    mocks.when(
        merchantOrderSelector.selectByWorkOrderIds(
          new Set<Id>{ parentWorkOrderId }
        )
      )
      .thenReturn(new List<MX_Order__c>{ mxOrder });
    mocks.when(orderItemsSelector.sObjectType())
      .thenReturn(OrderItem.SObjectType);
    mocks.when(
        orderItemsSelector.selectActivatedOrderItemsByAccountIds(
          new Set<Id>{ storeAccountId }
        )
      )
      .thenReturn(new List<OrderItem>{});
    mocks.stopStubbing();
    Application.UNITOFWORK.setMock(mockUOW);
    Application.SELECTOR.setMock(accountsSelector);
    Application.SELECTOR.setMock(merchantOrderSelector);
    Application.SELECTOR.setMock(orderItemsSelector);
    Application.SERVICE.setMock(
      IDecisionMakerCalculationService.class,
      decisionMakerService
    );
    Test.startTest();
    List<SectionWrapper> result = StoresOnWorkPlansService.fetchStoresData(
      JSON.serialize(new List<AccountWrapper>{ accountWrapper })
    );
    Test.stopTest();
    ((IDecisionMakerCalculationService) mocks.verify(decisionMakerService, 0))
      .getDecisionMakers(workOrders);
    System.assertEquals(
      5,
      result.size(),
      ASSERT_MESSAGE_INCORRECT_NUMBER_OF_SECTION_WRAPPER
    );
  }

  /**
   * @description To test OrderItem data is fetched when fetchStoresData is called
   * on work plan of type Ads/Promos.
   */
  @isTest
  private static void testWhenFetchStoreDataCalledOnAdsPromosParentWorkPlanThenReturnAdsPromosOrderItemsDetails() {
    Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
    Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
    Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
    Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
    Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
    Account storeAccount = (Account) new Fake(Account.class)
      .setField(Account.Id, storeAccountId)
      .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
      .setField(Account.RecordTypeId, ACCOUNT_STORE_RECORD_TYPE_ID)
      .toSObject();
    List<Account> storeAccounts = new List<Account>{ storeAccount };
    WorkOrder newMockWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
      .setField(WorkOrder.Status, STATUS_CONFIRMED)
      .setField(WorkOrder.Type__c, TYPE_ADS_AND_PROMOS)
      .setField(WorkOrder.AccountId, storeAccountId)
      .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
      .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
      .setField(WorkOrder.Menu_to_be_Completed_By__c, MENU_COMPLETED_BY)
      .setField(WorkOrder.Vertical__c, VERTICAL)
      .setField(WorkOrder.Id, workOrderId)
      .setField(WorkOrder.Opportunity__c, opportunityId)
      .setField(WorkOrder.Contract__c, contractId)
      .toSObject();
    WorkPlan mockWorkPlan = new WorkPlan(
      Id = workPlanId,
      Name = WORK_PLAN_NAME_ADS,
      WorkOrderId = newMockWorkOrder.Id
    );
    AccountWrapper accountWrapper = new AccountWrapper(
      storeAccountId,
      ACCOUNT_NAME,
      opportunityId,
      workOrderId
    );
    accountWrapper.parentWorkOrderId = parentWorkOrderId;
    accountWrapper.workOrderType = TYPE_ADS_AND_PROMOS;
    accountWrapper.workPlanType = mockWorkPlan.Name;
    accountWrapper.workOrderContractId = newMockWorkOrder.Contract__c;
    List<OrderItem> orderItems = new List<OrderItem>{
      new OrderItem(
        Id = fflib_IDGenerator.generate(OrderItem.SObjectType),
        OrderId = fflib_IDGenerator.generate(Order.SObjectType),
        SBQQ__Contract__c = contractId
      )
    };
    fflib_ApexMocks mocks = new fflib_ApexMocks();
    IAccountsSelector accountsSelector = (IAccountsSelector) mocks.mock(
      IAccountsSelector.class
    );
    IOrderItemsSelector orderItemsSelector = (IOrderItemsSelector) mocks.mock(
      IOrderItemsSelector.class
    );
    fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
      fflib_ISObjectUnitOfWork.class
    );
    mocks.startStubbing();
    mocks.when(accountsSelector.sObjectType()).thenReturn(Account.SObjectType);
    mocks.when(
        accountsSelector.selectRelatedChildsById(new Set<Id>{ storeAccountId })
      )
      .thenReturn(storeAccounts);
    mocks.when(orderItemsSelector.sObjectType())
      .thenReturn(OrderItem.SObjectType);
    mocks.when(
        orderItemsSelector.selectActivatedOrderItemsByAccountIds(
          new Set<Id>{ storeAccountId }
        )
      )
      .thenReturn(orderItems);
    mocks.stopStubbing();
    Application.UNITOFWORK.setMock(mockUOW);
    Application.SELECTOR.setMock(accountsSelector);
    Application.SELECTOR.setMock(orderItemsSelector);
    Test.startTest();
    List<SectionWrapper> sectionWrappers = StoresOnWorkPlansService.fetchStoresData(
      JSON.serialize(new List<AccountWrapper>{ accountWrapper })
    );
    Test.stopTest();
    for (SectionWrapper eachSectionWrapper : sectionWrappers) {
      if (eachSectionWrapper.objectName == ORDER_ITEM_OBJECT_NAME) {
        System.assertEquals(
          ORDER_ITEM_SECTION_NAME,
          eachSectionWrapper.sectionName,
          ORDER_ITEM_ERROR_MESSAGE
        );
      }
    }
  }
  /**
   * @description To test fetching of store account in case of Photoshoot work order type and workplan with dead status.
   */
  @isTest
  private static void testWhenFetchStoresFromPhotoShootWorkPlanWithStatusAsDead() {
    Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id photoshootWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
    Id childWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
    Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
    Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
    WorkPlan photoshootWorkPlan = (WorkPlan) new Fake(WorkPlan.class)
      .setField(WorkPlan.Id, photoshootWorkPlanId)
      .setField(WorkPlan.Status__c, STATUS_DEAD)
      .setField(WorkPlan.Work_Order_Type__c, WORK_ORDER_TYPE_PHOTOSHOOT)
      .setField(WorkPlan.Name, WORK_PLAN_NAME)
      .setField(WorkPlan.ParentRecordId, childWorkOrderId)
      .setField(WorkPlan.WorkOrderId, childWorkOrderId)
      .setParent(
        'WorkOrder',
        new Fake(WorkOrder.class)
          .setField(WorkOrder.Status, STATUS_CONFIRMED)
          .setField(WorkOrder.Type__c, TYPE_DRIVE)
          .setField(WorkOrder.AccountId, storeAccountId)
          .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
          .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
          .setField(WorkOrder.Menu_to_be_Completed_By__c, MENU_COMPLETED_BY)
          .setField(WorkOrder.Vertical__c, VERTICAL)
          .setField(WorkOrder.Id, childWorkOrderId)
          .setField(WorkOrder.Contract__c, null)
          .setParent(
            'Account',
            new Fake(Account.class)
              .setField(Account.Id, storeAccountId)
              .setField(Account.Name, STORE_ACCOUNT_NAME)
              .setField(Account.RecordTypeId, ACCOUNT_STORE_RECORD_TYPE_ID)
              .setField(Account.BillingStreet, ACCOUNT_BILLING_STREET)
              .setField(
                Account.Partnership_Status__c,
                ACCOUNT_PARTNERSHIP_STATUS
              )
              .setField(Account.ParentId, businessAccountId)
          )
      )
      .toSObject();
    fflib_ApexMocks mocks = new fflib_ApexMocks();
    IWorkPlansSelector workPlansSelector = (IWorkPlansSelector) mocks.mock(
      IWorkPlansSelector.class
    );
    fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
      fflib_ISObjectUnitOfWork.class
    );
    mocks.startStubbing();
    mocks.when(workPlansSelector.sObjectType())
      .thenReturn(WorkPlan.SObjectType);
    mocks.when(
        workPlansSelector.selectById(new Set<Id>{ photoshootWorkPlanId })
      )
      .thenReturn(new List<WorkPlan>{ photoshootWorkPlan });
    mocks.when(
        workPlansSelector.selectByIdAndStoreAccountRecordType(
          photoshootWorkPlanId
        )
      )
      .thenReturn(new List<WorkPlan>{ photoshootWorkPlan });
    mocks.stopStubbing();
    Application.UNITOFWORK.setMock(mockUOW);
    Application.SELECTOR.setMock(workPlansSelector);
    Test.startTest();
    StoresOnWorkPlansService.fetchStoresByWorkPlan(photoshootWorkPlanId);
    Test.stopTest();
    System.assertEquals(
      WORK_PLAN_NAME,
      photoshootWorkPlan.Name,
      ASSERT_MESSAGE_WORK_PLAN_NAME
    );
    System.assertEquals(
      storeAccountId,
      photoshootWorkPlan.WorkOrder.AccountId,
      ASSERT_MESSAGE_ID_DO_NOT_MATCH
    );
  }
}
