/**
 * @author BizApps
 * @date 05/2023
 * @description Interface to add ContractAssociatedAccounts domain class methods
 */
public interface IContractAssociatedAccounts extends fflib_ISObjects {
    /**
     * @description getNewAssociatedAccountIds from Contract_Associated_Accounts__c
     * @param
     * @return Map<Id,Set<String>>
     */
    Map<Id, Set<String>> getNewAssociatedAccountIds();

    /**
     * @description Get Contract ID by Associated AccountIds with no Active Agreements
     * @param contarctIdByAssociatedAccountIds
     * @return Map<Id,Set<String>>
     */
    Map<Id, Set<String>> getAssociatedAccountIdsWithNoActiveAgreements(
        Map<Id, Set<String>> contarctIdByAssociatedAccountIds
    );

    /**
     * @description Get Contract ID by Associated AccountIds with no Active Agreements
     * @param contarctIdByAssociatedAccountIds
     * @return Map<Id, Map<Id, String>>
     */
    Map<Id, Map<Id, String>> getNewAssociatedAccountIdWithGroupIdAndSerializedEntitlements(
        Map<Id, Set<String>> contarctIdByAssociatedAccountIds
    );

    /**
     * @description getExistingAssociatedAccountIdsFromCaa from Contract_Associated_Accounts__c
     * @param
     * @return Map<Id,Set<String>>
     */
    Map<Id, Set<String>> getExistingAssociatedAccountIdsFromCaa();
}