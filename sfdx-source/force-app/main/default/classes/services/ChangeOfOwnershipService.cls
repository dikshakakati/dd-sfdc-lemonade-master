/**
 * @description This is the service class for Change Of Ownership logic
 */
public inherited sharing class ChangeOfOwnershipService {

    /**
     * @description Generic method to provision Change of Ownership (COO)
     * @param cooProvisioningEventsList
     */
    public static void provisionCOO(List<Provisioning_Event__e> cooProvisioningEventsList) {
        service().provisionCOO(cooProvisioningEventsList);
    }

    /**
     * @description Get the default Business Reference for the COO Accounts.
     * This is used by COO, and finds the Business Reference of the Buyer.
     * @param cooSoldAccounts
     * @return Map<Id, Business_Reference__c> sold account to default Business Reference Map
     */
    public static Map<Id, Business_Reference__c> getDefaultBusinessReferenceForCOO(Set<Id> cooSoldAccounts)
    {
        return service().getDefaultBusinessReferenceForCOO(cooSoldAccounts);
    }

    /**
     * @description this method is used for processing the xref's via Async mode
     * @param xrefs
     */
    public static void processCooXrefsMarkedForAsyncProcess(Set<Id> xrefs) {
        service().processCooXrefsMarkedForAsyncProcess(xrefs);
    }

    /**
     * @description this method is used for retriveing and processing the xref's based on get store api response
     * @param xrefsList
     */
    public static void getDriveStoreIdsForStores(List<Xref__c> xrefsList) {
        service().getDriveStoreIdsForStores(xrefsList);
    }

    private static IChangeOfOwnershipService service() {
        return (IChangeOfOwnershipService) Application.Service.newInstance(
            IChangeOfOwnershipService.class
        );
    }
}