/**
 * @author Deloitte
 * @date 03/31/2022
 * @description Interface for WorkOrder selector class methods.
 */
public interface IWorkOrdersSelector extends fflib_ISObjectSelector {
    /**
     * @description It is used for getting number of child Work Orders
     * grouped by Provisioning Status values using given set of parent Work Order Ids.
     * @param parentWorkOrderIds - Set of parent WorkOrder Ids
     * @return Aggregate[]
     */
    Aggregate[] getChildWorkOrdersCountFilteredByParentWorkOrderIdsGroupedByProvisioningStatus(
        Set<Id> parentWorkOrderIds
    );

    /**
     * @description It is used for getting unique number of child WorkOrders grouped by store Account's
     * POS Integration Type & Tablet Delivery Method and Work Order's Bundled with Marketplace fields
     * using passed parent WorkOrder Ids.
     * @param parentWorkOrderIds
     * @return Aggregate[]
     */
    Aggregate[] getCountFilteredByPassedIdsGroupedByStoreLevelWorkPlansIndicators(
        Set<Id> parentWorkOrderIds
    );

    /**
     * @description It is used for getting count of WorkOrders filtered by passed AccountIds and
     * grouped by passed AccountIds.
     * @param workOrderAccountIds - Set of WorkOrder AccountIds
     * @return Aggregate[]
     */
    Aggregate[] getMarketplaceWorkOrdersCountFilteredByAccountIdsGroupedByAccountId(
        Set<Id> workOrderAccountIds
    );

    /**
     * @description It is used for getting unique number of Store Accounts from child WorkOrders
     * using given set of parent Work Order Ids.
     * @param parentWorkOrderIds - Set of parent WorkOrder Ids
     * @return Aggregate[]
     */
    Aggregate[] getUniqueStoreAccountsCountFilteredByParentWorkOrderIdsGroupedByParentWorkOrderId(
        Set<Id> parentWorkOrderIds
    );

    /**
     * @description - Method is being used to get WorkOrder records(Applicable only for Batch job)
     * @return List<WorkOrder>
     */
    List<WorkOrder> getWorkOrderRecordsForUpdateStatus();

    /**
     * @description It is used for retrieving Work Orders.
     * @param workOrderIds
     * @return List<WorkOrder>
     */
    List<WorkOrder> selectWorkOrderForPhotoshoot(Set<Id> workOrderIds);

    /**
     * @description - Method is being used to get WorkOrder records
     * @return Database.QueryLocator
     */
    Database.QueryLocator getWorkOrderRecordsForUpdateStatusFromBatch();

    /**
     * @description It queries Work Orders associated with the passed Account Ids.
     * @param accountIds
     * @return List<WorkOrder>
     */
    List<WorkOrder> selectByAccountIds(Set<Id> accountIds);

    /**
     * @description It is used for getting WorkOrders by the passed Ids.
     * @param workOrderIds
     * @return List<WorkOrder>
     */
    List<WorkOrder> selectById(Set<Id> workOrderIds);

    /**
     * @description It queries Work Orders by the passed parent WorkOrder Ids.
     * @param parentWorkOrderIds
     * @return List<WorkOrder>
     */
    List<WorkOrder> selectByParentWorkOrderIds(Set<Id> parentWorkOrderIds);

    /**
     * @description It queries WorkOrders and associated WorkSteps by set of WorkOrder Ids.
     * @param workOrderIds
     * @return List<WorkOrder>
     */
    List<WorkOrder> selectWorkOrdersAndWorkStepsUsingWorkOrderIds(Set<Id> workOrderIds);

    /**
     * @description It queries Non-Dead Drive Auto Activations Work Orders by passed Account Ids.
     * @JIRA# LEM-11612
     * @param accountIds
     * @return List<WorkOrder>
     */
    List<WorkOrder> selectNonDeadDriveAutoActivationsWorkOrdersByAccountIds(Set<Id> accountIds);

