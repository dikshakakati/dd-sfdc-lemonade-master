/**
 * @author Deloitte
 * @date 25/05/2022
 * @description Subscribe to BatchApexErrorEvent events.
 */
trigger BatchApexErrorEvents on BatchApexErrorEvent(after insert) {
    fflib_SObjectDomain.triggerHandler(BatchApexErrorEventHandler.class);

}