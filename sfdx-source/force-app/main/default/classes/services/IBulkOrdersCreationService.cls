/**
 * @author Deloitte
 * @date 08/08/2024
 * @description Interface of service class for creating Parent Work Order, Child Work Order and Merchant Orders 
 * for Tablet, Marketing Kit and Photoshoot Type of Bulk Requests
 */
public interface IBulkOrdersCreationService {
    /**
     * @description It is used for creating Parent Work Order and Child Work Order for Bulk Request
     * @param stagingRequests
     */
    void createBulkParentAndChilOrders(List<Staging_Bulk_Upload_Request__c> stagingRequests);
}
