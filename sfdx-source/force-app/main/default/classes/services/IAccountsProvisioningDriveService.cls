/**
 * @author Deloitte
 * @date 11/08/2022
 * @description Accounts Provisioning for Drive Service class
 */
public interface IAccountsProvisioningDriveService {
    /**
     * @description Generic method to provision Drive accounts by creation method
     * @param accountIdsByCreationMethod
     */
    void provisionDriveAccountsByCreationMethod(Map<String, Set<Id>> accountIdsByCreationMethod);
}