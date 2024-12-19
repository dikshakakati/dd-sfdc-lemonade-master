/**
 * @description This is the service interface for the Change Of Ownership service
 */
public interface IChangeOfOwnershipService {
    /**
     * @description Generic method to provision Change of Ownership (COO)
     * @param cooProvisioningEventsList
     */
    void provisionCOO(List<Provisioning_Event__e> cooProvisioningEventsList);

    /**
     * @description Get the default Business Reference for the COO Accounts.
     * This is used by COO, and finds the Business Reference of the Buyer.
     * @param cooSoldAccounts
     * @return Map<Id, Business_Reference__c> sold account to default Business Reference Map
     */
    Map<Id, Business_Reference__c> getDefaultBusinessReferenceForCOO(Set<Id> cooSoldAccounts);

    /**
     * @description this method is used for processing the xref's via Async mode
     * @param xrefs
     */
    void processCooXrefsMarkedForAsyncProcess(Set<Id> xrefs);

    /**
     * @description this method is used for retriveing and processing the xref's based on get store api response
     * @param xrefsList
     */
    void getDriveStoreIdsForStores(List<Xref__c> xrefsList);
}