/**
 * @author BizApps
 * @description Interface to add Selector class methods
 */
public interface IContractAssociatedAccountsSelector extends fflib_ISObjectSelector {
    /**
     * @description This method is for getting object type
     * @param idSet
     * @return List<Contract_Associated_Accounts__c> - List of Contract_Associated_Accounts__c
     */
    List<Contract_Associated_Accounts__c> selectById(Set<Id> idSet);

    /**
     * @description Retrieves all Contract_Associated_Accounts__c for an inputted Contract
     * @param contractId - Id to filter by in Contract__c field
     * @return List<Contract_Associated_Accounts__c>
    **/
    List<Contract_Associated_Accounts__c> selectByContractId(Id contractId);

    /**
     * @description Retrieves all Contract_Associated_Accounts__c for an inputted Set of Contracts
     * @param contractIds - Set<Id> to filter by in Contract__c field
     * @return List<Contract_Associated_Accounts__c>
    **/
    List<Contract_Associated_Accounts__c> selectByContractIds(Set<Id> contractIds);

    /**
     * @description Retrieves all Contract_Associated_Accounts__c for the contracts that needs to be processed in bacth modeß
     * @return Database.QueryLocator
    **/
    Database.QueryLocator selectByBatchProcessEnabledAndStatus();

     /**
     * @description Retrieves all Contract_Associated_Accounts__c for the contracts that needs to be processed in bacth modeß for an inputted Set of ContractAssociatedAccount IDs
     * @param conAssociatedAccountIds - Set<Id> to filter by Id
     * @return Database.QueryLocator
    **/
    Database.QueryLocator selectByBatchProcessEnabledAndStatusIds(Set<Id> conAssociatedAccountIds);
}