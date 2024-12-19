/**
 * @author Deloitte
 * @date 16/04/2024
 * @description Service Interface for child Work Orders creation related logic.
 */
public interface IChildWorkOrdersCreationService {
   /**
     * @description It initiates association of Stores to the parent Marketing Kit WorkOrder.
     * @JIRA# LEM-15317
     * @param originatingWorkOrderIdToMarketingKitWorkOrder
     */
    void initiateStoreAssociationOnMarketingKitWorkOrder(
        Map<Id,WorkOrder> originatingWorkOrderIdToMarketingKitWorkOrder
    );
}