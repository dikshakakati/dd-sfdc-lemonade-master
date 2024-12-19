/**
 * @author Deloitte
 * @date 08/04/2022
 * @description Domain Class for WorkPlan object.
 */
public inherited sharing class WorkPlans extends fflib_SObjects implements IWorkPlans {
    private static final String CHILD_WORKPLAN_IDS_CHUNK_SIZE_STATIC_CONFIG = 'Child_Work_Plan_Ids_Payload_Chunk_Size';
    private static final String COMMA_SEPARATOR = ',';
    private static final String GENERIC_WORK_ORDER_CREATION = 'WORK_ORDER_GENERATION';
    private static final String EVENT_TOPIC_WORK_OBJECTS_SYNC = 'WORK_OBJECTS_SYNC';
    private static final String NOT_STARTED = 'Not Started';
    private static final String PARENT_WORKPLAN_AGGREGATE_QUERY_COUNT_ALIAS = 'childWorkPlans';
    private static final String PARENT_WORKPLAN_AGGREGATE_QUERY_GROUPBYFIELD_ALIAS = 'parentId';
    private static final String SMB_SEGMENT = 'SMB';
    private static final String PARENT_WORKPLAN_AGGREGATE_QUERY_SUM_ALIAS = 'workableWorkSteps';
    private static final String PARENT_WORKPLAN_AGGREGATE_QUERY_VALIDATION_STATUS_ALIAS = 'validationStatus';
    private static final String TYPE_MARKETING_KIT = 'Marketing Kit';
    private static final String VALIDATION_STATUS_COMPLETED = 'Completed';
    private static final String VALIDATION_STATUS_ESCALATED = 'Escalated';
    private static final String VALIDATION_STATUS_IN_PROGRESS = 'In Progress';
    private static final String VALIDATION_STATUS_PENDING = 'Pending';
    private static final String VENDOR_PHOTOSHOOT = 'Vendor Photoshoot';
    private static final String WORK_PLAN_TYPE_ONBOARDING = 'Onboarding';
    private static final String WORK_PLAN_TYPE_STOREFRONT = 'Storefront';
    private static final String WORK_PLAN_COMPLETE = 'Complete';
    private static final String WORK_ORDER_CREATION_SOURCE_PLACE_IT_FOR_ME = 'Place It For Me';
    private static final String WORK_ORDER_TYPE_MARKETPLACE = 'Marketplace';
    private static final String LOG_SERVICE_WORK_PLANS = 'WorkPlans';
    private static final String LOG_DOMAIN_WORK_PLANS_CREATION = 'WorkPlans Records Creation';
    private enum ActivationChecklistValidationStatuses {
        STATUS_COMPLETED,
        STATUS_ESCALATED,
        STATUS_IN_PROGRESS,
        STATUS_PENDING
    }
    private static final Map<String, ActivationChecklistValidationStatuses> VALIDATION_STATUSES = new Map<String, ActivationChecklistValidationStatuses>{
        VALIDATION_STATUS_COMPLETED => ActivationChecklistValidationStatuses.STATUS_COMPLETED,
        VALIDATION_STATUS_ESCALATED => ActivationChecklistValidationStatuses.STATUS_ESCALATED,
        VALIDATION_STATUS_IN_PROGRESS => ActivationChecklistValidationStatuses.STATUS_IN_PROGRESS,
        VALIDATION_STATUS_PENDING => ActivationChecklistValidationStatuses.STATUS_PENDING
    };
    private Set<String> eligibleOrderProtocolForPreSalesMarketingKitWorkOrders;
    private Set<Id> parentWorkPlanIds;
    private List<WorkPlan> workPlansWithWorkPlanTemplateId;
    private Set<Id> workPlanTemplateIds;

    /*
     * @description Holds a mock instance of the constructor inner class.
     * Setting this will provide the ability to test the records being injected into
     * the domain class when it is instantiated.
     */
    private static fflib_IDomainConstructor constructorMock;

    /**
     * @description It is used to return the IWorkSteps interface.
     * @param workPlans - WorkPlans record list
     * @return IWorkPlans - returns IWorkPlans interface
     */
    public static IWorkPlans newInstance(List<WorkPlan> workPlans) {
        return (IWorkPlans) Application.Domain.newInstance(workPlans);
    }

    /**
     * @description Private method that allows the domain constructor mock to be set by test class.
     * @param mock fflib_IDomainConstructor
     */
    @TestVisible
    private static void setConstructorMock(fflib_IDomainConstructor mock) {
        constructorMock = mock;
    }

    /**
     * @description Default constructor for the class
     * @param sObjectList
     */
    public WorkPlans(List<WorkPlan> sObjectList) {
        super(sObjectList, Schema.WorkPlan.SObjectType);
        parentWorkPlanIds = new Set<Id>();
        workPlansWithWorkPlanTemplateId = new List<WorkPlan>();
        workPlanTemplateIds = new Set<Id>();
        eligibleOrderProtocolForPreSalesMarketingKitWorkOrders = new Set<String>(
        System.Label.Order_Protocol_Marketing_Kit_Pre_Sales.split(COMMA_SEPARATOR)
      );
    }

    /**
     * @description It updates WorkPlan related records on After Insert trigger event.
     */
    public void onAfterInsertHandleRelatedRecords() {
        List<WorkPlan> marketingKitWorkPlans = new List<WorkPlan>();
        List<WorkPlan> placeItForMeStorefrontWPs = new List<WorkPlan>();
        List<WorkPlan> vendorPhotoshootWorkPlans = new List<WorkPlan>();
        for (WorkPlan eachWorkPlan : (List<WorkPlan>) getRecords()) {
            //JIRA#: LEM-732
            collectWorkPlansAndWorkPlanTemplateIds(eachWorkPlan);
            //JIRA#: LEM-1964
            if (eachWorkPlan.Number_of_Workable_WorkSteps_Roll_Up__c != 0) {
                collectParentWorkPlanIds(eachWorkPlan);
            }
            //JIRA#: LEM-15585
            if (isPlaceItForMeStorefrontWorkPlan(eachWorkPlan)) {
                placeItForMeStorefrontWPs.add(eachWorkPlan);
            }
            //JIRA#: LEM-19805
            if (isEligibleForPhotoshootMxOrderCreation(eachWorkPlan)) {
                vendorPhotoshootWorkPlans.add(eachWorkPlan);
            }
            if (isEligibleForMarketingKitMxOrderCreation(eachWorkPlan)) {
                marketingKitWorkPlans.add(eachWorkPlan);
            }
        }
        //JIRA#: LEM-588, LEM-4160
        WorkStepsCreationService.createWorkStepsOnWorkPlans(
            workPlansWithWorkPlanTemplateId,
            workPlanTemplateIds
        );
        //JIRA#: LEM-1964
        calculateNumberOfWorkableWorkStepsOnParentWorkPlan();
        //JIRA#: LEM-15585
        PlaceItForMeIntegrationService.updatePlaceItForMeStorefrontWorkPlans(
            placeItForMeStorefrontWPs
        );
        //JIRA#: LEM-13595
        if (!vendorPhotoshootWorkPlans.isEmpty()) {
            initiatePhotoShootMxOrderCreation(vendorPhotoshootWorkPlans);
        }
        if (!marketingKitWorkPlans.isEmpty()) {
            initiateMarketingKitMxOrderCreation(marketingKitWorkPlans);
        }
        populateParentWorkPlanFields();
    }

    /**
     * @description It initiates Photoshoot Work Order Creation.
     * @param workPlanRecords
     */
    private void initiatePhotoShootMxOrderCreation(List<WorkPlan> workPlanRecords) {
        try {
            MxOrderCreationService.generatePhotoShootMxOrder(workPlanRecords);
        } catch (Exception mxOrderCreationException) {
            createLogEntries(mxOrderCreationException, workPlanRecords);
        }
    }

    /**
     * @description It initiates Marketing Kit Work Order Creation.
     * @param workPlanRecords
     */
    private void initiateMarketingKitMxOrderCreation(List<WorkPlan> workPlanRecords) {
        try {
            MxOrderCreationService.generateMarketingKitMxOrders(workPlanRecords);
        } catch (Exception mxOrderCreationException) {
            createLogEntries(mxOrderCreationException, workPlanRecords);
        }
    }

    /**
     * @description It creates Log records.
     * @param mxOrderCreationException
     * @param workPlanRecords
     */
    private void createLogEntries(Exception mxOrderCreationException, List<WorkPlan> workPlanRecords) {
        GenericLoggerService.publish(
            GenericLoggerService.createGenericLog(
                    LOG_SERVICE_WORK_PLANS,
                    LOG_DOMAIN_WORK_PLANS_CREATION,
                    GenericLogEntry.SeverityLevel.HIGH
                )
                .logException(mxOrderCreationException)
                .logSFRecordId(
                    (Set<String>) JSON.deserialize(
                        JSON.serialize((new Map<Id, WorkPlan>(workPlanRecords)).keySet()),
                        Set<String>.class
                    )
                )
        );
    }

    /**
     * @description It update Work Plan related records on After Update trigger event.
     * @param oldWorkPlans
     */
    public void onAfterUpdateHandleRelatedRecords(Map<Id, WorkPlan> oldWorkPlans) {
        WorkPlan oldWorkPlan;
        Set<Id> activationChecklistValidatedWorkPlans = new Set<Id>();
        Set<Id> acValidationInProgressParentWPs = new Set<Id>();
        for (WorkPlan eachWorkPlan : (List<WorkPlan>) getRecords()) {
            oldWorkPlan = oldWorkPlans.get(eachWorkPlan.Id);
            //JIRA#: LEM-1181, LEM-1964
            if (
                hasNumberOfWorkableWorkStepsChanged(eachWorkPlan, oldWorkPlan) ||
                hasParentWorkPlanChanged(eachWorkPlan, oldWorkPlan)
            ) {
                collectParentWorkPlanIds(eachWorkPlan);
                collectParentWorkPlanIds(oldWorkPlan);
            }
            //@JIRA#: LEM-13305
            if (isActivationChecklistValidationStatusChanged(eachWorkPlan, oldWorkPlan)) {
                activationChecklistValidatedWorkPlans.add(eachWorkPlan.Parent_Work_Plan__c);
            }
            //@JIRA#: LEM-13305
            if (
                isActivationChecklistValidationInProgressOnParentWorkPlan(eachWorkPlan, oldWorkPlan)
            ) {
                acValidationInProgressParentWPs.add(eachWorkPlan.Id);
            }
        }
        //JIRA#: LEM-1181
        calculateNumberOfWorkableWorkStepsOnParentWorkPlan();
        //JIRA#: LEM-13305
        calculateNumberOfValidatedStoresOnParentWorkPlan(activationChecklistValidatedWorkPlans);
        //JIRA#: LEM-13305
        if (!acValidationInProgressParentWPs.isEmpty()) {
            WorkPlansService.updateActivationChecklistValidationStatusOnWorkPlans(
                new Map<Id, WorkPlan>(
                        WorkPlansSelector.newInstance()
                            .selectByParentWorkPlanIds(acValidationInProgressParentWPs)
                    )
                    .keySet(),
                VALIDATION_STATUS_IN_PROGRESS
            );
        }
    }

    /**
     * @description It validate and update Work Plan fields on Before Update trigger event.
     * @param oldWorkPlans
     */
    public void onBeforeUpdateValidateAndUpdateWorkPlanFields(Map<Id, WorkPlan> oldWorkPlans) {
        WorkPlan oldWorkPlan;
        for (WorkPlan eachWorkPlan : (List<WorkPlan>) getRecords()) {
            oldWorkPlan = oldWorkPlans.get(eachWorkPlan.Id);
            //JIRA#: LEM-1181
            if (hasNumberOfWorkableWorkStepsChanged(eachWorkPlan, oldWorkPlan)) {
                copyNumberOfWorkableWorkStepsRollUpToNumberField(eachWorkPlan);
            }
        }
    }

    /**
     * @description It calculates Number of validted stores on Parent WorkPlan by summing up
     * child work plans with update on Activation Checklist Validation field.
     * @JIRA# LEM-13305
     * @param activationChecklistValidatedWorkPlans
     */
    private void calculateNumberOfValidatedStoresOnParentWorkPlan(
        Set<Id> activationChecklistValidatedWorkPlans
    ) {
        if (activationChecklistValidatedWorkPlans.isEmpty()) {
            return;
        }
        List<WorkPlan> workPlansToUpdate = new List<WorkPlan>();
        Map<Id, Integer> parentWPIdToValidationCompletedChildWPCount = new Map<Id, Integer>();
        Set<Id> validationEscalatedWorkPlans = new Set<Id>();
        Set<Id> validationInProgressWorkPlans = new Set<Id>();
        for (
            Aggregate eachAggregate : WorkPlansSelector.newInstance()
                .getNumberOfActivationChecklistValidationCompletedChildWorkPlansGroupedByParentWorkPlan(
                    activationChecklistValidatedWorkPlans
                )
        ) {
            switch on
                VALIDATION_STATUSES.get(
                    (String) eachAggregate.get(
                        PARENT_WORKPLAN_AGGREGATE_QUERY_VALIDATION_STATUS_ALIAS
                    )
                ) {
                when STATUS_COMPLETED {
                    parentWPIdToValidationCompletedChildWPCount.put(
                        (Id) eachAggregate.get(PARENT_WORKPLAN_AGGREGATE_QUERY_GROUPBYFIELD_ALIAS),
                        Integer.valueOf(
                            eachAggregate.get(PARENT_WORKPLAN_AGGREGATE_QUERY_COUNT_ALIAS)
                        )
                    );
                }
                when STATUS_ESCALATED {
                    validationEscalatedWorkPlans.add(
                        (Id) eachAggregate.get(PARENT_WORKPLAN_AGGREGATE_QUERY_GROUPBYFIELD_ALIAS)
                    );
                    parentWPIdToValidationCompletedChildWPCount.put(
                        (Id) eachAggregate.get(PARENT_WORKPLAN_AGGREGATE_QUERY_GROUPBYFIELD_ALIAS),
                        Integer.valueOf(
                            eachAggregate.get(PARENT_WORKPLAN_AGGREGATE_QUERY_COUNT_ALIAS)
                        )
                    );
                }
                when STATUS_IN_PROGRESS {
                    validationInProgressWorkPlans.add(
                        (Id) eachAggregate.get(PARENT_WORKPLAN_AGGREGATE_QUERY_GROUPBYFIELD_ALIAS)
                    );
                }
                when STATUS_PENDING {
                    validationInProgressWorkPlans.add(
                        (Id) eachAggregate.get(PARENT_WORKPLAN_AGGREGATE_QUERY_GROUPBYFIELD_ALIAS)
                    );
                }
            }
        }
        for (Id eachWorkPlanId : parentWPIdToValidationCompletedChildWPCount.keySet()) {
            if (validationInProgressWorkPlans.contains(eachWorkPlanId)) {
                workPlansToUpdate.add(
                    new WorkPlan(
                        Id = eachWorkPlanId,
                        Number_of_Stores_Validated__c = parentWPIdToValidationCompletedChildWPCount.get(
                            eachWorkPlanId
                        )
                    )
                );
            } else {
                workPlansToUpdate.add(
                    new WorkPlan(
                        Id = eachWorkPlanId,
                        Activation_Checklist_Validation__c = validationEscalatedWorkPlans.contains(
                                eachWorkPlanId
                            )
                            ? VALIDATION_STATUS_ESCALATED
                            : VALIDATION_STATUS_COMPLETED,
                        Last_Validation_Execution__c = System.now(),
                        Number_of_Stores_Validated__c = parentWPIdToValidationCompletedChildWPCount.get(
                            eachWorkPlanId
                        )
                    )
                );
            }
        }
        fireUpdateOnParent(workPlansToUpdate);
    }

    /**
     * @description It calculates Number of Workable WorkSteps on Parent WorkPlan by summing up
     * "Number of Workable WorkSteps Roll-Up" on child WorkPlans.
     * @JIRA# LEM-1181
     */
    private void calculateNumberOfWorkableWorkStepsOnParentWorkPlan() {
        if (parentWorkPlanIds.isEmpty()) {
            return;
        }
        List<WorkPlan> workPlansToUpdate = new List<WorkPlan>();
        for (
            Aggregate eachAggregate : WorkPlansSelector.newInstance()
                .getSumOfNumberOfWorkableWorkStepsOnChildWorkPlanGroupedByParentWorkPlan(
                    parentWorkPlanIds
                )
        ) {
            workPlansToUpdate.add(
                new WorkPlan(
                    Id = (Id) eachAggregate.get(PARENT_WORKPLAN_AGGREGATE_QUERY_GROUPBYFIELD_ALIAS),
                    Number_of_Workable_WorkSteps__c = Integer.valueOf(
                        eachAggregate.get(PARENT_WORKPLAN_AGGREGATE_QUERY_SUM_ALIAS)
                    )
                )
            );
        }
        fireUpdateOnParent(workPlansToUpdate);
    }

    /**
     * @description It collect Parent WorkPlan of child WorkPlan.
     * @JIRA# LEM-1181
     * @param workPlan
     */
    private void collectParentWorkPlanIds(WorkPlan workPlan) {
        if (isChildWorkPlan(workPlan)) {
            parentWorkPlanIds.add(workPlan.Parent_Work_Plan__c);
        } else {
            parentWorkPlanIds.add(workPlan.Id);
        }
    }

    /**
     * @description It collects child Work Plan record with updated parent Work Plan Id.
     * @JIRA# LEM-6198
     * @param parentWorkPlans
     */
    public void collectParentWorkPlansWithUpdatedInformation(List<WorkPlan> parentWorkPlans) {
        Set<Id> parentWorkPlanIds = new Set<Id>();
        for (WorkPlan eachWorkPlan : parentWorkPlans) {
            if (eachWorkPlan.Parent_Work_Plan__c != null) {
                continue;
            }
            parentWorkPlanIds.add(eachWorkPlan.Id);
        }
        if (parentWorkPlanIds.isEmpty()) {
            return;
        }
        getChildWorkPlansWithParentWorkPlanDetailsByParentWorkPlanIds(
            parentWorkPlanIds,
            EVENT_TOPIC_WORK_OBJECTS_SYNC
        );
    }

    /**
     * @description It collects parent Work Plan Ids from child Work Plan for the given topic.
     * @JIRA# LEM-6198
     * @param parentWorkPlanIds
     * @param eventTopic
     */
    public void getChildWorkPlansWithParentWorkPlanDetailsByParentWorkPlanIds(
        Set<Id> parentWorkPlanIds,
        String eventTopic
    ) {
        Map<Id, WorkPlan> childWorkPlans = new Map<Id, WorkPlan>(
            WorkPlansSelector.newInstance().selectByParentWorkPlanIds(parentWorkPlanIds)
        );
        if (childWorkPlans.isEmpty()) {
            return;
        }
        Integer childWorkPlanIdPayloadChunkSize = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(CHILD_WORKPLAN_IDS_CHUNK_SIZE_STATIC_CONFIG)
                .Configuration_Value__c
        );
        NotifierEventsService.publishBulkEvents(
            new Map<String, List<String>>{
                eventTopic => NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                    childWorkPlans.keySet(),
                    childWorkPlanIdPayloadChunkSize
                )
            }
        );
    }

    /**
     * @description It validates Work Plan fields on After Update trigger event for Marketing
     * Kit WorkOrder Creation.
     * @JIRA# LEM-13484
    */
    public void evaluateAndInitiateMarketingKitWorkOrderCreation() {
        Set<Id> workPlanIdsToCreateMarketingKitWorkOrders = new Set<Id>();
        for (WorkPlan eachWorkPlan : (List<WorkPlan>) getRecords()) {
            if (
                isWorkPlanEligibleForMarketingKitWorkOrderCreation(eachWorkPlan)
            ) {
                workPlanIdsToCreateMarketingKitWorkOrders.add(eachWorkPlan.Id);
            }
        }
        if (workPlanIdsToCreateMarketingKitWorkOrders.isEmpty()) {
            return;
        }
        WorkOrderCreationTriggerService.initiateWorkOrderCreation(
            workPlanIdsToCreateMarketingKitWorkOrders,
            GENERIC_WORK_ORDER_CREATION
        );
    }

    /**
     * @description It checks whether the work plan is eligible for
     * Marketing-Kit work order creartion
     * @JIRA# LEM-13484
     * @param eachWorkPlan
     * @return Boolean
     */
    private Boolean isWorkPlanEligibleForMarketingKitWorkOrderCreation(
        WorkPlan eachWorkPlan
    ) {
        return eachWorkPlan.Enable_Merchant_Orders_Creation__c &&
        eachWorkPlan.Segment__c == SMB_SEGMENT &&
        String.isBlank(eachWorkPlan.Parent_Work_Plan__c) &&
        eachWorkPlan.Status__c == WORK_PLAN_COMPLETE &&
        eachWorkPlan.Type__c == WORK_PLAN_TYPE_ONBOARDING &&
        eachWorkPlan.Work_Order_Type__c == WORK_ORDER_TYPE_MARKETPLACE &&
        eligibleOrderProtocolForPreSalesMarketingKitWorkOrders.contains(eachWorkPlan.Order_Protocol__c);
    }

    /**
     * @description It collects WorkPlan and associated WorkPlanTemplateId.
     * @JIRA# LEM-732
     * @param workPlan
     */
    private void collectWorkPlansAndWorkPlanTemplateIds(WorkPlan workPlan) {
        if (workPlan.Work_Plan_Template__c == null) {
            return;
        }
        workPlansWithWorkPlanTemplateId.add(workPlan);
        workPlanTemplateIds.add(workPlan.Work_Plan_Template__c);
    }

    /**
     * @description It is used to copy "Number_of_Workable_WorkSteps_Roll_Up__c"
     * on "Number_of_Workable_WorkSteps__c" for child WorkPlan.
     * @JIRA# LEM-1181
     * @param workPlan
     */
    private void copyNumberOfWorkableWorkStepsRollUpToNumberField(WorkPlan workPlan) {
        workPlan.Number_of_Workable_WorkSteps__c = workPlan.Number_of_Workable_WorkSteps_Roll_Up__c;
    }

    /**
     * @description It fires UPDATE DML statement on Parent records.
     * @param sObjectsToUpdate
     */
    private void fireUpdateOnParent(List<sObject> sObjectsToUpdate) {
        if (sObjectsToUpdate.isEmpty()) {
            return;
        }
        fflib_ISObjectUnitOfWork uowParentObjectUpdate = Application.UNITOFWORK.newInstance();
        uowParentObjectUpdate.registerDirty(sObjectsToUpdate);
        try {
            uowParentObjectUpdate.commitWork();
        } catch (Exception parentObjectUpdateException) {
            Logger.publish(
                LogEntry.newExceptionLog(parentObjectUpdateException, LogEntry.SeverityLevel.HIGH)
            );
        }
    }

    /**
     * @description It checks whether "Number of Workable WorkSteps Roll-Up" field has changed.
     * @JIRA# LEM-1181
     * @param newWorkPlan
     * @param oldWorkPlan
     * @return Boolean
     */
    private Boolean hasNumberOfWorkableWorkStepsChanged(
        WorkPlan newWorkPlan,
        WorkPlan oldWorkPlan
    ) {
        return (newWorkPlan.Number_of_Workable_WorkSteps_Roll_Up__c !=
            oldWorkPlan.Number_of_Workable_WorkSteps_Roll_Up__c) &&
            newWorkPlan.Parent_Work_Plan__c != null;
    }

    /**
     * @description It checks whether Parent WorkPlan field is changed.
     * @JIRA# LEM-1181, LEM-1964
     * @param newWorkPlan
     * @param oldWorkPlan
     * @return Boolean
     */
    private Boolean hasParentWorkPlanChanged(WorkPlan newWorkPlan, WorkPlan oldWorkPlan) {
        return newWorkPlan.Parent_Work_Plan__c != oldWorkPlan.Parent_Work_Plan__c;
    }

    /**
     * @description It checks whether Activation Checklist Validation status is updated on child Work Plans.
     * @JIRA# LEM-13305
     * @param newWorkPlan
     * @param oldWorkPlan
     * @return Boolean
     */
    private Boolean isActivationChecklistValidationStatusChanged(
        WorkPlan newWorkPlan,
        WorkPlan oldWorkPlan
    ) {
        return ((oldWorkPlan.Activation_Checklist_Validation__c !=
        newWorkPlan.Activation_Checklist_Validation__c) &&
        (oldWorkPlan.Activation_Checklist_Validation__c == VALIDATION_STATUS_COMPLETED ||
        newWorkPlan.Activation_Checklist_Validation__c == VALIDATION_STATUS_COMPLETED ||
        newWorkPlan.Activation_Checklist_Validation__c == VALIDATION_STATUS_ESCALATED) &&
        (newWorkPlan.Parent_Work_Plan__c != null));
    }

    /**
     * @description It checks whether Activation Checklist Validation status is updated
     * to 'In Progress' on parent Work Plans.
     * @JIRA# LEM-13305
     * @param newWorkPlan
     * @param oldWorkPlan
     * @return Boolean
     */
    private Boolean isActivationChecklistValidationInProgressOnParentWorkPlan(
        WorkPlan newWorkPlan,
        WorkPlan oldWorkPlan
    ) {
        return ((oldWorkPlan.Activation_Checklist_Validation__c !=
        newWorkPlan.Activation_Checklist_Validation__c) &&
        (newWorkPlan.Activation_Checklist_Validation__c == VALIDATION_STATUS_IN_PROGRESS) &&
        (newWorkPlan.Parent_Work_Plan__c == null));
    }

    /**
     * @description It checks whether WorkPlan has Parent WorkPlan populated.
     * @JIRA# LEM-1181
     * @param workPlan
     * @return Boolean
     */
    private Boolean isChildWorkPlan(WorkPlan workPlan) {
        return workPlan.Parent_Work_Plan__c != null;
    }

    /**
     * @description It checks whether the Work Plan is eligible for Marketing Kit Mx Order creation.
     * @JIRA# LEM-22115
     * @param workPlan
     * @return Boolean
     */
    private Boolean isEligibleForMarketingKitMxOrderCreation(WorkPlan workPlan) {
        return workPlan.Enable_Merchant_Orders_Creation__c &&
            workPlan.Type__c == TYPE_MARKETING_KIT;
    }

    /**
     * @description It checks whether the Work Plan is eligible for Photoshoot Mx Order creation.
     * @JIRA# LEM-22115
     * @param workPlan
     * @return Boolean
     */
    private Boolean isEligibleForPhotoshootMxOrderCreation(WorkPlan workPlan) {
        return workPlan.Enable_Merchant_Orders_Creation__c && workPlan.Type__c == VENDOR_PHOTOSHOOT;
    }

    /**
     * @description It checks whether Storefront Work Plan created by Place It For Me process.
     * @JIRA# LEM-22115
     * @param workPlan
     * @return Boolean
     */
    private Boolean isPlaceItForMeStorefrontWorkPlan(WorkPlan workPlan) {
        return workPlan.Type__c == WORK_PLAN_TYPE_STOREFRONT &&
            workPlan.Parent_Work_Order_Creation_Source__c ==
            WORK_ORDER_CREATION_SOURCE_PLACE_IT_FOR_ME;
    }

    /**
     * @description This class is used for implementing fflib_IDomainConstructor Interface
     */
    public class Constructor implements fflib_IDomainConstructor {
        /**
         * @description Constructor method implementation from fflib_IDomainConstructor class
         * @param objectList
         * @return WorkPlans
         */
        public fflib_SObjects construct(List<Object> objectList) {
            if (WorkPlans.constructorMock != null) {
                return (fflib_SObjects) WorkPlans.constructorMock.construct(objectList);
            }
            return new WorkPlans((List<SObject>) objectList);
        }
    }

    /**
     * @description It is used to populate the Is Virtual and Is Verified POS Integration flag
     * on Parent Work Plan.
    */
    private void populateParentWorkPlanFields() {
        Set<Id> childWorkPlanIds = new Set<Id>();
        for(WorkPlan eachWorkPlan : (List<WorkPlan>) getRecords()){
            if(eachWorkPlan.Parent_Work_Plan__c  != null){
                childWorkPlanIds.add(eachWorkPlan.Id);
            }
        }
        if(!childWorkPlanIds.isEmpty()){
            fflib_ISObjectUnitOfWork unitOfWork = Application.UNITOFWORK.newInstance();
            Map<Id,WorkPlan> mapOfParentWorkPlanIdToWorkPlan = new Map<Id,WorkPlan>();
            setParentWorkPlanFields(mapOfParentWorkPlanIdToWorkPlan,childWorkPlanIds);
            if(!mapOfParentWorkPlanIdToWorkPlan.values().isEmpty()){
                unitOfWork.registerDirty(mapOfParentWorkPlanIdToWorkPlan.values());
                unitOfWork.commitWork();
            }
        }
    }

    /**
     * @description It is used to set the Is Virtual and Is Verified POS Integration flag
     * on Parent Work Plan.
     * @param mapOfParentWorkPlanIdToWorkPlan
     * @param childWorkPlanIds
    */
    private void setParentWorkPlanFields(Map<Id,WorkPlan> mapOfParentWorkPlanIdToWorkPlan,Set<Id> childWorkPlanIds)
    {
        for(WorkPlan eachWorkPlan : WorkPlansSelector.newInstance()
            .selectWorkPlansWithWorkOrderAssociatedToVirtualStores(childWorkPlanIds)){
            WorkPlan parentWorkplan = new WorkPlan(
                Id = eachWorkPlan.Parent_Work_Plan__c,
                Is_Virtual_Store__c = true
            );
            if(!mapOfParentWorkPlanIdToWorkPlan.containsKey(eachWorkPlan.Parent_Work_Plan__c)){
                mapOfParentWorkPlanIdToWorkPlan.put(eachWorkPlan.Parent_Work_Plan__c,parentWorkplan);
            }
        }

        for(WorkPlan eachWorkPlan : WorkPlansSelector.newInstance()
            .selectWorkPlansWithVerifiedPOSIntegrationTypes(childWorkPlanIds)){
            if(mapOfParentWorkPlanIdToWorkPlan.containsKey(eachWorkPlan.Parent_Work_Plan__c) &&
                !(mapOfParentWorkPlanIdToWorkPlan.get(eachWorkPlan.Parent_Work_Plan__c).Is_POS_Integration_Verified__c)
            ) {
                mapOfParentWorkPlanIdToWorkPlan.get(eachWorkPlan.Parent_Work_Plan__c).Is_POS_Integration_Verified__c = true;
            }
            else if(!mapOfParentWorkPlanIdToWorkPlan.containsKey(eachWorkPlan.Parent_Work_Plan__c))
            {
                WorkPlan parentWorkplan = new WorkPlan(
                    Id = eachWorkPlan.Parent_Work_Plan__c,
                    Is_POS_Integration_Verified__c = true
                );
                mapOfParentWorkPlanIdToWorkPlan.put(eachWorkPlan.Parent_Work_Plan__c,parentWorkplan);
            }
        }
    }
}