/**
 * @author Deloitte
 * @date 20/07/2022
 * @description Test class for StoreReadinessCheckController class.
 * Suppressed Warnings since mock verify method does not require System Assert statements.
 */
@isTest(seeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
public class StoreReadinessCheckControllerTest {
    private static final String READINESS_CHECK_TRIGGER_SOURCE_MANUAL = 'Manual';
    private static final String WORKORDER_TYPE_MARKETPLACE = 'Marketplace';

    /**
     * @description To test when parent WorkOrder Id received from lwc then
     * child WorkOrder Ids are queried and passed to StoreReadinessCheckService class.
     */
    @isTest
    private static void testWhenParentWorkOrderIdReceivedThenCollectChildWorkOrderIds() {
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
            fflib_IDGenerator.generate(Account.SObjectType),
            WORKORDER_TYPE_MARKETPLACE
        );
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersService mockWorkOrdersService = (IWorkOrdersService) mocks.mock(
            IWorkOrdersService.class
        );
        Application.SERVICE.setMock(IWorkOrdersService.class, mockWorkOrdersService);
        StoreReadinessCheckController.validateStoresReadiness(parentWorkOrder.Id);
        ((IWorkOrdersService) mocks.verify(mockWorkOrdersService, 1))
            .runReadinessCheckOnParentWorkOrders(
                new Set<Id>{ parentWorkOrder.Id },
                READINESS_CHECK_TRIGGER_SOURCE_MANUAL
            );
    }
}