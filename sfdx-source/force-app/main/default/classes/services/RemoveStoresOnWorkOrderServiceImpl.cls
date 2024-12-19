/**
 * @author CriticalRiver
 * @date 05/02/2023
 * @description Service implementation class for RemoveStoresOnWorkOrderController related logic.
 */
public inherited sharing class RemoveStoresOnWorkOrderServiceImpl implements IRemoveStoresOnWorkOrderService {
    private static final String DELIMITER = ',';
    private static final String DEAD_STATUS = 'Dead';
    private static final String DISALLOW_PDOX_OVERRIDE_YES = 'Yes';
    private static final String PDOA_DELAY_DETAILS_REMOVE_STORES = System.Label.PDOADelayDetailsRemoveStores;
    private static final String PDOA_DELAY_REASON_OTHER = 'Other';
    private static final String PROVISIONING_STATUS_NOT_STARTED = 'Not Started';
    private static final String WORK_ORDER_STATUS_PLANNING = 'Planning';

    private List<WorkOrder> newParentWorkOrderList;

    /**
     * @description Default constructor to instantiate variables.
     */
    public RemoveStoresOnWorkOrderServiceImpl() {
        newParentWorkOrderList = new List<WorkOrder>();
    }

    /**
     * @description It removes selected from parent Work Order
     * for the selected stores.
     * @JIRA# LEM-5343
     * @param parentWorkOrderId
     * @param storeAccountIds
     * @param markAsDead
     * @param workOrderPDOA
     * @return String
     */
    public String removeStores(
        Id parentWorkOrderId,
        String storeAccountIds,
        Boolean markAsDead,
        Date workOrderPDOA
    ) {
        Set<Id> selectedStoreAccountIds = new Set<Id>((List<Id>) storeAccountIds.split(DELIMITER));
        String exceptionMessage;
        if (markAsDead) {
            exceptionMessage = updateChildWorkOrderStatus(
                parentWorkOrderId,
                selectedStoreAccountIds
            );
        } else {
            exceptionMessage = moveStoresToNewParentWorkOrder(
                parentWorkOrderId,
                selectedStoreAccountIds,
                workOrderPDOA
            );
        }
        return exceptionMessage;
    }

    private String updateChildWorkOrderStatus(
        Id parentWorkOrderId,
        Set<Id> selectedStoreAccountIds
    ) {
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        String returnMessage = null;

        List<WorkOrder> childWorkOrders = WorkOrdersSelector.newInstance()
            .selectChildWorkOrdersByStoreAccountIds(
                new Set<Id>{ parentWorkOrderId },
                selectedStoreAccountIds
            );
        Set<Id> workOrderIds = new Set<Id>();
        for (WorkOrder childWorkOrder : childWorkOrders) {
            workOrderIds.add(childWorkOrder.Id);
            childWorkOrder.Provisioning_Status__c = PROVISIONING_STATUS_NOT_STARTED;
            childWorkOrder.Status = DEAD_STATUS;
            uow.registerDirty(childWorkOrder);
        }
        cleanUpAssociatedChildRecords(workOrderIds, uow);
        try {
            uow.commitWork();
        } catch (Exception workOrdersUpdatexception) {
            Logger.publish(
                LogEntry.newExceptionLog(workOrdersUpdatexception, LogEntry.SeverityLevel.HIGH)
            );
            returnMessage = workOrdersUpdatexception.getMessage();
        }
        return returnMessage;
    }

    private String moveStoresToNewParentWorkOrder(
        Id parentWorkOrderId,
        Set<Id> selectedStoreAccountIds,
        Date workOrderPDOA
    ) {
        List<WorkOrder> parentWorkOrders = WorkOrdersSelector.newInstance()
            .selectById(new Set<Id>{ parentWorkOrderId });
        List<WorkOrder> childWorkOrders = WorkOrdersSelector.newInstance()
            .selectChildWorkOrdersByStoreAccountIds(
                new Set<Id>{ parentWorkOrderId },
                selectedStoreAccountIds
            );
        Set<Id> childWorkOrderIds = new Set<Id>();
        String returnMessage = null;

        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();

        cloneWorkOrder(parentWorkOrders[0], workOrderPDOA);
        Map<Id, Id> workPlansMap = cloneWorkPlans(parentWorkOrderId, newParentWorkOrderList[0].Id);
        Map<Id, Id> workStepsMap = cloneWorkSteps(
            workPlansMap,
            parentWorkOrderId,
            newParentWorkOrderList[0].Id
        );
        cloneWorkStepDependencies(workStepsMap, parentWorkOrderId);

        for (WorkOrder eachChildWorkOrder : childWorkOrders) {
            childWorkOrderIds.add(eachChildWorkOrder.Id);
            eachChildWorkOrder.ParentWorkOrderId = newParentWorkOrderList[0].Id;
            eachChildWorkOrder.Proposed_Date_of_Activation__c = workOrderPDOA;
            eachChildWorkOrder.PDOA_Delay_Reason__c = PDOA_DELAY_REASON_OTHER;
            eachChildWorkOrder.PDOA_Delay_Details__c = PDOA_DELAY_DETAILS_REMOVE_STORES;
            eachChildWorkOrder.Status = newParentWorkOrderList[0].Status;
            eachChildWorkOrder.Is_Updated_By_System__c = true;
            uow.registerDirty(eachChildWorkOrder);
        }
        updatePDOAOnStores(selectedStoreAccountIds, uow, workOrderPDOA);

        //update child workplans
        List<WorkPlan> childWorkPlans = WorkPlansSelector.newInstance()
            .selectWorkPlansByWorkOrderIds(childWorkOrderIds);
        for (WorkPlan childWorkPlan : childWorkPlans) {
            childWorkPlan.Parent_Work_Plan__c = workPlansMap.get(childWorkPlan.Parent_Work_Plan__c);
            childWorkPlan.Xref__c = null;
            uow.registerDirty(childWorkPlan);
        }
        //update child worksteps
        List<WorkStep> childWorkSteps = WorkStepsSelector.newInstance()
            .selectWorkStepsAllFieldsByWorkOrderIds(childWorkOrderIds);
        for (WorkStep childWorkStep : childWorkSteps) {
            childWorkStep.Parent_Work_Step__c = workStepsMap.get(childWorkStep.Parent_Work_Step__c);
            uow.registerDirty(childWorkStep);
        }
        try {
            uow.commitWork();
        } catch (Exception workOrdersUpdatexception) {
            Logger.publish(
                LogEntry.newExceptionLog(workOrdersUpdatexception, LogEntry.SeverityLevel.HIGH)
            );
            returnMessage = workOrdersUpdatexception.getMessage();
        }
        setOriginalParentWorkOrderStatus(parentWorkOrders[0]);
        if (!newParentWorkOrderList.isEmpty()) {
            // Trigger Work Steps status calculation using child Work Order Ids when Work Plans/Steps exist.
            WorkStepsService.runWorkStepStatusCalculationsOnParentRecords(childWorkOrderIds);
        }
        return returnMessage;
    }

    /**
     * @description It deletes all the associated work plans, work steps and work step
     * dependencies from the passed work orders.
     * @param workOrderIds
     * @param uow
     */
    private void cleanUpAssociatedChildRecords(Set<Id> workOrderIds, fflib_ISObjectUnitOfWork uow) {
        List<WorkPlan> childWorkPlans = WorkPlansSelector.newInstance()
            .selectWorkPlansByWorkOrderIds(workOrderIds);
        List<Workstep> childWorkSteps = WorkStepsSelector.newInstance()
            .selectWorkStepsByWorkOrderIds(workOrderIds);
        List<WorkStepDependency__c> workStepDependencies = WorkStepDependenciesSelector.newInstance()
            .selectDependenciesByWorkOrderIds(workOrderIds);
        uow.registerDeleted(childWorkPlans);
        uow.registerDeleted(childWorkSteps);
        uow.registerDeleted(workStepDependencies);
    }

    private void cloneWorkOrder(WorkOrder workOrder, Date workOrderPDOA) {
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        WorkOrder newParentWorkOrder = workOrder.clone(false, false, false, false);
        newParentWorkOrder.Originating_Work_Order__c = workOrder.Id;
        newParentWorkOrder.Proposed_Date_of_Activation__c = workOrderPDOA;
        //It is required to recalculate formulas on the cloned Work Order to get the correct status.
        Formula.recalculateFormulas(new List<WorkOrder>{ newParentWorkOrder });
        newParentWorkOrder.Status = getWorkOrderStatusByPDOA(newParentWorkOrder);
        newParentWorkOrderList.add(newParentWorkOrder);
        uow.registerNew(newParentWorkOrder);
        uow.commitWork();
    }

    private Map<Id, Id> cloneWorkPlans(Id parentWorkOrderId, Id newParentWorkOrderId) {
        List<WorkPlan> parentWorkPlans = WorkPlansSelector.newInstance()
            .selectWorkPlansByWorkOrderIds(new Set<Id>{ parentWorkOrderId });
        List<WorkPlan> newWorkPlans = new List<WorkPlan>();
        Map<Id, Id> workPlansIdMap = new Map<Id, Id>();
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        for (WorkPlan parentWorkPlan : parentWorkPlans) {
            WorkPlan newParentWorkPlan = parentWorkPlan.clone(false, false, false, false);
            newParentWorkPlan.WorkOrderId = newParentWorkOrderId;
            newWorkPlans.add(newParentWorkPlan);
            uow.registerNew(newParentWorkPlan);
        }

        if (!newWorkPlans.isEmpty()) {
            uow.commitWork();

            for (Integer index = 0; index < parentWorkPlans.size(); index++) {
                workPlansIdMap.put(parentWorkPlans[index].Id, newWorkPlans[index].Id);
            }
        }
        return workPlansIdMap;
    }

    private Map<Id, Id> cloneWorkSteps(
        Map<Id, Id> workPlansMap,
        Id parentWorkOrderId,
        Id newParentWorkOrderId
    ) {
        List<WorkStep> parentWorkSteps = WorkStepsSelector.newInstance()
            .selectWorkStepsAllFieldsByWorkOrderIds(new Set<Id>{ parentWorkOrderId });
        List<WorkStep> newWorkSteps = new List<WorkStep>();
        Map<Id, Id> workStepsIdMap = new Map<Id, Id>();
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        for (WorkStep parentWorkStep : parentWorkSteps) {
            WorkStep newParentWorkStep = parentWorkStep.clone(false, false, false, false);
            newParentWorkStep.WorkPlanId = workPlansMap.get(parentWorkStep.WorkPlanId);
            newParentWorkStep.ExecutionOrder = parentWorkStep.ExecutionOrder;
            newWorkSteps.add(newParentWorkStep);
            uow.registerNew(newParentWorkStep);
        }

        if (!newWorkSteps.isEmpty()) {
            uow.commitWork();

            for (Integer index = 0; index < parentWorkSteps.size(); index++) {
                workStepsIdMap.put(parentWorkSteps[index].Id, newWorkSteps[index].Id);
            }
        }
        return workStepsIdMap;
    }

    private void cloneWorkStepDependencies(Map<Id, Id> workStepsMap, Id parentWorkOrderId) {
        List<WorkStepDependency__c> workStepDependencies = WorkStepDependenciesSelector.newInstance()
            .selectDependenciesByWorkOrderIds(new Set<Id>{ parentWorkOrderId });
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        for (WorkStepDependency__c workStepDependency : workStepDependencies) {
            WorkStepDependency__c newWorkStepDependency = workStepDependency.clone(
                false,
                false,
                false,
                false
            );
            newWorkStepDependency.Dependee_Work_Step__c = workStepsMap.get(
                workStepDependency.Dependee_Work_Step__c
            );
            newWorkStepDependency.Dependent_Work_Step__c = workStepsMap.get(
                workStepDependency.Dependent_Work_Step__c
            );
            uow.registerNew(newWorkStepDependency);
        }

        if (!workStepDependencies.isEmpty()) {
            uow.commitWork();
        }
    }

    /**
     * @description It is used to get Work Order status value by Proposed Date of Activation
     * for the passed Work Order instance.
     * @param workOrderInstance
     * @return String
     */
    private String getWorkOrderStatusByPDOA(WorkOrder workOrderInstance) {
        String workOrderStatus = '';
        workOrderStatus = WorkOrdersService.getWorkStatusUpdatedValue(workOrderInstance);
        if (String.isEmpty(workOrderStatus)) {
            workOrderStatus = WORK_ORDER_STATUS_PLANNING;
        }
        return workOrderStatus;
    }

    /**
     * @description It is used to re-calculate the work order/plans/steps status on the original
     * parent work order. It also cleans up the associated child records when there are no stores
     * left on the original parent work order.
     * @param originalParentWorkOrder
     */
    private void setOriginalParentWorkOrderStatus(WorkOrder originalParentWorkOrder) {
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        if (originalParentWorkOrder == null) {
            return;
        }
        //LEM-10804: Added logic to re-calculate work steps on the original parent work order.
        List<WorkOrder> childWorkOrdersOnOriginalParentWorkOrder = WorkOrdersSelector.newInstance()
            .selectByParentWorkOrderIds(new Set<Id>{ originalParentWorkOrder.Id });
        if (
            childWorkOrdersOnOriginalParentWorkOrder != null &&
            !childWorkOrdersOnOriginalParentWorkOrder.isEmpty()
        ) {
            WorkStepsService.runWorkStepStatusCalculationsOnParentRecords(
                new Set<Id>{ childWorkOrdersOnOriginalParentWorkOrder[0].Id }
            );
        } else {
            uow.registerDirty(
                new WorkOrder(
                    Id = originalParentWorkOrder.Id,
                    Provisioning_Status__c = PROVISIONING_STATUS_NOT_STARTED,
                    Status = getWorkOrderStatusByPDOA(originalParentWorkOrder)
                )
            );
            cleanUpAssociatedChildRecords(new Set<Id>{ originalParentWorkOrder.Id }, uow);
            uow.commitWork();
        }
    }

    /**
     * @description It updates the ‘Proposed Date Of Activation’ on the passed store Accounts
     * based on the passed PDOA date.
     * @JIRA# LEM-11193
     * @param selectedStoreAccountIds
     * @param uowToUpdate
     * @param workOrderPDOA
     */
    private void updatePDOAOnStores(
        Set<Id> selectedStoreAccountIds,
        fflib_ISObjectUnitOfWork uowToUpdate,
        Date workOrderPDOA
    ) {
        for (
            Account eachStoreAccount : AccountsSelector.newInstance()
                .selectById(selectedStoreAccountIds)
        ) {
            if (eachStoreAccount.Disallow_PDOA_Override__c != DISALLOW_PDOX_OVERRIDE_YES) {
                uowToUpdate.registerDirty(
                    new Account(
                        Id = eachStoreAccount.Id,
                        Proposed_Date_of_Activation__c = workOrderPDOA
                    )
                );
            }
        }
    }
}