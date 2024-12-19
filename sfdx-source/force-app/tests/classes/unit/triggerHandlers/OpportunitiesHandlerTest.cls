/**
 * @description This is test class for OpportunitiesHandler class
 * @author Deloitte
 * @date 28/02/2022
 */
@isTest(SeeAllData=false)
public class OpportunitiesHandlerTest {
    private static final String ENTERPRISE = 'Enterprise';
    static final String EVENT_TOPIC_OPPORTUNITY_TEAM_MEMBER_CREATION = 'EVENT_TOPIC_OPPORTUNITY_TEAM_MEMBER_CREATION';
    private static final String STAGE_NAME_PROSPECTING = 'Prospecting';
    private static final String STAGE_NAME_CLOSED_LOST = 'Closed Lost';
    private static final String OPPORTUNITY_NAME = 'New Opportunity';
    private static final String OPPORTUNITY_SUB_STAGE_DISCOVERY = 'Discovery';
    private static final String OPPORTUNITY_STAGE_PROSPECTING = 'Prospecting';
    private static final String OPPORTUNITY_STAGE_NEGOTIATING = 'Negotiating';
    private static final String OPPORTUNITY_STAGE_CONTRACTING = 'Contracting';
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    private static final String ERROR_MESSAGE = 'No validation should be thrown.';
    private static final String TEST_ACCOUNT_NAME ='Test Account';
    private static final String TEST_OPPORTUNITY_NAME1 ='Test1';
    private static final String DEAL_TYPE_STANDARD='Standard';
    private static final String DEAL_TYPE_SELF_SERVE ='Self-Serve';
    private static final String SUB_TYPE_ADS_AND_PROMO = 'Ads & Promos';
    private static final String SUB_TYPE_COO = 'COO';
    private static final String OPPORTUNITY_SOURCE_LEAD ='Lead';
    private static final String TEST_OPPORTUNITY_NAME2='Test2';
    private static final String OPPORTUNITY_SOURCE_MANUAL = 'Manual';
    private static final String NEEDS_ANALYSIS_STAGE ='Needs Analysis';

