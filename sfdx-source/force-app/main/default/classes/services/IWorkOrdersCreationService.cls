/**
 * @author Deloitte
 * @date 06/17/2022
 * @description Interface of service class for Work Orders creation related logic.
 */
public interface IWorkOrdersCreationService {
    /**
     * @description It is used to create child Work Orders on the passed parent Work Order
     * using the passed store Accounts.
     * @param parentWorkOrder
     * @param verifiedStoreAccounts
     */
    void createChildWorkOrdersOnStoreAccounts(
        WorkOrder parentWorkOrder,
        List<Account> verifiedStoreAccounts
    );

    /**
     * @description It is used to handle and route the published OnboardingActivationsEvents.
     * @param onboardingActivationsEvents List of platform events with payload.
     */
    void handleOnboardingActivationsEvents(
        List<Onboarding_Activation__e> onboardingActivationsEvents
    );

    /**
     * @description It is used to create child Work Orders by franchise parent associated with
     * the passed store Accounts.
     * @param franchiseParentToParentWorkOrder
     * @param storeAccounts
     */
    void createChildWorkOrdersByFranchiseParents(
        Map<Id, WorkOrder> franchiseParentToParentWorkOrder,
        List<Account> storeAccounts
    );

    /**
     * @description It is entry point to create Work Orders according to matching criteria.
     * @param orderItemIds
     * @param isManagePricingProcess
     */
    void createWorkOrders(Set<Id> orderItemIds, Boolean isManagePricingProcess);

    /**
     * @description create child workorder for the given store Id
     * to be related to the given parent work order id
     * @param storeAccountIdToParentWOIds
     */
    void createChildWorkOrdersOnStoreAccounts(Map<Id, Set<Id>> storeAccountIdToParentWOIds);
}