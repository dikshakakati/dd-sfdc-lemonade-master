/**
 * @author Deloitte
 * @date 28/02/2022
 * @description This is the test class for Opportunities domain class
 */
@isTest(seeAllData=false)
@SuppressWarnings('PMD.NcssTypeCount,PMD.NcssLineCount,PMD.ExcessiveClassLength')
private class OpportunitiesTest {
    private static final String ACCOUNT_NAME_BUSINESS = 'Test Business';
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    private static final String ACCOUNT_SEGMENT_ENTERPRISE = 'Enterprise';
    private static final String ASSERT_MESSAGE = 'Unexpected Result: Last Inbound Date is null';
    private static final String BRAND_NAME = 'Test Brand';
    private static final Id BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Business')
        .getRecordTypeId();
    private static final String BUSINESS_ACCOUNT_RECORD_TYPE_NAME = 'Business';
    private static final String CONTRACTING_OPPORTUNITIES_ERROR_ASSERT_MESSAGE = 'Unexpected result: The error message was thrown for Opportunity with Work Order';
    private static final String CONTRACTING_STAGENAME_ERROR_ASSERT_MESSAGE = 'Unexpected result: The error message was thrown for Opportunity where Stage Name is not Contracting';
    private static final String OPPORTUNITY_NAME = 'Test Opportunity';
    private static final String STAGENAME_CONTRACTING = 'Contracting';
    private static final String SUB_TYPE = 'Ads & Promos';
    static final String EVENT_TOPIC_OPPORTUNITY_TEAM_MEMBER_CREATION = 'EVENT_TOPIC_OPPORTUNITY_TEAM_MEMBER_CREATION';
    private static final string EXISTING_TYPE = 'Existing';
    static final String DEAL_TYPE = 'Self-Serve';
    private static final String EVENT_STATUS_HELD = 'Event Held';
    private static final String EVENT_STATUS_MISSED = 'Event Missed';
    private static final String MEDAL_RANK_GOLD = 'Gold';
    private static final String DECK_RANK_JACK = 'Jack';
    private static final String GENERIC_WORK_ORDER_CREATION = 'WORK_ORDER_GENERATION';
    private static final String OPPORTUNITIES_ERROR_ASSERT_MESSAGE = 'Unexpected result: The values for Deck Rank At Closed Stage or Medal Rank At Closed Stage are mismatching';
    private static final String OPPORTUNITIES_STAGE_UPDATE_ASSERT_MESSAGE = 'Unexpected Error: The Opportunity updation was not successful and the error was fired.';
    private static final String OPPORTUNITIES_NO_HELD_EVENT_ASSERT_ERROR_MESSAGE = 'Unexpected Error: The Opportunity updation was successful and the error was not fired as expected.';
    private static final String OPPORTUNITY_NEGOTIATING_STAGE = 'Negotiating';
    private static final String NEW_TYPE = 'New';
    private static final String ACCOUNTPLANID_ERROR_ASSERT_MESSAGE = 'Unable to update AccountPlanId while inserting Opportunity';
    private static final String ACCOUNT_NAME = 'Test Account';
    private static final String ACCOUNT_PLAN_NAME = 'Account Plan';
    private static final String ACTIVE = 'Active';
    private static final String PITCHING = 'Pitching';
    private static final String SUB_TYPE_NEW_STORE_EXPANSION = 'New Store Expansion';
    private static final String SOURCE_MX_PORTAL = 'Mx Portal';
    private static final String SOURCE_NINTEX = 'Nintex';
    private static final String VSP_OPPORTUNITY_NAME_ASSERT_MESSAGE = 'The opportunity Name has been assigned correctly';
    private static final String NON_VSP_OPPORTUNITY_NAME_ASSERT_MESSAGE = 'The NON opportunity Name has not been assigned correctly';
    private static final String NO_ERROR_MESSAGE = 'No error shown';
    private static final String SOURCE_MANUAL = 'Manual';
    private static final String SOURCE_VSP_RECOMMENDATION = 'VSP Recommendation';
    private static final String STAGE_NAME_PROSPECTING = 'Prospecting';
    private static final String SUB_TYPE_RESCUE = 'Rescue';
    private static final String SUB_TYPE_COO = 'COO';
    private static final String CAMPAIGN_PRODUCT_NAME = 'Product 1';
    private static final String CAMPAIGN_PRODUCT_FAMILY_STOREFRONT = 'Storefront';
    private static final String PRODUCT_INSIGITS_INTERESET_LEVEL = 'Neutral';
    private static final String PRODUCT_INSIGITS_ORIGIN = 'VSP Recommendation';
    private static final String VSP = '-VSP:';
    static final String HYPHEN_WITH_UNTRIMMED_SPACE = ' - ';
    static final String QUARTER_FOUR = ' - Q4 ';
    static final String ORDER_TYPE_CORE= 'Core';

    @isTest
    private static void testWhenOpportunityInsertThenNameAssigned() {
        Integer year = system.today().year();
        String month = '5';
        String day = '17';
        String calculatedCloseDate = year + '-' + month + '-' + day;
        Date opportunityCloseDate = Date.valueOf(calculatedCloseDate);
        List<Account> accountList = new List<Account>{
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 1'),
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 2')
        };
        List<Opportunity> opportunitiesRec = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                StageName = 'Needs Analysis',
                CloseDate = opportunityCloseDate,
                AccountId = accountList[0].Id
            ),
            new Opportunity(
                Name = 'Test2',
                StageName = 'Needs Analysis',
                CloseDate = opportunityCloseDate,
                AccountId = accountList[1].Id,
                Opportunity_Sub_Type__c = 'Net New Partner'
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        IOpportunities opptInstance = Opportunities.newInstance(opportunitiesRec);
        mocks.startStubbing();

        mocks.when(selectorMock.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectByOpportunity(opportunitiesRec)).thenReturn(accountList);

        mocks.stopStubbing();
        Application.Selector.setMock(selectorMock);
        String last2DigitsOfYear = String.valueOf(opportunitiesRec[0].CloseDate.year()).right(2);
        opptInstance.assignNameOnInsertOrNameUpdate();
        System.assertEquals(
             'Parent 1 - Q2 ' +
            last2DigitsOfYear +
            ': Test1',
            opportunitiesRec[0].Name,
            'The opportunity Name has not been assigned correctly'
        );
        System.assertEquals(
             'Parent 2 - Q2 ' +
            last2DigitsOfYear +
            ' - Net New Partner: Test2',
            opportunitiesRec[1].Name,
            'The opportunity Name has not been assigned correctly'
        );
    }

