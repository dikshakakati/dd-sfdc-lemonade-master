/**
 * @author Deloitte
 * @date 14/06/2022
 * @description Interface of service class for CampaignMember related logic.
 */
public interface ICampaignMembersService {
    /**
     * @description It is used to filter CampaignMembers for creating Initiatives for the
     *              filtered list of CampaignMember
     * @param campaignMembers
     * @return List<List<CampaignMember>>
     */
    List<List<CampaignMember>> filterOutCampaignMembersWithInitiatives(
        List<List<CampaignMember>> campaignMembers
    );
}