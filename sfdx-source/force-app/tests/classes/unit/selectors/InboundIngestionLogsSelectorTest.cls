/**
 * @author Deloitte
 * @date 05/15/2024
 * @description Test class for InboundIngestionLogsSelector class.
 */
@isTest(SeeAllData=false)
public class InboundIngestionLogsSelectorTest {
    private static final String MISMATCH_IN_NUMBER_OF_LOGS_ASSERT_MESSAGE = 'Unexpected result: the number of logs returned do not match the expected number of logs';
    private static final String EMPTY_LIST_ASSERT_MESSAGE = 'Unexpected result: number of records returned does not match the expected outcome.';
    private static final String FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: mismatch in field list.';
    private static final String OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: The object type must be Business_Vertical__c.';
    private static final String INGESTION_LOG_PAYLOAD = '{"Mx Store Name":"KFC"}';
    private static final String INGESTION_LOG_STATUS_PENDING = 'Pending';
    private static final String PARENT_INGESTION_LOG_UUID = 'k123484c-595d-1567-99d8-3d8c931d9f82';
    private static final String INGESTION_LOG_UUID = 'h123456c-595d-1234-99d8-3d8c931d9f82';
    private static final String STATUS_COMPLETED = 'Completed';
    private static final String STATUS_FAILED = 'Failed';
    private static final String SOURCE_RESSMO = 'RESSMO';
    private static final String BUSINESS_ID = '12345';
    private static final String INTEGRATION_TYPE_FALLOUT_EVENT = 'Fallout event';

    /**
     * @description To test Contructor instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCheckSObjectTypeAndFieldList() {
        InboundIngestionLogsSelector inboundIngestionLogssSelectorInstance = (InboundIngestionLogsSelector) InboundIngestionLogsSelector.newInstance();
        Schema.SObjectType typeOfObject = inboundIngestionLogssSelectorInstance.getSObjectType();
        List<Schema.SObjectField> sObjectFields = inboundIngestionLogssSelectorInstance.getSObjectFieldList();
        System.assertEquals(
            Schema.Inbound_Ingestion_Log__c.SObjectType,
            typeOfObject,
            OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
                Inbound_Ingestion_Log__c.Id,
                Inbound_Ingestion_Log__c.Failure_Step__c,
                Inbound_Ingestion_Log__c.Parent_Log__c,
                Inbound_Ingestion_Log__c.Payload__c,
                Inbound_Ingestion_Log__c.Status__c,
                Inbound_Ingestion_Log__c.UUID__c,
                Inbound_Ingestion_Log__c.Source__c,
                Inbound_Ingestion_Log__c.Integration_Type__c,
                Inbound_Ingestion_Log__c.Unique_Id__c,
                Inbound_Ingestion_Log__c.Internal_Payload_For_Retry__c
            },
            sObjectFields,
            FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description It is used to test that Inbound Ingestion Logs are queried based
     * on the Inbound Ingestion Logs Ids passed.
     */
    @isTest
    public static void testWhenInboundIngestionLogIdsPassedThenInboundIngestionLogsReturned() {
        Inbound_Ingestion_Log__c inboundIngestionLog = new Inbound_Ingestion_Log__c(
            Payload__c = INGESTION_LOG_PAYLOAD,
            Status__c = INGESTION_LOG_STATUS_PENDING,
            UUID__c = INGESTION_LOG_UUID
        );
        insert inboundIngestionLog;
        Test.startTest();
        List<Inbound_Ingestion_Log__c> inboundIngestionLogs = InboundIngestionLogsSelector.newInstance()
            .selectById(new Set<Id>{ inboundIngestionLog.Id });
        Test.stopTest();
        System.assertEquals(
            1,
            inboundIngestionLogs.size(),
            MISMATCH_IN_NUMBER_OF_LOGS_ASSERT_MESSAGE
        );
    }

