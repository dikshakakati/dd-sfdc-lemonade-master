/**
 * @description Test class for Initiative Selector
 * @author Deloitte
 * @date 06/04/2022
 */
@isTest(seeAllData=false)
public class InitiativesSelectorTest {
    @isTest
    private static void testWhenCampaignMemberIdsAreProvidedThenInitiativesAreRetrieved() {
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
                Start_Date__c = System.today().addDays(5),
                Account__c = accountList[0].Id,
                Status__c = 'Not Started',
                Campaign__c = campaigns[0].Id,
                Campaign_Member_Id__c = campaignMembers[0].Id
            ),
            new Initiative__c(
                Type__c = 'Business Review',
                Name = 'Initiative 2',
                Start_Date__c = System.today().addDays(5),
                Account__c = accountList[0].Id,
                Status__c = 'Not Started'
            )
        };
        insert initativeRec;

        List<Initiative__c> fetchedInitiatives = new InitiativesSelector()
            .selectByCampaignMembers(new Set<Id>{ campaignMembers[0].Id, campaignMembers[1].Id });

        System.assertEquals(
            fetchedInitiatives.size(),
            1,
            'Only one initiative must be attached to the Campaign Members.'
        );
        System.assertEquals(
            fetchedInitiatives[0].Name,
            'Initiative 1',
            'The incorrect initiative was fetched.'
        );
    }

    @isTest
    private static void testWhenInsightsAreSentThenParentInitiativesAreQueried() {
        List<Account> accountList = new List<Account>{
            new Account(Name = 'Parent 1', Segment__c = 'Enterprise'),
            new Account(Name = 'Parent 2', Segment__c = 'Enterprise')
        };
        insert accountList;

        List<Initiative__c> initativeRec = new List<Initiative__c>{
            new Initiative__c(
                Type__c = 'Business Review',
                Name = 'Initiative 1',
                Start_Date__c = System.today().addDays(5),
                Account__c = accountList[0].Id,
                Status__c = 'Not Started'
            ),
            new Initiative__c(
                Type__c = 'Business Review',
                Name = 'Initiative 2',
                Start_Date__c = System.today().addDays(5),
                Account__c = accountList[1].Id,
                Status__c = 'Not Started'
            )
        };
        insert initativeRec;

        List<Campaign_Product__c> productRecords = new List<Campaign_Product__c>{
            new Campaign_Product__c(
                Name = 'Test Product 1',
                Product_Family__c = 'Ads',
                Status__c = 'Active'
            ),
            new Campaign_Product__c(
                Name = 'Test Product 2',
                Product_Family__c = 'Ads',
                Status__c = 'Active'
            )
        };
        insert productRecords;

        Product_Insights__c[] insightsList = new List<Product_Insights__c>{
            new Product_Insights__c(
                Initiative__c = initativeRec[0].Id,
                Outcome_Reason__c = 'Competitor',
                Interest_Level__c = 'Neutral',
                Origin__c = 'Mx Initiated',
                Outcome__c = 'Interested',
                Product__c = productRecords[0].Id
            ),
            new Product_Insights__c(
                Initiative__c = initativeRec[1].Id,
                Outcome_Reason__c = 'Competitor',
                Interest_Level__c = 'Neutral',
                Origin__c = 'Mx Initiated',
                Outcome__c = 'Interested',
                Product__c = productRecords[1].Id
            )
        };
        insert insightsList;

        List<Initiative__c> fetchedInitiatives = new InitiativesSelector()
            .selectByInsights(insightsList);

        System.assertEquals(
            2,
            fetchedInitiatives.size(),
            'The retrieved list of Initiatives do not have the necessary number of records'
        );
        System.assertEquals(
            fetchedInitiatives[0].Id,
            initativeRec[0].Id,
            'The retrieved initiative have mismatched Id'
        );
    }

    @isTest
    private static void testWhenIdIsSentThenReturnRecords() {
        List<Account> accountList = new List<Account>{
            new Account(Name = 'Parent 1', Segment__c = 'Enterprise'),
            new Account(Name = 'Parent 2', Segment__c = 'Enterprise')
        };
        insert accountList;

        List<Initiative__c> initativeRec = new List<Initiative__c>{
            new Initiative__c(
                Type__c = 'Business Review',
                Name = 'Initiative 1',
                Start_Date__c = System.today().addDays(5),
                Account__c = accountList[0].Id,
                Status__c = 'Not Started'
            ),
            new Initiative__c(
                Type__c = 'Business Review',
                Name = 'Initiative 2',
                Start_Date__c = System.today().addDays(5),
                Account__c = accountList[1].Id,
                Status__c = 'Not Started'
            )
        };
        insert initativeRec;

        List<Initiative__c> initiatives = new InitiativesSelector()
            .selectById(new Set<Id>{ initativeRec[0].Id, initativeRec[1].Id });

        System.assertEquals(
            2,
            initiatives.size(),
            'The retrieved list of Initiative Records is incorrect'
        );
    }

    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        List<Account> accountList = new List<Account>{
            new Account(Name = 'Parent 1', Segment__c = 'Enterprise'),
            new Account(Name = 'Parent 2', Segment__c = 'Enterprise')
        };
        insert accountList;

        List<Initiative__c> initativeRec = new List<Initiative__c>{
            new Initiative__c(
                Type__c = 'Business Review',
                Name = 'Initiative 1',
                Start_Date__c = System.today().addDays(5),
                Account__c = accountList[0].Id,
                Status__c = 'Not Started'
            ),
            new Initiative__c(
                Type__c = 'Business Review',
                Name = 'Initiative 2',
                Start_Date__c = System.today().addDays(5),
                Account__c = accountList[1].Id,
                Status__c = 'Not Started'
            )
        };
        insert initativeRec;

        InitiativesSelector initiativesInstance = new InitiativesSelector();

        Schema.SObjectType typeOfObj = initiativesInstance.getSObjectType();
        List<Schema.SObjectField> fieldList = initiativesInstance.getSObjectFieldList();

        InitiativesSelector.newInstance();

        System.assertEquals(
            Schema.Initiative__c.SObjectType,
            typeOfObj,
            'The object type must be Initiative'
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
                Initiative__c.Id,
                Initiative__c.Name,
                Initiative__c.Account__c,
                Initiative__c.Campaign_Member_Id__c
            },
            fieldList,
            'Mismatch in field list'
        );
    }

    @isTest
    private static void testWhenAccountIdsAreProvidedThenInitiativesAreRetrieved() {
        List<Account> accountList = new List<Account>{
            new Account(Name = 'Parent 1', Segment__c = 'Enterprise'),
            new Account(Name = 'Parent 2', Segment__c = 'Enterprise')
        };
        insert accountList;

        List<Initiative__c> initativeRec = new List<Initiative__c>{
            new Initiative__c(
                Type__c = 'Business Review',
                Name = 'Initiative 1',
                Start_Date__c = System.today().addDays(5),
                Account__c = accountList[0].Id,
                Status__c = 'Not Started'
            ),
            new Initiative__c(
                Type__c = 'Business Review',
                Name = 'Initiative 2',
                Start_Date__c = System.today().addDays(5),
                Account__c = accountList[0].Id,
                Status__c = 'Not Started'
            ),
            new Initiative__c(
                Type__c = 'Business Review',
                Name = 'Initiative 3',
                Start_Date__c = System.today().addDays(5),
                Account__c = accountList[1].Id,
                Status__c = 'Not Started'
            )
        };
        insert initativeRec;

        List<Initiative__c> fetchedInitiatives = new InitiativesSelector()
            .selectByAccounts(new Set<Id>{ accountList[0].Id, accountList[1].Id });

        System.assertEquals(
            fetchedInitiatives.size(),
            3,
            'Incorrect number of Initiatives fetched'
        );
    }
}