/**
 * @author Deloitte
 * @date 11/10/2022
 * @description Interface of service class for Brief related logic
 */
public interface IBriefsService {
    /**
     * @description It is used to create Briefs for a unique set of Campaigns from Quote Line Items
     * and relate them to a Quote.
     * @param quoteLineItems
     */
    void generateBriefsByQuoteLineItems(List<SBQQ__QuoteLine__c> quoteLineItems);

    /**
     * @description It is used to update Brief status based on related Brief Items status.
     * @param briefsWithItemsWaitingForInputs
     * @param briefsWithItemsInCampaignBuilding
     */
    void updateBriefBasedOnBriefItemsStatus(
        Set<Id> briefsWithItemsWaitingForInputs,
        Set<Id> briefsWithItemsInCampaignBuilding
    );

    /**
     * @description It is used to update Brief Date based on related Brief Items dates.
     * @param briefIds
     * @param briefsToStartDate
     * @param briefsToEndDate
     */
    void updateBriefDateBasedOnBriefItemsDate(
        Set<Id> briefIds,
        Map<Id, Date> briefsToStartDate,
        Map<Id, Date> briefsToEndDate
    );
    /**
     * @description updates opp related to brief
     * @param briefs
     */
    void updateOpportunityFromBrief(List<Brief__c> briefs);
    /**
     * @description LEM-9347 update agency fields on brief for existing briefs
     * @param mapBriefIdToQuoteLineContractSigned
     */
    void updateAgencyFieldOnExistingBriefs(Map<Id, SBQQ__QuoteLine__c> mapBriefIdToQuoteLineContractSigned);

    /**
     * @description This method is used to update config field on Briefs based on brief item fields
     * @param briefsToBriefItems
     * @param briefsWithVert
     */
    void updateBriefConfiguration(Map<Id, List<Brief_Item__c>> briefsToBriefItems, List<Brief__c> briefsWithVert);

}