/**
 * @author Deloitte
 * @date 14/06/2022
 * @description Service class for CampaignMember related logic.
 */
public inherited sharing class CampaignMembersService {
    /**
     * @description It is used to filter CampaignMembers for creating Initiatives for the
     *              filtered list of CampaignMember
     * @param campaignMembers
     * @return List<List<CampaignMember>>
     */
    public static List<List<CampaignMember>> filterOutCampaignMembersWithInitiatives(
        List<List<CampaignMember>> campaignMembers
    ) {
        return service().filterOutCampaignMembersWithInitiatives(campaignMembers);
    }

    /**
     * @description It creates an instance of CampaignMemberService class.
     * @return ICampaignMembersService - return instance of CampaignMembersServiceImpl
     */
    private static ICampaignMembersService service() {
        return (ICampaignMembersService) Application.SERVICE.newInstance(
            ICampaignMembersService.class
        );
    }
}