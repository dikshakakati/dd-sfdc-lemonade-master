/**
 * @description This is the service interface for the accounts provisioning service
 */
public interface IAccountsProvisioningService {
    /**
     * @description Generic method to provision Marketplace accounts by creation method
     * @param accountIdsByCreationMethod
     */
    void provisionMarketplaceAccountsByCreationMethod(
        Map<String, Set<Id>> accountIdsByCreationMethod
    );

    /**
     * @description Generic method for provisioning the amendments through existing Xrefs.
     * @param accountIdsByCreationMethod
     * @param isAmendment
     */
    void provisionMarketplaceAccountsByCreationMethod(
        Map<String, Set<Id>> accountIdsByCreationMethod,
        Boolean isAmendment
    );
}