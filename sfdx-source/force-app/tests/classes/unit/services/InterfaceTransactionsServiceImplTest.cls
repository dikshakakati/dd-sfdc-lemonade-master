/**
 * @author Deloitte
 * @date 04/25/2024
 * @description Test class for InterfaceTransactionsServiceImpl class.
 */
@isTest
public class InterfaceTransactionsServiceImplTest {
    private static final String EMAIL_OUTBOUND_CONFIG_NAME = 'Email_Outbound_Integration';
    private static final String INTEGRATION_USECASE_EMAIL = 'EMAIL_OUTBOUND_INTEGRATION';
    private static final String EVENT_TOPIC_PHOTOSHOOT_OUTBOUND = 'PHOTOSHOOT_OUTBOUND_INTEGRATION';
    private static final String EVENT_TOPIC_TABLET_OUTBOUND = 'TABLET_OUTBOUND_INTEGRATION';
    private static final String PHOTOSHOOT_OUTBOUND_CONFIG_NAME = 'Photoshoot_Outbound_Integration';
    private static final String SAMPLE_PAYLOAD = 'Mock_Payload';
    private static final String STATUS_SUBMITTED = 'Submitted';
    private static final String STATUS_NEW = 'New';
    private static final String STATUS_FAILURE = 'Failure';
    private static final String TABLET_OUTBOUND_CONFIG_NAME = 'Tablet_Outbound_Integration';

