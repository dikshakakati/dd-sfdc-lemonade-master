/**
* @author Aethereus
* @date 05-27-2024
* @description This is a test class created for ActivityTrackerComponentController class.
*/
@isTest(SeeAllData=false)
private class ActivityTrackerComponentControllerTest {

	private static final String WORK_ORDER_TYPE_DRIVE = 'Drive';
    private static final String STATUS_NOT_STARTED = 'Not Started';
    private static final String MARKETPLACE = 'Marketplace';
    private static final String WORK_ORDER_STATUS = 'Pending';
    private static final String WORK_STEP_STATUS = 'Blocked';
    private static final String VERTICAL = 'Floral';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ELIGIBLE_COUNTRY_TO_VALIDATE_AU = 'AU';
    private static final String ELIGIBLE_STATE_TO_VALIDATE_QLD = 'QLD';
    private static final String WORK_PLAN_TYPE_ONBOARDING = 'Onboarding';


     @IsTest
    static void testWhenFetchActivityDetailsPassedWithWorkPlanIdThenReturnMapWrapper(){

        Id businessAccountId = Fake.generateId(Account.class);
        Id storeAccountId = Fake.generateId(Account.class);
        Id opportunityId = Fake.generateId(Opportunity.class);
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);

        Fake parentWorkOrderFakeInstance = new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, workOrderId)
            .setField(WorkOrder.Type__c, MARKETPLACE)
            .setField(WorkOrder.Status, WORK_ORDER_STATUS)
            .setField(WorkOrder.AccountId, businessAccountId)
            .setField(WorkOrder.Opportunity__c, opportunityId);

        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );

        List<WorkOrder> childWorkOrders = new List<WorkOrder>{
            new WorkOrder(
                Id = Fake.generateId(WorkOrder.class),
                Type__c = MARKETPLACE,
                Status = WORK_ORDER_STATUS,
                AccountId = storeAccountId,
                ParentWorkOrder = parentWorkOrder,
                Opportunity__c = opportunityId,
                ParentWorkOrderId = parentWorkOrder.Id
            )
        };

         WorkPlan[] parentWorkPlan = new List<WorkPlan>{
            (WorkPlan) new Fake(WorkPlan.class)
                .setField(WorkPlan.Id, parentWorkPlanId)
                .setField(WorkPlan.Name, WORK_ORDER_TYPE_DRIVE)
                .setField(WorkPlan.Status__c, STATUS_NOT_STARTED)
                .setField(WorkPlan.WorkOrderId,workOrderId )
                .setField(WorkPlan.Parent_Work_Plan__c, NULL)
                .setField(WorkPlan.Type__c,WORK_PLAN_TYPE_ONBOARDING )
            	.setField(WorkPlan.ParentRecordId, childWorkOrders[0].id)
                .setParent('WorkOrder', parentWorkOrderFakeInstance)
                .setFakeId()
                .toSObject()
        };

        WorkPlan[] childWorkPlans = new List<WorkPlan>{
            (WorkPlan) new Fake(WorkPlan.class)
                .setField(WorkPlan.Name, WORK_ORDER_TYPE_DRIVE)
                .setField(WorkPlan.Status__c, STATUS_NOT_STARTED)
                .setField(WorkPlan.WorkOrderId,childWorkOrders[0].id )
                .setField(WorkPlan.Parent_Work_Plan__c, parentWorkPlanId)
            	.setField(WorkPlan.ParentRecordId, childWorkOrders[0].id)
                .setField(WorkPlan.Type__c,WORK_PLAN_TYPE_ONBOARDING )
                .setParent('WorkOrder', parentWorkOrderFakeInstance)
                .setFakeId()
                .toSObject()
        };
       Account fakeStoreAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, storeAccountId)
            .setField(Account.Name, 'Fake 1')
            .toSObject();

        EmailMessage fakeEmailMessage = (EmailMessage) new Fake(EmailMessage.class)
            .setField(EmailMessage.RelatedToId, childWorkPlans[0].Id)
            .setField(EmailMessage.Subject, 'Fake 1')
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkPlansSelector workPlanSelectorMock = (IWorkPlansSelector) mocks.mock(IWorkPlansSelector.class);

        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );

        IEmailMessagesSelector emailMessageSelectorMock = (IEmailMessagesSelector) mocks.mock(
            IEmailMessagesSelector.class
        );
        mocks.startStubbing();

        mocks.when(workPlanSelectorMock.sObjectType()).thenReturn(WorkPlan.SObjectType);
        mocks.when(workPlanSelectorMock.selectByWorkPlanIds(new Set<Id>{parentWorkPlanId}))
            .thenReturn( parentWorkPlan );
        mocks.when(workPlanSelectorMock.selectWorkPlansByParentWorkPlanAndStoreAccount(new Set<Id>{storeAccountId},new Set<String>{WORK_PLAN_TYPE_ONBOARDING},parentWorkPlanId ))
            .thenReturn( childWorkPlans );

        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountSelectorMock.selectStoreAccountsByParentId( businessAccountId ))
            .thenReturn(new List<Account>{fakeStoreAccount});

        mocks.when(emailMessageSelectorMock.sObjectType()).thenReturn(EmailMessage.SObjectType);
        mocks.when(emailMessageSelectorMock.selectEmailMessagesByRelatedId(new Set<Id>{childWorkPlans[0].Id}))
            .thenReturn(new List<EmailMessage>{fakeEmailMessage});

        mocks.stopStubbing();
        Application.SELECTOR.setMock(workPlanSelectorMock);
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(emailMessageSelectorMock);

        Test.StartTest();
        List<ActivityTrackerComponentController.EmailMessageDetails> wrapper = ActivityTrackerComponentController.fetchActivityDetails(parentWorkPlanId);
        Test.StopTest();
        System.assertEquals(1, wrapper[0].emailMessages.size(), 'Unexpected size of contractDataTableMap');
    }

    @IsTest
    static void testWhenUpdateEmailMessageToOpenedThenReturnBooleanFlag(){
        EmailMessage fakeEmailMessage = new EmailMessage();
        fakeEmailMessage.Is_Message_Seen__c = false;
        fakeEmailMessage.Subject = 'Fake 1';
        insert fakeEmailMessage;

        Test.StartTest();
        Boolean flag = ActivityTrackerComponentController.updateEmailMessageToOpened(fakeEmailMessage.Id);
        Test.StopTest();
        System.assertEquals(true, flag, 'Unexpected error');
    }
}