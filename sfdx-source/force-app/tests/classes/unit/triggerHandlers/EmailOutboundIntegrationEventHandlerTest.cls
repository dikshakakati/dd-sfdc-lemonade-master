/**
 * @author Deloitte
 * @date 05/09/2024
 * @description Test class for EmailOutboundIntegrationsEventsHandler class.
 * Suppressed Warnings since mock verify method does not require System assert statements.
 */
@isTest(seeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class EmailOutboundIntegrationEventHandlerTest {
    private static final String DATABASE_RECORD_FOUND_ASSERT_MESSAGE = 'Unexpected result: Email Outbound event is already published';
    private static final String DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE = 'Unexpected result: failed to publish Email Outbound event';
    private static final String EVENT_TOPIC_EMAIL_OUTBOUND_INTEGRATION = 'EMAIL_OUTBOUND_INTEGRATION';
    private static final String EVENT_TOPIC_NO_IMPLEMENTATION = 'NO_IMPLEMENTATION_TOPIC';
    private static final String LOG_TYPE = 'fflib_Application.DeveloperException';
    private static final String LOG_MESSAGE =
        'No implementation registered for event topic ' + EVENT_TOPIC_NO_IMPLEMENTATION;
    private static final String SERVICE_CLASS_NAME = 'IntegrationOutboundService';

    /**
     * @description To test execute method of EmailOutboundIntegrationsEvents handler class
     * is called on event publish.
     */
    @isTest
    private static void testWhenTopicWithImplementationPassedThenCorrespondingServiceExecuteMethodCalled() {
        Set<Id> recordIds = new Set<Id>{
            fflib_IDGenerator.generate(Opportunity.SObjectType),
            fflib_IDGenerator.generate(Opportunity.SObjectType),
            fflib_IDGenerator.generate(Opportunity.SObjectType)
        };
        List<Email_Outbound_Integration__e> mockEmailOutboundEvent = new List<Email_Outbound_Integration__e>{
            new Email_Outbound_Integration__e(
                Topic__c = EVENT_TOPIC_EMAIL_OUTBOUND_INTEGRATION,
                Payload__c = JSON.serialize(recordIds)
            )
        };

        Email_Outbound_Events_Binding__mdt[] bindings = new List<Email_Outbound_Events_Binding__mdt>{
            new Email_Outbound_Events_Binding__mdt(
                Class_Name__c = SERVICE_CLASS_NAME,
                Scope_Size__c = 5,
                Topic__c = EVENT_TOPIC_EMAIL_OUTBOUND_INTEGRATION
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IHandleEmailOutboundIntegrationsEvents handleEmailOutboundEventsMock = (IHandleEmailOutboundIntegrationsEvents) mocks.mock(
            IHandleEmailOutboundIntegrationsEvents.class
        );
        IEventBusTriggerContext eventBusTriggerContextMock = (IEventBusTriggerContext) mocks.mock(
            IEventBusTriggerContext.class
        );
        IEmailOutboundEventBindingSelector selectorMock = (IEmailOutboundEventBindingSelector) mocks.mock(
            IEmailOutboundEventBindingSelector.class
        );
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType())
            .thenReturn(Email_Outbound_Events_Binding__mdt.SObjectType);
        mocks.when(selectorMock.getAllValues()).thenReturn(bindings);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(selectorMock);
        Application.SERVICE.setMock(IEventBusTriggerContext.class, eventBusTriggerContextMock);
        Application.EMAIL_OUTBOUND_INTEGRATION_EVENT.setMock(
            EVENT_TOPIC_EMAIL_OUTBOUND_INTEGRATION,
            handleEmailOutboundEventsMock
        );

        fflib_SObjectDomain.Test.Database.onInsert(mockEmailOutboundEvent);
        fflib_SObjectDomain.triggerHandler(EmailOutboundIntegrationsEventsHandler.class);
        ((IHandleEmailOutboundIntegrationsEvents) mocks.verify(handleEmailOutboundEventsMock, 1))
            .execute(mockEmailOutboundEvent);
    }

    /**
     * @description To test execute method of EmailOutboundIntegrationsEvents handler class for multiple topics
     * is called on Multiple EmailOutboundIntegrationsEvents event publish.
     */
    @isTest
    private static void testWhenMultiplateTopicsWithImplementationPassedThenSingleTopicIsExecuted() {
        Set<Id> recordIds = new Set<Id>{
            fflib_IDGenerator.generate(Opportunity.SObjectType),
            fflib_IDGenerator.generate(Opportunity.SObjectType),
            fflib_IDGenerator.generate(Opportunity.SObjectType)
        };

        List<Email_Outbound_Integration__e> mockEmailOutboundEvent = new List<Email_Outbound_Integration__e>{
            new Email_Outbound_Integration__e(
                Topic__c = EVENT_TOPIC_EMAIL_OUTBOUND_INTEGRATION,
                Payload__c = JSON.serialize(recordIds)
            ),
            new Email_Outbound_Integration__e(
                Topic__c = EVENT_TOPIC_EMAIL_OUTBOUND_INTEGRATION,
                Payload__c = JSON.serialize(recordIds)
            )
        };

        Email_Outbound_Events_Binding__mdt[] bindings = new List<Email_Outbound_Events_Binding__mdt>{
            new Email_Outbound_Events_Binding__mdt(
                Class_Name__c = SERVICE_CLASS_NAME,
                Scope_Size__c = 5,
                Topic__c = EVENT_TOPIC_EMAIL_OUTBOUND_INTEGRATION
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IHandleEmailOutboundIntegrationsEvents handleEmailOutboundEventsMock = (IHandleEmailOutboundIntegrationsEvents) mocks.mock(
            IHandleEmailOutboundIntegrationsEvents.class
        );
        IEventBusTriggerContext eventBusTriggerContextMock = (IEventBusTriggerContext) mocks.mock(
            IEventBusTriggerContext.class
        );
        IEmailOutboundEventBindingSelector selectorMock = (IEmailOutboundEventBindingSelector) mocks.mock(
            IEmailOutboundEventBindingSelector.class
        );

        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType())
            .thenReturn(Email_Outbound_Events_Binding__mdt.SObjectType);
        mocks.when(selectorMock.getAllValues()).thenReturn(bindings);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(selectorMock);
        Application.SERVICE.setMock(IEventBusTriggerContext.class, eventBusTriggerContextMock);
        Application.EMAIL_OUTBOUND_INTEGRATION_EVENT.setMock(
            EVENT_TOPIC_EMAIL_OUTBOUND_INTEGRATION,
            handleEmailOutboundEventsMock
        );

        fflib_SObjectDomain.Test.Database.onInsert(mockEmailOutboundEvent);
        fflib_SObjectDomain.triggerHandler(EmailOutboundIntegrationsEventsHandler.class);

        ((IHandleEmailOutboundIntegrationsEvents) mocks.verify(handleEmailOutboundEventsMock, 1))
            .execute(
                new List<Email_Outbound_Integration__e>{
                    mockEmailOutboundEvent[0],
                    mockEmailOutboundEvent[1]
                }
            );
        ((IHandleEmailOutboundIntegrationsEvents) mocks.verify(handleEmailOutboundEventsMock, 1))
            .execute((List<Email_Outbound_Integration__e>) fflib_Match.anyList());
    }

    /**
     * @description To test scope size executed for EmailOutboundIntegrationsEvents events.
     */
    @isTest
    private static void testWhenTopicWithImplementationPassedThenVerifyScopeSizeExecuted() {
        Set<Id> recordIds = new Set<Id>{
            fflib_IDGenerator.generate(Opportunity.SObjectType),
            fflib_IDGenerator.generate(Opportunity.SObjectType),
            fflib_IDGenerator.generate(Opportunity.SObjectType)
        };
        List<Email_Outbound_Integration__e> mockEmailOutboundEvent = new List<Email_Outbound_Integration__e>();
        List<Email_Outbound_Integration__e> mockEmailOutboundEventWithinScope = new List<Email_Outbound_Integration__e>();

        for (Integer i = 0; i < 400; i++) {
            Email_Outbound_Integration__e emailOutboundRecord = new Email_Outbound_Integration__e(
                Topic__c = EVENT_TOPIC_EMAIL_OUTBOUND_INTEGRATION,
                Payload__c = JSON.serialize(recordIds)
            );
            mockEmailOutboundEvent.add(emailOutboundRecord);
            if (i < 5) {
                mockEmailOutboundEventWithinScope.add(emailOutboundRecord);
            }
        }

        Email_Outbound_Events_Binding__mdt[] bindings = new List<Email_Outbound_Events_Binding__mdt>{
            new Email_Outbound_Events_Binding__mdt(
                Class_Name__c = SERVICE_CLASS_NAME,
                Scope_Size__c = 5,
                Topic__c = EVENT_TOPIC_EMAIL_OUTBOUND_INTEGRATION
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IEventBusTriggerContext eventBusTriggerContextMock = (IEventBusTriggerContext) mocks.mock(
            IEventBusTriggerContext.class
        );
        IHandleEmailOutboundIntegrationsEvents handleEmailOutboundEventsMock = (IHandleEmailOutboundIntegrationsEvents) mocks.mock(
            IHandleEmailOutboundIntegrationsEvents.class
        );
        IEmailOutboundEventBindingSelector selectorMock = (IEmailOutboundEventBindingSelector) mocks.mock(
            IEmailOutboundEventBindingSelector.class
        );

        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType())
            .thenReturn(Email_Outbound_Events_Binding__mdt.SObjectType);
        mocks.when(selectorMock.getAllValues()).thenReturn(bindings);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(selectorMock);
        Application.SERVICE.setMock(IEventBusTriggerContext.class, eventBusTriggerContextMock);
        Application.EMAIL_OUTBOUND_INTEGRATION_EVENT.setMock(
            EVENT_TOPIC_EMAIL_OUTBOUND_INTEGRATION,
            handleEmailOutboundEventsMock
        );

        fflib_SObjectDomain.Test.Database.onInsert(mockEmailOutboundEvent);
        fflib_SObjectDomain.triggerHandler(EmailOutboundIntegrationsEventsHandler.class);
        ((IHandleEmailOutboundIntegrationsEvents) mocks.verify(handleEmailOutboundEventsMock, 1))
            .execute(mockEmailOutboundEventWithinScope);
        ((IHandleEmailOutboundIntegrationsEvents) mocks.verify(handleEmailOutboundEventsMock, 1))
            .execute((List<Email_Outbound_Integration__e>) fflib_Match.anyList());
    }

    /**
     * @description To verify when topic without implementation is passed then an exception is thrown.
     */
    @isTest
    private static void testWhenTopicWithoutImplementationPassedThenExceptionIsThrown() {
        Set<Id> recordIds = new Set<Id>{
            fflib_IDGenerator.generate(Opportunity.SObjectType),
            fflib_IDGenerator.generate(Opportunity.SObjectType),
            fflib_IDGenerator.generate(Opportunity.SObjectType)
        };
        List<Email_Outbound_Integration__e> mockEmailOutboundEvent = new List<Email_Outbound_Integration__e>{
            new Email_Outbound_Integration__e(
                Topic__c = EVENT_TOPIC_NO_IMPLEMENTATION,
                Payload__c = JSON.serialize(recordIds)
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        Application.UNITOFWORK.setMock(mockUOW);
        fflib_SObjectDomain.Test.Database.onInsert(mockEmailOutboundEvent);
        fflib_SObjectDomain.triggerHandler(EmailOutboundIntegrationsEventsHandler.class);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Log__c.Log_Type__c => LOG_TYPE,
                        Log__c.Detailed_Message__c => LOG_MESSAGE,
                        Log__c.Severity_Level__c => LogEntry.SeverityLevel.MEDIUM.name()
                    }
                )
            );
    }
}