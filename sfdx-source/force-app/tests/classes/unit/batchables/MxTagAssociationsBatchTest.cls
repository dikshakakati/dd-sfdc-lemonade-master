/**
 * @author Deloitte
 * @date 09/09/2024
 * @description Test class for MxTagAssociationsBatch.
 */
@isTest(SeeAllData=false)
private class MxTagAssociationsBatchTest {
    private static final String ASSERT_MESSAGE_MISMATCH_CONCATENATED_MX_TAGS = 'Unexpected Result: Mismatch for Mx Tag Associations Concatenated Value';
    private static final String ACCOUNT_NAME = 'Account Test';
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    private static final String MX_TAG_NAME_TIER = 'Tier 100';
    private static final String MX_TAG_NAME_TOP = 'Top 100';
    private static final String MX_TAG_NAME_MARKET_MAKER = 'Market Maker';
    private static final String SEMICOLON = ';';
    private static final String STATUS_ACTIVE = 'Active';
    private static final String STAGE_PITCHING = 'Pitching';
    private static final String OPPORTUNITY_NAME_TEST = 'Test 1';
    private static final String OPPORTUNITY_NAME_TEST_2 = 'Test 2';
    private static final String CONCATENATED_MX_TAGS = 'Market Maker;Tier 100;Top 100';

