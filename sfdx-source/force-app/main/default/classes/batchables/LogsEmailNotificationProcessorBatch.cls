/**
 * @author Deloitte
 * @date 01/11/2024
 * @description It processes Log__c records having Send_Notification__c as true and sends
 * email notifications to the targeted recipients.
 */
public with sharing class LogsEmailNotificationProcessorBatch implements Database.Batchable<AggregateResult>, Schedulable {
    private static final String AGGREGATE_RESULT_COUNT_IDENTIFIER = 'logsCount';
    private static final String AGGREGATE_RESULT_PARENT_ID_IDENTIFIER = 'ParentId';
    private static final String BATCH_CHUNK_RECORDS_PROCESS_LIMIT = 'Logs_Batch_Chunk_Records_Process_Limit';
    private static final String BATCH_SIZE_BY_FRANCHISE_PARENT_ID_STATIC_CONFIG = 'Logs_Batch_Size_By_Franchise_Parent_Id';
    private static final String BATCH_SIZE_BY_PARENT_ID_STATIC_CONFIG = 'Logs_Batch_Size_By_Parent_Id';
    private static final String COLON_DELIMETER = ':';
    private static final String DAYS_FILTER_STATIC_CONFIG = 'Logs_Batch_Last_Days_Filter';
    private static final String TIMESTAMP_FILTER_STATIC_CONFIG = 'Logs_Batch_Timestamp_Filter_in_24_hours';
    private static final String CREATED_DATE_FILTER_IDENTIFIER = 'createdDateFilter';
    private static final String EXCEPTION_BLANK_QUERY = 'Query to execute cannot be blank';
    private static final String EXCEPTION_NULL_PARENT_FIELD = 'Parent field cannot be null';
    private static final String EXCEPTION_RECORDS_PROCESS_LIMIT_EXCEEDED = 'Number of records to process exceeds the limit; total logs counts: ';
    private static Integer batchChunkRecordsProcessLimit,
        batchSizeByFranchiseParentId,
        batchSizeByParentId,
        daysToFilter;
    private static String aggregateQueryByFranchiseParentId,
        aggregateQueryByParentId,
        timestampToFilter;
    private String aggregateQueryToExecute;
    private Integer batchSize;
    private Schema.SObjectField parentField;

    /**
     * @description Static block to instantiate static variables.
     */
    static {
        collectStaticConfigurations();
    }

    /**
     * @description Parameterized constructor to initialize the class variables.
     * @param parentField
     */
    public LogsEmailNotificationProcessorBatch(Schema.SObjectField parentField) {
        this.parentField = parentField;
        this.batchSize = 200;
    }

    /**
     * @description It queries all the Log__c records eligible to send email notification.
     * @JIRA# LEM-11498
     * @param batchableContext
     * @return Database.QueryLocator
     */
    public Iterable<AggregateResult> start(Database.BatchableContext batchableContext) {
        if (parentField == null) {
            throw new LogsEmailNotificationProcessorBatchException(EXCEPTION_NULL_PARENT_FIELD);
        }
        getQueryToExecute();
        if (String.isBlank(this.aggregateQueryToExecute)) {
            throw new LogsEmailNotificationProcessorBatchException(EXCEPTION_BLANK_QUERY);
        }
        return new AggregateResultIterable(
            this.aggregateQueryToExecute,
            getQueryFilters(),
            AccessLevel.USER_MODE
        );
    }

    /**
     * @description It initiates process to send email notification for the passed Log records.
     * @JIRA# LEM-11498
     * @param batchableContext
     * @param aggregateResults
     */
    public void execute(
        Database.BatchableContext batchableContext,
        List<SObject> aggregateResults
    ) {
        Set<Id> parentIds = new Set<Id>();
        Integer totalLogsCount = 0;
        for (SObject eachAggregateResult : aggregateResults) {
            parentIds.add((Id) eachAggregateResult.get(AGGREGATE_RESULT_PARENT_ID_IDENTIFIER));
            totalLogsCount += (Integer) eachAggregateResult.get(AGGREGATE_RESULT_COUNT_IDENTIFIER);
        }
        if (totalLogsCount > batchChunkRecordsProcessLimit) {
            throw new LogsEmailNotificationProcessorBatchException(
                EXCEPTION_RECORDS_PROCESS_LIMIT_EXCEEDED + totalLogsCount
            );
        }
        LogsEmailNotificationService.initiateEmailNotificationsProcessor(parentField, parentIds);
    }

    /**
     * @description Execute method to schedule this batch class.
     * @param schedulableContext
     */
    public void execute(SchedulableContext schedulableContext) {
        Database.executeBatch(new LogsEmailNotificationProcessorBatch(parentField), getBatchSize());
    }

    /**
     * @description Default finish method for this batch class.
     * @JIRA# LEM-11498
     * @param batchableContext
     */
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext batchableContext) {
    }

    /**
     * @description It is used to get static configurations.
     */
    private static void collectStaticConfigurations() {
        batchChunkRecordsProcessLimit = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(BATCH_CHUNK_RECORDS_PROCESS_LIMIT)
                .Configuration_Value__c
        );
        batchSizeByFranchiseParentId = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(BATCH_SIZE_BY_FRANCHISE_PARENT_ID_STATIC_CONFIG)
                .Configuration_Value__c
        );
        batchSizeByParentId = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(BATCH_SIZE_BY_PARENT_ID_STATIC_CONFIG)
                .Configuration_Value__c
        );
        daysToFilter = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(DAYS_FILTER_STATIC_CONFIG)
                .Configuration_Value__c
        );
        timestampToFilter = String.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(TIMESTAMP_FILTER_STATIC_CONFIG)
                .Configuration_Value__c
        );
    }

    /**
     * @description It returns the batch size on basis of the parent field.
     * @return Integer
     */
    private Integer getBatchSize() {
        if (this.parentField == Log__c.Franchise_Parent_Account_Id_18__c) {
            this.batchSize = batchSizeByFranchiseParentId;
        } else {
            this.batchSize = batchSizeByParentId;
        }
        return this.batchSize;
    }

    /**
     * @description It returns the filters to apply on the query.
     * @return Map<String, Object>
     */
    private Map<String, Object> getQueryFilters() {
        Date dateToFilter = System.today().addDays(-daysToFilter);
        Time timeToFilter = Time.newInstance(0, 0, 0, 0);
        if (String.isNotBlank(timestampToFilter) && timestampToFilter.contains(COLON_DELIMETER)) {
            List<String> timestampComponents = timestampToFilter.split(COLON_DELIMETER);
            timeToFilter = Time.newInstance(
                getTimeStampComponent(0, timestampComponents),
                getTimeStampComponent(1, timestampComponents),
                getTimeStampComponent(2, timestampComponents),
                getTimeStampComponent(3, timestampComponents)
            );
        } else if (String.isNotBlank(timestampToFilter)) {
            timeToFilter = Time.newInstance(Integer.valueOf(timestampToFilter), 0, 0, 0);
        }
        DateTime dateTimeToFilter = DateTime.newInstance(dateToFilter, timeToFilter);
        return new Map<String, Object>{ CREATED_DATE_FILTER_IDENTIFIER => dateTimeToFilter };
    }

    /**
     * @description It identifies the query to execute on basis of the parent field.
     */
    private void getQueryToExecute() {
        if (this.parentField == Log__c.Franchise_Parent_Account_Id_18__c) {
            this.aggregateQueryToExecute = System.Label.Aggregate_Query_On_Log_By_Franchise_Parent_Id;
        } else {
            this.aggregateQueryToExecute = System.Label.Aggregate_Query_On_Log_By_Parent_Id;
        }
    }

    /**
     * @description It returs the hour, minute, second and millisecond components
     * of the passed timestamp on basis of the passed index.
     * @param index
     * @param timestampComponents
     * @return Integer
     */
    private Integer getTimestampComponent(Integer index, List<String> timestampComponents) {
        Integer timestampComponent = 0;
        if (index >= 0 && index < timestampComponents.size()) {
            timestampComponent = Integer.valueOf(timestampComponents[index]);
        }
        return timestampComponent;
    }

    /**
     * @author Deloitte
     * @date 01/11/2024
     * @description Exception class for custom exceptions related to this batch class.
     */
    private class LogsEmailNotificationProcessorBatchException extends Exception {
    }
}