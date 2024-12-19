/**
 * @author Deloitte
 * @date 05/02/2024
 * @description This is test class for OpportunityTeamMembersSelector class
 */
@isTest(SeeAllData=false)
private class OpportunityTeamMembersSelectorTest {
    private static final String SALES_DEVELOPMENT_REP_ROLE = 'Sales Development Rep';
    private static final String ACCOUNT_EXECUTIVE_ROLE = 'Account Executive';
    private static final String EMPTY_LIST_ASSERT_MESSAGE = 'Unexpected Result: Number of records returned does not match the expected outcome.';
    private static final String OPPORTUNITY_NAME = 'Test Corp Opportunity';
    private static final String PROSPECTING = 'Prospecting';

    /**
     * @description It is used to validate negative scenario for method to query related OpportunityTeamMember of Opportunity.
     */
    @isTest
    private static void testWhenPassingOpportunityIdsThenGetOpportunityTeamMemberFail() {
        Opportunity opportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.StageName, PROSPECTING)
            .setField(Opportunity.CloseDate, Date.today())
            .toSObject();
        insert opportunity;
        OpportunityTeamMember opportunityTeamMember = (OpportunityTeamMember) new Fake(
                OpportunityTeamMember.class
            )
            .setField(opportunityTeamMember.OpportunityId, opportunity.Id)
            .setField(opportunityTeamMember.TeamMemberRole, ACCOUNT_EXECUTIVE_ROLE)
            .setField(opportunityTeamMember.UserId, UserInfo.getUserID())
            .toSObject();
        insert (OpportunityTeamMember);
        Test.startTest();
        List<OpportunityTeamMember> opportunityTeamMembers = OpportunityTeamMembersSelector.newInstance()
            .selectByOpportunityIds(new Set<Id>{ opportunity.Id });
        Test.stopTest();
        System.assertEquals(true, opportunityTeamMembers.isEmpty(), EMPTY_LIST_ASSERT_MESSAGE);
    }

    /**
     * @description It is used to validate positive scenario for method to query related OpportunityTeamMember of Opportunity.
     */
    @isTest
    private static void testWhenPassingOpportunityIdsThenGetOpportunityTeamMemberPass() {
        Opportunity opportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.StageName, PROSPECTING)
            .setField(Opportunity.CloseDate, Date.today())
            .toSObject();
        insert opportunity;
        OpportunityTeamMember opportunityTeamMember = (OpportunityTeamMember) new Fake(
                OpportunityTeamMember.class
            )
            .setField(opportunityTeamMember.OpportunityId, opportunity.Id)
            .setField(opportunityTeamMember.TeamMemberRole, SALES_DEVELOPMENT_REP_ROLE)
            .setField(opportunityTeamMember.UserId, UserInfo.getUserID())
            .toSObject();
        insert (OpportunityTeamMember);
        Test.startTest();
        List<OpportunityTeamMember> opportunityTeamMembers = OpportunityTeamMembersSelector.newInstance()
            .selectByOpportunityIds(new Set<Id>{ opportunity.Id });
        Test.stopTest();
        System.assertEquals(false, opportunityTeamMembers.isEmpty(), EMPTY_LIST_ASSERT_MESSAGE);
    }

    /**
     * @description It is used to validate when Opportunity Ids inserted then opportunity
     * team members with SDR role are returned.
     */
    @isTest
    private static void testWhenOpportunityIdsPassedThenSDROpportunityTeamMembersReturned() {
        Opportunity opportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.StageName, PROSPECTING)
            .setField(Opportunity.CloseDate, Date.today())
            .toSObject();
        insert opportunity;
        OpportunityTeamMember opportunitySDRTeamMember = (OpportunityTeamMember) new Fake(
                OpportunityTeamMember.class
            )
            .setField(OpportunityTeamMember.OpportunityId, opportunity.Id)
            .setField(OpportunityTeamMember.TeamMemberRole, SALES_DEVELOPMENT_REP_ROLE)
            .setField(OpportunityTeamMember.UserId, UserInfo.getUserID())
            .toSObject();
        insert (opportunitySDRTeamMember);
        Test.startTest();
        List<OpportunityTeamMember> opportunityTeamMembers = OpportunityTeamMembersSelector.newInstance()
            .selectByOpportunityIdsWithoutRole(new Set<Id>{ opportunity.Id });
        Test.stopTest();
        System.assertEquals(false, opportunityTeamMembers.isEmpty(), EMPTY_LIST_ASSERT_MESSAGE);
        System.assertEquals(1, opportunityTeamMembers.size(), EMPTY_LIST_ASSERT_MESSAGE);
    }

    /**
     * @description It is used to validate when Opportunity Ids inserted then opportunity
     * team members with Account execeutive role are not returned.
     */
    @isTest
    private static void testWhenOpportunityIdsPassedThenNoOpportunityTeamMembersReturned() {
        Opportunity opportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.StageName, PROSPECTING)
            .setField(Opportunity.CloseDate, Date.today())
            .toSObject();
        insert opportunity;
        OpportunityTeamMember opportunityAccountExecutiveTeamMember = (OpportunityTeamMember) new Fake(
                OpportunityTeamMember.class
            )
            .setField(OpportunityTeamMember.OpportunityId, opportunity.Id)
            .setField(OpportunityTeamMember.TeamMemberRole, ACCOUNT_EXECUTIVE_ROLE)
            .setField(OpportunityTeamMember.UserId, UserInfo.getUserID())
            .toSObject();
        insert (opportunityAccountExecutiveTeamMember);
        Test.startTest();
        List<OpportunityTeamMember> opportunityTeamMembers = OpportunityTeamMembersSelector.newInstance()
            .selectByOpportunityIdsWithoutRole(new Set<Id>{ opportunity.Id });
        Test.stopTest();
        System.assertEquals(true, opportunityTeamMembers.isEmpty(), EMPTY_LIST_ASSERT_MESSAGE);
        System.assertEquals(0, opportunityTeamMembers.size(), EMPTY_LIST_ASSERT_MESSAGE);
    }

    /**
     * @description It is used to validate positive scenario for to get Opportunity Team Members by the passed Opportunity Ids.
     */
    @isTest
    private static void testWhenOpportunityIdsWithOpportunityTeamMembersProvidedThenReturnOpportunityTeamMembers() {
        Opportunity opportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.StageName, PROSPECTING)
            .setField(Opportunity.CloseDate, Date.today())
            .toSObject();
        insert opportunity;
        OpportunityTeamMember opportunityTeamMember = (OpportunityTeamMember) new Fake(
                OpportunityTeamMember.class
            )
            .setField(opportunityTeamMember.OpportunityId, opportunity.Id)
            .setField(opportunityTeamMember.TeamMemberRole, SALES_DEVELOPMENT_REP_ROLE)
            .setField(opportunityTeamMember.UserId, UserInfo.getUserID())
            .toSObject();
        insert (OpportunityTeamMember);
        Test.startTest();
        List<OpportunityTeamMember> opportunityTeamMembers = OpportunityTeamMembersSelector.newInstance()
            .selectAllOpportunityTeamMembersByOpportunityIds(new Set<String>{ opportunity.Id });
        Test.stopTest();
        System.assertEquals(false, opportunityTeamMembers.isEmpty(), EMPTY_LIST_ASSERT_MESSAGE);
    }

    /**
     * @description It is used to validate negative scenario for to query Opportunity Team Members by the passed Opportunity Ids.
     */
    @isTest
    private static void testWhenOpportunityIdsWithoutOpportunityTeamMembersProvidedThenDoNotReturnOpportunityTeamMembers() {
        Opportunity opportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.StageName, PROSPECTING)
            .setField(Opportunity.CloseDate, Date.today())
            .toSObject();
        insert opportunity;
        Test.startTest();
        List<OpportunityTeamMember> opportunityTeamMembers = OpportunityTeamMembersSelector.newInstance()
            .selectAllOpportunityTeamMembersByOpportunityIds(new Set<String>{ opportunity.Id });
        Test.stopTest();
        System.assertEquals(true, opportunityTeamMembers.isEmpty(), EMPTY_LIST_ASSERT_MESSAGE);
    }
}