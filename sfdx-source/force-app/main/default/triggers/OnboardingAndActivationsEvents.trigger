/**
 * @author Deloitte
 * @date 03/26/2024
 * @description Trigger on Onboarding & Activation Platform Event
 */
trigger OnboardingAndActivationsEvents on Onboarding_Activation__e(after insert) {
    fflib_SObjectDomain.triggerHandler(OnboardingActivationEventsHandler.class);
}