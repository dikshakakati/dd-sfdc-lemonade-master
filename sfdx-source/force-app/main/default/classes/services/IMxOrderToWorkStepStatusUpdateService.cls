/**
 * @author Deloitte
 * @date 05/06/2024
 * @description Interface of service class for Status Update for Mx Order and WorkStep.
 */
public interface IMxOrderToWorkStepStatusUpdateService {
    /**
     * @description It is used for updating the WorkStep status.
     * @JIRA# LEM-13508
     * @param mxOrders
     */
    void updateWorkStepStatus(List<MX_Order__c> mxOrders);
}