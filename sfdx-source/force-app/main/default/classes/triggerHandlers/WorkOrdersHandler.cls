/**
 * @author Deloitte
 * @date 03/30/2022
 * @description Work Order Trigger handler class
 */
public class WorkOrdersHandler extends ApplicationDomainHandler {
    private static final String EVENT_TOPIC_WORK_ORDER_STORES_CALCULATION = 'WORK_ORDER_STORES_CALCULATION';
    private static final String EVENT_TOPIC_WORK_ORDER_PROVISIONING_STATUS_UPDATE = 'WORK_ORDER_PROVISIONING_STATUS_UPDATE';
    private static final String PROVISIONING_STATUS_READY_FOR_PROVISIONING = 'Ready for Provisioning';
    private static final String PROVISIONING_STATUS_PROVISIONING_COMPLETE = 'Provisioning Complete';
    private static final String STATUS_DEAD = 'Dead';
    private static final String WORK_ORDER_TYPE_DRIVE = 'Drive';
    private static final String WORK_ORDER_TYPE_MARKETPLACE = 'Marketplace';
    private static final String WORK_ORDER_TYPE_STOREFRONT = 'Storefront';
    private static final String WORK_ORDER_TYPE_POST_SALES = 'Post-Sales';
    private static final String WORK_ORDER_TYPE_COO = 'COO';
    private static final Schema.Fieldset WORK_ORDER_PARENT_TO_CHILD_SYNC_FIELD_SET = SObjectType.WorkOrder.FieldSets.Parent_Fields_To_Sync_On_Childs;
    private static final String BUNDLED_WITH_MARKETPLACE_YES = 'Yes';
    private static Set<WorkOrder> changedStorefrontWorkOrdersReadyForProvisioning;

    /**
     * @description default constructor method
     * @param sObjectList
     */
    public WorkOrdersHandler(List<WorkOrder> sObjectList) {
        super(sObjectList);
        setContextBypass(WorkOrder.SObjectType, WorkOrdersHandler.class);
        changedStorefrontWorkOrdersReadyForProvisioning = new Set<WorkOrder>();
    }

    /**
     * @description constructor Class implements fflib_SObjectDomain class
     */
    public class Constructor implements fflib_SObjectDomain.Iconstructable {
        /**
         * @description this method implements construct class in fflib_SObjectDomain
         * @param sObjectList
         * @return WorkOrdersHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new WorkOrdersHandler(sObjectList);
        }
    }
    /**
     * @description Called to perform processing during the after insert phase.
     */
    public override void onAfterInsert() {
        WorkOrders.newInstance(this.records)
            .collectParentWorkOrderIds(this.records, EVENT_TOPIC_WORK_ORDER_STORES_CALCULATION);
        // enables Storefront Bundled, POS and Tablet Work Plan indicators on parent WorkOrder
        ParentWorkOrderSyncService.enableStoreLevelWorkPlansIndicatorsOnParentWorkOrder(
            this.records
        );
        WorkOrdersService.initiateTabletWorkPlanCreation(this.records);
        new IntegrationCriteriaEvaluator()
        .evaluateInitialCriteriaForEmailIntegration(this.records);
    }

    /**
     * @description Method to update Work Order status on PDOA, PDOT or PDOM update with future date
     * and to update Actual Number of Stores on parent WorkOrder.
     * @JIRA LEM-985, LEM-1011, LEM-1226, LEM-955, LEM-2083
     * @param existingRecords
     */
    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        onAfterUpdateStatusOnPDOAOrPDOTChange(existingRecords);
        runReadinessCheckOnParentWorkOrders(existingRecords);
        List<WorkOrder> changedWorkOrders = new List<WorkOrder>(
            (List<WorkOrder>) getChangedRecords(
                new Set<SObjectField>{ WorkOrder.ParentWorkOrderId, WorkOrder.AccountId }
            )
        );
        WorkOrders.newInstance(changedWorkOrders)
            .collectChildWorkOrdersWithUpdatedParentWorkOrderId(
                (Map<Id, WorkOrder>) existingRecords
            );
        WorkOrders.newInstance(this.records)
            .collectParentWorkOrderIds(
                getWorkOrdersWithStatusChangedToDead(),
                EVENT_TOPIC_WORK_ORDER_STORES_CALCULATION
            );

        WorkOrdersService.generateProvisioningEventForWorkOrders(
            getChangedWorkOrderIdsReadyForProvisioning(
                new Set<String>{
                    WORK_ORDER_TYPE_MARKETPLACE,
                    WORK_ORDER_TYPE_STOREFRONT,
                    WORK_ORDER_TYPE_POST_SALES
                }
            )
        );

