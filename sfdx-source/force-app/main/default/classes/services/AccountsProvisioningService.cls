/**
 * @description This is the service class for Account provisioning logic
 */
public inherited sharing class AccountsProvisioningService {
    /**
     * @description Generic method to provision Marketplace accounts by creation method
     * @param accountIdsByCreationMethod
     */
    public static void provisionMarketplaceAccountsByCreationMethod(
        Map<String, Set<Id>> accountIdsByCreationMethod
    ) {
        service().provisionMarketplaceAccountsByCreationMethod(accountIdsByCreationMethod);
    }

    /**
     * @description Generic method for provisioning the amendments through existing Xrefs.
     * @param accountIdsByCreationMethod
     * @param isAmendment
     */
    public static void provisionMarketplaceAccountsByCreationMethod(
        Map<String, Set<Id>> accountIdsByCreationMethod,
        Boolean isAmendment
    ) {
        service()
            .provisionMarketplaceAccountsByCreationMethod(accountIdsByCreationMethod, isAmendment);
    }

    private static IAccountsProvisioningService service() {
        return (IAccountsProvisioningService) Application.Service.newInstance(
            IAccountsProvisioningService.class
        );
    }
}