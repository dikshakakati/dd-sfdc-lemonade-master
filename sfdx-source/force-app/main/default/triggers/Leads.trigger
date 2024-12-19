/**
 * @author Deloitte
 * @date 03/27/2024
 * @description Trigger on Lead Object
 */
trigger Leads on Lead(before insert, after insert, before update, after update, after undelete) {
    fflib_SObjectDomain.triggerHandler(LeadsHandler.class);
}