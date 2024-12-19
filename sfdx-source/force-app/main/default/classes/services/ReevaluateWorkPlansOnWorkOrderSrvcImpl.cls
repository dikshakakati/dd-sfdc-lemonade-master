/**
 * @author Deloitte
 * @date 13/07/2022
 * @description Service implementation class for ReevaluateWorkPlansOnWorkOrderController related logic.
 */
public inherited sharing class ReevaluateWorkPlansOnWorkOrderSrvcImpl implements IReevaluateWorkPlansOnWorkOrderService {
    private static final String DML_ALLOWED_LIMIT_STATIC_CONFIG = 'DML_Allowed_Limit';
    private static final String LOG_RECORD_METHOD_NAME = 'reevaluateWorkPlans';
    private static final String LIMIT_EXCEEDS_EXCEPTION_MESSAGE = 'Unexpected error occured: one or more governor limit exceeded';
    private static final String OBJECT_INSTANCE_MAP_EMPTY = '{}';
    private static final String OBJECT_INSTANCE_NULL = 'null';
    private static final String OBJECT_INSTANCE_LIST_OR_SET_EMTPY = '[]';
    private static final String QUERIES_ALLOWED_LIMIT_STATIC_CONFIG = 'Queries_Allowed_Limit';
    private static final String QUERY_ROWS_ALLOWED_LIMIT_STATIC_CONFIG = 'Query_Rows_Allowed_Limit';
    private static final String SEPARATOR = System.Label.Separator;
    private static final String STORE_LEVEL_WORK_PLAN_TYPES_STATIC_CONFIG = 'Store_Level_Work_Plan_Types';
    private static final String WORK_PLANS_REEVALUATION_CHUNK_SIZE_STATIC_CONFIG = 'Work_Plans_Reevaluation_Chunk_Size';
    private static final String GENERIC_LOG_SERVICE = 'Reevaluate Work Plans On Work Order';
    private static final String GENERIC_LOG_DOMAIN = 'Provisioning';
    private Integer dmlAllowedLimit;
    private String noWorkPlansToReevaluateMessage;
    private Integer queriesAllowedLimit;
    private Integer queryRowsAllowedLimit;
    private Integer workPlansReevaluationChunkSize;
    private List<String> allWorkPlanTypes;
    private List<WorkPlan> relatedWorkPlans;
    private Set<String> storeLevelWorkPlanTypes;
    private List<String> workOrderIds;
    private Map<Id, Set<String>> workOrderIdToWorkPlanTypes;
    private Map<Id, WorkOrder> workOrders;

    /**
     * @description Default constructor to instantiate variables.
     */
    public ReevaluateWorkPlansOnWorkOrderSrvcImpl() {
        allWorkPlanTypes = new List<String>();
        noWorkPlansToReevaluateMessage = System.Label.No_Work_Plans_To_Reevaluate_Message;
        relatedWorkPlans = new List<WorkPlan>();
        storeLevelWorkPlanTypes = new Set<String>();
        workOrderIds = new List<String>();
        workOrderIdToWorkPlanTypes = new Map<Id, Set<String>>();
        workOrders = new Map<Id, WorkOrder>();
        collectStaticConfigurations();
    }

    /**
     * @description It re-evaulates Work Plans on parent and child Work Orders
     * by passing the parent Work Order Id.
     * //TODO: To implement creation of WorkPlans & WorkSteps using async process in-case limit exceeds.
     * @JIRA# LEM-1956
     * @param parentWorkOrderId
     */
    public void reevaluateWorkPlans(Id parentWorkOrderId) {
        workOrders = new Map<Id, WorkOrder>(
            WorkOrdersSelector.newInstance()
                .selectWorkOrdersWithWorkPlansByParentWorkOrderIds(new Set<Id>{ parentWorkOrderId })
        );
        workOrderIds = new List<Id>((Set<Id>) workOrders.keySet());
        //collects matching Work Plan types for the passed Work Order Ids
        workOrderIdToWorkPlanTypes = WorkPlansMapperService.collectMatchingWorkPlanTypes(
            workOrderIds
        );
        //collect all re-evaluated Work Plan types
        for (Set<String> eachWorkPlanTypes : workOrderIdToWorkPlanTypes.values()) {
            allWorkPlanTypes.addAll(eachWorkPlanTypes);
        }
        if (isEmptyOrNull(allWorkPlanTypes)) {
            //throw exception when no Work Plans are available for re-evaluation
            throw new AuraHandledException(noWorkPlansToReevaluateMessage);
        }
        syncWorkPlanTypesOnChildWorkOrders(parentWorkOrderId);
        removeDuplicateWorkPlanTypes();
        //@JIRA# LEM-2349 - Creating Work Plans on parent Work Order to maintain the hierarchy
        if (!isEmptyOrNull(workOrderIdToWorkPlanTypes.get(parentWorkOrderId))) {
            WorkPlanTemplatesService.createWorkPlansOnWorkOrdersByReevaluatingCriteria(
                new List<WorkOrder>{ workOrders.get(parentWorkOrderId) },
                new Map<Id, Set<String>>{
                    parentWorkOrderId => workOrderIdToWorkPlanTypes.get(parentWorkOrderId)
                }
            );
        }
        //removing parent Work Order types from Map
        workOrderIdToWorkPlanTypes.remove(parentWorkOrderId);
        //removing parent Work Order from list of WorkOrders
        workOrders.remove(parentWorkOrderId);
        workOrderIds.remove(workOrderIds.indexOf(parentWorkOrderId));
        if (workOrderIdToWorkPlanTypes.keySet().size() > workPlansReevaluationChunkSize) {
            triggerWorkPlansCreationByChunks();
        } else {
            WorkPlanTemplatesService.createWorkPlansOnWorkOrdersByReevaluatingCriteria(
                workOrders.values(),
                workOrderIdToWorkPlanTypes
            );
        }
    }

    /**
     * @description It is used to get static configurations.
     */
    private void collectStaticConfigurations() {
        this.dmlAllowedLimit = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(DML_ALLOWED_LIMIT_STATIC_CONFIG)
                .Configuration_Value__c
        );
        this.queriesAllowedLimit = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(QUERIES_ALLOWED_LIMIT_STATIC_CONFIG)
                .Configuration_Value__c
        );
        this.queryRowsAllowedLimit = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(QUERY_ROWS_ALLOWED_LIMIT_STATIC_CONFIG)
                .Configuration_Value__c
        );
        this.workPlansReevaluationChunkSize = Test.isRunningTest()
            ? 1
            : Integer.valueOf(
                  StaticConfigurationsSelector.newInstance()
                      .getInstanceValue(WORK_PLANS_REEVALUATION_CHUNK_SIZE_STATIC_CONFIG)
                      .Configuration_Value__c
              );
        this.storeLevelWorkPlanTypes = new Set<String>(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(STORE_LEVEL_WORK_PLAN_TYPES_STATIC_CONFIG)
                .Configuration_Value__c.split(SEPARATOR)
        );
    }

    /**
     * @description It returns chunked WorkOrder Id to WorkPlan types for creation of
     * WorkPlans on WorkOrder.
     * @JIRA# LEM-1956
     * @return List<String>
     */
    private List<String> chunkWorkOrderIdToWorkPlanTypes() {
        List<String> chunkedData = new List<String>();
        Integer iterator = 0;
        Integer chunkSize = workPlansReevaluationChunkSize;
        Integer endIndex = workPlansReevaluationChunkSize;
        while (iterator < workOrderIdToWorkPlanTypes.keySet().size()) {
            chunkedData.add(
                JSON.serialize(generateWorkOrderIdToWorkPlanTypesByChunkSize(endIndex, iterator))
            );
            iterator += chunkSize;
            endIndex += chunkSize;
        }
        return chunkedData;
    }

    /**
     * @description It is used to create log records for the issues recorded
     * while re-evaluating Work Plans.
     */
    private void createLogEntries() {
        ILogger loggerInstance;
        loggerInstance = Logger.add(
            LogEntry.newLog(
                ReevaluateWorkPlansOnWorkOrderSrvcImpl.class.getName(),
                LOG_RECORD_METHOD_NAME,
                LIMIT_EXCEEDS_EXCEPTION_MESSAGE
            )
        );
        if (loggerInstance == null) {
            return;
        }
        loggerInstance.publish();

        GenericLoggerService.publish(
            GenericLoggerService.createGenericLog(
                GENERIC_LOG_SERVICE,
                GENERIC_LOG_DOMAIN,
                GenericLogEntry.SeverityLevel.LOW
            ).logException(
                new DmlException( LIMIT_EXCEEDS_EXCEPTION_MESSAGE )
            )
        );
    }

    /**
     * @description It checks whether the processed Work Plan type contains
     * in workOrderIdToWorkPlanTypes map.
     * @param processedWorkOrderId
     * @param processedType
     * @return Boolean
     */
    private Boolean doesContainsProcessedType(Id processedWorkOrderId, String processedType) {
        return workOrderIdToWorkPlanTypes.get(processedWorkOrderId).contains(processedType);
    }

    /**
     * @description It is used to generate workOrderIdToWorkPlanTypes according to the chunk size.
     * @JIRA# LEM-1956
     * @param endIndex
     * @param startIndex
     * @return Map<Id,List<String>>
     */
    private Map<Id, Set<String>> generateWorkOrderIdToWorkPlanTypesByChunkSize(
        Integer endIndex,
        Integer startIndex
    ) {
        Map<Id, Set<String>> filteredWorkOrderIdToWorkPlanTypes = new Map<Id, Set<String>>();
        for (Integer index = startIndex; index < endIndex; index++) {
            if (index >= workOrderIds.size()) {
                continue;
            }
            filteredWorkOrderIdToWorkPlanTypes.put(
                workOrderIds[index],
                workOrderIdToWorkPlanTypes.get(workOrderIds[index])
            );
        }
        return filteredWorkOrderIdToWorkPlanTypes;
    }

    /**
     * @description To check whether the passed list or set or map is null or empty.
     * @JIRA# LEM-1956
     * @param objectInstance - List/Set/Map
     * @return Boolean
     */
    private Boolean isEmptyOrNull(Object objectInstance) {
        return (JSON.serialize(objectInstance) == OBJECT_INSTANCE_NULL) ||
            JSON.serialize(objectInstance).equals(OBJECT_INSTANCE_LIST_OR_SET_EMTPY) ||
            JSON.serialize(objectInstance).equals(OBJECT_INSTANCE_MAP_EMPTY);
    }

    /**
     * @description It checks whether DML, Query rows & SOQL limits exceeded.
     * @JIRA# LEM-1956
     * @return Boolean
     */
    private Boolean isLimitExceeded() {
        return (Limits.getLimitQueries() - Limits.getQueries()) < queriesAllowedLimit ||
            (Limits.getLimitQueryRows() - Limits.getQueryRows()) < queryRowsAllowedLimit ||
            (Limits.getLimitDMLStatements() - Limits.getDMLStatements()) < dmlAllowedLimit;
    }

    /**
     * @description It checks whether the passed Work Order Id is equal to the passed
     * parent Work Order Id.
     * @JIRA# LEM-1956
     * @param parentWorkOrderId
     * @param workOrderIdToCompare
     * @return Boolean
     */
    private Boolean isParentWorkOrderId(Id parentWorkOrderId, Id workOrderIdToCompare) {
        return parentWorkOrderId == workOrderIdToCompare;
    }

    /**
     * @description It removes duplicate Work Plan types for a Work Order.
     * @JIRA# LEM-1956
     */
    private void removeDuplicateWorkPlanTypes() {
        for (Id eachWorkOrderId : workOrders.keySet()) {
            for (WorkPlan eachWorkPlan : workOrders.get(eachWorkOrderId).WorkPlans) {
                if (
                    workOrderIdToWorkPlanTypes.get(eachWorkOrderId).contains(eachWorkPlan.Type__c)
                ) {
                    workOrderIdToWorkPlanTypes.get(eachWorkOrderId).remove(eachWorkPlan.Type__c);
                }
            }
        }
    }

    /**
     * @description It syncs the passed Work Plan types on the passed Work Order Id.
     * @JIRA# LEM-1956
     * @param workOrderId
     * @param workPlanTypesToCopy
     */
    private void syncWorkPlanTypes(Id workOrderId, Set<String> workPlanTypesToCopy) {
        for (String eachWorkPlanType : workPlanTypesToCopy) {
            if (
                !doesContainsProcessedType(workOrderId, eachWorkPlanType) &&
                !storeLevelWorkPlanTypes.contains(eachWorkPlanType)
            ) {
                workOrderIdToWorkPlanTypes.get(workOrderId).add(eachWorkPlanType);
            }
        }
    }

    /**
     * @description It syncs work plan types on child Work Orders as per the following criteria:
     * a. Work Orders without any Work Plan type re-evaluated through WorkPlansMapper.
     * b. Work Plans generated only on parent Work Order through re-evaluation.
     * @JIRA# LEM-1956
     * @param parentWorkOrderId
     */
    private void syncWorkPlanTypesOnChildWorkOrders(Id parentWorkOrderId) {
        Set<String> parentWorkPlanTypes = (Set<String>) workOrderIdToWorkPlanTypes.get(
            parentWorkOrderId
        );
        Boolean isParentWorkOrder = false;
        for (Id eachWorkOrderId : workOrders.keySet()) {
            isParentWorkOrder = isParentWorkOrderId(parentWorkOrderId, eachWorkOrderId);
            //prevents re-syncing the same Work Plan types
            if (
                isParentWorkOrder ||
                (!isParentWorkOrder &&
                parentWorkPlanTypes.equals(workOrderIdToWorkPlanTypes.get(eachWorkOrderId)))
            ) {
                continue;
            }
            syncWorkPlanTypes(eachWorkOrderId, parentWorkPlanTypes);
        }
    }

    /**
     * @description It triggers Work Plans creation in-case number of Work Orders exceeds chunk size.
     * @JIRA# LEM-1956
     */
    private void triggerWorkPlansCreationByChunks() {
        //performing dml in loop to create Work Plans in chunks
        for (String eachChunkedWorkOrderIdToWorkPlanType : chunkWorkOrderIdToWorkPlanTypes()) {
            if (isLimitExceeded()) {
                createLogEntries();
                break;
            }
            Map<Id, Set<String>> workOrderIdToWorkPlanTypesToBeCreated = (Map<Id, Set<String>>) JSON.deserialize(
                eachChunkedWorkOrderIdToWorkPlanType,
                Map<Id, Set<String>>.class
            );
            WorkPlanTemplatesService.createWorkPlansOnWorkOrdersByReevaluatingCriteria(
                workOrders.values(),
                workOrderIdToWorkPlanTypesToBeCreated
            );
        }
    }
}