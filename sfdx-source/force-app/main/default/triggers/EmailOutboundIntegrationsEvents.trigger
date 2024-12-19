/**
 * @author Deloitte
 * @date 05/09/2024
 * @description Trigger on Email Outbound Integrations Platform Event.
 */
trigger EmailOutboundIntegrationsEvents on Email_Outbound_Integration__e(after insert) {
    fflib_SObjectDomain.triggerHandler(EmailOutboundIntegrationsEventsHandler.class);
}