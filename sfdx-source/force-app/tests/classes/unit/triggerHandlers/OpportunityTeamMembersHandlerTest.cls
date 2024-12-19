/**
 * @description OpportunityTeamMember Object Trigger Handler Test
 * @author Deloitte
 * @date 07/03/2024
 */
@isTest(SeeAllData=false)
private class OpportunityTeamMembersHandlerTest {
    private static final String CONSTRUCTOR_ASSERT_MESSAGE = 'Unexpected result: The objects are matching';
    private static final String ACCOUNT_NAME = 'Account 1';
    private static final String OPPORTUNITY_NAME = 'Opportunity 1';
    private static final String OPPORTUNITY_STAGE_NAME = 'Prospecting';
    private static final string SALES_DEVELOPMENT_REP = 'Sales Development Rep';
    private static final string DRIVE_SPECIALIST = 'Drive Specialist';

	/**
     * @description This method is used to test OpportunityTeamMember TriggerHandler
     */
    @isTest
    private static void testWhenClassInstantiatesThenCheck() {
        List<OpportunityTeamMember> newOpportunityTeamMember = new List<OpportunityTeamMember>();
        OpportunityTeamMembersHandler opportunityTeamMemberObject = new OpportunityTeamMembersHandler(newOpportunityTeamMember);
        OpportunityTeamMembersHandler.Constructor objConstructor = new OpportunityTeamMembersHandler.Constructor();
        objConstructor.construct(newOpportunityTeamMember);
        System.assertNotEquals(
            opportunityTeamMemberObject,
            objConstructor.construct(newOpportunityTeamMember),
            CONSTRUCTOR_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test when opportunity team member inserted then call updateSDROpportunityOwnerOnOpportunity.
     * Suppressed Warnings since mock verify method does not require system asssert statements.
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOpportunityTeamMemberInsertedThenUpdateSDROwner() {
        Id testAccountId1 = Fake.generateId(Account.class);
        Account account = (Account) new Fake(Account.class)
            .setField(Account.Id, testAccountId1)
            .setField(Account.Name, ACCOUNT_NAME)
            .toSObject();

        Id testOppId1 = Fake.generateId(Opportunity.class);
        Opportunity opportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, testOppId1)
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_NAME)
            .setField(Opportunity.CloseDate, Date.newInstance(2027, 12, 31))
            .setField(Opportunity.AccountId, testAccountId1)
            .toSObject();

        Id testOpportunityTeamMemberId = Fake.generateId(OpportunityTeamMember.class);
        OpportunityTeamMember opportunityTeamMember = (OpportunityTeamMember) new Fake(
                OpportunityTeamMember.class
            )
            .setField(OpportunityTeamMember.Id, testOpportunityTeamMemberId)
            .setField(OpportunityTeamMember.OpportunityId, testOppId1)
            .setField(OpportunityTeamMember.TeamMemberRole, DRIVE_SPECIALIST)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunityTeamMembers opportunityTeamMemberMock = (IOpportunityTeamMembers) mocks.mock(IOpportunityTeamMembers.class);
        mocks.startStubbing();
        mocks.when(opportunityTeamMemberMock.getType()).thenReturn(Schema.OpportunityTeamMember.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(opportunityTeamMemberMock);
        fflib_SObjectDomain.Test.Database.onInsert(new List<OpportunityTeamMember>{opportunityTeamMember});
        fflib_SObjectDomain.triggerHandler(OpportunityTeamMembersHandler.class);
        ((IOpportunityTeamMembers) mocks.verify(OpportunityTeamMemberMock, 1)).updateSDROpportunityOwnerOnOpportunity(new Map<Id, OpportunityTeamMember>{});
    }


    /**
     * @description To test when opportunity team member updated then call updateSDROpportunityOwnerOnOpportunity.
     * Suppressed Warnings since mock verify method does not require system asssert statements.
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOpportunityTeamMemberUpdatedThenUpdateSDROwner() {
        Id testAccountId1 = Fake.generateId(Account.class);
        Account account = (Account) new Fake(Account.class)
            .setField(Account.Id, testAccountId1)
            .setField(Account.Name, ACCOUNT_NAME)
            .toSObject();

        Id testOppId1 = Fake.generateId(Opportunity.class);
        Opportunity opportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, testOppId1)
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_NAME)
            .setField(Opportunity.CloseDate, Date.newInstance(2027, 12, 31))
            .setField(Opportunity.AccountId, testAccountId1)
            .toSObject();

        Id testOpportunityTeamMemberId = Fake.generateId(OpportunityTeamMember.class);
        OpportunityTeamMember oldOpportunityTeamMember = (OpportunityTeamMember) new Fake(
                OpportunityTeamMember.class
            )
            .setField(OpportunityTeamMember.Id, testOpportunityTeamMemberId)
            .setField(OpportunityTeamMember.OpportunityId, testOppId1)
            .setField(OpportunityTeamMember.TeamMemberRole, DRIVE_SPECIALIST)
            .toSObject();
        OpportunityTeamMember newOpportunityTeamMember = (OpportunityTeamMember) new Fake(
                OpportunityTeamMember.class
            )
            .setField(OpportunityTeamMember.Id, testOpportunityTeamMemberId)
            .setField(OpportunityTeamMember.OpportunityId, testOppId1)
            .setField(OpportunityTeamMember.TeamMemberRole, SALES_DEVELOPMENT_REP)
            .toSObject();
        Map<Id,OpportunityTeamMember> mockOldOpportunityteamMembers = new Map<Id,OpportunityTeamMember>{testOpportunityTeamMemberId => oldOpportunityTeamMember};
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunityTeamMembers opportunityTeamMemberMock = (IOpportunityTeamMembers) mocks.mock(IOpportunityTeamMembers.class);
        mocks.startStubbing();
        mocks.when(opportunityTeamMemberMock.getType()).thenReturn(Schema.OpportunityTeamMember.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(opportunityTeamMemberMock);
        fflib_SObjectDomain.Test.Database.onUpdate(new List<OpportunityTeamMember>{newOpportunityTeamMember}, mockOldOpportunityteamMembers);
        fflib_SObjectDomain.triggerHandler(OpportunityTeamMembersHandler.class);
        ((IOpportunityTeamMembers) mocks.verify(opportunityTeamMemberMock, 1)).updateSDROpportunityOwnerOnOpportunity(mockOldOpportunityteamMembers);
    }
}