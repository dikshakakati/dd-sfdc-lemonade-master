/**
 * @author CriticalRiver
 * @date 05/18/2023
 * @description Test class for RemoveStoresOnWorkOrderController class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 */
@isTest(seeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class RemoveStoresOnWorkOrderControllerTest {

    private static final String DELIMITER = ',';

    /**
     * @description To test child Work Orders deletion for the selected stores.
     */
    @isTest
    private static void testWhenRemoveStoresCalledThenRemoveStores() {
        Id activeStoreAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        String accountIds = activeStoreAccountId + DELIMITER + storeAccountId;
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IRemoveStoresOnWorkOrderService removeStoreOnWorkOrderService = (IRemoveStoresOnWorkOrderService) mocks.mock(
            IRemoveStoresOnWorkOrderService.class
        );
        Application.SERVICE.setMock(IRemoveStoresOnWorkOrderService.class, removeStoreOnWorkOrderService);
        Test.startTest();
        RemoveStoresOnWorkOrderController.removeStores(parentWorkOrderId, accountIds,true,System.today()+100);
        Test.stopTest();
        ((IRemoveStoresOnWorkOrderService) mocks.verify(removeStoreOnWorkOrderService, 1))
            .removeStores(parentWorkOrderId, accountIds,true,System.today()+100);
    }
}