/**
 * @author Deloitte
 * @date 04/08/2024
 * @description Interface for Activation Checklist Validation Service.
 */
public interface IActivationChecklistValidationService {
    /**
     * @description This method is used validate the Store Account.
     * @param storeAccounts
     * @param mintStoreAccounts
     * @param activationChecklistValidations
     */
    void validateStoreAccount(
        List<Account> storeAccounts,
        Map<Id, ActivationChecklistWrapper> mintStoreAccounts,
        List<Activation_Checklist_Validation__mdt> activationChecklistValidations
    );
}