/**
 * @author Deloitte
 * @date 11/10/2022
 * @description Interface of service class for Brief Item related logic
 */
public interface IBriefItemsService {
    /**
     * @description It is used to create Brief Items for all Quote Line Items related to the
     * contract signed Quotes.
     * @param quoteLineItems
     * @param quoteBriefRelationships
     */
    void generateBriefItemsByQuoteLineItems(
        List<SBQQ__QuoteLine__c> quoteLineItems,
        List<Quote_Brief_Relationship__c> quoteBriefRelationships
    );

    /**
     * @description It is used to create a mapping between Campaign-Quote and Brief.
     * @param quoteBriefRelationships
     * @return Map<String, Quote_Brief_Relationship__c>
     */
    Map<String, Quote_Brief_Relationship__c> getCampaignQuoteRelationshipMappings(
        List<Quote_Brief_Relationship__c> quoteBriefRelationships
    );
    /**
     * @description creaties tracking items on Brief Items
     * @param existingBriefItemMap
     * @param changedBriefItemsList
     */
    void createBriefItemTrackingRecords(
        Map<Id, SObject> existingBriefItemMap,
        List<Brief_Item__c> changedBriefItemsList
    );
    /**
     * @description updates the in-campaign field if a required field is changed
     * @param existingBriefItemMap
     * @param changedBriefItemsList
     */
    void sendCampaignCompletedEmails(
        Map<Id, SObject> existingBriefItemMap,
        List<Brief_Item__c> changedBriefItemsList
    );
    /**
     * @description update in campaign change
     * @param existingBriefItemMap
     * @param changedBriefItemsList
     */
    void updateInCampaignChangeOnBriefItem(
        Map<Id, SObject> existingBriefItemMap,
        List<Brief_Item__c> changedBriefItemsList
    );
    /** @description updates the related quoteline with the Brief Item ID
     * @param briefItems
     * @JIRA LEM-9452
     */
    void updateQuoteLinesFromBriefItems(List<Brief_Item__c> briefItems);
    /**
     * @description updates the related brief items agency fields if necessary
     * @param mapBriefItemIdToQuoteline
     */
    void updateAgencyFieldOnExistingBriefItems(
        Map<Id, SBQQ__QuoteLine__c> mapBriefItemIdToQuoteline
    );

    /**
     * @description updates the draft Io template on brief items
     * @param quoteIdTempIdmap
     */
    void updateDraftIoTemplateOnExistingBriefItems(
        Map<Id, Id> quoteIdTempIdmap
    );
}