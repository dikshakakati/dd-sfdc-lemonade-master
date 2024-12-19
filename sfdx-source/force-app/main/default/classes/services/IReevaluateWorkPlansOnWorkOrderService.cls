/**
 * @author Deloitte
 * @date 13/07/2022
 * @description Interface for service class of ReevaluateWorkPlansOnWorkOrder controller related logic.
 */
public interface IReevaluateWorkPlansOnWorkOrderService {
    /**
     * @description To re-evaulates Work Plans on parent and child Work Orders
     * by passing the parent Work Order Id.
     * @param parentWorkOrderId
     */
    void reevaluateWorkPlans(Id parentWorkOrderId);
}