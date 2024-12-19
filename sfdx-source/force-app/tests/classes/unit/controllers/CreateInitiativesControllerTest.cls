/**
 * @author Deloitte
 * @date 14/06/2022
 * @description Controller Test class for Create Initiatives flow
 */
@isTest
public class CreateInitiativesControllerTest {
    /**
     * @description To test fetch store data when a section is changed on UI.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenControllerIsInvokedFromFlowThenCallService() {
        Id campaignMemberId = fflib_IDGenerator.generate(CampaignMember.SObjectType);
        List<CampaignMember> campaignMembers = new List<CampaignMember>{
            new CampaignMember(Id = campaignMemberId)
        };
        List<List<CampaignMember>> campaignMembersFromFlow = new List<List<CampaignMember>>{
            campaignMembers
        };
        List<List<CampaignMember>> filteredCampaignMembers = new List<List<CampaignMember>>{
            campaignMembers
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ICampaignMembersService campaignMemberService = (ICampaignMembersService) mocks.mock(
            ICampaignMembersService.class
        );
        mocks.startStubbing();
        mocks.when(
                campaignMemberService.filterOutCampaignMembersWithInitiatives(
                    campaignMembersFromFlow
                )
            )
            .thenReturn(filteredCampaignMembers);
        mocks.stopStubbing();
        Application.SERVICE.setMock(ICampaignMembersService.class, campaignMemberService);
        Test.startTest();
        CreateInitiativesController.filterCampaignMembers(campaignMembersFromFlow);
        Test.stopTest();
        ((ICampaignMembersService) mocks.verify(campaignMemberService, 1))
            .filterOutCampaignMembersWithInitiatives(campaignMembersFromFlow);
    }
}