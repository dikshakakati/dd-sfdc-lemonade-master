/**
 * @author Deloitte
 * @date 13/07/2022
 * @description Controller class for reevaluateWorkPlansOnWorkOrder lightning web component.
 */
public with sharing class ReevaluateWorkPlansOnWorkOrderController {
    /**
     * @description It re-evaluates Work Plans on parent and child Work Orders
     * by passing the parent Work Order Id.
     * @JIRA# LEM-1956
     * @param parentWorkOrderId
     */
    @AuraEnabled
    public static void reevaluateWorkPlans(Id parentWorkOrderId) {
        ReevaluateWorkPlansOnWorkOrderService.reevaluateWorkPlans(parentWorkOrderId);
    }
}