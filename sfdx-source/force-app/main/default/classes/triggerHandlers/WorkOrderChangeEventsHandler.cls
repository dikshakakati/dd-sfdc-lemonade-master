/**
 * @author Deloitte
 * @date 07/18/2022
 * @description WorkOrderChangeEvents trigger handler.
 * Note: Batch size is defaulted to 200 using PlatformEventSubscriberConfig.
 */
public class WorkOrderChangeEventsHandler extends ApplicationDomainHandler {
    private static final String ASSOCIATED_ACCOUNT_IDS = 'Associated_Account_Ids__c';
    private static final String CHANGE_TYPE_CREATE = 'CREATE';
    private static final String CHANGE_TYPE_UPDATE = 'UPDATE';
    private static final String PARENT_WORK_ORDER_ID_FIELD = 'ParentWorkOrderId';
    private static final String PROVISIONING_STATUS_FIELD = 'Provisioning_Status__c';
    private static final String READINESS_CHECK_TRIGGER_SOURCE_CHANGE_EVENT = 'Change_Event';
    private enum CHANGEDFIELDS {
        ASSOCIATEDACCOUNTIDS,
        PARENTWORKORDERID,
        PROVISIONINGSTATUS
    }
    private static final Map<String, CHANGEDFIELDS> CHANGED_FIELD_MAPPINGS = new Map<String, CHANGEDFIELDS>{
        ASSOCIATED_ACCOUNT_IDS => CHANGEDFIELDS.ASSOCIATEDACCOUNTIDS,
        PARENT_WORK_ORDER_ID_FIELD => CHANGEDFIELDS.PARENTWORKORDERID,
        PROVISIONING_STATUS_FIELD => CHANGEDFIELDS.PROVISIONINGSTATUS
    };

    /**
     * @description Parameterized constructor for instantiation.
     * @param sObjects - WorkOrderChangeEvent records
     */
    public WorkOrderChangeEventsHandler(List<WorkOrderChangeEvent> sObjects) {
        super(sObjects);
        setContextBypass(WorkOrderChangeEvent.SobjectType, WorkOrderChangeEventsHandler.class);
    }

    /**
     * @description Called to perform processing during the after insert phase.
     */
    public override void onAfterInsert() {
        Set<Id> childWorkOrderIdsToRunReadinessCheck = new Set<Id>();
        Set<Id> collectedRecordIds = new Set<Id>();
        Set<Id> workOrderIdsOnCreate = new Set<Id>();
        Set<Id> workOrderIdsOnUpdate = new Set<Id>();
        for (
            WorkOrderChangeEvent eachWorkOrderChangeEvent : (List<WorkOrderChangeEvent>) this.records
        ) {
            EventBus.ChangeEventHeader header = eachWorkOrderChangeEvent.ChangeEventHeader;
            if (header.changeType == CHANGE_TYPE_CREATE) {
                workOrderIdsOnCreate.addAll(
                    (Set<Id>) JSON.deserialize(JSON.serialize(header.recordIds), Set<Id>.class)
                );
            }
            if (header.changeType == CHANGE_TYPE_UPDATE) {
                for (String eachChangedField : header.changedFields) {
                    collectedRecordIds = (Set<Id>) JSON.deserialize(
                        JSON.serialize(header.recordIds),
                        Set<Id>.class
                    );
                    switch on CHANGED_FIELD_MAPPINGS.get(eachChangedField) {
                        when ASSOCIATEDACCOUNTIDS, PROVISIONINGSTATUS {
                            workOrderIdsOnUpdate.addAll(collectedRecordIds);
                        }
                        when PARENTWORKORDERID {
                            childWorkOrderIdsToRunReadinessCheck.addAll(collectedRecordIds);
                        }
                    }
                }
            }
        }
        WorkOrdersService.initiateStoreAssociation(
            WorkOrdersSelector.newInstance().selectById(workOrderIdsOnCreate)
        );
        WorkOrdersService.initiateChildWorkOrderAutoCreation(workOrderIdsOnCreate);
        WorkOrdersService.initiateChildWorkOrderAutoCreation(workOrderIdsOnUpdate);
        WorkOrdersService.runReadinessCheckOnChildWorkOrders(childWorkOrderIdsToRunReadinessCheck);
        WorkOrdersService.runReadinessCheckOnChildWorkOrders(workOrderIdsOnCreate);
        WorkOrdersService.initiateWorkPlansCreation(workOrderIdsOnCreate, CHANGE_TYPE_CREATE);
        WorkOrdersService.initiateWorkPlansCreation(workOrderIdsOnUpdate, CHANGE_TYPE_UPDATE);
    }

    /**
     * @description Constructor class implements fflib_SObjectDomain.IConstructable interface.
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description This method implements construct method of fflib_SObjectDomain.IConstructable
         * @param sObjects - list of SObjects
         * @return WorkOrderChangeEventsHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjects) {
            return new WorkOrderChangeEventsHandler(sObjects);
        }
    }
}