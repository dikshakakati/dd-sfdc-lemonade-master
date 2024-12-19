/**
 * @description Trigger on Opportunity Object
 * @author Deloitte
 * @date 22/02/2022
 */
trigger Opportunities on Opportunity(
    before insert,
    before update,
    after insert,
    after update,
    before delete,
    after delete,
    after undelete
) {
    fflib_SObjectDomain.triggerHandler(OpportunitiesHandler.class);
}