    /**
     * @description It queries WorkOrders by set of Account Ids.
     * @param accountIds
     * @return List<WorkOrder>
     */
    List<WorkOrder> selectWorkOrdersByAccountIds(Set<Id> accountIds);

    /**
     * @description It queries WorkOrders associated with passed Business Account Ids.
     * @param businessAccountIds
     * @return List<WorkOrder>
     */
    List<WorkOrder> selectWorkOrdersByBusinessAccountIds(Set<Id> businessAccountIds);

    /**
     * @description It queries child WorkOrders associated with passed Store Account Ids
     * and filtered by parent Work Order Ids.
     * @param parentWorkOrderIds
     * @param storeAccountIds
     * @return List<WorkOrder>
     */
    List<WorkOrder> selectChildWorkOrdersByStoreAccountIds(
        Set<Id> parentWorkOrderIds,
        Set<Id> storeAccountIds
    );
    /**
     * @description It queries parent Work Orders by passed Opportunity Ids.
     * @param opportunityIds
     * @return List<WorkOrder>
     */
    List<WorkOrder> selectParentWorkOrdersByOpportunityIds(Set<Id> opportunityIds);

    /**
     * @description It queries Work Orders with Account and related details
     * by the passed Work Order Ids where Provisioning Status is in the allowed status.
     * @param workOrderFieldSet
     * @param workOrderIds
     * @return List<WorkOrder>
     */
    List<WorkOrder> selectWorkOrdersWithAccountDetailsByIds(
        Schema.FieldSet workOrderFieldSet,
        Set<Id> workOrderIds
    );

    /**
     * @description It queries parent and child Work Orders along with related Work Plans
     * by the passed parent Work Order Ids.
     * @param parentWorkOrderIds
     * @return List<WorkOrder>
     */
    List<WorkOrder> selectWorkOrdersWithWorkPlansByParentWorkOrderIds(Set<Id> parentWorkOrderIds);
    /**
     * @description It is used to get WorkOrder that are not Complete, and of Type Drive, by AccountId
     * @JIRA# LEM-2772
     * @param accountIds
     * @return List<WorkOrder>
     */
    List<WorkOrder> queryNonCompleteDriveWorkOrdersByAccountIds(Set<Id> accountIds);

    /**
     * @description It queries WorkOrders with passed Nintex Ids from associated Opportunity.
     * @param nintexIds
     * @return List<WorkOrder>
     */
    List<WorkOrder> selectByNintexIds(Set<String> nintexIds);

    /**
     * @description It queries Work Orders using the passed Email Reference Ids.
     * @param emailReferenceIds
     * @return List<WorkOrder>
     */
    List<WorkOrder> selectByEmailReferenceIds(Set<String> emailReferenceIds);

    /**
     * @description It queries parent Work Orders by the passed Contract Ids.
     * @param contractIds
     * @return List<WorkOrder>
     */
    List<WorkOrder> selectParentWorkOrdersByContractIds(Set<Id> contractIds);
    /**
     * @description It queries the workorders which has amended Opportunity/Contract by the passed WorkOrders Ids.
     * @JIRA# LEM-3170
     * @param workOrderIds
     * @return List<WorkOrder>
     */
    List<WorkOrder> selectAmendedOpportunityWorkOrdersByWorkOrderIds(Set<Id> workOrderIds);
    /**
     * @description It queries the workorders which has amended Opportunity/Contract by the passed WorkOrders Ids.
     * @JIRA# LEM-4223
     * @param workOrderIds
     * @return List<WorkOrder>
     */
    List<WorkOrder> selectDriveAmendedOpportunityWorkOrdersByWorkOrderIds(Set<Id> workOrderIds);
    /**
     * @description It queries the workorders which has amended Opportunity/Contract by the passed WorkOrders Ids.
     * @JIRA# LEM-3648
     * @return Database.QueryLocator
     */
    Database.QueryLocator selectCOOWorkOrdersBasedOnPDOADate();

