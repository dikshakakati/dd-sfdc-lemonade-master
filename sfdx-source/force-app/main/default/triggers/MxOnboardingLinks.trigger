/**
 * @author Deloitte
 * @date 01/07/2024
 * @description Trigger on Mx_Onboarding_Link__c object.
 */
trigger MxOnboardingLinks on Mx_Onboarding_Link__c(after insert, after update) {
    fflib_SObjectDomain.triggerHandler(MxOnboardingLinksHandler.class);
}