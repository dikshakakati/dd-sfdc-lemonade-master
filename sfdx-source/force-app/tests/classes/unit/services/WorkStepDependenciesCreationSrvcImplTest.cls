/**
 * @author Deloitte
 * @date 01/03/2023
 * @description Test class for WorkStepDependenciesCreationServiceImpl class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class WorkStepDependenciesCreationSrvcImplTest {
    private static final String ACCOUNT_BILLING_STREET = '221B Baker Street';
    private static final String ACCOUNT_PARTNERSHIP_STATUS = 'Prospective Partner';
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final String ACCOUNT_STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get(ACCOUNT_RECORD_TYPE_NAME_STORE)
        .getRecordTypeId();
    private static final String ACTIVATE_CENTRALLY = 'Yes';
    private static final String COUNT_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: Argument count does not match';
    private static final String EVENT_TOPIC_WORK_STEP_DEPENDENCIES_CREATE = 'WORK_STEP_DEPENDENCIES_CREATE';
    private static final String MENU_COMPLETED_BY = 'Account Owner';
    private static final String ORDER_PROTOCOL = 'Email';
    private static final String STATUS_CONFIRMED = 'Confirmed';
    private static final String STATUS_NOT_STARTED = 'Not Started';
    private static final String STORE_ACCOUNT_NAME = 'Test Account';
    private static final String TOPIC_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: Notifier event topic does not match';
    private static final String TYPE_MARKETPLACE = 'Marketplace';
    private static final String VERTICAL = 'Floral';
    private static final String WORK_PLAN_NAME = 'Onboarding';
    private static final String WORK_STEP_NAME_REVIEW_AND_TRIAGE = 'Review & Triage';
    private static final String WORK_STEP_NAME_SETUP_BANKING = 'Setup Banking';
    private static final String WORK_STEP_NAME_SETUP_STORE = 'Setup Store';

    /**
     * @description To test deletion of existing WorkStepsDependencies and creation of new
     * WorkStepDependencies by handling the passed platform events.
     */
    @isTest
    private static void testWhenDependenciesCreationCalledAndWorkStepDependenciesPresentThenNewDependenciesCreatedAndExistingDependenciesDeleted() {
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
            .setField(WorkOrder.Type__c, TYPE_MARKETPLACE)
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
                            dependeeWorkPlanTemplateEntryId
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
                                .setField(WorkOrder.Type__c, TYPE_MARKETPLACE)
                                .setField(WorkOrder.Vertical__c, VERTICAL)
                        ),
                    new Fake(WorkStep.class)
                        .setField(WorkStep.Id, dependentWorkStepId)
                        .setField(WorkStep.Name, WORK_STEP_NAME_SETUP_BANKING)
                        .setField(WorkStep.WorkOrderId, workOrderId)
                        .setField(WorkStep.Type__c, WORK_STEP_NAME_SETUP_BANKING)
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
                                .setField(WorkOrder.Type__c, TYPE_MARKETPLACE)
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
            .setField(WorkOrder.Type__c, TYPE_MARKETPLACE)
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
                            dependeeWorkPlanTemplateEntryId
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
                                .setField(WorkOrder.Type__c, TYPE_MARKETPLACE)
                                .setField(WorkOrder.Vertical__c, VERTICAL)
                        ),
                    new Fake(WorkStep.class)
                        .setField(WorkStep.Id, dependentWorkStepId)
                        .setField(WorkStep.Name, WORK_STEP_NAME_SETUP_BANKING)
                        .setField(WorkStep.WorkOrderId, workOrderId)
                        .setField(WorkStep.Type__c, WORK_STEP_NAME_SETUP_BANKING)
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
                                .setField(WorkOrder.Type__c, TYPE_MARKETPLACE)
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
                    .setField(WorkOrder.Type__c, TYPE_MARKETPLACE)
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
        INotifierEventsPayloadGenerationService notifierEventPayloadService = (INotifierEventsPayloadGenerationService) mocks.mock(
            INotifierEventsPayloadGenerationService.class
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
                    new Set<Id>{ dependentWorkPlanTemplateEntryId, dependeeWorkPlanTemplateEntryId }
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
        Application.SERVICE.setMock(
            INotifierEventsPayloadGenerationService.class,
            notifierEventPayloadService
        );
        Application.SERVICE.setMock(INotifierEventsService.class, notifierEventService);
        Application.SERVICE.setMock(IGenericLogger.class,genericLoggerService);
        String eventPayload = JSON.serialize(new Set<Id>{ workOrderId });
        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = EVENT_TOPIC_WORK_STEP_DEPENDENCIES_CREATE
        );
        WorkStepDependenciesCreationService.execute(new List<Notifier__e>{ mockNotifierEvent });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            WorkStepDependency__c.Work_Step_Dependency_Template__c => workStepDependencyTemplateId,
                            WorkStepDependency__c.Dependent_Work_Step__c => dependentWorkStepId
                        }
                    }
                )
            );
        // deletion happens using SobjectDeletionService
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDeleted(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            WorkStepDependency__c.Id => workStepDependencyId
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
    }

    /**
     * @description To test no new WorkStepDependencies by handling the passed platform events
     * when the Work Step is non dependent.
     */
    @isTest
    private static void testWhenDependenciesCreationCalledForNonDependentWorkStepThenNoNewDependenciesCreated() {
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
            .setField(WorkOrder.Type__c, TYPE_MARKETPLACE)
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
                            dependeeWorkPlanTemplateEntryId
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
                                .setField(WorkOrder.Type__c, TYPE_MARKETPLACE)
                                .setField(WorkOrder.Vertical__c, VERTICAL)
                        ),
                    new Fake(WorkStep.class)
                        .setField(WorkStep.Id, dependentWorkStepId)
                        .setField(WorkStep.Name, WORK_STEP_NAME_SETUP_BANKING)
                        .setField(WorkStep.WorkOrderId, workOrderId)
                        .setField(WorkStep.Type__c, WORK_STEP_NAME_SETUP_BANKING)
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
                                .setField(WorkOrder.Type__c, TYPE_MARKETPLACE)
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
            .setField(WorkOrder.Type__c, TYPE_MARKETPLACE)
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
                            dependeeWorkPlanTemplateEntryId
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
                                .setField(WorkOrder.Type__c, TYPE_MARKETPLACE)
                                .setField(WorkOrder.Vertical__c, VERTICAL)
                        ),
                    new Fake(WorkStep.class)
                        .setField(WorkStep.Id, dependentWorkStepId)
                        .setField(WorkStep.Name, WORK_STEP_NAME_SETUP_BANKING)
                        .setField(WorkStep.WorkOrderId, workOrderId)
                        .setField(WorkStep.Type__c, WORK_STEP_NAME_SETUP_BANKING)
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
                                .setField(WorkOrder.Type__c, TYPE_MARKETPLACE)
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
                    .setField(WorkOrder.Type__c, TYPE_MARKETPLACE)
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
        IWorkStepDependenciesSelector mockWorkStepDependenciesSelector = (IWorkStepDependenciesSelector) mocks.mock(
            IWorkStepDependenciesSelector.class
        );
        INotifierEventsService notifierEventService = (INotifierEventsService) mocks.mock(
            INotifierEventsService.class
        );
        INotifierEventsPayloadGenerationService notifierEventPayloadService = (INotifierEventsPayloadGenerationService) mocks.mock(
            INotifierEventsPayloadGenerationService.class
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
                    new Set<Id>{ dependentWorkPlanTemplateEntryId, dependeeWorkPlanTemplateEntryId }
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
            .thenReturn(new List<WorkStepDependency__c>());
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkPlansSelector);
        Application.SELECTOR.setMock(mockWorkPlanTemplatesSelector);
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Application.SELECTOR.setMock(mockWorkStepDependencyTemplatesSelector);
        Application.SELECTOR.setMock(mockWorkStepDependenciesSelector);
        Application.SERVICE.setMock(
            INotifierEventsPayloadGenerationService.class,
            notifierEventPayloadService
        );
        Application.SERVICE.setMock(INotifierEventsService.class, notifierEventService);
        String eventPayload = JSON.serialize(new Set<Id>{ workOrderId });
        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = EVENT_TOPIC_WORK_STEP_DEPENDENCIES_CREATE
        );
        WorkStepDependenciesCreationService.execute(new List<Notifier__e>{ mockNotifierEvent });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }
}