    /**
     * @description It queries the workorders and parent workorder fields by the passed account id.
     * @JIRA# LEM-4850
     * @param accountId
     * @return List<WorkOrder>
     */
    List<WorkOrder> selectWorkOrdersByAccountId(Id accountId);

    /**
     * @description It queries the parent workorder fields by the passed opportunity id.
     * @JIRA# LEM-5270
     * @param opportunityId
     * @return List<WorkOrder>
     */
    List<WorkOrder> selectWorkOrdersByOpportunityId(Id opportunityId);

    /**
     * @description  It is used for getting unique number of child Work Orders grouped by store Account’s
     * PDOx fields using passed parent WorkOrder Ids.
     * @param parentWorkOrderIds - Set of Parent workOrder Ids
     * @return Aggregate[]
     */
    Aggregate[] selectChildWorkOrdersFilteredByParentWorkOrderIDsGroupedByStoreLevelPDOxDates(
        Set<Id> parentWorkOrderIds
    );

    /**
     * @description It queries parent and child Work Orders not having Status
     * as Dead using the passed Work Order Ids.
     * @param workOrderIds
     * @return List<WorkOrder>
     */
    List<WorkOrder> selectParentAndChildrenByIds(Set<Id> workOrderIds);

    /**
     * @description This method is used for getting workOrders and workplans by AccountIds, status and types
     * @param accountIds
     * @param status
     * @param type
     * @return List<WorkOrder>
     */
    List<WorkOrder> selectWorkOrdersAndWorkPlansByAccountIdsAndStatusAndType(
        Set<Id> accountIds,
        Set<String> status,
        Set<String> type
    );

    /**
     * @description It is used for getting WorkOrders and related account fields by the passed Ids.
     * @param idSet
     * @return List<WorkOrder>
     */
    List<WorkOrder> selectManageableById(Set<Id> idSet);

    /**
     * @description It is used for getting Child WorkOrders and parent WorkOrders for Drive
     * @param recordId
     * @return List<WorkOrder>
     */
    List<WorkOrder> selectParentAndChildWOsByWorkOrderIds(Id recordId);

    /**
     * @description It queries Marketplace WorkOrders which are not Dead and Onboarding Complete by accountIds.
     * @JIRA# LEM-7912
     * @param accountIds
     * @return List<WorkOrder>
     */
    List<WorkOrder> selectOpenMarketPlaceWorkOrdersByAccountIds(Set<Id> accountIds);

    /**
     * @description It queries Parent WorkOrders By Status, Type, SubTpe, OppotunityId and Batch Id
     * @JIRA# LEM-9052
     * @param status
     * @param type
     * @param subType
     * @param oppIds
     * @param batchIds
     * @return List<WorkOrder>
     */
    List<WorkOrder> selectWorkOrderByStatusAndTypeAndSubTypeAndOppIDAndBatchID(
        Set<String> status,
        Set<String> type,
        Set<String> subType,
        Set<Id> oppIds,
        Set<String> batchIds
    );

    /**
     * @description Retrieves details from the current WorkOrder related to the inputted Account.
     * @param accountId
     * @return List<WorkOrder>
     **/
    List<WorkOrder> selectWorkOrderDetailsForAccount(Id accountId);

    /**
     * @description It queries Withholding parent Work Orders by the passed Contract Ids.
     * @param contractIds
     * @return List<WorkOrder>
     */
    List<WorkOrder> selectWithholdingParentWorkOrdersByContractIds(Set<Id> contractIds);

    /**
     * @description It queries Work Orders by the passed WorkOrderId.
     * @param workOrderId
     * @return List<WorkOrder>
     */
    List<WorkOrder> selectWorkOrdersByParentId(Id workOrderId);

