/**
 * @author Deloitte
 * @date 07/18/2022
 * @description Controller class for readinessCheckOnStores lightning web component.
 */
public with sharing class StoreReadinessCheckController {
    private static final String READINESS_CHECK_TRIGGER_SOURCE_MANUAL = 'Manual';

    /**
     * @description It validates readiness of the stores associated with child Work Orders
     * for the given parent Work Order Id.
     * @JIRA# LEM-1684
     * @param parentWorkOrderId
     * @return Boolean
     */
    @AuraEnabled
    public static Boolean validateStoresReadiness(Id parentWorkOrderId) {
        Boolean isAsyncCall = WorkOrdersService.runReadinessCheckOnParentWorkOrders(
            new Set<Id>{ parentWorkOrderId },
            READINESS_CHECK_TRIGGER_SOURCE_MANUAL
        );
        return isAsyncCall;
    }
}