    @isTest
    private static void testWhenMxTagAssociationCreatedThenConcatenateActiveMxTagsOnOpportunities() {
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        String accountId = fflib_IDGenerator.generate(Account.SObjectType);
        String concatenatedMxTags = 'Tier 100;Top 100';
        String opportunityId1 = fflib_IDGenerator.generate(Opportunity.SObjectType);
        String opportunityId2 = fflib_IDGenerator.generate(Opportunity.SObjectType);
        List<Account> accounts = new List<Account>{
            new Account(Id = accountId, Name = ACCOUNT_NAME, RecordTypeId = accRecordTypeBusiness)
        };
        List<MxTag__c> mxTags = new List<MxTag__c>{
            new MxTag__c(
                Id = fflib_IDGenerator.generate(MxTag__c.SObjectType),
                Name__c = MX_TAG_NAME_TIER,
                Status__c = STATUS_ACTIVE
            ),
            new MxTag__c(
                Id = fflib_IDGenerator.generate(MxTag__c.SObjectType),
                Name__c = MX_TAG_NAME_TOP,
                Status__c = STATUS_ACTIVE
            )
        };
        Mx_Tag_Association__c tierAccountMxTagAssociation = (Mx_Tag_Association__c) new Fake(
                Mx_Tag_Association__c.class
            )
            .setField(
                Mx_Tag_Association__c.Id,
                fflib_IDGenerator.generate(Mx_Tag_Association__c.SObjectType)
            )
            .setField(Mx_Tag_Association__c.Account__c, accounts[0].Id)
            .setField(Mx_Tag_Association__c.MxTag__c, mxTags[0].Id)
            .setField(Mx_Tag_Association__c.MxTagName__c, MX_TAG_NAME_TIER)
            .toSobject();
        Mx_Tag_Association__c tierOppMxTagAssociation = (Mx_Tag_Association__c) new Fake(
                Mx_Tag_Association__c.class
            )
            .setField(
                Mx_Tag_Association__c.Id,
                fflib_IDGenerator.generate(Mx_Tag_Association__c.SObjectType)
            )
            .setField(Mx_Tag_Association__c.MxTag__c, mxTags[0].Id)
            .setField(Mx_Tag_Association__c.MxTagName__c, MX_TAG_NAME_TIER)
            .setField(Mx_Tag_Association__c.Opportunity__c, opportunityId1)
            .setField(Mx_Tag_Association__c.Opportunity_Account__c, accountId)
            .toSobject();
        Mx_Tag_Association__c topAccountMxTagAssociation = (Mx_Tag_Association__c) new Fake(
                Mx_Tag_Association__c.class
            )
            .setField(
                Mx_Tag_Association__c.Id,
                fflib_IDGenerator.generate(Mx_Tag_Association__c.SObjectType)
            )
            .setField(Mx_Tag_Association__c.Account__c, accountId)
            .setField(Mx_Tag_Association__c.MxTag__c, mxTags[1].Id)
            .setField(Mx_Tag_Association__c.MxTagName__c, MX_TAG_NAME_TOP)
            .toSobject();
        Mx_Tag_Association__c topOppMxTagAssociation = (Mx_Tag_Association__c) new Fake(
                Mx_Tag_Association__c.class
            )
            .setField(
                Mx_Tag_Association__c.Id,
                fflib_IDGenerator.generate(Mx_Tag_Association__c.SObjectType)
            )
            .setField(Mx_Tag_Association__c.MxTag__c, mxTags[1].Id)
            .setField(Mx_Tag_Association__c.MxTagName__c, MX_TAG_NAME_TIER)
            .setField(Mx_Tag_Association__c.Opportunity__c, opportunityId2)
            .setField(Mx_Tag_Association__c.Opportunity_Account__c, accountId)
            .toSobject();
        List<Mx_Tag_Association__c> mxTagAssociations = new List<Mx_Tag_Association__c>{
            tierAccountMxTagAssociation,
            tierOppMxTagAssociation,
            topAccountMxTagAssociation,
            topOppMxTagAssociation
        };
        List<Opportunity> opportunities = new List<Opportunity>{
            new Opportunity(
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Name = opportunityId1,
                StageName = STAGE_PITCHING,
                CloseDate = system.today().addDays(25),
                AccountId = accountId,
                Estimated_Number_of_Stores__c = 1
            ),
            new Opportunity(
                Id = opportunityId2,
                Name = OPPORTUNITY_NAME_TEST_2,
                StageName = STAGE_PITCHING,
                CloseDate = system.today().addDays(25),
                AccountId = accountId,
                Estimated_Number_of_Stores__c = 1
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        MxTagAssociationsSelector mocksMxTagAssociationsSelector = (MxTagAssociationsSelector) mocks.mock(
            MxTagAssociationsSelector.class
        );
        OpportunitiesSelector mocksOpportunitiesSelector = (OpportunitiesSelector) mocks.mock(
            OpportunitiesSelector.class
        );
        mocks.startStubbing();
        mocks.when(mocksMxTagAssociationsSelector.SObjectType())
            .thenReturn(Schema.Mx_Tag_Association__c.SObjectType);
        mocks.when(mocksOpportunitiesSelector.SObjectType())
            .thenReturn(Schema.Opportunity.SObjectType);
        mocks.when(
                mocksMxTagAssociationsSelector.selectActiveMxTagAssociationsCreatedUpdatedInLast24Hours()
            )
            .thenReturn(mxTagAssociations);
        mocks.when(
                mocksMxTagAssociationsSelector.selectByBusinessAccountIds(new Set<Id>{ accountId })
            )
            .thenReturn(mxTagAssociations);
        mocks.when(
                mocksOpportunitiesSelector.selectAllOpenOpportunitiesByAccountIds(
                    new Set<Id>{ accountId }
                )
            )
            .thenReturn(opportunities);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mocksMxTagAssociationsSelector);
        Application.SELECTOR.setMock(mocksOpportunitiesSelector);
        MxTagAssociationsBatch scheduler = new MxTagAssociationsBatch();
        scheduler.start(null);
        scheduler.execute(null, mxTagAssociations);
        scheduler.finish(null);
        System.assertEquals(
            MX_TAG_NAME_TIER +
            SEMICOLON +
            MX_TAG_NAME_TOP,
            concatenatedMxTags,
            ASSERT_MESSAGE_MISMATCH_CONCATENATED_MX_TAGS
        );
    }

    @isTest
    private static void testWhenMxTagAssociationCreatedThenConcatenateActiveMxTagsOnOpportunitiesWithFieldNotBlank() {
        String accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        List<Account> accounts = new List<Account>{
            (Account) new Fake(Account.class)
                .setField(Account.Id, accountId)
                .setField(Account.RecordTypeId, accRecordTypeBusiness)
                .setParent(
                    'RecordType',
                    new Fake(RecordType.class)
                        .setField(RecordType.Id, accRecordTypeBusiness)
                        .setField(RecordType.Name, 'Business')
                )
                .toSobject()
        };
        List<MxTag__c> mxTags = new List<MxTag__c>{
            new MxTag__c(
                Id = fflib_IDGenerator.generate(MxTag__c.SObjectType),
                Name__c = MX_TAG_NAME_TIER,
                Status__c = STATUS_ACTIVE
            ),
            new MxTag__c(
                Id = fflib_IDGenerator.generate(MxTag__c.SObjectType),
                Name__c = MX_TAG_NAME_TOP,
                Status__c = STATUS_ACTIVE
            )
        };
        Mx_Tag_Association__c tierAccountMxTagAssociation = (Mx_Tag_Association__c) new Fake(
                Mx_Tag_Association__c.class
            )
            .setField(
                Mx_Tag_Association__c.Id,
                fflib_IDGenerator.generate(Mx_Tag_Association__c.SObjectType)
            )
            .setField(Mx_Tag_Association__c.Account__c, accounts[0].Id)
            .setField(Mx_Tag_Association__c.MxTag__c, mxTags[0].Id)
            .setField(Mx_Tag_Association__c.MxTagName__c, MX_TAG_NAME_TIER)
            .toSobject();
        Mx_Tag_Association__c tierOppMxTagAssociation = (Mx_Tag_Association__c) new Fake(
                Mx_Tag_Association__c.class
            )
            .setField(
                Mx_Tag_Association__c.Id,
                fflib_IDGenerator.generate(Mx_Tag_Association__c.SObjectType)
            )
            .setField(Mx_Tag_Association__c.MxTag__c, mxTags[0].Id)
            .setField(Mx_Tag_Association__c.MxTagName__c, MX_TAG_NAME_TIER)
            .setField(Mx_Tag_Association__c.Opportunity__c, opportunityId)
            .setField(Mx_Tag_Association__c.Opportunity_Account__c, accountId)
            .toSobject();
        Mx_Tag_Association__c topAccountMxTagAssociation = (Mx_Tag_Association__c) new Fake(
                Mx_Tag_Association__c.class
            )
            .setField(
                Mx_Tag_Association__c.Id,
                fflib_IDGenerator.generate(Mx_Tag_Association__c.SObjectType)
            )
            .setField(Mx_Tag_Association__c.Account__c, accountId)
            .setField(Mx_Tag_Association__c.MxTag__c, mxTags[1].Id)
            .setField(Mx_Tag_Association__c.MxTagName__c, MX_TAG_NAME_TOP)
            .toSobject();
        Mx_Tag_Association__c topOppMxTagAssociation = (Mx_Tag_Association__c) new Fake(
                Mx_Tag_Association__c.class
            )
            .setField(
                Mx_Tag_Association__c.Id,
                fflib_IDGenerator.generate(Mx_Tag_Association__c.SObjectType)
            )
            .setField(Mx_Tag_Association__c.MxTag__c, mxTags[1].Id)
            .setField(Mx_Tag_Association__c.MxTagName__c, MX_TAG_NAME_TIER)
            .setField(Mx_Tag_Association__c.Opportunity__c, opportunityId)
            .setField(Mx_Tag_Association__c.Opportunity_Account__c, accountId)
            .toSobject();
        List<Mx_Tag_Association__c> mxTagAssociations = new List<Mx_Tag_Association__c>{
            tierAccountMxTagAssociation,
            tierOppMxTagAssociation,
            topAccountMxTagAssociation,
            topOppMxTagAssociation
        };
        List<Opportunity> opportunities = new List<Opportunity>{
            new Opportunity(
                Id = opportunityId,
                Name = OPPORTUNITY_NAME_TEST,
                StageName = STAGE_PITCHING,
                CloseDate = system.today().addDays(25),
                AccountId = accountId,
                Mx_Tag_Associations_Concatenated__c = MX_TAG_NAME_MARKET_MAKER,
                Estimated_Number_of_Stores__c = 1
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        MxTagAssociationsSelector mocksMxTagAssociationsSelector = (MxTagAssociationsSelector) mocks.mock(
            MxTagAssociationsSelector.class
        );
        OpportunitiesSelector mocksOpportunitiesSelector = (OpportunitiesSelector) mocks.mock(
            OpportunitiesSelector.class
        );
        mocks.startStubbing();
        mocks.when(mocksMxTagAssociationsSelector.SObjectType())
            .thenReturn(Schema.Mx_Tag_Association__c.SObjectType);
        mocks.when(mocksOpportunitiesSelector.SObjectType())
            .thenReturn(Schema.Opportunity.SObjectType);
        mocks.when(
                mocksMxTagAssociationsSelector.selectActiveMxTagAssociationsCreatedUpdatedInLast24Hours()
            )
            .thenReturn(mxTagAssociations);
        mocks.when(
                mocksMxTagAssociationsSelector.selectByBusinessAccountIds(
                    new Set<Id>{ accounts[0].Id }
                )
            )
            .thenReturn(mxTagAssociations);
        mocks.when(
                mocksOpportunitiesSelector.selectAllOpenOpportunitiesByAccountIds(
                    new Set<Id>{ accounts[0].Id }
                )
            )
            .thenReturn(opportunities);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mocksMxTagAssociationsSelector);
        Application.SELECTOR.setMock(mocksOpportunitiesSelector);
        MxTagAssociationsBatch scheduler = new MxTagAssociationsBatch();
        scheduler.start(null);
        scheduler.execute(null, mxTagAssociations);
        scheduler.finish(null);
        System.assertEquals(
            MX_TAG_NAME_MARKET_MAKER +
            SEMICOLON +
            MX_TAG_NAME_TIER +
            SEMICOLON +
            MX_TAG_NAME_TOP,
            CONCATENATED_MX_TAGS,
            ASSERT_MESSAGE_MISMATCH_CONCATENATED_MX_TAGS
        );
    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMxTagAssociationCreatedThenConcatenateActiveMxTagsOnOpportunitiesNegative() {
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        List<Account> accounts = new List<Account>{
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = ACCOUNT_NAME,
                RecordTypeId = accRecordTypeBusiness
            )
        };
        List<MxTag__c> mxTags = new List<MxTag__c>{
            new MxTag__c(
                Id = fflib_IDGenerator.generate(MxTag__c.SObjectType),
                Name__c = MX_TAG_NAME_TIER,
                Status__c = STATUS_ACTIVE
            ),
            new MxTag__c(
                Id = fflib_IDGenerator.generate(MxTag__c.SObjectType),
                Name__c = MX_TAG_NAME_TOP,
                Status__c = STATUS_ACTIVE
            )
        };
        List<Mx_Tag_Association__c> mxTagAssociations = new List<Mx_Tag_Association__c>{
            new Mx_Tag_Association__c(
                Id = fflib_IDGenerator.generate(Mx_Tag_Association__c.SObjectType),
                Account__c = accounts[0].Id,
                MxTag__c = mxTags[0].Id
            ),
            new Mx_Tag_Association__c(
                Id = fflib_IDGenerator.generate(Mx_Tag_Association__c.SObjectType),
                Account__c = accounts[0].Id,
                MxTag__c = mxTags[1].Id
            )
        };

        List<Opportunity> opportunities = new List<Opportunity>{
            new Opportunity(
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Name = OPPORTUNITY_NAME_TEST,
                StageName = STAGE_PITCHING,
                CloseDate = system.today().addDays(25),
                AccountId = accounts[0].Id,
                Mx_Tag_Associations_Concatenated__c = 'Tier 100; Top 100',
                Estimated_Number_of_Stores__c = 1
            ),
            new Opportunity(
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Name = OPPORTUNITY_NAME_TEST_2,
                StageName = STAGE_PITCHING,
                CloseDate = system.today().addDays(25),
                AccountId = accounts[0].Id,
                Mx_Tag_Associations_Concatenated__c = 'Tier 100; Top 100',
                Estimated_Number_of_Stores__c = 1
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        MxTagAssociationsSelector mocksMxTagAssociationsSelector = (MxTagAssociationsSelector) mocks.mock(
            MxTagAssociationsSelector.class
        );
        OpportunitiesSelector mocksOpportunitiesSelector = (OpportunitiesSelector) mocks.mock(
            OpportunitiesSelector.class
        );
        IOpportunitiesService serviceMock = (IOpportunitiesService) mocks.mock(
            IOpportunitiesService.class
        );
        mocks.startStubbing();
        mocks.when(mocksMxTagAssociationsSelector.SObjectType())
            .thenReturn(Schema.Mx_Tag_Association__c.SObjectType);
        mocks.when(mocksOpportunitiesSelector.SObjectType())
            .thenReturn(Schema.Opportunity.SObjectType);

        mocks.when(
                mocksMxTagAssociationsSelector.selectActiveMxTagAssociationsCreatedUpdatedInLast24Hours()
            )
            .thenReturn(mxTagAssociations);
        mocks.when(
                mocksMxTagAssociationsSelector.selectByBusinessAccountIds(
                    new Set<Id>{ accounts[0].Id }
                )
            )
            .thenReturn(mxTagAssociations);
        mocks.when(
                mocksOpportunitiesSelector.selectAllOpenOpportunitiesByAccountIds(
                    new Set<Id>{ accounts[0].Id }
                )
            )
            .thenReturn(opportunities);

        mocks.stopStubbing();
        Application.SELECTOR.setMock(mocksMxTagAssociationsSelector);
        Application.SELECTOR.setMock(mocksOpportunitiesSelector);
        Application.SERVICE.setMock(IOpportunitiesService.class, serviceMock);

        MxTagAssociationsBatch schedulerObj = new MxTagAssociationsBatch();
        schedulerObj.start(null);
        schedulerObj.execute(null, null);
        schedulerObj.finish(null);

        //ASSERT
        ((IOpportunitiesService) mocks.verify(serviceMock, 0))
            .concatenateMxTagsOnSObjects(new List<Mx_Tag_Association__c>{ mxTagAssociations[0] });
    }
}