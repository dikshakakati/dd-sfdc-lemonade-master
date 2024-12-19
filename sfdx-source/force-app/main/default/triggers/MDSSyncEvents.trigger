/**
 * @author Doordash
 * @date 02/27/2024
 * @description Trigger on MDS Sync Event Platform Event object
 */
trigger MDSSyncEvents on MDS_Sync_Event__e (after insert) {
    fflib_SObjectDomain.triggerHandler(MDSSyncEventsHandler.class);
}