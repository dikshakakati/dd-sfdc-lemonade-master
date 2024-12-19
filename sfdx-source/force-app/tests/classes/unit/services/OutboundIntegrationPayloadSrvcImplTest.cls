/**
 * @author Deloitte
 * @date 04/23/2024
 * @description Test class for OutboundIntegrationPayloadServiceImpl class.
 */
@isTest(SeeAllData=false)
public class OutboundIntegrationPayloadSrvcImplTest {
    private static final String ASSERT_MESSAGE_CHUNKING_ERROR = 'Unexpected Result: Payload not chunked';
    private static final String ASSERT_MESSAGE_ID_MISMATCH = 'Unexpected Result: Record Id does not match.';
    private static final String EMAIL_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG = 'Email_Payload_Chunk_Size';
    private static final String ENTITY_NAME_MX_ORDER = 'Merchant Order';
    private static final String ENTITY_NAME_INTERFACE_TRANSACTION = 'InterfaceTransaction';
    private static final String ENTITY_NAME_STORE_ACCOUNT = 'StoreAccount';
    private static final String ENTITY_NAME_WORK_STEP = 'WorkStep';
    private static final String EVENT_OPPORTUNITY_CLOSED_WON = 'OPPORTUNITY_CLOSED_WON';
    private static final String METADATA_VALUE = '2';
    private static final String MOCK_STORE_ID = '165551';
    private static final String MOCK_UUID = 'UUIDMock';
    private static final String PHOTOSHOOT_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG = 'Photoshoot_Payload_Chunk_Size';
    private static final String TABLET_OUTBOUND_EVENT_NAME = 'tablet-order-create-event';
    private static final String TABLET_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG = 'Tablet_Payload_Chunk_Size';

    /**
     * @description To test WorkStep Ids and Store account Ids are returned
     * when Activation Checklist payload is received.
     */
    @isTest
    private static void testWhenActivationChecklistPayloadReceivedThenReturnStoreAndWorkStepIds() {
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        List<ActivationChecklistOutboundWrapper.ActivationChecklistDetails> activationChecklistDetails = new List<ActivationChecklistOutboundWrapper.ActivationChecklistDetails>();
        ActivationChecklistOutboundWrapper.ActivationChecklistDetails mockActivationChecklistDetails = new ActivationChecklistOutboundWrapper.ActivationChecklistDetails();
        mockActivationChecklistDetails.accountSalesforceId = accountId;
        mockActivationChecklistDetails.workStepSalesforceId = workStepId;
        activationChecklistDetails.add(mockActivationChecklistDetails);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ActivationChecklistOutboundWrapper newActivationChecklistWrapper = new ActivationChecklistOutboundWrapper(
            MOCK_UUID,
            activationChecklistDetails
        );
        IStaticConfigurationsSelector mockStaticConfigurationsSelector = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockStaticConfigurationsSelector.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    EMAIL_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = EMAIL_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    PHOTOSHOOT_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = PHOTOSHOOT_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    TABLET_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = TABLET_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        Map<String, Set<String>> recordIdsReturned = OutboundIntegrationPayloadService.collectRecordIdsFromActivationChecklistPayload(
            new List<String>{ JSON.serialize(newActivationChecklistWrapper) }
        );
        System.assertEquals(
            workStepId,
            (new List<String>(recordIdsReturned.get(ENTITY_NAME_WORK_STEP)))[0],
            ASSERT_MESSAGE_ID_MISMATCH
        );
        System.assertEquals(
            accountId,
            (new List<String>(recordIdsReturned.get(ENTITY_NAME_STORE_ACCOUNT)))[0],
            ASSERT_MESSAGE_ID_MISMATCH
        );
    }

