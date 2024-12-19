@isTest
public class GetStoreServiceImplTest {
    @isTest
    private static void testWhenStoreHasDriveStoreThenDriveStoreIdIsNotNull() {
        String response = '{"drive_store_id": "12345"}';
        Integer statusCode = 200;
        Test.setMock(HttpCalloutMock.class, new GetStoreServiceMockResponseGenerator(response, statusCode));
        Test.startTest();
        IGetStoreService getStoreSvc = new GetStoreServiceImpl();
        Map<String, String> responseMap = getStoreSvc.getDriveStoreId('dummy-store-number');
        Test.stopTest();
        System.assertEquals(GetStoreServiceImpl.GET_STORE_API_STATUS_SUCCESS, responseMap.get(GetStoreServiceImpl.GET_STORE_API_STATUS_MAP_KEY), 'Get Store Service Api response should be success');
        System.assertEquals('12345', responseMap.get(GetStoreServiceImpl.DRIVE_STORE_ID_MAP_KEY), 'Drive Store Id was not returned as expected');
    }

    @isTest
    private static void testWhenStoreDoesNotHaveDriveStoreThenDriveStoreIdIsNull() {
        String response = '{"drive_store_id": ""}';
        Integer statusCode = 200;
        Test.setMock(HttpCalloutMock.class, new GetStoreServiceMockResponseGenerator(response, statusCode));
        Test.startTest();
        IGetStoreService getStoreSvc = new GetStoreServiceImpl();
        Map<String, String> responseMap = getStoreSvc.getDriveStoreId('dummy-store-number');
        Test.stopTest();
        System.assertEquals(GetStoreServiceImpl.GET_STORE_API_STATUS_SUCCESS, responseMap.get(GetStoreServiceImpl.GET_STORE_API_STATUS_MAP_KEY), 'Get Store Service Api response should be success');
        System.assert(String.isBlank(responseMap.get(GetStoreServiceImpl.API_DRIVE_STORE_ID_ATTRIBUTE)), 'Drive Store should be blank here');
    }

    @isTest
    private static void testWhenStoreApiFailsThenReturnsTheFailResponse() {
        String response = '{"failed-response": "authentication failed"}';
        Integer statusCode = 404;
        Test.setMock(HttpCalloutMock.class, new GetStoreServiceMockResponseGenerator(response, statusCode));
        Test.startTest();
        IGetStoreService getStoreSvc = new GetStoreServiceImpl();
        Map<String, String> responseMap = getStoreSvc.getDriveStoreId('dummy-store-number');
        Test.stopTest();
        System.assertEquals(GetStoreServiceImpl.GET_STORE_API_STATUS_FAILURE, responseMap.get(GetStoreServiceImpl.GET_STORE_API_STATUS_MAP_KEY), 'Get Store Service Api response should be failed');
        System.assertEquals(response, responseMap.get(GetStoreServiceImpl.GET_STORE_API_RESPONSE_MAP_KEY),'Get Store Api response is not returned as expected');
    }
}