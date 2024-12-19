/**
 * @author Deloitte
 * @date 05/06/2024
 * @description Test class for CloneAccountPlanController
 */
@isTest(SeeAllData=false)
private class CloneAccountPlanControllerTest {
    private static final String ACTIVE = 'Active';
    private static final String ACCOUNT_NAME = 'Test Account';
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    private static final String ACCOUNT_PLAN_NAME = 'Test Account Plan';
    private static final String ACCOUNT_TEAM_ROLE = 'Franchise Representative';
    private static final String ADS = 'Ads';
    private static final String CAMPAIGN_PRODUCT_NAME = 'Test Solution Name';
    private static final String COMPLETED = 'Completed';
    private static final String IN_PROGRESS = 'In Progress';
    private static final String MARKETPLACE = 'Marketplace';
    private static final String NEUTRAL = 'Neutral';
    private static final String PITCHING = 'Pitching';

    /**
     * @description It is used to test if the Account Plan is cloned and the
     * child records are reparented.
     * Suppressed Warnings since mock verify method does not require system assert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenCloneAccountPlanThenAccountPlanClonedAndChildRecordsReparented() {
        Id accountPlanId = fflib_IDGenerator.generate(Account_Plan__c.SObjectType);
        Id leverId1 = fflib_IDGenerator.generate(Lever__c.SObjectType);
        Id leverId2 = fflib_IDGenerator.generate(Lever__c.SObjectType);
        Id leverId3 = fflib_IDGenerator.generate(Lever__c.SObjectType);
        Id leverId4 = fflib_IDGenerator.generate(Lever__c.SObjectType);
        Id productInsightId1 = fflib_IDGenerator.generate(Product_Insights__c.SObjectType);
        Id productInsightId2 = fflib_IDGenerator.generate(Product_Insights__c.SObjectType);
        Id opportunityId1 = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id opportunityId2 = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id accountOwnerId = fflib_IDGenerator.generate(User.SObjectType);
        Id runningUserId = fflib_IDGenerator.generate(User.SObjectType);
        Id teamMemberId1 = fflib_IDGenerator.generate(User.SObjectType);
        Id teamMemberId2 = fflib_IDGenerator.generate(User.SObjectType);
        Id solutionId1 = fflib_IDGenerator.generate(Campaign_Product__c.SObjectType);
        Id solutionId2 = fflib_IDGenerator.generate(Campaign_Product__c.SObjectType);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Account accountRecord = new Account(
            Id = accountId,
            Name = ACCOUNT_NAME,
            Segment__c = ACCOUNT_SEGMENT_SMB,
            OwnerId = accountOwnerId
        );
        Account_Plan__c accountPlanRecord = (Account_Plan__c) new Fake(Account_Plan__c.class)
            .setField(Account_Plan__c.Id, accountPlanId)
            .setField(Account_Plan__c.Name, ACCOUNT_PLAN_NAME)
            .setField(Account_Plan__c.Account__c, accountId)
            .setField(Account_Plan__c.Status__c, ACTIVE)
            .toSObject();
        List<Opportunity> opportunityRecords = new List<Opportunity>{
            (Opportunity) new Fake(Opportunity.class)
                .setField(Opportunity.Id, opportunityId1)
                .setField(Opportunity.StageName, PITCHING)
                .toSObject(),
            (Opportunity) new Fake(Opportunity.class)
                .setField(Opportunity.Id, opportunityId2)
                .setField(Opportunity.StageName, PITCHING)
                .toSObject()
        };
        List<Lever__c> leverRecords = new List<Lever__c>{
            (Lever__c) new Fake(Lever__c.class)
                .setField(Lever__c.Id, leverId1)
                .setField(Lever__c.Status__c, IN_PROGRESS)
                .setParent(
                    'Account_Plan__r',
                    new Fake(Account_Plan__c.class)
                        .setField(Account_Plan__c.Id, accountPlanId)
                        .setField(Account_Plan__c.Name, ACCOUNT_PLAN_NAME)
                        .setField(Account_Plan__c.Account__c, accountId)
                        .setField(Account_Plan__c.Status__c, ACTIVE)
                )
                .setParent(
                    'Solution__r',
                    new Fake(Campaign_Product__c.class)
                        .setField(Campaign_Product__c.Id, solutionId2)
                        .setField(Campaign_Product__c.Product_Family__c, ADS)
                        .setField(Campaign_Product__c.Status__c, ACTIVE)
                        .setField(Campaign_Product__c.Name, CAMPAIGN_PRODUCT_NAME)
                )
                .toSObject(),
            (Lever__c) new Fake(Lever__c.class)
                .setField(Lever__c.Id, leverId2)
                .setField(Lever__c.Status__c, COMPLETED)
                .setParent(
                    'Account_Plan__r',
                    new Fake(Account_Plan__c.class)
                        .setField(Account_Plan__c.Id, accountPlanId)
                        .setField(Account_Plan__c.Name, ACCOUNT_PLAN_NAME)
                        .setField(Account_Plan__c.Account__c, accountId)
                        .setField(Account_Plan__c.Status__c, ACTIVE)
                )
                .setParent(
                    'Solution__r',
                    new Fake(Campaign_Product__c.class)
                        .setField(Campaign_Product__c.Id, solutionId1)
                        .setField(Campaign_Product__c.Product_Family__c, MARKETPLACE)
                        .setField(Campaign_Product__c.Status__c, ACTIVE)
                        .setField(Campaign_Product__c.Name, CAMPAIGN_PRODUCT_NAME)
                )
                .toSObject()
        };
        List<Lever__c> newLeverRecords = new List<Lever__c>{
            (Lever__c) new Fake(Lever__c.class)
                .setField(Lever__c.Id, leverId3)
                .setField(Lever__c.Status__c, IN_PROGRESS)
                .setField(Lever__c.Cloned_From_Lever_Id__c, leverId1)
                .setParent(
                    'Account_Plan__r',
                    new Fake(Account_Plan__c.class)
                        .setField(Account_Plan__c.Id, accountPlanId)
                        .setField(Account_Plan__c.Name, ACCOUNT_PLAN_NAME)
                        .setField(Account_Plan__c.Account__c, accountId)
                        .setField(Account_Plan__c.Status__c, ACTIVE)
                )
                .setParent(
                    'Solution__r',
                    new Fake(Campaign_Product__c.class)
                        .setField(Campaign_Product__c.Id, solutionId2)
                        .setField(Campaign_Product__c.Product_Family__c, ADS)
                        .setField(Campaign_Product__c.Status__c, ACTIVE)
                        .setField(Campaign_Product__c.Name, CAMPAIGN_PRODUCT_NAME)
                )
                .toSObject(),
            (Lever__c) new Fake(Lever__c.class)
                .setField(Lever__c.Id, leverId4)
                .setField(Lever__c.Status__c, COMPLETED)
                .setField(Lever__c.Cloned_From_Lever_Id__c, leverId2)
                .setParent(
                    'Account_Plan__r',
                    new Fake(Account_Plan__c.class)
                        .setField(Account_Plan__c.Id, accountPlanId)
                        .setField(Account_Plan__c.Name, ACCOUNT_PLAN_NAME)
                        .setField(Account_Plan__c.Account__c, accountId)
                        .setField(Account_Plan__c.Status__c, ACTIVE)
                )
                .setParent(
                    'Solution__r',
                    new Fake(Campaign_Product__c.class)
                        .setField(Campaign_Product__c.Id, solutionId1)
                        .setField(Campaign_Product__c.Product_Family__c, MARKETPLACE)
                        .setField(Campaign_Product__c.Status__c, ACTIVE)
                        .setField(Campaign_Product__c.Name, CAMPAIGN_PRODUCT_NAME)
                )
                .toSObject()
        };
        List<Product_Insights__c> productInsightsRecords = new List<Product_Insights__c>{
            (Product_Insights__c) new Fake(Product_Insights__c.class)
                .setField(Product_Insights__c.Id, productInsightId1)
                .setField(Product_Insights__c.Opportunity__c, opportunityId1)
                .setField(Product_Insights__c.Interest_Level__c, NEUTRAL)
                .setField(Product_Insights__c.Lever__c, leverRecords[0].Id)
                .setParent(
                    'Lever__r',
                    new Fake(Lever__c.class)
                        .setField(Lever__c.Id, leverRecords[0].Id)
                        .setField(Lever__c.Interest_Level__c, '')
                        .setField(Lever__c.Account__c, accountRecord.Id)
                )
                .setParent(
                    'Opportunity__r',
                    new Fake(Opportunity.class)
                        .setField(Opportunity.Id, opportunityId1)
                        .setField(Opportunity.StageName, PITCHING)
                        .setField(Opportunity.AccountId, accountRecord.Id)
                )
                .toSobject(),
            (Product_Insights__c) new Fake(Product_Insights__c.class)
                .setField(Product_Insights__c.Id, productInsightId2)
                .setField(Product_Insights__c.Opportunity__c, opportunityId2)
                .setField(Product_Insights__c.Interest_Level__c, NEUTRAL)
                .setField(Product_Insights__c.Lever__c, leverRecords[1].Id)
                .setParent(
                    'Lever__r',
                    new Fake(Lever__c.class)
                        .setField(Lever__c.Id, leverRecords[1].Id)
                        .setField(Lever__c.Interest_Level__c, '')
                        .setField(Lever__c.Account__c, accountRecord.Id)
                )
                .setParent(
                    'Opportunity__r',
                    new Fake(Opportunity.class)
                        .setField(Opportunity.Id, opportunityId2)
                        .setField(Opportunity.StageName, PITCHING)
                        .setField(Opportunity.AccountId, accountRecord.Id)
                )
                .toSobject()
        };
        List<AccountTeamMember> accountTeamMembers = new List<AccountTeamMember>{
            (AccountTeamMember) new Fake(AccountTeamMember.class)
                .setField(AccountTeamMember.UserId, teamMemberId1)
                .setField(AccountTeamMember.TeamMemberRole, ACCOUNT_TEAM_ROLE)
                .setField(AccountTeamMember.AccountId, accountRecord.Id)
                .setParent(
                    'Account',
                    new Fake(Account.class)
                        .setField(Account.Id, accountId)
                        .setField(Account.OwnerId, accountOwnerId)
                )
                .toSObject(),
            (AccountTeamMember) new Fake(AccountTeamMember.class)
                .setField(AccountTeamMember.UserId, teamMemberId2)
                .setField(AccountTeamMember.TeamMemberRole, ACCOUNT_TEAM_ROLE)
                .setField(AccountTeamMember.AccountId, accountRecord.Id)
                .setParent(
                    'Account',
                    new Fake(Account.class)
                        .setField(Account.Id, accountId)
                        .setField(Account.OwnerId, accountOwnerId)
                )
                .toSObject()
        };
        List<CloneAccountPlanFlowInputs> flowInputs = new List<CloneAccountPlanFlowInputs>();
        CloneAccountPlanFlowInputs flowInput = new CloneAccountPlanFlowInputs();
        flowInput.accountPlanRecord = accountPlanRecord;
        flowInput.runningUserId = runningUserId;
        flowInputs.add(flowInput);
        IProductInsightsSelector productInsightsSelectorMock = (IProductInsightsSelector) mocks.mock(
            IProductInsightsSelector.class
        );
        ILeversSelector leversSelectorMock = (ILeversSelector) mocks.mock(ILeversSelector.class);
        IAccountTeamMembersSelector accountTeamMemberSelectorMock = (IAccountTeamMembersSelector) mocks.mock(
            IAccountTeamMembersSelector.class
        );
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IOpportunitiesSelector opportunitySelectorMock = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );
        mocks.startStubbing();
        mocks.when(productInsightsSelectorMock.sObjectType())
            .thenReturn(Product_Insights__c.SObjectType);
        mocks.when(
                productInsightsSelectorMock.selectProductInsightsByOpportunityIds(
                    new Set<Id>{ opportunityId1, opportunityId2 }
                )
            )
            .thenReturn(productInsightsRecords);
        mocks.when(leversSelectorMock.sObjectType()).thenReturn(Lever__c.SObjectType);
        mocks.when(leversSelectorMock.selectOpenLeversByAccountPlanId(new Set<Id>{ accountPlanId }))
            .thenReturn(leverRecords);
        mocks.when(leversSelectorMock.selectByClonedLeverId(new Set<Id>{ leverId1, leverId2 }))
            .thenReturn(newLeverRecords);
        mocks.when(accountTeamMemberSelectorMock.sObjectType())
            .thenReturn(AccountTeamMember.SObjectType);
        mocks.when(accountTeamMemberSelectorMock.selectAccountTeamMembersByAccountId(accountId))
            .thenReturn(accountTeamMembers);
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountSelectorMock.selectById(new Set<Id>{ accountId }))
            .thenReturn(new List<Account>{ accountRecord });
        mocks.when(opportunitySelectorMock.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(
                opportunitySelectorMock.selectOpenOpportunitiesByAccountPlanIds(
                    new Set<Id>{ accountPlanId }
                )
            )
            .thenReturn(opportunityrecords);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(productInsightsSelectorMock);
        Application.SELECTOR.setMock(leversSelectorMock);
        Application.SELECTOR.setMock(accountTeamMemberSelectorMock);
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(opportunitySelectorMock);
        Test.startTest();
        CloneAccountPlanController.cloneAccountPlan(flowInputs);
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 3)).commitWork();
    }

    /**
     * @description It is used to test if the Account Plan is cloned and the
     * child records are reparented.
     * Suppressed Warnings since mock verify method does not require system assert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenCloneAccountPlanAndClosedOpportunitiesThenAccountPlanClonedAndChildRecordsReparented() {
        Id accountPlanId = fflib_IDGenerator.generate(Account_Plan__c.SObjectType);
        Id leverId1 = fflib_IDGenerator.generate(Lever__c.SObjectType);
        Id leverId2 = fflib_IDGenerator.generate(Lever__c.SObjectType);
        Id leverId3 = fflib_IDGenerator.generate(Lever__c.SObjectType);
        Id leverId4 = fflib_IDGenerator.generate(Lever__c.SObjectType);
        Id productInsightId1 = fflib_IDGenerator.generate(Product_Insights__c.SObjectType);
        Id productInsightId2 = fflib_IDGenerator.generate(Product_Insights__c.SObjectType);
        Id opportunityId1 = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id opportunityId2 = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id accountOwnerId = fflib_IDGenerator.generate(User.SObjectType);
        Id runningUserId = fflib_IDGenerator.generate(User.SObjectType);
        Id teamMemberId1 = fflib_IDGenerator.generate(User.SObjectType);
        Id teamMemberId2 = fflib_IDGenerator.generate(User.SObjectType);
        Id solutionId1 = fflib_IDGenerator.generate(Campaign_Product__c.SObjectType);
        Id solutionId2 = fflib_IDGenerator.generate(Campaign_Product__c.SObjectType);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Account accountRecord = new Account(
            Id = accountId,
            Name = ACCOUNT_NAME,
            Segment__c = ACCOUNT_SEGMENT_SMB,
            OwnerId = accountOwnerId
        );
        Account_Plan__c accountPlanRecord = (Account_Plan__c) new Fake(Account_Plan__c.class)
            .setField(Account_Plan__c.Id, accountPlanId)
            .setField(Account_Plan__c.Name, ACCOUNT_PLAN_NAME)
            .setField(Account_Plan__c.Account__c, accountId)
            .setField(Account_Plan__c.Status__c, ACTIVE)
            .toSObject();
        List<Opportunity> opportunityRecords = new List<Opportunity>{
            (Opportunity) new Fake(Opportunity.class)
                .setField(Opportunity.Id, opportunityId1)
                .setField(Opportunity.StageName, 'Closed Won')
                .toSObject(),
            (Opportunity) new Fake(Opportunity.class)
                .setField(Opportunity.Id, opportunityId2)
                .setField(Opportunity.StageName, 'Closed Won')
                .toSObject()
        };
        List<Lever__c> leverRecords = new List<Lever__c>{
            (Lever__c) new Fake(Lever__c.class)
                .setField(Lever__c.Id, leverId1)
                .setField(Lever__c.Status__c, IN_PROGRESS)
                .setParent(
                    'Account_Plan__r',
                    new Fake(Account_Plan__c.class)
                        .setField(Account_Plan__c.Id, accountPlanId)
                        .setField(Account_Plan__c.Name, ACCOUNT_PLAN_NAME)
                        .setField(Account_Plan__c.Account__c, accountId)
                        .setField(Account_Plan__c.Status__c, ACTIVE)
                )
                .setParent(
                    'Solution__r',
                    new Fake(Campaign_Product__c.class)
                        .setField(Campaign_Product__c.Id, solutionId2)
                        .setField(Campaign_Product__c.Product_Family__c, ADS)
                        .setField(Campaign_Product__c.Status__c, ACTIVE)
                        .setField(Campaign_Product__c.Name, CAMPAIGN_PRODUCT_NAME)
                )
                .toSObject(),
            (Lever__c) new Fake(Lever__c.class)
                .setField(Lever__c.Id, leverId2)
                .setField(Lever__c.Status__c, COMPLETED)
                .setParent(
                    'Account_Plan__r',
                    new Fake(Account_Plan__c.class)
                        .setField(Account_Plan__c.Id, accountPlanId)
                        .setField(Account_Plan__c.Name, ACCOUNT_PLAN_NAME)
                        .setField(Account_Plan__c.Account__c, accountId)
                        .setField(Account_Plan__c.Status__c, ACTIVE)
                )
                .setParent(
                    'Solution__r',
                    new Fake(Campaign_Product__c.class)
                        .setField(Campaign_Product__c.Id, solutionId1)
                        .setField(Campaign_Product__c.Product_Family__c, MARKETPLACE)
                        .setField(Campaign_Product__c.Status__c, ACTIVE)
                        .setField(Campaign_Product__c.Name, CAMPAIGN_PRODUCT_NAME)
                )
                .toSObject()
        };
        List<Lever__c> newLeverRecords = new List<Lever__c>{
            (Lever__c) new Fake(Lever__c.class)
                .setField(Lever__c.Id, leverId3)
                .setField(Lever__c.Status__c, IN_PROGRESS)
                .setField(Lever__c.Cloned_From_Lever_Id__c, leverId1)
                .setParent(
                    'Account_Plan__r',
                    new Fake(Account_Plan__c.class)
                        .setField(Account_Plan__c.Id, accountPlanId)
                        .setField(Account_Plan__c.Name, ACCOUNT_PLAN_NAME)
                        .setField(Account_Plan__c.Account__c, accountId)
                        .setField(Account_Plan__c.Status__c, ACTIVE)
                )
                .setParent(
                    'Solution__r',
                    new Fake(Campaign_Product__c.class)
                        .setField(Campaign_Product__c.Id, solutionId2)
                        .setField(Campaign_Product__c.Product_Family__c, ADS)
                        .setField(Campaign_Product__c.Status__c, ACTIVE)
                        .setField(Campaign_Product__c.Name, CAMPAIGN_PRODUCT_NAME)
                )
                .toSObject(),
            (Lever__c) new Fake(Lever__c.class)
                .setField(Lever__c.Id, leverId4)
                .setField(Lever__c.Status__c, COMPLETED)
                .setField(Lever__c.Cloned_From_Lever_Id__c, leverId2)
                .setParent(
                    'Account_Plan__r',
                    new Fake(Account_Plan__c.class)
                        .setField(Account_Plan__c.Id, accountPlanId)
                        .setField(Account_Plan__c.Name, ACCOUNT_PLAN_NAME)
                        .setField(Account_Plan__c.Account__c, accountId)
                        .setField(Account_Plan__c.Status__c, ACTIVE)
                )
                .setParent(
                    'Solution__r',
                    new Fake(Campaign_Product__c.class)
                        .setField(Campaign_Product__c.Id, solutionId1)
                        .setField(Campaign_Product__c.Product_Family__c, MARKETPLACE)
                        .setField(Campaign_Product__c.Status__c, ACTIVE)
                        .setField(Campaign_Product__c.Name, CAMPAIGN_PRODUCT_NAME)
                )
                .toSObject()
        };
        List<Product_Insights__c> productInsightsRecords = new List<Product_Insights__c>{
            (Product_Insights__c) new Fake(Product_Insights__c.class)
                .setField(Product_Insights__c.Id, productInsightId1)
                .setField(Product_Insights__c.Opportunity__c, opportunityId1)
                .setField(Product_Insights__c.Interest_Level__c, NEUTRAL)
                .setField(Product_Insights__c.Lever__c, leverRecords[0].Id)
                .setParent(
                    'Lever__r',
                    new Fake(Lever__c.class)
                        .setField(Lever__c.Id, leverRecords[0].Id)
                        .setField(Lever__c.Interest_Level__c, '')
                        .setField(Lever__c.Account__c, accountRecord.Id)
                )
                .setParent(
                    'Opportunity__r',
                    new Fake(Opportunity.class)
                        .setField(Opportunity.Id, opportunityId1)
                        .setField(Opportunity.StageName, 'Closed Won')
                        .setField(Opportunity.AccountId, accountRecord.Id)
                )
                .toSobject(),
            (Product_Insights__c) new Fake(Product_Insights__c.class)
                .setField(Product_Insights__c.Id, productInsightId2)
                .setField(Product_Insights__c.Opportunity__c, opportunityId2)
                .setField(Product_Insights__c.Interest_Level__c, NEUTRAL)
                .setField(Product_Insights__c.Lever__c, leverRecords[1].Id)
                .setParent(
                    'Lever__r',
                    new Fake(Lever__c.class)
                        .setField(Lever__c.Id, leverRecords[1].Id)
                        .setField(Lever__c.Interest_Level__c, '')
                        .setField(Lever__c.Account__c, accountRecord.Id)
                )
                .setParent(
                    'Opportunity__r',
                    new Fake(Opportunity.class)
                        .setField(Opportunity.Id, opportunityId2)
                        .setField(Opportunity.StageName, 'Closed Won')
                        .setField(Opportunity.AccountId, accountRecord.Id)
                )
                .toSobject()
        };
        List<AccountTeamMember> accountTeamMembers = new List<AccountTeamMember>{
            (AccountTeamMember) new Fake(AccountTeamMember.class)
                .setField(AccountTeamMember.UserId, teamMemberId1)
                .setField(AccountTeamMember.TeamMemberRole, ACCOUNT_TEAM_ROLE)
                .setField(AccountTeamMember.AccountId, accountRecord.Id)
                .setParent(
                    'Account',
                    new Fake(Account.class)
                        .setField(Account.Id, accountId)
                        .setField(Account.OwnerId, accountOwnerId)
                )
                .toSObject(),
            (AccountTeamMember) new Fake(AccountTeamMember.class)
                .setField(AccountTeamMember.UserId, teamMemberId2)
                .setField(AccountTeamMember.TeamMemberRole, ACCOUNT_TEAM_ROLE)
                .setField(AccountTeamMember.AccountId, accountRecord.Id)
                .setParent(
                    'Account',
                    new Fake(Account.class)
                        .setField(Account.Id, accountId)
                        .setField(Account.OwnerId, accountOwnerId)
                )
                .toSObject()
        };
        List<CloneAccountPlanFlowInputs> flowInputs = new List<CloneAccountPlanFlowInputs>();
        CloneAccountPlanFlowInputs flowInput = new CloneAccountPlanFlowInputs();
        flowInput.accountPlanRecord = accountPlanRecord;
        flowInput.runningUserId = runningUserId;
        flowInputs.add(flowInput);
        IProductInsightsSelector productInsightsSelectorMock = (IProductInsightsSelector) mocks.mock(
            IProductInsightsSelector.class
        );
        ILeversSelector leversSelectorMock = (ILeversSelector) mocks.mock(ILeversSelector.class);
        IAccountTeamMembersSelector accountTeamMemberSelectorMock = (IAccountTeamMembersSelector) mocks.mock(
            IAccountTeamMembersSelector.class
        );
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IOpportunitiesSelector opportunitySelectorMock = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );
        mocks.startStubbing();
        mocks.when(productInsightsSelectorMock.sObjectType())
            .thenReturn(Product_Insights__c.SObjectType);
        mocks.when(
                productInsightsSelectorMock.selectProductInsightsByOpportunityIds(
                    new Set<Id>{ opportunityId1, opportunityId2 }
                )
            )
            .thenReturn(productInsightsRecords);
        mocks.when(leversSelectorMock.sObjectType()).thenReturn(Lever__c.SObjectType);
        mocks.when(leversSelectorMock.selectOpenLeversByAccountPlanId(new Set<Id>{ accountPlanId }))
            .thenReturn(leverRecords);
        mocks.when(leversSelectorMock.selectByClonedLeverId(new Set<Id>{ leverId1, leverId2 }))
            .thenReturn(newLeverRecords);
        mocks.when(accountTeamMemberSelectorMock.sObjectType())
            .thenReturn(AccountTeamMember.SObjectType);
        mocks.when(accountTeamMemberSelectorMock.selectAccountTeamMembersByAccountId(accountId))
            .thenReturn(accountTeamMembers);
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountSelectorMock.selectById(new Set<Id>{ accountId }))
            .thenReturn(new List<Account>{ accountRecord });
        mocks.when(opportunitySelectorMock.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(
                opportunitySelectorMock.selectOpenOpportunitiesByAccountPlanIds(
                    new Set<Id>{ accountPlanId }
                )
            )
            .thenReturn(opportunityrecords);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(productInsightsSelectorMock);
        Application.SELECTOR.setMock(leversSelectorMock);
        Application.SELECTOR.setMock(accountTeamMemberSelectorMock);
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(opportunitySelectorMock);
        Test.startTest();
        CloneAccountPlanController.cloneAccountPlan(flowInputs);
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 3)).commitWork();
    }
}