/**
 * @author Deloitte
 * @date 11/24/2022
 * @description Service class for logic related to processing Work Orders initiated through Nintex.
 */
public inherited sharing class NintexWorkOrdersProcessorService {
    /**
     * @description It initiates child Work Orders creation using the passed store Accounts.
     * @param franchiseAccountIdToOpportunityId
     * @param storeAccounts
     * @return Set<Id>
     */
    public static Set<Id> initiateChildWorkOrdersCreation(
        Map<Id, Id> franchiseAccountIdToOpportunityId,
        List<Account> storeAccounts
    ) {
        return service()
            .initiateChildWorkOrdersCreation(franchiseAccountIdToOpportunityId, storeAccounts);
    }

    /**
     * @description It creates instance of NintexWorkOrdersProcessorServiceImpl class.
     * @return INintexWorkOrdersProcessorService - instance of NintexWorkOrdersProcessorServiceImpl
     */
    private static INintexWorkOrdersProcessorService service() {
        return (INintexWorkOrdersProcessorService) Application.Service.newInstance(
            INintexWorkOrdersProcessorService.class
        );
    }
}