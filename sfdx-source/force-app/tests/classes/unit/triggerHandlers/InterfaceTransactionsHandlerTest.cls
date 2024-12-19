/**
 * @author Deloitte
 * @date 04/25/2024
 * @description Test class for InterfaceTransactionsHandler class.
 */
@isTest
public class InterfaceTransactionsHandlerTest {
    private static final String CONSTRUCTOR_ASSERT_MESSAGE = 'Unexpected result: The objects are matching';
    private static final String DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE = 'Unexpected result: Record are not present in database';
    private static final String EVENT_TOPIC_GENERIC_WORK_ORDER_CREATION = 'WORK_ORDER_GENERATION';
    private static final String EVENT_TOPIC_GENERIC_INITIATE_RELATED_OBJECTS_CREATION = 'INITIATE_RELATED_OBJECTS_CREATION';
    private static final Integer INITIATE_RELATED_OBJECTS_CREATION_CREATION_CHUNK_SIZE = 30;
    private static final String INTERFACE_TRANSACTION_STATUS_SUCCESS = 'Success';
    private static final Integer REMAINING_RETRY_ATTEMPTS = 3;

    /**
     * @description This method is used to test InterfaceTransactionsHandler TriggerHandler
     */
    @isTest
    private static void testWhenClassInstantiatesThenCheck() {
        List<Interface_Transaction__c> newInterfaceTransactions = new List<Interface_Transaction__c>();
        InterfaceTransactionsHandler interfaceTransactionsHandlerInstance = new InterfaceTransactionsHandler(
            newInterfaceTransactions
        );
        InterfaceTransactionsHandler.Constructor handlerConstructor = new InterfaceTransactionsHandler.Constructor();
        handlerConstructor.construct(newInterfaceTransactions);
        System.assertNotEquals(
            interfaceTransactionsHandlerInstance,
            handlerConstructor.construct(newInterfaceTransactions),
            CONSTRUCTOR_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test outbound integration process is initiated
     * when Interface Transactions created.
     */
    /*
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenInterfaceTransactionInsertedThenInitiateOutboundIntegrationProcess() {
        Id interfaceTransactionId = Fake.generateId(Interface_Transaction__c.class);
        List<Interface_Transaction__c> newInterfaceTransactions = new List<Interface_Transaction__c>{
            new Interface_Transaction__c(Id = interfaceTransactionId)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IInterfaceTransactionsService interfaceTransactionsServiceMock = (IInterfaceTransactionsService) mocks.mock(
            IInterfaceTransactionsService.class
        );
        Application.SERVICE.setMock(
            IInterfaceTransactionsService.class,
            interfaceTransactionsServiceMock
        );
        fflib_SObjectDomain.Test.Database.onInsert(newInterfaceTransactions);
        fflib_SObjectDomain.triggerHandler(InterfaceTransactionsHandler.class);

        ((IInterfaceTransactionsService) mocks.verify(interfaceTransactionsServiceMock, 1))
            .initiateOutboundIntegrationForinterfaceTransactions(newInterfaceTransactions);
    }
    */

    /**
     * @description To test when Inteface Transaction is created for Work Order creation Then
     * fire Onboarding Activation Platform Event.
     * Suppressing PMD warning for Asserts.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenInterfaceTransactionCreatedForWorkOrderCreationThenFireOnboardingActivationsEvent() {
        Id interfaceTransactionId = fflib_IDGenerator.generate(
            Interface_Transaction__c.SobjectType
        );
        Id subscriptionId1 = fflib_IDGenerator.generate(SBQQ__Subscription__c.SobjectType);
        Id subscriptionId2 = fflib_IDGenerator.generate(SBQQ__Subscription__c.SobjectType);
        Id subscriptionId3 = fflib_IDGenerator.generate(SBQQ__Subscription__c.SobjectType);
        Set<Id> sObjectIds = new Set<Id>{ subscriptionId1, subscriptionId2, subscriptionId3 };
        String serializedIds = JSON.serialize(sObjectIds);
        sObjectIds.add(interfaceTransactionId);

        Interface_Transaction__c interfaceTransactionFake = (Interface_Transaction__c) new Fake(
                Interface_Transaction__c.class
            )
            .setField(Interface_Transaction__c.Id, interfaceTransactionId)
            .setField(
                Interface_Transaction__c.Interface_Transaction_Configuration_Name__c,
                EVENT_TOPIC_GENERIC_WORK_ORDER_CREATION
            )
            .setField(Interface_Transaction__c.Payload__c, serializedIds)
            .setField(
                Interface_Transaction__c.Remaining_Retry_Attempts__c,
                REMAINING_RETRY_ATTEMPTS
            )
            .setField(Interface_Transaction__c.Status__c, INTERFACE_TRANSACTION_STATUS_SUCCESS)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrderCreationTriggerService workOrderCreationTriggerServiceMock = (IWorkOrderCreationTriggerService) mocks.mock(
            IWorkOrderCreationTriggerService.class
        );
        Application.SERVICE.setMock(
            IWorkOrderCreationTriggerService.class,
            workOrderCreationTriggerServiceMock
        );
        Test.startTest();
        fflib_SObjectDomain.Test.Database.onInsert(
            new List<Interface_Transaction__c>{ interfaceTransactionFake }
        );
        Test.stopTest();
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.triggerHandler(InterfaceTransactionsHandler.class);
        ((IWorkOrderCreationTriggerService) mocks.verify(workOrderCreationTriggerServiceMock, 1))
            .fireonboardingActivationsEventsForWorkOrderCreation(
                sObjectIds,
                EVENT_TOPIC_GENERIC_WORK_ORDER_CREATION
            );
    }

    /**
     * @description To test when Inteface Transaction is created for related objects creation then
     * fire Onboarding Activations Platform Event.
     * Suppressing PMD warning for Asserts.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenInterfaceTransactionCreatedForRelatedObjectsCreationThenFireOnboardingActivationsEvent() {
        Id interfaceTransactionId = fflib_IDGenerator.generate(
            Interface_Transaction__c.SobjectType
        );
        Id subscriptionId1 = fflib_IDGenerator.generate(SBQQ__Subscription__c.SobjectType);
        Id subscriptionId2 = fflib_IDGenerator.generate(SBQQ__Subscription__c.SobjectType);
        Id subscriptionId3 = fflib_IDGenerator.generate(SBQQ__Subscription__c.SobjectType);
        Set<Id> sObjectIds = new Set<Id>{ subscriptionId1, subscriptionId2, subscriptionId3 };
        String serializedIds = JSON.serialize(sObjectIds);
        sObjectIds.add(interfaceTransactionId);

        Interface_Transaction__c interfaceTransactionFake = (Interface_Transaction__c) new Fake(
                Interface_Transaction__c.class
            )
            .setField(Interface_Transaction__c.Id, interfaceTransactionId)
            .setField(
                Interface_Transaction__c.Interface_Transaction_Configuration_Name__c,
                EVENT_TOPIC_GENERIC_INITIATE_RELATED_OBJECTS_CREATION
            )
            .setField(Interface_Transaction__c.Payload__c, serializedIds)
            .setField(
                Interface_Transaction__c.Remaining_Retry_Attempts__c,
                REMAINING_RETRY_ATTEMPTS
            )
            .setField(Interface_Transaction__c.Status__c, INTERFACE_TRANSACTION_STATUS_SUCCESS)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOnboardingActivationsEventsService onboardingActivationsEventsServiceMock = (IOnboardingActivationsEventsService) mocks.mock(
            IOnboardingActivationsEventsService.class
        );
        Application.SERVICE.setMock(
            IOnboardingActivationsEventsService.class,
            onboardingActivationsEventsServiceMock
        );
        Test.startTest();
        fflib_SObjectDomain.Test.Database.onInsert(
            new List<Interface_Transaction__c>{ interfaceTransactionFake }
        );
        Test.stopTest();
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            Map<String, List<String>>.class
        );
        fflib_SObjectDomain.triggerHandler(InterfaceTransactionsHandler.class);
        ((IOnboardingActivationsEventsService) mocks.verify(
                onboardingActivationsEventsServiceMock,
                2
            ))
            .publishBulkEvents((Map<String, List<String>>) capturedInsertUOWArguments.capture());
    }
}