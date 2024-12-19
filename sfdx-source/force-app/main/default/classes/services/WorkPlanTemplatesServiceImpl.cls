/**
 * @author Deloitte
 * @date 29/04/2022
 * @description Service implementation class for WorkPlanTemplate related logic.
 */
public inherited sharing class WorkPlanTemplatesServiceImpl implements IWorkPlanTemplatesService {
    private static final String ACCOUNT_ACTIVATION_STATUS_ACTIVE = 'Active';
    private static final String DELIMITER = System.Label.Separator;
    private static final String STATUS_NOT_STARTED = 'Not Started';
    private static final String WORK_ORDER_TYPE_STOREFRONT = 'Storefront';
    private static final String WORK_PLAN_TYPE_TABLET = 'Tablet';
    private static final String WORK_PLAN_TYPE_POS = 'POS';
    private static final String LOG_SERVICE_WORK_PLAN = 'Work Plan Service';
    private static final String LOG_DOMAIN_PROVISIONING = 'Provisioning';
    private Map<Id, Set<String>> childWorkOrderIdToWorkPlanTypes;
    private Map<Id, Set<String>> parentWorkOrderIdToWorkPlanTypes;
    private Map<String, Id> workPlanIdentifierToWorkPlanId;
    private Map<Id, Set<String>> workOrderIdToWorkPlanTypes;
    private Map<Id, WorkOrder> workOrders;
    private Map<String, WorkPlanTemplate> workPlanTypeToWorkPlanTemplate;

    /**
     * @description Default constructor to instantiate variables.
     */
    public WorkPlanTemplatesServiceImpl() {
        childWorkOrderIdToWorkPlanTypes = new Map<Id, Set<String>>();
        parentWorkOrderIdToWorkPlanTypes = new Map<Id, Set<String>>();
        workPlanIdentifierToWorkPlanId = new Map<String, Id>();
        workOrderIdToWorkPlanTypes = new Map<Id, Set<String>>();
        workOrders = new Map<Id, WorkOrder>();
        workPlanTypeToWorkPlanTemplate = new Map<String, WorkPlanTemplate>();
    }

    /**
     * @description Create WorkPlans for the passed list of WorkOrders using
     * the matching WorkPlan types.
     * @param workOrdersToCreateWorkPlans
     */
    public void createWorkPlansOnWorkOrdersByMatchingCriteria(
        List<WorkOrder> workOrdersToCreateWorkPlans
    ) {
        if (workOrdersToCreateWorkPlans.isEmpty()) {
            return;
        }
        Map<Id, WorkOrder> parentWorkOrders = new Map<Id, WorkOrder>();
        Map<Id, WorkOrder> childWorkOrders = new Map<Id, WorkOrder>();
        for (WorkOrder eachWorkOrder : workOrdersToCreateWorkPlans) {
            if (eachWorkOrder.ParentWorkOrderId != null) {
                parentWorkOrders.put(
                    eachWorkOrder.ParentWorkOrderId,
                    new WorkOrder(Id = eachWorkOrder.ParentWorkOrderId)
                );
                childWorkOrders.put(eachWorkOrder.Id, eachWorkOrder);
            } else {
                parentWorkOrders.put(eachWorkOrder.Id, eachWorkOrder);
            }
        }
        this.parentWorkOrderIdToWorkPlanTypes = WorkPlansMapperService.collectMatchingWorkPlanTypes(
            (List<String>) JSON.deserialize(
                JSON.serialize(parentWorkOrders.keySet()),
                List<String>.class
            )
        );
        this.childWorkOrderIdToWorkPlanTypes = WorkPlansMapperService.collectMatchingWorkPlanTypes(
            (List<String>) JSON.deserialize(
                JSON.serialize(childWorkOrders.keySet()),
                List<String>.class
            )
        );
        // Initialize variables for parent Work Plan creation
        this.workOrderIdToWorkPlanTypes = parentWorkOrderIdToWorkPlanTypes;
        this.workOrders = parentWorkOrders;
        triggerWorkPlansCreation(parentWorkOrders.values());
        // Initialize variables for child Work Plan creation
        this.workOrderIdToWorkPlanTypes = childWorkOrderIdToWorkPlanTypes;
        this.workOrders = childWorkOrders;
        triggerWorkPlansCreation(childWorkOrders.values());
    }

    /**
     * @description Create Work Plans on the passed Work Order by
     * re-evaluating criteria using the passed Work Plan types.
     * @JIRA# LEM-1956
     * @param workOrderToReevaluateWorkPlans
     * @param workOrderIdToWorkPlanTypes
     */
    public void createWorkPlansOnWorkOrdersByReevaluatingCriteria(
        List<WorkOrder> workOrderToReevaluateWorkPlans,
        Map<Id, Set<String>> workOrderIdToWorkPlanTypes
    ) {
        this.workOrderIdToWorkPlanTypes = workOrderIdToWorkPlanTypes;
        workOrders = new Map<Id, WorkOrder>(workOrderToReevaluateWorkPlans);
        triggerWorkPlansCreation(workOrderToReevaluateWorkPlans);
    }

    /**
     * @description To process WorkPlans creation for the passed list of WorkOrders.
     * @param workOrdersToCreateWorkPlans
     */
    private void triggerWorkPlansCreation(List<WorkOrder> workOrdersToCreateWorkPlans) {
        fetchParentWorkPlans(workOrdersToCreateWorkPlans);
        generateWorkPlansOnWorkOrders();
    }

    /**
     * @description It is used to create WorkPlan instance according to the passed values.
     * @param workOrder
     * @param workPlanTemplate
     * @return WorkPlan
     */
    private WorkPlan createWorkPlanInstance(
        WorkOrder workOrder,
        WorkPlanTemplate workPlanTemplate
    ) {
        return new WorkPlan(
            ExecutionOrder = workPlanTemplate.RelativeExecutionOrder,
            Name = workPlanTemplate.Name,
            ParentRecordId = workOrder.Id,
            Parent_Work_Plan__c = workPlanIdentifierToWorkPlanId.get(
                workOrder.ParentWorkOrderId + DELIMITER + workPlanTemplate.Name
            ),
            Status__c = (((workOrder.Store_Account_Activation_Status__c ==
                ACCOUNT_ACTIVATION_STATUS_ACTIVE &&
                workOrder.Type__c == WORK_ORDER_TYPE_STOREFRONT &&
                workPlanTemplate.Name.contains(WORK_ORDER_TYPE_STOREFRONT)) ||
                (workOrder.Type__c == WORK_PLAN_TYPE_TABLET &&
                workPlanTemplate.Name.contains(WORK_PLAN_TYPE_TABLET)))
                ? STATUS_NOT_STARTED
                : WorkPlanTemplate.Work_Plan_Default_Status__c),
            Type__c = workPlanTemplate.Type__c,
            WorkOrderId = workOrder.Id,
            Work_Plan_Template__c = workPlanTemplate.Id
        );
    }

    /**
     * @description It is used to create WorkPlan records using the WorkPlanTemplates
     * matching the WorkOrder criteria.
     * @return List<WorkPlan>
     */
    private List<WorkPlan> createWorkPlansByWorkPlanTemplates() {
        List<WorkPlan> workPlansToInsert = new List<WorkPlan>();
        for (Id eachWorkOrderId : workOrderIdToWorkPlanTypes.keySet()) {
            for (String eachWorkPlanType : workOrderIdToWorkPlanTypes.get(eachWorkOrderId)) {
                if (!workPlanTypeToWorkPlanTemplate.containsKey(eachWorkPlanType)) {
                    continue;
                }
                workPlansToInsert.add(
                    createWorkPlanInstance(
                        workOrders.get(eachWorkOrderId),
                        workPlanTypeToWorkPlanTemplate.get(eachWorkPlanType)
                    )
                );
            }
        }
        return workPlansToInsert;
    }

    /**
     * @description It is used to get WorkPlan of ParentWorkOrder.
     * @param workOrders
     */
    private void fetchParentWorkPlans(List<WorkOrder> workOrders) {
        Set<Id> parentWorkOrderIds = new Set<Id>();
        for (WorkOrder eachWorkOrder : workOrders) {
            if (eachWorkOrder.ParentWorkOrderId == null) {
                continue;
            }
            parentWorkOrderIds.add(eachWorkOrder.ParentWorkOrderId);
        }
        for (
            WorkPlan eachWorkPlan : WorkPlansSelector.newInstance()
                .selectWorkPlansByWorkOrderIds(parentWorkOrderIds)
        ) {
            workPlanIdentifierToWorkPlanId.put(
                eachWorkPlan.WorkOrderId + DELIMITER + eachWorkPlan.Name,
                eachWorkPlan.Id
            );
        }
    }

    /**
     * @description It is used to get WorkPlanTemplate using WorkPlan types.
     * @param workPlanTypes
     * @return Map<String, WorkPlanTemplate>
     */
    private Map<String, WorkPlanTemplate> fetchWorkPlanTemplates(Set<String> workPlanTypes) {
        Map<String, WorkPlanTemplate> workPlanTypeToWorkPlanTemplateId = new Map<String, WorkPlanTemplate>();
        if (workPlanTypes.isEmpty()) {
            return workPlanTypeToWorkPlanTemplateId;
        }
        for (
            WorkPlanTemplate eachWorkPlanTemplate : WorkPlanTemplatesSelector.newInstance()
                .selectByType(workPlanTypes)
        ) {
            workPlanTypeToWorkPlanTemplateId.put(
                eachWorkPlanTemplate.Type__c,
                eachWorkPlanTemplate
            );
        }
        return workPlanTypeToWorkPlanTemplateId;
    }

    /**
     * @description It is used to generate WorkPlans on WorkOrders.
     */
    private void generateWorkPlansOnWorkOrders() {
        fflib_ISObjectUnitOfWork uowToCreateWorkPlans = Application.UNITOFWORK.newInstance();
        List<WorkPlan> workPlansToInsert = new List<WorkPlan>();
        Set<String> workPlanTypes = new Set<String>();
        for (Id eachWorkOrderId : workOrderIdToWorkPlanTypes.keySet()) {
            workPlanTypes.addAll(workOrderIdToWorkPlanTypes.get(eachWorkOrderId));
        }
        workPlanTypeToWorkPlanTemplate = fetchWorkPlanTemplates(workPlanTypes);
        if (workPlanTypeToWorkPlanTemplate.isEmpty()) {
            return;
        }
        workPlansToInsert = createWorkPlansByWorkPlanTemplates();
        if (workPlansToInsert.isEmpty()) {
            return;
        }
        try {
            uowToCreateWorkPlans.registerNew(workPlansToInsert);
            uowToCreateWorkPlans.commitWork();
        } catch (Exception workPlansCreationException) {
            Logger.publish(
                LogEntry.newExceptionLog(workPlansCreationException, LogEntry.SeverityLevel.HIGH)
            );
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_SERVICE_WORK_PLAN,
                        LOG_DOMAIN_PROVISIONING,
                        GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logException(workPlansCreationException)
            );
        }
    }
}