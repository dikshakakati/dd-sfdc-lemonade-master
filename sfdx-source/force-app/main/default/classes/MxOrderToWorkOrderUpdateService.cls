/**
 * @author Deloitte
 * @date 11/15/2024
 * @description Service class to update Work Order fields
 */
public inherited sharing class MxOrderToWorkOrderUpdateService {
    /** 
     * @description Updates the Work Order Photo Shoot date and time.
     * @JIRA LEM-24164
     * @param mxOrders
    */
    public static void updateWorkOrderPhotoShootDateAndTime(List<Mx_Order__c> mxOrders) {
        service().updateWorkOrderPhotoShootDateAndTime(mxOrders);
    }
    /**
     * @description It creates instance of MxOrderToWorkStepStatusUpdateServiceImpl class.
     * @JIRA# LEM-24164
     * @return IMxOrderToWorkStepStatusUpdateService
     */
    private static IMxOrderToWorkOrderUpdateService service() {
        return (IMxOrderToWorkOrderUpdateService) Application.Service.newInstance(
            IMxOrderToWorkOrderUpdateService.class
        );
    }
}