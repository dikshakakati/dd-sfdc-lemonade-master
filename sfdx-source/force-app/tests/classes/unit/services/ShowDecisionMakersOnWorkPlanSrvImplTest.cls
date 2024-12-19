/**
 * @author Deloitte
 * @date 07/12/2024
 * @description Test class for ShowDecisionMakersOnWorkPlanServiceImpl class.
 */
@isTest(seeAllData=false)
private class ShowDecisionMakersOnWorkPlanSrvImplTest {
    private static final String ACCOUNT_BILLING_STREET = '221B Baker Street';
    private static final String ACTIVATE_CENTRALLY = 'Yes';
    private static final String ASSERT_MESSAGE_WORK_PLAN_NAME = 'Unexpected result: WorkPlan Name is not matching';
    private static final String ACCOUNT_NAME = 'Test KFC Account';
    private static final String ACCOUNT_PARTNERSHIP_STATUS = 'Prospective Partner';
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final String ACCOUNT_STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get(ACCOUNT_RECORD_TYPE_NAME_STORE)
        .getRecordTypeId();
    private static final String CONTACT_EMAIL = 'test@ContactsSelectorTest.com';
    private static final String CONTACT_FIRST_NAME = 'FirstName';
    private static final String CONTACT_LAST_NAME = 'LastName';
    private static final String CONTACT_PHONE = '1234567898';
    private static final String CONTACT_SSN = '1234';
    private static final String MENU_COMPLETED_BY = 'Account Owner';
    private static final Integer NUMBER_OF_CALL_ATTEMPTS = 1;
    private static final String ORDER_PROTOCOL = 'Email';
    private static final string ROLE = 'Decision Maker';
    private static final String STORE_ACCOUNT_NAME = 'Test Account';
    private static final String STATUS_CONFIRMED = 'Confirmed';
    private static final String TYPE_MARKETPLACE = 'Marketplace';
    private static final String TYPE_STOREFRONT = 'Storefront';
    private static final String VERTICAL = 'Floral';
    private static final String WORK_PLAN_NAME = 'Onboarding';
    private static final String WORK_PLAN_STATUS_NOT_STARTED = 'Not Started';

