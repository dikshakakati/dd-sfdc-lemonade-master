/**
 * @author Deloitte
 * @date 01/03/2023
 * @description Test class for WorkStepsCreationServiceImpl class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class WorkStepsCreationServiceImplTest {
    private static final String ACCOUNT_BILLING_STREET = '221B Baker Street';
    private static final String ACCOUNT_PARTNERSHIP_STATUS = 'Prospective Partner';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ACCOUNT_BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get(ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
        .getRecordTypeId();
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final String ACCOUNT_STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get(ACCOUNT_RECORD_TYPE_NAME_STORE)
        .getRecordTypeId();
    private static final String ACTIVATE_CENTRALLY = 'Yes';
    private static final String ASSERT_MESSAGE = 'Unexpected result: WorkSteps list is null';
    private static final String COUNT_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: Argument count does not match';
    private static final String DRIVE_SUB_TYPE_PARTNERSHIP_CREATION = 'Partnership creation/update';
    private static final String EVENT_TOPIC_WORK_STEP_DEPENDENCIES_CREATE = 'WORK_STEP_DEPENDENCIES_CREATE';
    private static final Integer EXECUTION_ORDER_FIRST = 1;
    private static final String MENU_COMPLETED_BY = 'Account Owner';
    private static final String ORDER_PROTOCOL = 'Email';
    private static final String STATUS_CONFIRMED = 'Confirmed';
    private static final String STATUS_NOT_STARTED = 'Not Started';
    private static final String STORE_ACCOUNT_NAME = 'Test Account';
    private static final String TOPIC_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: Notifier event topic does not match';
    private static final String TYPE_DRIVE = 'Drive';
    private static final String TYPE_MARKETPLACE = 'Marketplace';
    private static final String TYPE_STOREFRONT = 'Storefront';
    private static final String VERTICAL = 'Floral';
    private static final String WORK_PLAN_NAME = 'Onboarding';
    private static final String WORK_PLAN_NAME_STOREFRONT = 'Storefront';
    private static final String WORK_STEP_NAME_REVIEW_AND_TRIAGE = 'Review & Triage';
    private static final String WORK_STEP_NAME_SETUP_STORE = 'Setup Store';

    /**
     * @description To test Work Steps creation for passed Work Plan
     * using passed WorkPlanTemplate Id.
     */
    @isTest
    private static void testWhenCreateWorkStepsOnWorkPlansCalledThenWorkStepsCreated() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workPlanTemplateId = fflib_IDGenerator.generate(WorkPlanTemplate.SObjectType);
        Id workStepTemplateId = fflib_IDGenerator.generate(WorkStepTemplate.SObjectType);
        Id dependeeWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id dependentWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id dependentWorkPlanTemplateEntryId = fflib_IDGenerator.generate(
            WorkPlanTemplateEntry.SObjectType
        );
        Id workStepDependencyTemplateId = fflib_IDGenerator.generate(
            WorkStepDependencyTemplate__c.SObjectType
        );
        Id dependeeWorkPlanTemplateEntryId = fflib_IDGenerator.generate(
            WorkPlanTemplateEntry.SObjectType
        );
        WorkOrder mockWorkStepWithParentWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.AccountId, storeAccountId)
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
            .setField(WorkOrder.Menu_to_be_Completed_By__c, MENU_COMPLETED_BY)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
            .setField(WorkOrder.Status, STATUS_CONFIRMED)
            .setField(WorkOrder.Type__c, TYPE_STOREFRONT)
            .setField(WorkOrder.Vertical__c, VERTICAL)
            .setChildren(
                'WorkSteps',
                new List<Fake>{
                    new Fake(WorkStep.class)
                        .setField(WorkStep.Id, dependeeWorkStepId)
                        .setField(WorkStep.Name, WORK_STEP_NAME_REVIEW_AND_TRIAGE)
                        .setField(WorkStep.WorkOrderId, workOrderId)
                        .setField(WorkStep.Type__c, WORK_STEP_NAME_REVIEW_AND_TRIAGE)
                        .setField(
                            WorkStep.WorkPlanTemplateEntry__c,
                            dependentWorkPlanTemplateEntryId
                        )
                        .setParent(
                            'WorkOrder',
                            new Fake(WorkOrder.class)
                                .setField(WorkOrder.Id, parentWorkOrderId)
                                .setField(WorkOrder.AccountId, storeAccountId)
                                .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
                                .setField(WorkOrder.Menu_to_be_Completed_By__c, MENU_COMPLETED_BY)
                                .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
                                .setField(WorkOrder.Status, STATUS_CONFIRMED)
                                .setField(WorkOrder.Type__c, TYPE_STOREFRONT)
                                .setField(WorkOrder.Vertical__c, VERTICAL)
                        ),
                    new Fake(WorkStep.class)
                        .setField(WorkStep.Id, dependentWorkStepId)
                        .setField(WorkStep.Name, WORK_STEP_NAME_SETUP_STORE)
                        .setField(WorkStep.WorkOrderId, workOrderId)
                        .setField(WorkStep.Type__c, WORK_STEP_NAME_SETUP_STORE)
                        .setField(
                            WorkStep.WorkPlanTemplateEntry__c,
                            dependentWorkPlanTemplateEntryId
                        )
                        .setParent(
                            'WorkOrder',
                            new Fake(WorkOrder.class)
                                .setField(WorkOrder.Id, parentWorkOrderId)
                                .setField(WorkOrder.AccountId, storeAccountId)
                                .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
                                .setField(WorkOrder.Menu_to_be_Completed_By__c, MENU_COMPLETED_BY)
                                .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
                                .setField(WorkOrder.Status, STATUS_CONFIRMED)
                                .setField(WorkOrder.Type__c, TYPE_STOREFRONT)
                                .setField(WorkOrder.Vertical__c, VERTICAL)
                        )
                }
            )
            .toSObject();
        WorkOrder mockWorkStepWithChildWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, workOrderId)
            .setField(WorkOrder.AccountId, storeAccountId)
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
            .setField(WorkOrder.Menu_to_be_Completed_By__c, MENU_COMPLETED_BY)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
            .setField(WorkOrder.Status, STATUS_CONFIRMED)
            .setField(WorkOrder.Type__c, TYPE_STOREFRONT)
            .setField(WorkOrder.Vertical__c, VERTICAL)
            .setChildren(
                'WorkSteps',
                new List<Fake>{
                    new Fake(WorkStep.class)
                        .setField(WorkStep.Id, dependeeWorkStepId)
                        .setField(WorkStep.Name, WORK_STEP_NAME_REVIEW_AND_TRIAGE)
                        .setField(WorkStep.WorkOrderId, workOrderId)
                        .setField(WorkStep.Type__c, WORK_STEP_NAME_REVIEW_AND_TRIAGE)
                        .setField(
                            WorkStep.WorkPlanTemplateEntry__c,
                            dependentWorkPlanTemplateEntryId
                        )
                        .setParent(
                            'WorkOrder',
                            new Fake(WorkOrder.class)
                                .setField(WorkOrder.Id, workOrderId)
                                .setField(WorkOrder.AccountId, storeAccountId)
                                .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
                                .setField(WorkOrder.Menu_to_be_Completed_By__c, MENU_COMPLETED_BY)
                                .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
                                .setField(WorkOrder.Status, STATUS_CONFIRMED)
                                .setField(WorkOrder.Type__c, TYPE_STOREFRONT)
                                .setField(WorkOrder.Vertical__c, VERTICAL)
                        ),
                    new Fake(WorkStep.class)
                        .setField(WorkStep.Id, dependentWorkStepId)
                        .setField(WorkStep.Name, WORK_STEP_NAME_SETUP_STORE)
                        .setField(WorkStep.WorkOrderId, workOrderId)
                        .setField(WorkStep.Type__c, WORK_STEP_NAME_SETUP_STORE)
                        .setField(
                            WorkStep.WorkPlanTemplateEntry__c,
                            dependentWorkPlanTemplateEntryId
                        )
                        .setParent(
                            'WorkOrder',
                            new Fake(WorkOrder.class)
                                .setField(WorkOrder.Id, workOrderId)
                                .setField(WorkOrder.AccountId, storeAccountId)
                                .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
                                .setField(WorkOrder.Menu_to_be_Completed_By__c, MENU_COMPLETED_BY)
                                .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
                                .setField(WorkOrder.Status, STATUS_CONFIRMED)
                                .setField(WorkOrder.Type__c, TYPE_STOREFRONT)
                                .setField(WorkOrder.Vertical__c, VERTICAL)
                        )
                }
            )
            .toSObject();
        WorkPlan mockWorkPlanWithWorkOrder = (WorkPlan) new Fake(WorkPlan.class)
            .setField(WorkPlan.Id, workPlanId)
            .setField(WorkPlan.Name, WORK_PLAN_NAME)
            .setField(WorkPlan.Status__c, STATUS_NOT_STARTED)
            .setField(WorkPlan.ParentRecordId, workOrderId)
            .setField(WorkPlan.WorkOrderId, workOrderId)
            .setField(WorkPlan.Work_Plan_Template__c, workPlanTemplateId)
            .setParent(
                'WorkOrder',
                new Fake(WorkOrder.class)
                    .setField(WorkOrder.Id, workOrderId)
                    .setField(WorkOrder.AccountId, storeAccountId)
                    .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
                    .setField(WorkOrder.Menu_to_be_Completed_By__c, MENU_COMPLETED_BY)
                    .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
                    .setField(WorkOrder.Status, STATUS_CONFIRMED)
                    .setField(WorkOrder.Type__c, TYPE_STOREFRONT)
                    .setField(WorkOrder.Vertical__c, VERTICAL)
                    .setField(WorkOrder.ParentWorkOrderId, parentWorkOrderId)
                    .setParent(
                        'Account',
                        new Fake(Account.class)
                            .setField(Account.Id, storeAccountId)
                            .setField(Account.BillingStreet, ACCOUNT_BILLING_STREET)
                            .setField(Account.Name, STORE_ACCOUNT_NAME)
                            .setField(Account.Partnership_Status__c, ACCOUNT_PARTNERSHIP_STATUS)
                            .setField(Account.ParentId, businessAccountId)
                            .setField(Account.RecordTypeId, ACCOUNT_STORE_RECORD_TYPE_ID)
                    )
            )
            .toSObject();
        WorkPlanTemplate mockWorkPlanTemplate = (WorkPlanTemplate) new Fake(WorkPlanTemplate.class)
            .setField(WorkPlanTemplate.Id, workPlanTemplateId)
            .setChildren(
                'WorkStepTemplates',
                new List<Fake>{
                    new Fake(WorkPlanTemplateEntry.class)
                        .setField(WorkPlanTemplateEntry.WorkPlanTemplateId, workPlanTemplateId)
                        .setField(WorkPlanTemplateEntry.WorkStepTemplateId, workStepTemplateId)
                        .setParent(
                            'WorkStepTemplate',
                            new Fake(WorkStepTemplate.class)
                                .setField(WorkStepTemplate.Id, workStepTemplateId)
                                .setField(WorkStepTemplate.Name, WORK_STEP_NAME_SETUP_STORE)
                                .setField(WorkStepTemplate.IsActive, true)
                        )
                }
            )
            .toSObject();
        WorkStepDependencyTemplate__c mockWorkStepDependencyTemplate = (WorkStepDependencyTemplate__c) new Fake(
                WorkStepDependencyTemplate__c.class
            )
            .setField(WorkStepDependencyTemplate__c.Id, workStepDependencyTemplateId)
            .setField(
                WorkStepDependencyTemplate__c.Dependee_Work_Plan_Template_Entry__c,
                dependeeWorkPlanTemplateEntryId
            )
            .setField(
                WorkStepDependencyTemplate__c.Dependent_Work_Plan_Template_Entry__c,
                dependentWorkPlanTemplateEntryId
            )
            .setField(WorkStepDependencyTemplate__c.Is_Active__c, true)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkPlansSelector mockWorkPlansSelector = (IWorkPlansSelector) mocks.mock(
            IWorkPlansSelector.class
        );
        IWorkPlanTemplatesSelector mockWorkPlanTemplatesSelector = (IWorkPlanTemplatesSelector) mocks.mock(
            IWorkPlanTemplatesSelector.class
        );
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        IWorkStepDependencyTemplatesSelector mockWorkStepDependencyTemplatesSelector = (IWorkStepDependencyTemplatesSelector) mocks.mock(
            IWorkStepDependencyTemplatesSelector.class
        );
        IGenericLogger genericLoggerService = (IGenericLogger) mocks.mock(GenericLoggerImpl.class);
        mocks.startStubbing();
        mocks.when(mockWorkPlansSelector.sObjectType()).thenReturn(WorkPlan.SObjectType);
        mocks.when(
                mockWorkPlansSelector.selectWorkPlansWithWorkOrderDetails(new Set<Id>{ workPlanId })
            )
            .thenReturn(new List<WorkPlan>{ mockWorkPlanWithWorkOrder });
        mocks.when(mockWorkPlanTemplatesSelector.sObjectType())
            .thenReturn(WorkPlanTemplate.SObjectType);
        mocks.when(
                mockWorkPlanTemplatesSelector.selectWorkPlanTemplatesWithWorkPlanTemplateEntries(
                    new Set<Id>{ workPlanTemplateId }
                )
            )
            .thenReturn(new List<WorkPlanTemplate>{ mockWorkPlanTemplate });
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                mockWorkStepsSelector.selectWorkStepsByWorkOrderIds(
                    new Set<Id>{ parentWorkOrderId }
                )
            )
            .thenReturn(mockWorkStepWithParentWorkOrder.WorkSteps);
        mocks.when(mockWorkStepsSelector.selectWorkStepsByWorkOrderIds(new Set<Id>{ workOrderId }))
            .thenReturn(mockWorkStepWithChildWorkOrder.WorkSteps);
        mocks.when(mockWorkStepDependencyTemplatesSelector.sObjectType())
            .thenReturn(WorkStepDependencyTemplate__c.SObjectType);
        mocks.when(
                mockWorkStepDependencyTemplatesSelector.selectDependeeWorkStepDependencyTemplates(
                    new Set<Id>{ dependentWorkPlanTemplateEntryId }
                )
            )
            .thenReturn(new List<WorkStepDependencyTemplate__c>{ mockWorkStepDependencyTemplate });
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkPlansSelector);
        Application.SELECTOR.setMock(mockWorkPlanTemplatesSelector);
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Application.SELECTOR.setMock(mockWorkStepDependencyTemplatesSelector);
        Application.SERVICE.setMock(IGenericLogger.class,genericLoggerService);
        WorkStepsCreationService.createWorkStepsOnWorkPlans(
            new List<WorkPlan>{ mockWorkPlanWithWorkOrder },
            new Set<Id>{ workPlanTemplateId }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{ WorkStep.Name => WORK_STEP_NAME_SETUP_STORE }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 5)).commitWork();
    }

    /**
     * @description To test deletion of existing WorkStepsDependencies and creation of new
     * WorkStepDependencies and WorkSteps for the passed WorkPlan using passed WorkPlanTemplate Id.
     */
    @isTest
    private static void testWhenCreateWorkStepsOnWorkPlansCalledThenWorkStepsAndNewDependenciesCreatedAndExistingDependenciesDeleted() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workPlanTemplateId = fflib_IDGenerator.generate(WorkPlanTemplate.SObjectType);
        Id workStepTemplateId = fflib_IDGenerator.generate(WorkStepTemplate.SObjectType);
        Id dependeeWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id dependentWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id dependentWorkPlanTemplateEntryId = fflib_IDGenerator.generate(
            WorkPlanTemplateEntry.SObjectType
        );
        Id workStepDependencyTemplateId = fflib_IDGenerator.generate(
            WorkStepDependencyTemplate__c.SObjectType
        );
        Id dependeeWorkPlanTemplateEntryId = fflib_IDGenerator.generate(
            WorkPlanTemplateEntry.SObjectType
        );
        Id workStepDependencyId = fflib_IDGenerator.generate(WorkStepDependency__c.SObjectType);
        WorkOrder mockWorkStepWithParentWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.AccountId, storeAccountId)
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
            .setField(WorkOrder.Menu_to_be_Completed_By__c, MENU_COMPLETED_BY)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
            .setField(WorkOrder.Status, STATUS_CONFIRMED)
            .setField(WorkOrder.Type__c, TYPE_STOREFRONT)
            .setField(WorkOrder.Vertical__c, VERTICAL)
            .setChildren(
                'WorkSteps',
                new List<Fake>{
                    new Fake(WorkStep.class)
                        .setField(WorkStep.Id, dependeeWorkStepId)
                        .setField(WorkStep.Name, WORK_STEP_NAME_REVIEW_AND_TRIAGE)
                        .setField(WorkStep.WorkOrderId, workOrderId)
                        .setField(WorkStep.Type__c, WORK_STEP_NAME_REVIEW_AND_TRIAGE)
                        .setField(
                            WorkStep.WorkPlanTemplateEntry__c,
                            dependentWorkPlanTemplateEntryId
                        )
                        .setParent(
                            'WorkOrder',
                            new Fake(WorkOrder.class)
                                .setField(WorkOrder.Id, parentWorkOrderId)
                                .setField(WorkOrder.AccountId, storeAccountId)
                                .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
                                .setField(WorkOrder.Menu_to_be_Completed_By__c, MENU_COMPLETED_BY)
                                .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
                                .setField(WorkOrder.Status, STATUS_CONFIRMED)
                                .setField(WorkOrder.Type__c, TYPE_STOREFRONT)
                                .setField(WorkOrder.Vertical__c, VERTICAL)
                        ),
                    new Fake(WorkStep.class)
                        .setField(WorkStep.Id, dependentWorkStepId)
                        .setField(WorkStep.Name, WORK_STEP_NAME_SETUP_STORE)
                        .setField(WorkStep.WorkOrderId, workOrderId)
                        .setField(WorkStep.Type__c, WORK_STEP_NAME_SETUP_STORE)
                        .setField(
                            WorkStep.WorkPlanTemplateEntry__c,
                            dependentWorkPlanTemplateEntryId
                        )
                        .setParent(
                            'WorkOrder',
                            new Fake(WorkOrder.class)
                                .setField(WorkOrder.Id, parentWorkOrderId)
                                .setField(WorkOrder.AccountId, storeAccountId)
                                .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
                                .setField(WorkOrder.Menu_to_be_Completed_By__c, MENU_COMPLETED_BY)
                                .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
                                .setField(WorkOrder.Status, STATUS_CONFIRMED)
                                .setField(WorkOrder.Type__c, TYPE_STOREFRONT)
                                .setField(WorkOrder.Vertical__c, VERTICAL)
                        )
                }
            )
            .toSObject();
        WorkOrder mockWorkStepWithChildWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, workOrderId)
            .setField(WorkOrder.AccountId, storeAccountId)
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
            .setField(WorkOrder.Menu_to_be_Completed_By__c, MENU_COMPLETED_BY)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
            .setField(WorkOrder.Status, STATUS_CONFIRMED)
            .setField(WorkOrder.Type__c, TYPE_STOREFRONT)
            .setField(WorkOrder.Vertical__c, VERTICAL)
            .setChildren(
                'WorkSteps',
                new List<Fake>{
                    new Fake(WorkStep.class)
                        .setField(WorkStep.Id, dependeeWorkStepId)
                        .setField(WorkStep.Name, WORK_STEP_NAME_REVIEW_AND_TRIAGE)
                        .setField(WorkStep.WorkOrderId, workOrderId)
                        .setField(WorkStep.Type__c, WORK_STEP_NAME_REVIEW_AND_TRIAGE)
                        .setField(
                            WorkStep.WorkPlanTemplateEntry__c,
                            dependentWorkPlanTemplateEntryId
                        )
                        .setParent(
                            'WorkOrder',
                            new Fake(WorkOrder.class)
                                .setField(WorkOrder.Id, workOrderId)
                                .setField(WorkOrder.AccountId, storeAccountId)
                                .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
                                .setField(WorkOrder.Menu_to_be_Completed_By__c, MENU_COMPLETED_BY)
                                .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
                                .setField(WorkOrder.Status, STATUS_CONFIRMED)
                                .setField(WorkOrder.Type__c, TYPE_STOREFRONT)
                                .setField(WorkOrder.Vertical__c, VERTICAL)
                        ),
                    new Fake(WorkStep.class)
                        .setField(WorkStep.Id, dependentWorkStepId)
                        .setField(WorkStep.Name, WORK_STEP_NAME_SETUP_STORE)
                        .setField(WorkStep.WorkOrderId, workOrderId)
                        .setField(WorkStep.Type__c, WORK_STEP_NAME_SETUP_STORE)
                        .setField(
                            WorkStep.WorkPlanTemplateEntry__c,
                            dependentWorkPlanTemplateEntryId
                        )
                        .setParent(
                            'WorkOrder',
                            new Fake(WorkOrder.class)
                                .setField(WorkOrder.Id, workOrderId)
                                .setField(WorkOrder.AccountId, storeAccountId)
                                .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
                                .setField(WorkOrder.Menu_to_be_Completed_By__c, MENU_COMPLETED_BY)
                                .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
                                .setField(WorkOrder.Status, STATUS_CONFIRMED)
                                .setField(WorkOrder.Type__c, TYPE_STOREFRONT)
                                .setField(WorkOrder.Vertical__c, VERTICAL)
                        )
                }
            )
            .toSObject();
        WorkPlan mockWorkPlanWithWorkOrder = (WorkPlan) new Fake(WorkPlan.class)
            .setField(WorkPlan.Id, workPlanId)
            .setField(WorkPlan.Name, WORK_PLAN_NAME)
            .setField(WorkPlan.Status__c, STATUS_NOT_STARTED)
            .setField(WorkPlan.ParentRecordId, workOrderId)
            .setField(WorkPlan.WorkOrderId, workOrderId)
            .setField(WorkPlan.Work_Plan_Template__c, workPlanTemplateId)
            .setParent(
                'WorkOrder',
                new Fake(WorkOrder.class)
                    .setField(WorkOrder.Id, workOrderId)
                    .setField(WorkOrder.AccountId, storeAccountId)
                    .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
                    .setField(WorkOrder.Menu_to_be_Completed_By__c, MENU_COMPLETED_BY)
                    .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
                    .setField(WorkOrder.Status, STATUS_CONFIRMED)
                    .setField(WorkOrder.Type__c, TYPE_STOREFRONT)
                    .setField(WorkOrder.Vertical__c, VERTICAL)
                    .setField(WorkOrder.ParentWorkOrderId, parentWorkOrderId)
                    .setParent(
                        'Account',
                        new Fake(Account.class)
                            .setField(Account.Id, storeAccountId)
                            .setField(Account.BillingStreet, ACCOUNT_BILLING_STREET)
                            .setField(Account.Name, STORE_ACCOUNT_NAME)
                            .setField(Account.Partnership_Status__c, ACCOUNT_PARTNERSHIP_STATUS)
                            .setField(Account.ParentId, businessAccountId)
                            .setField(Account.RecordTypeId, ACCOUNT_STORE_RECORD_TYPE_ID)
                    )
            )
            .toSObject();
        WorkPlanTemplate mockWorkPlanTemplate = (WorkPlanTemplate) new Fake(WorkPlanTemplate.class)
            .setField(WorkPlanTemplate.Id, workPlanTemplateId)
            .setChildren(
                'WorkStepTemplates',
                new List<Fake>{
                    new Fake(WorkPlanTemplateEntry.class)
                        .setField(WorkPlanTemplateEntry.WorkPlanTemplateId, workPlanTemplateId)
                        .setField(WorkPlanTemplateEntry.WorkStepTemplateId, workStepTemplateId)
                        .setParent(
                            'WorkStepTemplate',
                            new Fake(WorkStepTemplate.class)
                                .setField(WorkStepTemplate.Id, workStepTemplateId)
                                .setField(WorkStepTemplate.Name, WORK_STEP_NAME_SETUP_STORE)
                                .setField(WorkStepTemplate.IsActive, true)
                        )
                }
            )
            .toSObject();
        WorkStepDependencyTemplate__c mockWorkStepDependencyTemplate = (WorkStepDependencyTemplate__c) new Fake(
                WorkStepDependencyTemplate__c.class
            )
            .setField(WorkStepDependencyTemplate__c.Id, workStepDependencyTemplateId)
            .setField(
                WorkStepDependencyTemplate__c.Dependee_Work_Plan_Template_Entry__c,
                dependeeWorkPlanTemplateEntryId
            )
            .setField(
                WorkStepDependencyTemplate__c.Dependent_Work_Plan_Template_Entry__c,
                dependentWorkPlanTemplateEntryId
            )
            .setField(WorkStepDependencyTemplate__c.Is_Active__c, true)
            .toSObject();
        WorkStepDependency__c mockWorkStepDependency = (WorkStepDependency__c) new Fake(
                WorkStepDependency__c.class
            )
            .setField(WorkStepDependency__c.Id, workStepDependencyId)
            .setField(WorkStepDependency__c.Dependee_Work_Step__c, dependeeWorkStepId)
            .setField(WorkStepDependency__c.Dependent_Work_Step__c, dependentWorkStepId)
            .setField(
                WorkStepDependency__c.Work_Step_Dependency_Template__c,
                workStepDependencyTemplateId
            )
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkPlansSelector mockWorkPlansSelector = (IWorkPlansSelector) mocks.mock(
            IWorkPlansSelector.class
        );
        IWorkPlanTemplatesSelector mockWorkPlanTemplatesSelector = (IWorkPlanTemplatesSelector) mocks.mock(
            IWorkPlanTemplatesSelector.class
        );
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        IWorkStepDependencyTemplatesSelector mockWorkStepDependencyTemplatesSelector = (IWorkStepDependencyTemplatesSelector) mocks.mock(
            IWorkStepDependencyTemplatesSelector.class
        );
        IWorkStepDependenciesSelector mockWorkStepDependenciesSelector = (IWorkStepDependenciesSelector) mocks.mock(
            IWorkStepDependenciesSelector.class
        );
        INotifierEventsService notifierEventService = (INotifierEventsService) mocks.mock(
            INotifierEventsService.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkPlansSelector.sObjectType()).thenReturn(WorkPlan.SObjectType);
        mocks.when(
                mockWorkPlansSelector.selectWorkPlansWithWorkOrderDetails(new Set<Id>{ workPlanId })
            )
            .thenReturn(new List<WorkPlan>{ mockWorkPlanWithWorkOrder });
        mocks.when(mockWorkPlanTemplatesSelector.sObjectType())
            .thenReturn(WorkPlanTemplate.SObjectType);
        mocks.when(
                mockWorkPlanTemplatesSelector.selectWorkPlanTemplatesWithWorkPlanTemplateEntries(
                    new Set<Id>{ workPlanTemplateId }
                )
            )
            .thenReturn(new List<WorkPlanTemplate>{ mockWorkPlanTemplate });
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                mockWorkStepsSelector.selectWorkStepsByWorkOrderIds(
                    new Set<Id>{ parentWorkOrderId }
                )
            )
            .thenReturn(mockWorkStepWithParentWorkOrder.WorkSteps);
        mocks.when(mockWorkStepsSelector.selectWorkStepsByWorkOrderIds(new Set<Id>{ workOrderId }))
            .thenReturn(mockWorkStepWithChildWorkOrder.WorkSteps);
        mocks.when(mockWorkStepDependencyTemplatesSelector.sObjectType())
            .thenReturn(WorkStepDependencyTemplate__c.SObjectType);
        mocks.when(
                mockWorkStepDependencyTemplatesSelector.selectDependeeWorkStepDependencyTemplates(
                    new Set<Id>{ dependentWorkPlanTemplateEntryId }
                )
            )
            .thenReturn(new List<WorkStepDependencyTemplate__c>{ mockWorkStepDependencyTemplate });
        mocks.when(mockWorkStepDependenciesSelector.sObjectType())
            .thenReturn(WorkStepDependency__c.SObjectType);
        mocks.when(
                mockWorkStepDependenciesSelector.selectDependenciesByWorkOrderIds(
                    new Set<Id>{ workOrderId }
                )
            )
            .thenReturn(new List<WorkStepDependency__c>{ mockWorkStepDependency });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkPlansSelector);
        Application.SELECTOR.setMock(mockWorkPlanTemplatesSelector);
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Application.SELECTOR.setMock(mockWorkStepDependencyTemplatesSelector);
        Application.SELECTOR.setMock(mockWorkStepDependenciesSelector);
        Application.SERVICE.setMock(INotifierEventsService.class, notifierEventService);
        WorkStepsCreationService.createWorkStepsOnWorkPlans(
            new List<WorkPlan>{ mockWorkPlanWithWorkOrder },
            new Set<Id>{ workPlanTemplateId }
        );
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            Map<String, List<String>>.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{ WorkStep.Name => WORK_STEP_NAME_SETUP_STORE }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((INotifierEventsService) mocks.verify(notifierEventService, 2))
            .publishBulkEvents((Map<String, List<String>>) capturedInsertUOWArguments.capture());
        Map<String, List<String>> capturedArguments = (Map<String, List<String>>) capturedInsertUOWArguments.getValue();
        System.assertEquals(1, capturedArguments.size(), COUNT_DO_NOT_MATCH_ASSERT_MESSAGE);
        System.assertEquals(
            new Set<String>{ EVENT_TOPIC_WORK_STEP_DEPENDENCIES_CREATE },
            capturedArguments.keySet(),
            TOPIC_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test WorkStep creation for parent WorkOrder with Type = Drive
     * when stores are not expected.
     */
    @isTest
    private static void testWhenDriveWorkPlanReceivedThenDriveWorkStepsCreated() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workPlanTemplateId = fflib_IDGenerator.generate(WorkPlanTemplate.SObjectType);
        Id workStepTemplateId = fflib_IDGenerator.generate(WorkStepTemplate.SObjectType);
        Id dependeeWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id dependentWorkPlanTemplateEntryId = fflib_IDGenerator.generate(
            WorkPlanTemplateEntry.SObjectType
        );
        WorkOrder mockWorkStepWithParentWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.AccountId, businessAccountId)
            .setField(WorkOrder.ParentWorkOrderId, null)
            .setField(WorkOrder.Status, STATUS_CONFIRMED)
            .setField(WorkOrder.Sub_Type__c, DRIVE_SUB_TYPE_PARTNERSHIP_CREATION)
            .setField(WorkOrder.Type__c, TYPE_DRIVE)
            .setChildren(
                'WorkSteps',
                new List<Fake>{
                    new Fake(WorkStep.class)
                        .setField(WorkStep.Id, dependeeWorkStepId)
                        .setField(WorkStep.Name, TYPE_DRIVE)
                        .setField(WorkStep.WorkOrderId, parentWorkOrderId)
                        .setField(WorkStep.Type__c, TYPE_DRIVE)
                        .setField(
                            WorkStep.WorkPlanTemplateEntry__c,
                            dependentWorkPlanTemplateEntryId
                        )
                        .setParent(
                            'WorkOrder',
                            new Fake(WorkOrder.class)
                                .setField(WorkOrder.Id, parentWorkOrderId)
                                .setField(WorkOrder.AccountId, businessAccountId)
                                .setField(WorkOrder.ParentWorkOrderId, null)
                                .setField(WorkOrder.Status, STATUS_CONFIRMED)
                                .setField(
                                    WorkOrder.Sub_Type__c,
                                    DRIVE_SUB_TYPE_PARTNERSHIP_CREATION
                                )
                                .setField(WorkOrder.Type__c, TYPE_DRIVE)
                        )
                }
            )
            .toSObject();
        WorkPlan mockWorkPlanWithWorkOrder = (WorkPlan) new Fake(WorkPlan.class)
            .setField(WorkPlan.Id, workPlanId)
            .setField(WorkPlan.Name, TYPE_DRIVE)
            .setField(WorkPlan.Status__c, STATUS_NOT_STARTED)
            .setField(WorkPlan.ParentRecordId, parentWorkOrderId)
            .setField(WorkPlan.WorkOrderId, parentWorkOrderId)
            .setField(WorkPlan.Work_Plan_Template__c, workPlanTemplateId)
            .setParent(
                'WorkOrder',
                new Fake(WorkOrder.class)
                    .setField(WorkOrder.Id, parentWorkOrderId)
                    .setField(WorkOrder.AccountId, businessAccountId)
                    .setField(WorkOrder.ParentWorkOrderId, null)
                    .setField(WorkOrder.Status, STATUS_CONFIRMED)
                    .setField(WorkOrder.Sub_Type__c, DRIVE_SUB_TYPE_PARTNERSHIP_CREATION)
                    .setField(WorkOrder.Type__c, TYPE_DRIVE)
                    .setParent(
                        'Account',
                        new Fake(Account.class)
                            .setField(Account.Id, businessAccountId)
                            .setField(Account.BillingStreet, ACCOUNT_BILLING_STREET)
                            .setField(Account.Name, STORE_ACCOUNT_NAME)
                            .setField(Account.RecordTypeId, ACCOUNT_BUSINESS_RECORD_TYPE_ID)
                    )
            )
            .toSObject();
        WorkPlanTemplate mockWorkPlanTemplate = (WorkPlanTemplate) new Fake(WorkPlanTemplate.class)
            .setField(WorkPlanTemplate.Id, workPlanTemplateId)
            .setChildren(
                'WorkStepTemplates',
                new List<Fake>{
                    new Fake(WorkPlanTemplateEntry.class)
                        .setField(WorkPlanTemplateEntry.WorkPlanTemplateId, workPlanTemplateId)
                        .setField(WorkPlanTemplateEntry.WorkStepTemplateId, workStepTemplateId)
                        .setParent(
                            'WorkStepTemplate',
                            new Fake(WorkStepTemplate.class)
                                .setField(WorkStepTemplate.Id, workStepTemplateId)
                                .setField(WorkStepTemplate.Name, TYPE_DRIVE)
                                .setField(WorkStepTemplate.IsActive, true)
                        )
                }
            )
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkPlansSelector mockWorkPlansSelector = (IWorkPlansSelector) mocks.mock(
            IWorkPlansSelector.class
        );
        IWorkPlanTemplatesSelector mockWorkPlanTemplatesSelector = (IWorkPlanTemplatesSelector) mocks.mock(
            IWorkPlanTemplatesSelector.class
        );
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        IWorkStepDependencyTemplatesSelector mockWorkStepDependencyTemplatesSelector = (IWorkStepDependencyTemplatesSelector) mocks.mock(
            IWorkStepDependencyTemplatesSelector.class
        );
        IWorkOrderSettingsService mockWorkOrderSettingsService = (IWorkOrderSettingsService) mocks.mock(
            IWorkOrderSettingsService.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkPlansSelector.sObjectType()).thenReturn(WorkPlan.SObjectType);
        mocks.when(
                mockWorkPlansSelector.selectWorkPlansWithWorkOrderDetails(new Set<Id>{ workPlanId })
            )
            .thenReturn(new List<WorkPlan>{ mockWorkPlanWithWorkOrder });
        mocks.when(mockWorkPlanTemplatesSelector.sObjectType())
            .thenReturn(WorkPlanTemplate.SObjectType);
        mocks.when(
                mockWorkPlanTemplatesSelector.selectWorkPlanTemplatesWithWorkPlanTemplateEntries(
                    new Set<Id>{ workPlanTemplateId }
                )
            )
            .thenReturn(new List<WorkPlanTemplate>{ mockWorkPlanTemplate });
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                mockWorkStepsSelector.selectWorkStepsByWorkOrderIds(
                    new Set<Id>{ parentWorkOrderId }
                )
            )
            .thenReturn(mockWorkStepWithParentWorkOrder.WorkSteps);
        mocks.when(mockWorkStepsSelector.selectWorkStepsByWorkOrderIds(new Set<Id>{}))
            .thenReturn(new List<WorkStep>{});
        mocks.when(mockWorkStepDependencyTemplatesSelector.sObjectType())
            .thenReturn(WorkStepDependencyTemplate__c.SObjectType);
        mocks.when(
                mockWorkStepDependencyTemplatesSelector.selectDependeeWorkStepDependencyTemplates(
                    new Set<Id>{}
                )
            )
            .thenReturn(new List<WorkStepDependencyTemplate__c>{});
        mocks.when(
                mockWorkOrderSettingsService.isProvisioningStatusNotificationEnabledOnParentWorkOrder(
                    mockWorkPlanWithWorkOrder.WorkOrder
                )
            )
            .thenReturn(true);
        mocks.when(
                mockWorkOrderSettingsService.isProvisioningStatusNotificationEnabledOnChildWorkOrder(
                    mockWorkPlanWithWorkOrder.WorkOrder
                )
            )
            .thenReturn(true);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkPlansSelector);
        Application.SELECTOR.setMock(mockWorkPlanTemplatesSelector);
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Application.SERVICE.setMock(IWorkOrderSettingsService.class, mockWorkOrderSettingsService);
        WorkStepsCreationService.createWorkStepsOnWorkPlans(
            new List<WorkPlan>{ mockWorkPlanWithWorkOrder },
            new Set<Id>{ workPlanTemplateId }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{ WorkStep.Name => TYPE_DRIVE }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 5)).commitWork();
    }

    /**
     * @description To test WorkStep creation for parent WorkOrder with Type = Marketplace
     * when stores are not expected.
     */
    @isTest
    private static void testWhenMarketplaceWorkPlanReceivedThenMarketplaceWorkStepsCreated() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workPlanTemplateId = fflib_IDGenerator.generate(WorkPlanTemplate.SObjectType);
        Id workStepTemplateId = fflib_IDGenerator.generate(WorkStepTemplate.SObjectType);
        Id dependeeWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id dependentWorkPlanTemplateEntryId = fflib_IDGenerator.generate(
            WorkPlanTemplateEntry.SObjectType
        );
        WorkOrder mockWorkStepWithParentWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.AccountId, businessAccountId)
            .setField(WorkOrder.ParentWorkOrderId, null)
            .setField(WorkOrder.Status, STATUS_CONFIRMED)
            .setField(WorkOrder.Type__c, TYPE_MARKETPLACE)
            .setChildren(
                'WorkSteps',
                new List<Fake>{
                    new Fake(WorkStep.class)
                        .setField(WorkStep.Id, dependeeWorkStepId)
                        .setField(WorkStep.Name, WORK_STEP_NAME_REVIEW_AND_TRIAGE)
                        .setField(WorkStep.WorkOrderId, parentWorkOrderId)
                        .setField(WorkStep.Type__c, WORK_STEP_NAME_REVIEW_AND_TRIAGE)
                        .setField(
                            WorkStep.WorkPlanTemplateEntry__c,
                            dependentWorkPlanTemplateEntryId
                        )
                        .setParent(
                            'WorkOrder',
                            new Fake(WorkOrder.class)
                                .setField(WorkOrder.Id, parentWorkOrderId)
                                .setField(WorkOrder.AccountId, businessAccountId)
                                .setField(WorkOrder.ParentWorkOrderId, null)
                                .setField(WorkOrder.Status, STATUS_CONFIRMED)
                                .setField(WorkOrder.Type__c, TYPE_MARKETPLACE)
                        )
                }
            )
            .toSObject();
        WorkPlan mockWorkPlanWithWorkOrder = (WorkPlan) new Fake(WorkPlan.class)
            .setField(WorkPlan.Id, workPlanId)
            .setField(WorkPlan.Name, WORK_PLAN_NAME)
            .setField(WorkPlan.Status__c, STATUS_NOT_STARTED)
            .setField(WorkPlan.ParentRecordId, parentWorkOrderId)
            .setField(WorkPlan.WorkOrderId, parentWorkOrderId)
            .setField(WorkPlan.Work_Plan_Template__c, workPlanTemplateId)
            .setParent(
                'WorkOrder',
                new Fake(WorkOrder.class)
                    .setField(WorkOrder.Id, parentWorkOrderId)
                    .setField(WorkOrder.AccountId, businessAccountId)
                    .setField(WorkOrder.ParentWorkOrderId, null)
                    .setField(WorkOrder.Status, STATUS_CONFIRMED)
                    .setField(WorkOrder.Type__c, TYPE_MARKETPLACE)
                    .setParent(
                        'Account',
                        new Fake(Account.class)
                            .setField(Account.Id, businessAccountId)
                            .setField(Account.BillingStreet, ACCOUNT_BILLING_STREET)
                            .setField(Account.Name, STORE_ACCOUNT_NAME)
                            .setField(Account.RecordTypeId, ACCOUNT_BUSINESS_RECORD_TYPE_ID)
                    )
            )
            .toSObject();
        WorkPlanTemplate mockWorkPlanTemplate = (WorkPlanTemplate) new Fake(WorkPlanTemplate.class)
            .setField(WorkPlanTemplate.Id, workPlanTemplateId)
            .setChildren(
                'WorkStepTemplates',
                new List<Fake>{
                    new Fake(WorkPlanTemplateEntry.class)
                        .setField(WorkPlanTemplateEntry.WorkPlanTemplateId, workPlanTemplateId)
                        .setField(WorkPlanTemplateEntry.WorkStepTemplateId, workStepTemplateId)
                        .setParent(
                            'WorkStepTemplate',
                            new Fake(WorkStepTemplate.class)
                                .setField(WorkStepTemplate.Id, workStepTemplateId)
                                .setField(WorkStepTemplate.Name, WORK_STEP_NAME_REVIEW_AND_TRIAGE)
                                .setField(WorkStepTemplate.IsActive, true)
                        )
                }
            )
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkPlansSelector mockWorkPlansSelector = (IWorkPlansSelector) mocks.mock(
            IWorkPlansSelector.class
        );
        IWorkPlanTemplatesSelector mockWorkPlanTemplatesSelector = (IWorkPlanTemplatesSelector) mocks.mock(
            IWorkPlanTemplatesSelector.class
        );
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        IWorkStepDependencyTemplatesSelector mockWorkStepDependencyTemplatesSelector = (IWorkStepDependencyTemplatesSelector) mocks.mock(
            IWorkStepDependencyTemplatesSelector.class
        );
        IWorkOrderSettingsService mockWorkOrderSettingsService = (IWorkOrderSettingsService) mocks.mock(
            IWorkOrderSettingsService.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkPlansSelector.sObjectType()).thenReturn(WorkPlan.SObjectType);
        mocks.when(
                mockWorkPlansSelector.selectWorkPlansWithWorkOrderDetails(new Set<Id>{ workPlanId })
            )
            .thenReturn(new List<WorkPlan>{ mockWorkPlanWithWorkOrder });
        mocks.when(mockWorkPlanTemplatesSelector.sObjectType())
            .thenReturn(WorkPlanTemplate.SObjectType);
        mocks.when(
                mockWorkPlanTemplatesSelector.selectWorkPlanTemplatesWithWorkPlanTemplateEntries(
                    new Set<Id>{ workPlanTemplateId }
                )
            )
            .thenReturn(new List<WorkPlanTemplate>{ mockWorkPlanTemplate });
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                mockWorkStepsSelector.selectWorkStepsByWorkOrderIds(
                    new Set<Id>{ parentWorkOrderId }
                )
            )
            .thenReturn(mockWorkStepWithParentWorkOrder.WorkSteps);
        mocks.when(mockWorkStepsSelector.selectWorkStepsByWorkOrderIds(new Set<Id>{}))
            .thenReturn(new List<WorkStep>{});
        mocks.when(mockWorkStepDependencyTemplatesSelector.sObjectType())
            .thenReturn(WorkStepDependencyTemplate__c.SObjectType);
        mocks.when(
                mockWorkStepDependencyTemplatesSelector.selectDependeeWorkStepDependencyTemplates(
                    new Set<Id>{}
                )
            )
            .thenReturn(new List<WorkStepDependencyTemplate__c>{});
        mocks.when(
                mockWorkOrderSettingsService.isProvisioningStatusNotificationEnabledOnParentWorkOrder(
                    mockWorkPlanWithWorkOrder.WorkOrder
                )
            )
            .thenReturn(false);
        mocks.when(
                mockWorkOrderSettingsService.isProvisioningStatusNotificationEnabledOnChildWorkOrder(
                    mockWorkPlanWithWorkOrder.WorkOrder
                )
            )
            .thenReturn(true);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkPlansSelector);
        Application.SELECTOR.setMock(mockWorkPlanTemplatesSelector);
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Application.SERVICE.setMock(IWorkOrderSettingsService.class, mockWorkOrderSettingsService);
        WorkStepsCreationService.createWorkStepsOnWorkPlans(
            new List<WorkPlan>{ mockWorkPlanWithWorkOrder },
            new Set<Id>{ workPlanTemplateId }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            WorkStep.Name => WORK_STEP_NAME_REVIEW_AND_TRIAGE
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 3)).commitWork();
    }

    /**
     * @description To test storefront WorkSteps creation for passed
     * WorkPlan using passed WorkPlanTemplate Id.
     */
    @isTest
    private static void testWhenCreateWorkStepsOnStorefrontWorkPlansCalledThenStorefrontWorkStepsAndDependenciesCreated() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workPlanTemplateId = fflib_IDGenerator.generate(WorkPlanTemplate.SObjectType);
        Id workStepTemplateId = fflib_IDGenerator.generate(WorkStepTemplate.SObjectType);
        Id dependeeWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id dependentWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id dependentWorkPlanTemplateEntryId = fflib_IDGenerator.generate(
            WorkPlanTemplateEntry.SObjectType
        );
        Id workStepDependencyTemplateId = fflib_IDGenerator.generate(
            WorkStepDependencyTemplate__c.SObjectType
        );
        Id dependeeWorkPlanTemplateEntryId = fflib_IDGenerator.generate(
            WorkPlanTemplateEntry.SObjectType
        );
        WorkOrder mockWorkStepWithParentWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.AccountId, storeAccountId)
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
            .setField(WorkOrder.Menu_to_be_Completed_By__c, MENU_COMPLETED_BY)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
            .setField(WorkOrder.Status, STATUS_CONFIRMED)
            .setField(WorkOrder.Type__c, TYPE_STOREFRONT)
            .setField(WorkOrder.Vertical__c, VERTICAL)
            .setChildren(
                'WorkSteps',
                new List<Fake>{
                    new Fake(WorkStep.class)
                        .setField(WorkStep.Id, dependeeWorkStepId)
                        .setField(WorkStep.Name, WORK_STEP_NAME_SETUP_STORE)
                        .setField(WorkStep.WorkOrderId, parentWorkOrderId)
                        .setField(WorkStep.Type__c, WORK_STEP_NAME_SETUP_STORE)
                        .setField(
                            WorkStep.WorkPlanTemplateEntry__c,
                            dependentWorkPlanTemplateEntryId
                        )
                        .setParent(
                            'WorkOrder',
                            new Fake(WorkOrder.class)
                                .setField(WorkOrder.Id, parentWorkOrderId)
                                .setField(WorkOrder.AccountId, storeAccountId)
                                .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
                                .setField(WorkOrder.Menu_to_be_Completed_By__c, MENU_COMPLETED_BY)
                                .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
                                .setField(WorkOrder.Status, STATUS_CONFIRMED)
                                .setField(WorkOrder.Type__c, TYPE_STOREFRONT)
                                .setField(WorkOrder.Vertical__c, VERTICAL)
                        ),
                    new Fake(WorkStep.class)
                        .setField(WorkStep.Id, dependentWorkStepId)
                        .setField(WorkStep.Name, WORK_STEP_NAME_SETUP_STORE)
                        .setField(WorkStep.WorkOrderId, parentWorkOrderId)
                        .setField(WorkStep.Type__c, WORK_STEP_NAME_SETUP_STORE)
                        .setField(
                            WorkStep.WorkPlanTemplateEntry__c,
                            dependentWorkPlanTemplateEntryId
                        )
                        .setParent(
                            'WorkOrder',
                            new Fake(WorkOrder.class)
                                .setField(WorkOrder.Id, parentWorkOrderId)
                                .setField(WorkOrder.AccountId, storeAccountId)
                                .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
                                .setField(WorkOrder.Menu_to_be_Completed_By__c, MENU_COMPLETED_BY)
                                .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
                                .setField(WorkOrder.Status, STATUS_CONFIRMED)
                                .setField(WorkOrder.Type__c, TYPE_STOREFRONT)
                                .setField(WorkOrder.Vertical__c, VERTICAL)
                        )
                }
            )
            .toSObject();
        WorkOrder mockWorkStepWithChildWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, workOrderId)
            .setField(WorkOrder.AccountId, storeAccountId)
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
            .setField(WorkOrder.Menu_to_be_Completed_By__c, MENU_COMPLETED_BY)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
            .setField(WorkOrder.Status, STATUS_CONFIRMED)
            .setField(WorkOrder.Type__c, TYPE_STOREFRONT)
            .setField(WorkOrder.Vertical__c, VERTICAL)
            .setChildren(
                'WorkSteps',
                new List<Fake>{
                    new Fake(WorkStep.class)
                        .setField(WorkStep.Id, dependeeWorkStepId)
                        .setField(WorkStep.Name, WORK_STEP_NAME_SETUP_STORE)
                        .setField(WorkStep.WorkOrderId, workOrderId)
                        .setField(WorkStep.Type__c, WORK_STEP_NAME_SETUP_STORE)
                        .setField(
                            WorkStep.WorkPlanTemplateEntry__c,
                            dependentWorkPlanTemplateEntryId
                        )
                        .setParent(
                            'WorkOrder',
                            new Fake(workOrder.class)
                                .setField(WorkOrder.Id, workOrderId)
                                .setField(WorkOrder.AccountId, storeAccountId)
                                .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
                                .setField(WorkOrder.Menu_to_be_Completed_By__c, MENU_COMPLETED_BY)
                                .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
                                .setField(WorkOrder.Status, STATUS_CONFIRMED)
                                .setField(WorkOrder.Type__c, TYPE_STOREFRONT)
                                .setField(WorkOrder.Vertical__c, VERTICAL)
                        ),
                    new Fake(WorkStep.class)
                        .setField(WorkStep.Id, dependentWorkStepId)
                        .setField(WorkStep.Name, WORK_STEP_NAME_SETUP_STORE)
                        .setField(WorkStep.WorkOrderId, workOrderId)
                        .setField(WorkStep.Type__c, WORK_STEP_NAME_SETUP_STORE)
                        .setField(
                            WorkStep.WorkPlanTemplateEntry__c,
                            dependentWorkPlanTemplateEntryId
                        )
                        .setParent(
                            'WorkOrder',
                            new Fake(workOrder.class)
                                .setField(WorkOrder.Id, workOrderId)
                                .setField(WorkOrder.AccountId, storeAccountId)
                                .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
                                .setField(WorkOrder.Menu_to_be_Completed_By__c, MENU_COMPLETED_BY)
                                .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
                                .setField(WorkOrder.Status, STATUS_CONFIRMED)
                                .setField(WorkOrder.Type__c, TYPE_STOREFRONT)
                                .setField(WorkOrder.Vertical__c, VERTICAL)
                        )
                }
            )
            .toSObject();
        WorkPlan mockWorkPlanWithWorkOrder = (WorkPlan) new Fake(WorkPlan.class)
            .setField(WorkPlan.Id, workPlanId)
            .setField(WorkPlan.Name, WORK_PLAN_NAME_STOREFRONT)
            .setField(WorkPlan.Status__c, STATUS_NOT_STARTED)
            .setField(WorkPlan.ParentRecordId, workOrderId)
            .setField(WorkPlan.WorkOrderId, workOrderId)
            .setField(WorkPlan.Work_Plan_Template__c, workPlanTemplateId)
            .setField(WorkPlan.Is_Store_Active__c, true)
            .setParent(
                'WorkOrder',
                new Fake(WorkOrder.class)
                    .setField(WorkOrder.Id, workOrderId)
                    .setField(WorkOrder.AccountId, storeAccountId)
                    .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
                    .setField(WorkOrder.Menu_to_be_Completed_By__c, MENU_COMPLETED_BY)
                    .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
                    .setField(WorkOrder.Status, STATUS_CONFIRMED)
                    .setField(WorkOrder.Type__c, TYPE_STOREFRONT)
                    .setField(WorkOrder.Vertical__c, VERTICAL)
                    .setField(WorkOrder.ParentWorkOrderId, parentWorkOrderId)
                    .setParent(
                        'Account',
                        new Fake(Account.class)
                            .setField(Account.Id, storeAccountId)
                            .setField(Account.BillingStreet, ACCOUNT_BILLING_STREET)
                            .setField(Account.Name, STORE_ACCOUNT_NAME)
                            .setField(Account.Partnership_Status__c, ACCOUNT_PARTNERSHIP_STATUS)
                            .setField(Account.ParentId, businessAccountId)
                            .setField(Account.RecordTypeId, ACCOUNT_STORE_RECORD_TYPE_ID)
                    )
            )
            .toSObject();
        WorkPlanTemplate mockWorkPlanTemplate = (WorkPlanTemplate) new Fake(WorkPlanTemplate.class)
            .setField(WorkPlanTemplate.Id, workPlanTemplateId)
            .setChildren(
                'WorkStepTemplates',
                new List<Fake>{
                    new Fake(WorkPlanTemplateEntry.class)
                        .setField(WorkPlanTemplateEntry.WorkPlanTemplateId, workPlanTemplateId)
                        .setField(WorkPlanTemplateEntry.WorkPlanTemplateId, workPlanTemplateId)
                        .setField(WorkPlanTemplateEntry.ExecutionOrder, EXECUTION_ORDER_FIRST)
                        .setParent(
                            'WorkStepTemplate',
                            new Fake(WorkStepTemplate.class)
                                .setField(WorkStepTemplate.Id, workStepTemplateId)
                                .setField(WorkStepTemplate.Name, WORK_STEP_NAME_SETUP_STORE)
                                .setField(WorkStepTemplate.IsActive, true)
                        )
                }
            )
            .toSObject();
        WorkStepDependencyTemplate__c mockWorkStepDependencyTemplate = (WorkStepDependencyTemplate__c) new Fake(
                WorkStepDependencyTemplate__c.class
            )
            .setField(WorkStepDependencyTemplate__c.Id, workStepDependencyTemplateId)
            .setField(
                WorkStepDependencyTemplate__c.Dependee_Work_Plan_Template_Entry__c,
                dependeeWorkPlanTemplateEntryId
            )
            .setField(
                WorkStepDependencyTemplate__c.Dependent_Work_Plan_Template_Entry__c,
                dependentWorkPlanTemplateEntryId
            )
            .setField(WorkStepDependencyTemplate__c.Is_Active__c, true)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkPlansSelector mockWorkPlansSelector = (IWorkPlansSelector) mocks.mock(
            IWorkPlansSelector.class
        );
        IWorkPlanTemplatesSelector mockWorkPlanTemplatesSelector = (IWorkPlanTemplatesSelector) mocks.mock(
            IWorkPlanTemplatesSelector.class
        );
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        IWorkStepDependencyTemplatesSelector mockWorkStepDependencyTemplatesSelector = (IWorkStepDependencyTemplatesSelector) mocks.mock(
            IWorkStepDependencyTemplatesSelector.class
        );
        INotifierEventsService notifierEventService = (INotifierEventsService) mocks.mock(
            INotifierEventsService.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkPlansSelector.sObjectType()).thenReturn(WorkPlan.SObjectType);
        mocks.when(
                mockWorkPlansSelector.selectWorkPlansWithWorkOrderDetails(new Set<Id>{ workPlanId })
            )
            .thenReturn(new List<WorkPlan>{ mockWorkPlanWithWorkOrder });
        mocks.when(mockWorkPlanTemplatesSelector.sObjectType())
            .thenReturn(WorkPlanTemplate.SObjectType);
        mocks.when(
                mockWorkPlanTemplatesSelector.selectWorkPlanTemplatesWithWorkPlanTemplateEntries(
                    new Set<Id>{ workPlanTemplateId }
                )
            )
            .thenReturn(new List<WorkPlanTemplate>{ mockWorkPlanTemplate });
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                mockWorkStepsSelector.selectWorkStepsByWorkOrderIds(
                    new Set<Id>{ parentWorkOrderId }
                )
            )
            .thenReturn(mockWorkStepWithParentWorkOrder.WorkSteps);
        mocks.when(mockWorkStepsSelector.selectWorkStepsByWorkOrderIds(new Set<Id>{ workOrderId }))
            .thenReturn(mockWorkStepWithChildWorkOrder.WorkSteps);
        mocks.when(mockWorkStepDependencyTemplatesSelector.sObjectType())
            .thenReturn(WorkStepDependencyTemplate__c.SObjectType);
        mocks.when(
                mockWorkStepDependencyTemplatesSelector.selectDependeeWorkStepDependencyTemplates(
                    new Set<Id>{ dependentWorkPlanTemplateEntryId }
                )
            )
            .thenReturn(new List<WorkStepDependencyTemplate__c>{ mockWorkStepDependencyTemplate });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkPlansSelector);
        Application.SELECTOR.setMock(mockWorkPlanTemplatesSelector);
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Application.SELECTOR.setMock(mockWorkStepDependencyTemplatesSelector);
        Application.SERVICE.setMock(INotifierEventsService.class, notifierEventService);
        WorkStepsCreationService.createWorkStepsOnWorkPlans(
            new List<WorkPlan>{ mockWorkPlanWithWorkOrder },
            new Set<Id>{ workPlanTemplateId }
        );
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            Map<String, List<String>>.class
        );
        ((INotifierEventsService) mocks.verify(notifierEventService, 3))
            .publishBulkEvents((Map<String, List<String>>) capturedInsertUOWArguments.capture());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{ WorkStep.Name => WORK_STEP_NAME_SETUP_STORE }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        Map<String, List<String>> capturedArguments = (Map<String, List<String>>) capturedInsertUOWArguments.getValue();
        System.assertEquals(1, capturedArguments.size(), COUNT_DO_NOT_MATCH_ASSERT_MESSAGE);
        System.assertEquals(
            new Set<String>{ EVENT_TOPIC_WORK_STEP_DEPENDENCIES_CREATE },
            capturedArguments.keySet(),
            TOPIC_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }
}