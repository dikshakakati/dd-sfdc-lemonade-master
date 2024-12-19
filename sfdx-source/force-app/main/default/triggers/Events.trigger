/**
 * @author Deloitte
 * @date 02/05/2024
 * @description Trigger on Event Object
 */
trigger Events on Event  (after insert, after update, after delete) {
    fflib_SObjectDomain.triggerHandler(EventsHandler.class);
}