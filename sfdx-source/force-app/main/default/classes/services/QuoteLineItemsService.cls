/**
 * @author Deloitte
 * @date   26/04/2023
 * @description This is the service class for QuoteLineItems
 */
public inherited sharing class QuoteLineItemsService {
    private static IQuoteLineItemsService service() {
        return (IQuoteLineItemsService) Application.Service.newInstance(
            IQuoteLineItemsService.class
        );
    }
    /**
     * @description populate Quote Line group on amemdment quote lines on the amendent quote
     * @param newQuotesMap
     */
    public static void insertMissingAmendmentLineGroups(Map<Id, SBQQ__Quote__c> newQuotesMap) {
        Service().insertMissingAmendmentLineGroups(newQuotesMap);
    }
    /**
     * @description updates the briefitems with the mapped fields from the quote line
     * @param quoteLineItems
     */
    public static void updateBriefItemsQuoteLineSyncFields(
        List<SBQQ__QuoteLine__c> quoteLineItems
    ) {
        Service().updateBriefItemsQuoteLineSyncFields(quoteLineItems);
    }
    /**
     * @description updates quotelines from amendments to have Has brief item field updated
     * @param quoteLineItems
     */
    public static void updateAmendmentQuoteLines(List<SBQQ__QuoteLine__c> quoteLineItems) {
        Service().updateAmendmentQuoteLines(quoteLineItems);
    }
    /**
     * @description updates Active Price Fields on QuoteLines
     * @param quoteLineItems
     */
    public static void updateActiveFeeActiveComissionOnQuotelines(
        List<SBQQ__QuoteLine__c> quoteLineItems
    ) {
        Service().updateActiveFeeActiveComissionOnQuotelines(quoteLineItems);
    }
    /**
     * @description reverts active price fields on quotelines when approvals are recalled
     * @param quoteLineItems
     */
    public static void revertActiveFeeActiveComissionOnQuotelines(
        List<SBQQ__QuoteLine__c> quoteLineItems
    ) {
        Service().revertActiveFeeActiveComissionOnQuotelines(quoteLineItems);
    }
    /**
     * @description Delete Brief Items before delete an associated Quote Line.
     * @param quoteLineItems
     */
    public static void deleteBriefItemBeforeQuoteLineIsDeleted(List<SBQQ__QuoteLine__c> quoteLineItems){
    Service().deleteBriefItemBeforeQuoteLineIsDeleted(quoteLineItems);
    }
    /**
    * @description - Update Prior Fields on Quote Lines
    * @JIRA# LEM-22670
    * @param quoteLines
    */
    public static void updatePriorFieldsOnQuoteLines(List<List<SBQQ__QuoteLine__c>> quoteLines){
        Service().updatePriorFieldsOnQuoteLines(quoteLines);
    }
}