    /**
     * @description To test Merchant Order Ids and Store account Ids are returned
     * when Activation Checklist payload is received.
     */
    @isTest
    private static void testWhenTabletPayloadReceivedThenReturnStoreAndMxOrderIds() {
        Id orderId = fflib_IDGenerator.generate(Mx_Order__c.SObjectType);
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        MerchantOrdersPayloads mxOrdersPayloadsInstance = new MerchantOrdersPayloads();
        MerchantOrdersPayloads.MxOrdersOutboundWrapper mxOrdersOutboundWrapperInstance = new MerchantOrdersPayloads.MxOrdersOutboundWrapper();
        MerchantOrdersPayloads.MerchantOrdersWrapper newMerchantOrdersWrapper = new MerchantOrdersPayloads.MerchantOrdersWrapper(
            MOCK_UUID,
            TABLET_OUTBOUND_EVENT_NAME
        );
        mxOrdersPayloadsInstance.setOrderSFID(mxOrdersOutboundWrapperInstance, orderId);
        mxOrdersPayloadsInstance.setAccountSFID(mxOrdersOutboundWrapperInstance, accountId);
        mxOrdersPayloadsInstance.setOrder(
            newMerchantOrdersWrapper,
            mxOrdersOutboundWrapperInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStaticConfigurationsSelector mockStaticConfigurationsSelector = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockStaticConfigurationsSelector.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    TABLET_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = TABLET_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    EMAIL_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = EMAIL_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    PHOTOSHOOT_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = PHOTOSHOOT_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        Map<String, Set<String>> recordIdsReturned = OutboundIntegrationPayloadService.collectRecordIdsFromMxOrderPayload(
            new List<String>{ JSON.serialize(newMerchantOrdersWrapper) }
        );
        System.assertEquals(
            orderId,
            (new List<String>(recordIdsReturned.get(ENTITY_NAME_MX_ORDER)))[0],
            ASSERT_MESSAGE_ID_MISMATCH
        );
        System.assertEquals(
            accountId,
            (new List<String>(recordIdsReturned.get(ENTITY_NAME_STORE_ACCOUNT)))[0],
            ASSERT_MESSAGE_ID_MISMATCH
        );
    }

    /**
     * @description To test chunked tablet payload is generated
     * when Interface Transactions with tablet payloads are received.
     */
    @isTest
    private static void testWhenTabletPayloadReceivedThenReturnChunkedPayloads() {
        List<Interface_Transaction__c> mockInterfaceTransactions = new List<Interface_Transaction__c>();
        for (Integer i = 0; i < 2; i++) {
            Id orderId = fflib_IDGenerator.generate(Mx_Order__c.SObjectType);
            Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
            Id interfaceTransactionId = fflib_IDGenerator.generate(
                Interface_Transaction__c.SObjectType
            );
            MerchantOrdersPayloads mxOrdersPayloadsInstance = new MerchantOrdersPayloads();
            MerchantOrdersPayloads.MxOrdersOutboundWrapper mxOrdersOutboundWrapperInstance = new MerchantOrdersPayloads.MxOrdersOutboundWrapper();
            MerchantOrdersPayloads.MerchantOrdersWrapper newMerchantOrdersWrapper = new MerchantOrdersPayloads.MerchantOrdersWrapper(
                MOCK_UUID,
                TABLET_OUTBOUND_EVENT_NAME
            );
            mxOrdersPayloadsInstance.setOrderSFID(mxOrdersOutboundWrapperInstance, orderId);
            mxOrdersPayloadsInstance.setAccountSFID(mxOrdersOutboundWrapperInstance, accountId);
            mxOrdersPayloadsInstance.setOrder(
                newMerchantOrdersWrapper,
                mxOrdersOutboundWrapperInstance
            );
            mockInterfaceTransactions.add(
                new Interface_Transaction__c(
                    Id = interfaceTransactionId,
                    Payload__c = JSON.serialize(newMerchantOrdersWrapper)
                )
            );
        }
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStaticConfigurationsSelector mockStaticConfigurationsSelector = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockStaticConfigurationsSelector.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    TABLET_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = TABLET_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    EMAIL_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = EMAIL_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    PHOTOSHOOT_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = PHOTOSHOOT_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        List<String> chunkedPayloads = OutboundIntegrationPayloadService.generateChunkedPayloadsForMxOrderIntegration(
            mockInterfaceTransactions
        );
        System.assertEquals(1, chunkedPayloads.size(), ASSERT_MESSAGE_CHUNKING_ERROR);
    }

    /**
     * @description To test chunked email payload is generated
     * when Interface Transactions with email payloads are received.
     */
    @isTest
    private static void testWhenEmailPayloadReceivedThenReturnChunkedPayloads() {
        List<Interface_Transaction__c> mockInterfaceTransactions = new List<Interface_Transaction__c>();
        for (Integer i = 0; i < 2; i++) {
            Id interfaceTransactionId = fflib_IDGenerator.generate(
                Interface_Transaction__c.SObjectType
            );
            EmailOutboundPayloads emailOutboundPayloadsInstance = new EmailOutboundPayloads();
            EmailOutboundPayloads.EmailOutboundWrapper emailOutboundWrapperInstance = new EmailOutboundPayloads.EmailOutboundWrapper(
                MOCK_UUID
            );
            EmailOutboundPayloads.EmailOutboundDetails newEmailOutboundDetails = new EmailOutboundPayloads.EmailOutboundDetails(
                EVENT_OPPORTUNITY_CLOSED_WON,
                interfaceTransactionId
            );
            emailOutboundPayloadsInstance.setRequestPayload(
                emailOutboundWrapperInstance,
                newEmailOutboundDetails
            );
            mockInterfaceTransactions.add(
                new Interface_Transaction__c(
                    Id = interfaceTransactionId,
                    Payload__c = JSON.serialize(newEmailOutboundDetails)
                )
            );
        }
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStaticConfigurationsSelector mockStaticConfigurationsSelector = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockStaticConfigurationsSelector.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    EMAIL_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = EMAIL_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    TABLET_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = TABLET_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    PHOTOSHOOT_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = PHOTOSHOOT_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        List<String> chunkedPayloads = OutboundIntegrationPayloadService.generateChunkedPayloadsForEmailIntegration(
            mockInterfaceTransactions
        );
        System.assertEquals(1, chunkedPayloads.size(), ASSERT_MESSAGE_CHUNKING_ERROR);
    }

    /**
     * @description To test Interface Transaction Ids are retruned
     * when email payloads are received.
     */
    @isTest
    private static void testWhenEmailPayloadReceivedThenReturnInterfaceTransactionId() {
        Id interfaceTransactionId = fflib_IDGenerator.generate(
            Interface_Transaction__c.SObjectType
        );
        EmailOutboundPayloads emailOutboundPayloadsInstance = new EmailOutboundPayloads();
        EmailOutboundPayloads.EmailOutboundWrapper emailOutboundWrapperInstance = new EmailOutboundPayloads.EmailOutboundWrapper(
            MOCK_UUID
        );
        EmailOutboundPayloads.EmailOutboundDetails newEmailOutboundDetails = new EmailOutboundPayloads.EmailOutboundDetails(
            EVENT_OPPORTUNITY_CLOSED_WON,
            interfaceTransactionId
        );
        emailOutboundPayloadsInstance.setRequestPayload(
            emailOutboundWrapperInstance,
            newEmailOutboundDetails
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStaticConfigurationsSelector mockStaticConfigurationsSelector = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockStaticConfigurationsSelector.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    EMAIL_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = EMAIL_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    TABLET_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = TABLET_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    PHOTOSHOOT_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = PHOTOSHOOT_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        Map<String, Set<String>> recordIdsFromPayload = OutboundIntegrationPayloadService.collectRecordIdsFromEmailPayload(
            new List<String>{ JSON.serialize(emailOutboundWrapperInstance) }
        );
        System.assertEquals(
            interfaceTransactionId,
            (new List<String>(recordIdsFromPayload.get(ENTITY_NAME_INTERFACE_TRANSACTION)))[0],
            ASSERT_MESSAGE_ID_MISMATCH
        );
    }

    /**
     * @description To test Merchant Order Ids and Store account Ids are returned
     * when Photoshoot payload is received.
     */
    @isTest
    private static void testWhenPhotoshootPayloadReceivedThenReturnStoreAndMxOrderIds() {
        Id orderId = fflib_IDGenerator.generate(Mx_Order__c.SObjectType);
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);

        MerchantOrdersPayloads mxOrdersPayloadsInstance = new MerchantOrdersPayloads();
        MerchantOrdersPayloads.PhotoshootMxOrdersOutboundWrapper mxOrdersOutboundWrapperInstance = new MerchantOrdersPayloads.PhotoshootMxOrdersOutboundWrapper();
        MerchantOrdersPayloads.PhotoshootMerchantOrdersWrapper newMerchantOrdersWrapper = new MerchantOrdersPayloads.PhotoshootMerchantOrdersWrapper(
            MOCK_UUID
        );
        mxOrdersPayloadsInstance.setPhotoshootOrderSFID(mxOrdersOutboundWrapperInstance, orderId);
        mxOrdersPayloadsInstance.setPhotoshootAccountSFID(
            mxOrdersOutboundWrapperInstance,
            accountId
        );
        mxOrdersPayloadsInstance.setPhotoshootOrder(
            newMerchantOrdersWrapper,
            mxOrdersOutboundWrapperInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStaticConfigurationsSelector mockStaticConfigurationsSelector = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockStaticConfigurationsSelector.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    TABLET_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = TABLET_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    EMAIL_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = EMAIL_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    PHOTOSHOOT_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = PHOTOSHOOT_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        Map<String, Set<String>> recordIdsReturned = OutboundIntegrationPayloadService.collectRecordIdsFromPhotoshootMxOrderPayload(
            new List<String>{ JSON.serialize(newMerchantOrdersWrapper) }
        );
        System.assertEquals(
            orderId,
            (new List<String>(recordIdsReturned.get(ENTITY_NAME_MX_ORDER)))[0],
            ASSERT_MESSAGE_ID_MISMATCH
        );
        System.assertEquals(
            accountId,
            (new List<String>(recordIdsReturned.get(ENTITY_NAME_STORE_ACCOUNT)))[0],
            ASSERT_MESSAGE_ID_MISMATCH
        );
    }

    /**
     * @description To test chunked photoshoot payload is generated
     * when Interface Transactions with photoshoot payloads are received.
     */
    @isTest
    private static void testWhenPhotoshootPayloadReceivedThenReturnChunkedPayloads() {
        List<Interface_Transaction__c> mockInterfaceTransactions = new List<Interface_Transaction__c>();
        for (Integer i = 0; i < 2; i++) {
            Id interfaceTransactionId = fflib_IDGenerator.generate(
                Interface_Transaction__c.SObjectType
            );
            Id orderId = fflib_IDGenerator.generate(Mx_Order__c.SObjectType);
            Id accountId = fflib_IDGenerator.generate(Account.SObjectType);

            MerchantOrdersPayloads mxOrdersPayloadsInstance = new MerchantOrdersPayloads();
            MerchantOrdersPayloads.PhotoshootMxOrdersOutboundWrapper mxOrdersOutboundWrapperInstance = new MerchantOrdersPayloads.PhotoshootMxOrdersOutboundWrapper();
            mxOrdersPayloadsInstance.setPhotoshootOrderSFID(
                mxOrdersOutboundWrapperInstance,
                orderId
            );
            mxOrdersPayloadsInstance.setPhotoshootAccountSFID(
                mxOrdersOutboundWrapperInstance,
                accountId
            );
            mockInterfaceTransactions.add(
                new Interface_Transaction__c(
                    Id = interfaceTransactionId,
                    Payload__c = JSON.serialize(mxOrdersOutboundWrapperInstance)
                )
            );
        }
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStaticConfigurationsSelector mockStaticConfigurationsSelector = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockStaticConfigurationsSelector.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    TABLET_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = TABLET_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    EMAIL_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = EMAIL_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    PHOTOSHOOT_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = PHOTOSHOOT_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        List<String> chunkedPayloads = OutboundIntegrationPayloadService.generateChunkedPayloadsForMxOrderPhotoshootIntegration(
            mockInterfaceTransactions
        );
        System.assertEquals(1, chunkedPayloads.size(), ASSERT_MESSAGE_CHUNKING_ERROR);
    }

    /**
     * @description To test Mx Fraud Document payload is generated
     * when Interface Transactions with payloads are received.
     */
    @isTest
    private static void testWhenInterfaceTransactionsReceivedThenReturnMxFraudDocumentPayloads() {
        List<Interface_Transaction__c> mockInterfaceTransactions = new List<Interface_Transaction__c>();
        Id interfaceTransactionId = fflib_IDGenerator.generate(
            Interface_Transaction__c.SObjectType
        );
        MxFraudDocumentsPayloads.MxFraudDocumentDetails newMxFraudDocumentDetails = new MxFraudDocumentsPayloads.MxFraudDocumentDetails(
            MOCK_STORE_ID
        );
        mockInterfaceTransactions.add(
            new Interface_Transaction__c(
                Id = interfaceTransactionId,
                Payload__c = JSON.serialize(newMxFraudDocumentDetails)
            )
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStaticConfigurationsSelector mockStaticConfigurationsSelector = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockStaticConfigurationsSelector.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    TABLET_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = TABLET_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    EMAIL_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = EMAIL_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    PHOTOSHOOT_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = PHOTOSHOOT_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        List<String> chunkedPayloads = OutboundIntegrationPayloadService.generateChunkedPayloadsForMxFraudDocumentsIntegration(
            mockInterfaceTransactions
        );
        System.assertEquals(1, chunkedPayloads.size(), ASSERT_MESSAGE_CHUNKING_ERROR);
    }

    /**
     * @description To test Interface Transaction Id is returned when Mx Fraud Document
     * outbound payload is received.
     */
    @isTest
    private static void testWhenMxFraudDocumentPayloadReceivedThenInterfaceTransactionIds() {
        Id interfaceTransactionId = fflib_IDGenerator.generate(
            Interface_Transaction__c.SObjectType
        );
        MxFraudDocumentsPayloads mxFraudDocumentsPayloadsInstance = new MxFraudDocumentsPayloads();
        MxFraudDocumentsPayloads.MxFraudDocumentDetails newMxFraudDocumentDetails = new MxFraudDocumentsPayloads.MxFraudDocumentDetails(
            MOCK_STORE_ID
        );
        mxFraudDocumentsPayloadsInstance.setInterfaceTransactionSFID(
            newMxFraudDocumentDetails,
            interfaceTransactionId
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStaticConfigurationsSelector mockStaticConfigurationsSelector = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockStaticConfigurationsSelector.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    TABLET_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = TABLET_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    EMAIL_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = EMAIL_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    PHOTOSHOOT_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = PHOTOSHOOT_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        Map<String, Set<String>> recordIdsFromPayload = OutboundIntegrationPayloadService.collectRecordIdsFromMxFraudPayload(
            new List<String>{ JSON.serialize(newMxFraudDocumentDetails) }
        );
        System.assertEquals(
            interfaceTransactionId,
            (new List<String>(recordIdsFromPayload.get(ENTITY_NAME_INTERFACE_TRANSACTION)))[0],
            ASSERT_MESSAGE_ID_MISMATCH
        );
    }
}