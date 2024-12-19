/**
 * @author Deloitte
 * @date 01/18/2024
 * @description Test class for LogsEmailNotificationProcessorBatch class.
 */
@isTest(SeeAllData=false)
private class LogsEmailNotificationProcessorBatchTest {
    private static final String BATCH_NOT_TRIGGERED_ASSERT_MESSAGE = 'Unexpected Error: The Batch has not been triggered yet';
    private static final String BATCH_CHUNK_RECORDS_PROCESS_LIMIT = 'Logs_Batch_Chunk_Records_Process_Limit';
    private static final String BATCH_SIZE_BY_FRANCHISE_PARENT_ID_STATIC_CONFIG = 'Logs_Batch_Size_By_Franchise_Parent_Id';
    private static final String BATCH_SIZE_BY_PARENT_ID_STATIC_CONFIG = 'Logs_Batch_Size_By_Parent_Id';
    private static final String CREATED_DATE_FILTER_IDENTIFIER = 'createdDateFilter';
    private static final String CRON_EXPRESSION = '0 0 1 * * ?';
    private static final String DAYS_FILTER_STATIC_CONFIG = 'Logs_Batch_Last_Days_Filter';
    private static final String TIMESTAMP_FILTER_STATIC_CONFIG = 'Logs_Batch_Timestamp_Filter_in_24_hours';
    private static final String SCHEDULED_JOB_NAME = LogsEmailNotificationProcessorBatchTest.class
        .getName();

    /**
     * @description To test if the service method is called when the batch runs.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    static void testWhenLogsSelectedThenSendEmailNotification() {
        Schema.SObjectField parentField = Log__c.Parent_Account_Id_18__c;
        String aggregateQueryToExecute = System.Label.Aggregate_Query_On_Log_By_Parent_Id;
        Map<String, Object> filters = new Map<String, Object>{
            CREATED_DATE_FILTER_IDENTIFIER => DateTime.newInstance(
                System.today().addDays(-1),
                Time.newInstance(9, 0, 0, 0)
            )
        };
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Log__c mockLog = new Log__c(
            Send_Notification__c = true,
            Parent_Account_Id_18__c = parentAccountId,
            Franchise_Parent_Account_Id_18__c = null,
            Recipient_Ids_To_Send_Notification__c = UserInfo.getUserId(),
            Store_Account_Id_18__c = storeAccountId,
            CreatedDate = System.today()
        );
        insert mockLog;
        AggregateResult[] aggregateResults = Database.queryWithBinds(
            String.escapeSingleQuotes(aggregateQueryToExecute),
            filters,
            AccessLevel.USER_MODE
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        LogsSelector mockLogsSelector = (LogsSelector) mocks.mock(LogsSelector.class);
        ILogsEmailNotificationService logsServiceMock = (ILogsEmailNotificationService) mocks.mock(
            ILogsEmailNotificationService.class
        );
        IStaticConfigurationsSelector mockStaticConfigurations = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockLogsSelector.sObjectType()).thenReturn(Log__c.SObjectType);
        mocks.when(
                mockLogsSelector.selectLogsEligibleToSendNotification(
                    parentField,
                    new Set<Id>{ parentAccountId },
                    Log__c.Franchise_Parent_Account_Id_18__c
                )
            )
            .thenReturn(new List<Log__c>{ mockLog });
        mocks.when(mockStaticConfigurations.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(mockStaticConfigurations.getInstanceValue(BATCH_CHUNK_RECORDS_PROCESS_LIMIT))
            .thenReturn(new Static_Configurations__mdt(Configuration_Value__c = '45000'));
        mocks.when(
                mockStaticConfigurations.getInstanceValue(
                    BATCH_SIZE_BY_FRANCHISE_PARENT_ID_STATIC_CONFIG
                )
            )
            .thenReturn(new Static_Configurations__mdt(Configuration_Value__c = '50'));
        mocks.when(mockStaticConfigurations.getInstanceValue(BATCH_SIZE_BY_PARENT_ID_STATIC_CONFIG))
            .thenReturn(new Static_Configurations__mdt(Configuration_Value__c = '50'));
        mocks.when(mockStaticConfigurations.getInstanceValue(DAYS_FILTER_STATIC_CONFIG))
            .thenReturn(new Static_Configurations__mdt(Configuration_Value__c = '0'));
        mocks.when(mockStaticConfigurations.getInstanceValue(TIMESTAMP_FILTER_STATIC_CONFIG))
            .thenReturn(new Static_Configurations__mdt(Configuration_Value__c = '07:00'));
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockLogsSelector);
        Application.SELECTOR.setMock(mockStaticConfigurations);
        Application.Service.setMock(ILogsEmailNotificationService.class, logsServiceMock);
        LogsEmailNotificationProcessorBatch batch = new LogsEmailNotificationProcessorBatch(
            parentField
        );
        batch.start(null);
        batch.execute(null, aggregateResults);
        batch.finish(null);
        ((ILogsEmailNotificationService) mocks.verify(logsServiceMock, 1))
            .initiateEmailNotificationsProcessor(parentField, new Set<Id>{ parentAccountId });
    }

    /**
     * @description To test if schedulable context execute
     * is scheduling the batch job correctly.
     **/
    @isTest
    private static void testWhenBatchIsScheduledThenBatchIsExecutedOnScheduledTime() {
        Schema.SObjectField parentField = Log__c.Parent_Account_Id_18__c;
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStaticConfigurationsSelector mockStaticConfigurations = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockStaticConfigurations.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(mockStaticConfigurations.getInstanceValue(BATCH_CHUNK_RECORDS_PROCESS_LIMIT))
            .thenReturn(new Static_Configurations__mdt(Configuration_Value__c = '45000'));
        mocks.when(
                mockStaticConfigurations.getInstanceValue(
                    BATCH_SIZE_BY_FRANCHISE_PARENT_ID_STATIC_CONFIG
                )
            )
            .thenReturn(new Static_Configurations__mdt(Configuration_Value__c = '50'));
        mocks.when(mockStaticConfigurations.getInstanceValue(BATCH_SIZE_BY_PARENT_ID_STATIC_CONFIG))
            .thenReturn(new Static_Configurations__mdt(Configuration_Value__c = '50'));
        mocks.when(mockStaticConfigurations.getInstanceValue(DAYS_FILTER_STATIC_CONFIG))
            .thenReturn(new Static_Configurations__mdt(Configuration_Value__c = '0'));
        mocks.when(mockStaticConfigurations.getInstanceValue(TIMESTAMP_FILTER_STATIC_CONFIG))
            .thenReturn(new Static_Configurations__mdt(Configuration_Value__c = '07:00'));
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStaticConfigurations);
        Test.startTest();
        String jobId = System.schedule(
            SCHEDULED_JOB_NAME,
            CRON_EXPRESSION,
            new LogsEmailNotificationProcessorBatch(parentField)
        );
        Test.stopTest();
        CronTrigger cronTriggerRecord = [
            SELECT Id, CronExpression, TimesTriggered, NextFireTime
            FROM CronTrigger
            WHERE Id = :jobId
        ];
        System.assertEquals(
            Time.newInstance(1, 0, 0, 0),
            cronTriggerRecord.NextFireTime.time(),
            BATCH_NOT_TRIGGERED_ASSERT_MESSAGE
        );
    }
}