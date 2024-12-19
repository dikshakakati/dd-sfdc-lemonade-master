/**
 * @author Deloitte
 * @date 04/22/2024
 * @description Interface of service class for product bundle selections for tablet worksteps.
 */
public inherited sharing class MxOrderCreationService {
    /**
     * @description It is used for generating product bundles for tablet worksteps
     * @param workSteps
     */
    public static void generateMxOrderAndSelectProduct(List<WorkStep> workSteps) {
        service().generateMxOrderAndSelectProduct(workSteps);
    }

    /**
     * @description It is used for generating product bundles for tablet worksteps
     * @param flowInput
     * @param isNetNew
     */
    public static void generateMerchantOrder(GuidedFlowInputs flowInput, Boolean isNetNew) {
        service().generateMerchantOrder(flowInput, isNetNew);
    }

    /**
     * @description It is used for generating photoshoot mxOrders
     * @param workplans
     */
    public static void generatePhotoShootMxOrder(List<WorkPlan> workplans) {
        service().generatePhotoShootMxOrder(workplans);
    }

    /**
     * @description It is used for generating "Marketing Kit" MxOrders.
     * @param workplans
     */
    public static void generateMarketingKitMxOrders(List<WorkPlan> workplans) {
        service().generateMarketingKitMxOrders(workplans);
    }

    /**
     * @description It is used for generating Merchant Orders for tablet worksteps
     * @param workSteps
     * @param childWOToStagingRequest
     */
    public static void generateMxOrderforTabletBulkRequest(Map<Id,WorkStep> workSteps,Map<Id,Staging_Bulk_Upload_Request__c> childWOToStagingRequest){
        service().generateMxOrderforTabletBulkRequest(workSteps,childWOToStagingRequest);
    }
        
    /**
     * @description It is used for generating photoshoot mxOrders //To do entire function
     * @return IMxOrderCreationService
     */
    private static IMxOrderCreationService service() {
        return (IMxOrderCreationService) Application.Service.newInstance(
            IMxOrderCreationService.class
        );
    }
}
