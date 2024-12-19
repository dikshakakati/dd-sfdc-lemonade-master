/**
 * @author Deloitte
 * @date 04/18/2022
 * @description Test class for WorkStepsServiceImpl class.
 * Suppressed Warnings since mock verify method does not require System Assert statements.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts, PMD.NcssTypeCount')
private class WorkStepsServiceImplTest {
    private static final String ACTIVATION_CHECKLIST_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG = 'Activations_Checklist_Payload_Chunk_Size';
    private static final String ACTIVATION_CHECKLIST_VALIDATIONS_STATIC_CONFIG = 'Activations_Checklist_Validations';
    private static final String ACTIVATION_CHECKLIST_VALIDATIONS = 'GET_STORE, GET_POINT_OF_SALE, GET_PAYMENT_ACCOUNT, GET_TAX_STRATEGY, GET_STORE_RETAIL, GET_STORE_ADDRESS_LINK, GET_MENU, GET_BUSINESS, GET_PRICING_PROGRAMS';
    private static final String ASSERT_MESSAGE_STATUS_NOT_UPDATED = 'Unexpected result: Status is not Updated';
    private static final String ACCOUNT_BILLING_STREET = '221B Baker Street';
    private static final String ACCOUNT_NAME_BUSINESS = 'Business Account';
    private static final String ACCOUNT_NAME_STORE = 'Store Account';
    private static final String ACCOUNT_PRIMARY_VERTICAL_PREMIUM = 'Grocery';
    private static final String ACCOUNT_ACTIVATION_STATUS_ACTIVE = 'Active';
    private static final String ACCOUNT_ACTIVATION_STATUS_INACTIVE = 'Inactive';
    private static final String ACCOUNT_ACTIVATED_CENTRALLY_YES = 'Yes';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String GLOBAL_DO_NOT_ACTIVATE_INTEGRATION_MESSAGE = 'This Business ID is deactivated and it is unable to be updated. Please raise a ticket in the #ask-lemonade channel to update Business ID.';
    private static final string ACCOUNT_BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get(ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
        .getRecordTypeId();
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final string ACCOUNT_STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get(ACCOUNT_RECORD_TYPE_NAME_STORE)
        .getRecordTypeId();
    private static final String ASSERT_MESSAGE_NO_CHILD_WORKSTEPS = 'Unexpected result: The list does not contain any child Work Steps';
    private static final String CHILD_WORK_STEPS_TO_UPDATE_EVENT_CHUNK_SIZE = 'Child_Work_Steps_Payload_Chunk_Size';
    private static final String COUNT_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: Work Steps count does not match';
    private static final String CURRENT_RETRY_COUNT = 'Current Retry Count: ';
    private static final String EVENT_TOPIC_REINITIATE_WORK_STEPS_STATUS_ROLL_UP = 'REINITIATE_WORK_STEPS_STATUS_ROLL_UP';
    private static final String EVENT_TOPIC_STOREFRONT_PARENT_WORK_STEP_STATUS_UPDATE = 'STOREFRONT_PARENT_WORK_STEP_STATUS_UPDATE';
    private static final String EVENT_TOPIC_STOREFRONT_WORK_STEPS_STATUS_UPDATE = 'STOREFRONT_WORK_STEPS_STATUS_UPDATE';
    private static final String EVENT_TOPIC_WORK_STEPS_STATUS_ROLL_UP = 'WORK_STEPS_STATUS_ROLL_UP';
    private static final String EVENT_TOPIC_UPDATE_CHILD_WORKSTEPS_ON_PARENT = 'UPDATE_CHILD_WORKSTEPS_ON_PARENT';
    private static final String EXCEEDED_MAXIMUM_RETRY_LIMIT_ERROR_MESSAGE = 'Maximum retry limit exceeded for Work Steps status rollup.';
    private static final Integer EXECUTION_ORDER_FIRST = 1;
    private static final Integer EXECUTION_ORDER_SECOND = 2;
    private static final String EXTERNAL_ID = '1234567';
    private static final String ID_FIELD_API_NAME = 'Id';
    private static final String METADATA_CONTAINS_OPERATOR = 'contains';
    private static final String METADATA_EQUALS_OPERATOR = 'equals';
    private static final Integer METADATA_SEQUENCE = 1;
    private static final String METADATA_VALUE = '50';
    private static final String MOCK_EXCEPTION_MESSAGE = 'Exception occurred while performing DML operation';
    private static final string OPPORTUNITY_NAME = 'Test Opportunity';
    private static final string OPPORTUNITY_STAGE_PROSPECTING = 'Prospecting';
    private static final String PAYLOAD_NOT_GENERATED_ERROR_MESSAGE = 'Unexpected result: Request payload is not generated with parent Work Plan Id.';
    private static final String PIPELINE_SEPARATOR = ' || ';
    private static final String BUSINESS_VERIFICATION = 'BusinessVerification';
    private static final String STATIC_RESOURCE_BUSINESS_VERIFICATION_JSON = 'Business_Verification_Mock_Payload';
    private static final String STATUS_AT_RISK = 'At Risk';
    private static final String STATUS_BLOCKED = 'Blocked';
    private static final String STATUS_COMPLETE = 'Complete';
    private static final String STATUS_COMPLETE_IMPLEMENTED_ON_CALL = 'Complete - Implemented on the call';
    private static final String STATUS_CONFIRMED = 'Confirmed';
    private static final String STATUS_DEAD = 'Dead';
    private static final String STATUS_ESCALATED = 'Escalated';
    private static final string STATUS_FIELD_API_NAME = 'Status__c';
    private static final String STATUS_IN_PROGRESS = 'In Progress';
    private static final String STATUS_NOT_STARTED = 'Not Started';
    private static final String STATUS_NOT_WORKABLE = 'Not Workable';
    private static final String STATUS_PAST_DUE = 'Past Due';
    private static final String STATUS_PLANNING = 'Planning';
    private static final String STATUS_QA_COMPLETE = 'QA Complete';
    private static final String STATUS_READY_FOR_QA = 'Ready for QA';
    private static final String STATUS_REASON_INACTIVE_MENU = 'Inactive menu';
    private static final String STATUS_REASON_INVALID_ADDRESS = 'Invalid Address';
    private static final String STATUS_REASON_OTHER = 'Other';
    private static final String STATUS_REASON_KYC_PENDING = 'Stripe KYC Verification Pending';
    private static final String STATUS_REASON_KYC_SUCCESS = 'Stripe KYC Verification Successful';
    private static final String STATUS_ONBOARDING_COMPLETE = 'Onboarding Complete';
    private static final String STORE_ID = 'StoreId';
    private static final String ULTIMATE_PARENT_AGGREGATE_QUERY_GROUPBYFIELD_ALIAS = 'parentId';
    private static final String ULTIMATE_PARENT_AGGREGATE_QUERY_STATUS_ALIAS = 'workStepStatus';
    private static final String ULTIMATE_PARENT_AGGREGATE_QUERY_COUNT_ALIAS = 'workStepsCount';
    private static final String ULTIMATE_PARENT_WORK_ORDER_CONDITION = 'WorkOrder.ParentWorkOrder.Status NOT IN :WORK_ORDER_PRIORITY_STATUSES';
    private static final String ULTIMATE_PARENT_WORK_ORDER_GROUPBYFIELD = 'WorkOrder.ParentWorkOrderId';
    private static final String ULTIMATE_PARENT_WORK_PLAN_CONDITION = null;
    private static final String ULTIMATE_PARENT_WORK_PLAN_GROUPBYFIELD = 'WorkPlan.Parent_Work_Plan__c';
    private static final String ULTIMATE_PARENT_WORK_STEP_CONDITION = null;
    private static final String ULTIMATE_PARENT_WORK_STEP_GROUPBYFIELD = 'Parent_Work_Step__c';
    private static final String USECASE_NAME_ACTIVATION_CHECKLIST_OUTBOUND_INTEGRATION = 'ACTIVATION_CHECKLIST_OUTBOUND_INTEGRATION';
    private static final String UPDATE_COUNT_DOES_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: SObjects updated count does not match';
    private static final Set<String> WORK_ORDER_PRIORITY_STATUSES = new Set<String>{
        STATUS_AT_RISK,
        STATUS_PAST_DUE
    };
    private static final String WORK_ORDER_SOURCE_SYSTEM = 'System';
    private static final string WORK_ORDER_STATUS_FIELD_API_NAME = 'Status';
    private static final String WORKORDER_TYPE_STOREFRONT = 'Storefront';
    private static final String WORKORDER_TYPE_DRIVE = 'Drive';
    private static final String WORK_PLAN_STORES_ACTIVATED_CHECK_MISMATCH_ASSERT_MESSAGE = 'Unexpected result: All stores associated with the Work Steps related to Work Plan are not activated';
    private static final String WORKPLAN_OWNER_NAME = 'O&A User';
    private static final String WORK_PLAN_ID_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: Work Plan Id does not match';
    private static final String WORK_PLAN_STATUS_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: Work Plan status does not match';
    private static final Integer WORK_PLAN_TEMPLATE_RELATIVE_EXECUTION_ORDER = 1;
    private static final String WORK_STEP_ID_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: Work Step Id does not match';
    private static final String WORK_STEP_STATUS_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: Work Step Status does not match';
    private static final String WORK_STEP_SETUP_BANKING = 'Setup Banking';
    private static final String WORK_STEP_SETUP_STORE = 'Setup Store';
    private static final String WORK_STEP_STATUS_ROLLUP_RETRY_LIMIT_STATIC_CONFIG = 'Work_Step_Status_Rollup_Retry_Limit';
    private static final String WORK_STEP_TYPE_ACTIVATION_CHECKLIST = 'Activations Checklist';
    private static final String WORK_STEP_TYPE_IMPLEMENTATION_CALL = 'Implementation Call';
    private static final String WORKSTEP_TYPE_ACTIVATE_STORE = 'Activate Store';
    private static final String WORKSTEP_TYPE_REVIEW_AND_TRIAGE = 'Review & Triage';
    private static final String WORKSTEP_QUICK_ACTION_NAME = 'Update_Invalid_Address';

    /**
     * @description To test WorkOrder and Work Plan Status update when WorkStep is Blocked.
     */
    @isTest
    private static void testWhenWorkStepIsBlockedThenUpdateWorkOrderToAtRiskAndWorkPlanToBlocked() {
        Set<Id> parentIds = new Set<Id>();
        List<SObject> sobjectsToUpdate = new List<SObject>();

        WorkOrder mockWorkOrder = new WorkOrder(
            Id = fflib_IDGenerator.generate(WorkOrder.SObjectType),
            Status = STATUS_CONFIRMED
        );
        parentIds.add(mockWorkOrder.Id);
        WorkPlan relatedWorkPlan = new WorkPlan(
            Id = fflib_IDGenerator.generate(WorkPlan.SObjectType),
            Status__c = STATUS_NOT_STARTED
        );
        parentIds.add(relatedWorkPlan.Id);
        List<WorkOrder> workOrderWithWorkSteps = (List<WorkOrder>) fflib_ApexMocksUtils.makeRelationship(
            List<WorkOrder>.class,
            new List<WorkOrder>{ mockWorkOrder },
            WorkStep.WorkOrderId,
            new List<List<WorkStep>>{
                new List<WorkStep>{
                    new Workstep(
                        Id = fflib_IDGenerator.generate(WorkStep.SObjectType),
                        WorkPlanId = relatedWorkPlan.Id,
                        Status = STATUS_BLOCKED
                    )
                }
            }
        );
        List<Work_Step_Status_Mapping__mdt> mockCustomMetadata = new List<Work_Step_Status_Mapping__mdt>{
            new Work_Step_Status_Mapping__mdt(
                Operator__c = METADATA_CONTAINS_OPERATOR,
                Sequence__c = METADATA_SEQUENCE,
                Status_To_Apply__c = STATUS_BLOCKED,
                Status__c = STATUS_BLOCKED
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkOrdersSelector mockWorkOrdersSelector = (WorkOrdersSelector) mocks.mock(
            WorkOrdersSelector.class
        );
        IWorkStepStatusMappingsSelector mockWorkStepStatusMappingSelector = (IWorkStepStatusMappingsSelector) mocks.mock(
            IWorkStepStatusMappingsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IGenericLogger genericLoggerService = (IGenericLogger) mocks.mock(GenericLoggerImpl.class);
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersAndWorkStepsUsingWorkOrderIds(
                    new Set<Id>{ mockWorkOrder.Id }
                )
            )
            .thenReturn(workOrderWithWorkSteps);
        mocks.when(mockWorkStepStatusMappingSelector.sObjectType())
            .thenReturn(Work_Step_Status_Mapping__mdt.SObjectType);
        mocks.when(mockWorkStepStatusMappingSelector.getAllValues()).thenReturn(mockCustomMetadata);
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockWorkStepStatusMappingSelector);
        Application.SERVICE.setMock(IGenericLogger.class, genericLoggerService);
        WorkStepsService.runWorkStepStatusCalculationsOnParentRecords(parentIds);
        mockWorkOrder.Status = STATUS_AT_RISK;
        mockWorkOrder.Is_Updated_By_System__c = true;
        relatedWorkPlan.Status__c = STATUS_BLOCKED;
        sobjectsToUpdate.addAll(new List<WorkOrder>{ mockWorkOrder });
        sobjectsToUpdate.addAll(new List<WorkPLan>{ relatedWorkPlan });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW)).registerDirty(sobjectsToUpdate);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test WorkOrder and WorkPlan Status update
     * when WorkStep status is In Progress.
     */
    @isTest
    private static void testWhenWorkStepIsInProgressThenUpdateWorkOrderAndWorkPlanToInProgress() {
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Set<Id> parentIds = new Set<Id>();
        List<SObject> sobjectsToUpdate = new List<SObject>();

        WorkOrder mockWorkOrder = new WorkOrder(
            Id = fflib_IDGenerator.generate(WorkOrder.SObjectType),
            Status = STATUS_CONFIRMED
        );
        parentIds.add(mockWorkOrder.Id);
        WorkPlan relatedWorkPlan = new WorkPlan(
            Id = fflib_IDGenerator.generate(WorkPlan.SObjectType),
            Status__c = STATUS_NOT_STARTED
        );
        parentIds.add(relatedWorkPlan.Id);
        List<WorkOrder> workOrderWithWorkSteps = (List<WorkOrder>) fflib_ApexMocksUtils.makeRelationship(
            List<WorkOrder>.class,
            new List<WorkOrder>{ mockWorkOrder },
            WorkStep.WorkOrderId,
            new List<List<WorkStep>>{
                new List<WorkStep>{
                    new Workstep(
                        Id = workStepId,
                        WorkPlanId = relatedWorkPlan.Id,
                        Status = STATUS_IN_PROGRESS
                    )
                }
            }
        );
        List<Work_Step_Status_Mapping__mdt> mockCustomMetadata = new List<Work_Step_Status_Mapping__mdt>{
            new Work_Step_Status_Mapping__mdt(
                Operator__c = METADATA_CONTAINS_OPERATOR,
                Sequence__c = METADATA_SEQUENCE,
                Status_To_Apply__c = STATUS_IN_PROGRESS,
                Status__c = STATUS_IN_PROGRESS
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkOrdersSelector mockWorkOrdersSelector = (WorkOrdersSelector) mocks.mock(
            WorkOrdersSelector.class
        );
        IWorkStepStatusMappingsSelector mockWorkStepStatusMappingSelector = (IWorkStepStatusMappingsSelector) mocks.mock(
            IWorkStepStatusMappingsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepStatusMappingSelector.sObjectType())
            .thenReturn(Work_Step_Status_Mapping__mdt.SObjectType);
        mocks.when(mockWorkStepStatusMappingSelector.getAllValues()).thenReturn(mockCustomMetadata);
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersAndWorkStepsUsingWorkOrderIds(
                    new Set<Id>{ mockWorkOrder.Id }
                )
            )
            .thenReturn(workOrderWithWorkSteps);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockWorkStepStatusMappingSelector);
        WorkStepsService.runWorkStepStatusCalculationsOnParentRecords(parentIds);
        mockWorkOrder.Status = STATUS_IN_PROGRESS;
        mockWorkOrder.Is_Updated_By_System__c = true;
        relatedWorkPlan.Status__c = STATUS_IN_PROGRESS;
        sobjectsToUpdate.addAll(new List<WorkOrder>{ mockWorkOrder });
        sobjectsToUpdate.addAll(new List<WorkPLan>{ relatedWorkPlan });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW)).registerDirty(sobjectsToUpdate);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test WorkPlan status update when to WorkStep Status is QA Complete.
     */
    @isTest
    private static void testWhenAllWorkStepsAreQACompleteThenUpdateWorkPlanToQAComplete() {
        Set<Id> parentIds = new Set<Id>();
        List<SObject> sobjectsToUpdate = new List<SObject>();

        WorkOrder mockWorkOrder = new WorkOrder(
            Id = fflib_IDGenerator.generate(WorkOrder.SObjectType),
            Status = STATUS_IN_PROGRESS
        );
        parentIds.add(mockWorkOrder.Id);
        WorkPlan relatedWorkPlan = new WorkPlan(
            Id = fflib_IDGenerator.generate(WorkPlan.SObjectType),
            Status__c = STATUS_IN_PROGRESS
        );
        parentIds.add(relatedWorkPlan.Id);
        List<WorkOrder> workOrderWithWorkSteps = (List<WorkOrder>) fflib_ApexMocksUtils.makeRelationship(
            List<WorkOrder>.class,
            new List<WorkOrder>{ mockWorkOrder },
            WorkStep.WorkOrderId,
            new List<List<WorkStep>>{
                new List<WorkStep>{
                    new Workstep(
                        Id = fflib_IDGenerator.generate(WorkStep.SObjectType),
                        WorkPlanId = relatedWorkPlan.Id,
                        Status = STATUS_QA_COMPLETE
                    ),
                    new Workstep(
                        Id = fflib_IDGenerator.generate(WorkStep.SObjectType),
                        WorkPlanId = relatedWorkPlan.Id,
                        Status = STATUS_QA_COMPLETE
                    )
                }
            }
        );
        List<Work_Step_Status_Mapping__mdt> mockCustomMetadata = new List<Work_Step_Status_Mapping__mdt>{
            new Work_Step_Status_Mapping__mdt(
                Operator__c = METADATA_EQUALS_OPERATOR,
                Sequence__c = METADATA_SEQUENCE,
                Status_To_Apply__c = STATUS_QA_COMPLETE,
                Status__c = STATUS_QA_COMPLETE
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkOrdersSelector mockWorkOrdersSelector = (WorkOrdersSelector) mocks.mock(
            WorkOrdersSelector.class
        );
        IWorkStepStatusMappingsSelector mockWorkStepStatusMappingSelector = (IWorkStepStatusMappingsSelector) mocks.mock(
            IWorkStepStatusMappingsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepStatusMappingSelector.sObjectType())
            .thenReturn(Work_Step_Status_Mapping__mdt.SObjectType);
        mocks.when(mockWorkStepStatusMappingSelector.getAllValues()).thenReturn(mockCustomMetadata);
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersAndWorkStepsUsingWorkOrderIds(
                    new Set<Id>{ mockWorkOrder.Id }
                )
            )
            .thenReturn(workOrderWithWorkSteps);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockWorkStepStatusMappingSelector);
        WorkStepsService.runWorkStepStatusCalculationsOnParentRecords(parentIds);
        relatedWorkPlan.Status__c = STATUS_QA_COMPLETE;
        mockWorkOrder.Is_Updated_By_System__c = true;
        mockWorkOrder.Status = STATUS_IN_PROGRESS;
        sobjectsToUpdate.addAll(new List<WorkOrder>{ mockWorkOrder });
        sobjectsToUpdate.addAll(new List<WorkPLan>{ relatedWorkPlan });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW)).registerDirty(sobjectsToUpdate);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test WorkOrder and WorkPlan Status update according to WorkStep is Completed.
     */
    @isTest
    private static void testWhenAllWorkStepsAreCompleteThenUpdateWorkOrderAndWorkPlanAsComplete() {
        Id workStepId1 = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workStepId2 = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Set<Id> parentIds = new Set<Id>();
        List<SObject> sobjectsToUpdate = new List<SObject>();
        WorkOrder mockWorkOrder = new WorkOrder(
            Id = fflib_IDGenerator.generate(WorkOrder.SObjectType),
            Status = STATUS_IN_PROGRESS
        );
        parentIds.add(mockWorkOrder.Id);
        WorkPlan relatedWorkPlan = new WorkPlan(
            Id = fflib_IDGenerator.generate(WorkPlan.SObjectType),
            Status__c = STATUS_IN_PROGRESS
        );
        parentIds.add(relatedWorkPlan.Id);
        List<WorkOrder> workOrderWithWorkSteps = (List<WorkOrder>) fflib_ApexMocksUtils.makeRelationship(
            List<WorkOrder>.class,
            new List<WorkOrder>{ mockWorkOrder },
            WorkStep.WorkOrderId,
            new List<List<WorkStep>>{
                new List<WorkStep>{
                    new Workstep(
                        Id = workStepId1,
                        WorkPlanId = relatedWorkPlan.Id,
                        Status = STATUS_COMPLETE
                    ),
                    new Workstep(
                        Id = workStepId2,
                        WorkPlanId = relatedWorkPlan.Id,
                        Status = STATUS_COMPLETE
                    )
                }
            }
        );
        List<Work_Step_Status_Mapping__mdt> mockCustomMetadata = new List<Work_Step_Status_Mapping__mdt>{
            new Work_Step_Status_Mapping__mdt(
                Operator__c = METADATA_CONTAINS_OPERATOR,
                Sequence__c = METADATA_SEQUENCE,
                Status_To_Apply__c = STATUS_COMPLETE,
                Status__c = STATUS_COMPLETE
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkOrdersSelector mockWorkOrdersSelector = (WorkOrdersSelector) mocks.mock(
            WorkOrdersSelector.class
        );
        IWorkStepStatusMappingsSelector mockWorkStepStatusMappingSelector = (IWorkStepStatusMappingsSelector) mocks.mock(
            IWorkStepStatusMappingsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepStatusMappingSelector.sObjectType())
            .thenReturn(Work_Step_Status_Mapping__mdt.SObjectType);
        mocks.when(mockWorkStepStatusMappingSelector.getAllValues()).thenReturn(mockCustomMetadata);
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersAndWorkStepsUsingWorkOrderIds(
                    new Set<Id>{ mockWorkOrder.Id }
                )
            )
            .thenReturn(workOrderWithWorkSteps);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockWorkStepStatusMappingSelector);
        WorkStepsService.runWorkStepStatusCalculationsOnParentRecords(parentIds);
        mockWorkOrder.Status = STATUS_ONBOARDING_COMPLETE;
        mockWorkOrder.Is_Updated_By_System__c = true;
        relatedWorkPlan.Status__c = STATUS_COMPLETE;
        sobjectsToUpdate.addAll(new List<WorkOrder>{ mockWorkOrder });
        sobjectsToUpdate.addAll(new List<WorkPLan>{ relatedWorkPlan });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW)).registerDirty(sobjectsToUpdate);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test WorkPlan Status update to Dead when all WorkSteps Status is Dead.
     */
    @isTest
    private static void testWhenAllWorkStepsAreDeadThenUpdateWorkPlanToDead() {
        Set<Id> parentIds = new Set<Id>();
        List<SObject> sobjectsToUpdate = new List<SObject>();
        WorkOrder mockWorkOrder = new WorkOrder(
            Id = fflib_IDGenerator.generate(WorkOrder.SObjectType),
            Status = STATUS_IN_PROGRESS
        );
        parentIds.add(mockWorkOrder.Id);
        WorkPlan relatedMockWorkPlan = new WorkPlan(
            Id = fflib_IDGenerator.generate(WorkPlan.SObjectType),
            Status__c = STATUS_IN_PROGRESS
        );
        parentIds.add(relatedMockWorkPlan.Id);
        List<WorkOrder> workOrderWithWorkSteps = (List<WorkOrder>) fflib_ApexMocksUtils.makeRelationship(
            List<WorkOrder>.class,
            new List<WorkOrder>{ mockWorkOrder },
            WorkStep.WorkOrderId,
            new List<List<WorkStep>>{
                new List<WorkStep>{
                    new Workstep(
                        Id = fflib_IDGenerator.generate(WorkStep.SObjectType),
                        WorkPlanId = relatedMockWorkPlan.Id,
                        Status = STATUS_DEAD,
                        Status_Reason__c = STATUS_REASON_OTHER
                    ),
                    new Workstep(
                        Id = fflib_IDGenerator.generate(WorkStep.SObjectType),
                        WorkPlanId = relatedMockWorkPlan.Id,
                        Status = STATUS_DEAD,
                        Status_Reason__c = STATUS_REASON_OTHER
                    )
                }
            }
        );
        List<Work_Step_Status_Mapping__mdt> mockCustomMetadata = new List<Work_Step_Status_Mapping__mdt>{
            new Work_Step_Status_Mapping__mdt(
                Operator__c = METADATA_CONTAINS_OPERATOR,
                Sequence__c = METADATA_SEQUENCE,
                Status_To_Apply__c = STATUS_DEAD,
                Status__c = STATUS_DEAD
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkOrdersSelector mockWorkOrdersSelector = (WorkOrdersSelector) mocks.mock(
            WorkOrdersSelector.class
        );
        IWorkStepStatusMappingsSelector mockWorkStepStatusMappingSelector = (IWorkStepStatusMappingsSelector) mocks.mock(
            IWorkStepStatusMappingsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepStatusMappingSelector.sObjectType())
            .thenReturn(Work_Step_Status_Mapping__mdt.SObjectType);
        mocks.when(mockWorkStepStatusMappingSelector.getAllValues()).thenReturn(mockCustomMetadata);
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersAndWorkStepsUsingWorkOrderIds(
                    new Set<Id>{ mockWorkOrder.Id }
                )
            )
            .thenReturn(workOrderWithWorkSteps);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        WorkStepsService.runWorkStepStatusCalculationsOnParentRecords(parentIds);
        mockWorkOrder.Status = STATUS_DEAD;
        mockWorkOrder.Is_Updated_By_System__c = true;
        relatedMockWorkPlan.Status__c = STATUS_DEAD;
        sobjectsToUpdate.addAll(new List<WorkOrder>{ mockWorkOrder });
        sobjectsToUpdate.addAll(new List<WorkPLan>{ relatedMockWorkPlan });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW)).registerDirty(sobjectsToUpdate);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test WorkOrder and WorkPlan Status update when WorkOrder Status is At Risk
     * according to WorkStep Status.
     */
    @isTest
    private static void testWhenWorkOrderIsAtRiskThenUpdateStatusForWorkOrderAndWorkPlan() {
        Set<Id> parentIds = new Set<Id>();
        List<SObject> sobjectsToUpdate = new List<SObject>();
        WorkOrder mockWorkOrder = new WorkOrder(
            Id = fflib_IDGenerator.generate(WorkOrder.SObjectType),
            Status = STATUS_AT_RISK
        );
        parentIds.add(mockWorkOrder.Id);
        WorkPlan relatedWorkPlan = new WorkPlan(
            Id = fflib_IDGenerator.generate(WorkPlan.SObjectType),
            Status__c = STATUS_NOT_STARTED
        );
        parentIds.add(relatedWorkPlan.Id);
        List<WorkOrder> workOrderWithWorkSteps = (List<WorkOrder>) fflib_ApexMocksUtils.makeRelationship(
            List<WorkOrder>.class,
            new List<WorkOrder>{ mockWorkOrder },
            WorkStep.WorkOrderId,
            new List<List<WorkStep>>{
                new List<WorkStep>{
                    new Workstep(
                        Id = fflib_IDGenerator.generate(WorkStep.SObjectType),
                        WorkPlanId = relatedWorkPlan.Id,
                        Status = STATUS_IN_PROGRESS
                    )
                }
            }
        );
        List<Work_Step_Status_Mapping__mdt> mockCustomMetadata = new List<Work_Step_Status_Mapping__mdt>{
            new Work_Step_Status_Mapping__mdt(
                Operator__c = METADATA_CONTAINS_OPERATOR,
                Sequence__c = METADATA_SEQUENCE,
                Status_To_Apply__c = STATUS_IN_PROGRESS,
                Status__c = STATUS_IN_PROGRESS
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkOrdersSelector mockWorkOrdersSelector = (WorkOrdersSelector) mocks.mock(
            WorkOrdersSelector.class
        );
        IWorkStepStatusMappingsSelector mockWorkStepStatusMappingSelector = (IWorkStepStatusMappingsSelector) mocks.mock(
            IWorkStepStatusMappingsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepStatusMappingSelector.sObjectType())
            .thenReturn(Work_Step_Status_Mapping__mdt.SObjectType);
        mocks.when(mockWorkStepStatusMappingSelector.getAllValues()).thenReturn(mockCustomMetadata);
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersAndWorkStepsUsingWorkOrderIds(
                    new Set<Id>{ mockWorkOrder.Id }
                )
            )
            .thenReturn(workOrderWithWorkSteps);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockWorkStepStatusMappingSelector);
        WorkStepsService.runWorkStepStatusCalculationsOnParentRecords(parentIds);
        relatedWorkPlan.Status__c = STATUS_IN_PROGRESS;
        mockWorkOrder.Is_Updated_By_System__c = true;
        mockWorkOrder.Status = STATUS_IN_PROGRESS;
        sobjectsToUpdate.addAll(new List<WorkOrder>{ mockWorkOrder });
        sobjectsToUpdate.addAll(new List<WorkPLan>{ relatedWorkPlan });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW)).registerDirty(sobjectsToUpdate);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test WorkOrder and WorkPlan Status update when any of WorkStep Status is QA Complete.
     */
    @isTest
    private static void testWhenAnyWorkStepIsQACompleteThenUpdateStatusOfWorkOrderAndWorkPlanToInProgress() {
        Set<Id> parentIds = new Set<Id>();
        List<SObject> sobjectsToUpdate = new List<SObject>();
        WorkOrder mockWorkOrder = new WorkOrder(
            Id = fflib_IDGenerator.generate(WorkOrder.SObjectType),
            Status = STATUS_NOT_STARTED
        );
        parentIds.add(mockWorkOrder.Id);
        WorkPlan relatedWorkPlan = new WorkPlan(
            Id = fflib_IDGenerator.generate(WorkPlan.SObjectType),
            Status__c = STATUS_NOT_STARTED
        );
        parentIds.add(relatedWorkPlan.Id);
        List<WorkOrder> workOrderWithWorkSteps = (List<WorkOrder>) fflib_ApexMocksUtils.makeRelationship(
            List<WorkOrder>.class,
            new List<WorkOrder>{ mockWorkOrder },
            WorkStep.WorkOrderId,
            new List<List<WorkStep>>{
                new List<WorkStep>{
                    new Workstep(
                        Id = fflib_IDGenerator.generate(WorkStep.SObjectType),
                        WorkPlanId = relatedWorkPlan.Id,
                        Status = STATUS_QA_COMPLETE
                    ),
                    new Workstep(
                        Id = fflib_IDGenerator.generate(WorkStep.SObjectType),
                        WorkPlanId = relatedWorkPlan.Id,
                        Status = STATUS_NOT_STARTED
                    )
                }
            }
        );
        List<Work_Step_Status_Mapping__mdt> mockCustomMetadata = new List<Work_Step_Status_Mapping__mdt>{
            new Work_Step_Status_Mapping__mdt(
                Operator__c = METADATA_CONTAINS_OPERATOR,
                Sequence__c = METADATA_SEQUENCE,
                Status_To_Apply__c = STATUS_IN_PROGRESS,
                Status__c = STATUS_QA_COMPLETE
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkOrdersSelector mockWorkOrdersSelector = (WorkOrdersSelector) mocks.mock(
            WorkOrdersSelector.class
        );
        IWorkStepStatusMappingsSelector mockWorkStepStatusMappingSelector = (IWorkStepStatusMappingsSelector) mocks.mock(
            IWorkStepStatusMappingsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepStatusMappingSelector.sObjectType())
            .thenReturn(Work_Step_Status_Mapping__mdt.SObjectType);
        mocks.when(mockWorkStepStatusMappingSelector.getAllValues()).thenReturn(mockCustomMetadata);
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersAndWorkStepsUsingWorkOrderIds(
                    new Set<Id>{ mockWorkOrder.Id }
                )
            )
            .thenReturn(workOrderWithWorkSteps);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockWorkStepStatusMappingSelector);
        WorkStepsService.runWorkStepStatusCalculationsOnParentRecords(parentIds);
        relatedWorkPlan.Status__c = STATUS_IN_PROGRESS;
        mockWorkOrder.Is_Updated_By_System__c = true;
        mockWorkOrder.Status = STATUS_IN_PROGRESS;
        sobjectsToUpdate.addAll(new List<WorkOrder>{ mockWorkOrder });
        sobjectsToUpdate.addAll(new List<WorkPLan>{ relatedWorkPlan });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW)).registerDirty(sobjectsToUpdate);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test WorkOrder and WorkPlan Status update when any of WorkStep Status is Ready for QA.
     */
    @isTest
    private static void testWhenAnyWorkStepIsReadyForQAThenUpdateStatusOfWorkOrderAndWorkPlanToInProgress() {
        Set<Id> parentIds = new Set<Id>();
        List<SObject> sobjectsToUpdate = new List<SObject>();
        WorkOrder mockWorkOrder = new WorkOrder(
            Id = fflib_IDGenerator.generate(WorkOrder.SObjectType),
            Status = STATUS_NOT_STARTED
        );
        parentIds.add(mockWorkOrder.Id);
        WorkPlan relatedWorkPlan = new WorkPlan(
            Id = fflib_IDGenerator.generate(WorkPlan.SObjectType),
            Status__c = STATUS_NOT_STARTED
        );
        parentIds.add(relatedWorkPlan.Id);
        List<WorkOrder> workOrderWithWorkSteps = (List<WorkOrder>) fflib_ApexMocksUtils.makeRelationship(
            List<WorkOrder>.class,
            new List<WorkOrder>{ mockWorkOrder },
            WorkStep.WorkOrderId,
            new List<List<WorkStep>>{
                new List<WorkStep>{
                    new Workstep(
                        Id = fflib_IDGenerator.generate(WorkStep.SObjectType),
                        WorkPlanId = relatedWorkPlan.Id,
                        Status = STATUS_READY_FOR_QA
                    ),
                    new Workstep(
                        Id = fflib_IDGenerator.generate(WorkStep.SObjectType),
                        WorkPlanId = relatedWorkPlan.Id,
                        Status = STATUS_NOT_STARTED
                    )
                }
            }
        );
        List<Work_Step_Status_Mapping__mdt> mockCustomMetadata = new List<Work_Step_Status_Mapping__mdt>{
            new Work_Step_Status_Mapping__mdt(
                Operator__c = METADATA_CONTAINS_OPERATOR,
                Sequence__c = METADATA_SEQUENCE,
                Status_To_Apply__c = STATUS_IN_PROGRESS,
                Status__c = STATUS_READY_FOR_QA
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkOrdersSelector mockWorkOrdersSelector = (WorkOrdersSelector) mocks.mock(
            WorkOrdersSelector.class
        );
        IWorkStepStatusMappingsSelector mockWorkStepStatusMappingSelector = (IWorkStepStatusMappingsSelector) mocks.mock(
            IWorkStepStatusMappingsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepStatusMappingSelector.sObjectType())
            .thenReturn(Work_Step_Status_Mapping__mdt.SObjectType);
        mocks.when(mockWorkStepStatusMappingSelector.getAllValues()).thenReturn(mockCustomMetadata);
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersAndWorkStepsUsingWorkOrderIds(
                    new Set<Id>{ mockWorkOrder.Id }
                )
            )
            .thenReturn(workOrderWithWorkSteps);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockWorkStepStatusMappingSelector);
        WorkStepsService.runWorkStepStatusCalculationsOnParentRecords(parentIds);
        relatedWorkPlan.Status__c = STATUS_IN_PROGRESS;
        mockWorkOrder.Is_Updated_By_System__c = true;
        mockWorkOrder.Status = STATUS_IN_PROGRESS;
        sobjectsToUpdate.addAll(new List<WorkOrder>{ mockWorkOrder });
        sobjectsToUpdate.addAll(new List<WorkPLan>{ relatedWorkPlan });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW)).registerDirty(sobjectsToUpdate);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test WorkOrder and WorkPlan Status update when WorkStep Status is Escalated.
     */
    @isTest
    private static void testWhenAnyWorkStepIsEscalatedThenUpdateWorkOrderToAtRiskAndWorkPlanToEscalated() {
        Set<Id> parentIds = new Set<Id>();
        List<SObject> sobjectsToUpdate = new List<SObject>();
        WorkOrder mockWorkOrder = new WorkOrder(
            Id = fflib_IDGenerator.generate(WorkOrder.SObjectType),
            Status = STATUS_CONFIRMED
        );
        parentIds.add(mockWorkOrder.Id);
        WorkPlan relatedWorkPlan = new WorkPlan(
            Id = fflib_IDGenerator.generate(WorkPlan.SObjectType),
            Status__c = STATUS_NOT_STARTED
        );
        parentIds.add(relatedWorkPlan.Id);
        List<WorkOrder> workOrderWithWorkSteps = (List<WorkOrder>) fflib_ApexMocksUtils.makeRelationship(
            List<WorkOrder>.class,
            new List<WorkOrder>{ mockWorkOrder },
            WorkStep.WorkOrderId,
            new List<List<WorkStep>>{
                new List<WorkStep>{
                    new Workstep(
                        Id = fflib_IDGenerator.generate(WorkStep.SObjectType),
                        WorkPlanId = relatedWorkPlan.Id,
                        Status = STATUS_IN_PROGRESS
                    ),
                    new Workstep(
                        Id = fflib_IDGenerator.generate(WorkStep.SObjectType),
                        WorkPlanId = relatedWorkPlan.Id,
                        Status = STATUS_ESCALATED,
                        Status_Reason__c = STATUS_REASON_OTHER
                    )
                }
            }
        );
        List<Work_Step_Status_Mapping__mdt> mockCustomMetadata = new List<Work_Step_Status_Mapping__mdt>{
            new Work_Step_Status_Mapping__mdt(
                Operator__c = METADATA_CONTAINS_OPERATOR,
                Sequence__c = METADATA_SEQUENCE,
                Status_To_Apply__c = STATUS_ESCALATED,
                Status__c = STATUS_ESCALATED
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkOrdersSelector mockWorkOrdersSelector = (WorkOrdersSelector) mocks.mock(
            WorkOrdersSelector.class
        );
        IWorkStepStatusMappingsSelector mockWorkStepStatusMappingSelector = (IWorkStepStatusMappingsSelector) mocks.mock(
            IWorkStepStatusMappingsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepStatusMappingSelector.sObjectType())
            .thenReturn(Work_Step_Status_Mapping__mdt.SObjectType);
        mocks.when(mockWorkStepStatusMappingSelector.getAllValues()).thenReturn(mockCustomMetadata);
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersAndWorkStepsUsingWorkOrderIds(
                    new Set<Id>{ mockWorkOrder.Id }
                )
            )
            .thenReturn(workOrderWithWorkSteps);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockWorkStepStatusMappingSelector);
        WorkStepsService.runWorkStepStatusCalculationsOnParentRecords(parentIds);
        mockWorkOrder.Status = STATUS_AT_RISK;
        mockWorkOrder.Is_Updated_By_System__c = true;
        relatedWorkPlan.Status__c = STATUS_ESCALATED;
        sobjectsToUpdate.addAll(new List<WorkOrder>{ mockWorkOrder });
        sobjectsToUpdate.addAll(new List<WorkPLan>{ relatedWorkPlan });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW)).registerDirty(sobjectsToUpdate);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test WorkPlan Status is updated from Not Workable to Not Started
     * when WorkStep Status is Not Started.
     */
    @isTest
    private static void testWhenWorkStepIsNotStartedThenUpdateStatusOfWorkOrderAndWorkPlanToNotStarted() {
        List<WorkOrder> workOrderWithWorkStepsResult = new List<WorkOrder>();
        Set<Id> parentIds = new Set<Id>();
        WorkOrder mockWorkOrder = new WorkOrder(
            Id = fflib_IDGenerator.generate(WorkOrder.SObjectType),
            Status = STATUS_CONFIRMED
        );
        parentIds.add(mockWorkOrder.Id);
        WorkPlan relatedWorkPlan = new WorkPlan(
            Id = fflib_IDGenerator.generate(WorkPlan.SObjectType),
            Status__c = STATUS_NOT_WORKABLE
        );
        parentIds.add(relatedWorkPlan.Id);
        List<WorkOrder> workOrderWithWorkSteps = (List<WorkOrder>) fflib_ApexMocksUtils.makeRelationship(
            List<WorkOrder>.class,
            new List<WorkOrder>{ mockWorkOrder },
            WorkStep.WorkOrderId,
            new List<List<WorkStep>>{
                new List<WorkStep>{
                    new Workstep(
                        Id = fflib_IDGenerator.generate(WorkStep.SObjectType),
                        WorkPlanId = relatedWorkPlan.Id,
                        Status = STATUS_NOT_STARTED
                    )
                }
            }
        );
        List<Work_Step_Status_Mapping__mdt> mockCustomMetadata = new List<Work_Step_Status_Mapping__mdt>{
            new Work_Step_Status_Mapping__mdt(
                Operator__c = METADATA_CONTAINS_OPERATOR,
                Sequence__c = METADATA_SEQUENCE,
                Status_To_Apply__c = STATUS_NOT_STARTED,
                Status__c = STATUS_NOT_STARTED
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkOrdersSelector mockWorkOrdersSelector = (WorkOrdersSelector) mocks.mock(
            WorkOrdersSelector.class
        );
        IWorkStepStatusMappingsSelector mockWorkStepStatusMappingSelector = (IWorkStepStatusMappingsSelector) mocks.mock(
            IWorkStepStatusMappingsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepStatusMappingSelector.sObjectType())
            .thenReturn(Work_Step_Status_Mapping__mdt.SObjectType);
        mocks.when(mockWorkStepStatusMappingSelector.getAllValues()).thenReturn(mockCustomMetadata);
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersAndWorkStepsUsingWorkOrderIds(
                    new Set<Id>{ mockWorkOrder.Id }
                )
            )
            .thenReturn(workOrderWithWorkSteps);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockWorkStepStatusMappingSelector);
        WorkStepsService.runWorkStepStatusCalculationsOnParentRecords(parentIds);
        workOrderWithWorkStepsResult = WorkOrdersSelector.newInstance()
            .selectWorkOrdersAndWorkStepsUsingWorkOrderIds(new Set<Id>{ mockWorkOrder.Id });
        System.assert(
            workOrderWithWorkStepsResult[0].WorkSteps != null,
            ASSERT_MESSAGE_NO_CHILD_WORKSTEPS
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test WorkOrder and WorkPlan Status update when Parent Ids are populated.
     */
    @isTest
    private static void testWhenWorkOrderParentExistsThenFetchParentAndUpdateStatus() {
        Id workStepParentWorkOrderId = Fake.generateId(WorkOrder.class);
        Id workStepParentId = Fake.generateId(WorkStep.class);
        Id workStepWorkPlanParentId = Fake.generateId(WorkPlan.class);
        Set<Id> parentIds = new Set<Id>();
        List<Aggregate> parentWorkOrderCountOfWorkStepRecords = new List<Aggregate>{
            new Aggregate()
                .put('parentId', workStepParentWorkOrderId)
                .put('workStepsCount', 1)
                .put('workStepStatus', 'Complete')
        };
        List<Aggregate> parentWorkStepCountOfWorkStepRecords = new List<Aggregate>{
            new Aggregate()
                .put('parentId', workStepParentId)
                .put('workStepsCount', 1)
                .put('workStepStatus', 'Complete')
        };
        List<Aggregate> parentWorkPlanCountOfWorkStepRecords = new List<Aggregate>{
            new Aggregate()
                .put('parentId', workStepWorkPlanParentId)
                .put('workStepsCount', 1)
                .put('workStepStatus', 'Complete')
        };
        Set<Id> parentWorkOrderIds = new Set<Id>{ workStepParentWorkOrderId };
        WorkOrder mockWorkOrder = new WorkOrder(
            Id = fflib_IDGenerator.generate(WorkOrder.SObjectType),
            Status = STATUS_CONFIRMED,
            ParentWorkOrderId = workStepParentWorkOrderId
        );
        parentIds.add(mockWorkOrder.Id);
        WorkPlan relatedWorkPlan = new WorkPlan(
            Id = fflib_IDGenerator.generate(WorkPlan.SObjectType),
            Status__c = STATUS_IN_PROGRESS
        );
        parentIds.add(relatedWorkPlan.Id);
        List<WorkOrder> workOrderWithWorkSteps = (List<WorkOrder>) fflib_ApexMocksUtils.makeRelationship(
            List<WorkOrder>.class,
            new List<WorkOrder>{ mockWorkOrder },
            WorkStep.WorkOrderId,
            new List<List<WorkStep>>{
                new List<WorkStep>{
                    new Workstep(
                        Id = fflib_IDGenerator.generate(WorkStep.SObjectType),
                        WorkPlanId = relatedWorkPlan.Id,
                        Status = STATUS_READY_FOR_QA,
                        Parent_Work_Step__c = workStepParentId
                    )
                }
            }
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        WorkStepsSelector workStepsSelectorMock = (WorkStepsSelector) mocks.mock(
            WorkStepsSelector.class
        );
        WorkOrdersSelector workOrdersSelectorMock = (WorkOrdersSelector) mocks.mock(
            WorkOrdersSelector.class
        );
        mocks.startStubbing();
        mocks.when(workStepsSelectorMock.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                workStepsSelectorMock.getWorkStepsCountFilteredByConditionGroupedByParentAndStatus(
                    ULTIMATE_PARENT_WORK_ORDER_CONDITION,
                    ULTIMATE_PARENT_WORK_ORDER_GROUPBYFIELD,
                    parentWorkOrderIds
                )
            )
            .thenReturn(parentWorkOrderCountOfWorkStepRecords);
        mocks.when(
                workStepsSelectorMock.getWorkStepsCountFilteredByConditionGroupedByParentAndStatus(
                    ULTIMATE_PARENT_WORK_PLAN_CONDITION,
                    ULTIMATE_PARENT_WORK_PLAN_GROUPBYFIELD,
                    new Set<Id>{ workStepWorkPlanParentId }
                )
            )
            .thenReturn(parentWorkPlanCountOfWorkStepRecords);
        mocks.when(
                workStepsSelectorMock.getWorkStepsCountFilteredByConditionGroupedByParentAndStatus(
                    ULTIMATE_PARENT_WORK_STEP_CONDITION,
                    ULTIMATE_PARENT_WORK_STEP_GROUPBYFIELD,
                    new Set<Id>{ workStepParentId }
                )
            )
            .thenReturn(parentWorkStepCountOfWorkStepRecords);
        mocks.when(workOrdersSelectorMock.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                workOrdersSelectorMock.selectWorkOrdersAndWorkStepsUsingWorkOrderIds(
                    new Set<Id>{ mockWorkOrder.Id }
                )
            )
            .thenReturn(workOrderWithWorkSteps);
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(workOrdersSelectorMock);
        Application.SELECTOR.setMock(workStepsSelectorMock);
        WorkStepsService.runWorkStepStatusCalculationsOnParentRecords(parentIds);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{ WorkOrder.Status => STATUS_IN_PROGRESS },
                        new Map<SObjectField, Object>{ WorkPlan.Status__c => STATUS_READY_FOR_QA }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    @isTest
    private static void testWhenWorkOrderIsPastDueThenUpdatePDOAWithFutureDate() {
        Set<Id> parentIds = new Set<Id>();
        WorkOrder mockWorkOrder = new WorkOrder(
            Id = fflib_IDGenerator.generate(WorkOrder.SObjectType),
            Proposed_Date_of_Activation__c = System.today() + 1
        );
        parentIds.add(mockWorkOrder.Id);
        WorkPlan relatedWorkPlan = new WorkPlan(
            Id = fflib_IDGenerator.generate(WorkPlan.SObjectType),
            Status__c = STATUS_NOT_STARTED
        );
        parentIds.add(relatedWorkPlan.Id);
        List<WorkOrder> workOrderWithWorkSteps = (List<WorkOrder>) fflib_ApexMocksUtils.makeRelationship(
            List<WorkOrder>.class,
            new List<WorkOrder>{ mockWorkOrder },
            WorkStep.WorkOrderId,
            new List<List<WorkStep>>{
                new List<WorkStep>{
                    new Workstep(
                        Id = fflib_IDGenerator.generate(WorkStep.SObjectType),
                        WorkPlanId = relatedWorkPlan.Id,
                        Status = STATUS_BLOCKED,
                        Status_Reason__c = STATUS_REASON_OTHER
                    )
                }
            }
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkOrdersSelector mockWorkOrdersSelector = (WorkOrdersSelector) mocks.mock(
            WorkOrdersSelector.class
        );

        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersAndWorkStepsUsingWorkOrderIds(
                    new Set<Id>{ mockWorkOrder.Id }
                )
            )
            .thenReturn(workOrderWithWorkSteps);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        WorkStepsService.runWorkStepStatusCalculationsOnParentRecords(parentIds);
    }

    /**
     * @description To test child WorkStep Status update when parent WorkStep is changed.
     */
    @isTest
    private static void testWhenParentWorkStepStatusChangedThenUpdateChildWorkStepsStatus() {
        Map<Id, WorkStep> parentWorkSteps = new Map<Id, WorkStep>();
        Fake parentWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
                STATUS_IN_PROGRESS
            )
            .setField(WorkStep.Name, WORKSTEP_TYPE_REVIEW_AND_TRIAGE)
            .setField(WorkStep.Type__c, WORKSTEP_TYPE_REVIEW_AND_TRIAGE);
        WorkStep parentReviewAndTriageWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            parentWorkStepFakeInstance
                .setField(WorkStep.Status_Reason__c, STATUS_REASON_INACTIVE_MENU)
        );
        Fake reviewAndTriageChildWorkStepFakeInstance = parentWorkStepFakeInstance
            .setField(WorkStep.Status__c, STATUS_NOT_WORKABLE)
            .setField(WorkStep.Parent_Work_Step__c, parentReviewAndTriageWorkStep.Id);
        WorkStep childReviewAndTriageNotWorkableWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            reviewAndTriageChildWorkStepFakeInstance
        );
        WorkStep childReviewAndTriageNotStartedWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            reviewAndTriageChildWorkStepFakeInstance.setField(
                WorkStep.Status__c,
                STATUS_NOT_STARTED
            )
        );
        Fake setupStoreParentWorkStepFakeInstance = parentWorkStepFakeInstance
            .setField(WorkStep.Status__c, STATUS_COMPLETE)
            .setField(WorkStep.Name, WORK_STEP_SETUP_STORE)
            .setField(WorkStep.Type__c, WORK_STEP_SETUP_STORE);
        WorkStep parentSetupStoreWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            setupStoreParentWorkStepFakeInstance
                .setField(WorkStep.Status_Reason__c, STATUS_REASON_INVALID_ADDRESS)
        );
        Fake setupStoreChildWorkStepFakeInstance = setupStoreParentWorkStepFakeInstance
            .setField(WorkStep.Status__c, STATUS_NOT_WORKABLE)
            .setField(WorkStep.Parent_Work_Step__c, parentSetupStoreWorkStep.Id);
        WorkStep childSetupStoreNotWorkableWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            setupStoreChildWorkStepFakeInstance
        );
        parentWorkSteps.put(parentReviewAndTriageWorkStep.Id, parentReviewAndTriageWorkStep);
        parentWorkSteps.put(parentSetupStoreWorkStep.Id, parentSetupStoreWorkStep);
        Map<String, List<String>> chunkedPayloads = new Map<String, List<String>>{
            EVENT_TOPIC_UPDATE_CHILD_WORKSTEPS_ON_PARENT => NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySObjects(
                new Set<SObject>{
                    childReviewAndTriageNotStartedWorkStep,
                    childReviewAndTriageNotWorkableWorkStep,
                    childSetupStoreNotWorkableWorkStep
                },
                Integer.valueOf(METADATA_VALUE)
            )
        };
        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = chunkedPayloads.get(EVENT_TOPIC_UPDATE_CHILD_WORKSTEPS_ON_PARENT)[0],
            Topic__c = EVENT_TOPIC_UPDATE_CHILD_WORKSTEPS_ON_PARENT
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        INotifierEventsService mockNotifierEventsService = (INotifierEventsService) mocks.mock(
            INotifierEventsService.class
        );
        IStaticConfigurationsSelector mockStaticConfigurations = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                mockWorkStepsSelector.selectChildWorkStepsByParentWorkStepIds(
                    parentWorkSteps.keySet()
                )
            )
            .thenReturn(
                new List<WorkStep>{
                    childReviewAndTriageNotStartedWorkStep,
                    childReviewAndTriageNotWorkableWorkStep,
                    childSetupStoreNotWorkableWorkStep
                }
            );
        mocks.when(mockStaticConfigurations.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurations.getInstanceValue(
                    CHILD_WORK_STEPS_TO_UPDATE_EVENT_CHUNK_SIZE
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = CHILD_WORK_STEPS_TO_UPDATE_EVENT_CHUNK_SIZE,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Application.SERVICE.setMock(INotifierEventsService.class, mockNotifierEventsService);
        WorkStepsService.updateChildWorkStepsStatusOnParentWorkStepsStatusChange(parentWorkSteps);
        WorkStepsService.execute(new List<Notifier__e>{ mockNotifierEvent });
        ((INotifierEventsService) mocks.verify(mockNotifierEventsService, 1))
            .publishBulkEvents(
                new Map<String, List<String>>{
                    EVENT_TOPIC_UPDATE_CHILD_WORKSTEPS_ON_PARENT => NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySObjects(
                        new Set<SObject>{
                            childReviewAndTriageNotStartedWorkStep,
                            childReviewAndTriageNotWorkableWorkStep,
                            childSetupStoreNotWorkableWorkStep
                        },
                        Integer.valueOf(METADATA_VALUE)
                    )
                }
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test WorkOrder and WorkPlan Status update according to WorkStep is Completed or Dead
     * skipping Dead status for "Onboarding Complete" scenario.
     */
    @isTest
    private static void testWhenWorkStepsAreCompleteOrDeadThenUpdateWorkOrderAndWorkPlanAsComplete() {
        Id workStepId1 = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workStepId2 = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Set<Id> parentIds = new Set<Id>();
        List<SObject> sobjectsToUpdate = new List<SObject>();
        WorkOrder mockWorkOrder = new WorkOrder(
            Id = fflib_IDGenerator.generate(WorkOrder.SObjectType),
            Status = STATUS_IN_PROGRESS
        );
        parentIds.add(mockWorkOrder.Id);
        WorkPlan relatedWorkPlan = new WorkPlan(
            Id = fflib_IDGenerator.generate(WorkPlan.SObjectType),
            Status__c = STATUS_IN_PROGRESS
        );
        parentIds.add(relatedWorkPlan.Id);
        List<WorkOrder> workOrderWithWorkSteps = (List<WorkOrder>) fflib_ApexMocksUtils.makeRelationship(
            List<WorkOrder>.class,
            new List<WorkOrder>{ mockWorkOrder },
            WorkStep.WorkOrderId,
            new List<List<WorkStep>>{
                new List<WorkStep>{
                    new Workstep(
                        Id = workStepId1,
                        WorkPlanId = relatedWorkPlan.Id,
                        Status = STATUS_COMPLETE
                    ),
                    new Workstep(
                        Id = workStepId2,
                        WorkPlanId = relatedWorkPlan.Id,
                        Status = STATUS_DEAD,
                        Status_Reason__c = STATUS_REASON_OTHER
                    )
                }
            }
        );
        List<Work_Step_Status_Mapping__mdt> mockCustomMetadata = new List<Work_Step_Status_Mapping__mdt>{
            new Work_Step_Status_Mapping__mdt(
                Operator__c = METADATA_CONTAINS_OPERATOR,
                Sequence__c = METADATA_SEQUENCE,
                Status_To_Apply__c = STATUS_COMPLETE,
                Status__c = STATUS_COMPLETE
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkOrdersSelector mockWorkOrdersSelector = (WorkOrdersSelector) mocks.mock(
            WorkOrdersSelector.class
        );
        IWorkStepStatusMappingsSelector mockWorkStepStatusMappingSelector = (IWorkStepStatusMappingsSelector) mocks.mock(
            IWorkStepStatusMappingsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepStatusMappingSelector.sObjectType())
            .thenReturn(Work_Step_Status_Mapping__mdt.SObjectType);
        mocks.when(mockWorkStepStatusMappingSelector.getAllValues()).thenReturn(mockCustomMetadata);
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersAndWorkStepsUsingWorkOrderIds(
                    new Set<Id>{ mockWorkOrder.Id }
                )
            )
            .thenReturn(workOrderWithWorkSteps);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockWorkStepStatusMappingSelector);
        WorkStepsService.runWorkStepStatusCalculationsOnParentRecords(parentIds);
        mockWorkOrder.Status = STATUS_ONBOARDING_COMPLETE;
        mockWorkOrder.Is_Updated_By_System__c = true;
        relatedWorkPlan.Status__c = STATUS_COMPLETE;
        sobjectsToUpdate.addAll(new List<WorkOrder>{ mockWorkOrder });
        sobjectsToUpdate.addAll(new List<WorkPLan>{ relatedWorkPlan });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW)).registerDirty(sobjectsToUpdate);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test updation of Work Steps status in execution order for Storefront
     * Work Order to "Not Started" and appropriate status updated on parent Work Step
     * when "STOREFRONT_WORK_STEPS_STATUS_UPDATE" platform event is received.
     */
    @isTest
    private static void testWhenStorefrontWorkStepsStatusUpdatedThenParentWorkStepStatusUpdatedToNotWorkable() {
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_PREMIUM,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_PREMIUM
            )
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Activation_Status__c, ACCOUNT_ACTIVATION_STATUS_ACTIVE)
            .setParent('Parent', parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake inactiveStoreAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_PREMIUM
            )
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Activation_Status__c, ACCOUNT_ACTIVATION_STATUS_INACTIVE)
            .setParent('Parent', parentAccountFakeInstance);
        Account inactiveStoreAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            inactiveStoreAccountFakeInstance
        );
        WorkPlanTemplate mockWorkPlanTemplate = (WorkPlanTemplate) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createWorkPlanTemplateFakeInstance(
                WORKORDER_TYPE_STOREFRONT,
                WORK_PLAN_TEMPLATE_RELATIVE_EXECUTION_ORDER
            )
        );
        mockWorkPlanTemplate.Work_Plan_Default_Status__c = STATUS_NOT_WORKABLE;
        Fake parentWorkOrderFakeInstance = (Fake) ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                WORKORDER_TYPE_STOREFRONT
            )
            .setField(WorkOrder.Id, workOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.Work_Order_Source__c, WORK_ORDER_SOURCE_SYSTEM)
            .setParent('Account', parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake parentWorkPlanFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstanceWithProvidedWorkPlanTemplate(
            parentWorkOrder.Id,
            mockWorkPlanTemplate
        );
        WorkPlan parentWorkPlan = (WorkPlan) ServiceMockDataBuilder.convertToSObject(
            parentWorkPlanFakeInstance
        );
        Fake parentWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
                STATUS_NOT_STARTED
            )
            .setField(WorkStep.ExecutionOrder, EXECUTION_ORDER_FIRST)
            .setField(WorkStep.Parent_Work_Step__c, null)
            .setField(WorkStep.WorkPlanId, parentWorkPlan.Id)
            .setParent('WorkOrder', parentWorkOrderFakeInstance)
            .setParent('WorkPlan', parentWorkPlanFakeInstance);
        WorkStep parentWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            parentWorkStepFakeInstance
        );
        Fake childWorkOrderFakeInstance = (Fake) ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_STOREFRONT
            )
            .setField(WorkOrder.Id, workOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.Work_Order_Source__c, WORK_ORDER_SOURCE_SYSTEM)
            .setParent('Account', storeAccountFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Fake childWorkPlanFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstanceWithProvidedWorkPlanTemplate(
            childWorkOrder.Id,
            mockWorkPlanTemplate
        );
        WorkPlan childWorkPlan = (WorkPlan) ServiceMockDataBuilder.convertToSObject(
            childWorkPlanFakeInstance
        );
        Fake childWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
                STATUS_NOT_STARTED
            )
            .setField(WorkStep.ExecutionOrder, EXECUTION_ORDER_FIRST)
            .setField(WorkStep.Store_Account__c, storeAccount.Id)
            .setField(WorkStep.Parent_Work_Step__c, parentWorkStep.Id)
            .setField(WorkStep.WorkPlanId, childWorkPlan.Id)
            .setParent('WorkOrder', childWorkOrderFakeInstance)
            .setParent('WorkPlan', childWorkPlanFakeInstance);
        WorkStep childWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            childWorkStepFakeInstance
        );
        Fake inactiveStoreChildWorkOrderFakeInstance = (Fake) ServiceMockDataBuilder.createWorkOrderFakeInstance(
                inactiveStoreAccount.Id,
                WORKORDER_TYPE_STOREFRONT
            )
            .setField(WorkOrder.Id, workOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.Work_Order_Source__c, WORK_ORDER_SOURCE_SYSTEM)
            .setParent('Account', inactiveStoreAccountFakeInstance);
        Fake firstChildWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
                STATUS_NOT_WORKABLE
            )
            .setField(WorkStep.ExecutionOrder, EXECUTION_ORDER_FIRST)
            .setField(WorkStep.Store_Account__c, inactiveStoreAccount.Id)
            .setField(WorkStep.Parent_Work_Step__c, parentWorkStep.Id)
            .setParent('WorkOrder', inactiveStoreChildWorkOrderFakeInstance)
            .setParent('Parent_Work_Step__r', parentWorkStepFakeInstance);
        WorkStep firstChildWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            firstChildWorkStepFakeInstance
        );
        Fake secondChildWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
                STATUS_NOT_STARTED
            )
            .setField(WorkStep.ExecutionOrder, EXECUTION_ORDER_SECOND)
            .setField(WorkStep.Store_Account__c, storeAccount.Id)
            .setField(WorkStep.Parent_Work_Step__c, parentWorkStep.Id)
            .setParent('WorkOrder', inactiveStoreChildWorkOrderFakeInstance)
            .setParent('Parent_Work_Step__r', parentWorkStepFakeInstance);
        WorkStep secondChildWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            secondChildWorkStepFakeInstance
        );
        List<WorkStep> childWorkSteps = new List<WorkStep>{
            firstChildWorkStep,
            secondChildWorkStep
        };
        List<WorkStep> newParentWorkSteps = new List<WorkStep>{
            new WorkStep(Id = parentWorkStep.Id, Status__c = STATUS_NOT_WORKABLE)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                mockWorkStepsSelector.selectFirstStorefrontWorkStepByStoreAccountIds(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<WorkStep>{ childWorkStep });
        mocks.when(
                mockWorkStepsSelector.selectChildWorkStepsByParentWorkStepIds(
                    new Set<Id>{ parentWorkStep.Id }
                )
            )
            .thenReturn(childWorkSteps);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        String eventPayload = JSON.serialize(new Set<Id>{ storeAccount.Id });
        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = EVENT_TOPIC_STOREFRONT_WORK_STEPS_STATUS_UPDATE
        );
        WorkStepsService.execute(new List<Notifier__e>{ mockNotifierEvent });
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            List<SObject>.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2))
            .registerDirty((List<SObject>) capturedInsertUOWArguments.capture());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
        List<SObject> capturedArguments = (List<SObject>) capturedInsertUOWArguments.getValue();
        WorkStep capturedWorkStep = (WorkStep) capturedArguments[0];
        WorkPlan capturedWorkPlan = (WorkPlan) capturedArguments[1];
        System.assertEquals(
            2,
            capturedArguments.size(),
            UPDATE_COUNT_DOES_NOT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            newParentWorkSteps[0].Id,
            capturedWorkStep.Id,
            WORK_STEP_ID_DO_NOT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            newParentWorkSteps[0].Status__c,
            capturedWorkStep.Status__c,
            WORK_STEP_STATUS_DO_NOT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            parentWorkPlan.Id,
            capturedWorkPlan.Id,
            WORK_PLAN_ID_DO_NOT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            parentWorkPlan.Status__c,
            capturedWorkPlan.Status__c,
            WORK_PLAN_STATUS_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test updation of Work Steps status in execution order for Storefront
     * Work Order to "Not Started" and appropriate status updated on parent Work Step
     * when "STOREFRONT_WORK_STEPS_STATUS_UPDATE" platform event is received.
     */
    @isTest
    private static void testWhenStorefrontWorkStepsStatusUpdatedThenParentWorkStepStatusUpdatedToNotStarted() {
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_PREMIUM,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_PREMIUM
            )
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Activation_Status__c, ACCOUNT_ACTIVATION_STATUS_ACTIVE)
            .setParent('Parent', parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake activeStoreAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_PREMIUM
            )
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Activation_Status__c, ACCOUNT_ACTIVATION_STATUS_ACTIVE)
            .setParent('Parent', parentAccountFakeInstance);
        Account activeStoreAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            activeStoreAccountFakeInstance
        );
        WorkPlanTemplate mockWorkPlanTemplate = (WorkPlanTemplate) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createWorkPlanTemplateFakeInstance(
                WORKORDER_TYPE_STOREFRONT,
                WORK_PLAN_TEMPLATE_RELATIVE_EXECUTION_ORDER
            )
        );
        mockWorkPlanTemplate.Work_Plan_Default_Status__c = STATUS_NOT_WORKABLE;
        Fake parentWorkOrderFakeInstance = (Fake) ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                WORKORDER_TYPE_STOREFRONT
            )
            .setField(WorkOrder.Id, workOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.Work_Order_Source__c, WORK_ORDER_SOURCE_SYSTEM)
            .setParent('Account', parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake parentWorkPlanFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstanceWithProvidedWorkPlanTemplate(
            parentWorkOrder.Id,
            mockWorkPlanTemplate
        );
        WorkPlan parentWorkPlan = (WorkPlan) ServiceMockDataBuilder.convertToSObject(
            parentWorkPlanFakeInstance
        );
        Fake parentWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
                STATUS_NOT_WORKABLE
            )
            .setField(WorkStep.ExecutionOrder, EXECUTION_ORDER_FIRST)
            .setField(WorkStep.Parent_Work_Step__c, null)
            .setField(WorkStep.WorkPlanId, parentWorkPlan.Id)
            .setParent('WorkOrder', parentWorkOrderFakeInstance)
            .setParent('WorkPlan', parentWorkPlanFakeInstance);
        WorkStep parentWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            parentWorkStepFakeInstance
        );
        Fake childWorkOrderFakeInstance = (Fake) ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_STOREFRONT
            )
            .setField(WorkOrder.Id, workOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.Work_Order_Source__c, WORK_ORDER_SOURCE_SYSTEM)
            .setParent('Account', storeAccountFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Fake childWorkPlanFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstanceWithProvidedWorkPlanTemplate(
            childWorkOrder.Id,
            mockWorkPlanTemplate
        );
        WorkPlan childWorkPlan = (WorkPlan) ServiceMockDataBuilder.convertToSObject(
            childWorkPlanFakeInstance
        );
        Fake childWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
                STATUS_NOT_STARTED
            )
            .setField(WorkStep.ExecutionOrder, EXECUTION_ORDER_FIRST)
            .setField(WorkStep.Store_Account__c, storeAccount.Id)
            .setField(WorkStep.Parent_Work_Step__c, parentWorkStep.Id)
            .setField(WorkStep.WorkPlanId, childWorkPlan.Id)
            .setParent('WorkOrder', childWorkOrderFakeInstance)
            .setParent('WorkPlan', childWorkPlanFakeInstance);
        WorkStep childWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            childWorkStepFakeInstance
        );
        Fake activeStoreChildWorkOrderFakeInstance = (Fake) ServiceMockDataBuilder.createWorkOrderFakeInstance(
                activeStoreAccount.Id,
                WORKORDER_TYPE_STOREFRONT
            )
            .setField(WorkOrder.Id, workOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.Work_Order_Source__c, WORK_ORDER_SOURCE_SYSTEM)
            .setParent('Account', activeStoreAccountFakeInstance);
        Fake firstChildWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
                STATUS_NOT_STARTED
            )
            .setField(WorkStep.ExecutionOrder, EXECUTION_ORDER_FIRST)
            .setField(WorkStep.Store_Account__c, activeStoreAccount.Id)
            .setField(WorkStep.Parent_Work_Step__c, parentWorkStep.Id)
            .setParent('WorkOrder', activeStoreChildWorkOrderFakeInstance)
            .setParent('Parent_Work_Step__r', parentWorkStepFakeInstance);
        WorkStep firstChildWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            firstChildWorkStepFakeInstance
        );
        Fake secondChildWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
                STATUS_NOT_STARTED
            )
            .setField(WorkStep.ExecutionOrder, EXECUTION_ORDER_SECOND)
            .setField(WorkStep.Store_Account__c, storeAccount.Id)
            .setField(WorkStep.Parent_Work_Step__c, parentWorkStep.Id)
            .setParent('WorkOrder', activeStoreChildWorkOrderFakeInstance)
            .setParent('Parent_Work_Step__r', parentWorkStepFakeInstance);
        WorkStep secondChildWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            secondChildWorkStepFakeInstance
        );
        List<WorkStep> childWorkSteps = new List<WorkStep>{
            firstChildWorkStep,
            secondChildWorkStep
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                mockWorkStepsSelector.selectFirstStorefrontWorkStepByStoreAccountIds(
                    new Set<Id>{ activeStoreAccount.Id }
                )
            )
            .thenReturn(new List<WorkStep>{ childWorkStep });
        mocks.when(
                mockWorkStepsSelector.selectChildWorkStepsByParentWorkStepIds(
                    new Set<Id>{ parentWorkStep.Id }
                )
            )
            .thenReturn(childWorkSteps);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        String eventPayload = JSON.serialize(new Set<Id>{ activeStoreAccount.Id });
        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = EVENT_TOPIC_STOREFRONT_WORK_STEPS_STATUS_UPDATE
        );
        WorkStepsService.execute(new List<Notifier__e>{ mockNotifierEvent });
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            List<SObject>.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2))
            .registerDirty((List<SObject>) capturedInsertUOWArguments.capture());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
        List<SObject> capturedArguments = (List<SObject>) capturedInsertUOWArguments.getValue();
        WorkStep capturedWorkStep = (WorkStep) capturedArguments[0];
        WorkPlan capturedWorkPlan = (WorkPlan) capturedArguments[1];
        System.assertEquals(
            2,
            capturedArguments.size(),
            UPDATE_COUNT_DOES_NOT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            parentWorkStep.Id,
            capturedWorkStep.Id,
            WORK_STEP_ID_DO_NOT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            parentWorkPlan.Id,
            capturedWorkPlan.Id,
            WORK_PLAN_ID_DO_NOT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            true,
            capturedWorkPlan.Have_All_Stores_Activated__c,
            WORK_PLAN_STORES_ACTIVATED_CHECK_MISMATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test updation of appropriate status on parent Work Step
     * when "STOREFRONT_PARENT_WORK_STEP_STATUS_UPDATE" platform event is received.
     */
    @isTest
    private static void testWhenStorefrontParentWorkStepStatusUpdateEventPayloadReceivedThenParentWorkStepStatusUpdated() {
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_PREMIUM,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_PREMIUM
            )
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Activation_Status__c, ACCOUNT_ACTIVATION_STATUS_ACTIVE)
            .setParent('Parent', parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake inactiveStoreAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_PREMIUM
            )
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Activation_Status__c, ACCOUNT_ACTIVATION_STATUS_INACTIVE)
            .setParent('Parent', parentAccountFakeInstance);
        Account inactiveStoreAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            inactiveStoreAccountFakeInstance
        );
        WorkPlanTemplate mockWorkPlanTemplate = (WorkPlanTemplate) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createWorkPlanTemplateFakeInstance(
                WORKORDER_TYPE_STOREFRONT,
                WORK_PLAN_TEMPLATE_RELATIVE_EXECUTION_ORDER
            )
        );
        mockWorkPlanTemplate.Work_Plan_Default_Status__c = STATUS_NOT_WORKABLE;
        Fake parentWorkOrderFakeInstance = (Fake) ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                WORKORDER_TYPE_STOREFRONT
            )
            .setField(WorkOrder.Id, workOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.Work_Order_Source__c, WORK_ORDER_SOURCE_SYSTEM)
            .setParent('Account', parentAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake parentWorkPlanFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstanceWithProvidedWorkPlanTemplate(
            parentWorkOrder.Id,
            mockWorkPlanTemplate
        );
        WorkPlan parentWorkPlan = (WorkPlan) ServiceMockDataBuilder.convertToSObject(
            parentWorkPlanFakeInstance
        );
        Fake parentWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
                STATUS_NOT_WORKABLE
            )
            .setField(WorkStep.ExecutionOrder, EXECUTION_ORDER_FIRST)
            .setField(WorkStep.Parent_Work_Step__c, null)
            .setField(WorkStep.WorkPlanId, parentWorkPlan.Id)
            .setParent('WorkOrder', parentWorkOrderFakeInstance)
            .setParent('WorkPlan', parentWorkPlanFakeInstance);
        WorkStep parentWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            parentWorkStepFakeInstance
        );
        Fake childWorkOrderFakeInstance = (Fake) ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_STOREFRONT
            )
            .setField(WorkOrder.Id, workOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.Work_Order_Source__c, WORK_ORDER_SOURCE_SYSTEM)
            .setParent('Account', storeAccountFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Fake childWorkPlanFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstanceWithProvidedWorkPlanTemplate(
            childWorkOrder.Id,
            mockWorkPlanTemplate
        );
        WorkPlan childWorkPlan = (WorkPlan) ServiceMockDataBuilder.convertToSObject(
            childWorkPlanFakeInstance
        );
        Fake childWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
                STATUS_NOT_STARTED
            )
            .setField(WorkStep.ExecutionOrder, EXECUTION_ORDER_FIRST)
            .setField(WorkStep.Store_Account__c, storeAccount.Id)
            .setField(WorkStep.Parent_Work_Step__c, parentWorkStep.Id)
            .setField(WorkStep.WorkPlanId, childWorkPlan.Id)
            .setParent('WorkOrder', childWorkOrderFakeInstance)
            .setParent('WorkPlan', childWorkPlanFakeInstance);
        WorkStep childWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            childWorkStepFakeInstance
        );
        Fake inactiveStoreChildWorkOrderFakeInstance = (Fake) ServiceMockDataBuilder.createWorkOrderFakeInstance(
                inactiveStoreAccount.Id,
                WORKORDER_TYPE_STOREFRONT
            )
            .setField(WorkOrder.Id, workOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.Work_Order_Source__c, WORK_ORDER_SOURCE_SYSTEM)
            .setParent('Account', inactiveStoreAccountFakeInstance);
        Fake firstChildWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
                STATUS_NOT_STARTED
            )
            .setField(WorkStep.ExecutionOrder, EXECUTION_ORDER_FIRST)
            .setField(WorkStep.Store_Account__c, inactiveStoreAccount.Id)
            .setField(WorkStep.Parent_Work_Step__c, parentWorkStep.Id)
            .setParent('WorkOrder', inactiveStoreChildWorkOrderFakeInstance)
            .setParent('Parent_Work_Step__r', parentWorkStepFakeInstance);
        WorkStep firstChildWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            firstChildWorkStepFakeInstance
        );
        Fake secondChildWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
                STATUS_NOT_STARTED
            )
            .setField(WorkStep.ExecutionOrder, EXECUTION_ORDER_SECOND)
            .setField(WorkStep.Store_Account__c, storeAccount.Id)
            .setField(WorkStep.Parent_Work_Step__c, parentWorkStep.Id)
            .setParent('WorkOrder', inactiveStoreChildWorkOrderFakeInstance)
            .setParent('Parent_Work_Step__r', parentWorkStepFakeInstance);
        WorkStep secondChildWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            secondChildWorkStepFakeInstance
        );
        List<WorkStep> childWorkSteps = new List<WorkStep>{
            firstChildWorkStep,
            secondChildWorkStep
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                mockWorkStepsSelector.selectFirstStorefrontWorkStepByStoreAccountIds(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<WorkStep>{ childWorkStep });
        mocks.when(
                mockWorkStepsSelector.selectChildWorkStepsByParentWorkStepIds(
                    new Set<Id>{ parentWorkStep.Id }
                )
            )
            .thenReturn(childWorkSteps);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        String eventPayload = JSON.serialize(new Set<Id>{ parentWorkStep.Id });
        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = EVENT_TOPIC_STOREFRONT_PARENT_WORK_STEP_STATUS_UPDATE
        );
        WorkStepsService.execute(new List<Notifier__e>{ mockNotifierEvent });
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            List<SObject>.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty((List<SObject>) capturedInsertUOWArguments.capture());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        List<SObject> capturedArguments = (List<SObject>) capturedInsertUOWArguments.getValue();
        WorkStep capturedWorkStep = (WorkStep) capturedArguments[0];
        WorkPlan capturedWorkPlan = (WorkPlan) capturedArguments[1];
        System.assertEquals(
            2,
            capturedArguments.size(),
            UPDATE_COUNT_DOES_NOT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            parentWorkStep.Id,
            capturedWorkStep.Id,
            WORK_STEP_ID_DO_NOT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            parentWorkPlan.Id,
            capturedWorkPlan.Id,
            WORK_PLAN_ID_DO_NOT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            true,
            capturedWorkPlan.Have_All_Stores_Activated__c,
            WORK_PLAN_STORES_ACTIVATED_CHECK_MISMATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test when child Work Steps are blocked then update parent Work Order to "At Risk",
     * parent Work Plan to "Blocked" and parent Work Step to "Blocked".
     */
    @isTest
    private static void testWhenChildWorkStepsBlockedThenParentRecordsStatusUpdated() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id parentWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id childWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id childWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id childWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                ACCOUNT_PRIMARY_VERTICAL_PREMIUM,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Id, businessAccountId);
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_PREMIUM
            )
            .setField(Account.Id, storeAccountId)
            .setField(Account.ParentId, parentAccount.Id)
            .setParent('Parent', parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = (Fake) ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                WORKORDER_TYPE_STOREFRONT
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setParent('Account', parentAccountFakeInstance);
        WorkPlanTemplate mockWorkPlanTemplate = (WorkPlanTemplate) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createWorkPlanTemplateFakeInstance(
                WORKORDER_TYPE_STOREFRONT,
                WORK_PLAN_TEMPLATE_RELATIVE_EXECUTION_ORDER
            )
        );
        mockWorkPlanTemplate.Work_Plan_Default_Status__c = STATUS_NOT_WORKABLE;
        Fake parentWorkPlanFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstanceWithProvidedWorkPlanTemplate(
                parentWorkOrderId,
                mockWorkPlanTemplate
            )
            .setField(WorkPlan.Id, parentWorkPlanId);
        WorkPlan parentWorkPlan = (WorkPlan) ServiceMockDataBuilder.convertToSObject(
            parentWorkPlanFakeInstance
        );
        Fake parentWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
                STATUS_NOT_WORKABLE
            )
            .setField(WorkStep.Id, parentWorkStepId)
            .setField(WorkStep.Status, STATUS_NOT_WORKABLE)
            .setField(WorkStep.ExecutionOrder, EXECUTION_ORDER_FIRST)
            .setField(WorkStep.Parent_Work_Step__c, null)
            .setField(WorkStep.WorkPlanId, parentWorkPlan.Id)
            .setParent('WorkPlan', parentWorkPlanFakeInstance);
        WorkStep parentWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            parentWorkStepFakeInstance
        );
        Fake childWorkOrderFakeInstance = (Fake) ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_STOREFRONT
            )
            .setField(WorkOrder.Id, childWorkOrderId)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrderId)
            .setParent('Account', storeAccountFakeInstance)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        Fake childWorkPlanFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstanceWithProvidedWorkPlanTemplate(
                childWorkOrderId,
                mockWorkPlanTemplate
            )
            .setField(WorkPlan.Id, childWorkPlanId)
            .setField(WorkPlan.Parent_Work_Plan__c, parentWorkPlanId)
            .setParent('Parent_Work_Plan__r', parentWorkPlanFakeInstance);
        WorkPlan childWorkPlan = (WorkPlan) ServiceMockDataBuilder.convertToSObject(
            childWorkPlanFakeInstance
        );
        Fake childWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
                STATUS_BLOCKED
            )
            .setField(WorkStep.Id, childWorkStepId)
            .setField(WorkStep.Status, STATUS_BLOCKED)
            .setField(WorkStep.Status_Reason__c, STATUS_REASON_OTHER)
            .setField(WorkStep.ExecutionOrder, EXECUTION_ORDER_FIRST)
            .setField(WorkStep.Store_Account__c, storeAccount.Id)
            .setField(WorkStep.Parent_Work_Step__c, parentWorkStep.Id)
            .setField(WorkStep.WorkPlanId, childWorkPlan.Id)
            .setParent('WorkPlan', childWorkPlanFakeInstance)
            .setParent('Parent_Work_Step__r', parentWorkStepFakeInstance);
        childWorkOrderFakeInstance
            .setChildren('WorkSteps', new List<Fake>{ childWorkStepFakeInstance });
        parentWorkOrderFakeInstance
            .setChildren('WorkSteps', new List<Fake>{ parentWorkStepFakeInstance });
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        List<Work_Step_Status_Mapping__mdt> mockCustomMetadata = new List<Work_Step_Status_Mapping__mdt>{
            new Work_Step_Status_Mapping__mdt(
                Operator__c = METADATA_CONTAINS_OPERATOR,
                Sequence__c = METADATA_SEQUENCE,
                Status_To_Apply__c = STATUS_BLOCKED,
                Status__c = STATUS_BLOCKED
            )
        };
        List<Aggregate> parentWorkOrderCountOfWorkStepRecords = new List<Aggregate>{
            new Aggregate()
                .put(ULTIMATE_PARENT_AGGREGATE_QUERY_GROUPBYFIELD_ALIAS, parentWorkOrderId)
                .put(ULTIMATE_PARENT_AGGREGATE_QUERY_COUNT_ALIAS, 1)
                .put(ULTIMATE_PARENT_AGGREGATE_QUERY_STATUS_ALIAS, STATUS_BLOCKED)
        };
        List<Aggregate> parentWorkStepCountOfWorkStepRecords = new List<Aggregate>{
            new Aggregate()
                .put(ULTIMATE_PARENT_AGGREGATE_QUERY_GROUPBYFIELD_ALIAS, parentWorkStepId)
                .put(ULTIMATE_PARENT_AGGREGATE_QUERY_COUNT_ALIAS, 1)
                .put(ULTIMATE_PARENT_AGGREGATE_QUERY_STATUS_ALIAS, STATUS_BLOCKED)
        };
        List<Aggregate> parentWorkPlanCountOfWorkStepRecords = new List<Aggregate>{
            new Aggregate()
                .put(ULTIMATE_PARENT_AGGREGATE_QUERY_GROUPBYFIELD_ALIAS, parentWorkPlanId)
                .put(ULTIMATE_PARENT_AGGREGATE_QUERY_COUNT_ALIAS, 1)
                .put(ULTIMATE_PARENT_AGGREGATE_QUERY_STATUS_ALIAS, STATUS_BLOCKED)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkOrdersSelector mockWorkOrdersSelector = (WorkOrdersSelector) mocks.mock(
            WorkOrdersSelector.class
        );
        IWorkStepsSelector workStepsSelectorMock = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        IWorkStepStatusMappingsSelector mockWorkStepStatusMappingSelector = (IWorkStepStatusMappingsSelector) mocks.mock(
            IWorkStepStatusMappingsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepStatusMappingSelector.sObjectType())
            .thenReturn(Work_Step_Status_Mapping__mdt.SObjectType);
        mocks.when(mockWorkStepStatusMappingSelector.getAllValues()).thenReturn(mockCustomMetadata);
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersAndWorkStepsUsingWorkOrderIds(
                    new Set<Id>{ childWorkOrderId }
                )
            )
            .thenReturn(new List<WorkOrder>{ childWorkOrder });
        mocks.when(workStepsSelectorMock.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                workStepsSelectorMock.getWorkStepsCountFilteredByConditionGroupedByParentAndStatus(
                    ULTIMATE_PARENT_WORK_ORDER_CONDITION,
                    ULTIMATE_PARENT_WORK_ORDER_GROUPBYFIELD,
                    new Set<Id>{ parentWorkOrderId }
                )
            )
            .thenReturn(parentWorkOrderCountOfWorkStepRecords);
        mocks.when(
                workStepsSelectorMock.getWorkStepsCountFilteredByConditionGroupedByParentAndStatus(
                    ULTIMATE_PARENT_WORK_PLAN_CONDITION,
                    ULTIMATE_PARENT_WORK_PLAN_GROUPBYFIELD,
                    new Set<Id>{ parentWorkPlanId }
                )
            )
            .thenReturn(parentWorkPlanCountOfWorkStepRecords);
        mocks.when(
                workStepsSelectorMock.getWorkStepsCountFilteredByConditionGroupedByParentAndStatus(
                    ULTIMATE_PARENT_WORK_STEP_CONDITION,
                    ULTIMATE_PARENT_WORK_STEP_GROUPBYFIELD,
                    new Set<Id>{ parentWorkStepId }
                )
            )
            .thenReturn(parentWorkStepCountOfWorkStepRecords);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(workStepsSelectorMock);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockWorkStepStatusMappingSelector);
        WorkStepsService.runWorkStepStatusCalculationsOnParentRecords(
            new Set<Id>{ childWorkOrderId, childWorkPlanId, parentWorkStepId }
        );
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            List<SObject>.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty((List<SObject>) capturedInsertUOWArguments.capture());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        List<SObject> capturedArguments = (List<SObject>) capturedInsertUOWArguments.getValue();
        System.assertEquals(
            5,
            capturedArguments.size(),
            UPDATE_COUNT_DOES_NOT_MATCH_ASSERT_MESSAGE
        );
        for (SObject eachcapturedArgument : capturedArguments) {
            Id capturedId = (Id) eachcapturedArgument.get(ID_FIELD_API_NAME);
            switch on String.valueOf(capturedId.getSObjectType()) {
                when 'WorkOrder' {
                    System.assertEquals(
                        STATUS_AT_RISK,
                        eachcapturedArgument.get(WORK_ORDER_STATUS_FIELD_API_NAME),
                        ASSERT_MESSAGE_STATUS_NOT_UPDATED
                    );
                }
                when 'WorkPlan', 'WorkStep' {
                    System.assertEquals(
                        STATUS_BLOCKED,
                        eachcapturedArgument.get(STATUS_FIELD_API_NAME),
                        ASSERT_MESSAGE_STATUS_NOT_UPDATED
                    );
                }
            }
        }
    }

    /**
     * @description To test when Implementation Call child WorkStep updated to "Complete - Implemented on the call"
     * then update parent Work Order to "Onboarding Complete", parent Work Plan to "Complete",
     * and parent Work Step to "Complete - Implemented on the call"
     */
    @isTest
    private static void testWhenImplementationCallStatusUpdatedToCompleteImplementedOnTheCallThenParentRecordsStatusUpdated() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id parentWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id childWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id childWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                ACCOUNT_PRIMARY_VERTICAL_PREMIUM,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Id, businessAccountId);
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_PREMIUM
            )
            .setField(Account.Id, storeAccountId)
            .setField(Account.ParentId, parentAccount.Id)
            .setParent('Parent', parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = (Fake) ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                WORKORDER_TYPE_STOREFRONT
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setParent('Account', parentAccountFakeInstance);
        WorkPlanTemplate mockWorkPlanTemplate = (WorkPlanTemplate) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createWorkPlanTemplateFakeInstance(
                WORKORDER_TYPE_STOREFRONT,
                WORK_PLAN_TEMPLATE_RELATIVE_EXECUTION_ORDER
            )
        );
        mockWorkPlanTemplate.Work_Plan_Default_Status__c = STATUS_NOT_WORKABLE;
        Fake parentWorkPlanFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstanceWithProvidedWorkPlanTemplate(
                parentWorkOrderId,
                mockWorkPlanTemplate
            )
            .setField(WorkPlan.Id, parentWorkPlanId);
        WorkPlan parentWorkPlan = (WorkPlan) ServiceMockDataBuilder.convertToSObject(
            parentWorkPlanFakeInstance
        );
        Fake parentWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
                STATUS_NOT_WORKABLE
            )
            .setField(WorkStep.Name, WORK_STEP_TYPE_IMPLEMENTATION_CALL)
            .setField(WorkStep.Type__c, WORK_STEP_TYPE_IMPLEMENTATION_CALL)
            .setField(WorkStep.Id, parentWorkStepId)
            .setField(WorkStep.Status, STATUS_NOT_WORKABLE)
            .setField(WorkStep.ExecutionOrder, EXECUTION_ORDER_FIRST)
            .setField(WorkStep.Parent_Work_Step__c, null)
            .setField(WorkStep.WorkPlanId, parentWorkPlan.Id)
            .setParent('WorkPlan', parentWorkPlanFakeInstance);
        WorkStep parentWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            parentWorkStepFakeInstance
        );
        Fake childWorkOrderFakeInstance = (Fake) ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_STOREFRONT
            )
            .setField(WorkOrder.Id, childWorkOrderId)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrderId)
            .setParent('Account', storeAccountFakeInstance)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        Fake childWorkPlanFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstanceWithProvidedWorkPlanTemplate(
                childWorkOrderId,
                mockWorkPlanTemplate
            )
            .setField(WorkPlan.Id, childWorkPlanId)
            .setField(WorkPlan.Parent_Work_Plan__c, parentWorkPlanId)
            .setParent('Parent_Work_Plan__r', parentWorkPlanFakeInstance);
        WorkPlan childWorkPlan = (WorkPlan) ServiceMockDataBuilder.convertToSObject(
            childWorkPlanFakeInstance
        );
        childWorkOrderFakeInstance
            .setChildren(
                'WorkSteps',
                ServiceMockDataBuilder.generateStorefrontWorkSteps(
                    childWorkPlan.Id,
                    childWorkPlanFakeInstance,
                    parentWorkStep.Id,
                    parentWorkStepFakeInstance,
                    storeAccount.Id
                )
            );
        parentWorkOrderFakeInstance
            .setChildren('WorkSteps', new List<Fake>{ parentWorkStepFakeInstance });
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        List<Work_Step_Status_Mapping__mdt> mockCustomMetadata = new List<Work_Step_Status_Mapping__mdt>{
            new Work_Step_Status_Mapping__mdt(
                Operator__c = METADATA_EQUALS_OPERATOR,
                Sequence__c = 1,
                Status_To_Apply__c = STATUS_COMPLETE,
                Status__c = STATUS_COMPLETE
            ),
            new Work_Step_Status_Mapping__mdt(
                Operator__c = METADATA_EQUALS_OPERATOR,
                Sequence__c = 2,
                Status_To_Apply__c = STATUS_COMPLETE_IMPLEMENTED_ON_CALL,
                Status__c = STATUS_COMPLETE_IMPLEMENTED_ON_CALL
            )
        };
        List<Aggregate> parentWorkOrderCountOfWorkStepRecords = new List<Aggregate>{
            new Aggregate()
                .put(ULTIMATE_PARENT_AGGREGATE_QUERY_GROUPBYFIELD_ALIAS, parentWorkOrderId)
                .put(ULTIMATE_PARENT_AGGREGATE_QUERY_COUNT_ALIAS, 3)
                .put(ULTIMATE_PARENT_AGGREGATE_QUERY_STATUS_ALIAS, STATUS_COMPLETE),
            new Aggregate()
                .put(ULTIMATE_PARENT_AGGREGATE_QUERY_GROUPBYFIELD_ALIAS, parentWorkOrderId)
                .put(ULTIMATE_PARENT_AGGREGATE_QUERY_COUNT_ALIAS, 1)
                .put(
                    ULTIMATE_PARENT_AGGREGATE_QUERY_STATUS_ALIAS,
                    STATUS_COMPLETE_IMPLEMENTED_ON_CALL
                )
        };
        List<Aggregate> parentWorkStepCountOfWorkStepRecords = new List<Aggregate>{
            new Aggregate()
                .put(ULTIMATE_PARENT_AGGREGATE_QUERY_GROUPBYFIELD_ALIAS, parentWorkStepId)
                .put(ULTIMATE_PARENT_AGGREGATE_QUERY_COUNT_ALIAS, 1)
                .put(
                    ULTIMATE_PARENT_AGGREGATE_QUERY_STATUS_ALIAS,
                    STATUS_COMPLETE_IMPLEMENTED_ON_CALL
                )
        };
        List<Aggregate> parentWorkPlanCountOfWorkStepRecords = new List<Aggregate>{
            new Aggregate()
                .put(ULTIMATE_PARENT_AGGREGATE_QUERY_GROUPBYFIELD_ALIAS, parentWorkPlanId)
                .put(ULTIMATE_PARENT_AGGREGATE_QUERY_COUNT_ALIAS, 3)
                .put(ULTIMATE_PARENT_AGGREGATE_QUERY_STATUS_ALIAS, STATUS_COMPLETE),
            new Aggregate()
                .put(ULTIMATE_PARENT_AGGREGATE_QUERY_GROUPBYFIELD_ALIAS, parentWorkPlanId)
                .put(ULTIMATE_PARENT_AGGREGATE_QUERY_COUNT_ALIAS, 1)
                .put(
                    ULTIMATE_PARENT_AGGREGATE_QUERY_STATUS_ALIAS,
                    STATUS_COMPLETE_IMPLEMENTED_ON_CALL
                )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkOrdersSelector mockWorkOrdersSelector = (WorkOrdersSelector) mocks.mock(
            WorkOrdersSelector.class
        );
        IWorkStepsSelector workStepsSelectorMock = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        IWorkStepStatusMappingsSelector mockWorkStepStatusMappingSelector = (IWorkStepStatusMappingsSelector) mocks.mock(
            IWorkStepStatusMappingsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepStatusMappingSelector.sObjectType())
            .thenReturn(Work_Step_Status_Mapping__mdt.SObjectType);
        mocks.when(mockWorkStepStatusMappingSelector.getAllValues()).thenReturn(mockCustomMetadata);
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersAndWorkStepsUsingWorkOrderIds(
                    new Set<Id>{ childWorkOrderId }
                )
            )
            .thenReturn(new List<WorkOrder>{ childWorkOrder });
        mocks.when(workStepsSelectorMock.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                workStepsSelectorMock.getWorkStepsCountFilteredByConditionGroupedByParentAndStatus(
                    ULTIMATE_PARENT_WORK_ORDER_CONDITION,
                    ULTIMATE_PARENT_WORK_ORDER_GROUPBYFIELD,
                    new Set<Id>{ parentWorkOrderId }
                )
            )
            .thenReturn(parentWorkOrderCountOfWorkStepRecords);
        mocks.when(
                workStepsSelectorMock.getWorkStepsCountFilteredByConditionGroupedByParentAndStatus(
                    ULTIMATE_PARENT_WORK_PLAN_CONDITION,
                    ULTIMATE_PARENT_WORK_PLAN_GROUPBYFIELD,
                    new Set<Id>{ parentWorkPlanId }
                )
            )
            .thenReturn(parentWorkPlanCountOfWorkStepRecords);
        mocks.when(
                workStepsSelectorMock.getWorkStepsCountFilteredByConditionGroupedByParentAndStatus(
                    ULTIMATE_PARENT_WORK_STEP_CONDITION,
                    ULTIMATE_PARENT_WORK_STEP_GROUPBYFIELD,
                    new Set<Id>{ parentWorkStepId }
                )
            )
            .thenReturn(parentWorkStepCountOfWorkStepRecords);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(workStepsSelectorMock);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockWorkStepStatusMappingSelector);
        WorkStepsService.runWorkStepStatusCalculationsOnParentRecords(
            new Set<Id>{ childWorkOrderId, childWorkPlanId, parentWorkStepId }
        );
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            List<SObject>.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty((List<SObject>) capturedInsertUOWArguments.capture());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        List<SObject> capturedArguments = (List<SObject>) capturedInsertUOWArguments.getValue();
        for (SObject eachcapturedArgument : capturedArguments) {
            Id capturedId = (Id) eachcapturedArgument.get(ID_FIELD_API_NAME);
            switch on String.valueOf(capturedId.getSObjectType()) {
                when 'WorkOrder' {
                    System.assertEquals(
                        STATUS_ONBOARDING_COMPLETE,
                        eachcapturedArgument.get(WORK_ORDER_STATUS_FIELD_API_NAME),
                        ASSERT_MESSAGE_STATUS_NOT_UPDATED
                    );
                }
                when 'WorkPlan' {
                    System.assertEquals(
                        STATUS_COMPLETE,
                        eachcapturedArgument.get(STATUS_FIELD_API_NAME),
                        ASSERT_MESSAGE_STATUS_NOT_UPDATED
                    );
                }
                when 'WorkStep' {
                    System.assertEquals(
                        STATUS_COMPLETE_IMPLEMENTED_ON_CALL,
                        eachcapturedArgument.get(STATUS_FIELD_API_NAME),
                        ASSERT_MESSAGE_STATUS_NOT_UPDATED
                    );
                }
            }
        }
    }

    /**
     * @description To test Work Order with 'Onboarding Complete' Status not updated to 'Dead' when
     * Work Step Status is updated to 'Dead'.
     */
    @isTest
    private static void testWhenWorkStepMarkedDeadThenDeadStatusNotRolledUpOnOnboardingCompleteWorkOrder() {
        Set<Id> parentIds = new Set<Id>();
        List<SObject> sobjectsToUpdate = new List<SObject>();
        WorkOrder mockWorkOrder = new WorkOrder(
            Id = fflib_IDGenerator.generate(WorkOrder.SObjectType),
            Status = STATUS_ONBOARDING_COMPLETE
        );
        parentIds.add(mockWorkOrder.Id);
        WorkPlan relatedWorkPlan = new WorkPlan(
            Id = fflib_IDGenerator.generate(WorkPlan.SObjectType),
            Status__c = STATUS_COMPLETE
        );
        parentIds.add(relatedWorkPlan.Id);
        List<WorkOrder> workOrderWithWorkSteps = (List<WorkOrder>) fflib_ApexMocksUtils.makeRelationship(
            List<WorkOrder>.class,
            new List<WorkOrder>{ mockWorkOrder },
            WorkStep.WorkOrderId,
            new List<List<WorkStep>>{
                new List<WorkStep>{
                    new Workstep(
                        Id = fflib_IDGenerator.generate(WorkStep.SObjectType),
                        WorkPlanId = relatedWorkPlan.Id,
                        Status = STATUS_DEAD,
                        Status_Reason__c = STATUS_REASON_OTHER
                    ),
                    new Workstep(
                        Id = fflib_IDGenerator.generate(WorkStep.SObjectType),
                        WorkPlanId = relatedWorkPlan.Id,
                        Status = STATUS_DEAD,
                        Status_Reason__c = STATUS_REASON_OTHER
                    )
                }
            }
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkOrdersSelector mockWorkOrdersSelector = (WorkOrdersSelector) mocks.mock(
            WorkOrdersSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersAndWorkStepsUsingWorkOrderIds(
                    new Set<Id>{ mockWorkOrder.Id }
                )
            )
            .thenReturn(workOrderWithWorkSteps);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        WorkStepsService.runWorkStepStatusCalculationsOnParentRecords(parentIds);
        // Work Order Status is not updated since current Status is 'Onboarding Complete'
        relatedWorkPlan.Status__c = STATUS_DEAD;
        sobjectsToUpdate.addAll(new List<WorkPLan>{ relatedWorkPlan });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW)).registerDirty(sobjectsToUpdate);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test WorkOrder and WorkPlan Status update
     * when Event payload is received.
     */
    @isTest
    private static void testWhenEventPayloadReceivedThenUpdateWorkOrderAndWorkPlanStatus() {
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Set<Id> parentIds = new Set<Id>();
        List<SObject> sobjectsToUpdate = new List<SObject>();

        WorkOrder mockWorkOrder = new WorkOrder(
            Id = fflib_IDGenerator.generate(WorkOrder.SObjectType),
            Status = STATUS_CONFIRMED
        );
        parentIds.add(mockWorkOrder.Id);
        WorkPlan relatedWorkPlan = new WorkPlan(
            Id = fflib_IDGenerator.generate(WorkPlan.SObjectType),
            Status__c = STATUS_NOT_STARTED
        );
        parentIds.add(relatedWorkPlan.Id);
        List<WorkOrder> workOrderWithWorkSteps = (List<WorkOrder>) fflib_ApexMocksUtils.makeRelationship(
            List<WorkOrder>.class,
            new List<WorkOrder>{ mockWorkOrder },
            WorkStep.WorkOrderId,
            new List<List<WorkStep>>{
                new List<WorkStep>{
                    new Workstep(
                        Id = workStepId,
                        WorkPlanId = relatedWorkPlan.Id,
                        Status = STATUS_IN_PROGRESS
                    )
                }
            }
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkOrdersSelector mockWorkOrdersSelector = (WorkOrdersSelector) mocks.mock(
            WorkOrdersSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersAndWorkStepsUsingWorkOrderIds(
                    new Set<Id>{ mockWorkOrder.Id }
                )
            )
            .thenReturn(workOrderWithWorkSteps);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        String eventPayload = JSON.serialize(parentIds);
        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = EVENT_TOPIC_WORK_STEPS_STATUS_ROLL_UP
        );
        WorkStepsService.execute(new List<Notifier__e>{ mockNotifierEvent });
        mockWorkOrder.Status = STATUS_IN_PROGRESS;
        mockWorkOrder.Is_Updated_By_System__c = true;
        relatedWorkPlan.Status__c = STATUS_IN_PROGRESS;
        sobjectsToUpdate.addAll(new List<WorkOrder>{ mockWorkOrder });
        sobjectsToUpdate.addAll(new List<WorkPLan>{ relatedWorkPlan });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW)).registerDirty(sobjectsToUpdate);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Work Order and Work Plan Status update when Work Order is Past Due
     * and Work Step is Complete.
     */
    @isTest
    private static void testWhenAllWorkStepsCompleteThenUpdatePastDueWorkOrderAsOnboardingComplete() {
        Id workStepId1 = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workStepId2 = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Set<Id> parentIds = new Set<Id>();
        List<SObject> sobjectsToUpdate = new List<SObject>();
        WorkOrder mockWorkOrder = new WorkOrder(
            Id = fflib_IDGenerator.generate(WorkOrder.SObjectType),
            Status = STATUS_PAST_DUE
        );
        parentIds.add(mockWorkOrder.Id);
        WorkPlan relatedWorkPlan = new WorkPlan(
            Id = fflib_IDGenerator.generate(WorkPlan.SObjectType),
            Status__c = STATUS_IN_PROGRESS
        );
        parentIds.add(relatedWorkPlan.Id);
        List<WorkOrder> workOrderWithWorkSteps = (List<WorkOrder>) fflib_ApexMocksUtils.makeRelationship(
            List<WorkOrder>.class,
            new List<WorkOrder>{ mockWorkOrder },
            WorkStep.WorkOrderId,
            new List<List<WorkStep>>{
                new List<WorkStep>{
                    new Workstep(
                        Id = workStepId1,
                        WorkPlanId = relatedWorkPlan.Id,
                        Status = STATUS_COMPLETE
                    ),
                    new Workstep(
                        Id = workStepId2,
                        WorkPlanId = relatedWorkPlan.Id,
                        Status = STATUS_COMPLETE
                    )
                }
            }
        );
        List<Work_Step_Status_Mapping__mdt> mockCustomMetadata = new List<Work_Step_Status_Mapping__mdt>{
            new Work_Step_Status_Mapping__mdt(
                Operator__c = METADATA_CONTAINS_OPERATOR,
                Sequence__c = METADATA_SEQUENCE,
                Status_To_Apply__c = STATUS_COMPLETE,
                Status__c = STATUS_COMPLETE
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkOrdersSelector mockWorkOrdersSelector = (WorkOrdersSelector) mocks.mock(
            WorkOrdersSelector.class
        );
        IWorkStepStatusMappingsSelector mockWorkStepStatusMappingSelector = (IWorkStepStatusMappingsSelector) mocks.mock(
            IWorkStepStatusMappingsSelector.class
        );
        IWorkOrdersService mockWorkOrdersService = (IWorkOrdersService) mocks.mock(
            IWorkOrdersService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepStatusMappingSelector.sObjectType())
            .thenReturn(Work_Step_Status_Mapping__mdt.SObjectType);
        mocks.when(mockWorkStepStatusMappingSelector.getAllValues()).thenReturn(mockCustomMetadata);
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersAndWorkStepsUsingWorkOrderIds(
                    new Set<Id>{ mockWorkOrder.Id }
                )
            )
            .thenReturn(workOrderWithWorkSteps);
        mocks.when(mockWorkOrdersService.getWorkStatusUpdatedValue(workOrderWithWorkSteps[0]))
            .thenReturn(STATUS_PAST_DUE);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockWorkStepStatusMappingSelector);
        Application.SERVICE.setMock(IWorkOrdersService.class, mockWorkOrdersService);
        WorkStepsService.runWorkStepStatusCalculationsOnParentRecords(parentIds);
        mockWorkOrder.Status = STATUS_ONBOARDING_COMPLETE;
        mockWorkOrder.Is_Updated_By_System__c = true;
        relatedWorkPlan.Status__c = STATUS_COMPLETE;
        sobjectsToUpdate.addAll(new List<WorkOrder>{ mockWorkOrder });
        sobjectsToUpdate.addAll(new List<WorkPLan>{ relatedWorkPlan });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW)).registerDirty(sobjectsToUpdate);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Work Order and Work Plan Status update when Work Order is Past Due
     * and Work Step is Dead.
     */
    @isTest
    private static void testWhenAllWorkStepsDeadThenUpdatePastDueWorkOrderAsDead() {
        Id workStepId1 = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workStepId2 = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Set<Id> parentIds = new Set<Id>();
        List<SObject> sobjectsToUpdate = new List<SObject>();
        WorkOrder mockWorkOrder = new WorkOrder(
            Id = fflib_IDGenerator.generate(WorkOrder.SObjectType),
            Status = STATUS_PAST_DUE
        );
        parentIds.add(mockWorkOrder.Id);
        WorkPlan relatedWorkPlan = new WorkPlan(
            Id = fflib_IDGenerator.generate(WorkPlan.SObjectType),
            Status__c = STATUS_IN_PROGRESS
        );
        parentIds.add(relatedWorkPlan.Id);
        List<WorkOrder> workOrderWithWorkSteps = (List<WorkOrder>) fflib_ApexMocksUtils.makeRelationship(
            List<WorkOrder>.class,
            new List<WorkOrder>{ mockWorkOrder },
            WorkStep.WorkOrderId,
            new List<List<WorkStep>>{
                new List<WorkStep>{
                    new Workstep(
                        Id = workStepId1,
                        WorkPlanId = relatedWorkPlan.Id,
                        Status = STATUS_DEAD,
                        Status_Reason__c = STATUS_REASON_OTHER
                    ),
                    new Workstep(
                        Id = workStepId2,
                        WorkPlanId = relatedWorkPlan.Id,
                        Status = STATUS_DEAD,
                        Status_Reason__c = STATUS_REASON_OTHER
                    )
                }
            }
        );
        List<Work_Step_Status_Mapping__mdt> mockCustomMetadata = new List<Work_Step_Status_Mapping__mdt>{
            new Work_Step_Status_Mapping__mdt(
                Operator__c = METADATA_CONTAINS_OPERATOR,
                Sequence__c = METADATA_SEQUENCE,
                Status_To_Apply__c = STATUS_DEAD,
                Status__c = STATUS_DEAD
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkOrdersSelector mockWorkOrdersSelector = (WorkOrdersSelector) mocks.mock(
            WorkOrdersSelector.class
        );
        IWorkStepStatusMappingsSelector mockWorkStepStatusMappingSelector = (IWorkStepStatusMappingsSelector) mocks.mock(
            IWorkStepStatusMappingsSelector.class
        );
        IWorkOrdersService mockWorkOrdersService = (IWorkOrdersService) mocks.mock(
            IWorkOrdersService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepStatusMappingSelector.sObjectType())
            .thenReturn(Work_Step_Status_Mapping__mdt.SObjectType);
        mocks.when(mockWorkStepStatusMappingSelector.getAllValues()).thenReturn(mockCustomMetadata);
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersAndWorkStepsUsingWorkOrderIds(
                    new Set<Id>{ mockWorkOrder.Id }
                )
            )
            .thenReturn(workOrderWithWorkSteps);
        mocks.when(mockWorkOrdersService.getWorkStatusUpdatedValue(workOrderWithWorkSteps[0]))
            .thenReturn(STATUS_PAST_DUE);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockWorkStepStatusMappingSelector);
        Application.SERVICE.setMock(IWorkOrdersService.class, mockWorkOrdersService);
        WorkStepsService.runWorkStepStatusCalculationsOnParentRecords(parentIds);
        mockWorkOrder.Status = STATUS_DEAD;
        mockWorkOrder.Is_Updated_By_System__c = true;
        relatedWorkPlan.Status__c = STATUS_DEAD;
        sobjectsToUpdate.addAll(new List<WorkOrder>{ mockWorkOrder });
        sobjectsToUpdate.addAll(new List<WorkPLan>{ relatedWorkPlan });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW)).registerDirty(sobjectsToUpdate);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Status rollup process is reinitiated when exception occurs.
     */
    @isTest
    private static void testWhenExceptionOccurredThenReinitiateStatusRollup() {
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Set<Id> parentIds = new Set<Id>();
        WorkOrder mockWorkOrder = new WorkOrder(
            Id = fflib_IDGenerator.generate(WorkOrder.SObjectType),
            Status = STATUS_CONFIRMED
        );
        parentIds.add(mockWorkOrder.Id);
        WorkPlan relatedWorkPlan = new WorkPlan(
            Id = fflib_IDGenerator.generate(WorkPlan.SObjectType),
            Status__c = STATUS_NOT_STARTED
        );
        parentIds.add(relatedWorkPlan.Id);
        List<WorkOrder> workOrderWithWorkSteps = (List<WorkOrder>) fflib_ApexMocksUtils.makeRelationship(
            List<WorkOrder>.class,
            new List<WorkOrder>{ mockWorkOrder },
            WorkStep.WorkOrderId,
            new List<List<WorkStep>>{
                new List<WorkStep>{
                    new Workstep(
                        Id = workStepId,
                        WorkPlanId = relatedWorkPlan.Id,
                        Status = STATUS_IN_PROGRESS
                    )
                }
            }
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        INotifierEventsService notifierEventServiceMock = (INotifierEventsService) mocks.mock(
            INotifierEventsService.class
        );
        WorkOrdersSelector mockWorkOrdersSelector = (WorkOrdersSelector) mocks.mock(
            WorkOrdersSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersAndWorkStepsUsingWorkOrderIds(
                    new Set<Id>{ mockWorkOrder.Id }
                )
            )
            .thenReturn(workOrderWithWorkSteps);
        ((fflib_ISObjectUnitOfWork) mocks.doThrowWhen(
                new TestCommitException(MOCK_EXCEPTION_MESSAGE),
                mockUOW
            ))
            .commitWork();
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SERVICE.setMock(INotifierEventsService.class, notifierEventServiceMock);
        String eventPayload = JSON.serialize(parentIds);
        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = EVENT_TOPIC_WORK_STEPS_STATUS_ROLL_UP
        );
        String exceptionMessage;
        try {
            WorkStepsService.execute(new List<Notifier__e>{ mockNotifierEvent });
        } catch (Exception mockException) {
            exceptionMessage =
                mockException.getMessage() +
                PIPELINE_SEPARATOR +
                CURRENT_RETRY_COUNT +
                0;
        }
        WorkStepStatusEntry workStepStatusEntryWrapperMock = new WorkStepStatusEntry(parentIds, 1);
        String eventPayloadMock = JSON.serialize(workStepStatusEntryWrapperMock);
        ((INotifierEventsService) mocks.verify(notifierEventServiceMock, 1))
            .publishEvents(
                new Map<String, String>{
                    EVENT_TOPIC_REINITIATE_WORK_STEPS_STATUS_ROLL_UP => eventPayloadMock
                }
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{ Log__c.Detailed_Message__c => exceptionMessage }
                )
            );
    }

    /**
     * @description To test Work Plan Status update when WorkStep Status reverted to "Not Workable".
     */
    @isTest
    private static void testWhenWorkStepRevertedToNotWorkableThenUpdateWorkPlanToNotWorkable() {
        Set<Id> parentIds = new Set<Id>();

        WorkOrder mockWorkOrder = new WorkOrder(
            Id = fflib_IDGenerator.generate(WorkOrder.SObjectType),
            Status = STATUS_CONFIRMED
        );
        parentIds.add(mockWorkOrder.Id);
        WorkPlan relatedWorkPlan = new WorkPlan(
            Id = fflib_IDGenerator.generate(WorkPlan.SObjectType),
            Status__c = STATUS_NOT_STARTED
        );
        parentIds.add(relatedWorkPlan.Id);
        List<WorkOrder> workOrderWithWorkSteps = (List<WorkOrder>) fflib_ApexMocksUtils.makeRelationship(
            List<WorkOrder>.class,
            new List<WorkOrder>{ mockWorkOrder },
            WorkStep.WorkOrderId,
            new List<List<WorkStep>>{
                new List<WorkStep>{
                    new Workstep(
                        Id = fflib_IDGenerator.generate(WorkStep.SObjectType),
                        WorkPlanId = relatedWorkPlan.Id,
                        Status = STATUS_NOT_WORKABLE
                    )
                }
            }
        );
        List<Work_Step_Status_Mapping__mdt> mockCustomMetadata = new List<Work_Step_Status_Mapping__mdt>{
            new Work_Step_Status_Mapping__mdt(
                Operator__c = METADATA_CONTAINS_OPERATOR,
                Sequence__c = METADATA_SEQUENCE,
                Status_To_Apply__c = STATUS_NOT_WORKABLE,
                Status__c = STATUS_NOT_WORKABLE
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkOrdersSelector mockWorkOrdersSelector = (WorkOrdersSelector) mocks.mock(
            WorkOrdersSelector.class
        );
        IWorkStepStatusMappingsSelector mockWorkStepStatusMappingSelector = (IWorkStepStatusMappingsSelector) mocks.mock(
            IWorkStepStatusMappingsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersAndWorkStepsUsingWorkOrderIds(
                    new Set<Id>{ mockWorkOrder.Id }
                )
            )
            .thenReturn(workOrderWithWorkSteps);
        mocks.when(mockWorkStepStatusMappingSelector.sObjectType())
            .thenReturn(Work_Step_Status_Mapping__mdt.SObjectType);
        mocks.when(mockWorkStepStatusMappingSelector.getAllValues()).thenReturn(mockCustomMetadata);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockWorkStepStatusMappingSelector);
        WorkStepsService.runWorkStepStatusCalculationsOnParentRecords(parentIds);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            WorkOrder.Id => mockWorkOrder.Id,
                            WorkOrder.Status => STATUS_PLANNING
                        },
                        new Map<SObjectField, Object>{
                            WorkPlan.Id => relatedWorkPlan.Id,
                            WorkPlan.Status__c => STATUS_NOT_WORKABLE
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test child Work Order/Plan and parent Work Step's status updated when
     * only child Work Order Ids are provided.
     */
    @isTest
    private static void testWhenChildWorkOrderIdsPassedThenStatusOnParentWorkRecordsUpdated() {
        Id workStepParentWorkOrderId = Fake.generateId(WorkOrder.class);
        Id workStepParentId = Fake.generateId(WorkStep.class);
        Id workStepWorkPlanParentId = Fake.generateId(WorkPlan.class);
        Set<Id> parentIds = new Set<Id>();
        List<Aggregate> parentWorkOrderCountOfWorkStepRecords = new List<Aggregate>{
            new Aggregate()
                .put('parentId', workStepParentWorkOrderId)
                .put('workStepsCount', 1)
                .put('workStepStatus', 'Ready for QA')
        };
        List<Aggregate> parentWorkStepCountOfWorkStepRecords = new List<Aggregate>{
            new Aggregate()
                .put('parentId', workStepParentId)
                .put('workStepsCount', 1)
                .put('workStepStatus', 'Ready for QA')
        };
        List<Aggregate> parentWorkPlanCountOfWorkStepRecords = new List<Aggregate>{
            new Aggregate()
                .put('parentId', workStepWorkPlanParentId)
                .put('workStepsCount', 1)
                .put('workStepStatus', 'Ready for QA')
        };
        Set<Id> parentWorkOrderIds = new Set<Id>{ workStepParentWorkOrderId };
        WorkOrder mockWorkOrder = new WorkOrder(
            Id = fflib_IDGenerator.generate(WorkOrder.SObjectType),
            Status = STATUS_CONFIRMED,
            ParentWorkOrderId = workStepParentWorkOrderId
        );
        parentIds.add(mockWorkOrder.Id);
        WorkPlan relatedWorkPlan = new WorkPlan(
            Id = fflib_IDGenerator.generate(WorkPlan.SObjectType),
            Status__c = STATUS_IN_PROGRESS
        );
        List<WorkOrder> workOrderWithWorkSteps = (List<WorkOrder>) fflib_ApexMocksUtils.makeRelationship(
            List<WorkOrder>.class,
            new List<WorkOrder>{ mockWorkOrder },
            WorkStep.WorkOrderId,
            new List<List<WorkStep>>{
                new List<WorkStep>{
                    new Workstep(
                        Id = fflib_IDGenerator.generate(WorkStep.SObjectType),
                        WorkPlanId = relatedWorkPlan.Id,
                        Status = STATUS_READY_FOR_QA,
                        Parent_Work_Step__c = workStepParentId
                    )
                }
            }
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        WorkStepsSelector workStepsSelectorMock = (WorkStepsSelector) mocks.mock(
            WorkStepsSelector.class
        );
        WorkOrdersSelector workOrdersSelectorMock = (WorkOrdersSelector) mocks.mock(
            WorkOrdersSelector.class
        );
        mocks.startStubbing();
        mocks.when(workStepsSelectorMock.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                workStepsSelectorMock.getWorkStepsCountFilteredByConditionGroupedByParentAndStatus(
                    ULTIMATE_PARENT_WORK_ORDER_CONDITION,
                    ULTIMATE_PARENT_WORK_ORDER_GROUPBYFIELD,
                    parentWorkOrderIds
                )
            )
            .thenReturn(parentWorkOrderCountOfWorkStepRecords);
        mocks.when(
                workStepsSelectorMock.getWorkStepsCountFilteredByConditionGroupedByParentAndStatus(
                    ULTIMATE_PARENT_WORK_PLAN_CONDITION,
                    ULTIMATE_PARENT_WORK_PLAN_GROUPBYFIELD,
                    new Set<Id>{ workStepWorkPlanParentId }
                )
            )
            .thenReturn(parentWorkPlanCountOfWorkStepRecords);
        mocks.when(
                workStepsSelectorMock.getWorkStepsCountFilteredByConditionGroupedByParentAndStatus(
                    ULTIMATE_PARENT_WORK_STEP_CONDITION,
                    ULTIMATE_PARENT_WORK_STEP_GROUPBYFIELD,
                    new Set<Id>{ workStepParentId }
                )
            )
            .thenReturn(parentWorkStepCountOfWorkStepRecords);
        mocks.when(workOrdersSelectorMock.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                workOrdersSelectorMock.selectWorkOrdersAndWorkStepsUsingWorkOrderIds(
                    new Set<Id>{ mockWorkOrder.Id }
                )
            )
            .thenReturn(workOrderWithWorkSteps);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(workOrdersSelectorMock);
        Application.SELECTOR.setMock(workStepsSelectorMock);
        WorkStepsService.runWorkStepStatusCalculationsOnParentRecords(parentIds);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{ WorkOrder.Status => STATUS_IN_PROGRESS },
                        new Map<SObjectField, Object>{ WorkPlan.Status__c => STATUS_READY_FOR_QA },
                        new Map<SObjectField, Object>{ WorkStep.Status__c => STATUS_READY_FOR_QA }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test parent Work Order/Plan/Step's status updated when
     * only child Work Order Ids are provided.
     */
    @isTest
    private static void testWhenChildWorkOrderIdsPassedThenStatusOnUltimateParentWorkRecordsUpdated() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id parentWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id childWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id childWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id childWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                ACCOUNT_PRIMARY_VERTICAL_PREMIUM,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Id, businessAccountId);
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_PREMIUM
            )
            .setField(Account.Id, storeAccountId)
            .setField(Account.ParentId, parentAccount.Id)
            .setParent('Parent', parentAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = (Fake) ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                WORKORDER_TYPE_STOREFRONT
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setParent('Account', parentAccountFakeInstance);
        WorkPlanTemplate mockWorkPlanTemplate = (WorkPlanTemplate) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createWorkPlanTemplateFakeInstance(
                WORKORDER_TYPE_STOREFRONT,
                WORK_PLAN_TEMPLATE_RELATIVE_EXECUTION_ORDER
            )
        );
        mockWorkPlanTemplate.Work_Plan_Default_Status__c = STATUS_NOT_WORKABLE;
        Fake parentWorkPlanFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstanceWithProvidedWorkPlanTemplate(
                parentWorkOrderId,
                mockWorkPlanTemplate
            )
            .setField(WorkPlan.Id, parentWorkPlanId);
        WorkPlan parentWorkPlan = (WorkPlan) ServiceMockDataBuilder.convertToSObject(
            parentWorkPlanFakeInstance
        );
        Fake parentWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
                STATUS_NOT_WORKABLE
            )
            .setField(WorkStep.Id, parentWorkStepId)
            .setField(WorkStep.Status, STATUS_NOT_WORKABLE)
            .setField(WorkStep.ExecutionOrder, EXECUTION_ORDER_FIRST)
            .setField(WorkStep.Parent_Work_Step__c, null)
            .setField(WorkStep.WorkPlanId, parentWorkPlan.Id)
            .setParent('WorkPlan', parentWorkPlanFakeInstance);
        WorkStep parentWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            parentWorkStepFakeInstance
        );
        Fake childWorkOrderFakeInstance = (Fake) ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_STOREFRONT
            )
            .setField(WorkOrder.Id, childWorkOrderId)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrderId)
            .setParent('Account', storeAccountFakeInstance)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        Fake childWorkPlanFakeInstance = ServiceMockDataBuilder.createWorkPlanFakeInstanceWithProvidedWorkPlanTemplate(
                childWorkOrderId,
                mockWorkPlanTemplate
            )
            .setField(WorkPlan.Id, childWorkPlanId)
            .setField(WorkPlan.Parent_Work_Plan__c, parentWorkPlanId)
            .setParent('Parent_Work_Plan__r', parentWorkPlanFakeInstance);
        WorkPlan childWorkPlan = (WorkPlan) ServiceMockDataBuilder.convertToSObject(
            childWorkPlanFakeInstance
        );
        Fake childWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
                STATUS_BLOCKED
            )
            .setField(WorkStep.Id, childWorkStepId)
            .setField(WorkStep.Status, STATUS_BLOCKED)
            .setField(WorkStep.Status_Reason__c, STATUS_REASON_OTHER)
            .setField(WorkStep.ExecutionOrder, EXECUTION_ORDER_FIRST)
            .setField(WorkStep.Store_Account__c, storeAccount.Id)
            .setField(WorkStep.Parent_Work_Step__c, parentWorkStep.Id)
            .setField(WorkStep.WorkPlanId, childWorkPlan.Id)
            .setParent('WorkPlan', childWorkPlanFakeInstance)
            .setParent('Parent_Work_Step__r', parentWorkStepFakeInstance);
        childWorkOrderFakeInstance
            .setChildren('WorkSteps', new List<Fake>{ childWorkStepFakeInstance });
        parentWorkOrderFakeInstance
            .setChildren('WorkSteps', new List<Fake>{ parentWorkStepFakeInstance });
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        List<Work_Step_Status_Mapping__mdt> mockCustomMetadata = new List<Work_Step_Status_Mapping__mdt>{
            new Work_Step_Status_Mapping__mdt(
                Operator__c = METADATA_CONTAINS_OPERATOR,
                Sequence__c = METADATA_SEQUENCE,
                Status_To_Apply__c = STATUS_BLOCKED,
                Status__c = STATUS_BLOCKED
            )
        };
        List<Aggregate> parentWorkOrderCountOfWorkStepRecords = new List<Aggregate>{
            new Aggregate()
                .put(ULTIMATE_PARENT_AGGREGATE_QUERY_GROUPBYFIELD_ALIAS, parentWorkOrderId)
                .put(ULTIMATE_PARENT_AGGREGATE_QUERY_COUNT_ALIAS, 1)
                .put(ULTIMATE_PARENT_AGGREGATE_QUERY_STATUS_ALIAS, STATUS_BLOCKED)
        };
        List<Aggregate> parentWorkStepCountOfWorkStepRecords = new List<Aggregate>{
            new Aggregate()
                .put(ULTIMATE_PARENT_AGGREGATE_QUERY_GROUPBYFIELD_ALIAS, parentWorkStepId)
                .put(ULTIMATE_PARENT_AGGREGATE_QUERY_COUNT_ALIAS, 1)
                .put(ULTIMATE_PARENT_AGGREGATE_QUERY_STATUS_ALIAS, STATUS_BLOCKED)
        };
        List<Aggregate> parentWorkPlanCountOfWorkStepRecords = new List<Aggregate>{
            new Aggregate()
                .put(ULTIMATE_PARENT_AGGREGATE_QUERY_GROUPBYFIELD_ALIAS, parentWorkPlanId)
                .put(ULTIMATE_PARENT_AGGREGATE_QUERY_COUNT_ALIAS, 1)
                .put(ULTIMATE_PARENT_AGGREGATE_QUERY_STATUS_ALIAS, STATUS_BLOCKED)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkOrdersSelector mockWorkOrdersSelector = (WorkOrdersSelector) mocks.mock(
            WorkOrdersSelector.class
        );
        IWorkStepsSelector workStepsSelectorMock = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        IWorkStepStatusMappingsSelector mockWorkStepStatusMappingSelector = (IWorkStepStatusMappingsSelector) mocks.mock(
            IWorkStepStatusMappingsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepStatusMappingSelector.sObjectType())
            .thenReturn(Work_Step_Status_Mapping__mdt.SObjectType);
        mocks.when(mockWorkStepStatusMappingSelector.getAllValues()).thenReturn(mockCustomMetadata);
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersAndWorkStepsUsingWorkOrderIds(
                    new Set<Id>{ childWorkOrderId }
                )
            )
            .thenReturn(new List<WorkOrder>{ childWorkOrder });
        mocks.when(workStepsSelectorMock.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                workStepsSelectorMock.getWorkStepsCountFilteredByConditionGroupedByParentAndStatus(
                    ULTIMATE_PARENT_WORK_ORDER_CONDITION,
                    ULTIMATE_PARENT_WORK_ORDER_GROUPBYFIELD,
                    new Set<Id>{ parentWorkOrderId }
                )
            )
            .thenReturn(parentWorkOrderCountOfWorkStepRecords);
        mocks.when(
                workStepsSelectorMock.getWorkStepsCountFilteredByConditionGroupedByParentAndStatus(
                    ULTIMATE_PARENT_WORK_PLAN_CONDITION,
                    ULTIMATE_PARENT_WORK_PLAN_GROUPBYFIELD,
                    new Set<Id>{ parentWorkPlanId }
                )
            )
            .thenReturn(parentWorkPlanCountOfWorkStepRecords);
        mocks.when(
                workStepsSelectorMock.getWorkStepsCountFilteredByConditionGroupedByParentAndStatus(
                    ULTIMATE_PARENT_WORK_STEP_CONDITION,
                    ULTIMATE_PARENT_WORK_STEP_GROUPBYFIELD,
                    new Set<Id>{ parentWorkStepId }
                )
            )
            .thenReturn(parentWorkStepCountOfWorkStepRecords);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(workStepsSelectorMock);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockWorkStepStatusMappingSelector);
        WorkStepsService.runWorkStepStatusCalculationsOnParentRecords(
            new Set<Id>{ childWorkOrderId }
        );
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            List<SObject>.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty((List<SObject>) capturedInsertUOWArguments.capture());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        List<SObject> capturedArguments = (List<SObject>) capturedInsertUOWArguments.getValue();
        System.assertEquals(
            5,
            capturedArguments.size(),
            UPDATE_COUNT_DOES_NOT_MATCH_ASSERT_MESSAGE
        );
        for (SObject eachcapturedArgument : capturedArguments) {
            Id capturedId = (Id) eachcapturedArgument.get(ID_FIELD_API_NAME);
            switch on String.valueOf(capturedId.getSObjectType()) {
                when 'WorkOrder' {
                    System.assertEquals(
                        STATUS_AT_RISK,
                        eachcapturedArgument.get(WORK_ORDER_STATUS_FIELD_API_NAME),
                        ASSERT_MESSAGE_STATUS_NOT_UPDATED
                    );
                }
                when 'WorkPlan', 'WorkStep' {
                    System.assertEquals(
                        STATUS_BLOCKED,
                        eachcapturedArgument.get(STATUS_FIELD_API_NAME),
                        ASSERT_MESSAGE_STATUS_NOT_UPDATED
                    );
                }
            }
        }
    }

    /**
     * @description To test workstep updates, check the 'Click N Pop Eligible' checkbox and the 'Original Status Reason and Details' fields.
     * when the status of a workstep is changed to 'blocked'.
     * @jira LEM-13961
     */
    @isTest
    private static void testWhenParentWorkStepStatusChangedThenUpdateClickAndPopupCheckbox() {
        Id workStepId1 = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workStepId2 = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workStepId3 = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id businessFriendlyMappingId = fflib_IDGenerator.generate(
            Business_Friendly_Mapping__mdt.SObjectType
        );
        Status_Reason_And_Details_Mapping__mdt statusReasonAndDetailsMappings = (Status_Reason_And_Details_Mapping__mdt) new Fake(
                Status_Reason_And_Details_Mapping__mdt.class
            )
            .setField(Status_Reason_And_Details_Mapping__mdt.Status__c, STATUS_BLOCKED)
            .setField(Status_Reason_And_Details_Mapping__mdt.Status_Reason__c, STATUS_REASON_OTHER)
            .setField(Status_Reason_And_Details_Mapping__mdt.Type__c, WORK_STEP_SETUP_STORE)
            .setField(
                Status_Reason_And_Details_Mapping__mdt.Quick_Action_Name__c,
                WORKSTEP_QUICK_ACTION_NAME
            )
            .setField(
                Status_Reason_And_Details_Mapping__mdt.Business_Friendly_Mapping__c,
                businessFriendlyMappingId
            )
            .setParent(
                'Business_Friendly_Mapping__r',
                new Fake(Business_Friendly_Mapping__mdt.class)
                    .setField(Business_Friendly_Mapping__mdt.id, businessFriendlyMappingId)
                    .setField(
                        Business_Friendly_Mapping__mdt.Integration_Key_String__c,
                        'required key [accountCurrency] not found'
                    )
                    .setField(
                        Business_Friendly_Mapping__mdt.Integration_Type__c,
                        'Xref Provisioning'
                    )
                    .setField(
                        Business_Friendly_Mapping__mdt.Message_Category__c,
                        'Missing Data - Currency'
                    )
                    .setField(
                        Business_Friendly_Mapping__mdt.Business_Friendly_Message__c,
                        GLOBAL_DO_NOT_ACTIVATE_INTEGRATION_MESSAGE
                    )
                    .setField(Business_Friendly_Mapping__mdt.Order__c, 40)
                    .setField(Business_Friendly_Mapping__mdt.Active__c, true)
            )
            .setFakeId()
            .toSObject();

        List<WorkStep> workSteps = new List<WorkStep>{
            new WorkStep(
                Id = workStepId1,
                Status = STATUS_BLOCKED,
                Status__c = STATUS_BLOCKED,
                Status_Reason__c = STATUS_REASON_OTHER,
                Type__c = WORK_STEP_SETUP_STORE,
                Status_Reason_Details__c = GLOBAL_DO_NOT_ACTIVATE_INTEGRATION_MESSAGE
            ),
            new WorkStep(
                Id = workStepId2,
                Status = STATUS_BLOCKED,
                Status__c = STATUS_BLOCKED,
                Status_Reason__c = STATUS_REASON_OTHER,
                Type__c = WORK_STEP_SETUP_STORE
            ),
            new WorkStep(
                Id = workStepId3,
                Status = STATUS_BLOCKED,
                Status__c = STATUS_BLOCKED,
                Status_Reason__c = '',
                Type__c = ''
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStatusReasonAndDetailsMappingsSelector mockStatusReasonsSelector = (IStatusReasonAndDetailsMappingsSelector) mocks.mock(
            IStatusReasonAndDetailsMappingsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockStatusReasonsSelector.sObjectType())
            .thenReturn(Status_Reason_And_Details_Mapping__mdt.SObjectType);
        mocks.when(mockStatusReasonsSelector.getAllMappings())
            .thenReturn(
                new List<Status_Reason_And_Details_Mapping__mdt>{ statusReasonAndDetailsMappings }
            );
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockStatusReasonsSelector);

        WorkStepsService.updatePopnClickOnWorkStepStatusChange(workSteps);

        System.assertEquals(workSteps[0].Click_N_Pop_Eligible__c, true, '');
        System.assertEquals(
            workSteps[0].Original_Status_Reason_and_Details__c,
            GLOBAL_DO_NOT_ACTIVATE_INTEGRATION_MESSAGE,
            ''
        );
    }

    @IsTest
    static void testWhenWorkStepsAreCompleteThenUpdateStripeStatusReasons() {
        WorkStep completeWorkStepMultipleStatuses = new WorkStep(
            Name = WORK_STEP_SETUP_BANKING,
            Type__c = WORK_STEP_SETUP_BANKING,
            Status__c = STATUS_COMPLETE,
            Status_Reason__c = STATUS_REASON_KYC_PENDING + ';' + STATUS_REASON_KYC_SUCCESS
        );
        WorkStep completeWorkStepSingleStatus = new WorkStep(
            Name = WORK_STEP_SETUP_BANKING,
            Type__c = WORK_STEP_SETUP_BANKING,
            Status__c = STATUS_COMPLETE,
            Status_Reason__c = STATUS_REASON_KYC_PENDING
        );
        WorkStep inProgressWorkStep = new WorkStep(
            Name = WORK_STEP_SETUP_BANKING,
            Type__c = WORK_STEP_SETUP_BANKING,
            Status__c = STATUS_IN_PROGRESS,
            Status_Reason__c = STATUS_REASON_KYC_PENDING
        );
        WorkStep nonSetupBankingWorkStep = new WorkStep(
            Name = WORK_STEP_SETUP_STORE,
            Type__c = WORK_STEP_SETUP_STORE,
            Status__c = STATUS_COMPLETE,
            Status_Reason__c = STATUS_REASON_OTHER
        );

        // Verify a Completed Work Step has its "Pending" Status Reason removed
        WorkStepsService.handleCompletionStatusReasonUpdates(completeWorkStepMultipleStatuses);
        System.assertEquals(
            STATUS_REASON_KYC_SUCCESS,
            completeWorkStepMultipleStatuses.Status_Reason__c,
            'The Pending Status Reason should have been removed and the `Stripe KYC Verification Successful` Status Reason should remain on the WorkStep!'
        );

        // Verify a Completed Work Step has its "Pending" Status Reason removed when it's the only SR
        WorkStepsService.handleCompletionStatusReasonUpdates(completeWorkStepSingleStatus);
        System.assertEquals(
            STATUS_REASON_KYC_SUCCESS,
            completeWorkStepSingleStatus.Status_Reason__c,
            'The Pending Status Reason should be removed and the Status Reason should be updated to Success'
        );

        // Verify an In Progress Work Step has its "Pending" Status Reason remain
        WorkStepsService.handleCompletionStatusReasonUpdates(inProgressWorkStep);
        System.assertEquals(
            STATUS_REASON_KYC_PENDING,
            inProgressWorkStep.Status_Reason__c,
            'WorkSteps that are not completed should have Pending kept as a Status Reason'
        );
        System.assert(
            !inProgressWorkStep.Status_Reason__c.contains(STATUS_REASON_KYC_SUCCESS),
            'WorkSteps that are not completed should not be updated to a Successful Status Reason'
        );

        // Verify this only works for Setup Banking Work Steps
        WorkStepsService.handleCompletionStatusReasonUpdates(nonSetupBankingWorkStep);
        System.assertEquals(
            STATUS_REASON_OTHER,
            nonSetupBankingWorkStep.Status_Reason__c,
            'The WorkStep should not have been updated in this scenario'
        );
    }
    /**
     * @description To test creation of request payload when parent Activation checklist Work Step Ids received.
     */
    @isTest
    private static void testWhenActivationChecklistWorkStepIdsPassedThenCollectStoreDetailsForRequestPayload() {
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id parentWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id childWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id childWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id businessReferenceId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);

        Fake xrefInstance = new Fake(Xref__c.class)
            .setField(Xref__c.Id, xrefId)
            .setField(Xref__c.External_ID__c, EXTERNAL_ID)
            .setField(Xref__c.Business_Reference__c, businessReferenceId)
            .setField(Xref__c.Salesforce_Account_Name__c, storeAccountId);

        Fake childWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
                STATUS_NOT_STARTED
            )
            .setField(WorkStep.Id, childWorkStepId)
            .setField(WorkStep.Type__c, WORK_STEP_TYPE_ACTIVATION_CHECKLIST)
            .setField(WorkStep.Store_Account__c, storeAccountId)
            .setField(WorkStep.Parent_Work_Step__c, parentWorkStepId)
            .setField(WorkStep.WorkPlanId, childWorkPlanId)
            .setParent(
                'WorkPlan',
                new Fake(WorkPlan.class)
                    .setField(WorkPlan.Id, childWorkPlanId)
                    .setField(WorkPlan.Business_ID__c, EXTERNAL_ID)
                    .setParent('Xref__r', xrefInstance)
            )
            .setParent(
                'Parent_Work_Step__r',
                new Fake(WorkStep.class)
                    .setField(WorkStep.Id, parentWorkStepId)
                    .setField(WorkStep.WorkPlanId, parentWorkPlanId)
            );

        WorkStep childWorkStep = (WorkStep) ServiceMockDataBuilder.convertToSObject(
            childWorkStepFakeInstance
        );
        Xref__c xrefRecord = (Xref__c) ServiceMockDataBuilder.convertToSObject(xrefInstance);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkStepsSelector workStepsSelectorMock = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        IStaticConfigurationsSelector mockStaticConfigurationsSelector = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        IActivationChecklistService mockActivationChecklistService = (IActivationChecklistService) mocks.mock(
            IActivationChecklistService.class
        );
        IXrefsSelector xrefsSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        mocks.startStubbing();
        mocks.when(mockStaticConfigurationsSelector.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(xrefsSelectorMock.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    WORK_STEP_STATUS_ROLLUP_RETRY_LIMIT_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = WORK_STEP_STATUS_ROLLUP_RETRY_LIMIT_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    CHILD_WORK_STEPS_TO_UPDATE_EVENT_CHUNK_SIZE
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = CHILD_WORK_STEPS_TO_UPDATE_EVENT_CHUNK_SIZE,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    ACTIVATION_CHECKLIST_VALIDATIONS_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = ACTIVATION_CHECKLIST_VALIDATIONS_STATIC_CONFIG,
                    Configuration_Value__c = ACTIVATION_CHECKLIST_VALIDATIONS
                )
            );
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    ACTIVATION_CHECKLIST_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = ACTIVATION_CHECKLIST_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(xrefsSelectorMock.selectBySalesforceAccountName(new Set<Id>{ storeAccountId }))
            .thenReturn(new List<Xref__c>{ xrefRecord });
        mocks.when(workStepsSelectorMock.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                workStepsSelectorMock.selectChildWorkStepsByParentWorkStepIds(
                    new Set<Id>{ parentWorkStepId }
                )
            )
            .thenReturn(new List<WorkStep>{ childWorkStep });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        Application.SELECTOR.setMock(workStepsSelectorMock);
        Application.SERVICE.setMock(
            IActivationChecklistService.class,
            mockActivationChecklistService
        );
        WorkStepsService.collectChildActivationChecklistWorkStepsForOutboundIntegration(
            new Set<Id>{ parentWorkStepId }
        );
        fflib_ArgumentCaptor capturedPayloads = fflib_ArgumentCaptor.forClass(List<String>.class);
        ((IActivationChecklistService) mocks.verify(mockActivationChecklistService, 1))
            .generatePayloadAndInitiateOutboundIntegration(
                (List<ActivationChecklistOutboundWrapper.ActivationChecklistDetails>) capturedPayloads.capture()
            );
        List<ActivationChecklistOutboundWrapper.ActivationChecklistDetails> capturedPayloadArguments = (List<ActivationChecklistOutboundWrapper.ActivationChecklistDetails>) capturedPayloads.getValue();
        System.assertEquals(
            EXECUTION_ORDER_FIRST,
            capturedPayloadArguments.size(),
            PAYLOAD_NOT_GENERATED_ERROR_MESSAGE
        );
    }

    /**
     * @description To test WorkStep status update based on passed WorkStep Ids and Status value.
     */
    @isTest
    private static void testWhenWorkStepIdsPassedWithStatusThenUpdateWorkStepsStatus() {
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkStepsSelector workStepsSelectorMock = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        mocks.startStubbing();
        mocks.when(workStepsSelectorMock.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(workStepsSelectorMock.selectByIds(new Set<Id>{ workStepId }))
            .thenReturn(new List<WorkStep>{ new WorkStep(Id = workStepId) });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(workStepsSelectorMock);
        WorkStepsService.updateActivationChecklistWorkStepsStatus(
            new Set<Id>{ workStepId },
            false,
            STATUS_IN_PROGRESS
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                new List<WorkStep>{
                    new WorkStep(
                        Id = workStepId,
                        Status__c = STATUS_IN_PROGRESS,
                        Status_Reason__c = '',
                        Status_Reason_Details__c = ''
                    )
                }
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test WorkStep Status not updated when Completed WorkStep Ids are passed
     * for Status update.
     *
    @isTest
    private static void testWhenCompletedWorkStepIdsPassedWithStatusThenWorkStepsStatusNotUpdated() {
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkStepsSelector workStepsSelectorMock = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        mocks.startStubbing();
        mocks.when(workStepsSelectorMock.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(workStepsSelectorMock.selectByIds(new Set<Id>{ workStepId }))
            .thenReturn(
                new List<WorkStep>{ new WorkStep(Id = workStepId, Status__c = STATUS_COMPLETE) }
            );
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(workStepsSelectorMock);
        Test.startTest();
        WorkStepsService.updateActivationChecklistWorkStepsStatus(
            new Set<Id>{ workStepId },
            false,
            STATUS_ESCALATED
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }*/

    /**
     * @description To test parent WorkStep Status Reason not updated when Completed WorkStep Ids are passed
     * for Status update.
     *
    @isTest
    private static void testWhenCompletedParentWorkStepIdsPassedWithStatusThenWorkStepsStatusNotUpdated() {
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id parentWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        WorkStep mockWorkStep = (WorkStep) new Fake(WorkStep.class)
            .setField(WorkStep.Id, workStepId)
            .setField(WorkStep.Status__c, STATUS_IN_PROGRESS)
            .setField(WorkStep.Parent_Work_Step__c, parentWorkStepId)
            .setParent(
                'Parent_Work_Step__r',
                new Fake(WorkStep.class)
                    .setField(WorkStep.Id, parentWorkStepId)
                    .setField(WorkStep.Status__c, STATUS_COMPLETE)
            )
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkStepsSelector workStepsSelectorMock = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        mocks.startStubbing();
        mocks.when(workStepsSelectorMock.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(workStepsSelectorMock.selectByIds(new Set<Id>{ workStepId }))
            .thenReturn(new List<WorkStep>{ mockWorkStep });mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(workStepsSelectorMock);
        Test.startTest();
        WorkStepsService.updateActivationChecklistWorkStepsStatus(
            new Set<Id>{ workStepId },
            false,
            STATUS_ESCALATED
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }*/

    /**
     * @description To test when Store Id and Business Vertification Details passed then WorkStep
     * status updated.
     */
    @isTest
    private static void testWhenStoreIdsAndBusinessVerificationDetailsPassedThenUpdateWorkStepsStatus() {
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Map<String, BusinessVerficationDetails> storeIdsToBusinessVertificationDetails = new Map<String, BusinessVerficationDetails>();
        Map<Id, String> salesforceAccountIdToStoreId = new Map<Id, String>();
        BusinessVerficationDetails storeData;
        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_BUSINESS_VERIFICATION_JSON
        ];
        Blob blobJSON = staticResource.Body;
        Map<String, Object> payloadString = (Map<String, Object>) JSON.deserializeUntyped(
            blobJSON.toString()
        );
        storeData = new BusinessVerficationDetails((String) payloadString.get(STORE_ID));
        storeData.businessVerificationDetails = (BusinessVerficationDetails.BusinessVerificationStatusDetails) JSON.deserialize(
            JSON.serialize(payloadString.get(BUSINESS_VERIFICATION)),
            BusinessVerficationDetails.BusinessVerificationStatusDetails.class
        );
        storeIdsToBusinessVertificationDetails.put((String) payloadString.get(STORE_ID), storeData);
        salesforceAccountIdToStoreId.put(accountId, (String) payloadString.get(STORE_ID));
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkStepsSelector workStepsSelectorMock = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        mocks.startStubbing();
        mocks.when(workStepsSelectorMock.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                workStepsSelectorMock.selectWorkStepsByTypesAndStoreAccountIds(
                    new Set<Id>{ accountId },
                    new Set<String>{ WORKSTEP_TYPE_REVIEW_AND_TRIAGE }
                )
            )
            .thenReturn(new List<WorkStep>{ new WorkStep(Id = workStepId) });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(workStepsSelectorMock);
        Test.startTest();
        WorkStepsService.updateWorkStepsStatusDetailsByBusinessVerificationStatusDetails(
            new Set<Id>{ accountId },
            salesforceAccountIdToStoreId,
            storeIdsToBusinessVertificationDetails
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description To test WorkStep Status not updated when Blocked WorkStep Ids are passed
     * for Status update.
     *
    @isTest
    private static void testWhenBlockedWorkStepIdsPassedWithStatusThenWorkStepsStatusNotUpdated() {
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkStepsSelector workStepsSelectorMock = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        mocks.startStubbing();
        mocks.when(workStepsSelectorMock.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(workStepsSelectorMock.selectByIds(new Set<Id>{ workStepId }))
            .thenReturn(
                new List<WorkStep>{ new WorkStep(Id = workStepId, Status__c = STATUS_BLOCKED) }
            );
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(workStepsSelectorMock);
        Test.startTest();
        WorkStepsService.updateActivationChecklistWorkStepsStatus(
            new Set<Id>{ workStepId },
                false,
                STATUS_ESCALATED
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }*/

    /**
     * @description To test when Store Id and Business Vertification Details passed then WorkStep
     * status not updated.
     */
    @isTest
    private static void testWhenStoreIdsAndBusinessVerificationDetailsPassedThenDoNotUpdateWorkStepsStatus() {
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Map<String, BusinessVerficationDetails> storeIdsToBusinessVertificationDetails = new Map<String, BusinessVerficationDetails>();
        Map<Id, String> salesforceAccountIdToStoreId = new Map<Id, String>();
        BusinessVerficationDetails storeData;
        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_BUSINESS_VERIFICATION_JSON
        ];
        Blob blobJSON = staticResource.Body;
        Map<String, Object> payloadString = (Map<String, Object>) JSON.deserializeUntyped(
            blobJSON.toString()
        );
        storeData = new BusinessVerficationDetails((String) payloadString.get(STORE_ID));
        storeData.businessVerificationDetails = (BusinessVerficationDetails.BusinessVerificationStatusDetails) JSON.deserialize(
            JSON.serialize(payloadString.get(BUSINESS_VERIFICATION)),
            BusinessVerficationDetails.BusinessVerificationStatusDetails.class
        );
        storeIdsToBusinessVertificationDetails.put((String) payloadString.get(STORE_ID), storeData);
        salesforceAccountIdToStoreId.put(accountId, (String) payloadString.get(STORE_ID));
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkStepsSelector workStepsSelectorMock = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        mocks.startStubbing();
        mocks.when(workStepsSelectorMock.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                workStepsSelectorMock.selectWorkStepsByTypesAndStoreAccountIds(
                    new Set<Id>{ accountId },
                    new Set<String>{ WORKSTEP_TYPE_REVIEW_AND_TRIAGE }
                )
            )
            .thenReturn(new List<WorkStep>{ new WorkStep(Id = workStepId) });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(workStepsSelectorMock);
        Test.startTest();
        WorkStepsService.updateWorkStepsStatusDetailsByBusinessVerificationStatusDetails(
            new Set<Id>{ accountId },
            salesforceAccountIdToStoreId,
            storeIdsToBusinessVertificationDetails
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }
}