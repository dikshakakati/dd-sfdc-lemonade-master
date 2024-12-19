/**
 * @author ATG
 * @date 2022-04-07
 * @description This is test class for Quotes class
 */
@isTest(seeAllData=false)
public class QuotesTest {
    private static final String ASSERT_MESSAGE_MISMATCH_IN_OUT_FOR_SIGNATURE_DATE = 'Unexpected result: mismatch in Out For Signature date on Quote';
    private static final String INVALID_ASSERT_MESSAGE = 'Unexpected result';
    public static final String PAYMENT_TERMS_NET_30 = 'Net 30';
    public static final String PAYMENT_TERMS_NET_45 = 'Net 45';
    private static final String REDLINING = 'Redlining';
    private static final String QUOTE_STATUS_APPROVED = 'Approved';
    private static final String QUOTE_STATUS_OUT_FOR_SIGNATURE = 'Out for Signature';
    private static final String SPONSORSHIPS = 'Sponsorships';
    private static final String SEGMENT_SMB = 'SMB';
    private static final String SELF_SERVE_ACTIVATED = 'Activated';
    private static final String TEMPLATIZED_E_SIGN = 'Templatized e-sign';
    private static final String OPPORTUNITY_STAGE_CONTRACTING = 'Contracting';
    private static final String OPPORTUNITY_STAGE_CLOSED_WON = 'Closed Won';
    private static final String OPPORTUNITY_STAGE_PROSPECTING = 'Prospecting';
    private static final String OPPORTUNITY_STAGE_NEGOTIATING = 'Negotiating';
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    private static final String SUB_TYPE_ADS_AND_PROMO = 'Ads & Promos';
    private static final String DEAL_TYPE_SELF_SERVE = 'Self-Serve';
    private static final String ACCOUNT_SEGMENT_ENTERPRISE = 'Enterprise';
    private static final String ACCOUNT_SEGMENT_ALL = 'All';
    private static final String QUOTE_STATUS_CONTRACT_SIGNED = 'Contract Signed';
    private static final String QUOTE_STATUS_DRAFT = 'Draft';
    private static final String ASSERT_MESSAGE = 'Unexpected result: There is a mismatch in Quotes data';
    public static final String ADS_PROMOS_YES_VALUE = 'Yes';
    public static final String ADS_PROMOS_NO_VALUE = 'No';
    public static final String CONTRACT_SPLIT_CATEGORY_ADS_PROMOS = 'A&P';
    private static final String ALCOHOL_PRODUCT = 'Alcohol Delivery';
    /**
     * @description To test generateOrders call
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenQuotesUpdatedThenGenerateOrders() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id quoteId2 = Fake.generateId(SBQQ__Quote__c.class);
        Id contentDocumentId = Fake.generateId(ContentDocument.class);

        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>{
            new SBQQ__Quote__c(
                Id = quoteId,
                SBQQ__Ordered__c = false,
                SBQQ__Status__c = QuotesHandler.CONTRACT_SIGNED
            ),
            new SBQQ__Quote__c(
                Id = quoteId2,
                SBQQ__Ordered__c = false,
                SBQQ__Status__c = QuotesHandler.CONTRACT_SIGNED
            )
        };
        ContentDocumentLink contentlink1 = new ContentDocumentLink();
        contentlink1.LinkedEntityId = quoteId;
        contentlink1.contentdocumentid = contentDocumentId;

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IContentDocumentLinkSelector selectorMock = (IContentDocumentLinkSelector) mocks.mock(
            ContentDocumentLinkSelector.class
        );

        mocks.startStubbing();
        mocks.when(selectorMock.SObjectType()).thenReturn(ContentDocumentLink.SObjectType);
        mocks.when(
                selectorMock.selectCompletedTitlesByLinkedEntity(new Set<Id>{ quoteId, quoteId2 })
            )
            .thenReturn(new List<ContentDocumentLink>{ contentlink1 });
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(selectorMock);

        IQuotes quotesInstance = Quotes.newInstance(quoteList);
        quotesInstance.setSignedContractLinkAndDate();
        Map<Id, SBQQ__Quote__c> quoteMapForBeforeUpdate = new Map<Id, SBQQ__Quote__c>(quoteList);
        System.assertEquals(
            date.today(),
            quoteMapForBeforeUpdate.get(quoteId).Contract_Signed_Date__c,
            'Contract Signed Date is not updated as expected'
        );
        System.assert(
            quoteMapForBeforeUpdate.get(quoteId)
                .Signed_Contract_link__c.contains(contentdocumentid),
            'Signed Contract link is not set as expected'
        );
        quotesInstance.generateOrders();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        SBQQ__Quote__c.Id => quoteId,
                        SBQQ__Quote__c.SBQQ__Ordered__c => true
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        SBQQ__Quote__c.Id => quoteId2,
                        SBQQ__Quote__c.SBQQ__Ordered__c => true
                    }
                )
            );
    }

    /**
     * @description To test generateOrders call
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenQuotesNotContractSignedThenDoNotGenerateOrders() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id quoteId2 = Fake.generateId(SBQQ__Quote__c.class);

        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>{
            new SBQQ__Quote__c(
                Id = quoteId,
                SBQQ__Ordered__c = false,
                SBQQ__Status__c = 'Out for Signature'
            ),
            new SBQQ__Quote__c(
                Id = quoteId2,
                SBQQ__Ordered__c = false,
                SBQQ__Status__c = 'Out for Signature'
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        IQuotes quotesInstance = Quotes.newInstance(quoteList);
        quotesInstance.generateOrders();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.never()))
            .registerDirty(fflib_Match.anySObject());
    }

    /**
     * @description To test generateOrders call
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenNegativeConditionQuotesUpdatedThenDoNotGenerateOrders() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id quoteId2 = Fake.generateId(SBQQ__Quote__c.class);

        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>{
            new SBQQ__Quote__c(
                Id = quoteId,
                SBQQ__Ordered__c = true,
                SBQQ__Status__c = Quotes.CONTRACT_SIGNED
            ),
            new SBQQ__Quote__c(
                Id = quoteId2,
                SBQQ__Ordered__c = false,
                SBQQ__Status__c = QUOTE_STATUS_APPROVED
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        IQuotes quotesInstance = Quotes.newInstance(quoteList);
        quotesInstance.generateOrders();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.never()))
            .registerDirty(fflib_Match.anySObject());
    }

    /**
     * @description To test empty quote list
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenEmptyQuoteListThenDoNotGenerateOrders() {
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>{};

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        IQuotes quotesInstance = Quotes.newInstance(quoteList);
        quotesInstance.generateOrders();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.never()))
            .registerDirty(fflib_Match.anySObject());
    }

    /**
     * @description To test Quote Trigger
     */
    @isTest
    private static void testWhenQuoteInsertedThenRun() {
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        insert quote;
        System.assertNotEquals(null, quote.Id, 'Id is null');
    }
    /**
     * @description To test populateDoorDashSignerOnQuote Method
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAdsPromosSumUpdatesThenPopulateDDSigner() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id quoteId2 = Fake.generateId(SBQQ__Quote__c.class);
        Id quoteId3 = Fake.generateId(SBQQ__Quote__c.class);

        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>{
            new SBQQ__Quote__c(
                Id = quoteId,
                SBQQ__Ordered__c = false,
                Ads_Promos_Budget_Sum__c = 90000,
                SBQQ__SalesRep__c = UserInfo.getUserId()
            ),
            new SBQQ__Quote__c(
                Id = quoteId2,
                SBQQ__Ordered__c = false,
                Ads_Promos_Budget_Sum__c = 100000,
                SBQQ__SalesRep__c = UserInfo.getUserId()
            ),
            new SBQQ__Quote__c(
                Id = quoteId3,
                SBQQ__Ordered__c = false,
                Ads_Promos_Budget_Sum__c = 1000000,
                SBQQ__SalesRep__c = UserInfo.getUserId()
            )
        };
        User currentUserManager = new User(
            Id = Fake.generateId(User.class),
            Email = 'user.Manager@xyz.com',
            FirstName = 'User',
            LastName = 'Manager',
            IsActive = true,
            Username = 'user.Manager@xyz.com.xxx'
        );
        User currentUser = new User(
            Id = UserInfo.getUserId(),
            Email = 'test@test.com.xxx.yyy',
            FirstName = 'Test',
            LastName = 'User1',
            IsActive = true,
            Username = 'test@test.com.xxx',
            ManagerId = currentUserManager.Id
        );
        User docuSignDirector = new User(
            Id = Fake.generateId(User.class),
            Email = system.label.Docusign_Budget_Director,
            FirstName = 'DocuSign',
            LastName = 'Director',
            IsActive = true,
            Username = system.label.Docusign_Budget_Director + '.xxx'
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IUsersSelector selectorMock = (IUsersSelector) mocks.mock(IUsersSelector.class);
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(User.SObjectType);
        mocks.when(
                selectorMock.selectUserIdsByEmailAddressAndIds(
                    system.label.Docusign_Budget_Director,
                    new Set<Id>{ UserInfo.getUserId() }
                )
            )
            .thenReturn(new List<User>{ currentUser, docuSignDirector });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        IQuotes quotesInstance = Quotes.newInstance(quoteList);
        quotesInstance.populateDoorDashSignerOnQuote();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 3))
            .registerDirty(fflib_Match.anySObject());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        SBQQ__Quote__c.Id => quoteId,
                        SBQQ__Quote__c.DoorDash_Signer__c => currentUser.Id
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        SBQQ__Quote__c.Id => quoteId2,
                        SBQQ__Quote__c.DoorDash_Signer__c => currentUser.ManagerId
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        SBQQ__Quote__c.Id => quoteId3,
                        SBQQ__Quote__c.DoorDash_Signer__c => docuSignDirector.Id
                    }
                )
            );
    }
    /**
     * @description To test populateDoorDashSignerOnQuote Method
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenDDSignerAlreadyExistsThenDoNotUpdate() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id quoteId2 = Fake.generateId(SBQQ__Quote__c.class);
        Id quoteId3 = Fake.generateId(SBQQ__Quote__c.class);

        User currentUserManager = new User(
            Id = Fake.generateId(User.class),
            Email = 'user.Manager@xyz.com',
            FirstName = 'User',
            LastName = 'Manager',
            IsActive = true,
            Username = 'user.Manager@xyz.com.xxx'
        );
        User currentUser = new User(
            Id = UserInfo.getUserId(),
            Email = 'test@test.com.xxx.yyy',
            FirstName = 'Test',
            LastName = 'User1',
            IsActive = true,
            Username = 'test@test.com.xxx',
            ManagerId = currentUserManager.Id
        );
        User docuSignDirector = new User(
            Id = Fake.generateId(User.class),
            Email = system.label.Docusign_Budget_Director,
            FirstName = 'DocuSign',
            LastName = 'Director',
            IsActive = true,
            Username = system.label.Docusign_Budget_Director + '.xxx'
        );

        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>{
            new SBQQ__Quote__c(
                Id = quoteId,
                SBQQ__Ordered__c = false,
                Ads_Promos_Budget_Sum__c = 90000,
                SBQQ__SalesRep__c = UserInfo.getUserId(),
                DoorDash_Signer__c = UserInfo.getUserId()
            ),
            new SBQQ__Quote__c(
                Id = quoteId2,
                SBQQ__Ordered__c = false,
                Ads_Promos_Budget_Sum__c = 100000,
                SBQQ__SalesRep__c = UserInfo.getUserId(),
                DoorDash_Signer__c = currentUser.ManagerId
            ),
            new SBQQ__Quote__c(
                Id = quoteId3,
                SBQQ__Ordered__c = false,
                Ads_Promos_Budget_Sum__c = 1000000,
                SBQQ__SalesRep__c = UserInfo.getUserId(),
                DoorDash_Signer__c = docuSignDirector.Id
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IUsersSelector selectorMock = (IUsersSelector) mocks.mock(IUsersSelector.class);
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(User.SObjectType);
        mocks.when(
                selectorMock.selectUserIdsByEmailAddressAndIds(
                    system.label.Docusign_Budget_Director,
                    new Set<Id>{ UserInfo.getUserId() }
                )
            )
            .thenReturn(new List<User>{ currentUser, docuSignDirector });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        IQuotes quotesInstance = Quotes.newInstance(quoteList);
        quotesInstance.populateDoorDashSignerOnQuote();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.never()))
            .registerDirty(fflib_Match.anySObject());
    }

    /**
     * @description To test updateContractSignatoryExists Method
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenQuoteIsApprovedThenUpdateContractSignatoryFlag() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id quoteId2 = Fake.generateId(SBQQ__Quote__c.class);
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>{
            new SBQQ__Quote__c(Id = quoteId, SBQQ__Status__c = QUOTE_STATUS_APPROVED),
            new SBQQ__Quote__c(Id = quoteId2, SBQQ__Status__c = 'Draft')
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        IQuotes quotesInstance = Quotes.newInstance(quoteList);
        quotesInstance.updateContractSignatoryExists();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.never()))
            .registerDirty(fflib_Match.anySObject());
    }

    /**
     * @description To test if Briefs and Brief Items creation is initiated when the Quote is
     * Contract Signed.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenContractOnQuoteSignedThenBriefsAndItemCreationInitiated() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id quoteId2 = Fake.generateId(SBQQ__Quote__c.class);
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>{
            new SBQQ__Quote__c(Id = quoteId, SBQQ__Status__c = 'In Review'),
            new SBQQ__Quote__c(Id = quoteId2, SBQQ__Status__c = 'Draft')
        };
        //mocking
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBriefsService mockBriefsService = (IBriefsService) mocks.mock(IBriefsService.class);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IBriefsService.class, mockBriefsService);
        IQuotes quotesInstance = Quotes.newInstance(quoteList);
        quotesInstance.initiateBriefsWithItemsGeneration();
        ((IBriefsService) mocks.verify(mockBriefsService, 0))
            .generateBriefsByQuoteLineItems(new List<SBQQ__QuoteLine__c>{});
    }

    /**
     * @description To test if Opportunity update is initiated when the Estimated Total Investment
     * is updated on Quote.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenInvestmentOnQuoteThenOpportunityInvestmentIsUpdated() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        SBQQ__Quote__c parentQuote = (SBQQ__Quote__c) new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id, quoteId)
            .setField(SBQQ__Quote__c.SBQQ__Status__c, 'In Review')
            .setChildren(
                'SBQQ__LineItems__r',
                new List<Fake>{
                    new Fake(SBQQ__QuoteLine__c.class)
                        .setFakeId()
                        .setField(SBQQ__QuoteLine__c.Campaign_Name__c, 'Campaign')
                        .setField(SBQQ__QuoteLine__c.Estimated_Total_Investment__c, 7)
                        .setField(SBQQ__QuoteLine__c.SBQQ__Quote__c, quoteId)
                }
            )
            .toSObject();
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        quotes.add(parentQuote);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunitiesService mockOpportunitiesService = (IOpportunitiesService) mocks.mock(
            IOpportunitiesService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IOpportunitiesService.class, mockOpportunitiesService);
        IQuotes quotesInstance = new Quotes(quotes);
        quotesInstance.updateOpportunityInvestment();
        ((IOpportunitiesService) mocks.verify(mockOpportunitiesService, 1))
            .updateEstimatedTotalInvestmentOnOpportunity(new Map<Id, Decimal>{});
    }
    /**
     * @description To validate when Quote's status changed to 'Out for Signature' then associated Opportunity's status changed to 'Contracting'.
     * @JIRA# LEM-14174
     */

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenQuoteStatusOutForSignatureThenOpportunityStageChangedToContracting() {
        Id mockQuoteId1 = Fake.generateId(SBQQ__Quote__c.class);
        Id mockQuoteId2 = Fake.generateId(SBQQ__Quote__c.class);
        Id mockOpportunityId1 = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id mockOpportunityId2 = fflib_IDGenerator.generate(Opportunity.SObjectType);

        List<Opportunity> opportunityIdToStage = new List<Opportunity>{
            new Opportunity(Id = mockOpportunityId1, StageName = OPPORTUNITY_STAGE_PROSPECTING),
            new Opportunity(Id = mockOpportunityId2, StageName = OPPORTUNITY_STAGE_PROSPECTING)
        };

        SBQQ__Quote__c newQuote1 = (SBQQ__Quote__c) new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id, mockQuoteId1)
            .setField(SBQQ__Quote__c.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(SBQQ__Quote__c.SBQQ__Opportunity2__c, opportunityIdToStage[0].Id)
            .setField(SBQQ__Quote__c.SBQQ__Status__c, QUOTE_STATUS_OUT_FOR_SIGNATURE)
            .toSObject();

        SBQQ__Quote__c newQuote2 = (SBQQ__Quote__c) new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id, mockQuoteId2)
            .setField(SBQQ__Quote__c.Segment__c, ACCOUNT_SEGMENT_ENTERPRISE)
            .setField(SBQQ__Quote__c.Opportunity_Deal_Type__c, DEAL_TYPE_SELF_SERVE)
            .setField(SBQQ__Quote__c.Opportunity_Sub_Type__c, SUB_TYPE_ADS_AND_PROMO)
            .setField(SBQQ__Quote__c.SBQQ__Opportunity2__c, opportunityIdToStage[1].Id)
            .setField(SBQQ__Quote__c.SBQQ__Status__c, QUOTE_STATUS_OUT_FOR_SIGNATURE)
            .toSObject();

        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        quotes.add(newQuote1);
        quotes.add(newQuote2);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunitiesService mockOpportunitiesService = (IOpportunitiesService) mocks.mock(
            IOpportunitiesService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IOpportunitiesService.class, mockOpportunitiesService);
        IQuotes quotesInstance = new Quotes(quotes);
        quotesInstance.updateOpportunityStageByQuoteStatus(new Map<Id, SObject>(quotes));
        ((IOpportunitiesService) mocks.verify(mockOpportunitiesService, 1))
            .updateOpportunityStageByQuoteStatus(
                new Map<Id, String>{
                    mockOpportunityId1 => OPPORTUNITY_STAGE_CONTRACTING,
                    mockOpportunityId2 => OPPORTUNITY_STAGE_CONTRACTING
                }
            );
    }

    /**
     * @description To validate when Quote's status changed to 'Contract Signed' then associated Opportunity's status changed to 'Closed Won'.
     * @JIRA# LEM-14174
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenQuoteStatusContractSignedThenOpportunityStageChangedToClosedWon() {
        Id mockQuoteId1 = Fake.generateId(SBQQ__Quote__c.class);
        Id mockQuoteId2 = Fake.generateId(SBQQ__Quote__c.class);
        Id mockOpportunityId1 = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id mockOpportunityId2 = fflib_IDGenerator.generate(Opportunity.SObjectType);

        List<Opportunity> opportunityIdToStage = new List<Opportunity>{
            new Opportunity(Id = mockOpportunityId1, StageName = OPPORTUNITY_STAGE_PROSPECTING),
            new Opportunity(Id = mockOpportunityId2, StageName = OPPORTUNITY_STAGE_PROSPECTING)
        };

        SBQQ__Quote__c newQuote1 = (SBQQ__Quote__c) new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id, mockQuoteId1)
            .setField(SBQQ__Quote__c.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(SBQQ__Quote__c.SBQQ__Opportunity2__c, opportunityIdToStage[0].Id)
            .setField(SBQQ__Quote__c.SBQQ__Status__c, QUOTE_STATUS_CONTRACT_SIGNED)
            .toSObject();
        SBQQ__Quote__c newQuote2 = (SBQQ__Quote__c) new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id, mockQuoteId2)
            .setField(SBQQ__Quote__c.Segment__c, ACCOUNT_SEGMENT_ENTERPRISE)
            .setField(SBQQ__Quote__c.Opportunity_Deal_Type__c, DEAL_TYPE_SELF_SERVE)
            .setField(SBQQ__Quote__c.Opportunity_Sub_Type__c, SUB_TYPE_ADS_AND_PROMO)
            .setField(SBQQ__Quote__c.SBQQ__Opportunity2__c, opportunityIdToStage[1].Id)
            .setField(SBQQ__Quote__c.SBQQ__Status__c, QUOTE_STATUS_CONTRACT_SIGNED)
            .toSObject();

        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        quotes.add(newQuote1);
        quotes.add(newQuote2);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunitiesService mockOpportunitiesService = (IOpportunitiesService) mocks.mock(
            IOpportunitiesService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IOpportunitiesService.class, mockOpportunitiesService);
        IQuotes quotesInstance = new Quotes(quotes);
        quotesInstance.updateOpportunityStageByQuoteStatus(new Map<Id, SObject>(quotes));
        ((IOpportunitiesService) mocks.verify(mockOpportunitiesService, 1))
            .updateOpportunityStageByQuoteStatus(
                new Map<Id, String>{
                    mockOpportunityId1 => OPPORTUNITY_STAGE_CLOSED_WON,
                    mockOpportunityId2 => OPPORTUNITY_STAGE_CLOSED_WON
                }
            );
    }

    /**
     * @description To validate when Quote's status changed to 'Approved' then associated Opportunity's status is not changed.
     * @JIRA# LEM-14174
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenQuoteStatusApprovedThenOpportunityStageNotChanged() {
        Id mockQuoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id mockOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);

        List<Opportunity> opportunityIdToStage = new List<Opportunity>{
            new Opportunity(Id = mockOpportunityId, StageName = OPPORTUNITY_STAGE_PROSPECTING)
        };

        SBQQ__Quote__c newQuote = (SBQQ__Quote__c) new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id, mockQuoteId)
            .setField(SBQQ__Quote__c.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(SBQQ__Quote__c.SBQQ__Opportunity2__c, opportunityIdToStage[0].Id)
            .setField(SBQQ__Quote__c.SBQQ__Status__c, QUOTE_STATUS_APPROVED)
            .toSObject();

        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        quotes.add(newQuote);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunitiesService mockOpportunitiesService = (IOpportunitiesService) mocks.mock(
            IOpportunitiesService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IOpportunitiesService.class, mockOpportunitiesService);
        IQuotes quotesInstance = new Quotes(quotes);
        quotesInstance.updateOpportunityStageByQuoteStatus(new Map<Id, SObject>(quotes));
        ((IOpportunitiesService) mocks.verify(mockOpportunitiesService, 0))
            .updateOpportunityStageByQuoteStatus(new Map<Id, String>{});
    }
    /**
     * @description To validate when Quote's status changed to 'Draft' from 'Out for Signature' then associated Opportunity's status is changed to 'Negotiating'.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenQuoteStatusChangedToDraftThenOpportunityStageChangedToNegotiating() {
        Id mockQuoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id mockOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        List<Opportunity> opportunityIdToStage = new List<Opportunity>{
            new Opportunity(Id = mockOpportunityId, StageName = OPPORTUNITY_STAGE_CONTRACTING)
        };
        SBQQ__Quote__c oldQuote = (SBQQ__Quote__c) new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id, mockQuoteId)
            .setField(SBQQ__Quote__c.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(SBQQ__Quote__c.SBQQ__Opportunity2__c, opportunityIdToStage[0].Id)
            .setField(SBQQ__Quote__c.SBQQ__Status__c, QUOTE_STATUS_OUT_FOR_SIGNATURE)
            .toSObject();

        SBQQ__Quote__c newQuote = (SBQQ__Quote__c) new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id, mockQuoteId)
            .setField(SBQQ__Quote__c.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(SBQQ__Quote__c.ApprovalStatus__c, QUOTE_STATUS_APPROVED)
            .setField(SBQQ__Quote__c.SBQQ__Opportunity2__c, opportunityIdToStage[0].Id)
            .setField(SBQQ__Quote__c.SBQQ__Status__c, QUOTE_STATUS_DRAFT)
            .toSObject();

        List<SBQQ__Quote__c> newQuotes = new List<SBQQ__Quote__c>();
        newQuotes.add(newQuote);
        List<SBQQ__Quote__c> oldQuotes = new List<SBQQ__Quote__c>();
        oldQuotes.add(oldQuote);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunitiesService mockOpportunitiesService = (IOpportunitiesService) mocks.mock(
            IOpportunitiesService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IOpportunitiesService.class, mockOpportunitiesService);
        Test.startTest();
        Quotes.newInstance(newQuotes)
            .updateOpportunityStageByQuoteStatus(new Map<Id, SObject>(oldQuotes));
        Test.stopTest();
        ((IOpportunitiesService) mocks.verify(mockOpportunitiesService, 1))
            .updateOpportunityStageByQuoteStatus(
                new Map<Id, String>{ mockOpportunityId => OPPORTUNITY_STAGE_NEGOTIATING }
            );
    }

    /**
     * @description To test Brief Item creation is initiated when the Quote has an associated Brief
     * and the Quote Line does not have a Brief Item.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenContractOnQuoteInReviewThenBriefItemsCreatedForQuoteLinesWithExistingBrief() {
        Id accountId = Fake.generateId(Account.class);
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        SBQQ__Quote__c parentQuote = (SBQQ__Quote__c) new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id, quoteId)
            .setField(SBQQ__Quote__c.SBQQ__Status__c, 'In Review')
            .setChildren(
                'Quote_Brief_Relationships__r',
                new List<Fake>{
                    new Fake(Quote_Brief_Relationship__c.class)
                        .setFakeId()
                        .setField(Quote_Brief_Relationship__c.Campaign_of_Brief__c, 'Campaign')
                        .setParent(
                            'Brief__r',
                            new Fake(Brief__c.class).setField(Brief__c.CampaignName__c, 'Campaign')
                        )
                }
            )
            .setChildren(
                'SBQQ__LineItems__r',
                new List<Fake>{
                    new Fake(SBQQ__QuoteLine__c.class)
                        .setFakeId()
                        .setField(SBQQ__QuoteLine__c.Campaign_Name__c, 'Campaign')
                        .setField(SBQQ__QuoteLine__c.Has_Brief_Item__c, false)
                        .setField(SBQQ__QuoteLine__c.SBQQ__Quote__c, quoteId)
                }
            )
            .toSObject();

        Map<String, Quote_Brief_Relationship__c> keyToQuoteBriefRelationship = new Map<String, Quote_Brief_Relationship__c>();
        keyToQuoteBriefRelationship.put(
            'Campaign - ' + accountId,
            parentQuote.Quote_Brief_Relationships__r[0]
        );
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        quotes.add(parentQuote);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBriefsService mockBriefsService = (IBriefsService) mocks.mock(IBriefsService.class);
        IBriefItemsService mockBriefItemsService = (IBriefItemsService) mocks.mock(
            IBriefItemsService.class
        );
        IQuotesSelector quotesSelector = (IQuotesSelector) mocks.mock(IQuotesSelector.class);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Quotes quotesInstance = new Quotes(quotes);
        mocks.startStubbing();
        mocks.when(quotesSelector.sObjectType()).thenReturn(SBQQ__Quote__c.SObjectType);
        mocks.when(
                quotesSelector.selectQuotesWithQuoteLineAndQuoteBriefRelationships(
                    new Set<Id>{ quoteId }
                )
            )
            .thenReturn(quotes);
        mocks.when(
                mockBriefItemsService.getCampaignQuoteRelationshipMappings(
                    parentQuote.Quote_Brief_Relationships__r
                )
            )
            .thenReturn(keyToQuoteBriefRelationship);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IBriefsService.class, mockBriefsService);
        Application.SERVICE.setMock(IBriefItemsService.class, mockBriefItemsService);
        Application.SELECTOR.setMock(quotesSelector);
        quotesInstance.initiateBriefsWithItemsGeneration();
        ((IBriefsService) mocks.verify(mockBriefsService, 1))
            .generateBriefsByQuoteLineItems(new List<SBQQ__QuoteLine__c>{});
        ((IBriefItemsService) mocks.verify(mockBriefItemsService, 0))
            .generateBriefItemsByQuoteLineItems(
                new List<SBQQ__QuoteLine__c>{ quotes[0].SBQQ__LineItems__r },
                new List<Quote_Brief_Relationship__c>{ quotes[0].Quote_Brief_Relationships__r }
            );
    }

    /**
     * @description To test if Brief and Brief Item creation is initiated when a quote does not
     * have an associated Brief for a new Campaign on the Quote Line Item.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenContractOnQuoteInReviewThenBriefItemsAndBriefItemsCreatedForQuoteLinesWithNewCampaign() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        SBQQ__Quote__c parentQuote = (SBQQ__Quote__c) new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id, quoteId)
            .setField(SBQQ__Quote__c.SBQQ__Status__c, 'In Review')
            .setChildren(
                'Quote_Brief_Relationships__r',
                new List<Fake>{
                    new Fake(Quote_Brief_Relationship__c.class)
                        .setFakeId()
                        .setField(
                            Quote_Brief_Relationship__c.Campaign_of_Brief__c,
                            'Campaign Existing'
                        )
                        .setParent(
                            'Brief__r',
                            new Fake(Brief__c.class)
                                .setField(Brief__c.CampaignName__c, 'Campaign Existing')
                        )
                }
            )
            .setChildren(
                'SBQQ__LineItems__r',
                new List<Fake>{
                    new Fake(SBQQ__QuoteLine__c.class)
                        .setFakeId()
                        .setField(SBQQ__QuoteLine__c.Campaign_Name__c, 'Campaign')
                        .setField(SBQQ__QuoteLine__c.Has_Brief_Item__c, false)
                        .setField(SBQQ__QuoteLine__c.SBQQ__Quote__c, quoteId)
                }
            )
            .toSObject();

        Map<String, Quote_Brief_Relationship__c> keyToQuoteBriefRelationship = new Map<String, Quote_Brief_Relationship__c>();
        keyToQuoteBriefRelationship.put(
            'Campaign Existing - ' + quoteId,
            parentQuote.Quote_Brief_Relationships__r[0]
        );
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        quotes.add(parentQuote);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBriefsService mockBriefsService = (IBriefsService) mocks.mock(IBriefsService.class);
        IBriefItemsService mockBriefItemsService = (IBriefItemsService) mocks.mock(
            IBriefItemsService.class
        );
        IQuotesSelector quotesSelector = (IQuotesSelector) mocks.mock(IQuotesSelector.class);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Quotes quotesInstance = new Quotes(quotes);
        mocks.startStubbing();
        mocks.when(quotesSelector.sObjectType()).thenReturn(SBQQ__Quote__c.SObjectType);
        mocks.when(
                quotesSelector.selectQuotesWithQuoteLineAndQuoteBriefRelationships(
                    new Set<Id>{ quoteId }
                )
            )
            .thenReturn(quotes);
        mocks.when(
                mockBriefItemsService.getCampaignQuoteRelationshipMappings(
                    parentQuote.Quote_Brief_Relationships__r
                )
            )
            .thenReturn(keyToQuoteBriefRelationship);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IBriefsService.class, mockBriefsService);
        Application.SERVICE.setMock(IBriefItemsService.class, mockBriefItemsService);
        Application.SELECTOR.setMock(quotesSelector);
        quotesInstance.initiateBriefsWithItemsGeneration();
        ((IBriefsService) mocks.verify(mockBriefsService, 0))
            .generateBriefsByQuoteLineItems(
                new List<SBQQ__QuoteLine__c>{ quotes[0].SBQQ__LineItems__r }
            );
        ((IBriefItemsService) mocks.verify(mockBriefItemsService, 1))
            .generateBriefItemsByQuoteLineItems(
                new List<SBQQ__QuoteLine__c>{},
                new List<Quote_Brief_Relationship__c>{ quotes[0].Quote_Brief_Relationships__r }
            );
    }

    /**
     * @description Testing syncing payment terms with payment account.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenContractSignedThenSyncPaymentAccount() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id paymentAccountId = Fake.generateId(Payment_Account__c.class);
        Id accountPaymentAccountId = Fake.generateId(Account_Payment_Account_Relation__c.class);

        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>{
            new SBQQ__Quote__c(
                id = quoteId,
                Invoicing_Payment_Account__c = accountPaymentAccountId,
                SBQQ__Status__c = 'Contract Signed',
                SBQQ__PaymentTerms__c = PAYMENT_TERMS_NET_30
            )
        };
        List<Account_Payment_Account_Relation__c> accountPaymentAccountsList = new List<Account_Payment_Account_Relation__c>{
            (Account_Payment_Account_Relation__c) new Fake(
                    Account_Payment_Account_Relation__c.class
                )
                .setField(Account_Payment_Account_Relation__c.Id, accountPaymentAccountId)
                .setField(Account_Payment_Account_Relation__c.Payment_Account__c, paymentAccountId)
                .setField(
                    Account_Payment_Account_Relation__c.Payment_Terms__c,
                    PAYMENT_TERMS_NET_45
                )
                .toSObject()
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAccountPaymentAccountRelationsSelector selectorMock = (IAccountPaymentAccountRelationsSelector) mocks.mock(
            IAccountPaymentAccountRelationsSelector.class
        );
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType())
            .thenReturn(Account_Payment_Account_Relation__c.SObjectType);
        mocks.when(selectorMock.selectById(new Set<Id>{ accountPaymentAccountId }))
            .thenReturn(accountPaymentAccountsList);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        IQuotes quotesInstance = Quotes.newInstance(quoteList);
        quotesInstance.syncPaymentTermsWithPaymentAccount();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                new Payment_Account__c(
                    id = paymentAccountId,
                    Payment_Terms__c = PAYMENT_TERMS_NET_30
                )
            );
    }
    /**
     * @description LEM-2831 It is used to validate the Quote Line's required drawer field are filled or not.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenValidateThenReturnQuoteLineDrawerField() {
        Id mockQuoteId = Fake.generateId(SBQQ__Quote__c.class);
        List<SBQQ__Quote__c> mockQuotes = new List<SBQQ__Quote__c>{
            new SBQQ__Quote__c(Id = mockQuoteId, SBQQ__Status__c = 'Contract Signed')
        };

        List<SBQQ__QuoteLine__c> mockQuoteLines = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c mockQuoteLine = (SBQQ__QuoteLine__c) new Fake(SBQQ__QuoteLine__c.class)
            .setFakeId()
            .setField(SBQQ__QuoteLine__c.SBQQ__ProductCode__c, '10011')
            .setField(SBQQ__QuoteLine__c.SBQQ__Quote__c, mockQuoteId)
            .setField(SBQQ__QuoteLine__c.Marketing_Only_Commission__c, 10)
            .setField(SBQQ__QuoteLine__c.Budget__c, null)
            .toSObject();
        mockQuoteLines.add(mockQuoteLine);
        SBQQ__QuoteLine__c mockQuoteLineDifferentCode = (SBQQ__QuoteLine__c) new Fake(
                SBQQ__QuoteLine__c.class
            )
            .setFakeId()
            .setField(SBQQ__QuoteLine__c.SBQQ__ProductCode__c, '10004')
            .setField(SBQQ__QuoteLine__c.SBQQ__Quote__c, mockQuoteId)
            .setField(SBQQ__QuoteLine__c.Marketing_Only_Commission__c, 10)
            .setField(SBQQ__QuoteLine__c.Budget__c, null)
            .toSObject();
        mockQuoteLines.add(mockQuoteLineDifferentCode);

        Quote_Line_Drawer_Products__mdt drawerProductAttribute = new Quote_Line_Drawer_Products__mdt(
            Product_Code__c = mockQuoteLine.SBQQ__ProductCode__c,
            Is_Active__c = true
        );
        Quote_Line_Drawer_Products__mdt drawerProductAttributeDifferentCode = new Quote_Line_Drawer_Products__mdt(
            Product_Code__c = mockQuoteLineDifferentCode.SBQQ__ProductCode__c,
            Is_Active__c = true
        );
        List<Quote_Line_Drawer_Attributes__mdt> attributes = new List<Quote_Line_Drawer_Attributes__mdt>();
        attributes.add(
            new Quote_Line_Drawer_Attributes__mdt(
                Field_API_Name__c = 'Marketing_Only_Commission__c',
                Applicable_Segment__c = ACCOUNT_SEGMENT_ENTERPRISE,
                Required_for_Segment__c = ACCOUNT_SEGMENT_ALL,
                Quote_Line_Drawer_Products__r = drawerProductAttribute
            )
        );
        attributes.add(
            new Quote_Line_Drawer_Attributes__mdt(
                Field_API_Name__c = 'Budget__c',
                Applicable_Segment__c = ACCOUNT_SEGMENT_ENTERPRISE,
                Required_for_Segment__c = ACCOUNT_SEGMENT_ALL,
                Quote_Line_Drawer_Products__r = drawerProductAttributeDifferentCode
            )
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IQuoteLineItemsSelector selectorMock = (IQuoteLineItemsSelector) mocks.mock(
            IQuoteLineItemsSelector.class
        );
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(SBQQ__QuoteLine__c.SObjectType);
        mocks.when(selectorMock.selectDrawerFieldByQuotes(new Set<Id>{ mockQuotes[0].Id }))
            .thenReturn(mockQuoteLines);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        IQuotes quotesInstance = Quotes.newInstance(mockQuotes);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        quotesInstance.validateQuoteLineDrawerField();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description LEM-2831 It is used to validate the Quote Line's required drawer field are filled or not.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenValidateThenReturnQuoteLineDrawerFieldSelfServe() {
        Id quoteId = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType);
        Id oppId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        List<Opportunity> opportunityList = new List<Opportunity>{
            new Opportunity(Id = oppId, Deal_Type__c = 'Self-Serve', Name = 'test1')
        };
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>{
            (SBQQ__Quote__c) new Fake(SBQQ__Quote__c.class)
                .setFakeId()
                .setField(SBQQ__Quote__c.SBQQ__Status__c, 'Contract Signed')
                .setField(SBQQ__Quote__c.SBQQ__Opportunity2__c, opportunityList[0].Id)
                .setField(SBQQ__Quote__c.Self_Serve_Status__c, SELF_SERVE_ACTIVATED)
                .setField(SBQQ__Quote__c.Opportunity_Deal_Type__c, 'Self-Serve')
                .toSObject()
        };

        List<SBQQ__QuoteLine__c> quotelines = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c quoteLineFake = (SBQQ__QuoteLine__c) new Fake(SBQQ__QuoteLine__c.class)
            .setFakeId()
            .setField(SBQQ__QuoteLine__c.SBQQ__ProductCode__c, '10009')
            .setField(SBQQ__QuoteLine__c.SBQQ__Quote__c, quoteList[0].Id)
            .setParent(
                'SBQQ__Quote__r',
                new Fake(SBQQ__Quote__c.class)
                    .setField(SBQQ__Quote__c.Id, quoteId)
                    .setField(SBQQ__Quote__c.SBQQ__Status__c, 'Contract Signed')
                    .setField(SBQQ__Quote__c.SBQQ__Opportunity2__c, opportunityList[0].Id)
                    .setField(SBQQ__Quote__c.Self_Serve_Status__c, SELF_SERVE_ACTIVATED)
                    .setField(SBQQ__Quote__c.Opportunity_Deal_Type__c, 'Self-Serve')
            )
            .toSObject();
        quotelines.add(quoteLineFake);
        SBQQ__QuoteLine__c quoteLineFake2 = (SBQQ__QuoteLine__c) new Fake(SBQQ__QuoteLine__c.class)
            .setFakeId()
            .setField(SBQQ__QuoteLine__c.SBQQ__ProductCode__c, '10006')
            .setField(SBQQ__QuoteLine__c.SBQQ__Quote__c, quoteList[0].Id)
            .setParent(
                'SBQQ__Quote__r',
                new Fake(SBQQ__Quote__c.class)
                    .setField(SBQQ__Quote__c.Id, quoteId)
                    .setField(SBQQ__Quote__c.SBQQ__Status__c, 'Contract Signed')
                    .setField(SBQQ__Quote__c.SBQQ__Opportunity2__c, opportunityList[0].Id)
                    .setField(SBQQ__Quote__c.Self_Serve_Status__c, SELF_SERVE_ACTIVATED)
                    .setField(SBQQ__Quote__c.Opportunity_Deal_Type__c, 'Self-Serve')
            )
            .toSObject();
        quotelines.add(quoteLineFake2);
        SBQQ__QuoteLine__c quoteLineFake3 = (SBQQ__QuoteLine__c) new Fake(SBQQ__QuoteLine__c.class)
            .setFakeId()
            .setField(SBQQ__QuoteLine__c.SBQQ__ProductCode__c, '10038')
            .setField(SBQQ__QuoteLine__c.Package__c, 'Sponsorships')
            .setField(SBQQ__QuoteLine__c.SBQQ__Quote__c, quoteList[0].Id)
            .setParent(
                'SBQQ__Quote__r',
                new Fake(SBQQ__Quote__c.class)
                    .setField(SBQQ__Quote__c.Id, quoteId)
                    .setField(SBQQ__Quote__c.SBQQ__Status__c, 'Contract Signed')
                    .setField(SBQQ__Quote__c.SBQQ__Opportunity2__c, opportunityList[0].Id)
                    .setField(SBQQ__Quote__c.Self_Serve_Status__c, SELF_SERVE_ACTIVATED)
                    .setField(SBQQ__Quote__c.Opportunity_Deal_Type__c, 'Self-Serve')
            )
            .toSObject();
        quotelines.add(quoteLineFake3);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IQuoteLineItemsSelector selectorMock = (IQuoteLineItemsSelector) mocks.mock(
            IQuoteLineItemsSelector.class
        );
        IOpportunitiesSelector opportunityMock = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );
        IQuotesSelector quotesSelectorMock = (IQuotesSelector) mocks.mock(IQuotesSelector.class);
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(SBQQ__QuoteLine__c.SObjectType);
        mocks.when(quotesSelectorMock.SObjectType()).thenReturn(SBQQ__Quote__c.SObjectType);
        mocks.when(quotesSelectorMock.selectById(new Set<Id>{ quoteList[0].Id }))
            .thenReturn(quoteList);
        mocks.when(selectorMock.selectDrawerFieldByQuotes(new Set<Id>{ quoteList[0].Id }))
            .thenReturn(quotelines);
        mocks.when(opportunityMock.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(opportunityMock.selectById(new Set<Id>{ opportunityList[0].Id }))
            .thenReturn(opportunityList);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(selectorMock);
        Application.Selector.setMock(opportunityMock);
        Application.Selector.setMock(quotesSelectorMock);
        IQuotes quotesInstance = Quotes.newInstance(quoteList);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        quotesInstance.validateQuoteLineDrawerField();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description To test Breif and Brief Item creation when Sponsorships package is added.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenSponsorshipsisAddedWithOptionsThenBriefAndBriefItemsCreated() {
        Id accountId = Fake.generateId(Account.class);
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        SBQQ__Quote__c parentQuote = (SBQQ__Quote__c) new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id, quoteId)
            .setField(SBQQ__Quote__c.SBQQ__Status__c, 'In Review')
            .setChildren(
                'Quote_Brief_Relationships__r',
                new List<Fake>{
                    new Fake(Quote_Brief_Relationship__c.class)
                        .setFakeId()
                        .setField(
                            Quote_Brief_Relationship__c.Campaign_of_Brief__c,
                            'Sponsorships Campaign'
                        )
                        .setParent(
                            'Brief__r',
                            new Fake(Brief__c.class)
                                .setField(Brief__c.CampaignName__c, 'Sponsorships Campaign')
                        )
                }
            )
            .setChildren(
                'SBQQ__LineItems__r',
                new List<Fake>{
                    new Fake(SBQQ__QuoteLine__c.class)
                        .setFakeId()
                        .setField(SBQQ__QuoteLine__c.Campaign_Name__c, 'Sponsorships Campaign')
                        .setField(SBQQ__QuoteLine__c.Has_Brief_Item__c, false)
                        .setField(SBQQ__QuoteLine__c.SBQQ__Quote__c, quoteId)
                        .setField(SBQQ__QuoteLine__c.SBQQ__ProductName__c, SPONSORSHIPS),
                    new Fake(SBQQ__QuoteLine__c.class)
                        .setFakeId()
                        .setField(SBQQ__QuoteLine__c.Campaign_Name__c, '')
                        .setField(SBQQ__QuoteLine__c.Has_Brief_Item__c, false)
                        .setField(SBQQ__QuoteLine__c.SBQQ__Quote__c, quoteId)
                        .setField(SBQQ__QuoteLine__c.Package__c, SPONSORSHIPS)
                        .setParent(
                            'SBQQ__RequiredBy__r',
                            new Fake(SBQQ__QuoteLine__c.class)
                                .setField(
                                    SBQQ__QuoteLine__c.SBQQ__RequiredBy__r.Campaign_Name__c,
                                    'Sponsorships Campaign'
                                )
                        )
                }
            )
            .toSObject();
        Map<String, Quote_Brief_Relationship__c> keyToQuoteBriefRelationship = new Map<String, Quote_Brief_Relationship__c>();
        keyToQuoteBriefRelationship.put(
            'Campaign - ' + accountId,
            parentQuote.Quote_Brief_Relationships__r[0]
        );
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        quotes.add(parentQuote);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBriefsService mockBriefsService = (IBriefsService) mocks.mock(IBriefsService.class);
        IBriefItemsService mockBriefItemsService = (IBriefItemsService) mocks.mock(
            IBriefItemsService.class
        );
        IQuotesSelector quotesSelector = (IQuotesSelector) mocks.mock(IQuotesSelector.class);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Quotes quotesInstance = new Quotes(quotes);
        mocks.startStubbing();
        mocks.when(quotesSelector.sObjectType()).thenReturn(SBQQ__Quote__c.SObjectType);
        mocks.when(
                quotesSelector.selectQuotesWithQuoteLineAndQuoteBriefRelationships(
                    new Set<Id>{ quoteId }
                )
            )
            .thenReturn(quotes);
        mocks.when(
                mockBriefItemsService.getCampaignQuoteRelationshipMappings(
                    parentQuote.Quote_Brief_Relationships__r
                )
            )
            .thenReturn(keyToQuoteBriefRelationship);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IBriefsService.class, mockBriefsService);
        Application.SERVICE.setMock(IBriefItemsService.class, mockBriefItemsService);
        Application.SELECTOR.setMock(quotesSelector);
        quotesInstance.initiateBriefsWithItemsGeneration();
        ((IBriefsService) mocks.verify(mockBriefsService, 0))
            .generateBriefsByQuoteLineItems(
                new List<SBQQ__QuoteLine__c>{ quotes[0].SBQQ__LineItems__r[1] }
            );
    } /**
     *@description To check for standalone pipeline product and update the hasPipelineProduct field on the quote object
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenQuoteHasOnlyPipelineProductThenUpdateQuoteHasPipelineProduct() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id quoteId2 = Fake.generateId(SBQQ__Quote__c.class);
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>{
            new SBQQ__Quote__c(
                Id = quoteId,
                SBQQ__Status__c = 'Contract Signed',
                hasPipelineProduct__c = true
            ),
            new SBQQ__Quote__c(
                Id = quoteId2,
                SBQQ__Status__c = 'Contract Signed',
                hasPipelineProduct__c = false
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        IQuotes quotesInstance = Quotes.newInstance(quoteList);
        quotesInstance.generateOrders();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(fflib_Match.anySObject());
    }

    /**
     * @description To test updateMissingFieldsOnAmendmentQuotesFromOriginalQuotes Method
     */
    @isTest
    private static void testWhenAmendmentIsCreatedThenUpdateFieldsFromOriginalQuote() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id amendedQuoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id masterContractId = Fake.generateId(Contract.class);
        Id orderId = Fake.generateId(Order.class);

        List<SBQQ__Quote__c> amendedQuoteList = new List<SBQQ__Quote__c>{
            (SBQQ__Quote__c) new Fake(SBQQ__Quote__c.class)
                .setField(SBQQ__Quote__c.id, amendedQuoteId)
                .setField(SBQQ__Quote__c.SBQQ__MasterEvergreenContract__c, masterContractId)
                .setParent(
                    'SBQQ__MasterEvergreenContract__r',
                    new Fake(Contract.class)
                        .setField(Contract.id, masterContractId)
                        .setField(Contract.SBQQ__Order__c, orderId)
                        .setParent(
                            'SBQQ__Order__r',
                            new Fake(Order.class)
                                .setField(Order.id, orderId)
                                .setField(Order.SBQQ__Quote__c, quoteId)
                                .setParent(
                                    'SBQQ__Quote__r',
                                    new Fake(SBQQ__Quote__c.class)
                                        .setField(SBQQ__Quote__c.id, quoteId)
                                        .setField(SBQQ__Quote__c.Is_this_for_Ads_Promos__c, 'Yes')
                                )
                        )
                )
                .toSobject()
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IQuotesSelector selectorMock = (IQuotesSelector) mocks.mock(IQuotesSelector.class);
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(SBQQ__Quote__c.SObjectType);
        mocks.when(selectorMock.selectQuoteFieldsFromOriginalQuote(new Set<Id>{ amendedQuoteId }))
            .thenReturn(amendedQuoteList);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        IQuotes quotesInstance = Quotes.newInstance(amendedQuoteList);
        quotesInstance.updateMissingFieldsOnAmendmentQuotesFromOriginalQuotes();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        System.assertEquals(
            amendedQuoteList[0].Is_this_for_Ads_Promos__c,
            'Yes',
            'Is_this_for_Ads_Promos__c Field mismatch'
        );
    }
    /**
     * @description Check if the Users Approval Groups field populates on Quotes.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenQuoteCreatedThenUpdateApprovalGroups() {
        Id mockQuoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id groupUserId = fflib_IDGenerator.generate(User.SObjectType);
        Id quoteOwnerId = fflib_IDGenerator.generate(User.SObjectType);
        SBQQ__Quote__c mockQuote = (SBQQ__Quote__c) new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id, mockQuoteId)
            .setField(SBQQ__Quote__c.CreatedById, quoteOwnerId)
            .setField(SBQQ__Quote__c.Users_Manager_Id__c, groupUserId)
            .toSObject();
        Id mockGroupID = Fake.generateId(GroupMember.class);
        GroupMember mockGroupMember = (GroupMember) new Fake(GroupMember.class)
            .setField(GroupMember.Id, Fake.generateId(GroupMember.class))
            .setField(GroupMember.UserOrGroupId, groupUserId)
            .setField(GroupMember.GroupId, mockGroupID)
            .setParent(
                'Group',
                new Fake(Group.class)
                    .setField(Group.Id, mockGroupID)
                    .setField(Group.Name, SPONSORSHIPS)
                    .setField(Group.DeveloperName, SPONSORSHIPS)
            )
            .toSObject();
        GroupMember mockGroupMemberSecond = (GroupMember) new Fake(GroupMember.class)
            .setField(GroupMember.Id, Fake.generateId(GroupMember.class))
            .setField(GroupMember.UserOrGroupId, groupUserId)
            .setField(GroupMember.GroupId, mockGroupID)
            .setParent(
                'Group',
                new Fake(Group.class)
                    .setField(Group.Id, mockGroupID)
                    .setField(Group.Name, SPONSORSHIPS)
                    .setField(Group.DeveloperName, SPONSORSHIPS)
            )
            .toSObject();
        Approval_Group__mdt mockApprovalGroup = (Approval_Group__mdt) new Fake(
                Approval_Group__mdt.class
            )
            .setField(Approval_Group__mdt.Label, SPONSORSHIPS)
            .setField(Approval_Group__mdt.DeveloperName, SPONSORSHIPS)
            .toSObject();
        List<SBQQ__Quote__c> mockQuoteList = new List<SBQQ__Quote__c>{ mockQuote };
        List<GroupMember> mockGroupMemberList = new List<GroupMember>{
            mockGroupMember,
            mockGroupMemberSecond
        };
        List<Approval_Group__mdt> mockApprovalGroupsList = new List<Approval_Group__mdt>{
            mockApprovalGroup
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IApprovalGroupsSelector selectorApprovalMock = (IApprovalGroupsSelector) mocks.mock(
            ApprovalGroupsSelector.class
        );
        IGroupMembersSelector selectorGroupMemberMock = (IGroupMembersSelector) mocks.mock(
            GroupMembersSelector.class
        );
        mocks.startStubbing();
        mocks.when(selectorGroupMemberMock.sObjectType()).thenReturn(GroupMember.SObjectType);
        mocks.when(
                selectorGroupMemberMock.selectGroupMembersByGroupNamesAndUserIds(
                    new List<String>{ SPONSORSHIPS },
                    new Set<Id>{ groupUserId }
                )
            )
            .thenReturn(mockGroupMemberList);
        mocks.when(selectorApprovalMock.sObjectType()).thenReturn(Approval_Group__mdt.SObjectType);
        mocks.when(selectorApprovalMock.selectApprovalGroups()).thenReturn(mockApprovalGroupsList);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorGroupMemberMock);
        Application.SELECTOR.setMock(selectorApprovalMock);
        IQuotes quotesInstance = Quotes.newInstance(mockQuoteList);
        Test.StartTest();
        quotesInstance.populateAssignedGroupsNameOnQuotes();
        Test.StopTest();
        System.assertEquals(SPONSORSHIPS, mockQuoteList[0].Users_Approval_Group__c, ASSERT_MESSAGE);
    }
    /**
     * @description Verify if Users Approval Groups field on Quotes is empty.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenNegativeConditionQuotesInsertedThenDoNotUpdateApprovalGroups() {
        Id mockQuoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id groupUserId = fflib_IDGenerator.generate(User.SObjectType);
        Id quoteOwnerId = fflib_IDGenerator.generate(User.SObjectType);
        SBQQ__Quote__c mockQuote = (SBQQ__Quote__c) new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id, mockQuoteId)
            .setField(SBQQ__Quote__c.CreatedById, quoteOwnerId)
            .setField(SBQQ__Quote__c.Users_Manager_Id__c, groupUserId)
            .toSObject();
        List<SBQQ__Quote__c> mockQuoteList = new List<SBQQ__Quote__c>{ mockQuote };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IApprovalGroupsSelector selectorApprovalMock = (IApprovalGroupsSelector) mocks.mock(
            ApprovalGroupsSelector.class
        );
        IGroupMembersSelector selectorGroupMemberMock = (IGroupMembersSelector) mocks.mock(
            GroupMembersSelector.class
        );
        mocks.startStubbing();
        mocks.when(selectorGroupMemberMock.sObjectType()).thenReturn(GroupMember.SObjectType);
        mocks.when(
                selectorGroupMemberMock.selectGroupMembersByGroupNamesAndUserIds(
                    new List<String>{ QUOTE_STATUS_APPROVED },
                    new Set<Id>()
                )
            )
            .thenReturn(new List<GroupMember>{});
        mocks.when(selectorApprovalMock.sObjectType()).thenReturn(Approval_Group__mdt.SObjectType);
        mocks.when(selectorApprovalMock.selectApprovalGroups())
            .thenReturn(new List<Approval_Group__mdt>{});
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorGroupMemberMock);
        Application.SELECTOR.setMock(selectorApprovalMock);
        IQuotes quotesInstance = Quotes.newInstance(mockQuoteList);
        Test.StartTest();
        quotesInstance.populateAssignedGroupsNameOnQuotes();
        Test.StopTest();
        Map<Id, SBQQ__Quote__c> quoteBeforeUpdatingApprovalGroup = new Map<Id, SBQQ__Quote__c>(
            mockQuoteList
        );
        System.assertEquals(
            null,
            quoteBeforeUpdatingApprovalGroup.get(mockQuoteId).Users_Approval_Group__c,
            ASSERT_MESSAGE
        );
    }

    /**
     * @description To test 'Out For Signature Date' field update on Quote whenever a
     * Quote status is changed to "Out For Signature".
     */
    @isTest
    private static void testWhenQuoteStatusOutForSignatureThenUpdateOutForSignatureDate() {
        Id quoteOFSId = Fake.generateId(SBQQ__Quote__c.class);

        SBQQ__Quote__c quoteOFS = new SBQQ__Quote__c(
            Id = quoteOFSId,
            SBQQ__Status__c = QUOTE_STATUS_OUT_FOR_SIGNATURE
        );

        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        quoteList.add(quoteOFS);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);

        Map<Id, SObject> existingRecords = new Map<Id, SObject>();
        existingRecords.put(
            quoteOFS.id,
            new SBQQ__Quote__c(Id = quoteOFSId, SBQQ__Status__c = QUOTE_STATUS_APPROVED)
        );

        IQuotes quotesInstance = Quotes.newInstance(quoteList);
        quotesInstance.updateQuoteOutForSignatureDate(existingRecords);
        System.assertEquals(
            System.today(),
            quoteList[0].Out_For_Signature_Date__c,
            ASSERT_MESSAGE_MISMATCH_IN_OUT_FOR_SIGNATURE_DATE
        );
    }

    /*
     * @description To test that Briefs are not generated when the Segment is 'SMB' on Quote.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenSMBQuoteCreatedThenDoNotGenerateBriefs() {
        Id mockQuoteId = Fake.generateId(SBQQ__Quote__c.class);
        SBQQ__Quote__c newQuote = (SBQQ__Quote__c) new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id, mockQuoteId)
            .setField(SBQQ__Quote__c.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(SBQQ__Quote__c.ApprovalStatus__c, QUOTE_STATUS_APPROVED)
            .toSObject();
        List<SBQQ__Quote__c> checkQuote = new List<SBQQ__Quote__c>();
        checkQuote.add(newQuote);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBriefsService mockBriefsService = (IBriefsService) mocks.mock(IBriefsService.class);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IBriefsService.class, mockBriefsService);
        IQuotes quotesInstance = Quotes.newInstance(checkQuote);
        Test.StartTest();
        quotesInstance.initiateBriefsWithItemsGeneration();
        Test.StopTest();
        ((IBriefsService) mocks.verify(mockBriefsService, 0))
            .generateBriefsByQuoteLineItems(new List<SBQQ__QuoteLine__c>{});
    }

    /**
     * @description Verify if Users Managers field on Quotes is empty then do not updte approval groups on Quote.
     */
    private static void testWhenQuoteOwnerIdIsPassedThenDoNotTriggerApprovals() {
        Id mockQuoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id quoteOwnerId = fflib_IDGenerator.generate(User.SObjectType);
        SBQQ__Quote__c mockQuote = (SBQQ__Quote__c) new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id, mockQuoteId)
            .setField(SBQQ__Quote__c.CreatedById, quoteOwnerId)
            .toSObject();
        List<SBQQ__Quote__c> mockQuoteList = new List<SBQQ__Quote__c>{ mockQuote };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IApprovalGroupsSelector selectorApprovalMock = (IApprovalGroupsSelector) mocks.mock(
            ApprovalGroupsSelector.class
        );
        IGroupMembersSelector selectorGroupMemberMock = (IGroupMembersSelector) mocks.mock(
            GroupMembersSelector.class
        );
        mocks.startStubbing();
        mocks.when(selectorGroupMemberMock.sObjectType()).thenReturn(GroupMember.SObjectType);
        mocks.when(
                selectorGroupMemberMock.selectGroupMembersByGroupNamesAndUserIds(
                    new List<String>{ QUOTE_STATUS_APPROVED },
                    new Set<Id>()
                )
            )
            .thenReturn(new List<GroupMember>{});
        mocks.when(selectorApprovalMock.sObjectType()).thenReturn(Approval_Group__mdt.SObjectType);
        mocks.when(selectorApprovalMock.selectApprovalGroups())
            .thenReturn(new List<Approval_Group__mdt>{});
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorGroupMemberMock);
        Application.SELECTOR.setMock(selectorApprovalMock);

        IQuotes quotesInstance = Quotes.newInstance(mockQuoteList);
        Test.StartTest();
        quotesInstance.populateAssignedGroupsNameOnQuotes();
        Test.StopTest();
        Map<Id, SBQQ__Quote__c> quoteBeforeUpdatingApprovalGroup = new Map<Id, SBQQ__Quote__c>(
            mockQuoteList
        );
        System.assertEquals(
            null,
            quoteBeforeUpdatingApprovalGroup.get(mockQuoteId).Users_Approval_Group__c,
            ASSERT_MESSAGE
        );
    }
    /**
     * @description To verify if the Amendment quote designated for ads and promotions is correctly labeled as an ads and promos quote.
     */
    @isTest
    private static void testWhenAdsAndPromosAmendmentQuoteCreatedThenUpdateAdsPromosFlagOnQuote() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id amendedQuoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id masterContractId = Fake.generateId(Contract.class);
        Id orderId = Fake.generateId(Order.class);

        List<SBQQ__Quote__c> amendedQuoteList = new List<SBQQ__Quote__c>{
            (SBQQ__Quote__c) new Fake(SBQQ__Quote__c.class)
                .setField(SBQQ__Quote__c.id, amendedQuoteId)
                .setField(SBQQ__Quote__c.SBQQ__MasterEvergreenContract__c, masterContractId)
                .setParent(
                    'SBQQ__MasterEvergreenContract__r',
                    new Fake(Contract.class)
                        .setField(Contract.id, masterContractId)
                        .setField(Contract.SBQQ__Order__c, orderId)
                        .setField(Contract.SBQQ__Order__c, orderId)
                        .setField(
                            Contract.Contract_Split_Category__c,
                            CONTRACT_SPLIT_CATEGORY_ADS_PROMOS
                        )
                        .setParent(
                            'SBQQ__Order__r',
                            new Fake(Order.class)
                                .setField(Order.id, orderId)
                                .setField(Order.SBQQ__Quote__c, quoteId)
                                .setParent(
                                    'SBQQ__Quote__r',
                                    new Fake(SBQQ__Quote__c.class)
                                        .setField(SBQQ__Quote__c.id, quoteId)
                                        .setField(
                                            SBQQ__Quote__c.Is_this_for_Ads_Promos__c,
                                            ADS_PROMOS_NO_VALUE
                                        )
                                )
                        )
                )
                .toSobject()
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IQuotesSelector selectorMock = (IQuotesSelector) mocks.mock(IQuotesSelector.class);
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(SBQQ__Quote__c.SObjectType);
        mocks.when(selectorMock.selectQuoteFieldsFromOriginalQuote(new Set<Id>{ amendedQuoteId }))
            .thenReturn(amendedQuoteList);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        Quotes.newInstance(amendedQuoteList)
            .updateMissingFieldsOnAmendmentQuotesFromOriginalQuotes();
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        System.assertEquals(
            ADS_PROMOS_YES_VALUE,
            amendedQuoteList[0].Is_this_for_Ads_Promos__c,
            ASSERT_MESSAGE
        );
    }
    /**
     * @description checks if the Quote is eligible and stamps RESSMO_Eligible__c false.
     * @JIRA# LEM-16422
     */
    @isTest
    private static void testWhenQuoteStatusApprovedThenRessmoEligibilityCheckedFalse() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>{
            new SBQQ__Quote__c(Id = quoteId, SBQQ__Status__c = QUOTE_STATUS_APPROVED)
        };
        IQuotes quotesInstance = Quotes.newInstance(quoteList);
        Test.StartTest();
        quotesInstance.populateRESSMOEligibleOnQuoteStatusIsApproved();
        Test.StopTest();
        Assert.areEqual(false, quoteList[0].RESSMO_Eligible__c, 'Not Eligibile for RESSMO');
    }
    /**
     * @description checks if the Quote is eligible and stamps RESSMO_Eligible__c true.
     * @JIRA# LEM-16422
     */
    @isTest
    private static void testWhenQuoteStatusApprovedThenRessmoEligibilityCheckedTrue() {
        List<RESSMO_Mapping__mdt> ressmoMappings = new List<RESSMO_Mapping__mdt>{
            new RESSMO_Mapping__mdt(
                Object_Name__c = RESSMOServiceImpl.BUSINESS_ACCOUNT_OBJECT,
                Field_Name__c = 'Name',
                JSON_Object__c = 'BusinessAccountJSON',
                API_Property__c = 'businessProperty',
                Add_to_Request__c = true,
                Data_Type__c = 'Text'
            )
        };
        Id accountId = Fake.generateId(Account.class);
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        List<SBQQ__Quote__c> listofQuotes = new List<SBQQ__Quote__c>();
        SBQQ__Quote__c quote = (SBQQ__Quote__c) new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id, quoteId)
            .setField(SBQQ__Quote__c.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(SBQQ__Quote__c.SBQQ__Status__c, QUOTE_STATUS_APPROVED)
            .setField(SBQQ__Quote__c.RESSMO_Store_Account_Id__c, accountId)
            .toSObject();
        listofQuotes.add(quote);
        Map<String, Set<String>> sobjectToSetOfField = new Map<String, Set<String>>{
            RESSMOServiceImpl.BUSINESS_ACCOUNT_OBJECT => new Set<String>{ 'Name' }
        };
        Map<String, sObject> ddmxObjectToSobject = new Map<String, sObject>();
        ddmxObjectToSobject.put('SBQQ__Quote__c', quote);
        List<SBQQ__QuoteLine__c> quoteLineItems = new List<SBQQ__QuoteLine__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IRESSMOService mockRESSMOService = (IRESSMOService) mocks.mock(IRESSMOService.class);
        IRessmoMappingsSelector ressmoMappingsSelectorMock = (IRessmoMappingsSelector) mocks.mock(
            IRessmoMappingsSelector.class
        );

        mocks.startStubbing();

        mocks.when(ressmoMappingsSelectorMock.SObjectType())
            .thenReturn(RESSMO_Mapping__mdt.SObjectType);
        mocks.when(ressmoMappingsSelectorMock.selectAllRessmoMappings()).thenReturn(ressmoMappings);

        mocks.when(mockRESSMOService.getMapOfSobjectAndSetOfField(ressmoMappings))
            .thenReturn(sobjectToSetOfField);
        mocks.when(
                mockRESSMOService.getQuotesAndQuoteLinesWithFieldsFromMetaData(
                    new Set<Id>{ quoteId },
                    sobjectToSetOfField
                )
            )
            .thenReturn(listofQuotes);

        mocks.when(
                mockRESSMOService.quoteEligibilityMessagesForRESSMO(
                    ressmoMappings,
                    ddmxObjectToSobject,
                    quoteLineItems
                )
            )
            .thenReturn(new Map<String, List<String>>());
        mocks.when(mockRESSMOService.storeEligibilityMessagesForRESSMO(ddmxObjectToSobject))
            .thenReturn(new Map<String, List<String>>());
        mocks.stopStubbing();

        Application.SELECTOR.setMock(ressmoMappingsSelectorMock);
        Application.SERVICE.setMock(IRESSMOService.class, mockRESSMOService);
        IQuotes quotesInstance = Quotes.newInstance(listofQuotes);
        Test.StartTest();
        quotesInstance.populateRESSMOEligibleOnQuoteStatusIsApproved();
        Test.StopTest();
        Assert.areEqual(true, listofQuotes[0].RESSMO_Eligible__c, 'Eligibile for RESSMO');
    }

    /**
     * @description To test Brief Item creation is not initiated when the Quote has
     * an associated Brief and the Quote Line does not have a Brief Item on 'SMB' Contract.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenSMBContractOnQuoteInReviewThenDoNotCreateBriefItemsForQuoteLinesWithExistingBrief() {
        Id accountId = Fake.generateId(Account.class);
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        SBQQ__Quote__c parentQuote = (SBQQ__Quote__c) new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id, quoteId)
            .setField(SBQQ__Quote__c.SBQQ__Status__c, 'In Review')
            .setField(SBQQ__Quote__c.Segment__c, SEGMENT_SMB)
            .setChildren(
                'Quote_Brief_Relationships__r',
                new List<Fake>{
                    new Fake(Quote_Brief_Relationship__c.class)
                        .setFakeId()
                        .setField(Quote_Brief_Relationship__c.Campaign_of_Brief__c, 'Campaign')
                        .setParent(
                            'Brief__r',
                            new Fake(Brief__c.class).setField(Brief__c.CampaignName__c, 'Campaign')
                        )
                }
            )
            .setChildren(
                'SBQQ__LineItems__r',
                new List<Fake>{
                    new Fake(SBQQ__QuoteLine__c.class)
                        .setFakeId()
                        .setField(SBQQ__QuoteLine__c.Campaign_Name__c, 'Campaign')
                        .setField(SBQQ__QuoteLine__c.Has_Brief_Item__c, false)
                        .setField(SBQQ__QuoteLine__c.SBQQ__Quote__c, quoteId)
                }
            )
            .toSObject();

        Map<String, Quote_Brief_Relationship__c> keyToQuoteBriefRelationship = new Map<String, Quote_Brief_Relationship__c>();
        keyToQuoteBriefRelationship.put(
            'Campaign - ' + accountId,
            parentQuote.Quote_Brief_Relationships__r[0]
        );
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        quotes.add(parentQuote);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBriefsService mockBriefsService = (IBriefsService) mocks.mock(IBriefsService.class);
        IBriefItemsService mockBriefItemsService = (IBriefItemsService) mocks.mock(
            IBriefItemsService.class
        );
        IQuotesSelector quotesSelector = (IQuotesSelector) mocks.mock(IQuotesSelector.class);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Quotes quotesInstance = new Quotes(quotes);
        mocks.startStubbing();
        mocks.when(quotesSelector.sObjectType()).thenReturn(SBQQ__Quote__c.SObjectType);
        mocks.when(
                quotesSelector.selectQuotesWithQuoteLineAndQuoteBriefRelationships(
                    new Set<Id>{ quoteId }
                )
            )
            .thenReturn(quotes);
        mocks.when(
                mockBriefItemsService.getCampaignQuoteRelationshipMappings(
                    parentQuote.Quote_Brief_Relationships__r
                )
            )
            .thenReturn(keyToQuoteBriefRelationship);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IBriefsService.class, mockBriefsService);
        Application.SERVICE.setMock(IBriefItemsService.class, mockBriefItemsService);
        Application.SELECTOR.setMock(quotesSelector);
        quotesInstance.initiateBriefsWithItemsGeneration();
        ((IBriefsService) mocks.verify(mockBriefsService, 1))
            .generateBriefsByQuoteLineItems(new List<SBQQ__QuoteLine__c>{});
    }

    /**
     * @description To test Alcohol Eligibility for amendment quotes when there are existing active
     * alcohol related subscription present on business account.
     */
    @IsTest
    private static void testWhenCreatingQuoteForExistingOpportunityThenVerifyAlcoholEligibility() {
        Id accountId = Fake.generateId(Account.class);
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>{
            new SBQQ__Quote__c(SBQQ__Type__c = 'Amendment', SBQQ__Account__c = accountId)
        };
        SBQQ__Subscription__c alcoholSubscription = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, Fake.generateId(SBQQ__Subscription__c.class))
            .setField(SBQQ__Subscription__c.SBQQ__Account__c, accountId)
            .setParent(
                'SBQQ__Product__r',
                new Fake(Product2.class)
                    .setField(Product2.Id, Fake.generateId(Product2.class))
                    .setField(Product2.Name, ALCOHOL_PRODUCT)
            )
            .setField(SBQQ__Subscription__c.SBQQ__TerminatedDate__c, null)
            .setField(SBQQ__Subscription__c.SBQQ__SubscriptionEndDate__c, null)
            .toSObject();
        List<SBQQ__Subscription__c> subscriptionList = new List<SBQQ__Subscription__c>{
            alcoholSubscription
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ISubscriptionSelector selectorMock = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(selectorMock.selectAlcoholSubscriptionByAccount(new Set<Id>{ accountId }))
            .thenReturn(subscriptionList);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        IQuotes quotesInstance = Quotes.newInstance(quoteList);
        quotesInstance.VerifyAlcoholEligibilityForExistingOpportunity();
        System.assertEquals(
            true,
            quoteList[0].Is_Alcohol_Delivery_Pickup_Exists__c,
            INVALID_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test Alcohol Eligibility for amendment quotes when there are no existing active
     * alcohol related subscription present on business account.
     */
    @IsTest
    private static void testWhenCreatingQuoteForExistingOpportunityThenVerifyAlcoholEligibilityNegativity() {
        Id accountId = Fake.generateId(Account.class);
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>{
            new SBQQ__Quote__c(SBQQ__Type__c = 'Amendment', SBQQ__Account__c = accountId)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ISubscriptionSelector selectorMock = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(selectorMock.selectAlcoholSubscriptionByAccount(new Set<Id>{ accountId }))
            .thenReturn(new List<SBQQ__Subscription__c>());
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        IQuotes quotesInstance = Quotes.newInstance(quoteList);
        quotesInstance.VerifyAlcoholEligibilityForExistingOpportunity();
        System.assertEquals(
            false,
            quoteList[0].Is_Alcohol_Delivery_Pickup_Exists__c,
            INVALID_ASSERT_MESSAGE
        );
    }

    /**
     * @description Used to test validations enforced for ANZ user related to Unique Term fields.
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenUpdatingANZQuotesUniqueTermFieldsThenThrowValidations() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        SBQQ__Quote__c quoteRecord = (SBQQ__Quote__c) new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id, quoteId)
            .setField(SBQQ__Quote__c.Applicable_to_all_Locations__c, true)
            .setField(SBQQ__Quote__c.Segment__c, SEGMENT_SMB)
            .setField(SBQQ__Quote__c.Account_Billing_Country_Code__c, 'AU')
            .toSObject();
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>{ quoteRecord };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IQuotes quotesInstance = Quotes.newInstance(quoteList);
        quotesInstance.validateIfUniqueTermFieldsWereUpdated();
        ((IQuotes) mocks.verify(quotesInstance, 1)).validateIfUniqueTermFieldsWereUpdated();
    }

    /**
     * @description It is used to test whether the dynamic approver creation is invoked or not when
     * 'Contracting Flow' is updated to "Redlining".
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenContractingFlowUpdatedToRedliningThenDynamicApproverCreationInvoked() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id usersManagerId = Fake.generateId(User.class);
        SBQQ__Quote__c quote = (SBQQ__Quote__c) new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id, quoteId)
            .setField(SBQQ__Quote__c.Contracting_Flow__c, REDLINING)
            .setField(SBQQ__Quote__c.Users_Manager_Id__c, usersManagerId)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IApproversService mockApproversService = (IApproversService) mocks.mock(
            IApproversService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IApproversService.class, mockApproversService);
        Test.startTest();
        Quotes.newInstance(new List<SBQQ__Quote__c>{ quote })
            .initiateRedliningApproversCreationByManagerId();
        Test.stopTest();
        ((IApproversService) mocks.verify(mockApproversService, 1))
            .createApproversByUserIds(new Set<Id>{ usersManagerId });
    }

    /**
     * @description It is used to test that dynamic approver creation is not invoked when
     * 'Contracting Flow' is updated to "Templatized e-sign".
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenContractingFlowUpdatedToTemplatizedESignThenDynamicApproverCreationNotInvoked() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id usersManagerId = Fake.generateId(User.class);
        SBQQ__Quote__c quote = (SBQQ__Quote__c) new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id, quoteId)
            .setField(SBQQ__Quote__c.Contracting_Flow__c, TEMPLATIZED_E_SIGN)
            .setField(SBQQ__Quote__c.Users_Manager_Id__c, usersManagerId)
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IApproversService mockApproversService = (IApproversService) mocks.mock(
            IApproversService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IApproversService.class, mockApproversService);
        Test.startTest();
        Quotes.newInstance(new List<SBQQ__Quote__c>{ quote })
            .initiateRedliningApproversCreationByManagerId();
        Test.stopTest();
        ((IApproversService) mocks.verify(mockApproversService, 0))
            .createApproversByUserIds(new Set<Id>{ usersManagerId });
    }

    /**
     * @description To test if Briefs and Brief Items creation is not initiated when the Quote is
     * Approved and Opportunity Deal type is Self Serve.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenApprovedThenBriefsAndItemAreNotCreatedForSelfServe() {
        Id accountId = Fake.generateId(Account.class);
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id quoteLineId = Fake.generateId(SBQQ__QuoteLine__c.class);
        Id opptyId = Fake.generateId(Opportunity.class);
        Id briefId = Fake.generateId(Brief__c.class);

        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>{
            (SBQQ__Quote__c) new Fake(SBQQ__Quote__c.class)
                .setField(SBQQ__Quote__c.id, quoteId)
                .setField(SBQQ__Quote__c.SBQQ__Status__c, 'Approved')
                .setField(SBQQ__Quote__c.SBQQ__Opportunity2__c, opptyId)
                .setField(SBQQ__Quote__c.SBQQ__Account__c, accountId)
                .toSobject()
        };

        Fake opportunityFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opptyId)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, 'Test Opportunity')
            .setField(Opportunity.AccountId, accountId)
            .setField(Opportunity.StageName, 'Prospecting')
            .setField(Opportunity.Type, 'New')
            .setField(Opportunity.Deal_Type__c, 'Self-Serve');

        Fake quoteFakeInstance = new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id, quoteId)
            .setField(SBQQ__Quote__c.SBQQ__Primary__c, 'true')
            .setParent('SBQQ__Opportunity2__r', opportunityFakeInstance);

        List<SBQQ__QuoteLine__c> quoteLineItemList = new List<SBQQ__QuoteLine__c>{
            (SBQQ__QuoteLine__c) new Fake(SBQQ__QuoteLine__c.class)
                .setField(SBQQ__QuoteLine__c.id, quoteLineId)
                .setField(SBQQ__QuoteLine__c.Requested_Commission__c, 5)
                .setField(SBQQ__QuoteLine__c.SBQQ__SpecialPrice__c, 2)
                .setField(SBQQ__QuoteLine__c.Active_Commission__c, 4)
                .setField(SBQQ__QuoteLine__c.Active_Fee__c, 1)
                .setParent('SBQQ__Quote__r', quoteFakeInstance)
                .toSobject()
        };

        Map<Id, SBQQ__QuoteLine__c> quoteLineMap = new Map<Id, SBQQ__QuoteLine__c>();
        quoteLineMap.put(quoteLineId, quoteLineItemList[0]);

        List<Brief__c> briefList = new List<Brief__c>{
            new Brief__c(
                Id = briefId,
                Account__c = accountId,
                Is_Created_By_System__c = true,
                CampaignName__c = 'Campaign Name',
                Additional_Notes__c = 'Additional Notes',
                Opportunity_Name__c = opptyId,
                Netsuite_ID__c = 'NetSuite ID',
                Applicable_DoorDash_Order_Types__c = 'Delivery',
                Configuration__c = 'Standard (Launch Ops)'
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IQuoteLineItemsSelector selectorMock = (IQuoteLineItemsSelector) mocks.mock(
            IQuoteLineItemsSelector.class
        );
        IQuotesSelector quotesSelector = (IQuotesSelector) mocks.mock(IQuotesSelector.class);
        IBriefsService mockBriefsService = (IBriefsService) mocks.mock(IBriefsService.class);
        IBriefsSelector mockBriefSelector = (IBriefsSelector) mocks.mock(IBriefsSelector.class);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(SBQQ__QuoteLine__c.SObjectType);
        mocks.when(selectorMock.selectQuoteLinesWithUpgradedSubscriptions(new Set<Id>{ quoteId }))
            .thenReturn(quoteLineMap);
        mocks.when(quotesSelector.sObjectType()).thenReturn(SBQQ__Quote__c.SObjectType);
        mocks.when(
                quotesSelector.selectQuotesWithQuoteLineAndQuoteBriefRelationships(
                    new Set<Id>{ quoteId }
                )
            )
            .thenReturn(quoteList);
        mocks.when(mockBriefSelector.sObjectType()).thenReturn(Brief__c.SObjectType);
        mocks.when(mockBriefSelector.selectByAccountIds(new Set<Id>{ accountId }))
            .thenReturn(briefList);
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IBriefsService.class, mockBriefsService);
        Application.SELECTOR.setMock(selectorMock);
        Application.SELECTOR.setMock(quotesSelector);
        Application.SELECTOR.setMock(mockBriefSelector);
        IQuotes quotesInstance = Quotes.newInstance(quoteList);
        quotesInstance.initiateBriefsWithItemsGeneration();
        ((IBriefsService) mocks.verify(mockBriefsService, 1))
            .generateBriefsByQuoteLineItems(new List<SBQQ__QuoteLine__c>{});
        ((IQuoteLineItemsSelector) mocks.verify(selectorMock, 1))
            .selectQuoteLinesWithUpgradedSubscriptions(new Set<Id>{ quoteId });
    }

    /**
     * @description To test if Briefs and Brief Items creation is initiated when the Quote is
     * Approved and Opportunity Deal type is not Self Serve.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenApprovedThenBriefsAndItemAreCreatedForNotSelfServe() {
        Id accountId = Fake.generateId(Account.class);
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id quoteLineId = Fake.generateId(SBQQ__QuoteLine__c.class);
        Id opptyId = Fake.generateId(Opportunity.class);
        Id briefId = Fake.generateId(Brief__c.class);

        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>{
            (SBQQ__Quote__c) new Fake(SBQQ__Quote__c.class)
                .setField(SBQQ__Quote__c.id, quoteId)
                .setField(SBQQ__Quote__c.SBQQ__Status__c, 'Approved')
                .setField(SBQQ__Quote__c.SBQQ__Opportunity2__c, opptyId)
                .setField(SBQQ__Quote__c.SBQQ__Account__c, accountId)
                .toSobject()
        };

        Fake opportunityFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opptyId)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, 'Test Opportunity')
            .setField(Opportunity.AccountId, accountId)
            .setField(Opportunity.StageName, 'Prospecting')
            .setField(Opportunity.Type, 'New')
            .setField(Opportunity.Deal_Type__c, 'Standard');

        Fake quoteFakeInstance = new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id, quoteId)
            .setField(SBQQ__Quote__c.SBQQ__Primary__c, 'true')
            .setParent('SBQQ__Opportunity2__r', opportunityFakeInstance);

        List<SBQQ__QuoteLine__c> quoteLineItemList = new List<SBQQ__QuoteLine__c>{
            (SBQQ__QuoteLine__c) new Fake(SBQQ__QuoteLine__c.class)
                .setField(SBQQ__QuoteLine__c.id, quoteLineId)
                .setField(SBQQ__QuoteLine__c.Requested_Commission__c, 5)
                .setField(SBQQ__QuoteLine__c.SBQQ__SpecialPrice__c, 2)
                .setField(SBQQ__QuoteLine__c.Active_Commission__c, 4)
                .setField(SBQQ__QuoteLine__c.Active_Fee__c, 1)
                .setParent('SBQQ__Quote__r', quoteFakeInstance)
                .toSobject()
        };

        Map<Id, SBQQ__QuoteLine__c> quoteLineMap = new Map<Id, SBQQ__QuoteLine__c>();
        quoteLineMap.put(quoteLineId, quoteLineItemList[0]);

        List<Brief__c> briefList = new List<Brief__c>{
            new Brief__c(
                Id = briefId,
                Account__c = accountId,
                Is_Created_By_System__c = true,
                CampaignName__c = 'Campaign Name',
                Additional_Notes__c = 'Additional Notes',
                Opportunity_Name__c = opptyId,
                Netsuite_ID__c = 'NetSuite ID',
                Applicable_DoorDash_Order_Types__c = 'Delivery',
                Configuration__c = 'Standard (Launch Ops)'
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IQuoteLineItemsSelector selectorMock = (IQuoteLineItemsSelector) mocks.mock(
            IQuoteLineItemsSelector.class
        );
        IQuotesSelector quotesSelector = (IQuotesSelector) mocks.mock(IQuotesSelector.class);
        IBriefsService mockBriefsService = (IBriefsService) mocks.mock(IBriefsService.class);
        IBriefsSelector mockBriefSelector = (IBriefsSelector) mocks.mock(IBriefsSelector.class);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(SBQQ__QuoteLine__c.SObjectType);
        mocks.when(selectorMock.selectQuoteLinesWithUpgradedSubscriptions(new Set<Id>{ quoteId }))
            .thenReturn(quoteLineMap);
        mocks.when(quotesSelector.sObjectType()).thenReturn(SBQQ__Quote__c.SObjectType);
        mocks.when(
                quotesSelector.selectQuotesWithQuoteLineAndQuoteBriefRelationships(
                    new Set<Id>{ quoteId }
                )
            )
            .thenReturn(quoteList);
        mocks.when(mockBriefSelector.sObjectType()).thenReturn(Brief__c.SObjectType);
        mocks.when(mockBriefSelector.selectByAccountIds(new Set<Id>{ accountId }))
            .thenReturn(briefList);
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IBriefsService.class, mockBriefsService);
        Application.SELECTOR.setMock(selectorMock);
        Application.SELECTOR.setMock(quotesSelector);
        Application.SELECTOR.setMock(mockBriefSelector);
        IQuotes quotesInstance = Quotes.newInstance(quoteList);
        quotesInstance.initiateBriefsWithItemsGeneration();
        ((IBriefsService) mocks.verify(mockBriefsService, 0))
            .generateBriefsByQuoteLineItems(new List<SBQQ__QuoteLine__c>{});
        ((IQuoteLineItemsSelector) mocks.verify(selectorMock, 1))
            .selectQuoteLinesWithUpgradedSubscriptions(new Set<Id>{ quoteId });
    }
    
    @isTest
    private static void testWhenQuoteUpdatedToIronCladWorkflowTrueThenBlankUUID(){
        Opportunity opportunity = (Opportunity)new Fake(Opportunity.class)
            .setField(Opportunity.RESSMO_Link__c,'Test.com')
            .setFakeId()
            .tosObject();

        SBQQ__Quote__c quote = (SBQQ__Quote__c)new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Unique_Identifier__c,'1234')
            .setField(SBQQ__Quote__c.Ironclad_WF_Launched__c,true)
            .setField(SBQQ__Quote__c.SBQQ__Opportunity2__c,opportunity.Id)
            .setFakeId()
            .tosObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunitiesSelector mockSelector = (IOpportunitiesSelector)mocks.mock(IOpportunitiesSelector.class);

        mocks.startStubbing();
            mocks.when(mockSelector.sObjectType()).thenReturn(Schema.Opportunity.sObjectType);
            mocks.when(mockSelector.selectById(new Set<Id>{opportunity.Id})).thenReturn(new List<Opportunity>{opportunity});
        mocks.stopStubbing();

        APPLICATION.SELECTOR.setMock(mockSelector);

        Test.StartTest();
            Quotes.newInstance(new List<SBQQ__Quote__c>{quote}).blankUniqueIdentifier();
        Test.stopTest();

        Assert.areEqual('',quote.Unique_Identifier__c,'Quote UUID should be blank when Ironclad Workflow is true');
    }

    @isTest
    private static void testWhenQuoteUpdatedToIronCladWorkflowFalseThenDontBlankUUID(){
        Opportunity opportunity = (Opportunity)new Fake(Opportunity.class)
            .setField(Opportunity.RESSMO_Link__c,'Test.com')
            .setFakeId()
            .tosObject();

        SBQQ__Quote__c quote = (SBQQ__Quote__c)new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Unique_Identifier__c,'1234')
            .setField(SBQQ__Quote__c.Ironclad_WF_Launched__c,false)
            .setField(SBQQ__Quote__c.SBQQ__Opportunity2__c,opportunity.Id)
            .setFakeId()
            .tosObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunitiesSelector mockSelector = (IOpportunitiesSelector)mocks.mock(IOpportunitiesSelector.class);

        mocks.startStubbing();
            mocks.when(mockSelector.sObjectType()).thenReturn(Schema.Opportunity.sObjectType);
            mocks.when(mockSelector.selectById(new Set<Id>{opportunity.Id})).thenReturn(new List<Opportunity>{opportunity});
        mocks.stopStubbing();

        APPLICATION.SELECTOR.setMock(mockSelector);

        Test.StartTest();
            Quotes.newInstance(new List<SBQQ__Quote__c>{quote}).blankUniqueIdentifier();
        Test.stopTest();

        Assert.areEqual('1234',quote.Unique_Identifier__c,'Quote UUID should be blank when Ironclad Workflow is true');
    }

    @isTest
    private static void testWhenQuoteUpdatedToIronCladWorkflowTrueAndOppRESSMOBlankThenDontBlankUUID(){
        Opportunity opportunity = (Opportunity)new Fake(Opportunity.class)
            .setField(Opportunity.RESSMO_Link__c,null)
            .setFakeId()
            .tosObject();

        SBQQ__Quote__c quote = (SBQQ__Quote__c)new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Unique_Identifier__c,'1234')
            .setField(SBQQ__Quote__c.Ironclad_WF_Launched__c,true)
            .setField(SBQQ__Quote__c.SBQQ__Opportunity2__c,opportunity.Id)
            .setFakeId()
            .tosObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunitiesSelector mockSelector = (IOpportunitiesSelector)mocks.mock(IOpportunitiesSelector.class);

        mocks.startStubbing();
            mocks.when(mockSelector.sObjectType()).thenReturn(Schema.Opportunity.sObjectType);
            mocks.when(mockSelector.selectById(new Set<Id>{opportunity.Id})).thenReturn(new List<Opportunity>{opportunity});
        mocks.stopStubbing();

        APPLICATION.SELECTOR.setMock(mockSelector);

        Test.StartTest();
            Quotes.newInstance(new List<SBQQ__Quote__c>{quote}).blankUniqueIdentifier();
        Test.stopTest();

        Assert.areEqual('1234',quote.Unique_Identifier__c,'Quote UUID should be blank when Ironclad Workflow is true');
    }
}