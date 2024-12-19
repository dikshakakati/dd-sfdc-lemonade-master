/**
 * @author Deloitte
 * @date 04/04/2024
 * @description Test class for IntegrationOutboundServiceImpl class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
public class IntegrationOutboundServiceImplTest {
    private static final String COUNT_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: Argument count does not match';
    private static final String EMAIL_NAMED_CREDENTIAL = 'Mulesoft_Email_Named_Cred';
    private static final String ENTITY_NAME_INTERFACE_TRANSACTION = 'InterfaceTransaction';
    private static final String ENTITY_NAME_MX_ORDER = 'Merchant Order';
    private static final String ENTITY_NAME_STORE_ACCOUNT = 'StoreAccount';
    private static final String ENTITY_NAME_WORK_STEP = 'WorkStep';
    private static final String EVENT_OPPORTUNITY_CLOSED_WON = 'OPPORTUNITY_CLOSED_WON';
    private static final String EVENT_TOPIC_ORDER_RETRY_CALLOUT = 'RETRY_CALLOUT';
    private static final String EVENT_TOPIC_ORDER_RETRY_CALLOUT_BATCH = 'RETRY_CALLOUT_BATCH';
    private static final String HTTP_REQUEST_NAMED_CREDENTIAL = 'Mulesoft_Activation_Checklist_Named_Cred';
    private static final String MX_FRAUD_HTTP_REQUEST_NAMED_CREDENTIAL = 'Mulesoft_Mx_Fraud_Named_Cred';
    private static final String TABLET_HTTP_REQUEST_NAMED_CREDENTIAL = 'Mulesoft_Tablet_Named_Cred';
    private static final String LOG_ERROR_MESSAGE = 'Unable to send outbound integration request payload. : System.HttpResponse[Status=null, StatusCode=503]';
    private static final String LOG_METHOD_NAME = 'sendPayloadforOutboundIntegration';
    private static final String MOCK_NAMED_CREDENTIAL = 'Mock_Named_Cred';
    private static final String MOCK_PAYLOAD = '{IntegrationOutboundServiceImplTest_Mock_Payload}';
    private static final String MOCK_RESPONSE = '{Mock_Response}';
    private static final String MOCK_UUID = 'UUIDMock';
    private static final String PHOTOSHOOT_NAMED_CREDENTIAL = 'Mulesoft_Photoshoot_Named_Cred';
    private static final String SHIPPING_ADDRESS = '221 Baker Street';
    private static final String SHIPPING_CITY = 'Moon City';
    private static final String SHIPPING_COUNTRY_CODE = 'US';
    private static final String SHIPPING_LATITUDE = '1.00';
    private static final String SHIPPING_LONGITUDE = '1.00';
    private static final String SHIPPING_NOTES = 'Mock Notes';
    private static final String SHIPPING_POSTAL_CODE = 'T-101';
    private static final String SHIPPING_STATE_CODE = 'NY';
    private static final Integer STATUS_CODE_SUCCESS = 200;
    private static final Integer STATUS_CODE_FAILURE = 503;
    private static final String TABLET_OUTBOUND_EVENT_NAME = 'tablet-order-create-event';
    private static final String USECASE_NAME_ACTIVATION_CHECKLIST_OUTBOUND_INTEGRATION = 'ACTIVATION_CHECKLIST_OUTBOUND_INTEGRATION';
    private static final String USECASE_NAME_EMAIL_OUTBOUND_INTEGRATION = 'EMAIL_OUTBOUND_INTEGRATION';
    private static final String USECASE_NAME_MX_FRAUD_OUTBOUND_INTEGRATION = 'MX_FRAUD_DOCUMENT_INTEGRATION';
    private static final String USECASE_NAME_PHOTOSHOOT_OUTBOUND_INTEGRATION = 'PHOTOSHOOT_OUTBOUND_INTEGRATION';
    private static final String USECASE_NAME_TABLET_OUTBOUND_INTEGRATION = 'TABLET_OUTBOUND_INTEGRATION';
    private static final String WORK_STEP_STATUS_IN_PROGRESS = 'In Progress';

    /**
     * @description To test HTTP callout is sent when request payloads received with record Ids.
     */
    @isTest
    private static void testWhenRequestPayloadReceivedThenSendHttpRequest() {
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        List<ActivationChecklistOutboundWrapper.ActivationChecklistDetails> activationChecklistDetails = new List<ActivationChecklistOutboundWrapper.ActivationChecklistDetails>();
        ActivationChecklistOutboundWrapper.ActivationChecklistDetails mockActivationChecklistDetails = new ActivationChecklistOutboundWrapper.ActivationChecklistDetails();
        mockActivationChecklistDetails.accountSalesforceId = fflib_IDGenerator.generate(
            Account.SObjectType
        );
        mockActivationChecklistDetails.workStepSalesforceId = workStepId;
        activationChecklistDetails.add(mockActivationChecklistDetails);
        ActivationChecklistOutboundWrapper newActivationChecklistWrapper = new ActivationChecklistOutboundWrapper(
            MOCK_UUID,
            activationChecklistDetails
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStaticConfigurationsSelector mockStaticConfigurationsSelector = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        IWorkStepsService mockWorkStepsService = (IWorkStepsService) mocks.mock(
            IWorkStepsService.class
        );
        IOutboundIntegrationPayloadService outboundIntegrationPayloadSrvcMock = (IOutboundIntegrationPayloadService) mocks.mock(
            IOutboundIntegrationPayloadService.class
        );
        mocks.startStubbing();
        mocks.when(mockStaticConfigurationsSelector.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(mockStaticConfigurationsSelector.getInstanceValue(HTTP_REQUEST_NAMED_CREDENTIAL))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = HTTP_REQUEST_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    TABLET_HTTP_REQUEST_NAMED_CREDENTIAL
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = TABLET_HTTP_REQUEST_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(mockStaticConfigurationsSelector.getInstanceValue(EMAIL_NAMED_CREDENTIAL))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = EMAIL_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(mockStaticConfigurationsSelector.getInstanceValue(PHOTOSHOOT_NAMED_CREDENTIAL))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = PHOTOSHOOT_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    MX_FRAUD_HTTP_REQUEST_NAMED_CREDENTIAL
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = MX_FRAUD_HTTP_REQUEST_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(
                outboundIntegrationPayloadSrvcMock.collectRecordIdsFromActivationChecklistPayload(
                    new List<String>()
                )
            )
            .thenReturn(
                new Map<String, Set<String>>{ ENTITY_NAME_STORE_ACCOUNT => new Set<String>() }
            );
        mocks.when(
                outboundIntegrationPayloadSrvcMock.collectRecordIdsFromActivationChecklistPayload(
                    new List<String>{ JSON.Serialize(newActivationChecklistWrapper) }
                )
            )
            .thenReturn(
                new Map<String, Set<String>>{
                    ENTITY_NAME_WORK_STEP => new Set<String>{ workStepId }
                }
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        Application.SERVICE.setMock(IWorkStepsService.class, mockWorkStepsService);
        Application.SERVICE.setMock(
            IOutboundIntegrationPayloadService.class,
            outboundIntegrationPayloadSrvcMock
        );
        Test.setMock(
            HttpCalloutMock.class,
            new HttpCalloutMockResponseGenerator(MOCK_RESPONSE, STATUS_CODE_SUCCESS)
        );
        Test.startTest();
        IntegrationOutboundService.sendAPICalloutWithRequestPayload(
            USECASE_NAME_ACTIVATION_CHECKLIST_OUTBOUND_INTEGRATION,
            new List<String>{ JSON.Serialize(newActivationChecklistWrapper) }
        );
        Test.stopTest();
        ((IWorkStepsService) mocks.verify(mockWorkStepsService, 1))
            .updateActivationChecklistWorkStepsStatus(
                new Set<Id>{ workStepId },
                false,
                WORK_STEP_STATUS_IN_PROGRESS
            );
    }

    /**
     * @description To test Log__c record creation when HTTP Callout is failed.
     */
    @isTest
    private static void testWhenHttpCalloutFailedThenCreateErrorLog() {
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        List<ActivationChecklistOutboundWrapper.ActivationChecklistDetails> activationChecklistDetails = new List<ActivationChecklistOutboundWrapper.ActivationChecklistDetails>();
        ActivationChecklistOutboundWrapper.ActivationChecklistDetails mockActivationChecklistDetails = new ActivationChecklistOutboundWrapper.ActivationChecklistDetails();
        mockActivationChecklistDetails.accountSalesforceId = accountId;
        mockActivationChecklistDetails.workStepSalesforceId = workStepId;
        activationChecklistDetails.add(mockActivationChecklistDetails);
        ActivationChecklistOutboundWrapper newActivationChecklistWrapper = new ActivationChecklistOutboundWrapper(
            MOCK_UUID,
            activationChecklistDetails
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IStaticConfigurationsSelector mockStaticConfigurationsSelector = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        IWorkStepsService mockWorkStepsService = (IWorkStepsService) mocks.mock(
            IWorkStepsService.class
        );
        IOutboundIntegrationPayloadService outboundIntegrationPayloadSrvcMock = (IOutboundIntegrationPayloadService) mocks.mock(
            IOutboundIntegrationPayloadService.class
        );
        mocks.startStubbing();
        mocks.when(mockStaticConfigurationsSelector.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(mockStaticConfigurationsSelector.getInstanceValue(HTTP_REQUEST_NAMED_CREDENTIAL))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = HTTP_REQUEST_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    TABLET_HTTP_REQUEST_NAMED_CREDENTIAL
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = TABLET_HTTP_REQUEST_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(mockStaticConfigurationsSelector.getInstanceValue(EMAIL_NAMED_CREDENTIAL))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = EMAIL_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(mockStaticConfigurationsSelector.getInstanceValue(PHOTOSHOOT_NAMED_CREDENTIAL))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = PHOTOSHOOT_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    MX_FRAUD_HTTP_REQUEST_NAMED_CREDENTIAL
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = MX_FRAUD_HTTP_REQUEST_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(
                outboundIntegrationPayloadSrvcMock.collectRecordIdsFromActivationChecklistPayload(
                    new List<String>{ JSON.Serialize(newActivationChecklistWrapper) }
                )
            )
            .thenReturn(
                new Map<String, Set<String>>{
                    ENTITY_NAME_STORE_ACCOUNT => new Set<String>{ accountId }
                }
            );
        mocks.when(
                outboundIntegrationPayloadSrvcMock.collectRecordIdsFromActivationChecklistPayload(
                    new List<String>()
                )
            )
            .thenReturn(
                new Map<String, Set<String>>{ ENTITY_NAME_STORE_ACCOUNT => new Set<String>() }
            );
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        Application.SERVICE.setMock(IWorkStepsService.class, mockWorkStepsService);
        Application.SERVICE.setMock(
            IOutboundIntegrationPayloadService.class,
            outboundIntegrationPayloadSrvcMock
        );
        Test.setMock(
            HttpCalloutMock.class,
            new HttpCalloutMockResponseGenerator(MOCK_RESPONSE, STATUS_CODE_FAILURE)
        );
        Test.startTest();
        IntegrationOutboundService.sendAPICalloutWithRequestPayload(
            USECASE_NAME_ACTIVATION_CHECKLIST_OUTBOUND_INTEGRATION,
            new List<String>{ JSON.Serialize(newActivationChecklistWrapper) }
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Log__c.Class_Name__c => IntegrationOutboundServiceImpl.class.getName(),
                        Log__c.Class_Method_Name__c => LOG_METHOD_NAME,
                        Log__c.Detailed_Message__c => LOG_ERROR_MESSAGE,
                        Log__c.Record_Id__c => accountId
                    }
                )
            );
    }

    /**
     * @description To test HTTP callout is sent when request payloads
     * received for Tablet integration.
     */
    @isTest
    private static void testWhenTabletRequestPayloadReceivedThenSendHttpRequest() {
        Id orderId = fflib_IDGenerator.generate(Mx_Order__c.SObjectType);
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);

        MerchantOrdersPayloads mxOrdersPayloadsInstance = new MerchantOrdersPayloads();
        MerchantOrdersPayloads.MxOrdersOutboundWrapper mxOrdersOutboundWrapperInstance = new MerchantOrdersPayloads.MxOrdersOutboundWrapper();
        MerchantOrdersPayloads.AddressDetails addressDetailsWrapper = new MerchantOrdersPayloads.AddressDetails();
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
        mxOrdersPayloadsInstance.setAddress1(addressDetailsWrapper, SHIPPING_ADDRESS);
        mxOrdersPayloadsInstance.setAddress2(addressDetailsWrapper, SHIPPING_ADDRESS);
        mxOrdersPayloadsInstance.setCity(addressDetailsWrapper, SHIPPING_CITY);
        mxOrdersPayloadsInstance.setPostalCode(addressDetailsWrapper, SHIPPING_POSTAL_CODE);
        mxOrdersPayloadsInstance.setState(addressDetailsWrapper, SHIPPING_STATE_CODE);
        mxOrdersPayloadsInstance.setCountryCode(addressDetailsWrapper, SHIPPING_COUNTRY_CODE);
        mxOrdersPayloadsInstance.setCountry(addressDetailsWrapper, SHIPPING_COUNTRY_CODE);
        mxOrdersPayloadsInstance.setShippingInfo(
            addressDetailsWrapper,
            mxOrdersOutboundWrapperInstance
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStaticConfigurationsSelector mockStaticConfigurationsSelector = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        IInterfaceTransactionsService mockInterfaceTransactionsService = (IInterfaceTransactionsService) mocks.mock(
            IInterfaceTransactionsService.class
        );
        IOutboundIntegrationPayloadService outboundIntegrationPayloadSrvcMock = (IOutboundIntegrationPayloadService) mocks.mock(
            IOutboundIntegrationPayloadService.class
        );
        mocks.startStubbing();
        mocks.when(mockStaticConfigurationsSelector.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(mockStaticConfigurationsSelector.getInstanceValue(HTTP_REQUEST_NAMED_CREDENTIAL))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = HTTP_REQUEST_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    TABLET_HTTP_REQUEST_NAMED_CREDENTIAL
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = TABLET_HTTP_REQUEST_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(mockStaticConfigurationsSelector.getInstanceValue(EMAIL_NAMED_CREDENTIAL))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = EMAIL_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(mockStaticConfigurationsSelector.getInstanceValue(PHOTOSHOOT_NAMED_CREDENTIAL))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = PHOTOSHOOT_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    MX_FRAUD_HTTP_REQUEST_NAMED_CREDENTIAL
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = MX_FRAUD_HTTP_REQUEST_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(
                outboundIntegrationPayloadSrvcMock.collectRecordIdsFromMxOrderPayload(
                    new List<String>()
                )
            )
            .thenReturn(
                new Map<String, Set<String>>{
                    ENTITY_NAME_STORE_ACCOUNT => new Set<String>(),
                    ENTITY_NAME_MX_ORDER => new Set<String>()
                }
            );
        mocks.when(
                outboundIntegrationPayloadSrvcMock.collectRecordIdsFromMxOrderPayload(
                    new List<String>{ JSON.Serialize(newMerchantOrdersWrapper) }
                )
            )
            .thenReturn(
                new Map<String, Set<String>>{ ENTITY_NAME_MX_ORDER => new Set<String>{ orderId } }
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        Application.SERVICE.setMock(
            IInterfaceTransactionsService.class,
            mockInterfaceTransactionsService
        );
        Application.SERVICE.setMock(
            IOutboundIntegrationPayloadService.class,
            outboundIntegrationPayloadSrvcMock
        );
        Test.setMock(
            HttpCalloutMock.class,
            new HttpCalloutMockResponseGenerator(MOCK_RESPONSE, STATUS_CODE_SUCCESS)
        );
        Test.startTest();
        IntegrationOutboundService.sendAPICalloutWithRequestPayload(
            USECASE_NAME_TABLET_OUTBOUND_INTEGRATION,
            new List<String>{ JSON.Serialize(newMerchantOrdersWrapper) }
        );
        Test.stopTest();
        ((IInterfaceTransactionsService) mocks.verify(mockInterfaceTransactionsService, 1))
            .updateInterfaceTransactionStatusByResponse(
                new Set<String>(),
                new Set<String>{ orderId }
            );
    }

    /**
     * @description To test HTTP callout is sent when request payloads received for Email integration.
     */
    @isTest
    private static void testWhenEmailRequestPayloadReceivedThenSendHttpRequest() {
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
        IInterfaceTransactionsService mockInterfaceTransactionsService = (IInterfaceTransactionsService) mocks.mock(
            IInterfaceTransactionsService.class
        );
        IOutboundIntegrationPayloadService outboundIntegrationPayloadSrvcMock = (IOutboundIntegrationPayloadService) mocks.mock(
            IOutboundIntegrationPayloadService.class
        );
        mocks.startStubbing();
        mocks.when(mockStaticConfigurationsSelector.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(mockStaticConfigurationsSelector.getInstanceValue(HTTP_REQUEST_NAMED_CREDENTIAL))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = HTTP_REQUEST_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    TABLET_HTTP_REQUEST_NAMED_CREDENTIAL
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = TABLET_HTTP_REQUEST_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(mockStaticConfigurationsSelector.getInstanceValue(EMAIL_NAMED_CREDENTIAL))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = EMAIL_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(mockStaticConfigurationsSelector.getInstanceValue(PHOTOSHOOT_NAMED_CREDENTIAL))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = PHOTOSHOOT_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    MX_FRAUD_HTTP_REQUEST_NAMED_CREDENTIAL
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = MX_FRAUD_HTTP_REQUEST_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(
                outboundIntegrationPayloadSrvcMock.collectRecordIdsFromEmailPayload(
                    new List<String>()
                )
            )
            .thenReturn(
                new Map<String, Set<String>>{
                    ENTITY_NAME_INTERFACE_TRANSACTION => new Set<String>()
                }
            );
        mocks.when(
                outboundIntegrationPayloadSrvcMock.collectRecordIdsFromEmailPayload(
                    new List<String>{ JSON.Serialize(emailOutboundWrapperInstance) }
                )
            )
            .thenReturn(
                new Map<String, Set<String>>{
                    ENTITY_NAME_INTERFACE_TRANSACTION => new Set<String>{ interfaceTransactionId }
                }
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        Application.SERVICE.setMock(
            IInterfaceTransactionsService.class,
            mockInterfaceTransactionsService
        );
        Application.SERVICE.setMock(
            IOutboundIntegrationPayloadService.class,
            outboundIntegrationPayloadSrvcMock
        );
        Test.setMock(
            HttpCalloutMock.class,
            new HttpCalloutMockResponseGenerator(MOCK_RESPONSE, STATUS_CODE_SUCCESS)
        );
        Test.startTest();
        IntegrationOutboundService.sendAPICalloutWithRequestPayload(
            USECASE_NAME_EMAIL_OUTBOUND_INTEGRATION,
            new List<String>{ JSON.Serialize(emailOutboundWrapperInstance) }
        );
        Test.stopTest();
        ((IInterfaceTransactionsService) mocks.verify(mockInterfaceTransactionsService, 1))
            .updateInterfaceTransactionStatusByOutboundCalloutResponse(
                new Set<String>(),
                new Set<String>{ interfaceTransactionId }
            );
    }

    /**
     * @description To test HTTP callout is sent when request payloads received
     * for 'Failed' Email integration during retry process.
     */
    @isTest
    private static void testWhenRetryEmailRequestPayloadReceivedThenSendHttpRequest() {
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
        List<Interface_Transaction__c> newInterfaceTransaction = new List<Interface_Transaction__c>{
            new Interface_Transaction__c(
                Id = interfaceTransactionId,
                Interface_Transaction_Configuration_Name__c = USECASE_NAME_EMAIL_OUTBOUND_INTEGRATION,
                Payload__c = JSON.serialize(newEmailOutboundDetails)
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStaticConfigurationsSelector mockStaticConfigurationsSelector = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        IInterfaceTransactionSelector mockInterfaceTransactionSelector = (IInterfaceTransactionSelector) mocks.mock(
            IInterfaceTransactionSelector.class
        );
        IInterfaceTransactionsService mockInterfaceTransactionsService = (IInterfaceTransactionsService) mocks.mock(
            IInterfaceTransactionsService.class
        );
        IOutboundIntegrationPayloadService outboundIntegrationPayloadSrvcMock = (IOutboundIntegrationPayloadService) mocks.mock(
            IOutboundIntegrationPayloadService.class
        );
        mocks.startStubbing();
        mocks.when(mockStaticConfigurationsSelector.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(mockStaticConfigurationsSelector.getInstanceValue(HTTP_REQUEST_NAMED_CREDENTIAL))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = HTTP_REQUEST_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(mockInterfaceTransactionSelector.sObjectType())
            .thenReturn(Interface_Transaction__c.SObjectType);
        mocks.when(
                mockInterfaceTransactionSelector.selectById(new Set<Id>{ interfaceTransactionId })
            )
            .thenReturn(newInterfaceTransaction);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    TABLET_HTTP_REQUEST_NAMED_CREDENTIAL
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = TABLET_HTTP_REQUEST_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(mockStaticConfigurationsSelector.getInstanceValue(EMAIL_NAMED_CREDENTIAL))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = EMAIL_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(mockStaticConfigurationsSelector.getInstanceValue(PHOTOSHOOT_NAMED_CREDENTIAL))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = PHOTOSHOOT_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    MX_FRAUD_HTTP_REQUEST_NAMED_CREDENTIAL
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = MX_FRAUD_HTTP_REQUEST_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(
                outboundIntegrationPayloadSrvcMock.generateChunkedPayloadsForEmailIntegration(
                    newInterfaceTransaction
                )
            )
            .thenReturn(new List<String>{ JSON.Serialize(emailOutboundWrapperInstance) });
        mocks.when(
                outboundIntegrationPayloadSrvcMock.collectRecordIdsFromEmailPayload(
                    new List<String>()
                )
            )
            .thenReturn(
                new Map<String, Set<String>>{
                    ENTITY_NAME_INTERFACE_TRANSACTION => new Set<String>()
                }
            );
        mocks.when(
                outboundIntegrationPayloadSrvcMock.collectRecordIdsFromEmailPayload(
                    new List<String>{ JSON.Serialize(emailOutboundWrapperInstance) }
                )
            )
            .thenReturn(
                new Map<String, Set<String>>{
                    ENTITY_NAME_INTERFACE_TRANSACTION => new Set<String>{ interfaceTransactionId }
                }
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        Application.SELECTOR.setMock(mockInterfaceTransactionSelector);
        Application.SERVICE.setMock(
            IInterfaceTransactionsService.class,
            mockInterfaceTransactionsService
        );
        Application.SERVICE.setMock(
            IOutboundIntegrationPayloadService.class,
            outboundIntegrationPayloadSrvcMock
        );
        Test.setMock(
            HttpCalloutMock.class,
            new HttpCalloutMockResponseGenerator(MOCK_RESPONSE, STATUS_CODE_SUCCESS)
        );
        Test.startTest();
        IntegrationOutboundServiceImpl integrationOutboundServiceImplInstance = new IntegrationOutboundServiceImpl();
        integrationOutboundServiceImplInstance.retry(interfaceTransactionId);
        Test.stopTest();
        ((IInterfaceTransactionsService) mocks.verify(mockInterfaceTransactionsService, 1))
            .updateInterfaceTransactionStatusByOutboundCalloutResponse(
                new Set<String>(),
                new Set<String>{ interfaceTransactionId }
            );
    }

    /**
     * @description To test HTTP callout is sent when request payloads received for Photoshoot integration.
     */
    @isTest
    private static void testWhenPhotoshootRequestPayloadReceivedThenSendHttpRequest() {
        Id orderId = fflib_IDGenerator.generate(Mx_Order__c.SObjectType);
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);

        MerchantOrdersPayloads mxOrdersPayloadsInstance = new MerchantOrdersPayloads();
        MerchantOrdersPayloads.PhotoshootMxOrdersOutboundWrapper mxOrdersOutboundWrapperInstance = new MerchantOrdersPayloads.PhotoshootMxOrdersOutboundWrapper();
        MerchantOrdersPayloads.AddressDetails addressDetailsWrapper = new MerchantOrdersPayloads.AddressDetails();
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
        mxOrdersPayloadsInstance.setAddress1(addressDetailsWrapper, SHIPPING_ADDRESS);
        mxOrdersPayloadsInstance.setAddress2(addressDetailsWrapper, SHIPPING_ADDRESS);
        mxOrdersPayloadsInstance.setCity(addressDetailsWrapper, SHIPPING_CITY);
        mxOrdersPayloadsInstance.setPostalCode(addressDetailsWrapper, SHIPPING_POSTAL_CODE);
        mxOrdersPayloadsInstance.setState(addressDetailsWrapper, SHIPPING_STATE_CODE);
        mxOrdersPayloadsInstance.setCountryCode(addressDetailsWrapper, SHIPPING_COUNTRY_CODE);
        mxOrdersPayloadsInstance.setCountry(addressDetailsWrapper, SHIPPING_COUNTRY_CODE);
        mxOrdersPayloadsInstance.setLatitude(addressDetailsWrapper, SHIPPING_LATITUDE);
        mxOrdersPayloadsInstance.setLongitude(addressDetailsWrapper, SHIPPING_LONGITUDE);
        mxOrdersPayloadsInstance.setAddressNotes(addressDetailsWrapper, SHIPPING_NOTES);
        mxOrdersPayloadsInstance.setPhotoshootStoreInfo(
            addressDetailsWrapper,
            mxOrdersOutboundWrapperInstance
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStaticConfigurationsSelector mockStaticConfigurationsSelector = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        IInterfaceTransactionsService mockInterfaceTransactionsService = (IInterfaceTransactionsService) mocks.mock(
            IInterfaceTransactionsService.class
        );
        IOutboundIntegrationPayloadService outboundIntegrationPayloadSrvcMock = (IOutboundIntegrationPayloadService) mocks.mock(
            IOutboundIntegrationPayloadService.class
        );
        mocks.startStubbing();
        mocks.when(mockStaticConfigurationsSelector.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(mockStaticConfigurationsSelector.getInstanceValue(HTTP_REQUEST_NAMED_CREDENTIAL))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = HTTP_REQUEST_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    TABLET_HTTP_REQUEST_NAMED_CREDENTIAL
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = TABLET_HTTP_REQUEST_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(mockStaticConfigurationsSelector.getInstanceValue(EMAIL_NAMED_CREDENTIAL))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = EMAIL_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(mockStaticConfigurationsSelector.getInstanceValue(PHOTOSHOOT_NAMED_CREDENTIAL))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = PHOTOSHOOT_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    MX_FRAUD_HTTP_REQUEST_NAMED_CREDENTIAL
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = MX_FRAUD_HTTP_REQUEST_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(
                outboundIntegrationPayloadSrvcMock.collectRecordIdsFromPhotoshootMxOrderPayload(
                    new List<String>()
                )
            )
            .thenReturn(
                new Map<String, Set<String>>{
                    ENTITY_NAME_STORE_ACCOUNT => new Set<String>(),
                    ENTITY_NAME_MX_ORDER => new Set<String>()
                }
            );
        mocks.when(
                outboundIntegrationPayloadSrvcMock.collectRecordIdsFromPhotoshootMxOrderPayload(
                    new List<String>{ JSON.Serialize(newMerchantOrdersWrapper) }
                )
            )
            .thenReturn(
                new Map<String, Set<String>>{ ENTITY_NAME_MX_ORDER => new Set<String>{ orderId } }
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        Application.SERVICE.setMock(
            IInterfaceTransactionsService.class,
            mockInterfaceTransactionsService
        );
        Application.SERVICE.setMock(
            IOutboundIntegrationPayloadService.class,
            outboundIntegrationPayloadSrvcMock
        );
        Test.setMock(
            HttpCalloutMock.class,
            new HttpCalloutMockResponseGenerator(MOCK_RESPONSE, STATUS_CODE_SUCCESS)
        );
        Test.startTest();
        IntegrationOutboundService.sendAPICalloutWithRequestPayload(
            USECASE_NAME_PHOTOSHOOT_OUTBOUND_INTEGRATION,
            new List<String>{ JSON.Serialize(newMerchantOrdersWrapper) }
        );
        Test.stopTest();
        ((IInterfaceTransactionsService) mocks.verify(mockInterfaceTransactionsService, 1))
            .updateInterfaceTransactionStatusByResponse(
                new Set<String>(),
                new Set<String>{ orderId }
            );
    }

    /**
     * @description To test HTTP callout is sent when request payloads received
     * for 'Failed' Photoshoot integration during retry process.
     */
    @isTest
    private static void testWhenRetryPhotoshootRequestPayloadReceivedThenSendHttpRequest() {
        Id interfaceTransactionId = fflib_IDGenerator.generate(
            Interface_Transaction__c.SObjectType
        );
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

        List<Interface_Transaction__c> newInterfaceTransaction = new List<Interface_Transaction__c>{
            new Interface_Transaction__c(
                Id = interfaceTransactionId,
                Interface_Transaction_Configuration_Name__c = USECASE_NAME_PHOTOSHOOT_OUTBOUND_INTEGRATION,
                Payload__c = JSON.serialize(mxOrdersOutboundWrapperInstance)
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStaticConfigurationsSelector mockStaticConfigurationsSelector = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        IInterfaceTransactionSelector mockInterfaceTransactionSelector = (IInterfaceTransactionSelector) mocks.mock(
            IInterfaceTransactionSelector.class
        );
        IOnboardingActivationsEventsService onboardingActivationsEventsSrvcMock = (IOnboardingActivationsEventsService) mocks.mock(
            IOnboardingActivationsEventsService.class
        );
        mocks.startStubbing();
        mocks.when(mockStaticConfigurationsSelector.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(mockStaticConfigurationsSelector.getInstanceValue(HTTP_REQUEST_NAMED_CREDENTIAL))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = HTTP_REQUEST_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(mockInterfaceTransactionSelector.sObjectType())
            .thenReturn(Interface_Transaction__c.SObjectType);
        mocks.when(
                mockInterfaceTransactionSelector.selectById(new Set<Id>{ interfaceTransactionId })
            )
            .thenReturn(newInterfaceTransaction);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    TABLET_HTTP_REQUEST_NAMED_CREDENTIAL
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = TABLET_HTTP_REQUEST_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(mockStaticConfigurationsSelector.getInstanceValue(EMAIL_NAMED_CREDENTIAL))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = EMAIL_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(mockStaticConfigurationsSelector.getInstanceValue(PHOTOSHOOT_NAMED_CREDENTIAL))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = PHOTOSHOOT_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    MX_FRAUD_HTTP_REQUEST_NAMED_CREDENTIAL
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = MX_FRAUD_HTTP_REQUEST_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        Application.SELECTOR.setMock(mockInterfaceTransactionSelector);
        Application.SERVICE.setMock(
            IOnboardingActivationsEventsService.class,
            onboardingActivationsEventsSrvcMock
        );
        Test.setMock(
            HttpCalloutMock.class,
            new HttpCalloutMockResponseGenerator(MOCK_RESPONSE, STATUS_CODE_SUCCESS)
        );
        Test.startTest();
        IntegrationOutboundServiceImpl integrationOutboundServiceImplInstance = new IntegrationOutboundServiceImpl();
        integrationOutboundServiceImplInstance.retry(interfaceTransactionId);
        Test.stopTest();
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            Map<String, List<String>>.class
        );
        ((IOnboardingActivationsEventsService) mocks.verify(onboardingActivationsEventsSrvcMock, 1))
            .publishBulkEvents((Map<String, List<String>>) capturedInsertUOWArguments.capture());
        Map<String, List<String>> capturedArguments = (Map<String, List<String>>) capturedInsertUOWArguments.getValue();
        System.assertEquals(
            1,
            capturedArguments.get(EVENT_TOPIC_ORDER_RETRY_CALLOUT_BATCH).size(),
            COUNT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test HTTP callout is sent when request payloads received
     * for 'Failed' Tablet integration during retry process.
     */
    @isTest
    private static void testWhenRetryTabletRequestPayloadReceivedThenSendHttpRequest() {
        Id interfaceTransactionId = fflib_IDGenerator.generate(
            Interface_Transaction__c.SObjectType
        );
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

        List<Interface_Transaction__c> newInterfaceTransaction = new List<Interface_Transaction__c>{
            new Interface_Transaction__c(
                Id = interfaceTransactionId,
                Interface_Transaction_Configuration_Name__c = USECASE_NAME_TABLET_OUTBOUND_INTEGRATION,
                Payload__c = JSON.serialize(mxOrdersOutboundWrapperInstance)
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStaticConfigurationsSelector mockStaticConfigurationsSelector = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        IInterfaceTransactionSelector mockInterfaceTransactionSelector = (IInterfaceTransactionSelector) mocks.mock(
            IInterfaceTransactionSelector.class
        );
        IOnboardingActivationsEventsService onboardingActivationsEventsSrvcMock = (IOnboardingActivationsEventsService) mocks.mock(
            IOnboardingActivationsEventsService.class
        );
        mocks.startStubbing();
        mocks.when(mockStaticConfigurationsSelector.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(mockStaticConfigurationsSelector.getInstanceValue(HTTP_REQUEST_NAMED_CREDENTIAL))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = HTTP_REQUEST_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(mockInterfaceTransactionSelector.sObjectType())
            .thenReturn(Interface_Transaction__c.SObjectType);
        mocks.when(
                mockInterfaceTransactionSelector.selectById(new Set<Id>{ interfaceTransactionId })
            )
            .thenReturn(newInterfaceTransaction);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    TABLET_HTTP_REQUEST_NAMED_CREDENTIAL
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = TABLET_HTTP_REQUEST_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(mockStaticConfigurationsSelector.getInstanceValue(EMAIL_NAMED_CREDENTIAL))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = EMAIL_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(mockStaticConfigurationsSelector.getInstanceValue(PHOTOSHOOT_NAMED_CREDENTIAL))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = PHOTOSHOOT_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    MX_FRAUD_HTTP_REQUEST_NAMED_CREDENTIAL
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = MX_FRAUD_HTTP_REQUEST_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        Application.SELECTOR.setMock(mockInterfaceTransactionSelector);
        Application.SERVICE.setMock(
            IOnboardingActivationsEventsService.class,
            onboardingActivationsEventsSrvcMock
        );
        Test.setMock(
            HttpCalloutMock.class,
            new HttpCalloutMockResponseGenerator(MOCK_RESPONSE, STATUS_CODE_SUCCESS)
        );
        Test.startTest();
        IntegrationOutboundServiceImpl integrationOutboundServiceImplInstance = new IntegrationOutboundServiceImpl();
        integrationOutboundServiceImplInstance.retry(interfaceTransactionId);
        Test.stopTest();
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            Map<String, List<String>>.class
        );
        ((IOnboardingActivationsEventsService) mocks.verify(onboardingActivationsEventsSrvcMock, 1))
            .publishBulkEvents((Map<String, List<String>>) capturedInsertUOWArguments.capture());
        Map<String, List<String>> capturedArguments = (Map<String, List<String>>) capturedInsertUOWArguments.getValue();
        System.assertEquals(
            1,
            capturedArguments.get(EVENT_TOPIC_ORDER_RETRY_CALLOUT_BATCH).size(),
            COUNT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test platform event is triggered to send HTTP callout when request payloads
     * received for 'Failed' Tablet integration during manual retry process.
     */
    @isTest
    private static void testWhenManualReattemptTabletRequestPayloadReceivedThenSendHttpRequest() {
        Id interfaceTransactionId = fflib_IDGenerator.generate(
            Interface_Transaction__c.SObjectType
        );

        List<Interface_Transaction__c> newInterfaceTransaction = new List<Interface_Transaction__c>{
            new Interface_Transaction__c(Id = interfaceTransactionId)
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStaticConfigurationsSelector mockStaticConfigurationsSelector = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        INotifierEventsPayloadGenerationService notifierEventsPayloadSrvcMock = (INotifierEventsPayloadGenerationService) mocks.mock(
            INotifierEventsPayloadGenerationService.class
        );
        IOnboardingActivationsEventsService onboardingActivationsEventsSrvcMock = (IOnboardingActivationsEventsService) mocks.mock(
            IOnboardingActivationsEventsService.class
        );
        mocks.startStubbing();
        mocks.when(mockStaticConfigurationsSelector.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(mockStaticConfigurationsSelector.getInstanceValue(HTTP_REQUEST_NAMED_CREDENTIAL))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = HTTP_REQUEST_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    TABLET_HTTP_REQUEST_NAMED_CREDENTIAL
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = TABLET_HTTP_REQUEST_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(mockStaticConfigurationsSelector.getInstanceValue(EMAIL_NAMED_CREDENTIAL))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = EMAIL_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(mockStaticConfigurationsSelector.getInstanceValue(PHOTOSHOOT_NAMED_CREDENTIAL))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = PHOTOSHOOT_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    MX_FRAUD_HTTP_REQUEST_NAMED_CREDENTIAL
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = MX_FRAUD_HTTP_REQUEST_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(
                notifierEventsPayloadSrvcMock.generateChunkedPayloadsBySobjectIds(
                    new Set<Id>{ newInterfaceTransaction[0].Id },
                    5
                )
            )
            .thenReturn(new List<String>{ newInterfaceTransaction[0].Id });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        Application.SERVICE.setMock(
            IOnboardingActivationsEventsService.class,
            onboardingActivationsEventsSrvcMock
        );
        Test.setMock(
            HttpCalloutMock.class,
            new HttpCalloutMockResponseGenerator(MOCK_RESPONSE, STATUS_CODE_SUCCESS)
        );
        Test.startTest();
        IntegrationOutboundService.retryInterfaceTransactions(
            new List<String>{ newInterfaceTransaction[0].Id }
        );
        Test.stopTest();
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            Map<String, List<String>>.class
        );
        ((IOnboardingActivationsEventsService) mocks.verify(onboardingActivationsEventsSrvcMock, 1))
            .publishBulkEvents((Map<String, List<String>>) capturedInsertUOWArguments.capture());
        Map<String, List<String>> capturedArguments = (Map<String, List<String>>) capturedInsertUOWArguments.getValue();
        System.assertEquals(
            1,
            capturedArguments.get(EVENT_TOPIC_ORDER_RETRY_CALLOUT).size(),
            COUNT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test HTTP callout is sent when onboarding events received
     * for 'Failed' Tablet integration during batch retry process.
     */
    @isTest
    private static void testWhenBatchRetryOnboardingEventReceivedThenSendHttpRequest() {
        Id interfaceTransactionId = fflib_IDGenerator.generate(
            Interface_Transaction__c.SObjectType
        );
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

        List<Interface_Transaction__c> newInterfaceTransaction = new List<Interface_Transaction__c>{
            new Interface_Transaction__c(
                Id = interfaceTransactionId,
                Interface_Transaction_Configuration_Name__c = USECASE_NAME_TABLET_OUTBOUND_INTEGRATION,
                Payload__c = JSON.serialize(mxOrdersOutboundWrapperInstance)
            )
        };
        List<Onboarding_Activation__e> onboardingActivationsEvents = new List<Onboarding_Activation__e>{
            new Onboarding_Activation__e(
                Topic__c = EVENT_TOPIC_ORDER_RETRY_CALLOUT_BATCH,
                Payload__c = JSON.serialize(new Set<Id>{ interfaceTransactionId })
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStaticConfigurationsSelector mockStaticConfigurationsSelector = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        IInterfaceTransactionSelector mockInterfaceTransactionSelector = (IInterfaceTransactionSelector) mocks.mock(
            IInterfaceTransactionSelector.class
        );
        IInterfaceTransactionsService mockInterfaceTransactionsService = (IInterfaceTransactionsService) mocks.mock(
            IInterfaceTransactionsService.class
        );
        IOutboundIntegrationPayloadService outboundIntegrationPayloadSrvcMock = (IOutboundIntegrationPayloadService) mocks.mock(
            IOutboundIntegrationPayloadService.class
        );
        mocks.startStubbing();
        mocks.when(mockStaticConfigurationsSelector.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(mockStaticConfigurationsSelector.getInstanceValue(HTTP_REQUEST_NAMED_CREDENTIAL))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = HTTP_REQUEST_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(mockInterfaceTransactionSelector.sObjectType())
            .thenReturn(Interface_Transaction__c.SObjectType);
        mocks.when(
                mockInterfaceTransactionSelector.selectById(new Set<Id>{ interfaceTransactionId })
            )
            .thenReturn(newInterfaceTransaction);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    TABLET_HTTP_REQUEST_NAMED_CREDENTIAL
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = TABLET_HTTP_REQUEST_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(mockStaticConfigurationsSelector.getInstanceValue(EMAIL_NAMED_CREDENTIAL))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = EMAIL_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(mockStaticConfigurationsSelector.getInstanceValue(PHOTOSHOOT_NAMED_CREDENTIAL))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = PHOTOSHOOT_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    MX_FRAUD_HTTP_REQUEST_NAMED_CREDENTIAL
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = MX_FRAUD_HTTP_REQUEST_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(
                outboundIntegrationPayloadSrvcMock.generateChunkedPayloadsForMxOrderIntegration(
                    newInterfaceTransaction
                )
            )
            .thenReturn(new List<String>{ JSON.Serialize(newMerchantOrdersWrapper) });
        mocks.when(
                outboundIntegrationPayloadSrvcMock.collectRecordIdsFromMxOrderPayload(
                    new List<String>()
                )
            )
            .thenReturn(
                new Map<String, Set<String>>{
                    ENTITY_NAME_STORE_ACCOUNT => new Set<String>(),
                    ENTITY_NAME_MX_ORDER => new Set<String>()
                }
            );
        mocks.when(
                outboundIntegrationPayloadSrvcMock.collectRecordIdsFromMxOrderPayload(
                    new List<String>{ JSON.Serialize(newMerchantOrdersWrapper) }
                )
            )
            .thenReturn(
                new Map<String, Set<String>>{ ENTITY_NAME_MX_ORDER => new Set<String>{ orderId } }
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        Application.SELECTOR.setMock(mockInterfaceTransactionSelector);
        Application.SERVICE.setMock(
            IInterfaceTransactionsService.class,
            mockInterfaceTransactionsService
        );
        Application.SERVICE.setMock(
            IOutboundIntegrationPayloadService.class,
            outboundIntegrationPayloadSrvcMock
        );
        Test.setMock(
            HttpCalloutMock.class,
            new HttpCalloutMockResponseGenerator(MOCK_RESPONSE, STATUS_CODE_SUCCESS)
        );
        Test.startTest();
        IntegrationOutboundService.execute(onboardingActivationsEvents);
        Test.stopTest();
        ((IInterfaceTransactionsService) mocks.verify(mockInterfaceTransactionsService, 1))
            .updateInterfaceTransactionStatusByResponse(
                new Set<String>(),
                new Set<String>{ orderId }
            );
    }

    /**
     * @description To test HTTP callout is sent when onboarding events received
     * for 'Failed' Tablet integration during manual retry process.
     */
    @isTest
    private static void testWhenManualRetryOnboardingEventReceivedThenSendHttpRequest() {
        Id interfaceTransactionId = fflib_IDGenerator.generate(
            Interface_Transaction__c.SObjectType
        );
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

        List<Interface_Transaction__c> newInterfaceTransaction = new List<Interface_Transaction__c>{
            new Interface_Transaction__c(
                Id = interfaceTransactionId,
                Interface_Transaction_Configuration_Name__c = USECASE_NAME_TABLET_OUTBOUND_INTEGRATION,
                Payload__c = JSON.serialize(mxOrdersOutboundWrapperInstance)
            )
        };
        List<Onboarding_Activation__e> onboardingActivationsEvents = new List<Onboarding_Activation__e>{
            new Onboarding_Activation__e(
                Topic__c = EVENT_TOPIC_ORDER_RETRY_CALLOUT,
                Payload__c = JSON.serialize(new Set<Id>{ interfaceTransactionId })
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStaticConfigurationsSelector mockStaticConfigurationsSelector = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        IInterfaceTransactionSelector mockInterfaceTransactionSelector = (IInterfaceTransactionSelector) mocks.mock(
            IInterfaceTransactionSelector.class
        );
        IInterfaceTransactionsService mockInterfaceTransactionsService = (IInterfaceTransactionsService) mocks.mock(
            IInterfaceTransactionsService.class
        );
        IOutboundIntegrationPayloadService outboundIntegrationPayloadSrvcMock = (IOutboundIntegrationPayloadService) mocks.mock(
            IOutboundIntegrationPayloadService.class
        );
        mocks.startStubbing();
        mocks.when(mockStaticConfigurationsSelector.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(mockStaticConfigurationsSelector.getInstanceValue(HTTP_REQUEST_NAMED_CREDENTIAL))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = HTTP_REQUEST_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(mockInterfaceTransactionSelector.sObjectType())
            .thenReturn(Interface_Transaction__c.SObjectType);
        mocks.when(
                mockInterfaceTransactionSelector.selectById(new Set<Id>{ interfaceTransactionId })
            )
            .thenReturn(newInterfaceTransaction);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    TABLET_HTTP_REQUEST_NAMED_CREDENTIAL
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = TABLET_HTTP_REQUEST_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(mockStaticConfigurationsSelector.getInstanceValue(EMAIL_NAMED_CREDENTIAL))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = EMAIL_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(mockStaticConfigurationsSelector.getInstanceValue(PHOTOSHOOT_NAMED_CREDENTIAL))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = PHOTOSHOOT_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    MX_FRAUD_HTTP_REQUEST_NAMED_CREDENTIAL
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = MX_FRAUD_HTTP_REQUEST_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(
                outboundIntegrationPayloadSrvcMock.generateChunkedPayloadsForMxOrderIntegration(
                    newInterfaceTransaction
                )
            )
            .thenReturn(new List<String>{ JSON.Serialize(newMerchantOrdersWrapper) });
        mocks.when(
                outboundIntegrationPayloadSrvcMock.collectRecordIdsFromMxOrderPayload(
                    new List<String>()
                )
            )
            .thenReturn(
                new Map<String, Set<String>>{
                    ENTITY_NAME_STORE_ACCOUNT => new Set<String>(),
                    ENTITY_NAME_MX_ORDER => new Set<String>()
                }
            );
        mocks.when(
                outboundIntegrationPayloadSrvcMock.collectRecordIdsFromMxOrderPayload(
                    new List<String>{ JSON.Serialize(newMerchantOrdersWrapper) }
                )
            )
            .thenReturn(
                new Map<String, Set<String>>{ ENTITY_NAME_MX_ORDER => new Set<String>{ orderId } }
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        Application.SELECTOR.setMock(mockInterfaceTransactionSelector);
        Application.SERVICE.setMock(
            IInterfaceTransactionsService.class,
            mockInterfaceTransactionsService
        );
        Application.SERVICE.setMock(
            IOutboundIntegrationPayloadService.class,
            outboundIntegrationPayloadSrvcMock
        );
        Test.setMock(
            HttpCalloutMock.class,
            new HttpCalloutMockResponseGenerator(MOCK_RESPONSE, STATUS_CODE_SUCCESS)
        );
        Test.startTest();
        IntegrationOutboundService.execute(onboardingActivationsEvents);
        Test.stopTest();
        ((IInterfaceTransactionsService) mocks.verify(mockInterfaceTransactionsService, 1))
            .updateInterfaceTransactionStatusByResponse(
                new Set<String>(),
                new Set<String>{ orderId }
            );
    }

    /**
     * @description To test HTTP callout is sent when request payloads received for MxFraud integration.
     */
    @isTest
    private static void testWhenMxFraudPayloadReceivedThenSendHttpRequest() {
        Id interfaceTransactionId = fflib_IDGenerator.generate(
            Interface_Transaction__c.SObjectType
        );
        MxFraudDocumentsPayloads mxFraudDocumentsPayloadsInstance = new MxFraudDocumentsPayloads();
        MxFraudDocumentsPayloads.MxFraudDocumentDetails mxFraudDocumentDetailsInstance = new MxFraudDocumentsPayloads.MxFraudDocumentDetails(
            MOCK_UUID
        );
        mxFraudDocumentsPayloadsInstance.setInterfaceTransactionSFID(
            mxFraudDocumentDetailsInstance,
            String.valueOf(interfaceTransactionId)
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStaticConfigurationsSelector mockStaticConfigurationsSelector = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        IInterfaceTransactionsService mockInterfaceTransactionsService = (IInterfaceTransactionsService) mocks.mock(
            IInterfaceTransactionsService.class
        );
        IOutboundIntegrationPayloadService outboundIntegrationPayloadSrvcMock = (IOutboundIntegrationPayloadService) mocks.mock(
            IOutboundIntegrationPayloadService.class
        );
        mocks.startStubbing();
        mocks.when(mockStaticConfigurationsSelector.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(mockStaticConfigurationsSelector.getInstanceValue(HTTP_REQUEST_NAMED_CREDENTIAL))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = HTTP_REQUEST_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    TABLET_HTTP_REQUEST_NAMED_CREDENTIAL
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = TABLET_HTTP_REQUEST_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(mockStaticConfigurationsSelector.getInstanceValue(EMAIL_NAMED_CREDENTIAL))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = EMAIL_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(mockStaticConfigurationsSelector.getInstanceValue(PHOTOSHOOT_NAMED_CREDENTIAL))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = PHOTOSHOOT_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    MX_FRAUD_HTTP_REQUEST_NAMED_CREDENTIAL
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = MX_FRAUD_HTTP_REQUEST_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(
                outboundIntegrationPayloadSrvcMock.collectRecordIdsFromMxFraudPayload(
                    new List<String>()
                )
            )
            .thenReturn(
                new Map<String, Set<String>>{
                    ENTITY_NAME_INTERFACE_TRANSACTION => new Set<String>()
                }
            );
        mocks.when(
                outboundIntegrationPayloadSrvcMock.collectRecordIdsFromMxFraudPayload(
                    new List<String>{ JSON.Serialize(mxFraudDocumentDetailsInstance) }
                )
            )
            .thenReturn(
                new Map<String, Set<String>>{
                    ENTITY_NAME_INTERFACE_TRANSACTION => new Set<String>{ interfaceTransactionId }
                }
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        Application.SERVICE.setMock(
            IInterfaceTransactionsService.class,
            mockInterfaceTransactionsService
        );
        Application.SERVICE.setMock(
            IOutboundIntegrationPayloadService.class,
            outboundIntegrationPayloadSrvcMock
        );
        Test.setMock(
            HttpCalloutMock.class,
            new HttpCalloutMockResponseGenerator(MOCK_RESPONSE, STATUS_CODE_SUCCESS)
        );
        Test.startTest();
        IntegrationOutboundService.sendAPICalloutWithRequestPayload(
            USECASE_NAME_MX_FRAUD_OUTBOUND_INTEGRATION,
            new List<String>{ JSON.Serialize(mxFraudDocumentDetailsInstance) }
        );
        Test.stopTest();
        ((IInterfaceTransactionsService) mocks.verify(mockInterfaceTransactionsService, 1))
            .updateInterfaceTransactionStatusByOutboundCalloutResponse(
                new Set<String>(),
                new Set<String>{ interfaceTransactionId }
            );
    }

    /**
     * @description To test HTTP callout is sent when request payloads received
     * for 'Failed' Mx Fraud integration during retry process.
     */
    @isTest
    private static void testWhenRetryMxFraudRequestPayloadReceivedThenSendHttpRequest() {
        Id interfaceTransactionId = fflib_IDGenerator.generate(
            Interface_Transaction__c.SObjectType
        );
        MxFraudDocumentsPayloads mxFraudDocumentsPayloadsInstance = new MxFraudDocumentsPayloads();
        MxFraudDocumentsPayloads.MxFraudDocumentDetails mxFraudDocumentDetailsInstance = new MxFraudDocumentsPayloads.MxFraudDocumentDetails(
            MOCK_UUID
        );
        mxFraudDocumentsPayloadsInstance.setInterfaceTransactionSFID(
            mxFraudDocumentDetailsInstance,
            String.valueOf(interfaceTransactionId)
        );
        List<Interface_Transaction__c> newInterfaceTransaction = new List<Interface_Transaction__c>{
            new Interface_Transaction__c(
                Id = interfaceTransactionId,
                Interface_Transaction_Configuration_Name__c = USECASE_NAME_MX_FRAUD_OUTBOUND_INTEGRATION,
                Payload__c = JSON.serialize(mxFraudDocumentDetailsInstance)
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStaticConfigurationsSelector mockStaticConfigurationsSelector = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        IInterfaceTransactionSelector mockInterfaceTransactionSelector = (IInterfaceTransactionSelector) mocks.mock(
            IInterfaceTransactionSelector.class
        );
        IInterfaceTransactionsService mockInterfaceTransactionsService = (IInterfaceTransactionsService) mocks.mock(
            IInterfaceTransactionsService.class
        );
        IOutboundIntegrationPayloadService outboundIntegrationPayloadSrvcMock = (IOutboundIntegrationPayloadService) mocks.mock(
            IOutboundIntegrationPayloadService.class
        );
        mocks.startStubbing();
        mocks.when(mockStaticConfigurationsSelector.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(mockStaticConfigurationsSelector.getInstanceValue(HTTP_REQUEST_NAMED_CREDENTIAL))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = HTTP_REQUEST_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(mockInterfaceTransactionSelector.sObjectType())
            .thenReturn(Interface_Transaction__c.SObjectType);
        mocks.when(
                mockInterfaceTransactionSelector.selectById(new Set<Id>{ interfaceTransactionId })
            )
            .thenReturn(newInterfaceTransaction);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    TABLET_HTTP_REQUEST_NAMED_CREDENTIAL
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = TABLET_HTTP_REQUEST_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(mockStaticConfigurationsSelector.getInstanceValue(EMAIL_NAMED_CREDENTIAL))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = EMAIL_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(mockStaticConfigurationsSelector.getInstanceValue(PHOTOSHOOT_NAMED_CREDENTIAL))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = PHOTOSHOOT_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    MX_FRAUD_HTTP_REQUEST_NAMED_CREDENTIAL
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = MX_FRAUD_HTTP_REQUEST_NAMED_CREDENTIAL,
                    Configuration_Value__c = MOCK_NAMED_CREDENTIAL
                )
            );
        mocks.when(
                outboundIntegrationPayloadSrvcMock.generateChunkedPayloadsForMxFraudDocumentsIntegration(
                    newInterfaceTransaction
                )
            )
            .thenReturn(new List<String>{ JSON.Serialize(mxFraudDocumentDetailsInstance) });
        mocks.when(
                outboundIntegrationPayloadSrvcMock.collectRecordIdsFromMxFraudPayload(
                    new List<String>()
                )
            )
            .thenReturn(
                new Map<String, Set<String>>{
                    ENTITY_NAME_INTERFACE_TRANSACTION => new Set<String>()
                }
            );
        mocks.when(
                outboundIntegrationPayloadSrvcMock.collectRecordIdsFromMxFraudPayload(
                    new List<String>{ JSON.Serialize(mxFraudDocumentDetailsInstance) }
                )
            )
            .thenReturn(
                new Map<String, Set<String>>{
                    ENTITY_NAME_INTERFACE_TRANSACTION => new Set<String>{ interfaceTransactionId }
                }
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        Application.SELECTOR.setMock(mockInterfaceTransactionSelector);
        Application.SERVICE.setMock(
            IInterfaceTransactionsService.class,
            mockInterfaceTransactionsService
        );
        Application.SERVICE.setMock(
            IOutboundIntegrationPayloadService.class,
            outboundIntegrationPayloadSrvcMock
        );
        Test.setMock(
            HttpCalloutMock.class,
            new HttpCalloutMockResponseGenerator(MOCK_RESPONSE, STATUS_CODE_SUCCESS)
        );
        Test.startTest();
        IntegrationOutboundServiceImpl integrationOutboundServiceImplInstance = new IntegrationOutboundServiceImpl();
        integrationOutboundServiceImplInstance.retry(interfaceTransactionId);
        Test.stopTest();
        ((IInterfaceTransactionsService) mocks.verify(mockInterfaceTransactionsService, 1))
            .updateInterfaceTransactionStatusByOutboundCalloutResponse(
                new Set<String>(),
                new Set<String>{ interfaceTransactionId }
            );
    }
}