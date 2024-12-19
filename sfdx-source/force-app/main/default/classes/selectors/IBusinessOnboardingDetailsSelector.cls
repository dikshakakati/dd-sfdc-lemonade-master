/**
 * @author Deloitte
 * @date 07/03/2024
 * @description Interface for Business Onboarding Details Selector.
 */
public interface IBusinessOnboardingDetailsSelector extends fflib_ISObjectSelector {
    /**
     * @description It is for getting the fields on Business_Onboarding_Detail__c.
     * @return List<Schema.SObjectField>
     */
    List<Schema.SObjectField> getSObjectFieldList();
}