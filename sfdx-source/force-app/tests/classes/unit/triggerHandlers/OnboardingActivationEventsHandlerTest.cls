/**
 * @author Deloitte
 * @date 17/05/2022
 * @description Test class for OnboardingActivationEventsHandler class.
 * Suppressed Warnings since mock verify method does not require System assert statements.
 */
@isTest(seeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class OnboardingActivationEventsHandlerTest {
    private static final String DATABASE_RECORD_FOUND_ASSERT_MESSAGE = 'Unexpected result: Onboarding Activation event is already published';
    private static final String DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE = 'Unexpected result: failed to publish Onboarding Activation event';
    private static final String EVENT_TOPIC_CREATE_ACTIVATION_CHECKLIST = 'CREATE_ACTIVATION_CHECKLIST';
    private static final String EVENT_TOPIC_NO_IMPLEMENTATION = 'NO_IMPLEMENTATION_TOPIC';
    private static final String LOG_TYPE = 'fflib_Application.DeveloperException';
    private static final String LOG_MESSAGE =
        'No implementation registered for event topic ' + EVENT_TOPIC_NO_IMPLEMENTATION;

    /**
     * @description To test execute method of OnboardingActivationEvents handler class
     * is called on Notifier event publish.
     */
    @isTest
    private static void testWhenTopicWithImplementationPassedThenCorrespondingServiceExecuteMethodCalled() {
        Set<Id> parentWorkOrderIds = new Set<Id>{
            fflib_IDGenerator.generate(WorkOrder.SObjectType),
            fflib_IDGenerator.generate(WorkOrder.SObjectType),
            fflib_IDGenerator.generate(WorkOrder.SObjectType)
        };
        List<Onboarding_Activation__e> mockOnboardingActivationEvent = new List<Onboarding_Activation__e>{
            new Onboarding_Activation__e(
                Topic__c = EVENT_TOPIC_CREATE_ACTIVATION_CHECKLIST,
                Payload__c = JSON.serialize(parentWorkOrderIds)
            )
        };

        Onboarding_Events_Binding__mdt[] bindings = new List<Onboarding_Events_Binding__mdt>{
            new Onboarding_Events_Binding__mdt(
                Class_Name__c = 'ActivationChecklistService',
                Scope_Size__c = 5,
                Topic__c = EVENT_TOPIC_CREATE_ACTIVATION_CHECKLIST
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IHandleOnboardingActivationsEvents handleOnboardingActivationEventsMock = (IHandleOnboardingActivationsEvents) mocks.mock(
            IHandleOnboardingActivationsEvents.class
        );
        IEventBusTriggerContext eventBusTriggerContextMock = (IEventBusTriggerContext) mocks.mock(
            IEventBusTriggerContext.class
        );
        IOnboardActivationEventBindingSelector selectorMock = (IOnboardActivationEventBindingSelector) mocks.mock(
            IOnboardActivationEventBindingSelector.class
        );
        Test.startTest();
        Integration_Request__c integrationRequest = new Integration_Request__c(
            Integration_Type__c = 'Activation Checklist'
        );
        insert integrationRequest;
        Test.stopTest();
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType())
            .thenReturn(Onboarding_Events_Binding__mdt.SObjectType);
        mocks.when(selectorMock.getAllValues()).thenReturn(bindings);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(selectorMock);
        Application.SERVICE.setMock(IEventBusTriggerContext.class, eventBusTriggerContextMock);
        Application.ONBOARDING_AND_ACTIVATIONS_EVENT.setMock(
            EVENT_TOPIC_CREATE_ACTIVATION_CHECKLIST,
            handleOnboardingActivationEventsMock
        );

        fflib_SObjectDomain.Test.Database.onInsert(mockOnboardingActivationEvent);
        fflib_SObjectDomain.triggerHandler(OnboardingActivationEventsHandler.class);
        ((IHandleOnboardingActivationsEvents) mocks.verify(handleOnboardingActivationEventsMock, 1))
            .execute(mockOnboardingActivationEvent);
    }

    /**
     * @description To test execute method of OnboardingActivationEvents handler class for multiple topics
     * is called on Multiple OnboardingActivationEvents event publish.
     */
    @isTest
    private static void testWhenMultiplateTopicsWithImplementationPassedThenSingleTopicIsExecuted() {
        Set<Id> parentWorkOrderIds = new Set<Id>{
            fflib_IDGenerator.generate(WorkOrder.SObjectType),
            fflib_IDGenerator.generate(WorkOrder.SObjectType),
            fflib_IDGenerator.generate(WorkOrder.SObjectType)
        };

        List<Onboarding_Activation__e> mockOnboardingActivationEvent = new List<Onboarding_Activation__e>{
            new Onboarding_Activation__e(
                Topic__c = EVENT_TOPIC_CREATE_ACTIVATION_CHECKLIST,
                Payload__c = JSON.serialize(parentWorkOrderIds)
            ),
            new Onboarding_Activation__e(
                Topic__c = EVENT_TOPIC_CREATE_ACTIVATION_CHECKLIST,
                Payload__c = JSON.serialize(parentWorkOrderIds)
            )
        };

        Onboarding_Events_Binding__mdt[] bindings = new List<Onboarding_Events_Binding__mdt>{
            new Onboarding_Events_Binding__mdt(
                Class_Name__c = 'ActivationChecklistService',
                Scope_Size__c = 5,
                Topic__c = EVENT_TOPIC_CREATE_ACTIVATION_CHECKLIST
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IHandleOnboardingActivationsEvents handleOnboardingActivationEventsMock = (IHandleOnboardingActivationsEvents) mocks.mock(
            IHandleOnboardingActivationsEvents.class
        );
        IEventBusTriggerContext eventBusTriggerContextMock = (IEventBusTriggerContext) mocks.mock(
            IEventBusTriggerContext.class
        );
        IOnboardActivationEventBindingSelector selectorMock = (IOnboardActivationEventBindingSelector) mocks.mock(
            IOnboardActivationEventBindingSelector.class
        );

        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType())
            .thenReturn(Onboarding_Events_Binding__mdt.SObjectType);
        mocks.when(selectorMock.getAllValues()).thenReturn(bindings);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(selectorMock);
        Application.SERVICE.setMock(IEventBusTriggerContext.class, eventBusTriggerContextMock);
        Application.ONBOARDING_AND_ACTIVATIONS_EVENT.setMock(
            EVENT_TOPIC_CREATE_ACTIVATION_CHECKLIST,
            handleOnboardingActivationEventsMock
        );

        fflib_SObjectDomain.Test.Database.onInsert(mockOnboardingActivationEvent);
        fflib_SObjectDomain.triggerHandler(OnboardingActivationEventsHandler.class);

        ((IHandleOnboardingActivationsEvents) mocks.verify(handleOnboardingActivationEventsMock, 1))
            .execute(
                new List<Onboarding_Activation__e>{
                    mockOnboardingActivationEvent[0],
                    mockOnboardingActivationEvent[1]
                }
            );
        ((IHandleOnboardingActivationsEvents) mocks.verify(handleOnboardingActivationEventsMock, 1))
            .execute((List<Onboarding_Activation__e>) fflib_Match.anyList());
    }

    /**
     * @description To test scope size executed for OnboardingActivationEvents events.
     */
    @isTest
    private static void testWhenTopicWithImplementationPassedThenVerifyScopeSizeExecuted() {
        Set<Id> parentWorkOrderIds = new Set<Id>{
            fflib_IDGenerator.generate(WorkOrder.SObjectType),
            fflib_IDGenerator.generate(WorkOrder.SObjectType),
            fflib_IDGenerator.generate(WorkOrder.SObjectType)
        };
        List<Onboarding_Activation__e> mockOnboardingActivationEvent = new List<Onboarding_Activation__e>();
        List<Onboarding_Activation__e> mockOnboardingActivationEventWithinScope = new List<Onboarding_Activation__e>();

        for (Integer i = 0; i < 400; i++) {
            Onboarding_Activation__e onboardingActivationRecord = new Onboarding_Activation__e(
                Topic__c = EVENT_TOPIC_CREATE_ACTIVATION_CHECKLIST,
                Payload__c = JSON.serialize(parentWorkOrderIds)
            );
            mockOnboardingActivationEvent.add(onboardingActivationRecord);
            if (i < 5) {
                mockOnboardingActivationEventWithinScope.add(onboardingActivationRecord);
            }
        }

        Onboarding_Events_Binding__mdt[] bindings = new List<Onboarding_Events_Binding__mdt>{
            new Onboarding_Events_Binding__mdt(
                Class_Name__c = 'ActivationChecklistService',
                Scope_Size__c = 5,
                Topic__c = EVENT_TOPIC_CREATE_ACTIVATION_CHECKLIST
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IEventBusTriggerContext eventBusTriggerContextMock = (IEventBusTriggerContext) mocks.mock(
            IEventBusTriggerContext.class
        );
        IHandleOnboardingActivationsEvents handleOnboardingActivationEventsMock = (IHandleOnboardingActivationsEvents) mocks.mock(
            IHandleOnboardingActivationsEvents.class
        );
        IOnboardActivationEventBindingSelector selectorMock = (IOnboardActivationEventBindingSelector) mocks.mock(
            IOnboardActivationEventBindingSelector.class
        );

        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType())
            .thenReturn(Onboarding_Events_Binding__mdt.SObjectType);
        mocks.when(selectorMock.getAllValues()).thenReturn(bindings);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(selectorMock);
        Application.SERVICE.setMock(IEventBusTriggerContext.class, eventBusTriggerContextMock);
        Application.ONBOARDING_AND_ACTIVATIONS_EVENT.setMock(
            EVENT_TOPIC_CREATE_ACTIVATION_CHECKLIST,
            handleOnboardingActivationEventsMock
        );

        fflib_SObjectDomain.Test.Database.onInsert(mockOnboardingActivationEvent);
        fflib_SObjectDomain.triggerHandler(OnboardingActivationEventsHandler.class);
        ((IHandleOnboardingActivationsEvents) mocks.verify(handleOnboardingActivationEventsMock, 1))
            .execute(mockOnboardingActivationEventWithinScope);
        ((IHandleOnboardingActivationsEvents) mocks.verify(handleOnboardingActivationEventsMock, 1))
            .execute((List<Onboarding_Activation__e>) fflib_Match.anyList());
    }

    /**
     * @description To verify when topic without implementation is passed then an exception is thrown.
     */
    @isTest
    private static void testWhenTopicWithoutImplementationPassedThenExceptionIsThrown() {
        Set<Id> parentWorkOrderIds = new Set<Id>{
            fflib_IDGenerator.generate(WorkOrder.SObjectType),
            fflib_IDGenerator.generate(WorkOrder.SObjectType),
            fflib_IDGenerator.generate(WorkOrder.SObjectType)
        };
        List<Onboarding_Activation__e> mockOnboardingActivationEvent = new List<Onboarding_Activation__e>{
            new Onboarding_Activation__e(
                Topic__c = EVENT_TOPIC_NO_IMPLEMENTATION,
                Payload__c = JSON.serialize(parentWorkOrderIds)
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        Application.UNITOFWORK.setMock(mockUOW);
        fflib_SObjectDomain.Test.Database.onInsert(mockOnboardingActivationEvent);
        fflib_SObjectDomain.triggerHandler(OnboardingActivationEventsHandler.class);
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