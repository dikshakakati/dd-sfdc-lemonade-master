/**
 * @author Deloitte
 * @date 11/24/2022
 * @description Service implementation class for logic related to processing Work Orders initiated through Nintex.
 */
public inherited sharing class NintexWorkOrdersProcessorServiceImpl implements INintexWorkOrdersProcessorService {
    private Set<Id> opportunityIds;

    /**
     * @description Default constructor to instantiate variables.
     */
    public NintexWorkOrdersProcessorServiceImpl() {
        this.opportunityIds = new Set<Id>();
    }

    /**
     * @description It initiates child Work Orders creation using the passed store Accounts.
     * @JIRA# LEM-3658
     * @param franchiseAccountIdToOpportunityId
     * @param storeAccounts
     * @return Set<Id>
     */
    public Set<Id> initiateChildWorkOrdersCreation(
        Map<Id, Id> franchiseAccountIdToOpportunityId,
        List<Account> storeAccounts
    ) {
        Map<Id, WorkOrder> franchiseParentToParentWorkOrder = new Map<Id, WorkOrder>();
        Map<Id, WorkOrder> workOrders = new Map<Id, WorkOrder>();
        Map<Id, Account> filteredStoreAccounts = new Map<Id, Account>(storeAccounts);
        WorkOrder parentWorkOrder;
        collectOpportunityIdsByStoreAccounts(franchiseAccountIdToOpportunityId, storeAccounts);
        if (opportunityIds.isEmpty()) {
            return workOrders.keySet();
        }
        for (
            WorkOrder eachParentWorkOrder : WorkOrdersSelector.newInstance()
                .selectParentWorkOrdersByOpportunityIds(opportunityIds)
        ) {
            workOrders.put(eachParentWorkOrder.Id, eachParentWorkOrder);
            franchiseParentToParentWorkOrder.put(
                eachParentWorkOrder.AccountId,
                eachParentWorkOrder
            );
        }
        // Remove store Accounts with existing child Work Order associated with parent Work Order
        for (
            WorkOrder eachChildWorkOrder : WorkOrdersSelector.newInstance()
                .selectByParentWorkOrderIds(workOrders.keySet())
        ) {
            parentWorkOrder = franchiseParentToParentWorkOrder.get(
                eachChildWorkOrder.Account.Franchise_Parent__c
            );
            if (
                eachChildWorkOrder.ParentWorkOrderId == parentWorkOrder?.Id &&
                filteredStoreAccounts.containsKey(eachChildWorkOrder.AccountId)
            ) {
                filteredStoreAccounts.remove(eachChildWorkOrder.AccountId);
            }
        }
        WorkOrdersCreationService.createChildWorkOrdersByFranchiseParents(
            franchiseParentToParentWorkOrder,
            filteredStoreAccounts.values()
        );
        return workOrders.keySet();
    }

    /**
     * @description It collects Opportunitiy Ids from the map of franchise Account to Opportunity Id
     * by passing the storeAccounts.
     * @param franchiseAccountIdToOpportunityId
     * @param storeAccounts
     */
    private void collectOpportunityIdsByStoreAccounts(
        Map<Id, Id> franchiseAccountIdToOpportunityId,
        List<Account> storeAccounts
    ) {
        for (Account eachStoreAccount : storeAccounts) {
            if (
                franchiseAccountIdToOpportunityId.containsKey(eachStoreAccount.Franchise_Parent__c)
            ) {
                opportunityIds.add(
                    franchiseAccountIdToOpportunityId.get(eachStoreAccount.Franchise_Parent__c)
                );
            }
        }
    }
}