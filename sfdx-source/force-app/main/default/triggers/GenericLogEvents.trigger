/**
 * @description Trigger on Generic Log Platform Event
 */
trigger GenericLogEvents on Generic_Log_Event__e (after insert) {
    fflib_SObjectDomain.triggerHandler(GenericLogEventsHandler.class);
}