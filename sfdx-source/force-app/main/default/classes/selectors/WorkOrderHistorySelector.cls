/**
 * @author Deloitte
 * @date 03/16/2023
 * @description Selector class for WorkOrderHistory object.
 */
public inherited sharing class WorkOrderHistorySelector extends fflib_SObjectSelector implements IWorkOrderHistorySelector {
    private static final String WORK_ORDER_STATUS_FIELD = 'Status';

    /**
     * @description Default constructor for the WorkOrderHistorySelector class.
     * @return IWorkOrderHistorySelector
     */
    public static IWorkOrderHistorySelector newInstance() {
        return (IWorkOrderHistorySelector) Application.Selector.newInstance(
            WorkOrderHistory.SObjectType
        );
    }

    /**
     * @description It is used for getting SObject type.
     * @return SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return WorkOrderHistory.SObjectType;
    }

    /**
     * @description It is used for getting the fields on WorkOrderHistory object.
     * @JIRA# LEM-5159
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            WorkOrderHistory.Id,
            WorkOrderHistory.Field,
            WorkOrderHistory.OldValue,
            WorkOrderHistory.WorkOrderId
        };
    }

    /**
     * @description It queries Work Order History records having Status field’s history
     * using the passed Work Order Ids.
     * @JIRA# LEM-5159
     * @param workOrderIds
     * @return List<WorkOrderHistory>
     */
    public List<WorkOrderHistory> selectStatusHistoryByWorkOrderIds(Set<Id> workOrderIds) {
        fflib_QueryFactory workOrderHistoryQuery = newQueryFactory()
            .setCondition('WorkOrderId IN :workOrderIds AND Field = :WORK_ORDER_STATUS_FIELD')
            .setOrdering('WorkOrderId', fflib_QueryFactory.SortOrder.ASCENDING)
            .addOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        return (List<WorkOrderHistory>) Database.query(workOrderHistoryQuery.toSOQL());
    }
}