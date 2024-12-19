/**
 * @description This is test class for Orders Trigger handler class
 * @author ATG
 * @date 2022-04-07
 */
@isTest(seeAllData=false)
public class QuotesHandlerTest {
    private static final String DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE = 'Unexpected result: Record are not present in database';
    private static final String QUOTE_STATUS_APPROVED = 'Approved';
    private static final String QUOTE_STATUS_OUT_FOR_SIGNATURE = 'Out for Signature';
    private static final String APPROVAL_GROUP = 'Core East';
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    private static final Integer LINE_COUNT = 2;
    private static final String OPPORTUNITY_TYPE = 'Existing';
    private static final String REDLINING = 'Redlining';
    private static final String TEMPLATIZED_E_SIGN = 'Templatized e-sign';
    /**
     * @description To test method call on Quote update
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenQuoteStatusUpdatedToContractSignedThenCallGenerateOrders() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);

        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>{
            new SBQQ__Quote__c(Id = quoteId, SBQQ__Status__c = QuotesHandler.CONTRACT_SIGNED)
        };

        List<SBQQ__Quote__c> oldquoteList = new List<SBQQ__Quote__c>{
            new SBQQ__Quote__c(Id = quoteId, SBQQ__Status__c = 'Out for Signature')
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IQuotes quotesMock = (IQuotes) mocks.mock(IQuotes.class);
        mocks.startStubbing();
        mocks.when(quotesMock.getType()).thenReturn(Schema.SBQQ__Quote__c.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(quotesMock);

        fflib_SObjectDomain.Test.Database.onUpdate(quoteList, new Map<Id, SObject>(oldquoteList));
        fflib_SObjectDomain.triggerHandler(QuotesHandler.class);

        ((IQuotes) mocks.verify(quotesMock, 1)).generateOrders();
    }

    /**
     * @description To test constructor only gets called with Status changed Quotes
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenQuoteOnlyStatusUpdatedThenCallConstructor() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id quoteId2 = Fake.generateId(SBQQ__Quote__c.class);

        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>{
            new SBQQ__Quote__c(Id = quoteId, SBQQ__Status__c = QuotesHandler.CONTRACT_SIGNED),
            new SBQQ__Quote__c(Id = quoteId2, SBQQ__Status__c = QuotesHandler.CONTRACT_SIGNED)
        };

        List<SBQQ__Quote__c> oldquoteList = new List<SBQQ__Quote__c>{
            new SBQQ__Quote__c(Id = quoteId, SBQQ__Status__c = 'Out for Signature'),
            new SBQQ__Quote__c(Id = quoteId2, SBQQ__Status__c = QuotesHandler.CONTRACT_SIGNED)
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_IDomainConstructor constructor = (fflib_IDomainConstructor) mocks.mock(
            fflib_IDomainConstructor.class
        );
        Quotes quotesMock = (Quotes) mocks.mock(Quotes.class);
        mocks.startStubbing();
        mocks.when(constructor.construct(fflib_Match.anyList())).thenReturn(quotesMock);
        mocks.when(quotesMock.getType()).thenReturn(Schema.SBQQ__Quote__c.SObjectType);
        mocks.stopStubbing();
        Quotes.setConstructorMock(constructor);

        fflib_SObjectDomain.Test.Database.onUpdate(quoteList, new Map<Id, SObject>(oldquoteList));
        fflib_SObjectDomain.triggerHandler(QuotesHandler.class);

        ((Quotes) mocks.verify(quotesMock, 1)).generateOrders();
    }
    /**
     * @description To test constructor only gets called with Ads and Promos Changed
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenQuoteAdsBudgetChangedThenCallQuoteHandler() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id quoteId2 = Fake.generateId(SBQQ__Quote__c.class);

        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>{
            new SBQQ__Quote__c(Id = quoteId, Ads_Promos_Budget_Sum__c = 90000),
            new SBQQ__Quote__c(Id = quoteId2, Ads_Promos_Budget_Sum__c = 100000)
        };

        List<SBQQ__Quote__c> oldquoteList = new List<SBQQ__Quote__c>{
            new SBQQ__Quote__c(Id = quoteId, Ads_Promos_Budget_Sum__c = 0),
            new SBQQ__Quote__c(Id = quoteId2, Ads_Promos_Budget_Sum__c = 100)
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_IDomainConstructor constructor = (fflib_IDomainConstructor) mocks.mock(
            fflib_IDomainConstructor.class
        );
        Quotes quotesMock = (Quotes) mocks.mock(Quotes.class);
        mocks.startStubbing();
        mocks.when(constructor.construct(fflib_Match.anyList())).thenReturn(quotesMock);
        mocks.when(quotesMock.getType()).thenReturn(Schema.SBQQ__Quote__c.SObjectType);
        mocks.stopStubbing();
        Quotes.setConstructorMock(constructor);

        fflib_SObjectDomain.Test.Database.onUpdate(quoteList, new Map<Id, SObject>(oldquoteList));
        fflib_SObjectDomain.triggerHandler(QuotesHandler.class);

        ((IQuotes) mocks.verify(quotesMock, 1)).populateDoorDashSignerOnQuote();
    }

    /**
     * @description To test constructor only gets called with Ads and Promos Changed
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenQuoteAdsBudgetChangedThenNoCallQuoteHandler() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id quoteId2 = Fake.generateId(SBQQ__Quote__c.class);

        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>{
            new SBQQ__Quote__c(Id = quoteId, Ads_Promos_Budget_Sum__c = 0),
            new SBQQ__Quote__c(Id = quoteId2, Ads_Promos_Budget_Sum__c = 100)
        };

        List<SBQQ__Quote__c> oldquoteList = new List<SBQQ__Quote__c>{
            new SBQQ__Quote__c(Id = quoteId, Ads_Promos_Budget_Sum__c = 0),
            new SBQQ__Quote__c(Id = quoteId2, Ads_Promos_Budget_Sum__c = 100)
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_IDomainConstructor constructor = (fflib_IDomainConstructor) mocks.mock(
            fflib_IDomainConstructor.class
        );
        Quotes quotesMock = (Quotes) mocks.mock(Quotes.class);
        mocks.startStubbing();
        mocks.when(constructor.construct(fflib_Match.anyList())).thenReturn(quotesMock);
        mocks.when(quotesMock.getType()).thenReturn(Schema.SBQQ__Quote__c.SObjectType);
        mocks.stopStubbing();
        Quotes.setConstructorMock(constructor);

        fflib_SObjectDomain.Test.Database.onUpdate(quoteList, new Map<Id, SObject>(oldquoteList));
        fflib_SObjectDomain.triggerHandler(QuotesHandler.class);

        ((IQuotes) mocks.verify(quotesMock, 1)).populateDoorDashSignerOnQuote();
    }

    /**
     * @description To test updateMissingFieldsOnAmendmentQuotesFromOriginalQuotes Method
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAmendmentIsCreatedThenUpdateFieldsFromOriginalQuote() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);

        List<SBQQ__Quote__c> amendedQuoteList = new List<SBQQ__Quote__c>{
            (SBQQ__Quote__c) new Fake(SBQQ__Quote__c.class)
                .setField(SBQQ__Quote__c.id, quoteId)
                .setField(SBQQ__Quote__c.SBQQ__Type__c, 'Amendment')
                .toSobject()
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IQuotes quotesMock = (IQuotes) mocks.mock(IQuotes.class);
        mocks.startStubbing();
        mocks.when(quotesMock.getType()).thenReturn(Schema.SBQQ__Quote__c.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(quotesMock);

        fflib_SObjectDomain.Test.Database.onInsert(amendedQuoteList);
        fflib_SObjectDomain.triggerHandler(QuotesHandler.class);
        ((IQuotes) mocks.verify(quotesMock, 1))
            .updateMissingFieldsOnAmendmentQuotesFromOriginalQuotes();
    }

    /**
     * @description To test populateQuotesWithoutGroups Method
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAmendedQuoteIsUpdatedThenCloneGroups() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id quoteId2 = Fake.generateId(SBQQ__Quote__c.class);

        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>{
            new SBQQ__Quote__c(
                Id = quoteId,
                SBQQ__Status__c = 'Draft',
                SBQQ__Type__c = 'Amendment'
            ),
            new SBQQ__Quote__c(Id = quoteId2, SBQQ__Status__c = 'In Review')
        };

        List<SBQQ__Quote__c> oldquoteList = new List<SBQQ__Quote__c>{
            new SBQQ__Quote__c(Id = quoteId, SBQQ__Status__c = 'Draft'),
            new SBQQ__Quote__c(Id = quoteId2, SBQQ__Status__c = 'Draft')
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IQuoteLineItemsService quoteLineServiceMock = (IQuoteLineItemsService) mocks.mock(
            IQuoteLineItemsService.class
        );

        Application.Service.setMock(IQuoteLineItemsService.class, quoteLineServiceMock);

        fflib_SObjectDomain.Test.Database.onUpdate(quoteList, new Map<Id, SObject>(oldquoteList));
        fflib_SObjectDomain.triggerHandler(QuotesHandler.class);

        ((IQuoteLineItemsService) mocks.verify(quoteLineServiceMock, 1))
            .insertMissingAmendmentLineGroups(
                new Map<Id, SBQQ__Quote__c>{ quoteId => quoteList[0] }
            );
    }

    /**
     * @description Used to check Users Approval Groups field is populating on Quotes.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenQuoteIsCreatedThenUpdateApprovalGroups() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        List<SBQQ__Quote__c> quoteListForApprovalGroups = new List<SBQQ__Quote__c>{
            (SBQQ__Quote__c) new Fake(SBQQ__Quote__c.class)
                .setField(SBQQ__Quote__c.id, quoteId)
                .setField(SBQQ__Quote__c.Users_Approval_Group__c, APPROVAL_GROUP)
                .setField(SBQQ__Quote__c.SBQQ__LineItemCount__c, LINE_COUNT)
                .toSobject()
        };
        List<SBQQ__Quote__c> quoteListForApprovalGroupsBeforeUpdate = new List<SBQQ__Quote__c>{
            (SBQQ__Quote__c) new Fake(SBQQ__Quote__c.class)
                .setField(SBQQ__Quote__c.id, quoteId)
                .toSobject()
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IQuotes quotesMock = (IQuotes) mocks.mock(IQuotes.class);
        mocks.startStubbing();
        mocks.when(quotesMock.getType()).thenReturn(Schema.SBQQ__Quote__c.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(quotesMock);

        fflib_SObjectDomain.Test.Database.onUpdate(
            quoteListForApprovalGroups,
            new Map<Id, SObject>(quoteListForApprovalGroupsBeforeUpdate)
        );

        fflib_SObjectDomain.triggerHandler(QuotesHandler.class);
        ((IQuotes) mocks.verify(quotesMock, 1)).populateAssignedGroupsNameOnQuotes();
    }

    /**
     * @description To test 'Out For Signature Date' field update on Quote whenever a
     * Quote status is changed to "Out For Signature".
     */
    @isTest
    private static void testWhenQuoteStatusUpdatedToOutForSignatureThenUpdateQuoteOutForSignatureDateCalled() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        SBQQ__Quote__c quote = new SBQQ__Quote__c(
            Id = quoteId,
            SBQQ__Status__c = QUOTE_STATUS_APPROVED
        );
        SBQQ__Quote__c updatedQuote = new SBQQ__Quote__c(
            Id = quoteId,
            SBQQ__Status__c = QUOTE_STATUS_OUT_FOR_SIGNATURE
        );

        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        quoteList.add(quote);
        quoteList.add(updatedQuote);
        Map<Id, SObject> existingRecords = new Map<Id, SObject>();
        existingRecords.put(quote.id, quote);

