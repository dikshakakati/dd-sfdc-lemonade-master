/**
 * @author Deloitte
 * @date 14/06/2022
 * @description Service implementation class for CampaignMember related logic.
 */
public inherited sharing class CampaignMembersServiceImpl implements ICampaignMembersService {
    /**
     * @description It is used to filter CampaignMembers for creating Initiatives for the
     *              filtered list of CampaignMember
     * @param campaignMembers
     * @return List<List<CampaignMember>>
     */
    public List<List<CampaignMember>> filterOutCampaignMembersWithInitiatives(
        List<List<CampaignMember>> campaignMembers
    ) {
        List<CampaignMember> allCampaignMembers = new List<CampaignMember>();
        if (campaignMembers == null && campaignMembers.isEmpty()) {
            return new List<List<CampaignMember>>();
        }
        for (List<CampaignMember> eachCampaignMember : campaignMembers) {
            allCampaignMembers.addAll(eachCampaignMember);
        }
        Map<Id, CampaignMember> idToMember = new Map<Id, CampaignMember>(allCampaignMembers);
        return filterMembersWithNoInitiatives(idToMember);
    }

    /**
     * @description Initiative related filtering logic is performed in this method
     * @param allCampaignMembers
     * @return List<List<CampaignMember>>
     */
    private List<List<CampaignMember>> filterMembersWithNoInitiatives(
        Map<Id, CampaignMember> allCampaignMembers
    ) {
        for (
            Initiative__c eachInitiative : InitiativesSelector.newInstance()
                .selectByCampaignMembers(allCampaignMembers.keySet())
        ) {
            allCampaignMembers.remove(eachInitiative.Campaign_Member_Id__c);
        }
        return new List<List<CampaignMember>>{ allCampaignMembers.values() };
    }
}