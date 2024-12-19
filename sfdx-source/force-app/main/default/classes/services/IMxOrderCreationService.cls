/**
 * @author Deloitte
 * @date 04/22/2024
 * @description Interface of service class for product bundle selections for tablet worksteps.
 */
public interface IMxOrderCreationService {
    /**
     * @description It is used for generating product bundles for tablet worksteps
     * @param workSteps
     */
    void generateMxOrderAndSelectProduct(List<WorkStep> workSteps);

    /**
     * @description It is used for generating product bundles for tablet worksteps
     * @param flowInput
     * @param isNetNew
     */
    void generateMerchantOrder(GuidedFlowInputs flowInput, Boolean isNetNew);

    /**
     * @description It is used for generating photoshoot mxOrders.
     * @param workplans
     */
    void generatePhotoShootMxOrder(List<WorkPlan> workplans);

    /**
     * @description It is used for generating "Marketing Kit" MxOrders.
     * @param workplans
     */
    void generateMarketingKitMxOrders(List<WorkPlan> workplans);

    /**
     * @description It is used for generating Merchant Orders for tablet worksteps
     * @param workSteps
     * @param childWOToStagingRequest
     */
    void generateMxOrderforTabletBulkRequest(Map<Id,WorkStep> workSteps,Map<Id,Staging_Bulk_Upload_Request__c> childWOToStagingRequest);
}