/**
 * @author Deloitte
 * @date 05/15/2024
 * @description Test class for IngestionPayloadHandlerServiceImpl
 */
@isTest
private class IngestionPayloadHandlerServiceImplTest {
    private static final String STATIC_RESOURCE_TEST_JSON = 'Inbound_Ingestion_Payload_Data';
    private static final String STATIC_RESOURCE_TEST_JSON_FALLOUT = 'SSMO_Lead_Ingestion_Mock_Payload';
    private static final String STATIC_RESOURCE_INGESTION_LOG_ARRAY_JSON = 'Inbound_Ingestion_Array_Payload_Data';
    private static final String STATIC_RESOURCE_INGESTION_LOG_ARRAY_JSON_FALLOUT = 'Inbound_Ingestion_Fallout_Array_Payload_Data';
    private static final string INVALID_ASSERT_MESSAGE = 'Unexpected results';
    private static final string INTEGRATION_TYPE_ONBOARDING_EVENT = 'Onboarding Event';
    private static final string SOURCE_SSMO = 'SSMO';
    private static final string SOURCE_SSOB = 'SSOB';
    private static final string UUID = '92108a53-e8d9-4a0c-9193-9152aeb86fe4';
    private static final string SECOND_UUID = '81108a53-e8d9-4a0c-9193-9152aeb86fe4';
    private static final String FALLOUT_UUID = '79k4d787-66TH-4bb0-93ed-4b0bc2ec1cf8';
    private static final String FALLOUT_SECOND_UUID = '25d4d787-66TH-4bb0-93ed-4b0bc2ec1cf8';
    private static final String INGESTION_LOG_STATUS_PENDING = 'Pending';
    private static final String INTEGRATION_TYPE_FALLOUT_EVENT = 'Fallout event';
    private static final String INVALID_PAYLOAD = '{"Mx Store Name":"Yumm"}';
    private static final String UUID_MISSING_ERROR_MESSAGE = 'UUID is missing';
    private static final String EMAIL_ID_MISSING_ERROR_MESSAGE = 'Email Id is missing';
    private static final String NAME_MISSING_ERROR_MESSAGE = 'Store Name is missing';
    private static final String ADDRESS_MISSING_ERROR_MESSAGE = 'Address is missing';
    private static final String MX_PORTAL_NSE_EVENT = 'Mx Portal New Store Expansion';
    private static final String MX_PORTAL_SOURCE = 'Mx Portal';

