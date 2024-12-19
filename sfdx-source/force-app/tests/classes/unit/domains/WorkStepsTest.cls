/**
 * @author Deloitte
 * @date 11/04/2022
 * @description Test class for WorkSteps class.
 */
@isTest(SeeAllData=false)
private class WorkStepsTest {
    private static final string ACCOUNT_NAME = 'Test McDonald Account';
    private static final string ACCOUNT_OWNER_EMAIL_ID = 'test@WorkStepsTest.com';
    private static final string ACCOUNT_OWNER_EMAIL_NOT_UPDATED_ASSERT_MESSAGE = 'Unexpected result: failed to updated Account owner email address on Work Step';
    private static final String ACCOUNT_PRIMARY_VERTICAL_PREMIUM = 'Grocery';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final string ACTIVATE_CENTRALLY = 'Yes';
    private static final String ACTIVATION_CHECKLIST_VALIDATIONS_STATIC_CONFIG = 'Activations_Checklist_Validations';
    private static final String ACTIVATION_CHECKLIST_VALIDATIONS = 'GET_STORE, GET_POINT_OF_SALE, GET_PAYMENT_ACCOUNT, GET_TAX_STRATEGY, GET_STORE_RETAIL, GET_STORE_ADDRESS_LINK, GET_MENU, GET_BUSINESS, GET_PRICING_PROGRAMS';
    private static final String AFTER_UPDATE_ASSERT_MESSAGE = 'Unexpected result: WorkSteps old map is null';
    private static final String ALLOW_WORK_STEP_STATUS_UPDATES = 'Allow_Work_Step_Status_Updates';
    private static final String BOOLEAN_STRING_TRUE = 'TRUE';
    private static final String CASE_STATUS_OPEN = 'Open';
    private static final String CHILD_WORK_STEPS_TO_UPDATE_CHUNK_SIZE = '40';
    private static final String CHILD_WORK_STEPS_TO_UPDATE_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG = 'Child_Work_Steps_Payload_Chunk_Size';
    private static final String CONSTRUCTOR_ASSERT_MESSAGE = 'Unexpected result: The objects are matching';
    private static final String ENABLE_ENT_TABLET_CASE_UPDATE_FLAG = 'Tablet_Case_Update_By_Platform_Event';
    private static final String ENABLE_TABLET_CASE_CREATION_FLAG = 'Tablet_Case_Create_By_Platform_Event';
    private static final String EXTERNAL_NOTIFIER_EVENT_TABLET_CASE_UPDATE_TOPIC = 'TABLET_CASE_UPDATE';
    private static final String EVENT_TOPIC_WORK_STEPS_CALCULATION = 'WORK_STEPS_RESCUE_PROCESS_CALCULATION';
    private static final String EVENT_TOPIC_WORK_STEPS_STATUS_ROLL_UP = 'WORK_STEPS_STATUS_ROLL_UP';
    private static final String EVENT_TOPIC_UPDATE_CHILD_WORKSTEPS_ON_PARENT = 'UPDATE_CHILD_WORKSTEPS_ON_PARENT';
    private static final String FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE = 'Unexpected result: the field is not updated with expected value';
    private static final String MENU_COMPLETED_BY = 'Account Owner';
    private static final String MENU_ERROR_TYPE_NOT_BLANKED_ASSERT_MESSAGE = 'Unexpected result: Menu Error Type is not blanked for valid record';
    private static final String MENU_ERROR_TYPE_BLANKED_ASSERT_MESSAGE = 'Unexpected result: Menu Error Type is blanked for invalid scenario';
    private static final String METADATA_INSTANCE_NAME = 'Tablet_Case_Eligible_Work_Order_Types';
    private static final String METADATA_VALUE = 'Marketplace';
    private static final String MOCK_FIGMENT_ID = 'WorkStepsTest_Figment_Id';
    private static final String MX_ORDER_TYPE_TABLET = 'Tablet';
    private static final String MX_ORDER_NAME = 'MX-0001';
    private static final String MX_ORDER_VENDOR_NAME = 'Denali';
    private static final String ORDER_STATUS_DRAFT = 'Draft';
    private static final string ORDER_PROTOCOL = 'Email';
    private static final String RESTRICT_STATUS_UPDATE_ASSERT_MESSAGE = 'Unexpected result: WorkStep status is restricted';
    private static final String RESTRICT_STATUS_UPDATE_NEGATIVE_ASSERT_MESSAGE = 'Unexpected result: WorkStep status is not restricted';
    private static final String RESTRICT_TABLET_CASE_NOTIFICATION = 'Restrict_Tablet_Case_Notification';
    private static final String RESTRICT_WORK_STEP_STATUS_UPDATES = 'Restrict_Work_Step_Status_Updates';
    private static final string STATUS_CONFIRMED = 'Confirmed';
    private static final String STATUS_NOT_CHANGED_ASSERT_MESSAGE = 'Unexpected Error: Work Step status is not changed';
    private static final String WORK_STEP_STATUS_ROLLUP_RETRY_LIMIT_STATIC_CONFIG = 'Work_Step_Status_Rollup_Retry_Limit';
    private static final String STATUS_REASON_NOT_BLANKED_ASSERT_MESSAGE = 'Unexpected result: Status Reason is not blanked for valid record';
    private static final String STATUS_REASON_DETAILS_NOT_BLANKED_ASSERT_MESSAGE = 'Unexpected result: Status Reason Details is not blanked for valid record';
    private static final String STATUS_ROLLUP_REEXECUTION_LIMIT_VALUE = '5';
    private static final String STATUS_UPDATE_ASSERT_MESSAGE = 'Unexpected result: WorkStep status not updated to Escalated';
    private static final String STATUS_UPDATE_NEGATIVE_ASSERT_MESSAGE = 'Unexpected result: WorkStep status changed to Escalated';
    private static final String STATUS_UPDATE_WITH_STATUS_REASON_ERROR_ASSERT_MESSAGE = 'Unexpected result: The error message was thrown for Work Step Status update with Status Reason';
    private static final String STATUS_UPDATE_WITHOUT_STATUS_REASON_ERROR_ASSERT_MESSAGE = 'Unexpected result: The error message was thrown for Work Step Status update without Status Reason';
    private static final String STATUS_NOT_STARTED = 'Not Started';
    private static final String TABLET_CASE_ELIGIBLE_WORK_ORDER_TYPES_STATIC_CONFIG = 'Tablet_Case_Eligible_Work_Order_Types';
    private static final String TYPE_DRIVE = 'Drive';
    private static final String VALIDATION_STATUS_IN_PROGRESS = 'In Progress';
    private static final String VERTICAL = 'Floral';
    private static final String WORK_ORDER_CREATION_SOURCE_PLACE_IT_FOR_ME = 'Place It For Me';
    private static final String WORK_ORDER_TYPE = 'Activations Checklist';
    private static final String WORKORDER_TYPE_STOREFRONT = 'Storefront';
    private static final String WORK_STEP_NAME_SETUP_BUSINESS = 'Setup Business';
    private static final String WORK_STEP_NAME_SETUP_MENU = 'Setup Menu';
    private static final String WORK_STEP_NAME_SETUP_STORE = 'Setup Store';
    private static final Integer WORK_STEP_PARENT_IDS_CHUNK_SIZE = 100;
    private static final String WORK_STEP_PARENT_IDS_CHUNK_SIZE_STATIC_CONFIG = 'Work_Steps_Status_Rollup_Chunk_Size';
    private static final String WORK_STEP_STATUS_ESCALATED = 'Escalated';
    private static final String WORK_STEP_STATUS_BLOCKED = 'Blocked';
    private static final String WORK_STEP_STATUS_COMPLETE = 'Complete';
    private static final String WORK_STEP_STATUS_DEAD = 'Dead';
    private static final String WORK_STEP_STATUS_IN_PROGRESS = 'In Progress';
    private static final String WORK_STEP_STATUS_NOT_STARTED = 'Not Started';
    private static final String WORK_STEP_STATUS_NOT_WORKABLE = 'Not Workable';
    private static final String WORK_STEP_STATUS_REASON_INVALID_ADDRESS = 'Invalid Address';
    private static final String WORK_STEP_STATUS_REASON_OTHER = 'Other';
    private static final String WORK_STEP_STATUS_RESOLVED = 'Resolved';
    private static final String WORK_STEP_MENU_ERROR_TYPE = 'Formatting';
    private static final String WORK_STEP_OLD_MENU_ERROR_TYPE = 'Duplicate Options';
    private static final String WORK_STEP_STATUS_COMPLETE_DD_TO_IMPLEMENT_LINK = 'Complete - DoorDash to implement link';
    private static final String WORK_STEP_STATUS_COMPLETE_IMPLEMENTED_ON_CALL = 'Complete - Implemented on the call';
    private static final String WORK_STEP_STATUS_COMPLETE_MX_TO_IMPLEMENT = 'Complete - Mx to implement link';
    private static final String WORK_STEP_TYPE_DELIVER_TABLET = 'Deliver Tablet';
    private static final String WORK_STEP_TYPE_IMPLEMENTATION_CALL = 'Implementation Call';
    private static final String WORK_STEP_TYPE_LINK_IMPLEMENTATION = 'Link Implementation';
    private static final String WORK_STEP_TYPE_SETUP_STORE = 'Setup Store';
    private static final String WORK_STEP_TYPE_SETUP_STOREFRONT_PAGE = 'Setup Storefront Page';
    private static final String WORK_STEPS_STATUS_ROLLUP_API_NAME = 'Work_Steps_Status_Rollup_Chunk_Size';
    private static final String WORK_STEPS_STATUS_ROLLUP_LABEL = 'Work Steps Status Rollup Chunk Size';
    private static final String TABLET_USERNAME = 'AccountsTest Username';
    private static final String TABLET_PASSWORD = 'AccountsTest Password';
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final String ASSERT_MESSAGE_ERROR_MESSAGE_MISMATCH = 'Exception message does not match';
    private static final string ACCOUNT_STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get(ACCOUNT_RECORD_TYPE_NAME_STORE)
        .getRecordTypeId();
    private static final String ACCOUNT_NAME_STORE = 'Store Account';

