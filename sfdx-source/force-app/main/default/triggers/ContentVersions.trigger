/**
 * @author Deloitte
 * @date 07/05/2024
 * @description Trigger on Content Version object.
 */
trigger ContentVersions on ContentVersion(after insert, before insert) {
    fflib_SObjectDomain.triggerHandler(ContentVersionsHandler.class);
}