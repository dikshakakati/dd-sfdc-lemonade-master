/**
 * @author Deloitte
 * @date 06/17/2022
 * @description Service class for Work Orders creation related logic.
 */
public inherited sharing class WorkOrdersCreationService implements IHandleOnboardingActivationsEvents {
    /**
     * @description It is used to create child Work Orders on the passed parent Work Order
     * using the passed store Accounts.
     * @JIRA# LEM-2013
     * @param parentWorkOrder
     * @param verifiedStoreAccounts
     */
    public static void createChildWorkOrdersOnStoreAccounts(
        WorkOrder parentWorkOrder,
        List<Account> verifiedStoreAccounts
    ) {
        service().createChildWorkOrdersOnStoreAccounts(parentWorkOrder, verifiedStoreAccounts);
    }

    /**
     * @description It allows NotifierEvents handler to pass events to the service class
     * corresponding to a topic.
     * @param onboardingActivationsEvents
     */
    public static void execute(List<Onboarding_Activation__e> onboardingActivationsEvents) {
        service().handleOnboardingActivationsEvents(onboardingActivationsEvents);
    }

    /**
     * @description create child workorder for the given store Id
     * to be related to the given parent work order id
     * @param storeAccountIdToParentWOIds
     */
    public static void createChildWorkOrdersOnStoreAccounts(
        Map<Id, Set<Id>> storeAccountIdToParentWOIds
    ) {
        service().createChildWorkOrdersOnStoreAccounts(storeAccountIdToParentWOIds);
    }

    /**
     * @description It is used to create child Work Orders by franchise parent associated with
     * the passed store Accounts.
     * @JIRA# LEM-3658
     * @param franchiseParentToParentWorkOrder
     * @param storeAccounts
     */
    public static void createChildWorkOrdersByFranchiseParents(
        Map<Id, WorkOrder> franchiseParentToParentWorkOrder,
        List<Account> storeAccounts
    ) {
        service()
            .createChildWorkOrdersByFranchiseParents(
                franchiseParentToParentWorkOrder,
                storeAccounts
            );
    }

    /**
     * @description It is entry point to create Work Orders according to matching criteria.
     * @param orderItemIds
     * @param isManagePricingProcess
     */
    public static void createWorkOrders(Set<Id> orderItemIds, Boolean isManagePricingProcess) {
        service().createWorkOrders(orderItemIds, isManagePricingProcess);
    }

    /**
     * @description It creates instance of WorkOrdersCreationServiceImpl class.
     * @return IWorkOrdersCreationService - return instance of WorkOrdersCreationServiceImpl
     */
    private static IWorkOrdersCreationService service() {
        return (IWorkOrdersCreationService) Application.SERVICE.newInstance(
            IWorkOrdersCreationService.class
        );
    }
}