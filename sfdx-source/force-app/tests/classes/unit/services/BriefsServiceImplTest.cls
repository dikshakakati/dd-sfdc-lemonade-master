/**
 * @author Deloitte
 * @date 11/17/2022
 * @description Test class for BriefsService.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class BriefsServiceImplTest {
    private static final String CAMPAIGN_HALLOWEEN_DEALS = 'Halloween Deals';
    private static final String CAMPAIGN_THANKSGIVING = 'Thanksgiving Offers';
    private static final String OPPORTUNITY_STAGE_PROSPECTING = 'Prospecting';
    private static final String OPPORTUNITY_NAME = 'Opportunity Test';
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenQuoteLineItemsArePassedThenBriefsAreCreated() {
        Id marketplacePromotionQuoteLineItem = fflib_IDGenerator.generate(
            SBQQ__QuoteLine__c.SObjectType
        );
        Id advertisementQuoteLineItem = fflib_IDGenerator.generate(SBQQ__QuoteLine__c.SObjectType);
        Id contractSignedQuote = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType);
        Id oppId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        List<SBQQ__QuoteLine__c> quoteLineItems = new List<SBQQ__QuoteLine__c>{
            (SBQQ__QuoteLine__c) new Fake(SBQQ__QuoteLine__c.class)
                .setField(SBQQ__QuoteLine__c.Id, marketplacePromotionQuoteLineItem)
                .setField(SBQQ__QuoteLine__c.SBQQ__Quote__c, contractSignedQuote)
                .setField(SBQQ__QuoteLine__c.Campaign_Name__c, CAMPAIGN_HALLOWEEN_DEALS)
                .setParent('SBQQ__Quote__r',
                    new Fake(SBQQ__Quote__c.class)
                    .setField(SBQQ__Quote__c.id, contractSignedQuote)
                    .setField(SBQQ__Quote__c.SBQQ__Opportunity2__c, oppId)
                    .setParent('SBQQ__Opportunity2__r',
                        new Fake(Opportunity.class)
                        .setField(Opportunity.AccountId, accountId)
                        .setField(Opportunity.Id, oppId)
                        .setField(Opportunity.CloseDate, System.today().addMonths(5))
                        .setField(Opportunity.Name, OPPORTUNITY_NAME)
                        .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
                        .setField(Opportunity.StageName, OPPORTUNITY_STAGE_PROSPECTING)
                    )
                )
                .toSObject(),
            (SBQQ__QuoteLine__c) new Fake(SBQQ__QuoteLine__c.class)
                .setField(SBQQ__QuoteLine__c.Id, advertisementQuoteLineItem)
                .setField(SBQQ__QuoteLine__c.SBQQ__Quote__c, contractSignedQuote)
                .setField(SBQQ__QuoteLine__c.Campaign_Name__c, CAMPAIGN_THANKSGIVING)
                .setParent('SBQQ__Quote__r',
                    new Fake(SBQQ__Quote__c.class)
                    .setField(SBQQ__Quote__c.id, contractSignedQuote)
                    .setField(SBQQ__Quote__c.SBQQ__Opportunity2__c, oppId)
                    .setParent('SBQQ__Opportunity2__r',
                        new Fake(Opportunity.class)
                        .setField(Opportunity.AccountId, accountId)
                        .setField(Opportunity.Id, oppId)
                        .setField(Opportunity.CloseDate, System.today().addMonths(5))
                        .setField(Opportunity.Name, OPPORTUNITY_NAME)
                        .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
                        .setField(Opportunity.StageName, OPPORTUNITY_STAGE_PROSPECTING)
                    )
                )
                .toSObject()
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Schema.SObjectField oppNameField = ((SObject)Type.forName('Brief__c').newInstance()).getSObjectType().getDescribe().fields.getMap().get('Opportunity_Name__c');
        IQuoteLineItemsSelector selectorMock = (IQuoteLineItemsSelector) mocks.mock(IQuoteLineItemsSelector.class);
        IOpportunityToBriefMappingSelector oppMappingSelectorMock = (IOpportunityToBriefMappingSelector) mocks.mock(IOpportunityToBriefMappingSelector.class);
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(SBQQ__Quoteline__c.SObjectType);
        mocks.when(selectorMock.selectQuoteLinesWithUpgradedSubscriptions(new Set<Id>{contractSignedQuote})).thenReturn(quoteLineItems);
        mocks.when(oppMappingSelectorMock.getBriefFieldsList()).thenReturn(new List<Schema.SObjectField>{oppNameField});

        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        Application.SELECTOR.setMock(oppMappingSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        BriefsService.generateBriefsByQuoteLineItems(quoteLineItems);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Brief__c.CampaignName__c => CAMPAIGN_HALLOWEEN_DEALS
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Brief__c.CampaignName__c => CAMPAIGN_THANKSGIVING
                    }
                )
            );
    }

    @isTest
    private static void testWhenBriefIdsArePassedThenTheStatusIsUpdated() {
        List<Brief__c> briefsWithItemsWaitingForInputs = new List<Brief__c>{
            new Brief__c(
                Id = fflib_IDGenerator.generate(Brief__c.SObjectType),
                Are_All_Brief_Items_in_Campaign_Building__c = false
            )
        };
        Set<Id> briefIdsWithItemsWaitingForInputs = new Set<Id>{
            briefsWithItemsWaitingForInputs[0].Id
        };
        List<Brief__c> briefsWithItemsWithCampaignBuilding = new List<Brief__c>{
            new Brief__c(
                Id = fflib_IDGenerator.generate(Brief__c.SObjectType),
                Are_All_Brief_Items_in_Campaign_Building__c = false
            )
        };
        Set<Id> briefIdsWithItemsWithCampaignBuilding = new Set<Id>{
            briefsWithItemsWithCampaignBuilding[0].Id
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        BriefsSelector selectorMock = (BriefsSelector) mocks.mock(BriefsSelector.class);
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Brief__c.SObjectType);
        mocks.when(
                selectorMock.selectById(
                    new Set<Id>{
                        briefsWithItemsWithCampaignBuilding[0].Id,
                        briefsWithItemsWaitingForInputs[0].Id
                    }
                )
            )
            .thenReturn(
                new List<Brief__c>{
                    briefsWithItemsWithCampaignBuilding[0],
                    briefsWithItemsWaitingForInputs[0]
                }
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        BriefsService.updateBriefBasedOnBriefItemsStatus(
            briefIdsWithItemsWaitingForInputs,
            briefIdsWithItemsWithCampaignBuilding
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    @isTest
    private static void testWhenBriefIdsArePassedThenTheDateIsUpdated() {
        List<Brief__c> briefsWithItemsWaitingForInputs = new List<Brief__c>{
            new Brief__c(
                Id = fflib_IDGenerator.generate(Brief__c.SObjectType),
                Start_Date__c = System.today() - 2,
                End_Date__c = System.today() + 4
            )
        };
        List<Brief__c> briefsWithItemsWithCampaignBuilding = new List<Brief__c>{
            new Brief__c(
                Id = fflib_IDGenerator.generate(Brief__c.SObjectType),
                Start_Date__c = System.today() - 4,
                End_Date__c = System.today() + 7
            )
        };
        Map<Id, Date> briefToStartDate = new Map<Id, Date>{
            briefsWithItemsWaitingForInputs[0].Id => briefsWithItemsWaitingForInputs[0]
                .Start_Date__c,
            briefsWithItemsWithCampaignBuilding[0].Id => briefsWithItemsWithCampaignBuilding[0]
                .Start_Date__c
        };
        Map<Id, Date> briefToEndDate = new Map<Id, Date>{
            briefsWithItemsWaitingForInputs[0].Id => briefsWithItemsWaitingForInputs[0].End_Date__c,
            briefsWithItemsWithCampaignBuilding[0].Id => briefsWithItemsWithCampaignBuilding[0]
                .End_Date__c
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        BriefsSelector selectorMock = (BriefsSelector) mocks.mock(BriefsSelector.class);
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Brief__c.SObjectType);
        mocks.when(
                selectorMock.selectById(
                    new Set<Id>{
                        briefsWithItemsWithCampaignBuilding[0].Id,
                        briefsWithItemsWaitingForInputs[0].Id
                    }
                )
            )
            .thenReturn(
                new List<Brief__c>{
                    briefsWithItemsWithCampaignBuilding[0],
                    briefsWithItemsWaitingForInputs[0]
                }
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        BriefsService.updateBriefDateBasedOnBriefItemsDate(
            new Set<Id>{
                briefsWithItemsWithCampaignBuilding[0].Id,
                briefsWithItemsWaitingForInputs[0].Id
            },
            briefToStartDate,
            briefToEndDate
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }
    /**
     * @description testing updating opps by brief
     */

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenBriefsAreUpdatedThenOpportunitiesAreUpdated(){
        Id oppId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id briefId = fflib_IDGenerator.generate(Brief__c.SObjectType);
        Set<Schema.SObjectField> oppFieldSet = new Set<Schema.SObjectField>{
            Opportunity.SObjectType.getDescribe().fields.getMap().get('Name'),
            Opportunity.SObjectType.getDescribe().fields.getMap().get('Campaign_TLDR__c'),
            Opportunity.SObjectType.getDescribe().fields.getMap().get('Purchase_Order__c')
        };

        List<Opportunity> testOpps = new List<Opportunity>{
            new Opportunity(
                Id = oppId,
                Name = 'TestOpp',
                Campaign_TLDR__c = null,
                Purchase_Order__c = null
            )
        };
        List<Brief__c> briefList = new List<Brief__c>{
            new Brief__c(
                Id = briefId,
                Opportunity_Name__c = oppId,
                Campaign_TLDR__c = 'testTLDR',
                Purchase_Order__c = '123'
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        OpportunitiesSelector selectorMock = (OpportunitiesSelector) mocks.mock(OpportunitiesSelector.class);
        OpportunityToBriefMappingSelector mappingSelectorMock = (OpportunityToBriefMappingSelector) mocks.mock(OpportunityToBriefMappingSelector.class);
        //Mocking
        mocks.startStubbing();
        mocks.when(mappingSelectorMock.getOpportunityFieldSet()).thenReturn(oppFieldSet);
        mocks.when(selectorMock.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(selectorMock.getOpportunitiesToSyncFromBriefs(new Set<Id>{oppId})).thenReturn(testOpps);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        BriefsService.updateOpportunityFromBrief(briefList);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();


    }
    /**
     * @description testing update agency fields
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenAMapOfBriefIdToQuotelineIsProvidedThenBriefsAreUpdated(){
        Id advertisementQuoteLineItem = fflib_IDGenerator.generate(SBQQ__QuoteLine__c.SObjectType);
        Id contractSignedQuote = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType);
        Id advertisementBrief = fflib_IDGenerator.generate(Brief__c.SObjectType);
        Id briefItemId = fflib_IDGenerator.generate(Brief_Item__c.SObjectType);
        Id oppId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Fake parentQuoteLineInstane = new Fake(SBQQ__QuoteLine__c.class)
                .setField(SBQQ__QuoteLine__c.Id, advertisementQuoteLineItem)
                .setField(SBQQ__QuoteLine__c.SBQQ__Quote__c, contractSignedQuote)
                .setField(SBQQ__QuoteLine__c.CurrencyIsoCode, 'USD')
                .setField(SBQQ__QuoteLine__c.Campaign_Name__c, CAMPAIGN_THANKSGIVING)
                .setField(SBQQ__Quoteline__c.Brief_Item__c, briefItemId)
                .setField(SBQQ__Quoteline__c.Has_Brief_Item__c, true)
                .setField(SBQQ__QuoteLine__c.SBQQ__ProductName__c, 'CRM');
            List<SBQQ__QuoteLine__c> quoteLineItems = new List<SBQQ__QuoteLine__c>{
                (SBQQ__QuoteLine__c) ServiceMockDataBuilder.convertToSObject(parentQuoteLineInstane)
            };
            Fake parentOpportunityFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, oppId)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.AccountId, businessAccountId)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_PROSPECTING);
            List<Brief__c> briefToUpdate = new List<Brief__c>{
                (Brief__c) new Fake(Brief__c.class)
                .setField(Brief__c.Id, advertisementBrief)
                .setField(Brief__c.Opportunity_Name__c, oppId)
                .setParent('Opportunity_Name__r', parentOpportunityFakeInstance)
                .toSObject()
            };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        IBriefsSelector briefsSelectorMock = (IBriefsSelector) mocks.mock(
            IBriefsSelector.class
        );
        IQuoteLineItemsSelector selectorMock = (IQuoteLineItemsSelector) mocks.mock(
            IQuoteLineItemsSelector.class
        );
        //mocking
        mocks.startStubbing();
        mocks.when(briefsSelectorMock.SObjectType()).thenReturn(Brief__c.SObjectType);
        mocks.when(briefsSelectorMock.selectByIdIncludingAccountId(new Set<Id>{ advertisementBrief }))
            .thenReturn(briefToUpdate);
        mocks.when(selectorMock.sObjectType()).thenReturn(SBQQ__QuoteLine__c.SObjectType);
        mocks.when(
            selectorMock.selectById(new Set<Id>{advertisementQuoteLineItem})
        ).thenReturn(quoteLineItems);
        mocks.stopStubbing();
        Application.Selector.setMock(briefsSelectorMock);
        Application.Selector.setMock(selectorMock);
        SBQQ__Quoteline__c line = quoteLineItems[0];

        Map<Id, SBQQ__Quoteline__c> briefIdToQuotelineMap = new Map<Id, SBQQ__QuoteLine__c>();
        briefIdToQuotelineMap.put(advertisementBrief, line);
        BriefsService.updateAgencyFieldOnExistingBriefs(
            briefIdToQuotelineMap
        );
    }

    /**
     * @description testing updating brief config field when passed brief list and brief to brief
     * items mapping
     */

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenPassedBriefListAndBriefToBriefItemsThenBriefsAreUpdated(){
        Id oppId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Account testAcc = new Account (
            Id = accountId,
            Primary_Vertical__c = 'CPG'
        );
        Opportunity testOpp = new Opportunity (
            Id = oppId,
            Name = 'TestOpp',
            AccountId = testAcc.Id
        );
        List<Brief__c> briefsWithVert = new List<Brief__c>{
            new Brief__c(
                Id = fflib_IDGenerator.generate(Brief__c.SObjectType),
                Opportunity_Name__c	= testOpp.Id
            ),
            new Brief__c(
                Id = fflib_IDGenerator.generate(Brief__c.SObjectType)
            )
        };
        List<Brief_Item__c> briefItemsOne = new List<Brief_Item__c>{
            new Brief_Item__c(
                Id = fflib_IDGenerator.generate(Brief_Item__c.SObjectType),
                Brief_Routing__c = 'Standard (Launch Ops)',
                Custom_Creative_Required__c = 'Yes'
            )
        };
        List<Brief_Item__c> briefItemsTwo = new List<Brief_Item__c>{
            new Brief_Item__c(
                Id = fflib_IDGenerator.generate(Brief_Item__c.SObjectType),
                Brief_Routing__c = 'Custom (Ad Ops)',
                Custom_Creative_Required__c = 'Yes'
            ),
            new Brief_Item__c(
                Id = fflib_IDGenerator.generate(Brief_Item__c.SObjectType),
                Brief_Routing__c = 'Custom (Ad Ops)',
                Custom_Creative_Required__c = 'No'
            )
        };
        Map<Id, List<Brief_Item__c>> briefsToBriefItems = new Map<Id, List<Brief_Item__c>>{
            briefsWithVert[0].Id => briefItemsOne,
            briefsWithVert[1].Id => briefItemsTwo
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        BriefsService.updateBriefConfiguration(briefsToBriefItems, briefsWithVert);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description testing updating brief config field when passed brief list and brief to brief
     * items mappings
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenPaymentProtocolOnBriefItemIsMarketingFundThenBriefsConfigurationIsCustomAddOpps(){
        Id briefId = fflib_IDGenerator.generate(Brief__c.SObjectType);
        Id briefItemId1 = fflib_IDGenerator.generate(Brief_Item__c.SObjectType);

        List<Brief__c> briefList = new List<Brief__c>{
            (Brief__c) new Fake(Brief__c.class)
                .setField(Brief__c.Id, briefId)
                .toSobject()
        };
        List<Brief_Item__c> briefItemList = new List<Brief_Item__c>{
            (Brief_Item__c) new Fake(Brief_Item__c.class)
                .setField(Brief_Item__c.Id, briefItemId1)
                .setField(Brief_Item__c.Brief_Routing__c, 'Standard (Launch Ops)')
                .setField(Brief_Item__c.Custom_Creative_Required__c, '')
                .setField(Brief_Item__c.Payment_Protocol__c, 'Marketing Fund')
                .setParent(
                    'Brief__r',
                        new Fake(Brief__c.class)
                            .setField(Brief__c.id, briefId)
                            .setField(Brief__c.Configuration__c, 'Standard (Launch Ops)')
                            )
                .toSobject()
        };

        Map<Id, List<Brief_Item__c>> briefsToBriefItems = new Map<Id, List<Brief_Item__c>>{
            briefId => briefItemList
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        BriefsService.updateBriefConfiguration(briefsToBriefItems, briefList);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }
}