    @isTest
    private static void testWhenOpportunityIsUpdatedThenNameIsAssigned() {
        Integer year = System.today().year();
        String month = '6';
        String day = '17';
        String calculatedCloseDate = year + '-' + month + '-' + day;
        Date opportunityCloseDate = Date.valueOf(calculatedCloseDate);
        List<Account> accountList = new List<Account>{
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 1'),
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 2')
        };

        Id opportunity1 = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id opportunity2 = fflib_IDGenerator.generate(Opportunity.SObjectType);

        List<Opportunity> opportunitiesRec = new List<Opportunity>{
            new Opportunity(
                Id = opportunity1,
                Name = 'Parent 1 - Q2 28  - Upgrade: Test1',
                StageName = 'Prospecting',
                CloseDate = opportunityCloseDate,
                AccountId = accountList[0].Id,
                Opportunity_Sub_Type__c = 'Upgrade'
            ),
            new Opportunity(
                Id = opportunity2,
                Name = 'Parent 2 - Q2 22 - Net New Partner: Test2',
                StageName = 'Prospecting',
                CloseDate = opportunityCloseDate,
                AccountId = accountList[1].Id,
                Opportunity_Sub_Type__c = 'Net New Partner'
            )
        };
        List<Opportunity> oldOpportunitiesRec = new List<Opportunity>{
            new Opportunity(
                Id = opportunity1,
                Name = 'Parent 1 - Q2 28 - Upgrade: Test1',
                StageName = 'Prospecting',
                CloseDate = opportunityCloseDate,
                AccountId = accountList[0].Id,
                Opportunity_Sub_Type__c = 'Upgrade'
            ),
            new Opportunity(
                Id = opportunity2,
                Name = 'Parent 2 - Q2 22 - Net New Partner: Test2',
                StageName = 'Prospecting',
                CloseDate = opportunityCloseDate,
                AccountId = accountList[1].Id,
                Opportunity_Sub_Type__c = 'Net New Partner'
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        IOpportunities opptInstance = Opportunities.newInstance(opportunitiesRec);
        mocks.startStubbing();

        mocks.when(selectorMock.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectByOpportunity(opportunitiesRec)).thenReturn(accountList);
        mocks.stopStubbing();
        Application.Selector.setMock(selectorMock);

        opptInstance.assignNameOnNamingComponentsUpdates(
            new Map<Id, Opportunity>(oldOpportunitiesRec)
        );
        String last2DigitsOfYear = String.valueOf(oldOpportunitiesRec[1].CloseDate.year()).right(2);
        System.assertEquals(
             'Parent 2 - Q2 ' +
            last2DigitsOfYear +
            ' - Net New Partner: ',
            opportunitiesRec[1].Name,
            'The opportunity Name has not been assigned correctly'
        );
    }

    /**
     * @description To validate that when the name is changed on an open Opportunity
     * then no error message is displayed.
     */
    @isTest
    private static void testWhenNameUpdatedOnNonClosedOpportunitThenErrorNotDisplayed() {
        List<Account> accountList = new List<Account>{
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 1'),
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 2')
        };

        Id opportunity1 = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id opportunity2 = fflib_IDGenerator.generate(Opportunity.SObjectType);

        List<Opportunity> oldOpportunitiesRec = new List<Opportunity>{
            new Opportunity(
                Id = opportunity1,
                Name = 'Parent 1 - Q2 28 - Test1',
                StageName = 'Prospecting',
                CloseDate = System.today().addDays(3),
                AccountId = accountList[0].Id
            ),
            new Opportunity(
                Id = opportunity2,
                Name = 'Parent 2 - Q2 28 - Net New Partner - Test2',
                StageName = 'Prospecting',
                CloseDate = System.today().addDays(3),
                AccountId = accountList[1].Id,
                Opportunity_Sub_Type__c = 'Net New Partner'
            )
        };

        List<Opportunity> opportunitiesRec = new List<Opportunity>{
            new Opportunity(
                Id = opportunity1,
                Name = 'Test1',
                StageName = 'Prospecting',
                CloseDate = System.today().addDays(3),
                AccountId = accountList[0].Id
            ),
            new Opportunity(
                Id = opportunity2,
                Name = 'Test2',
                StageName = 'Prospecting',
                CloseDate = System.today().addDays(3),
                AccountId = accountList[1].Id,
                Opportunity_Sub_Type__c = 'Net New Partner'
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        IOpportunities opptInstance = Opportunities.newInstance(opportunitiesRec);
        mocks.startStubbing();

        mocks.when(selectorMock.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectByOpportunity(opportunitiesRec)).thenReturn(accountList);

        mocks.stopStubbing();
        Application.Selector.setMock(selectorMock);

        opptInstance.validateOpportunityNameChange(new Map<Id, Opportunity>(oldOpportunitiesRec));
        //Assertion
        System.assertEquals(
            true,
            fflib_SObjects.Errors.getAll().isEmpty(),
            'Unexpected Result: Name change validation message was thrown for an open Opportuntiy'
        );
    }

    @isTest
    private static void testWhenNotClosedAdsAndPromosOpportunityNameIsUpdatedThenErrorIsNotDisplayed() {
        List<Account> accountList = new List<Account>{
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 1'),
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 2')
        };

        Id opportunity1 = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id opportunity2 = fflib_IDGenerator.generate(Opportunity.SObjectType);

        List<Opportunity> oldOpportunitiesRec = new List<Opportunity>{
            new Opportunity(
                Id = opportunity1,
                Name = 'Parent 1 - Q2 28 - Test1',
                StageName = 'Prospecting',
                CloseDate = System.today().addDays(3),
                AccountId = accountList[0].Id,
                Opportunity_Sub_Type__c = SUB_TYPE
            ),
            new Opportunity(
                Id = opportunity2,
                Name = 'Parent 2 - Q2 28 - Net New Partner - Test2',
                StageName = 'Prospecting',
                CloseDate = System.today().addDays(3),
                AccountId = accountList[1].Id,
                Opportunity_Sub_Type__c = SUB_TYPE
            )
        };

        List<Opportunity> opportunitiesRec = new List<Opportunity>{
            new Opportunity(
                Id = opportunity1,
                Name = 'Test1',
                StageName = 'Prospecting',
                CloseDate = System.today().addDays(3),
                AccountId = accountList[0].Id,
                Opportunity_Sub_Type__c = SUB_TYPE
            ),
            new Opportunity(
                Id = opportunity2,
                Name = 'Test2',
                StageName = 'Prospecting',
                CloseDate = System.today().addDays(3),
                AccountId = accountList[1].Id,
                Opportunity_Sub_Type__c = SUB_TYPE
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        IOpportunities opptInstance = Opportunities.newInstance(opportunitiesRec);
        mocks.startStubbing();

        mocks.when(selectorMock.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectByOpportunity(opportunitiesRec)).thenReturn(accountList);

        mocks.stopStubbing();
        Application.Selector.setMock(selectorMock);

        opptInstance.validateOpportunityNameChange(new Map<Id, Opportunity>(oldOpportunitiesRec));
        //Assertion
        System.assertEquals(0, fflib_SObjects.Errors?.getAll().size(), 'No error shown');
    }

    @isTest
    private static void testWhenClosedOpportunityNameIsUpdatedThenErrorIsDisplayed() {
        List<Account> accountList = new List<Account>{
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 1')
        };
        Id opportunityRecordId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Fake oldOpportunityFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityRecordId)
            .setField(Opportunity.AccountId, accountList[0].Id)
            .setField(Opportunity.Name, 'Parent 1 - Q2 28 - Test1')
            .setField(Opportunity.CloseDate, System.today().addDays(3))
            .setField(Opportunity.IsClosed, true)
            .setField(Opportunity.StageName, 'Closed Lost');
        List<Opportunity> oldOpportunitiesRec = new List<Opportunity>{
            (Opportunity) oldOpportunityFakeInstance.toSObject()
        };
        List<Opportunity> opportunitiesRec = new List<Opportunity>{
            (Opportunity) oldOpportunityFakeInstance.setField(Opportunity.Name, 'Test1').toSObject()
        };
        IOpportunities opptInstance = Opportunities.newInstance(opportunitiesRec);
        opptInstance.validateOpportunityNameChange(new Map<Id, Opportunity>(oldOpportunitiesRec));
        //Assertion
        System.assertEquals(
            System.Label.Opportunity_Name_Change_Error,
            fflib_SObjects.Errors.getAll()[0].message,
            'Unexpected Error'
        );
    }

    @isTest
    private static void testWhenOpportunityIsReparentedWithAccessThenValidate() {
        //Arrange

        List<Account> accountList = new List<Account>{
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 1'),
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 2')
        };

        List<Opportunity> opportunitiesRec = new List<Opportunity>{
            new Opportunity(
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Name = 'Test1',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(3),
                AccountId = accountList[0].Id
            ),
            new Opportunity(
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Name = 'Test2',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(3),
                AccountId = accountList[0].Id,
                Opportunity_Sub_Type__c = 'Net New Partner'
            )
        };
        //Adding Quotes and linking them to Opportunity
        List<SBQQ__Quote__c> childQuotes = new List<SBQQ__Quote__c>{
            new SBQQ__Quote__c(
                Id = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType),
                SBQQ__Opportunity2__c = opportunitiesRec[0].Id
            )
        };

        //Mocking QuotesSelector
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IQuotesSelector quotesSelectorMock = (IQuotesSelector) mocks.mock(IQuotesSelector.class);
        IOpportunities opptInstance = Opportunities.newInstance(opportunitiesRec);
        mocks.startStubbing();

        mocks.when(quotesSelectorMock.SObjectType()).thenReturn(SBQQ__Quote__c.SObjectType);
        mocks.when(
                quotesSelectorMock.selectByOpportunity(
                    new Set<Id>{ opportunitiesRec[0].Id, opportunitiesRec[1].Id }
                )
            )
            .thenReturn(childQuotes);

        mocks.stopStubbing();

        Application.Selector.setMock(quotesSelectorMock);
        opptInstance.opportunityReparentingValidation(
            new List<Opportunity>{ opportunitiesRec[0], opportunitiesRec[1] },
            opptInstance.getOpportunitiesWithQuotes(
                new List<Opportunity>{ opportunitiesRec[0], opportunitiesRec[1] }
            )
        );

        ApexPages.Message quoteFailureMessage = new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'This opportunity has an associated quote and is therefore unable to be re-parented.'
        );

        //Assertion
        System.assertEquals(
            1,
            ApexPages.getMessages().size(),
            'The Opportunity with linked quote did not fire an error'
        );
        System.assertEquals(quoteFailureMessage, ApexPages.getMessages()[0], 'Message');
        System.assertNotEquals(null, opportunitiesRec[0].AccountId, 'Opportunity is orphaned');
    }

    @isTest
    private static void testWhenPitchAmountIsChangedForOpptyWithQuoteThenNotifyWithError() {
        //Arrange

        List<Account> accountList = new List<Account>{
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 1'),
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 2')
        };

        List<Opportunity> opportunitiesRec = new List<Opportunity>{
            new Opportunity(
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Name = 'Test1',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(3),
                Pitch_Amount__c = 10,
                AccountId = accountList[0].Id
            ),
            new Opportunity(
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Name = 'Test2',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(3),
                AccountId = accountList[0].Id,
                Pitch_Amount__c = 80,
                Opportunity_Sub_Type__c = 'Net New Partner'
            )
        };
        //Adding Quotes and linking them to Opportunity
        List<SBQQ__Quote__c> childQuotes = new List<SBQQ__Quote__c>{
            new SBQQ__Quote__c(
                Id = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType),
                SBQQ__Opportunity2__c = opportunitiesRec[0].Id
            )
        };

        //Mocking QuotesSelector
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IQuotesSelector quotesSelectorMock = (IQuotesSelector) mocks.mock(IQuotesSelector.class);
        IOpportunities opptInstance = Opportunities.newInstance(opportunitiesRec);
        mocks.startStubbing();

        mocks.when(quotesSelectorMock.SObjectType()).thenReturn(SBQQ__Quote__c.SObjectType);
        mocks.when(
                quotesSelectorMock.selectByOpportunity(
                    new Set<Id>{ opportunitiesRec[0].Id, opportunitiesRec[1].Id }
                )
            )
            .thenReturn(childQuotes);

        mocks.stopStubbing();

        Application.Selector.setMock(quotesSelectorMock);
        opptInstance.validateChangeInPitchAmount(
            opptInstance.getOpportunitiesWithQuotes(
                new List<Opportunity>{ opportunitiesRec[0], opportunitiesRec[1] }
            )
        );
        //Assertion
        System.assertEquals(
            System.Label.Opportunity_Pitch_Amount_validation,
            fflib_SObjects.Errors.getAll()[0].message,
            'Unexpected Error'
        );
    }

    @isTest
    private static void testWhenSubTypeIsChangedForContractingOpportunityThenNotifyWithError() {
        //Arrange

        List<Account> accountList = new List<Account>{
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 1'),
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 2')
        };

        List<Opportunity> opportunitiesRec = new List<Opportunity>{
            new Opportunity(
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Name = 'Test1',
                StageName = 'Contracting',
                CloseDate = System.today().addDays(3),
                Pitch_Amount__c = 10,
                AccountId = accountList[0].Id,
                Opportunity_Sub_Type__c = 'Net New Partner'
            )
        };
        IOpportunities opptInstance = Opportunities.newInstance(opportunitiesRec);
        opptInstance.validateChangeInSubType();
        //Assertion
        System.assertEquals(
            System.Label.Contract_Correction,
            fflib_SObjects.Errors.getAll()[0].message,
            'Unexpected Error'
        );
    }

    @isTest
    private static void testWhenOpportunitiesInContextHaveQuotesLinkedThenReturnSetOfOpportunitiesIds() {
        //Arrange

        List<Account> accountList = new List<Account>{
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 1'),
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 2')
        };

        List<Opportunity> opportunitiesRec = new List<Opportunity>{
            new Opportunity(
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Name = 'Test1',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(3),
                Pitch_Amount__c = 10,
                AccountId = accountList[0].Id
            ),
            new Opportunity(
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Name = 'Test2',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(3),
                AccountId = accountList[0].Id,
                Pitch_Amount__c = 80,
                Opportunity_Sub_Type__c = 'Net New Partner'
            )
        };
        //Adding Quotes and linking them to Opportunity
        List<SBQQ__Quote__c> childQuotes = new List<SBQQ__Quote__c>{
            new SBQQ__Quote__c(
                Id = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType),
                SBQQ__Opportunity2__c = opportunitiesRec[0].Id
            )
        };

        //Mocking QuotesSelector
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IQuotesSelector quotesSelectorMock = (IQuotesSelector) mocks.mock(IQuotesSelector.class);
        IOpportunities opptInstance = Opportunities.newInstance(opportunitiesRec);
        mocks.startStubbing();

        mocks.when(quotesSelectorMock.SObjectType()).thenReturn(SBQQ__Quote__c.SObjectType);
        mocks.when(
                quotesSelectorMock.selectByOpportunity(
                    new Set<Id>{ opportunitiesRec[0].Id, opportunitiesRec[1].Id }
                )
            )
            .thenReturn(childQuotes);

        mocks.stopStubbing();

        Application.Selector.setMock(quotesSelectorMock);
        Set<Id> opportuntiesWithQuote = opptInstance.getOpportunitiesWithQuotes(
            new List<Opportunity>{ opportunitiesRec[0], opportunitiesRec[1] }
        );

        System.assertEquals(
            new Set<Id>{ opportunitiesRec[0].Id },
            opportuntiesWithQuote,
            'The expected set of Opportunity Ids were not returned'
        );
    }

    @isTest
    private static void testWhenOpportunityIsReparentedWithoutAccessThenValidate() {
        //Arrange
        String bypassOpportunityValidations = 'Bypass_Opportunity_Validation_Rules';
        String uniqueUserName = 'standarduser2' + DateTime.now().getTime() + '@testorg.com';
        String uniqueAdminName = 'systemadmintester' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile standardUser = [SELECT Id FROM Profile WHERE Name = 'Standard User'][0];
        Profile systemAdministrator = [
            SELECT Id
            FROM Profile
            WHERE Name = 'System Administrator'
        ][0];
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Account_Management'];
        User noAccessUser = new User(
            Alias = 'standt',
            Email = 'standarduser@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = standardUser.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = uniqueUserName
        );
        insert noAccessUser;
        User reparentingAccessUser = new User(
            Alias = 'sadmin',
            Email = 'systemadmin@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = systemAdministrator.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = uniqueAdminName
        );

        insert new PermissionSetAssignment(AssigneeId = noAccessUser.id, PermissionSetId = ps.Id);

        List<Account> accountList = new List<Account>{
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 1'),
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 2')
        };

        Id opportunityrecId1 = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id opportunityrecId2 = fflib_IDGenerator.generate(Opportunity.SObjectType);

        List<Opportunity> opportunitiesRec = new List<Opportunity>{
            new Opportunity(
                Id = opportunityrecId1,
                Name = 'Test1',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(3),
                AccountId = accountList[0].Id
            ),
            new Opportunity(
                Id = opportunityrecId2,
                Name = 'Test2',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(3),
                AccountId = accountList[1].Id,
                Opportunity_Sub_Type__c = 'Net New Partner'
            )
        };
        //Adding Quotes and linking them to Opportunity
        List<SBQQ__Quote__c> childQuotes = new List<SBQQ__Quote__c>{
            new SBQQ__Quote__c(
                Id = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType),
                SBQQ__Opportunity2__c = opportunitiesRec[0].Id
            )
        };

        //Mocking QuotesSelector
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IQuotesSelector quotesSelectorMock = (IQuotesSelector) mocks.mock(IQuotesSelector.class);
        IFeatureManagementService featureManagementServiceMock = (IFeatureManagementService) mocks.mock(
            IFeatureManagementService.class
        );

        IOpportunities opptInstance = Opportunities.newInstance(opportunitiesRec);
        mocks.startStubbing();

        mocks.when(quotesSelectorMock.SObjectType()).thenReturn(SBQQ__Quote__c.SObjectType);

        mocks.when(
                quotesSelectorMock.selectByOpportunity(
                    new Set<Id>{ opportunitiesRec[0].Id, opportunitiesRec[1].Id }
                )
            )
            .thenReturn(childQuotes);
        mocks.when(
                featureManagementServiceMock.checkPermission(
                    'Allow_Non_Owner_Opportunity_Reparenting'
                )
            )
            .thenReturn(true);
        mocks.when(featureManagementServiceMock.checkPermission(bypassOpportunityValidations))
            .thenReturn(true);

        mocks.stopStubbing();

        Application.Selector.setMock(quotesSelectorMock);
        Application.Service.setMock(IFeatureManagementService.class, featureManagementServiceMock);

        opportunitiesRec[1].AccountId = accountList[0].Id;

        System.runAs(reparentingAccessUser) {
            opptInstance.opportunityReparentingValidation(
                new List<Opportunity>{ opportunitiesRec[0], opportunitiesRec[1] },
                opptInstance.getOpportunitiesWithQuotes(
                    new List<Opportunity>{ opportunitiesRec[0], opportunitiesRec[1] }
                )
            );
        }

        System.assertEquals(
            accountList[0].Id,
            opportunitiesRec[1].AccountId,
            'The opportunity has not be reparented successfully'
        );

        mocks.startStubbing();

        mocks.when(quotesSelectorMock.SObjectType()).thenReturn(SBQQ__Quote__c.SObjectType);
        mocks.when(
                quotesSelectorMock.selectByOpportunity(
                    new Set<Id>{ opportunitiesRec[0].Id, opportunitiesRec[1].Id }
                )
            )
            .thenReturn(childQuotes);
        mocks.when(
                featureManagementServiceMock.checkPermission(
                    'Allow_Non_Owner_Opportunity_Reparenting'
                )
            )
            .thenReturn(false);
        mocks.when(featureManagementServiceMock.checkPermission(bypassOpportunityValidations))
            .thenReturn(false);

        mocks.stopStubbing();

        Application.Selector.setMock(quotesSelectorMock);
        Application.Service.setMock(IFeatureManagementService.class, featureManagementServiceMock);

        System.runAs(noAccessUser) {
            opptInstance.opportunityReparentingValidation(
                new List<Opportunity>{ opportunitiesRec[0], opportunitiesRec[1] },
                opptInstance.getOpportunitiesWithQuotes(
                    new List<Opportunity>{ opportunitiesRec[0], opportunitiesRec[1] }
                )
            );
        }
        ApexPages.Message quoteFailureMessage = new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'This opportunity has an associated quote and is therefore unable to be re-parented.'
        );
        ApexPages.Message accessFailureMessage = new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'You do not have the access necessary to re-parent this opportunity. Please reach out to the opportunity owner.'
        );

        //Assertion
        System.assertEquals(
            2,
            ApexPages.getMessages().size(),
            'The Opportunity with linked quote did not fire an error'
        );
        System.assertEquals(quoteFailureMessage, ApexPages.getMessages()[0], 'Message');
        System.assertEquals(accessFailureMessage, ApexPages.getMessages()[1], 'Message');
        System.assertNotEquals(null, opportunitiesRec[0].AccountId, 'Opportunity is orphaned');
    }

    @isTest
    private static void testWhenPricebookDefaultedThenNewOpportunityIsCreated() {
        //Arrange
        List<Opportunity> opportunityList = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(3)
            ),
            new Opportunity(
                Name = 'Test2',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(3)
            )
        };

        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;

        IOpportunities opptInstance = Opportunities.newInstance(opportunityList);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IPricebookSelector pbSelector = (IPricebookSelector) mocks.mock(IPricebookSelector.class);

        mocks.startStubbing();
        mocks.when(pbSelector.sObjectType()).thenReturn(standardPricebook);
        mocks.stopStubbing();
        opptInstance.assignPriceBook();

        System.assertEquals(
            standardPricebook.Id,
            opportunityList[0].pricebook2Id,
            'The pricebooks are different'
        );
        System.assertEquals(
            standardPricebook.Id,
            opportunityList[1].pricebook2Id,
            'The pricebooks are different'
        );
    }

    @isTest
    private static void testWhenOpportunityIsInsertedThenContractIdIsAssigned() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id orderId = Fake.generateId(Order.class);
        List<Account> accountList = new List<Account>{
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 1'),
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 2')
        };

        List<Opportunity> opportunityRecords = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(3),
                AccountId = accountList[0].Id,
                Type = 'Existing'
            ),
            new Opportunity(
                Name = 'Test2',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(3),
                AccountId = accountList[1].Id,
                Opportunity_Sub_Type__c = 'Net New Partner'
            )
        };

         Order ordersInstance = new Order(
             Id = orderId,
             Name = 'Primary Order',
             SBQQ__Quote__c = quoteId,
             Type = ORDER_TYPE_CORE
         );

       Contract childContract = new Contract(
            StartDate = Date.today() + 1,
            AccountId = accountList[0].Id,
            Status = 'Activated',
            SBQQ__Order__c = ordersInstance.Id
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IContractsSelector selectorMock = (IContractsSelector) mocks.mock(IContractsSelector.class);
        IContractsService serviceMock = (IContractsService) mocks.mock(IContractsService.class);
        IOpportunities opptInstance = Opportunities.newInstance(opportunityRecords);
        mocks.startStubbing();

        mocks.when(selectorMock.SObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(
                selectorMock.selectByParentAccountId(
                    new Set<Id>{ accountList[0].Id, accountList[1].Id }
                )
            )
            .thenReturn(new List<Contract>{ childContract });

        mocks.stopStubbing();
        Application.Selector.setMock(selectorMock);
        Application.Service.setMock(IContractsService.class, serviceMock);

        opptInstance.assignContractAndPreventOpportunityNewTypeCreation();
        System.assertEquals(
            childContract.Id,
            opportunityRecords[0].ContractId,
            'The Contract has not been assigned correctly'
        );
        System.assertEquals(
            null,
            opportunityRecords[1].ContractId,
            'The opportunity must not be linked to a Contract'
        );
    }

    @isTest
    private static void testWhenNewOpportunityIsInsertedOnAccountWithActivatedContractThenPreventCreation() {
        List<Account> accountList = new List<Account>{
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Parent 1',
                RecordTypeId = BUSINESS_RECORD_TYPE_ID
            ),
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Parent 2',
                RecordTypeId = BUSINESS_RECORD_TYPE_ID
            )
        };

        List<Opportunity> opportunityRecords = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(3),
                AccountId = accountList[0].Id,
                Type = 'New'
            ),
            new Opportunity(
                Name = 'Test2',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(3),
                AccountId = accountList[1].Id,
                Opportunity_Sub_Type__c = 'Net New Partner',
                Type = 'New'
            )
        };

        Contract childContract = new Contract(
            Id = fflib_IDGenerator.generate(Contract.SObjectType),
            StartDate = Date.today() + 1,
            AccountId = accountList[0].Id,
            Status = 'Activated'
        );
        Map<Id, List<Contract>> returnedContractMap = new Map<Id, List<Contract>>{
            accountList[0].Id => new List<Contract>{childContract}
        };
        Map<Id, List<Contract>> returnedMiddlewareContracts = new Map<Id, List<Contract>>();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IContractsSelector selectorMock = (IContractsSelector) mocks.mock(IContractsSelector.class);
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IContractsService serviceMock = (IContractsService) mocks.mock(IContractsService.class);
        IOpportunities opptInstance = Opportunities.newInstance(opportunityRecords);
        mocks.startStubbing();

        mocks.when(selectorMock.SObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(
                selectorMock.selectByParentAccountId(
                    new Set<Id>{ accountList[0].Id, accountList[1].Id }
                )
            )
            .thenReturn(new List<Contract>{ childContract });
        mocks.when(
                serviceMock.setAllContractOnParentAccount(
                    new Set<Id>{ accountList[0].Id, accountList[1].Id }
                )
            )
            .thenReturn(returnedContractMap);
        mocks.when(
                serviceMock.setMiddlewareProviderContractOnParentAccount(
                    new Set<Id>{ accountList[0].Id, accountList[1].Id }
                )
            )
            .thenReturn(returnedMiddlewareContracts);
        mocks.when(accountSelectorMock.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountSelectorMock.selectByOpportunity(opportunityRecords))
            .thenReturn(accountList);
        mocks.stopStubbing();
        Application.Selector.setMock(selectorMock);
        Application.Service.setMock(IContractsService.class, serviceMock);
        Application.Selector.setMock(accountSelectorMock);
        opptInstance.assignContractAndPreventOpportunityNewTypeCreation();

        System.assertEquals(
            System.Label.New_Opportunity_On_Account_With_Activated_Contract_Error,
            fflib_SObjects.Errors.getAll()[0].message,
            'Unexpected Error: The Opportunity creation was successful and the error was not fired as expected.'
        );
    }

    @isTest
    private static void testWhenStageIsChangedToStalledThenUpdatedRestoreForecastAndProbability() {
        //Arrange
        List<Account> accountList = new List<Account>{
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 1'),
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 2')
        };
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);

        List<Opportunity> oldOpportunityRecords = new List<Opportunity>{
            new Opportunity(
                Id = opportunityId,
                Name = 'Test1',
                StageName = 'Pitching',
                Type = 'New',
                Accountid = accountList[0].Id,
                Probability = 30,
                ForecastCategoryName = 'Pipeline',
                CloseDate = System.today().addDays(3)
            )
        };

        List<Opportunity> opportunityRecords = new List<Opportunity>{
            new Opportunity(
                Id = opportunityId,
                Name = 'Test1',
                StageName = 'Stalled',
                Type = 'New',
                Accountid = accountList[0].Id,
                Probability = 60,
                ForecastCategoryName = 'Best Case',
                CloseDate = System.today().addDays(3)
            )
        };

        IOpportunities opptInstance = Opportunities.newInstance(opportunityRecords);
        opptInstance.restoreForecastAndProbabilityOnStageChangeToStalled(
            new Map<Id, Opportunity>(oldOpportunityRecords),
            opportunityRecords
        );
        System.assertEquals(
            30,
            opportunityRecords[0].Probability,
            'The probability must match the previous Stage Value'
        );
        System.assertEquals(
            'Pipeline',
            opportunityRecords[0].ForecastCategoryName,
            'The Forecast Category must match the previous Stage Value'
        );
    }

    @isTest
    private static void testWhenStageChangeWithContactRoleThenAllow() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        List<Account> accountList = new List<Account>{
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 1'),
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 2')
        };
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);

        List<Opportunity> oldOpportunityRecords = new List<Opportunity>{
            new Opportunity(
                Id = opportunityId,
                Name = 'Test1',
                StageName = 'Pitching',
                Type = 'New',
                Accountid = accountList[0].Id,
                Probability = 30,
                Deal_Type__c = 'Standard',
                ForecastCategoryName = 'Pipeline',
                CloseDate = System.today().addDays(3)
            )
        };

        List<Opportunity> opportunityRecords = new List<Opportunity>{
            new Opportunity(
                id = opportunityId,
                Name = 'Test1',
                StageName = 'Negotiating',
                Type = 'New',
                Accountid = accountList[0].Id,
                Probability = 30,
                Deal_Type__c = 'Standard',
                ForecastCategoryName = 'Pipeline',
                CloseDate = System.today().addDays(3),
                SBQQ__PrimaryQuote__c = quoteId
            )
        };
        List<OpportunityContactRole> oppContactRole = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                Id = fflib_IDGenerator.generate(OpportunityContactRole.SObjectType),
                OpportunityId = opportunityRecords[0].Id
            )
        };

        Opportunity updateOpportunityRecord = opportunityRecords[0];
        updateOpportunityRecord.StageName = 'Negotiating';

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunities opptInstance = Opportunities.newInstance(opportunityRecords);
        IOpportunityContactRoleSelector oppContactRoleSelectorMock = (IOpportunityContactRoleSelector) mocks.mock(
            IOpportunityContactRoleSelector.class
        );
        IOpportunitiesSelector selectorMockOp = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );
        mocks.startStubbing();
        mocks.when(oppContactRoleSelectorMock.SObjectType())
            .thenReturn(OpportunityContactRole.SObjectType);
        mocks.when(
                oppContactRoleSelectorMock.selectPrimaryOrContractSignatoryOpportunityContactRoleByOpportunity(
                    new Set<Id>{ opportunityRecords[0].Id }
                )
            )
            .thenReturn(oppContactRole);
        mocks.stopStubbing();
        mocks.when(selectorMockOp.SObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(
                selectorMockOp.selectOpportunitiesWithQuotes(
                    new Set<Id>{ opportunityRecords[0].Id }
                )
            )
            .thenReturn(new List<Opportunity>{ updateOpportunityRecord });
        Application.Selector.setMock(oppContactRoleSelectorMock);
        opptInstance.contactRoleValidationOnOpportunityCreation();
        opptInstance.contactRoleValidationBeforeStageChangePastPitching(
            new Map<Id, Opportunity>(oldOpportunityRecords),
            new List<Opportunity>{ updateOpportunityRecord }
        );

        //Assertion
        System.assertEquals(
            2,
            ApexPages.getMessages().size(),
            'The Opportunity without linked contact role did not fire an error'
        );
    }

    @isTest
    private static void testWhenStageChangeWithBrandRelationshipThenAllow() {
        List<Account> accountList = new List<Account>{
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Parent 1',
                RecordTypeId = BUSINESS_RECORD_TYPE_ID
            ),
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Parent 2',
                RecordTypeId = BUSINESS_RECORD_TYPE_ID
            )
        };
        Id opportunityId1 = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id opportunityId2 = fflib_IDGenerator.generate(Opportunity.SObjectType);

        List<Opportunity> oldOpportunityRecords = new List<Opportunity>{
            new Opportunity(
                Id = opportunityId1,
                Name = 'Test1',
                StageName = 'Pitching',
                Type = 'New',
                Accountid = accountList[0].Id,
                Probability = 30,
                Deal_Type__c = 'Standard',
                ForecastCategoryName = 'Pipeline',
                CloseDate = System.today().addDays(3)
            ),
            new Opportunity(
                Id = opportunityId2,
                Name = 'Test1',
                StageName = 'Pitching',
                Type = 'New',
                Accountid = accountList[0].Id,
                Probability = 30,
                Deal_Type__c = 'Standard',
                ForecastCategoryName = 'Pipeline',
                CloseDate = System.today().addDays(3)
            )
        };

        List<Opportunity> opportunityRecords = new List<Opportunity>{
            new Opportunity(
                id = opportunityId1,
                Name = 'Test1',
                StageName = 'Pitching',
                Type = 'New',
                Accountid = accountList[0].Id,
                Probability = 30,
                Deal_Type__c = 'Standard',
                ForecastCategoryName = 'Pipeline',
                CloseDate = System.today().addDays(3)
            ),
            new Opportunity(
                id = opportunityId2,
                Name = 'Test1',
                StageName = 'Pitching',
                Type = 'New',
                Accountid = accountList[0].Id,
                Probability = 30,
                Deal_Type__c = 'Standard',
                ForecastCategoryName = 'Pipeline',
                CloseDate = System.today().addDays(3)
            )
        };
        List<Opportunity_Brand_Relationship__c> opportunityBrandRelationship = new List<Opportunity_Brand_Relationship__c>{
            new Opportunity_Brand_Relationship__c(
                Id = fflib_IDGenerator.generate(Opportunity_Brand_Relationship__c.SObjectType),
                Opportunity__c = opportunityRecords[0].Id
            )
        };

        Opportunity updateOpportunityRecord = opportunityRecords[0];
        updateOpportunityRecord.StageName = 'Negotiating';
        Opportunity updateOpportunityRecord2 = opportunityRecords[1];
        updateOpportunityRecord.StageName = 'Negotiating';

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunities opptInstance = Opportunities.newInstance(opportunityRecords);
        IOpportunityBrandRelationshipsSelector opportunityBrandRelationshipsSelectorMock = (IOpportunityBrandRelationshipsSelector) mocks.mock(
            IOpportunityBrandRelationshipsSelector.class
        );
        mocks.startStubbing();
        mocks.when(opportunityBrandRelationshipsSelectorMock.SObjectType())
            .thenReturn(Opportunity_Brand_Relationship__c.SObjectType);
        mocks.when(
                opportunityBrandRelationshipsSelectorMock.selectByOpportunity(
                    new Set<Id>{ opportunityRecords[0].Id, opportunityRecords[1].Id }
                )
            )
            .thenReturn(opportunityBrandRelationship);
        mocks.stopStubbing();

        Application.Selector.setMock(opportunityBrandRelationshipsSelectorMock);
        opptInstance.validateOpportunitiesInNegotiatingStage(
            new Map<Id, Opportunity>(oldOpportunityRecords),
            new List<Opportunity>{ updateOpportunityRecord, updateOpportunityRecord2 }
        );

        //Assertion
        System.assertEquals(
            0,
            ApexPages.getMessages().size(),
            'The Opportunity with linked brand relationship is firing an error.'
        );
    }

    @isTest
    private static void testWhenStageChangeWithContactRoleThenAllowForLite() {
        List<Account> accountList = new List<Account>{
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 1'),
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 2')
        };
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);

        List<Opportunity> oldOpportunityRecords = new List<Opportunity>{
            new Opportunity(
                Id = opportunityId,
                Name = 'Test1',
                StageName = 'Pitching',
                Type = 'New',
                Accountid = accountList[0].Id,
                Probability = 30,
                Deal_Type__c = 'Lite',
                ForecastCategoryName = 'Pipeline',
                CloseDate = System.today().addDays(3)
            )
        };

        List<Opportunity> opportunityRecords = new List<Opportunity>{
            new Opportunity(
                id = opportunityId,
                Name = 'Test1',
                StageName = 'Negotiating',
                Type = 'New',
                Accountid = accountList[0].Id,
                Probability = 30,
                Deal_Type__c = 'Lite',
                ForecastCategoryName = 'Pipeline',
                CloseDate = System.today().addDays(3)
            )
        };
        List<OpportunityContactRole> oppContactRole = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                Id = fflib_IDGenerator.generate(OpportunityContactRole.SObjectType),
                OpportunityId = opportunityRecords[0].Id,
                IsPrimary = true,
                Role = 'Contract Signatory'
            )
        };

        Opportunity updateOpportunityRecord = opportunityRecords[0];
        updateOpportunityRecord.StageName = 'Negotiating';

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunities opptInstance = Opportunities.newInstance(opportunityRecords);
        IOpportunityContactRoleSelector oppContactRoleSelectorMock = (IOpportunityContactRoleSelector) mocks.mock(
            IOpportunityContactRoleSelector.class
        );
        mocks.startStubbing();
        mocks.when(oppContactRoleSelectorMock.SObjectType())
            .thenReturn(OpportunityContactRole.SObjectType);
        mocks.when(
                oppContactRoleSelectorMock.selectPrimaryOrContractSignatoryOpportunityContactRoleByOpportunity(
                    new Set<Id>{ opportunityRecords[0].Id }
                )
            )
            .thenReturn(oppContactRole);
        mocks.stopStubbing();

        Application.Selector.setMock(oppContactRoleSelectorMock);

        opptInstance.contactRoleValidationBeforeStageChangePastPitching(
            new Map<Id, Opportunity>(oldOpportunityRecords),
            new List<Opportunity>{ updateOpportunityRecord }
        );

        //Assertion
        System.assertEquals(
            0,
            ApexPages.getMessages().size(),
            'The Opportunity without linked contact role did not fire an error'
        );
    }

    @isTest
    private static void testWhenStageChangeWithNoContactRoleThenDoNotAllow() {
        List<Account> accountList = new List<Account>{
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 1'),
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 2')
        };

        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);

        List<Opportunity> oldOpportunityRecords = new List<Opportunity>{
            new Opportunity(
                Id = opportunityId,
                Name = 'Test1',
                StageName = 'Pitching',
                Type = 'New',
                Accountid = accountList[0].Id,
                Probability = 30,
                Deal_Type__c = 'Standard',
                ForecastCategoryName = 'Pipeline',
                CloseDate = System.today().addDays(3)
            )
        };

        List<Opportunity> opportunityRecords = new List<Opportunity>{
            new Opportunity(
                id = opportunityId,
                Name = 'Test1',
                StageName = 'Pitching',
                Type = 'New',
                Accountid = accountList[0].Id,
                Probability = 30,
                Deal_Type__c = 'Standard',
                ForecastCategoryName = 'Pipeline',
                CloseDate = System.today().addDays(3)
            )
        };

        List<OpportunityContactRole> oppContactRole = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                Id = fflib_IDGenerator.generate(OpportunityContactRole.SObjectType),
                OpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType)
            )
        };

        Opportunity updateOpportunityRecord = opportunityRecords[0];
        updateOpportunityRecord.StageName = 'Negotiating';

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunities opptInstance = Opportunities.newInstance(opportunityRecords);
        IOpportunityContactRoleSelector oppContactRoleSelectorMock = (IOpportunityContactRoleSelector) mocks.mock(
            IOpportunityContactRoleSelector.class
        );
        mocks.startStubbing();
        mocks.when(oppContactRoleSelectorMock.SObjectType())
            .thenReturn(OpportunityContactRole.SObjectType);
        mocks.when(
                oppContactRoleSelectorMock.selectByOpportunity(
                    new Set<Id>{ opportunityRecords[0].Id }
                )
            )
            .thenReturn(oppContactRole);
        mocks.stopStubbing();

        Application.Selector.setMock(oppContactRoleSelectorMock);

        opptInstance.contactRoleValidationBeforeStageChangePastPitching(
            new Map<Id, Opportunity>(oldOpportunityRecords),
            new List<Opportunity>{ updateOpportunityRecord }
        );

        ApexPages.Message contactRoleFailureMessage = new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'Before moving forwarding into Negotiating Stage, please ensure you have at least one contact role that is a "Contact Signatory", and at least one contact listed as the "Primary Contact". One contact can meet both criteria.'
        );

        //Assertion
        System.assertEquals(
            1,
            ApexPages.getMessages().size(),
            'The Opportunity without linked contact role did not fire an error'
        );
        System.assertEquals(contactRoleFailureMessage, ApexPages.getMessages()[0], 'Message');
    }

    @isTest
    private static void testWhenStageChangeWithNoBrandRelationshipThenDoNotAllow() {
        List<Account> accountList = new List<Account>{
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Parent 1',
                RecordTypeId = BUSINESS_RECORD_TYPE_ID,
                Segment__c = ACCOUNT_SEGMENT_ENTERPRISE
            ),
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Parent 2',
                RecordTypeId = BUSINESS_RECORD_TYPE_ID,
                Segment__c = ACCOUNT_SEGMENT_ENTERPRISE
            )
        };

        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);

        List<Opportunity> oldOpportunityRecords = new List<Opportunity>{
            new Opportunity(
                Id = opportunityId,
                Name = 'Test1',
                StageName = 'Pitching',
                Type = 'New',
                Accountid = accountList[0].Id,
                Probability = 30,
                Deal_Type__c = 'Standard',
                ForecastCategoryName = 'Pipeline',
                CloseDate = System.today().addDays(3)
            )
        };

        List<Opportunity> opportunityRecords = new List<Opportunity>{
            new Opportunity(
                id = opportunityId,
                Name = 'Test1',
                StageName = 'Pitching',
                Type = 'New',
                Accountid = accountList[0].Id,
                Probability = 30,
                Deal_Type__c = 'Standard',
                ForecastCategoryName = 'Pipeline',
                CloseDate = System.today().addDays(3)
            )
        };

        Opportunity updateOpportunityRecord = opportunityRecords[0];
        updateOpportunityRecord.StageName = 'Negotiating';

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunities opptInstance = Opportunities.newInstance(opportunityRecords);
        IOpportunityBrandRelationshipsSelector oppBrandRelationshipSelectorMock = (IOpportunityBrandRelationshipsSelector) mocks.mock(
            IOpportunityBrandRelationshipsSelector.class
        );
        mocks.startStubbing();
        mocks.when(oppBrandRelationshipSelectorMock.SObjectType())
            .thenReturn(Opportunity_Brand_Relationship__c.SObjectType);
        mocks.when(
                oppBrandRelationshipSelectorMock.selectByOpportunity(
                    new Set<Id>{ opportunityRecords[0].Id }
                )
            )
            .thenReturn(new List<Opportunity_Brand_Relationship__c>());
        mocks.stopStubbing();

        Application.Selector.setMock(oppBrandRelationshipSelectorMock);

        opptInstance.validateOpportunitiesInNegotiatingStage(
            new Map<Id, Opportunity>(oldOpportunityRecords),
            new List<Opportunity>{ updateOpportunityRecord }
        );

        //Assertion
        System.assertEquals(
            0,
            ApexPages.getMessages().size(),
            'The Opportunity without linked Brand Relationship did not fire an error.'
        );
        //System.assertEquals(brandRelationshipFailure, ApexPages.getMessages()[0], 'Message');
    }

    @isTest
    private static void testWhenStageChangeWithNoBrandRelationshipAndAdsPromosThenAllow() {
        List<Account> accountList = new List<Account>{
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Parent 1',
                RecordTypeId = BUSINESS_RECORD_TYPE_ID
            ),
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Parent 2',
                RecordTypeId = BUSINESS_RECORD_TYPE_ID
            )
        };

        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);

        List<Opportunity> oldOpportunityRecords = new List<Opportunity>{
            new Opportunity(
                Id = opportunityId,
                Name = 'Test1',
                StageName = 'Pitching',
                Type = 'New',
                Accountid = accountList[0].Id,
                Probability = 30,
                Deal_Type__c = DEAL_TYPE,
                ForecastCategoryName = 'Pipeline',
                CloseDate = System.today().addDays(3),
                Opportunity_Sub_Type__c = SUB_TYPE
            )
        };

        List<Opportunity> opportunityRecords = new List<Opportunity>{
            new Opportunity(
                id = opportunityId,
                Name = 'Test1',
                StageName = 'Pitching',
                Type = 'New',
                Accountid = accountList[0].Id,
                Probability = 30,
                Deal_Type__c = DEAL_TYPE,
                ForecastCategoryName = 'Pipeline',
                CloseDate = System.today().addDays(3),
                Opportunity_Sub_Type__c = SUB_TYPE
            )
        };

        Opportunity updateOpportunityRecord = opportunityRecords[0];
        updateOpportunityRecord.StageName = 'Negotiating';

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunities opptInstance = Opportunities.newInstance(opportunityRecords);
        IOpportunityBrandRelationshipsSelector oppBrandRelationshipSelectorMock = (IOpportunityBrandRelationshipsSelector) mocks.mock(
            IOpportunityBrandRelationshipsSelector.class
        );
        mocks.startStubbing();
        mocks.when(oppBrandRelationshipSelectorMock.SObjectType())
            .thenReturn(Opportunity_Brand_Relationship__c.SObjectType);
        mocks.when(
                oppBrandRelationshipSelectorMock.selectByOpportunity(
                    new Set<Id>{ opportunityRecords[0].Id }
                )
            )
            .thenReturn(new List<Opportunity_Brand_Relationship__c>());
        mocks.stopStubbing();

        Application.Selector.setMock(oppBrandRelationshipSelectorMock);

        opptInstance.validateOpportunitiesInNegotiatingStage(
            new Map<Id, Opportunity>(oldOpportunityRecords),
            new List<Opportunity>{ updateOpportunityRecord }
        );

        //Assertion
        System.assertEquals(
            0,
            ApexPages.getMessages().size(),
            'The Ads & Promos Opportunity without linked Brand Relationship did not fire an error.'
        );
    }

    /**
     *@description testing that when and Ads & Promos Opportunity with a deal type of Self Serve is created you
     * can change the stage to closed won without an error being fired for not having a contract signed quote
     */
    @isTest
    private static void testWhenAdsPromosDealTypeSelfServeThenDontThrowErrorOnChangingStageToClosedWon() {
        List<Account> accountList = new List<Account>{
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Parent 1',
                Type = 'Agency'
            ),
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Parent 2',
                Type = 'Agency'
            )
        };
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);

        List<Opportunity> opportunitiesRec = new List<Opportunity>{
            new Opportunity(
                Id = opportunityId,
                Name = 'Test1',
                StageName = 'Closed Won',
                Type = 'Existing',
                Accountid = accountList[0].Id,
                Probability = 30,
                Deal_Type__c = DEAL_TYPE,
                Opportunity_Sub_Type__c = SUB_TYPE,
                ForecastCategoryName = 'Pipeline',
                CloseDate = System.today().addDays(3)
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        IOpportunities opptInstance = Opportunities.newInstance(opportunitiesRec);
        mocks.startStubbing();

        mocks.when(selectorMock.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectByOpportunity(opportunitiesRec)).thenReturn(accountList);

        mocks.stopStubbing();
        Application.Selector.setMock(selectorMock);
        opptInstance.validatePrimaryOrderForOpportunityCloseWin();

        System.assertEquals(
            0,
            ApexPages.getMessages().size(),
            'The Ads & Promos Opportunity without linked Brand Relationship did not fire an error.'
        );
    }

    /**
     *@description testing that when and Ads & Promos Opportunity with a deal type of Full Serve is created you
     * cannot change the stage to closed won without an error being fired for not having a contract signed quote
     */
    @isTest
    private static void testWhenAdsPromosDealTypeFullServeThenThrowErrorOnChangingStageToClosedWon() {
        List<Account> accountList = new List<Account>{
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Parent 1',
                Type = 'Agency'
            ),
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Parent 2',
                Type = 'Agency'
            )
        };
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);

        List<Opportunity> opportunitiesRec = new List<Opportunity>{
            new Opportunity(
                Id = opportunityId,
                Name = 'Test1',
                StageName = 'Closed Won',
                Type = 'Existing',
                Accountid = accountList[0].Id,
                Probability = 30,
                Deal_Type__c = 'Full-Serve',
                Opportunity_Sub_Type__c = SUB_TYPE,
                ForecastCategoryName = 'Pipeline',
                CloseDate = System.today().addDays(3)
            )
        };

        List<SBQQ__Quote__c> quoteWithBDProduct = new List<SBQQ__Quote__c>{
            new SBQQ__Quote__c(
                Id = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType),
                SBQQ__Opportunity2__c = opportunitiesRec[0].Id,
                HasPipelineProduct__c = false
            )
        };

        Opportunity updateOpportunityRecord = opportunitiesRec[0];
        updateOpportunityRecord.SBQQ__PrimaryQuote__c = quoteWithBDProduct[0].Id;

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        IOpportunities opptInstance = Opportunities.newInstance(opportunitiesRec);
        IOpportunitiesSelector opportunitySelectorMock = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );
        mocks.startStubbing();

        mocks.when(selectorMock.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectByOpportunity(opportunitiesRec)).thenReturn(accountList);
        mocks.when(opportunitySelectorMock.SObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(
                opportunitySelectorMock.selectOpportunitiesWithQuotes(
                    new Set<Id>{ opportunitiesRec[0].Id }
                )
            )
            .thenReturn(new List<Opportunity>{ updateOpportunityRecord });

        mocks.stopStubbing();
        Application.Selector.setMock(selectorMock);
        Application.Selector.setMock(opportunitySelectorMock);
        opptInstance.validatePrimaryOrderForOpportunityCloseWin();

        System.assertEquals(
            1,
            ApexPages.getMessages().size(),
            'The Ads & Promos Opportunity without linked Brand Relationship did not fire an error.'
        );
    }

    /*
     * Needs a test that ensures the functional code handles opportunities that don't have accounts properly
     * and a test that ensures that the code handles accounts with a blank value for CurrencyIsoCode properly
     */
    @isTest
    private static void testWhenParentIsCreatedThenCurrencyIsDefaulted() {
        List<Account> accountList = new List<Account>{
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Parent 1',
                CurrencyIsoCode = 'AUD'
            ),
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Parent 2',
                CurrencyIsoCode = 'USD'
            )
        };

        List<Opportunity> opportunitiesRec = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(3),
                AccountId = accountList[0].Id
            ),
            new Opportunity(
                Name = 'Test2',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(3),
                AccountId = accountList[1].Id,
                Opportunity_Sub_Type__c = 'Net New Partner'
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        IOpportunities opptInstance = Opportunities.newInstance(opportunitiesRec);
        mocks.startStubbing();

        mocks.when(selectorMock.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectByOpportunity(opportunitiesRec)).thenReturn(accountList);

        mocks.stopStubbing();
        Application.Selector.setMock(selectorMock);

        opptInstance.defaultOpportunityCurrencyToAccountCurrency();
        System.assertEquals(
            accountList[0].CurrencyIsoCode,
            opportunitiesRec[0].CurrencyIsoCode,
            'The opportunity currency has not been assigned correctly'
        );
        System.assertEquals(
            accountList[1].CurrencyIsoCode,
            opportunitiesRec[1].CurrencyIsoCode,
            'The opportunity currency has not been assigned correctly'
        );
    }

    @isTest
    private static void testWhenParentIsCreatedThenCurrencyIsDefaultedNoCurrencyOnAccount() {
        List<Account> accountList = new List<Account>{
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 1')
        };

        List<Opportunity> opportunitiesRec = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(3),
                AccountId = accountList[0].Id,
                CurrencyIsoCode = 'USD'
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        IOpportunities opptInstance = Opportunities.newInstance(opportunitiesRec);
        mocks.startStubbing();

        mocks.when(selectorMock.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectByOpportunity(opportunitiesRec)).thenReturn(accountList);

        mocks.stopStubbing();
        Application.Selector.setMock(selectorMock);

        opptInstance.defaultOpportunityCurrencyToAccountCurrency();

        System.assertEquals(
            null,
            opportunitiesRec[0].CurrencyIsoCode,
            'The opportunity currency has not been assigned correctly'
        );
    }

    @isTest
    private static void testWhenOpportunityIsCreatedThenCurrencyAutoPopulates() {
        List<Account> accountList = new List<Account>{
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Parent 1',
                CurrencyIsoCode = 'AUD'
            )
        };

        List<Opportunity> opportunitiesRec = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(3),
                AccountId = accountList[0].Id,
                CurrencyIsoCode = 'USD'
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        IOpportunities opptInstance = Opportunities.newInstance(opportunitiesRec);
        mocks.startStubbing();

        mocks.when(selectorMock.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectByOpportunity(opportunitiesRec)).thenReturn(accountList);

        mocks.stopStubbing();
        Application.Selector.setMock(selectorMock);

        opptInstance.defaultOpportunityCurrencyToAccountCurrency();

        System.assertEquals(
            'AUD',
            opportunitiesRec[0].CurrencyIsoCode,
            'The opportunity currency has not been assigned correctly'
        );
    }

    @isTest
    private static void testWhenParentIsNotAddedOnOpportunityThenCurrencyIsDefaulted() {
        List<Opportunity> opportunitiesRec = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(3),
                CurrencyIsoCode = 'USD'
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        IOpportunities opptInstance = Opportunities.newInstance(opportunitiesRec);
        mocks.startStubbing();

        mocks.when(selectorMock.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectByOpportunity(opportunitiesRec))
            .thenReturn(new List<Account>());

        mocks.stopStubbing();
        Application.Selector.setMock(selectorMock);

        opptInstance.defaultOpportunityCurrencyToAccountCurrency();

        System.assertEquals(
            'USD',
            opportunitiesRec[0].CurrencyIsoCode,
            'The opportunity currency has not been assigned correctly'
        );
    }

    @isTest
    private static void testWhenClassInstantiatesThenRun() {
        List<Opportunity> opportunitiesList = new List<Opportunity>();
        //IOpportunities Instance Creation Call
        Opportunities.newInstance(opportunitiesList);
        //Default Constructor Call
        Opportunities opportunitiesObject = new Opportunities(opportunitiesList);
        //fflib_IDomainConstructor call
        Opportunities.Constructor constructorObject = new Opportunities.Constructor();
        constructorObject.construct(opportunitiesList);
        System.assertNotEquals(
            Opportunities.newInstance(opportunitiesList),
            opportunitiesObject,
            'These objects should not be similar'
        );
    }

    /**
     * @description this method test when an Business account have any assosiated opportunitiy then the
     * Account life cycle status changes to In Pursuit.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOpportunityRelatedWithAccountThenChangeStatus() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        List<Account> accounts = new List<Account>{
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Parent 1',
                Account_Lifecycle_Status__c = 'Unvetted',
                RecordTypeId = businessRecordTypeId
            ),
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Parent 2',
                Account_Lifecycle_Status__c = 'In Pursuit',
                RecordTypeId = businessRecordTypeId
            )
        };

        List<Opportunity> opportunitiesRec = new List<Opportunity>{
            new Opportunity(
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Name = 'Test1',
                StageName = 'Prospecting',
                AccountId = accounts[0].Id
            ),
            new Opportunity(
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Name = 'Test2',
                StageName = 'Prospecting',
                AccountId = accounts[1].Id
            )
        };
        Set<Id> accountIds = new Set<Id>{ accounts[0].Id, accounts[1].Id };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        IOpportunities opportunitiesInstance = Opportunities.newInstance(opportunitiesRec);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();

        mocks.when(selectorMock.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectUnverifiedBusinessAccountsById(accountIds))
            .thenReturn(new List<Account>{ accounts[0] });

        mocks.stopStubbing();
        Application.Selector.setMock(selectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        opportunitiesInstance.updateAccountLifecycleStatusOnOpportunityInsertOrUndelete();
        System.assertEquals(
            accounts[0].Account_Lifecycle_Status__c,
            'In Pursuit',
            'Status is not updated correctly'
        );
    }

    /**
     * @description this method test when an account doesnt have any assosiated opportunitiy(after delete) then the
     * Account life cycle status changes to Unvetted.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenNoHistoricalOpportunitiesWithAccountThenChangeStatus() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();

        List<Account> accounts = new List<Account>{
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Test 1',
                Account_Lifecycle_Status__c = 'In Pursuit',
                RecordTypeId = businessRecordTypeId
            ),
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Test 2',
                Account_Lifecycle_Status__c = 'In Pursuit',
                RecordTypeId = businessRecordTypeId
            )
        };
        Set<Id> accountIds = new Set<Id>{ accounts[0].Id };

        List<Opportunity> opportunitiesRecords = new List<Opportunity>{
            new Opportunity(
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Name = 'Test1',
                StageName = 'Stalled',
                AccountId = accounts[0].Id
            ),
            new Opportunity(
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Name = 'Test2',
                StageName = 'Stalled'
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunitiesSelector selectorMockOp = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );
        IOpportunities opportunityInstance = Opportunities.newInstance(opportunitiesRecords);
        IAccountsSelector selectorMockAc = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        mocks.startStubbing();

        mocks.when(selectorMockOp.SObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(selectorMockOp.selectOpportunitiesByAccountId(accountIds))
            .thenReturn(new List<Opportunity>{ opportunitiesRecords[0] });
        mocks.when(selectorMockAc.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMockAc.selectInPursuitBusinessAccountsById(accountIds))
            .thenReturn(accounts);

        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.Selector.setMock(selectorMockOp);
        Application.Selector.setMock(selectorMockAc);

        opportunityInstance.checkAccountLifecycleStatusWhenOpportunityDeleted();
        System.assertEquals(
            accounts[1].Account_Lifecycle_Status__c,
            'Unvetted',
            'Status is not updated correctly'
        );
    }

    /**
     * @description this method is to test selectors and filters.
     */
    @isTest
    private static void testWhenGetByIdThenReturnRecords() {
        List<Opportunity> opportunitiesRecords = new List<Opportunity>{
            new Opportunity(
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Name = 'Test1',
                StageName = 'Stalled',
                AccountId = fflib_IDGenerator.generate(Account.SObjectType)
            ),
            new Opportunity(
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Name = 'Test2',
                StageName = 'Stalled',
                AccountId = fflib_IDGenerator.generate(Account.SObjectType)
            )
        };

        Map<Id, Opportunity> opportunityMapById = Opportunities.newInstance(opportunitiesRecords)
            .getById();

        System.assertEquals(
            2,
            opportunityMapById.size(),
            'Call returned the incorrect number of rows'
        );
    }

    /**
     * @description this method is to test Nintex selectors.
     */
    @isTest
    private static void testWhenNintexCallsThenReturnRecords() {
        List<Opportunity> opportunitiesRecords = new List<Opportunity>{
            new Opportunity(
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Name = 'Test1',
                StageName = 'Stalled',
                AccountId = fflib_IDGenerator.generate(Account.SObjectType),
                Marketplace_Nintex_Id__c = 'NintextId1',
                Nintex_Use_Case__c = 'New Franchise - Known',
                ContractId = fflib_IDGenerator.generate(Contract.SObjectType),
                Nintex_Signed_Date__c = System.today(),
                Packages_with_Products__c = '{"packageDetails":[{"packageName":"Marketplace","products":"Dashpass,Delivery"},{"packageName":"Storefront","products":""}]}'
            ),
            new Opportunity(
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Name = 'Test2',
                StageName = 'Stalled',
                AccountId = fflib_IDGenerator.generate(Account.SObjectType),
                Marketplace_Nintex_Id__c = 'NintextId2',
                Nintex_Use_Case__c = null,
                ContractId = fflib_IDGenerator.generate(Contract.SObjectType),
                Nintex_Signed_Date__c = System.today(),
                Packages_with_Products__c = '{"packageDetails":[{"packageName":"Marketplace","products":"Pickup"},{"packageName":"Storefront","products":""}]}'
            ),
            new Opportunity(
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Name = 'Test3',
                StageName = 'Stalled',
                AccountId = fflib_IDGenerator.generate(Account.SObjectType),
                Marketplace_Nintex_Id__c = 'NintextId3',
                Nintex_Use_Case__c = 'Change of Ownership',
                ContractId = null,
                Nintex_Signed_Date__c = System.today(),
                Packages_with_Products__c = '{"packageDetails":[{"packageName":"Marketplace","products":"DashPass"},{"packageName":"Storefront","products":""}]}'
            ),
            new Opportunity(
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Name = 'Test4',
                StageName = 'Stalled',
                AccountId = fflib_IDGenerator.generate(Account.SObjectType),
                Drive_Nintex_Id__c = 'NintextId4',
                Nintex_Use_Case__c = 'Rate Change',
                ContractId = fflib_IDGenerator.generate(Contract.SObjectType),
                Nintex_Signed_Date__c = null,
                Packages_with_Products__c = '{"packageDetails":[{"packageName":"Marketplace","products":""},{"packageName":"Storefront","products":""}]}'
            ),
            new Opportunity(
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Name = 'Test5',
                StageName = 'Stalled',
                AccountId = fflib_IDGenerator.generate(Account.SObjectType),
                Drive_Nintex_Id__c = null,
                Nintex_Use_Case__c = 'Drive - Amendment',
                ContractId = fflib_IDGenerator.generate(Contract.SObjectType),
                Nintex_Signed_Date__c = System.today(),
                Packages_with_Products__c = '{"packageDetails":[{"packageName":"Marketplace","products":""},{"packageName":"Storefront","products":""}]}'
            )
        };
        Map<String, Opportunity> opportunityMapByMkplNintexId = Opportunities.newInstance(
                opportunitiesRecords
            )
            .getByMarketPlaceNintexId();
        Map<String, Opportunity> opportunityMapByDriveNintexId = Opportunities.newInstance(
                opportunitiesRecords
            )
            .getByDriveNintexId();
        Map<String, IOpportunities> opportunityMapByUseCase = Opportunities.newInstance(
                opportunitiesRecords
            )
            .getByUseCase();

        Set<Id> contractSet = Opportunities.newInstance(opportunitiesRecords).getContractIds();
        Set<Id> accountSet = Opportunities.newInstance(opportunitiesRecords).getAccountIds();
        Set<String> driveNintexIds = Opportunities.newInstance(opportunitiesRecords)
            .getDriveNintexIds();
        Set<String> marketplaceNintexIds = Opportunities.newInstance(opportunitiesRecords)
            .getMarketplaceNintexIds();
        Map<String, Id> accountIdContractIdMap = Opportunities.newInstance(opportunitiesRecords)
            .getAccountIdContractIdMap();
        Map<Id, Map<String, String>> accountIdDeselectedServicesMap = Opportunities.newInstance(
                opportunitiesRecords
            )
            .getAccountIdDeselectedServicesMap();
        System.assertEquals(
            1,
            opportunityMapByMkplNintexId.size(),
            'Call returned the incorrect number of rows'
        );
        System.assertEquals(
            0,
            opportunityMapByDriveNintexId.size(),
            'Call returned the incorrect number of rows'
        );

        System.assertEquals(
            5,
            opportunityMapByUseCase.size(),
            'Call returned the incorrect number of rows'
        );
        System.assertEquals(4, contractSet.size(), 'Call returned the incorrect number of rows');
        System.assertEquals(5, accountSet.size(), 'Call returned the incorrect number of rows');
        System.assertEquals(
            4,
            accountIdContractIdMap.size(),
            'Call returned the incorrect number of rows'
        );
        System.assertEquals(
            5,
            accountIdDeselectedServicesMap.size(),
            'Call returned the incorrect number of rows'
        );
        System.assertEquals(1, driveNintexIds.size(), 'Call returned the incorrect number of rows');
        System.assertEquals(
            3,
            marketplaceNintexIds.size(),
            'Call returned the incorrect number of rows'
        );
    }

    /**
     * @description To test createAgreementsFromOpportunities
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenCreateAgreementsFromOpportunitiesThenCallService() {
        List<Opportunity> opportunitiesRecords = new List<Opportunity>{
            new Opportunity(
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Name = 'Test1',
                StageName = 'Closed Won',
                AccountId = fflib_IDGenerator.generate(Account.SObjectType),
                Nintex_Use_Case__c = 'New Franchise - Unknown',
                ContractId = fflib_IDGenerator.generate(Contract.SObjectType),
                Nintex_Signed_Date__c = System.today()
            ),
            new Opportunity(
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Name = 'Test2',
                StageName = 'Stalled',
                AccountId = fflib_IDGenerator.generate(Account.SObjectType),
                Nintex_Use_Case__c = 'New Franchise - Unknown',
                ContractId = fflib_IDGenerator.generate(Contract.SObjectType),
                Nintex_Signed_Date__c = System.today()
            ),
            new Opportunity(
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Name = 'Test3',
                StageName = 'Stalled',
                AccountId = fflib_IDGenerator.generate(Account.SObjectType),
                Nintex_Use_Case__c = 'Change of Ownership',
                ContractId = null,
                Nintex_Signed_Date__c = System.today()
            ),
            new Opportunity(
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Name = 'Test4',
                StageName = 'Stalled',
                AccountId = fflib_IDGenerator.generate(Account.SObjectType),
                Nintex_Use_Case__c = 'Rate Change',
                ContractId = fflib_IDGenerator.generate(Contract.SObjectType),
                Nintex_Signed_Date__c = null
            ),
            new Opportunity(
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Name = 'Test5',
                StageName = 'Stalled',
                AccountId = fflib_IDGenerator.generate(Account.SObjectType),
                Nintex_Use_Case__c = 'Drive - Amendment',
                ContractId = fflib_IDGenerator.generate(Contract.SObjectType),
                Nintex_Signed_Date__c = System.today()
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        INintexSubmissionService nintexSubmissionService = (INintexSubmissionService) mocks.mock(
            INintexSubmissionService.class
        );
        Application.SERVICE.setMock(INintexSubmissionService.class, nintexSubmissionService);

        Opportunities.newInstance(opportunitiesRecords).createAgreementsFromOpportunities();
        ((INintexSubmissionService) mocks.verify(nintexSubmissionService, 1))
            .submitOpportunities((IOpportunities) fflib_Match.anyObject());
    }

    /**
     * @description To test restriction on corporate Opportunity Stage change to Contracting
     * when it has no associated Work Order.
     */
    @isTest
    private static void testWhenStageChangedToContractingThenRestrictUpdateOnOpportunityWithoutWorkOrder() {
        Id mockOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        List<Opportunity> mockOpportunities = new List<Opportunity>{
            new Opportunity(Id = mockOpportunityId, StageName = STAGENAME_CONTRACTING)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersService mockWorkOrdersService = (IWorkOrdersService) mocks.mock(
            IWorkOrdersService.class
        );
        IOpportunitiesService mockOpportunitiesService = (IOpportunitiesService) mocks.mock(
            IOpportunitiesService.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersService.collectOpportunitiesWithoutWorkOrder(mockOpportunities))
            .thenReturn(mockOpportunities);
        mocks.when(
                mockOpportunitiesService.collectOpportunitiesWithoutWorkOrderInContractingStage(
                    mockOpportunities
                )
            )
            .thenReturn(mockOpportunities);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IWorkOrdersService.class, mockWorkOrdersService);
        Application.SERVICE.setMock(IOpportunitiesService.class, mockOpportunitiesService);
        Test.startTest();
        Opportunities.newInstance(mockOpportunities).validateOpportunitiesInContractingStage();
        Test.stopTest();
        System.assertEquals(
            System.Label.Opportunity_Contracting_Stage_Validation_Error_Message,
            fflib_SObjects.Errors.getAll()[0].message,
            CONTRACTING_STAGENAME_ERROR_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test corporate Opportunity Stage change to
     * Contracting when it has associated Work Order.
     */
    @isTest
    private static void testWhenOpportunityHasWorkOrderThenNoErrorMessageDisplayed() {
        Id mockOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        List<Opportunity> mockOpportunities = new List<Opportunity>{
            new Opportunity(Id = mockOpportunityId, StageName = STAGENAME_CONTRACTING)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersService mockWorkOrdersService = (IWorkOrdersService) mocks.mock(
            IWorkOrdersService.class
        );
        IOpportunitiesService mockOpportunitiesService = (IOpportunitiesService) mocks.mock(
            IOpportunitiesService.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersService.collectOpportunitiesWithoutWorkOrder(mockOpportunities))
            .thenReturn(new List<Opportunity>{});
        mocks.when(
                mockOpportunitiesService.collectOpportunitiesWithoutWorkOrderInContractingStage(
                    mockOpportunities
                )
            )
            .thenReturn(new List<Opportunity>{});
        mocks.stopStubbing();
        Application.SERVICE.setMock(IWorkOrdersService.class, mockWorkOrdersService);
        Application.SERVICE.setMock(IOpportunitiesService.class, mockOpportunitiesService);
        Test.startTest();
        Opportunities.newInstance(mockOpportunities).validateOpportunitiesInContractingStage();
        Test.stopTest();
        System.assertEquals(
            0,
            fflib_SObjects.Errors.getAll().size(),
            CONTRACTING_OPPORTUNITIES_ERROR_ASSERT_MESSAGE
        );
    }
    /**
     * @description To test when an account of an Opportunity is updated then Account life cycle status of Old and New
     * account changed.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAccountChangedInOpportunityThenUpdateAccountLifeCycleStatus() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Id opportunityId1 = fflib_IDGenerator.generate(Opportunity.SObjectType);
        List<Account> accounts = new List<Account>{
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Parent 1',
                Account_Lifecycle_Status__c = 'Unvetted',
                RecordTypeId = businessRecordTypeId
            ),
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Parent 2',
                Account_Lifecycle_Status__c = 'In Pursuit',
                RecordTypeId = businessRecordTypeId
            )
        };
        List<Opportunity> oldOpportunityRecords = new List<Opportunity>{
            new Opportunity(Id = opportunityId1, AccountId = accounts[1].Id)
        };
        List<Opportunity> opportunityRecords = new List<Opportunity>{
            new Opportunity(Id = opportunityId1, AccountId = accounts[0].Id)
        };
        Set<Id> newAccountIds = new Set<Id>{ accounts[0].Id };
        Set<Id> oldAccountIds = new Set<Id>{ accounts[1].Id };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunitiesSelector opportunitySelectorMock = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );
        IAccountsService serviceMock = (IAccountsService) mocks.mock(IAccountsService.class);
        mocks.startStubbing();
        mocks.when(opportunitySelectorMock.SObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(opportunitySelectorMock.selectOpportunitiesByAccountId(oldAccountIds))
            .thenReturn(oldOpportunityRecords);
        mocks.stopStubbing();

        Application.SERVICE.setMock(IAccountsService.class, serviceMock);
        Application.Selector.setMock(opportunitySelectorMock);
        Opportunities.newInstance(opportunityRecords)
            .updateAccountLifecycleStatusOnOpportunityUpdate(
                new Map<Id, Opportunity>(oldOpportunityRecords)
            );
        ((IAccountsService) mocks.verify(serviceMock, 1))
            .updateAcountLifeCycleStatusToInPursuit(newAccountIds);
        ((IAccountsService) mocks.verify(serviceMock, 1))
            .updateAcountLifeCycleStatusToUnvetted(oldAccountIds, oldAccountIds);
    }
    /**
     * @description LEM-4974 It is used to create opportunity team members for new opportunities
     * and Opportunities where owner is changed
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOpportunityIsCreatedThenOpportunityTeamMemberCreated() {
        Id opportunityRecordId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Opportunity newOpportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityRecordId)
            .toSObject();
        List<Opportunity> opportunityList = new List<Opportunity>{ newOpportunity };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        INotifierEventsService serviceMock = (INotifierEventsService) mocks.mock(
            INotifierEventsService.class
        );
        Application.SERVICE.setMock(INotifierEventsService.class, serviceMock);
        Opportunities.newInstance(opportunityList)
            .createOpportunityTeamMembersForManagersOnOwnerUpdate(
                EVENT_TOPIC_OPPORTUNITY_TEAM_MEMBER_CREATION
            );
        ((INotifierEventsService) mocks.verify(serviceMock, 1))
            .publishEvents(
                new Map<String, String>{
                    EVENT_TOPIC_OPPORTUNITY_TEAM_MEMBER_CREATION => JSON.serialize(
                        new Set<Id>{ opportunityRecordId }
                    )
                }
            );
    }
    @isTest
    private static void testWhenStageChangeWithNoContactRoleAndWithBDProductThenAllow() {
        List<Account> accountList = new List<Account>{
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 1'),
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 2')
        };

        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);

        List<Opportunity> oldOpportunityRecords = new List<Opportunity>{
            new Opportunity(
                Id = opportunityId,
                Name = 'Test1',
                StageName = 'Pitching',
                Type = 'New',
                Accountid = accountList[0].Id,
                Probability = 30,
                Deal_Type__c = 'Standard',
                ForecastCategoryName = 'Pipeline',
                CloseDate = System.today().addDays(3)
            )
        };

        List<Opportunity> opportunityRecords = new List<Opportunity>{
            new Opportunity(
                id = opportunityId,
                Name = 'Test1',
                StageName = 'Pitching',
                Type = 'New',
                Accountid = accountList[0].Id,
                Probability = 30,
                Deal_Type__c = 'Standard',
                ForecastCategoryName = 'Pipeline',
                CloseDate = System.today().addDays(3)
            )
        };

        List<OpportunityContactRole> oppContactRole = new List<OpportunityContactRole>{
            new OpportunityContactRole(
                Id = fflib_IDGenerator.generate(OpportunityContactRole.SObjectType),
                OpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType)
            )
        };
        List<SBQQ__Quote__c> quoteWithBDProduct = new List<SBQQ__Quote__c>{
            new SBQQ__Quote__c(
                Id = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType),
                SBQQ__Opportunity2__c = opportunityRecords[0].Id,
                HasPipelineProduct__c = true
            )
        };

        Opportunity updateOpportunityRecord = opportunityRecords[0];
        updateOpportunityRecord.StageName = 'Negotiating';
        updateOpportunityRecord.SBQQ__PrimaryQuote__c = quoteWithBDProduct[0].Id;

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunities opptInstance = Opportunities.newInstance(opportunityRecords);
        IOpportunityContactRoleSelector oppContactRoleSelectorMock = (IOpportunityContactRoleSelector) mocks.mock(
            IOpportunityContactRoleSelector.class
        );
        IOpportunitiesSelector opportunitySelectorMock = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );
        mocks.startStubbing();
        mocks.when(oppContactRoleSelectorMock.SObjectType())
            .thenReturn(OpportunityContactRole.SObjectType);
        mocks.when(opportunitySelectorMock.SObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(
                oppContactRoleSelectorMock.selectByOpportunity(
                    new Set<Id>{ opportunityRecords[0].Id }
                )
            )
            .thenReturn(oppContactRole);
        mocks.when(
                opportunitySelectorMock.selectOpportunitiesWithQuotes(
                    new Set<Id>{ opportunityRecords[0].Id }
                )
            )
            .thenReturn(new List<Opportunity>{ updateOpportunityRecord });
        mocks.stopStubbing();

        Application.Selector.setMock(oppContactRoleSelectorMock);
        Application.Selector.setMock(opportunitySelectorMock);
        opptInstance.contactRoleValidationBeforeStageChangePastPitching(
            new Map<Id, Opportunity>(oldOpportunityRecords),
            new List<Opportunity>{ updateOpportunityRecord }
        );

        ApexPages.Message contactRoleFailureMessage = new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'Before moving forwarding into Negotiating Stage, please ensure you have at least one contact role that is a "Contact Signatory", and at least one contact listed as the "Primary Contact". One contact can meet both criteria.'
        );

        //Assertion
        System.assertEquals(
            1,
            ApexPages.getMessages().size(),
            'The Opportunity without linked contact role did not fire an error'
        );
        System.assertEquals(contactRoleFailureMessage, ApexPages.getMessages()[0], 'Message');
    }

    /**
     * @description LEM-13473 It is used to test if opportunity contact role is created for new opportunities
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOpportunityIsCreatedThenOpportunityContactRoleIsCreated() {
        Id opportunityRecordId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id acrId = fflib_IDGenerator.generate(AccountContactRelation.SObjectType);
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);

        Fake opportunityFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityRecordId)
            .setField(Opportunity.Source__c, 'Manual')
            .setField(Opportunity.AccountId, accountId);
        //.setParent('Account', accountFakeInstance);

        Opportunity opportunityRecord = (Opportunity) ServiceMockDataBuilder.convertToSObject(
            opportunityFakeInstance
        );
        Fake mockAccountContactRelation = new Fake(AccountContactRelation.class)
        .setField(AccountContactRelation.Id, acrId)
        .setField(AccountContactRelation.AccountId, accountId)
        .setField(AccountContactRelation.ContactId, contactId)
        .setField(AccountContactRelation.IsActive, true)
        .setField(AccountContactRelation.Roles, 'Decision Maker')
        .setField(AccountContactRelation.LastModifiedDate, Date.today() - 1)
        .setParent(
            'Contact',
            new Fake(Contact.class).setField(Contact.Id, contactId)
        )
        .setParent(
            'Account',
            new Fake(Account.class).setField(Account.Id, accountId)
        );
        AccountContactRelation acrRecord = (AccountContactRelation) ServiceMockDataBuilder.convertToSObject(
            mockAccountContactRelation
        );

        List<Opportunity> opportunityList = new List<Opportunity>{ opportunityRecord };
        Map<Id, Id> opportunityIdToContactIdMap = new Map<Id, Id>();
        opportunityIdToContactIdMap.put(opportunityRecordId, contactId);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountContactRelationsSelector selectorMock = (IAccountContactRelationsSelector) mocks.mock(
            IAccountContactRelationsSelector.class
        );
        IOpportunityContactRoleService serviceMock = (IOpportunityContactRoleService) mocks.mock(
            IOpportunityContactRoleService.class
        );
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(AccountContactRelation.SObjectType);
        mocks.when(selectorMock.selectActiveACRByAccountIdsAndRoles(new Set<Id>{ accountId }))
            .thenReturn(new List<AccountContactRelation>{ acrRecord });
        mocks.stopStubbing();
        Application.Selector.setMock(selectorMock);
        Application.SERVICE.setMock(IOpportunityContactRoleService.class, serviceMock);
        Opportunities.newInstance(opportunityList).createOCRForManuallyCreatedOpportunities();
        ((IOpportunityContactRoleService) mocks.verify(serviceMock, 1))
            .createOCR(opportunityIdToContactIdMap, true);
    }

    /**
     * @description LEM-13473 It is used to test if opportunity contact role is created for lead converted opportunities
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOpportunityIsCreatedFromLeadThenOpportunityContactRoleIsUpdated() {
        Id opportunityContactRoleId = fflib_IDGenerator.generate(
            OpportunityContactRole.SObjectType
        );
        Id opportunityRecordId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);

        Fake opportunityContactRoleFakeInstance = new Fake(OpportunityContactRole.class)
            .setField(OpportunityContactRole.Id, opportunityContactRoleId)
            .setField(OpportunityContactRole.OpportunityId, opportunityRecordId)
            .setField(OpportunityContactRole.ContactId, contactId)
            .setField(OpportunityContactRole.IsPrimary, true)
            .setField(OpportunityContactRole.LastModifiedDate, Date.today() - 1);
        OpportunityContactRole ocrRecord = (OpportunityContactRole) ServiceMockDataBuilder.convertToSObject(
            opportunityContactRoleFakeInstance
        );
        Fake opportunityFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityRecordId)
            .setField(Opportunity.Source__c, 'Manual')
            .setField(Opportunity.AccountId, accountId)
            .setChildren(
                'OpportunityContactRoles',
                new List<Fake>{ opportunityContactRoleFakeInstance }
            );
        //.setParent('Account', accountFakeInstance);

        Opportunity opportunityRecord = (Opportunity) ServiceMockDataBuilder.convertToSObject(
            opportunityFakeInstance
        );

        List<Opportunity> opportunityList = new List<Opportunity>{ opportunityRecord };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunityContactRoleSelector selectorMock = (IOpportunityContactRoleSelector) mocks.mock(
            IOpportunityContactRoleSelector.class
        );

        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(OpportunityContactRole.SObjectType);
        mocks.when(selectorMock.selectByOpportunity(new Set<Id>{ opportunityRecordId }))
            .thenReturn(new List<OpportunityContactRole>{ ocrRecord });
        mocks.stopStubbing();
        Application.Selector.setMock(selectorMock);
        Opportunities.newInstance(opportunityList).updateOCRForLeadConvertedOpportunities();
        System.assertEquals('Contract Signatory', ocrRecord.Role, 'Update unsuccessful');
    }

    /**
     * @description To test association of Brand with Opportunity for 'SMB' parent Account.
     * @JIRA# LEM-13447
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOpportunityHasSMBAccountAssociatedThenAssociateBrandOnOpportunity() {
        Id brandId = fflib_IDGenerator.generate(Brand__c.SObjectType);
        Id brandAssociationId = fflib_IDGenerator.generate(Brand_Association__c.SObjectType);
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get(BUSINESS_ACCOUNT_RECORD_TYPE_NAME)
            .getRecordTypeId();
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Brand__c brand = (Brand__c) new Fake(Brand__c.class)
            .setField(Brand__c.Id, brandId)
            .setField(Brand__c.Name, BRAND_NAME)
            .toSObject();
        Account parentAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, parentAccountId)
            .setField(Account.Name, ACCOUNT_NAME_BUSINESS)
            .setField(Account.RecordTypeID, businessRecordTypeId)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .toSObject();
        Brand_Association__c brandAssociation = (Brand_Association__c) new Fake(
                Brand_Association__c.class
            )
            .setField(Brand_Association__c.Brand_Name__c, brand.Id)
            .setField(Brand_Association__c.Business_Account_Name__c, parentAccount.Id)
            .setField(Brand_Association__c.Id, brandAssociationId)
            .setParent('Brand_Name__r', new Fake(Brand__c.class).setField(Brand__c.Id, brand.Id))
            .setParent(
                'Business_Account_Name__r',
                new Fake(Account.class).setField(Account.Id, parentAccount.Id)
            )
            .toSObject();
        Opportunity currentOpportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.AccountId, parentAccount.Id)
            .setField(Opportunity.Account_Record_Type__c, businessRecordTypeId)
            .setField(Opportunity.Account_Segment__c, ACCOUNT_SEGMENT_SMB)
            .setFakeId()
            .setParent(
                'Account',
                new Fake(Account.class)
                    .setField(Account.Id, parentAccountId)
                    .setField(Account.RecordTypeID, businessRecordTypeId)
            )
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBrandAssociationsSelector mockBrandAssociationsSelector = (IBrandAssociationsSelector) mocks.mock(
            IBrandAssociationsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockBrandAssociationsSelector.sObjectType())
            .thenReturn(Brand_Association__c.SObjectType);
        mocks.when(
                mockBrandAssociationsSelector.selectByBusinessAccountIds(
                    new Set<Id>{ currentOpportunity.AccountId }
                )
            )
            .thenReturn(new List<Brand_Association__c>{ brandAssociation });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockBrandAssociationsSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        Opportunities.newInstance(new List<Opportunity>{ currentOpportunity })
            .createBrandRelationshipOnOpportunityInsert();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Opportunity_Brand_Relationship__c.Opportunity__c => currentOpportunity.Id,
                        Opportunity_Brand_Relationship__c.Brand__c => brandAssociation.Id
                    }
                )
            );
    }

    /**
     * @description To test association of Brand with Opportunity for 'Enterprise Sele-Serve' parent Account.
     * @JIRA# LEM-22478
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOpportunityHasEnterpriseSelfServeAccountAssociatedThenAssociateBrandOnOpportunity() {
        Id brandId = fflib_IDGenerator.generate(Brand__c.SObjectType);
        Id brandAssociationId = fflib_IDGenerator.generate(Brand_Association__c.SObjectType);
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get(BUSINESS_ACCOUNT_RECORD_TYPE_NAME)
            .getRecordTypeId();
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Brand__c brand = (Brand__c) new Fake(Brand__c.class)
            .setField(Brand__c.Id, brandId)
            .setField(Brand__c.Name, BRAND_NAME)
            .toSObject();
        Account parentAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, parentAccountId)
            .setField(Account.Name, ACCOUNT_NAME_BUSINESS)
            .setField(Account.RecordTypeID, businessRecordTypeId)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_ENTERPRISE)
            .toSObject();
        Brand_Association__c brandAssociation = (Brand_Association__c) new Fake(
                Brand_Association__c.class
            )
            .setField(Brand_Association__c.Brand_Name__c, brand.Id)
            .setField(Brand_Association__c.Business_Account_Name__c, parentAccount.Id)
            .setField(Brand_Association__c.Id, brandAssociationId)
            .setParent('Brand_Name__r', new Fake(Brand__c.class).setField(Brand__c.Id, brand.Id))
            .setParent(
                'Business_Account_Name__r',
                new Fake(Account.class).setField(Account.Id, parentAccount.Id)
            )
            .toSObject();
        Opportunity currentOpportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.AccountId, parentAccount.Id)
            .setField(Opportunity.Deal_Type__c, DEAL_TYPE)
            .setField(Opportunity.Opportunity_Sub_Type__c, SUB_TYPE)
            .setField(Opportunity.Account_Record_Type__c, businessRecordTypeId)
            .setField(Opportunity.Account_Segment__c, ACCOUNT_SEGMENT_ENTERPRISE)
            .setFakeId()
            .setParent(
                'Account',
                new Fake(Account.class)
                    .setField(Account.Id, parentAccountId)
                    .setField(Account.RecordTypeID, businessRecordTypeId)
            )
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBrandAssociationsSelector mockBrandAssociationsSelector = (IBrandAssociationsSelector) mocks.mock(
            IBrandAssociationsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockBrandAssociationsSelector.sObjectType())
            .thenReturn(Brand_Association__c.SObjectType);
        mocks.when(
                mockBrandAssociationsSelector.selectByBusinessAccountIds(
                    new Set<Id>{ currentOpportunity.AccountId }
                )
            )
            .thenReturn(new List<Brand_Association__c>{ brandAssociation });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockBrandAssociationsSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        Opportunities.newInstance(new List<Opportunity>{ currentOpportunity })
            .createBrandRelationshipOnOpportunityInsert();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Opportunity_Brand_Relationship__c.Opportunity__c => currentOpportunity.Id,
                        Opportunity_Brand_Relationship__c.Brand__c => brandAssociation.Id
                    }
                )
            );
    }

    /**
     * @description It is used to test stamping of Medal Rank At Closed Stage
     * and Deck Rank At Closed Stage when Opportunity is Closed.
     * @JIRA# LEM-14100
     */
    @isTest
    private static void testWhenOpportunityStageChangesToClosedThenStampDeckAndMedalRankAtClosed() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get(BUSINESS_ACCOUNT_RECORD_TYPE_NAME)
            .getRecordTypeId();
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Account parentAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, parentAccountId)
            .setField(Account.Name, ACCOUNT_NAME_BUSINESS)
            .setField(Account.RecordTypeID, businessRecordTypeId)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(Account.Deck_Rank__c, DECK_RANK_JACK)
            .setField(Account.Medal_Rank__c, MEDAL_RANK_GOLD)
            .toSObject();
        Opportunity currentOpportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.AccountId, parentAccount.Id)
            .setField(Opportunity.Account_Record_Type__c, businessRecordTypeId)
            .setField(Opportunity.Account_Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(Opportunity.Account_Deck_Rank__c, DECK_RANK_JACK)
            .setField(Opportunity.Medal_Rank__c, MEDAL_RANK_GOLD)
            .setField(Opportunity.IsClosed, true)
            .setFakeId()
            .setParent(
                'Account',
                new Fake(Account.class)
                    .setField(Account.Id, parentAccountId)
                    .setField(Account.RecordTypeID, businessRecordTypeId)
            )
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IOpportunities opportunitiesInstance = Opportunities.newInstance(
            new List<Opportunity>{ currentOpportunity }
        );
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        opportunitiesInstance.stampDeckRankAndMedalRankValues(
            new List<Opportunity>{ currentOpportunity }
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        System.assertEquals(
            MEDAL_RANK_GOLD,
            currentOpportunity.Medal_Rank_At_Closed_Stage__c,
            OPPORTUNITIES_ERROR_ASSERT_MESSAGE
        );
        System.assertEquals(
            DECK_RANK_JACK,
            currentOpportunity.Deck_Rank_At_Closed_Stage__c,
            OPPORTUNITIES_ERROR_ASSERT_MESSAGE
        );
    }

    /**
     * @description It is used to test stamping of Medal Rank At Closed Stage
     * and Deck Rank At Closed Stage when Opportunity is Not Closed.
     * @JIRA# LEM-14100
     */
    @isTest
    private static void testWhenOpportunityStageChangesToAnyStageThenDeckAndMedalRankAtClosedNotStamped() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get(BUSINESS_ACCOUNT_RECORD_TYPE_NAME)
            .getRecordTypeId();
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Account parentAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, parentAccountId)
            .setField(Account.Name, ACCOUNT_NAME_BUSINESS)
            .setField(Account.RecordTypeID, businessRecordTypeId)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(Account.Deck_Rank__c, DECK_RANK_JACK)
            .setField(Account.Medal_Rank__c, MEDAL_RANK_GOLD)
            .toSObject();
        Opportunity currentOpportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.AccountId, parentAccount.Id)
            .setField(Opportunity.Account_Record_Type__c, businessRecordTypeId)
            .setField(Opportunity.Account_Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(Opportunity.Account_Deck_Rank__c, DECK_RANK_JACK)
            .setField(Opportunity.Medal_Rank__c, MEDAL_RANK_GOLD)
            .setField(Opportunity.IsClosed, false)
            .setFakeId()
            .setParent(
                'Account',
                new Fake(Account.class)
                    .setField(Account.Id, parentAccountId)
                    .setField(Account.RecordTypeID, businessRecordTypeId)
            )
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IOpportunities opportunitiesInstance = Opportunities.newInstance(
            new List<Opportunity>{ currentOpportunity }
        );
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        opportunitiesInstance.stampDeckRankAndMedalRankValues(
            new List<Opportunity>{ currentOpportunity }
        );
        Test.stopTest();
        System.assertNotEquals(
            MEDAL_RANK_GOLD,
            currentOpportunity.Medal_Rank_At_Closed_Stage__c,
            OPPORTUNITIES_ERROR_ASSERT_MESSAGE
        );
        System.assertNotEquals(
            DECK_RANK_JACK,
            currentOpportunity.Deck_Rank_At_Closed_Stage__c,
            OPPORTUNITIES_ERROR_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test whether opportunity lookup field is going to be set or not
     * on MxTagAssociation when new opportunity is created
     */
    @isTest
    private static void testWhenOpportunityisCreatedThenUpdateRelatedMxTagAssociation() {
        Integer year = system.today().year();
        String month = '12';
        String day = '31';
        String calculatedCloseDate = year + '-' + month + '-' + day;
        Date opportunityCloseDate = Date.valueOf(calculatedCloseDate);

        Id testAccountId1 = Fake.generateId(Account.class);
        Account account = (Account) new Fake(Account.class)
            .setField(Account.Id, testAccountId1)
            .setField(Account.Name, 'Account 1')
            .toSObject();

        Id testOppId1 = Fake.generateId(Opportunity.class);
        Opportunity opportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, testOppId1)
            .setField(Opportunity.Name, 'Opportunity 1')
            .setField(Opportunity.StageName, 'Prospecting')
            .setField(Opportunity.CloseDate, opportunityCloseDate)
            .setField(Opportunity.AccountId, testAccountId1)
            .toSObject();

        Id testMxTagId1 = Fake.generateId(Mx_Tag_Association__c.class);
        Mx_Tag_Association__c mxTagAssociation = (Mx_Tag_Association__c) new Fake(
                Mx_Tag_Association__c.class
            )
            .setField(Mx_Tag_Association__c.Id, testMxTagId1)
            .setField(Mx_Tag_Association__c.Account__c, testAccountId1)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IMxTagAssociationsSelector mxTagAssociationsSelectorMock = (IMxTagAssociationsSelector) mocks.mock(
            IMxTagAssociationsSelector.class
        );
        IOpportunitiesSelector opportunitySelectorMock = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );

        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Schema.Account.SObjectType);
        mocks.when(accountSelectorMock.selectById(new Set<Id>{ testAccountId1 }))
            .thenReturn(new List<Account>{ account });

        mocks.when(opportunitySelectorMock.sObjectType())
            .thenReturn(Schema.Opportunity.SObjectType);
        mocks.when(opportunitySelectorMock.selectById(new Set<Id>{ testOppId1 }))
            .thenReturn(new List<Opportunity>{ opportunity });

        mocks.when(mxTagAssociationsSelectorMock.sObjectType())
            .thenReturn(Schema.Mx_Tag_Association__c.SObjectType);
        mocks.when(
                mxTagAssociationsSelectorMock.selectByBusinessAccountIds(
                    new Set<Id>{ testAccountId1 }
                )
            )
            .thenReturn(new List<Mx_Tag_Association__c>{ mxTagAssociation });

        mocks.stopStubbing();
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(mxTagAssociationsSelectorMock);
        Application.SELECTOR.setMock(opportunitySelectorMock);

        Test.startTest();
        Opportunities.newInstance(new List<Opportunity>{ opportunity })
            .addMxTagAssociationToNewlyCreatedOpportunity();
        System.assertEquals(0, fflib_SObjects.Errors?.getAll().size(), 'No error shown');
        Test.stopTest();
    }

    /**
     * @description To test whether Last Inbound Date is updated on Opportunity.
     */
    @isTest
    private static void testWhenOpportunityPrimaryCampaignSourceUpdatedThenLastInboundDateUpdated() {
        Id opportunityId1 = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id opportunityId2 = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id campaignId = fflib_IDGenerator.generate(Campaign.SObjectType);
        List<Opportunity> opportunityRecords = new List<Opportunity>{
            new Opportunity(
                Id = opportunityId1,
                Name = OPPORTUNITY_NAME,
                StageName = STAGENAME_CONTRACTING,
                CampaignId = campaignId
            ),
            new Opportunity(
                Id = opportunityId2,
                Name = OPPORTUNITY_NAME,
                StageName = STAGENAME_CONTRACTING
            )
        };
        Opportunities.newInstance(opportunityRecords).updateLastInboundDateTime();
        System.assertNotEquals(
            null,
            opportunityRecords[0].Last_Inbound_Date_Time__c,
            ASSERT_MESSAGE
        );
        System.assertEquals(null, opportunityRecords[1].Last_Inbound_Date_Time__c, ASSERT_MESSAGE);
    }
    /**
     * @description It tested when the opportunity is moved to Negotiating stage with events with held status,
     * then it should not throw a validation error.
     */
    @isTest
    private static void testWhenOpportunityStageMovedToNegotiatingWithHeldEventThenDontThrowValdiation() {
        String eventStatusHeld = 'Event Held';
        String accountName = 'Test Account';
        String opportunityName = 'Test Opportunity';
        Id testAccountId1 = Fake.generateId(Account.class);
        Account account = (Account) new Fake(Account.class)
            .setField(Account.Id, testAccountId1)
            .setField(Account.Name, accountName)
            .toSObject();

        Id opportunityId = Fake.generateId(Opportunity.class);
        Opportunity opportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.Type, NEW_TYPE)
            .setField(Opportunity.Name, opportunityName)
            .setField(Opportunity.StageName, OPPORTUNITY_NEGOTIATING_STAGE)
            .setField(Opportunity.CloseDate, System.today().addDays(10))
            .setField(Opportunity.AccountId, testAccountId1)
            .setField(Opportunity.Estimated_Number_of_Stores__c, 1)
            .setField(Opportunity.Account_Segment__c, ACCOUNT_SEGMENT_SMB)
            .toSObject();

        Id eventId = Fake.generateId(Event.class);
        Event event = (Event) new Fake(Event.class)
            .setField(Event.Id, eventId)
            .setField(Event.DurationInMinutes, 10)
            .setField(Event.WhatId, opportunityId)
            .setField(Event.ActivityDateTime, System.today().addDays(10))
            .setField(Event.Event_Status__c, eventStatusHeld)
            .toSObject();
        Aggregate mockAPARAggregate = new Aggregate();
        mockAPARAggregate.put('WhatId', opportunityId);
        mockAPARAggregate.put('countIds', 1);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IEventsSelector eventSelectorMock = (IEventsSelector) mocks.mock(IEventsSelector.class);
        mocks.startStubbing();
        mocks.when(eventSelectorMock.sObjectType()).thenReturn(Schema.Event.SObjectType);
        mocks.when(
                eventSelectorMock.selectCountOfEventsByStatusAndRelatedToIds(
                    new Set<Id>{ opportunityId },
                    eventStatusHeld
                )
            )
            .thenReturn(new List<Aggregate>{ mockAPARAggregate });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(eventSelectorMock);
        Test.startTest();
        Opportunities.newInstance(new List<Opportunity>{ opportunity })
            .validateOpportunitiesMovedToNegotiatingWithoutHeldEvents();
        Test.stopTest();
        System.assertEquals(
            OPPORTUNITY_NEGOTIATING_STAGE,
            Opportunity.StageName,
            OPPORTUNITIES_STAGE_UPDATE_ASSERT_MESSAGE
        );
    }
    /**
     * @description It tested when the opportunity is moved to Negotiating stage without any events with held status,
     * then it should throw a validation error.
     */
    @isTest
    private static void testWhenOpportunityStageMovedToNegotiatingWithoutHeldEventThenThrowValdiation() {
        String eventStatusMissed = 'Event Missed';
        String eventStatusHeld = 'Event Held';
        String accountName = 'Test Account';
        String opportunityName = 'Test Opportunity';
        Id testAccountId1 = Fake.generateId(Account.class);
        Account account = (Account) new Fake(Account.class)
            .setField(Account.Id, testAccountId1)
            .setField(Account.Name, accountName)
            .toSObject();

        Id opportunityId = Fake.generateId(Opportunity.class);
        Opportunity opportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.Type, NEW_TYPE)
            .setField(Opportunity.Name, opportunityName)
            .setField(Opportunity.StageName, OPPORTUNITY_NEGOTIATING_STAGE)
            .setField(Opportunity.CloseDate, System.today().addDays(10))
            .setField(Opportunity.AccountId, testAccountId1)
            .setField(Opportunity.Estimated_Number_of_Stores__c, 1)
            .setField(Opportunity.Account_Segment__c, ACCOUNT_SEGMENT_SMB)
            .toSObject();

        Id eventId = Fake.generateId(Event.class);
        Event event = (Event) new Fake(Event.class)
            .setField(Event.Id, eventId)
            .setField(Event.DurationInMinutes, 10)
            .setField(Event.WhatId, opportunityId)
            .setField(Event.ActivityDateTime, System.today().addDays(10))
            .setField(Event.Event_Status__c, eventStatusMissed)
            .toSObject();
        Aggregate mockAPARAggregate = new Aggregate();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IEventsSelector eventSelectorMock = (IEventsSelector) mocks.mock(IEventsSelector.class);
        mocks.startStubbing();
        mocks.when(eventSelectorMock.sObjectType()).thenReturn(Schema.Event.SObjectType);
        mocks.when(
                eventSelectorMock.selectCountOfEventsByStatusAndRelatedToIds(
                    new Set<Id>{ opportunityId },
                    eventStatusHeld
                )
            )
            .thenReturn(new List<Aggregate>{ mockAPARAggregate });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(eventSelectorMock);
        Test.startTest();
        Opportunities.newInstance(new List<Opportunity>{ opportunity })
            .validateOpportunitiesMovedToNegotiatingWithoutHeldEvents();
        Test.stopTest();
        System.assertEquals(
            System.Label.Error_on_Negotiating_Opportunity_without_held_Event,
            opportunity.getErrors()[0].getMessage(),
            OPPORTUNITIES_NO_HELD_EVENT_ASSERT_ERROR_MESSAGE
        );
    }
    /**
     * @description It is used to test when the opportunity is moved to Contracting stage with events with held status,
     * then it should not throw a validation error.
     */
    @isTest
    private static void testWhenOpportunityStageMovedToContractingWithHeldEventThenDontThrowValdiation() {
        Id opportunityId = Fake.generateId(Opportunity.class);
        Id eventId = Fake.generateId(Event.class);
        String eventStatusHeld = EVENT_STATUS_HELD;
        String accountName = ACCOUNT_NAME;
        String opportunityName = OPPORTUNITY_NAME;
        Id testAccountId1 = Fake.generateId(Account.class);
        Account account = (Account) new Fake(Account.class)
            .setField(Account.Id, testAccountId1)
            .setField(Account.Name, accountName)
            .toSObject();

        Opportunity opportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.Type, NEW_TYPE)
            .setField(Opportunity.Name, opportunityName)
            .setField(Opportunity.StageName, STAGENAME_CONTRACTING)
            .setField(Opportunity.CloseDate, System.today().addDays(10))
            .setField(Opportunity.AccountId, testAccountId1)
            .setField(Opportunity.Estimated_Number_of_Stores__c, 1)
            .setField(Opportunity.Account_Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(Opportunity.SDR_Opportunity_Owner__c, Fake.generateId(User.class))
            .toSObject();

        Event event = (Event) new Fake(Event.class)
            .setField(Event.Id, eventId)
            .setField(Event.DurationInMinutes, 10)
            .setField(Event.WhatId, opportunityId)
            .setField(Event.ActivityDateTime, System.today().addDays(10))
            .setField(Event.Event_Status__c, eventStatusHeld)
            .toSObject();
        Aggregate mockAPARAggregate = new Aggregate();
        mockAPARAggregate.put('WhatId', opportunityId);
        mockAPARAggregate.put('countIds', 1);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IEventsSelector eventSelectorMock = (IEventsSelector) mocks.mock(IEventsSelector.class);
        mocks.startStubbing();
        mocks.when(eventSelectorMock.sObjectType()).thenReturn(Schema.Event.SObjectType);
        mocks.when(
                eventSelectorMock.selectCountOfEventsByStatusAndRelatedToIds(
                    new Set<Id>{ opportunityId },
                    eventStatusHeld
                )
            )
            .thenReturn(new List<Aggregate>{ mockAPARAggregate });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(eventSelectorMock);
        Test.startTest();
        Opportunities.newInstance(new List<Opportunity>{ opportunity })
            .validateOpportunitiesMovedToNegotiatingWithoutHeldEvents();
        Test.stopTest();
        System.assertEquals(
            STAGENAME_CONTRACTING,
            Opportunity.StageName,
            OPPORTUNITIES_STAGE_UPDATE_ASSERT_MESSAGE
        );
    }
    /**
     * @description It is used to test when the opportunity is moved to Contracting stage without any events with held status,
     * then it should throw a validation error.
     */
    @isTest
    private static void testWhenOpportunityStageMovedToContractingWithoutHeldEventThenThrowValdiation() {
        Id opportunityId = Fake.generateId(Opportunity.class);
        Id eventId = Fake.generateId(Event.class);
        String eventStatusMissed = EVENT_STATUS_MISSED;
        String eventStatusHeld = EVENT_STATUS_HELD;
        String accountName = ACCOUNT_NAME;
        String opportunityName = OPPORTUNITY_NAME;
        Id testAccountId1 = Fake.generateId(Account.class);
        Account account = (Account) new Fake(Account.class)
            .setField(Account.Id, testAccountId1)
            .setField(Account.Name, accountName)
            .toSObject();

        Opportunity opportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.Type, NEW_TYPE)
            .setField(Opportunity.Name, opportunityName)
            .setField(Opportunity.StageName, STAGENAME_CONTRACTING)
            .setField(Opportunity.CloseDate, System.today().addDays(10))
            .setField(Opportunity.AccountId, testAccountId1)
            .setField(Opportunity.Estimated_Number_of_Stores__c, 1)
            .setField(Opportunity.Account_Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(Opportunity.SDR_Opportunity_Owner__c, Fake.generateId(User.class))
            .toSObject();

        Event event = (Event) new Fake(Event.class)
            .setField(Event.Id, eventId)
            .setField(Event.DurationInMinutes, 10)
            .setField(Event.WhatId, opportunityId)
            .setField(Event.ActivityDateTime, System.today().addDays(10))
            .setField(Event.Event_Status__c, eventStatusMissed)
            .toSObject();
        Aggregate mockAPARAggregate = new Aggregate();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IEventsSelector eventSelectorMock = (IEventsSelector) mocks.mock(IEventsSelector.class);
        mocks.startStubbing();
        mocks.when(eventSelectorMock.sObjectType()).thenReturn(Schema.Event.SObjectType);
        mocks.when(
                eventSelectorMock.selectCountOfEventsByStatusAndRelatedToIds(
                    new Set<Id>{ opportunityId },
                    eventStatusHeld
                )
            )
            .thenReturn(new List<Aggregate>{ mockAPARAggregate });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(eventSelectorMock);
        Test.startTest();
        Opportunities.newInstance(new List<Opportunity>{ opportunity })
            .validateOpportunitiesMovedToNegotiatingWithoutHeldEvents();
        Test.stopTest();
        System.assertEquals(
            System.Label.Error_on_Contracting_Opportunity_without_held_Event,
            opportunity.getErrors()[0].getMessage(),
            OPPORTUNITIES_NO_HELD_EVENT_ASSERT_ERROR_MESSAGE
        );
    }

    /**
     * @description To test that Active Account Plan Id is set when Opportunity is created.
     */
    @isTest
    private static void testWhenOpportunityCreatedThenSetDefaultActiveAccountPlanId() {
        Id accountId = Fake.generateId(Account.class);
        List<String> businessAccountIdList = new List<String>();
        businessAccountIdList.add(accountId);
        Id accountPlanId = Fake.generateId(Account_Plan__c.class);
        Id opportunityId = Fake.generateId(Opportunity.class);

        Account_Plan__c accountPlanRecord = (Account_Plan__c) new Fake(Account_Plan__c.class)
            .setField(Account_Plan__c.Id, accountPlanId)
            .setField(Account_Plan__c.Name, ACCOUNT_PLAN_NAME)
            .setField(Account_Plan__c.Account__c, accountId)
            .setParent('Account__r', new Fake(Account.class).setField(Account.Id, accountId))
            .setField(Account_Plan__c.Status__c, ACTIVE)
            .toSObject();

        Opportunity opportunity1 = (Opportunity) new Fake(Opportunity.class)
            .setField(opportunity.Id, opportunityId)
            .setField(opportunity.AccountId, accountId)
            .setParent('Account', new Fake(Account.class).setField(Account.Id, accountId))
            .setField(opportunity.StageName, PITCHING)
            .setField(opportunity.Type, EXISTING_TYPE)
            .setField(opportunity.IsClosed, false)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        AccountPlansSelector mocksAccountPlnsSelector = (AccountPlansSelector) mocks.mock(
            AccountPlansSelector.class
        );
        mocks.startStubbing();
        mocks.when(mocksAccountPlnsSelector.sObjectType())
            .thenReturn(Schema.Account_Plan__c.SObjectType);
        mocks.when(
                mocksAccountPlnsSelector.selectActiveAccountPlanByAccounts(new Set<Id>{ accountId })
            )
            .thenReturn(new List<Account_Plan__c>{ accountPlanRecord });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mocksAccountPlnsSelector);

        Test.startTest();
        Opportunities.newInstance(new List<Opportunity>{ opportunity1 })
            .assignActiveAccountPlanId();
        System.assertEquals(
            accountPlanRecord.Id,
            opportunity1.Account_Plan__c,
            ACCOUNTPLANID_ERROR_ASSERT_MESSAGE
        );
        Test.stopTest();
    }

    /**
     * @description To test when Opportunities are inserted then initiate Work Order Creation for Mx Portal Store Addition.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOpportunitiesInsertedThenInitiateWorkOrderCreationForMxPortalStoreAddition() {
        Id opportunityId = Fake.generateId(Opportunity.class);
        Fake opportunityFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.Type, EXISTING_TYPE)
            .setField(Opportunity.Opportunity_Sub_Type__c, SUB_TYPE_NEW_STORE_EXPANSION)
            .setField(Opportunity.Source__c, SOURCE_MX_PORTAL);
        List<Opportunity> fakeOpportunities = new List<Opportunity>{
            (Opportunity) opportunityFakeInstance.toSObject()
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrderCreationTriggerService workOrderCreationTriggerServiceMock = (IWorkOrderCreationTriggerService) mocks.mock(
            IWorkOrderCreationTriggerService.class
        );
        Application.SERVICE.setMock(
            IWorkOrderCreationTriggerService.class,
            workOrderCreationTriggerServiceMock
        );
        Test.startTest();
        Opportunities.newInstance(fakeOpportunities)
            .evaluateAndInitiateWorkOrderCreationForMxPortalStoreAddition();
        Test.stopTest();
        ((IWorkOrderCreationTriggerService) mocks.verify(workOrderCreationTriggerServiceMock, 1))
            .initiateWorkOrderCreation(new Set<Id>{ opportunityId }, GENERIC_WORK_ORDER_CREATION);
    }

    /**
     * @description To test when Opportunities are inserted for non Mx Portal creation Source then
     * do not initiate Work Order Creation.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOpportunitiesInsertedForNonMxPortalSourceThenDoNotInitiateWorkOrderCreation() {
        Id opportunityId = Fake.generateId(Opportunity.class);
        Fake opportunityFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.Type, EXISTING_TYPE)
            .setField(Opportunity.Opportunity_Sub_Type__c, SUB_TYPE_NEW_STORE_EXPANSION)
            .setField(Opportunity.Source__c, SOURCE_NINTEX);
        List<Opportunity> fakeOpportunities = new List<Opportunity>{
            (Opportunity) opportunityFakeInstance.toSObject()
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrderCreationTriggerService workOrderCreationTriggerServiceMock = (IWorkOrderCreationTriggerService) mocks.mock(
            IWorkOrderCreationTriggerService.class
        );
        Application.SERVICE.setMock(
            IWorkOrderCreationTriggerService.class,
            workOrderCreationTriggerServiceMock
        );
        Test.startTest();
        Opportunities.newInstance(fakeOpportunities)
            .evaluateAndInitiateWorkOrderCreationForMxPortalStoreAddition();
        Test.stopTest();
        ((IWorkOrderCreationTriggerService) mocks.verify(workOrderCreationTriggerServiceMock, 0))
            .initiateWorkOrderCreation(new Set<Id>{ opportunityId }, GENERIC_WORK_ORDER_CREATION);
    }
    /**
     * @description To test when VSP Opportunities are upadted then Opportunity Name should be updated
     */
    @isTest
    static void testWhenVSPOpportunityUpdatedThenNameShouldBeUpdated() {
        Id testAccountId1 = Fake.generateId(Account.class);
        Account account = (Account) new Fake(Account.class)
            .setField(Account.Id, testAccountId1)
            .setField(Account.Name, ACCOUNT_NAME_BUSINESS)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .toSObject();
        List<Account> accountList = new List<Account>();
        accountList.add(account);
        Id testOppId1 = Fake.generateId(Opportunity.class);
        Opportunity existingOpportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, testOppId1)
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.StageName, STAGE_NAME_PROSPECTING)
            .setField(Opportunity.CloseDate, Date.newInstance(2927, 12, 31))
            .setField(Opportunity.AccountId, testAccountId1)
            .setField(Opportunity.Source__c, SOURCE_VSP_RECOMMENDATION)
            .setField(Opportunity.Opportunity_Sub_Type__c, SUB_TYPE_RESCUE)
            .setField(Opportunity.Estimated_Number_of_Stores__c, 1)
            .toSObject();
        Opportunity updatedOpportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, testOppId1)
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.StageName, STAGE_NAME_PROSPECTING)
            .setField(Opportunity.CloseDate, Date.newInstance(2027, 12, 31))
            .setField(Opportunity.AccountId, testAccountId1)
            .setField(Opportunity.Source__c, SOURCE_VSP_RECOMMENDATION)
            .setField(Opportunity.Opportunity_Sub_Type__c, SUB_TYPE_COO)
            .setField(Opportunity.Estimated_Number_of_Stores__c, 1)
            .toSObject();
        Id campaignProductId1 = Fake.generateId(Campaign_Product__c.class);
        Id productInsightId1 = Fake.generateId(Product_Insights__c.class);
        Product_Insights__c productInsight = (Product_Insights__c) new Fake(
                Product_Insights__c.class
            )
            .setField(Product_Insights__c.Id, productInsightId1)
            .setField(Product_Insights__c.Opportunity__c, existingOpportunity.Id)
            .setField(Product_Insights__c.Interest_Level__c, PRODUCT_INSIGITS_INTERESET_LEVEL)
            .setField(Product_Insights__c.Origin__c, PRODUCT_INSIGITS_ORIGIN)
            .setField(Product_Insights__c.Product__c, campaignProductId1)
            .setParent(
                'Product__r',
                new Fake(Campaign_Product__c.class)
                    .setField(Campaign_Product__c.Id, campaignProductId1)
                    .setField(Campaign_Product__c.Name, CAMPAIGN_PRODUCT_NAME)
                    .setField(
                        Campaign_Product__c.Product_Family__c,
                        CAMPAIGN_PRODUCT_FAMILY_STOREFRONT
                    )
                    .setField(Campaign_Product__c.Status__c, ACTIVE)
            )
            .toSObject();
        List<Opportunity> upadtedOpportunities = new List<Opportunity>();
        upadtedOpportunities.add(updatedOpportunity);
        Map<Id, Opportunity> existingOpportunities = new Map<Id, Opportunity>{
            existingOpportunity.Id => existingOpportunity
        };
        List<Product_Insights__c> productInsights = new List<Product_Insights__c>();
        productInsights.add(productInsight);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        IProductInsightsSelector selectorMockProductInsights = (IProductInsightsSelector) mocks.mock(
            IProductInsightsSelector.class
        );
        mocks.startStubbing();
        mocks.when(selectorMock.SObjectType()).thenReturn(Schema.Account.SObjectType);
        mocks.when(selectorMock.selectByOpportunity(upadtedOpportunities)).thenReturn(accountList);
        mocks.when(selectorMockProductInsights.SObjectType())
            .thenReturn(Schema.Product_Insights__c.SObjectType);
        mocks.when(
                selectorMockProductInsights.selectProductInsightsByOpportunityIds(
                    new Set<Id>{ upadtedOpportunities[0].Id }
                )
            )
            .thenReturn(productInsights);
        mocks.stopStubbing();
        Application.Selector.setMock(selectorMock);
        Application.Selector.setMock(selectorMockProductInsights);
        Test.startTest();
        String last2DigitsOfYear = String.valueOf(upadtedOpportunities[0].CloseDate.year())
            .right(2);
        Opportunities.newInstance(upadtedOpportunities)
            .vspOpportunityNameUpdate(existingOpportunities);
        Test.stopTest();
        System.assertEquals(
            ACCOUNT_NAME_BUSINESS +
            QUARTER_FOUR +
            last2DigitsOfYear +
            HYPHEN_WITH_UNTRIMMED_SPACE +
            upadtedOpportunities[0].Opportunity_Sub_Type__c +
            VSP +
            OPPORTUNITY_NAME,
            upadtedOpportunities[0].Name,
            VSP_OPPORTUNITY_NAME_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test when NON VSP Opportunities are upadted then Opportunity Name should Not be updated
     */
    @isTest
    static void testWhenVSPOpportunityUpdatedThenNameShouldNotBeUpdated() {
        Id testAccountId1 = Fake.generateId(Account.class);
        Account account = (Account) new Fake(Account.class)
            .setField(Account.Id, testAccountId1)
            .setField(Account.Name, ACCOUNT_NAME_BUSINESS)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .toSObject();
        List<Account> accountList = new List<Account>();
        accountList.add(account);
        Id testOppId1 = Fake.generateId(Opportunity.class);
        Opportunity existingOpportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, testOppId1)
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.StageName, STAGE_NAME_PROSPECTING)
            .setField(Opportunity.CloseDate, Date.newInstance(2027, 12, 31))
            .setField(Opportunity.AccountId, testAccountId1)
            .setField(Opportunity.Source__c, SOURCE_MANUAL)
            .setField(Opportunity.Opportunity_Sub_Type__c, SUB_TYPE_RESCUE)
            .setField(Opportunity.Estimated_Number_of_Stores__c, 1)
            .toSObject();
        Opportunity updatedOpportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, testOppId1)
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.StageName, STAGE_NAME_PROSPECTING)
            .setField(Opportunity.CloseDate, Date.newInstance(2027, 12, 31))
            .setField(Opportunity.AccountId, testAccountId1)
            .setField(Opportunity.Source__c, SOURCE_MANUAL)
            .setField(Opportunity.Opportunity_Sub_Type__c, SUB_TYPE_COO)
            .setField(Opportunity.Estimated_Number_of_Stores__c, 1)
            .toSObject();
        Id campaignProductId1 = Fake.generateId(Campaign_Product__c.class);
        Id productInsightId1 = Fake.generateId(Product_Insights__c.class);
        Product_Insights__c productInsight = (Product_Insights__c) new Fake(
                Product_Insights__c.class
            )
            .setField(Product_Insights__c.Id, productInsightId1)
            .setField(Product_Insights__c.Opportunity__c, existingOpportunity.Id)
            .setField(Product_Insights__c.Interest_Level__c, PRODUCT_INSIGITS_INTERESET_LEVEL)
            .setField(Product_Insights__c.Origin__c, PRODUCT_INSIGITS_ORIGIN)
            .setField(Product_Insights__c.Product__c, campaignProductId1)
            .setParent(
                'Product__r',
                new Fake(Campaign_Product__c.class)
                    .setField(Campaign_Product__c.Id, campaignProductId1)
                    .setField(Campaign_Product__c.Name, CAMPAIGN_PRODUCT_NAME)
                    .setField(
                        Campaign_Product__c.Product_Family__c,
                        CAMPAIGN_PRODUCT_FAMILY_STOREFRONT
                    )
                    .setField(Campaign_Product__c.Status__c, ACTIVE)
            )
            .toSObject();
        List<Opportunity> upadtedOpportunities = new List<Opportunity>();
        upadtedOpportunities.add(updatedOpportunity);
        Map<Id, Opportunity> existingOpportunities = new Map<Id, Opportunity>{
            existingOpportunity.Id => existingOpportunity
        };
        List<Product_Insights__c> productInsights = new List<Product_Insights__c>();
        productInsights.add(productInsight);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        IProductInsightsSelector selectorMockProductInsights = (IProductInsightsSelector) mocks.mock(
            IProductInsightsSelector.class
        );
        mocks.startStubbing();
        mocks.when(selectorMock.SObjectType()).thenReturn(Schema.Account.SObjectType);
        mocks.when(selectorMock.selectByOpportunity(upadtedOpportunities)).thenReturn(accountList);
        mocks.when(selectorMockProductInsights.SObjectType())
            .thenReturn(Schema.Product_Insights__c.SObjectType);
        mocks.when(
                selectorMockProductInsights.selectProductInsightsByOpportunityIds(
                    new Set<Id>{ upadtedOpportunities[0].Id }
                )
            )
            .thenReturn(productInsights);
        mocks.stopStubbing();
        Application.Selector.setMock(selectorMock);
        Application.Selector.setMock(selectorMockProductInsights);
        Test.startTest();
        String last2DigitsOfYear = String.valueOf(upadtedOpportunities[0].CloseDate.year())
            .right(2);
        Opportunities.newInstance(upadtedOpportunities)
            .vspOpportunityNameUpdate(existingOpportunities);
        Test.stopTest();
        System.assertNotEquals(
            ACCOUNT_NAME_BUSINESS +
            QUARTER_FOUR +
            last2DigitsOfYear +
            HYPHEN_WITH_UNTRIMMED_SPACE +
            upadtedOpportunities[0].Opportunity_Sub_Type__c +
            VSP +
            OPPORTUNITY_NAME,
            upadtedOpportunities[0].Name,
            NON_VSP_OPPORTUNITY_NAME_ASSERT_MESSAGE
        );
    }
}