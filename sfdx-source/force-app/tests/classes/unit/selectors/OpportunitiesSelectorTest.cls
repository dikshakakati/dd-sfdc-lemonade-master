/**
 * @author Deloitte
 * @date 28/02/2022
 * @description This is test class for OpportunitiesSelector class
 */
@isTest(seeAllData=false)
public class OpportunitiesSelectorTest {
    private static final String ACCOUNT_NAME = 'KFC';
    private static final String ACCOUNT_PRIMARY_VERTICAL = 'Rx';
    private static final String CONTACT_FIRST_NAME = 'Test';
    private static final String CONTACT_LAST_NAME = 'User';
    private static final String CONTACT_DESCRIPTION = 'KFC Contact';
    private static final String CONTACT_EMAIL = 'testuser@kfc.com';
    private static final String SOURCE_NINTEX = 'Nintex';
    private static final String SIZE_MISMATCH_ASSERTION = 'Unexpected Error: The expected Opportunities were not fetched';
    private static final String MISMATCH_IN_OPPORTUNITY_COUNT_ERROR_MESSAGE = 'Unexpected Error: The Opportunities were not fetched as expected.';
    private static final String MISMATCH_IN_OCR_COUNT_ERROR_MESSAGE = 'Unexpected Error: The Opportunity Contact Role were not fetched as expected.';
    private static final String MISMATCH_IN_QUOTE_COUNT_ERROR_MESSAGE = 'Unexpected Error: The Quotes were not fetched as expected.';
    private static final String SEGMENT_SMB = 'SMB';
    private static final String SUB_STAGE_DISCOVERY = 'Discovery';
    private static final String SUB_STAGE_UNTOUCHED = 'Untouched';
    private static final String OPPORTUNITY_SUB_TYPE_NET_NEW = 'Net New Partner';
    private static final String OPPORTUNITY_SUB_TYPE_NEW_STORE_EXPANSION = 'New Store Expansion';
    private static final String OPPORTUNITY_TYPE_NEW = 'New';
    private static final String OPPORTUNITY_TYPE_EXISTING = 'Existing';
    private static final String OPPORTUNITY_NAME = 'KFC Opportunity';
    private static final String OPPORTUNITY_STAGE_NAME_PROSPECTING = 'Prospecting';
    private static final String OPPORTUNITY_SUB_STAGE_NAME_UNTOUCHED ='Untouched';
    private static final String OPPORTUNITY_DEAL_TYPE_STANDARD = 'Standard';
    private static final string SALES_DEVELOPMENT_REP = 'Sales Development Rep';
    private static final String NO_TEAM_PRESENT_ON_OPPORTUNITY_ASSERT_MESSAGE = 'Unexpected result: no Opportunity Team Member found on Opportunity';
    private static final String ACCOUNT_EXECUTIVE_ROLE = 'Account Executive';
    private static final String CONTRACT_SIGNATORY_CONTACT_ROLE = 'Contract Signatory';

