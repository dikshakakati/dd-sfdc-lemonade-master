/**
 * @author Deloitte
 * @date 09/01/2022
 * @description Service implementation class for parent Work Order sync related logic.
 */
public inherited sharing class ParentWorkOrderSyncServiceImpl implements IParentWorkOrderSyncService {
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final String AGGREGATE_BUNDLED_WITH_MARKETPLACE_FIELD_ALIAS = 'bundledWithMarketplace';
    private static final String AGGREGATE_DELAY_TABLET_SHIPMENT_FIELD_ALIAS = 'delayTabletShipment';
    private static final String AGGREGATE_PARENTWORKORDERID_FIELD_ALIAS = 'parentWorkOrderId';
    private static final String AGGREGATE_PROPOSED_DATE_ACTIVATION_FIELD_ALIAS = 'proposedDateOfActivaton';
    private static final String AGGREGATE_PPROPOSED_DATE_MENU_FIELD_ALIAS = 'proposedDateOfMenu';
    private static final String AGGREGATE_MENU_UI_TYPE_FIELD_ALIAS = 'menuUIType';
    private static final String AGGREGATE_ORDER_PROTOCOL_FIELD_ALIAS = 'orderProtocol';
    private static final String AGGREGATE_POS_INTEGRATION_TYPE_FIELD_ALIAS = 'posIntergrationType';
    private static final String AGGREGATE_TABLET_DELIVERY_METHOD_FIELD_ALIAS = 'tabletDeliveryMethod';
    private static final String BUNDLED_WITH_MARKETPLACE_NO = 'No';
    private static final String BUNDLED_WITH_MARKETPLACE_YES = 'Yes';
    private static final String DELAY_TABLET_SHIPMENT_YES = 'Yes';
    private static final String MENU_UI_TYPE_RESTAURANT = 'Restaurant';
    private static final String MENU_UI_TYPE_RETAIL = 'Retail';
    private static final String ORDER_PROTOCOL_EXCLUDED_VALUES = System.Label.Order_Protocol_Excluded_Values_For_Tablet_WorkPlan;
    private static final String POS_INTEGRATION_TYPE_NON_INTEGRATED_MX = 'non_integrated_mx';
    private static final String TABLET_DELIVERY_METHOD = 'Drop-ship';
    private static final String LOG_SERVICE_WORK_ORDER = 'Parent Work Order Sync';
    private static final String LOG_DOMAIN_PROVISIONING = 'Provisioning';

    /**
     * @description It is used for enabling indiactor on parent Work Order for the
     * following Work Plans generation criteria is dependent on store level values:
     * a. POS
     * b. Storefront Bundled
     * c. Tablet
     * Update the Parent wokkplan indicator for change in Storelevel PDox changes
     * Update the Parent workorder PDOx Indicator when the store account PDOx value does not match
     * @JIRA# LEM-2370 & LEM-2683 && LEM-5126 && LEM-5126
     * @param workOrders
     */
    public void enableStoreLevelWorkPlansIndicatorsOnParentWorkOrder(List<WorkOrder> workOrders) {
        Map<Id, WorkOrder> parentWorkOrders = collectParentWorkOrders(workOrders);
        if (!parentWorkOrders?.isEmpty()) {
            setStoreLevelWorkPlansIndicatorValues(parentWorkOrders);
            setParentWorkOrderPDOxIndicator(parentWorkOrders);
            fireUpdateOnParent(parentWorkOrders.values());
        }
    }

    /**
     * @description It is used for enabling indiactor on parent Work Order for the
     * following Work Plans generation criteria when POS_Integration_Type__c or
     * Tablet_Delivery_Method__c field is updated on the store Account:
     * a. POS
     * b. Tablet
     * @JIRA# LEM-2683
     * @param storeAccountIds
     */
    public void enableStoreLevelWorkPlanIndicatorsOnParentWorkOrderByStoreAccounts(
        Set<Id> storeAccountIds
    ) {
        List<WorkOrder> workOrdersToEnableStoreLevelWorkPlanIndicators = new List<WorkOrder>();
        workOrdersToEnableStoreLevelWorkPlanIndicators = WorkOrdersSelector.newInstance()
            .selectWorkOrdersByAccountIds(storeAccountIds);
        // enables POS and Tablet Work Plan indicators on parent WorkOrder
        enableStoreLevelWorkPlansIndicatorsOnParentWorkOrder(
            workOrdersToEnableStoreLevelWorkPlanIndicators
        );
    }

    /**
     * @description It is used to process the passed Work Orders related to merged Accounts.
     * It enables store level Work Plans indicators on basis of the passed Work Orders.
     * @JIRA# LEM-3643
     * @param workOrdersToProcess
     */
    public void processMergedAccountsRelatedRecords(List<WorkOrder> workOrdersToProcess) {
        if (workOrdersToProcess.isEmpty()) {
            return;
        }
        enableStoreLevelWorkPlansIndicatorsOnParentWorkOrder(workOrdersToProcess);
    }

    /**
     * @description It collects parent Work Orders from the passed list of Work Orders.
     * @param workOrders
     * @return Map<Id, WorkOrder>
     */
    private Map<Id, WorkOrder> collectParentWorkOrders(List<WorkOrder> workOrders) {
        Map<Id, WorkOrder> parentWorkOrders = new Map<Id, WorkOrder>();
        for (WorkOrder eachWorkOrder : workOrders) {
            if (isChildWorkOrder(eachWorkOrder)) {
                parentWorkOrders.put(
                    eachWorkOrder.ParentWorkOrderId,
                    new WorkOrder(
                        Id = eachWorkOrder.ParentWorkOrderId,
                        Has_Any_Store_Tablet_Shipment_Delayed__c = false,
                        HasCatalogWorkPlan__c = false,
                        HasMenuWorkPlan__c = false,
                        HasPOSWorkPlan__c = false,
                        HasTabletWorkPlan__c = false,
                        Bundled_with_Marketplace__c = BUNDLED_WITH_MARKETPLACE_NO
                    )
                );
            }
        }
        return parentWorkOrders;
    }

    /**
     * @description A common method to commit unit of work.
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
            );
        }
    }

    /**
     * @description It fires UPDATE DML statement on Parent records.
     * @param sObjectsToUpdate
     */
    private void fireUpdateOnParent(List<sObject> sObjectsToUpdate) {
        fflib_ISObjectUnitOfWork uowParentObjectUpdate = Application.UNITOFWORK.newInstance();
        uowParentObjectUpdate.registerDirty(sObjectsToUpdate);
        commitWork(uowParentObjectUpdate);
    }

    /**
     * @description It checks whether the passed Work Order is child Work Order.
     * @param workOrder
     * @return Boolean
     */
    private Boolean isChildWorkOrder(WorkOrder workOrder) {
        return workOrder.ParentWorkOrderId != null &&
            workOrder.Account_Record_Type_Name__c == ACCOUNT_RECORD_TYPE_NAME_STORE;
    }

    /**
     * @description It sets store level Work Plans indicator values on parent WorkOrder.
     * @param parentWorkOrders
     */
    private void setStoreLevelWorkPlansIndicatorValues(Map<Id, WorkOrder> parentWorkOrders) {
        Id workOrderId;
        WorkOrder currentWorkOrder;
        Boolean hasCatalogChildWorkPlans;
        Boolean hasMenuChildWorkPlans;
        Boolean hasPOSChildWorkPlans;
        Boolean hasTabletChildWorkPlans;
        Boolean hasTabletShipmentDelayed;
        String bundledWithMarketplace;
        Set<String> orderProtocolExcludedValues = new Set<String>(
            ORDER_PROTOCOL_EXCLUDED_VALUES.split(System.Label.Separator)
        );
        for (
            Aggregate eachAggregate : WorkOrdersSelector.newInstance()
                .getCountFilteredByPassedIdsGroupedByStoreLevelWorkPlansIndicators(
                    parentWorkOrders.keySet()
                )
        ) {
            workOrderId = (Id) eachAggregate.get(AGGREGATE_PARENTWORKORDERID_FIELD_ALIAS);
            currentWorkOrder = parentWorkOrders.get(workOrderId);
            hasCatalogChildWorkPlans =
                currentWorkOrder.HasCatalogWorkPlan__c ||
                eachAggregate.get(AGGREGATE_MENU_UI_TYPE_FIELD_ALIAS) == MENU_UI_TYPE_RETAIL;
            hasMenuChildWorkPlans =
                currentWorkOrder.HasMenuWorkPlan__c ||
                eachAggregate.get(AGGREGATE_MENU_UI_TYPE_FIELD_ALIAS) == MENU_UI_TYPE_RESTAURANT;
            hasPOSChildWorkPlans =
                currentWorkOrder.HasPOSWorkPlan__c ||
                (eachAggregate.get(AGGREGATE_POS_INTEGRATION_TYPE_FIELD_ALIAS) !=
                POS_INTEGRATION_TYPE_NON_INTEGRATED_MX &&
                eachAggregate.get(AGGREGATE_POS_INTEGRATION_TYPE_FIELD_ALIAS) != null);
            hasTabletChildWorkPlans =
                currentWorkOrder.HasTabletWorkPlan__c ||
                (eachAggregate.get(AGGREGATE_TABLET_DELIVERY_METHOD_FIELD_ALIAS) ==
                TABLET_DELIVERY_METHOD &&
                !orderProtocolExcludedValues.contains(
                    (String) eachAggregate.get(AGGREGATE_ORDER_PROTOCOL_FIELD_ALIAS)
                ));
            bundledWithMarketplace = currentWorkOrder.Bundled_with_Marketplace__c ==
                BUNDLED_WITH_MARKETPLACE_YES
                ? BUNDLED_WITH_MARKETPLACE_YES
                : (String) eachAggregate.get(AGGREGATE_BUNDLED_WITH_MARKETPLACE_FIELD_ALIAS);
            hasTabletShipmentDelayed =
                currentWorkOrder.Has_Any_Store_Tablet_Shipment_Delayed__c ||
                eachAggregate.get(AGGREGATE_DELAY_TABLET_SHIPMENT_FIELD_ALIAS) ==
                DELAY_TABLET_SHIPMENT_YES;
            currentWorkOrder.HasCatalogWorkPlan__c = hasCatalogChildWorkPlans;
            currentWorkOrder.HasMenuWorkPlan__c = hasMenuChildWorkPlans;
            currentWorkOrder.HasPOSWorkPlan__c = hasPOSChildWorkPlans;
            currentWorkOrder.HasTabletWorkPlan__c = hasTabletChildWorkPlans;
            currentWorkOrder.Bundled_with_Marketplace__c = bundledWithMarketplace;
            currentWorkOrder.Has_Any_Store_Tablet_Shipment_Delayed__c = hasTabletShipmentDelayed;
            parentWorkOrders.put(workOrderId, currentWorkOrder);
        }
    }

    /**
     * @description Update the Parent WorOrder PDOx Indicator field highlighting if there are differences
     * in PDOA/PDOM dates amongst the stores.
     * @JIRA# LEM-5126
     * @param storeAccountIds
     */
    public void updateStoreLevelPDOxIndicatorOnParentWorkOrder(Set<Id> storeAccountIds) {
        if (storeAccountIds.isEmpty()) {
            return;
        }
        List<WorkOrder> workOrders = new List<WorkOrder>();
        workOrders = WorkOrdersSelector.newInstance().selectByAccountIds(storeAccountIds);
        if (workOrders.isEmpty()) {
            return;
        }
        Set<Id> parentWorkOrderIds = new Set<Id>();
        for (
            WorkOrder eachWorkOrder : WorkOrdersSelector.newInstance()
                .selectByAccountIds(storeAccountIds)
        ) {
            if (eachWorkOrder.ParentWorkOrderId != null) {
                parentWorkOrderIds.add(eachWorkOrder.ParentWorkOrderId);
            }
        }
        if (!parentWorkOrderIds.isEmpty()) {
            Map<Id, WorkOrder> parentWorkOrders = getParentWorkOrders(parentWorkOrderIds);
            setParentWorkOrderPDOxIndicator(parentWorkOrders);
            fireUpdateOnParent(parentWorkOrders.values());
        }
    }

    /**
     * @description From the results of WorkOrder Selector Agrregare Query Populate the
     * Map of ParentWorkOrdeId to Set of PDOx dates
     * Update the Parent WorkOrder PDOx Indicator
     * @JIRA# LEM-5126
     * @param parentWorkOrders
     */
    private void setParentWorkOrderPDOxIndicator(Map<Id, WorkOrder> parentWorkOrders) {
        Map<Id, Set<Date>> proposedDateOfActivationDateSetByParentWorkOrderID = new Map<Id, Set<Date>>();
        Map<Id, Set<Date>> proposedDateOfMenuDateSetByParentWorkOrderID = new Map<Id, Set<Date>>();
        Id parentWorkOrderId;
        for (
            Aggregate eachAggregate : WorkOrdersSelector.newInstance()
                .selectChildWorkOrdersFilteredByParentWorkOrderIDsGroupedByStoreLevelPDOxDates(
                    parentWorkOrders.keySet()
                )
        ) {
            parentWorkOrderId = (Id) eachAggregate.get(AGGREGATE_PARENTWORKORDERID_FIELD_ALIAS);
            if (
                !proposedDateOfActivationDateSetByParentWorkOrderID.containsKey(parentWorkOrderId)
            ) {
                proposedDateOfActivationDateSetByParentWorkOrderID.put(
                    parentWorkOrderId,
                    new Set<Date>()
                );
            }
            if (eachAggregate.get(AGGREGATE_PROPOSED_DATE_ACTIVATION_FIELD_ALIAS) != null) {
                proposedDateOfActivationDateSetByParentWorkOrderID.get(parentWorkOrderId)
                    .add((Date) eachAggregate.get(AGGREGATE_PROPOSED_DATE_ACTIVATION_FIELD_ALIAS));
            }
            if (!proposedDateOfMenuDateSetByParentWorkOrderID.containsKey(parentWorkOrderId)) {
                proposedDateOfMenuDateSetByParentWorkOrderID.put(
                    parentWorkOrderId,
                    new Set<Date>()
                );
            }
            if (eachAggregate.get(AGGREGATE_PPROPOSED_DATE_MENU_FIELD_ALIAS) != null) {
                proposedDateOfMenuDateSetByParentWorkOrderID.get(parentWorkOrderId)
                    .add((Date) eachAggregate.get(AGGREGATE_PPROPOSED_DATE_MENU_FIELD_ALIAS));
            }
        }
        updateParentWorkOrderPDOxIndicator(
            parentWorkOrders,
            proposedDateOfActivationDateSetByParentWorkOrderID,
            proposedDateOfMenuDateSetByParentWorkOrderID
        );
    }

    /**
     * @description Sets the Parent WorkOrder PDOx Indicator to True if the Store Level PDOx matches
     * Sets the Parent WorkOrder PDOx Indicator to False if the Account Level PDOx does not match
     * @JIRA# LEM-5126
     * @param parentWorkOrders
     * @param proposedDateOfActivationDateSetByParentWorkOrderID
     * @param proposedDateOfMenuDateSetByParentWorkOrderID
     */
    private void updateParentWorkOrderPDOxIndicator(
        Map<Id, WorkOrder> parentWorkOrders,
        Map<Id, Set<Date>> proposedDateOfActivationDateSetByParentWorkOrderID,
        Map<Id, Set<Date>> proposedDateOfMenuDateSetByParentWorkOrderID
    ) {
        Boolean isPDOAPDOMSameforAllStores;
        WorkOrder currentWorkOrder;
        for (Id eachParentWorkOrderID : parentWorkOrders.keySet()) {
            isPDOAPDOMSameforAllStores = false;
            currentWorkOrder = parentWorkOrders.get(eachParentWorkOrderID);
            if (
                proposedDateOfActivationDateSetByParentWorkOrderID.containsKey(
                    eachParentWorkOrderID
                ) || proposedDateOfMenuDateSetByParentWorkOrderID.containsKey(eachParentWorkOrderID)
            ) {
                if (
                    proposedDateOfActivationDateSetByParentWorkOrderID.get(eachParentWorkOrderID)
                        .size() > 1 ||
                    proposedDateOfMenuDateSetByParentWorkOrderID.get(eachParentWorkOrderID).size() >
                    1
                ) {
                    isPDOAPDOMSameforAllStores = false;
                } else {
                    isPDOAPDOMSameforAllStores = true;
                }
                currentWorkOrder.Is_PDOA_PDOM_Same_for_All_Stores__c = isPdoaPdomSameForAllStores;
                parentWorkOrders.put(eachParentWorkOrderID, currentWorkOrder);
            }
        }
    }

    /**
     * @description It collects parent Work Orders from the passed list of Parent WorkOrder IDs
     * @JIRA# LEM-5126
     * @param parentWorkOrdersIDs
     * @return Map<Id, WorkOrder>
     */
    private Map<Id, WorkOrder> getParentWorkOrders(Set<Id> parentWorkOrdersIDs) {
        Map<Id, WorkOrder> parentWorkOrders = new Map<Id, WorkOrder>();
        for (Id eachID : parentWorkOrdersIDs) {
            parentWorkOrders.put(eachID, new WorkOrder(Id = eachID));
        }
        return parentWorkOrders;
    }
}