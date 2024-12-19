/**
 * @author Deloitte
 * @date 07/03/2024
 * @description Selector class for Business Onboarding Details.
 */
public inherited sharing class BusinessOnboardingDetailsSelector extends fflib_SObjectSelector implements IBusinessOnboardingDetailsSelector {
    /**
     * @description Default constructor for the class.
     * @return IBusinessOnboardingDetailsSelector
     */
    public static IBusinessOnboardingDetailsSelector newInstance() {
        return (IBusinessOnboardingDetailsSelector) Application.Selector.newInstance(
            Business_Onboarding_Detail__c.SObjectType
        );
    }

    /**
     * @description It is used for getting the object type.
     * @return SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Business_Onboarding_Detail__c.SObjectType;
    }

    /**
     * @description It is for getting the fields on Business_Onboarding_Detail__c.
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Business_Onboarding_Detail__c.Activated_Centrally_AC__c,
            Business_Onboarding_Detail__c.Mx_Requested_Photoshoot__c,
            Business_Onboarding_Detail__c.Order_Protocol__c,
            Business_Onboarding_Detail__c.Photoshoot_Date__c,
            Business_Onboarding_Detail__c.Photoshoot_Time__c,
            Business_Onboarding_Detail__c.Proposed_Date_of_Activation__c
        };
    }
}