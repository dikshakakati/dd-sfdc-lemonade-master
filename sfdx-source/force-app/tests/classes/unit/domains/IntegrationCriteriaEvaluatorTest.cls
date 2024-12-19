/**
 * @author Deloitte
 * @date 04/30/2024
 * @description Test class for IntegrationCriteriaEvaluator class.
 */
@isTest(SeeAllData=false)
public class IntegrationCriteriaEvaluatorTest {
    private static final String EMAIL_INTEGRATION_CHUNK_SIZE = 'Email_Outbound_Integration_Chunk_Size';
    private static final String INITIATE_EMAIL_INTEGRATION = 'EMAIL_INTEGRATION_OUTBOUND';
    private static final String METADATA_VALUE = '5';
    private static final String ORDER_STATUS_DRAFT = 'Draft';
    private static final String ORDER_STATUS_SHIPPED = 'Shipped';
    private static final String ONBOARDING_LINK_STATUS_ACTIVE = 'Active';
    private static final String WORK_ORDER_NOT_STARTED = 'Not Started';
    private static final String WORK_ORDER_READINESS_CHECK_COMPLETE = 'Readiness Check Complete';
    private static final String WORK_STEP_STATUS_BLOCKED = 'Blocked';
    private static final String WORK_STEP_STATUS_COMPLETE = 'Complete';
    private static final String TEST_EMAIL_ID = 'test@test.com';
    private static final String WORK_ORDER_TYPE_MARKETPLACE = 'Marketplace';

