/**
 * @description Trigger on Provisioning Platform Event
 */
trigger ProvisioningEvents on Provisioning_Event__e(after insert) {
    fflib_SObjectDomain.triggerHandler(ProvisioningEventsHandler.class);
}