/**
 * @author Deloitte
 * @date 11/08/2022
 * @description Accounts Provisioning for Drive Service class
 */
public inherited sharing class AccountsProvisioningDriveService {
    /**
     * @description Generic method to provision Drive accounts by creation method
     * @param accountIdsByCreationMethod
     */
    public static void provisionDriveAccountsByCreationMethod(
        Map<String, Set<Id>> accountIdsByCreationMethod
    ) {
        service().provisionDriveAccountsByCreationMethod(accountIdsByCreationMethod);
    }

    private static IAccountsProvisioningDriveService service() {
        return (IAccountsProvisioningDriveService) Application.Service.newInstance(
            IAccountsProvisioningDriveService.class
        );
    }
}