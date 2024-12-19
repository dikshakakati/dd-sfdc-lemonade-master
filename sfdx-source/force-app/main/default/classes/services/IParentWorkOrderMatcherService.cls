/**
 * @author Deloitte
 * @date 10/19/2022
 * @description Interface of service class for parent Work Order matching related logic.
 */
public interface IParentWorkOrderMatcherService {
    /**
     * @description It is used to get parent Work Order record by matching Contract
     * against Order Product for "Post-Sales - Rate Change" Work Order where
     * Opportunity will be populated.
     * @param orderItem
     * @param contractIdToParentWorkOrders
     * @return WorkOrder
     */
    WorkOrder matchByContractOnRateChange(
        OrderItem orderItem,
        Map<Id, List<WorkOrder>> contractIdToParentWorkOrders
    );

    /**
     * @description It is used to get parent Work Order record
     * by matching Nintex Id against Nintex Id of Opportunity associated
     * with Order of Order Product.
     * @param orderItem
     * @param nintexIdToParentWorkOrders
     * @return WorkOrder
     */
    WorkOrder matchByNintexId(
        OrderItem orderItem,
        Map<String, List<WorkOrder>> nintexIdToParentWorkOrders
    );

    /**
     * @description It is used to get parent Work Order record
     * by matching PDOA criteria against Order Product.
     * @param orderItem
     * @param businessAccountIdToParentWorkOrders
     * @return WorkOrder
     */
    WorkOrder matchByPDOA(
        OrderItem orderItem,
        Map<Id, List<WorkOrder>> businessAccountIdToParentWorkOrders
    );
    /**
     * @description It is used to get parent Work Order record
     * by matching rate change type
     * @JIRA# LEM-12932
     * @param orderItem
     * @param businessAccountIdToParentWorkOrders
     * @return WorkOrder
     */
    WorkOrder matchByRateChangeTypeFromRateChangeRequest(
        OrderItem orderItem,
        Map<Id, List<WorkOrder>> businessAccountIdToParentWorkOrders
    );

    /**
     * @description It is used to get parent Work Order record for Order Product
     * by matching type without matching PDOA.
     * @param orderItem
     * @param businessAccountIdToParentWorkOrders
     * @return WorkOrder
     */
    WorkOrder matchByType(
        OrderItem orderItem,
        Map<Id, List<WorkOrder>> businessAccountIdToParentWorkOrders
    );

    /**
     * @description It is used to get parent Work Order record
     * by matching Unique Identifier.
     * @JIRA# LEM-15782
     * @param orderItem
     * @param uniqueIdentifierToParentWorkOrders
     * @return WorkOrder
     */
    WorkOrder matchByMxOnboardingLink(
        OrderItem orderItem,
        Map<String, List<WorkOrder>> uniqueIdentifierToParentWorkOrders
    );
}