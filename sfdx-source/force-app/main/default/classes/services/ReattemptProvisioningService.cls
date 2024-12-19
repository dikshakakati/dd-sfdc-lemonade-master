/**
 * @author atg
 * @date 08/08/2022
 * @description Service class for ReattemptProvisioningService related logic.
 */
public inherited sharing class ReattemptProvisioningService {
    /**
     * @description For Business References or Xrefs that failed integration try to integrate them again.
     * @JIRA# LEM-2226
     * @param parentWorkPlanId
     * @return boolean
     */
    public static boolean reattemptProvisioning(Id parentWorkPlanId) {
        return service().reattemptProvisioning(parentWorkPlanId);
    }

    /**
     * @description For Business References or Xrefs that failed integration try to integrate them again called from Parent WorkOrder.
     * @JIRA# LEM-7366
     * @param parentWorkOrderID
     * @return boolean
     */
    public static boolean reattemptProvisioningOnWorkOrder(Id parentWorkOrderID) {
        return service().reattemptProvisioningOnWorkOrder(parentWorkOrderID);
    }

    /**
     * @description It creates instance of ReattemptProvisioningServiceImpl class.
     * @return IReattemptProvisioningService - instance of ReattemptProvisioningServiceImpl
     */
    private static IReattemptProvisioningService service() {
        return (IReattemptProvisioningService) Application.Service.newInstance(
            IReattemptProvisioningService.class
        );
    }
}