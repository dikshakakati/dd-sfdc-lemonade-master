/**
 * @author Deloitte
 * @date 07/06/2024
 * @description Interface to add selector class methods
 */
public interface IAccountPlansSelector extends fflib_ISObjectSelector {
    /**
     * @description This method id for getting object type
     * @param idSet
     * @return Map<Id, Account> - Map of Accounts
     */
    List<Account_Plan__c> selectById(Set<Id> idSet);

    /**
     * @description This method is used for getting active Account Plans by passing Account Ids.
     * @param accountsWithActiveAccountPlans
     * @return List<Account>
     */
    List<Account_Plan__c> selectActiveAccountPlanByAccounts(Set<Id> accountsWithActiveAccountPlans);
}