        Map<Id, SBQQ__Quote__c> oldQuotes = new Map<Id, SBQQ__Quote__c>();
        oldQuotes.put(quoteId, quote);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IQuotes quotesMock = (IQuotes) mocks.mock(IQuotes.class);
        mocks.startStubbing();
        mocks.when(quotesMock.getType()).thenReturn(Schema.SBQQ__Quote__c.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(quotesMock);
        fflib_SObjectDomain.Test.Database.onUpdate(quoteList, existingRecords);
        fflib_SObjectDomain.triggerHandler(QuotesHandler.class);
        ((IQuotes) mocks.verify(quotesMock, 1)).updateQuoteOutForSignatureDate(existingRecords);

        System.assertEquals(
            true,
            fflib_SObjectDomain.Test.Database.hasRecords(),
            DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE
        );
    }

    /**
     * @description It updates Stage on Opportunity to 'Contracting' or 'Closed Won' whenever a Quote's
     * 'Status' is changed to 'Out For Signature' and 'Contract Signed' respectively.
     * @JIRA# LEM-14174
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenQuoteStatusOutForSignatureThenOpportunityStageChanged() {
        Id mockQuoteStatusOutForSignatureId = Fake.generateId(SBQQ__Quote__c.class);

        List<SBQQ__Quote__c> newQuote = new List<SBQQ__Quote__c>{
            new SBQQ__Quote__c(
                Id = mockQuoteStatusOutForSignatureId,
                SBQQ__Status__c = QUOTE_STATUS_OUT_FOR_SIGNATURE
            )
        };

        List<SBQQ__Quote__c> oldQuote = new List<SBQQ__Quote__c>{
            new SBQQ__Quote__c(
                Id = mockQuoteStatusOutForSignatureId,
                ApprovalStatus__c = QUOTE_STATUS_APPROVED,
                SBQQ__Status__c = QUOTE_STATUS_APPROVED
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_IDomainConstructor constructor = (fflib_IDomainConstructor) mocks.mock(
            fflib_IDomainConstructor.class
        );
        Quotes quotesMock = (Quotes) mocks.mock(Quotes.class);
        mocks.startStubbing();
        mocks.when(constructor.construct(fflib_Match.anyList())).thenReturn(quotesMock);
        mocks.when(quotesMock.getType()).thenReturn(Schema.SBQQ__Quote__c.SObjectType);
        mocks.stopStubbing();
        Quotes.setConstructorMock(constructor);
        fflib_SObjectDomain.Test.Database.onUpdate(newQuote, new Map<Id, SObject>(oldQuote));
        fflib_SObjectDomain.triggerHandler(QuotesHandler.class);
        ((IQuotes) mocks.verify(quotesMock, 1))
            .updateOpportunityStageByQuoteStatus(new Map<Id, SObject>(oldQuote));
    }

    /**
     * @description To test updateActiveFeeActiveComissionOnQuotelines Method
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenQuoteIsApprovedThenUpdateActivePrices() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id quoteId2 = Fake.generateId(SBQQ__Quote__c.class);

        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>{
            new SBQQ__Quote__c(Id = quoteId, SBQQ__Status__c = 'Approved'),
            new SBQQ__Quote__c(Id = quoteId2, SBQQ__Status__c = 'In Review')
        };

        List<SBQQ__Quote__c> oldquoteList = new List<SBQQ__Quote__c>{
            new SBQQ__Quote__c(Id = quoteId, SBQQ__Status__c = 'Draft'),
            new SBQQ__Quote__c(Id = quoteId2, SBQQ__Status__c = 'Draft')
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IQuotes quotesMock = (IQuotes) mocks.mock(IQuotes.class);
        mocks.startStubbing();
        mocks.when(quotesMock.getType()).thenReturn(Schema.SBQQ__Quote__c.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(quotesMock);

        fflib_SObjectDomain.Test.Database.onUpdate(quoteList, new Map<Id, SObject>(oldquoteList));
        fflib_SObjectDomain.triggerHandler(QuotesHandler.class);

        ((IQuotes) mocks.verify(quotesMock, 1)).updateActiveFeeActiveComissionOnQuotelines();
    }

    /**
     * @description To test revertActiveFeeActiveComissionOnQuotelines Method is called
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenApprovalsRecalledThenRevertActivePrices() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id quoteId2 = Fake.generateId(SBQQ__Quote__c.class);

        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>{
            new SBQQ__Quote__c(Id = quoteId, SBQQ__Status__c = 'Draft'),
            new SBQQ__Quote__c(Id = quoteId2, SBQQ__Status__c = 'Draft')
        };

        List<SBQQ__Quote__c> oldquoteList = new List<SBQQ__Quote__c>{
            new SBQQ__Quote__c(Id = quoteId, SBQQ__Status__c = 'Approved'),
            new SBQQ__Quote__c(Id = quoteId2, SBQQ__Status__c = 'In Review')
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IQuotes quotesMock = (IQuotes) mocks.mock(IQuotes.class);
        mocks.startStubbing();
        mocks.when(quotesMock.getType()).thenReturn(Schema.SBQQ__Quote__c.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(quotesMock);

        fflib_SObjectDomain.Test.Database.onUpdate(quoteList, new Map<Id, SObject>(oldquoteList));
        fflib_SObjectDomain.triggerHandler(QuotesHandler.class);

        ((IQuotes) mocks.verify(quotesMock, 1)).revertActiveFeeActiveComissionOnQuotelines();
    }

    /**
     * @description To test VerifyAlcoholEligibilityForExistingOpportunity Method is called
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenCreatingQuoteForExistingOpportunityThenVerifyAlcoholEligibility() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>{
            (SBQQ__Quote__c) new Fake(SBQQ__Quote__c.class)
                .setField(SBQQ__Quote__c.id, quoteId)
                .setField(SBQQ__Quote__c.Opportunity_Type__c, OPPORTUNITY_TYPE)
                .toSobject()
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IQuotes quotesMock = (IQuotes) mocks.mock(IQuotes.class);
        mocks.startStubbing();
        mocks.when(quotesMock.getType()).thenReturn(Schema.SBQQ__Quote__c.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(quotesMock);
        fflib_SObjectDomain.Test.Database.onInsert(quoteList);
        fflib_SObjectDomain.triggerHandler(QuotesHandler.class);
        ((IQuotes) mocks.verify(quotesMock, 1)).VerifyAlcoholEligibilityForExistingOpportunity();
    }

    /**
     * @description It is used to test whether dynamic Approvers creation process is invoked or not
     * when 'Contracting Flow' is updated on Quote.
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenContractingFlowOnQuoteIsUpdatedThenDynamicApproverCreationInvoked() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        List<SBQQ__Quote__c> quoteWithRedlining = new List<SBQQ__Quote__c>{
            new SBQQ__Quote__c(Id = quoteId, SBQQ__Status__c = REDLINING)
        };
        List<SBQQ__Quote__c> oldquoteWithoutRedlining = new List<SBQQ__Quote__c>{
            new SBQQ__Quote__c(Id = quoteId, SBQQ__Status__c = TEMPLATIZED_E_SIGN)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IQuotes quotesMock = (IQuotes) mocks.mock(IQuotes.class);
        mocks.startStubbing();
        mocks.when(quotesMock.getType()).thenReturn(Schema.SBQQ__Quote__c.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(quotesMock);
        fflib_SObjectDomain.Test.Database.onUpdate(
            quoteWithRedlining,
            new Map<Id, SObject>(oldquoteWithoutRedlining)
        );
        fflib_SObjectDomain.triggerHandler(QuotesHandler.class);
        ((IQuotes) mocks.verify(quotesMock, 1)).initiateRedliningApproversCreationByManagerId();
    }

    /**
     * @description It is used to test whether dynamic Approvers creation process is invoked or not
     * when Quote is created with a default value of 'Contracting Flow' as "Redlining".
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenQuoteIsCreatedWithRedliningContractingFlowThenDynamicApproverCreationInvoked() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        List<SBQQ__Quote__c> quoteWithRedlining = new List<SBQQ__Quote__c>{
            new SBQQ__Quote__c(Id = quoteId, SBQQ__Status__c = REDLINING)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IQuotes quotesMock = (IQuotes) mocks.mock(IQuotes.class);
        mocks.startStubbing();
        mocks.when(quotesMock.getType()).thenReturn(Schema.SBQQ__Quote__c.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(quotesMock);
        fflib_SObjectDomain.Test.Database.onInsert(quoteWithRedlining);
        fflib_SObjectDomain.triggerHandler(QuotesHandler.class);
        ((IQuotes) mocks.verify(quotesMock, 1)).initiateRedliningApproversCreationByManagerId();
    }
}