    /**
     * @description To test Merchant Order record evaluated based on email integration entry criteria
     * and platform event is triggered when criteria evaluates to true.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMxOrderEmailCriteriaEvaluatesToTrueThenTriggerPlatformEvent() {
        Id mxOrderId = fflib_IDGenerator.generate(Mx_Order__c.SObjectType);
        Map<Id, SObject> oldRecords = new Map<Id, SObject>{
            mxOrderId => new Mx_Order__c(Id = mxOrderId, Status__c = ORDER_STATUS_DRAFT)
        };
        List<SObject> newRecords = new List<SObject>{
            new Mx_Order__c(Id = mxOrderId, Status__c = ORDER_STATUS_SHIPPED)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStaticConfigurationsSelector mockStaticConfigurations = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        INotifierEventsPayloadGenerationService notifierEventServiceMock = (INotifierEventsPayloadGenerationService) mocks.mock(
            INotifierEventsPayloadGenerationService.class
        );
        IEmailOutboundIntegrationsEventsService emailOutboundEventsServiceMock = (IEmailOutboundIntegrationsEventsService) mocks.mock(
            IEmailOutboundIntegrationsEventsService.class
        );
        mocks.startStubbing();
        mocks.when(mockStaticConfigurations.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(mockStaticConfigurations.getInstanceValue(EMAIL_INTEGRATION_CHUNK_SIZE))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = EMAIL_INTEGRATION_CHUNK_SIZE,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(
                notifierEventServiceMock.generateChunkedPayloadsBySobjectIds(
                    new Set<Id>{ mxOrderId },
                    Integer.valueOf(METADATA_VALUE)
                )
            )
            .thenReturn(new List<String>{ mxOrderId });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStaticConfigurations);
        Application.SERVICE.setMock(
            INotifierEventsPayloadGenerationService.class,
            notifierEventServiceMock
        );
        Application.SERVICE.setMock(
            IEmailOutboundIntegrationsEventsService.class,
            emailOutboundEventsServiceMock
        );
        Test.startTest();
        IntegrationCriteriaEvaluator integrationCriteriaEvaluatorInstance = new IntegrationCriteriaEvaluator();
        integrationCriteriaEvaluatorInstance.evaluateInitialCriteriaForEmailIntegration(
            newRecords,
            oldRecords
        );
        Test.stopTest();
        ((IEmailOutboundIntegrationsEventsService) mocks.verify(emailOutboundEventsServiceMock, 1))
            .publishBulkEvents(
                new Map<String, List<String>>{
                    INITIATE_EMAIL_INTEGRATION => new List<String>{ mxOrderId }
                }
            );
    }

    /**
     * @description To test Work Order record evaluated based on email integration entry criteria
     * and platform event is triggered when criteria evaluates to true.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenWorkOrderEmailCriteriaEvaluatesToTrueThenTriggerPlatformEvent() {
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Map<Id, SObject> oldRecords = new Map<Id, SObject>{
            workOrderId => new WorkOrder(
                Id = workOrderId,
                Provisioning_Status__c = WORK_ORDER_NOT_STARTED,
                Type__c = WORK_ORDER_TYPE_MARKETPLACE,
                Sub_Type__c = ''
            )
        };
        List<SObject> newRecords = new List<SObject>{
            new WorkOrder(
                Id = workOrderId,
                Provisioning_Status__c = WORK_ORDER_READINESS_CHECK_COMPLETE,
                Type__c = WORK_ORDER_TYPE_MARKETPLACE
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStaticConfigurationsSelector mockStaticConfigurations = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        INotifierEventsPayloadGenerationService notifierEventServiceMock = (INotifierEventsPayloadGenerationService) mocks.mock(
            INotifierEventsPayloadGenerationService.class
        );
        IEmailOutboundIntegrationsEventsService emailOutboundEventsServiceMock = (IEmailOutboundIntegrationsEventsService) mocks.mock(
            IEmailOutboundIntegrationsEventsService.class
        );
        mocks.startStubbing();
        mocks.when(mockStaticConfigurations.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(mockStaticConfigurations.getInstanceValue(EMAIL_INTEGRATION_CHUNK_SIZE))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = EMAIL_INTEGRATION_CHUNK_SIZE,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(
                notifierEventServiceMock.generateChunkedPayloadsBySobjectIds(
                    new Set<Id>{ workOrderId },
                    Integer.valueOf(METADATA_VALUE)
                )
            )
            .thenReturn(new List<String>{ workOrderId });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStaticConfigurations);
        Application.SERVICE.setMock(
            INotifierEventsPayloadGenerationService.class,
            notifierEventServiceMock
        );
        Application.SERVICE.setMock(
            IEmailOutboundIntegrationsEventsService.class,
            emailOutboundEventsServiceMock
        );
        Test.startTest();
        IntegrationCriteriaEvaluator integrationCriteriaEvaluatorInstance = new IntegrationCriteriaEvaluator();
        integrationCriteriaEvaluatorInstance.evaluateInitialCriteriaForEmailIntegration(
            newRecords,
            oldRecords
        );
        Test.stopTest();
        ((IEmailOutboundIntegrationsEventsService) mocks.verify(emailOutboundEventsServiceMock, 1))
            .publishBulkEvents(
                new Map<String, List<String>>{
                    INITIATE_EMAIL_INTEGRATION => new List<String>{ workOrderId }
                }
            );
    }

    /**
     * @description To test Work Step record evaluated based on email integration entry criteria
     * and platform event is triggered when criteria evaluates to true.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenWorkStepEmailCriteriaEvaluatesToTrueThenTriggerPlatformEvent() {
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Map<Id, SObject> oldRecords = new Map<Id, SObject>{
            workStepId => new WorkStep(Id = workStepId, Status__c = WORK_STEP_STATUS_BLOCKED)
        };
        List<SObject> newRecords = new List<SObject>{
            new WorkStep(Id = workStepId, Status__c = WORK_STEP_STATUS_COMPLETE)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStaticConfigurationsSelector mockStaticConfigurations = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        INotifierEventsPayloadGenerationService notifierEventServiceMock = (INotifierEventsPayloadGenerationService) mocks.mock(
            INotifierEventsPayloadGenerationService.class
        );
        IEmailOutboundIntegrationsEventsService emailOutboundEventsServiceMock = (IEmailOutboundIntegrationsEventsService) mocks.mock(
            IEmailOutboundIntegrationsEventsService.class
        );
        mocks.startStubbing();
        mocks.when(mockStaticConfigurations.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(mockStaticConfigurations.getInstanceValue(EMAIL_INTEGRATION_CHUNK_SIZE))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = EMAIL_INTEGRATION_CHUNK_SIZE,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(
                notifierEventServiceMock.generateChunkedPayloadsBySobjectIds(
                    new Set<Id>{ workStepId },
                    Integer.valueOf(METADATA_VALUE)
                )
            )
            .thenReturn(new List<String>{ workStepId });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStaticConfigurations);
        Application.SERVICE.setMock(
            INotifierEventsPayloadGenerationService.class,
            notifierEventServiceMock
        );
        Application.SERVICE.setMock(
            IEmailOutboundIntegrationsEventsService.class,
            emailOutboundEventsServiceMock
        );
        Test.startTest();
        IntegrationCriteriaEvaluator integrationCriteriaEvaluatorInstance = new IntegrationCriteriaEvaluator();
        integrationCriteriaEvaluatorInstance.evaluateInitialCriteriaForEmailIntegration(
            newRecords,
            oldRecords
        );
        Test.stopTest();
        ((IEmailOutboundIntegrationsEventsService) mocks.verify(emailOutboundEventsServiceMock, 1))
            .publishBulkEvents(
                new Map<String, List<String>>{
                    INITIATE_EMAIL_INTEGRATION => new List<String>{ workStepId }
                }
            );
    }

    /**
     * @description To test Mx Onboarding Link record evaluated based on email integration entry criteria
     * and platform event is triggered when criteria evaluates to true.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMxOnboardingLinkEmailCriteriaEvaluatesToTrueThenTriggerPlatformEvent() {
        Id onboardingLinkId = fflib_IDGenerator.generate(Mx_Onboarding_Link__c.SObjectType);
        List<SObject> newRecords = new List<SObject>{
            new Mx_Onboarding_Link__c(
                Id = onboardingLinkId,
                Record_Creation_Status__c = '',
                Mx_Email__c = TEST_EMAIL_ID,
                Status__c = ONBOARDING_LINK_STATUS_ACTIVE
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStaticConfigurationsSelector mockStaticConfigurations = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        INotifierEventsPayloadGenerationService notifierEventServiceMock = (INotifierEventsPayloadGenerationService) mocks.mock(
            INotifierEventsPayloadGenerationService.class
        );
        IEmailOutboundIntegrationsEventsService emailOutboundEventsServiceMock = (IEmailOutboundIntegrationsEventsService) mocks.mock(
            IEmailOutboundIntegrationsEventsService.class
        );
        mocks.startStubbing();
        mocks.when(mockStaticConfigurations.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(mockStaticConfigurations.getInstanceValue(EMAIL_INTEGRATION_CHUNK_SIZE))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = EMAIL_INTEGRATION_CHUNK_SIZE,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(
                notifierEventServiceMock.generateChunkedPayloadsBySobjectIds(
                    new Set<Id>{ onboardingLinkId },
                    Integer.valueOf(METADATA_VALUE)
                )
            )
            .thenReturn(new List<String>{ onboardingLinkId });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockStaticConfigurations);
        Application.SERVICE.setMock(
            INotifierEventsPayloadGenerationService.class,
            notifierEventServiceMock
        );
        Application.SERVICE.setMock(
            IEmailOutboundIntegrationsEventsService.class,
            emailOutboundEventsServiceMock
        );
        Test.startTest();
        IntegrationCriteriaEvaluator integrationCriteriaEvaluatorInstance = new IntegrationCriteriaEvaluator();
        integrationCriteriaEvaluatorInstance.evaluateInitialCriteriaForEmailIntegration(newRecords);
        Test.stopTest();
        ((IEmailOutboundIntegrationsEventsService) mocks.verify(emailOutboundEventsServiceMock, 1))
            .publishBulkEvents(
                new Map<String, List<String>>{
                    INITIATE_EMAIL_INTEGRATION => new List<String>{ onboardingLinkId }
                }
            );
    }
}