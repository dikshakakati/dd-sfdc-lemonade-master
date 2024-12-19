/**
 * @author Deloitte
 * @date 10/17/2024
 * @description Test class for StoreDetailsHandler class.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class StoreDetailsHandlerTest {
    private static final String ADDRESS_VERIFICATION_STATUS_VERIFIED = 'Verified';
    private static final String ADDRESS_VERIFICATION_NOT_APPLICABLE = 'Not Applicable';
    private static final String COVERAGE_IN_COVERGAE = 'In Coverage';
    private static final String ONE_TIME_LINK = 'www.test.com';
    private static final String DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE = 'Unexpected result: Record are not present in database';

    /**
     * @description To test if Address details are captured when Store Details are
     * inserted.
     */
    @isTest
    private static void testWhenRecordsInsertedThenCaptureAddressDetails() {
        Id storeDetailsId = fflib_IDGenerator.generate(Store_Detail__c.SObjectType);
        Store_Detail__c storeDetailFake = (Store_Detail__c) new Fake(Store_Detail__c.class)
            .setField(Store_Detail__c.Id, storeDetailsId)
            .setField(Store_Detail__c.Coverage__c, COVERAGE_IN_COVERGAE)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStoreDetails storeDetailsMock = (IStoreDetails) mocks.mock(IStoreDetails.class);
        mocks.startStubbing();
        mocks.when(storeDetailsMock.getType()).thenReturn(Schema.Store_Detail__c.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(storeDetailsMock);
        Test.startTest();
        fflib_SObjectDomain.Test.Database.onInsert(new List<Store_Detail__c>{ storeDetailFake });
        Test.stopTest();
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.triggerHandler(StoreDetailsHandler.class);
        ((IStoreDetails) mocks.verify(storeDetailsMock, 1)).captureUserEnteredAddress();
    }

    /**
     * @description To test if Address verification is initiated when records are
     * inserted.
     */
    @isTest
    private static void testWhenRecordsInsertedThenInitiateAddressverification() {
        Id storeDetailsId = fflib_IDGenerator.generate(Store_Detail__c.SObjectType);
        Store_Detail__c storeDetailFake = (Store_Detail__c) new Fake(Store_Detail__c.class)
            .setField(Store_Detail__c.Id, storeDetailsId)
            .setField(
                Store_Detail__c.Address_Verification_Status__c,
                ADDRESS_VERIFICATION_STATUS_VERIFIED
            )
            .setField(Store_Detail__c.Coverage__c, COVERAGE_IN_COVERGAE)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStoreDetails storeDetailsMock = (IStoreDetails) mocks.mock(IStoreDetails.class);
        IAddressVerificationService addressVerificationServiceMock = (IAddressVerificationService) mocks.mock(
            IAddressVerificationService.class
        );
        mocks.startStubbing();
        mocks.when(storeDetailsMock.getType()).thenReturn(Schema.Store_Detail__c.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(storeDetailsMock);
        Application.SERVICE.setMock(
            IAddressVerificationService.class,
            addressVerificationServiceMock
        );
        Test.startTest();
        fflib_SObjectDomain.Test.Database.onInsert(new List<Store_Detail__c>{ storeDetailFake });
        Test.stopTest();
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.triggerHandler(StoreDetailsHandler.class);
        ((IAddressVerificationService) mocks.verify(addressVerificationServiceMock, 1))
            .publishAddressVerificationEvent(new List<Store_Detail__c>{ storeDetailFake });
    }

    /**
     * @description To test if Address verification is initiated when records are
     * updated
     */
    @isTest
    private static void testWhenRecordsUpdatedThenInitiateAddressverification() {
        Id storeDetailsId = fflib_IDGenerator.generate(Store_Detail__c.SObjectType);
        Store_Detail__c oldStoreDetailFake = (Store_Detail__c) new Fake(Store_Detail__c.class)
            .setField(Store_Detail__c.Id, storeDetailsId)
            .setField(
                Store_Detail__c.Address_Verification_Status__c,
                ADDRESS_VERIFICATION_NOT_APPLICABLE
            )
            .setField(Store_Detail__c.Coverage__c, COVERAGE_IN_COVERGAE)
            .toSObject();
        Store_Detail__c storeDetailFake = (Store_Detail__c) new Fake(Store_Detail__c.class)
            .setField(Store_Detail__c.Id, storeDetailsId)
            .setField(
                Store_Detail__c.Address_Verification_Status__c,
                ADDRESS_VERIFICATION_STATUS_VERIFIED
            )
            .setField(Store_Detail__c.Coverage__c, COVERAGE_IN_COVERGAE)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStoreDetails storeDetailsMock = (IStoreDetails) mocks.mock(IStoreDetails.class);
        IStoreDetailRollUpService iStoreDetailRollUpService = (IStoreDetailRollUpService) mocks.mock(
            IStoreDetailRollUpService.class
        );
        mocks.startStubbing();
        mocks.when(storeDetailsMock.getType()).thenReturn(Schema.Store_Detail__c.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(storeDetailsMock);
        Application.SERVICE.setMock(IStoreDetailRollUpService.class, iStoreDetailRollUpService);
        Test.startTest();
        fflib_SObjectDomain.Test.Database.onUpdate(
            new List<Store_Detail__c>{ storeDetailFake },
            new Map<Id, Store_Detail__c>(new List<Store_Detail__c>{ oldStoreDetailFake })
        );
        Test.stopTest();
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.triggerHandler(StoreDetailsHandler.class);
        ((IStoreDetailRollUpService) mocks.verify(iStoreDetailRollUpService, 1))
            .publishAddressVerificationRollUpEvents(new List<Store_Detail__c>{ storeDetailFake });
    }

    /**
     * @description To test if Address verification is initiated when records are
     * deleted
     */
    @isTest
    private static void testWhenRecordsDeletedThenInitiateAddressverification() {
        Id storeDetailsId = fflib_IDGenerator.generate(Store_Detail__c.SObjectType);
        Store_Detail__c storeDetailFake = (Store_Detail__c) new Fake(Store_Detail__c.class)
            .setField(Store_Detail__c.Id, storeDetailsId)
            .setField(
                Store_Detail__c.Address_Verification_Status__c,
                ADDRESS_VERIFICATION_STATUS_VERIFIED
            )
            .setField(Store_Detail__c.Coverage__c, COVERAGE_IN_COVERGAE)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStoreDetails storeDetailsMock = (IStoreDetails) mocks.mock(IStoreDetails.class);
        IAddressVerificationService addressVerificationServiceMock = (IAddressVerificationService) mocks.mock(
            IAddressVerificationService.class
        );
        mocks.startStubbing();
        mocks.when(storeDetailsMock.getType()).thenReturn(Schema.Store_Detail__c.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(storeDetailsMock);
        Application.SERVICE.setMock(
            IAddressVerificationService.class,
            addressVerificationServiceMock
        );
        Test.startTest();
        fflib_SObjectDomain.Test.Database.onUndelete(new List<Store_Detail__c>{ storeDetailFake });
        Test.stopTest();
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.triggerHandler(StoreDetailsHandler.class);
        ((IAddressVerificationService) mocks.verify(addressVerificationServiceMock, 1))
            .publishAddressVerificationEvent(new List<Store_Detail__c>{ storeDetailFake });
    }
}