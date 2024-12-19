/**
 * @author Deloitte
 * @date 30/03/2022
 * @description Domain class for WorkStep object.
 */
@SuppressWarnings(
    'PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity, PMD.NcssMethodCount, PMD.ExcessiveClassLength'
)
public inherited sharing class WorkSteps extends fflib_SObjects implements IWorkSteps {
    private static final String ALLOW_WORK_STEP_STATUS_UPDATES = 'Allow_Work_Step_Status_Updates';
    private static final String BOOLEAN_STRING_TRUE = 'TRUE';
    private static final String ENABLE_ENT_TABLET_CASE_UPDATE_FLAG = 'Tablet_Case_Update_By_Platform_Event';
    private static final String ENABLE_TABLET_CASE_CREATION_FLAG = 'Tablet_Case_Create_By_Platform_Event';
    private static final String EXTERNAL_NOTIFIER_EVENT_TABLET_CASE_INSERT_TOPIC = 'TABLET_CASE_INSERT';
    private static final String EXTERNAL_NOTIFIER_EVENT_TABLET_CASE_UPDATE_TOPIC = 'TABLET_CASE_UPDATE';
    private static final String EVENT_TOPIC_WORK_STEPS_CALCULATION = 'WORK_STEPS_RESCUE_PROCESS_CALCULATION';
    private static final String EVENT_TOPIC_WORK_STEPS_STATUS_ROLL_UP = 'WORK_STEPS_STATUS_ROLL_UP';
    private static final String EVENT_TOPIC_PHOTOSHOOT_WORK_ORDER_CREATION = 'PHOTOSHOOT_WORK_ORDER_CREATION';
    private static final String RESTRICT_TABLET_CASE_NOTIFICATION = 'Restrict_Tablet_Case_Notification';
    private static final String RESTRICT_WORK_STEP_STATUS_UPDATES = 'Restrict_Work_Step_Status_Updates';
    private static final String SEGMENT_SMB = 'SMB';
    private static final String SEPARATOR = System.Label.Separator;
    private static final String VALIDATION_STATUS_IN_PROGRESS = 'In Progress';
    private static final String WORK_ORDER_CREATION_SOURCE_MX_PORTAL = 'Mx Portal';
    private static final String WORK_ORDER_CREATION_SOURCE_PLACE_IT_FOR_ME = 'Place It For Me';
    private static final String WORK_ORDER_CREATION_SOURCE_SSMO = 'SSMO';
    private static final String WORK_STEP_PARENT_IDS_CHUNK_SIZE_STATIC_CONFIG = 'Work_Steps_Status_Rollup_Chunk_Size';
    private static final String WORK_STEP_STATUS_BLOCKED = 'Blocked';
    private static final String WORK_STEP_STATUS_COMPLETE = 'Complete';
    private static final String WORK_STEP_STATUS_DEAD = 'Dead';
    private static final String WORK_STEP_STATUS_COMPLETE_DD_TO_IMPLEMENT_LINK = 'Complete - DoorDash to implement link';
    private static final String WORK_STEP_STATUS_COMPLETE_IMPLEMENTED_ON_CALL = 'Complete - Implemented on the call';
    private static final String WORK_STEP_STATUS_COMPLETE_MX_TO_IMPLEMENT = 'Complete - Mx to implement link';
    private static final String WORK_STEP_STATUS_ESCALATED = 'Escalated';
    private static final String WORK_STEP_STATUS_IN_PROGRESS = 'In Progress';
    private static final String WORK_STEP_STATUS_NOT_STARTED = 'Not Started';
    private static final String WORK_STEP_STATUS_NOT_WORKABLE = 'Not Workable';
    private static final String WORK_STEP_STATUS_PIFM_LEAD = 'PIFM Lead';
    private static final String WORK_STEP_STATUS_RESOLVED = 'Resolved';
    private static final String WORK_STEP_TYPE_ACTIVATION_CHECKLIST = 'Activations Checklist';
    private static final String WORK_STEP_TYPE_IMPLEMENTATION_CALL = 'Implementation Call';
    private static final String WORK_STEP_TYPE_DELIVER_TABLET = 'Deliver Tablet';
    private static final String WORK_STEP_TYPE_LINK_IMPLEMENTATION = 'Link Implementation';
    private static final String WORK_STEP_TYPE_SETUP_BUSINESS = 'Setup Business';
    private static final String WORK_STEP_TYPE_SETUP_MENU = 'Setup Menu';
    private static final String WORK_STEP_TYPE_SETUP_STORE = 'Setup Store';
    private static final String WORK_STEP_TYPE_SETUP_STOREFRONT_PAGE = 'Setup Storefront Page';
    private static final String WORK_STEP_TYPE_GRANT_PORTAL_ACCESS = 'Grant Portal Access';
    private static final String WORK_STEP_TYPE_SETUP_BANKING = 'Setup Banking';
    private static final String WORK_ORDER_CREATION_SOURCE_RESSMO = 'RESSMO';
    private static final String LOG_SERVICE_MX_ORDER_CREATION = 'Merchant Order Creation Service';
    private static final String LOG_DOMAIN_MX_ORDERS = 'Merchant Orders Creation';
    private static final Set<String> CREATION_SOURCES_TO_BYPASS_READINESS_CHECK = new Set<String>{
        'SSMO',
        'Mx Portal',
        WORK_ORDER_CREATION_SOURCE_RESSMO
    };
    private static final Set<String> WORK_STEP_BLOCKED_STATUSES = new Set<String>{
        WORK_STEP_STATUS_BLOCKED,
        WORK_STEP_STATUS_ESCALATED
    };
    private static final Set<String> ELIGIBLE_WORK_STEP_STATUSES_TO_NOTIFY_TABLET_CASE_CREATION = new Set<String>{
        WORK_STEP_STATUS_NOT_STARTED,
        WORK_STEP_STATUS_IN_PROGRESS
    };
    private static final Set<String> WORK_STEP_COMPLETE_STATUSES = new Set<String>{
        WORK_STEP_STATUS_COMPLETE,
        WORK_STEP_STATUS_COMPLETE_DD_TO_IMPLEMENT_LINK,
        WORK_STEP_STATUS_COMPLETE_MX_TO_IMPLEMENT,
        WORK_STEP_STATUS_COMPLETE_IMPLEMENTED_ON_CALL
    };
    private static final Set<String> WORK_STEP_RESTRICTED_STATUSES_WITHOUT_STATUS_REASON = new Set<String>{
        WORK_STEP_STATUS_BLOCKED,
        WORK_STEP_STATUS_DEAD,
        WORK_STEP_STATUS_ESCALATED
    };
    private static final Map<String, String> IMPLEMENTATION_CALL_STATUS_VALUES = new Map<String, String>{
        WORK_STEP_STATUS_COMPLETE_DD_TO_IMPLEMENT_LINK => WORK_STEP_STATUS_NOT_STARTED,
        WORK_STEP_STATUS_COMPLETE_MX_TO_IMPLEMENT => WORK_STEP_STATUS_IN_PROGRESS,
        WORK_STEP_STATUS_COMPLETE_IMPLEMENTED_ON_CALL => WORK_STEP_STATUS_COMPLETE
    };
    private static final Set<String> INBOUND_INTEGRATION_WORKSTEPS_TYPES_TO_UPDATE = new Set<String>{
        WORK_STEP_TYPE_IMPLEMENTATION_CALL,
        WORK_STEP_TYPE_SETUP_BUSINESS,
        WORK_STEP_TYPE_SETUP_STOREFRONT_PAGE,
        WORK_STEP_TYPE_SETUP_STORE,
        WORK_STEP_TYPE_GRANT_PORTAL_ACCESS
    };
    private Set<Id> parentIdsOfWorkStepsWithChangedStatus;
    private Set<Id> parentWorkStepIdsOfBlockedOrResolvedWorkSteps;
    private Map<Id, WorkStep> parentWorkStepsWithChangedStatus;
    private enum FutureUpdatesScenarios {
        DEPENDENT_WORK_STEP_UPDATES,
        LINK_IMPLEMENTATION_UPDATES
    }
    private enum WorkStepTypes {
        WORK_STEP_TYPE_IMPLEMENTATION_CALL,
        WORK_STEP_TYPE_LINK_IMPLEMENTATION
    }
    private static final Map<String, WorkStepTypes> WORKSTEPTYPEMAPPINGS = new Map<String, WorkStepTypes>{
        WORK_STEP_TYPE_IMPLEMENTATION_CALL => WorkStepTypes.WORK_STEP_TYPE_IMPLEMENTATION_CALL,
        WORK_STEP_TYPE_LINK_IMPLEMENTATION => WorkStepTypes.WORK_STEP_TYPE_LINK_IMPLEMENTATION
    };
    private static final Set<String> INBOUND_INTEGRATION_CREATION_SOURCES = new Set<String>{
        WORK_ORDER_CREATION_SOURCE_MX_PORTAL,
        WORK_ORDER_CREATION_SOURCE_SSMO,
        WORK_ORDER_CREATION_SOURCE_RESSMO
    };
    private static final Set<String> INTEGRATION_SOURCE_WORKSTEPS_TYPES_TO_STATUS_UPDATE_TO_COMPLETE = new Set<String>{
        WORK_ORDER_CREATION_SOURCE_MX_PORTAL +
        SEPARATOR +
        WORK_STEP_TYPE_SETUP_BUSINESS,
        WORK_ORDER_CREATION_SOURCE_MX_PORTAL +
        SEPARATOR +
        WORK_STEP_TYPE_SETUP_STOREFRONT_PAGE,
        WORK_ORDER_CREATION_SOURCE_MX_PORTAL +
        SEPARATOR +
        WORK_STEP_TYPE_SETUP_STORE,
        WORK_ORDER_CREATION_SOURCE_MX_PORTAL +
        SEPARATOR +
        WORK_STEP_TYPE_GRANT_PORTAL_ACCESS,
        WORK_ORDER_CREATION_SOURCE_MX_PORTAL +
        SEPARATOR +
        WORK_STEP_TYPE_SETUP_BANKING,
        WORK_ORDER_CREATION_SOURCE_SSMO +
        SEPARATOR +
        WORK_STEP_TYPE_SETUP_BUSINESS,
        WORK_ORDER_CREATION_SOURCE_SSMO +
        SEPARATOR +
        WORK_STEP_TYPE_SETUP_STORE,
        WORK_ORDER_CREATION_SOURCE_SSMO +
        SEPARATOR +
        WORK_STEP_TYPE_SETUP_BANKING,
        WORK_ORDER_CREATION_SOURCE_RESSMO +
        SEPARATOR +
        WORK_STEP_TYPE_SETUP_BUSINESS,
        WORK_ORDER_CREATION_SOURCE_RESSMO +
        SEPARATOR +
        WORK_STEP_TYPE_SETUP_STOREFRONT_PAGE,
        WORK_ORDER_CREATION_SOURCE_RESSMO +
        SEPARATOR +
        WORK_STEP_TYPE_SETUP_STORE,
        WORK_ORDER_CREATION_SOURCE_RESSMO +
        SEPARATOR +
        WORK_STEP_TYPE_GRANT_PORTAL_ACCESS,
        WORK_ORDER_CREATION_SOURCE_RESSMO +
        SEPARATOR +
        WORK_STEP_TYPE_SETUP_BANKING
    };
    private Boolean isTabletCaseUpdateByPlatformEventEnabled;
    private Boolean isTabletCaseCreationByPlatformEventEnabled;

    /*
     * @description Holds a mock instance of the constructor inner class.
     * Setting this will provide the ability to test the records being injected into
     * the domain class when it is instantiated.
     */
    private static fflib_IDomainConstructor constructorMock;

    /**
     * @description It is used to return the IWorkSteps interface.
     * @param workSteps - WorkSteps record list
     * @return IWorkSteps - instance of IWorkSteps interface
     */
    public static IWorkSteps newInstance(List<WorkStep> workSteps) {
        return (IWorkSteps) Application.Domain.newInstance(workSteps);
    }

    /**
     * @description Default constructor to instantiate the variables.
     * @param sObjectList
     */
    public WorkSteps(List<WorkStep> sObjectList) {
        super(sObjectList, Schema.WorkStep.SObjectType);
        parentIdsOfWorkStepsWithChangedStatus = new Set<Id>();
        parentWorkStepsWithChangedStatus = new Map<Id, WorkStep>();
        parentWorkStepIdsOfBlockedOrResolvedWorkSteps = new Set<Id>();
        collectStaticConfigurations();
    }

    /**
     * @description It handles Work Step related records on After Insert trigger event.
     */
    public void onAfterInsertHandleRelatedRecords() {
        Set<Id> storeAccountIdsToInitiateTabletCaseCreation = new Set<Id>();
        for (WorkStep eachWorkStep : (List<WorkStep>) getRecords()) {
            if (
                INBOUND_INTEGRATION_CREATION_SOURCES.contains(
                    eachWorkStep.Parent_Work_Order_Creation_Source__c
                )
            ) {
                collectParentIdsOfWorkStepsWithChangedStatus(eachWorkStep.Parent_Work_Step__c);
                collectParentIdsOfWorkStepsWithChangedStatus(eachWorkStep.WorkPlanId);
                collectParentIdsOfWorkStepsWithChangedStatus(eachWorkStep.WorkOrderId);
            }
            if (
                isTabletCaseCreationByPlatformEventEnabled &&
                isEligibleToNotifyTabletCaseCreation(eachWorkStep)
            ) {
                storeAccountIdsToInitiateTabletCaseCreation.add(eachWorkStep.Store_Account__c);
            }
        }
        //JIRA# LEM-15268 - Initiate Work Order/Plan Status update based on Inbound Integration Work Steps.
        initiateStatusRollup();
        //JIRA# LEM-12073 - send stores associated to 'Deliver Tablet' WorkSteps to trigger
        // Tablet Case creation in Figment.
        TabletCasePayloadGenerationService.generatePayloadUsingStoreAccountIds(
            storeAccountIdsToInitiateTabletCaseCreation,
            EXTERNAL_NOTIFIER_EVENT_TABLET_CASE_INSERT_TOPIC
        );
    }

    /**
     * @description It handles WorkStep related records on After Update trigger event.
     * @param oldWorkSteps - Map of old WorkSteps
     */
    public void onAfterUpdateHandleRelatedRecords(Map<Id, WorkStep> oldWorkSteps) {
        WorkStep oldWorkStep;
        Set<Id> activationChecklistWorkSteps = new Set<Id>();
        Set<Id> completedActivationChecklistWorkOrders = new Set<Id>();
        Set<Id> activationChecklistParentWorkPlans = new Set<Id>();
        Set<Id> completedWorkStepIds = new Set<Id>();
        Boolean hasRecordsForFutureUpdates = false;
        Set<Id> implementationCallRelatedWorkPlanIds = new Set<Id>();
        Set<Id> storeAccountIds = new Set<Id>();
        List<WorkStep> unblockedDeliverTabletWorkSteps = new List<WorkStep>();
        List<WorkStep> workStepsForProductBundleSelection = new List<WorkStep>();
        Map<String, Set<Id>> futureUpdatesScenarioNameToRecordIds = new Map<String, Set<Id>>();
        Map<Id, WorkStep> workStepsEligibleToNotifyTabletCreation = new Map<Id, WorkStep>();
        for (WorkStep eachWorkStep : (List<WorkStep>) getRecords()) {
            oldWorkStep = oldWorkSteps.get(eachWorkStep.Id);
            if (hasWorkStepStatusChanged(eachWorkStep, oldWorkStep)) {
                collectParentIdsOfWorkStepsWithChangedStatus(eachWorkStep.Parent_Work_Step__c);
                collectParentIdsOfWorkStepsWithChangedStatus(eachWorkStep.WorkPlanId);
                collectParentIdsOfWorkStepsWithChangedStatus(eachWorkStep.WorkOrderId);
                //JIRA#: LEM-530
                collectParentWorkStepsWithChangedStatus(eachWorkStep);
                //JIRA#: LEM-1142, LEM-3439 & LEM-3517
                if (
                    isWorkStepStatusComplete(eachWorkStep.Status__c) ||
                    isWorkStepStatusDead(eachWorkStep.Status__c)
                ) {
                    completedWorkStepIds.add(eachWorkStep.Id);
                    hasRecordsForFutureUpdates = true;
                }
                //JIRA#: LEM-1087
                if (
                    evaluateANDLogicalOperator(
                        isTabletCaseUpdateByPlatformEventEnabled,
                        eachWorkStep.Figment_Id__c != null
                    ) && isDeliverTabletWorkStepUnblocked(eachWorkStep, oldWorkStep)
                ) {
                    unblockedDeliverTabletWorkSteps.add(eachWorkStep);
                }
                //JIRA#: LEM-12073
                if (
                    isTabletCaseCreationByPlatformEventEnabled &&
                    isEligibleToNotifyTabletCaseCreationByWorkStepStatus(eachWorkStep, oldWorkStep)
                ) {
                    storeAccountIds.add(eachWorkStep.Store_Account__c);
                }
                //JIRA#: LEM-2043
                collectParentWorkStepIdsOfBlockedAndResolvedWorkSteps(eachWorkStep, oldWorkStep);
                //JIRA#: LEM-13305
                if (
                    isParentActivationChecklistWorkStepInNotStartedStatus(eachWorkStep, oldWorkStep)
                ) {
                    activationChecklistWorkSteps.add(eachWorkStep.Id);
                    activationChecklistParentWorkPlans.add(eachWorkStep.WorkPlanId);
                }
                if (
                    isActivationChecklistWorkStepInCompleteStatus(eachWorkStep) &&
                    eachWorkStep.Enable_Merchant_Orders_Creation__c
                ) {
                    completedActivationChecklistWorkOrders.add(eachWorkStep.WorkOrderId);
                }
            }
            //@JIRA#: LEM-1115
            if (isEligibleLinkImplemenationOutcomeWorkStep(eachWorkStep, oldWorkStep)) {
                implementationCallRelatedWorkPlanIds.add(eachWorkStep.WorkPlanId);
                hasRecordsForFutureUpdates = true;
            }
            //@JIRA#: LEM-14054
            if (
                eachWorkStep.Enable_Merchant_Orders_Creation__c &&
                isTabletWorkStepInNotStartedStatus(eachWorkStep, oldWorkStep)
            ) {
                workStepsEligibleToNotifyTabletCreation.put(eachWorkStep.Id, eachWorkStep);
            }
        }

        //JIRA# LEM-12073 - send stores associated to 'Deliver Tablet' WorkSteps to trigger
        // Tablet Case creation in Figment.
        getWorkStepsEligibleForMxOrderCreation(
            workStepsEligibleToNotifyTabletCreation,
            workStepsForProductBundleSelection
        );
        TabletCasePayloadGenerationService.generatePayloadUsingStoreAccountIds(
            storeAccountIds,
            EXTERNAL_NOTIFIER_EVENT_TABLET_CASE_INSERT_TOPIC
        );
        //JIRA# LEM-1087 - send Deliver Tablet WorkSteps for Tablet Case Status update in Figment.
        TabletCasePayloadGenerationService.generatePayloadUsingWorkSteps(
            unblockedDeliverTabletWorkSteps,
            EXTERNAL_NOTIFIER_EVENT_TABLET_CASE_UPDATE_TOPIC
        );
        /**
         * JIRA#: LEM-1142 - call future method for updating dependent WorkStep Status.
         * JIRA#: LEM-1454 - added future context check.
         * JIRA#: LEM-1115 - call future method to update Link Implementation WS Status to Complete.
         * JIRA# LEM-1483 - optimized code to implement the sequencing of logic in future method.
         * JIRA# LEM-1377 Future method optimization
         */
        futureUpdatesScenarioNameToRecordIds.put(
            FutureUpdatesScenarios.DEPENDENT_WORK_STEP_UPDATES.name(),
            completedWorkStepIds
        );
        futureUpdatesScenarioNameToRecordIds.put(
            FutureUpdatesScenarios.LINK_IMPLEMENTATION_UPDATES.name(),
            implementationCallRelatedWorkPlanIds
        );
        if (
            evaluateANDLogicalOperator(
                !System.isBatch(),
                evaluateANDLogicalOperator(!System.isFuture(), hasRecordsForFutureUpdates)
            )
        ) {
            handleWorkStepRelatedUpdatesInFuture(
                JSON.serialize(futureUpdatesScenarioNameToRecordIds)
            );
        }
        //JIRA#: LEM-582, LEM-527 & LEM-4218
        initiateStatusRollup();
        //JIRA#: LEM-530
        WorkStepsService.updateChildWorkStepsStatusOnParentWorkStepsStatusChange(
            parentWorkStepsWithChangedStatus
        );
        //JIRA#: LEM-13305
        WorkStepsService.collectChildActivationChecklistWorkStepsForOutboundIntegration(
            activationChecklistWorkSteps
        );
        //JIRA#: LEM-13305
        WorkPlansService.updateActivationChecklistValidationStatusOnWorkPlans(
            activationChecklistParentWorkPlans,
            VALIDATION_STATUS_IN_PROGRESS
        );
        //JIRA#: LEM-2043 - initiate the rescue process related calculations
        triggerRescueProcessCalculations();

        //JIRA#: LEM-14054 - Invoke MxOrderCreationService
        initiateMxOrderCreation(workStepsForProductBundleSelection);
        //JITA#: LEM-13498 - Create Photoshoot Work Orders.
        OnboardingActivationsEventsService.publishBulkEvents(
            new Map<String, List<String>>{
                EVENT_TOPIC_PHOTOSHOOT_WORK_ORDER_CREATION => NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                    completedActivationChecklistWorkOrders,
                    5
                )
            }
        );
    }

    /**
     * @description It validate and update WorkStep fields on Before Insert trigger event.
     */
    public void onBeforeInsertValidateAndUpdateWorkStepFields() {
        List<WorkStep> inboundIntegrationWorkStepsForStatusUpdate = new List<WorkStep>();
        for (WorkStep eachWorkStep : (List<WorkStep>) getRecords()) {
            //JIRA#: LEM-1120
            copyCustomStatusValueOnStandardStatusField(eachWorkStep);
            //JIRA#: LEM-2045
            copyAccountOwnerEmail(eachWorkStep);
            //JIRA#: LEM-15585
            if (INBOUND_INTEGRATION_WORKSTEPS_TYPES_TO_UPDATE.contains(eachWorkStep.Type__c)) {
                inboundIntegrationWorkStepsForStatusUpdate.add(eachWorkStep);
            }
        }
        if (!inboundIntegrationWorkStepsForStatusUpdate.isEmpty()) {
            updateWorkStepStatusByParentWorkOrderCreationSource(
                inboundIntegrationWorkStepsForStatusUpdate
            );
        }
    }

    /**
     * @description It validate and update WorkStep fields on Before Update trigger event.
     * @param oldWorkSteps - Map of old WorkSteps
     */
    public void onBeforeUpdateValidateAndUpdateWorkStepFields(Map<Id, WorkStep> oldWorkSteps) {
        WorkStep oldWorkStep;
        List<WorkStep> newWorkStepsWithStatusUpdate = new List<WorkStep>();
        List<WorkStep> workStepStatusBlocked = new List<WorkStep>();
        for (WorkStep eachWorkStep : (List<WorkStep>) getRecords()) {
            oldWorkStep = oldWorkSteps.get(eachWorkStep.Id);
            if (hasWorkStepStatusChanged(eachWorkStep, oldWorkStep)) {
                //JIRA#: LEM-15697 - Refresh Status Reason and Status Reason Details values on Status update.
                refreshWorkStepStatusReasonAndStatusReasonDetails(eachWorkStep, oldWorkStep);
                //JIRA#: LEM-2346 - Block EPM persona from updating status other than from Blocked to Resolved
                restrictEPMToUpdateStatus(eachWorkStep, oldWorkStep);
                // JIRA#: LEM-4629 - Block user from updating status to Blocked/Dead/Escalated without Status Reason.
                restrictUserToUpdateStatusWithoutStatusReason(eachWorkStep, oldWorkStep);
                // Reverting indicator for system updates
                eachWorkStep.Is_Updated_By_System__c = false;
                //JIRA#: LEM-1120
                copyCustomStatusValueOnStandardStatusField(eachWorkStep);
                //JIRA#: LEM-1489
                newWorkStepsWithStatusUpdate.add(eachWorkStep);

                WorkStepsService.handleCompletionStatusReasonUpdates(eachWorkStep);

                if (hasSetupMenuWorkStepEscalationResolved(eachWorkStep, oldWorkStep)) {
                    //JIRA#: LEM-1044
                    updateWorkStepMenuErrorTypeToBlank(eachWorkStep);
                }
                //* @JIRA# LEM-13961
                if (isWorkStepStatusChangedToBlocked(eachWorkStep)) {
                    workStepStatusBlocked.add(eachWorkStep);
                }
            } else if (eachWorkStep.Status_Reason__c != oldWorkStep.Status_Reason__c) {
                // JIRA#: LEM-4629 - Block user from updating Status Reason to blank with Blocked/Dead/Escalated Status.
                restrictUserToUpdateStatusWithoutStatusReason(eachWorkStep, oldWorkStep);
                WorkStepsService.handleCompletionStatusReasonUpdates(eachWorkStep);

                //* @JIRA# LEM-13961
                if (isWorkStepStatusChangedToBlocked(eachWorkStep)) {
                    workStepStatusBlocked.add(eachWorkStep);
                }
            }
        }
        //JIRA#: LEM-1489
        WorkStepsStatusRelatedDatesCalcService.updateAssociatedDateTrackingFieldsOnStatusChange(
            newWorkStepsWithStatusUpdate,
            oldWorkSteps
        );
        /**
         * @description It updates the 'Click N Pop Eligible' checkbox and the 'Original Status Reason_and Details' fields
         * when the status of a workstep is changed to 'blocked'.
         * @JIRA# LEM-13961
         */
        WorkStepsService.updatePopnClickOnWorkStepStatusChange(workStepStatusBlocked);
    }

    /**
     * @description It checks if the status of a given WorkStep has been changed to 'blocked' and 'Click_n_Pop_Eligible__c' field is not true.
     * @JIRA# LEM-13961
     * @param eachWorkStep
     * @return Boolean
     */
    private Boolean isWorkStepStatusChangedToBlocked(WorkStep eachWorkStep) {
        return eachWorkStep.Click_n_Pop_Eligible__c != true &&
            String.isNotBlank(eachWorkStep.Status__c) &&
            eachWorkStep.Status__c.equalsIgnoreCase(WORK_STEP_STATUS_BLOCKED);
    }

    /**
     * @description It checks for valid values to allow "Not Started" Status update on dependent WorkStep.
     * @JIRA# LEM-1142
     * @param workStepStatus
     * @param dependeeWorkStepStatuses
     * @return Boolean
     */
    private static Boolean allowNotStartedStatusUpdate(
        String workStepStatus,
        Set<String> dependeeWorkStepStatuses
    ) {
        dependeeWorkStepStatuses.removeAll(WORK_STEP_COMPLETE_STATUSES);
        dependeeWorkStepStatuses.remove(WORK_STEP_STATUS_DEAD);
        return workStepStatus == WORK_STEP_STATUS_NOT_WORKABLE &&
            dependeeWorkStepStatuses.isEmpty();
    }

    /**
     * @description It collects parent Activation Checklist WorkStep Ids for outbound integration.
     * @JIRA# LEM-13305
     * @param newWorkStep
     * @param oldWorkStep
     * @return Boolean
     */
    private Boolean isParentActivationChecklistWorkStepInNotStartedStatus(
        WorkStep newWorkStep,
        WorkStep oldWorkStep
    ) {
        return (String.isBlank(String.valueOf(newWorkStep.Parent_Work_Step__c)) &&
        newWorkStep.Type__c == WORK_STEP_TYPE_ACTIVATION_CHECKLIST &&
        oldWorkStep.Status__c == WORK_STEP_STATUS_NOT_WORKABLE &&
        newWorkStep.Status__c == WORK_STEP_STATUS_NOT_STARTED);
    }

    /**
     * @description It collects Tablet WorkStep Ids for tablet integration.
     * @JIRA# LEM-14054
     * @param newWorkStep
     * @param oldWorkStep
     * @return Boolean
     */
    private Boolean isTabletWorkStepInNotStartedStatus(WorkStep newWorkStep, WorkStep oldWorkStep) {
        return newWorkStep.Type__c == WORK_STEP_TYPE_DELIVER_TABLET &&
            oldWorkStep.Status__c == WORK_STEP_STATUS_NOT_WORKABLE &&
            ELIGIBLE_WORK_STEP_STATUSES_TO_NOTIFY_TABLET_CASE_CREATION.contains(
                newWorkStep.Status__c
            ) &&
            newWorkStep.Parent_Work_Step__c != null;
    }

    /**
     * @description It collects Tablet WorkStep Ids for tablet integration.
     * @JIRA# LEM-14054
     * @param newWorkStep
     * @return Boolean
     */
    private Boolean isActivationChecklistWorkStepInCompleteStatus(WorkStep newWorkStep) {
        return newWorkStep.Type__c == WORK_STEP_TYPE_ACTIVATION_CHECKLIST &&
            newWorkStep.Status__c == WORK_STEP_STATUS_COMPLETE &&
            newWorkStep.Parent_Work_Step__c == null;
    }

    /**
     * @description It collects dependent WorkSteps where passed WorkSteps are dependee.
     * @JIRA# LEM-1142
     * @param workStepIds - Set of WorkStepIds
     * @return Map<Id, String> - Map of WorkStepId to Status
     */
    private static Map<Id, String> collectDependentWorkSteps(Set<Id> workStepIds) {
        Map<Id, String> dependentWorkStepIdToStatus = new Map<Id, String>();
        if (workStepIds.isEmpty()) {
            return dependentWorkStepIdToStatus;
        }
        for (
            WorkStepDependency__c eachWorkStepDependency : WorkStepDependenciesSelector.newInstance()
                .selectDependenciesByDependeeWorkStepsIds(workStepIds)
        ) {
            if (
                eachWorkStepDependency.Dependent_Work_Step__c == null &&
                eachWorkStepDependency.Dependee_Work_Step__c == null
            ) {
                continue;
            }
            dependentWorkStepIdToStatus.put(
                eachWorkStepDependency.Dependent_Work_Step__c,
                eachWorkStepDependency.Dependent_Work_Step__r.Status__c
            );
        }
        return dependentWorkStepIdToStatus;
    }

    /**
     * @description It collects the configuration values from Static Configuration custom metadata.
     * @JIRA# LEM-22115
     */
    private void collectStaticConfigurations() {
        isTabletCaseUpdateByPlatformEventEnabled = String.valueOf(
                    StaticConfigurationsSelector.newInstance()
                        .getInstanceValue(ENABLE_ENT_TABLET_CASE_UPDATE_FLAG)
                        .Configuration_Value__c
                )
                .equalsIgnoreCase(BOOLEAN_STRING_TRUE)
            ? true
            : false;
        isTabletCaseCreationByPlatformEventEnabled = String.valueOf(
                    StaticConfigurationsSelector.newInstance()
                        .getInstanceValue(ENABLE_TABLET_CASE_CREATION_FLAG)
                        .Configuration_Value__c
                )
                .equalsIgnoreCase(BOOLEAN_STRING_TRUE)
            ? true
            : false;
    }

    /**
     * @description It is used to get Work Steps eligible for Tablet Mx Order Creation.
     * @JIRA# LEM-25257
     * @param workStepsEligibleToNotifyTabletCreation
     * @param workStepsForProductBundleSelection
     */
    private void getWorkStepsEligibleForMxOrderCreation(
        Map<Id, WorkStep> workStepsEligibleToNotifyTabletCreation,
        List<WorkStep> workStepsForProductBundleSelection
    ) {
        Set<Id> workStepsContainingMxOrders = new Set<Id>();
        if (workStepsEligibleToNotifyTabletCreation.isEmpty()) {
            return;
        }
        for (
            MX_Order__c eachMxOrder : MerchantOrdersSelector.newInstance()
                .selectByWorkStepIds(
                    workStepsEligibleToNotifyTabletCreation.keySet(),
                    new Set<String>{}
                )
        ) {
            workStepsContainingMxOrders.add((eachMxOrder.Work_Step__c));
        }
        for (Id eachWorkStepId : workStepsEligibleToNotifyTabletCreation.keySet()) {
            if (!workStepsContainingMxOrders.contains(eachWorkStepId)) {
                workStepsForProductBundleSelection.add(
                    workStepsEligibleToNotifyTabletCreation.get(eachWorkStepId)
                );
            }
        }
    }

    /**
     * @description It initiates Mx Order Creation.
     * @param workStepsForProductBundleSelection
     */
    private void initiateMxOrderCreation(List<WorkStep> workStepsForProductBundleSelection) {
        try {
            MxOrderCreationService.generateMxOrderAndSelectProduct(
                workStepsForProductBundleSelection
            );
        } catch (Exception mxOrderCreationException) {
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_SERVICE_MX_ORDER_CREATION,
                        LOG_DOMAIN_MX_ORDERS,
                        GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logException(mxOrderCreationException)
                    .logSFRecordId(
                        (Set<String>) JSON.deserialize(
                            JSON.serialize(
                                (new Map<Id, WorkStep>(workStepsForProductBundleSelection)).keySet()
                            ),
                            Set<String>.class
                        )
                    )
            );
        }
    }

    /**
     * @description It compares the received boolean values with AND(&&) logical operator
     * and returns the result.
     * It is added to reduce the Cyclomatic Complexity of the class.
     * @param leftOperand
     * @param rightOperand
     * @return Boolean
     */
    private Boolean evaluateANDLogicalOperator(Boolean leftOperand, Boolean rightOperand) {
        return leftOperand && rightOperand;
    }

    /**
     * @description Private method that allows the domain constructor mock to be set by test class.
     * @param mock fflib_IDomainConstructor
     */
    @TestVisible
    private static void setConstructorMock(fflib_IDomainConstructor mock) {
        constructorMock = mock;
    }

    /**
     * @description It updates Status of dependent WorkStep to the passed value.
     * @JIRA# LEM-1142 & LEM-1454
     * @param workStepIds - Set of Complete WorkStepIds
     * @param workStepStatus - Status value to be assigned to dependent WorkSteps
     */
    private static void handleDependentWorkStepsStatusUpdates(
        Set<Id> workStepIds,
        String workStepStatus
    ) {
        if (workStepIds.isEmpty()) {
            return;
        }
        Map<Id, String> dependentWorkStepIdToStatus = new Map<Id, String>();
        Map<Id, Set<String>> dependentWorkStepIdToDependeeWorkStepStatuses = new Map<Id, Set<String>>();
        fflib_ISObjectUnitOfWork uowToUpdateWorkSteps = Application.UNITOFWORK.newInstance();
        dependentWorkStepIdToStatus = collectDependentWorkSteps(workStepIds);
        dependentWorkStepIdToDependeeWorkStepStatuses = WorkStepDependenciesService.getSobjectIdToDependeeWorkStepStatuses(
            dependentWorkStepIdToStatus.keySet(),
            WorkStep.SobjectType
        );
        if (dependentWorkStepIdToDependeeWorkStepStatuses.isEmpty()) {
            return;
        }
        for (Id eachWorkStepId : dependentWorkStepIdToStatus.keySet()) {
            if (
                allowNotStartedStatusUpdate(
                    dependentWorkStepIdToStatus.get(eachWorkStepId),
                    dependentWorkStepIdToDependeeWorkStepStatuses.get(eachWorkStepId)
                )
            ) {
                uowToUpdateWorkSteps.registerDirty(
                    new WorkStep(Id = eachWorkStepId, Status__c = workStepStatus)
                );
            }
        }
        try {
            uowToUpdateWorkSteps.commitWork();
        } catch (Exception workStepsStatusUpdateException) {
            Logger.publish(
                LogEntry.newExceptionLog(
                    workStepsStatusUpdateException,
                    LogEntry.SeverityLevel.HIGH
                )
            );
        }
    }

    /**
     * @description It is used to call future method to update WorkSteps
     * @param scenarioMappings - map of scenarioName to set of record Ids
     */
    @future
    private static void handleWorkStepRelatedUpdatesInFuture(String scenarioMappings) {
        Set<Id> implementationCallRelatedWorkPlanIds = new Set<Id>();
        Set<Id> completedWorkStepIds = new Set<Id>();
        Map<String, Set<Id>> scenarioNameToRecordIds = (Map<String, Set<Id>>) JSON.deserialize(
            scenarioMappings,
            Map<String, Set<Id>>.class
        );
        if (scenarioNameToRecordIds == null) {
            return;
        }
        for (String secnarionName : scenarioNameToRecordIds.keySet()) {
            Set<Id> recordIds = scenarioNameToRecordIds.get(secnarionName);
            switch on FutureUpdatesScenarios.valueOf(secnarionName) {
                when LINK_IMPLEMENTATION_UPDATES {
                    implementationCallRelatedWorkPlanIds.addAll(recordIds);
                }
                when DEPENDENT_WORK_STEP_UPDATES {
                    completedWorkStepIds.addAll(recordIds);
                }
            }
        }
        /** JIRA#: LEM-1115 & LEM-1377 - Update the Link Implementation WorkStep status
         * as per the link implementation outcome value.
         */
        completedWorkStepIds.addAll(
            updateLinkImplementationWorkStepsStatus(implementationCallRelatedWorkPlanIds)
        );
        //JIRA#: LEM-1142 - It updates Status of dependent WorkStep to Not Started.
        handleDependentWorkStepsStatusUpdates(completedWorkStepIds, WORK_STEP_STATUS_NOT_STARTED);
    }

    /**
     * @description It updates Status of "Link Implementation" WorkStep present
     * in the passed WorkPlan as per the link implementation call outcome value.
     * @JIRA# LEM-1115 & LEM-1377 & LEM-3154
     * @param workPlanIds - Set of WorkPlansIds
     * @return Set<Id> - Set of completed WorkStepIds
     */
    private static Set<Id> updateLinkImplementationWorkStepsStatus(Set<Id> workPlanIds) {
        Set<Id> completedWorkStepIds = new Set<Id>();
        if (workPlanIds.isEmpty()) {
            return completedWorkStepIds;
        }
        fflib_ISObjectUnitOfWork uowToUpdateWorkSteps = Application.UNITOFWORK.newInstance();
        Map<Id, String> workPlanIdToLinkImplementationStatus = new Map<Id, String>();
        List<WorkStep> linkImplementations = new List<WorkStep>();
        for (
            WorkStep eachWorkStep : WorkStepsSelector.newInstance()
                .selectLinkImplementationWorkStepAttachedToWorkPlan(workPlanIds)
        ) {
            switch on WORKSTEPTYPEMAPPINGS.get(eachWorkStep.Type__c) {
                when WORK_STEP_TYPE_IMPLEMENTATION_CALL {
                    workPlanIdToLinkImplementationStatus.put(
                        eachWorkStep.WorkPlanId,
                        IMPLEMENTATION_CALL_STATUS_VALUES.get(eachWorkStep.Status__c)
                    );
                }
                when WORK_STEP_TYPE_LINK_IMPLEMENTATION {
                    linkImplementations.add(eachWorkStep);
                }
            }
        }
        String statusValue;
        for (WorkStep eachWorkStep : linkImplementations) {
            statusValue = workPlanIdToLinkImplementationStatus.get(eachWorkStep.WorkPlanId);
            eachWorkStep.Status__c = statusValue;
            if (statusValue == WORK_STEP_STATUS_COMPLETE) {
                completedWorkStepIds.add(eachWorkStep.Id);
            }
            uowToUpdateWorkSteps.registerDirty(eachWorkStep);
        }
        try {
            uowToUpdateWorkSteps.commitWork();
        } catch (Exception workStepsStatusUpdateException) {
            Logger.publish(
                LogEntry.newExceptionLog(
                    workStepsStatusUpdateException,
                    LogEntry.SeverityLevel.HIGH
                )
            );
        }
        return completedWorkStepIds;
    }

    /**
     * @description It initiates status rollup logic using platform events when current user matches
     * the permission criteria or synchronously if the permission criteria doesn't match.
     * @JIRA# LEM-582,LEM-527 & LEM-4218
     */
    private void initiateStatusRollup() {
        if (parentIdsOfWorkStepsWithChangedStatus.isEmpty()) {
            return;
        }
        if (
            FeatureManagementService.newInstance()
                .checkPermission(System.Label.EnableAsyncWorkStepsStatusRollupCustomPermissionName)
        ) {
            Integer workStepParentIdsChunkSize = Integer.valueOf(
                StaticConfigurationsSelector.newInstance()
                    .getInstanceValue(WORK_STEP_PARENT_IDS_CHUNK_SIZE_STATIC_CONFIG)
                    .Configuration_Value__c
            );
            NotifierEventsService.publishBulkEvents(
                new Map<String, List<String>>{
                    EVENT_TOPIC_WORK_STEPS_STATUS_ROLL_UP => NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                        parentIdsOfWorkStepsWithChangedStatus,
                        workStepParentIdsChunkSize
                    )
                }
            );
        } else {
            WorkStepsService.runWorkStepStatusCalculationsOnParentRecords(
                parentIdsOfWorkStepsWithChangedStatus
            );
        }
    }

    /**
     * @description It collects parent WorkStep Id of the passed child WorkStep.
     * @JIRA# LEM-2043
     * @param workStepRecord
     */
    private void collectParentWorkStepsId(WorkStep workStepRecord) {
        if (workStepRecord.Parent_Work_Step__c == null) {
            return;
        }
        parentWorkStepIdsOfBlockedOrResolvedWorkSteps.add(workStepRecord.Parent_Work_Step__c);
    }

    /**
     * @description It collects parent WorkStep Ids for rescue process related calculations.
     * @JIRA# LEM-2043
     * @param newWorkStep
     * @param oldWorkStep
     */
    private void collectParentWorkStepIdsOfBlockedAndResolvedWorkSteps(
        WorkStep newWorkStep,
        WorkStep oldWorkStep
    ) {
        if (
            isWorkStepStatusBlocked(newWorkStep.Status__c) ||
            isWorkStepStatusResolved(newWorkStep.Status__c)
        ) {
            collectParentWorkStepsId(newWorkStep);
        }
        if (
            isWorkStepStatusBlocked(oldWorkStep.Status__c) ||
            isWorkStepStatusResolved(oldWorkStep.Status__c)
        ) {
            collectParentWorkStepsId(oldWorkStep);
        }
    }

    /**
     * @description It collect Parent Ids where WorkStep Status is changed in a set.
     * @JIRA# LEM-582 & LEM-527
     * @param sObjectId
     */
    private void collectParentIdsOfWorkStepsWithChangedStatus(Id sObjectId) {
        if (sObjectId == null) {
            return;
        }
        parentIdsOfWorkStepsWithChangedStatus.add(sObjectId);
    }

    /**
     * @description It collects WorkStep where "Parent Work Step" is blank.
     * @JIRA# LEM-530
     * @param newWorkStep
     */
    private void collectParentWorkStepsWithChangedStatus(WorkStep newWorkStep) {
        if (String.isBlank(String.valueOf(newWorkStep.Parent_Work_Step__c))) {
            parentWorkStepsWithChangedStatus.put(newWorkStep.Id, newWorkStep);
        }
    }

    /**
     * @description It copies "Account Owner Email Calculated" (formula field)
     * to "Account Owner Email Id" (email field).
     * @JIRA# LEM-2045
     * @param workStep
     */
    private void copyAccountOwnerEmail(WorkStep workStep) {
        workStep.Account_Owner_Email_Id__c = workStep.Account_Owner_Email_Calculated__c;
    }

    /**
     * @description It copy custom WorkStep Status field value on OOTB Work Step Status field.
     * @JIRA# LEM-1120
     * @param workStep - WorkStep record
     */
    private void copyCustomStatusValueOnStandardStatusField(WorkStep workStep) {
        workStep.Status = workStep.Status__c;
    }

    /**
     * @description It checks whether Work Step Escalation is Resolved.
     * @JIRA# LEM-1044
     * @param newWorkStep - new WorkStep Record
     * @param oldWorkStep - old WorkStep Record
     * @return Boolean
     */
    private Boolean hasSetupMenuWorkStepEscalationResolved(
        WorkStep newWorkStep,
        WorkStep oldWorkStep
    ) {
        return evaluateANDLogicalOperator(
            evaluateANDLogicalOperator(
                newWorkStep.Type__c == WORK_STEP_TYPE_SETUP_MENU,
                newWorkStep.Menu_Error_Type__c != null
            ),
            !WORK_STEP_BLOCKED_STATUSES.contains(newWorkStep.Status__c)
        );
    }

    /**
     * @description It copy custom Work Step Status field value on OOTB Work Step Status field.
     * @JIRA# LEM-793
     * @param newWorkStep - new WorkStep Record
     * @param oldWorkStep - old WorkStep Record
     * @return Boolean
     */
    private Boolean hasWorkStepStatusChanged(WorkStep newWorkStep, WorkStep oldWorkStep) {
        return newWorkStep.Status__c != oldWorkStep.Status__c;
    }

    /**
     * @description It blanks Work Step Status Reason and Status Reason Details field values.
     * @JIRA# LEM-15697
     * @param newWorkStep - new WorkStep Record
     * @param oldWorkStep - old WorkStep Record
     */
    private void refreshWorkStepStatusReasonAndStatusReasonDetails(
        WorkStep newWorkStep,
        WorkStep oldWorkStep
    ) {
        if (hasWorkStepStatusResolvedFromBlocked(newWorkStep, oldWorkStep)) {
            if (!hasWorkStepStatusReasonChanged(newWorkStep, oldWorkStep)) {
                newWorkStep.Status_Reason__c = '';
            }
            if (!hasWorkStepStatusReasonDetailsChanged(newWorkStep, oldWorkStep)) {
                newWorkStep.Status_Reason_Details__c = '';
            }
        }
    }

    /**
     * @description It checks whether the Status is moved from blocked values to unblocked.
     * @JIRA# LEM-15697
     * @param newWorkStep - new WorkStep Record
     * @param oldWorkStep - old WorkStep Record
     * @return Boolean
     */
    private Boolean hasWorkStepStatusResolvedFromBlocked(
        WorkStep newWorkStep,
        WorkStep oldWorkStep
    ) {
        return (!WORK_STEP_RESTRICTED_STATUSES_WITHOUT_STATUS_REASON.contains(
                newWorkStep.Status__c
            )) &&
            WORK_STEP_RESTRICTED_STATUSES_WITHOUT_STATUS_REASON.contains(oldWorkStep.Status__c);
    }

    /**
     * @description It checks whether the Work Step Status Reason field value is updated.
     * @JIRA# LEM-15697
     * @param newWorkStep - new WorkStep Record
     * @param oldWorkStep - old WorkStep Record
     * @return Boolean
     */
    private Boolean hasWorkStepStatusReasonChanged(WorkStep newWorkStep, WorkStep oldWorkStep) {
        return newWorkStep.Status_Reason__c != oldWorkStep.Status_Reason__c;
    }

    /**
     * @description It checks whether the Work Step Status Reason Details field value is updated.
     * @JIRA# LEM-15697
     * @param newWorkStep - new WorkStep Record
     * @param oldWorkStep - old WorkStep Record
     * @return Boolean
     */
    private Boolean hasWorkStepStatusReasonDetailsChanged(
        WorkStep newWorkStep,
        WorkStep oldWorkStep
    ) {
        return newWorkStep.Status_Reason_Details__c != oldWorkStep.Status_Reason_Details__c;
    }

    /**
     * @description It checks whether the Work Step satisfies criteria to send the notification for
     * Tablet Case creation in Figment environment.
     * @JIRA# LEM-4386
     * @param workStep
     * @return Boolean
     */
    private Boolean isEligibleToNotifyTabletCaseCreation(WorkStep workStep) {
        return workStep.Type__c == WORK_STEP_TYPE_DELIVER_TABLET &&
            workStep.Parent_Work_Step__c != null &&
            workStep.Segment__c != SEGMENT_SMB;
    }

    /**
     * @description It checks whether "Implementation Call" WorkStep's Link Implementation Call
     * Outcome is changed to "Mx to implement link" or "Implemented on the call".
     * @JIRA# LEM-1115 & LEM-3154
     * @param newWorkStep - new WorkStep Record
     * @param oldWorkStep - old WorkStep Record
     * @return Boolean
     */
    private Boolean isEligibleLinkImplemenationOutcomeWorkStep(
        WorkStep newWorkStep,
        WorkStep oldWorkStep
    ) {
        return evaluateANDLogicalOperator(
            hasWorkStepStatusChanged(newWorkStep, oldWorkStep),
            IMPLEMENTATION_CALL_STATUS_VALUES.keySet().contains(newWorkStep.Status__c)
        );
    }

    /**
     * @description It checks whether the Work Step satisfies criteria to send the notification for
     * Tablet Case creation in Figment environment.
     * @JIRA# LEM-12073
     * @param newWorkStep
     * @param oldWorkStep
     * @return Boolean
     */
    private Boolean isEligibleToNotifyTabletCaseCreationByWorkStepStatus(
        WorkStep newWorkStep,
        WorkStep oldWorkStep
    ) {
        return newWorkStep.Type__c == WORK_STEP_TYPE_DELIVER_TABLET &&
            oldWorkStep.Status__c == WORK_STEP_STATUS_NOT_WORKABLE &&
            ELIGIBLE_WORK_STEP_STATUSES_TO_NOTIFY_TABLET_CASE_CREATION.contains(
                newWorkStep.Status__c
            ) &&
            newWorkStep.Figment_Id__c == null &&
            newWorkStep.Parent_Work_Step__c != null;
    }

    /**
     * @description It checks whether Deliver Tablet Work Step Status is changed
     * from Escalated/Blocked to In Progress and is eligble to send Tablet Case notification.
     * @JIRA# LEM-1087 & LEM-4400
     * @param newWorkStep
     * @param oldWorkStep
     * @return Boolean
     */
    private Boolean isDeliverTabletWorkStepUnblocked(WorkStep newWorkStep, WorkStep oldWorkStep) {
        return evaluateANDLogicalOperator(
            (evaluateANDLogicalOperator(
                evaluateANDLogicalOperator(
                    evaluateANDLogicalOperator(
                        newWorkStep.Type__c == WORK_STEP_TYPE_DELIVER_TABLET,
                        newWorkStep.Status__c == WORK_STEP_STATUS_IN_PROGRESS
                    ),
                    evaluateANDLogicalOperator(
                        WORK_STEP_BLOCKED_STATUSES.contains(oldWorkStep.Status__c),
                        !FeatureManagementService.newInstance()
                            .checkPermission(RESTRICT_TABLET_CASE_NOTIFICATION)
                    )
                ),
                newWorkStep.Parent_Work_Step__c != null
            )),
            newWorkStep.Segment__c != SEGMENT_SMB
        );
    }

    /**
     * @description It checks whether WorkStep Status is Blocked.
     * @JIRA# LEM-2043
     * @param workStepStatus - WorkStep record status
     * @return Boolean
     */
    private Boolean isWorkStepStatusBlocked(String workStepStatus) {
        return workStepStatus == WORK_STEP_STATUS_BLOCKED;
    }

    /**
     * @description It checks whether Work Step Status is restricted without populating Status Reason value.
     * @JIRA# LEM-4629
     * @param workStep
     * @return Boolean
     */
    private Boolean isWorkStepStatusRestrictedWithoutStatusReason(WorkStep workStep) {
        return evaluateANDLogicalOperator(
            WORK_STEP_RESTRICTED_STATUSES_WITHOUT_STATUS_REASON.contains(workStep.Status__c),
            String.isBlank(workStep.Status_Reason__c)
        );
    }

    /**
     * @description It checks whether WorkStep Status is Complete.
     * @JIRA# LEM-1142
     * @param workStepStatus - WorkStep record status
     * @return Boolean
     */
    private Boolean isWorkStepStatusComplete(String workStepStatus) {
        return WORK_STEP_COMPLETE_STATUSES.contains(workStepStatus);
    }

    /**
     * @description It checks whether Work Step Status is Dead.
     * @JIRA# LEM-3517
     * @param workStepStatus
     * @return Boolean
     */
    private Boolean isWorkStepStatusDead(String workStepStatus) {
        return workStepStatus == WORK_STEP_STATUS_DEAD;
    }

    /**
     * @description It checks whether WorkStep Status is Resolved.
     * @JIRA# LEM-2043
     * @param workStepStatus - WorkStep record status
     * @return Boolean
     */
    private Boolean isWorkStepStatusResolved(String workStepStatus) {
        return workStepStatus == WORK_STEP_STATUS_RESOLVED;
    }

    /**
     * @description It restricts EPM persona's users from updating Work Step status through UI
     * other than from Blocked to Resolved.
     * @JIRA# LEM-2346
     * @param newWorkStep
     * @param oldWorkStep
     */
    private void restrictEPMToUpdateStatus(WorkStep newWorkStep, WorkStep oldWorkStep) {
        if (
            evaluateANDLogicalOperator(
                evaluateANDLogicalOperator(
                    evaluateANDLogicalOperator(
                        FeatureManagementService.newInstance()
                            .checkPermission(RESTRICT_WORK_STEP_STATUS_UPDATES),
                        !newWorkStep.Is_Updated_By_System__c
                    ),
                    !evaluateANDLogicalOperator(
                        isWorkStepStatusBlocked(oldWorkStep.Status__c),
                        isWorkStepStatusResolved(newWorkStep.Status__c)
                    )
                ),
                !(FeatureManagementService.newInstance()
                    .checkPermission(ALLOW_WORK_STEP_STATUS_UPDATES))
            )
        ) {
            newWorkStep.addError(
                error(System.Label.ErrorMessage_WorkStep_RestrictEPMToUpdateStatus, newWorkStep)
            );
        }
    }

    /**
     * @description It restricts users from updating Work Step Status to Blocked/Dead/Escalated
     * without populating Status Reason value.
     * @JIRA# LEM-4629
     * @param newWorkStep
     * @param oldWorkStep
     */
    private void restrictUserToUpdateStatusWithoutStatusReason(
        WorkStep newWorkStep,
        WorkStep oldWorkStep
    ) {
        if (
            evaluateANDLogicalOperator(
                isWorkStepStatusRestrictedWithoutStatusReason(newWorkStep),
                !newWorkStep.Is_Updated_By_System__c
            ) &&
            !FeatureManagementService.newInstance()
                .checkPermission(System.Label.EnableAsyncWorkStepsStatusRollupCustomPermissionName)
        ) {
            newWorkStep.Status_Reason__c.addError(
                error(
                    System.Label.ErrorMessageWorkStepStatusCannotChangeWithoutStatusReason,
                    newWorkStep
                )
            );
        }
    }

    /**
     * @description It passes parent WorkStep Ids of Blocked or Resolved child Work Steps to
     * NotifierEvent to calculate number of blocked and number of resolved child Work Steps.
     * @JIRA# LEM-2043
     */
    private void triggerRescueProcessCalculations() {
        if (parentWorkStepIdsOfBlockedOrResolvedWorkSteps.isEmpty()) {
            return;
        }
        NotifierEventsService.publishEvents(
            new Map<String, String>{
                EVENT_TOPIC_WORK_STEPS_CALCULATION => JSON.serialize(
                    parentWorkStepIdsOfBlockedOrResolvedWorkSteps
                )
            }
        );
    }

    /**
     * @description It updates Work Step statuses for 'Place It For Me' Work Orders.
     * @JIRA# LEM-15585
     * @param workStep
     */
    private void updatePlaceItForMeWorkStepStatus(WorkStep workStep) {
        if (workStep.Type__c == WORK_STEP_TYPE_IMPLEMENTATION_CALL) {
            workStep.Status__c = WORK_STEP_STATUS_ESCALATED;
            workStep.Status_Reason__c = WORK_STEP_STATUS_PIFM_LEAD;
        }
        if (workStep.Type__c == WORK_STEP_TYPE_SETUP_STOREFRONT_PAGE) {
            workStep.Status__c = WORK_STEP_STATUS_COMPLETE;
        }
    }

    /**
     * @description It updates Work Steps Status on creation based on Work Order creation source.
     * @JIRA# LEM-13961
     * @param inboundIntegrationWorkStepsForStatusUpdate
     */
    private void updateWorkStepStatusByParentWorkOrderCreationSource(
        List<WorkStep> inboundIntegrationWorkStepsForStatusUpdate
    ) {
        for (WorkStep eachWorkStep : inboundIntegrationWorkStepsForStatusUpdate) {
            if (
                eachWorkStep.Parent_Work_Order_Creation_Source__c ==
                WORK_ORDER_CREATION_SOURCE_PLACE_IT_FOR_ME
            ) {
                updatePlaceItForMeWorkStepStatus(eachWorkStep);
            } else if (
                INTEGRATION_SOURCE_WORKSTEPS_TYPES_TO_STATUS_UPDATE_TO_COMPLETE.contains(
                    eachWorkStep.Parent_Work_Order_Creation_Source__c +
                        SEPARATOR +
                        eachWorkStep.Type__c
                )
            ) {
                eachWorkStep.Status__c = WORK_STEP_STATUS_COMPLETE;
            }
            copyCustomStatusValueOnStandardStatusField(eachWorkStep);
        }
    }

    /**
     * @description It updates the Menu Error Type to blank when WorkStep's escalation is resolved.
     * @JIRA# LEM-1044
     * @param workStep - WorkStep record to update
     */
    private void updateWorkStepMenuErrorTypeToBlank(WorkStep workStep) {
        workStep.Menu_Error_Type__c = null;
    }

    /**
     * @description This class is used for implementing fflib_IDomainConstructor Interface
     */
    public class Constructor implements fflib_IDomainConstructor {
        /**
         * @description Constructor method implementation from fflib_IDomainConstructor class
         * @param objectList
         * @return WorkSteps - List of WorkSteps
         */
        public fflib_SObjects construct(List<Object> objectList) {
            if (WorkSteps.constructorMock != null) {
                return (fflib_SObjects) WorkSteps.constructorMock.construct(objectList);
            }
            return new WorkSteps((List<SObject>) objectList);
        }
    }
}