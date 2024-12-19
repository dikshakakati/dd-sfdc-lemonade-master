/**
 * @author Deloitte
 * @date 08/04/2022
 * @description Interface for WorkPlansSelector class methods.
 */
public interface IWorkPlansSelector extends fflib_ISObjectSelector {
    /**
     * @description It is used for getting count of validated Child WorkPlans with "Completed"
     * Acivation Checklist Validation Status grouped by Parent WorkPlan.
     * @param parentIds - Set of Parent WorkPlan Ids
     * @return Aggregate[]
     */
    Aggregate[] getNumberOfActivationChecklistValidationCompletedChildWorkPlansGroupedByParentWorkPlan(
        Set<Id> parentIds
    );

    /**
     * @description It is used for getting sum of workable WorkSteps on Child WorkPlan
     * grouped by Parent WorkPlan.
     * @param parentIds - Set of Parent WorkPlan Ids
     * @return Aggregate[]
     */
    Aggregate[] getSumOfNumberOfWorkableWorkStepsOnChildWorkPlanGroupedByParentWorkPlan(
        Set<Id> parentIds
    );

    /**
     * @description It is used for getting WorkPlan records by set of Ids.
     * @param workPlanIds
     * @return List<WorkPlan>
     */
    List<WorkPlan> selectById(Set<Id> workPlanIds);

    /**
     * @description It is used for getting WorkPlan record filtered by Id
     * and Store Account RecordType.
     * @param workPlanId - WorkPlan Id
     * @return List<WorkPlan>
     */
    List<WorkPlan> selectByIdAndStoreAccountRecordType(Id workPlanId);

    /**
     * @description It queries WorkPlans with WorkOrder details.
     * @param workPlanIds
     * @return List<WorkPlan>
     */
    List<WorkPlan> selectWorkPlansWithWorkOrderDetails(Set<Id> workPlanIds);

    /**
     * @description It queries parent and child WorkPlans by passed recordIds.
     * @param recordIds
     * @return List<WorkPlan>
     */
    List<WorkPlan> selectWorkPlansWithChildWorkPlanDetails(Set<String> recordIds);

    /**
     * @description It queries WorkPlans associated with WorkOrders.
     * @param workOrderIds
     * @return List<WorkPlan>
     */
    List<WorkPlan> selectWorkPlansByWorkOrderIds(Set<Id> workOrderIds);

    /**
     * @description Gets integration info for all Work Plans with this Parent Work Plan Id
     * @param parentWorkPlanId
     * @return List<WorkPlan>
     */
    List<WorkPlan> selectIntegrationInfoForWorkPlansByParentWorkPlanId(Id parentWorkPlanId);

    /**
     * @description It queries WorkPlans and worksteps associated with IntegrationRequests.
     * @param integrationRequestIds
     * @return List<WorkPlan>
     */
    List<WorkPlan> selectWorkPlansByIntegrationRequestId(Set<Id> integrationRequestIds);

    /**
     * @description It queries child Work Plans using the parent Work Plan Ids.
     * @param parentWorkPlanIds
     * @return List<WorkPlan>
     */
    List<WorkPlan> selectByParentWorkPlanIds(Set<Id> parentWorkPlanIds);

    /**
     * @description It queries WorkPlans using the parent Work Order Id.
     * @param parentWorkOrderId
     * @return List<WorkPlan>
     */
    List<WorkPlan> selectIntegrationInfoForWorkPlansByParentWorkOrderDriveId(Id parentWorkOrderId);

    /**
     * @description It queries WorkPlans using the Store Account IDs and WorkPlan type
     * @param storeAccIds
     * @param type
     * @return List<WorkPlan>
     */
    List<WorkPlan> selectWorkPlansByStoreAccountIDAndType(Set<Id> storeAccIds, Set<String> type);

    /**
     * @description It queries WorkPlans with WorkOrder and Photoshoot Store Location details.
     * @JIRA# LEM-13504
     * @param workPlanIds
     * @return List<WorkPlan>
     */
    List<WorkPlan> selectWorkPlansWithWorkOrderAndPhotoshootStoreLocationDetails(
        Set<Id> workPlanIds
    );

    /**
     * @description It queries Work Plans with Work Order details by the passed Work Plan Ids and Types.
     * @JIRA# LEM-15318
     * @param workPlanIds - WorkPlanIds
     * @param types - WorkPlanTpe
     * @return List<WorkPlan>
     */
    List<WorkPlan> selectWorkPlansByWorkPlanIdsAndTypes(Set<Id> workPlanIds, Set<String> types);

    /**
     * @description It fetches Work Plans with Work Order details using the passed Work Plan Ids.
     * @JIRA# LEM-15997
     * @param workPlanIds
     * @return List<WorkPlan>
     */
    List<WorkPlan> selectWorkPlansWithWorkOrderDetailsByParentWorkPlanIds(Set<Id> workPlanIds);

    /**
     * @description It queries WorkPlans by status.
     * @JIRA LEM-13576
     * @param emailRefIds
     * @return List<WorkPlan>
     */
    List<WorkPlan> selectWorkPlansByEmailRefId(set<String> emailRefIds);

    /**
     * @description It is used to fetch work plan details
     * @JIRA# LEM-13577
     * @param workPlanIds
     * @return List<WorkPlan>
     */
    List<WorkPlan> selectByWorkPlanIds(Set<Id> workPlanIds);

     /**
     * @description Select workplans by passed parent workplan, storeIds and Type
     * @JIRA# LEM-13578
     * @param storeAccIds -storeAccountIds
     * @param type - WorkPlanTpe
     * @param parentWorkplan - parentWorkPlan
     * @return List<WorkPlan>
     */
     List<WorkPlan> selectWorkPlansByParentWorkPlanAndStoreAccount(Set<Id> storeAccIds, Set<String> type, Id parentWorkplan);
    /**
     * @description It queries WorkPlans with WorkOrder associated to Virtual Stores.
     * @JIRA# LEM-21618
     * @param workPlanIds
     * @return List<WorkPlan>
     */
    List<WorkPlan> selectWorkPlansWithWorkOrderAssociatedToVirtualStores(Set<Id> workPlanIds);

    /**
     * @description It is used to query WorkPlans with verified POS Intergation Types.
     * @JIRA# LEM-25823
     * @param workPlanIds
     * @return List<WorkPlan>
     */
    List<WorkPlan> selectWorkPlansWithVerifiedPOSIntegrationTypes(Set<Id> workPlanIds);
}