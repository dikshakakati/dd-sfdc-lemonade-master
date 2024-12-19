/**
 * @author atg
 * @date   05/23/2022
 * @description This is the service class for Activation Orders related logic
 */
public inherited sharing class ActivationOrdersService {
    /**
     * @description create Activation Orders for Store Agreements
     * @param agreements
     * @param appliedArp
     */
    public static void createActivationOrdersAndProducts(
        List<Agreement__c> agreements,
        Boolean appliedArp
    ) {
        service().createActivationOrdersAndProducts(agreements, appliedArp);
    }

    /**
     * @description create Activation Orders and Activation Order Products on Contract Amendment LEM-2589
     * @param amendedContractIds
     */
    public static void createActivationOrdersAndProductsOnContractAmendment(
        Set<Id> amendedContractIds
    ) {
        service().createActivationOrdersAndProductsOnContractAmendment(amendedContractIds);
    }

    /**
     * @description create Activation Orders and Activation Order Products on Integrated Franchise LEM-2673
     * @param accountIdContractIdMap
     * @param uow
     * @return Boolean uowCommitted
     */
    public static boolean createActivationOrdersAndProductsForIntegratedFranchise(
        Map<String, Id> accountIdContractIdMap,
        fflib_ISObjectUnitOfWork uow
    ) {
        return service()
            .createActivationOrdersAndProductsForIntegratedFranchise(accountIdContractIdMap, uow);
    }

    /**
     * @description Activate Orders Products on Xref success
     * @param xrefList
     */
    public static void activateOrderProductsOnXrefSuccess(List<Xref__c> xrefList) {
        service().activateOrderProductsOnXrefSuccess(xrefList);
    }

    /**
     * @description Activate Orders Products on Business Reference success(Drive Only)
     * @param businessReferenceList
     */
    public static void activateOrderProductsOnBusinessReferenceSuccess(
        List<Business_Reference__c> businessReferenceList
    ) {
        service().activateOrderProductsOnBusinessReferenceSuccess(businessReferenceList);
    }

    /**
     * @description Update Merchant Services Based on Entitlements from Agreements
     * @param agreements
     */
    public static void updateMerchantServicesbasedOnEntitlements(List<Agreement__c> agreements) {
        service().updateMerchantServicesbasedOnEntitlements(agreements);
    }

    private static IActivationOrdersService service() {
        return (IActivationOrdersService) Application.Service.newInstance(
            IActivationOrdersService.class
        );
    }
}