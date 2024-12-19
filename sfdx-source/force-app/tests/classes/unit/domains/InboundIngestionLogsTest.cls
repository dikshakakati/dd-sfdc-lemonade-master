/**
 * @author Deloitte
 * @date 05/15/2024
 * @description Test class for InboundIngestionLogs class
 */

@isTest(SeeAllData=false)
private class InboundIngestionLogsTest {
    private static final String ASSERT_MESSAGE_PARENT_MISMATCH = 'Unexpected result: parent record not updated correctly.';
    private static final String ASSERT_MESSAGE_STATUS_MISMATCH = 'Unexpected result: status not updated correctly.';
    private static final String COMPLETED_SSMO_UUID = 'a192876c-595d-4891-87d8-3d8c931d9f82';
    private static final String EVENT_TOPIC_ACCOUNT_RECORD_UPDATE_BY_INGESTION_ONBOARDING_PAYLOAD = 'EVENT_TOPIC_ACCOUNT_RECORD_UPDATE_BY_INGESTION_ONBOARDING_PAYLOAD';
    private static final String EVENT_TOPIC_FOR_SSMO_FALLOUT_RECORDS_CREATION = 'EVENT_TOPIC_FOR_SSMO_FALLOUT_RECORDS_CREATION';
    private static final String EVENT_TOPIC_FOR_SSMO_ONBOARDING_RECORDS_CREATION = 'EVENT_TOPIC_FOR_SSMO_ONBOARDING_RECORDS_CREATION';
    private static final String EXCEPTION_MESSAGE = 'Test Exception Message';
    private static final String FALLOUT_EVENT = 'Fallout event';
    private static final String ONBOARDING_EVENT = 'Onboarding Event';
    private static final String PAYLOAD = '{"Mx Store Name":"Subway"}';
    private static final String BUSINESS_ID_PAYLOAD = '{"business": {"businessId": "12820285"}}';
    private static final String REJECTED_PAYLOAD = '{"store":{"addressVerificationInfo":{"addressVerificationStatus":"Rejected"}}}';
    private static final String STATUS_COMPLETED = 'Completed';
    private static final String STATUS_PENDING = 'Pending';
    private static final String STATUS_SKIPPED = 'Skipped';
    private static final String STATUS_SUCCESS = 'Success';
    private static final String STATUS_REJECTED = 'Rejected';
    private static final String STATUS_DUPLICATE = 'Duplicate';
    private static final String SSMO_UUID = 'a123456c-595d-4891-99d8-3d8c931d9f82';
    private static final String SUCCESS_MESSAGE = 'Fallout event has been completed successfully';
    private static final String ERROR_MESSAGE = 'Encountered error while processing.';
    private static final STRING STACK_TRACE = 'Error occured at Line no 10.';
    private static final STRING BUSINESS_ERROR_MESSAGE = 'Fallout event is failed.';
    private static final String STATUS_FAILED = 'Failed';
    private static final String EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD = 'EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD';
    private static final String STATIC_RESOURCE_TEST_JSON = 'Inbound_Ingestion_Payload_Data';
    private static final String MX_PORTAL_NSE_EVENT = 'Mx Portal New Store Expansion';
    private static final String SSMO = 'SSMO';
    private static final String SOURCE_RESSMO = 'RESSMO';
    private static final String BUSINESS_ID = '12820285';
    private static final String SSMO_UNIQUE_ID = 'ad43456c-595d-4891-99d8-3d8c931d9f82';

