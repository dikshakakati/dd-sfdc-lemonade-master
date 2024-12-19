/**
 * @author Deloitte
 * @date 09/01/2022
 * @description Interface of service class for parent Work Order sync related logic.
 */
public interface IParentWorkOrderSyncService {
    /**
     * @description It is used for enabling indiactor on parent Work Order for the
     * following Work Plans generation criteria is dependent on store level values:
     * a. POS
     * b. Storefront Bundled
     * c. Tablet
     * @param workOrders
     */
    void enableStoreLevelWorkPlansIndicatorsOnParentWorkOrder(List<WorkOrder> workOrders);

    /**
     * @description It is used for enabling indiactor on parent Work Order for the
     * following Work Plans generation criteria when POS_Integration_Type__c or
     * Tablet_Delivery_Method__c field is updated on the store Account:
     * a. POS
     * b. Tablet
     * @param storeAccountIds
     */
    void enableStoreLevelWorkPlanIndicatorsOnParentWorkOrderByStoreAccounts(
        Set<Id> storeAccountIds
    );

    /**
     * @description It is used to process the passed Work Orders related to merged Accounts.
     * It enables store level Work Plans indicators on basis of the passed Work Orders.
     * @param workOrders
     */
    void processMergedAccountsRelatedRecords(List<WorkOrder> workOrders);

    /**
     * @description It is used to update the  parent work order PDOx indicator field if there there are differences
     * in PDOA/PDOM dates amongst the stores.
     * @param parentAccountIds
     */
    void updateStoreLevelPDOxIndicatorOnParentWorkOrder(Set<Id> parentAccountIds);
}