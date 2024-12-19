/**
 * @author Deloitte
 * @date 04/04/2024
 * @description Selector class to query Onboarding & Activations binding.
 */
public inherited sharing class OnboardingActivationEventBindingSelector extends fflib_SObjectSelector implements IOnboardActivationEventBindingSelector {
    /**
     * @description default constructor for the class
     * @return IOnboardActivationEventBindingSelector - interface of IOnboardActivationEventBindingSelector
     */
    public static IOnboardActivationEventBindingSelector newInstance() {
        return (IOnboardActivationEventBindingSelector) Application.Selector.newInstance(
            Onboarding_Events_Binding__mdt.SObjectType
        );
    }

    /**
     * @description override default getSObjectType method
     * @return SObjectType - object type of metadata
     */
    public Schema.SObjectType getSObjectType() {
        return Onboarding_Events_Binding__mdt.SObjectType;
    }

    /**
     * @description This method is for getting all field values for Onboarding_Events_Binding__mdt
     * @return List<Onboarding_Events_Binding__mdt> - List of metadata records with values
     */
    public List<Onboarding_Events_Binding__mdt> getAllValues() {
        return Onboarding_Events_Binding__mdt.getAll().values();
    }

    /**
     * @description This method is for getting the fields of Onboarding_Events_Binding__mdt
     * @return List<Schema.SObjectField>- Onboarding_Events_Binding__mdt fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Onboarding_Events_Binding__mdt.Topic__c,
            Onboarding_Events_Binding__mdt.Class_Name__c,
            Onboarding_Events_Binding__mdt.Scope_Size__c
        };
    }
}