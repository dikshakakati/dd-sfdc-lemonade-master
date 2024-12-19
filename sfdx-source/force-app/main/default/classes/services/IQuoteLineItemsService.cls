/**
 * @author Deloitte
 * @date   26/04/2023
 * @description Interface of service class for  QuoteLineItems related logic
 */
public interface IQuoteLineItemsService {
    /**
     * @description LEM-9452: Syncs updated fields back to the brief item
     * @param quoteLineItems
     */
    void updateBriefItemsQuoteLineSyncFields(List<SBQQ__QuoteLine__c> quoteLineItems);
    /**
     * @description updates quotelines from amendments to have Has brief item field updated
     * @param quoteLineItems
     */
    void updateAmendmentQuoteLines(List<SBQQ__QuoteLine__c> quoteLineItems);
    /**
     * @description populate Quote Line group on amemdment quote lines on the amendent quote
     * @param newQuotesMap
     */
    void insertMissingAmendmentLineGroups(Map<Id, SBQQ__Quote__c> newQuotesMap);
    /**
     * @description updates active price fields on quotelines
     * @param quoteLineItems
     */
    void updateActiveFeeActiveComissionOnQuotelines(List<SBQQ__QuoteLine__c> quoteLineItems);
    /**
     * @description reverts active price fields on quotelines when approvals are recalled
     * @param quoteLineItems
     */
    void revertActiveFeeActiveComissionOnQuotelines(List<SBQQ__QuoteLine__c> quoteLineItems);
    /**
     * @description delete Brief items before deleteing an associated quote line
     * @param quoteLineItems
	 */
    void deleteBriefItemBeforeQuoteLineIsDeleted(List<SBQQ__QuoteLine__c> quoteLineItems);
    /**
    * @description - Update Prior Fields on Quote Lines
    * @JIRA# LEM-22670
    * @param quoteLines
    */
    void updatePriorFieldsOnQuoteLines(List<List<SBQQ__QuoteLine__c>> quoteLines);
}