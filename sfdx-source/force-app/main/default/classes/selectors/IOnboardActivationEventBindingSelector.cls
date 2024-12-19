/**
 * @author Deloitte
 * @date 05/03/2024
 * @description Selector Interface for Onbaording Activations Event Binding Selector.
 */
public interface IOnboardActivationEventBindingSelector extends fflib_ISObjectSelector {
    /**
     * @description Method fetches all Notifier Event Binding records
     * @return List<Onboarding_Events_Binding__mdt> - returns list of metadata records
     */
    List<Onboarding_Events_Binding__mdt> getAllValues();

    /**
     * @description This method is for getting the fields on Onboarding_Events_Binding__mdt
     * @return List<Schema.SObjectField>- Onboarding_Events_Binding__mdt fields
     */
    List<Schema.SObjectField> getSObjectFieldList();
}