/**
 * @author atg
 * @date   08/09/2022
 * @description This is the service interface Activation Order Creation logic
 */
@SuppressWarnings('PMD.ExcessiveParameterList')
public interface IActivationOrderCreationService {
    /**
     * @description Creates Activation Orders, Activation OrderItems, and Services for all Accounts in the Map.
     * @param accountAgreementStringContractIdMap
     * @param accountIdToFranchiseParentIdMap
     * @param accountIdToDeselectedServicesMap
     * @param accountIdToAgreedToServicesMap
     * @param amendedAccountIdToAutoProvisionValueMap
     * @param accountIdsToSelectedPckgIdToDeselectedProdListMap
     * @param uow
     * @return Boolean work committed
     */
    Boolean createActivationOrdersForAccountContractMap(
        Map<String, Id> accountAgreementStringContractIdMap,
        Map<Id, Id> accountIdToFranchiseParentIdMap,
        Map<Id, Map<String, String>> accountIdToDeselectedServicesMap,
        Map<Id, String> accountIdToAgreedToServicesMap,
        Map<Id, Boolean> amendedAccountIdToAutoProvisionValueMap,
        Map<Id, Map<String, List<String>>> accountIdsToSelectedPckgIdToDeselectedProdListMap,
        fflib_ISObjectUnitOfWork uow
    );
}