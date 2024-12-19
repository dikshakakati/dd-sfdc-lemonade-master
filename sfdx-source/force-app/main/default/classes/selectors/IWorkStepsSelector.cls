/**
 * @author Deloitte
 * @date 15/04/2022
 * @description Interface for WorkStep selector class methods.
 */
public interface IWorkStepsSelector extends fflib_ISObjectSelector {
    /**
     * @description It is used for getting count of Blocked and Resolved child WorkSteps
     * filtered by parentId and grouped by parentId and Status.
     * @param parentIds
     * @return Aggregate[]
     */
    Aggregate[] getChildWorkStepsCountFilteredByAndGroupedByParentAndStatus(Set<Id> parentIds);

    /**
     * @description It is used to get WorkSteps' details by
     * passed set of Store Account Ids.
     * @param storeAccountIds
     * @return List<WorkStep>
     */
    List<WorkStep> getDeliverTabletWorkStepsDetailsByStoreAccount(Set<Id> storeAccountIds);

    /**
     * @description It is used to get WorkSteps' details by
     * passed set of Store Account Ids.
     * @param storeAccountIds
     * @return List<WorkStep>
     */
    List<WorkStep> getNonCompleteMarketplaceSetupBusinessWorkStepsByStoreAccount(
        Set<Id> storeAccountIds
    );

    /**
     * @description It is used to get WorkSteps' details for COO
     * passed set of Store Account Ids.
     * @param storeAccountIds
     * @return List<WorkStep>
     */
    List<WorkStep> getNonCompleteCOOSetupBusinessWorkStepsByStoreAccount(Set<Id> storeAccountIds);

    /**
     * @description It is used to get WorkSteps details by passed set of business reference id.
     * @JIRA# LEM-3166
     * @param storeAccountIds
     * @return List<WorkStep>
     */
    List<WorkStep> getNonCompleteWorkStepRecForDriveByBusinessAccount(Set<Id> storeAccountIds);
    /**
     * @description It is used to get WorkSteps details by
     * passed set of store Account Ids.
     * @JIRA# LEM-2203
     * @param storeAccountIds
     * @return List<WorkStep>
     */
    List<WorkStep> getNonCompleteSetupStoreWorkStepsByStoreAccount(Set<Id> storeAccountIds);
    /**
     * @description It is used to get WorkSteps details by passed set of store Account Ids.
     * @JIRA# LEM-3166
     * @param storeAccountIds
     * @return List<WorkStep>
     */
    List<WorkStep> getNonCompleteSetupStoreWorkStepsByStoreAccountForTypeStore(
        Set<Id> storeAccountIds
    );

    /**
     * @description It is used for getting count of WorkSteps filtered by passed condition and
     * parentId and grouped by passed field and Status.
     * @param condition
     * @param groupByField
     * @param parentIds
     * @return Aggregate[]
     */
    Aggregate[] getWorkStepsCountFilteredByConditionGroupedByParentAndStatus(
        String condition,
        String groupByField,
        Set<Id> parentIds
    );

    /**
     * @description It is used for getting count of WorkSteps filtered by WorkOrderID and Status.
     * @param workOrderIds
     * @return Aggregate[]
     */
    Aggregate[] getWorkStepsCountFilteredByConditionGroupedByWorkOrderIdAndStatus(Id workOrderIds);

    /**
     * @description It is used to get WorkSteps by passed Ids.
     * @param workStepIds
     * @return List<WorkStep>
     */
    List<WorkStep> selectById(Set<Id> workStepIds);

    /**
     * @description It is used to query child Activation Checklist WorkSteps by the passed parent WorkStep Ids.
     * @param parentWorkStepIds
     * @return List<WorkStep>
     */
    List<WorkStep> selectChildActivationChecklistWorkStepsByParentWorkStepIds(
        Set<Id> parentWorkStepIds
    );

    /**
     * @description It is used to query child WorkSteps by the passed parent WorkStep Ids.
     * @param parentWorkStepIds
     * @return List<WorkStep>
     */
    List<WorkStep> selectChildWorkStepsByParentWorkStepIds(Set<Id> parentWorkStepIds);

    /**
     * @description It is used to get "Link Implementation" WorkSteps attached to passed WorkPlans
     * where Status is not Complete.
     * @param workPlanIds
     * @return List<WorkStep>
     */
    List<WorkStep> selectLinkImplementationWorkStepAttachedToWorkPlan(Set<Id> workPlanIds);

    /**
     * @description It is used to query first Work Step in execution order for Storefront
     * Work Order filtered by the passed store Account Ids.
     * @param storeAccountIds
     * @return List<WorkStep>
     */
    List<WorkStep> selectFirstStorefrontWorkStepByStoreAccountIds(Set<Id> storeAccountIds);

    /**
     * @description It is used to query child WorkSteps by the passed parent WorkOrder Ids.
     * @param workOrderIds
     * @return List<WorkStep>
     */
    List<WorkStep> selectWorkStepsByWorkOrderIds(Set<Id> workOrderIds);

