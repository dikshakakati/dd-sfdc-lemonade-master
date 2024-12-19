/**
 * @author Deloitte
 * @date 10/03/2023
 * @description Test class for LogsServiceImpl class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class LogsServiceImplTest {
    private static final String DETAILED_ERROR_MESSAGE = 'Associated Store Account does not have address verified or is not in coverage';
    private static final String EVENT_TOPIC_BUSINESS_ERROR_LOGS_CREATION = 'BUSINESS_ERROR_LOGS_CREATION';
    private static final String EVENT_TOPIC_WORK_ORDER_STORES_CALCULATION = 'WORK_ORDER_STORES_CALCULATION';
    private static final String RECORD_IDS_SOURCE_RECORD_SUFFIX = 'Source Record Ids: ';
    private static final String STORE_ACCOUNT_NAME = 'Test Account';
    private static final String WORK_ORDERS_CREATION_SERVICE_CLASS_NAME = 'WorkOrdersCreationServiceImpl';
    private static final String WORK_ORDERS_CREATION_SERVICE_METHOD_NAME = 'createWorkOrders';

    /**
     * @description To test creation of Log records when notifier event is received
     * with error details.
     */
    @isTest
    private static void testWhenNotifierEventReceivedThenCreateLogs() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id logOwnerId = fflib_IDGenerator.generate(User.SObjectType);
        Id sourceId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        LogMessageEntry logMessageEntryInstance = new LogMessageEntry(
            businessAccountId,
            DETAILED_ERROR_MESSAGE,
            logOwnerId,
            sourceId,
            storeAccountId
        );
        logMessageEntryInstance.logType = LogEntry.LogCategory.BUSINESS_ERROR.name();
        logMessageEntryInstance.sendNotification = true;
        logMessageEntryInstance.storeAccountName = STORE_ACCOUNT_NAME;
        LogCreationEntry logCreationEntryInstance = new LogCreationEntry(
            WORK_ORDERS_CREATION_SERVICE_CLASS_NAME,
            WORK_ORDERS_CREATION_SERVICE_METHOD_NAME,
            new List<LogMessageEntry>{ logMessageEntryInstance }
        );
        List<Notifier__e> events = new List<Notifier__e>();
        events.add(
            new Notifier__e(
                Topic__c = EVENT_TOPIC_BUSINESS_ERROR_LOGS_CREATION,
                Payload__c = JSON.serialize(new List<LogCreationEntry>{ logCreationEntryInstance })
            )
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        LogsService.execute(events);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Log__c.Class_Name__c => LogCreationEntryInstance.sourceClassName,
                        Log__c.Class_Method_Name__c => logCreationEntryInstance.sourceMethodName,
                        Log__c.Detailed_Message__c => logMessageEntryInstance.detailedMessage,
                        Log__c.Log_Type__c => LogEntry.LogCategory.BUSINESS_ERROR.name(),
                        Log__c.OwnerId => logMessageEntryInstance.logOwnerId,
                        Log__c.Parent_Account_Id_18__c => logMessageEntryInstance.businessAccountId,
                        Log__c.Record_Id__c => RECORD_IDS_SOURCE_RECORD_SUFFIX +
                        new Set<Id>{ logMessageEntryInstance.sourceRecordId },
                        Log__c.Send_Notification__c => true,
                        Log__c.Severity_Level__c => LogEntry.SeverityLevel.MEDIUM.name(),
                        Log__c.Store_Account_Id_18__c => logMessageEntryInstance.storeAccountId,
                        Log__c.Store_Account_Name__c => logMessageEntryInstance.storeAccountName
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Log__c records creation is not initiated when notifier event is received
     * with different event topic.
     */
    @isTest
    private static void testWhenIncorrectEventTopicReceivedThenLogsNotCreated() {
        List<Notifier__e> events = new List<Notifier__e>();
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id logOwnerId = fflib_IDGenerator.generate(User.SObjectType);
        Id sourceId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        LogMessageEntry logMessageEntryInstance = new LogMessageEntry(
            businessAccountId,
            DETAILED_ERROR_MESSAGE,
            logOwnerId,
            sourceId,
            storeAccountId
        );
        logMessageEntryInstance.logType = LogEntry.LogCategory.BUSINESS_ERROR.name();
        logMessageEntryInstance.sendNotification = true;
        LogCreationEntry logCreationEntryInstance = new LogCreationEntry(
            WORK_ORDERS_CREATION_SERVICE_CLASS_NAME,
            WORK_ORDERS_CREATION_SERVICE_METHOD_NAME,
            new List<LogMessageEntry>{ logMessageEntryInstance }
        );
        events.add(
            new Notifier__e(
                Topic__c = EVENT_TOPIC_WORK_ORDER_STORES_CALCULATION,
                Payload__c = JSON.serialize(logCreationEntryInstance)
            )
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        LogsService.execute(events);
        Test.stopTest();
        // Verifying Commit work as 0 since logs are not created
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }
}