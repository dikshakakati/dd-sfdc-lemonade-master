/**
 * @author BizApps
 * @date 04/25/2023
 * @description Service Class for ContractAssociatedAccount Object
 */
public with sharing class ContractAssociatedAccountsService {
    /**
     * @description It creates instance of ContractAssociatedAccountsServiceImpl class.
     * @return IContractAssociatedAccountsService - return instance of ContractAssociatedAccountsServiceImpl
     */
    private static IContractAssociatedAccountsService service() {
        return (IContractAssociatedAccountsService) Application.SERVICE.newInstance(
            IContractAssociatedAccountsService.class
        );
    }

    // /**
    //  * @description Generate the appropriate number of Contract_Associated_Accounts__c for inputted Contract
    //  * @param accountIds - Set<Id> to register with Contract
    //  * @param contractId - SFDC Record ID of Contract
    //  **/
    // public static void generateContractAssociations(Set<Id> accountIds, Id contractId) {
    //     service().generateContractAssociations(accountIds, contractId);
    // }

    /**
     * @description Public method to call and reset/generate the Contract_Associated_Accounts__c for a given Contract for Existing and New stores
     * @param associatedAccountsWrapperList
     * @param ccpApplied
     * @param ccpAnsoFlow
     **/
    public static void generateContractAssociationsWithGroupForExistingAndNewStores(
        List<AssociatedAccountsWrapper> associatedAccountsWrapperList, Boolean ccpApplied, String ccpAnsoFlow
    ) {
        service()
            .generateContractAssociationsWithGroupForExistingAndNewStores(
                associatedAccountsWrapperList, ccpApplied, ccpAnsoFlow
            );
    }
}