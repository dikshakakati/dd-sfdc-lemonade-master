/**
 * @author Deloitte
 * @date 11/15/2024
 * @description Interface of service class for Work Order Update for Mx Order
 */
public interface IMxOrderToWorkOrderUpdateService {
    /** 
     * @description Updates the Work Order Photo Shoot date and time.
     * @JIRA LEM24164
     * @param mxOrders
    */
    void updateWorkOrderPhotoShootDateAndTime(List<Mx_Order__c> mxOrders);
}