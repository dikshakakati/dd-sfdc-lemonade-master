/**
 * @author Deloitte
 * @date 11/24/2022
 * @description Interface of service class for logic related to processing Work Orders initiated through Nintex.
 */
public interface INintexWorkOrdersProcessorService {
    /**
     * @description It initiates child Work Orders creation using the passed store Accounts.
     * @param franchiseAccountIdToOpportunityId
     * @param storeAccounts
     * @return Set<Id>
     */
    Set<Id> initiateChildWorkOrdersCreation(
        Map<Id, Id> franchiseAccountIdToOpportunityId,
        List<Account> storeAccounts
    );
}