/**
 * @author Deloitte
 * @date 16/05/2022
 * @description Trigger on Notifier Platform Event.
 */
trigger NotifierEvents on Notifier__e(after insert) {
    fflib_SObjectDomain.triggerHandler(NotifierEventsHandler.class);
}