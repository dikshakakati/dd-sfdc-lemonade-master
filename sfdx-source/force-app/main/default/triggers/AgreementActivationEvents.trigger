/**
 * @description Trigger on Agreement Activation Event
 */
trigger AgreementActivationEvents on Agreement_Activation_Event__e (after insert) {
    fflib_SObjectDomain.triggerHandler(AgreementActivationEventsHandler.class);
}