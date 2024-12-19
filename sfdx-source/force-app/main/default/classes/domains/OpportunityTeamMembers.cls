/**
 * @author Deloitte
 * @date 07/03/2024
 * @description Domain class for OpportunityTeamMember object.
 */
public inherited sharing class OpportunityTeamMembers extends fflib_SObjects implements IOpportunityTeamMembers {
    private static final string SALES_DEVELOPMENT_REP = 'Sales Development Rep';
    private static final String LOG_DOMAIN = 'Sales';
    private static final String LOG_ERROR = 'Failed to update SDR Opportunity Owner on Opportunity when Opportunity Team Member is updated or inserted';
    fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    /**
     * @description This method is used to return the IOpportunityTeamMembers interface
     * @param opportunityTeamMembers
     * @return IOpportunityTeamMembers
     */
    public static IOpportunityTeamMembers newInstance(
        List<OpportunityTeamMember> opportunityTeamMembers
    ) {
        return (IOpportunityTeamMembers) Application.Domain.newInstance(opportunityTeamMembers);
    }

    /**
     * @description Default constructor for the class
     * @param sObjects
     */
    public OpportunityTeamMembers(List<OpportunityTeamMember> sObjects) {
        super(sObjects, Schema.OpportunityTeamMember.SObjectType);
    }

    /**
     * @description Holds a mock instance of the constructor inner class.
     * Setting this will provide the ability to test the records being injected into
     * the domain class when it is instantiated.
     */
    private static fflib_IDomainConstructor constructorMock;

    /**
     * @description Private method that allows the domain constructor mock to be set by test class.
     * @param mock fflib_IDomainConstructor
     */
    @TestVisible
    private static void setConstructorMock(fflib_IDomainConstructor mock) {
        constructorMock = mock;
    }

    /**
     * @description To create instance of OpportunityTeamMember domain class.
     */
    public class Constructor implements fflib_IDomainConstructor {
        /**
         * @description Constructor method implementation from fflib_IDomainConstructor class
         * @param objects List<Object>
         * @return instance of OpportunityTeamMember
         */
        public fflib_ISObjects construct(List<Object> objects) {
            if (OpportunityTeamMembers.constructorMock != null) {
                return (fflib_ISObjects) OpportunityTeamMembers.constructorMock.construct(objects);
            }
            return new OpportunityTeamMembers((List<OpportunityTeamMember>) objects);
        }
    }

    /**
     * @description update SDR Opportunity Owner on Opportunity when opportunity team member is added with Sales Development Rep role.
     * @param existingRecords
     */
    public void updateSDROpportunityOwnerOnOpportunity(
        Map<Id, OpportunityTeamMember> existingRecords
    ) {
        Set<Id> opportunityIds = new Set<Id>();
        for (
            OpportunityTeamMember eachOpportunityTeamMember : (List<OpportunityTeamMember>) getRecords()
        ) {
            if (eachOpportunityTeamMember.TeamMemberRole == SALES_DEVELOPMENT_REP) {
                uow.registerDirty(
                    new Opportunity(
                        Id = eachOpportunityTeamMember.OpportunityId,
                        SDR_Opportunity_Owner__c = eachOpportunityTeamMember.UserId
                    )
                );
            } else if (
                !existingRecords.isEmpty() &&
                existingRecords.containsKey(eachOpportunityTeamMember.Id) &&
                eachOpportunityTeamMember.TeamMemberRole != SALES_DEVELOPMENT_REP
            ) {
                opportunityIds.add(eachOpportunityTeamMember.OpportunityId);
            }
        }
        if (!opportunityIds.isEmpty()) {
            removeSDROpportunityOwnerFromOpportunity(opportunityIds);
        }
        try {
            uow.commitWork();
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_ERROR,
                        LOG_DOMAIN,
                        GenericLogEntry.SeverityLevel.LOW
                    )
                    .logException(ex)
            );
        }
    }

    /**
     * @description remove SDR Opportunity Owner from Opportunity when opportunity team member is changed to non Sales Development Rep role.
     * @param opportunityIds
     */
    private void removeSDROpportunityOwnerFromOpportunity(Set<Id> opportunityIds) {
        for (
            Opportunity eachOpportunity : OpportunitiesSelector.newInstance()
                .selectOpportunityAndRelatedOpportunityTeamMemberByOpportunityIds(opportunityIds)
        ) {
            if (eachOpportunity.OpportunityTeamMembers.size() > 0) {
                OpportunityTeamMember opportunityTeamMember = eachOpportunity.OpportunityTeamMembers[0];
                uow.registerDirty(
                    new Opportunity(
                        Id = opportunityTeamMember.OpportunityId,
                        SDR_Opportunity_Owner__c = opportunityTeamMember.UserId
                    )
                );
            } else {
                uow.registerDirty(
                    new Opportunity(Id = eachOpportunity.Id, SDR_Opportunity_Owner__c = null)
                );
            }
        }
    }
}