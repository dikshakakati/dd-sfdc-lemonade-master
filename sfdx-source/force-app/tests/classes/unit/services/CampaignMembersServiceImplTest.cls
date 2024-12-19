/**
 * @author Deloitte
 * @date 14/06/2022
 * @description Test class for CampaignMembersServiceImplTest class.
 */
@isTest
private class CampaignMembersServiceImplTest {
    private static final String ASSERT_MESSAGE_FLOW_INPUT = 'Unexpected error: The flow has no inputs to accept';
    private static final String ASSERT_MESSAGE_MEMBER_LIST = 'Unexpected error: The CampaignMember records were not filtered properly';

    /**
     * @description To test logic for fetching WorkPlan & child WorkPlan when WorkPlanIds are passed.
     * Suppressed Warnings since mock verify method is equivalent of System.assert statement.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenCampaignMembersAreProvidedThenReturnMembersWithNoInitiative() {
        CampaignMember campaignMemberIdDashPass = new CampaignMember(
            Id = fflib_IDGenerator.generate(CampaignMember.SObjectType)
        );
        CampaignMember campaignMemberIdDrive = new CampaignMember(
            Id = fflib_IDGenerator.generate(CampaignMember.SObjectType)
        );
        List<List<CampaignMember>> campaignMembersList = new List<List<CampaignMember>>();
        List<CampaignMember> membersList = new List<CampaignMember>{
            campaignMemberIdDashPass,
            campaignMemberIdDrive
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IInitiativesSelector initiativesSelectorMock = (IInitiativesSelector) mocks.mock(
            IInitiativesSelector.class
        );
        mocks.startStubbing();
        mocks.when(initiativesSelectorMock.SObjectType()).thenReturn(Initiative__c.SObjectType);
        mocks.when(
                initiativesSelectorMock.selectByCampaignMembers(
                    new Set<Id>{ campaignMemberIdDashPass.Id, campaignMemberIdDrive.Id }
                )
            )
            .thenReturn(new List<Initiative__c>());
        mocks.stopStubbing();
        Application.Selector.setMock(initiativesSelectorMock);
        campaignMembersList = CampaignMembersService.filterOutCampaignMembersWithInitiatives(
            new List<List<CampaignMember>>{ membersList }
        );
        System.assertEquals(1, campaignMembersList.size(), ASSERT_MESSAGE_FLOW_INPUT);
        System.assertEquals(2, campaignMembersList[0].size(), ASSERT_MESSAGE_MEMBER_LIST);
    }
}