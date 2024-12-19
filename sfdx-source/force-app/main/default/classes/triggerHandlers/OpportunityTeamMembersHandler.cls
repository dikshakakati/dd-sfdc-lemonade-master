/**
 * @author Deloitte
 * @date 07/03/2024
 * @description OpportunityTeamMember Trigger handler class
 */
public class OpportunityTeamMembersHandler extends ApplicationDomainHandler {
    /**
     * @description Constructor class implements fflib_SObjectDomain class
     * @param opportunityTeamMembers - OpportunityTeamMember Record List
     */
    public OpportunityTeamMembersHandler(List<OpportunityTeamMember> opportunityTeamMembers) {
        super(opportunityTeamMembers);
        setContextBypass(OpportunityTeamMember.SObjectType, OpportunityTeamMembersHandler.class);
    }

    /**
     * @description Constructor class implements fflib_SObjectDomain class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description This method implements construct method of fflib_SObjectDomain.IConstructable
         * @param opportunityTeamMembers - List of Opportunity Team Members
         * @return OpportunityTeamMembersHandler
         */
        public fflib_SObjectDomain construct(List<SObject> opportunityTeamMembers) {
            return new OpportunityTeamMembersHandler(opportunityTeamMembers);
        }
    }

    /**
     * @description Called to perform after insert processing
     */
    public override void onAfterInsert() {
        OpportunityTeamMembers.newInstance(this.records)
            .updateSDROpportunityOwnerOnOpportunity(new Map<Id, OpportunityTeamMember>{});
    }

    /**
     * @description Called to perform on after update processing
     * @param existingRecords - The map of old requests
     */
    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        List<OpportunityTeamMember> changedTeamMemberRoleMember = new List<OpportunityTeamMember>(
            (List<OpportunityTeamMember>) getChangedRecords(
                new Set<SObjectField>{ OpportunityTeamMember.TeamMemberRole }
            )
        );
        OpportunityTeamMembers.newInstance(changedTeamMemberRoleMember)
            .updateSDROpportunityOwnerOnOpportunity(
                (Map<Id, OpportunityTeamMember>) existingRecords
            );
    }
}