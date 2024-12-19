/**
 * @author Deloitte
 * @date 05/31/2023
 * @description Service implementation class for Work Objects related logic.
 */
public inherited sharing class WorkObjectsSyncServiceImpl implements IWorkObjectsSyncService {
    private static final String ACCOUNT_RELATION = 'Account';
    private static final String ALLOW_PDOA_PDOT_WITH_NO = 'No';
    private static final String EVENT_TOPIC_WORK_OBJECTS_SYNC = 'WORK_OBJECTS_SYNC';
    private static final String FIELD_ACCOUNTID = 'AccountId';
    private static final String FIELD_DISALLOW_PDOA = 'Disallow_PDOA_Override__c';
    private static final String FIELD_DISALLOW_PDOT = 'User_Sets_PDOT_Value__c';
    private static final String FIELD_PDOA = 'Proposed_Date_of_Activation__c';
    private static final String FIELD_PDOI = 'Proposed_Date_of_Implementation__c';
    private static final String FIELD_PDOT = 'Proposed_Date_of_Tablet__c';
    private static final String PARENTWORKORDER_RELATION = 'ParentWorkOrder';
    private static final String PARENTWORKPLAN_RELATION = 'Parent_Work_Plan__r';
    private static final String LOG_SERVICE_WORK_ORDER = 'WorkOrder Service';
    private static final String LOG_DOMAIN_PROVISIONING = 'Provisioning';
    private static final String WORK_ORDER_FIELD_TYPE = 'Type__c';
    private static final String WORK_ORDER_TYPE_COO = 'COO';
    private static final String WORK_ORDER_TYPE_MARKETPLACE = 'Marketplace';
    private static final String WORK_ORDER_TYPE_STOREFRONT = 'Storefront';
    private List<SObject> listSObjectToUpdate;
    private static final Map<SObjectType, List<Schema.FieldSetMember>> FIELD_SET_MAP = new Map<SObjectType, List<Schema.FieldSetMember>>{
        Account.getSObjectType() => (SObjectType.Account.FieldSets.Child_WorkOrder_to_Store_Account_Sync)
            .getFields(),
        WorkOrder.getSObjectType() => (SObjectType.WorkOrder.FieldSets.Parent_Fields_To_Sync_On_Childs)
            .getFields(),
        WorkPlan.getSObjectType() => (SObjectType.WorkPlan.FieldSets.Parent_Fields_To_Sync_On_Childs)
            .getFields()
    };
    private static final Map<String, Schema.SObjectField> WORK_ORDER_FIELDSET_MAP = Schema.SObjectType.WorkOrder.fields.getMap();
    private static final Set<String> WORK_ORDER_TYPE_ELIGIBLE_FOR_AUTO_SYNC = new Set<String>{
        WORK_ORDER_TYPE_MARKETPLACE,
        WORK_ORDER_TYPE_COO
    };
    private static final Map<String, List<Schema.FieldSetMember>> WORK_ORDER_TYPE_TO_FIELDSET = new Map<String, List<Schema.FieldSetMember>>{
        WORK_ORDER_TYPE_MARKETPLACE => (SObjectType.Account.FieldSets.Child_WorkOrder_to_Store_Account_Sync)
            .getFields(),
        WORK_ORDER_TYPE_COO => (SObjectType.Account.FieldSets.Child_WorkOrder_to_Store_Account_Sync)
            .getFields(),
        WORK_ORDER_TYPE_STOREFRONT => (SObjectType.Account.FieldSets.SF_Child_WorkOrder_to_Store_Account)
            .getFields()
    };

    /**
     * @description Default Constructor to initialize class variables.
     */
    public WorkObjectsSyncServiceImpl() {
        this.listSObjectToUpdate = new List<SObject>();
    }

    /**
     * @description A common method to commit unit of work.
     * @JIRA# LEM-6198
     * @param unitOfWork
     */
    private void commitWork(fflib_ISObjectUnitOfWork unitOfWork) {
        try {
            unitOfWork.commitWork();
        } catch (Exception unitOfWorkException) {
            Logger.publish(
                LogEntry.newExceptionLog(unitOfWorkException, LogEntry.SeverityLevel.HIGH)
            );
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_SERVICE_WORK_ORDER,
                        LOG_DOMAIN_PROVISIONING,
                        GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logException(unitOfWorkException)
            );
        }
    }

    /**
     * @description It is being called through NotifierEvent class for getting child Work Order
     * or child work plans Ids from the payload received via Platform Event.
     * @JIRA# LEM-6198
     * @param events
     */
    public void handleNotifierEvents(List<Notifier__e> events) {
        fflib_ISObjectUnitOfWork unitOfWorkInstance = Application.UNITOFWORK.newInstance();
        Set<Id> childWorkOrderIds = new Set<Id>();
        Set<Id> childWorkPlanIds = new Set<Id>();
        Set<Id> recordIdsFromPayload = new Set<Id>();
        for (Notifier__e eachEvent : events) {
            recordIdsFromPayload = (Set<Id>) JSON.deserialize(eachEvent.Payload__c, Set<Id>.class);
            if (recordIdsFromPayload == null) {
                continue;
            }
            String objectName = new List<Id>(recordIdsFromPayload)
                .get(0)
                .getSObjectType()
                .getDescribe()
                .getName();
            if (eachEvent.Topic__c == EVENT_TOPIC_WORK_OBJECTS_SYNC) {
                switch on objectName {
                    when 'WorkOrder' {
                        childWorkOrderIds.addAll(recordIdsFromPayload);
                    }
                    when 'WorkPlan' {
                        childWorkPlanIds.addAll(recordIdsFromPayload);
                    }
                }
            }
        }
        syncParentInformationOnWorkOrder(childWorkOrderIds);
        syncParentInformationOnWorkPlan(childWorkPlanIds);
        unitOfWorkInstance.registerDirty(listSObjectToUpdate);
        commitWork(unitOfWorkInstance);
    }

    /**
     * @description To check whether the field 'Proposed Date Of Activation' on store account
     * is eligible to be updated.
     * @JIRA# 6198
     * @param childWorkOrder
     * @return Boolean
     */
    private Boolean isPDOAAllowed(SObject childWorkOrder) {
        return (String) childWorkOrder.getSObject(ACCOUNT_RELATION).get(FIELD_DISALLOW_PDOA) ==
            ALLOW_PDOA_PDOT_WITH_NO;
    }

    /**
     * @description To check whether the field 'Proposed Date Of Tablet' on store account
     * is eligible to be updated.
     * @JIRA# 6198
     * @param childWorkOrder
     * @return Boolean
     */
    private Boolean isPDOTAllowed(SObject childWorkOrder) {
        return (String) childWorkOrder.getSObject(ACCOUNT_RELATION).get(FIELD_DISALLOW_PDOT) ==
            ALLOW_PDOA_PDOT_WITH_NO;
    }

    /**
     * @description To check whether the field on store account is eligible to be updated.
     * @JIRA# 6198
     * @param childWorkOrder
     * @param fieldName
     * @return Boolean
     */
    private Boolean isValidationPass(SObject childWorkOrder, String fieldName) {
        return (fieldName == FIELD_PDOA && isPDOAAllowed(childWorkOrder)) ||
            (fieldName == FIELD_PDOT && isPDOTAllowed(childWorkOrder)) ||
            (fieldName == FIELD_PDOI);
    }

    /**
     * @description Update child work order fields from parent work order
     * @JIRA# 6198
     * @param childWorkOrder
     */
    private void updateChildWorkOrderRecords(SObject childWorkOrder) {
        WorkOrder childWorkOrderToUpdate = new WorkOrder();
        String workOrderType = String.valueOf(childWorkOrder.get(WORK_ORDER_FIELD_TYPE));
        childWorkOrderToUpdate.Id = childWorkOrder.Id;
        childWorkOrderToUpdate.Is_Updated_By_System__c = true;
        for (
            Schema.FieldSetMember fieldSetMember : FIELD_SET_MAP.get(
                childWorkOrderToUpdate.getSObjectType()
            )
        ) {
            String fieldName = String.valueOf(fieldSetMember.getSObjectField());
            //LEM-24967 - To skip the Sync logic for all WO types except Marketplace & COO.
            if (
                WORK_ORDER_FIELDSET_MAP.get(fieldName) == null ||
                !WORK_ORDER_TYPE_ELIGIBLE_FOR_AUTO_SYNC.contains(workOrderType)
            ) {
                continue;
            }
            switch on String.valueOf(fieldSetMember.getType()) {
                when 'DATE' {
                    childWorkOrderToUpdate.put(
                        fieldName,
                        (Date) childWorkOrder.getSObject(PARENTWORKORDER_RELATION).get(fieldName)
                    );
                }
                when else {
                    childWorkOrderToUpdate.put(
                        fieldName,
                        (String) childWorkOrder.getSObject(PARENTWORKORDER_RELATION).get(fieldName)
                    );
                }
            }
        }
        listSObjectToUpdate.add(childWorkOrderToUpdate);
    }

    /**
     * @description Update child work plan fields from parent work plan
     * @JIRA# 6198
     * @param childWorkPlan
     */
    private void updateChildWorkPlanRecords(SObject childWorkPlan) {
        WorkPlan childWorkPlanToUpdate = new WorkPlan();
        childWorkPlanToUpdate.Id = childWorkPlan.Id;
        for (
            Schema.FieldSetMember fieldSetMember : FIELD_SET_MAP.get(
                childWorkPlanToUpdate.getSObjectType()
            )
        ) {
            String fieldName = String.valueOf(fieldSetMember.getSObjectField());
            switch on String.valueOf(fieldSetMember.getType()) {
                when 'DATE' {
                    childWorkPlanToUpdate.put(
                        fieldName,
                        (Date) childWorkPlan.getSObject(PARENTWORKPLAN_RELATION).get(fieldName)
                    );
                }
                when else {
                    childWorkPlanToUpdate.put(
                        fieldName,
                        (String) childWorkPlan.getSObject(PARENTWORKPLAN_RELATION).get(fieldName)
                    );
                }
            }
        }
        listSObjectToUpdate.add(childWorkPlanToUpdate);
    }

    /**
     * @description Update store account fields from Parent Work Order and the fields 'PDOA'
     * and 'PDOT' depending on 'Disallow PDOA Override' and 'Disallow PDOT Override'
     * respectively.
     * @JIRA# 6198
     * @param childWorkOrder
     */
    private void updateStoreAccountInformation(SObject childWorkOrder) {
        Account updateStoreAccount = new Account(Id = (String) childWorkOrder.get(FIELD_ACCOUNTID));
        String workOrderType = String.valueOf(childWorkOrder.get(WORK_ORDER_FIELD_TYPE));
        if (!WORK_ORDER_TYPE_TO_FIELDSET.containsKey(workOrderType)) {
            return;
        }
        for (
            Schema.FieldSetMember fieldSetMember : WORK_ORDER_TYPE_TO_FIELDSET.get(workOrderType)
        ) {
            String fieldName = String.valueOf(fieldSetMember.getSObjectField());
            switch on String.valueOf(fieldSetMember.getType()) {
                when 'DATE' {
                    if (isValidationPass(childWorkOrder, fieldName)) {
                        updateStoreAccount.put(
                            fieldName,
                            (Date) childWorkOrder.getSObject(PARENTWORKORDER_RELATION)
                                .get(fieldName)
                        );
                    }
                }
                when else {
                    updateStoreAccount.put(
                        fieldName,
                        (String) childWorkOrder.getSObject(PARENTWORKORDER_RELATION).get(fieldName)
                    );
                }
            }
        }
        listSObjectToUpdate.add(updateStoreAccount);
    }

    /**
     * @description Update child work order and store account selected fields from parent work
     * order.
     * @JIRA# 6198
     * @param childWorkOrderIds
     */
    private void syncParentInformationOnWorkOrder(Set<Id> childWorkOrderIds) {
        if (childWorkOrderIds.isEmpty()) {
            return;
        }
        for (
            SObject eachWorkOrder : ((IWorkObjectsSyncSelector) Application.SELECTOR.newInstance(
                    WorkOrder.SObjectType
                ))
                .selectParentDetailsByChildIds(childWorkOrderIds)
        ) {
            updateChildWorkOrderRecords(eachWorkOrder);
            updateStoreAccountInformation(eachWorkOrder);
        }
    }

    /**
     * @description Update child work plan selected fields from parent work plan on
     * update of fields
     * @JIRA# 6198
     * @param childWorkPlanIds
     */
    private void syncParentInformationOnWorkPlan(Set<Id> childWorkPlanIds) {
        if (childWorkPlanIds.isEmpty()) {
            return;
        }
        for (
            SObject eachWorkPlan : ((IWorkObjectsSyncSelector) Application.SELECTOR.newInstance(
                    WorkPlan.SObjectType
                ))
                .selectParentDetailsByChildIds(childWorkPlanIds)
        ) {
            updateChildWorkPlanRecords(eachWorkPlan);
        }
    }
}