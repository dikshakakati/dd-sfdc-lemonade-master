/**
 * @author Deloitte
 * @date 07/07/2022
 * @description Service implementation class for store readiness validations related logic.
 */
public inherited sharing class StoreReadinessCheckServiceImpl implements IStoreReadinessCheckService {
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final String AGGREGATE_READINESS_FAILURE_COUNT_ALIAS = 'readinessCheckFailuresCount';
    private static final String AGGREGATE_WORK_ORDER_ID_FIELD_ALIAS = 'childWorkOrderId';
    private static final String DML_ALLOWED_LIMIT_STATIC_CONFIG = 'DML_Allowed_Limit';
    private static final String PROVISIONING_STATUS_READINESS_CHECK_FAILED = 'Readiness Check Failed';
    private static final String PROVISIONING_STATUS_READINESS_CHECK_COMPLETE = 'Readiness Check Complete';
    private static final Schema.Fieldset FIELDS_TO_QUERY = SObjectType.WorkOrder.FieldSets.Store_Readiness_Check_Fields;
    private static final String LIMIT_EXCEEDS_EXCEPTION_MESSAGE = 'Unexpected error occured: one or more governor limit exceeded';
    private static final String QUERIES_ALLOWED_LIMIT_STATIC_CONFIG = 'Queries_Allowed_Limit';
    private static final String QUERY_ROWS_ALLOWED_LIMIT_STATIC_CONFIG = 'Query_Rows_Allowed_Limit';
    private static final String LOG_SERVICE_READINESS_CHECK = 'Readiness Check';
    private static final String LOG_DOMAIN_PROVISIONING = 'Provisioning';
    private List<WorkOrder> childWorkOrders;
    private List<Readiness_Check_Failure__c> existingReadinessCheckFailuresRecord;
    private Integer dmlAllowedLimit;
    private Map<String, String> objectNameToServiceClassName;
    private Map<String, List<Store_Readiness_Validation_Rule__mdt>> objectNameToValidationRules;
    private Map<Id, WorkOrder> parentWorkOrders;
    private Integer queriesAllowedLimit;
    private Integer queryRowsAllowedLimit;
    /**
     * @description Default constructor to instantiate variables.
     */
    public StoreReadinessCheckServiceImpl() {
        this.childWorkOrders = new List<WorkOrder>();
        this.objectNameToServiceClassName = new Map<String, String>();
        this.objectNameToValidationRules = new Map<String, List<Store_Readiness_Validation_Rule__mdt>>();
        this.parentWorkOrders = new Map<Id, WorkOrder>();
        this.existingReadinessCheckFailuresRecord = new List<Readiness_Check_Failure__c>();
        collectStaticConfigurations();
    }

    /**
     * @description It is used to collect store readiness validation rules
     * and child Work Orders to perform readiness check on stores associated with
     * the passed Work Order Ids.
     * @jira LEM-13963
     * @param workOrderIds
     * @param existingReadinessCheckFailures
     */
    public void runReadinessCheckOnWorkOrders(Set<Id> workOrderIds,List<Readiness_Check_Failure__c> existingReadinessCheckFailures) {
        if (workOrderIds.isEmpty()) {
            return;
        }
        collectStoreReadinessValidationRules();
        Map<Id, WorkOrder> workOrders = new Map<Id, WorkOrder>(
            WorkOrdersSelector.newInstance()
                .selectWorkOrdersWithAccountDetailsByIds(
                    (Schema.FieldSet) FIELDS_TO_QUERY,
                    workOrderIds
                )
        );
        if (workOrders.isEmpty()) {
            return;
        }
        if(existingReadinessCheckFailures != null && !existingReadinessCheckFailures.isEmpty()){
            this.existingReadinessCheckFailuresRecord.addAll(existingReadinessCheckFailures);
        }
        collectParentAndChildWorkOrders(workOrders.values());
        callSObjectValidationServices();
        updateWorkOrderStatusByStoreReadinessCheckOutcome(workOrders);
    }

    /**
     * @description It is used to call respective service class and methods
     * from the configured custom metadata for store readiness check validations.
     */
    private void callSObjectValidationServices() {
        if (objectNameToServiceClassName.isEmpty()) {
            return;
        }
        LogEntry logEntryInstance;
        ILogger loggerInstance;
        IHandleStoreReadinessValidations serviceClassInstance;
        for (String eachObjectName : objectNameToValidationRules.keySet()) {
            serviceClassInstance = (IHandleStoreReadinessValidations) Application.SERVICE.newInstance(
                Type.forName(objectNameToServiceClassName.get(eachObjectName))
            );
            // It ensures that governor limits are not exceeded in iterative call
            // to service classes.
            if (isLimitExceeded()) {
                logEntryInstance = LogEntry.newLog(
                    StoreReadinessCheckServiceImpl.class.getName(),
                    serviceClassInstance.toString().substringBefore(':'),
                    LIMIT_EXCEEDS_EXCEPTION_MESSAGE
                );
                if (loggerInstance == null) {
                    loggerInstance = Logger.add(logEntryInstance);
                } else {
                    loggerInstance.add(logEntryInstance);
                }
                break;
            }
            try {
                // @jira LEM-13963
                serviceClassInstance.validate(
                    childWorkOrders,
                    parentWorkOrders.values(),
                    objectNameToValidationRules.get(eachObjectName),
                    existingReadinessCheckFailuresRecord,
                    eachObjectName
                );
            } catch (Exception sObjectServiceException) {
                // Exception logging to allow processing of other services in the iteration.
                logEntryInstance = LogEntry.newExceptionLog(
                    sObjectServiceException,
                    LogEntry.SeverityLevel.MEDIUM
                );
                if (loggerInstance == null) {
                    loggerInstance = Logger.add(logEntryInstance);
                    continue;
                }
                loggerInstance.add(logEntryInstance);
            }
        }
        if (loggerInstance != null) {
            loggerInstance.publish();
        }
    }

    /**
     * @description It collects Work Orders associated with either store Accounts
     * or business Accounts based on the list of Work Orders received.
     * @JIRA# LEM-1684
     * @param workOrders
     */
    private void collectParentAndChildWorkOrders(List<WorkOrder> workOrders) {
        for (WorkOrder eachWorkOrder : workOrders) {
            if (
                eachWorkOrder.ParentWorkOrderId != null &&
                eachWorkOrder.Account_Record_Type_Name__c == ACCOUNT_RECORD_TYPE_NAME_STORE
            ) {
                childWorkOrders.add(eachWorkOrder);
                parentWorkOrders.put(
                    eachWorkOrder.ParentWorkOrderId,
                    eachWorkOrder.ParentWorkOrder
                );
            }
            if (
                eachWorkOrder.ParentWorkOrderId == null &&
                eachWorkOrder.Account_Record_Type_Name__c == ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            ) {
                parentWorkOrders.put(eachWorkOrder.Id, eachWorkOrder);
            }
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
    }

    /**
     * @description It is used to collect valid active store readiness validation rules.
     */
    private void collectStoreReadinessValidationRules() {
        String objectName;
        for (
            Store_Readiness_Validation_Rule__mdt eachStoreReadinessValidationRule : StoreReadinessValidationRulesSelector.newInstance()
                .selectAllValidReadinessValidationRules()
        ) {
            objectName = eachStoreReadinessValidationRule.Object_Name__c;
            if (!objectNameToServiceClassName.containsKey(objectName)) {
                objectNameToServiceClassName.put(
                    objectName,
                    eachStoreReadinessValidationRule.Service_Class_Name__c
                );
            }
            if (!objectNameToValidationRules.containsKey(objectName)) {
                objectNameToValidationRules.put(
                    objectName,
                    new List<Store_Readiness_Validation_Rule__mdt>()
                );
            }
            objectNameToValidationRules.get(objectName).add(eachStoreReadinessValidationRule);
        }
    }

    /**
     * @description It checkss whether DML, Query rows & SOQL limit exceeded.
     * @return Boolean
     */
    private Boolean isLimitExceeded() {
        return (Limits.getLimitQueries() - Limits.getQueries()) < queriesAllowedLimit ||
            (Limits.getLimitQueryRows() - Limits.getQueryRows()) < queryRowsAllowedLimit ||
            (Limits.getLimitDMLStatements() - Limits.getDMLStatements()) < dmlAllowedLimit;
    }

    /**
     * @description It is used to update provisioning status on Work Order
     * according to the result o store readiness check.
     * @param workOrders
     */
    private void updateWorkOrderStatusByStoreReadinessCheckOutcome(Map<Id, WorkOrder> workOrders) {
        Set<Id> failedWorkOrderIds = new Set<Id>();
        WorkOrder workOrderToUpdate;
        Set<Id> workOrderIdsToQuery = new Set<Id>();
        fflib_ISObjectUnitOfWork uowWorkOrdersUpdation = Application.UNITOFWORK.newInstance();
        for (WorkOrder eachWorkOrder : workOrders.values()) {
            workOrderIdsToQuery.add(eachWorkOrder.Id);
            if (eachWorkOrder.ParentWorkOrderId != null) {
                workOrderIdsToQuery.add(eachWorkOrder.ParentWorkOrderId);
            }
        }
        for (
            Aggregate eachAggregate : ReadinessCheckFailuresSelector.newInstance()
                .getReadinessFailuresCountFilteredAndGroupedByWorkOrderIds(workOrderIdsToQuery)
        ) {
            if ((Integer) eachAggregate.get(AGGREGATE_READINESS_FAILURE_COUNT_ALIAS) > 0) {
                failedWorkOrderIds.add((Id) eachAggregate.get(AGGREGATE_WORK_ORDER_ID_FIELD_ALIAS));
            }
        }
        for (WorkOrder eachWorkOrder : workOrders.values()) {
            workOrderToUpdate = new WorkOrder(
                Id = eachWorkOrder.Id,
                Provisioning_Status__c = PROVISIONING_STATUS_READINESS_CHECK_COMPLETE
            );
            // It ensures that business Account should also pass readiness check
            if (
                failedWorkOrderIds.contains(eachWorkOrder.Id) ||
                failedWorkOrderIds.contains(eachWorkOrder.ParentWorkOrderId)
            ) {
                workOrderToUpdate.Provisioning_Status__c = PROVISIONING_STATUS_READINESS_CHECK_FAILED;
                workOrderToUpdate.Send_Readiness_Check_Email__c = String.valueOf(
                    Math.abs(Crypto.getRandomInteger())
                );
            }
            uowWorkOrdersUpdation.registerDirty(workOrderToUpdate);
        }
        try {
            uowWorkOrdersUpdation.commitWork();
        } catch (Exception workOrdersUpdatexception) {
            Logger.publish(
                LogEntry.newExceptionLog(workOrdersUpdatexception, LogEntry.SeverityLevel.HIGH)
            );
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                    LOG_SERVICE_READINESS_CHECK,LOG_DOMAIN_PROVISIONING,GenericLogEntry.SeverityLevel.HIGH
                ).logException(workOrdersUpdatexception)
            );
        }
    }
}