    /**
     * @description To test Contructor instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenRun() {
        List<WorkStep> workStepsList = new List<WorkStep>();
        WorkSteps.newInstance(workStepsList);
        WorkSteps workStepsObject = new WorkSteps(workStepsList);
        WorkSteps.Constructor constructorObject = new WorkSteps.Constructor();
        constructorObject.construct(workStepsList);
        System.assertNotEquals(
            WorkSteps.newInstance(workStepsList),
            workStepsObject,
            CONSTRUCTOR_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test copy custom Status Field value to Standard Status field on insert.
     */
    @isTest
    private static void testWhenInsertWorkStepThenValidateAndUpdateStatusToInprogress() {
        List<WorkStep> newWorkSteps = new List<WorkStep>{
            new WorkStep(
                Name = WORK_STEP_NAME_SETUP_MENU,
                WorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType),
                Menu_Error_Type__c = WORK_STEP_OLD_MENU_ERROR_TYPE,
                Status__c = WORK_STEP_STATUS_IN_PROGRESS,
                Type__c = WORK_ORDER_TYPE
            )
        };
        WorkSteps.newInstance(newWorkSteps).onBeforeInsertValidateAndUpdateWorkStepFields();
        System.assertEquals(
            WORK_STEP_STATUS_IN_PROGRESS,
            newWorkSteps[0].Status,
            STATUS_NOT_CHANGED_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test copy Custom Status Field value to Standard Status field on update.
     */
    @isTest
    private static void testWhenUpdateWorkStepThenValidateAndUpdateStatusToInprogress() {
        Id setupStoreWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        List<WorkStep> oldWorkSteps = new List<WorkStep>{
            new WorkStep(
                Id = setupStoreWorkStepId,
                Name = WORK_STEP_NAME_SETUP_STORE,
                WorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType),
                Status__c = WORK_STEP_STATUS_IN_PROGRESS,
                Type__c = WORK_STEP_NAME_SETUP_STORE
            )
        };
        List<WorkStep> newWorkSteps = new List<WorkStep>{
            new WorkStep(
                Id = setupStoreWorkStepId,
                Name = WORK_STEP_NAME_SETUP_STORE,
                WorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType),
                Status__c = WORK_STEP_STATUS_NOT_STARTED,
                Type__c = WORK_STEP_NAME_SETUP_STORE
            )
        };
        WorkSteps.newInstance(newWorkSteps)
            .onBeforeUpdateValidateAndUpdateWorkStepFields(new Map<Id, WorkStep>(oldWorkSteps));
        System.assertEquals(
            WORK_STEP_STATUS_NOT_STARTED,
            newWorkSteps[0].Status,
            STATUS_NOT_CHANGED_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test blanking of Menu Error Type when Escalation is resolved.
     */
    @isTest
    private static void testWhenWorkStepEscalationIsResolvedThenMenuErrorTypeIsBlanked() {
        Id escalatedSetupMenuWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id setupStoreWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        List<WorkStep> oldWorkSteps = new List<WorkStep>{
            new WorkStep(
                Id = escalatedSetupMenuWorkStepId,
                Name = WORK_STEP_NAME_SETUP_MENU,
                WorkPlanId = parentWorkPlanId,
                Menu_Error_Type__c = WORK_STEP_MENU_ERROR_TYPE,
                Status__c = WORK_STEP_STATUS_ESCALATED,
                Type__c = WORK_STEP_NAME_SETUP_MENU
            ),
            new WorkStep(
                Id = setupStoreWorkStepId,
                Name = WORK_STEP_NAME_SETUP_STORE,
                WorkPlanId = parentWorkPlanId,
                Menu_Error_Type__c = WORK_STEP_MENU_ERROR_TYPE,
                Status__c = WORK_STEP_STATUS_ESCALATED,
                Type__c = WORK_STEP_NAME_SETUP_STORE
            )
        };
        List<WorkStep> newWorkSteps = new List<WorkStep>{
            new WorkStep(
                Id = escalatedSetupMenuWorkStepId,
                Name = WORK_STEP_NAME_SETUP_MENU,
                WorkPlanId = parentWorkPlanId,
                Menu_Error_Type__c = WORK_STEP_MENU_ERROR_TYPE,
                Status__c = WORK_STEP_STATUS_NOT_STARTED,
                Type__c = WORK_STEP_NAME_SETUP_MENU
            ),
            new WorkStep(
                Id = setupStoreWorkStepId,
                Name = WORK_STEP_NAME_SETUP_STORE,
                WorkPlanId = parentWorkPlanId,
                Menu_Error_Type__c = WORK_STEP_MENU_ERROR_TYPE,
                Status__c = WORK_STEP_STATUS_NOT_STARTED,
                Type__c = WORK_STEP_NAME_SETUP_STORE
            )
        };
        WorkSteps.newInstance(newWorkSteps)
            .onBeforeUpdateValidateAndUpdateWorkStepFields(new Map<Id, WorkStep>(oldWorkSteps));
        System.assertEquals(
            null,
            newWorkSteps[0].Menu_Error_Type__c,
            MENU_ERROR_TYPE_NOT_BLANKED_ASSERT_MESSAGE
        );
        System.assertEquals(
            WORK_STEP_MENU_ERROR_TYPE,
            newWorkSteps[1].Menu_Error_Type__c,
            MENU_ERROR_TYPE_BLANKED_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test blanking of Menu Error Type when Work Step is moved
     * from Escalated to Blocked.
     */
    @isTest
    private static void testWhenWorkStepIsBlockedThenMenuErrorTypeIsNotBlanked() {
        Id escalatedSetupMenuWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        List<WorkStep> oldWorkSteps = new List<WorkStep>{
            new WorkStep(
                Id = escalatedSetupMenuWorkStepId,
                Menu_Error_Type__c = WORK_STEP_MENU_ERROR_TYPE,
                Name = WORK_STEP_NAME_SETUP_MENU,
                Status__c = WORK_STEP_STATUS_ESCALATED,
                Type__c = WORK_STEP_NAME_SETUP_MENU,
                WorkPlanId = parentWorkPlanId
            )
        };
        List<WorkStep> newWorkSteps = new List<WorkStep>{
            new WorkStep(
                Id = escalatedSetupMenuWorkStepId,
                Menu_Error_Type__c = WORK_STEP_MENU_ERROR_TYPE,
                Name = WORK_STEP_NAME_SETUP_MENU,
                Status__c = WORK_STEP_STATUS_BLOCKED,
                Type__c = WORK_STEP_NAME_SETUP_MENU,
                WorkPlanId = parentWorkPlanId
            )
        };
        WorkSteps.newInstance(newWorkSteps)
            .onBeforeUpdateValidateAndUpdateWorkStepFields(new Map<Id, WorkStep>(oldWorkSteps));
        System.assertEquals(
            WORK_STEP_MENU_ERROR_TYPE,
            newWorkSteps[0].Menu_Error_Type__c,
            MENU_ERROR_TYPE_BLANKED_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test blanking of Menu Error Type when WorkStep is unblocked.
     */
    @isTest
    private static void testWhenWorkStepIsUnblockedThenMenuErrorTypeIsBlanked() {
        Id blockedToInProgressSetupMenuWorkStepId = fflib_IDGenerator.generate(
            WorkStep.SObjectType
        );
        Id blockedToEscalatedSetupMenuWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id blockedsetupStoreWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        List<WorkStep> oldWorkSteps = new List<WorkStep>{
            new WorkStep(
                Id = blockedToInProgressSetupMenuWorkStepId,
                Menu_Error_Type__c = WORK_STEP_MENU_ERROR_TYPE,
                Name = WORK_STEP_NAME_SETUP_MENU,
                Status__c = WORK_STEP_STATUS_BLOCKED,
                Type__c = WORK_STEP_NAME_SETUP_MENU,
                WorkPlanId = parentWorkPlanId
            ),
            new WorkStep(
                Id = blockedsetupStoreWorkStepId,
                Menu_Error_Type__c = WORK_STEP_MENU_ERROR_TYPE,
                Name = WORK_STEP_NAME_SETUP_STORE,
                Status__c = WORK_STEP_STATUS_BLOCKED,
                Type__c = WORK_STEP_NAME_SETUP_STORE,
                WorkPlanId = parentWorkPlanId
            ),
            new WorkStep(
                Id = blockedToEscalatedSetupMenuWorkStepId,
                Menu_Error_Type__c = WORK_STEP_MENU_ERROR_TYPE,
                Name = WORK_STEP_NAME_SETUP_MENU,
                Status__c = WORK_STEP_STATUS_BLOCKED,
                Type__c = WORK_STEP_NAME_SETUP_MENU,
                WorkPlanId = parentWorkPlanId
            )
        };
        List<WorkStep> newWorkSteps = new List<WorkStep>{
            new WorkStep(
                Id = blockedToInProgressSetupMenuWorkStepId,
                Menu_Error_Type__c = WORK_STEP_MENU_ERROR_TYPE,
                Name = WORK_STEP_NAME_SETUP_MENU,
                Status__c = WORK_STEP_STATUS_IN_PROGRESS,
                Type__c = WORK_STEP_NAME_SETUP_MENU,
                WorkPlanId = parentWorkPlanId
            ),
            new WorkStep(
                Id = blockedsetupStoreWorkStepId,
                Menu_Error_Type__c = WORK_STEP_MENU_ERROR_TYPE,
                Name = WORK_STEP_NAME_SETUP_STORE,
                Status__c = WORK_STEP_STATUS_IN_PROGRESS,
                Type__c = WORK_STEP_NAME_SETUP_STORE,
                WorkPlanId = parentWorkPlanId
            ),
            new WorkStep(
                Id = blockedToEscalatedSetupMenuWorkStepId,
                Menu_Error_Type__c = WORK_STEP_MENU_ERROR_TYPE,
                Name = WORK_STEP_NAME_SETUP_MENU,
                Status__c = WORK_STEP_STATUS_ESCALATED,
                Type__c = WORK_STEP_NAME_SETUP_MENU,
                WorkPlanId = parentWorkPlanId
            )
        };
        WorkSteps.newInstance(newWorkSteps)
            .onBeforeUpdateValidateAndUpdateWorkStepFields(new Map<Id, WorkStep>(oldWorkSteps));
        System.assertEquals(
            null,
            newWorkSteps[0].Menu_Error_Type__c,
            MENU_ERROR_TYPE_NOT_BLANKED_ASSERT_MESSAGE
        );
        System.assertEquals(
            WORK_STEP_MENU_ERROR_TYPE,
            newWorkSteps[1].Menu_Error_Type__c,
            MENU_ERROR_TYPE_BLANKED_ASSERT_MESSAGE
        );
        System.assertEquals(
            WORK_STEP_MENU_ERROR_TYPE,
            newWorkSteps[2].Menu_Error_Type__c,
            MENU_ERROR_TYPE_BLANKED_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test handle related records on update.
     * TODO: Update with mock.verify() methods.
     */
    @isTest
    private static void testWhenUpdateThenHandleRelatedRecords() {
        Id setupMenuWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id setupStoreWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        List<WorkStep> oldWorkSteps = new List<WorkStep>{
            new WorkStep(
                Id = setupMenuWorkStepId,
                Name = WORK_STEP_NAME_SETUP_MENU,
                WorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType),
                Menu_Error_Type__c = WORK_STEP_OLD_MENU_ERROR_TYPE,
                Status__c = WORK_STEP_STATUS_IN_PROGRESS,
                Type__c = WORK_ORDER_TYPE
            ),
            new WorkStep(
                Id = setupStoreWorkStepId,
                Name = WORK_STEP_NAME_SETUP_STORE,
                WorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType),
                Status__c = WORK_STEP_STATUS_IN_PROGRESS,
                Type__c = WORK_ORDER_TYPE
            )
        };
        List<WorkStep> newWorkSteps = new List<WorkStep>{
            new WorkStep(
                Id = setupMenuWorkStepId,
                Name = WORK_STEP_NAME_SETUP_MENU,
                WorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType),
                Menu_Error_Type__c = WORK_STEP_MENU_ERROR_TYPE,
                Status__c = WORK_STEP_STATUS_NOT_STARTED,
                Type__c = WORK_ORDER_TYPE
            ),
            new WorkStep(
                Id = setupStoreWorkStepId,
                Name = WORK_STEP_NAME_SETUP_STORE,
                WorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType),
                Status__c = WORK_STEP_STATUS_NOT_STARTED,
                Type__c = WORK_ORDER_TYPE
            )
        };
        WorkSteps.newInstance(newWorkSteps)
            .onAfterUpdateHandleRelatedRecords(new Map<Id, WorkStep>(oldWorkSteps));
        System.assertEquals(false, oldWorkSteps.isEmpty(), AFTER_UPDATE_ASSERT_MESSAGE);
    }

    /**
     * @description To test when "Implementation Call" status is updated to
     * "Complete - Mx to implement link” WorkStep then
     * "Link Implementation" WorkStep Status is marked In Progress.
     * Suppressed Warnings since mock.veriyf() method is equivalent to System.assert statement.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenImplementationCallStatusUpdatedToCompleteMxToImplementLinkThenLinkImplementationStatusChangedToInProgress() {
        Id implementationCallWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id linkImplementationWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id parentWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);

        List<WorkStep> oldImplementationCallWorkSteps = new List<WorkStep>{
            new WorkStep(
                Id = implementationCallWorkStepId,
                Name = WORK_STEP_TYPE_IMPLEMENTATION_CALL,
                Status__c = WORK_STEP_STATUS_IN_PROGRESS,
                Type__c = WORK_STEP_TYPE_IMPLEMENTATION_CALL,
                WorkPlanId = workPlanId
            )
        };
        List<WorkStep> newImplementationCallWorkSteps = new List<WorkStep>{
            new WorkStep(
                Id = implementationCallWorkStepId,
                Name = WORK_STEP_TYPE_IMPLEMENTATION_CALL,
                Status__c = WORK_STEP_STATUS_COMPLETE_MX_TO_IMPLEMENT,
                Parent_Work_Step__c = parentWorkStepId,
                Type__c = WORK_STEP_TYPE_IMPLEMENTATION_CALL,
                WorkPlanId = workPlanId
            )
        };
        List<WorkStep> linkImplementationWorkSteps = new List<WorkStep>{
            new WorkStep(
                Id = linkImplementationWorkStepId,
                Name = WORK_STEP_TYPE_LINK_IMPLEMENTATION,
                Status__c = WORK_STEP_STATUS_NOT_STARTED,
                Type__c = WORK_STEP_TYPE_LINK_IMPLEMENTATION,
                WorkPlanId = workPlanId
            )
        };
        linkImplementationWorkSteps.addAll(newImplementationCallWorkSteps);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkStepsSelector mockWorkStepsSelector = (WorkStepsSelector) mocks.mock(
            WorkStepsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                mockWorkStepsSelector.selectLinkImplementationWorkStepAttachedToWorkPlan(
                    new Set<Id>{ workPlanId }
                )
            )
            .thenReturn(linkImplementationWorkSteps);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Test.startTest();
        WorkSteps.newInstance(newImplementationCallWorkSteps)
            .onAfterUpdateHandleRelatedRecords(
                new Map<Id, WorkStep>(oldImplementationCallWorkSteps)
            );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkStep.Id => linkImplementationWorkStepId,
                        WorkStep.Status__c => WORK_STEP_STATUS_IN_PROGRESS
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
    }

    /**
     * @description To test when "Implementation Call" status is updated to
     * “Complete - Implemented on the call” then
     * "Link Implementation" WorkStep Status is marked Complete.
     * Suppressed Warnings since mock.veriyf() method is equivalent to System.assert statement.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenImplementationCallStatusUpdatedToCompleteImplementedOnTheCallThenLinkImplementationStatusChangedToComplete() {
        Id implementationCallWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id linkImplementationWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id parentWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);

        List<WorkStep> oldImplementationCallWorkSteps = new List<WorkStep>{
            new WorkStep(
                Id = implementationCallWorkStepId,
                Name = WORK_STEP_TYPE_IMPLEMENTATION_CALL,
                Status__c = WORK_STEP_STATUS_IN_PROGRESS,
                Parent_Work_Step__c = parentWorkStepId,
                Type__c = WORK_STEP_TYPE_IMPLEMENTATION_CALL,
                WorkPlanId = workPlanId
            )
        };
        List<WorkStep> newImplementationCallWorkSteps = new List<WorkStep>{
            new WorkStep(
                Id = implementationCallWorkStepId,
                Name = WORK_STEP_TYPE_IMPLEMENTATION_CALL,
                Status__c = WORK_STEP_STATUS_COMPLETE_IMPLEMENTED_ON_CALL,
                Parent_Work_Step__c = parentWorkStepId,
                Type__c = WORK_STEP_TYPE_IMPLEMENTATION_CALL,
                WorkPlanId = workPlanId
            )
        };
        List<WorkStep> linkImplementationWorkSteps = new List<WorkStep>{
            new WorkStep(
                Id = linkImplementationWorkStepId,
                Name = WORK_STEP_TYPE_LINK_IMPLEMENTATION,
                Status__c = WORK_STEP_STATUS_IN_PROGRESS,
                Type__c = WORK_STEP_TYPE_LINK_IMPLEMENTATION,
                WorkPlanId = workPlanId
            )
        };
        linkImplementationWorkSteps.addAll(newImplementationCallWorkSteps);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkStepsSelector mockWorkStepsSelector = (WorkStepsSelector) mocks.mock(
            WorkStepsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                mockWorkStepsSelector.selectLinkImplementationWorkStepAttachedToWorkPlan(
                    new Set<Id>{ workPlanId }
                )
            )
            .thenReturn(linkImplementationWorkSteps);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Test.startTest();
        WorkSteps.newInstance(newImplementationCallWorkSteps)
            .onAfterUpdateHandleRelatedRecords(
                new Map<Id, WorkStep>(oldImplementationCallWorkSteps)
            );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkStep.Id => linkImplementationWorkStepId,
                        WorkStep.Status__c => WORK_STEP_STATUS_COMPLETE
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
    }

    /**
     * @description To test WorkStep completions updates dependent WorkStep Status to Not Started.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenWorkStepIsCompleteThenUpdateDependentWorkStepToNotStarted() {
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workStepDependencyTemplateId = fflib_IDGenerator.generate(
            WorkStepDependencyTemplate__c.SObjectType
        );
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        WorkStep oldWorkStep = new WorkStep(
            Id = workStepId,
            Name = WORK_STEP_NAME_SETUP_BUSINESS,
            Status__c = WORK_STEP_STATUS_IN_PROGRESS,
            Type__c = WORK_STEP_NAME_SETUP_BUSINESS
        );
        WorkStep newWorkStep = new WorkStep(
            Id = workStepId,
            Name = WORK_STEP_NAME_SETUP_BUSINESS,
            Status__c = WORK_STEP_STATUS_COMPLETE,
            Type__c = WORK_STEP_NAME_SETUP_BUSINESS
        );
        WorkStep dependentWorkStep = new WorkStep(
            Id = fflib_IDGenerator.generate(WorkStep.SObjectType),
            Status__c = WORK_STEP_STATUS_NOT_WORKABLE
        );
        WorkStepDependency__c workStepDependency = (WorkStepDependency__c) new Fake(
                WorkStepDependency__c.class
            )
            .setFakeId()
            .setField(WorkStepDependency__c.Dependee_Work_Step__c, newWorkStep.Id)
            .setField(WorkStepDependency__c.Dependent_Work_Step__c, dependentWorkStep.Id)
            .setField(
                WorkStepDependency__c.Work_Step_Dependency_Template__c,
                workStepDependencyTemplateId
            )
            .setParent(
                'Dependent_Work_Step__r',
                new Fake(WorkStep.class)
                    .setField(WorkStep.Id, dependentWorkStep.Id)
                    .setField(WorkStep.Name, WORK_STEP_TYPE_SETUP_STORE)
                    .setField(WorkStep.Status__c, WORK_STEP_STATUS_NOT_WORKABLE)
                    .setField(WorkStep.Type__c, WORK_STEP_TYPE_SETUP_STORE)
                    .setField(WorkStep.WorkOrderId, workOrderId)
                    .setField(WorkStep.WorkPlanId, workPlanId)
            )
            .toSObject();
        Map<Id, Set<String>> dependentWorkStepIdToDependeeWorkStepStatuses = new Map<Id, Set<String>>{
            dependentWorkStep.Id => new Set<String>{ WORK_STEP_STATUS_COMPLETE }
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkStepDependenciesService mockWorkStepDependenciesService = (IWorkStepDependenciesService) mocks.mock(
            IWorkStepDependenciesService.class
        );
        WorkStepDependenciesSelector mockWorkStepDependenciesSelector = (WorkStepDependenciesSelector) mocks.mock(
            WorkStepDependenciesSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepDependenciesSelector.sObjectType())
            .thenReturn(WorkStepDependency__c.SObjectType);
        mocks.when(
                mockWorkStepDependenciesSelector.selectDependenciesByDependeeWorkStepsIds(
                    new Set<Id>{ newWorkStep.Id }
                )
            )
            .thenReturn(new List<WorkStepDependency__c>{ workStepDependency });
        mocks.when(
                mockWorkStepDependenciesService.getSobjectIdToDependeeWorkStepStatuses(
                    new Set<Id>{ dependentWorkStep.Id },
                    WorkStep.SobjectType
                )
            )
            .thenReturn(dependentWorkStepIdToDependeeWorkStepStatuses);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkStepDependenciesSelector);
        Application.SERVICE.setMock(
            IWorkStepDependenciesService.class,
            mockWorkStepDependenciesService
        );
        Test.startTest();
        WorkSteps.newInstance(new List<WorkStep>{ newWorkStep })
            .onAfterUpdateHandleRelatedRecords(
                new Map<Id, WorkStep>{ oldWorkStep.Id => oldWorkStep }
            );
        Test.stopTest();
        String eventPayload = JSON.serialize(new List<WorkStep>{ oldWorkStep });
        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = EVENT_TOPIC_UPDATE_CHILD_WORKSTEPS_ON_PARENT
        );
        WorkStepsService.execute(new List<Notifier__e>{ mockNotifierEvent });
    }

    /**
     * @description To test update on date fields utilized for tracking WorkStep Status change
     * when Status is updated.
     */
    @isTest
    private static void testWhenWorkStepStatusUpdatedThenAssociatedDateTrackingFieldsUpdated() {
        Map<Id, WorkStep> oldWorkSteps = new Map<Id, WorkStep>();
        Fake oldWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
            WORK_STEP_STATUS_NOT_STARTED
        );
        WorkStep oldWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            oldWorkStepFakeInstance
        );
        oldWorkSteps.put(oldWorkStep.Id, oldWorkStep);
        WorkStep newWorkStep = new WorkStep(
            Id = oldWorkStep.Id,
            Status__c = WORK_STEP_STATUS_IN_PROGRESS
        );
        WorkSteps.newInstance(new List<WorkStep>{ newWorkStep })
            .onBeforeUpdateValidateAndUpdateWorkStepFields(oldWorkSteps);
        DateTime startDateTimeValue = newWorkStep.Start_Date_Time__c;
        Date updatedStartDate = Date.newInstance(
            startDateTimeValue.year(),
            startDateTimeValue.month(),
            startDateTimeValue.day()
        );
        System.assertEquals(System.today(), updatedStartDate, FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE);
    }

    /**
     * @description To test when WorkStep Status is not changed
     * then associated date tracking fields are not updated.
     */
    @isTest
    private static void testWhenWorkStepStatusNotUpdatedThenAssociatedDateTrackingFieldsNotUpdated() {
        Map<Id, WorkStep> oldWorkSteps = new Map<Id, WorkStep>();
        Fake oldWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
            WORK_STEP_STATUS_NOT_STARTED
        );
        WorkStep oldWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            oldWorkStepFakeInstance
        );
        oldWorkSteps.put(oldWorkStep.Id, oldWorkStep);
        WorkStep newWorkStep = new WorkStep(
            Id = oldWorkStep.Id,
            Status__c = WORK_STEP_STATUS_NOT_STARTED
        );
        WorkSteps.newInstance(new List<WorkStep>{ newWorkStep })
            .onBeforeUpdateValidateAndUpdateWorkStepFields(oldWorkSteps);
        System.assertEquals(
            null,
            newWorkStep.Start_Date_Time__c,
            FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE
        );
    }
    /**
     * @description To test when WorkStep Status is not changed
     * then associated date tracking fields are not updated.
     * Suppressed warning since mock verify method does not require system assert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenDeliverTableWorkStepUnblockedThenTabletCaseNotificationSent() {
        Map<Id, WorkStep> oldWorkSteps = new Map<Id, WorkStep>();
        Fake oldWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
                WORK_STEP_STATUS_ESCALATED
            )
            .setField(WorkStep.Name, WORK_STEP_TYPE_DELIVER_TABLET)
            .setField(
                WorkStep.Parent_Work_Step__c,
                fflib_IDGenerator.generate(WorkStep.SObjectType)
            )
            .setField(WorkStep.Type__c, WORK_STEP_TYPE_DELIVER_TABLET);
        WorkStep oldWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            oldWorkStepFakeInstance
        );
        oldWorkSteps.put(oldWorkStep.Id, oldWorkStep);
        WorkStep newWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            oldWorkStepFakeInstance.setField(WorkStep.Status__c, WORK_STEP_STATUS_IN_PROGRESS)
                .setField(WorkStep.Figment_Id__c, MOCK_FIGMENT_ID)
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ITabletCasePayloadGenerationService tabletCasePayloadGenerationServiceMock = (ITabletCasePayloadGenerationService) mocks.mock(
            ITabletCasePayloadGenerationService.class
        );
        IFeatureManagementService featureManagementService = (IFeatureManagementService) mocks.mock(
            IFeatureManagementService.class
        );
        mocks.startStubbing();
        mocks.when(featureManagementService.checkPermission(RESTRICT_TABLET_CASE_NOTIFICATION))
            .thenReturn(false);
        mocks.when(
                featureManagementService.checkPermission(
                    System.Label.EnableAsyncWorkStepsStatusRollupCustomPermissionName
                )
            )
            .thenReturn(false);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IFeatureManagementService.class, featureManagementService);
        Application.SERVICE.setMock(
            ITabletCasePayloadGenerationService.class,
            tabletCasePayloadGenerationServiceMock
        );
        WorkSteps.newInstance(new List<WorkStep>{ newWorkStep })
            .onAfterUpdateHandleRelatedRecords(oldWorkSteps);
        ((ITabletCasePayloadGenerationService) mocks.verify(
                tabletCasePayloadGenerationServiceMock,
                1
            ))
            .generatePayloadUsingWorkSteps(
                new List<WorkStep>{ newWorkStep },
                EXTERNAL_NOTIFIER_EVENT_TABLET_CASE_UPDATE_TOPIC
            );
    }

    /**
     * @description To test parent WorkStep Ids are collected and passed to Notifier event
     * when child WorkSteps are updated to Blocked or Resolved.
     * Suppressed warning since mock verify method does not require system assert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenChildWorkStepStatusUpdatedToBlockedOrResolvedThenNotifierEventFired() {
        Map<Id, WorkStep> oldWorkSteps = new Map<Id, WorkStep>();
        Fake parentWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
            WORK_STEP_STATUS_IN_PROGRESS
        );
        WorkStep parentWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            parentWorkStepFakeInstance
        );
        Fake parentWorkStepWithStatusUpdateFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
            WORK_STEP_STATUS_IN_PROGRESS
        );
        WorkStep parentWorkStepWithStatusUpdate = MockWorkStepDataBuilder.convertToWorkStepObject(
            parentWorkStepWithStatusUpdateFakeInstance
        );
        oldWorkSteps.put(parentWorkStepWithStatusUpdate.Id, parentWorkStepWithStatusUpdate);
        Fake newParentWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
            WORK_STEP_STATUS_IN_PROGRESS
        );
        WorkStep newParentWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            newParentWorkStepFakeInstance
        );
        Fake childWorkStepInNotStartedFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
                WORK_STEP_STATUS_NOT_STARTED
            )
            .setField(WorkStep.Parent_Work_Step__c, parentWorkStep.Id)
            .setParent('Parent_Work_Step__r', parentWorkStepFakeInstance);
        WorkStep childWorkStepInNotStarted = MockWorkStepDataBuilder.convertToWorkStepObject(
            childWorkStepInNotStartedFakeInstance
        );
        oldWorkSteps.put(childWorkStepInNotStarted.Id, childWorkStepInNotStarted);
        Fake childWorkStepInBlockedFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
                WORK_STEP_STATUS_BLOCKED
            )
            .setField(WorkStep.Parent_Work_Step__c, parentWorkStep.Id)
            .setParent('Parent_Work_Step__r', parentWorkStepFakeInstance);
        WorkStep childWorkStepInBlocked = MockWorkStepDataBuilder.convertToWorkStepObject(
            childWorkStepInBlockedFakeInstance
        );
        oldWorkSteps.put(childWorkStepInBlocked.Id, childWorkStepInBlocked);
        Fake childWorkStepInResolvedFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
                WORK_STEP_STATUS_RESOLVED
            )
            .setField(WorkStep.Parent_Work_Step__c, parentWorkStep.Id)
            .setParent('Parent_Work_Step__r', parentWorkStepFakeInstance);
        WorkStep childWorkStepInResolved = MockWorkStepDataBuilder.convertToWorkStepObject(
            childWorkStepInResolvedFakeInstance
        );
        oldWorkSteps.put(childWorkStepInResolved.Id, childWorkStepInResolved);
        Fake childWorkStepInNotWorkableFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
                WORK_STEP_STATUS_NOT_WORKABLE
            )
            .setField(WorkStep.Parent_Work_Step__c, parentWorkStep.Id)
            .setParent('Parent_Work_Step__r', parentWorkStepFakeInstance);
        WorkStep childWorkStepInNotWorkable = MockWorkStepDataBuilder.convertToWorkStepObject(
            childWorkStepInNotWorkableFakeInstance
        );
        oldWorkSteps.put(childWorkStepInNotWorkable.Id, childWorkStepInNotWorkable);
        List<WorkStep> newWorkSteps = new List<WorkStep>{
            MockWorkStepDataBuilder.convertToWorkStepObject(
                parentWorkStepWithStatusUpdateFakeInstance.setField(
                    WorkStep.Status__c,
                    WORK_STEP_STATUS_BLOCKED
                )
            ),
            MockWorkStepDataBuilder.convertToWorkStepObject(
                childWorkStepInNotStartedFakeInstance.setField(
                    WorkStep.Status__c,
                    WORK_STEP_STATUS_BLOCKED
                )
            ),
            MockWorkStepDataBuilder.convertToWorkStepObject(
                childWorkStepInBlockedFakeInstance.setField(
                    WorkStep.Status__c,
                    WORK_STEP_STATUS_RESOLVED
                )
            ),
            MockWorkStepDataBuilder.convertToWorkStepObject(
                childWorkStepInResolvedFakeInstance.setField(
                    WorkStep.Status__c,
                    WORK_STEP_STATUS_COMPLETE
                )
            ),
            MockWorkStepDataBuilder.convertToWorkStepObject(
                childWorkStepInNotWorkableFakeInstance.setField(
                        WorkStep.Status__c,
                        WORK_STEP_STATUS_BLOCKED
                    )
                    .setField(WorkStep.Parent_Work_Step__c, newParentWorkStep.Id)
                    .setParent('Parent_Work_Step__r', newParentWorkStepFakeInstance)
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        INotifierEventsService notifierEventService = (INotifierEventsService) mocks.mock(
            INotifierEventsService.class
        );
        Application.SERVICE.setMock(INotifierEventsService.class, notifierEventService);
        Test.startTest();
        WorkSteps.newInstance(newWorkSteps).onAfterUpdateHandleRelatedRecords(oldWorkSteps);
        Test.stopTest();
        Set<Id> parentWorkStepIds = new Set<Id>{ parentWorkStep.Id, newParentWorkStep.Id };
        ((INotifierEventsService) mocks.verify(notifierEventService, 1))
            .publishEvents(
                new Map<String, String>{
                    EVENT_TOPIC_WORK_STEPS_CALCULATION => JSON.serialize(parentWorkStepIds)
                }
            );
    }

    /**
     * @description To test "Account Owner Email Calculated" (formula field)
     * copies to "Account Owner Email Id" (email field) on WorkOrder insertion.
     */
    @isTest
    private static void testWhenWorkStepInsertedThenAccountOwnerEmailCopiedFromCalculatedField() {
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Fake newWorkStepFakeInstance = ServiceMockDataBuilder.createWorkStepFakeInstance(
                workOrderId,
                workPlanId
            )
            .setField(WorkStep.Account_Owner_Email_Calculated__c, ACCOUNT_OWNER_EMAIL_ID);
        WorkStep newWorkStep = (WorkStep) ServiceMockDataBuilder.convertToSObject(
            newWorkStepFakeInstance
        );
        List<WorkStep> newWorkSteps = new List<WorkStep>{ newWorkStep };
        WorkSteps.newInstance(newWorkSteps).onBeforeInsertValidateAndUpdateWorkStepFields();
        System.assertEquals(
            ACCOUNT_OWNER_EMAIL_ID,
            newWorkSteps[0].Account_Owner_Email_Id__c,
            ACCOUNT_OWNER_EMAIL_NOT_UPDATED_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test restrict update on Work Step Status field by EPM User
     * when Status is updated.
     */
    @isTest
    private static void testWhenWorkStepStatusUpdatedByEPMThenRestrictStatusUpdate() {
        Map<Id, WorkStep> oldWorkSteps = new Map<Id, WorkStep>();
        Fake oldWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
            WORK_STEP_STATUS_BLOCKED
        );
        WorkStep oldWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            oldWorkStepFakeInstance
        );
        oldWorkSteps.put(oldWorkStep.Id, oldWorkStep);
        WorkStep newWorkStep = new WorkStep(
            Id = oldWorkStep.Id,
            Status__c = WORK_STEP_STATUS_IN_PROGRESS,
            Is_Updated_By_System__c = false
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IFeatureManagementService featureManagementService = (IFeatureManagementService) mocks.mock(
            IFeatureManagementService.class
        );
        mocks.startStubbing();
        mocks.when(featureManagementService.checkPermission(RESTRICT_WORK_STEP_STATUS_UPDATES))
            .thenReturn(true);
        mocks.when(featureManagementService.checkPermission(ALLOW_WORK_STEP_STATUS_UPDATES))
            .thenReturn(false);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IFeatureManagementService.class, featureManagementService);
        Test.startTest();
        WorkSteps.newInstance(new List<WorkStep>{ newWorkStep })
            .onBeforeUpdateValidateAndUpdateWorkStepFields(oldWorkSteps);
        ApexPages.Message statusUpdateMessage = new ApexPages.Message(
            ApexPages.Severity.ERROR,
            System.Label.ErrorMessage_WorkStep_RestrictEPMToUpdateStatus
        );
        Test.stopTest();
        System.assertEquals(
            1,
            ApexPages.getMessages().size(),
            RESTRICT_STATUS_UPDATE_NEGATIVE_ASSERT_MESSAGE
        );
        System.assertEquals(
            statusUpdateMessage,
            ApexPages.getMessages()[0],
            RESTRICT_STATUS_UPDATE_NEGATIVE_ASSERT_MESSAGE
        );
    }
    /**
     * @description To test allow update on Work Step Status field by COO User
     * when Status is updated.
     */
    @isTest
    private static void testWhenWorkStepStatusUpdatedByCOOTeamThenAllowStatusUpdate() {
        Map<Id, WorkStep> oldWorkSteps = new Map<Id, WorkStep>();
        Fake oldWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
            WORK_STEP_STATUS_BLOCKED
        );
        WorkStep oldWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            oldWorkStepFakeInstance
        );
        oldWorkSteps.put(oldWorkStep.Id, oldWorkStep);
        WorkStep newWorkStep = new WorkStep(
            Id = oldWorkStep.Id,
            Status__c = WORK_STEP_STATUS_IN_PROGRESS,
            Is_Updated_By_System__c = false
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IFeatureManagementService featureManagementService = (IFeatureManagementService) mocks.mock(
            IFeatureManagementService.class
        );
        mocks.startStubbing();
        mocks.when(featureManagementService.checkPermission(RESTRICT_WORK_STEP_STATUS_UPDATES))
            .thenReturn(true);
        mocks.when(featureManagementService.checkPermission(ALLOW_WORK_STEP_STATUS_UPDATES))
            .thenReturn(true);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IFeatureManagementService.class, featureManagementService);
        Test.startTest();
        WorkSteps.newInstance(new List<WorkStep>{ newWorkStep })
            .onBeforeUpdateValidateAndUpdateWorkStepFields(oldWorkSteps);
        Test.stopTest();
        System.assertEquals(
            0,
            ApexPages.getMessages().size(),
            RESTRICT_STATUS_UPDATE_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test update on WorkStep Status field by O&A persona when
     * user has no permission to restrict Status update.
     */
    @isTest
    private static void testWhenEPMHasNoPermissionToRestrictStatusUpdateThenUpdateStatus() {
        Map<Id, WorkStep> oldWorkSteps = new Map<Id, WorkStep>();
        Fake oldWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
            WORK_STEP_STATUS_BLOCKED
        );
        WorkStep oldWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            oldWorkStepFakeInstance
        );
        oldWorkSteps.put(oldWorkStep.Id, oldWorkStep);
        WorkStep newWorkStep = new WorkStep(
            Id = oldWorkStep.Id,
            Status__c = WORK_STEP_STATUS_RESOLVED,
            Is_Updated_By_System__c = false
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IFeatureManagementService featureManagementService = (IFeatureManagementService) mocks.mock(
            IFeatureManagementService.class
        );
        mocks.startStubbing();
        mocks.when(featureManagementService.checkPermission(RESTRICT_WORK_STEP_STATUS_UPDATES))
            .thenReturn(false);
        mocks.when(featureManagementService.checkPermission(ALLOW_WORK_STEP_STATUS_UPDATES))
            .thenReturn(false);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IFeatureManagementService.class, featureManagementService);
        Test.startTest();
        WorkSteps.newInstance(new List<WorkStep>{ newWorkStep })
            .onBeforeUpdateValidateAndUpdateWorkStepFields(oldWorkSteps);
        Test.stopTest();
        System.assertEquals(
            0,
            ApexPages.getMessages().size(),
            RESTRICT_STATUS_UPDATE_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test status update on WorkStep Status field by EPM User
     * when Status is updated from Blocked to Resolved.
     */
    @isTest
    private static void testWhenWorkStepStatusUpdatedToResolvedByEPMThenUpdateStatus() {
        Map<Id, WorkStep> oldWorkSteps = new Map<Id, WorkStep>();
        Fake oldWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
            WORK_STEP_STATUS_BLOCKED
        );
        WorkStep oldWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            oldWorkStepFakeInstance
        );
        oldWorkSteps.put(oldWorkStep.Id, oldWorkStep);
        WorkStep newWorkStep = new WorkStep(
            Id = oldWorkStep.Id,
            Status__c = WORK_STEP_STATUS_RESOLVED,
            Is_Updated_By_System__c = false
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IFeatureManagementService featureManagementService = (IFeatureManagementService) mocks.mock(
            IFeatureManagementService.class
        );
        mocks.startStubbing();
        mocks.when(featureManagementService.checkPermission(RESTRICT_WORK_STEP_STATUS_UPDATES))
            .thenReturn(true);
        mocks.when(featureManagementService.checkPermission(ALLOW_WORK_STEP_STATUS_UPDATES))
            .thenReturn(true);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IFeatureManagementService.class, featureManagementService);
        Test.startTest();
        WorkSteps.newInstance(new List<WorkStep>{ newWorkStep })
            .onBeforeUpdateValidateAndUpdateWorkStepFields(oldWorkSteps);
        Test.stopTest();
        System.assertEquals(
            0,
            ApexPages.getMessages().size(),
            RESTRICT_STATUS_UPDATE_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test status update on WorkStep Status field by EPM User
     * when Status is updated from Blocked to Resolved and Is_Updated_By_System__c is true.
     */
    @isTest
    private static void testWhenWorkStepStatusUpdatedToResolvedAndIsUpdatedBySystemThenUpdateStatus() {
        Map<Id, WorkStep> oldWorkSteps = new Map<Id, WorkStep>();
        Fake oldWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
            WORK_STEP_STATUS_BLOCKED
        );
        WorkStep oldWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            oldWorkStepFakeInstance
        );
        oldWorkSteps.put(oldWorkStep.Id, oldWorkStep);
        WorkStep newWorkStep = new WorkStep(
            Id = oldWorkStep.Id,
            Status__c = WORK_STEP_STATUS_RESOLVED,
            Is_Updated_By_System__c = true
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IFeatureManagementService featureManagementService = (IFeatureManagementService) mocks.mock(
            IFeatureManagementService.class
        );
        mocks.startStubbing();
        mocks.when(featureManagementService.checkPermission(RESTRICT_WORK_STEP_STATUS_UPDATES))
            .thenReturn(true);
        mocks.when(featureManagementService.checkPermission(ALLOW_WORK_STEP_STATUS_UPDATES))
            .thenReturn(true);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IFeatureManagementService.class, featureManagementService);
        Test.startTest();
        WorkSteps.newInstance(new List<WorkStep>{ newWorkStep })
            .onBeforeUpdateValidateAndUpdateWorkStepFields(oldWorkSteps);
        Test.stopTest();
        System.assertEquals(
            0,
            ApexPages.getMessages().size(),
            RESTRICT_STATUS_UPDATE_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test "Link Implementation" Work Step status is changed from "Not Workable"
     * to "Not Started" when Implementation Call Work Step Status is updated
     * from "In Progress" to "Complete - DoorDash to implement link".
     * Suppressed Warnings since mock verify method does not require system assert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenImplementationCallWorkStepStatusUpdatedToCompleteThenUpdateLinkImplementationWorkStepToNotStarted() {
        Id implementationCallWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id linkImplementationWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id parentWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        List<WorkStep> oldImplementationCallWorkSteps = new List<WorkStep>{
            new WorkStep(
                Id = implementationCallWorkStepId,
                Name = WORK_STEP_TYPE_IMPLEMENTATION_CALL,
                Status__c = WORK_STEP_STATUS_IN_PROGRESS,
                Type__c = WORK_STEP_TYPE_IMPLEMENTATION_CALL,
                WorkPlanId = workPlanId
            )
        };
        List<WorkStep> newImplementationCallWorkSteps = new List<WorkStep>{
            new WorkStep(
                Id = implementationCallWorkStepId,
                Name = WORK_STEP_TYPE_IMPLEMENTATION_CALL,
                Status__c = WORK_STEP_STATUS_COMPLETE_DD_TO_IMPLEMENT_LINK,
                Parent_Work_Step__c = parentWorkStepId,
                Type__c = WORK_STEP_TYPE_IMPLEMENTATION_CALL,
                WorkPlanId = workPlanId
            )
        };
        List<WorkStep> linkImplementationWorkSteps = new List<WorkStep>{
            new WorkStep(
                Id = linkImplementationWorkStepId,
                Name = WORK_STEP_TYPE_LINK_IMPLEMENTATION,
                Status__c = WORK_STEP_STATUS_NOT_WORKABLE,
                Type__c = WORK_STEP_TYPE_LINK_IMPLEMENTATION,
                WorkPlanId = workPlanId
            )
        };
        linkImplementationWorkSteps.addAll(newImplementationCallWorkSteps);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkStepsSelector mockWorkStepsSelector = (WorkStepsSelector) mocks.mock(
            WorkStepsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                mockWorkStepsSelector.selectLinkImplementationWorkStepAttachedToWorkPlan(
                    new Set<Id>{ workPlanId }
                )
            )
            .thenReturn(linkImplementationWorkSteps);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Test.startTest();
        WorkSteps.newInstance(newImplementationCallWorkSteps)
            .onAfterUpdateHandleRelatedRecords(
                new Map<Id, WorkStep>(oldImplementationCallWorkSteps)
            );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkStep.Status__c => WORK_STEP_STATUS_NOT_STARTED
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
    }

    /**
     * @description To test "Link Implementation" Work Step status is changed from "In Progress"
     * to "Complete" when Implementation Call Work Step Status is updated
     * from "In Progress" to "Complete - Implemented on the call".
     * Suppressed Warnings since mock verify method does not require system assert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenImplementationCallWorkStepUpdatedToCompleteImplementedOnTheCallThenUpdateLinkImplementationWorkStepToComplete() {
        Id implementationCallWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id linkImplementationWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id parentWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        List<WorkStep> oldImplementationCallWorkSteps = new List<WorkStep>{
            new WorkStep(
                Id = implementationCallWorkStepId,
                Name = WORK_STEP_TYPE_IMPLEMENTATION_CALL,
                Status__c = WORK_STEP_STATUS_IN_PROGRESS,
                Parent_Work_Step__c = parentWorkStepId,
                Type__c = WORK_STEP_TYPE_IMPLEMENTATION_CALL,
                WorkPlanId = workPlanId
            )
        };
        List<WorkStep> newImplementationCallWorkSteps = new List<WorkStep>{
            new WorkStep(
                Id = implementationCallWorkStepId,
                Name = WORK_STEP_TYPE_IMPLEMENTATION_CALL,
                Status__c = WORK_STEP_STATUS_COMPLETE_IMPLEMENTED_ON_CALL,
                Parent_Work_Step__c = parentWorkStepId,
                Type__c = WORK_STEP_TYPE_IMPLEMENTATION_CALL,
                WorkPlanId = workPlanId
            )
        };
        List<WorkStep> linkImplementationWorkSteps = new List<WorkStep>{
            new WorkStep(
                Id = linkImplementationWorkStepId,
                Name = WORK_STEP_TYPE_LINK_IMPLEMENTATION,
                Status__c = WORK_STEP_STATUS_IN_PROGRESS,
                Type__c = WORK_STEP_TYPE_LINK_IMPLEMENTATION,
                WorkPlanId = workPlanId
            )
        };
        linkImplementationWorkSteps.addAll(newImplementationCallWorkSteps);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkStepsSelector mockWorkStepsSelector = (WorkStepsSelector) mocks.mock(
            WorkStepsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                mockWorkStepsSelector.selectLinkImplementationWorkStepAttachedToWorkPlan(
                    new Set<Id>{ workPlanId }
                )
            )
            .thenReturn(linkImplementationWorkSteps);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Test.startTest();
        WorkSteps.newInstance(newImplementationCallWorkSteps)
            .onAfterUpdateHandleRelatedRecords(
                new Map<Id, WorkStep>(oldImplementationCallWorkSteps)
            );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkStep.Id => linkImplementationWorkStepId,
                        WorkStep.Status__c => WORK_STEP_STATUS_COMPLETE
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
    }

    /**
     * @description To test "Link Implementation" Work Step status is changed from "Not Started"
     * to "In Progress" when Implementation Call Work Step Status is updated
     * from "In Progress" to "Complete - Mx to implement link".
     * Suppressed Warnings since mock verify method does not require system assert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenImplementationCallWorkStepUpdatedToCompleteMxToImplementLinkThenUpdateLinkImplementationWorkStepToInProgress() {
        Id implementationCallWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id linkImplementationWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id parentWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        List<WorkStep> oldImplementationCallWorkSteps = new List<WorkStep>{
            new WorkStep(
                Id = implementationCallWorkStepId,
                Name = WORK_STEP_TYPE_IMPLEMENTATION_CALL,
                Status__c = WORK_STEP_STATUS_IN_PROGRESS,
                Type__c = WORK_STEP_TYPE_IMPLEMENTATION_CALL,
                WorkPlanId = workPlanId
            )
        };
        List<WorkStep> newImplementationCallWorkSteps = new List<WorkStep>{
            new WorkStep(
                Id = implementationCallWorkStepId,
                Name = WORK_STEP_TYPE_IMPLEMENTATION_CALL,
                Status__c = WORK_STEP_STATUS_COMPLETE_MX_TO_IMPLEMENT,
                Parent_Work_Step__c = parentWorkStepId,
                Type__c = WORK_STEP_TYPE_IMPLEMENTATION_CALL,
                WorkPlanId = workPlanId
            )
        };
        List<WorkStep> linkImplementationWorkSteps = new List<WorkStep>{
            new WorkStep(
                Id = linkImplementationWorkStepId,
                Name = WORK_STEP_TYPE_LINK_IMPLEMENTATION,
                Status__c = WORK_STEP_STATUS_NOT_STARTED,
                Type__c = WORK_STEP_TYPE_LINK_IMPLEMENTATION,
                WorkPlanId = workPlanId
            )
        };
        linkImplementationWorkSteps.addAll(newImplementationCallWorkSteps);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkStepsSelector mockWorkStepsSelector = (WorkStepsSelector) mocks.mock(
            WorkStepsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                mockWorkStepsSelector.selectLinkImplementationWorkStepAttachedToWorkPlan(
                    new Set<Id>{ workPlanId }
                )
            )
            .thenReturn(linkImplementationWorkSteps);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Test.startTest();
        WorkSteps.newInstance(newImplementationCallWorkSteps)
            .onAfterUpdateHandleRelatedRecords(
                new Map<Id, WorkStep>(oldImplementationCallWorkSteps)
            );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkStep.Id => linkImplementationWorkStepId,
                        WorkStep.Status__c => WORK_STEP_STATUS_IN_PROGRESS
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
    }

    /**
     * @description To test dependent Work Step Status update to 'Not Started'
     * when dependee Work Step status is updated to 'Dead'.
     * Suppressed Warnings since mock verify method does not require system assert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenDependeeWorkStepDeadThenUpdateDependentWorkStepToNotStarted() {
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workStepDependencyTemplateId = fflib_IDGenerator.generate(
            WorkStepDependencyTemplate__c.SObjectType
        );
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        WorkStep oldWorkStep = new WorkStep(
            Id = workStepId,
            Name = WORK_STEP_NAME_SETUP_BUSINESS,
            Status__c = WORK_STEP_STATUS_IN_PROGRESS,
            Type__c = WORK_STEP_NAME_SETUP_BUSINESS
        );
        WorkStep newWorkStep = new WorkStep(
            Id = workStepId,
            Name = WORK_STEP_NAME_SETUP_BUSINESS,
            Status__c = WORK_STEP_STATUS_DEAD,
            Type__c = WORK_STEP_NAME_SETUP_BUSINESS
        );
        WorkStep dependentWorkStep = new WorkStep(
            Id = fflib_IDGenerator.generate(WorkStep.SObjectType),
            Status__c = WORK_STEP_STATUS_NOT_WORKABLE
        );
        WorkStepDependency__c workStepDependency = (WorkStepDependency__c) new Fake(
                WorkStepDependency__c.class
            )
            .setFakeId()
            .setField(WorkStepDependency__c.Dependee_Work_Step__c, newWorkStep.Id)
            .setField(WorkStepDependency__c.Dependent_Work_Step__c, dependentWorkStep.Id)
            .setField(
                WorkStepDependency__c.Work_Step_Dependency_Template__c,
                workStepDependencyTemplateId
            )
            .setParent(
                'Dependent_Work_Step__r',
                new Fake(WorkStep.class)
                    .setField(WorkStep.Id, dependentWorkStep.Id)
                    .setField(WorkStep.Name, WORK_STEP_TYPE_SETUP_STORE)
                    .setField(WorkStep.Status__c, WORK_STEP_STATUS_NOT_WORKABLE)
                    .setField(WorkStep.Type__c, WORK_STEP_TYPE_SETUP_STORE)
                    .setField(WorkStep.WorkOrderId, workOrderId)
                    .setField(WorkStep.WorkPlanId, workPlanId)
            )
            .toSObject();
        Map<Id, Set<String>> dependentWorkStepIdToDependeeWorkStepStatuses = new Map<Id, Set<String>>{
            dependentWorkStep.Id => new Set<String>{ WORK_STEP_STATUS_DEAD }
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkStepDependenciesService mockWorkStepDependenciesService = (IWorkStepDependenciesService) mocks.mock(
            IWorkStepDependenciesService.class
        );
        WorkStepDependenciesSelector mockWorkStepDependenciesSelector = (WorkStepDependenciesSelector) mocks.mock(
            WorkStepDependenciesSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepDependenciesSelector.sObjectType())
            .thenReturn(WorkStepDependency__c.SObjectType);
        mocks.when(
                mockWorkStepDependenciesSelector.selectDependenciesByDependeeWorkStepsIds(
                    new Set<Id>{ newWorkStep.Id }
                )
            )
            .thenReturn(new List<WorkStepDependency__c>{ workStepDependency });
        mocks.when(
                mockWorkStepDependenciesService.getSobjectIdToDependeeWorkStepStatuses(
                    new Set<Id>{ dependentWorkStep.Id },
                    WorkStep.SobjectType
                )
            )
            .thenReturn(dependentWorkStepIdToDependeeWorkStepStatuses);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkStepDependenciesSelector);
        Application.SERVICE.setMock(
            IWorkStepDependenciesService.class,
            mockWorkStepDependenciesService
        );
        Test.startTest();
        WorkSteps.newInstance(new List<WorkStep>{ newWorkStep })
            .onAfterUpdateHandleRelatedRecords(
                new Map<Id, WorkStep>{ oldWorkStep.Id => oldWorkStep }
            );
        Test.stopTest();
        String eventPayload = JSON.serialize(new List<WorkStep>{ oldWorkStep });
        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = EVENT_TOPIC_UPDATE_CHILD_WORKSTEPS_ON_PARENT
        );
        WorkStepsService.execute(new List<Notifier__e>{ mockNotifierEvent });
    }

    /**
     * @description To test "Link Implementation" Work Step status is changed from "Complete"
     * to "Not Started" when Implementation Call Work Step Status is updated
     * from "Complete - Implemented on the call" to "Complete - DoorDash to implement link".
     * Suppressed Warnings since mock verify method does not require system assert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenImplementationCallWorkStepUpdatedToCompleteDDToImplementLinkThenUpdateLinkImplementationWorkStepToNotStarted() {
        Id implementationCallWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id linkImplementationWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id parentWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        List<WorkStep> oldImplementationCallWorkSteps = new List<WorkStep>{
            new WorkStep(
                Id = implementationCallWorkStepId,
                Name = WORK_STEP_TYPE_IMPLEMENTATION_CALL,
                Status__c = WORK_STEP_STATUS_COMPLETE_IMPLEMENTED_ON_CALL,
                Type__c = WORK_STEP_TYPE_IMPLEMENTATION_CALL,
                WorkPlanId = workPlanId
            )
        };
        List<WorkStep> newImplementationCallWorkSteps = new List<WorkStep>{
            new WorkStep(
                Id = implementationCallWorkStepId,
                Name = WORK_STEP_TYPE_IMPLEMENTATION_CALL,
                Status__c = WORK_STEP_STATUS_COMPLETE_DD_TO_IMPLEMENT_LINK,
                Parent_Work_Step__c = parentWorkStepId,
                Type__c = WORK_STEP_TYPE_IMPLEMENTATION_CALL,
                WorkPlanId = workPlanId
            )
        };
        List<WorkStep> linkImplementationWorkSteps = new List<WorkStep>{
            new WorkStep(
                Id = linkImplementationWorkStepId,
                Name = WORK_STEP_TYPE_LINK_IMPLEMENTATION,
                Status__c = WORK_STEP_STATUS_COMPLETE,
                Type__c = WORK_STEP_TYPE_LINK_IMPLEMENTATION,
                WorkPlanId = workPlanId
            )
        };
        linkImplementationWorkSteps.addAll(newImplementationCallWorkSteps);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkStepsSelector mockWorkStepsSelector = (WorkStepsSelector) mocks.mock(
            WorkStepsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                mockWorkStepsSelector.selectLinkImplementationWorkStepAttachedToWorkPlan(
                    new Set<Id>{ workPlanId }
                )
            )
            .thenReturn(linkImplementationWorkSteps);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Test.startTest();
        WorkSteps.newInstance(newImplementationCallWorkSteps)
            .onAfterUpdateHandleRelatedRecords(
                new Map<Id, WorkStep>(oldImplementationCallWorkSteps)
            );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkStep.Id => linkImplementationWorkStepId,
                        WorkStep.Status__c => WORK_STEP_STATUS_NOT_STARTED
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
    }

    /**
     * @description To test "Link Implementation" Work Step status is changed from "Complete"
     * to "In Progress" when Implementation Call Work Step Status is updated
     * from "Complete - Implemented on the call" to "Complete - Mx to implement link".
     * Suppressed Warnings since mock verify method does not require system assert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenImplementationCallWorkStepUpdatedToCompleteMxToImplementLinkThenUpdateLinkImplementationWorkStepFromCompleteToInProgress() {
        Id implementationCallWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id linkImplementationWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id parentWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        List<WorkStep> oldImplementationCallWorkSteps = new List<WorkStep>{
            new WorkStep(
                Id = implementationCallWorkStepId,
                Name = WORK_STEP_TYPE_IMPLEMENTATION_CALL,
                Status__c = WORK_STEP_STATUS_COMPLETE_IMPLEMENTED_ON_CALL,
                Type__c = WORK_STEP_TYPE_IMPLEMENTATION_CALL,
                WorkPlanId = workPlanId
            )
        };
        List<WorkStep> newImplementationCallWorkSteps = new List<WorkStep>{
            new WorkStep(
                Id = implementationCallWorkStepId,
                Name = WORK_STEP_TYPE_IMPLEMENTATION_CALL,
                Status__c = WORK_STEP_STATUS_COMPLETE_MX_TO_IMPLEMENT,
                Parent_Work_Step__c = parentWorkStepId,
                Type__c = WORK_STEP_TYPE_IMPLEMENTATION_CALL,
                WorkPlanId = workPlanId
            )
        };
        List<WorkStep> linkImplementationWorkSteps = new List<WorkStep>{
            new WorkStep(
                Id = linkImplementationWorkStepId,
                Name = WORK_STEP_TYPE_LINK_IMPLEMENTATION,
                Status__c = WORK_STEP_STATUS_COMPLETE,
                Type__c = WORK_STEP_TYPE_LINK_IMPLEMENTATION,
                WorkPlanId = workPlanId
            )
        };
        linkImplementationWorkSteps.addAll(newImplementationCallWorkSteps);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkStepsSelector mockWorkStepsSelector = (WorkStepsSelector) mocks.mock(
            WorkStepsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepsSelector.sObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                mockWorkStepsSelector.selectLinkImplementationWorkStepAttachedToWorkPlan(
                    new Set<Id>{ workPlanId }
                )
            )
            .thenReturn(linkImplementationWorkSteps);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Test.startTest();
        WorkSteps.newInstance(newImplementationCallWorkSteps)
            .onAfterUpdateHandleRelatedRecords(
                new Map<Id, WorkStep>(oldImplementationCallWorkSteps)
            );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkStep.Id => linkImplementationWorkStepId,
                        WorkStep.Status__c => WORK_STEP_STATUS_IN_PROGRESS
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
    }

    /**
     * @description To test WorkSteps Status rollup event is published
     * when Status Rollup custom permission is assigned to the user.
     * Suppressed Warnings since mock verify method does not require system assert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenStatusRollupCustomPermissionAssignedThenPublishStatusRollupEvent() {
        Id setupMenuWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id parentWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        List<WorkStep> oldWorkSteps = new List<WorkStep>{
            new WorkStep(
                Id = setupMenuWorkStepId,
                Name = WORK_STEP_NAME_SETUP_MENU,
                WorkPlanId = workPlanId,
                Parent_Work_Step__c = parentWorkStepId,
                Status__c = WORK_STEP_STATUS_NOT_STARTED,
                Type__c = WORK_ORDER_TYPE
            )
        };
        List<WorkStep> newWorkSteps = new List<WorkStep>{
            new WorkStep(
                Id = setupMenuWorkStepId,
                Name = WORK_STEP_NAME_SETUP_MENU,
                WorkPlanId = workPlanId,
                Parent_Work_Step__c = parentWorkStepId,
                Status__c = WORK_STEP_STATUS_IN_PROGRESS,
                Type__c = WORK_ORDER_TYPE
            )
        };
        Static_Configurations__mdt workStepsStatusRollupChunkSize = new Static_Configurations__mdt(
            DeveloperName = WORK_STEPS_STATUS_ROLLUP_API_NAME,
            MasterLabel = WORK_STEPS_STATUS_ROLLUP_LABEL,
            Configuration_Value__c = String.valueOf(WORK_STEP_PARENT_IDS_CHUNK_SIZE)
        );
        List<String> eventPayload = new List<String>{
            JSON.serialize(new List<Id>{ parentWorkStepId, workPlanId })
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IFeatureManagementService mockFeatureManagementService = (IFeatureManagementService) mocks.mock(
            IFeatureManagementService.class
        );
        INotifierEventsPayloadGenerationService mockNotifierEventsPayloadGenerationService = (INotifierEventsPayloadGenerationService) mocks.mock(
            INotifierEventsPayloadGenerationService.class
        );
        INotifierEventsService notifierEventService = (INotifierEventsService) mocks.mock(
            INotifierEventsService.class
        );
        IOnboardingActivationsEventsService onboardingActivationsEventsService = (IOnboardingActivationsEventsService) mocks.mock(
            IOnboardingActivationsEventsService.class
        );
        IStaticConfigurationsSelector mockStaticConfigurationsSelector = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        mocks.startStubbing();
        mocks.when(
                mockFeatureManagementService.checkPermission(
                    System.Label.EnableAsyncWorkStepsStatusRollupCustomPermissionName
                )
            )
            .thenReturn(true);
        mocks.when(mockFeatureManagementService.checkPermission(RESTRICT_TABLET_CASE_NOTIFICATION))
            .thenReturn(true);
        mocks.when(
                mockNotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                    new Set<Id>{ parentWorkStepId, workPlanId },
                    WORK_STEP_PARENT_IDS_CHUNK_SIZE
                )
            )
            .thenReturn(eventPayload);
        mocks.when(mockStaticConfigurationsSelector.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    WORK_STEP_PARENT_IDS_CHUNK_SIZE_STATIC_CONFIG
                )
            )
            .thenReturn(workStepsStatusRollupChunkSize);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    TABLET_CASE_ELIGIBLE_WORK_ORDER_TYPES_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = METADATA_INSTANCE_NAME,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    WORK_STEP_STATUS_ROLLUP_RETRY_LIMIT_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Configuration_Value__c = STATUS_ROLLUP_REEXECUTION_LIMIT_VALUE
                )
            );
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    CHILD_WORK_STEPS_TO_UPDATE_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = CHILD_WORK_STEPS_TO_UPDATE_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG,
                    Configuration_Value__c = CHILD_WORK_STEPS_TO_UPDATE_CHUNK_SIZE
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
                    ENABLE_ENT_TABLET_CASE_UPDATE_FLAG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = ENABLE_ENT_TABLET_CASE_UPDATE_FLAG,
                    Configuration_Value__c = BOOLEAN_STRING_TRUE
                )
            );
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(ENABLE_TABLET_CASE_CREATION_FLAG)
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = ENABLE_TABLET_CASE_CREATION_FLAG,
                    Configuration_Value__c = BOOLEAN_STRING_TRUE
                )
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        Application.SERVICE.setMock(IFeatureManagementService.class, mockFeatureManagementService);
        Application.SERVICE.setMock(
            INotifierEventsPayloadGenerationService.class,
            mockNotifierEventsPayloadGenerationService
        );
        Application.SERVICE.setMock(INotifierEventsService.class, notifierEventService);
        Application.SERVICE.setMock(
            IOnboardingActivationsEventsService.class,
            onboardingActivationsEventsService
        );
        WorkSteps.newInstance(newWorkSteps)
            .onAfterUpdateHandleRelatedRecords(new Map<Id, WorkStep>(oldWorkSteps));
        ((INotifierEventsService) mocks.verify(notifierEventService, 1))
            .publishBulkEvents(
                new Map<String, List<String>>{
                    EVENT_TOPIC_WORK_STEPS_STATUS_ROLL_UP => eventPayload
                }
            );
    }

    /**
     * @description To test when Work Step is unblocked by MuleSoft user
     * then Tablet Case notification is not sent.
     * Suppressed warning since mock verify method does not require system assert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenDeliverTableWorkStepUnblockedByMuleSoftThenTabletCaseNotificationNotSent() {
        Map<Id, WorkStep> oldWorkSteps = new Map<Id, WorkStep>();
        Fake oldWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
                WORK_STEP_STATUS_ESCALATED
            )
            .setField(WorkStep.Name, WORK_STEP_TYPE_DELIVER_TABLET)
            .setField(WorkStep.Type__c, WORK_STEP_TYPE_DELIVER_TABLET);
        WorkStep oldWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            oldWorkStepFakeInstance
        );
        oldWorkSteps.put(oldWorkStep.Id, oldWorkStep);
        WorkStep newWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            oldWorkStepFakeInstance.setField(WorkStep.Status__c, WORK_STEP_STATUS_IN_PROGRESS)
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ITabletCasePayloadGenerationService tabletCasePayloadGenerationServiceMock = (ITabletCasePayloadGenerationService) mocks.mock(
            ITabletCasePayloadGenerationService.class
        );
        IFeatureManagementService featureManagementServiceMock = (IFeatureManagementService) mocks.mock(
            IFeatureManagementService.class
        );
        mocks.startStubbing();
        mocks.when(
                featureManagementServiceMock.checkPermission(
                    System.Label.EnableAsyncWorkStepsStatusRollupCustomPermissionName
                )
            )
            .thenReturn(true);
        mocks.when(featureManagementServiceMock.checkPermission(RESTRICT_TABLET_CASE_NOTIFICATION))
            .thenReturn(true);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IFeatureManagementService.class, featureManagementServiceMock);
        Application.SERVICE.setMock(
            ITabletCasePayloadGenerationService.class,
            tabletCasePayloadGenerationServiceMock
        );
        Test.startTest();
        WorkSteps.newInstance(new List<WorkStep>{ newWorkStep })
            .onAfterUpdateHandleRelatedRecords(oldWorkSteps);
        Test.stopTest();
        ((ITabletCasePayloadGenerationService) mocks.verify(
                tabletCasePayloadGenerationServiceMock,
                1
            ))
            .generatePayloadUsingWorkSteps(
                new List<WorkStep>{},
                EXTERNAL_NOTIFIER_EVENT_TABLET_CASE_UPDATE_TOPIC
            );
    }

    /**
     * @description To test restriction on manual update of Work Step Status to 'Blocked'
     * when Status Reason is null.
     */
    @isTest
    private static void testWhenWorkStepStatusChangedToBlockedWithoutStatusReasonDetailsThenRestrictStatusUpdate() {
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        List<WorkStep> oldWorkSteps = new List<WorkStep>{
            new WorkStep(
                Id = workStepId,
                Name = WORK_STEP_NAME_SETUP_STORE,
                WorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType),
                Status__c = WORK_STEP_STATUS_IN_PROGRESS,
                Type__c = WORK_STEP_NAME_SETUP_STORE,
                Is_Updated_By_System__c = false
            )
        };
        List<WorkStep> newWorkSteps = new List<WorkStep>{
            new WorkStep(
                Id = workStepId,
                Name = WORK_STEP_NAME_SETUP_STORE,
                WorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType),
                Status__c = WORK_STEP_STATUS_BLOCKED,
                Status_Reason__c = null,
                Type__c = WORK_STEP_NAME_SETUP_STORE,
                Is_Updated_By_System__c = false
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IFeatureManagementService featureManagementService = (IFeatureManagementService) mocks.mock(
            IFeatureManagementService.class
        );
        mocks.startStubbing();
        mocks.when(featureManagementService.checkPermission(RESTRICT_WORK_STEP_STATUS_UPDATES))
            .thenReturn(true);
        mocks.when(featureManagementService.checkPermission(ALLOW_WORK_STEP_STATUS_UPDATES))
            .thenReturn(true);
        mocks.when(featureManagementService.checkPermission(System.Label.EnableAsyncWorkStepsStatusRollupCustomPermissionName))
            .thenReturn(false);
        Test.startTest();
        WorkSteps.newInstance(newWorkSteps)
            .onBeforeUpdateValidateAndUpdateWorkStepFields(new Map<Id, WorkStep>(oldWorkSteps));
        Test.stopTest();
        System.assertEquals(
            System.Label.ErrorMessageWorkStepStatusCannotChangeWithoutStatusReason,
            fflib_SObjects.Errors.getAll()[0].message,
            STATUS_UPDATE_WITHOUT_STATUS_REASON_ERROR_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test error message is not displayed when Work Step Status
     * updated to 'Blocked' with Status Reason.
     */
    @isTest
    private static void testWhenWorkStepStatusChangedToBlockedWithStatusReasonDetailsThenErrorMessageNotDisplayed() {
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        List<WorkStep> oldWorkSteps = new List<WorkStep>{
            new WorkStep(
                Id = workStepId,
                Name = WORK_STEP_NAME_SETUP_STORE,
                WorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType),
                Status__c = WORK_STEP_STATUS_IN_PROGRESS,
                Type__c = WORK_STEP_NAME_SETUP_STORE,
                Is_Updated_By_System__c = false
            )
        };
        List<WorkStep> newWorkSteps = new List<WorkStep>{
            new WorkStep(
                Id = workStepId,
                Name = WORK_STEP_NAME_SETUP_STORE,
                WorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType),
                Status__c = WORK_STEP_STATUS_BLOCKED,
                Status_Reason__c = WORK_STEP_STATUS_REASON_INVALID_ADDRESS,
                Type__c = WORK_STEP_NAME_SETUP_STORE,
                Is_Updated_By_System__c = false
            )
        };
        WorkSteps.newInstance(newWorkSteps)
            .onBeforeUpdateValidateAndUpdateWorkStepFields(new Map<Id, WorkStep>(oldWorkSteps));
        System.assertEquals(
            0,
            fflib_SObjects.Errors.getAll().size(),
            STATUS_UPDATE_WITH_STATUS_REASON_ERROR_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test error message is not displayed when Work Step Status
     * updated to 'Escalated' without Status Reason by System.
     */
    @isTest
    private static void testWhenWorkStepStatusChangedToEscalatedWithoutStatusReasonDetailsBySystemThenErrorMessageNotDisplayed() {
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        List<WorkStep> oldWorkSteps = new List<WorkStep>{
            new WorkStep(
                Id = workStepId,
                Name = WORK_STEP_NAME_SETUP_STORE,
                WorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType),
                Status__c = WORK_STEP_STATUS_IN_PROGRESS,
                Type__c = WORK_STEP_NAME_SETUP_STORE,
                Is_Updated_By_System__c = false
            )
        };
        List<WorkStep> newWorkSteps = new List<WorkStep>{
            new WorkStep(
                Id = workStepId,
                Name = WORK_STEP_NAME_SETUP_STORE,
                WorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType),
                Status__c = WORK_STEP_STATUS_ESCALATED,
                Status_Reason__c = null,
                Type__c = WORK_STEP_NAME_SETUP_STORE,
                Is_Updated_By_System__c = true
            )
        };
        WorkSteps.newInstance(newWorkSteps)
            .onBeforeUpdateValidateAndUpdateWorkStepFields(new Map<Id, WorkStep>(oldWorkSteps));
        System.assertEquals(
            0,
            fflib_SObjects.Errors.getAll().size(),
            STATUS_UPDATE_WITHOUT_STATUS_REASON_ERROR_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test restriction on manual update of Work Step Status to 'Dead'
     * when Status Reason is null.
     */
    @isTest
    private static void testWhenWorkStepStatusChangedToDeadWithoutStatusReasonDetailsThenRestrictStatusUpdate() {
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        List<WorkStep> oldWorkSteps = new List<WorkStep>{
            new WorkStep(
                Id = workStepId,
                Name = WORK_STEP_NAME_SETUP_STORE,
                WorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType),
                Status__c = WORK_STEP_STATUS_NOT_STARTED,
                Type__c = WORK_STEP_NAME_SETUP_STORE,
                Is_Updated_By_System__c = false
            )
        };
        List<WorkStep> newWorkSteps = new List<WorkStep>{
            new WorkStep(
                Id = workStepId,
                Name = WORK_STEP_NAME_SETUP_STORE,
                WorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType),
                Status__c = WORK_STEP_STATUS_DEAD,
                Status_Reason__c = null,
                Type__c = WORK_STEP_NAME_SETUP_STORE,
                Is_Updated_By_System__c = false
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IFeatureManagementService featureManagementService = (IFeatureManagementService) mocks.mock(
            IFeatureManagementService.class
        );
        mocks.startStubbing();
        mocks.when(featureManagementService.checkPermission(RESTRICT_WORK_STEP_STATUS_UPDATES))
            .thenReturn(true);
        mocks.when(featureManagementService.checkPermission(ALLOW_WORK_STEP_STATUS_UPDATES))
            .thenReturn(true);
        mocks.when(featureManagementService.checkPermission(System.Label.EnableAsyncWorkStepsStatusRollupCustomPermissionName))
            .thenReturn(false);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IFeatureManagementService.class, featureManagementService);
        Test.startTest();
        WorkSteps.newInstance(newWorkSteps)
            .onBeforeUpdateValidateAndUpdateWorkStepFields(new Map<Id, WorkStep>(oldWorkSteps));
        Test.stopTest();
        System.assertEquals(
            System.Label.ErrorMessageWorkStepStatusCannotChangeWithoutStatusReason,
            fflib_SObjects.Errors.getAll()[0].message,
            STATUS_UPDATE_WITHOUT_STATUS_REASON_ERROR_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test restriction on manual update of Work Step Status Reason to blank/null
     * on Blocked/Dead/Escalated Work Step.
     */
    @isTest
    private static void testWhenWorkStepStatusReasonChangedToNullOnBlockedWorkStepThenRestrictUpdate() {
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        List<WorkStep> oldWorkSteps = new List<WorkStep>{
            new WorkStep(
                Id = workStepId,
                Name = WORK_STEP_NAME_SETUP_STORE,
                WorkPlanId = workPlanId,
                Status__c = WORK_STEP_STATUS_BLOCKED,
                Status_Reason__c = WORK_STEP_STATUS_REASON_OTHER,
                Type__c = WORK_STEP_NAME_SETUP_STORE,
                Is_Updated_By_System__c = false
            )
        };
        List<WorkStep> newWorkSteps = new List<WorkStep>{
            new WorkStep(
                Id = workStepId,
                Name = WORK_STEP_NAME_SETUP_STORE,
                WorkPlanId = workPlanId,
                Status__c = WORK_STEP_STATUS_BLOCKED,
                Status_Reason__c = null,
                Type__c = WORK_STEP_NAME_SETUP_STORE,
                Is_Updated_By_System__c = false
            )
        };
        WorkSteps.newInstance(newWorkSteps)
            .onBeforeUpdateValidateAndUpdateWorkStepFields(new Map<Id, WorkStep>(oldWorkSteps));
        System.assertEquals(
            System.Label.ErrorMessageWorkStepStatusCannotChangeWithoutStatusReason,
            fflib_SObjects.Errors.getAll()[0].message,
            STATUS_UPDATE_WITHOUT_STATUS_REASON_ERROR_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test when parent Activation Checklist WorkStep status is updated to
     * 'Not Started' then initiate Activation Checklist validation process.
     * Suppressed warning since mock verify method does not require system assert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenActivationChecklistWorkStepNotStartedThenInitiateValidation() {
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Map<Id, WorkStep> oldWorkSteps = new Map<Id, WorkStep>();
        Fake oldWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
                WORK_STEP_STATUS_NOT_WORKABLE
            )
            .setField(WorkStep.Name, WORK_ORDER_TYPE)
            .setField(WorkStep.Type__c, WORK_ORDER_TYPE)
            .setField(WorkStep.WorkPlanId, workPlanId);
        WorkStep oldWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            oldWorkStepFakeInstance
        );
        oldWorkSteps.put(oldWorkStep.Id, oldWorkStep);
        WorkStep newWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            oldWorkStepFakeInstance.setField(WorkStep.Status__c, WORK_STEP_STATUS_NOT_STARTED)
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkStepsService workStepsServiceMock = (IWorkStepsService) mocks.mock(
            IWorkStepsService.class
        );
        IWorkPlansService workPlansServiceMock = (IWorkPlansService) mocks.mock(
            IWorkPlansService.class
        );
        Application.SERVICE.setMock(IWorkStepsService.class, workStepsServiceMock);
        Application.SERVICE.setMock(IWorkPlansService.class, workPlansServiceMock);
        WorkSteps.newInstance(new List<WorkStep>{ newWorkStep })
            .onAfterUpdateHandleRelatedRecords(oldWorkSteps);
        ((IWorkStepsService) mocks.verify(workStepsServiceMock, 1))
            .collectChildActivationChecklistWorkStepsForOutboundIntegration(
                new Set<Id>{ oldWorkStep.Id }
            );
        ((IWorkPlansService) mocks.verify(workPlansServiceMock, 1))
            .updateActivationChecklistValidationStatusOnWorkPlans(
                new Set<Id>{ workPlanId },
                VALIDATION_STATUS_IN_PROGRESS
            );
    }

    /**
     * @description To test blanking of Status Reason and Status Reason Details
     * when Escalation is resolved.
     */
    @isTest
    private static void testWhenWorkStepEscalationIsResolvedThenStatusReasonAndDetailsBlanked() {
        Id escalatedWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        List<WorkStep> oldWorkSteps = new List<WorkStep>{
            new WorkStep(
                Id = escalatedWorkStepId,
                Name = WORK_STEP_NAME_SETUP_MENU,
                WorkPlanId = parentWorkPlanId,
                Status__c = WORK_STEP_STATUS_ESCALATED,
                Status_Reason__c = WORK_STEP_STATUS_REASON_OTHER,
                Status_Reason_Details__c = WORK_STEP_STATUS_REASON_OTHER,
                Type__c = WORK_STEP_NAME_SETUP_MENU
            )
        };
        List<WorkStep> newWorkSteps = new List<WorkStep>{
            new WorkStep(
                Id = escalatedWorkStepId,
                Name = WORK_STEP_NAME_SETUP_MENU,
                WorkPlanId = parentWorkPlanId,
                Status__c = WORK_STEP_STATUS_NOT_STARTED,
                Status_Reason__c = WORK_STEP_STATUS_REASON_OTHER,
                Status_Reason_Details__c = WORK_STEP_STATUS_REASON_OTHER,
                Type__c = WORK_STEP_NAME_SETUP_MENU
            )
        };
        WorkSteps.newInstance(newWorkSteps)
            .onBeforeUpdateValidateAndUpdateWorkStepFields(new Map<Id, WorkStep>(oldWorkSteps));
        System.assertEquals(
            '',
            newWorkSteps[0].Status_Reason__c,
            STATUS_REASON_NOT_BLANKED_ASSERT_MESSAGE
        );
        System.assertEquals(
            '',
            newWorkSteps[0].Status_Reason_Details__c,
            STATUS_REASON_DETAILS_NOT_BLANKED_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test 'Implementation Call' Work Step status is updated to 'Escalated'
     * for Work Orders created through 'Place It For Me' process.
     */
    @isTest
    private static void testWhenInsertPlaceItForMeImplementationCallWorkStepThenUpdateStatusToEscalated() {
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Fake workStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
                WORK_STEP_STATUS_IN_PROGRESS
            )
            .setField(WorkStep.Name, WORK_STEP_TYPE_IMPLEMENTATION_CALL)
            .setField(WorkStep.Type__c, WORK_STEP_TYPE_IMPLEMENTATION_CALL)
            .setField(
                WorkStep.Parent_Work_Order_Creation_Source__c,
                WORK_ORDER_CREATION_SOURCE_PLACE_IT_FOR_ME
            )
            .setField(WorkStep.WorkPlanId, workPlanId);
        WorkStep newWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            workStepFakeInstance
        );
        WorkPlan newWorkPlan = (WorkPlan) new Fake(WorkPlan.class)
            .setField(WorkPlan.Id, workPlanId)
            .setField(
                WorkPlan.Parent_Work_Order_Creation_Source__c,
                WORK_ORDER_CREATION_SOURCE_PLACE_IT_FOR_ME
            )
            .toSObject();
        List<WorkStep> newWorkSteps = new List<WorkStep>{ newWorkStep };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkPlansSelector mockWorkPlansSelector = (WorkPlansSelector) mocks.mock(
            WorkPlansSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkPlansSelector.sObjectType()).thenReturn(WorkPlan.SObjectType);
        mocks.when(mockWorkPlansSelector.selectById(new Set<Id>{ workPlanId }))
            .thenReturn(new List<WorkPlan>{ newWorkPlan });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkPlansSelector);
        WorkSteps.newInstance(newWorkSteps).onBeforeInsertValidateAndUpdateWorkStepFields();
        System.assertEquals(
            WORK_STEP_STATUS_ESCALATED,
            newWorkSteps[0].Status__c,
            STATUS_NOT_CHANGED_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test 'Setup Storefront Page' Work Step status is updated to 'Completed'
     * for Work Orders created through 'Place It For Me' process.
     */
    @isTest
    private static void testWhenInsertPlaceItForMeSetupStorefrontPageWorkStepThenUpdateStatusToCompleted() {
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Fake workStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
                WORK_STEP_STATUS_IN_PROGRESS
            )
            .setField(WorkStep.Name, WORK_STEP_TYPE_SETUP_STOREFRONT_PAGE)
            .setField(WorkStep.Type__c, WORK_STEP_TYPE_SETUP_STOREFRONT_PAGE)
            .setField(
                WorkStep.Parent_Work_Order_Creation_Source__c,
                WORK_ORDER_CREATION_SOURCE_PLACE_IT_FOR_ME
            )
            .setField(WorkStep.WorkPlanId, workPlanId);
        WorkStep newWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            workStepFakeInstance
        );
        WorkPlan newWorkPlan = (WorkPlan) new Fake(WorkPlan.class)
            .setField(WorkPlan.Id, workPlanId)
            .setField(
                WorkPlan.Parent_Work_Order_Creation_Source__c,
                WORK_ORDER_CREATION_SOURCE_PLACE_IT_FOR_ME
            )
            .toSObject();
        List<WorkStep> newWorkSteps = new List<WorkStep>{ newWorkStep };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        WorkPlansSelector mockWorkPlansSelector = (WorkPlansSelector) mocks.mock(
            WorkPlansSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkPlansSelector.sObjectType()).thenReturn(WorkPlan.SObjectType);
        mocks.when(mockWorkPlansSelector.selectById(new Set<Id>{ workPlanId }))
            .thenReturn(new List<WorkPlan>{ newWorkPlan });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkPlansSelector);
        WorkSteps.newInstance(newWorkSteps).onBeforeInsertValidateAndUpdateWorkStepFields();
        System.assertEquals(
            WORK_STEP_STATUS_COMPLETE,
            newWorkSteps[0].Status__c,
            STATUS_NOT_CHANGED_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test handle related records on update.
     */
    @isTest
    private static void testWhenUpdateHandleRelatedRecordsThenExceptionThrown() {
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id parentWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        List<WorkStep> oldWorkSteps = new List<WorkStep>{
            new WorkStep(
                Id = workStepId,
                Name = WORK_STEP_TYPE_DELIVER_TABLET,
                WorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType),
                //Enable_Merchant_Orders_Creation__c = true,
                Status__c = WORK_STEP_STATUS_NOT_WORKABLE,
                Type__c = WORK_STEP_TYPE_DELIVER_TABLET,
                Parent_Work_Step__c = parentWorkStepId
            )
        };
        List<WorkStep> newWorkSteps = new List<WorkStep>{
            new WorkStep(
                Id = workStepId,
                Name = WORK_STEP_TYPE_DELIVER_TABLET,
                WorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType),
                //Enable_Merchant_Orders_Creation__c = true,
                Status__c = WORK_STEP_STATUS_NOT_STARTED,
                Type__c = WORK_STEP_TYPE_DELIVER_TABLET,
                Parent_Work_Step__c = parentWorkStepId
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IMxOrderCreationService serviceMock = (IMxOrderCreationService) mocks.mock(
            IMxOrderCreationService.class
        );
        mocks.startStubbing();
        mocks.stopStubbing();
        Application.SERVICE.setMock(IMxOrderCreationService.class, serviceMock);
        Test.startTest();
        try {
            WorkSteps.newInstance(newWorkSteps)
                .onAfterUpdateHandleRelatedRecords(new Map<Id, WorkStep>(oldWorkSteps));
        } catch (Exception mockException) {
            System.assertNotEquals(
                null,
                mockException.getMessage(),
                ASSERT_MESSAGE_ERROR_MESSAGE_MISMATCH
            );
        }
        Test.stopTest();
    }

    /**
     * @description To test when 'Deliver Tablet' Work Steps are updated from 'Not Workable' to 'In Progress' then
     * do not create duplicate Mx Order.
     */
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    @isTest
    private static void testWhenDeliverTabletWorkStepStatusChangedToInProgressThenDoNotCreateDuplicateMxOrder() {
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id parentWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        List<WorkStep> oldWorkSteps = new List<WorkStep>{
            (WorkStep) new Fake(WorkStep.class)
                .setField(WorkStep.Id, workStepId)
                .setField(WorkStep.Name, WORK_STEP_TYPE_DELIVER_TABLET)
                .setField(WorkStep.WorkPlanId, workPlanId)
                .setField(WorkStep.Enable_Merchant_Orders_Creation__c, true)
                .setField(WorkStep.Status__c, WORK_STEP_STATUS_NOT_WORKABLE)
                .setField(WorkStep.Type__c, WORK_STEP_TYPE_DELIVER_TABLET)
                .setField(WorkStep.Parent_Work_Step__c, parentWorkStepId)
                .toSObject()
        };
        WorkStep workStepWithMxOrder = (WorkStep) new Fake(WorkStep.class)
            .setField(WorkStep.Id, workStepId)
            .setField(WorkStep.Name, WORK_STEP_TYPE_DELIVER_TABLET)
            .setField(WorkStep.WorkPlanId, workPlanId)
            .setField(WorkStep.Enable_Merchant_Orders_Creation__c, true)
            .setField(WorkStep.Status__c, WORK_STEP_STATUS_IN_PROGRESS)
            .setField(WorkStep.Type__c, WORK_STEP_TYPE_DELIVER_TABLET)
            .setField(WorkStep.Parent_Work_Step__c, parentWorkStepId)
            .toSObject();
        List<WorkStep> newWorkSteps = new List<WorkStep>{ workStepWithMxOrder };
        List<MX_Order__c> fakeMxOrders = new List<MX_Order__c>{
            (MX_Order__c) new Fake(MX_Order__c.class)
                .setFakeId()
                .setField(MX_Order__c.Account__c, fflib_IDGenerator.generate(Account.SObjectType))
                .setField(MX_Order__c.Type__c, MX_ORDER_TYPE_TABLET)
                .setField(MX_Order__c.Name, MX_ORDER_NAME)
                .setField(MX_Order__c.Vendor__c, MX_ORDER_VENDOR_NAME)
                .setField(MX_Order__c.Contact__c, fflib_IDGenerator.generate(Contact.SObjectType))
                .setField(MX_Order__c.Status__c, ORDER_STATUS_DRAFT)
                .setField(MX_Order__c.Work_Step__c, workStepId)
                .toSObject()
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IMerchantOrdersSelector mockMerchantOrdersSelector = (IMerchantOrdersSelector) mocks.mock(
            IMerchantOrdersSelector.class
        );
        IMxOrderCreationService mockMxOrderCreationService = (IMxOrderCreationService) mocks.mock(
            IMxOrderCreationService.class
        );
        mocks.startStubbing();
        mocks.when(mockMerchantOrdersSelector.sObjectType()).thenReturn(MX_Order__c.SObjectType);
        mocks.when(
                mockMerchantOrdersSelector.selectByWorkStepIds(
                    new Set<Id>{ workStepId },
                    new Set<String>{}
                )
            )
            .thenReturn(fakeMxOrders);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockMerchantOrdersSelector);
        Application.SERVICE.setMock(IMxOrderCreationService.class, mockMxOrderCreationService);
        Test.startTest();
        WorkSteps.newInstance(newWorkSteps)
            .onAfterUpdateHandleRelatedRecords(new Map<Id, WorkStep>(oldWorkSteps));
        Test.stopTest();
        ((IMxOrderCreationService) mocks.verify(mockMxOrderCreationService, 1))
            .generateMxOrderAndSelectProduct(new List<WorkStep>{});
    }
    /**
     * @description To test when 'Deliver Tablet' Work Steps are updated from 'Not Workable' to 'In Progress' then
     * create new Mx Order.
     */
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    @isTest
    private static void testWhenDeliverTabletWorkStepStatusChangedToInProgressThenCreateNewMxOrder() {
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id parentWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        List<WorkStep> oldWorkSteps = new List<WorkStep>{
            (WorkStep) new Fake(WorkStep.class)
                .setField(WorkStep.Id, workStepId)
                .setField(WorkStep.Name, WORK_STEP_TYPE_DELIVER_TABLET)
                .setField(WorkStep.WorkPlanId, workPlanId)
                .setField(WorkStep.Enable_Merchant_Orders_Creation__c, true)
                .setField(WorkStep.Status__c, WORK_STEP_STATUS_NOT_WORKABLE)
                .setField(WorkStep.Type__c, WORK_STEP_TYPE_DELIVER_TABLET)
                .setField(WorkStep.Parent_Work_Step__c, parentWorkStepId)
                .toSObject()
        };
        WorkStep workStepWithoutMxOrder = (WorkStep) new Fake(WorkStep.class)
            .setField(WorkStep.Id, workStepId)
            .setField(WorkStep.Name, WORK_STEP_TYPE_DELIVER_TABLET)
            .setField(WorkStep.WorkPlanId, workPlanId)
            .setField(WorkStep.Enable_Merchant_Orders_Creation__c, true)
            .setField(WorkStep.Status__c, WORK_STEP_STATUS_IN_PROGRESS)
            .setField(WorkStep.Type__c, WORK_STEP_TYPE_DELIVER_TABLET)
            .setField(WorkStep.Parent_Work_Step__c, parentWorkStepId)
            .toSObject();
        List<WorkStep> newWorkSteps = new List<WorkStep>{ workStepWithoutMxOrder };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IMerchantOrdersSelector mockMerchantOrdersSelector = (IMerchantOrdersSelector) mocks.mock(
            IMerchantOrdersSelector.class
        );
        IMxOrderCreationService mockMxOrderCreationService = (IMxOrderCreationService) mocks.mock(
            IMxOrderCreationService.class
        );
        mocks.startStubbing();
        mocks.when(mockMerchantOrdersSelector.sObjectType()).thenReturn(MX_Order__c.SObjectType);
        mocks.when(
                mockMerchantOrdersSelector.selectByWorkStepIds(
                    new Set<Id>{ workStepId },
                    new Set<String>{}
                )
            )
            .thenReturn(new List<MX_Order__c>{});
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockMerchantOrdersSelector);
        Application.SERVICE.setMock(IMxOrderCreationService.class, mockMxOrderCreationService);
        Test.startTest();
        WorkSteps.newInstance(newWorkSteps)
            .onAfterUpdateHandleRelatedRecords(new Map<Id, WorkStep>(oldWorkSteps));
        Test.stopTest();
        ((IMxOrderCreationService) mocks.verify(mockMxOrderCreationService, 1))
            .generateMxOrderAndSelectProduct(new List<WorkStep>{ workStepWithoutMxOrder });
    }
}