    @isTest
    public static void testWhenOpportunityLitePassesThenContactRoleValidationOnUpdate() {
        Account testAccount = new Account(
            name = 'Test Account',
            Type = 'Corporate',
            Segment__c = 'SMB'
        );
        insert testAccount;
        testAccount.Data_Verification_Status__c = 'Verified';
        update testAccount;

        List<Account> testAccountList = [SELECT id, Address_Verification_Status__c FROM account];

        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;

        Brand__c enterpriseBrand = new Brand__c(
            Brand_Owner__c = testAccountList[0].Id,
            Name = 'Enteprise Brand'
        );
        insert enterpriseBrand;

        Brand_Association__c eachBrandAssociation = new Brand_Association__c(
            Business_Account_Name__c = testAccountList[0].Id,
            Brand_Name__c = enterpriseBrand.Id
        );
        insert eachBrandAssociation;

        List<Opportunity> opportunityList = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                StageName = 'Pitching',
                Deal_Type__c = 'Lite',
                Type = 'Existing',
                CloseDate = System.today().addDays(5),
                Opportunity_Sub_Type__c = 'COO',
                AccountId = testAccount.id,
                Estimated_Number_of_Stores__c = 1,
                Substage__c = OPPORTUNITY_SUB_STAGE_DISCOVERY
            )
        };
        insert opportunityList;

        Id opportunityContactRoleId = fflib_IDGenerator.generate(
            OpportunityContactRole.SObjectType
        );
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);

        Fake opportunityContactRoleFakeInstance = new Fake(OpportunityContactRole.class)
            .setField(OpportunityContactRole.Id, opportunityContactRoleId)
            .setField(OpportunityContactRole.OpportunityId, opportunityList[0].Id)
            .setField(OpportunityContactRole.ContactId, contactId)
            .setField(OpportunityContactRole.isPrimary, true);
        OpportunityContactRole ocrRecord = (OpportunityContactRole) ServiceMockDataBuilder.convertToSObject(
            opportunityContactRoleFakeInstance
        );
        ocrRecord.Role = 'Contract Signatory';
        Opportunity_Brand_Relationship__c testEntepriseOpportunityAccountRelationship = new Opportunity_Brand_Relationship__c(
            Opportunity__c = opportunityList[0].Id,
            Brand__c = eachBrandAssociation.Id
        );
        insert testEntepriseOpportunityAccountRelationship;

        WorkOrder newWorkOrder = new WorkOrder(
            AccountId = testAccountList[0].id,
            Activated_Centrally_AC__c = 'Yes',
            Proposed_Date_of_Activation__c = System.today().addMonths(2),
            Status = 'Planning',
            Type__c = 'COO',
            Menu_to_be_Completed_By__c = 'Merchant',
            Opportunity__c = opportunityList[0].Id
        );
        insert newWorkOrder;

        List<Opportunity> updateOpptyRecords = new List<Opportunity>();
        List<Opportunity> fetchOpptyRecords = [SELECT id, stageName, Deal_Type__c FROM Opportunity];
        for (Opportunity oppty : fetchOpptyRecords) {
            oppty.StageName = 'Contracting';
            updateOpptyRecords.add(oppty);
        }
        update updateOpptyRecords;

        List<Opportunity> updatedOpptyRecords = [
            SELECT id, StageName, Deal_Type__c
            FROM Opportunity
        ];
        System.assertEquals(
            'Contracting',
            updatedOpptyRecords[0].StageName,
            'Opportunity Stage was not updated'
        );
    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenOpportunityPitchAmountChangesThenAreValidatedOnUpdate() {
        Id opptyid1 = Fake.generateId(Opportunity.class);
        Id opptyid2 = Fake.generateId(Opportunity.class);

        List<Opportunity> opportunityListBefore = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5),
                Id = opptyid1,
                Pitch_Amount__c = 90,
                Opportunity_Sub_Type__c = 'test'
            ),
            new Opportunity(
                Name = 'Test2',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5),
                Id = opptyid2,
                Pitch_Amount__c = 75,
                Opportunity_Sub_Type__c = 'test'
            )
        };
        List<Opportunity> opportunityListAfter = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5),
                Opportunity_Sub_Type__c = 'test',
                Pitch_Amount__c = 85,
                Id = opptyid1
            ),
            new Opportunity(
                Name = 'Test1',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5),
                Opportunity_Sub_Type__c = 'Does not match',
                Pitch_Amount__c = 90,
                Id = opptyid2
            )
        };

        //Adding Quotes and linking them to Opportunity
        List<SBQQ__Quote__c> childQuotes = new List<SBQQ__Quote__c>{
            new SBQQ__Quote__c(
                Id = Fake.generateId(SBQQ__Quote__c.class),
                SBQQ__Opportunity2__c = opportunityListAfter[0].Id
            )
        };

        Map<Id, Opportunity> testMap = new Map<Id, Opportunity>(opportunityListBefore);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunities opportunitiesMock = (IOpportunities) mocks.mock(IOpportunities.class);
        IQuotesSelector quotesSelectorMock = (IQuotesSelector) mocks.mock(IQuotesSelector.class);
        fflib_IDomainConstructor constructor = (fflib_IDomainConstructor) mocks.mock(
            fflib_IDomainConstructor.class
        );

        mocks.startStubbing();
        mocks.when(opportunitiesMock.getType()).thenReturn(Schema.Opportunity.SObjectType);
        mocks.when(quotesSelectorMock.SObjectType()).thenReturn(SBQQ__Quote__c.SObjectType);
        mocks.when(
                quotesSelectorMock.selectByOpportunity(
                    new Set<Id>{ opportunityListAfter[0].Id, opportunityListAfter[1].Id }
                )
            )
            .thenReturn(childQuotes);
        mocks.when(constructor.construct(fflib_Match.anyList())).thenReturn(opportunitiesMock);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(quotesSelectorMock);
        Opportunities.setConstructorMock(constructor);

        fflib_SObjectDomain.Test.Database.onUpdate(opportunityListAfter, testMap);

        fflib_SObjectDomain.triggerHandler(OpportunitiesHandler.class);
        ((IOpportunities) mocks.verify(opportunitiesMock, 1))
            .getOpportunitiesWithQuotes(opportunityListAfter);
    }

    @isTest
    public static void testWhenOpportunityLitePassesThenContactRoleValidationOnInsert() {
        Account testAccount = new Account(
            name = 'Test Account',
            Type = 'Coporate',
            BillingCountry = 'United States',
            Data_Verification_Status__c = 'Verified',
            Segment__c = 'SMB'
        );
        insert testAccount;

        List<Account> testAccountList = [SELECT id, Address_Verification_Status__c FROM account];

        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;

        List<Opportunity> opportunityList = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                StageName = 'Pitching',
                Deal_Type__c = 'Lite',
                Type = 'New',
                CloseDate = System.today().addDays(5),
                Opportunity_Sub_Type__c = 'COO',
                AccountId = testAccountList[0].id,
                Estimated_Number_of_Stores__c = 1,
                Substage__c = OPPORTUNITY_SUB_STAGE_DISCOVERY
            )
        };
        insert opportunityList;

        List<Opportunity> insertedOpptyRecords = [
            SELECT id, stageName, Deal_Type__c
            FROM Opportunity
        ];

        System.assertEquals(
            'Pitching',
            insertedOpptyRecords[0].StageName,
            'Opportunity Stage was not updated'
        );
    }

    /**
     * @description Test Opportunitieshandler class on Opportunity Insertion
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenOpportunityCreatedThenCall() {
        List<Opportunity> opportunityList = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5)
            ),
            new Opportunity(
                Name = 'Test2',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5)
            )
        };
        fflib_SObjectDomain.Test.Database.onInsert(opportunityList);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunities opportunitiesMock = (IOpportunities) mocks.mock(IOpportunities.class);
        mocks.startStubbing();
        mocks.when(opportunitiesMock.getType()).thenReturn(Opportunity.SObjectType);
        mocks.stopStubbing();
        Application.DOMAIN.setMock(opportunitiesMock);

        fflib_SObjectDomain.triggerHandler(OpportunitiesHandler.class);
        ((IOpportunities) mocks.verify(opportunitiesMock, 1)).assignNameOnInsertOrNameUpdate();
        ((IOpportunities) mocks.verify(opportunitiesMock, 1)).assignPriceBook();
        ((IOpportunities) mocks.verify(opportunitiesMock, 1))
            .contactRoleValidationOnOpportunityCreation();
        ((IOpportunities) mocks.verify(opportunitiesMock, 1))
            .createBrandRelationshipOnOpportunityInsert();
        ((IOpportunities) mocks.verify(opportunitiesMock, 1))
            .updateAccountLifecycleStatusOnOpportunityInsertOrUndelete();
    }

    /**
     * @description Test OpportunitiesHandler class on Opportunity Updation
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenOpportunityUpdatedThenCall() {
        List<Opportunity> opportunityList = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                StageName = 'Needs Analysis',
                Deal_Type__c = 'Lite',
                CloseDate = System.today().addDays(5),
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Opportunity_Sub_Type__c = 'test'
            ),
            new Opportunity(
                Name = 'Test2',
                StageName = 'Needs Analysis',
                Deal_Type__c = 'Standard',
                CloseDate = System.today().addDays(5),
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Opportunity_Sub_Type__c = 'test'
            )
        };
        Map<Id, Opportunity> testMap = new Map<Id, Opportunity>(opportunityList);

        fflib_SObjectDomain.Test.Database.onUpdate(opportunityList, testMap);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunities opportunitiesMock = (IOpportunities) mocks.mock(IOpportunities.class);
        mocks.startStubbing();
        mocks.when(opportunitiesMock.getType()).thenReturn(Opportunity.SObjectType);
        mocks.stopStubbing();
        Application.DOMAIN.setMock(opportunitiesMock);

        fflib_SObjectDomain.triggerHandler(OpportunitiesHandler.class);
        ((IOpportunities) mocks.verify(opportunitiesMock, 1))
            .validateOpportunityNameChange(new Map<Id, Opportunity>(opportunityList));
        ((IOpportunities) mocks.verify(opportunitiesMock, 1))
            .assignNameOnNamingComponentsUpdates(testMap);
    }

    /**
     * @description Test OpportunityHandler Class on Opportunity Updation.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenOpportunityUpdatedThenCall2() {
        Id opptyid1 = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id opptyid2 = fflib_IDGenerator.generate(Opportunity.SObjectType);

        List<Opportunity> opportunityListBefore = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5),
                Id = opptyid1,
                Opportunity_Sub_Type__c = 'test'
            ),
            new Opportunity(
                Name = 'Test2',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5),
                Id = opptyid2,
                Opportunity_Sub_Type__c = 'test'
            )
        };
        List<Opportunity> opportunityListAfter = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5),
                Opportunity_Sub_Type__c = 'test',
                Id = opptyid1
            ),
            new Opportunity(
                Name = 'Test1',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5),
                Opportunity_Sub_Type__c = 'Does not match',
                Id = opptyid2
            )
        };

        Map<Id, Opportunity> testMap = new Map<Id, Opportunity>(opportunityListBefore);

        fflib_SObjectDomain.Test.Database.onUpdate(opportunityListAfter, testMap);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_IDomainConstructor constructor = (fflib_IDomainConstructor) mocks.mock(
            fflib_IDomainConstructor.class
        );
        IOpportunities opportunitiesMock = (IOpportunities) mocks.mock(IOpportunities.class);

        mocks.startStubbing();
        mocks.when(constructor.construct(fflib_Match.anyList())).thenReturn(opportunitiesMock);
        mocks.when(opportunitiesMock.getType()).thenReturn(Opportunity.SObjectType);
        mocks.stopStubbing();
        Opportunities.setConstructorMock(constructor);

        fflib_SObjectDomain.triggerHandler(OpportunitiesHandler.class);

        ((fflib_IDomainConstructor) mocks.verify(constructor, 4))
            .construct(new List<Opportunity>{ opportunityListAfter[1] });
    }

    /**
     * @description OpportunitiesHandler class instantiate and check
     */
    @isTest
    private static void testWhenClassInstantiatesThenCheck() {
        //Constructor Call
        List<Opportunity> opportunityList = new List<Opportunity>();
        OpportunitiesHandler opportunitiesHandlerObject = new OpportunitiesHandler(opportunityList);
        //Inner Class Constructor Call
        OpportunitiesHandler.Constructor objConstructor = new OpportunitiesHandler.Constructor();
        objConstructor.construct(opportunityList);
        //assertion
        System.assertNotEquals(
            opportunitiesHandlerObject,
            objConstructor.construct(opportunityList),
            'The two constructs should not be similar'
        );
    }

    /**
     * @description Test bypass trigger context
     */
    @isTest
    static void testWhenBypassReturnsTrueThenDisableTheTriggerContext() {
        // Arrange
        List<Opportunity> opportunityList = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                StageName = 'Prospecting',
                CloseDate = System.today().addDays(5)
            ),
            new Opportunity(
                Name = 'Test2',
                StageName = 'Prospecting',
                CloseDate = System.today().addDays(5)
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        BypassLogicModelImpl bypassMock = (BypassLogicModelImpl) mocks.mock(
            BypassLogicModelImpl.class
        );
        IOpportunities opportunitiesInstance = (IOpportunities) mocks.mock(IOpportunities.class);
        SystemFacade.triggerContext = System.TriggerOperation.BEFORE_INSERT;
        mocks.startStubbing();
        mocks.when(opportunitiesInstance.getType()).thenReturn(Opportunity.SObjectType);
        mocks.when(
                bypassMock.isTriggerBypassed('Opportunity', System.TriggerOperation.BEFORE_INSERT)
            )
            .thenReturn(true);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IBypassLogicModel.class, bypassMock);
        Application.DOMAIN.setMock(opportunitiesInstance);
        //Act
        fflib_SObjectDomain.Test.Database.onInsert(opportunityList);
        fflib_SObjectDomain.triggerHandler(OpportunitiesHandler.class);

        ((IOpportunities) mocks.verify(opportunitiesInstance, 1))
            .createOpportunityTeamMembersForManagersOnOwnerUpdate(
                EVENT_TOPIC_OPPORTUNITY_TEAM_MEMBER_CREATION
            );
        // Assert
        System.assertEquals(
            false,
            fflib_SObjectDomain.getTriggerEvent(OpportunitiesHandler.class).BeforeInsertEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(OpportunitiesHandler.class).AfterInsertEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(OpportunitiesHandler.class).BeforeUpdateEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(OpportunitiesHandler.class).AfterUpdateEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(OpportunitiesHandler.class).BeforeDeleteEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(OpportunitiesHandler.class).AfterDeleteEnabled,
            'The trigger was unexpectedly disabled'
        );
        System.assert(
            fflib_SObjectDomain.getTriggerEvent(OpportunitiesHandler.class).AfterUndeleteEnabled,
            'The trigger was unexpectedly disabled'
        );
    }

    /**
     * @description Test Opportunitieshandler class on Undelete context.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenOpportunityUndeletedThenCall() {
        List<Opportunity> opportunityList = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType)
            ),
            new Opportunity(
                Name = 'Test2',
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType)
            )
        };

        fflib_SObjectDomain.Test.Database.onUndelete(opportunityList);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunities opportunitiesMock = (IOpportunities) mocks.mock(IOpportunities.class);
        mocks.startStubbing();
        mocks.when(opportunitiesMock.getType()).thenReturn(Opportunity.SObjectType);
        mocks.stopStubbing();
        Application.DOMAIN.setMock(opportunitiesMock);

        fflib_SObjectDomain.triggerHandler(OpportunitiesHandler.class);
        ((IOpportunities) mocks.verify(opportunitiesMock, 1))
            .updateAccountLifecycleStatusOnOpportunityInsertOrUndelete();
    }

    /**
     * @description Test Opportunity Name on Opportunity Delete
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenOpportunityDeletedThenCall() {
        List<Opportunity> opportunityList = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType)
            ),
            new Opportunity(
                Name = 'Test2',
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType)
            )
        };
        Map<Id, Opportunity> opportunities = new Map<Id, Opportunity>(opportunityList);
        fflib_SObjectDomain.Test.Database.onDelete(opportunities);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunities opportunitiesMock = (IOpportunities) mocks.mock(IOpportunities.class);
        mocks.startStubbing();
        mocks.when(opportunitiesMock.getType()).thenReturn(Opportunity.SObjectType);
        mocks.stopStubbing();
        Application.DOMAIN.setMock(opportunitiesMock);

        fflib_SObjectDomain.triggerHandler(OpportunitiesHandler.class);
        ((IOpportunities) mocks.verify(opportunitiesMock, 1))
            .checkAccountLifecycleStatusWhenOpportunityDeleted();
    }
    /**
     * @description To test method call on Agreement__c insert
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOpportunityUpdatedThenUpdateOppContactRole() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id oppId = Fake.generateId(Opportunity.class);
        Id opportunityContactRoleId = fflib_IDGenerator.generate(
            OpportunityContactRole.SObjectType
        );

        List<Opportunity> oppList = new List<Opportunity>{
            new Opportunity(
                Id = oppId,
                Name = 'Test 1',
                StageName = 'Prospecting',
                SBQQ__PrimaryQuote__c = quoteId
            )
        };
        List<Opportunity> oldOppList = new List<Opportunity>{
            new Opportunity(
                Id = oppId,
                Name = 'Test 1',
                StageName = 'Prospecting',
                SBQQ__PrimaryQuote__c = null
            )
        };

        OpportunityContactRole oppContactRole = (OpportunityContactRole) new Fake(
                OpportunityContactRole.class
            )
            .setField(OpportunityContactRole.Id, opportunityContactRoleId)
            .setField(OpportunityContactRole.Quote__c, null)
            .setField(OpportunityContactRole.OpportunityId, oppList[0].Id)
            .setFakeId()
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunityContactRoleService oppContactRoleService = (IOpportunityContactRoleService) mocks.mock(
            IOpportunityContactRoleService.class
        );
        IOpportunityContactRoleSelector oppContactRoleSelectorMock = (IOpportunityContactRoleSelector) mocks.mock(
            IOpportunityContactRoleSelector.class
        );

        mocks.startStubbing();
        mocks.when(oppContactRoleSelectorMock.SObjectType())
            .thenReturn(OpportunityContactRole.SObjectType);
        mocks.when(
                oppContactRoleSelectorMock.selectContractSignatoryOppContactRole(
                    new Set<Id>{ oppList[0].Id }
                )
            )
            .thenReturn(oppContactRole);
        mocks.stopStubbing();

        Application.SERVICE.setMock(IOpportunityContactRoleService.class, oppContactRoleService);
        Application.SELECTOR.setMock(oppContactRoleSelectorMock);

        fflib_SObjectDomain.Test.Database.onUpdate(oppList, new Map<Id, Opportunity>(oldOppList));
        fflib_SObjectDomain.triggerHandler(OpportunitiesHandler.class);

        ((IOpportunityContactRoleService) mocks.verify(oppContactRoleService, 1))
            .stampPrimaryQuoteOnOppContactRole(
                new Map<Id, Opportunity>{ oppList[0].id => oppList[0] }
            );
    }
    /**
     * @description To test method onAfterUpdate for Closed Won NinTex UseCase Opportunities
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenNintexUseCaseThenCallNintexService() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id oppId1 = Fake.generateId(Opportunity.class);
        Id oppId2 = Fake.generateId(Opportunity.class);
        Id oppId3 = Fake.generateId(Opportunity.class);
        Id oppId4 = Fake.generateId(Opportunity.class);

        List<Opportunity> oppList = new List<Opportunity>{
            new Opportunity(
                Id = oppId1,
                Name = 'Test 2',
                StageName = 'Closed Won',
                SBQQ__PrimaryQuote__c = quoteId,
                Nintex_Use_Case__c = 'Change of Ownership'
            ),
            new Opportunity(
                Id = oppId2,
                Name = 'Test 2',
                StageName = 'Closed Won',
                SBQQ__PrimaryQuote__c = quoteId,
                Nintex_Use_Case__c = 'New additional stores'
            ),
            new Opportunity(
                Id = oppId3,
                Name = 'Test 2',
                StageName = 'Closed Won',
                SBQQ__PrimaryQuote__c = quoteId,
                Nintex_Use_Case__c = 'New Franchise -  Known'
            ),
            new Opportunity(
                Id = oppId4,
                Name = 'Test 2',
                StageName = 'Closed Won',
                SBQQ__PrimaryQuote__c = quoteId,
                Nintex_Use_Case__c = 'New Franchise - Unknown'
            )
        };
        List<Opportunity> oldOppList = new List<Opportunity>{
            new Opportunity(
                Id = oppId1,
                Name = 'Test 2',
                StageName = 'Prospecting',
                SBQQ__PrimaryQuote__c = quoteId,
                Nintex_Use_Case__c = 'Change of Ownership'
            ),
            new Opportunity(
                Id = oppId2,
                Name = 'Test 2',
                StageName = 'Prospecting',
                SBQQ__PrimaryQuote__c = quoteId,
                Nintex_Use_Case__c = 'New additional stores'
            ),
            new Opportunity(
                Id = oppId3,
                Name = 'Test 2',
                StageName = 'Prospecting',
                SBQQ__PrimaryQuote__c = quoteId,
                Nintex_Use_Case__c = 'New Franchise -  Known'
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunities opportunitiesMock = (IOpportunities) mocks.mock(IOpportunities.class);
        mocks.startStubbing();
        mocks.when(opportunitiesMock.getType()).thenReturn(Opportunity.SObjectType);
        mocks.stopStubbing();
        Application.DOMAIN.setMock(opportunitiesMock);

        fflib_SObjectDomain.Test.Database.onUpdate(oppList, new Map<Id, Opportunity>(oldOppList));
        fflib_SObjectDomain.triggerHandler(OpportunitiesHandler.class);

        ((IOpportunities) mocks.verify(opportunitiesMock, 1)).createAgreementsFromOpportunities();
    }

    /**
     * @description To test method onAfterUpdate for Closed Won NinTex UseCase Opportunities
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenNintexUseCaseThenNoCallToNintexService() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id oppId1 = Fake.generateId(Opportunity.class);
        Id oppId2 = Fake.generateId(Opportunity.class);
        Id oppId3 = Fake.generateId(Opportunity.class);
        List<Opportunity> oppList = new List<Opportunity>{
            new Opportunity(
                Id = oppId1,
                Name = 'Test 2',
                StageName = 'Prospecting',
                SBQQ__PrimaryQuote__c = quoteId,
                Nintex_Use_Case__c = 'Change of Ownership'
            ),
            new Opportunity(
                Id = oppId2,
                Name = 'Test 2',
                StageName = 'Closed Won',
                SBQQ__PrimaryQuote__c = quoteId,
                Nintex_Use_Case__c = null
            ),
            new Opportunity(
                Id = oppId3,
                Name = 'Test 2',
                StageName = 'Closed Won',
                SBQQ__PrimaryQuote__c = quoteId,
                Nintex_Use_Case__c = null
            )
        };
        List<Opportunity> oldOppList = new List<Opportunity>{
            new Opportunity(
                Id = oppId1,
                Name = 'Test 2',
                StageName = 'Prospecting',
                SBQQ__PrimaryQuote__c = quoteId,
                Nintex_Use_Case__c = 'Change of Ownership'
            ),
            new Opportunity(
                Id = oppId2,
                Name = 'Test 2',
                StageName = 'Closed Won',
                SBQQ__PrimaryQuote__c = quoteId,
                Nintex_Use_Case__c = 'New additional stores'
            ),
            new Opportunity(
                Id = oppId3,
                Name = 'Test 2',
                StageName = 'Closed Won',
                SBQQ__PrimaryQuote__c = quoteId,
                Nintex_Use_Case__c = 'New Franchise -  Known'
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IOpportunities opportunitiesMock = (IOpportunities) mocks.mock(IOpportunities.class);
        mocks.startStubbing();
        mocks.when(opportunitiesMock.getType()).thenReturn(Opportunity.SObjectType);
        mocks.stopStubbing();
        Application.DOMAIN.setMock(opportunitiesMock);

        fflib_SObjectDomain.Test.Database.onUpdate(oppList, new Map<Id, Opportunity>(oldOppList));
        fflib_SObjectDomain.triggerHandler(OpportunitiesHandler.class);

        ((IOpportunities) mocks.verify(opportunitiesMock, 1)).createAgreementsFromOpportunities();
    }

    /**
     * @description Test OpportunitiesHandler class on Is_Parent_Account_Merged Field updation.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenIsParentAccountMergedFieldChangedThenRelatedMethodCalled() {
        List<Opportunity> oldOpportunities = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                StageName = 'Needs Analysis',
                Deal_Type__c = 'Lite',
                CloseDate = System.today().addDays(5),
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Opportunity_Sub_Type__c = 'test',
                Is_Parent_Account_Merged__c = false
            ),
            new Opportunity(
                Name = 'Test2',
                StageName = 'Needs Analysis',
                Deal_Type__c = 'Standard',
                CloseDate = System.today().addDays(5),
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Opportunity_Sub_Type__c = 'test',
                Is_Parent_Account_Merged__c = false
            )
        };
        List<Opportunity> newOpportunities = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                StageName = 'Needs Analysis',
                Deal_Type__c = 'Lite',
                CloseDate = System.today().addDays(5),
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Opportunity_Sub_Type__c = 'test',
                Is_Parent_Account_Merged__c = true
            ),
            new Opportunity(
                Name = 'Test2',
                StageName = 'Needs Analysis',
                Deal_Type__c = 'Standard',
                CloseDate = System.today().addDays(5),
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Opportunity_Sub_Type__c = 'test',
                Is_Parent_Account_Merged__c = true
            )
        };
        Map<Id, Opportunity> oldOpportunitiesMap = new Map<Id, Opportunity>(oldOpportunities);

        fflib_SObjectDomain.Test.Database.onUpdate(newOpportunities, oldOpportunitiesMap);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunities opportunitiesMock = (IOpportunities) mocks.mock(IOpportunities.class);
        mocks.startStubbing();
        mocks.when(opportunitiesMock.getType()).thenReturn(Opportunity.SObjectType);
        mocks.stopStubbing();
        Application.DOMAIN.setMock(opportunitiesMock);

        fflib_SObjectDomain.triggerHandler(OpportunitiesHandler.class);
        ((IOpportunities) mocks.verify(opportunitiesMock, 1))
            .assignNameOnNamingComponentsUpdates(oldOpportunitiesMap);
        ((IOpportunities) mocks.verify(opportunitiesMock, 1))
            .updateAccountLifecycleStatusOnOpportunityInsertOrUndelete();
    }

    /**
     * @description Test when  an Account changed on an opportunity then call the method updateAccountLifecycleStatusOnOpportunityUpdate.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenAccountIdChangedChangedThenCallupdateAccountLifecycleStatusOnOpportunityUpdate() {
        List<Opportunity> oldOpportunities = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                AccountId = fflib_IDGenerator.generate(Account.SObjectType)
            ),
            new Opportunity(
                Name = 'Test2',
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                AccountId = fflib_IDGenerator.generate(Account.SObjectType)
            )
        };
        List<Opportunity> newOpportunities = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                AccountId = fflib_IDGenerator.generate(Account.SObjectType)
            ),
            new Opportunity(
                Name = 'Test2',
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                AccountId = fflib_IDGenerator.generate(Account.SObjectType)
            )
        };
        Map<Id, Opportunity> oldOpportunitiesMap = new Map<Id, Opportunity>(oldOpportunities);

        fflib_SObjectDomain.Test.Database.onUpdate(newOpportunities, oldOpportunitiesMap);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunities opportunitiesMock = (IOpportunities) mocks.mock(IOpportunities.class);
        mocks.startStubbing();
        mocks.when(opportunitiesMock.getType()).thenReturn(Opportunity.SObjectType);
        mocks.stopStubbing();
        Application.DOMAIN.setMock(opportunitiesMock);

        fflib_SObjectDomain.triggerHandler(OpportunitiesHandler.class);
        ((IOpportunities) mocks.verify(opportunitiesMock, 1))
            .updateAccountLifecycleStatusOnOpportunityUpdate(oldOpportunitiesMap);
    }

    /**
     * @description Test when an Opportunity is inserted then , OCR creation is initiated
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenOpportunityInsertedThenInitiateOCRCreation() {
        List<Opportunity> opportunities = new List<Opportunity>{
            (Opportunity)new Fake(Opportunity.class)
            .setField(Opportunity.Name,TEST_OPPORTUNITY_NAME1)
            .setField(Opportunity.StageName, STAGE_NAME_PROSPECTING)
            .setField(Opportunity.Deal_Type__c, DEAL_TYPE_STANDARD)
            .setField(Opportunity.CloseDate, System.today().addDays(5))
            .setField(Opportunity.Id, fflib_IDGenerator.generate(Opportunity.SObjectType))
            .setField(Opportunity.Opportunity_Sub_Type__c, SUB_TYPE_COO)
            .setField(Opportunity.Source__c, OPPORTUNITY_SOURCE_LEAD)
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Name, TEST_ACCOUNT_NAME)
                    .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)

            )
            .setField(Opportunity.Account_Segment__c, ACCOUNT_SEGMENT_SMB)
            .toSObject(),

        (Opportunity)new Fake(Opportunity.class)
            .setField(Opportunity.Name, TEST_OPPORTUNITY_NAME2)
            .setField(Opportunity.StageName, NEEDS_ANALYSIS_STAGE)
            .setField(Opportunity.Deal_Type__c, DEAL_TYPE_STANDARD)
            .setField(Opportunity.CloseDate, System.today().addDays(5))
            .setField(Opportunity.Id, fflib_IDGenerator.generate(Opportunity.SObjectType))
            .setField(Opportunity.Opportunity_Sub_Type__c, SUB_TYPE_COO)
            .setField(Opportunity.Source__c, OPPORTUNITY_SOURCE_MANUAL)
            .setParent(
                'Account__r',
                 new Fake(Account.class)
                    .setField(Account.Name, TEST_ACCOUNT_NAME)
                    .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)

            )
            .setField(Opportunity.Account_Segment__c, ACCOUNT_SEGMENT_SMB)
            .toSObject()
        };
        fflib_SObjectDomain.Test.Database.onInsert(opportunities);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunities opportunitiesMock = (IOpportunities) mocks.mock(IOpportunities.class);
        mocks.startStubbing();
        mocks.when(opportunitiesMock.getType()).thenReturn(Opportunity.SObjectType);
        mocks.stopStubbing();
        Application.DOMAIN.setMock(opportunitiesMock);

        fflib_SObjectDomain.triggerHandler(OpportunitiesHandler.class);
        ((IOpportunities) mocks.verify(opportunitiesMock, 1))
            .updateOCRForLeadConvertedOpportunities();
        ((IOpportunities) mocks.verify(opportunitiesMock, 1))
            .createOCRForManuallyCreatedOpportunities();
    }

    /**
     * @description Test when an Opportunity is inserted then , OCR creation is initiated
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenSelfServeOpportunityInsertedThenInitiateOCRCreation() {
        List<Opportunity> opportunities = new List<Opportunity>{
            (Opportunity)new Fake(Opportunity.class)
                .setField(Opportunity.Name, TEST_OPPORTUNITY_NAME1)
                .setField(Opportunity.StageName, NEEDS_ANALYSIS_STAGE)
                .setField(Opportunity.Deal_Type__c, DEAL_TYPE_SELF_SERVE)
                .setField(Opportunity.CloseDate, System.today().addDays(5))
                .setField(Opportunity.Id, fflib_IDGenerator.generate(Opportunity.SObjectType))
                .setField(Opportunity.Opportunity_Sub_Type__c, SUB_TYPE_ADS_AND_PROMO)
                .setField(Opportunity.Source__c, OPPORTUNITY_SOURCE_MANUAL)
                .setParent(
                    'Account__r',
                    new Fake(Account.class)
                    .setField(Account.Name, TEST_ACCOUNT_NAME)
                    .setField(Account.Segment__c, ENTERPRISE)
                )
                .setField(Opportunity.Account_Segment__c, ENTERPRISE)
                .toSObject()
        };
        fflib_SObjectDomain.Test.Database.onInsert(opportunities);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunities opportunitiesMock = (IOpportunities) mocks.mock(IOpportunities.class);
        mocks.startStubbing();
        mocks.when(opportunitiesMock.getType()).thenReturn(Opportunity.SObjectType);
        mocks.stopStubbing();
        Application.DOMAIN.setMock(opportunitiesMock);

        fflib_SObjectDomain.triggerHandler(OpportunitiesHandler.class);
        ((IOpportunities) mocks.verify(opportunitiesMock, 1))
            .createOCRForManuallyCreatedOpportunities();
    }

    /**
     * @description Test when an Opportunity is inserted then add the MxTagAssociation
     * to the related List of that business account.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenOpportunityInsertedThenCreateMxTagAssociationRelatedList() {
        List<Opportunity> opportunities = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                StageName = 'Prospecting',
                Deal_Type__c = 'Standard',
                CloseDate = System.today().addDays(5),
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Opportunity_Sub_Type__c = 'COO',
                Source__c = 'Lead'
            )
        };
        fflib_SObjectDomain.Test.Database.onInsert(opportunities);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunities opportunitiesMock = (IOpportunities) mocks.mock(IOpportunities.class);
        mocks.startStubbing();
        mocks.when(opportunitiesMock.getType()).thenReturn(Opportunity.SObjectType);
        mocks.stopStubbing();
        Application.DOMAIN.setMock(opportunitiesMock);

        fflib_SObjectDomain.triggerHandler(OpportunitiesHandler.class);
        ((IOpportunities) mocks.verify(opportunitiesMock, 1))
            .addMxTagAssociationToNewlyCreatedOpportunity();
    }

    /**
     * @description Test when an Opportunity is closed lost then, update Quote and Ironclad status.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOpportunityStageChangedThenUpdateStageNameToClosedLost() {
        Id mockAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id mockOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        List<Opportunity> oldOpportunities = new List<Opportunity>{
            new Opportunity(
                Id = mockOpportunityId,
                Name = OPPORTUNITY_NAME,
                StageName = STAGE_NAME_PROSPECTING,
                AccountId = mockAccountId
            )
        };
        List<Opportunity> newOpportunities = new List<Opportunity>{
            new Opportunity(
                Id = mockOpportunityId,
                Name = OPPORTUNITY_NAME,
                StageName = STAGE_NAME_CLOSED_LOST,
                AccountId = mockAccountId
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ISObjectsStatusUpdateService sObjectStatusUpdateServiceMock = (ISObjectsStatusUpdateService) mocks.mock(
            ISObjectsStatusUpdateService.class
        );
        Application.SERVICE.setMock(
            ISObjectsStatusUpdateService.class,
            sObjectStatusUpdateServiceMock
        );
        fflib_SObjectDomain.Test.Database.onUpdate(
            newOpportunities,
            new Map<Id, Opportunity>(oldOpportunities)
        );
        fflib_SObjectDomain.triggerHandler(OpportunitiesHandler.class);
        ((ISObjectsStatusUpdateService) mocks.verify(sObjectStatusUpdateServiceMock, 1))
            .updateSObjectsStatusFieldValue(newOpportunities);
    }
    /**
     * @description To test when an Opportunity stage is moved to Negotiating then call the
     * method validateOpportunitiesMovedToNegotiatingWithoutHeldEvents.
     * Suppressed Warnings since mock verify method does not require system asssert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOpportunityStageMovedToNegotiatingThenCheckForMethodCall() {
        List<Opportunity> oldOpportunities = new List<Opportunity>{
            new Opportunity(
                Name = OPPORTUNITY_NAME,
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                AccountId = fflib_IDGenerator.generate(Account.SObjectType),
                StageName = OPPORTUNITY_STAGE_PROSPECTING
            )
        };
        List<Opportunity> newOpportunities = new List<Opportunity>{
            new Opportunity(
                Name = OPPORTUNITY_NAME,
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                AccountId = fflib_IDGenerator.generate(Account.SObjectType),
                StageName = OPPORTUNITY_STAGE_NEGOTIATING
            )
        };
        Map<Id, Opportunity> oldOpportunitiesMap = new Map<Id, Opportunity>(oldOpportunities);
        fflib_SObjectDomain.Test.Database.onUpdate(newOpportunities, oldOpportunitiesMap);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunities opportunitiesMock = (IOpportunities) mocks.mock(IOpportunities.class);
        mocks.startStubbing();
        mocks.when(opportunitiesMock.getType()).thenReturn(Opportunity.SObjectType);
        mocks.stopStubbing();
        Application.DOMAIN.setMock(opportunitiesMock);

        fflib_SObjectDomain.triggerHandler(OpportunitiesHandler.class);
        ((IOpportunities) mocks.verify(opportunitiesMock, 1))
            .validateOpportunitiesMovedToNegotiatingWithoutHeldEvents();
    }
    /**
     * @description To test when an Opportunity stage is moved to Contracting then call the
     * method validateOpportunitiesMovedToNegotiatingWithoutHeldEvents.
     * Suppressed Warnings since mock verify method does not require system asssert statements.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOpportunityStageMovedToContractingThenCheckForMethodCall() {
        List<Opportunity> oldOpportunities = new List<Opportunity>{
            new Opportunity(
                Name = OPPORTUNITY_NAME,
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                AccountId = fflib_IDGenerator.generate(Account.SObjectType),
                StageName = OPPORTUNITY_STAGE_PROSPECTING
            )
        };
        List<Opportunity> newOpportunities = new List<Opportunity>{
            new Opportunity(
                Name = OPPORTUNITY_NAME,
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                AccountId = fflib_IDGenerator.generate(Account.SObjectType),
                StageName = OPPORTUNITY_STAGE_CONTRACTING
            )
        };
        Map<Id, Opportunity> oldOpportunitiesMap = new Map<Id, Opportunity>(oldOpportunities);
        fflib_SObjectDomain.Test.Database.onUpdate(newOpportunities, oldOpportunitiesMap);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunities opportunitiesMock = (IOpportunities) mocks.mock(IOpportunities.class);
        mocks.startStubbing();
        mocks.when(opportunitiesMock.getType()).thenReturn(Opportunity.SObjectType);
        mocks.stopStubbing();
        Application.DOMAIN.setMock(opportunitiesMock);

        fflib_SObjectDomain.triggerHandler(OpportunitiesHandler.class);
        ((IOpportunities) mocks.verify(opportunitiesMock, 1))
            .validateOpportunitiesMovedToNegotiatingWithoutHeldEvents();
    }


    /**
     * @description To test when an Opportunity is move to 'Contracting' and Segment is 'SMB' then no
     * Work Order Validation is thrown.
     */
    @isTest
    public static void testWhenOpportunityStageMovedToContractingThenNoWorkOrderValidation() {
        Opportunity oldOpportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, fflib_IDGenerator.generate(Opportunity.SObjectType))
            .setField(Opportunity.Account_Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_PROSPECTING)
            .toSObject();

        Opportunity newOpportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, fflib_IDGenerator.generate(Opportunity.SObjectType))
            .setField(Opportunity.Account_Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_CONTRACTING)
            .toSObject();
        List<Opportunity> oldOpportunities = new List<Opportunity>{ oldOpportunity };
        List<Opportunity> newOpportunities = new List<Opportunity>{ newOpportunity };
        Map<Id, Opportunity> oldOpportunitiesMap = new Map<Id, Opportunity>(oldOpportunities);
        fflib_SObjectDomain.Test.Database.onUpdate(newOpportunities, oldOpportunitiesMap);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunities opportunitiesMock = (IOpportunities) mocks.mock(IOpportunities.class);
        mocks.startStubbing();
        mocks.when(opportunitiesMock.getType()).thenReturn(Opportunity.SObjectType);
        mocks.stopStubbing();
        Application.DOMAIN.setMock(opportunitiesMock);
        Test.startTest();
        fflib_SObjectDomain.triggerHandler(OpportunitiesHandler.class);
        Test.stopTest();
        System.assertEquals(0, fflib_SObjects.Errors.getAll().size(), ERROR_MESSAGE);
    }
}