    /**
     * @description It is used to test that Inbound Ingestion Logs are not queried
     * when no Inbound Ingestion Logs Ids passed.
     */
    @isTest
    public static void testWhenNoInboundIngestionLogIdsPassedThenInboundIngestionLogsNotReturned() {
        Inbound_Ingestion_Log__c inboundIngestionLog = new Inbound_Ingestion_Log__c(
            Payload__c = INGESTION_LOG_PAYLOAD,
            Status__c = INGESTION_LOG_STATUS_PENDING,
            UUID__c = INGESTION_LOG_UUID
        );
        insert inboundIngestionLog;
        Test.startTest();
        List<Inbound_Ingestion_Log__c> inboundIngestionLogs = InboundIngestionLogsSelector.newInstance()
            .selectById(new Set<Id>{});
        Test.stopTest();
        System.assertEquals(0, inboundIngestionLogs.size(), EMPTY_LIST_ASSERT_MESSAGE);
    }

    /**
     * @description To test whether expected parent inbound ingestion log records
     * are returned.
     */
    @isTest
    private static void testWhenUUIDsPassedThenReturnParentInboundIngestionLogs() {
        Inbound_Ingestion_Log__c parentInboundIngestionLog = new Inbound_Ingestion_Log__c(
            Payload__c = INGESTION_LOG_PAYLOAD,
            Status__c = INGESTION_LOG_STATUS_PENDING,
            UUID__c = INGESTION_LOG_UUID
        );
        insert parentInboundIngestionLog;
        Inbound_Ingestion_Log__c childInboundIngestionLog = new Inbound_Ingestion_Log__c(
            Payload__c = INGESTION_LOG_PAYLOAD,
            Status__c = INGESTION_LOG_STATUS_PENDING,
            UUID__c = INGESTION_LOG_UUID,
            Parent_Log__c = parentInboundIngestionLog.Id
        );
        insert childInboundIngestionLog;
        Test.startTest();
        List<Inbound_Ingestion_Log__c> inboundIngestionLogs = InboundIngestionLogsSelector.newInstance()
            .selectParentInboundIngestionLogsByUUIDs(
                new Set<String>{ parentInboundIngestionLog.UUID__c }
            );
        Test.stopTest();
        System.assertEquals(
            1,
            inboundIngestionLogs.size(),
            MISMATCH_IN_NUMBER_OF_LOGS_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test when child UUID passed then parent inbound ingestion
     * logs not returned.
     */
    @isTest
    private static void testWhenChildUUIDsPassedThenParentInboundIngestionLogsNotReturned() {
        Inbound_Ingestion_Log__c parentInboundIngestionLog = new Inbound_Ingestion_Log__c(
            Payload__c = INGESTION_LOG_PAYLOAD,
            Status__c = INGESTION_LOG_STATUS_PENDING,
            UUID__c = PARENT_INGESTION_LOG_UUID
        );
        insert parentInboundIngestionLog;
        Inbound_Ingestion_Log__c childInboundIngestionLog = new Inbound_Ingestion_Log__c(
            Payload__c = INGESTION_LOG_PAYLOAD,
            Status__c = INGESTION_LOG_STATUS_PENDING,
            UUID__c = INGESTION_LOG_UUID,
            Parent_Log__c = parentInboundIngestionLog.Id
        );
        insert childInboundIngestionLog;
        Test.startTest();
        List<Inbound_Ingestion_Log__c> inboundIngestionLogs = InboundIngestionLogsSelector.newInstance()
            .selectParentInboundIngestionLogsByUUIDs(
                new Set<String>{ childInboundIngestionLog.UUID__c }
            );
        Test.stopTest();
        System.assertEquals(0, inboundIngestionLogs.size(), EMPTY_LIST_ASSERT_MESSAGE);
    }

    /**
     * @description To test when the SSMO process is completed or failed update Inbound Ingestion Logs Status.
     * Suppressed Warnings since mock verify method does not require system assert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenProcessCompletedOrFailedThenUpdateInboundIngestionLogsStatus() {
        Id inboundIngestionLogId = fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType);
        Inbound_Ingestion_Log__c log = new Inbound_Ingestion_Log__c(
            Id = inboundIngestionLogId,
            Payload__c = INGESTION_LOG_PAYLOAD,
            Status__c = INGESTION_LOG_STATUS_PENDING,
            UUID__c = INGESTION_LOG_UUID
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IInboundIngestionLogsSelector inboundIngestionLogsSelectorMock = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IInboundIngestionLogs inboundIngestionMock = (IInboundIngestionLogs) mocks.mock(
            IInboundIngestionLogs.class
        );
        inboundIngestionMock.updateIngestionLogsWithSucessOrFailureStatus(
            new Set<Id>{ inboundIngestionLogId },
            STATUS_COMPLETED,
            '',
            '',
            ''
        );
        mocks.startStubbing();
        mocks.when(inboundIngestionLogsSelectorMock.sObjectType())
            .thenReturn(Inbound_Ingestion_Log__c.SObjectType);
        mocks.when(
                inboundIngestionLogsSelectorMock.selectById(new Set<Id>{ inboundIngestionLogId })
            )
            .thenReturn(new List<Inbound_Ingestion_Log__c>{ log });
        mocks.stopStubbing();
        Application.DOMAIN.setMock(inboundIngestionMock);
        Application.UNITOFWORK.setMock(mockUOW);
        ((IInboundIngestionLogs) mocks.verify(inboundIngestionMock, 1))
            .updateIngestionLogsWithSucessOrFailureStatus(
                new Set<Id>{ inboundIngestionLogId },
                STATUS_COMPLETED,
                '',
                '',
                ''
            );
    }

    /**
     * @description It is used to test that Inbound Ingestion Logs are queried based on the
     * unique identifier passed.
     */
    @isTest
    private static void testWhenUniqueIdentifierPassedThenReturnParentInboundIngestionLogs() {
        Inbound_Ingestion_Log__c inboundIngestionLogRecord = new Inbound_Ingestion_Log__c(
            Payload__c = INGESTION_LOG_PAYLOAD,
            Status__c = INGESTION_LOG_STATUS_PENDING,
            UUID__c = INGESTION_LOG_UUID,
            Integration_Type__c = INTEGRATION_TYPE_FALLOUT_EVENT
        );
        insert inboundIngestionLogRecord;
        Test.startTest();
        List<Inbound_Ingestion_Log__c> inboundIngestionLogs = InboundIngestionLogsSelector.newInstance()
            .selectInboundIngestionLogsByUniqueIdentifiers(
                new Set<String>{ INTEGRATION_TYPE_FALLOUT_EVENT },
                new Set<String>{ INGESTION_LOG_UUID }
            );
        Test.stopTest();
        System.assertEquals(1, inboundIngestionLogs.size(), EMPTY_LIST_ASSERT_MESSAGE);
    }

    /**
     * @description It is used to test that no Inbound Ingestion Logs are returned based
     * on the different unique identifier passed.
     */
    @isTest
    private static void testWhenDifferentUniqueIdentifierPassedThenReturnsNoParentInboundIngestionLogs() {
        Inbound_Ingestion_Log__c inboundIngestionLogRecord = new Inbound_Ingestion_Log__c(
            Payload__c = INGESTION_LOG_PAYLOAD,
            Status__c = INGESTION_LOG_STATUS_PENDING,
            UUID__c = PARENT_INGESTION_LOG_UUID,
            Integration_Type__c = INTEGRATION_TYPE_FALLOUT_EVENT
        );
        insert inboundIngestionLogRecord;
        Test.startTest();
        List<Inbound_Ingestion_Log__c> inboundIngestionLogs = InboundIngestionLogsSelector.newInstance()
            .selectInboundIngestionLogsByUniqueIdentifiers(
                new Set<String>{ INTEGRATION_TYPE_FALLOUT_EVENT },
                new Set<String>{ INGESTION_LOG_UUID }
            );
        Test.stopTest();
        System.assertEquals(0, inboundIngestionLogs.size(), EMPTY_LIST_ASSERT_MESSAGE);
    }

    /**
     * @description It is used to test that Inbound Ingestion Logs are queried based on the
     * unique identifier passed.
     */
    @isTest
    private static void testWhenUniqueIdentifierPassedThenReturnsInboundIngestionLogs() {
        Inbound_Ingestion_Log__c parentInboundIngestionLog = new Inbound_Ingestion_Log__c(
            Payload__c = INGESTION_LOG_PAYLOAD,
            Status__c = INGESTION_LOG_STATUS_PENDING,
            UUID__c = INGESTION_LOG_UUID,
            Integration_Type__c = INTEGRATION_TYPE_FALLOUT_EVENT
        );
        insert parentInboundIngestionLog;
        Inbound_Ingestion_Log__c inboundIngestionLog = new Inbound_Ingestion_Log__c(
            Payload__c = INGESTION_LOG_PAYLOAD,
            Status__c = INGESTION_LOG_STATUS_PENDING,
            UUID__c = INGESTION_LOG_UUID,
            Integration_Type__c = INTEGRATION_TYPE_FALLOUT_EVENT,
            Parent_Log__c = parentInboundIngestionLog.Id
        );
        insert inboundIngestionLog;
        Test.startTest();
        List<Inbound_Ingestion_Log__c> inboundIngestionLogs = InboundIngestionLogsSelector.newInstance()
            .selectInboundIngestionLogsByUUIDsAndIntegrationTypes(
                new Set<String>{ INTEGRATION_TYPE_FALLOUT_EVENT },
                new Set<String>{ INGESTION_LOG_UUID }
            );
        Test.stopTest();
        System.assertEquals(
            3,
            inboundIngestionLogs.size(),
            MISMATCH_IN_NUMBER_OF_LOGS_ASSERT_MESSAGE
        );
    }

    /**
     * @description It is used to test that no Inbound Ingestion Logs are returned based
     * on the different unique identifier passed.
     */
    @isTest
    private static void testWhenDifferentUniqueIdentifierPassedThenNoInboundIngestionLogsReturned() {
        Inbound_Ingestion_Log__c parentInboundIngestionLog = new Inbound_Ingestion_Log__c(
            Payload__c = INGESTION_LOG_PAYLOAD,
            Status__c = INGESTION_LOG_STATUS_PENDING,
            UUID__c = PARENT_INGESTION_LOG_UUID,
            Integration_Type__c = INTEGRATION_TYPE_FALLOUT_EVENT
        );
        insert parentInboundIngestionLog;
        Inbound_Ingestion_Log__c inboundIngestionLog = new Inbound_Ingestion_Log__c(
            Payload__c = INGESTION_LOG_PAYLOAD,
            Status__c = INGESTION_LOG_STATUS_PENDING,
            UUID__c = PARENT_INGESTION_LOG_UUID,
            Integration_Type__c = INTEGRATION_TYPE_FALLOUT_EVENT,
            Parent_Log__c = parentInboundIngestionLog.Id
        );
        insert inboundIngestionLog;
        Test.startTest();
        List<Inbound_Ingestion_Log__c> inboundIngestionLogs = InboundIngestionLogsSelector.newInstance()
            .selectInboundIngestionLogsByUUIDsAndIntegrationTypes(
                new Set<String>{ INTEGRATION_TYPE_FALLOUT_EVENT },
                new Set<String>{ INGESTION_LOG_UUID }
            );
        Test.stopTest();
        System.assertEquals(0, inboundIngestionLogs.size(), EMPTY_LIST_ASSERT_MESSAGE);
    }

    /**
     * @description It is used to test that Inbound Ingestion Logs are queried based on the UUIds passed.
     */
    @isTest
    private static void testWhenUUIdsPassedThenInboundIngestionLogsReturned() {
        Inbound_Ingestion_Log__c inboundIngestionLogRecord = new Inbound_Ingestion_Log__c(
            Payload__c = '{"Mx Store Name":"KFC"}',
            Status__c = 'Pending',
            UUID__c = INGESTION_LOG_UUID
        );
        insert inboundIngestionLogRecord;
        Test.startTest();
        List<Inbound_Ingestion_Log__c> inboundIngestionLogs = InboundIngestionLogsSelector.newInstance()
            .selectInboundIngestionLogsByUUIDs(new Set<String>{ INGESTION_LOG_UUID });
        Test.stopTest();
        System.assertEquals(1, inboundIngestionLogs.size(), EMPTY_LIST_ASSERT_MESSAGE);
    }

    /**
     * @description It is used to test that Child Onboarding Inbound Ingestion Logs are queried based on the UUIds passed.
     */
    @isTest
    private static void testWhenUUIdsPassedThenOnboardingInboundIngestionLogsReturned() {
        Inbound_Ingestion_Log__c inboundIngestionLogFalloutRecord = new Inbound_Ingestion_Log__c(
            Payload__c = '{"Mx Store fallout":"KFC"}',
            Status__c = 'Pending',
            UUID__c = INGESTION_LOG_UUID,
            Integration_Type__c = 'Fallout event'
        );
        insert inboundIngestionLogFalloutRecord;
        Inbound_Ingestion_Log__c inboundIngestionLogOnboardingRecord = new Inbound_Ingestion_Log__c(
            Payload__c = '{"Mx Store Onboarding":"KFC"}',
            Status__c = 'Pending',
            UUID__c = INGESTION_LOG_UUID,
            Integration_Type__c = 'Onboarding Event',
            Parent_Log__c = inboundIngestionLogFalloutRecord.Id
        );
        insert inboundIngestionLogOnboardingRecord;
        Test.startTest();
        List<Inbound_Ingestion_Log__c> inboundIngestionLogs = InboundIngestionLogsSelector.newInstance()
            .selectInboundIngestionLogsByUUIDs(new Set<String>{ INGESTION_LOG_UUID });
        Test.stopTest();
        System.assertEquals(1, inboundIngestionLogs.size(), EMPTY_LIST_ASSERT_MESSAGE);
    }

    /**
     * @description It is used to test that Inbound Ingestion Logs are queried based on the UUIds passed.
     */
    @isTest
    public static void testWhenSelectFailedIngestionLogsByBizIdsThenReturnFailedIIL() {
        List<Inbound_Ingestion_Log__c> iils = new List<Inbound_Ingestion_Log__c>();
        Inbound_Ingestion_Log__c inboundIngestionLogRecord = new Inbound_Ingestion_Log__c(
            Payload__c = '{"Mx Store Name":"KFC", "business":{"businessId":"' + BUSINESS_ID + '"}}',
            Status__c = STATUS_FAILED,
            UUID__c = INGESTION_LOG_UUID,
            Source__c = SOURCE_RESSMO,
            Business_Id__c = BUSINESS_ID
        );
        iils.add(inboundIngestionLogRecord);
        Inbound_Ingestion_Log__c inboundIngestionLogRecord2 = new Inbound_Ingestion_Log__c(
            Payload__c = '{"Mx Store Name":"KFC", "business":{"businessId":"' + BUSINESS_ID + '"}}',
            Status__c = STATUS_COMPLETED,
            UUID__c = INGESTION_LOG_UUID,
            Source__c = SOURCE_RESSMO,
            Business_Id__c = BUSINESS_ID
        );
        iils.add(inboundIngestionLogRecord2);
        insert iils;
        Test.startTest();
        List<Inbound_Ingestion_Log__c> inboundIngestionLogs = InboundIngestionLogsSelector.newInstance()
            .selectFailedIngestionLogsByBizIds(new Set<String>{ BUSINESS_ID });
        Test.stopTest();
        Assert.areEqual(1, inboundIngestionLogs.size(), EMPTY_LIST_ASSERT_MESSAGE);
        Assert.areEqual(
            inboundIngestionLogRecord.Id,
            inboundIngestionLogs[0].Id,
            'Not a expected Id'
        );
    }

    @isTest
    private static void testWhenSelectByUUIDAndGivenStatusThenReturnValidLogs() {
        List<Inbound_Ingestion_Log__c> iils = new List<Inbound_Ingestion_Log__c>();
        Inbound_Ingestion_Log__c inboundIngestionLogRecord = new Inbound_Ingestion_Log__c(
            Payload__c = '{"Mx Store Name":"KFC", "business":{"businessId":"' + BUSINESS_ID + '"}}',
            Status__c = STATUS_FAILED,
            UUID__c = INGESTION_LOG_UUID,
            Source__c = SOURCE_RESSMO,
            Business_Id__c = BUSINESS_ID
        );
        iils.add(inboundIngestionLogRecord);
        Inbound_Ingestion_Log__c inboundIngestionLogRecord2 = new Inbound_Ingestion_Log__c(
            Payload__c = '{"Mx Store Name":"KFC", "business":{"businessId":"' + BUSINESS_ID + '"}}',
            Status__c = STATUS_COMPLETED,
            UUID__c = INGESTION_LOG_UUID + '1',
            Source__c = SOURCE_RESSMO,
            Business_Id__c = BUSINESS_ID
        );
        iils.add(inboundIngestionLogRecord2);
        insert iils;

        Test.startTest();
        List<Inbound_Ingestion_Log__c> inboundIngestionLogs = InboundIngestionLogsSelector.newInstance()
            .selectByUUIDStatusSource(
                new Set<String>{ INGESTION_LOG_UUID },
                new Set<String>{ STATUS_COMPLETED },
                SOURCE_RESSMO
            );

        List<Inbound_Ingestion_Log__c> inboundIngestionLogsOne = InboundIngestionLogsSelector.newInstance()
            .selectByUUIDStatusSource(
                new Set<String>{ INGESTION_LOG_UUID },
                new Set<String>{ STATUS_FAILED },
                SOURCE_RESSMO
            );
        Test.stopTest();
        Assert.areEqual(0, inboundIngestionLogs.size(), EMPTY_LIST_ASSERT_MESSAGE);
        Assert.areEqual(1, inboundIngestionLogsOne.size(), EMPTY_LIST_ASSERT_MESSAGE);
        Assert.areEqual(
            inboundIngestionLogRecord.Id,
            inboundIngestionLogsOne[0].Id,
            'Not a expected Id'
        );
    }

    /**
     * @description It is used to test that Inbound Ingestion Logs are queried based on
     * Failed Status and Retry Count less than three.
     */
    @isTest
    private static void testWhenFailedStatusThenInboundIngestionLogsReturned() {
        Test.startTest();
        Database.QueryLocator queryLocatorRecord = InboundIngestionLogsSelector.newInstance()
            .selectFailedIngestionLogs();
        Test.stopTest();
        System.assertNotEquals(null, queryLocatorRecord, EMPTY_LIST_ASSERT_MESSAGE);
    }

    /**
     * @description It is used to test that Inbound Ingestion Logs are queried based on the source and integration type passed.
     */
    @isTest
    private static void testWhenSourceAndIntegrationPassedThenInboundIngestionLogsReturned() {
        Inbound_Ingestion_Log__c inboundIngestionLogOnboardingRecord = new Inbound_Ingestion_Log__c(
            Payload__c = '{"Mx Store fallout":"KFC"}',
            Status__c = 'Success',
            UUID__c = INGESTION_LOG_UUID,
            Integration_Type__c = 'Onboarding Event',
            Source__c = 'SSMO'
        );
        insert inboundIngestionLogOnboardingRecord;
        Inbound_Ingestion_Log__c fetchedIIL = new Inbound_Ingestion_Log__c();

        Test.startTest();
        Database.QueryLocator inboundIngestionLogs = InboundIngestionLogsSelector.newInstance()
            .selectSuccessIngestionLogsWithSSMOSourceORMxPortalNSEIntegrationType();
        Database.QueryLocatorIterator iteratorOnIIL = inboundIngestionLogs.iterator();

        while (iteratorOnIIL.hasNext()) {
            fetchedIIL = (Inbound_Ingestion_Log__c) iteratorOnIIL.next();
        }

        Test.stopTest();
        System.assertEquals(
            inboundIngestionLogOnboardingRecord.Id,
            fetchedIIL.Id,
            EMPTY_LIST_ASSERT_MESSAGE
        );
    }
    /**
     * @description It is used to test that Inbound Ingestion Logs are not queried based on the incorrect source and integration type passed.
     */
    @isTest
    private static void testWhenIncorrectSourceAndIntegrationPassedThenNoInboundIngestionLogsReturned() {
        Inbound_Ingestion_Log__c inboundIngestionLogOnboardingRecord = new Inbound_Ingestion_Log__c(
            Payload__c = '{"Mx Store fallout":"KFC"}',
            Status__c = 'Success',
            UUID__c = INGESTION_LOG_UUID,
            Integration_Type__c = 'Mx Portal Ads & Promos',
            Source__c = 'Mx Portal'
        );
        insert inboundIngestionLogOnboardingRecord;
        Inbound_Ingestion_Log__c fetchedIIL = new Inbound_Ingestion_Log__c();

        Test.startTest();
        Database.QueryLocator inboundIngestionLogs = InboundIngestionLogsSelector.newInstance()
            .selectSuccessIngestionLogsWithSSMOSourceORMxPortalNSEIntegrationType();
        Database.QueryLocatorIterator iteratorOnIIL = inboundIngestionLogs.iterator();

        while (iteratorOnIIL.hasNext()) {
            fetchedIIL = (Inbound_Ingestion_Log__c) iteratorOnIIL.next();
        }

        Test.stopTest();
        System.assertEquals(null, fetchedIIL.Id, EMPTY_LIST_ASSERT_MESSAGE);
    }
}