    /**
     * @description It is used to test when onboarding inbound ingestion inboundIngestionLogs
     * are inserted then SSMO record creations are initiated or not.
     * Suppressed Warnings since mock verify method does not require system assert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOnboardingInboundIngestionLogsInsertedThenSSMOFalloutRecordsCreationInitiated() {
        Id inboundIngestionLogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Fake inboundIngestionLogRecords = new Fake(Inbound_Ingestion_Log__c.class)
            .setField(Inbound_Ingestion_Log__c.Id, inboundIngestionLogId)
            .setField(Inbound_Ingestion_Log__c.Payload__c, PAYLOAD)
            .setField(Inbound_Ingestion_Log__c.Integration_Type__c, ONBOARDING_EVENT)
            .setField(Inbound_Ingestion_Log__c.UUID__c, SSMO_UUID);
        Inbound_Ingestion_Log__c newInboundIngestionLog = (Inbound_Ingestion_Log__c) inboundIngestionLogRecords.toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IInboundIngestionLogs inboundIngestionLogsMock = (IInboundIngestionLogs) mocks.mock(
            IInboundIngestionLogs.class
        );
        IInstantIngestorEventsService instantIngestorEventsServiceMock = (IInstantIngestorEventsService) mocks.mock(
            IInstantIngestorEventsService.class
        );
        IInboundIngestionLogsSelector selectorMock = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Inbound_Ingestion_Log__c.SObjectType);
        mocks.when(
                selectorMock.selectInboundIngestionLogsByUUIDsAndIntegrationTypes(
                    new Set<String>{ FALLOUT_EVENT },
                    new Set<String>{ SSMO_UUID }
                )
            )
            .thenReturn(new List<Inbound_Ingestion_Log__c>());
        mocks.stopStubbing();
        Application.Domain.setMock(inboundIngestionLogsMock);
        Application.SERVICE.setMock(
            IInstantIngestorEventsService.class,
            instantIngestorEventsServiceMock
        );
        Application.SELECTOR.setMock(selectorMock);
        Test.startTest();
        InboundIngestionLogs.newInstance(
                new List<Inbound_Ingestion_Log__c>{ newInboundIngestionLog }
            )
            .initiateSSMOOnboardingRecordsCreation(
                EVENT_TOPIC_FOR_SSMO_ONBOARDING_RECORDS_CREATION
            );
        Test.stopTest();
        ((IInstantIngestorEventsService) mocks.verify(instantIngestorEventsServiceMock, 1))
            .publishBulkEvents(
                new Map<String, List<String>>{
                    EVENT_TOPIC_FOR_SSMO_ONBOARDING_RECORDS_CREATION => NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                        new Set<Id>{ newInboundIngestionLog.Id },
                        1
                    )
                },
                PreSalesTransaction__e.SObjectType
            );
    }

    /**
     * @description It is used to test when fallout inbound ingestion logs are inserted then
     * SSMO fallout record creations are initiated or not.
     * Suppressed Warnings since mock verify method does not require system assert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenFalloutInboundIngestionLogsInsertedThenSSMOFalloutRecordsCreationInitiated() {
        Id inboundIngestionLogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id parentInboundIngestionLogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Fake inboundIngestionLogRecords = new Fake(Inbound_Ingestion_Log__c.class)
            .setField(Inbound_Ingestion_Log__c.Id, inboundIngestionLogId)
            .setField(Inbound_Ingestion_Log__c.Payload__c, PAYLOAD)
            .setField(Inbound_Ingestion_Log__c.Integration_Type__c, FALLOUT_EVENT)
            .setField(Inbound_Ingestion_Log__c.Parent_Log__c, parentInboundIngestionLogId)
            .setParent(
                'Parent_Log__r',
                new Fake(Inbound_Ingestion_Log__c.class)
                    .setField(Inbound_Ingestion_Log__c.Id, parentInboundIngestionLogId)
            );
        Inbound_Ingestion_Log__c newInboundIngestionLog = (Inbound_Ingestion_Log__c) inboundIngestionLogRecords.toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IInboundIngestionLogs inboundIngestionLogsMock = (IInboundIngestionLogs) mocks.mock(
            IInboundIngestionLogs.class
        );
        INonInstantIngestorEventsService nonInstantIngestorEventsServiceMock = (INonInstantIngestorEventsService) mocks.mock(
            INonInstantIngestorEventsService.class
        );
        Application.Domain.setMock(inboundIngestionLogsMock);
        Application.SERVICE.setMock(
            INonInstantIngestorEventsService.class,
            nonInstantIngestorEventsServiceMock
        );
        Test.startTest();
        InboundIngestionLogs.newInstance(
                new List<Inbound_Ingestion_Log__c>{ newInboundIngestionLog }
            )
            .initiateSSMOFalloutRecordsCreation(EVENT_TOPIC_FOR_SSMO_FALLOUT_RECORDS_CREATION);
        Test.stopTest();
        ((INonInstantIngestorEventsService) mocks.verify(nonInstantIngestorEventsServiceMock, 1))
            .publishBulkEvents(
                new Map<String, List<String>>{
                    EVENT_TOPIC_FOR_SSMO_FALLOUT_RECORDS_CREATION => new List<String>{
                        JSON.serialize(new List<Id>{ inboundIngestionLogId })
                    }
                }
            );
    }

    /**
     * @description It is used to test when invalid inbound ingestion logs are inserted then SSMO
     * record creations are not initiated.
     * Suppressed Warnings since mock verify method does not require system assert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenInvalidInboundIngestionLogsInsertedThenSSMOFalloutRecordsCreationNotInitiated() {
        Id inboundIngestionLogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Fake inboundIngestionLogRecords = new Fake(Inbound_Ingestion_Log__c.class)
            .setField(Inbound_Ingestion_Log__c.Id, inboundIngestionLogId)
            .setField(Inbound_Ingestion_Log__c.Payload__c, PAYLOAD)
            .setField(Inbound_Ingestion_Log__c.Integration_Type__c, null);
        Inbound_Ingestion_Log__c newInboundIngestionLog = (Inbound_Ingestion_Log__c) inboundIngestionLogRecords.toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IInboundIngestionLogs inboundIngestionLogsMock = (IInboundIngestionLogs) mocks.mock(
            IInboundIngestionLogs.class
        );
        INonInstantIngestorEventsService nonInstantIngestorEventsServiceMock = (INonInstantIngestorEventsService) mocks.mock(
            INonInstantIngestorEventsService.class
        );
        Application.Domain.setMock(inboundIngestionLogsMock);
        Application.SERVICE.setMock(
            INonInstantIngestorEventsService.class,
            nonInstantIngestorEventsServiceMock
        );
        Test.startTest();
        InboundIngestionLogs.newInstance(
                new List<Inbound_Ingestion_Log__c>{ newInboundIngestionLog }
            )
            .initiateSSMOFalloutRecordsCreation(EVENT_TOPIC_FOR_SSMO_FALLOUT_RECORDS_CREATION);
        Test.stopTest();
        ((INonInstantIngestorEventsService) mocks.verify(nonInstantIngestorEventsServiceMock, 0))
            .publishEvents(
                new Map<String, String>{
                    EVENT_TOPIC_FOR_SSMO_FALLOUT_RECORDS_CREATION => JSON.serialize(
                        new List<Id>{ inboundIngestionLogId }
                    )
                }
            );
    }

    /**
     * @description To test parent id mapping in child inbound records
     */
    @isTest
    private static void testWhenChildInboundInsertedThenParentIdPopulated() {
        Id childInboundIngestionLogId = fflib_IDGenerator.generate(
            Inbound_Ingestion_Log__c.SObjectType
        );
        Id onboardingInboundIngestionLogId = fflib_IDGenerator.generate(
            Inbound_Ingestion_Log__c.SObjectType
        );
        Id parentInboundIngestionLogId = fflib_IDGenerator.generate(
            Inbound_Ingestion_Log__c.SObjectType
        );
        Inbound_Ingestion_Log__c onboardingInboundIngestionLog = new Inbound_Ingestion_Log__c(
            Id = onboardingInboundIngestionLogId,
            Integration_Type__c = ONBOARDING_EVENT,
            UUID__c = SSMO_UUID,
            Status__c = STATUS_COMPLETED
        );
        Inbound_Ingestion_Log__c parentInboundIngestionLog = new Inbound_Ingestion_Log__c(
            Id = parentInboundIngestionLogId,
            Integration_Type__c = FALLOUT_EVENT,
            UUID__c = SSMO_UUID,
            Status__c = STATUS_COMPLETED
        );
        Inbound_Ingestion_Log__c childInboundIngestionLog = new Inbound_Ingestion_Log__c(
            Id = childInboundIngestionLogId,
            Integration_Type__c = FALLOUT_EVENT,
            UUID__c = SSMO_UUID,
            Status__c = STATUS_PENDING
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IInboundIngestionLogsSelector selectorMock = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Inbound_Ingestion_Log__c.SObjectType);
        mocks.when(
                selectorMock.selectParentInboundIngestionLogsByUUIDs(new Set<String>{ SSMO_UUID })
            )
            .thenReturn(new List<Inbound_Ingestion_Log__c>{ parentInboundIngestionLog });
        mocks.when(
                selectorMock.selectInboundIngestionLogsByUUIDsAndIntegrationTypes(
                    new Set<String>{ FALLOUT_EVENT, ONBOARDING_EVENT, MX_PORTAL_NSE_EVENT },
                    new Set<String>{ SSMO_UUID }
                )
            )
            .thenReturn(
                new List<Inbound_Ingestion_Log__c>{
                    parentInboundIngestionLog,
                    onboardingInboundIngestionLog
                }
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        InboundIngestionLogs.newInstance(
                new List<Inbound_Ingestion_Log__c>{ childInboundIngestionLog }
            )
            .onBeforeInsertHandleFalloutIngestionLogs();
        System.assertEquals(
            parentInboundIngestionLog.Id,
            childInboundIngestionLog.Parent_Log__c,
            ASSERT_MESSAGE_PARENT_MISMATCH
        );
    }

    /**
     * @description Test method for InboundIngestionLogs.onBeforeInsertHandleRESSMOIngestionLogs
     * @author VenkateshDD | 10-04-2024
     **/
    @isTest
    private static void testWhenOnBeforeInsertHandleRESSMoIILRessmoThenAssignBusinessId() {
        Id ressmoOnboardingIIL = fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType);
        Inbound_Ingestion_Log__c onboardingInboundIngestionLog = new Inbound_Ingestion_Log__c(
            Id = ressmoOnboardingIIL,
            Integration_Type__c = ONBOARDING_EVENT,
            UUID__c = SSMO_UUID,
            Status__c = STATUS_COMPLETED,
            Source__c = SOURCE_RESSMO,
            Payload__c = BUSINESS_ID_PAYLOAD
        );
        Id nonRessmoOnboardingIIL = fflib_IDGenerator.generate(
            Inbound_Ingestion_Log__c.SObjectType
        );
        Inbound_Ingestion_Log__c onboardingInboundIngestionLog2 = new Inbound_Ingestion_Log__c(
            Id = nonRessmoOnboardingIIL,
            Integration_Type__c = ONBOARDING_EVENT,
            UUID__c = SSMO_UUID,
            Status__c = STATUS_COMPLETED,
            Source__c = SSMO,
            Payload__c = PAYLOAD
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IInboundIngestionLogsSelector selectorMock = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Inbound_Ingestion_Log__c.SObjectType);
        mocks.when(
                selectorMock.selectByUUIDStatusSource(
                    new Set<String>{ SSMO_UUID },
                    new Set<String>{
                        STATUS_PENDING,
                        STATUS_COMPLETED,
                        STATUS_SUCCESS,
                        STATUS_FAILED
                    },
                    SOURCE_RESSMO
                )
            )
            .thenReturn(new List<Inbound_Ingestion_Log__c>());
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);

