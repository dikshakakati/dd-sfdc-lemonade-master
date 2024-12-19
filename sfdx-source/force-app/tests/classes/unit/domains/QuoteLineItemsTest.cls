/**
 * @author Deloitte
 * @date 2023-04-25
 * @description Test Class for QuoteLineItems Object.
 */
@isTest(seeAllData=false)
public with sharing class QuoteLineItemsTest {
    /**
     * @description To test updateBriefItemsStartAndEndDates call
     * Suppressed Warnings since mock verify method does not require system assert statements.
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenQuotesLineItemsUpdatedThenUpdateBriefItems() {
        Id quoteLineItemIdOne = fflib_IDGenerator.generate(SBQQ__QuoteLine__c.SObjectType);
        Fake quoteLineItemInstance = new Fake(SBQQ__QuoteLine__c.class)
            .setField(SBQQ__QuoteLine__c.Id, quoteLineItemIdOne)
            .setField(SBQQ__QuoteLine__c.Start_Date__c, System.today() - 2)
            .setField(SBQQ__QuoteLine__c.End_Date__c, System.today() + 4)
            .setField(SBQQ__QuoteLine__c.Has_Brief_Item__c, true);
        List<SBQQ__QuoteLine__c> quoteLineItemsMock = new List<SBQQ__QuoteLine__c>{
            (SBQQ__QuoteLine__c) quoteLineItemInstance.toSObject()
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IQuoteLineItemsService serviceMock = (IQuoteLineItemsService) mocks.mock(
            IQuoteLineItemsService.class
        );
        Application.SERVICE.setMock(IQuoteLineItemsService.class, serviceMock);
        QuoteLineItems.newInstance(quoteLineItemsMock).updateBriefItemsQuoteLineSyncFields();
        ((IQuoteLineItemsService) mocks.verify(serviceMock, 1))
            .updateBriefItemsQuoteLineSyncFields(quoteLineItemsMock);
    }

}