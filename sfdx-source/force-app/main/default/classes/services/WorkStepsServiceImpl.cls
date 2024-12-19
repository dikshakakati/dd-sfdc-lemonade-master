/**
 * @author Deloitte
 * @date 04/15/2022
 * @description Service implementation class for WorkStep related logic.
 */
@SuppressWarnings('PMD.CyclomaticComplexity,PMD.ExcessiveClassLength')
public inherited sharing class WorkStepsServiceImpl implements IWorkStepsService {
    private static final String ACTIVATION_CHECKLIST_VALIDATIONS_STATIC_CONFIG = 'Activations_Checklist_Validations';
    private static final String CHILD_WORK_STEPS_TO_UPDATE_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG = 'Child_Work_Steps_Payload_Chunk_Size';
    private Integer childWorkStepsToUpdatePayloadChunkSize;
    private static final String ACTIVATION_CHECKLIST_EVENT_NAME = 'activation-checklist-event';
    private static final String ACTIVATION_CHECKLIST_PAYLOAD_CONTENT_TYPE = 'application/json';
    private static final String ACTIVATION_CHECKLIST_VALIDATION_SOURCE = 'ddmx';
    private static final String ACTIVATION_CHECKLIST_VALIDATION_VERSION = '1.0';
    private static final String CHURNED_MERCHANT_CONTRACT_TYPE = 'Churned Merchant';
    private static final String COMMA_SPLIT = ',';
    private static final String COMPARISON_OPERATOR_EQUALS = 'equals';
    private static final String COMPARISON_OPERATOR_CONTAINS = 'contains';
    private static final String CURRENT_RETRY_COUNT = 'Current Retry Count: ';
    private static final String EVENT_TOPIC_REINITIATE_WORK_STEPS_STATUS_ROLL_UP = 'REINITIATE_WORK_STEPS_STATUS_ROLL_UP';
    private static final String EVENT_TOPIC_STOREFRONT_PARENT_WORK_STEP_STATUS_UPDATE = 'STOREFRONT_PARENT_WORK_STEP_STATUS_UPDATE';
    private static final String EVENT_TOPIC_STOREFRONT_WORK_STEPS_STATUS_UPDATE = 'STOREFRONT_WORK_STEPS_STATUS_UPDATE';
    private static final String EVENT_TOPIC_WORK_STEPS_STATUS_ROLL_UP = 'WORK_STEPS_STATUS_ROLL_UP';
    private static final String EVENT_TOPIC_UPDATE_CHILD_WORKSTEPS_ON_PARENT = 'UPDATE_CHILD_WORKSTEPS_ON_PARENT';
    private static final String EXCEEDED_MAXIMUM_RETRY_LIMIT_ERROR_MESSAGE = 'Maximum retry limit exceeded for Work Steps status rollup.';
    private static final String PIPELINE_SEPARATOR = ' || ';
    private static final String SEPARATOR = '~';
    private static final String STATUS_AT_RISK = 'At Risk';
    private static final String STATUS_BLOCKED = 'Blocked';
    private static final String STATUS_COMPLETE = 'Complete';
    private static final String STATUS_DEAD = 'Dead';
    private static final String STATUS_FRAUD = 'Fraud';
    private static final String STATUS_ESCALATED = 'Escalated';
    private static final String STATUS_GONE_DARK = 'Gone Dark';
    private static final String STATUS_IN_PROGRESS = 'In Progress';
    private static final String STATUS_NOT_STARTED = 'Not Started';
    private static final String STATUS_NOT_WORKABLE = 'Not Workable';
    private static final String STATUS_ONBOARDING_COMPLETE = 'Onboarding Complete';
    private static final String STATUS_PAST_DUE = 'Past Due';
    private static final String STATUS_PLANNING = 'Planning';
    private static final String STATUS_QA_COMPLETE = 'QA Complete';
    private static final String STATUS_READY_FOR_QA = 'Ready for QA';
    private static final String STATUS_REASON_OTHER = 'Other';
    private static final String STATUS_RESOLVED = 'Resolved';
    private static final String STATUS_ROLLUP_METHOD_NAME = 'updateParentObjectsStatus';
    private static final String STATUS_REASON_STRIPE_KYC_SUCCESSFUL = 'Stripe KYC Verification Successful';
    private static final String STATUS_REASON_STRIPE_KYC_PENDING = 'Stripe KYC Verification Pending';
    private static final String WORK_STEP_NAME_SETUP_BANKING = 'Setup Banking';
    private static final String SYSTEM_ERROR = 'System Error';
    private static final String TIMEFORMAT = 'yyyy-MM-dd\'T\'HH:mm:ss\'Z\'';
    private static final String TIMESTAMPZONE = 'GMT';
    private static final String WORK_ORDER_ACTIVATION_STATUS_INACTIVE = 'Inactive';
    private static final String WORK_STEP_TYPE_REVIEW_AND_TRIAGE = 'Review & Triage';
    private static final String WORK_STEP_TYPE_SETUP_STORE = 'Setup Store';
    private static final String WORK_STEP_TYPE_SETUP_BUSINESS = 'Setup Business';
    private static final String WORK_STEP_TYPE_SETUP_STOREFRONT_PAGE = 'Setup Storefront Page';
    private static final String WORK_STEP_FAILURE_STATUS_DETAIL = 'Failure due to Integration or MINT system downtime, try again by clicking Validate button on Activation Checklist tab';
    private static final String WORK_STEP_STATUS_ROLLUP_RETRY_LIMIT_STATIC_CONFIG = 'Work_Step_Status_Rollup_Retry_Limit';
    private static final String LOG_SERVICE_WORK_STEP = 'Work Step Service';
    private static final String LOG_DOMAIN_PROVISIONING = 'Provisioning';
    private final static String XREF_EXTERNAL_ID_SOURCE_MDS = 'MDS';
    private static final String DOCUMENTATION_REQUIRED = 'Documentation Required';
    private static final String FOLLOW_UP_NEEDED = 'Follow Up Needed';
    private static final String DENIED = 'Denied';
    private static final String APPROVED = 'Approved';
    private static final String MARKETPLACE = 'Marketplace';
    private static final String STOREFRONT = 'Storefront';

    private enum EventTopics {
        EVENTTOPIC_REINITIATE_WORK_STEPS_STATUS_ROLL_UP,
        EVENTTOPIC_STOREFRONT_PARENT_WORK_STEP_STATUS_UPDATE,
        EVENTTOPIC_STOREFRONT_WORK_STEPS_STATUS_UPDATE,
        EVENTTOPIC_WORK_STEPS_STATUS_ROLL_UP,
        EVENTTOPIC_UPDATE_CHILD_WORKSTEPS_ON_PARENT
    }
    private static final Map<String, EventTopics> EVENT_TOPIC_MAPPINGS = new Map<String, EventTopics>{
        EVENT_TOPIC_REINITIATE_WORK_STEPS_STATUS_ROLL_UP => EventTopics.EVENTTOPIC_REINITIATE_WORK_STEPS_STATUS_ROLL_UP,
        EVENT_TOPIC_STOREFRONT_PARENT_WORK_STEP_STATUS_UPDATE => EventTopics.EVENTTOPIC_STOREFRONT_PARENT_WORK_STEP_STATUS_UPDATE,
        EVENT_TOPIC_STOREFRONT_WORK_STEPS_STATUS_UPDATE => EventTopics.EVENTTOPIC_STOREFRONT_WORK_STEPS_STATUS_UPDATE,
        EVENT_TOPIC_WORK_STEPS_STATUS_ROLL_UP => EventTopics.EVENTTOPIC_WORK_STEPS_STATUS_ROLL_UP,
        EVENT_TOPIC_UPDATE_CHILD_WORKSTEPS_ON_PARENT => EventTopics.EVENTTOPIC_UPDATE_CHILD_WORKSTEPS_ON_PARENT
    };

    private enum BUSINESS_VERIFICATION_STATUS {
        DOCUMENTATION_REQUIRED,
        FOLLOW_UP_NEEDED,
        DENIED,
        APPROVED
    }

    private static final Map<String, BUSINESS_VERIFICATION_STATUS> BUSINESS_VERIFICATION_STATUS_MAPPINGS = new Map<String, BUSINESS_VERIFICATION_STATUS>{
        DOCUMENTATION_REQUIRED => BUSINESS_VERIFICATION_STATUS.DOCUMENTATION_REQUIRED,
        FOLLOW_UP_NEEDED => BUSINESS_VERIFICATION_STATUS.FOLLOW_UP_NEEDED,
        DENIED => BUSINESS_VERIFICATION_STATUS.DENIED,
        APPROVED => BUSINESS_VERIFICATION_STATUS.APPROVED
    };

    private enum WORK_ORDER_TYPE {
        MARKETPLACE,
        STOREFRONT
    }

    private static final Map<String, WORK_ORDER_TYPE> WORK_ORDER_TYPE_MAPPINGS = new Map<String, WORK_ORDER_TYPE>{
        MARKETPLACE => WORK_ORDER_TYPE.MARKETPLACE,
        STOREFRONT => WORK_ORDER_TYPE.STOREFRONT
    };

    private enum ParentObjectTypes {
        ACCOUNT,
        WORKORDER,
        WORKPLAN,
        WORKSTEP
    }
    private static final Map<Schema.SobjectType, ParentObjectTypes> SOBJECTTYPETOPARENTOBJECTTYPES = new Map<Schema.SobjectType, ParentObjectTypes>{
        Account.SObjectType => ParentObjectTypes.ACCOUNT,
        WorkOrder.SObjectType => ParentObjectTypes.WORKORDER,
        WorkPlan.SObjectType => ParentObjectTypes.WORKPLAN,
        WorkStep.SObjectType => ParentObjectTypes.WORKSTEP
    };
    private static final String ULTIMATE_PARENT_AGGREGATE_QUERY_GROUPBYFIELD_ALIAS = 'parentId';
    private static final String ULTIMATE_PARENT_AGGREGATE_QUERY_STATUS_ALIAS = 'workStepStatus';
    private static final String ULTIMATE_PARENT_WORK_ORDER_CONDITION = 'WorkOrder.ParentWorkOrder.Status NOT IN :WORK_ORDER_PRIORITY_STATUSES';
    private static final String ULTIMATE_PARENT_WORK_ORDER_GROUPBYFIELD = 'WorkOrder.ParentWorkOrderId';
    private static final String ULTIMATE_PARENT_WORK_PLAN_CONDITION = null;
    private static final String ULTIMATE_PARENT_WORK_PLAN_GROUPBYFIELD = 'WorkPlan.Parent_Work_Plan__c';
    private static final String ULTIMATE_PARENT_WORK_STEP_CONDITION = null;
    private static final String ULTIMATE_PARENT_WORK_STEP_GROUPBYFIELD = 'Parent_Work_Step__c';
    private static final String WORKPLAN_NAME_STOREFRONT = 'Storefront';
    private static final Set<String> WORKPLAN_SPECIFIC_STATUSES = new Set<String>{ STATUS_DEAD };
    private static final Set<String> WORKORDER_COMPLETION_STATUSES = new Set<String>{
        STATUS_COMPLETE,
        STATUS_DEAD
    };
    private static final Set<String> ACTIVATION_CHECKLIST_WORKSTEP_STATUSES_TO_SKIP_ROLLUP = new Set<String>{
        STATUS_BLOCKED,
        STATUS_COMPLETE,
        STATUS_DEAD
    };
    private static final Set<String> WORK_ORDER_ALLOWED_STATUSES_WITH_PAST_DATES = new Set<String>{
        STATUS_ONBOARDING_COMPLETE,
        STATUS_DEAD
    };
    private static final Set<String> WORK_ORDER_PRIORITY_STATUSES = new Set<String>{
        STATUS_AT_RISK,
        STATUS_PAST_DUE
    };
    private static final Set<String> IMPLEMENTATIONCALL_WORKSTEP_COMPLETION_STATUSES = new Set<String>{
        'Complete - DoorDash to implement link',
        'Complete - Mx to implement link',
        'Complete - Implemented on the call'
    };
    private String activationChecklistValidations;
    private Set<Id> initialPayload;
    private Set<Id> parentWorkStepIds;
    private Integer rollUpReExecutionLimit;
    private Integer rollupRetryCount;
    private Map<Id, String> sObjectIdToCurrentStatus;
    private Map<Id, Set<String>> sObjectIdToWorkStepStatuses;
    private Set<String> statusesToCompare;
    private Map<Schema.SobjectType, Set<Id>> ultimateParentTypeToUltimateParentIds;
    private Set<Id> workOrderIds;
    private Set<Id> workOrderIdsWithPastDates;
    private Set<Id> workOrderIdsWithChurnedMxContracts;
    private Set<Id> workPlanIds;
    private List<Work_Step_Status_Mapping__mdt> workStepsStatusMappings;

    /**
     * @description Default constructor for this class.
     */
    public WorkStepsServiceImpl() {
        this.initialPayload = new Set<Id>();
        this.parentWorkStepIds = new Set<Id>();
        this.rollupRetryCount = 0;
        this.sObjectIdToCurrentStatus = new Map<Id, String>();
        this.sObjectIdToWorkStepStatuses = new Map<Id, Set<String>>();
        this.statusesToCompare = new Set<String>();
        this.workOrderIds = new Set<Id>();
        this.workOrderIdsWithPastDates = new Set<Id>();
        this.workOrderIdsWithChurnedMxContracts = new Set<Id>();
        this.workPlanIds = new Set<Id>();
        this.workStepsStatusMappings = new List<Work_Step_Status_Mapping__mdt>();
        this.ultimateParentTypeToUltimateParentIds = new Map<Schema.SobjectType, Set<Id>>();
        collectStaticConfigurations();
        getWorkStepStatusMappings();
    }

    /**
     * @description Collect child Activation Checklist Work Steps details and generate
     * request payload for outbound integration.
     * @JIRA# LEM-13305
     * @param activationChecklistWorkSteps
     */
    public void collectChildActivationChecklistWorkStepsForOutboundIntegration(
        Set<Id> activationChecklistWorkSteps
    ) {
        if (
            activationChecklistWorkSteps.isEmpty() &&
            !String.isBlank(activationChecklistValidations)
        ) {
            return;
        }
        ActivationChecklistOutboundWrapper.ActivationChecklistDetails activationChecklistDetailsWrapper;
        List<ActivationChecklistOutboundWrapper.ActivationChecklistDetails> activationChecklistDetails = new List<ActivationChecklistOutboundWrapper.ActivationChecklistDetails>();
        List<String> validations = activationChecklistValidations.split(COMMA_SPLIT);
        List<WorkStep> activationChecklistChildWorkSteps = new List<WorkStep>();
        Set<Id> storeAccountIds = new Set<Id>();
        Map<Id, Xref__c> storeAccountIdToXref = new Map<Id, Xref__c>();
        Id storeAccountId;
        Boolean doesXrefExists = false;
        Xref__c xrefAssociatedToStore;
        for (
            WorkStep eachChildWorKStep : WorkStepsSelector.newInstance()
                .selectChildWorkStepsByParentWorkStepIds(activationChecklistWorkSteps)
        ) {
            if (eachChildWorKStep.WorkOrder.Status == STATUS_DEAD) {
                continue;
            }
            activationChecklistChildWorkSteps.add(eachChildWorKStep);
            storeAccountIds.add(eachChildWorKStep.WorkOrder.AccountId);
        }
        if (activationChecklistChildWorkSteps.isEmpty()) {
            return;
        }
        for (
            Xref__c eachXref : XrefsSelector.newInstance()
                .selectBySalesforceAccountName(storeAccountIds)
        ) {
            if (eachXref.External_Id_Source__c == XREF_EXTERNAL_ID_SOURCE_MDS) {
                storeAccountIdToXref.put(eachXref.Salesforce_Account_Name__c, eachXref);
            }
        }
        for (WorkStep eachChildWorKStep : activationChecklistChildWorkSteps) {
            storeAccountId = eachChildWorKStep.WorkOrder.AccountId;
            doesXrefExists = storeAccountIdToXref.containsKey(storeAccountId);
            activationChecklistDetailsWrapper = new ActivationChecklistOutboundWrapper.ActivationChecklistDetails();
            if (doesXrefExists) {
                xrefAssociatedToStore = storeAccountIdToXref.get(storeAccountId);
                activationChecklistDetailsWrapper.storeId = xrefAssociatedToStore.External_ID__c;
                activationChecklistDetailsWrapper.businessId = xrefAssociatedToStore.BusinessID__c;
                activationChecklistDetailsWrapper.xrefSalesforceId = xrefAssociatedToStore.Id;
                activationChecklistDetailsWrapper.businessRefSalesforceId = xrefAssociatedToStore.Business_Reference__c;
            } else {
                activationChecklistDetailsWrapper.storeId = null;
                activationChecklistDetailsWrapper.businessId = null;
                activationChecklistDetailsWrapper.xrefSalesforceId = null;
                activationChecklistDetailsWrapper.businessRefSalesforceId = null;
            }
            activationChecklistDetailsWrapper.accountSalesforceId = eachChildWorKStep.WorkOrder.AccountId;
            activationChecklistDetailsWrapper.workStepSalesforceId = eachChildWorKStep.Id;
            activationChecklistDetailsWrapper.validationsList = validations;
            activationChecklistDetails.add(activationChecklistDetailsWrapper);
        }
        ActivationChecklistService.generatePayloadAndInitiateOutboundIntegration(
            activationChecklistDetails
        );
    }

    /**
     * @description It is used to map parent Work Order Ids to Work Steps.
     * @param workSteps
     * @return Map<Id, WorkStep>
     */
    public Map<Id, WorkStep> getParentWorkOrdersToWorkStep(List<WorkStep> workSteps) {
        Map<Id, WorkStep> parentWorkOrderIdToWorkStep = new Map<Id, WorkStep>();
        for (WorkStep eachWorkStep : workSteps) {
            parentWorkOrderIdToWorkStep.put(
                eachWorkStep?.Parent_Work_Step__r?.WorkOrderId,
                eachWorkStep
            );
        }
        return parentWorkOrderIdToWorkStep;
    }

    /**
     * @description It is used to handle Notifier Events to further process Work Step Ids
     * from the received payload.
     * @param events
     */
    public void handleNotifierEvents(List<Notifier__e> events) {
        Set<Id> parentIds = new Set<Id>();
        Set<Id> storeAccountIds = new Set<Id>();
        Set<Id> storefrontParentWorkStepIds = new Set<Id>();
        Set<Id> recordIdsByPayload;
        Set<WorkStep> childWorkSteps = new Set<WorkStep>();
        for (Notifier__e eachEvent : events) {
            switch on EVENT_TOPIC_MAPPINGS.get(eachEvent.Topic__c) {
                when EVENTTOPIC_REINITIATE_WORK_STEPS_STATUS_ROLL_UP {
                    WorkStepStatusEntry workStepStatusEntryInstance = (WorkStepStatusEntry) JSON.deserialize(
                        eachEvent.Payload__c,
                        WorkStepStatusEntry.class
                    );
                    recordIdsByPayload = workStepStatusEntryInstance.parentIds;
                    rollupRetryCount = workStepStatusEntryInstance.retryCount;
                    parentIds.addAll(recordIdsByPayload);
                }
                when EVENTTOPIC_STOREFRONT_PARENT_WORK_STEP_STATUS_UPDATE {
                    recordIdsByPayload = (Set<Id>) JSON.deserialize(
                        eachEvent.Payload__c,
                        Set<Id>.class
                    );
                    storefrontParentWorkStepIds.addAll(recordIdsByPayload);
                }
                when EVENTTOPIC_STOREFRONT_WORK_STEPS_STATUS_UPDATE {
                    recordIdsByPayload = (Set<Id>) JSON.deserialize(
                        eachEvent.Payload__c,
                        Set<Id>.class
                    );
                    storeAccountIds.addAll(recordIdsByPayload);
                }
                //@JIRA#: LEM-4218
                when EVENTTOPIC_WORK_STEPS_STATUS_ROLL_UP {
                    recordIdsByPayload = (Set<Id>) JSON.deserialize(
                        eachEvent.Payload__c,
                        Set<Id>.class
                    );
                    parentIds.addAll(recordIdsByPayload);
                }
                when EVENTTOPIC_UPDATE_CHILD_WORKSTEPS_ON_PARENT {
                    childWorkSteps.addAll(
                        (Set<WorkStep>) JSON.deserialize(eachEvent.Payload__c, Set<WorkStep>.class)
                    );
                }
            }
        }
        setStorefrontWorkStepsStatusByActivatedStores(storeAccountIds);
        setStorefrontParentWorkStepsStatus(storefrontParentWorkStepIds);
        runWorkStepStatusCalculationsOnParentRecords(parentIds);
        if (!childWorkSteps.isEmpty()) {
            updateChildWorkStepsOnParent(new List<WorkStep>(childWorkSteps));
        }
    }

    /**
     * @description It triggers WorkStep Status calculations to update WorkOrder & WorkPlan Status.
     * @JIRA# LEM-582 & LEM-527
     * @param parentIds
     */
    public void runWorkStepStatusCalculationsOnParentRecords(Set<Id> parentIds) {
        initialPayload.addAll(parentIds);
        separateAndCollectDifferentParentIds(parentIds);
        Boolean hasWorkPlanIds = workPlanIds != null && !workPlanIds.isEmpty();
        Boolean hasParentWorkStepIds = parentWorkStepIds != null && !parentWorkStepIds.isEmpty();
        Boolean hasOnlyWorkOrderIdsPassedByInitializer =
            workOrderIds != null &&
            !workOrderIds.isEmpty() &&
            !hasWorkPlanIds &&
            !hasParentWorkStepIds;
        for (
            WorkOrder eachWorkOrder : WorkOrdersSelector.newInstance()
                .selectWorkOrdersAndWorkStepsUsingWorkOrderIds(workOrderIds)
        ) {
            // Collect Work Order's current status
            sObjectIdToCurrentStatus.put(eachWorkOrder.Id, eachWorkOrder.Status);
            if (eachWorkOrder.ParentWorkOrderId != null) {
                // Collect Parent Work Order's current status
                sObjectIdToCurrentStatus.put(
                    eachWorkOrder.ParentWorkOrderId,
                    eachWorkOrder.ParentWorkOrder.Status
                );
            }
            for (WorkStep eachWorkStep : eachWorkOrder.WorkSteps) {
                if (hasOnlyWorkOrderIdsPassedByInitializer) {
                    //LEM-10804: Added logic to collect ultimate parent Ids through queried records in
                    //case only child work order Ids are passed from the calling class.
                    collectSobjectIdAndWorkStepStatusToCalculateStatus(
                        eachWorkStep.WorkPlanId,
                        eachWorkStep.Status
                    );
                    collectUltimateParentIds(eachWorkStep.Parent_Work_Step__c);
                    collectUltimateParentIds(eachWorkStep.WorkPlan.Parent_Work_Plan__c);
                }
                if (hasWorkPlanIds && workPlanIds.contains(eachWorkStep.WorkPlanId)) {
                    collectSobjectIdAndWorkStepStatusToCalculateStatus(
                        eachWorkStep.WorkPlanId,
                        eachWorkStep.Status
                    );
                    collectUltimateParentIds(eachWorkStep.WorkPlan.Parent_Work_Plan__c);
                }
                collectWorkOrderWithPastDueDates(eachWorkOrder);
                collectWorkOrderWithChurnedMxContracts(eachWorkOrder);
                collectSobjectIdAndWorkStepStatusToCalculateStatus(
                    eachWorkOrder.Id,
                    eachWorkStep.Status
                );
                collectUltimateParentIds(eachWorkOrder.ParentWorkOrderId);
            }
        }
        if (sObjectIdToWorkStepStatuses.isEmpty()) {
            return;
        }
        collectUltimateParentIds(getUnprocessedWorkSteps(parentWorkStepIds));
        runWorkStepsStatusCalculationOnUltimateParent();
        updateParentObjectsStatus();
    }

    /**
     * @description Update parent Activation Checklist Work Step status to 'In Progress'
     * after outbound integration request is sent.
     * @JIRA# LEM-13305
     * @param activationChecklistWorkSteps
     * @param isSystemError
     * @param workStepStatus
     */
    public void updateActivationChecklistWorkStepsStatus(
        Set<Id> activationChecklistWorkSteps,
        Boolean isSystemError,
        String workStepStatus
    ) {
        Map<Id, String> workStepIdToParentWorkStepStatus = new Map<Id, String>();
        if (activationChecklistWorkSteps.isEmpty()) {
            return;
        }
        Map<Id, String> parentWorkStepIdToStatus = new Map<Id, String>();
        List<WorkStep> updatedWorkSteps = new List<WorkStep>();
        WorkStep workStepToBeUpdated;
        Boolean isParentWorkStep;
        for (
            WorkStep eachWorkStep : WorkStepsSelector.newInstance()
                .selectByIds(activationChecklistWorkSteps)
        ) {
            workStepIdToParentWorkStepStatus.put(eachWorkStep.Id, eachWorkStep.Status__c);
            if (
                eachWorkStep.Parent_Work_Step__c != null &&
                String.isNotBlank(eachWorkStep.Parent_Work_Step__c)
            ) {
                activationChecklistWorkSteps.add(eachWorkStep.Parent_Work_Step__c);
                parentWorkStepIdToStatus.put(
                    eachWorkStep.Parent_Work_Step__c,
                    eachWorkStep.Parent_Work_Step__r.Status__c
                );
            }
        }
        for (Id eachWorkStepId : activationChecklistWorkSteps) {
            workStepToBeUpdated = new WorkStep(Id = eachWorkStepId);
            isParentWorkStep = parentWorkStepIdToStatus.containsKey(eachWorkStepId);
            // For parent Work Steps the Status update will be handled by existing roll up logic.
            if (!isParentWorkStep) {
                workStepToBeUpdated.Status__c = workStepStatus;
            }
            if (workStepStatus == STATUS_ESCALATED && isSystemError) {
                workStepToBeUpdated.Status_Reason_Details__c = WORK_STEP_FAILURE_STATUS_DETAIL;
                workStepToBeUpdated.Status_Reason__c = SYSTEM_ERROR;
            }
            if (!isSystemError) {
                workStepToBeUpdated.Status_Reason_Details__c = '';
                workStepToBeUpdated.Status_Reason__c = (workStepStatus == STATUS_ESCALATED ||
                    (isParentWorkStep &&
                    parentWorkStepIdToStatus.get(eachWorkStepId) == STATUS_ESCALATED))
                    ? STATUS_REASON_OTHER
                    : '';
            }
            updatedWorkSteps.add(workStepToBeUpdated);
        }
        fireUpdateOnParent(updatedWorkSteps);
    }

    /**
     * @description Publish Notifier Event with payload of parent WorkStep status changes.
     * @JIRA# LEM-530 and LEM-6856
     * @param parentWorkSteps
     */
    public void updateChildWorkStepsStatusOnParentWorkStepsStatusChange(
        Map<Id, WorkStep> parentWorkSteps
    ) {
        Set<SObject> childWorkStepsToUpdate = new Set<SObject>();
        if (parentWorkSteps.isEmpty()) {
            return;
        }
        WorkStep parentWorkStep;
        for (
            WorkStep eachWorkStep : WorkStepsSelector.newInstance()
                .selectChildWorkStepsByParentWorkStepIds(
                    getUnprocessedWorkSteps(parentWorkSteps.keySet())
                )
        ) {
            parentWorkStep = parentWorkSteps.get(eachWorkStep.Parent_Work_Step__c);
            eachWorkStep.Status__c = parentWorkStep.Status__c;
            eachWorkStep.Is_Updated_By_System__c = true;
            eachWorkStep.Status_Reason__c = parentWorkStep.Status_Reason__c;
            childWorkStepsToUpdate.add(eachWorkStep);
            // Add Parent WorkStep to processed record set
            WorkStepsService.processedWorkStepIds.add(eachWorkStep.Parent_Work_Step__c);
        }
        if (!childWorkStepsToUpdate.isEmpty()) {
            NotifierEventsService.publishBulkEvents(
                new Map<String, List<String>>{
                    EVENT_TOPIC_UPDATE_CHILD_WORKSTEPS_ON_PARENT => NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySObjects(
                        childWorkStepsToUpdate,
                        childWorkStepsToUpdatePayloadChunkSize
                    )
                }
            );
        }
    }

    /**
     * @description When WorkSteps are marked as Complete, remove the Status Reasons that are
     *              no longer applicable and add those that are applicable.
     * @param thisWorkStep - WorkStep record to update
     **/
    public void handleCompletionStatusReasonUpdates(WorkStep thisWorkStep) {
        // Skip if the WorkStep Status is not `Complete`
        if (thisWorkStep == null || thisWorkStep.Status__c != STATUS_COMPLETE) {
            return;
        }

        removeInapplicableStatusReasonsOnCompletion(thisWorkStep);
        updateStripeKycStatusUponCompletionOfSetupBanking(thisWorkStep);
    }

    /**
     * @description When WorkSteps are marked as Complete, remove the Status Reasons that are
     *              no longer applicable. This can be expanded to update/validate Status/Status Reason
     *              mappings generally.
     * @param thisWorkStep - WorkStep record to update
     **/
    private void removeInapplicableStatusReasonsOnCompletion(WorkStep thisWorkStep) {
        Boolean inPendingStatusReason =
            String.isNotBlank(thisWorkStep.Status_Reason__c) &&
            thisWorkStep.Status_Reason__c.contains(STATUS_REASON_STRIPE_KYC_PENDING);

        // The Work Step's Status should be "Complete" if we are in this method already, but
        // performing check here again anyway.
        if (thisWorkStep.Status__c == STATUS_COMPLETE && inPendingStatusReason) {
            // Define the regex pattern to match the status reason and potential trailing semicolon
            String pattern = STATUS_REASON_STRIPE_KYC_PENDING + '(;)?';

            // Replace the status reason and any trailing semicolon using regex
            thisWorkStep.Status_Reason__c = thisWorkStep.Status_Reason__c.replaceAll(pattern, '');

            if (String.isNotBlank(thisWorkStep.Status_Reason__c)) {
                // Remove any leading semicolon left after the replacement
                thisWorkStep.Status_Reason__c = thisWorkStep.Status_Reason__c.replaceAll('^;', '');

                // Remove any trailing semicolon left after all replacements
                thisWorkStep.Status_Reason__c = thisWorkStep.Status_Reason__c.replaceAll(';$', '');
            }

            // If the result after all the changes is an empty string, set it explicitly to null
            if (String.isBlank(thisWorkStep.Status_Reason__c)) {
                thisWorkStep.Status_Reason__c = null;
            }
        }
    }

    /**
     * @description When the `Setup Banking` WorkStep is complete, set the Status Reason to
     *              `Stripe KYC Verification Successful`
     * @param thisWorkStep - WorkStep record to update
     **/
    private void updateStripeKycStatusUponCompletionOfSetupBanking(WorkStep thisWorkStep) {
        // Skip if the WorkStep is not `Setup Banking` or the Status is not `Complete`
        if (
            thisWorkStep == null ||
            thisWorkStep.Type__c != WORK_STEP_NAME_SETUP_BANKING ||
            thisWorkStep.Status__c != STATUS_COMPLETE
        ) {
            return;
        }

        // If Status Reason is blank, set it to `Stripe KYC Verification Successful`
        if (String.isBlank(thisWorkStep.Status_Reason__c)) {
            thisWorkStep.Status_Reason__c = STATUS_REASON_STRIPE_KYC_SUCCESSFUL;
        } else {
            // Split the existing multi-select picklist values
            Set<String> statusReasonsSet = new Set<String>(
                thisWorkStep.Status_Reason__c.split(';')
            );

            // Add the `Stripe KYC Verification Successful` value.
            // This also handles the scenario where `Stripe KYC Verification Successful` is already in the values --
            // the Set ensures there is no duplication of values.
            statusReasonsSet.add(STATUS_REASON_STRIPE_KYC_SUCCESSFUL);

            // Join the set back into a multi-select picklist string
            thisWorkStep.Status_Reason__c = String.join(new List<String>(statusReasonsSet), ';');
        }
    }

    /**
     * @description It updates child WorkStep Status based on parent WorkStep status changes.
     * @JIRA# LEM-530 and LEM-6856
     * @param childWorkStepsToUpdate
     */
    private void updateChildWorkStepsOnParent(List<WorkStep> childWorkStepsToUpdate) {
        // Reusing method to call UOW commitWork
        fireUpdateOnParent(childWorkStepsToUpdate);
    }

    /**
     * @description It collect Parent sObjectType to WorkStep Status in a map for further
     * calculations.
     * @param sObjectId
     * @param status
     */
    private void collectSobjectIdAndWorkStepStatusToCalculateStatus(Id sObjectId, String status) {
        if (sObjectIdToWorkStepStatuses.containsKey(sObjectId)) {
            sObjectIdToWorkStepStatuses.get(sObjectId).add(status);
        } else {
            sObjectIdToWorkStepStatuses.put(sObjectId, new Set<String>{ status });
        }
    }

    /**
     * @description It is used to get static configurations.
     */
    private void collectStaticConfigurations() {
        this.rollUpReExecutionLimit = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(WORK_STEP_STATUS_ROLLUP_RETRY_LIMIT_STATIC_CONFIG)
                .Configuration_Value__c
        );
        this.childWorkStepsToUpdatePayloadChunkSize = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(CHILD_WORK_STEPS_TO_UPDATE_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG)
                .Configuration_Value__c
        );
        this.activationChecklistValidations = String.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(ACTIVATION_CHECKLIST_VALIDATIONS_STATIC_CONFIG)
                .Configuration_Value__c
        );
    }

    /**
     * @description It collect ultimate Parent sObjectType to Id in a map.
     * @param parentId
     */
    private void collectUltimateParentIds(Id parentId) {
        if (parentId == null) {
            return;
        }
        if (ultimateParentTypeToUltimateParentIds.containsKey(parentId.getSObjectType())) {
            ultimateParentTypeToUltimateParentIds.get(parentId.getSObjectType()).add(parentId);
        } else {
            ultimateParentTypeToUltimateParentIds.put(
                parentId.getSObjectType(),
                new Set<Id>{ parentId }
            );
        }
    }

    /**
     * @description It collect ultimate Parent sObjectType to Id in a map.
     * @param parentIds
     */
    private void collectUltimateParentIds(Set<Id> parentIds) {
        if (parentIds == null || parentIds.isEmpty()) {
            return;
        }
        Schema.SObjectType parentSobjectType = new List<Id>(parentIds)[0].getSObjectType();
        ultimateParentTypeToUltimateParentIds.put(parentSobjectType, parentIds);
    }

    /**
     * @description It collects Work Order (parent & child) with past due dates.
     * @param workOrderInstance
     */
    private void collectWorkOrderWithPastDueDates(WorkOrder workOrderInstance) {
        if (
            WORK_ORDER_PRIORITY_STATUSES.contains(
                WorkOrdersService.getWorkStatusUpdatedValue(workOrderInstance)
            )
        ) {
            workOrderIdsWithPastDates.add(workOrderInstance.Id);
        }
        if (
            workOrderInstance.ParentWorkOrder != null &&
            WORK_ORDER_PRIORITY_STATUSES.contains(
                WorkOrdersService.getWorkStatusUpdatedValue(workOrderInstance.ParentWorkOrder)
            )
        ) {
            workOrderIdsWithPastDates.add(workOrderInstance.ParentWorkOrderId);
        }
    }

    /**
     * @description It is used to collect the work order ids where the associated contract is of type
     * "Churned Merchant".
     * @JIRA# LEM-23780, LEM-24497
     * @param workOrderInstance
     */
    private void collectWorkOrderWithChurnedMxContracts(WorkOrder workOrderInstance) {
        if (
            workOrderInstance.Contract__r.Contract_Split_Category__c ==
            CHURNED_MERCHANT_CONTRACT_TYPE
        ) {
            workOrderIdsWithChurnedMxContracts.add(workOrderInstance.Id);
        }
    }

    /**
     * @description It query and collect Id to Set of Status Map for Parent records' Parent.
     * @param condition
     * @param groupByField
     * @param parentIds
     */
    private void fetchUltimateParentStatus(
        String condition,
        String groupByField,
        Set<Id> parentIds
    ) {
        for (
            Aggregate eachAggregate : WorkStepsSelector.newInstance()
                .getWorkStepsCountFilteredByConditionGroupedByParentAndStatus(
                    condition,
                    groupByField,
                    parentIds
                )
        ) {
            collectSobjectIdAndWorkStepStatusToCalculateStatus(
                (Id) eachAggregate.get(ULTIMATE_PARENT_AGGREGATE_QUERY_GROUPBYFIELD_ALIAS),
                (String) eachAggregate.get(ULTIMATE_PARENT_AGGREGATE_QUERY_STATUS_ALIAS)
            );
        }
    }

    /**
     * @description It fires UPDATE DML statement on parent records for Status rollup and
     * publish notifier event when exception occurs.
     * @param sObjectsToUpdate
     */
    private void fireStatusRollUpUpdateOnParent(List<sObject> sObjectsToUpdate) {
        fflib_ISObjectUnitOfWork uowToUpdateParentObjectStatus = Application.UNITOFWORK.newInstance();
        String logDetailedMessage;
        LogEntry logEntryInstance;
        ILogger loggerInstance;
        try {
            uowToUpdateParentObjectStatus.registerDirty(sObjectsToUpdate);
            uowToUpdateParentObjectStatus.commitWork();
        } catch (Exception parentStatusUpdateException) {
            logDetailedMessage =
                parentStatusUpdateException.getMessage() +
                PIPELINE_SEPARATOR +
                CURRENT_RETRY_COUNT +
                rollupRetryCount;
            if (rollupRetryCount < rollUpReExecutionLimit) {
                reinitiateWorkStepStatusRollup();
            } else {
                logDetailedMessage +=
                    PIPELINE_SEPARATOR + EXCEEDED_MAXIMUM_RETRY_LIMIT_ERROR_MESSAGE;
            }
            logEntryInstance = LogEntry.newLog(
                WorkStepsServiceImpl.class.getName(),
                STATUS_ROLLUP_METHOD_NAME,
                logDetailedMessage
            );
            loggerInstance = Logger.add(logEntryInstance);
            if (loggerInstance != null) {
                loggerInstance.publish();
                GenericLoggerService.publish(
                    GenericLoggerService.createGenericLog(
                            LOG_SERVICE_WORK_STEP,
                            LOG_DOMAIN_PROVISIONING,
                            GenericLogEntry.SeverityLevel.HIGH
                        )
                        .logException(parentStatusUpdateException)
                );
            }
        }
    }

    /**
     * @description It fires UPDATE DML statement on Parent records.
     * @param sObjectsToUpdate
     */
    private void fireUpdateOnParent(List<sObject> sObjectsToUpdate) {
        if (sObjectsToUpdate.isEmpty()) {
            return;
        }
        fflib_ISObjectUnitOfWork uowForParentObjectStatusUpdate = Application.UNITOFWORK.newInstance();
        uowForParentObjectStatusUpdate.registerDirty(sObjectsToUpdate);
        try {
            uowForParentObjectStatusUpdate.commitWork();
        } catch (Exception parentStatusUpdateException) {
            Logger.publish(
                LogEntry.newExceptionLog(parentStatusUpdateException, LogEntry.SeverityLevel.HIGH)
            );
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_SERVICE_WORK_STEP,
                        LOG_DOMAIN_PROVISIONING,
                        GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logException(parentStatusUpdateException)
            );
        }
    }

    /**
     * @description It gets WorkOrder Status corresponding to calculated Status.
     * @param calculatedStatus
     * @param workStepStatuses
     * @return String
     */
    private String getCorrespondingWorkOrderStatus(
        String calculatedStatus,
        Set<String> workStepStatuses
    ) {
        String workOrderStatus = calculatedStatus;
        if (
            calculatedStatus == STATUS_BLOCKED ||
            calculatedStatus == STATUS_ESCALATED ||
            calculatedStatus == STATUS_GONE_DARK
        ) {
            workOrderStatus = STATUS_AT_RISK;
        } else if (isWorkOrderCalculatedStatusComplete(calculatedStatus, workStepStatuses)) {
            workOrderStatus = STATUS_ONBOARDING_COMPLETE;
        } else if (
            calculatedStatus == STATUS_READY_FOR_QA ||
            calculatedStatus == STATUS_QA_COMPLETE ||
            calculatedStatus == STATUS_RESOLVED
        ) {
            workOrderStatus = STATUS_IN_PROGRESS;
        } else if (
            calculatedStatus == STATUS_NOT_STARTED ||
            calculatedStatus == STATUS_NOT_WORKABLE
        ) {
            workOrderStatus = STATUS_PLANNING;
        }

        return workOrderStatus;
    }

    /**
     * @description It gets WorkPlan Status corresponding to calculated Status.
     * @param calculatedStatus
     * @param workStepStatuses
     * @return String
     */
    private String getCorrespondingWorkPlanStatus(
        String calculatedStatus,
        Set<String> workStepStatuses
    ) {
        String workPlanStatus = calculatedStatus;
        /** Removing implementation call completion statuses to mark the Work Plan complete
         * when all associated Work Steps are complete.
         */
        workStepStatuses.removeAll(IMPLEMENTATIONCALL_WORKSTEP_COMPLETION_STATUSES);
        if (calculatedStatus == STATUS_RESOLVED) {
            workPlanStatus = STATUS_IN_PROGRESS;
        } else if (workStepStatuses.equals(new Set<String>{ STATUS_COMPLETE })) {
            workPlanStatus = STATUS_COMPLETE;
        }
        return workPlanStatus;
    }

    /**
     * @description It identifies correct Status for parent record on basis of WorkSteps's Status.
     * @param workStepStatuses
     * @return String
     */
    private String getSobjectStatus(Set<String> workStepStatuses) {
        String comparisonOperator;
        Boolean isStatusConditionStatisfied = false;
        String sObjectStatus;
        //JIRA#: LEM-2401 skipping Dead status for "Onboarding Complete" scenario
        if (workStepStatuses.equals(WORKORDER_COMPLETION_STATUSES)) {
            return STATUS_COMPLETE;
        }
        for (Work_Step_Status_Mapping__mdt eachWorkStepStatusMapping : workStepsStatusMappings) {
            if (!statusesToCompare.contains(eachWorkStepStatusMapping.Status__c)) {
                continue;
            }
            comparisonOperator = eachWorkStepStatusMapping.Operator__c;
            sObjectStatus = eachWorkStepStatusMapping.Status_To_Apply__c;
            if (comparisonOperator == COMPARISON_OPERATOR_EQUALS) {
                isStatusConditionStatisfied = workStepStatuses.equals(
                    new Set<String>{ eachWorkStepStatusMapping.Status__c }
                );
            } else {
                isStatusConditionStatisfied = workStepStatuses.contains(
                    eachWorkStepStatusMapping.Status__c
                );
            }
            if (isStatusConditionStatisfied) {
                break;
            }
        }
        return sObjectStatus;
    }

    /**
     * @description It gets WorkSteps which are not processed in the previous run of the trigger.
     * @JIRA# LEM-530
     * @param workStepIds
     * @return Set<Id>
     */
    private Set<Id> getUnprocessedWorkSteps(Set<Id> workStepIds) {
        workStepIds.removeAll(WorkStepsService.processedWorkStepIds);
        return workStepIds;
    }

    /**
     * @description It fetches Work Step Status Mapping custom metadata data records.
     */
    private void getWorkStepStatusMappings() {
        for (
            Work_Step_Status_Mapping__mdt eachWorkStepStatusMapping : WorkStepStatusMappingsSelector.newInstance()
                .getAllValues()
        ) {
            statusesToCompare.add(eachWorkStepStatusMapping.Status__c);
            workStepsStatusMappings.add(eachWorkStepStatusMapping);
        }
    }

    /**
     * @description It fires notifier event to reinitiate Work Steps Status rollup.
     */
    private void reinitiateWorkStepStatusRollup() {
        NotifierEventsService.publishEvents(
            new Map<String, String>{
                EVENT_TOPIC_REINITIATE_WORK_STEPS_STATUS_ROLL_UP => JSON.serialize(
                    new WorkStepStatusEntry(initialPayload, ++rollupRetryCount)
                )
            }
        );
    }

    /**
     * @description It calculates Status for Parent records' Parent.
     * TODO: Add getLimitAggregateQueries() & getAggregateQueries() logic to avoid hitting limits.
     */
    private void runWorkStepsStatusCalculationOnUltimateParent() {
        for (Schema.SobjectType eachSobjectType : ultimateParentTypeToUltimateParentIds.keySet()) {
            switch on SOBJECTTYPETOPARENTOBJECTTYPES.get(eachSobjectType) {
                when WORKORDER {
                    fetchUltimateParentStatus(
                        ULTIMATE_PARENT_WORK_ORDER_CONDITION,
                        ULTIMATE_PARENT_WORK_ORDER_GROUPBYFIELD,
                        ultimateParentTypeToUltimateParentIds.get(eachSobjectType)
                    );
                }
                when WORKPLAN {
                    fetchUltimateParentStatus(
                        ULTIMATE_PARENT_WORK_PLAN_CONDITION,
                        ULTIMATE_PARENT_WORK_PLAN_GROUPBYFIELD,
                        ultimateParentTypeToUltimateParentIds.get(eachSobjectType)
                    );
                }
                when WORKSTEP {
                    fetchUltimateParentStatus(
                        ULTIMATE_PARENT_WORK_STEP_CONDITION,
                        ULTIMATE_PARENT_WORK_STEP_GROUPBYFIELD,
                        ultimateParentTypeToUltimateParentIds.get(eachSobjectType)
                    );
                }
            }
        }
    }

    /**
     * @description It separates out different Parent Ids by sObjectType.
     * @param parentIds
     */
    private void separateAndCollectDifferentParentIds(Set<Id> parentIds) {
        for (Id eachSObjectId : parentIds) {
            switch on SOBJECTTYPETOPARENTOBJECTTYPES.get(eachSObjectId.getSObjectType()) {
                when WORKORDER {
                    workOrderIds.add(eachSObjectId);
                }
                when WORKPLAN {
                    workPlanIds.add(eachSObjectId);
                }
                when WORKSTEP {
                    parentWorkStepIds.add(eachSObjectId);
                }
            }
        }
    }

    /**
     * @description It updates status of first Work Step in execution order for Storefront
     * Work Order to "Not Started". The first Work Step is as follows (as on 09/05/2022):
     * Storefront Work Plan => Setup Storefront Page
     * Storefront Bundled Work Plan => Setup Store
     * @JIRA# LEM-2132
     * @param parentWorkStepIds
     */
    private void setStorefrontParentWorkStepsStatus(Set<Id> parentWorkStepIds) {
        if (parentWorkStepIds.isEmpty()) {
            return;
        }
        WorkPlan parentWorkPlan;
        List<WorkPlan> parentWorkPlansToBeUpdated = new List<WorkPlan>();
        WorkStep parentWorkStep;
        Map<Id, Id> parentWorkStepIdToParentWorkPlanId = new Map<Id, Id>();
        Map<Id, Set<String>> parentWorkStepIdToWorkStepStatuses = new Map<Id, Set<String>>();
        Map<Id, Set<String>> parentWorkStepIdToStoreActivationStatuses = new Map<Id, Set<String>>();
        String parentWorkStepStatus;
        List<WorkStep> parentWorkStepsToBeUpdated = new List<WorkStep>();
        List<sObject> sObjectsToUpdate = new List<sObject>();
        Set<String> workStepStatuses = new Set<String>();
        for (
            WorkStep eachWorkStep : WorkStepsSelector.newInstance()
                .selectChildWorkStepsByParentWorkStepIds(parentWorkStepIds)
        ) {
            if (!parentWorkStepIdToWorkStepStatuses.containsKey(eachWorkStep.Parent_Work_Step__c)) {
                parentWorkStepIdToWorkStepStatuses.put(
                    eachWorkStep.Parent_Work_Step__c,
                    new Set<String>()
                );
            }
            if (
                !parentWorkStepIdToStoreActivationStatuses.containsKey(
                    eachWorkStep.Parent_Work_Step__c
                )
            ) {
                parentWorkStepIdToStoreActivationStatuses.put(
                    eachWorkStep.Parent_Work_Step__c,
                    new Set<String>()
                );
            }
            parentWorkStepIdToWorkStepStatuses.get(eachWorkStep.Parent_Work_Step__c)
                .add(eachWorkStep.Status__c);
            parentWorkStepIdToStoreActivationStatuses.get(eachWorkStep.Parent_Work_Step__c)
                .add(eachWorkStep.WorkOrder.Store_Account_Activation_Status__c);
            parentWorkStepIdToParentWorkPlanId.put(
                eachWorkStep.Parent_Work_Step__c,
                eachWorkStep.Parent_Work_Step__r.WorkPlanId
            );
        }
        for (Id eachParentWorkStepId : parentWorkStepIdToWorkStepStatuses.keySet()) {
            workStepStatuses = parentWorkStepIdToWorkStepStatuses.get(eachParentWorkStepId);
            parentWorkStepStatus = getSobjectStatus(workStepStatuses);
            parentWorkPlan = new WorkPlan(
                Id = parentWorkStepIdToParentWorkPlanId.get(eachParentWorkStepId)
            );
            parentWorkStep = new WorkStep(
                Id = eachParentWorkStepId,
                Status__c = parentWorkStepStatus,
                Is_Updated_By_System__c = true
            );
            if (
                workStepStatuses.contains(STATUS_NOT_WORKABLE) &&
                parentWorkStepStatus == STATUS_NOT_STARTED
            ) {
                parentWorkStep.Status__c = STATUS_NOT_WORKABLE;
                parentWorkPlan.Status__c = STATUS_NOT_WORKABLE;
            }

            parentWorkPlan.Have_All_Stores_Activated__c = parentWorkStepIdToStoreActivationStatuses.get(
                        eachParentWorkStepId
                    )
                    ?.contains(WORK_ORDER_ACTIVATION_STATUS_INACTIVE)
                ? false
                : true;
            parentWorkStepsToBeUpdated.add(parentWorkStep);
            parentWorkPlansToBeUpdated.add(parentWorkPlan);
            // Add Parent WorkStep to processed record set
            WorkStepsService.processedWorkStepIds.add(eachParentWorkStepId);
        }
        sObjectsToUpdate.addAll(parentWorkStepsToBeUpdated);
        sObjectsToUpdate.addAll(parentWorkPlansToBeUpdated);
        fireUpdateOnParent(sObjectsToUpdate);
    }

    /**
     * @description It updates status of first Work Step in execution order for Storefront
     * Work Order to "Not Started". The first Work Step is as follows (as on 09/05/2022):
     * Storefront Work Plan => Setup Storefront Page
     * Storefront Bundled Work Plan => Setup Store
     * @JIRA# LEM-2132
     * @param activatedStoreAccountIds
     */
    private void setStorefrontWorkStepsStatusByActivatedStores(Set<Id> activatedStoreAccountIds) {
        if (activatedStoreAccountIds.isEmpty()) {
            return;
        }
        List<WorkStep> workStepsToBeUpdated = new List<WorkStep>();
        Set<Id> parentWorkStepIds = new Set<Id>();
        for (
            WorkStep eachWorkStep : WorkStepsSelector.newInstance()
                .selectFirstStorefrontWorkStepByStoreAccountIds(activatedStoreAccountIds)
        ) {
            if (eachWorkStep.Status__c == STATUS_NOT_WORKABLE) {
                eachWorkStep.Status__c = STATUS_NOT_STARTED;
            }
            if (eachWorkStep.Parent_Work_Step__c != null) {
                parentWorkStepIds.add(eachWorkStep.Parent_Work_Step__c);
            }
            workStepsToBeUpdated.add(eachWorkStep);
        }
        fireUpdateOnParent(workStepsToBeUpdated);
        setStorefrontParentWorkStepsStatus(parentWorkStepIds);
    }

    /**
     * @description It checks whether Work Order status to be updated should be
     * Onboarding Complete when implementation call Work Step completion status is included
     * in all associated Work Steps with status as Complete.
     * @param calculatedStatus
     * @param workStepStatuses
     * @return Boolean
     */
    private Boolean isWorkOrderCalculatedStatusComplete(
        String calculatedStatus,
        Set<String> workStepStatuses
    ) {
        /**
         * Removing implementation call completion statuses to mark the Work Order complete
         * when all associated Work Steps are complete.
         */
        workStepStatuses.removeAll(IMPLEMENTATIONCALL_WORKSTEP_COMPLETION_STATUSES);
        return calculatedStatus == STATUS_COMPLETE ||
            workStepStatuses.equals(new Set<String>{ STATUS_COMPLETE });
    }

    /**
     * @description It updates Parent object Status on basis of calculations.
     */
    private void updateParentObjectsStatus() {
        String sObjectStatus;
        String sObjectStatusToUpdate;
        List<sObject> sObjectsToUpdate = new List<sObject>();
        List<WorkOrder> workOrdersToUpdate = new List<WorkOrder>();
        List<WorkPlan> workPlansToUpdate = new List<WorkPlan>();
        List<WorkStep> workStepsToUpdate = new List<WorkStep>();
        Set<String> workStepStatuses = new Set<String>();
        for (Id eachSObjectId : sObjectIdToWorkStepStatuses.keySet()) {
            workStepStatuses = sObjectIdToWorkStepStatuses.get(eachSObjectId);
            sObjectStatus = getSobjectStatus(workStepStatuses);
            if (String.isBlank(sObjectStatus)) {
                continue;
            }
            switch on SOBJECTTYPETOPARENTOBJECTTYPES.get(eachSObjectId.getSObjectType()) {
                when WORKORDER {
                    if (
                        sObjectIdToCurrentStatus.get(eachSObjectId) == STATUS_ONBOARDING_COMPLETE &&
                        sObjectStatus == STATUS_DEAD &&
                        !workOrderIdsWithChurnedMxContracts.contains(eachSObjectId)
                    ) {
                        continue;
                    }
                    sObjectStatusToUpdate = getCorrespondingWorkOrderStatus(
                        sObjectStatus,
                        workStepStatuses
                    );
                    if (
                        workOrderIdsWithPastDates.contains(eachSObjectId) &&
                        !WORK_ORDER_ALLOWED_STATUSES_WITH_PAST_DATES.contains(sObjectStatusToUpdate)
                    ) {
                        continue;
                    }
                    workOrdersToUpdate.add(
                        new WorkOrder(
                            Id = eachSObjectId,
                            Is_Updated_By_System__c = true,
                            Status = sObjectStatusToUpdate
                        )
                    );
                }
                when WORKPLAN {
                    workPlansToUpdate.add(
                        new WorkPlan(
                            Id = eachSObjectId,
                            Status__c = getCorrespondingWorkPlanStatus(
                                sObjectStatus,
                                workStepStatuses
                            )
                        )
                    );
                }
                when WORKSTEP {
                    workStepsToUpdate.add(
                        new WorkStep(
                            Id = eachSObjectId,
                            Is_Updated_By_System__c = true,
                            Status__c = sObjectStatus
                        )
                    );
                    // Add Parent WorkStep to processed record set
                    WorkStepsService.processedWorkStepIds.add(eachSObjectId);
                }
            }
        }
        sObjectsToUpdate.addAll(workOrdersToUpdate);
        sObjectsToUpdate.addAll(workPlansToUpdate);
        sObjectsToUpdate.addAll(workStepsToUpdate);
        fireStatusRollUpUpdateOnParent(sObjectsToUpdate);
    }

    /**
     * @description It updates the 'Click N Pop Eligible' checkbox and the 'Original Status Reason and Details' fields
     * when the status of a workstep is changed to 'blocked'.
     * @JIRA# LEM-13961
     * @param workSteps
     */
    public void updatePopnClickOnWorkStepStatusChange(List<WorkStep> workSteps) {
        if (workSteps == null) {
            return;
        }
        List<Status_Reason_And_Details_Mapping__mdt> statusReasonAndDetailsMappings = StatusReasonAndDetailsMappingsSelector.newInstance()
            .getAllMappings();
        Map<String, List<Status_Reason_And_Details_Mapping__mdt>> statusReasonAndDetailsMappingsMap = createStatusReasonAndDetailsMappingsMap(
            statusReasonAndDetailsMappings
        );
        updateWorkSteps(workSteps, statusReasonAndDetailsMappingsMap);
    }
    /**
     * @description It creates a map where the key is a concatenated string of the 'Type__c', 'Status__c', and 'Status_Reason__c' fields of a Status_Reason_And_Details_Mapping__mdt record only if the Status__c is 'blocked.
     * @JIRA# LEM-13961, LEM-15326
     * @param statusReasonAndDetailsMappings
     * @return Map<String, List<Status_Reason_And_Details_Mapping__mdt>>
     */
    private Map<String, List<Status_Reason_And_Details_Mapping__mdt>> createStatusReasonAndDetailsMappingsMap(
        List<Status_Reason_And_Details_Mapping__mdt> statusReasonAndDetailsMappings
    ) {
        Map<String, List<Status_Reason_And_Details_Mapping__mdt>> statusReasonAndDetailsMappingsMap = new Map<String, List<Status_Reason_And_Details_Mapping__mdt>>();
        for (
            Status_Reason_And_Details_Mapping__mdt statusReasion : statusReasonAndDetailsMappings
        ) {
            if (
                String.isNotBlank(statusReasion.Status__c) &&
                statusReasion.Status__c.equalsIgnoreCase(STATUS_BLOCKED)
            ) {
                String metaDatakey = getConcatenateString(
                    statusReasion.Type__c,
                    statusReasion.Status__c,
                    statusReasion.Status_Reason__c
                );
                if (!statusReasonAndDetailsMappingsMap.containsKey(metaDatakey)) {
                    statusReasonAndDetailsMappingsMap.put(
                        metaDatakey,
                        new List<Status_Reason_And_Details_Mapping__mdt>()
                    );
                }
                statusReasonAndDetailsMappingsMap.get(metaDatakey).add(statusReasion);
            }
        }
        return statusReasonAndDetailsMappingsMap;
    }

    /**
     * @description it updates a list of WorkStep records based on a map of Status_Reason_And_Details_Mapping__mdt records.
     * It iterates over each WorkStep and checks if the 'Type__c' and 'Status_Reason__c' fields are not blank.
     * If the 'Status_Reason__c' field contains more than one value (separated by ';'), it skips the current WorkStep.
     * It then creates a key by concatenating the 'Type__c', 'Status__c', and 'Status_Reason__c' fields of the WorkStep.
     * If this key exists in the map, it sets the 'Click_N_Pop_Eligible__c' field of the WorkStep to true.
     * If the 'Original_Status_Reason_and_Details__c' field of the WorkStep is blank and the 'Status_Reason_Details__c' field is not blank,
     * it sets the 'Original_Status_Reason_and_Details__c' field to the value of the 'Status_Reason_Details__c' field.
     * @JIRA# LEM-13961
     * @param workSteps
     * @param statusReasonAndDetailsMappingsMap
     */
    private void updateWorkSteps(
        List<WorkStep> workSteps,
        Map<String, List<Status_Reason_And_Details_Mapping__mdt>> statusReasonAndDetailsMappingsMap
    ) {
        for (WorkStep ws : workSteps) {
            if (String.isBlank(ws.Type__c) || String.isBlank(ws.Status_Reason__c)) {
                continue;
            }
            List<String> wsStatusReasons = ws.Status_Reason__c.split(';');
            if (wsStatusReasons != null && wsStatusReasons.size() > 1) {
                continue;
            }
            String wsKey = getConcatenateString(ws.Type__c, ws.Status__c, ws.Status_Reason__c);
            if (
                statusReasonAndDetailsMappingsMap != null &&
                statusReasonAndDetailsMappingsMap.containsKey(wsKey)
            ) {
                ws.Click_N_Pop_Eligible__c = true;
                if (
                    String.isBlank(ws.Original_Status_Reason_and_Details__c) &&
                    String.isNotBlank(ws.Status_Reason_Details__c)
                ) {
                    ws.Original_Status_Reason_and_Details__c = ws.Status_Reason_Details__c;
                }
            }
        }
    }

    /**
     * @description it concatenates three strings: 'type', 'status', and 'statusReason', with an asterisk (*) as a separator.
     * @JIRA# LEM-13961
     * @param type
     * @param status
     * @param statusReason
     * @return string
     */
    private string getConcatenateString(String type, String status, String statusReason) {
        return (type + '*' + status + '*' + statusReason).toLowerCase();
    }

    /**
     * @description It updates WorkStep Status, Status Reason and Notes based on Business Verification Details.
     * @JIRA# LEM-15834
     * @param storeAccountIds
     * @param salesforceAccountIdToStoreId
     * @param storeIdsToBusinessVertificationDetails
     */
    public void updateWorkStepsStatusDetailsByBusinessVerificationStatusDetails(
        Set<Id> storeAccountIds,
        Map<Id, String> salesforceAccountIdToStoreId,
        Map<String, BusinessVerficationDetails> storeIdsToBusinessVertificationDetails
    ) {
        BusinessVerficationDetails businessVerificationDetails;
        List<sObject> sObjectsToUpdate = new List<sObject>();
        Set<String> workStepTypes = new Set<String>{ WORK_STEP_TYPE_REVIEW_AND_TRIAGE };
        Map<Id, WorkOrder> childWorkOrders = new Map<Id, WorkOrder>();
        for (
            WorkStep eachWorkStep : WorkStepsSelector.newInstance()
                .selectWorkStepsByTypesAndStoreAccountIds(storeAccountIds, workStepTypes)
        ) {
            if (eachWorkStep.Store_Account__c != null) {
                businessVerificationDetails = storeIdsToBusinessVertificationDetails.get(
                    salesforceAccountIdToStoreId.get(eachWorkStep.Store_Account__c)
                );
            }
            if (businessVerificationDetails != null) {
                switch on
                    BUSINESS_VERIFICATION_STATUS_MAPPINGS.get(
                        businessVerificationDetails.businessVerificationDetails.status
                    ) {
                    when DOCUMENTATION_REQUIRED {
                        eachWorkStep.Status__c = STATUS_BLOCKED;
                        eachWorkStep.Status_Reason__c = STATUS_FRAUD;
                        eachWorkStep.Status_Reason_Details__c = businessVerificationDetails.businessVerificationDetails.statusReason;
                        eachWorkStep.Notes__c = businessVerificationDetails.businessVerificationDetails.statusNotes;
                    }
                    when FOLLOW_UP_NEEDED {
                        eachWorkStep.Status__c = STATUS_BLOCKED;
                        eachWorkStep.Status_Reason__c = STATUS_FRAUD;
                        eachWorkStep.Status_Reason_Details__c = businessVerificationDetails.businessVerificationDetails.statusReason;
                        eachWorkStep.Notes__c = businessVerificationDetails.businessVerificationDetails.statusNotes;
                    }
                    when DENIED {
                        if (
                            eachWorkStep.WorkOrderId != null &&
                            !childWorkOrders.containsKey(eachWorkStep.WorkOrderId)
                        ) {
                            childWorkOrders.put(
                                eachWorkStep.WorkOrderId,
                                new WorkOrder(
                                    Id = eachWorkStep.WorkOrderId,
                                    Description = businessVerificationDetails.businessVerificationDetails.statusNotes,
                                    Status = STATUS_DEAD
                                )
                            );
                            eachWorkStep.Status_Reason__c = STATUS_FRAUD;
                        }
                    }
                    when APPROVED {
                        eachWorkStep.Status__c = STATUS_IN_PROGRESS;
                        eachWorkStep.Status_Reason_Details__c = businessVerificationDetails.businessVerificationDetails.statusReason;
                        eachWorkStep.Notes__c = businessVerificationDetails.businessVerificationDetails.statusNotes;
                    }
                }
                sObjectsToUpdate.add(eachWorkStep);
            }
        }
        sObjectsToUpdate.addAll(childWorkOrders.values());
        fireUpdateOnParent(sObjectsToUpdate);
    }
}