    /**
     * @description It is used to test when a JSON payload is passed in a non array format then an
     * inbound ingestion log is inserted with the details.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenNonArrayPayloadPassedThenInboundIngestionLogInserted() {
        Id mockInboundingestionlogId = Fake.generateId(Inbound_Ingestion_Log__c.class);

        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_JSON
        ];

        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        Inbound_Ingestion_Log__c inboundIngestionLogRecord = new Inbound_Ingestion_Log__c(
            Id = mockInboundingestionlogId,
            Payload__c = payloadString,
            Status__c = INGESTION_LOG_STATUS_PENDING,
            UUID__c = UUID,
            Integration_Type__c = INTEGRATION_TYPE_FALLOUT_EVENT
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IInboundIngestionLogsSelector mockInstantIngestorLogs = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockInstantIngestorLogs.sObjectType())
            .thenReturn(Inbound_Ingestion_Log__c.SObjectType);
        mocks.when(
                mockInstantIngestorLogs.selectInboundIngestionLogsByUniqueIdentifiers(
                    new Set<String>{ INTEGRATION_TYPE_FALLOUT_EVENT },
                    new Set<String>{ UUID }
                )
            )
            .thenReturn(new List<Inbound_Ingestion_Log__c>{ inboundIngestionLogRecord });
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockInstantIngestorLogs);

        IngestionPayloadHandlerService.insertInboundIngestionLogs(
            INTEGRATION_TYPE_ONBOARDING_EVENT,
            payloadString,
            SOURCE_SSMO
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Inbound_Ingestion_Log__c.Integration_Type__c => MX_PORTAL_NSE_EVENT,
                        Inbound_Ingestion_Log__c.UUID__c => UUID,
                        Inbound_Ingestion_Log__c.Source__c => MX_PORTAL_SOURCE
                    }
                )
            );
    }
    /**
     * @description It is used to test when a invalid JSON payload is passed then an
     * custom validation thrown with the details.
     */
    @isTest
    private static void testWhenInvalidPayloadPassedThenCustomValidationThrown() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        Application.UNITOFWORK.setMock(mockUOW);
        try {
            IngestionPayloadHandlerService.insertInboundIngestionLogs(
                INTEGRATION_TYPE_ONBOARDING_EVENT,
                INVALID_PAYLOAD,
                SOURCE_SSMO
            );
        } catch (Exception customValidationException) {
            System.assertEquals(
                true,
                customValidationException.getMessage().contains(ADDRESS_MISSING_ERROR_MESSAGE),
                INVALID_ASSERT_MESSAGE
            );
            System.assertEquals(
                true,
                customValidationException.getMessage().contains(EMAIL_ID_MISSING_ERROR_MESSAGE),
                INVALID_ASSERT_MESSAGE
            );
            System.assertEquals(
                true,
                customValidationException.getMessage().contains(NAME_MISSING_ERROR_MESSAGE),
                INVALID_ASSERT_MESSAGE
            );
            System.assertEquals(
                true,
                customValidationException.getMessage().contains(UUID_MISSING_ERROR_MESSAGE),
                INVALID_ASSERT_MESSAGE
            );
        }
    }

    /**
     * @description It is used to test when a JSON payload is passed in an array format then multiple
     * inbound ingestion loga are inserted with the details.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenArrayPayloadPassedThenMultipleInboundIngestionLogInserted() {
        Id mockInboundingestionlogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id mockInboundingestionlogSecondId = Fake.generateId(Inbound_Ingestion_Log__c.class);

        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_INGESTION_LOG_ARRAY_JSON
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        List<Inbound_Ingestion_Log__c> inboundIngestionLogRecords = new List<Inbound_Ingestion_Log__c>{
            new Inbound_Ingestion_Log__c(
                Id = mockInboundingestionlogId,
                Payload__c = payloadString,
                Status__c = INGESTION_LOG_STATUS_PENDING,
                UUID__c = UUID,
                Integration_Type__c = INTEGRATION_TYPE_FALLOUT_EVENT
            ),
            new Inbound_Ingestion_Log__c(
                Id = mockInboundingestionlogSecondId,
                Payload__c = payloadString,
                Status__c = INGESTION_LOG_STATUS_PENDING,
                UUID__c = SECOND_UUID,
                Integration_Type__c = INTEGRATION_TYPE_FALLOUT_EVENT
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IInboundIngestionLogsSelector mockInstantIngestorLogs = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockInstantIngestorLogs.sObjectType())
            .thenReturn(Inbound_Ingestion_Log__c.SObjectType);
        mocks.when(
                mockInstantIngestorLogs.selectInboundIngestionLogsByUniqueIdentifiers(
                    new Set<String>{ INTEGRATION_TYPE_FALLOUT_EVENT },
                    new Set<String>{ SECOND_UUID, UUID }
                )
            )
            .thenReturn(inboundIngestionLogRecords);
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockInstantIngestorLogs);

        IngestionPayloadHandlerService.insertInboundIngestionLogs(
            INTEGRATION_TYPE_ONBOARDING_EVENT,
            payloadString,
            SOURCE_SSMO
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Inbound_Ingestion_Log__c.Integration_Type__c => INTEGRATION_TYPE_ONBOARDING_EVENT,
                        Inbound_Ingestion_Log__c.UUID__c => UUID,
                        Inbound_Ingestion_Log__c.Source__c => SOURCE_SSMO
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Inbound_Ingestion_Log__c.Integration_Type__c => INTEGRATION_TYPE_ONBOARDING_EVENT,
                        Inbound_Ingestion_Log__c.UUID__c => SECOND_UUID,
                        Inbound_Ingestion_Log__c.Source__c => SOURCE_SSMO
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).registerNew(fflib_Match.anySObject());
    }
    /**
     * @description It is used to test when a JSON payload is passed in a non array format then an
     * inbound ingestion log is inserted with the details.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenNonArrayFalloutPayloadPassedThenInboundIngestionLogInserted() {
        Id mockInboundingestionlogId = Fake.generateId(Inbound_Ingestion_Log__c.class);

        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_JSON_FALLOUT
        ];

        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        Inbound_Ingestion_Log__c inboundIngestionLogRecord = new Inbound_Ingestion_Log__c(
            Id = mockInboundingestionlogId,
            Payload__c = payloadString,
            Status__c = INGESTION_LOG_STATUS_PENDING,
            UUID__c = FALLOUT_UUID,
            Integration_Type__c = INTEGRATION_TYPE_FALLOUT_EVENT
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IInboundIngestionLogsSelector mockInstantIngestorLogs = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockInstantIngestorLogs.sObjectType())
            .thenReturn(Inbound_Ingestion_Log__c.SObjectType);
        mocks.when(
                mockInstantIngestorLogs.selectInboundIngestionLogsByUniqueIdentifiers(
                    new Set<String>{ INTEGRATION_TYPE_FALLOUT_EVENT },
                    new Set<String>{ FALLOUT_UUID }
                )
            )
            .thenReturn(new List<Inbound_Ingestion_Log__c>{ inboundIngestionLogRecord });
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockInstantIngestorLogs);

        IngestionPayloadHandlerService.insertInboundIngestionLogs(
            INTEGRATION_TYPE_FALLOUT_EVENT,
            payloadString,
            SOURCE_SSMO
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).registerNew(fflib_Match.anySObject());
    }
    /**
     * @description It is used to test when a JSON payload is passed in an array format then multiple
     * inbound ingestion loga are inserted with the details.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenArrayFalloutPayloadPassedThenMultipleInboundIngestionLogInserted() {
        Id mockInboundingestionlogId = Fake.generateId(Inbound_Ingestion_Log__c.class);
        Id mockInboundingestionlogSecondId = Fake.generateId(Inbound_Ingestion_Log__c.class);

        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_INGESTION_LOG_ARRAY_JSON_FALLOUT
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        List<Inbound_Ingestion_Log__c> inboundIngestionLogRecords = new List<Inbound_Ingestion_Log__c>{
            new Inbound_Ingestion_Log__c(
                Id = mockInboundingestionlogId,
                Payload__c = payloadString,
                Status__c = INGESTION_LOG_STATUS_PENDING,
                UUID__c = FALLOUT_UUID,
                Integration_Type__c = INTEGRATION_TYPE_FALLOUT_EVENT
            ),
            new Inbound_Ingestion_Log__c(
                Id = mockInboundingestionlogSecondId,
                Payload__c = payloadString,
                Status__c = INGESTION_LOG_STATUS_PENDING,
                UUID__c = FALLOUT_SECOND_UUID,
                Integration_Type__c = INTEGRATION_TYPE_FALLOUT_EVENT
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IInboundIngestionLogsSelector mockInstantIngestorLogs = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockInstantIngestorLogs.sObjectType())
            .thenReturn(Inbound_Ingestion_Log__c.SObjectType);
        mocks.when(
                mockInstantIngestorLogs.selectInboundIngestionLogsByUniqueIdentifiers(
                    new Set<String>{ INTEGRATION_TYPE_FALLOUT_EVENT },
                    new Set<String>{ FALLOUT_SECOND_UUID, FALLOUT_UUID }
                )
            )
            .thenReturn(inboundIngestionLogRecords);
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockInstantIngestorLogs);

        IngestionPayloadHandlerService.insertInboundIngestionLogs(
            INTEGRATION_TYPE_FALLOUT_EVENT,
            payloadString,
            SOURCE_SSMO
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Inbound_Ingestion_Log__c.Integration_Type__c => INTEGRATION_TYPE_FALLOUT_EVENT,
                        Inbound_Ingestion_Log__c.UUID__c => FALLOUT_UUID,
                        Inbound_Ingestion_Log__c.Source__c => SOURCE_SSMO
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Inbound_Ingestion_Log__c.Integration_Type__c => INTEGRATION_TYPE_FALLOUT_EVENT,
                        Inbound_Ingestion_Log__c.UUID__c => FALLOUT_SECOND_UUID,
                        Inbound_Ingestion_Log__c.Source__c => SOURCE_SSMO
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).registerNew(fflib_Match.anySObject());
    }
}