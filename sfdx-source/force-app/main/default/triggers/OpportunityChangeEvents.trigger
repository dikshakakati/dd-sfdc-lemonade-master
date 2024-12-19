/**
 * @author Deloitte
 * @date 06/16/2022
 * @description Trigger for Opportunity Change Data Capture Event.
 */
trigger OpportunityChangeEvents on OpportunityChangeEvent(after insert) {
    fflib_SObjectDomain.triggerHandler(OpportunityChangeEventsHandler.class);
}
