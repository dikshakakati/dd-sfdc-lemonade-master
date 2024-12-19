/**
 * @author Deloitte
 * @date 27/06/2022
 * @description Service class for AddStoresOnWorkOrderController related logic.
 */
public inherited sharing class AddStoresOnWorkOrderService {
    /**
     * @description It creates child Work Orders on passed parent Work Order
     * for the selected stores.
     * @JIRA# LEM-2013
     * @param parentWorkOrderId
     * @param storeAccountIds
     * @return String - validation error message
     */
    public static String createChildWorkOrders(Id parentWorkOrderId, String storeAccountIds) {
        return service().createChildWorkOrders(parentWorkOrderId, storeAccountIds);
    }

    /**
     * @description It fetches in-coverage verified store Accounts and associated Xrefs
     * which are related to the business Account attached to parent Work Order and doesn't have
     * any child Work Orders.
     * @JIRA# LEM-2013, LEM-3495, LEM-3672
     * @param addStoresContainerJSON
     * @return AddStoresContainer
     */
    public static AddStoresContainer fetchVerifiedStores(String addStoresContainerJSON) {
        return service().fetchVerifiedStores(addStoresContainerJSON);
    }

    /**
     * @description It is used to search in-coverage and verified store Accounts and related Xrefs
     * which are related to the business Account attached to parent Work Order and doesn't have
     * any child Work Order by matching the passed search key with the Account's Name or Address
     * or Xref's External Id.
     * @JIRA# LEM-3495, LEM-3672
     * @param addStoresContainerJSON
     * @return AddStoresContainer
     */
    public static AddStoresContainer findVerifiedStoresBySearchKey(String addStoresContainerJSON) {
        return service().findVerifiedStoresBySearchKey(addStoresContainerJSON);
    }

    /**
     * @description It fetches store Accounts which are related to the parent Work Order
     * @JIRA# LEM-5343
     * @param addStoresContainerJSON
     * @return AddStoresContainer
     */
    public static AddStoresContainer fetchStoresAdded(String addStoresContainerJSON) {
        return service().fetchStoresAdded(addStoresContainerJSON);
    }

    /**
     * @description It fetches store Accounts which are related to the parent Work Order
     * by matching the passed search key with the Account's Name or Address or Xref's External Id.
     * @JIRA# LEM-5343
     * @param addStoresContainerJSON
     * @return AddStoresContainer
     */
    public static AddStoresContainer findStoresAddedBySearchKey(String addStoresContainerJSON) {
        return service().findStoresAddedBySearchKey(addStoresContainerJSON);
    }

    /**
     * @description It creates instance of AddStoresOnWorkOrderServiceImpl class.
     * @return IAddStoresOnWorkOrderService - instance of AddStoresOnWorkOrderServiceImpl
     */
    private static IAddStoresOnWorkOrderService service() {
        return (IAddStoresOnWorkOrderService) Application.Service.newInstance(
            IAddStoresOnWorkOrderService.class
        );
    }
}