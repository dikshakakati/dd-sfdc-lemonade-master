/**
 * @author Deloitte
 * @date 04/08/2024
 * @description Service Class for Activation Checklist Validation.
 **/
public inherited sharing class ActivationCheckValidationsService {
    public static Set<Id> failedWorkStepIdsFromPayload = new Set<Id>();

    /**
     * @description This method is used to handle the published Onboarding and Activation Events events.
     * @param storeAccounts list of platform events with payload
     * @param mintStoreAccounts
     * @param activationChecklistValidations
     */
    public static void validateStoreAccount(
        List<Account> storeAccounts,
        Map<Id, ActivationChecklistWrapper> mintStoreAccounts,
        List<Activation_Checklist_Validation__mdt> activationChecklistValidations
    ) {
        service()
            .validateStoreAccount(storeAccounts, mintStoreAccounts, activationChecklistValidations);
    }

    private static IActivationChecklistValidationService service() {
        return (IActivationChecklistValidationService) Application.SERVICE.newInstance(
            IActivationChecklistValidationService.class
        );
    }
}