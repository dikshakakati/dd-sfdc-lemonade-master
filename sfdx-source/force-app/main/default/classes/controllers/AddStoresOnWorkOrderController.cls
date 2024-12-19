/**
 * @author Deloitte
 * @date 27/04/2022
 * @description Controller class for addStoresOnWorkOrder lightning web component.
 */
public with sharing class AddStoresOnWorkOrderController {

     /**
     * @description It will validate the selected stores.
     * @JIRA#
     * @param parentWorkOrderId
     * @param storeAccountIds
     * @return Map<String, List<String>>
     */
    @AuraEnabled
    public static Map<String, List<String>> validateStores(Id parentWorkOrderId, String storeAccountIds) {

        return new AddStoresOnWorkOrderServiceImpl().validateStores(parentWorkOrderId, storeAccountIds);
    }

    /**
     * @description It creates child Work Orders for the selected stores.
     * @JIRA# LEM-2013
     * @param parentWorkOrderId
     * @param storeAccountIds
     * @return String - validation error message
     */
    @AuraEnabled
    public static String createChildWorkOrders(Id parentWorkOrderId, String storeAccountIds) {
        return AddStoresOnWorkOrderService.createChildWorkOrders(
            parentWorkOrderId,
            storeAccountIds
        );
    }

    /**
     * @description It fetches in-coverage and verified store Accounts and related Xrefs
     * which are related to the business Account attached to parent Work Order and doesn't have
     * any child Work Order.
     * @JIRA# LEM-2013
     * @param addStoresContainerJSON
     * @return List<AccountWrapper>
     */
    @AuraEnabled(cacheable=true)
    public static AddStoresContainer fetchVerifiedStores(String addStoresContainerJSON) {
        return AddStoresOnWorkOrderService.fetchVerifiedStores(addStoresContainerJSON);
    }

    /**
     * @description It is used to search in-coverage and verified store Accounts and related Xrefs
     * which are related to the business Account attached to parent Work Order and doesn't have
     * any child Work Order by matching the passed search key with the Account's Name or Address
     * or Xref's External Id.
     * @JIRA# LEM-3495
     * @param addStoresContainerJSON
     * @return AddStoresContainer
     */
    @AuraEnabled(cacheable=true)
    public static AddStoresContainer findVerifiedStoresBySearchKey(String addStoresContainerJSON) {
        return AddStoresOnWorkOrderService.findVerifiedStoresBySearchKey(addStoresContainerJSON);
    }

    /**
     * @description It fetches store Accounts which are related to the parent Work Order
     * @JIRA# LEM-5343
     * @param addStoresContainerJSON
     * @return AddStoresContainer
     */
    @AuraEnabled(cacheable=true)
    public static AddStoresContainer fetchStoresAdded(String addStoresContainerJSON) {
        return AddStoresOnWorkOrderService.fetchStoresAdded(addStoresContainerJSON);
        //return AddStoresOnWorkOrderService.fetchVerifiedStores(addStoresContainerJSON);
    }

    /**
     * @description It fetches store Accounts which are related to the parent Work Order
     * by matching the passed search key with the Account's Name or Address or Xref's External Id.
     * @JIRA# LEM-5343
     * @param addStoresContainerJSON
     * @return AddStoresContainer
     */
    @AuraEnabled(cacheable=true)
    public static AddStoresContainer findStoresAddedBySearchKey(String addStoresContainerJSON) {
        return AddStoresOnWorkOrderService.findStoresAddedBySearchKey(addStoresContainerJSON);
    }
}