/**
 * @author Deloitte
 * @date 04/05/2024
 * @description Test class for Activation Checklist Service Implementation Test.
 */
@isTest(seeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class ActivationChecklistServiceImplTest {
    private static final String ACTIVATION_CHECKLIST_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG = 'Activations_Checklist_Payload_Chunk_Size';
    private static final String ACTIVATION_CHECKLIST_VALIDATIONS_STATIC_CONFIG = 'Activations_Checklist_Validations';
    private static final String CHILD_WORK_STEPS_TO_UPDATE_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG = 'Child_Work_Steps_Payload_Chunk_Size';
    private static final String COUNT_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: Argument count does not match';
    private static final String DASH_SPLIT = '-';
    private static final String EVENT_TOPIC = 'CREATE_ACTIVATION_CHECKLIST';
    private static final String EVENT_TOPIC_ACTIVATION_CHECKLIST_OUTBOUND_INTEGRATION = 'ACTIVATION_CHECKLIST_OUTBOUND_INTEGRATION';
    private static final String INTEGRATION_TYPE_ACTIVATION_CHECKLIST = 'Activation Checklist';
    private static final String METADATA_VALUE = '5';
    private static final String MOCK_PAYLOAD_ACCOUNT_ID = '001O100000BquksIAB-MockId';
    private static final String STATIC_RESOURCE_TEST_JSON = 'Activation_Checklist_Inbound_Payload_TestData';
    private static final String WORK_STEP_STATUS_ROLLUP_RETRY_LIMIT_STATIC_CONFIG = 'Work_Step_Status_Rollup_Retry_Limit';
    /**
     * @description To test when create Activation Checklist event received
     * then initiate Activation Checklist creation.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOnboardingActivationsEventsReceivedThenSetFlag() {
        StaticResource sr = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_JSON
        ];
        Blob blobJSON = sr.Body;
        String payloadString = blobJSON.toString();
        Id integrationRequestId = fflib_IDGenerator.generate(Integration_Request__c.SObjectType);
        Integration_Request__c[] newIntegrationRequest = new List<Integration_Request__c>{
            new Integration_Request__c(
                Id = integrationRequestId,
                Integration_Type__c = INTEGRATION_TYPE_ACTIVATION_CHECKLIST,
                Payload__c = payloadString
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IActivationChecklistValidationService activationCheckValidationsServiceMock = (IActivationChecklistValidationService) mocks.mock(
            IActivationChecklistValidationService.class
        );
        IIntegrationRequestsSelector mockIntegrationRequestsSelector = (IIntegrationRequestsSelector) mocks.mock(
            IIntegrationRequestsSelector.class
        );
        IStaticConfigurationsSelector mockStaticConfigurationsSelector = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                mockAccountsSelector.selectById(
                    new Set<String>{ (Id) MOCK_PAYLOAD_ACCOUNT_ID.substringBefore(DASH_SPLIT) }
                )
            )
            .thenReturn(
                new List<Account>{
                    new Account(Id = (Id) MOCK_PAYLOAD_ACCOUNT_ID.substringBefore(DASH_SPLIT))
                }
            );
        mocks.when(mockIntegrationRequestsSelector.sObjectType())
            .thenReturn(Integration_Request__c.SObjectType);
        mocks.when(
                mockIntegrationRequestsSelector.selectById(
                    new Set<Id>{ newIntegrationRequest[0].Id }
                )
            )
            .thenReturn(newIntegrationRequest);
        mocks.when(mockStaticConfigurationsSelector.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    ACTIVATION_CHECKLIST_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = ACTIVATION_CHECKLIST_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    WORK_STEP_STATUS_ROLLUP_RETRY_LIMIT_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = WORK_STEP_STATUS_ROLLUP_RETRY_LIMIT_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    CHILD_WORK_STEPS_TO_UPDATE_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = CHILD_WORK_STEPS_TO_UPDATE_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    ACTIVATION_CHECKLIST_VALIDATIONS_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = ACTIVATION_CHECKLIST_VALIDATIONS_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockAccountsSelector);
        Application.SELECTOR.setMock(mockIntegrationRequestsSelector);
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        Application.SERVICE.setMock(
            IActivationChecklistValidationService.class,
            activationCheckValidationsServiceMock
        );
        String eventPayload = JSON.serialize(new Set<Id>{ newIntegrationRequest[0].Id });
        Onboarding_Activation__e mockOnboardingActivationEvents = new Onboarding_Activation__e(
            Payload__c = eventPayload,
            Topic__c = EVENT_TOPIC
        );
        ActivationChecklistService.execute(
            new List<Onboarding_Activation__e>{ mockOnboardingActivationEvents }
        );
        fflib_ArgumentCaptor capturedAccounts = fflib_ArgumentCaptor.forClass(List<Account>.class);
        fflib_ArgumentCaptor capturedWrappers = fflib_ArgumentCaptor.forClass(
            Map<Id, ActivationChecklistWrapper>.class
        );
        fflib_ArgumentCaptor capturedMetadata = fflib_ArgumentCaptor.forClass(
            List<Activation_Checklist_Validation__mdt>.class
        );
        ((IActivationChecklistValidationService) mocks.verify(
                activationCheckValidationsServiceMock,
                1
            ))
            .validateStoreAccount(
                (List<Account>) capturedAccounts.capture(),
                (Map<Id, ActivationChecklistWrapper>) capturedWrappers.capture(),
                (List<Activation_Checklist_Validation__mdt>) capturedMetadata.capture()
            );
        List<Account> capturedArguments = (List<Account>) capturedAccounts.getValue();
        System.assertEquals(
            MOCK_PAYLOAD_ACCOUNT_ID.substringBefore(DASH_SPLIT),
            capturedArguments[0].Id,
            COUNT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test when Activation Checklist Outbound Integration event received
     * then initiate outbound integration with received payload.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenActivationChecklistOutboundIntegrationTopicReceivedThenInitiateOutboundIntegration() {
        String eventPayload = JSON.serialize(INTEGRATION_TYPE_ACTIVATION_CHECKLIST);
        Onboarding_Activation__e mockOnboardingActivationEvents = new Onboarding_Activation__e(
            Payload__c = eventPayload,
            Topic__c = EVENT_TOPIC_ACTIVATION_CHECKLIST_OUTBOUND_INTEGRATION
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IIntegrationOutboundService integrationOutboundServiceMock = (IIntegrationOutboundService) mocks.mock(
            IIntegrationOutboundService.class
        );
        IStaticConfigurationsSelector mockStaticConfigurations = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockStaticConfigurations.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurations.getInstanceValue(
                    ACTIVATION_CHECKLIST_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = ACTIVATION_CHECKLIST_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStaticConfigurations);
        Application.SERVICE.setMock(
            IIntegrationOutboundService.class,
            integrationOutboundServiceMock
        );
        ActivationChecklistService.execute(
            new List<Onboarding_Activation__e>{ mockOnboardingActivationEvents }
        );
        ((IIntegrationOutboundService) mocks.verify(integrationOutboundServiceMock, 1))
            .sendAPICalloutWithRequestPayload(
                EVENT_TOPIC_ACTIVATION_CHECKLIST_OUTBOUND_INTEGRATION,
                new List<String>{ JSON.serialize(INTEGRATION_TYPE_ACTIVATION_CHECKLIST) }
            );
    }

    /**
     * @description To test payload is generated as per configured chunk size
     * when Activation checklist details wrapper received.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenActivationChecklistDetailsWrapperReceivedThenGenerateChunkedPayload() {
        List<ActivationChecklistOutboundWrapper.ActivationChecklistDetails> activationChecklistDetails = new List<ActivationChecklistOutboundWrapper.ActivationChecklistDetails>();
        ActivationChecklistOutboundWrapper.ActivationChecklistDetails mockActivationChecklistDetails;
        for (integer i = 1; i <= 5; i++) {
            mockActivationChecklistDetails = new ActivationChecklistOutboundWrapper.ActivationChecklistDetails();
            mockActivationChecklistDetails.accountSalesforceId = fflib_IDGenerator.generate(
                Account.SObjectType
            );
            activationChecklistDetails.add(mockActivationChecklistDetails);
        }
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStaticConfigurationsSelector mockStaticConfigurations = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        IOnboardingActivationsEventsService onboardingActivationsEventsServiceMock = (IOnboardingActivationsEventsService) mocks.mock(
            IOnboardingActivationsEventsService.class
        );
        mocks.startStubbing();
        mocks.when(mockStaticConfigurations.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurations.getInstanceValue(
                    ACTIVATION_CHECKLIST_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = ACTIVATION_CHECKLIST_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStaticConfigurations);
        Application.SERVICE.setMock(
            IOnboardingActivationsEventsService.class,
            onboardingActivationsEventsServiceMock
        );
        ActivationChecklistService.generatePayloadAndInitiateOutboundIntegration(
            activationChecklistDetails
        );
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            Map<String, List<String>>.class
        );
        ((IOnboardingActivationsEventsService) mocks.verify(
                onboardingActivationsEventsServiceMock,
                1
            ))
            .publishBulkEvents((Map<String, List<String>>) capturedInsertUOWArguments.capture());
        Map<String, List<String>> capturedArguments = (Map<String, List<String>>) capturedInsertUOWArguments.getValue();
        System.assertEquals(
            1,
            capturedArguments.get(EVENT_TOPIC_ACTIVATION_CHECKLIST_OUTBOUND_INTEGRATION).size(),
            COUNT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test payload is generated as per configured chunk size
     * when Activation Checklist details wrapper received.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenActivationChecklistDetailsWrapperReceivedExceedsChunkSizeThenGenerateChunkedPayload() {
        List<ActivationChecklistOutboundWrapper.ActivationChecklistDetails> activationChecklistDetails = new List<ActivationChecklistOutboundWrapper.ActivationChecklistDetails>();
        ActivationChecklistOutboundWrapper.ActivationChecklistDetails mockActivationChecklistDetails;
        for (integer i = 1; i <= 6; i++) {
            mockActivationChecklistDetails = new ActivationChecklistOutboundWrapper.ActivationChecklistDetails();
            mockActivationChecklistDetails.accountSalesforceId = fflib_IDGenerator.generate(
                Account.SObjectType
            );
            activationChecklistDetails.add(mockActivationChecklistDetails);
        }
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStaticConfigurationsSelector mockStaticConfigurations = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        IOnboardingActivationsEventsService onboardingActivationsEventsServiceMock = (IOnboardingActivationsEventsService) mocks.mock(
            IOnboardingActivationsEventsService.class
        );
        mocks.startStubbing();
        mocks.when(mockStaticConfigurations.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurations.getInstanceValue(
                    ACTIVATION_CHECKLIST_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = ACTIVATION_CHECKLIST_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStaticConfigurations);
        Application.SERVICE.setMock(
            IOnboardingActivationsEventsService.class,
            onboardingActivationsEventsServiceMock
        );
        ActivationChecklistService.generatePayloadAndInitiateOutboundIntegration(
            activationChecklistDetails
        );
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            Map<String, List<String>>.class
        );
        ((IOnboardingActivationsEventsService) mocks.verify(
                onboardingActivationsEventsServiceMock,
                1
            ))
            .publishBulkEvents((Map<String, List<String>>) capturedInsertUOWArguments.capture());
        Map<String, List<String>> capturedArguments = (Map<String, List<String>>) capturedInsertUOWArguments.getValue();
        System.assertEquals(
            2,
            capturedArguments.get(EVENT_TOPIC_ACTIVATION_CHECKLIST_OUTBOUND_INTEGRATION).size(),
            COUNT_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }
}