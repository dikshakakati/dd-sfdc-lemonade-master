/**
 * @author Deloitte
 * @date 21/03/2022
 * @description Interface to add Quotes Selector class methods
 */
public interface IQuotesSelector extends fflib_ISObjectSelector {
    /**
     * @description This method is used for getting Qotes based on Id
     * @param setIds Set of Ids
     * @return List<SBQQ__Quote__c>
     */
    List<SBQQ__Quote__c> selectById(Set<Id> setIds);

    /**
     * @description This method is used to get the list of child quotes for opportunities
     * @param opportunityIds
     * @return List<SBQQ__Quote__c>
     */
    List<SBQQ__Quote__c> selectByOpportunity(Set<Id> opportunityIds);

    /**
     * @description It queries parent and child Work Orders along with related Work Plans
     * by the passed parent Work Order Ids.
     * @param quoteIds
     * @return List<SBQQ__Qoote__c>
     */
    List<SBQQ__Quote__c> selectQuotesWithQuoteLineAndQuoteBriefRelationships(Set<Id> quoteIds);

    /**
     * @description This method is used to get the list of contract signed child quotes for accounts
     * @param accountIds
     * @return List<SBQQ__Quote__c>
     */
    List<SBQQ__Quote__c> selectByAccounts(Set<Id> accountIds);

    /**
     * @description It is used to fetch fields from quotes from which an amendment is amended.
     * @param quoteIds
     * @return List<SBQQ__Quote__c>
     */
    List<SBQQ__Quote__c> selectQuoteFieldsFromOriginalQuote(Set<Id> quoteIds);

    /**
     * @description It is used to select quotes by the passed unique identifiers.
     * @JIRA LEM-14588
     * @param uniqueIdentifiers
     * @return List<SBQQ__Quote__c>
     */
    List<SBQQ__Quote__c> selectQuotesbyUniqueIdentifiers(Set<String> uniqueIdentifiers);

    /**
     * @description Retrieves a list of SBQQ__Quote__c records along with their related Quote Lines
     * @JIRA LEM-16305
     * @param quoteIds The set of Quote record IDs to retrieve.
     * @param fieldSetMap the map of Quote , QuoteLine, Contact with set of fields respectively
     * @return A list of SBQQ__Quote__c records with their related Quote Lines and OCR with given fields
     */
    List<SBQQ__Quote__c> selectQuotewithQuoteLinesAndOpportunityContactRoleWithGivenFields(
        Set<Id> quoteIds,
        Map<String, Set<String>> fieldSetMap
    );


    /**
    * @description  - select quote and its business account details
    * @author Soumya Dash | 07-30-2024
    * @param quoteId
    * @param fields
    * @param ;
    * @return SBQQ__Quote__c
    **/
    SBQQ__Quote__c selectByIdWithBusinessAccount(Id quoteId,map<String,set<String>> fields);

    /**
     * @description It is used to select primary quotes with status contract signed
     * by the passed account ids.
     * @JIRA LEM-15849
     * @param accountIds
     * @return List<SBQQ__Quote__c>
     */
    List<SBQQ__Quote__c> selectPrimaryQuotesBySalesforceAccountIds(Set<Id> accountIds);

    /**
     * @description It is used to retrieve all the Original Quote field values by passing Quote Id.
     * @param quoteId
     * @param targetFieldAPIs
     * @return List<SBQQ__Quote__c>
     */
    List<SBQQ__Quote__c> selectOriginalQuotewithDynamicFields(
        Set<Id> quoteId,
        Set<String> targetFieldAPIs
    );

    /**
    * @description  - select quote and with some fields.
    * @author Samiksha Bharti | 06-27-2024
    * @param quoteIds
    * @param fieldSet
    * @return SBQQ__Quote__c
    **/
    List<SBQQ__Quote__c> selectQuoteByIdWithGivenFields(Set<Id> quoteIds, Set<String> fieldSet);


    /**
    * @description Select business account details related to the quote
    * @author Pankaj | 07-16-2024
    * @param quoteId
    * @param ;
    * @return SBQQ__Quote__c
    **/
    SBQQ__Quote__c selectByIdWithAccountOpportunityContacts(Id quoteId);
    /**
     * @description It is used to query the self-serve A&P quotes that are stuck in non-primary and
     * approved status. It selects the quotes created before the current date.
     * @JIRA #LEM-23462
     * @return Database.QueryLocator
     **/
    Database.QueryLocator selectSelfServeHaltedQuotes();
}