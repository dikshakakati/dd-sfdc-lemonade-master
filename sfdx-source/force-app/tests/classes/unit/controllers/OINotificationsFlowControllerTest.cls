/**
 * @author Deloitte
 * @date 05/12/2024
 * @description Test class for OINotificationsFlowController class.
 */
@isTest(SeeAllData=false)
private class OINotificationsFlowControllerTest {
    private static final String ASSERT_MESSAGE_FLOW_INPUT = 'Unexpected error: The flow has no inputs to accept';
    private static final String EMPTY_LIST_ASSERT_MESSAGE = 'Unexpected error: The Opportunity Team Member records were not found';
    private static final String SALES_DEVELOPMENT_REP = 'Sales Development Rep';

    /**
     * @description It is used to validate positive scenario for method to query related OpportunityTeamMember of Opportunity.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOpportunityIdsWithOpportunityTeamMembersProvidedThenReturnOpportunityTeamMembers() {
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id opportunityTeamMemberId = Fake.generateId(OpportunityTeamMember.class);
        Id mockUserId = fflib_IDGenerator.generate(User.SObjectType);

        OpportunityTeamMember opportunityTeamMemberInstance = (OpportunityTeamMember) new Fake( OpportunityTeamMember.class)
            .setField(OpportunityTeamMember.Id, opportunityTeamMemberId)
            .setField(OpportunityTeamMember.OpportunityId, opportunityId)
            .setField(OpportunityTeamMember.TeamMemberRole, SALES_DEVELOPMENT_REP)
            .setField(OpportunityTeamMember.UserId,mockUserId)
            .toSObject();
        List<List<OpportunityTeamMember>> opportunityTeamMembers = new List<List<OpportunityTeamMember>>();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunityTeamMembersSelector opportunityTeamSelectorMock = (IOpportunityTeamMembersSelector) mocks.mock(
            IOpportunityTeamMembersSelector.class
        );
        mocks.startStubbing();
        mocks.when(opportunityTeamSelectorMock.SObjectType()).thenReturn(OpportunityTeamMember.SObjectType);
        mocks.when(
                opportunityTeamSelectorMock.selectAllOpportunityTeamMembersByOpportunityIds(
                    new Set<String>{ opportunityId }
                )
            )
            .thenReturn(new List<OpportunityTeamMember> {opportunityTeamMemberInstance});
        mocks.stopStubbing();
        Application.Selector.setMock(opportunityTeamSelectorMock);
        opportunityTeamMembers = OINotificationsFlowController.getOpportunityTeamMembers(
            new List<String>{ opportunityId }
        );
        System.assertEquals(1, opportunityTeamMembers.size(), ASSERT_MESSAGE_FLOW_INPUT);
    }

    /**
     * @description It is used to validate negative scenario for method to query related OpportunityTeamMember of Opportunity.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOpportunityIdsWithoutOpportunityTeamMembersProvidedThenDoNotReturnOpportunityTeamMembers() {
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        List<List<OpportunityTeamMember>> opportunityTeamMembers = new List<List<OpportunityTeamMember>>();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunityTeamMembersSelector opportunityTeamSelectorMock = (IOpportunityTeamMembersSelector) mocks.mock(
            IOpportunityTeamMembersSelector.class
        );
        mocks.startStubbing();
        mocks.when(opportunityTeamSelectorMock.SObjectType()).thenReturn(OpportunityTeamMember.SObjectType);
        mocks.when(
                opportunityTeamSelectorMock.selectAllOpportunityTeamMembersByOpportunityIds(
                    new Set<String>{ opportunityId }
                )
            )
            .thenReturn(new List<OpportunityTeamMember> ());
        mocks.stopStubbing();
        Application.Selector.setMock(opportunityTeamSelectorMock);
        opportunityTeamMembers = OINotificationsFlowController.getOpportunityTeamMembers(
            new List<String>{ opportunityId }
        );
       System.assertEquals(true, opportunityTeamMembers[0].isEmpty(), EMPTY_LIST_ASSERT_MESSAGE);
    }
}