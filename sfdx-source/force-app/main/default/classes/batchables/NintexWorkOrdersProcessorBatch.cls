/**
 * @author Deloitte
 * @date 11/24/2022
 * @description Batch class to process records created through Nintex for initiating child Work Orders creation.
 * It is currently being used for initiating stores association with parent Work Order for "Rate Change" Nintex Use Case.
 */
public with sharing class NintexWorkOrdersProcessorBatch implements Database.Batchable<SObject>, Database.Stateful, Database.RaisesPlatformEvents {
    private static final String DML_ALLOWED_LIMIT_STATIC_CONFIG = 'DML_Allowed_Limit';
    private static final String LIMIT_EXCEEDED_MESSAGE = 'Governor Limit exceeded';
    private static final String QUERIES_ALLOWED_LIMIT_STATIC_CONFIG = 'Queries_Allowed_Limit';
    private static final String QUERY_ROWS_ALLOWED_LIMIT_STATIC_CONFIG = 'Query_Rows_Allowed_Limit';
    private static Integer dmlAllowedLimit, queriesAllowedLimit, queryRowsAllowedLimit;
    private Map<Id, Id> franchiseAccountIdToOpportunityId;
    private Boolean limitExceeded;
    @TestVisible
    private Set<Id> parentWorkOrderIds;

    /**
     * @description Static block to instantiate static variables.
     */
    static {
        collectStaticConfigurations();
    }

    /**
     * @description Default constructor to instantiate variables.
     * @param franchiseAccountIdToOpportunityId
     */
    public NintexWorkOrdersProcessorBatch(Map<Id, Id> franchiseAccountIdToOpportunityId) {
        this.franchiseAccountIdToOpportunityId = franchiseAccountIdToOpportunityId;
        this.limitExceeded = false;
        this.parentWorkOrderIds = new Set<Id>();
    }

    /**
     * @description It queries store Accounts by passing the franchiseParentIds
     * to start the batch processing.
     * @JIRA# LEM-3658
     * @param batchableContext
     * @return Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        return AccountsSelector.newInstance()
            .selectStoreAccountsByFranchiseParentIds(franchiseAccountIdToOpportunityId?.keySet());
    }

    /**
     * @description It initiates child Work Orders creation using the passed store Accounts.
     * @JIRA# LEM-3658
     * @param batchableContext
     * @param storeAccounts
     */
    public void execute(Database.BatchableContext batchableContext, List<Account> storeAccounts) {
        if (isLimitExceeded()) {
            limitExceeded = true;
            return;
        }
        parentWorkOrderIds.addAll(
            NintexWorkOrdersProcessorService.initiateChildWorkOrdersCreation(
                franchiseAccountIdToOpportunityId,
                storeAccounts
            )
        );
    }

    /**
     * @description It is used to toggle banner message indicator on parent Work Orders
     * in finish method.
     * @JIRA# LEM-3658
     * @param batchableContext
     */
    public void finish(Database.BatchableContext batchableContext) {
        WorkOrdersService.toggleBannerOnParentWorkOrders(parentWorkOrderIds);
        createLogEntries();
    }

    /**
     * @description It is used to get static configurations.
     */
    private static void collectStaticConfigurations() {
        dmlAllowedLimit = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(DML_ALLOWED_LIMIT_STATIC_CONFIG)
                .Configuration_Value__c
        );
        queriesAllowedLimit = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(QUERIES_ALLOWED_LIMIT_STATIC_CONFIG)
                .Configuration_Value__c
        );
        queryRowsAllowedLimit = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(QUERY_ROWS_ALLOWED_LIMIT_STATIC_CONFIG)
                .Configuration_Value__c
        );
    }

    /**
     * @description It is used to create log records when the governor limits are exceeded
     * while generating child Work Orders.
     */
    private void createLogEntries() {
        ILogger loggerInstance;
        if (limitExceeded) {
            loggerInstance = Logger.add(
                LogEntry.newLog(LIMIT_EXCEEDED_MESSAGE, LogEntry.SeverityLevel.HIGH)
            );
        }
        if (loggerInstance == null) {
            return;
        }
        loggerInstance.publish();
    }

    /**
     * @description It checks whether DML, Query rows & SOQL limits exceeded.
     * @return Boolean
     */
    private Boolean isLimitExceeded() {
        return (Limits.getLimitQueries() - Limits.getQueries()) < queriesAllowedLimit ||
            (Limits.getLimitQueryRows() - Limits.getQueryRows()) < queryRowsAllowedLimit ||
            (Limits.getLimitDMLStatements() - Limits.getDMLStatements()) < dmlAllowedLimit;
    }
}