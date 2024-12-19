/**
 * @author atg
 * @date   05/23/2022
 * @description This is the service interface Actiavtion Order related logic
 */
public interface IActivationOrdersService {
    /**
     * @description create Activation Orders and Activation Order Products LEM-635
     * @param agreements
     * @param appliedArp
     */
    void createActivationOrdersAndProducts(List<Agreement__c> agreements, Boolean appliedArp);

    /**
     * @description create Activation Orders and Activation Order Products on Contract Amendment LEM-2589
     * @param amendedContractIds
     */
    void createActivationOrdersAndProductsOnContractAmendment(Set<Id> amendedContractIds);

    /**
     * @description create Activation Orders and Activation Order Products on Integrated Franchise LEM-2673
     * @param accountIdContractIdMap
     * @param uow
     * @return Boolean uowCommitted
     */
    boolean createActivationOrdersAndProductsForIntegratedFranchise(
        Map<String, Id> accountIdContractIdMap,
        fflib_ISObjectUnitOfWork uow
    );

    /**
     * @description Activate Orders Products on Xref success
     * @param xrefList
     */
    void activateOrderProductsOnXrefSuccess(List<Xref__c> xrefList);

    /**
     * @description Activate Orders Products on Business Reference success(Drive Only)
     * @param businessReferenceList
     */
    void activateOrderProductsOnBusinessReferenceSuccess(
        List<Business_Reference__c> businessReferenceList
    );

    /**
     * @description Update Merchant Services Based on Entitlements from Agreements
     * @param agreements
     */
    void updateMerchantServicesbasedOnEntitlements(List<Agreement__c> agreements);
}