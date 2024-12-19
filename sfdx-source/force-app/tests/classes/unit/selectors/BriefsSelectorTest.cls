/**
 * @author Deloitte
 * @date 11/30/2022
 * @description Test class for Briefs selector.
 */
@isTest(SeeAllData=false)
private class BriefsSelectorTest {
    private static final String ACCOUNT_PRIMARY_VERTICAL = 'Rx';
    /**
     * @description This method used to test Brief Selector class
     */
    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        BriefsSelector selector = new BriefsSelector();
        List<Schema.SObjectField> fieldList = selector.getSObjectFieldList();
        Schema.SObjectType typeOfObj = selector.getSObjectType();
        System.assertEquals(
            new List<Schema.SObjectField>{
                Brief__c.Id,
                Brief__c.Name,
                Brief__c.CampaignName__c,
                Brief__c.Start_Date__c,
                Brief__c.End_Date__c,
                Brief__c.Are_All_Brief_Items_in_Campaign_Building__c,
                Brief__c.Opportunity_Name__c,
                Brief__c.SBQQ_Quote__c
            },
            fieldList,
            'Mismatch in field list.'
        );
        System.assertEquals(
            Schema.Brief__c.SObjectType,
            typeOfObj,
            'The object type must be Brief.'
        );
    }

    /**
     * @description It is used to test if the Brief Items are fetched.
     */
    @isTest
    private static void testWhenBriefIdsArePassedThenBriefsAreFetched() {
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Account[] businessAccounts = new List<Account>{
            new Account(Name = 'Name1', RecordTypeId = accRecordTypeBusiness, Segment__c = 'Enterprise'),
            new Account(Name = 'Name2', RecordTypeId = accRecordTypeBusiness, Segment__c = 'Enterprise')
        };
        insert businessAccounts;

        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(Id = pricebookId, IsActive = true);
        update standardPricebook;

        List<Opportunity> opportunityList = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5),
                AccountId = businessAccounts[0].Id,
                Deal_Type__c= 'Standard',
                Opportunity_Sub_Type__c= 'Former Partner',
                Pricebook2Id = pricebookId
            )
        };
        insert opportunityList;

        List<Brief__c> briefs = new List<Brief__c>{
            new Brief__c(
                Is_Created_By_System__c = true,
                CampaignName__c = 'Campaign Name',
                Additional_Notes__c = 'Additional Notes',
                Opportunity_Name__c = opportunityList[0].Id,
                Opportunity_Owner__c = UserInfo.getUserId(),
                Netsuite_ID__c = 'NetSuite ID',
                Configuration__c = 'Standard (Launch Ops)              '
            )
        };
        insert briefs;

        List<Brief__c> newBrief = BriefsSelector.newInstance()
            .selectById(new Set<Id>{ briefs[0].Id });

        System.assertEquals(1, newBrief.size(), 'The Briefs were not appropriately fetched.');
    }

    /**
     * @description It is used to test if Brief records are fetched when related Account Id is
     * passed.
     */
    @isTest
    private static void testWhenAccountIdsArePassedThenBriefsAreFetched() {
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Account[] businessAccounts = new List<Account>{
            new Account(Name = 'Name1', RecordTypeId = accRecordTypeBusiness, Segment__c = 'Enterprise'),
            new Account(Name = 'Name2', RecordTypeId = accRecordTypeBusiness, Segment__c = 'Enterprise')
        };
        insert businessAccounts;

        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(Id = pricebookId, IsActive = true);
        update standardPricebook;

        List<Opportunity> opportunityList = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5),
                AccountId = businessAccounts[0].Id,
                Deal_Type__c= 'Standard',
                Opportunity_Sub_Type__c= 'Former Partner',
                Pricebook2Id = pricebookId
            )
        };
        insert opportunityList;

        List<Brief__c> briefs = new List<Brief__c>{
            new Brief__c(
                Is_Created_By_System__c = true,
                CampaignName__c = 'Campaign Name',
                Additional_Notes__c = 'Additional Notes',
                Opportunity_Name__c = opportunityList[0].Id,
                Opportunity_Owner__c = UserInfo.getUserId(),
                Netsuite_ID__c = 'NetSuite ID',
                Applicable_DoorDash_Order_Types__c = 'Delivery',
                Configuration__c = 'Standard (Launch Ops)'
            )
        };
        insert briefs;

        List<Brief__c> newBrief = BriefsSelector.newInstance()
            .selectByAccountIds(new Set<Id>{ businessAccounts[0].Id, businessAccounts[1].Id });

        System.assertEquals(1, newBrief.size(), 'The Briefs were not appropriately fetched.');
    }

    /**
     * @description It is used to test if Brief records are fetched when related Opportunity Id is
     * passed.
     */
    @isTest
    private static void testWhenOpportunityIdsArePassedThenBriefsAreFetched() {
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        List<Account> accountList = new List<Account>{
            new Account(
                Name = 'Parent 1',
                Primary_Vertical__c = ACCOUNT_PRIMARY_VERTICAL,
                RecordTypeId = accRecordTypeBusiness,Segment__c = 'Enterprise'
            ),
            new Account(Name = 'Parent 2', RecordTypeId = accRecordTypeBusiness, Segment__c = 'Enterprise')
        };
        insert accountList;

        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(Id = pricebookId, IsActive = true);
        update standardPricebook;

        Opportunity testOpp = CPQTestDataFactory.createOpportunity(accountList[0].Id, true);
        SBQQ__Quote__c quote = CPQTestDataFactory.createQuote(testOpp, accountList[0], null, true);
        quote.Opt_In_Out_Responsible_Party__c = 'Merchant';
        quote.Opt_In_Opt_Out_Response_Time_in_Days__c = 3;
        quote.Opt_In_Opt_Out_Decision__c = 'FSA';
        quote.Opt_Out_Save_Period_days__c = 3;
        update quote;

        List<Brief__c> briefs = new List<Brief__c>{
            new Brief__c(
                Is_Created_By_System__c = true,
                CampaignName__c = 'Campaign Name',
                Additional_Notes__c = 'Additional Notes',
                Opportunity_Name__c = testOpp.Id,
                Opportunity_Owner__c = UserInfo.getUserId(),
                Netsuite_ID__c = 'NetSuite ID',
                Applicable_DoorDash_Order_Types__c = 'Delivery',
                Configuration__c = 'Standard (Launch Ops)'
            )
        };
        insert briefs;

        List<Quote_Brief_Relationship__c> quoteBriefRelationships = new List<Quote_Brief_Relationship__c>{
            new Quote_Brief_Relationship__c(Quote__c = quote.Id, Brief__c = briefs[0].Id)
        };
        insert quoteBriefRelationships;

        List<Brief__c> newBrief = BriefsSelector.newInstance()
            .selectByOpportunities(new Set<Id>{ testOpp.Id });

        System.assertEquals(1, newBrief.size(), 'The Briefs were not appropriately fetched.');
    }
    /**
     * @description It is used to test if Brief records are fetched when related Brief Id is
     * passed.
     */
    @isTest
    private static void testWhenUsingselectByIdIncludingAccountIdThenBriefsAreReturned() {
        Id briefId = Fake.generateId(Brief__c.class);
        Id oppId = Fake.generateId(Opportunity.class);
        Set<Id> briefIds = new Set<Id>{briefId};
        List<Brief__c> briefsList = new List<Brief__c>{
            new Brief__c(
                Is_Created_By_System__c = true,
                CampaignName__c = 'Campaign Name',
                Additional_Notes__c = 'Additional Notes',
                Opportunity_Name__c = oppId,
                Opportunity_Owner__c = UserInfo.getUserId(),
                Netsuite_ID__c = 'NetSuite ID',
                Applicable_DoorDash_Order_Types__c = 'Delivery',
                Configuration__c = 'Standard (Launch Ops)'
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        BriefsSelector briefsSelectorMock = (BriefsSelector) mocks.mock(BriefsSelector.class);
        mocks.startStubbing();
        mocks.when(briefsSelectorMock.getSObjectType()).thenReturn(Brief_Item__c.SObjectType);
        mocks.when(briefsSelectorMock.selectByIdIncludingAccountId(briefIds)).thenReturn(briefsList);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(briefsSelectorMock);
        List<Brief__c> returnedBriefs = BriefsSelector.newInstance().selectByIdIncludingAccountId(briefIds);
        System.assertNotEquals(briefsList.size(),returnedBriefs.size(), 'Returned Brief do not match');

    }
    /**
     * @description It is used to test if Brief records are fetched when related Opportunity Id is
     * passed.
     */
    @isTest
    private static void testWhenUsingselectByOpportunityBriefRelationshipThenBriefsAreReturned() {
        Id briefId = Fake.generateId(Brief__c.class);
        Id oppId = Fake.generateId(Opportunity.class);
        Set<Id> oppIds = new Set<Id>{oppId};
        List<Brief__c> briefsList = new List<Brief__c>{
            new Brief__c(
                Is_Created_By_System__c = true,
                CampaignName__c = 'Campaign Name',
                Additional_Notes__c = 'Additional Notes',
                Opportunity_Name__c = oppId,
                Opportunity_Owner__c = UserInfo.getUserId(),
                Netsuite_ID__c = 'NetSuite ID',
                Applicable_DoorDash_Order_Types__c = 'Delivery',
                Configuration__c = 'Standard (Launch Ops)',
                Id = briefId
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        BriefsSelector briefsSelectorMock = (BriefsSelector) mocks.mock(BriefsSelector.class);
        //mocking
        mocks.startStubbing();
        mocks.when(briefsSelectorMock.getSObjectType()).thenReturn(Brief_Item__c.SObjectType);
        mocks.when(briefsSelectorMock.selectByOpportunityBriefRelationship(oppIds)).thenReturn(briefsList);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(briefsSelectorMock);
        List<Brief__c> returnedBriefs = BriefsSelector.newInstance().selectByOpportunityBriefRelationship(oppIds);
        System.assertNotEquals(briefsList.size(),returnedBriefs.size(), 'Returned Brief do not match');
    }

    /**
     * @description It is used to test if Brief records are fetched when passed brief ids
     * with primary vertical field
     */
    @isTest
    private static void testWhenUsingSelectBriefWithPrimaryVerticalThenBriefsAreReturned() {
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Account[] businessAccounts = new List<Account>{
            new Account(Name = 'Name1', RecordTypeId = accRecordTypeBusiness, Segment__c = 'Enterprise'),
            new Account(Name = 'Name2', RecordTypeId = accRecordTypeBusiness, Segment__c = 'Enterprise')
        };
        insert businessAccounts;

        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(Id = pricebookId, IsActive = true);
        update standardPricebook;

        List<Opportunity> opportunityList = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5),
                AccountId = businessAccounts[0].Id,
                Deal_Type__c= 'Standard',
                Opportunity_Sub_Type__c= 'Former Partner',
                Pricebook2Id = pricebookId
            )
        };
        insert opportunityList;

        List<Brief__c> briefs = new List<Brief__c>{
            new Brief__c(
                Is_Created_By_System__c = true,
                CampaignName__c = 'Campaign Name',
                Additional_Notes__c = 'Additional Notes',
                Opportunity_Name__c = opportunityList[0].Id,
                Opportunity_Owner__c = UserInfo.getUserId(),
                Netsuite_ID__c = 'NetSuite ID',
                Configuration__c = 'Standard (Launch Ops)'
            )
        };
        insert briefs;

        List<Brief__c> newBrief = BriefsSelector.newInstance()
            .selectBriefWithPrimaryVertical(new Set<Id>{ briefs[0].Id });

        System.assertEquals(1, newBrief.size(), 'The Briefs were not appropriately fetched.');
    }
}