    /**
     * @description It queries Parent Work Orders by the passed StoreAccountId.
     * @param storeAccountIds
     * @return List<WorkOrder>
     */
    List<WorkOrder> selectWorkOrdersWithParentWorkOrderIdByAccountIds(Set<Id> storeAccountIds);

    /**
     * @description select Market place and Drive Work Order in Allowed Status by Accounts
     * @author rishab.goyal | 03-20-2024
     * @param accountIds
     * @param ;
     * @return List<WorkOrder>
     **/
    List<WorkOrder> selectMarketplaceAndDriveWorkOrderInAllowedStatusByAccounts(Set<Id> accountIds);

    /**
     * @description It queries child WOs using its associated Account Ids
     * @param accountIds
     * @return List<WorkOrder>
     */
    List<WorkOrder> selectInProgressWorkOrdersWithParentDetailsByAccountIds(Set<Id> accountIds);

    /**
     * @description It queries child WOs using its parent Work Order Id & by order protocol
     * @param parentWorkOrderId
     * @param orderProtocol
     * @return List<WorkOrder>
     */
    List<WorkOrder> selectAllChildWosByOrderProtocol(Id parentWorkOrderId, String orderProtocol);

    /**
     * @description It queries child Work Orders along with Work Step details
     * based on Store Account Ids and Work Step Types.
     * @param accountIds
     * @param workStepTypes
     * @return List<WorkOrder>
     */
    List<WorkOrder> selectMarketplaceWorkOrdersAndWorkStepsByAccountIdsAndWorkStepTypes(
        Set<Id> accountIds,
        Set<String> workStepTypes
    );

    /**
     * @description It queries Parent Work Orders by passed Unique Identifiers
     * @param uuids
     * @return List<WorkOrder>
     */
    List<WorkOrder> selectParentWorkOrdersByUniqueIdentifiers(set<String> uuids);

    /**
     * @description It queries Work Orders using passed Account Ids where the Account Segment 'SMB'.
     * @param accountIds
     * @return List<WorkOrder>
     */
    List<WorkOrder> selectWorkOrdersBySegment(Set<Id> accountIds);

    /**
     * @description It queries Work Orders along with Work Step details
     * based on passed Account Ids, Work Order Types and Work Step Types.
     * @param accountIds
     * @param workOrderTypes
     * @param workStepTypes
     * @return List<WorkOrder>
     */
    List<WorkOrder> selectWorkOrdersAndWorkStepsByAccountIdsAndTypesAndWorkStepTypes(
        Set<Id> accountIds,
        Set<String> workOrderTypes,
        Set<String> workStepTypes
    );
    
    /**
     * @description It queries Parent and Child Work Orders with Work Plans
     * by Business Account Ids.
     * @JIRA# LEM-23780
     * @param businessAccountIds
     * @return List<WorkOrder> 
     */
    List<WorkOrder> selectParentAndChildWorkOrdersWithWorkPlansByBusinessAccountIds(Set<Id> businessAccountIds);

    /**
     * @description It is used to select WorkOrders by Originating Work Order.
     * @JIRA# LEM-18140
     * @param workOrderIds
     * @return List<WorkOrder>
     */
    List<WorkOrder> selectMarketingKitWorkOrdersByOriginatingWorkOrder(Set<Id> workOrderIds);

    /**
     * @description It queries parent Work Orders by passed Bulk Order Ketset.
     * @JIRA# LEM-15978
     * @param bulkParentOrderKeySet
     * @return List<WorkOrder>
     */
    List<WorkOrder> selectWorkOrdersByBulkParentOrderKeys(Set<String> bulkParentOrderKeySet);

    /**
     * @description It is used to query Work Orders eligible for Business Reference creation by the passed Acccount Ids.
     * @JIRA# LEM-20169
     * @param accountIds
     * @return List<WorkOrder>
     */
    List<WorkOrder> selectBusinessReferenceCreationEligibleWorkOrdersByAccountIds(
        Set<Id> accountIds
    );
}