/**
 * @author Deloitte
 * @date 07/09/2023
 * @description This is the Selector interface for QuoteLineGroup Selector related logic
 */
public interface IQuoteLineGroupSelector extends fflib_ISObjectSelector {
    /**
     * @description method to be implemented in child class
     * @return Map of SBQQ__QuoteLineGroup__c records
     * @param groupRecIds - SBQQ__QuoteLineGroup__c Record Ids
     */
    Map<Id, SBQQ__QuoteLineGroup__c> selectGroupRecords(Set<Id> groupRecIds);

    /**
     * @description method to be implemented in child class.
     * @return List<SBQQ__QuoteLineGroup__c>
     * @param quoteIds
     */
    List<SBQQ__QuoteLineGroup__c> selectGroupRecordsFromQuote(Set<Id> quoteIds);
    /**
     * @description This method is for getting SBQQ__QuoteLineGroup__c based on the provided list of ids
     * @param groupIds - SBQQ__QuoteLineGroup__c Record Ids
     * @param quotelineGroupFields List of fields from quoteline
     * @return List<SBQQ__QuoteLineGroup__c>
     */
    List<SBQQ__QuoteLineGroup__c> selectQuoteLineGroupByGroupIdWithDynamicFields(
        Set<Id> groupIds,
        Set<String> quotelineGroupFields
    );

    /**
     * @description It is used to get Quote Line Groups by the passed Quote Ids.
     * @param quoteIds
     * @return List<SBQQ__QuoteLineGroup__c>
     */
    List<SBQQ__QuoteLineGroup__c> selectQuoteLineGroupsByQuoteIds(Set<Id> quoteIds);
}