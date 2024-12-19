/**
 * @author Deloitte
 * @date 10/19/2022
 * @description Service class for parent Work Order matching related logic.
 */
public inherited sharing class ParentWorkOrderMatcherService {
    /**
     * @description It is used to get parent Work Order record by matching Contract
     * against Order Product for "Post-Sales - Rate Change" Work Order where
     * Opportunity will be populated.
     * @JIRA# LEM-3357 & LEM-5118
     * @param orderItem
     * @param contractIdToParentWorkOrders
     * @return WorkOrder
     */
    public static WorkOrder matchByContractOnRateChange(
        OrderItem orderItem,
        Map<Id, List<WorkOrder>> contractIdToParentWorkOrders
    ) {
        return service().matchByContractOnRateChange(orderItem, contractIdToParentWorkOrders);
    }

    /**
     * @description It is used to get parent Work Order record
     * by matching Nintex Id against Nintex Id of Opportunity associated
     * with Order of Order Product.
     * @JIRA# LEM-3357
     * @param orderItem
     * @param nintexIdToParentWorkOrders
     * @return WorkOrder
     */
    public static WorkOrder matchByNintexId(
        OrderItem orderItem,
        Map<String, List<WorkOrder>> nintexIdToParentWorkOrders
    ) {
        return service().matchByNintexId(orderItem, nintexIdToParentWorkOrders);
    }

    /**
     * @description It is used to get parent Work Order record
     * by matching PDOA criteria against Order Product.
     * @JIRA# LEM-3357
     * @param orderItem
     * @param businessAccountIdToParentWorkOrders
     * @return WorkOrder
     */
    public static WorkOrder matchByPDOA(
        OrderItem orderItem,
        Map<Id, List<WorkOrder>> businessAccountIdToParentWorkOrders
    ) {
        return service().matchByPDOA(orderItem, businessAccountIdToParentWorkOrders);
    }

    /**
     * @description It is used to get parent Work Order record
     * by matching rate change type
     * @JIRA# LEM-12932
     * @param orderItem
     * @param businessAccountIdToParentWorkOrders
     * @return WorkOrder
     */
    public static WorkOrder matchByRateChangeTypeFromRateChangeRequest(
        OrderItem orderItem,
        Map<Id, List<WorkOrder>> businessAccountIdToParentWorkOrders
    ) {
        return service()
            .matchByRateChangeTypeFromRateChangeRequest(
                orderItem,
                businessAccountIdToParentWorkOrders
            );
    }

    /**
     * @description It is used to get parent Work Order record for Order Product
     * by matching type without matching PDOA.
     * @JIRA# LEM-3357, LEM-3384
     * @param orderItem
     * @param businessAccountIdToParentWorkOrders
     * @return WorkOrder
     */
    public static WorkOrder matchByType(
        OrderItem orderItem,
        Map<Id, List<WorkOrder>> businessAccountIdToParentWorkOrders
    ) {
        return service().matchByType(orderItem, businessAccountIdToParentWorkOrders);
    }

    /**
     * @description It is used to get parent Work Order record
     * by matching Unique Identifier.
     * @param orderItem
     * @param uniqueIdentifierToParentWorkOrders
     * @return WorkOrder
     */
    public static WorkOrder matchByMxOnboardingLink(
        OrderItem orderItem,
        Map<String, List<WorkOrder>> uniqueIdentifierToParentWorkOrders
    ) {
        return service().matchByMxOnboardingLink(orderItem, uniqueIdentifierToParentWorkOrders);
    }

    /**
     * @description It creates instance of ParentWorkOrderMatcherServiceImpl class.
     * @return IParentWorkOrderMatcherService - instance of ParentWorkOrderMatcherServiceImpl
     */
    private static IParentWorkOrderMatcherService service() {
        return (IParentWorkOrderMatcherService) Application.Service.newInstance(
            IParentWorkOrderMatcherService.class
        );
    }
}