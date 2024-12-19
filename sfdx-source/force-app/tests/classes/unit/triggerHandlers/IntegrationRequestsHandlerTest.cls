/**
 * @author DoorDash
 * @date 03/22/2023
 * @description Test class for IntegrationRequestsHandler class.
 */
@isTest(seeAllData=false)
private class IntegrationRequestsHandlerTest {
    private static final String CONSTRUCTOR_ASSERT_MESSAGE = 'Unexpected result: The objects are matching';
    private static final String DATABASE_RECORD_FOUND_ASSERT_MESSAGE = 'Unexpected result: Record are present in database';
    private static final String DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE = 'Unexpected result: Record are not present in database';
    private static final string STORE_ID = '24680';
     /**
     * @description To test Contructor instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenRun() {
        List<Integration_request__c> integrationRequestsList = new List<Integration_request__c>();
        IntegrationRequests.newInstance(IntegrationRequestsList);
        IntegrationRequests integrationRequestsObject = new IntegrationRequests(IntegrationRequestsList);
        IntegrationRequests.Constructor constructorObject = new IntegrationRequests.Constructor();
        constructorObject.construct(IntegrationRequestsList);
        System.assertNotEquals(
            IntegrationRequests.newInstance(IntegrationRequestsList),
            IntegrationRequestsObject,
            CONSTRUCTOR_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test when after insert called then after insert domain method is called.
     */
    @isTest
    private static void testWhenIntReqInsertedThenCallDomainAndServiceMethods() {

        Fake integrationRequestFakeInstace =  ServiceMockDataBuilder.createIntegrationRequestFakeInstance(STORE_ID);

        Integration_request__c integrationRequestInstance =
            (Integration_request__c) ServiceMockDataBuilder.convertToSObject(integrationRequestFakeInstace);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_IDomainConstructor constructor = (fflib_IDomainConstructor) mocks.mock(
            fflib_IDomainConstructor.class
        );
        IIntegrationRequests integrationRequestsMock = (IIntegrationRequests) mocks.mock(IIntegrationRequests.class);
        IIntegrationRequestsService integrationRequestsServiceMock = (IIntegrationRequestsService) mocks.mock(IIntegrationRequestsService.class);

        mocks.startStubbing();
        mocks.when(integrationRequestsMock.getType()).thenReturn(Schema.Integration_request__c.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(integrationRequestsMock);
        IntegrationRequests.setConstructorMock(constructor);
        Application.SERVICE.setMock(IIntegrationRequestsService.class, integrationRequestsServiceMock);
        System.assertEquals(
            false,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.Test.Database.onInsert(new List<Integration_request__c>{ integrationRequestInstance });
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.triggerHandler(IntegrationRequestsHandler.class);
        ((IIntegrationRequests) mocks.verify(integrationRequestsMock, 1)).validateAndPrePopulateFields();
        ((IIntegrationRequestsService) mocks.verify(integrationRequestsServiceMock, 1)).publishEventsForProcessing(new Map<Id, Integration_Request__c>(), new List<Integration_request__c>{ integrationRequestInstance }, false);

    }
     /**
     * @description To test when after update called then after update domain method is called.
     */
    @isTest
    private static void testWhenIntReqUpdatedThenCallDomainAndServiceMethods() {

        Fake integrationRequestFakeInstace =  ServiceMockDataBuilder.createIntegrationRequestFakeInstance(STORE_ID);

        Integration_request__c integrationRequestInstance =
            (Integration_request__c) ServiceMockDataBuilder.convertToSObject(integrationRequestFakeInstace);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_IDomainConstructor constructor = (fflib_IDomainConstructor) mocks.mock(
            fflib_IDomainConstructor.class
        );
        IIntegrationRequests integrationRequestsMock = (IIntegrationRequests) mocks.mock(IIntegrationRequests.class);
        IIntegrationRequestsService integrationRequestsServiceMock = (IIntegrationRequestsService) mocks.mock(IIntegrationRequestsService.class);
        Map<Id, Integration_request__c> existingRecords = new Map<Id, Integration_request__c>{integrationRequestInstance.Id => integrationRequestInstance};
        mocks.startStubbing();
        mocks.when(integrationRequestsMock.getType()).thenReturn(Schema.Integration_request__c.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(integrationRequestsMock);
        IntegrationRequests.setConstructorMock(constructor);
        Application.SERVICE.setMock(IIntegrationRequestsService.class, integrationRequestsServiceMock);
        System.assertEquals(
            false,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.Test.Database.onUpdate(new List<Integration_request__c>{ integrationRequestInstance }, ExistingRecords);
        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
        fflib_SObjectDomain.triggerHandler(IntegrationRequestsHandler.class);
        ((IIntegrationRequestsService) mocks.verify(integrationRequestsServiceMock, 1)).updateParentIntRequest( ExistingRecords, new List<Integration_request__c>{ integrationRequestInstance });
        ((IIntegrationRequestsService) mocks.verify(integrationRequestsServiceMock, 1)).publishEventsForProcessing( ExistingRecords, new List<Integration_request__c>{ integrationRequestInstance }, false);
    }
}