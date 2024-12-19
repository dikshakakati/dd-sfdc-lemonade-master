/**
 * @author Deloitte
 * @date 06/27/2022
 * @description Interface for service class of AddStoresOnWorkOrder controller related logic.
 */
public interface IAddStoresOnWorkOrderService {
    /**
     * @description To create child Work Orders on passed parent Work Order
     * for the selected stores.
     * @param parentWorkOrderId
     * @param storeAccountIds
     * @return String
     */
    String createChildWorkOrders(Id parentWorkOrderId, String storeAccountIds);

    /**
     * @description To validate selected stores passed parent Work Order
     * for the selected stores.
     * @param parentWorkOrderId
     * @param storeAccountIds
     * @return Map<string, List<String>>
     */
    Map<String, List<String>> validateStores(Id parentWorkOrderId, String storeAccountIds);

    /**
     * @description To fetch in-coverage verified store Accounts and associated Xrefs
     * which are related to the business Account attached to parent Work Order and doesn't have
     * any child Work Orders.
     * @param addStoresContainerJSON
     * @return AddStoresContainer
     */
    AddStoresContainer fetchVerifiedStores(String addStoresContainerJSON);

    /**
     * @description It is used to search in-coverage and verified store Accounts and related Xrefs
     * which are related to the business Account attached to parent Work Order and doesn't have
     * any child Work Order by matching the passed search key with the Account's Name or Address
     * or Xref's External Id.
     * @param addStoresContainerJSON
     * @return AddStoresContainer
     */
    AddStoresContainer findVerifiedStoresBySearchKey(String addStoresContainerJSON);

    /**
     * @description It fetches store Accounts which are related to the parent Work Order
     * @JIRA# LEM-5343
     * @param addStoresContainerJSON
     * @return AddStoresContainer
     */
    AddStoresContainer fetchStoresAdded(String addStoresContainerJSON);

    /**
     * @description It fetches store Accounts which are related to the parent Work Order
     * by matching the passed search key with the Account's Name or Address or Xref's External Id.
     * @JIRA# LEM-5343
     * @param addStoresContainerJSON
     * @return AddStoresContainer
     */
    AddStoresContainer findStoresAddedBySearchKey(String addStoresContainerJSON);

    /**
     * @description It returns the concatenation of the passed validation error message
     * and store account names.
     * @JIRA# LEM-11611
     * @param parentWorkOrder
     * @param storeAccountIds
     * @return List<Account>
     */
    List<Account>  getStoresAccountsWithoutActiveMDSXrefs(
        WorkOrder parentWorkOrder,
        Set<Id> storeAccountIds
    );

     /**
     * @description It returns the concatenation of the passed validation error message
     * and store account names.
     * @JIRA# LEM-11611
     * @param validationErrorMessage
     * @param accountsWithValidationError
     * @return String
     */
     String getValidationErrorMessageByStoreAccounts(
        String validationErrorMessage,
        List<Account> accountsWithValidationError
    );
}