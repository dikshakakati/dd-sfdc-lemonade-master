/**
 * @author Deloitte
 * @date 09/01/2022
 * @description Service class for parent Work Order sync related logic.
 */
public inherited sharing class ParentWorkOrderSyncService {
    /**
     * @description It is used for enabling indiactor on parent Work Order for the
     * following Work Plans generation criteria is dependent on store level values:
     * a. POS
     * b. Storefront Bundled
     * c. Tablet
     * @JIRA# LEM-2370 & LEM-2683
     * @param workOrders
     */
    public static void enableStoreLevelWorkPlansIndicatorsOnParentWorkOrder(
        List<WorkOrder> workOrders
    ) {
        service().enableStoreLevelWorkPlansIndicatorsOnParentWorkOrder(workOrders);
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
    public static void enableStoreLevelWorkPlanIndicatorsOnParentWorkOrderByStoreAccounts(
        Set<Id> storeAccountIds
    ) {
        service()
            .enableStoreLevelWorkPlanIndicatorsOnParentWorkOrderByStoreAccounts(storeAccountIds);
    }

    /**
     * @description It is used to process the passed Work Orders related to merged Accounts.
     * It enables store level Work Plans indicators on basis of the passed Work Orders.
     * @JIRA# LEM-3643
     * @param workOrders
     */
    public static void processMergedAccountsRelatedRecords(List<WorkOrder> workOrders) {
        service().processMergedAccountsRelatedRecords(workOrders);
    }

    /**
     * @description It creates instance of ParentWorkOrderSyncServiceImpl class.
     * @return IParentWorkOrderSyncService - instance of ParentWorkOrderSyncServiceImpl
     */
    private static IParentWorkOrderSyncService service() {
        return (IParentWorkOrderSyncService) Application.Service.newInstance(
            IParentWorkOrderSyncService.class
        );
    }

    /**
     * @description It is used to update the  parent work order PDOx indicator field if there there are differences
     * in PDOA/PDOM dates amongst the stores.
     * @JIRA# LEM-5126
     * @param parentAccountIds
     */
    public static void updateStoreLevelPDOxIndicatorOnParentWorkOrder(
        Set<Id> parentAccountIds
    ) {
        service()
            .updateStoreLevelPDOxIndicatorOnParentWorkOrder(parentAccountIds);
    }
}