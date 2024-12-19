/**
 * @author Deloitte
 * @date 07/03/2024
 * @description Interface to add domain class methods of OpportunityTeamMember Object
 */
public interface IOpportunityTeamMembers extends fflib_ISObjects {
    /**
     * @description It updates SDR Opportunity Owner on Opportunity when opportunity team member is added with Sales Development Rep role.
     * @param existingRecords
     */
    void updateSDROpportunityOwnerOnOpportunity(Map<Id, OpportunityTeamMember> existingRecords);
}