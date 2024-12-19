/**
 * @author Deloitte
 * @date 16/04/2024
 * @description Service class for child Work Orders creation related logic.
 */
public inherited sharing class ChildWorkOrdersCreationService {
    /**
     * @description It initiates association of Stores to the parent Marketing Kit WorkOrder.
     * @JIRA# LEM-15317
     * @param originatingWorkOrderIdToMarketingKitWorkOrder
     */
    public static void initiateStoreAssociationOnMarketingKitWorkOrder(
        Map<Id,WorkOrder> originatingWorkOrderIdToMarketingKitWorkOrder
    ){

        service().initiateStoreAssociationOnMarketingKitWorkOrder(originatingWorkOrderIdToMarketingKitWorkOrder);
    }

    /**
     * @description calling newInstance for service class.
     * @return IChildWorkOrdersCreationService - returning interface.
     */
    private static IChildWorkOrdersCreationService service() {
        return (IChildWorkOrdersCreationService) Application.SERVICE.newInstance(
            IChildWorkOrdersCreationService.class
        );
    }
}