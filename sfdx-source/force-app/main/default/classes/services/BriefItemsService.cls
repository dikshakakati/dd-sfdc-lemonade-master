/**
 * @author Deloitte
 * @date 11/11/2022
 * @description Service class for logic related to Brief Items.
 */
public with sharing class BriefItemsService {
    /**
     * @description It is used to create Brief Items for all Quote Line Items related to the
     * contract signed Quotes.
     * @param quoteLineItems
     * @param quoteBriefRelationships
     */
    public static void generateBriefItemsByQuoteLineItems(
        List<SBQQ__QuoteLine__c> quoteLineItems,
        List<Quote_Brief_Relationship__c> quoteBriefRelationships
    ) {
        service().generateBriefItemsByQuoteLineItems(quoteLineItems, quoteBriefRelationships);
    }

    /**
     * @description It is used to create a mapping between Campaign-Quote and Brief.
     * @param quoteBriefRelationships
     * @return Map<String, Quote_Brief_Relationship__c>
     */
    public static Map<String, Quote_Brief_Relationship__c> getCampaignQuoteRelationshipMappings(
        List<Quote_Brief_Relationship__c> quoteBriefRelationships
    ) {
        return service().getCampaignQuoteRelationshipMappings(quoteBriefRelationships);
    }
    /**
     * @description used to create brief Item field tracking objects
     * @param existingBriefItemMap
     * @param changedBriefItemsList
     */
    public static void createBriefItemTrackingRecords(
        Map<Id, SObject> existingBriefItemMap,
        List<Brief_Item__c> changedBriefItemsList
    ) {
        service().createBriefItemTrackingRecords(existingBriefItemMap, changedBriefItemsList);
    }

    /**
     * @description This method is used to create an instance of BriefItemsServiceImpl class.
     * @return IBriefItemsService - return instance of BriefItemsServiceImpl
     */
    private static IBriefItemsService service() {
        return (IBriefItemsService) Application.Service.newInstance(IBriefItemsService.class);
    }
    /**
     * @description updates the in-campaign field if a required field is changed
     * @param existingBriefItemMap
     * @param changedBriefItemsList
     */
    public static void sendCampaignCompletedEmails(
        Map<Id, SObject> existingBriefItemMap,
        List<Brief_Item__c> changedBriefItemsList
    ) {
        service().sendCampaignCompletedEmails(existingBriefItemMap, changedBriefItemsList);
    }
    /** @description updates the related quoteline with the Brief Item ID
     * @param briefItems
     * @JIRA LEM-9452
     */
    public static void updateQuoteLinesFromBriefItems(List<Brief_Item__c> briefItems) {
        service().updateQuoteLinesFromBriefItems(briefItems);
    }
    /**
     * @description updates the related brief items agency fields if necessary
     * @param mapBriefItemIdToQuoteline
     */
    public static void updateAgencyFieldOnExistingBriefItems(
        Map<Id, SBQQ__QuoteLine__c> mapBriefItemIdToQuoteline
    ) {
        service().updateAgencyFieldOnExistingBriefItems(mapBriefItemIdToQuoteline);
    }
    /**
     * @description update in campaign change
     * @param existingBriefItemMap
     * @param changedBriefItemsList
     */
    public static void updateInCampaignChangeOnBriefItem(
        Map<Id, SObject> existingBriefItemMap,
        List<Brief_Item__c> changedBriefItemsList
    ) {
        service().updateInCampaignChangeOnBriefItem(existingBriefItemMap, changedBriefItemsList);
    }

    /**
     * @description updates the draft Io template on brief items
     * @param quoteIdTempIdmap
     */
    public static void updateDraftIoTemplateOnExistingBriefItems(Map<Id, Id> quoteIdTempIdmap){
        service().updateDraftIoTemplateOnExistingBriefItems(quoteIdTempIdmap);
    }
}