    /**
     * @description To test Work Order's related Store Account from parent WorkPlan Id.
     */
    @isTest
    private static void testWhenFetchWorkPlanByParentWorkPlanIdThenReturnRelatedChildWorkPlanes() {
        Id accountContactId = fflib_IDGenerator.generate(AccountContactRelation.SObjectType);
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
        Id childWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id marketplaceChildWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id storeFrontAccountContactId = fflib_IDGenerator.generate(
            AccountContactRelation.SObjectType
        );
        Id storefrontChildWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id storeFrontContactId = fflib_IDGenerator.generate(Contact.SObjectType);
        Id storeMarketplaceAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id storeStorefrontAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
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
            .setField(WorkPlan.ParentRecordId, marketplaceChildWorkOrderId)
            .setField(WorkPlan.WorkOrderId, marketplaceChildWorkOrderId)
            .setField(WorkPlan.Parent_Work_Plan__c, parentWorkPlan.Id)
            .setParent(
                'WorkOrder',
                new Fake(WorkOrder.class)
                    .setField(WorkOrder.Status, STATUS_CONFIRMED)
                    .setField(WorkOrder.Type__c, TYPE_MARKETPLACE)
                    .setField(WorkOrder.AccountId, storeMarketplaceAccountId)
                    .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
                    .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
                    .setField(WorkOrder.Menu_to_be_Completed_By__c, MENU_COMPLETED_BY)
                    .setField(WorkOrder.Vertical__c, VERTICAL)
                    .setField(WorkOrder.Id, marketplaceChildWorkOrderId)
                    .setParent(
                        'Account',
                        new Fake(Account.class)
                            .setField(Account.Id, storeMarketplaceAccountId)
                            .setField(Account.Name, STORE_ACCOUNT_NAME)
                            .setField(Account.RecordTypeId, ACCOUNT_STORE_RECORD_TYPE_ID)
                            .setField(Account.BillingStreet, ACCOUNT_BILLING_STREET)
                            .setField(Account.Partnership_Status__c, ACCOUNT_PARTNERSHIP_STATUS)
                            .setField(Account.ParentId, businessAccountId)
                    )
            )
            .toSObject();
        WorkPlan childWorkPlan2 = (WorkPlan) new Fake(WorkPlan.class)
            .setField(WorkPlan.Id, childWorkPlanId)
            .setField(WorkPlan.Status__c, WORK_PLAN_STATUS_NOT_STARTED)
            .setField(WorkPlan.Name, WORK_PLAN_NAME)
            .setField(WorkPlan.ParentRecordId, storeStorefrontAccountId)
            .setField(WorkPlan.WorkOrderId, storeStorefrontAccountId)
            .setField(WorkPlan.Parent_Work_Plan__c, parentWorkPlan.Id)
            .setParent(
                'WorkOrder',
                new Fake(WorkOrder.class)
                    .setField(WorkOrder.Status, STATUS_CONFIRMED)
                    .setField(WorkOrder.Type__c, TYPE_STOREFRONT)
                    .setField(WorkOrder.AccountId, storeStorefrontAccountId)
                    .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
                    .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
                    .setField(WorkOrder.Menu_to_be_Completed_By__c, MENU_COMPLETED_BY)
                    .setField(WorkOrder.Vertical__c, VERTICAL)
                    .setField(WorkOrder.Id, storefrontChildWorkOrderId)
                    .setParent(
                        'Account',
                        new Fake(Account.class)
                            .setField(Account.Id, storeStorefrontAccountId)
                            .setField(Account.Name, STORE_ACCOUNT_NAME)
                            .setField(Account.RecordTypeId, ACCOUNT_STORE_RECORD_TYPE_ID)
                            .setField(Account.BillingStreet, ACCOUNT_BILLING_STREET)
                            .setField(Account.Partnership_Status__c, ACCOUNT_PARTNERSHIP_STATUS)
                            .setField(Account.ParentId, businessAccountId)
                    )
            )
            .toSObject();
        Contact contactDetail = (Contact) new Fake(Contact.class)
            .setField(Contact.Id, contactId)
            .setField(Contact.Firstname, CONTACT_FIRST_NAME)
            .setField(Contact.LastName, CONTACT_LAST_NAME)
            .setField(Contact.Email, CONTACT_EMAIL)
            .setField(Contact.SSN_Last_4Digits__c, CONTACT_SSN)
            .setField(Contact.Phone, CONTACT_PHONE)
            .setField(Contact.AccountId, storeMarketplaceAccountId)
            .toSObject();
        Contact storeFrontcontactDetail = (Contact) new Fake(Contact.class)
            .setField(Contact.Id, storeFrontContactId)
            .setField(Contact.Firstname, CONTACT_FIRST_NAME)
            .setField(Contact.LastName, CONTACT_LAST_NAME)
            .setField(Contact.Email, CONTACT_EMAIL)
            .setField(Contact.SSN_Last_4Digits__c, CONTACT_SSN)
            .setField(Contact.Phone, CONTACT_PHONE)
            .setField(Contact.AccountId, storeStorefrontAccountId)
            .toSObject();
        AccountContactRelation accountContactDetails = (AccountContactRelation) new Fake(
                AccountContactRelation.class
            )
            .setField(AccountContactRelation.Id, AccountContactId)
            .setField(AccountContactRelation.AccountId, storeMarketplaceAccountId)
            .setField(AccountContactRelation.ContactId, contactDetail.Id)
            .setField(AccountContactRelation.Roles, ROLE)
            .toSObject();
        AccountContactRelation storeFrontAccountContactDetails = (AccountContactRelation) new Fake(
                AccountContactRelation.class
            )
            .setField(AccountContactRelation.Id, storeFrontAccountContactId)
            .setField(AccountContactRelation.AccountId, storeStorefrontAccountId)
            .setField(AccountContactRelation.ContactId, storeFrontcontactDetail.Id)
            .setField(AccountContactRelation.Roles, ROLE)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkPlansSelector workPlansSelector = (IWorkPlansSelector) mocks.mock(
            IWorkPlansSelector.class
        );
        IAccountContactRelationsSelector accountContactSelector = (IAccountContactRelationsSelector) mocks.mock(
            IAccountContactRelationsSelector.class
        );
        mocks.startStubbing();
        mocks.when(workPlansSelector.sObjectType()).thenReturn(WorkPlan.SObjectType);
        mocks.when(
                workPlansSelector.selectWorkPlansWithWorkOrderDetailsByParentWorkPlanIds(
                    new Set<Id>{ workPlanId }
                )
            )
            .thenReturn(new List<WorkPlan>{ childWorkPlan, childWorkPlan2 });
        mocks.when(accountContactSelector.sObjectType())
            .thenReturn(AccountContactRelation.SObjectType);
        mocks.when(
                accountContactSelector.selectByAccountIds(
                    new Set<Id>{ storeStorefrontAccountId, storeMarketplaceAccountId }
                )
            )
            .thenReturn(
                new List<AccountContactRelation>{
                    accountContactDetails,
                    storeFrontAccountContactDetails
                }
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(workPlansSelector);
        Application.SELECTOR.setMock(accountContactSelector);
        Test.startTest();
        ShowDecisionMakersOnWorkPlanService.getDecisionMakerPhoneDetails(workPlanId);
        Test.stopTest();
        System.assertEquals(WORK_PLAN_NAME, childWorkPlan.Name, ASSERT_MESSAGE_WORK_PLAN_NAME);
    }

    /**
     * @description To test child workplan field update associated with Store Account
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenUpdateNumberOfCallAttemptsOnWorkPlanCalledThenUpdateWorkPlan() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id childWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id marketplaceChildWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id storeMarketplaceAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);

        DecisionMakerWrapper.DecisionMakerDetails decisionMakerInstance = new DecisionMakerWrapper.DecisionMakerDetails(
            '',
            '',
            '',
            NUMBER_OF_CALL_ATTEMPTS,
            childWorkPlanId,
            ''
        );
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
            .setField(WorkPlan.ParentRecordId, marketplaceChildWorkOrderId)
            .setField(WorkPlan.WorkOrderId, marketplaceChildWorkOrderId)
            .setField(WorkPlan.Number_of_Call_Attempts__c, NUMBER_OF_CALL_ATTEMPTS)
            .setField(WorkPlan.Parent_Work_Plan__c, parentWorkPlan.Id)
            .setParent(
                'WorkOrder',
                new Fake(WorkOrder.class)
                    .setField(WorkOrder.Status, STATUS_CONFIRMED)
                    .setField(WorkOrder.Type__c, TYPE_MARKETPLACE)
                    .setField(WorkOrder.AccountId, storeMarketplaceAccountId)
                    .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
                    .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
                    .setField(WorkOrder.Menu_to_be_Completed_By__c, MENU_COMPLETED_BY)
                    .setField(WorkOrder.Vertical__c, VERTICAL)
                    .setField(WorkOrder.Id, marketplaceChildWorkOrderId)
                    .setParent(
                        'Account',
                        new Fake(Account.class)
                            .setField(Account.Id, storeMarketplaceAccountId)
                            .setField(Account.Name, STORE_ACCOUNT_NAME)
                            .setField(Account.RecordTypeId, ACCOUNT_STORE_RECORD_TYPE_ID)
                            .setField(Account.BillingStreet, ACCOUNT_BILLING_STREET)
                            .setField(Account.Partnership_Status__c, ACCOUNT_PARTNERSHIP_STATUS)
                            .setField(Account.ParentId, businessAccountId)
                    )
            )
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );
        IWorkPlansSelector workPlansSelector = (IWorkPlansSelector) mocks.mock(
            IWorkPlansSelector.class
        );
        mocks.startStubbing();
        mocks.when(workPlansSelector.sObjectType()).thenReturn(WorkPlan.SObjectType);
        mocks.when(workPlansSelector.selectById(new Set<Id>{ childWorkPlanId }))
            .thenReturn(new List<WorkPlan>{ childWorkPlan });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(workPlansSelector);
        Application.UNITOFWORK.setMock(uowMock);
        ShowDecisionMakersOnWorkPlanService.updateNumberOfCallAttemptsOnWorkPlan(
            JSON.serialize(
                new List<DecisionMakerWrapper.DecisionMakerDetails>{ decisionMakerInstance }
            )
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1))
            .registerDirty(new List<WorkPlan>{ childWorkPlan });
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
    }
}