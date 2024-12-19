/**
 * @author Deloitte
 * @date 14/06/2022
 * @description Integration Test class for CampaignMembersServiceImpl
 */
@isTest
private class CampaignMembersServiceImplIntTest {
    private static final String ASSERT_ERROR_FOR_NO_FILTERED_CAMPAIGNS = 'Campaign Members with Initiatives have also been improperly fetched';
    private static final String ASSERT_ERROR_FOR_FILTERED_CAMPAIGNS = 'The Campaign members were not filtered correctly';

    @testSetup
    static void setupCampaignData() {
        List<Account> accountList = new List<Account>{ new Account(Name = 'Parent 1', Segment__c = 'Enterprise') };
        insert accountList;

        List<Campaign> campaigns = new List<Campaign>{
            new Campaign(Name = 'Test Campaign 1'),
            new Campaign(Name = 'Test Campaign 2')
        };
        insert campaigns;

        List<CampaignMember> campaignMembers = new List<CampaignMember>{
            new CampaignMember(AccountId = accountList[0].Id, CampaignId = campaigns[0].Id),
            new CampaignMember(AccountId = accountList[0].Id, CampaignId = campaigns[1].Id)
        };
        insert campaignMembers;

        List<Initiative__c> initativeRec = new List<Initiative__c>{
            new Initiative__c(
                Type__c = 'Business Review',
                Name = 'Initiative 1',
                Start_Date__c = System.today().addDays(3),
                Account__c = accountList[0].Id,
                Status__c = 'Not Started',
                Campaign__c = campaigns[0].Id,
                Campaign_Member_Id__c = campaignMembers[0].Id
            ),
            new Initiative__c(
                Type__c = 'Business Review',
                Name = 'Initiative 2',
                Start_Date__c = System.today().addDays(3),
                Account__c = accountList[0].Id,
                Status__c = 'Not Started'
            )
        };
        insert initativeRec;
    }

    @isTest
    private static void testWhenCampaignMembersWithInitiativesAreProvidedThenReturnNoCampaignMembers() {
        List<Campaign> campaigns = [SELECT Id, Name FROM Campaign WHERE Name = 'Test Campaign 1'];
        List<CampaignMember> campaignMembersWithInitiative = [
            SELECT Id, Name
            FROM CampaignMember
            WHERE CampaignId = :campaigns[0].Id
        ];

        List<List<CampaignMember>> campaignMembersFromFlow = new List<List<CampaignMember>>();
        List<List<CampaignMember>> filteredCampaignMembers = new List<List<CampaignMember>>();
        campaignMembersFromFlow.add(campaignMembersWithInitiative);
        filteredCampaignMembers = CampaignMembersService.filterOutCampaignMembersWithInitiatives(
            campaignMembersFromFlow
        );
        System.assertEquals(
            0,
            filteredCampaignMembers[0].size(),
            ASSERT_ERROR_FOR_NO_FILTERED_CAMPAIGNS
        );
    }

    @isTest
    private static void testWhenCampaignMembersWithoutInitiativesAreProvidedThenReturnAllMembers() {
        List<Campaign> campaigns = [SELECT Id, Name FROM Campaign WHERE Name = 'Test Campaign 2'];
        List<CampaignMember> campaignMembersWithInitiative = [
            SELECT Id, Name
            FROM CampaignMember
            WHERE CampaignId = :campaigns[0].Id
        ];

        List<List<CampaignMember>> campaignMembersFromFlow = new List<List<CampaignMember>>();
        List<List<CampaignMember>> filteredCampaignMembers = new List<List<CampaignMember>>();
        campaignMembersFromFlow.add(campaignMembersWithInitiative);
        filteredCampaignMembers = CampaignMembersService.filterOutCampaignMembersWithInitiatives(
            campaignMembersFromFlow
        );
        System.assertEquals(
            1,
            filteredCampaignMembers[0].size(),
            ASSERT_ERROR_FOR_FILTERED_CAMPAIGNS
        );
    }
}