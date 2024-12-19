/**
 * @author Deloitte
 * @date 28/02/2022
 * @description This is test class for RollUpEventsHandler class
 */
@isTest(seeAllData=false)
public class RollUpEventsHandlerTest {
    private static final String ADDRESS_VERIFICATION_STATUS = 'Address Verification Status';
    /**
     * @description To test method call on roll up event insert
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenBulkRollUpEventInsertedThenCheckScopeSize() {
        Map<Id, RollUpEvent__e> newRollUpEvents = new Map<Id, RollUpEvent__e>();
        Map<String, Set<Id>> accountIdsByType = new Map<String, Set<Id>>();
        accountIdsByType.put('Store Count', new Set<Id>());

        for (Integer i = 0; i < 205; i++) {
            RollUpEvent__e rollUpRecord = new RollUpEvent__e(
                RecordId__c = Fake.generateId(Account.sObjectType),
                Type__c = 'Store Count'
            );
            newRollUpEvents.put(rollUpRecord.RecordId__c, rollUpRecord);
            if (i < 200) {
                accountIdsByType.get('Store Count').add(rollUpRecord.RecordId__c);
            }
        }

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountRollUpService accountRollUpServiceMock = (IAccountRollUpService) mocks.mock(
            IAccountRollUpService.class
        );
        IEventBusTriggerContext eventBusTriggerContextMock = (IEventBusTriggerContext) mocks.mock(
            IEventBusTriggerContext.class
        );
        Application.SERVICE.setMock(IAccountRollupService.class, accountRollUpServiceMock);
        Application.SERVICE.setMock(IEventBusTriggerContext.class, eventBusTriggerContextMock);

        fflib_SObjectDomain.Test.Database.onInsert(newRollUpEvents.values());
        fflib_SObjectDomain.triggerHandler(RollUpEventsHandler.class);

        ((IAccountRollUpService) mocks.verify(accountRollUpServiceMock, 1))
            .calculateRollupsByType(accountIdsByType);
    }

    /**
     * @description To test method call on roll up event insert
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenRollUpEventInsertedThenCheckMethodCall() {
        Map<Id, RollUpEvent__e> newRollUpEvents = new Map<Id, RollUpEvent__e>();
        Map<String, Set<Id>> accountIdsByType = new Map<String, Set<Id>>();
        accountIdsByType.put('Store Count', new Set<Id>());

        RollUpEvent__e[] rollUpRecords = new List<RollUpEvent__e>{
            new RollUpEvent__e(
                RecordId__c = Fake.generateId(Account.sObjectType),
                Type__c = 'Store Count'
            ),
            new RollUpEvent__e(
                RecordId__c = Fake.generateId(Account.sObjectType),
                Type__c = 'Store Count'
            )
        };

        newRollUpEvents.put(rollUpRecords[0].RecordId__c, rollUpRecords[0]);
        newRollUpEvents.put(rollUpRecords[1].RecordId__c, rollUpRecords[1]);

        accountIdsByType.get('Store Count').add(rollUpRecords[0].RecordId__c);
        accountIdsByType.get('Store Count').add(rollUpRecords[1].RecordId__c);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountRollUpService accountRollUpServiceMock = (IAccountRollUpService) mocks.mock(
            IAccountRollUpService.class
        );
        IEventBusTriggerContext eventBusTriggerContextMock = (IEventBusTriggerContext) mocks.mock(
            IEventBusTriggerContext.class
        );
        Application.SERVICE.setMock(IAccountRollupService.class, accountRollUpServiceMock);
        Application.SERVICE.setMock(IEventBusTriggerContext.class, eventBusTriggerContextMock);

        fflib_SObjectDomain.Test.Database.onInsert(newRollUpEvents.values());
        fflib_SObjectDomain.triggerHandler(RollUpEventsHandler.class);

        ((IAccountRollUpService) mocks.verify(accountRollUpServiceMock, 1))
            .calculateRollupsByType(accountIdsByType);
    }

    /**
     * @description To test method call on address verification status roll up event insert.
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenRollUpEventForAddressverificationInsertedThenCheckMethodCall() {
        Map<Id, RollUpEvent__e> newRollUpEvents = new Map<Id, RollUpEvent__e>();
        RollUpEvent__e[] rollUpRecords = new List<RollUpEvent__e>{
            new RollUpEvent__e(
                RecordId__c = Fake.generateId(Store_Detail__c.sObjectType),
                Type__c = ADDRESS_VERIFICATION_STATUS
            ),
            new RollUpEvent__e(
                RecordId__c = Fake.generateId(Store_Detail__c.sObjectType),
                Type__c = ADDRESS_VERIFICATION_STATUS
            )
        };

        newRollUpEvents.put(rollUpRecords[0].RecordId__c, rollUpRecords[0]);
        newRollUpEvents.put(rollUpRecords[1].RecordId__c, rollUpRecords[1]);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStoreDetailRollUpService storeDetailRollUpServiceMock = (IStoreDetailRollUpService) mocks.mock(
            IStoreDetailRollUpService.class
        );
        IEventBusTriggerContext eventBusTriggerContextMock = (IEventBusTriggerContext) mocks.mock(
            IEventBusTriggerContext.class
        );
        Application.SERVICE.setMock(IStoreDetailRollUpService.class, storeDetailRollUpServiceMock);
        Application.SERVICE.setMock(IEventBusTriggerContext.class, eventBusTriggerContextMock);

        fflib_SObjectDomain.Test.Database.onInsert(newRollUpEvents.values());
        fflib_SObjectDomain.triggerHandler(RollUpEventsHandler.class);

        ((IStoreDetailRollUpService) mocks.verify(storeDetailRollUpServiceMock, 1))
            .rollUpAddressVerificationStatus(
                new Set<Id>{ rollUpRecords[0].RecordId__c, rollUpRecords[1].RecordId__c }
            );
    }

    /**
     * @description To test Roll Up Events Trigger
     */
    @isTest
    private static void testWhenRollUpIsPublishThenRollUpTriggerIsCalled() {
        RollUpEvent__e rollUpEventRec = new RollUpEvent__e(
            RecordId__c = Fake.generateId(Account.sObjectType),
            Type__c = 'Store Count'
        );
        Test.startTest();
        Database.SaveResult result = EventBus.publish(rollUpEventRec);
        Test.stopTest();
        System.assertEquals(true, result.isSuccess(), 'Publish event failed');
    }
}