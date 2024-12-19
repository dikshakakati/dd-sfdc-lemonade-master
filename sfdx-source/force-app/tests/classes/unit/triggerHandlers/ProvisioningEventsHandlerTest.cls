/**
 * @description Test class for ProvisioningEventsHandler.
 */
@isTest(SeeAllData=false)
public class ProvisioningEventsHandlerTest {
    public static final String PROVISIONING_EVENT_CREATION_METHOD_MANUAL = 'Manual';
    public static final String PROVISIONING_EVENT_CREATION_METHOD_AUTOMATIC = 'Automatic';

    public static final String PROVISIONING_EVENT_ASSERTION_FAILED = 'Assertion failed: Failed to publish event.';
    private static final String WORK_ORDER_TYPE_DRIVE = 'Drive';
    private static final String WORK_ORDER_TYPE_MARKETPLACE = 'Marketplace';
    private static final String WORK_ORDER_TYPE_STOREFRONT = 'Storefront';
    private static final String WORK_ORDER_TYPE_POST_SALES = 'Post-Sales';
    private static final String WORK_ORDER_TYPE_COO = 'COO';
    /**
     * @description Tests manual store provisioning.
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenProvisioningEventWithManualCreationMethodIsInsertedThenCallProvisioningService() {
        Id storeAccountId1 = fflib_IDGenerator.generate(Account.SObjectType);
        Id storeAccountId2 = fflib_IDGenerator.generate(Account.SObjectType);

        List<Provisioning_Event__e> provisingEventList = new List<Provisioning_Event__e>{
            new Provisioning_Event__e(
                WO_Type__c = WORK_ORDER_TYPE_MARKETPLACE,
                Creation_Method__c = PROVISIONING_EVENT_CREATION_METHOD_MANUAL,
                Accounts__c = JSON.serialize(new List<Id>{ storeAccountId1, storeAccountId2 })
            ),
            new Provisioning_Event__e(
                WO_Type__c = WORK_ORDER_TYPE_MARKETPLACE,
                Creation_Method__c = PROVISIONING_EVENT_CREATION_METHOD_AUTOMATIC,
                Accounts__c = JSON.serialize(new List<Id>{ storeAccountId1, storeAccountId2 })
            )
        };

        Map<String, Set<Id>> creationMethodAccountIdMap = new Map<String, Set<Id>>();
        creationMethodAccountIdMap.put(
            PROVISIONING_EVENT_CREATION_METHOD_MANUAL,
            new Set<Id>{ storeAccountId1, storeAccountId2 }
        );
        //Only 1 at a time now, so Automatic won't be processed yet.

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsProvisioningService accountProvisioningServiceMock = (IAccountsProvisioningService) mocks.mock(
            IAccountsProvisioningService.class
        );
        Application.SERVICE.setMock(
            IAccountsProvisioningService.class,
            accountProvisioningServiceMock
        );

        Test.startTest();
        EventBus.publish(provisingEventList);

        Test.stopTest();

        ((IAccountsProvisioningService) mocks.verify(accountProvisioningServiceMock, 1))
            .provisionMarketplaceAccountsByCreationMethod(creationMethodAccountIdMap);
    }

    /**
     * @description Tests manual store provisioning
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenProvisioningEventForDriveThenCallProvisioningService() {
        Id storeAccountId1 = fflib_IDGenerator.generate(Account.SObjectType);
        Id storeAccountId2 = fflib_IDGenerator.generate(Account.SObjectType);

        List<Provisioning_Event__e> provisingEventList = new List<Provisioning_Event__e>{
            new Provisioning_Event__e(
                WO_Type__c = WORK_ORDER_TYPE_DRIVE,
                Creation_Method__c = PROVISIONING_EVENT_CREATION_METHOD_AUTOMATIC,
                Accounts__c = JSON.serialize(new List<Id>{ storeAccountId1, storeAccountId2 })
            ),
            new Provisioning_Event__e(
                WO_Type__c = WORK_ORDER_TYPE_DRIVE,
                Creation_Method__c = PROVISIONING_EVENT_CREATION_METHOD_AUTOMATIC,
                Accounts__c = JSON.serialize(new List<Id>{ storeAccountId1, storeAccountId2 })
            )
        };

        Map<String, Set<Id>> creationMethodAccountIdMap = new Map<String, Set<Id>>();
        creationMethodAccountIdMap.put(
            PROVISIONING_EVENT_CREATION_METHOD_AUTOMATIC,
            new Set<Id>{ storeAccountId1, storeAccountId2 }
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsProvisioningDriveService accountProvisioningServiceMock = (IAccountsProvisioningDriveService) mocks.mock(
            IAccountsProvisioningDriveService.class
        );
        Application.SERVICE.setMock(
            IAccountsProvisioningDriveService.class,
            accountProvisioningServiceMock
        );

        Test.startTest();
        EventBus.publish(provisingEventList);

        Test.stopTest();

        ((IAccountsProvisioningDriveService) mocks.verify(accountProvisioningServiceMock, 1))
            .provisionDriveAccountsByCreationMethod(creationMethodAccountIdMap);
    }

    /**
     * @description To test amendment provisioning for Storefront Work Order.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenProvisioningEventForStorefrontThenAmendmentProvisioningServiceCalled() {
        Id storeAccountId1 = fflib_IDGenerator.generate(Account.SObjectType);
        Id storeAccountId2 = fflib_IDGenerator.generate(Account.SObjectType);
        List<Provisioning_Event__e> provisingEventList = new List<Provisioning_Event__e>{
            new Provisioning_Event__e(
                WO_Type__c = WORK_ORDER_TYPE_STOREFRONT,
                Creation_Method__c = PROVISIONING_EVENT_CREATION_METHOD_AUTOMATIC,
                Accounts__c = JSON.serialize(new List<Id>{ storeAccountId1, storeAccountId2 })
            ),
            new Provisioning_Event__e(
                WO_Type__c = WORK_ORDER_TYPE_STOREFRONT,
                Creation_Method__c = PROVISIONING_EVENT_CREATION_METHOD_AUTOMATIC,
                Accounts__c = JSON.serialize(new List<Id>{ storeAccountId1, storeAccountId2 })
            )
        };
        Map<String, Set<Id>> creationMethodAccountIdMap = new Map<String, Set<Id>>();
        creationMethodAccountIdMap.put(
            PROVISIONING_EVENT_CREATION_METHOD_AUTOMATIC,
            new Set<Id>{ storeAccountId1, storeAccountId2 }
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsProvisioningService accountProvisioningServiceMock = (IAccountsProvisioningService) mocks.mock(
            IAccountsProvisioningService.class
        );
        Application.SERVICE.setMock(
            IAccountsProvisioningService.class,
            accountProvisioningServiceMock
        );
        Test.startTest();
        EventBus.publish(provisingEventList);
        Test.stopTest();
        ((IAccountsProvisioningService) mocks.verify(accountProvisioningServiceMock, 1))
            .provisionMarketplaceAccountsByCreationMethod(creationMethodAccountIdMap, true);
    }

    /**
     * @description It tests COO provisioning event trigger for COO scenario.
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenProvisioningEventCOOThenCallProvisioningService() {
        Id storeAccountId1 = fflib_IDGenerator.generate(Account.SObjectType);
        Id storeAccountId2 = fflib_IDGenerator.generate(Account.SObjectType);
        List<Provisioning_Event__e> provisingEventList = new List<Provisioning_Event__e>{
            new Provisioning_Event__e(
                WO_Type__c = WORK_ORDER_TYPE_COO,
                Creation_Method__c = PROVISIONING_EVENT_CREATION_METHOD_AUTOMATIC,
                Accounts__c = JSON.serialize(new List<Id>{ storeAccountId1, storeAccountId2 })
            )
        };
        Map<String, Set<Id>> creationMethodAccountIdMap = new Map<String, Set<Id>>();
        creationMethodAccountIdMap.put(
            PROVISIONING_EVENT_CREATION_METHOD_AUTOMATIC,
            new Set<Id>{ storeAccountId1, storeAccountId2 }
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsProvisioningService accountProvisioningServiceMock = (IAccountsProvisioningService) mocks.mock(
            IAccountsProvisioningService.class
        );
        Application.SERVICE.setMock(
            IAccountsProvisioningService.class,
            accountProvisioningServiceMock
        );
        Test.startTest();
        EventBus.publish(provisingEventList);
        Test.stopTest();
        ((IAccountsProvisioningService) mocks.verify(accountProvisioningServiceMock, 0))
            .provisionMarketplaceAccountsByCreationMethod(creationMethodAccountIdMap, true);
    }

    /**
     * @description Tests COO provisioning
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenProvisioningEventCOOThenCallCOOService() {
        Id storeAccountId1 = fflib_IDGenerator.generate(Account.SObjectType);
        Id storeAccountId2 = fflib_IDGenerator.generate(Account.SObjectType);

        List<Provisioning_Event__e> provisingEventList = new List<Provisioning_Event__e>{
            new Provisioning_Event__e(
                WO_Type__c = WORK_ORDER_TYPE_COO,
                Creation_Method__c = PROVISIONING_EVENT_CREATION_METHOD_MANUAL,
                Accounts__c = JSON.serialize(new List<Id>{ storeAccountId1, storeAccountId2 })
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IChangeOfOwnershipService cooServiceMock = (IChangeOfOwnershipService) mocks.mock(
            IChangeOfOwnershipService.class
        );
        Application.SERVICE.setMock(IChangeOfOwnershipService.class, cooServiceMock);

        Test.startTest();
        EventBus.publish(provisingEventList);

        Test.stopTest();

        ((IChangeOfOwnershipService) mocks.verify(cooServiceMock, 1))
            .provisionCOO((List<Provisioning_Event__e>) fflib_Match.anyList());
    }

    /**
     * @description Tests manual store provisioning
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenProvisioningEventWithManualCreationMethodIsInsertedThenCallProvisioningServiceTest() {
        Id storeAccountId1 = fflib_IDGenerator.generate(Account.SObjectType);
        Id storeAccountId2 = fflib_IDGenerator.generate(Account.SObjectType);

        Provisioning_Event__e provisioningEvent = new Provisioning_Event__e(
            Creation_Method__c = PROVISIONING_EVENT_CREATION_METHOD_MANUAL,
            Accounts__c = JSON.serialize(new List<Id>{ storeAccountId1, storeAccountId2 })
        );

        Test.startTest();
        Database.SaveResult sr = EventBus.publish(provisioningEvent);

        Test.stopTest();

        System.assertEquals(true, sr.isSuccess(), PROVISIONING_EVENT_ASSERTION_FAILED);
    }
}