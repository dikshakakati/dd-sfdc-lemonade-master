/**
 * @description This is test class for Orders Trigger handler class
 * @author ATG
 * @date 2023-04-26
 */
@isTest(SeeAllData=false)
public class QuoteLineItemsHandlerTest {
    /**
     * @description To test method call on Quote update
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenQuoteLineItemStartAndEndDateUpdatedThenUpdateBriefItem() {
        Id quoteLineItemId = Fake.generateId(SBQQ__QuoteLine__c.class);

        List<SBQQ__QuoteLine__c> quoteLineItemList = new List<SBQQ__QuoteLine__c>{
            new SBQQ__QuoteLine__c(
                Id = quoteLineItemId,
                Start_Date__c = System.today() - 2,
                End_Date__c = System.today() + 4,
                Has_Brief_Item__c = true
            )
        };

        List<SBQQ__QuoteLine__c> oldQuoteLineItemList = new List<SBQQ__QuoteLine__c>{
            new SBQQ__QuoteLine__c(
                Id = quoteLineItemId,
                Start_Date__c = System.today() - 3,
                End_Date__c = System.today() + 6,
                Has_Brief_Item__c = true
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IQuoteLineItems quotesMock = (IQuoteLineItems) mocks.mock(IQuoteLineItems.class);
        mocks.startStubbing();
        mocks.when(quotesMock.getType()).thenReturn(Schema.SBQQ__QuoteLine__c.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(quotesMock);

        fflib_SObjectDomain.Test.Database.onUpdate(
            quoteLineItemList,
            new Map<Id, SObject>(oldQuoteLineItemList)
        );
        fflib_SObjectDomain.triggerHandler(QuoteLineItemsHandler.class);

        ((IQuoteLineItems) mocks.verify(quotesMock, 0)).updateBriefItemsQuoteLineSyncFields();
    }

    /**
     * @description To test method call on Quote insert
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenQuoteLineItemHasBriefItemThenUpdateHasBriefItemField() {
        Id quoteLineItemId = Fake.generateId(SBQQ__QuoteLine__c.class);
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        List<SBQQ__QuoteLine__c> quoteLineItemList = new List<SBQQ__QuoteLine__c>{
            new SBQQ__QuoteLine__c(
                Id = quoteLineItemId,
                Start_Date__c = System.today() - 2,
                End_Date__c = System.today() + 4,
                SBQQ__Quote__c = quoteId
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IQuoteLineItems quotesMock = (IQuoteLineItems) mocks.mock(IQuoteLineItems.class);
        mocks.startStubbing();
        mocks.when(quotesMock.getType()).thenReturn(Schema.SBQQ__QuoteLine__c.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(quotesMock);

        fflib_SObjectDomain.Test.Database.onInsert(quoteLineItemList);
        fflib_SObjectDomain.triggerHandler(QuoteLineItemsHandler.class);

        ((IQuoteLineItems) mocks.verify(quotesMock, 1)).updateAmendmentQuoteLines();
    }
}