        InboundIngestionLogs.newInstance(
                new List<Inbound_Ingestion_Log__c>{
                    onboardingInboundIngestionLog,
                    onboardingInboundIngestionLog2
                }
            )
            .onBeforeInsertHandleRESSMOIngestionLogs();
        Assert.areEqual(
            BUSINESS_ID,
            onboardingInboundIngestionLog.Business_Id__c,
            'Not expected business Id'
        );
        Assert.areEqual(
            null,
            onboardingInboundIngestionLog2.Business_Id__c,
            'Not expected business Id'
        );
    }

    /**
     * @description Test method for InboundIngestionLogs.onBeforeInsertHandleRESSMOIngestionLogs
     * @author VenkateshDD | 10-04-2024
     **/
    @isTest
    private static void testWhenOnBeforeInsertHandleRESSMoIILRessmoInvalidAddressThenMarkIILasRejected() {
        Id ressmoOnboardingIIL = fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType);
        Inbound_Ingestion_Log__c onboardingInboundIngestionLog = new Inbound_Ingestion_Log__c(
            Id = ressmoOnboardingIIL,
            Integration_Type__c = ONBOARDING_EVENT,
            UUID__c = SSMO_UUID,
            Status__c = STATUS_COMPLETED,
            Source__c = SOURCE_RESSMO,
            Payload__c = REJECTED_PAYLOAD
        );
        Id nonRessmoOnboardingIIL = fflib_IDGenerator.generate(
            Inbound_Ingestion_Log__c.SObjectType
        );
        Inbound_Ingestion_Log__c onboardingInboundIngestionLog2 = new Inbound_Ingestion_Log__c(
            Id = nonRessmoOnboardingIIL,
            Integration_Type__c = ONBOARDING_EVENT,
            UUID__c = SSMO_UUID,
            Status__c = STATUS_COMPLETED,
            Source__c = SSMO,
            Payload__c = PAYLOAD
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IInboundIngestionLogsSelector selectorMock = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Inbound_Ingestion_Log__c.SObjectType);
        mocks.when(
                selectorMock.selectByUUIDStatusSource(
                    new Set<String>{ SSMO_UUID },
                    new Set<String>{
                        STATUS_PENDING,
                        STATUS_COMPLETED,
                        STATUS_SUCCESS,
                        STATUS_FAILED
                    },
                    SOURCE_RESSMO
                )
            )
            .thenReturn(new List<Inbound_Ingestion_Log__c>());
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);

        InboundIngestionLogs.newInstance(
                new List<Inbound_Ingestion_Log__c>{
                    onboardingInboundIngestionLog,
                    onboardingInboundIngestionLog2
                }
            )
            .onBeforeInsertHandleRESSMOIngestionLogs();
        Assert.areEqual(
            STATUS_REJECTED,
            onboardingInboundIngestionLog.Status__c,
            'It should be rejected'
        );
    }

    /**
     * @description Test method for InboundIngestionLogs.onBeforeInsertHandleRESSMOIngestionLogs
     * @author VenkateshDD | 10-04-2024
     **/
    @isTest
    private static void testWhenOnBeforeInsertHandleRESSMoIILRessmoInvalidAddressThenMarkIILasDuplicate() {
        Id ressmoOnboardingIIL = fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType);
        Inbound_Ingestion_Log__c onboardingInboundIngestionLog = new Inbound_Ingestion_Log__c(
            Id = ressmoOnboardingIIL,
            Integration_Type__c = ONBOARDING_EVENT,
            UUID__c = SSMO_UUID,
            Status__c = STATUS_COMPLETED,
            Source__c = SOURCE_RESSMO,
            Payload__c = BUSINESS_ID_PAYLOAD
        );
        Id nonRessmoOnboardingIIL = fflib_IDGenerator.generate(
            Inbound_Ingestion_Log__c.SObjectType
        );
        Inbound_Ingestion_Log__c onboardingInboundIngestionLog2 = new Inbound_Ingestion_Log__c(
            Id = nonRessmoOnboardingIIL,
            Integration_Type__c = ONBOARDING_EVENT,
            UUID__c = SSMO_UUID,
            Status__c = STATUS_COMPLETED,
            Source__c = SSMO,
            Payload__c = PAYLOAD
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IInboundIngestionLogsSelector selectorMock = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Inbound_Ingestion_Log__c.SObjectType);
        mocks.when(
                selectorMock.selectByUUIDStatusSource(
                    new Set<String>{ SSMO_UUID },
                    new Set<String>{
                        STATUS_PENDING,
                        STATUS_COMPLETED,
                        STATUS_SUCCESS,
                        STATUS_FAILED
                    },
                    SOURCE_RESSMO
                )
            )
            .thenReturn(new List<Inbound_Ingestion_Log__c>{ onboardingInboundIngestionLog2 });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);

        InboundIngestionLogs.newInstance(
                new List<Inbound_Ingestion_Log__c>{
                    onboardingInboundIngestionLog,
                    onboardingInboundIngestionLog2
                }
            )
            .onBeforeInsertHandleRESSMOIngestionLogs();
        Assert.areEqual(
            STATUS_DUPLICATE,
            onboardingInboundIngestionLog.Status__c,
            'It should be rejected'
        );
    }

    /**
     * @description To test creation of child inbound ingestion log when UUID does not exist.
     * Suppressed Warnings since mock verify method does not require system assert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenChildInboundInsertedAndUuidDoNotExistThenCreateChildRecordAndParentIdPopulated() {
        Id parentInboundIngestionLogId = fflib_IDGenerator.generate(
            Inbound_Ingestion_Log__c.SObjectType
        );
        Inbound_Ingestion_Log__c parentInboundIngestionLog = new Inbound_Ingestion_Log__c(
            Id = parentInboundIngestionLogId,
            UUID__c = SSMO_UUID,
            Status__c = STATUS_COMPLETED,
            Integration_Type__c = FALLOUT_EVENT,
            Created_Date_Time__c = System.now().addDays(-1),
            Source__c = SSMO,
            Payload__c = PAYLOAD,
            Unique_Id__c = SSMO_UNIQUE_ID
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        InboundIngestionLogs.newInstance(
                new List<Inbound_Ingestion_Log__c>{ parentInboundIngestionLog }
            )
            .createParentAndChildRecordsWhenNoMatchingUUIDFound();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test parent id is not populated when there is no existing log record
     * with matching SSMO UUID.
     */
    @isTest
    private static void testWhenInboundIngestionLogInsertedWithNoMatchingUUIDThenParentIdNotPopulated() {
        Id childInboundIngestionLogId = fflib_IDGenerator.generate(
            Inbound_Ingestion_Log__c.SObjectType
        );
        Id onboardingInboundIngestionLogId = fflib_IDGenerator.generate(
            Inbound_Ingestion_Log__c.SObjectType
        );
        Inbound_Ingestion_Log__c onboardingInboundIngestionLog = new Inbound_Ingestion_Log__c(
            Id = onboardingInboundIngestionLogId,
            Integration_Type__c = ONBOARDING_EVENT,
            UUID__c = SSMO_UUID,
            Status__c = STATUS_PENDING
        );
        Inbound_Ingestion_Log__c inboundIngestionLog = new Inbound_Ingestion_Log__c(
            Id = childInboundIngestionLogId,
            Integration_Type__c = FALLOUT_EVENT,
            UUID__c = SSMO_UUID,
            Status__c = STATUS_PENDING
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IInboundIngestionLogsSelector selectorMock = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Inbound_Ingestion_Log__c.SObjectType);
        mocks.when(
                selectorMock.selectParentInboundIngestionLogsByUUIDs(new Set<String>{ SSMO_UUID })
            )
            .thenReturn(new List<Inbound_Ingestion_Log__c>());
        mocks.when(
                selectorMock.selectInboundIngestionLogsByUUIDsAndIntegrationTypes(
                    new Set<String>{ FALLOUT_EVENT, ONBOARDING_EVENT, MX_PORTAL_NSE_EVENT },
                    new Set<String>{ SSMO_UUID }
                )
            )
            .thenReturn(new List<Inbound_Ingestion_Log__c>());
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        InboundIngestionLogs.newInstance(
                new List<Inbound_Ingestion_Log__c>{
                    inboundIngestionLog,
                    onboardingInboundIngestionLog
                }
            )
            .onBeforeInsertHandleFalloutIngestionLogs();
        System.assertEquals(
            null,
            inboundIngestionLog.Parent_Log__c,
            ASSERT_MESSAGE_PARENT_MISMATCH
        );
        System.assertEquals(
            STATUS_SKIPPED,
            inboundIngestionLog.Status__c,
            ASSERT_MESSAGE_STATUS_MISMATCH
        );
    }

    /**
     * @description To test rollup of field values from child inbound to parent inbound.
     * Suppressed Warnings since mock verify method does not require system assert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenChildInboundUpdatedThenRollupToParentLog() {
        Id childInboundIngestionLogId = fflib_IDGenerator.generate(
            Inbound_Ingestion_Log__c.SObjectType
        );
        Id parentInboundIngestionLogId = fflib_IDGenerator.generate(
            Inbound_Ingestion_Log__c.SObjectType
        );
        Inbound_Ingestion_Log__c parentLog = new Inbound_Ingestion_Log__c(
            Id = parentInboundIngestionLogId,
            UUID__c = SSMO_UUID,
            Status__c = STATUS_COMPLETED
        );
        Inbound_Ingestion_Log__c childLog = (Inbound_Ingestion_Log__c) new Fake(
                Inbound_Ingestion_Log__c.class
            )
            .setField(Inbound_Ingestion_Log__c.Id, childInboundIngestionLogId)
            .setField(Inbound_Ingestion_Log__c.UUID__c, SSMO_UUID)
            .setField(Inbound_Ingestion_Log__c.Status__c, STATUS_PENDING)
            .setField(Inbound_Ingestion_Log__c.Parent_Log__c, parentInboundIngestionLogId)
            .setField(Inbound_ingestion_Log__c.Exception_Message__c, EXCEPTION_MESSAGE)
            .setField(Inbound_ingestion_Log__c.Business_Error_Message__c, BUSINESS_ERROR_MESSAGE)
            .setField(Inbound_ingestion_Log__c.Error_Message__c, ERROR_MESSAGE)
            .setParent(
                'Parent_Log__r',
                new Fake(Inbound_Ingestion_Log__c.class)
                    .setField(Inbound_Ingestion_Log__c.Id, parentLog.Id)
            )
            .toSObject();
        List<Inbound_Ingestion_Log__c> newInboundIngestionLogs = new List<Inbound_Ingestion_Log__c>{
            parentLog,
            childLog
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        InboundIngestionLogs.newInstance(newInboundIngestionLogs).rollupStatusAndErrorMessage();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Inbound_Ingestion_Log__c.Id => newInboundIngestionLogs[1].Parent_Log__c,
                            Inbound_ingestion_Log__c.Business_Error_Message__c => newInboundIngestionLogs[1]
                                .Business_Error_Message__c,
                            Inbound_Ingestion_Log__c.Error_Message__c => newInboundIngestionLogs[1]
                                .Error_Message__c,
                            Inbound_ingestion_Log__c.Exception_Message__c => newInboundIngestionLogs[1]
                                .Exception_Message__c,
                            Inbound_Ingestion_Log__c.Stack_Trace__c => newInboundIngestionLogs[1]
                                .Stack_Trace__c,
                            Inbound_Ingestion_Log__c.Status__c => newInboundIngestionLogs[1]
                                .Status__c,
                            Inbound_Ingestion_Log__c.Success_Message__c => newInboundIngestionLogs[1]
                                .Success_Message__c
                        }
                    }
                )
            );
    }

    /**
     * @description To test rollup of field values does not occur when there is no
     * parent associated on inbound ingestion log.
     * Suppressed Warnings since mock verify method does not require system assert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenInboundIngestionLogWithoutParentUpdatedThenDoNotRollupToParentLog() {
        Id inboundIngestionLogId = fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType);
        List<Inbound_Ingestion_Log__c> newInboundIngestionLogs = new List<Inbound_Ingestion_Log__c>{
            new Inbound_Ingestion_Log__c(
                Id = inboundIngestionLogId,
                UUID__c = SSMO_UUID,
                Status__c = STATUS_COMPLETED,
                Integration_Type__c = FALLOUT_EVENT,
                Parent_Log__c = null
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        InboundIngestionLogs.newInstance(newInboundIngestionLogs).rollupStatusAndErrorMessage();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description To test rollup of field values does not occur when there is no
     * parent associated on inbound ingestion log.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenInboundIngestionLogStatusUpdatedThenUpdateTheLogWithSuccessOrFailure() {
        Id inboundIngestionLogId = fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType);
        Inbound_Ingestion_Log__c falloutInboundIngestionLog = new Inbound_Ingestion_Log__c(
            Id = inboundIngestionLogId,
            Integration_Type__c = FALLOUT_EVENT,
            UUID__c = SSMO_UUID,
            Status__c = STATUS_PENDING,
            Created_Date_Time__c = System.now()
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IInboundIngestionLogsSelector selectorMock = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Inbound_Ingestion_Log__c.SObjectType);
        mocks.when(selectorMock.selectById(new Set<Id>{ inboundIngestionLogId }))
            .thenReturn(new List<Inbound_Ingestion_Log__c>{ falloutInboundIngestionLog });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        InboundIngestionLogs.updateIngestionLogsWithSucessOrFailureStatus(
            new Set<Id>{ inboundIngestionLogId },
            STATUS_COMPLETED,
            '',
            '',
            ''
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
    }

    /**
     * @description To test status marked skipped when there is a latest fallout event created
     * inbound ingestion log.
     */
    @isTest
    private static void testWhenInboundIngestionLogsInsertedThenStatusMarkedSkipped() {
        Id childInboundIngestionLogId = fflib_IDGenerator.generate(
            Inbound_Ingestion_Log__c.SObjectType
        );
        Id falloutInboundIngestionLogId = fflib_IDGenerator.generate(
            Inbound_Ingestion_Log__c.SObjectType
        );
        Inbound_Ingestion_Log__c falloutInboundIngestionLog = new Inbound_Ingestion_Log__c(
            Id = falloutInboundIngestionLogId,
            Integration_Type__c = FALLOUT_EVENT,
            UUID__c = SSMO_UUID,
            Status__c = STATUS_PENDING,
            Created_Date_Time__c = System.now()
        );
        Inbound_Ingestion_Log__c inboundIngestionLog = new Inbound_Ingestion_Log__c(
            Id = childInboundIngestionLogId,
            Integration_Type__c = FALLOUT_EVENT,
            UUID__c = SSMO_UUID,
            Status__c = STATUS_PENDING,
            Created_Date_Time__c = System.now().addDays(1)
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IInboundIngestionLogsSelector selectorMock = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Inbound_Ingestion_Log__c.SObjectType);
        mocks.when(
                selectorMock.selectParentInboundIngestionLogsByUUIDs(new Set<String>{ SSMO_UUID })
            )
            .thenReturn(new List<Inbound_Ingestion_Log__c>());
        mocks.when(
                selectorMock.selectInboundIngestionLogsByUUIDsAndIntegrationTypes(
                    new Set<String>{ FALLOUT_EVENT, ONBOARDING_EVENT, MX_PORTAL_NSE_EVENT },
                    new Set<String>{ SSMO_UUID }
                )
            )
            .thenReturn(new List<Inbound_Ingestion_Log__c>());
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        InboundIngestionLogs.newInstance(
                new List<Inbound_Ingestion_Log__c>{
                    inboundIngestionLog,
                    falloutInboundIngestionLog
                }
            )
            .onBeforeInsertHandleFalloutIngestionLogs();
        System.assertEquals(
            null,
            inboundIngestionLog.Parent_Log__c,
            ASSERT_MESSAGE_PARENT_MISMATCH
        );
        System.assertEquals(
            STATUS_SKIPPED,
            falloutInboundIngestionLog.Status__c,
            ASSERT_MESSAGE_STATUS_MISMATCH
        );
    }
    /**
     * @description To test when the SSMO process is failed update Inbound Ingestion Logs Status.
     * Suppressed Warnings since mock verify method does not require system assert statements.
     */
    //@isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenProcessFailedThenUpdateInboundIngestionLogsStatus() {
        Id inboundIngestionLogId = fflib_IDGenerator.generate(Inbound_Ingestion_Log__c.SObjectType);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        InboundIngestionLogs.updateIngestionLogsWithSucessOrFailureStatus(
            new Set<Id>{ inboundIngestionLogId },
            STATUS_FAILED,
            ERROR_MESSAGE,
            STACK_TRACE,
            BUSINESS_ERROR_MESSAGE
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Inbound_Ingestion_Log__c.Id => inboundIngestionLogId,
                        Inbound_Ingestion_Log__c.Status__c => STATUS_FAILED,
                        Inbound_Ingestion_Log__c.Error_Message__c => ERROR_MESSAGE,
                        Inbound_Ingestion_Log__c.Business_Error_Message__c => BUSINESS_ERROR_MESSAGE,
                        Inbound_Ingestion_Log__c.Exception_Message__c => ERROR_MESSAGE,
                        Inbound_Ingestion_Log__c.Stack_Trace__c => STACK_TRACE
                    }
                )
            );
    }
    /**
     * @description To test failed status update to pending
     * parent associated on inbound ingestion log.
     */
    @isTest
    private static void testWhenInboundIngestionLogFailedThenUpdateStatusToPending() {
        Inbound_Ingestion_Log__c parentInboundIngestionLog = new Inbound_Ingestion_Log__c(
            Integration_Type__c = FALLOUT_EVENT,
            UUID__c = SSMO_UUID,
            Status__c = STATUS_FAILED
        );
        insert parentInboundIngestionLog;

        Inbound_Ingestion_Log__c childInboundIngestionLog = new Inbound_Ingestion_Log__c(
            parent_log__c = parentInboundIngestionLog.id,
            UUID__c = SSMO_UUID,
            Status__c = STATUS_FAILED,
            Integration_Type__c = FALLOUT_EVENT
        );
        insert childInboundIngestionLog;

        test.startTest();

        List<Inbound_Ingestion_Log__c> ilList = new List<Inbound_Ingestion_Log__c>();
        ilList.add(parentInboundIngestionLog);
        IInboundIngestionLogs il = InboundIngestionLogs.newInstance(ilList);
        il.updateFailedLogsWithPendingStatus();

        test.stopTest();
        Inbound_Ingestion_Log__c ilog = [
            SELECT id, status__c, retry_count__c
            FROM Inbound_Ingestion_Log__c
            WHERE id = :parentInboundIngestionLog.Id
            LIMIT 1
        ];
        system.assertEquals('Pending', ilog.status__c, 'Log Status Updated to Pending');
    }
    /**
     * @description To test when the SSMO process is successful update Inbound Ingestion Logs Status.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOnboardingInboundIngestionLogsInsertedThenRESSMOOnboardingRecordsCreationInitiated() {
        Id inboundIngestionLogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Fake inboundIngestionLogRecords = new Fake(Inbound_Ingestion_Log__c.class)
            .setField(Inbound_Ingestion_Log__c.Id, inboundIngestionLogId)
            .setField(Inbound_Ingestion_Log__c.Payload__c, '{"Mx Store Name":"KFC"}')
            .setField(Inbound_Ingestion_Log__c.Integration_Type__c, ONBOARDING_EVENT)
            .setField(Inbound_Ingestion_Log__c.Status__c, STATUS_PENDING)
            .setField(Inbound_Ingestion_Log__c.Source__c, SOURCE_RESSMO);
        Inbound_Ingestion_Log__c newInboundIngestionLog = (Inbound_Ingestion_Log__c) inboundIngestionLogRecords.toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IInboundIngestionLogs inboundIngestionLogsMock = (IInboundIngestionLogs) mocks.mock(
            IInboundIngestionLogs.class
        );
        IInstantIngestorEventsService instantIngestorEventsServiceMock = (IInstantIngestorEventsService) mocks.mock(
            IInstantIngestorEventsService.class
        );
        Application.Domain.setMock(inboundIngestionLogsMock);
        Application.SERVICE.setMock(
            IInstantIngestorEventsService.class,
            instantIngestorEventsServiceMock
        );
        Test.startTest();
        InboundIngestionLogs.newInstance(
                new List<Inbound_Ingestion_Log__c>{ newInboundIngestionLog }
            )
            .initiateRESSMOOnboardingRecordsCreation(
                EVENT_TOPIC_ACCOUNT_RECORD_UPDATE_BY_INGESTION_ONBOARDING_PAYLOAD
            );
        Test.stopTest();
        ((IInstantIngestorEventsService) mocks.verify(instantIngestorEventsServiceMock, 1))
            .publishEvents(
                new Map<String, String>{
                    EVENT_TOPIC_ACCOUNT_RECORD_UPDATE_BY_INGESTION_ONBOARDING_PAYLOAD => JSON.serialize(
                        new List<Id>{ inboundIngestionLogId }
                    )
                },
                PreSalesTransaction__e.SObjectType
            );
    }
    /**
     * @description To test when the status moved to pending then intiate retry SSMO process.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenStatusMovedToPendingThenRetrySSMOProcessInitiated() {
        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_JSON
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        Id inboundIngestionLogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Fake inboundIngestionLogRecords = new Fake(Inbound_Ingestion_Log__c.class)
            .setField(Inbound_Ingestion_Log__c.Id, inboundIngestionLogId)
            .setField(Inbound_Ingestion_Log__c.Payload__c, payloadString)
            .setField(Inbound_Ingestion_Log__c.Failure_Step__c, 1)
            .setField(Inbound_Ingestion_Log__c.Status__c, STATUS_PENDING)
            .setField(Inbound_Ingestion_Log__c.Integration_Type__c, ONBOARDING_EVENT);
        Inbound_Ingestion_Log__c newInboundIngestionLog = (Inbound_Ingestion_Log__c) inboundIngestionLogRecords.toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IInboundIngestionLogs inboundIngestionLogsMock = (IInboundIngestionLogs) mocks.mock(
            IInboundIngestionLogs.class
        );
        IInstantIngestorEventsService instantIngestorEventsServiceMock = (IInstantIngestorEventsService) mocks.mock(
            IInstantIngestorEventsService.class
        );
        Application.Domain.setMock(inboundIngestionLogsMock);
        Application.SERVICE.setMock(
            IInstantIngestorEventsService.class,
            instantIngestorEventsServiceMock
        );
        Test.startTest();
        InboundIngestionLogs.newInstance(
                new List<Inbound_Ingestion_Log__c>{ newInboundIngestionLog }
            )
            .initiateRetrySSMORecordsCreation();
        Test.stopTest();
        ((IInstantIngestorEventsService) mocks.verify(instantIngestorEventsServiceMock, 0))
            .publishBulkEvents(
                new Map<String, List<String>>{
                    EVENT_TOPIC_ACCOUNT_RECORD_CREATION_BY_INGESTION_ONBOARDING_PAYLOAD => NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                        new Set<Id>{ newInboundIngestionLog.Id },
                        1
                    )
                }
            );
    }

    /**
     * @description To test when the status moved to pending then intiate retry SSMO process.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenInitiateRetryRecordsCreationByFieldValueAndSourceThenRetriggerRESSMO() {
        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_JSON
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        Id inboundIngestionLogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Fake inboundIngestionLogRecords = new Fake(Inbound_Ingestion_Log__c.class)
            .setField(Inbound_Ingestion_Log__c.Id, inboundIngestionLogId)
            .setField(Inbound_Ingestion_Log__c.Payload__c, payloadString)
            .setField(Inbound_Ingestion_Log__c.Failure_Step__c, 5)
            .setField(Inbound_Ingestion_Log__c.Status__c, STATUS_PENDING)
            .setField(Inbound_Ingestion_Log__c.Source__c, SOURCE_RESSMO)
            .setField(Inbound_Ingestion_Log__c.Integration_Type__c, ONBOARDING_EVENT);
        Inbound_Ingestion_Log__c newInboundIngestionLog = (Inbound_Ingestion_Log__c) inboundIngestionLogRecords.toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IInboundIngestionLogs inboundIngestionLogsMock = (IInboundIngestionLogs) mocks.mock(
            IInboundIngestionLogs.class
        );
        IInstantIngestorEventsService instantIngestorEventsServiceMock = (IInstantIngestorEventsService) mocks.mock(
            IInstantIngestorEventsService.class
        );
        Application.Domain.setMock(inboundIngestionLogsMock);
        Application.SERVICE.setMock(
            IInstantIngestorEventsService.class,
            instantIngestorEventsServiceMock
        );
        Test.startTest();
        InboundIngestionLogs.newInstance(
                new List<Inbound_Ingestion_Log__c>{ newInboundIngestionLog }
            )
            .initiateRetryRESSMORecordsCreation();
        Test.stopTest();
        ((IInstantIngestorEventsService) mocks.verify(instantIngestorEventsServiceMock, 0))
            .publishBulkEvents(
                new Map<String, List<String>>{
                    EVENT_TOPIC_ACCOUNT_RECORD_UPDATE_BY_INGESTION_ONBOARDING_PAYLOAD => NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                        new Set<Id>{ newInboundIngestionLog.Id },
                        1
                    )
                }
            );
    }
}