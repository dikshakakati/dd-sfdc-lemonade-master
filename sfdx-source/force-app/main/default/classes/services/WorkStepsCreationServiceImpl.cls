/**
 * @author Deloitte
 * @date 12/23/2022
 * @description Service implementation class for WorkSteps creation logic.
 */
public inherited sharing class WorkStepsCreationServiceImpl implements IWorkStepsCreationService {
    private static final String ACCOUNT_RECORD_TYPE_STORE = 'Store';
    private static final String DELIMITER = System.Label.Separator;
    private static final Integer EXECUTION_ORDER_FIRST = 1;
    private static final Boolean IS_TEST_CONTEXT = Test.isRunningTest();
    private static final String STOREFRONT_PARENT_WORK_STEP_STATUS_UPDATE = 'STOREFRONT_PARENT_WORK_STEP_STATUS_UPDATE';
    private static final String PARENT_WORKORDER_IDS_CHUNK_SIZE_STATIC_CONFIG = 'Parent_WorkOrders_Payload_Chunk_Size';
    private static final String WORK_ORDER_CREATION_SOURCE_MX_PORTAL = 'Mx Portal';
    private static final String WORK_ORDER_CREATION_SOURCE_RESSMO = 'RESSMO';
    private static final String WORK_ORDER_CREATION_SOURCE_SSMO = 'SSMO';
    private static final String WORK_ORDER_READY_FOR_PROVISIONING_STATUS_UPDATE = 'WORK_ORDER_READY_FOR_PROVISIONING_STATUS_UPDATE';
    private static final String WORK_STEP_DEPENDENCIES_CREATE = 'WORK_STEP_DEPENDENCIES_CREATE';
    private static final String WORK_PLAN_NAME_STOREFRONT = 'Storefront';
    private static final String WORK_PLAN_NAME_TABLET = 'Tablet';
    private static final String WORK_STEP_STATUS_NOT_STARTED = 'Not Started';
    private static final String WORK_STEP_TYPE_IMPLEMENTATION_CALL = 'Implementation Call';
    private static final String WORK_STEP_TYPE_SETUP_BANKING = 'Setup Banking';
    private static final String WORK_STEP_TYPE_SETUP_STOREFRONT_PAGE = 'Setup Storefront Page';
    private static final String LOG_SERVICE_WORK_STEP = 'Work Step Service';
    private static final String LOG_DOMAIN_PROVISIONING = 'Provisioning';
    private Boolean isSuccess;
    private Map<String, Id> parentWorkStepIdentifierToWorkStepId;
    private Set<Id> parentWorkOrderIdsToDisableNotification;
    private Set<Id> storefrontParentWorkStepIds;
    private Set<Id> workOrderIds;
    private Integer workOrderIdsChunkSize;
    private Set<Id> workOrderIdsToSendNotification;
    private List<WorkPlan> workPlansWithWorkOrderDetails;
    private static final Set<String> CREATION_SOURCES_ELIGIBLE_FOR_SETUP_BANKING_UPDATE = new Set<String>{
        WORK_ORDER_CREATION_SOURCE_MX_PORTAL,
        WORK_ORDER_CREATION_SOURCE_RESSMO,
        WORK_ORDER_CREATION_SOURCE_SSMO
    };

    /**
     * @description Default constructor to instantiate variables.
     */
    public WorkStepsCreationServiceImpl() {
        isSuccess = false;
        parentWorkOrderIdsToDisableNotification = new Set<Id>();
        parentWorkStepIdentifierToWorkStepId = new Map<String, Id>();
        storefrontParentWorkStepIds = new Set<Id>();
        workOrderIds = new Set<Id>();
        workOrderIdsToSendNotification = new Set<Id>();
        workPlansWithWorkOrderDetails = new List<WorkPlan>();
        collectStaticConfigurations();
    }

    /**
     * @description It triggers creation of WorkSteps from WorkPlanTemplates
     * and associated WorkPlanTemplateEntries after creation of WorkPlans.
     * @JIRA# LEM-732, LEM-4160
     * @param workPlans
     * @param workPlanTemplateIds
     */
    public void createWorkStepsOnWorkPlans(List<WorkPlan> workPlans, Set<Id> workPlanTemplateIds) {
        if (workPlans.isEmpty()) {
            return;
        }
        WorkPlanTemplate workPlanTemplate;
        List<WorkStep> workStepsToInsert = new List<WorkStep>();
        Map<Id, WorkPlanTemplate> workPlanTemplatesWithWorkPlanTemplateEntries = new Map<Id, WorkPlanTemplate>(
            WorkPlanTemplatesSelector.newInstance()
                .selectWorkPlanTemplatesWithWorkPlanTemplateEntries(workPlanTemplateIds)
        );
        collectWorkPlansDetailsAndParentWorkSteps(new Map<Id, WorkPlan>(workPlans).keySet());
        for (WorkPlan eachWorkPlan : workPlansWithWorkOrderDetails) {
            if (
                !workPlanTemplatesWithWorkPlanTemplateEntries.containsKey(
                    eachWorkPlan.Work_Plan_Template__c
                )
            ) {
                continue;
            }
            workPlanTemplate = workPlanTemplatesWithWorkPlanTemplateEntries.get(
                eachWorkPlan.Work_Plan_Template__c
            );
            if (workPlanTemplate.WorkStepTemplates == null) {
                continue;
            }
            workOrderIds.add(eachWorkPlan.WorkOrderId);
            for (
                WorkPlanTemplateEntry eachWorkPlanTemplateEntry : workPlanTemplate.WorkStepTemplates
            ) {
                if (!eachWorkPlanTemplateEntry.WorkStepTemplate.IsActive) {
                    continue;
                }
                workStepsToInsert.add(createWorkStep(eachWorkPlan, eachWorkPlanTemplateEntry));
            }
            if (
                WorkOrderSettingsService.isProvisioningStatusNotificationEnabledOnChildWorkOrder(
                    eachWorkPlan.WorkOrder
                )
            ) {
                workOrderIdsToSendNotification.add(eachWorkPlan.WorkOrderId);
            }
        }
        fireRecordsInsertion(workStepsToInsert);
        // prevent firing Notifier event for parent Work Orders
        workOrderIdsToSendNotification.removeAll(parentWorkOrderIdsToDisableNotification);
        if (isSuccess) {
            sendNotifications();
        }
    }

    /**
     * @description It is used to get static configurations.
     */
    private void collectStaticConfigurations() {
        this.workOrderIdsChunkSize = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(PARENT_WORKORDER_IDS_CHUNK_SIZE_STATIC_CONFIG)
                .Configuration_Value__c
        );
    }

    /**
     * @description It collects WorkPlans, WorkOrders and ParentWorkStep details.
     * @JIRA# LEM-2193
     * @param workPlanIds
     */
    private void collectWorkPlansDetailsAndParentWorkSteps(Set<Id> workPlanIds) {
        Set<Id> parentIds = new Set<Id>();
        for (
            WorkPlan eachWorkPlan : WorkPlansSelector.newInstance()
                .selectWorkPlansWithWorkOrderDetails(workPlanIds)
        ) {
            workPlansWithWorkOrderDetails.add(eachWorkPlan);
            if (eachWorkPlan.WorkOrder.ParentWorkOrderId != null) {
                parentIds.add(eachWorkPlan.WorkOrder.ParentWorkOrderId);
            } else if (
                eachWorkPlan.WorkOrder.ParentWorkOrderId == null &&
                !WorkOrderSettingsService.isProvisioningStatusNotificationEnabledOnParentWorkOrder(
                    eachWorkPlan.WorkOrder
                )
            ) {
                parentWorkOrderIdsToDisableNotification.add(eachWorkPlan.WorkOrderId);
            }
        }
        for (
            WorkStep eachWorkStep : WorkStepsSelector.newInstance()
                .selectWorkStepsByWorkOrderIds(parentIds)
        ) {
            parentWorkStepIdentifierToWorkStepId.put(
                eachWorkStep.WorkOrderId + DELIMITER + eachWorkStep.Type__c,
                eachWorkStep.Id
            );
        }
    }

    /**
     * @description It creates WorkSteps from passed WorkPlan and WorkPlanTemplateEntry record.
     * @JIRA# LEM-732
     * @param workPlan
     * @param workPlanTemplateEntry
     * @return WorkStep
     */
    private WorkStep createWorkStep(
        WorkPlan workPlan,
        WorkPlanTemplateEntry workPlanTemplateEntry
    ) {
        Boolean isStorefrontCriteriaSatisfied = isStorefrontCriteriaSatisfied(
            workPlan,
            workPlanTemplateEntry
        );
        Boolean isSetupBankingCriteriaSatisfied = isSetupBankingCriteriaSatisfied(
            workPlan,
            workPlanTemplateEntry
        );
        Boolean isTabletCriteriaSatisfied = (workPlan.Name.contains(WORK_PLAN_NAME_TABLET) &&
        workPlanTemplateEntry.ExecutionOrder == EXECUTION_ORDER_FIRST &&
        workPlan.WorkOrder.Type__c == WORK_PLAN_NAME_TABLET);
        Id parentWorkStepId = parentWorkStepIdentifierToWorkStepId.get(
            workPlan.WorkOrder.ParentWorkOrderId +
                DELIMITER +
                workPlanTemplateEntry.WorkStepTemplate.Name
        );
        if (isStorefrontCriteriaSatisfied && parentWorkStepId != null) {
            storefrontParentWorkStepIds.add(parentWorkStepId);
        }
        return new WorkStep(
            ExecutionOrder = workPlanTemplateEntry.ExecutionOrder,
            Name = workPlanTemplateEntry.WorkStepTemplate.Name,
            Type__c = workPlanTemplateEntry.WorkStepTemplate.Name,
            Parent_Work_Step__c = parentWorkStepId,
            //@JIRA# LEM-1424 - Added store activation check
            Status__c = (isStorefrontCriteriaSatisfied ||
                isTabletCriteriaSatisfied ||
                isSetupBankingCriteriaSatisfied)
                ? WORK_STEP_STATUS_NOT_STARTED
                : workPlanTemplateEntry.Work_Step_Default_Status__c,
            Store_Account__c = workPlan.WorkOrder.Account.RecordType.DeveloperName ==
                ACCOUNT_RECORD_TYPE_STORE
                ? workPlan.WorkOrder.AccountId
                : null,
            WorkPlanId = workPlan.Id,
            WorkPlanTemplateEntry__c = workPlanTemplateEntry.Id,
            Work_Step_Sequence__c = WorkPlanTemplateEntry.Work_Step_Sequence__c
        );
    }

    /**
     * @description It checks if 'Setup Banking' is eligible for Status update.
     * @param workPlanInstance
     * @param workPlanTemplateEntryInstance
     * @return Boolean
     */
    private Boolean isSetupBankingCriteriaSatisfied(
        WorkPlan workPlanInstance,
        WorkPlanTemplateEntry workPlanTemplateEntryInstance
    ) {
        return CREATION_SOURCES_ELIGIBLE_FOR_SETUP_BANKING_UPDATE.contains(
                workPlanInstance.Parent_Work_Order_Creation_Source__c
            ) &&
            workPlanTemplateEntryInstance.WorkStepTemplate.Name == WORK_STEP_TYPE_SETUP_BANKING;
    }

    /**
     * @description It checks if the Storefront Workstep criteria satisfiy for Status update.
     * @param workPlan
     * @param workPlanTemplateEntry
     * @return Boolean
     */
    private Boolean isStorefrontCriteriaSatisfied(
        WorkPlan workPlan,
        WorkPlanTemplateEntry workPlanTemplateEntry
    ) {
        return workPlan.Name.contains(WORK_PLAN_NAME_STOREFRONT) &&
            ((workPlan.Is_Store_Active__c &&
            workPlanTemplateEntry.ExecutionOrder == EXECUTION_ORDER_FIRST) ||
            (workPlan.Parent_Work_Order_Creation_Source__c ==
            WORK_ORDER_CREATION_SOURCE_MX_PORTAL &&
            workPlanTemplateEntry.WorkStepTemplate.Name == WORK_STEP_TYPE_IMPLEMENTATION_CALL) ||
            (workPlan.Parent_Work_Order_Creation_Source__c == WORK_ORDER_CREATION_SOURCE_SSMO &&
            workPlanTemplateEntry.WorkStepTemplate.Name == WORK_STEP_TYPE_SETUP_STOREFRONT_PAGE));
    }

    /**
     * @description It trigger UOW commitWork on the passed records.
     * @param sObjectListToInsert
     */
    private void fireRecordsInsertion(List<SObject> sObjectListToInsert) {
        if (sObjectListToInsert == null || sObjectListToInsert.isEmpty()) {
            return;
        }
        fflib_ISObjectUnitOfWork uowRecordsCreation = Application.UnitOfWork.newInstance();
        uowRecordsCreation.registerNew(sObjectListToInsert);
        try {
            uowRecordsCreation.commitWork();
            isSuccess = true;
        } catch (Exception recordsCreationException) {
            isSuccess = false;
            Logger.publish(
                LogEntry.newExceptionLog(recordsCreationException, LogEntry.SeverityLevel.HIGH)
            );
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_SERVICE_WORK_STEP,
                        LOG_DOMAIN_PROVISIONING,
                        GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logException(recordsCreationException)
            );
        }
    }

    /**
     * @description It sends notifications for updating the child Work Orders'
     * provisioning status to "Ready for Provisioning".
     * @JIRA# LEM-1684
     */
    private void sendNotifications() {
        if (!workOrderIdsToSendNotification.isEmpty()) {
            NotifierEventsService.publishBulkEvents(
                new Map<String, List<String>>{
                    WORK_ORDER_READY_FOR_PROVISIONING_STATUS_UPDATE => NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                        workOrderIdsToSendNotification,
                        workOrderIdsChunkSize
                    )
                }
            );
        }
        if (!storefrontParentWorkStepIds.isEmpty()) {
            NotifierEventsService.publishBulkEvents(
                new Map<String, List<String>>{
                    STOREFRONT_PARENT_WORK_STEP_STATUS_UPDATE => NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                        storefrontParentWorkStepIds,
                        workOrderIdsChunkSize
                    )
                }
            );
        }
        if (!workOrderIds.isEmpty()) {
            NotifierEventsService.publishBulkEvents(
                new Map<String, List<String>>{
                    WORK_STEP_DEPENDENCIES_CREATE => NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                        workOrderIds,
                        workOrderIdsChunkSize
                    )
                }
            );
        }
    }
}