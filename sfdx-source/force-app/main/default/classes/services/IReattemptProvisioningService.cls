/**
 * @author atg
 * @date 08/08/2022
 * @description Interface for service class of ReattemptProvisioning controller related logic.
 */
public interface IReattemptProvisioningService {
    /**
     * @description To reprovision Business References or Xrefs that failed Integration.
     * @param parentWorkPlanId
     * @return boolean
     */
    boolean reattemptProvisioning(Id parentWorkPlanId);

     /**
     * @description To reprovision Business References or Xrefs that failed Integration called from Parent WorkOrder.
     * @param parentWorkOrderId
     * @return boolean
     */
    boolean reattemptProvisioningOnWorkOrder(Id parentWorkOrderId);
}