    /**
     * @description It is used to query child WorkSteps with all default feilds by the passed parent WorkOrder Ids.
     * @param workOrderIds
     * @return List<WorkStep>
     */
    List<WorkStep> selectWorkStepsAllFieldsByWorkOrderIds(Set<Id> workOrderIds);

    /**
     * @description It is used to query child Work Steps using the passed store Account Ids and
     * Work Order Ids.
     * @param storeAccountIds
     * @param workOrderIds
     * @param workStepTypes
     * @return List<WorkStep>
     */
    List<WorkStep> selectByStoreAccountAndWorkOrderIds(
        Set<Id> storeAccountIds,
        Set<Id> workOrderIds,
        Set<String> workStepTypes
    );

    /**
     * @description It is used to query all child Work Steps for the Parent
     * @param parentWorkOrderIDs
     * @return List<WorkStep>
     */
    List<WorkStep> selectAllChildWorkStepsByParentWorkOrderID(Set<Id> parentWorkOrderIDs);

    /**
     * @description It is used to query all child Work Steps for the Parent
     * @param storeAccountIds
     * @param batchIds
     * @return List<WorkStep>
     */
    List<WorkStep> selectChildWorkStepsByStoreAccountIdsAndBatchId(
        Set<Id> storeAccountIds,
        Set<String> batchIds
    );

    /**
     * @description It is used to query child Work Steps for the passed store Account Ids and Type.
     * @param storeAccountIds
     * @param type
     * @param batchIds
     * @return List<WorkStep>
     */
    List<WorkStep> selectChildWorkStepsByStoreAccountIdsAndTypeAndBatchId(
        Set<Id> storeAccountIds,
        Set<String> type,
        Set<String> batchIds
    );

    /**
     * @description It is used to query child Work Steps for the passed store Account Ids by Type
     * @param storeAccountIds
     * @param type
     * @return List<WorkStep>
     */
    List<WorkStep> selectChildWorkStepsByStoreAccountIdsAndType(
        Set<Id> storeAccountIds,
        Set<String> type
    );

    /**
     * @description It is used to query child Work Steps which have Blocked status using the passed Work Order Ids.
     * @param workOrderIds
     * @param statuses
     * @JIRA# LEM-9934
     * @return List<WorkStep>
     */
    List<WorkStep> selectWorkStepsByWorkOrderIdsAndStatuses(
        Set<Id> workOrderIds,
        Set<String> statuses
    );

    /**
     * @description It is used for retrieving Work steps based on parent Work Order Id & its work plan names
     * @param parentWorkOrderId
     * @param workPlanNames
     * @return List<WorkStep>
     */
    List<WorkStep> selectWorkStepsByParentWorkOrderAndPlanName(
        Id parentWorkOrderId,
        List<String> workPlanNames
    );

    /**
     * @description It is used to query child Work Steps based on workplan record.
     * @param workPlanId
     * @param workStepName
     * @return List<WorkStep>
     */
    List<WorkStep> selectChildWorkStepsByWorkPlan(Id workPlanId, String workStepName);

    /**
     * @description It is used to get WorkSteps by passed Ids.
     * @param workStepIds
     * @return List<WorkStep>
     */
    List<WorkStep> selectByIds(Set<Id> workStepIds);

    /**
     * @description It is used to query the Deliver Tablet WorkSteps by the passed parent
     * WorkOrder Ids.
     * @JIRA# LEM-13511
     * @param workOrderIds
     * @param types
     * @return List<WorkStep>
     */
    List<WorkStep> selectReturnLabelWorkStepsByWorkOrderIdsAndType(
        Set<Id> workOrderIds,
        Set<String> types
    );

    /**
     * @description It is used to query Work Steps by the passed parent Work Plan Ids.
     * WorkOrder Ids.
     * @JIRA# LEM-14124
     * @param workPlanIds
     * @return List<WorkStep>
     */
    List<WorkStep> selectByWorkPlanIds(Set<Id> workPlanIds);

    /**
     * @description It is used to query WorkSteps by the passed storeAccountIds and work step types.
     * @param storeAccountIds
     * @param workSteptypes
     * @return List<WorkStep>
     */
    List<WorkStep> selectWorkStepsByTypesAndStoreAccountIds(
        Set<Id> storeAccountIds,
        Set<String> workSteptypes
    );

    /**
     * @description It is used to query WorkSteps that are in Escalated or Blocked status
     * by the passed parent Work Order Ids.
     * @JIRA# LEM-13576
     * @param workPlanIds
     * @return List<WorkStep>
     */
    List<WorkStep> selectEscalatedOrBlockedByWorkPlanIds(Set<Id> workPlanIds);


     /**
     * @description It is used to query all child Work Steps for the passed Parent WorkOrder Ids if
     * Work Plan is dead and WS are not dead
     * @param workOrderIDs
     * @param wpName
     * @return List<WorkStep>
     */
    List<WorkStep> selectAllChildWorkStepsByWorkOrderIDToDeadOut(Set<Id> workOrderIDs,String wpName);
}