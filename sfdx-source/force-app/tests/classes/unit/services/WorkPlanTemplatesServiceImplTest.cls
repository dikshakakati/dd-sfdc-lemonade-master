/**
 * @author Deloitte
 * @date 05/02/2022
 * @description Test class for WorkPlanTemplatesServiceImpl class.
 * Suppressed Warnings since mock verify method does not require System Assert statements.
 */
@isTest(seeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class WorkPlanTemplatesServiceImplTest {
    private static final String ACCOUNT_ACTIVATION_STATUS_ACTIVE = 'Active';
    private static final String ACCOUNT_BILLING_STREET = '221B Baker Street';
    private static final String ACCOUNT_NAME = 'Test Account';
    private static final String ACCOUNT_STORE_NAME = 'Test Store Account';
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final String ACCOUNT_STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get(ACCOUNT_RECORD_TYPE_NAME_STORE)
        .getRecordTypeId();
    private static final String BUNDLED_WITH_MARKETPLACE_YES = 'Yes';
    private static final String STATUS_CONFIRMED = 'Confirmed';
    private static final String STATUS_NOT_STARTED = 'Not Started';
    private static final String STATUS_NOT_WORKABLE = 'Not Workable';
    private static final String STOREFRONT_BUNDLED = 'Storefront Bundled';
    private static final String TYPE_DRIVE = 'Drive';
    private static final String TYPE_STOREFRONT = 'Storefront';
    private static final String VERTICAL = 'Floral';
    private static final Integer WORK_PLAN_TEMPLATE_RELATIVE_EXECUTION_ORDER = 1;

    /**
     * @description To test creation of Work Plans on insert of Work Orders.
     */
    @isTest
    private static void testWhenWorkOrderIsInsertedThenCreateRelatedWorkPlans() {
        List<WorkPlanTemplate> workPlanTemplateRecords = new List<WorkPlanTemplate>();
        WorkPlanTemplate mockWorkPlanTemplate = new WorkPlanTemplate(
            Id = fflib_IDGenerator.generate(WorkPlanTemplate.SObjectType),
            Name = TYPE_DRIVE,
            Type__c = TYPE_DRIVE,
            IsActive = true,
            Work_Plan_Default_Status__c = STATUS_NOT_STARTED,
            RelativeExecutionOrder = WORK_PLAN_TEMPLATE_RELATIVE_EXECUTION_ORDER
        );
        workPlanTemplateRecords.add(mockWorkPlanTemplate);
        Account parentAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            Name = ACCOUNT_NAME,
            Primary_Vertical__c = VERTICAL
        );
        WorkOrder mockWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Status, STATUS_CONFIRMED)
            .setField(WorkOrder.Type__c, TYPE_DRIVE)
            .setField(WorkOrder.AccountId, parentAccount.Id)
            .setField(
                WorkOrder.ParentWorkOrderId,
                fflib_IDGenerator.generate(WorkOrder.SObjectType)
            )
            .setFakeId()
            .toSObject();
        WorkPlan newWorkPlan = new WorkPlan(
            Name = mockWorkPlanTemplate.Name,
            Work_Plan_Template__c = mockWorkPlanTemplate.Id,
            Status__c = mockWorkPlanTemplate.Work_Plan_Default_Status__c,
            ParentRecordId = mockWorkOrder.Id,
            Parent_Work_Plan__c = null,
            Type__c = mockWorkPlanTemplate.Type__c,
            WorkOrderId = mockWorkOrder.Id,
            ExecutionOrder = mockWorkPlanTemplate.RelativeExecutionOrder
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkPlanTemplatesSelector mockWorkPlanTemplatesSelector = (WorkPlanTemplatesSelector) mocks.mock(
            WorkPlanTemplatesSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkPlansMapperService mockWorkPlansMapperService = (IWorkPlansMapperService) mocks.mock(
            IWorkPlansMapperService.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkPlanTemplatesSelector.sObjectType())
            .thenReturn(WorkPlanTemplate.SObjectType);
        mocks.when(
                mockWorkPlanTemplatesSelector.selectByType(new Set<String>{ newWorkPlan.Type__c })
            )
            .thenReturn(workPlanTemplateRecords);
        mocks.when(
                mockWorkPlansMapperService.collectMatchingWorkPlanTypes(
                    new List<String>{ mockWorkOrder.ParentWorkOrderId }
                )
            )
            .thenReturn(
                new Map<Id, Set<String>>{ mockWorkOrder.ParentWorkOrderId => new Set<String>{} }
            );
        mocks.when(
                mockWorkPlansMapperService.collectMatchingWorkPlanTypes(
                    new List<String>{ mockWorkOrder.Id }
                )
            )
            .thenReturn(
                new Map<Id, Set<String>>{
                    mockWorkOrder.Id => new Set<String>{ newWorkPlan.Type__c }
                }
            );
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkPlanTemplatesSelector);
        Application.SERVICE.setMock(IWorkPlansMapperService.class, mockWorkPlansMapperService);
        WorkPlanTemplatesService.createWorkPlansOnWorkOrdersByMatchingCriteria(
            new List<WorkOrder>{ mockWorkOrder }
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew(new List<WorkPlan>{ newWorkPlan });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test creation of Work Plans on insert of child Work Orders.
     */
    @isTest
    private static void testWhenChildWorkOrderInsertedThenCreateRelatedWorkPlans() {
        List<WorkPlanTemplate> workPlanTemplateRecords = new List<WorkPlanTemplate>();
        WorkPlanTemplate mockWorkPlanTemplate = new WorkPlanTemplate(
            Id = fflib_IDGenerator.generate(WorkPlanTemplate.SObjectType),
            Name = TYPE_DRIVE,
            Type__c = TYPE_DRIVE,
            IsActive = true,
            Work_Plan_Default_Status__c = STATUS_NOT_STARTED,
            RelativeExecutionOrder = WORK_PLAN_TEMPLATE_RELATIVE_EXECUTION_ORDER
        );
        workPlanTemplateRecords.add(mockWorkPlanTemplate);
        Account parentAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            Name = ACCOUNT_NAME,
            Primary_Vertical__c = VERTICAL
        );
        Account storeAccount = (Account) new Fake(Account.class)
            .setField(Account.Name, ACCOUNT_STORE_NAME)
            .setField(Account.Primary_Vertical__c, VERTICAL)
            .setField(Account.RecordTypeId, ACCOUNT_STORE_RECORD_TYPE_ID)
            .setFakeId()
            .toSObject();
        Fake parentWorkOrderFakeInstance = new Fake(WorkOrder.class)
            .setField(WorkOrder.Status, STATUS_CONFIRMED)
            .setField(WorkOrder.Type__c, TYPE_DRIVE)
            .setField(WorkOrder.AccountId, parentAccount.Id)
            .setFakeId();
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        WorkPlan parentWorkPlan = new WorkPlan(
            Name = mockWorkPlanTemplate.Name,
            Work_Plan_Template__c = mockWorkPlanTemplate.Id,
            Status__c = mockWorkPlanTemplate.Work_Plan_Default_Status__c,
            ParentRecordId = parentWorkOrder.Id,
            Parent_Work_Plan__c = null,
            WorkOrderId = parentWorkOrder.Id,
            Type__c = mockWorkPlanTemplate.Type__c,
            ExecutionOrder = mockWorkPlanTemplate.RelativeExecutionOrder
        );
        WorkOrder childWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Status, STATUS_CONFIRMED)
            .setField(WorkOrder.Type__c, TYPE_DRIVE)
            .setField(WorkOrder.AccountId, storeAccount.Id)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance)
            .setFakeId()
            .toSObject();
        WorkPlan childWorkPlan = new WorkPlan(
            Name = mockWorkPlanTemplate.Name,
            Work_Plan_Template__c = mockWorkPlanTemplate.Id,
            Status__c = mockWorkPlanTemplate.Work_Plan_Default_Status__c,
            ParentRecordId = childWorkOrder.Id,
            Parent_Work_Plan__c = parentWorkPlan.Id,
            WorkOrderId = childWorkOrder.Id,
            Type__c = mockWorkPlanTemplate.Type__c,
            ExecutionOrder = mockWorkPlanTemplate.RelativeExecutionOrder
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkPlansSelector mockWorkPlansSelector = (WorkPlansSelector) mocks.mock(
            WorkPlansSelector.class
        );
        WorkPlanTemplatesSelector mockWorkPlanTemplatesSelector = (WorkPlanTemplatesSelector) mocks.mock(
            WorkPlanTemplatesSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkPlansMapperService mockWorkPlansMapperService = (IWorkPlansMapperService) mocks.mock(
            IWorkPlansMapperService.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkPlansSelector.sObjectType()).thenReturn(WorkPlan.SObjectType);
        mocks.when(
                mockWorkPlansSelector.selectWorkPlansByWorkOrderIds(
                    new Set<Id>{ childWorkOrder.ParentWorkOrderId }
                )
            )
            .thenReturn(new List<WorkPlan>{ parentWorkPlan });
        mocks.when(mockWorkPlansSelector.selectWorkPlansByWorkOrderIds(new Set<Id>()))
            .thenReturn(new List<WorkPlan>());
        mocks.when(mockWorkPlanTemplatesSelector.sObjectType())
            .thenReturn(WorkPlanTemplate.SObjectType);
        mocks.when(
                mockWorkPlanTemplatesSelector.selectByType(
                    new Set<String>{ parentWorkPlan.Type__c }
                )
            )
            .thenReturn(workPlanTemplateRecords);
        mocks.when(
                mockWorkPlanTemplatesSelector.selectByType(new Set<String>{ childWorkPlan.Type__c })
            )
            .thenReturn(workPlanTemplateRecords);
        mocks.when(
                mockWorkPlansMapperService.collectMatchingWorkPlanTypes(
                    new List<String>{ parentWorkOrder.Id }
                )
            )
            .thenReturn(
                new Map<Id, Set<String>>{
                    parentWorkOrder.Id => new Set<String>{ parentWorkPlan.Type__c }
                }
            );
        mocks.when(
                mockWorkPlansMapperService.collectMatchingWorkPlanTypes(
                    new List<String>{ childWorkOrder.Id }
                )
            )
            .thenReturn(
                new Map<Id, Set<String>>{
                    childWorkOrder.Id => new Set<String>{ childWorkPlan.Type__c }
                }
            );
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkPlansSelector);
        Application.SELECTOR.setMock(mockWorkPlanTemplatesSelector);
        Application.SERVICE.setMock(IWorkPlansMapperService.class, mockWorkPlansMapperService);
        WorkPlanTemplatesService.createWorkPlansOnWorkOrdersByMatchingCriteria(
            new List<WorkOrder>{ childWorkOrder }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2))
            .registerNew(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{ WorkPlan.Name => mockWorkPlanTemplate.Name }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
    }

    /**
     * @description To test creation of Storefront Bundled Work Plan in Not Started Status if Store Account is Active.
     */
    @isTest
    private static void testWhenWorkOrderIsInsertedForActiveStoreThenCreateStorefrontBundledWorkPlansWithNotStartedStatus() {
        WorkPlanTemplate storefrontBundledWorkPlanTemplate = new WorkPlanTemplate(
            Id = fflib_IDGenerator.generate(WorkPlanTemplate.SObjectType),
            IsActive = true,
            Name = STOREFRONT_BUNDLED,
            RelativeExecutionOrder = WORK_PLAN_TEMPLATE_RELATIVE_EXECUTION_ORDER,
            Type__c = TYPE_STOREFRONT,
            Work_Plan_Default_Status__c = STATUS_NOT_WORKABLE
        );
        Account parentAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            Activation_Status__c = ACCOUNT_ACTIVATION_STATUS_ACTIVE,
            BillingStreet = ACCOUNT_BILLING_STREET,
            Name = ACCOUNT_NAME,
            ParentId = fflib_IDGenerator.generate(Account.SObjectType),
            Primary_Vertical__c = VERTICAL,
            RecordTypeID = ACCOUNT_STORE_RECORD_TYPE_ID
        );
        WorkOrder mockWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.AccountId, parentAccount.Id)
            .setField(WorkOrder.Status, STATUS_CONFIRMED)
            .setField(WorkOrder.Bundled_with_Marketplace__c, BUNDLED_WITH_MARKETPLACE_YES)
            .setField(
                WorkOrder.Store_Account_Activation_Status__c,
                ACCOUNT_ACTIVATION_STATUS_ACTIVE
            )
            .setField(WorkOrder.Type__c, TYPE_STOREFRONT)
            .setField(WorkOrder.Vertical__c, VERTICAL)
            .setField(
                WorkOrder.ParentWorkOrderId,
                fflib_IDGenerator.generate(WorkOrder.SObjectType)
            )
            .setFakeId()
            .toSObject();
        WorkPlan newWorkPlan = new WorkPlan(
            ExecutionOrder = storefrontBundledWorkPlanTemplate.RelativeExecutionOrder,
            Name = storefrontBundledWorkPlanTemplate.Name,
            ParentRecordId = mockWorkOrder.Id,
            Parent_Work_Plan__c = null,
            Status__c = STATUS_NOT_STARTED,
            WorkOrderId = mockWorkOrder.Id,
            Type__c = storefrontBundledWorkPlanTemplate.Type__c,
            Work_Plan_Template__c = storefrontBundledWorkPlanTemplate.Id
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkPlanTemplatesSelector mockWorkPlanTemplatesSelector = (WorkPlanTemplatesSelector) mocks.mock(
            WorkPlanTemplatesSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkPlansMapperService mockWorkPlansMapperService = (IWorkPlansMapperService) mocks.mock(
            IWorkPlansMapperService.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkPlanTemplatesSelector.sObjectType())
            .thenReturn(WorkPlanTemplate.SObjectType);
        mocks.when(
                mockWorkPlanTemplatesSelector.selectByType(new Set<String>{ newWorkPlan.Type__c })
            )
            .thenReturn(new List<WorkPlanTemplate>{ storefrontBundledWorkPlanTemplate });
        mocks.when(
                mockWorkPlansMapperService.collectMatchingWorkPlanTypes(
                    new List<String>{ mockWorkOrder.ParentWorkOrderId }
                )
            )
            .thenReturn(
                new Map<Id, Set<String>>{ mockWorkOrder.ParentWorkOrderId => new Set<String>{} }
            );
        mocks.when(
                mockWorkPlansMapperService.collectMatchingWorkPlanTypes(
                    new List<String>{ mockWorkOrder.Id }
                )
            )
            .thenReturn(
                new Map<Id, Set<String>>{
                    mockWorkOrder.Id => new Set<String>{ newWorkPlan.Type__c }
                }
            );
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkPlanTemplatesSelector);
        Application.SERVICE.setMock(IWorkPlansMapperService.class, mockWorkPlansMapperService);
        WorkPlanTemplatesService.createWorkPlansOnWorkOrdersByMatchingCriteria(
            new List<WorkOrder>{ mockWorkOrder }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew(new List<WorkPlan>{ newWorkPlan });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test creation of Work Plans when list of WorkOrders & map of WorkOrder Id
     * to WorkPlan types is passed.
     */
    @isTest
    private static void testWhenWorkOrderIsReevaluatedThenCreateRelatedWorkPlans() {
        List<WorkPlanTemplate> workPlanTemplateRecords = new List<WorkPlanTemplate>();
        WorkPlanTemplate mockWorkPlanTemplate = new WorkPlanTemplate(
            Id = fflib_IDGenerator.generate(WorkPlanTemplate.SObjectType),
            Name = TYPE_DRIVE,
            Type__c = TYPE_DRIVE,
            IsActive = true,
            Work_Plan_Default_Status__c = STATUS_NOT_STARTED,
            RelativeExecutionOrder = WORK_PLAN_TEMPLATE_RELATIVE_EXECUTION_ORDER
        );
        workPlanTemplateRecords.add(mockWorkPlanTemplate);
        Account parentAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            Name = ACCOUNT_NAME,
            Primary_Vertical__c = VERTICAL
        );
        WorkOrder mockWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Status, STATUS_CONFIRMED)
            .setField(WorkOrder.Type__c, TYPE_DRIVE)
            .setField(WorkOrder.AccountId, parentAccount.Id)
            .setFakeId()
            .toSObject();
        WorkPlan newWorkPlan = new WorkPlan(
            Name = mockWorkPlanTemplate.Name,
            Work_Plan_Template__c = mockWorkPlanTemplate.Id,
            Status__c = mockWorkPlanTemplate.Work_Plan_Default_Status__c,
            ParentRecordId = mockWorkOrder.Id,
            Parent_Work_Plan__c = null,
            Type__c = mockWorkPlanTemplate.Type__c,
            WorkOrderId = mockWorkOrder.Id,
            ExecutionOrder = mockWorkPlanTemplate.RelativeExecutionOrder
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkPlanTemplatesSelector mockWorkPlanTemplatesSelector = (WorkPlanTemplatesSelector) mocks.mock(
            WorkPlanTemplatesSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkPlansMapperService mockWorkPlansMapperService = (IWorkPlansMapperService) mocks.mock(
            IWorkPlansMapperService.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkPlanTemplatesSelector.sObjectType())
            .thenReturn(WorkPlanTemplate.SObjectType);
        mocks.when(
                mockWorkPlanTemplatesSelector.selectByType(new Set<String>{ newWorkPlan.Type__c })
            )
            .thenReturn(workPlanTemplateRecords);
        mocks.when(
                mockWorkPlansMapperService.collectMatchingWorkPlanTypes(
                    new List<String>{ mockWorkOrder.Id }
                )
            )
            .thenReturn(
                new Map<Id, Set<String>>{
                    mockWorkOrder.Id => new Set<String>{ newWorkPlan.Type__c }
                }
            );
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkPlanTemplatesSelector);
        Application.SERVICE.setMock(IWorkPlansMapperService.class, mockWorkPlansMapperService);
        WorkPlanTemplatesService.createWorkPlansOnWorkOrdersByReevaluatingCriteria(
            new List<WorkOrder>{ mockWorkOrder },
            new Map<Id, Set<String>>{
                mockWorkOrder.Id => new Set<String>{ mockWorkPlanTemplate.Name }
            }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew(new List<WorkPlan>{ newWorkPlan });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }
}