    /**
     * @description This test method instatiates class.
     */
    @isTest
    private static void testWhenInsightsAreSentThenParentOpportunitiesAreQueried() {
        Test.startTest();
        List<Account> accountList = new List<Account>{
            new Account(Name = 'Parent 1', Segment__c = SEGMENT_SMB),
            new Account(Name = 'Parent 2', Segment__c = SEGMENT_SMB)
        };
        insert accountList;

        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(Id = pricebookId, IsActive = true);
        update standardPricebook;

        List<Opportunity> opportunityList = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5),
                AccountId = accountList[0].Id,
                Pricebook2Id = pricebookId,
                Deal_Type__c = 'Standard',
                Opportunity_Sub_Type__c = 'Former Partner',
                Estimated_Number_of_Stores__c = 1
            ),
            new Opportunity(
                Name = 'Test2',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5),
                AccountId = accountList[1].Id,
                Deal_Type__c = 'Standard',
                Opportunity_Sub_Type__c = 'Former Partner',
                Pricebook2Id = pricebookId,
                Estimated_Number_of_Stores__c = 1
            )
        };
        insert opportunityList;

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
                Opportunity__c = opportunityList[0].Id,
                Outcome_Reason__c = 'Competitor',
                Interest_Level__c = 'Neutral',
                Origin__c = 'Mx Initiated',
                Outcome__c = 'Interested',
                Product__c = productRecords[0].Id
            ),
            new Product_Insights__c(
                Opportunity__c = opportunityList[1].Id,
                Outcome_Reason__c = 'Competitor',
                Interest_Level__c = 'Neutral',
                Origin__c = 'Mx Initiated',
                Outcome__c = 'Interested',
                Product__c = productRecords[1].Id
            )
        };
        insert insightsList;
        List<Opportunity> fetchedOpportunities = new OpportunitiesSelector()
            .selectByInsights(insightsList);
        Test.stopTest();
        System.assertEquals(
            2,
            fetchedOpportunities.size(),
            'The retrieved list of Opportunities do not have the necessary number of records'
        );
        System.assertEquals(
            fetchedOpportunities[0].Id,
            opportunityList[0].Id,
            'The retrieved opportunity have mismatched Id'
        );
    }

    @isTest
    private static void testWhenIdIsSentThenReturnRecords() {
        Test.startTest();
        List<Account> accountList = new List<Account>{
            new Account(Name = 'Parent 1', Segment__c = SEGMENT_SMB),
            new Account(Name = 'Parent 2', Segment__c = SEGMENT_SMB)
        };
        insert accountList;

        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(Id = pricebookId, IsActive = true);
        update standardPricebook;

        List<Opportunity> opportunityList = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5),
                AccountId = accountList[0].Id,
                Pricebook2Id = pricebookId,
                Deal_Type__c = 'Standard',
                Opportunity_Sub_Type__c = 'Former Partner',
                Estimated_Number_of_Stores__c = 1
            ),
            new Opportunity(
                Name = 'Test2',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5),
                AccountId = accountList[1].Id,
                Deal_Type__c = 'Standard',
                Opportunity_Sub_Type__c = 'Former Partner',
                Pricebook2Id = pricebookId,
                Estimated_Number_of_Stores__c = 1
            )
        };
        insert opportunityList;
        List<Opportunity> opportunities = new OpportunitiesSelector()
            .selectById(new Set<Id>{ opportunityList[0].Id, opportunityList[1].Id });
        Test.stopTest();
        System.assertEquals(
            2,
            opportunities.size(),
            'The retrieved list of Opportunity Records is incorrect'
        );
    }

    @isTest
    private static void testWhenSelectInactiveMethodCalledThenThenReturnRecords() {
        Integer numberOfDays = 120;
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunitiesSelector opportunitySelectorMock = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );
        mocks.startStubbing();
        mocks.when(opportunitySelectorMock.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(opportunitySelectorMock.selectInactiveOpportunityInStalledStage(numberOfDays))
            .thenReturn(null);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(opportunitySelectorMock);
        Database.QueryLocator queryRecord = new OpportunitiesSelector()
            .selectInactiveOpportunityInStalledStage(numberOfDays);
        Database.QueryLocator queryRecord2 = OpportunitiesSelector.newInstance()
            .selectInactiveOpportunityInStalledStage(numberOfDays);
        // Assert
        ((IOpportunitiesSelector) mocks.verify(opportunitySelectorMock, 1))
            .selectInactiveOpportunityInStalledStage(numberOfDays);
        System.assertNotEquals(queryRecord, queryRecord2, 'Both Queries are same');
    }

    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        Opportunity testOpportunity1 = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = System.today().addDays(5),
            Substage__c = SUB_STAGE_UNTOUCHED
        );

        OpportunitiesSelector opportunitiesInstance = new OpportunitiesSelector();

        List<Opportunity> opportunities = opportunitiesInstance.selectById(
            new Set<Id>{ testOpportunity1.Id }
        );
        Schema.SObjectType typeOfObj = opportunitiesInstance.getSObjectType();
        List<Schema.SObjectField> fieldList = opportunitiesInstance.getSObjectFieldList();

        OpportunitiesSelector.newInstance();

        System.assertEquals(
            Schema.Opportunity.SObjectType,
            typeOfObj,
            'The object type must be Account'
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
                Opportunity.Id,
                Opportunity.Business_ID__c,
                Opportunity.Name,
                Opportunity.Description,
                Opportunity.AccountId,
                Opportunity.ContactId,
                Opportunity.CloseDate,
                Opportunity.ContractId,
                Opportunity.CreatedDate,
                Opportunity.CurrencyISOCode,
                Opportunity.Deal_Type__c,
                Opportunity.Deselected_Marketplace_Offerings__c,
                Opportunity.Drive_Nintex_Id__c,
                Opportunity.First_Activity__c,
                Opportunity.FranchiseAmendmentProcess__c,
                Opportunity.IsClosed,
                Opportunity.IsWon,
                Opportunity.Last_Activity__c,
                Opportunity.Marketplace_Nintex_Id__c,
                Opportunity.Nintex_Signed_Date__c,
                Opportunity.Nintex_Use_Case__c,
                Opportunity.Opportunity_Sub_Type__c,
                Opportunity.Opt_In_Opt_Out_Response_Time__c,
                Opportunity.Opt_Out_Save_Period__c,
                Opportunity.OwnerId,
                Opportunity.Responsible_Party__c,
                Opportunity.SBQQ__PrimaryQuote__c,
                Opportunity.Source__c,
                Opportunity.StageName,
                Opportunity.Type,
                Opportunity.Estimated_Total_Investment__c,
                Opportunity.Campaign_TLDR__c,
                Opportunity.Campaign_Program__c,
                Opportunity.Purchase_Order__c,
                Opportunity.Packages_with_Products__c,
                Opportunity.Count_of_Emails_Sent__c,
                Opportunity.Count_of_Calls_Outbound_Inbound__c,
                Opportunity.Days_OFS_to_Next_Step_Date__c,
                Opportunity.Contract_Sent_Date__c,
                Opportunity.Contract_Signed_Date__c,
                Opportunity.First_Qualified_Activity__c,
                Opportunity.Last_Qualified_Activity__c,
                Opportunity.Days_Since_Last_Activity__c,
                Opportunity.Last_Stage_Change__c,
                Opportunity.Days_Since_Last_Stage_Change__c,
                Opportunity.Account_Segment__c,
                Opportunity.First_Activity__c,
                Opportunity.Last_Activity__c,
                Opportunity.Next_Step_Date__c,
                Opportunity.Unique_Identifier__c,
                Opportunity.Pricebook2Id,
                Opportunity.Meeting_Set__c,
                Opportunity.RESSMO_Link__c
            },
            fieldList,
            'Mismatch in field list'
        );
        System.assert(opportunities != null, 'The list does not contain any opportunities');
    }

    /**
     * @description This test method to query related opportunities of accounts.
     */
    @isTest
    private static void testWhenPassingAccountIdsThenGettingRelatedOpportunities() {
        Test.startTest();
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        List<Account> accounts = new List<Account>{
            new Account(
                name = 'TestAccount1',
                RecordTypeId = accRecordTypeBusiness,
                Segment__c = SEGMENT_SMB
            ),
            new Account(
                name = 'TestAccount2',
                RecordTypeId = accRecordTypeBusiness,
                Segment__c = SEGMENT_SMB
            ),
            new Account(
                name = 'TestAccount3',
                RecordTypeId = accRecordTypeBusiness,
                Segment__c = SEGMENT_SMB
            )
        };
        insert accounts;
        //Pricebook2Id =standardPricebook,
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        List<Opportunity> opportunities = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                StageName = 'Prospecting',
                Pricebook2Id = standardPricebook.Id,
                Type = 'New',
                CloseDate = System.today(),
                AccountId = accounts[0].Id,
                Deal_Type__c = 'Standard',
                Opportunity_Sub_Type__c = 'Former Partner',
                Substage__c = SUB_STAGE_UNTOUCHED,
                Estimated_Number_of_Stores__c = 1
            ),
            new Opportunity(
                Name = 'Test2',
                StageName = 'Prospecting',
                Pricebook2Id = standardPricebook.Id,
                Type = 'New',
                CloseDate = System.today(),
                AccountId = accounts[1].Id,
                Deal_Type__c = 'Standard',
                Opportunity_Sub_Type__c = 'Former Partner',
                Substage__c = SUB_STAGE_UNTOUCHED,
                Estimated_Number_of_Stores__c = 1
            ),
            new Opportunity(
                Name = 'Test3',
                StageName = 'Prospecting',
                Pricebook2Id = standardPricebook.Id,
                Type = 'New',
                CloseDate = System.today(),
                AccountId = accounts[2].Id,
                Deal_Type__c = 'Standard',
                Opportunity_Sub_Type__c = 'Former Partner',
                Substage__c = SUB_STAGE_UNTOUCHED,
                Estimated_Number_of_Stores__c = 1
            )
        };
        insert opportunities;
        Set<Id> accountIds = new Set<Id>{ accounts[0].Id, accounts[1].Id };
        OpportunitiesSelector opportunitiesInstance = new OpportunitiesSelector();
        List<Opportunity> relatedOpportunities = opportunitiesInstance.selectOpportunitiesByAccountId(
            accountIds
        );
        Test.stopTest();
        System.assertEquals(2, relatedOpportunities.size(), 'The list size does not match');
    }

    /**
     * @description This test method checks if the relevant Open Opportunities are fetched
     * when parent Account Ids are sent.
     */
    @isTest
    private static void testWhenAccountIdsAreProvidedThenOpenRelatedOpportunitiesAreFetched() {
        Test.startTest();
        List<Account> accountList = new List<Account>{
            new Account(Name = 'Parent 1', Segment__c = SEGMENT_SMB),
            new Account(Name = 'Parent 2', Segment__c = SEGMENT_SMB)
        };
        insert accountList;

        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(Id = pricebookId, IsActive = true);
        update standardPricebook;

        List<Opportunity> opportunityList = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                StageName = 'Prospecting',
                CloseDate = Date.today() + 1,
                AccountId = accountList[0].Id,
                Pricebook2Id = pricebookId,
                Deal_Type__c = 'Standard',
                Opportunity_Sub_Type__c = 'Former Partner',
                Substage__c = SUB_STAGE_UNTOUCHED,
                Estimated_Number_of_Stores__c = 1
            ),
            new Opportunity(
                Name = 'Test2',
                StageName = 'Pitching',
                CloseDate = Date.today() + 1,
                AccountId = accountList[1].Id,
                Deal_Type__c = 'Standard',
                Opportunity_Sub_Type__c = 'Former Partner',
                Pricebook2Id = pricebookId,
                Substage__c = SUB_STAGE_DISCOVERY,
                Estimated_Number_of_Stores__c = 1
            ),
            new Opportunity(
                Name = 'Test3',
                StageName = 'Pitching',
                CloseDate = Date.today() + 1,
                AccountId = accountList[1].Id,
                Deal_Type__c = 'Standard',
                Opportunity_Sub_Type__c = 'Former Partner',
                Pricebook2Id = pricebookId,
                Substage__c = SUB_STAGE_DISCOVERY,
                Estimated_Number_of_Stores__c = 1
            )
        };
        insert opportunityList;
        Set<Id> accountIds = new Set<Id>{ accountList[0].Id, accountList[1].Id };
        OpportunitiesSelector opportunitiesInstance = new OpportunitiesSelector();
        List<Opportunity> relatedOpportunities = opportunitiesInstance.selectOpenOpportunitiesByAccountIds(
            accountIds
        );
        Test.stopTest();
        System.assertEquals(
            3,
            relatedOpportunities.size(),
            'Unexpected Error: The Open Opportunities were not fetched as expected'
        );
    }

    /**
     * @description This test method checks if Opportunities are fetched when Nintex Use Case is not blank.
     */
    @isTest
    private static void testWhenSelectOpportunitiesWithNintexUseCaseThenOpportunitiesWithNotNullNintexUseCaseReturned() {
        Test.startTest();
        //Arrange
        List<Account> accountList = new List<Account>{
            new Account(
                Name = 'Parent 1',
                Primary_Vertical__c = ACCOUNT_PRIMARY_VERTICAL,
                Segment__c = SEGMENT_SMB
            ),
            new Account(Name = 'Parent 2', Segment__c = SEGMENT_SMB)
        };
        insert accountList;

        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(Id = pricebookId, IsActive = true);
        update standardPricebook;

        Opportunity testOpp = new Opportunity(
            AccountId = accountList[0].Id,
            Name = 'Test Opportunity',
            CloseDate = System.today(),
            StageName = 'Prospecting',
            Deal_Type__c = 'Standard',
            Opportunity_Sub_Type__c = 'Former Partner',
            Estimated_Number_of_Stores__c = 1
        );
        insert testOpp;
        SBQQ__Quote__c quote = CPQTestDataFactory.createQuote(testOpp, accountList[0], null, true);
        quote.Opt_In_Out_Responsible_Party__c = 'Merchant';
        quote.Opt_In_Opt_Out_Response_Time_in_Days__c = 3;
        quote.Opt_In_Opt_Out_Decision__c = 'FSA';
        quote.Opt_Out_Save_Period_days__c = 3;
        quote.SBQQ__Primary__c = true;
        update quote;
        testOpp.SBQQ__PrimaryQuote__c = quote.Id;
        update testOpp;
        Order primaryOrder = ServiceIntegrationDataBuilder.createPrimaryOrderInstance(
            accountList[0].Id
        );
        primaryOrder.SBQQ__Quote__c = quote.Id;
        insert primaryOrder;

        Contract contract = new Contract();
        contract.AccountId = accountList[0].Id;
        contract.StartDate = system.today();
        contract.ContractTerm = 12;
        Contract.SBQQ__Order__c = primaryOrder.Id;
        insert contract;

        List<Opportunity> opportunityList = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5),
                AccountId = accountList[0].Id,
                Pricebook2Id = pricebookId,
                Nintex_Use_Case__c = 'Rate Change',
                ContractId = contract.Id,
                FranchiseAmendmentProcess__c = null,
                Opt_In_Opt_Out_Response_Time__c = null,
                Opt_Out_Save_Period__c = null,
                Responsible_Party__c = null,
                Deal_Type__c = 'Standard',
                Opportunity_Sub_Type__c = 'Former Partner',
                Estimated_Number_of_Stores__c = 1
            )
        };
        insert opportunityList;
        OpportunitiesSelector opportunitiesSelectorInstance = new OpportunitiesSelector();
        List<Opportunity> queryResult = opportunitiesSelectorInstance.selectOpportunitiesWithNintexUseCase(
            new Set<Id>{ opportunityList[0].Id }
        );
        Test.stopTest();
        System.assertEquals(1, queryResult.size(), 'The list size does not match');
    }

    /**
     * @description To test selection of Opportunities
     * having (Marketplace/Drive) Nintex Id populated by Ids.
     */ /*
    @isTest
    private static void testWhenOpprtunityIdsPassedThenReturnRecordsWithNintexId() {
        Test.startTest();
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Parent 1', Segment__c = SEGMENT_SMB),
            new Account(Name = 'Parent 2', Segment__c = SEGMENT_SMB)
        };
        insert accounts;
        Contact[] contacts = new List<Contact>{
            new Contact(
                Firstname = 'FirstName1',
                LastName = 'LastName1',
                Description = 'Test 1',
                OCR_Flag_From_Nintex__c = true,
                Email = 'abc1@gmail.com',
                AccountId = accounts[0].Id,
                Nintex_Id__c = 'TestDriveNintexId'
            ),
            new Contact(
                Firstname = 'FirstName2',
                LastName = 'LastName2',
                Description = 'Test 2',
                OCR_Flag_From_Nintex__c = true,
                Email = 'abc2@gmail.com',
                AccountId = accounts[1].Id,
                Nintex_Id__c = 'TestMarketplaceNintexId'
            )
        };
        insert contacts;
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(Id = pricebookId, IsActive = true);
        update standardPricebook;
        List<Opportunity> opportunities = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                AccountId = accounts[0].Id,
                ContactId = contacts[0].Id,
                CloseDate = Date.today() + 10,
                Drive_Nintex_Id__c = 'TestDriveNintexId',
                Nintex_Use_Case__c = 'New additional stores',
                Pricebook2Id = pricebookId,
                Source__c = SOURCE_NINTEX,
                StageName = 'Prospecting',
                Deal_Type__c = 'Standard',
                Opportunity_Sub_Type__c = 'Former Partner',
                Substage__c = SUB_STAGE_UNTOUCHED,
                Estimated_Number_of_Stores__c = 1
            ),
            new Opportunity(
                Name = 'Test2',
                AccountId = accounts[1].Id,
                ContactId = contacts[1].Id,
                CloseDate = Date.today() + 10,
                Marketplace_Nintex_Id__c = 'TestMarketplaceNintexId',
                Nintex_Use_Case__c = 'New additional stores',
                Deal_Type__c = 'Standard',
                Opportunity_Sub_Type__c = 'Former Partner',
                Pricebook2Id = pricebookId,
                Source__c = SOURCE_NINTEX,
                StageName = 'Pitching',
                Substage__c = SUB_STAGE_DISCOVERY,
                Estimated_Number_of_Stores__c = 1
            ),
            new Opportunity(
                Name = 'Test3',
                AccountId = accounts[1].Id,
                ContactId = contacts[1].Id,
                CloseDate = Date.today() + 1,
                Deal_Type__c = 'Standard',
                Opportunity_Sub_Type__c = 'Former Partner',
                Pricebook2Id = pricebookId,
                StageName = 'Pitching',
                Substage__c = SUB_STAGE_DISCOVERY,
                Estimated_Number_of_Stores__c = 1
            )
        };
        insert opportunities;
        Test.startTest();
        OpportunitiesSelector opportunitiesSelectorInstance = new OpportunitiesSelector();
        List<Opportunity> queryResult = opportunitiesSelectorInstance.selectOpportunitiesWithNintexIdById(
            new Set<Id>{ opportunities[0].Id }
        );
        queryResult = new List<Opportunity>();
        Test.stopTest();
        System.assertEquals(
            1,
            queryResult.size(),
            'Unexpected Error: The Open Opportunities were not fetched as expected.'
        );
    }

    /**
     * @description test when Opportunities are selected for update from brief
     */
    @isTest
    public static void testWhenOpportunityIsSelectedForUpdateFromBriefThenValidate() {
        Id oppId = Fake.generateId(Opportunity.class);
        Set<Id> oppIds = new Set<Id>{ oppId };
        List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>{
            Opportunity.getSObjectType().getDescribe().fields.getMap().get('Name')
        };
        List<Opportunity> testOppsList = new List<Opportunity>{
            new Opportunity(Id = oppId, Name = 'TestOpp')
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunitiesSelector opportunitySelectorMock = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );
        IOpportunityToBriefMappingSelector oppMappingSelectorMock = (IOpportunityToBriefMappingSelector) mocks.mock(
            IOpportunityToBriefMappingSelector.class
        );
        mocks.startStubbing();
        mocks.when(opportunitySelectorMock.SObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(opportunitySelectorMock.getOpportunitiesToSyncFromBriefs(oppIds))
            .thenReturn(testOppsList);
        mocks.when(oppMappingSelectorMock.getOpportunityFieldSet()).thenReturn(fieldList);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(opportunitySelectorMock);
        List<Opportunity> returnedOpps = OpportunitiesSelector.newInstance()
            .getOpportunitiesToSyncFromBriefs(oppIds);
        System.assertEquals(testOppsList, returnedOpps, 'Opportunity list does not match');
    }

    /**
     * @description This test method checks if the Opportunities are being fetched
     * when contract id is being passed.
     */
    /*@isTest
    private static void testWhenContractIdIsProvidedThenOpportunitiesAreFetched() {
        List<Account> accountList = new List<Account>{
            new Account(
                Name = 'Parent 1',
                Primary_Vertical__c = ACCOUNT_PRIMARY_VERTICAL
            )
        };
        insert accountList;

        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(Id = pricebookId, IsActive = true);
        update standardPricebook;

        Order primaryOrder = ServiceIntegrationDataBuilder.createPrimaryOrderInstance(
            accountList[0].Id
        );
        primaryOrder.SBQQ__Quote__c = quote.Id;
        insert primaryOrder;

        Contract contract = new Contract();
        contract.AccountId = accountList[0].Id;
        contract.StartDate = system.today();
        contract.ContractTerm = 12;
        Contract.SBQQ__Order__c = primaryOrder.Id;
        insert contract;

        List<Opportunity> opportunityList = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5),
                AccountId = accountList[0].Id,
                Pricebook2Id = pricebookId,
                Nintex_Use_Case__c = 'Rate Change',
                ContractId = contract.Id,
                FranchiseAmendmentProcess__c = null,
                Opt_In_Opt_Out_Response_Time__c = null,
                Opt_Out_Save_Period__c = null,
                Responsible_Party__c = null,
                Deal_Type__c = 'Standard',
                Opportunity_Sub_Type__c = 'Former Partner',
                Estimated_Number_of_Stores__c = 1
            )
        };
        insert opportunityList;
        SBQQ__Quote__c quote = CPQTestDataFactory.createQuote(
            opportunityList[0],
            accountList[0],
            null,
            true
        );
        quote.Opt_In_Out_Responsible_Party__c = 'Merchant';
        quote.Opt_In_Opt_Out_Response_Time_in_Days__c = 3;
        quote.Opt_In_Opt_Out_Decision__c = 'FSA';
        quote.Opt_Out_Save_Period_days__c = 3;
        update quote;

        Test.startTest();
        List<Opportunity> relatedOpportunities = OpportunitiesSelector.newInstance()
            .selectOpportunitiesByContractId(contract.Id);
        Test.stopTest();
        System.assertEquals(1, relatedOpportunities.size(), SIZE_MISMATCH_ASSERTION);
    }*/

    /**
     * @description test when Opportunities and child quotes are returned when accountIds are passed.
     */
    @isTest
    public static void testWhenAccountIdsPassedThenReturnOpportunitiesAndChildQuotes() {
        Test.startTest();
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Parent 1', Segment__c = SEGMENT_SMB),
            new Account(Name = 'Parent 2', Segment__c = SEGMENT_SMB)
        };
        insert accounts;
        Contact[] contacts = new List<Contact>{
            new Contact(
                Firstname = 'FirstName1',
                LastName = 'LastName1',
                Description = 'Test 1',
                Email = 'abc1@gmail.com',
                AccountId = accounts[0].Id
            ),
            new Contact(
                Firstname = 'FirstName2',
                LastName = 'LastName2',
                Description = 'Test 2',
                Email = 'abc2@gmail.com',
                AccountId = accounts[1].Id
            )
        };
        insert contacts;

        List<Opportunity> opportunities = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                AccountId = accounts[0].Id,
                ContactId = contacts[0].Id,
                CloseDate = Date.today() + 10,
                StageName = 'Prospecting',
                Deal_Type__c = 'Standard',
                Opportunity_Sub_Type__c = 'Former Partner',
                Source__c = 'Manual',
                Substage__c = SUB_STAGE_UNTOUCHED,
                Estimated_Number_of_Stores__c = 1
            ),
            new Opportunity(
                Name = 'Test2',
                AccountId = accounts[1].Id,
                ContactId = contacts[1].Id,
                CloseDate = Date.today() + 10,
                Deal_Type__c = 'Standard',
                Opportunity_Sub_Type__c = 'Former Partner',
                StageName = 'Pitching',
                Source__c = 'Manual',
                Substage__c = SUB_STAGE_DISCOVERY,
                Estimated_Number_of_Stores__c = 1
            )
        };
        insert opportunities;

        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>{
            new SBQQ__Quote__c(
                SBQQ__Status__c = 'Approved',
                SBQQ__Primary__c = true,
                SBQQ__Opportunity2__c = opportunities[0].Id
            ),
            new SBQQ__Quote__c(
                SBQQ__Status__c = 'Approved',
                SBQQ__Primary__c = false,
                SBQQ__Opportunity2__c = opportunities[0].Id
            ),
            new SBQQ__Quote__c(
                SBQQ__Status__c = 'Approved',
                SBQQ__Primary__c = true,
                SBQQ__Opportunity2__c = opportunities[1].Id
            )
        };
        insert quotes;
        List<Opportunity> queryResult = new OpportunitiesSelector()
            .selectOpportunitiesAndQuotesByAccountIds(
                new Set<Id>{ accounts[0].Id, accounts[1].Id }
            );
        Test.stopTest();
        System.assertEquals(2, queryResult.size(), MISMATCH_IN_OPPORTUNITY_COUNT_ERROR_MESSAGE);
        System.assertEquals(
            1,
            queryResult[0].SBQQ__Quotes2__r.size(),
            MISMATCH_IN_QUOTE_COUNT_ERROR_MESSAGE
        );
        System.assertEquals(
            1,
            queryResult[1].SBQQ__Quotes2__r.size(),
            MISMATCH_IN_QUOTE_COUNT_ERROR_MESSAGE
        );
        System.assertEquals(
            0,
            queryResult[1].OpportunityContactRoles.size(),
            MISMATCH_IN_QUOTE_COUNT_ERROR_MESSAGE
        );
    }
    /**
     * @description test when Opportunities and child quotes are returned when opportunity Ids are passed.
     */
    @isTest
    public static void testWhenOpportunityIdsPassedThenReturnOpportunitiesAndOCR() {
        Test.startTest();
        List<Contact> contactsToInsert = new List<Contact>();
        List<Opportunity> opportunitiesToInsert = new List<Opportunity>();
        Account account = new Account(Name = 'Parent 1', Segment__c = SEGMENT_SMB);
        insert account;
        Contact contact1 = new Contact(
            Firstname = 'FirstName1',
            LastName = 'LastName1',
            Description = 'Test 1',
            Email = 'abc1@gmail.com',
            AccountId = account.Id
        );
        contactsToInsert.add(contact1);
        Contact contact2 = new Contact(
            Firstname = 'FirstName2',
            LastName = 'LastName2',
            Description = 'Test 2',
            Email = 'abc2@gmail.com',
            AccountId = account.Id
        );
        contactsToInsert.add(contact2);
        insert contactsToInsert;
        Opportunity opportunity1 = new Opportunity(
            Name = 'Test1',
            AccountId = account.Id,
            ContactId = contact1.Id,
            CloseDate = Date.today() + 10,
            Estimated_Number_of_Stores__c = 1,
            StageName = 'Prospecting',
            Deal_Type__c = 'Standard',
            Opportunity_Sub_Type__c = 'Former Partner',
            Source__c = 'Manual',
            Substage__c = SUB_STAGE_UNTOUCHED
        );
        opportunitiesToInsert.add(opportunity1);
        Opportunity opportunity2 = new Opportunity(
            Name = 'Test2',
            AccountId = account.Id,
            ContactId = contact2.Id,
            CloseDate = Date.today() + 10,
            Estimated_Number_of_Stores__c = 1,
            StageName = 'Prospecting',
            Deal_Type__c = 'Standard',
            Opportunity_Sub_Type__c = 'Former Partner',
            Source__c = 'Manual',
            Substage__c = SUB_STAGE_UNTOUCHED
        );
        opportunitiesToInsert.add(opportunity2);
        insert opportunitiesToInsert;
        List<Opportunity> queryResult = new OpportunitiesSelector()
            .selectOpportunitiesAndOpportunityContactRolesByIds(
                new Set<Id>{ opportunity1.Id, opportunity2.Id },
                new List<Id>{ contact1.Id }
            );
        Test.stopTest();
        System.assertEquals(2, queryResult.size(), MISMATCH_IN_OPPORTUNITY_COUNT_ERROR_MESSAGE);
        System.assertEquals(
            1,
            queryResult[0].OpportunityContactRoles.size(),
            MISMATCH_IN_OCR_COUNT_ERROR_MESSAGE
        );
        System.assertEquals(
            0,
            queryResult[1].OpportunityContactRoles.size(),
            MISMATCH_IN_OCR_COUNT_ERROR_MESSAGE
        );
    }

    /**
     * @description To test if the Opportunities are returned when Account Plan Ids are passed.
     */
    @isTest
    public static void testWhenAccountPlanIdsPassedThenReturnOpportunities() {
        Test.startTest();
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Account businessAccount = new Account(
            Name = 'Name1',
            RecordTypeId = accRecordTypeBusiness,
            Segment__c = 'SMB'
        );
        insert businessAccount;
        Account_Plan__c accountPlan1 = new Account_Plan__c(
            Name = 'Test Account Plan',
            Account__c = businessAccount.Id,
            Status__c = 'Active'
        );
        insert accountPlan1;
        Account_Plan__c accountPlan2 = new Account_Plan__c(
            Name = 'Test Account Plan',
            Account__c = businessAccount.Id,
            Status__c = 'Inactive'
        );
        insert accountPlan2;
        Opportunity opportunityRecord = new Opportunity(
            Name = 'Test1',
            AccountId = businessAccount.Id,
            CloseDate = Date.today() + 10,
            Estimated_Number_of_Stores__c = 1,
            StageName = 'Prospecting',
            Deal_Type__c = 'Standard',
            Opportunity_Sub_Type__c = 'Former Partner',
            Source__c = 'Manual',
            Substage__c = SUB_STAGE_UNTOUCHED,
            Account_Plan__c = accountPlan1.Id
        );
        insert opportunityRecord;
        List<Opportunity> queryResult = new OpportunitiesSelector()
            .selectOpenOpportunitiesByAccountPlanIds(new Set<Id>{ accountPlan1.Id });
        List<Opportunity> opportunityRecords = new OpportunitiesSelector()
            .selectOpenOpportunitiesByAccountPlanIds(new Set<Id>{ accountPlan2.Id });
        Test.stopTest();
        System.assertEquals(1, queryResult.size(), MISMATCH_IN_OPPORTUNITY_COUNT_ERROR_MESSAGE);
        System.assertEquals(
            0,
            opportunityRecords.size(),
            MISMATCH_IN_OPPORTUNITY_COUNT_ERROR_MESSAGE
        );
    }

    /**
     * @description To test if the Opportunities are returned when Account Plan Ids are passed.
     */
    @isTest
    public static void testWhenAccountPlanIdsPassedThenDoNotReturnOpportunities() {
        Test.startTest();
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Account businessAccount = new Account(
            Name = 'Name1',
            RecordTypeId = accRecordTypeBusiness,
            Segment__c = 'SMB'
        );
        insert businessAccount;
        Account_Plan__c accountPlan1 = new Account_Plan__c(
            Name = 'Test Account Plan',
            Account__c = businessAccount.Id,
            Status__c = 'Active'
        );
        insert accountPlan1;
        Account_Plan__c accountPlan2 = new Account_Plan__c(
            Name = 'Test Account Plan',
            Account__c = businessAccount.Id,
            Status__c = 'Inactive'
        );
        insert accountPlan2;
        Opportunity opportunityRecord = new Opportunity(
            Name = 'Test1',
            AccountId = businessAccount.Id,
            CloseDate = Date.today() + 10,
            Estimated_Number_of_Stores__c = 1,
            StageName = 'Prospecting',
            Deal_Type__c = 'Standard',
            Opportunity_Sub_Type__c = 'Former Partner',
            Source__c = 'Manual',
            Substage__c = SUB_STAGE_UNTOUCHED,
            Account_Plan__c = accountPlan1.Id
        );
        insert opportunityRecord;
        List<Opportunity> opportunityRecords = new OpportunitiesSelector()
            .selectOpenOpportunitiesByAccountPlanIds(new Set<Id>{ accountPlan2.Id });
        Test.stopTest();
        System.assertEquals(
            0,
            opportunityRecords.size(),
            MISMATCH_IN_OPPORTUNITY_COUNT_ERROR_MESSAGE
        );
    }

    /**
     * @description It is used to test whether an opportunity exist under the passed account names.
     */
    @isTest
    public static void testWhenAccountNamePassedThenOpportunitiesWithPrimaryQuoteReturned() {
        Test.startTest();
        Account account = new Account(Name = ACCOUNT_NAME, Segment__c = SEGMENT_SMB);
        insert account;
        Contact contact = new Contact(
            Firstname = CONTACT_FIRST_NAME,
            LastName = CONTACT_LAST_NAME,
            Description = CONTACT_DESCRIPTION,
            Email = CONTACT_EMAIL,
            AccountId = account.Id
        );
        insert contact;
        Opportunity opportunity = new Opportunity(
            Name = OPPORTUNITY_NAME,
            AccountId = account.Id,
            ContactId = contact.Id,
            CloseDate = Date.today() + 10,
            Estimated_Number_of_Stores__c = 1,
            StageName = OPPORTUNITY_STAGE_NAME_PROSPECTING,
            Deal_Type__c = OPPORTUNITY_DEAL_TYPE_STANDARD,
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE_NET_NEW,
            Substage__c = SUB_STAGE_UNTOUCHED,
            Type = OPPORTUNITY_TYPE_NEW
        );
        insert opportunity;
        List<Opportunity> returnedOpps = OpportunitiesSelector.newInstance()
            .getExistingOpportunitiesAndPrimaryQuotesbyAccountNames(new Set<Id>{ account.Id });
        Test.stopTest();
        System.assertEquals(
            account.Id,
            returnedOpps[0].AccountId,
            MISMATCH_IN_OPPORTUNITY_COUNT_ERROR_MESSAGE
        );
    }

    /**
     * @description It is used to test if Opportunities are returned for New Store Expansion
     * when AccountIds are passed.
     */
    @isTest
    public static void testWhenAccountIdsPassedThenReturnOpportunitiesForNewStoreExpansion() {
        Account account = new Account(Name = ACCOUNT_NAME, Segment__c = SEGMENT_SMB);
        insert account;
        Contact contact = new Contact(
            Firstname = CONTACT_FIRST_NAME,
            LastName = CONTACT_LAST_NAME,
            Description = CONTACT_DESCRIPTION,
            Email = CONTACT_EMAIL,
            AccountId = account.Id
        );
        insert contact;
        Opportunity opportunity = new Opportunity(
            Name = OPPORTUNITY_NAME,
            AccountId = account.Id,
            ContactId = contact.Id,
            CloseDate = Date.today() + 10,
            Estimated_Number_of_Stores__c = 1,
            StageName = OPPORTUNITY_STAGE_NAME_PROSPECTING,
            Substage__c = OPPORTUNITY_SUB_STAGE_NAME_UNTOUCHED,
            Deal_Type__c = OPPORTUNITY_DEAL_TYPE_STANDARD,
            Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE_NEW_STORE_EXPANSION,
            Type = OPPORTUNITY_TYPE_EXISTING
        );
        insert opportunity;
        Test.startTest();
        List<Opportunity> returnedOpps = OpportunitiesSelector.newInstance()
            .selectNewStoreExpansionOpportunitiesByAccountIds(new Set<Id>{ account.Id });
        Test.stopTest();
        System.assertEquals(
            account.Id,
            returnedOpps[0].AccountId,
            MISMATCH_IN_OPPORTUNITY_COUNT_ERROR_MESSAGE
        );
    }

    /**
     * @description To test when Opportunity ids passes then do not return  Opportunity records with
     * associated opportunoty team members.
     */
    @isTest
    public static void testWhenOpportunityIdsArePassedThenDoNotReturnOpportunitiesWithTeamMembers() {
        Test.startTest();
        List<Contact> contactsToInsert = new List<Contact>();
        List<Opportunity> opportunitiesToInsert = new List<Opportunity>();
        Account account = new Account(Name = 'Parent 1', Segment__c = SEGMENT_SMB);
        insert account;
        Contact contact1 = new Contact(
            Firstname = 'FirstName1',
            LastName = 'LastName1',
            Description = 'Test 1',
            Email = 'abc1@gmail.com',
            AccountId = account.Id
        );
        contactsToInsert.add(contact1);
        Contact contact2 = new Contact(
            Firstname = 'FirstName2',
            LastName = 'LastName2',
            Description = 'Test 2',
            Email = 'abc2@gmail.com',
            AccountId = account.Id
        );
        contactsToInsert.add(contact2);
        insert contactsToInsert;
        Opportunity opportunity1 = new Opportunity(
            Name = 'Test1',
            AccountId = account.Id,
            ContactId = contact1.Id,
            CloseDate = Date.today() + 10,
            Estimated_Number_of_Stores__c = 1,
            StageName = 'Prospecting',
            Deal_Type__c = 'Standard',
            Opportunity_Sub_Type__c = 'Former Partner',
            Source__c = 'Manual',
            Substage__c = SUB_STAGE_UNTOUCHED
        );
        opportunitiesToInsert.add(opportunity1);
        Opportunity opportunity2 = new Opportunity(
            Name = 'Test2',
            AccountId = account.Id,
            ContactId = contact2.Id,
            CloseDate = Date.today() + 10,
            Estimated_Number_of_Stores__c = 1,
            StageName = 'Prospecting',
            Deal_Type__c = 'Standard',
            Opportunity_Sub_Type__c = 'Former Partner',
            Source__c = 'Manual',
            Substage__c = SUB_STAGE_UNTOUCHED
        );
        opportunitiesToInsert.add(opportunity2);
        insert opportunitiesToInsert;
        OpportunityTeamMember opportunityTeamMember1 = new OpportunityTeamMember(
            OpportunityId = opportunity1.Id,
            TeamMemberRole = ACCOUNT_EXECUTIVE_ROLE,
            UserId = UserInfo.getUserID()
        );
        insert opportunityTeamMember1;
        List<Opportunity> results = new OpportunitiesSelector()
            .selectOpportunityAndRelatedOpportunityTeamMemberByOpportunityIds(
                new Set<Id>{ opportunity1.Id }
            );
        Test.stopTest();
        System.assertEquals(1, results.size(), MISMATCH_IN_OPPORTUNITY_COUNT_ERROR_MESSAGE);
        System.assertEquals(
            results[0].OpportunityTeamMembers.size(),
            0,
            NO_TEAM_PRESENT_ON_OPPORTUNITY_ASSERT_MESSAGE
        );
    }
    /**
     * @description To test when Opportunity ids passes then return  Opportunity records with
     * associated opportunoty team members.
     */
    @isTest
    public static void testWhenOpportunityIdsArePassedThenReturnOpportunitiesWithTeamMembers() {
        Test.startTest();
        Account account = new Account(Name = 'Parent 1', Segment__c = SEGMENT_SMB);
        insert account;
        Contact contact1 = new Contact(
            Firstname = 'FirstName1',
            LastName = 'LastName1',
            Description = 'Test 1',
            Email = 'abc1@gmail.com',
            AccountId = account.Id
        );
        insert contact1;
        Opportunity opportunity1 = new Opportunity(
            Name = 'Test1',
            AccountId = account.Id,
            ContactId = contact1.Id,
            CloseDate = Date.today() + 10,
            Estimated_Number_of_Stores__c = 1,
            StageName = 'Prospecting',
            Deal_Type__c = 'Standard',
            Opportunity_Sub_Type__c = 'Former Partner',
            Source__c = 'Manual',
            Substage__c = SUB_STAGE_UNTOUCHED
        );
        insert opportunity1;
        OpportunityTeamMember opportunityTeamMember1 = new OpportunityTeamMember(
            OpportunityId = opportunity1.Id,
            TeamMemberRole = SALES_DEVELOPMENT_REP,
            UserId = UserInfo.getUserID()
        );
        insert opportunityTeamMember1;
        List<Opportunity> results = new OpportunitiesSelector()
            .selectOpportunityAndRelatedOpportunityTeamMemberByOpportunityIds(
                new Set<Id>{ opportunity1.Id }
            );
        Test.stopTest();
        System.assertEquals(1, results.size(), MISMATCH_IN_OPPORTUNITY_COUNT_ERROR_MESSAGE);
        System.assertEquals(
            results[0].OpportunityTeamMembers.size(),
            1,
            NO_TEAM_PRESENT_ON_OPPORTUNITY_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test selection of Opportunities by Ids
     * having (Marketplace/Drive) Nintex Id populated for 'SSMO' Nintex use case with ContractId.
     */
    /*@isTest
    private static void testWhenNintexSSMOOpportunityIdsHavingContractIdPassedThenReturnOpportunityDetails() {
        Test.startTest();
        Account mockAccount = new Account(Name = 'Parent', Segment__c = SEGMENT_SMB);
        insert mockAccount;
        Contact mockContact = new Contact(
            Firstname = 'First Name',
            LastName = 'Last Name',
            Description = 'Description',
            OCR_Flag_From_Nintex__c = true,
            Email = 'contact@doordash.com',
            AccountId = mockAccount.Id,
            Nintex_Id__c = 'MockMarketplaceNintexId'
        );
        insert mockContact;
        Id standardPricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(Id = standardPricebookId, IsActive = true);
        update standardPricebook;
        Opportunity mockOpportunity = new Opportunity(
            AccountId = mockAccount.Id,
            Name = 'Mock Standard Opportunity',
            CloseDate = System.today(),
            StageName = 'Prospecting',
            Deal_Type__c = 'Standard',
            Opportunity_Sub_Type__c = 'Former Partner',
            Estimated_Number_of_Stores__c = 1
        );
        insert mockOpportunity;
        SBQQ__Quote__c mockQuote = CPQTestDataFactory.createQuote(
            mockOpportunity,
            mockAccount,
            null,
            true
        );
        mockQuote.Opt_In_Out_Responsible_Party__c = 'Merchant';
        mockQuote.Opt_In_Opt_Out_Response_Time_in_Days__c = 3;
        mockQuote.Opt_In_Opt_Out_Decision__c = 'FSA';
        mockQuote.Opt_Out_Save_Period_days__c = 3;
        mockQuote.SBQQ__Primary__c = true;
        update mockQuote;
        mockOpportunity.SBQQ__PrimaryQuote__c = mockQuote.Id;
        update mockOpportunity;
        Order mockPrimaryOrder = ServiceIntegrationDataBuilder.createPrimaryOrderInstance(
            mockAccount.Id
        );
        mockPrimaryOrder.SBQQ__Quote__c = mockQuote.Id;
        insert mockPrimaryOrder;
        Contract mockContract = new Contract(
            AccountId = mockAccount.Id,
            StartDate = System.today(),
            ContractTerm = 12,
            SBQQ__Order__c = mockPrimaryOrder.Id
        );
        insert mockContract;
        Opportunity mockNintexSSMOOpportunity = new Opportunity(
            Name = 'Nintex SSMO Opportunity',
            StageName = 'Needs Analysis',
            CloseDate = System.today().addDays(5),
            AccountId = mockAccount.Id,
            Pricebook2Id = standardPricebookId,
            Marketplace_Nintex_Id__c = 'MockMarketplaceNintexId',
            Nintex_Use_Case__c = 'SSMO',
            ContractId = mockContract.Id,
            FranchiseAmendmentProcess__c = null,
            Opt_In_Opt_Out_Response_Time__c = null,
            Opt_Out_Save_Period__c = null,
            Responsible_Party__c = null,
            Deal_Type__c = 'Standard',
            Opportunity_Sub_Type__c = 'Former Partner',
            Estimated_Number_of_Stores__c = 1
        );
        insert mockNintexSSMOOpportunity;
        List<Opportunity> queryResult = OpportunitiesSelector.newInstance()
            .selectOpportunitiesWithNintexIdById(new Set<Id>{ mockNintexSSMOOpportunity.Id });
        Test.stopTest();
        System.assertEquals(
            1,
            queryResult.size(),
            'Unexpected Result: The Nintex SSMO Opportunity not fetched.'
        );
    }*/

    /**
     * @description To test selection of Opportunities by Ids
     * having (Marketplace/Drive) Nintex Id populated for 'SSMO' Nintex use case without ContractId.
     */
    @isTest
    private static void testWhenNintexSSMOOpportunityIdsNotHavingContractIdPassedThenReturnEmptyList() {
        Test.startTest();
        Account mockAccount = new Account(Name = 'Parent', Segment__c = SEGMENT_SMB);
        insert mockAccount;
        Contact mockContact = new Contact(
            Firstname = 'First Name',
            LastName = 'Last Name',
            Description = 'Description',
            OCR_Flag_From_Nintex__c = true,
            Email = 'contact@doordash.com',
            AccountId = mockAccount.Id,
            Nintex_Id__c = 'MockMarketplaceNintexId'
        );
        insert mockContact;
        Id standardPricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(Id = standardPricebookId, IsActive = true);
        update standardPricebook;
        Opportunity mockOpportunity = new Opportunity(
            AccountId = mockAccount.Id,
            Name = 'Mock Standard Opportunity',
            CloseDate = System.today(),
            StageName = 'Prospecting',
            Deal_Type__c = 'Standard',
            Opportunity_Sub_Type__c = 'Former Partner',
            Estimated_Number_of_Stores__c = 1
        );
        insert mockOpportunity;
        SBQQ__Quote__c mockQuote = CPQTestDataFactory.createQuote(
            mockOpportunity,
            mockAccount,
            null,
            true
        );
        mockQuote.Opt_In_Out_Responsible_Party__c = 'Merchant';
        mockQuote.Opt_In_Opt_Out_Response_Time_in_Days__c = 3;
        mockQuote.Opt_In_Opt_Out_Decision__c = 'FSA';
        mockQuote.Opt_Out_Save_Period_days__c = 3;
        mockQuote.SBQQ__Primary__c = true;
        update mockQuote;
        mockOpportunity.SBQQ__PrimaryQuote__c = mockQuote.Id;
        update mockOpportunity;
        Order mockPrimaryOrder = ServiceIntegrationDataBuilder.createPrimaryOrderInstance(
            mockAccount.Id
        );
        mockPrimaryOrder.SBQQ__Quote__c = mockQuote.Id;
        insert mockPrimaryOrder;
        Contract mockContract = new Contract(
            AccountId = mockAccount.Id,
            StartDate = System.today(),
            ContractTerm = 12,
            SBQQ__Order__c = mockPrimaryOrder.Id
        );
        insert mockContract;
        Opportunity mockNintexSSMOOpportunity = new Opportunity(
            Name = 'Nintex SSMO Opportunity',
            StageName = 'Needs Analysis',
            CloseDate = System.today().addDays(5),
            AccountId = mockAccount.Id,
            Pricebook2Id = standardPricebookId,
            Nintex_Use_Case__c = 'SSMO',
            FranchiseAmendmentProcess__c = null,
            Opt_In_Opt_Out_Response_Time__c = null,
            Opt_Out_Save_Period__c = null,
            Responsible_Party__c = null,
            Deal_Type__c = 'Standard',
            Opportunity_Sub_Type__c = 'Former Partner',
            Estimated_Number_of_Stores__c = 1
        );
        insert mockNintexSSMOOpportunity;
        List<Opportunity> queryResult = OpportunitiesSelector.newInstance()
            .selectOpportunitiesWithNintexIdById(new Set<Id>{ mockNintexSSMOOpportunity.Id });
        Test.stopTest();
        System.assertEquals(
            true,
            queryResult.isEmpty(),
            'Unexpected Result: The Nintex SSMO Opportunity incorrectly fetched.'
        );
    }

    /**
     * @description test When Select OpportunityContactRole Then Contract Signatory Role to be returned
     * @author SamikshaDD | 08-02-2024
     **/
    @isTest
    public static void testWhenSelectOpportunityContactRoleThenContractSignatory() {
        Account account = new Account(Name = 'Testing Account 1', Segment__c = SEGMENT_SMB);
        insert account;
        Contact contact = new Contact(
            Firstname = CONTACT_FIRST_NAME,
            LastName = CONTACT_LAST_NAME,
            Email = 'abc@doordash.com',
            Phone = '1234567890',
            AccountId = account.Id
        );
        insert contact;

        Opportunity opportunity = new Opportunity(
            Name = OPPORTUNITY_NAME,
            AccountId = account.Id,
            StageName = 'Prospecting',
            Substage__c = 'Untouched',
            CloseDate = System.today().addDays(5),
            Deal_Type__c = 'Standard',
            Type = 'New',
            Opportunity_Sub_Type__c = 'Net New Partner',
            Estimated_Number_of_Stores__c = 1
        );
        insert opportunity;

        OpportunityContactRole opportunitycontactrole = new OpportunityContactRole(
            OpportunityId = opportunity.Id,
            ContactId = contact.Id,
            Role = CONTRACT_SIGNATORY_CONTACT_ROLE
        );
        insert opportunitycontactrole;

        Map<String, Set<String>> objectToSobjectsFields = new Map<String, Set<String>>();
        objectToSobjectsFields.put(
            'Contact',
            new Set<String>{ 'contact.Id', 'contact.FirstName', 'contact.LastName' }
        );

        OpportunitiesSelector opportunitiesSelectorInstance = new OpportunitiesSelector();
        Opportunity queryResult = opportunitiesSelectorInstance.selectOpportunityContactRoleByOpportunityId(
            opportunity.Id,
            objectToSobjectsFields
        );

        Assert.areEqual(
            opportunitycontactrole.OpportunityId,
            queryResult.Id,
            'Opportunity does not Match'
        );
    }
}
