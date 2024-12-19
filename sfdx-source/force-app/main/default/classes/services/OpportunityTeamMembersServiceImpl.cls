/**
 * @author Deloitte
 * @date   14/04/2023
 * @description This is the service implementation class for OpportunityTeamMember
 */
public inherited sharing class OpportunityTeamMembersServiceImpl implements IOpportunityTeamMembersService {
    private static final String POD_MANAGER = 'Pod Manager';
    private static final String TEAM_LEAD = 'Team Lead';
    private static final String ACCESS_EDIT = 'Edit';
    /**
     * @description LEM-4974 It is used to create opportunity team members for new opportunities
     * and Opportunities where owner is changed
     * @param newOpportunities
     */
    public void createOpportunityTeamMembersForManagers(List<Opportunity> newOpportunities) {
        fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        OpportunityTeamMember newMember;
        OpportunityTeamMember superMember;
        Set<Id> ownerIds = new Set<Id>();

        for (Opportunity eachOpportunity : newOpportunities) {
            ownerIds.add(eachOpportunity.OwnerId);
        }

        Map<Id, User> userMap = new Map<Id, User>(
            UsersSelector.newInstance().selectUsersById(ownerIds)
        );

        for (Opportunity opp : newOpportunities) {
            if (opp.OwnerId != null && userMap.get(opp.OwnerId).ManagerId != null) {
                newMember = new OpportunityTeamMember();
                newMember.OpportunityId = opp.Id;
                newMember.UserId = userMap.get(opp.OwnerId).ManagerId;
                newMember.TeamMemberRole = POD_MANAGER;
                newMember.OpportunityAccessLevel = ACCESS_EDIT;
                uow.registerNew(newMember);
                if (userMap.get(opp.OwnerId).Manager.ManagerId != null) {
                    superMember = new OpportunityTeamMember();
                    superMember.OpportunityId = opp.Id;
                    superMember.UserId = userMap.get(opp.OwnerId).Manager.ManagerId;
                    superMember.TeamMemberRole = TEAM_LEAD;
                    superMember.OpportunityAccessLevel = ACCESS_EDIT;
                    uow.registerNew(superMember);
                }
            }
        }
        commitUnitOfWork(uow);
    }
    /**
     * @description Commits all the Units of Work created/updated/deleted.
     * @param unitOfWorkInstance
     */
    private static void commitUnitOfWork(fflib_ISObjectUnitOfWork unitOfWorkInstance) {
        try {
            unitOfWorkInstance.commitWork();
        } catch (Exception relationshipUnitOfWorkException) {
            Logger.publish(
                LogEntry.newExceptionLog(
                    relationshipUnitOfWorkException,
                    LogEntry.SeverityLevel.HIGH
                )
            );
        }
    }
}