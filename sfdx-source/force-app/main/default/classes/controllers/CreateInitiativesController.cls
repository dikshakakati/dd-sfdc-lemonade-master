/**
 * @author Deloitte
 * @date 14/06/2022
 * @description This is the controller for Create Initiatives Flow Component.
 */
public with sharing class CreateInitiativesController {
    /**
     * @description Controller to filter CampaignMembers for creating Initiatives for the
     *              filtered list of CampaignMember
     * @JIRA# LEM-1595
     * @param campaignMembers
     * @return List<List<CampaignMember>>
     */
    @InvocableMethod(
        label='Get Filtered Campaign Members'
        description='Get filtered List of Campaign Members associated with Initiatives.'
    )
    public static List<List<CampaignMember>> filterCampaignMembers(
        List<List<CampaignMember>> campaignMembers
    ) {
        return CampaignMembersService.filterOutCampaignMembersWithInitiatives(campaignMembers);
    }
}