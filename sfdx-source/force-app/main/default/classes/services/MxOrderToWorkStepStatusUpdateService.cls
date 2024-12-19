/**
 * @author Deloitte
 * @date 05/06/2024
 * @description Service class for Status Update for Mx Order and WorkStep.
 */
public inherited sharing class MxOrderToWorkStepStatusUpdateService {
    /**
     * @description It is used for updating the WorkStep status.
     * @JIRA# LEM-13508
     * @param mxOrders
     */
    public static void updateWorkStepStatus(List<MX_Order__c> mxOrders) {
        service().updateWorkStepStatus(mxOrders);
    }

    /**
     * @description It creates instance of MxOrderToWorkStepStatusUpdateServiceImpl class.
     * @JIRA# LEM-13508
     * @return IMxOrderToWorkStepStatusUpdateService
     */
    private static IMxOrderToWorkStepStatusUpdateService service() {
        return (IMxOrderToWorkStepStatusUpdateService) Application.Service.newInstance(
            IMxOrderToWorkStepStatusUpdateService.class
        );
    }
}