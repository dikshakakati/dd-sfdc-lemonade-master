/**
 * @author Deloitte
 * @date 13/07/2022
 * @description Service class for ReevaluateWorkPlansOnWorkOrderController related logic.
 */
public inherited sharing class ReevaluateWorkPlansOnWorkOrderService {
    /**
     * @description It re-evaulates Work Plans on parent and child Work Orders
     * by passing the parent Work Order Id.
     * @JIRA# LEM-1956
     * @param parentWorkOrderId
     */
    public static void reevaluateWorkPlans(Id parentWorkOrderId) {
        service().reevaluateWorkPlans(parentWorkOrderId);
    }

    /**
     * @description It creates instance of ReevaluateWorkPlansOnWorkOrderSrvcImpl class.
     * @return IReevaluateWorkPlansOnWorkOrderService - instance of ReevaluateWorkPlansOnWorkOrderSrvcImpl
     */
    private static IReevaluateWorkPlansOnWorkOrderService service() {
        return (IReevaluateWorkPlansOnWorkOrderService) Application.Service.newInstance(
            IReevaluateWorkPlansOnWorkOrderService.class
        );
    }
}