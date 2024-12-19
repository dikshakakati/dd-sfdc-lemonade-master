/**
 * @author Deloitte
 * @date 08/08/2024
 * @description Service Implementation class for creating Parent Work Order, Child Work Order and Merchant Orders 
 * for Tablet, Marketing Kit and Photoshoot Type of Bulk Requests
 */
public inherited sharing class BulkOrdersCreationService {
    /**
     * @description It is used for creating Parent Work Order and Child Work Order for Bulk Request
     * @param stagingRequests
     */
    public static void createBulkParentAndChilOrders(List<Staging_Bulk_Upload_Request__c> stagingRequests) {
        service().createBulkParentAndChilOrders(stagingRequests);
    }

    /**
     * @description It is used for creating Parent Work Order and Child Work Order for Bulk Request
     * @return IBulkOrdersCreationService
     */
    private static IBulkOrdersCreationService service() {
        return (IBulkOrdersCreationService) Application.Service.newInstance(
            IBulkOrdersCreationService.class
        );
    }
}
