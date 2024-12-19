/**
 * @author atg
 * @date   09/08/2022
 * @description This is the service class for Activation Order Creation logic
 */
public inherited sharing class ActivationOrderCreationService {
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
    @SuppressWarnings('PMD.ExcessiveParameterList')
    public static Boolean createActivationOrdersForAccountContractMap(
        Map<String, Id> accountAgreementStringContractIdMap,
        Map<Id, Id> accountIdToFranchiseParentIdMap,
        Map<Id, Map<String, String>> accountIdToDeselectedServicesMap,
        Map<Id, String> accountIdToAgreedToServicesMap,
        Map<Id, Boolean> amendedAccountIdToAutoProvisionValueMap,
        Map<Id, Map<String, List<String>>> accountIdsToSelectedPckgIdToDeselectedProdListMap,
        fflib_ISObjectUnitOfWork uow
    ) {
        return service()
            .createActivationOrdersForAccountContractMap(
                accountAgreementStringContractIdMap,
                accountIdToFranchiseParentIdMap,
                accountIdToDeselectedServicesMap,
                accountIdToAgreedToServicesMap,
                amendedAccountIdToAutoProvisionValueMap,
                accountIdsToSelectedPckgIdToDeselectedProdListMap,
                uow
            );
    }

    private static IActivationOrderCreationService service() {
        return (IActivationOrderCreationService) Application.Service.newInstance(
            IActivationOrderCreationService.class
        );
    }
}