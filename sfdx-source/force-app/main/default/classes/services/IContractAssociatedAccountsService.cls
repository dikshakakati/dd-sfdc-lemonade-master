/**
 * @description Interface for Service Class of the ContractAssociatedAccount object
 */
public interface IContractAssociatedAccountsService {
    // /**
    //  * @description Generate the appropriate number of Contract_Associated_Accounts__c for inputted Contract
    //  * @param accountIds - Set<Id> to register with the Contract
    //  * @param contractId - SFDC Record ID of Contract
    //  **/
    // void generateContractAssociations(Set<Id> accountIds, Id contractId);

    /**
     * @description Public method to call and reset/generate the Contract_Associated_Accounts__c for a given Contract for Existing and New stores
     * @param associatedAccountsWrapperList
     * @param ccpApplied
     * @param ccpAnsoFlow
     **/
    void generateContractAssociationsWithGroupForExistingAndNewStores(
        List<AssociatedAccountsWrapper> associatedAccountsWrapperList, Boolean ccpApplied, String ccpAnsoFlow
    );
}