/**
 * @author Deloitte
 * @date 11/10/2022
 * @description Service class for Brief related logic.
 */
public with sharing class BriefsService {
    /**
     * @description It is used to create Campaign Briefs and Brief Items for each Campaign
     * associated with Quotes that are Contract-Signed and their related Quote Line Items.
     * @param quoteLineItems
     */
    public static void generateBriefsByQuoteLineItems(List<SBQQ__QuoteLine__c> quoteLineItems) {
        service().generateBriefsByQuoteLineItems(quoteLineItems);
    }
    /**
     * @description updates opp related to brief
     * @param briefs
     */
    public static void updateOpportunityFromBrief(List<Brief__c> briefs){
        service().updateOpportunityFromBrief(briefs);
    }

    /**
    /**
     * @description It is used to update Brief Date based on related Brief Items dates.
     * @param briefIds
     * @param briefsToStartDate
     * @param briefsToEndDate
     */
    public static void updateBriefDateBasedOnBriefItemsDate(
        Set<Id> briefIds,
        Map<Id, Date> briefsToStartDate,
        Map<Id, Date> briefsToEndDate
    ) {
        service()
            .updateBriefDateBasedOnBriefItemsDate(briefIds, briefsToStartDate, briefsToEndDate);
    }

    /**
     * @description It is used to update Brief status based on related Brief Items status.
     * @param briefsWithItemsWaitingForInputs
     * @param briefsWithItemsInCampaignBuilding
     */
    public static void updateBriefBasedOnBriefItemsStatus(
        Set<Id> briefsWithItemsWaitingForInputs,
        Set<Id> briefsWithItemsInCampaignBuilding
    ) {
        service()
            .updateBriefBasedOnBriefItemsStatus(
                briefsWithItemsWaitingForInputs,
                briefsWithItemsInCampaignBuilding
            );
    }

    /**
     * @description This method is used to create an instance of BriefsService class.
     * @return IBriefsService - return instance of BriefsServiceImpl
     */
    private static IBriefsService service() {
        return (IBriefsService) Application.Service.newInstance(IBriefsService.class);
    }
    /**
     * @description LEM-9347 update agency fields on brief for existing briefs
     * @param mapBriefIdToQuoteLineContractSigned
     */
    public static void updateAgencyFieldOnExistingBriefs(Map<Id, SBQQ__QuoteLine__c> mapBriefIdToQuoteLineContractSigned){
        service().updateAgencyFieldOnExistingBriefs(mapBriefIdToQuoteLineContractSigned);
    }

    /**
     * @description This method is used to update config field on Briefs based on brief item fields
     * @param briefsToBriefItems
     * @param briefsWithVert
     */
    public static void updateBriefConfiguration(
        Map<Id, List<Brief_Item__c>> briefsToBriefItems,
        List<Brief__c> briefsWithVert
        ) {
        service()
            .updateBriefConfiguration(
                briefsToBriefItems,
                briefsWithVert
            );
    }
}