        WorkOrdersService.generateProvisioningEventForDriveWorkOrders(
            getChangedWorkOrderIdsReadyForProvisioning(new Set<String>{ WORK_ORDER_TYPE_DRIVE })
        );

        WorkOrdersService.generateProvisioningEventForCOOWorkOrders(
            getChangedWorkOrderIdsReadyForProvisioning(new Set<String>{ WORK_ORDER_TYPE_COO })
        );

        List<WorkOrder> workOrdersWithProvisionStatusUpdate = new List<WorkOrder>(
            (List<WorkOrder>) getChangedRecords(
                new Set<SObjectField>{
                    WorkOrder.Provisioning_Status__c,
                    WorkOrder.Send_Readiness_Check_Email__c
                }
            )
        );
        WorkOrders.newInstance(workOrdersWithProvisionStatusUpdate)
            .collectParentWorkOrderIds(
                workOrdersWithProvisionStatusUpdate,
                EVENT_TOPIC_WORK_ORDER_PROVISIONING_STATUS_UPDATE
            );
        WorkOrdersService.updateChildWorkOrdersStatusToProvisioningComplete(
            getChangedWorkOrderIdsProvisioningComplete(
                new Set<String>{ WORK_ORDER_TYPE_MARKETPLACE }
            )
        );
        WorkOrdersService.updateChildWorkOrderProvisioningStatusForStorefrontBundledWorkOrder(
            changedStorefrontWorkOrdersReadyForProvisioning
        );
        WorkOrders.newInstance(this.records)
            .updateChildWorkStepsStatusToDead(getWorkOrdersWithStatusChangedToDead());

        List<WorkOrder> updatedParentWorkOrders = new List<WorkOrder>(
            (List<WorkOrder>) getChangedRecords(getParentWorkOrderUpdatedFields())
        );
        WorkOrders.newInstance(updatedParentWorkOrders)
            .collectParentWorkOrdersWithUpdatedInformation(updatedParentWorkOrders);
        new IntegrationCriteriaEvaluator()
            .evaluateInitialCriteriaForEmailIntegration(this.records, existingRecords);
    }

    /**
     * @description Called to perform processing during the after delete phase.
     */
    public override void onAfterDelete() {
        WorkOrders.newInstance(this.records)
            .collectParentWorkOrderIds(this.records, EVENT_TOPIC_WORK_ORDER_STORES_CALCULATION);
    }

    /**
     * @description Called to perform processing during the after undelete phase.
     */
    public override void onAfterUndelete() {
        WorkOrders.newInstance(this.records)
            .collectParentWorkOrderIds(this.records, EVENT_TOPIC_WORK_ORDER_STORES_CALCULATION);
    }

    /**
     * @description Called to perform processing during the before insert phase.
     */
    public override void onBeforeInsert() {
        IWorkOrders workOrdersInstance = WorkOrders.newInstance(this.records);
        workOrdersInstance.onBeforeInsertValidateAndUpdateWorkOrderFields();
        workOrdersInstance.populateFranchiseRepAsOwnerOnMxpAndDriveWorkOrders();
    }