    /**
     * @description To test platform event is sent to initiate outbound integration
     * when interface transactions with payloads received.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenInterfaceTransactionsWithPayloadReceivedThenTriggerPlatformEvent() {
        Id interfaceTransactionId = Fake.generateId(Interface_Transaction__c.class);
        List<Interface_Transaction__c> newInterfaceTransactions = new List<Interface_Transaction__c>{
            new Interface_Transaction__c(
                Id = interfaceTransactionId,
                Interface_Transaction_Configuration_Name__c = TABLET_OUTBOUND_CONFIG_NAME,
                Payload__c = SAMPLE_PAYLOAD,
                Status__c = STATUS_NEW
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOnboardingActivationsEventsService onboardingEventsServiceMock = (IOnboardingActivationsEventsService) mocks.mock(
            IOnboardingActivationsEventsService.class
        );
        IOutboundIntegrationPayloadService outboundIntegrationPayloadSrvcMock = (IOutboundIntegrationPayloadService) mocks.mock(
            IOutboundIntegrationPayloadService.class
        );
        mocks.startStubbing();
        mocks.when(
                outboundIntegrationPayloadSrvcMock.generateChunkedPayloadsForMxOrderPhotoshootIntegration(
                    new List<Interface_Transaction__c>()
                )
            )
            .thenReturn(new List<String>{});
        mocks.when(
                outboundIntegrationPayloadSrvcMock.generateChunkedPayloadsForMxOrderIntegration(
                    newInterfaceTransactions
                )
            )
            .thenReturn(new List<String>{ SAMPLE_PAYLOAD });
        mocks.when(
                outboundIntegrationPayloadSrvcMock.generateChunkedPayloadsForMxFraudDocumentsIntegration(
                    new List<Interface_Transaction__c>()
                )
            )
            .thenReturn(new List<String>{});
        mocks.stopStubbing();
        Application.SERVICE.setMock(
            IOnboardingActivationsEventsService.class,
            onboardingEventsServiceMock
        );
        Application.SERVICE.setMock(
            IOutboundIntegrationPayloadService.class,
            outboundIntegrationPayloadSrvcMock
        );
        InterfaceTransactionsService.initiateOutboundIntegrationForinterfaceTransactions(
            newInterfaceTransactions
        );
        ((IOnboardingActivationsEventsService) mocks.verify(onboardingEventsServiceMock, 1))
            .publishBulkEvents(
                new Map<String, List<String>>{
                    EVENT_TOPIC_TABLET_OUTBOUND => new List<String>{ SAMPLE_PAYLOAD }
                }
            );
    }

    /**
     * @description To outbound callout is initiated when platform event payload is received.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenPlatformEventPayloadReceivedThenTriggerCallout() {
        List<Onboarding_Activation__e> onboardingEvents = new List<Onboarding_Activation__e>{
            new Onboarding_Activation__e(
                Topic__c = EVENT_TOPIC_TABLET_OUTBOUND,
                Payload__c = SAMPLE_PAYLOAD
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IIntegrationOutboundService integrationOutboundServiceMock = (IIntegrationOutboundService) mocks.mock(
            IIntegrationOutboundService.class
        );
        Application.SERVICE.setMock(
            IIntegrationOutboundService.class,
            integrationOutboundServiceMock
        );
        InterfaceTransactionsService.execute(onboardingEvents);
        ((IIntegrationOutboundService) mocks.verify(integrationOutboundServiceMock, 1))
            .sendAPICalloutWithRequestPayload(
                EVENT_TOPIC_TABLET_OUTBOUND,
                new List<String>{ SAMPLE_PAYLOAD }
            );
    }

    /**
     * @description To test Interface Transaction status updates based on received order Ids.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenPassedOrderIdsReceivedThenUpdateStatusToSuccess() {
        Id interfaceTransactionId = Fake.generateId(Interface_Transaction__c.class);
        Id mxOrderId = Fake.generateId(MX_Order__c.class);
        List<Interface_Transaction__c> newInterfaceTransactions = new List<Interface_Transaction__c>{
            new Interface_Transaction__c(
                Id = interfaceTransactionId,
                Payload__c = SAMPLE_PAYLOAD,
                Status__c = STATUS_NEW,
                Record_Id__c = mxOrderId
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );
        IInterfaceTransactionSelector interfaceTransactionSelectorMock = (IInterfaceTransactionSelector) mocks.mock(
            IInterfaceTransactionSelector.class
        );
        mocks.startStubbing();
        mocks.when(interfaceTransactionSelectorMock.sObjectType())
            .thenReturn(Interface_Transaction__c.SObjectType);
        mocks.when(
                interfaceTransactionSelectorMock.selectByOriginRecordIds(
                    new Set<String>{ mxOrderId }
                )
            )
            .thenReturn(newInterfaceTransactions);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(interfaceTransactionSelectorMock);
        Application.UNITOFWORK.setMock(uowMock);
        InterfaceTransactionsService.updateInterfaceTransactionStatusByResponse(
            new Set<String>{},
            new Set<String>{ mxOrderId }
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Interface_Transaction__c.Id => interfaceTransactionId,
                            Interface_Transaction__c.Status__c => STATUS_SUBMITTED
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
    }

    /**
     * @description To test Interface Transaction status updates based on received failed order Ids.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenFailedOrderIdsReceivedThenUpdateStatusToSuccess() {
        Id interfaceTransactionId = Fake.generateId(Interface_Transaction__c.class);
        Id mxOrderId = Fake.generateId(MX_Order__c.class);
        List<Interface_Transaction__c> newInterfaceTransactions = new List<Interface_Transaction__c>{
            new Interface_Transaction__c(
                Id = interfaceTransactionId,
                Payload__c = SAMPLE_PAYLOAD,
                Status__c = STATUS_NEW,
                Record_Id__c = mxOrderId
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );
        IInterfaceTransactionSelector interfaceTransactionSelectorMock = (IInterfaceTransactionSelector) mocks.mock(
            IInterfaceTransactionSelector.class
        );
        mocks.startStubbing();
        mocks.when(interfaceTransactionSelectorMock.sObjectType())
            .thenReturn(Interface_Transaction__c.SObjectType);
        mocks.when(
                interfaceTransactionSelectorMock.selectByOriginRecordIds(
                    new Set<String>{ mxOrderId }
                )
            )
            .thenReturn(newInterfaceTransactions);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(interfaceTransactionSelectorMock);
        Application.UNITOFWORK.setMock(uowMock);
        InterfaceTransactionsService.updateInterfaceTransactionStatusByResponse(
            new Set<String>{ mxOrderId },
            new Set<String>{}
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Interface_Transaction__c.Id => interfaceTransactionId,
                            Interface_Transaction__c.Status__c => STATUS_FAILURE
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
    }

    /**
     * @description To test outbound integration initiated when interface transactions
     * with email payloads received.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenInterfaceTransactionsWithEmailPayloadReceivedThenInititateOutboundIntegration() {
        Id interfaceTransactionId = Fake.generateId(Interface_Transaction__c.class);
        Id integrationTemplateId = Fake.generateId(Integration_Template__c.class);
        List<Interface_Transaction__c> newInterfaceTransactions = new List<Interface_Transaction__c>{
            new Interface_Transaction__c(
                Id = interfaceTransactionId,
                Integration_Template__c = integrationTemplateId,
                Interface_Transaction_Configuration_Name__c = EMAIL_OUTBOUND_CONFIG_NAME,
                Payload__c = SAMPLE_PAYLOAD,
                Status__c = STATUS_NEW
            )
        };
        List<Integration_Template__c> mockIntegrationTemplates = new List<Integration_Template__c>{
            new Integration_Template__c(
                Id = integrationTemplateId,
                Immediate_Communication__c = true
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOutboundIntegrationPayloadService outboundIntegrationPayloadSrvcMock = (IOutboundIntegrationPayloadService) mocks.mock(
            IOutboundIntegrationPayloadService.class
        );
        IIntegrationTemplatesSelector mockIntegrationTemplatesSelector = (IIntegrationTemplatesSelector) mocks.mock(
            IIntegrationTemplatesSelector.class
        );
        IIntegrationOutboundService integrationOutboundServiceMock = (IIntegrationOutboundService) mocks.mock(
            IIntegrationOutboundService.class
        );
        mocks.startStubbing();
        mocks.when(mockIntegrationTemplatesSelector.sObjectType())
            .thenReturn(Integration_Template__c.SObjectType);
        mocks.when(
                mockIntegrationTemplatesSelector.selectByIds(new Set<Id>{ integrationTemplateId })
            )
            .thenReturn(mockIntegrationTemplates);
        mocks.when(
                outboundIntegrationPayloadSrvcMock.generateChunkedPayloadsForMxOrderPhotoshootIntegration(
                    new List<Interface_Transaction__c>()
                )
            )
            .thenReturn(new List<String>{});
        mocks.when(
                outboundIntegrationPayloadSrvcMock.generateChunkedPayloadsForMxOrderIntegration(
                    new List<Interface_Transaction__c>()
                )
            )
            .thenReturn(new List<String>{});
        mocks.when(
                outboundIntegrationPayloadSrvcMock.generateChunkedPayloadsForEmailIntegration(
                    newInterfaceTransactions
                )
            )
            .thenReturn(new List<String>{ SAMPLE_PAYLOAD });
        mocks.when(
                outboundIntegrationPayloadSrvcMock.generateChunkedPayloadsForMxFraudDocumentsIntegration(
                    new List<Interface_Transaction__c>()
                )
            )
            .thenReturn(new List<String>{});
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockIntegrationTemplatesSelector);
        Application.SERVICE.setMock(
            IOutboundIntegrationPayloadService.class,
            outboundIntegrationPayloadSrvcMock
        );
        Application.SERVICE.setMock(
            IIntegrationOutboundService.class,
            integrationOutboundServiceMock
        );
        InterfaceTransactionsService.initiateOutboundIntegrationForinterfaceTransactions(
            newInterfaceTransactions
        );
        ((IIntegrationOutboundService) mocks.verify(integrationOutboundServiceMock, 1))
            .sendAPICalloutWithRequestPayload(
                INTEGRATION_USECASE_EMAIL,
                new List<String>{ SAMPLE_PAYLOAD }
            );
    }

    /**
     * @description To test Interface Transaction status updates based on received
     * submitted interface transaction Ids.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenPassedInterfaceTransactionIdsReceivedThenUpdateStatusToSubmitted() {
        Id interfaceTransactionId = Fake.generateId(Interface_Transaction__c.class);
        List<Interface_Transaction__c> newInterfaceTransactions = new List<Interface_Transaction__c>{
            new Interface_Transaction__c(
                Id = interfaceTransactionId,
                Payload__c = SAMPLE_PAYLOAD,
                Status__c = STATUS_NEW,
                Remaining_Retry_Attempts__c = 5
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );
        IInterfaceTransactionSelector interfaceTransactionSelectorMock = (IInterfaceTransactionSelector) mocks.mock(
            IInterfaceTransactionSelector.class
        );
        mocks.startStubbing();
        mocks.when(interfaceTransactionSelectorMock.sObjectType())
            .thenReturn(Interface_Transaction__c.SObjectType);
        mocks.when(
                interfaceTransactionSelectorMock.selectById(new Set<Id>{ interfaceTransactionId })
            )
            .thenReturn(newInterfaceTransactions);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(interfaceTransactionSelectorMock);
        Application.UNITOFWORK.setMock(uowMock);
        InterfaceTransactionsService.updateInterfaceTransactionStatusByOutboundCalloutResponse(
            new Set<String>{},
            new Set<String>{ interfaceTransactionId }
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Interface_Transaction__c.Id => interfaceTransactionId,
                            Interface_Transaction__c.Status__c => STATUS_SUBMITTED
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
    }

    /**
     * @description To test Interface Transaction status updates based on
     * received failed interface transaction Ids.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenFailedInterfaceTransactionIdsReceivedThenUpdateStatusToFailure() {
        Id interfaceTransactionId = Fake.generateId(Interface_Transaction__c.class);
        List<Interface_Transaction__c> newInterfaceTransactions = new List<Interface_Transaction__c>{
            new Interface_Transaction__c(
                Id = interfaceTransactionId,
                Payload__c = SAMPLE_PAYLOAD,
                Status__c = STATUS_NEW,
                Remaining_Retry_Attempts__c = 5
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );
        IInterfaceTransactionSelector interfaceTransactionSelectorMock = (IInterfaceTransactionSelector) mocks.mock(
            IInterfaceTransactionSelector.class
        );
        mocks.startStubbing();
        mocks.when(interfaceTransactionSelectorMock.sObjectType())
            .thenReturn(Interface_Transaction__c.SObjectType);
        mocks.when(
                interfaceTransactionSelectorMock.selectById(new Set<Id>{ interfaceTransactionId })
            )
            .thenReturn(newInterfaceTransactions);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(interfaceTransactionSelectorMock);
        Application.UNITOFWORK.setMock(uowMock);
        InterfaceTransactionsService.updateInterfaceTransactionStatusByOutboundCalloutResponse(
            new Set<String>{ interfaceTransactionId },
            new Set<String>{}
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Interface_Transaction__c.Id => interfaceTransactionId,
                            Interface_Transaction__c.Status__c => STATUS_FAILURE
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
    }

    /**
     * @description To outbound callout is initiated when platform event payload is received.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenPlatformEventPayloadReceivedThenTriggerCalloutForPhotoshootIntegration() {
        List<Onboarding_Activation__e> onboardingEvents = new List<Onboarding_Activation__e>{
            new Onboarding_Activation__e(
                Topic__c = EVENT_TOPIC_PHOTOSHOOT_OUTBOUND,
                Payload__c = SAMPLE_PAYLOAD
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IIntegrationOutboundService integrationOutboundServiceMock = (IIntegrationOutboundService) mocks.mock(
            IIntegrationOutboundService.class
        );
        Application.SERVICE.setMock(
            IIntegrationOutboundService.class,
            integrationOutboundServiceMock
        );
        InterfaceTransactionsService.execute(onboardingEvents);
        ((IIntegrationOutboundService) mocks.verify(integrationOutboundServiceMock, 1))
            .sendAPICalloutWithRequestPayload(
                EVENT_TOPIC_PHOTOSHOOT_OUTBOUND,
                new List<String>{ SAMPLE_PAYLOAD }
            );
    }

    /**
     * @description To test platform event is sent to initiate outbound integration
     * when interface transactions with payloads received.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenInterfaceTransactionsWithPhotoshootPayloadReceivedThenTriggerPlatformEvent() {
        Id interfaceTransactionId = Fake.generateId(Interface_Transaction__c.class);
        List<Interface_Transaction__c> newInterfaceTransactions = new List<Interface_Transaction__c>{
            new Interface_Transaction__c(
                Id = interfaceTransactionId,
                Interface_Transaction_Configuration_Name__c = PHOTOSHOOT_OUTBOUND_CONFIG_NAME,
                Payload__c = SAMPLE_PAYLOAD,
                Status__c = STATUS_NEW
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOnboardingActivationsEventsService onboardingEventsServiceMock = (IOnboardingActivationsEventsService) mocks.mock(
            IOnboardingActivationsEventsService.class
        );
        IOutboundIntegrationPayloadService outboundIntegrationPayloadSrvcMock = (IOutboundIntegrationPayloadService) mocks.mock(
            IOutboundIntegrationPayloadService.class
        );
        mocks.startStubbing();
        mocks.when(
                outboundIntegrationPayloadSrvcMock.generateChunkedPayloadsForMxOrderPhotoshootIntegration(
                    newInterfaceTransactions
                )
            )
            .thenReturn(new List<String>{ SAMPLE_PAYLOAD });
        mocks.when(
                outboundIntegrationPayloadSrvcMock.generateChunkedPayloadsForMxOrderIntegration(
                    new List<Interface_Transaction__c>()
                )
            )
            .thenReturn(new List<String>{});
        mocks.when(
                outboundIntegrationPayloadSrvcMock.generateChunkedPayloadsForMxFraudDocumentsIntegration(
                    new List<Interface_Transaction__c>()
                )
            )
            .thenReturn(new List<String>{});
        mocks.stopStubbing();
        Application.SERVICE.setMock(
            IOnboardingActivationsEventsService.class,
            onboardingEventsServiceMock
        );
        Application.SERVICE.setMock(
            IOutboundIntegrationPayloadService.class,
            outboundIntegrationPayloadSrvcMock
        );
        InterfaceTransactionsService.initiateOutboundIntegrationForinterfaceTransactions(
            newInterfaceTransactions
        );
        ((IOnboardingActivationsEventsService) mocks.verify(onboardingEventsServiceMock, 1))
            .publishBulkEvents(
                new Map<String, List<String>>{
                    EVENT_TOPIC_PHOTOSHOOT_OUTBOUND => new List<String>{ SAMPLE_PAYLOAD }
                }
            );
    }
}