    /**
     * @description Called to perform processing during the before update phase.
     * @param existingRecords - the map of old Work Orders
     */
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        WorkOrders.newInstance(this.records)
            .onBeforeUpdateValidateAndUpdateWorkOrderFields((Map<Id, WorkOrder>) existingRecords);
    }

    /**
     * @description Method to update Work Order status on PDOA, PDOT or PDOM update with future date
     * @JIRA LEM-985,LEM-1011
     * @param existingRecords
     */
    private void onAfterUpdateStatusOnPDOAOrPDOTChange(Map<Id, SObject> existingRecords) {
        WorkOrders.newInstance(this.records).updateStatusOnPDOAOrPDOTChange(existingRecords);
    }

    /**
     * @description gets work orders with provisioning status changed and equal to ready for
     * provisioning, and the Work Order Type__c has to be equal to a string in the passed in Set.
     * @param workOrderTypeSet
     * @return set of ids
     */
    @SuppressWarnings('PMD.AvoidDeeplyNestedIfStmts')
    private Set<Id> getChangedWorkOrderIdsReadyForProvisioning(Set<String> workOrderTypeSet) {
        Set<Id> changedWorkOrderIdsReadyForProvisioning = new Set<Id>();
        for (
            WorkOrder eachWorkOrder : (List<WorkOrder>) getChangedRecords(
                new Set<SObjectField>{ WorkOrder.Provisioning_Status__c }
            )
        ) {
            if (
                (eachWorkOrder.Provisioning_Status__c ==
                PROVISIONING_STATUS_READY_FOR_PROVISIONING) &&
                (workOrderTypeSet.contains(eachWorkOrder.Type__c))
            ) {
                //If Storefront work order is bundled with Marketplace, then do not fire a platform event
                //@JIRA# LEM-19828
                if (
                    eachWorkOrder.Type__c == WORK_ORDER_TYPE_STOREFRONT &&
                    eachWorkOrder.Bundled_with_Marketplace__c == BUNDLED_WITH_MARKETPLACE_YES
                ) {
                    if (eachWorkOrder.parentWorkOrderId == null) {
                        changedStorefrontWorkOrdersReadyForProvisioning.add(eachWorkOrder);
                    }
                    continue;
                }
                // bypassing child Work Orders of Drive type for Provisioning Events
                else if (
                    eachWorkOrder.Type__c == WORK_ORDER_TYPE_DRIVE &&
                    eachWorkOrder.ParentWorkOrderId != null
                ) {
                    continue;
                }
                changedWorkOrderIdsReadyForProvisioning.add(eachWorkOrder.Id);
            }
        }

        return changedWorkOrderIdsReadyForProvisioning;
    }
    /**
     * @description gets work orders with provisioning status changed and equal to provisioning
     * complete LEM-3170
     * @param workOrderTypeSet
     * @return set of ids
     */
    private Set<Id> getChangedWorkOrderIdsProvisioningComplete(Set<String> workOrderTypeSet) {
        Set<Id> changedWorkOrderIdsProvisioningComplete = new Set<Id>();
        for (
            WorkOrder eachWorkOrder : (List<WorkOrder>) getChangedRecords(
                new Set<SObjectField>{ WorkOrder.Provisioning_Status__c }
            )
        ) {
            if (
                (eachWorkOrder.Provisioning_Status__c ==
                PROVISIONING_STATUS_PROVISIONING_COMPLETE) &&
                (workOrderTypeSet.contains(eachWorkOrder.Type__c))
            ) {
                changedWorkOrderIdsProvisioningComplete.add(eachWorkOrder.Id);
            }
        }
        return changedWorkOrderIdsProvisioningComplete;
    }

    /**
     * @description Fetch SObjectField having updated values from workorder records
     * @return Set<SObjectField>
     */
    private Set<SObjectField> getParentWorkOrderUpdatedFields() {
        Map<String, Schema.SObjectField> workOrderSobjectFields = WorkOrder.SObjectType.getDescribe()
            .fields.getMap();
        Set<SObjectField> workOrderFields = new Set<SObjectField>();
        Schema.FieldSet fieldSetObj = SObjectType.WorkOrder.FieldSets.Parent_Fields_To_Sync_On_Childs;
        List<Schema.FieldSetMember> fieldSetMembers = fieldSetObj.getFields();
        for (Schema.FieldSetMember fieldSetMember : fieldSetMembers) {
            String fieldName = String.valueOf(fieldSetMember.getSObjectField());
            if (workOrderSobjectFields.get(fieldName) != null) {
                workOrderFields.add(workOrderSobjectFields.get(fieldName));
            }
        }
        return workOrderFields;
    }

    /**
     * @description It collects Work Order records where Status is changed to 'Dead'.
     * @JIRA# LEM-5837
     * @return List<WorkOrder>
     */
    private List<WorkOrder> getWorkOrdersWithStatusChangedToDead() {
        List<WorkOrder> deadWorkOrders = new List<WorkOrder>();
        for (
            WorkOrder eachWorkOrder : (List<WorkOrder>) getChangedRecords(
                new Set<SObjectField>{ WorkOrder.Status }
            )
        ) {
            if (eachWorkOrder.Status == STATUS_DEAD) {
                deadWorkOrders.add(eachWorkOrder);
            }
        }
        return deadWorkOrders;
    }

    /**
     * @description It is used to trigger Readiness Check on parent Work Orders.
     * @JIRA LEM-19805
     * @param existingRecords
     */
    private void runReadinessCheckOnParentWorkOrders(Map<Id, SObject> existingRecords) {
        WorkOrders.newInstance(this.records).runReadinessCheckOnParentWorkOrders(existingRecords);
    }
}