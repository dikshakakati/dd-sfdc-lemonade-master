/**
 * @author DoorDash
 * @date 08/11/2023
 * @description LEM-8769 Controller class for configuring Rate Card and Rate Card Tier on Quote Line Drawer
 */
public class ConfigureRateCardController {
    private static final String QUOTE_TYPE_AMENDMENT = 'Amendment';
    private static final String RATE_CARD_FEETYPE_TIEREDPRICING = 'Tiered Pricing';

    /**
     * @description It is used to Insert, Update and Delete the Rate Cards and Rate Card Tiers
     * @param lstRateCards
     * @param deleteRateCards
     * @param quoteLineRecId
     */
    @AuraEnabled
    public static void upsertRateCards(
        String lstRateCards,
        List<Rate_Card__c> deleteRateCards,
        Id quoteLineRecId
    ) {
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        Map<String, List<Rate_Card_Tier__c>> rateCardTiersMap = new Map<String, List<Rate_Card_Tier__c>>();

        List<RateCardsContainer> rateCardContainerList = (List<RateCardsContainer>) System.JSON.deserialize(
            lstRateCards,
            List<RateCardsContainer>.class
        );
        try {
            for (RateCardsContainer rateCardContainer : rateCardContainerList) {
                uow.registerUpsert(rateCardContainer.rateCard);
                String stateFeeType =
                    rateCardContainer.rateCard.State__c + rateCardContainer.rateCard.Fee_Type__c;
                if (
                    rateCardContainer.rateCard.Fee_Type__c != RATE_CARD_FEETYPE_TIEREDPRICING &&
                    !rateCardContainer.relatedRateCardTiers.isEmpty()
                ) {
                    uow.registerDeleted(rateCardContainer.relatedRateCardTiers);
                } else if (!rateCardContainer.relatedRateCardTiers.isEmpty()) {
                    rateCardTiersMap.put(stateFeeType, rateCardContainer.relatedRateCardTiers);
                }
                uow.registerDeleted(rateCardContainer.deleteRateCardTiers);
            }

            commitWork(uow);
            upsertRateCards(deleteRateCards, rateCardTiersMap, quoteLineRecId, uow);
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
    /**
     * @description It is used to Insert, Update and Delete the Rate Cards and Rate Card Tiers
     * @param deleteRateCards
     * @param rateCardTiersMap
     * @param quoteLineRecId
     * @param uow2
     */
    public static void upsertRateCards(
        List<Rate_Card__c> deleteRateCards,
        Map<String, List<Rate_Card_Tier__c>> rateCardTiersMap,
        Id quoteLineRecId,
        fflib_ISObjectUnitOfWork uow2
    ) {
        Map<String, Id> rateCardIdMap = new Map<String, Id>();
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        for (
            Rate_Card__c rateCard : RateCardsSelector.newInstance()
                .selectByQuoteLineIds(new Set<Id>{ quoteLineRecId })
        ) {
            String stateFeeType = rateCard.State__c + rateCard.Fee_Type__c;
            rateCardIdMap.put(stateFeeType, rateCard.Id);
        }

        for (String stateFeeType : rateCardTiersMap.KeySet()) {
            for (Rate_Card_Tier__c rateCardTier : rateCardTiersMap.get(stateFeeType)) {
                if (rateCardTier.Id == null) {
                    rateCardTier.Rate_Card__c = rateCardIdMap.get(stateFeeType);
                }
                uow.registerUpsert(rateCardTier);
            }
        }

        // uow.commitWork();
        uow.registerDeleted(deleteRateCards);
        // uow.commitWork();
        commitWork(uow);
    }

    /**
     * @description It is used to fetch the Rate Cards and Rate Card Tiers related to Quote Line
     * @param quoteLineRecId
     * @param type
     * @param upgradedSubscription
     * @param quoteId
     * @param groupId
     * @return List<Rate_Card__c>
     */
    @AuraEnabled
    public static List<Rate_Card__c> getRateCardsForQuoteLine(
        Id quoteLineRecId,
        String type,
        Id upgradedSubscription,
        Id quoteId,
        Id groupId
    ) {
        List<Rate_Card__c> rateCardList = new List<Rate_Card__c>();
        rateCardList = RateCardsSelector.newInstance()
            .selectByQuoteLineIds(new Set<Id>{ quoteLineRecId });

        if((rateCardList == null || rateCardList.isEmpty()) && type == QUOTE_TYPE_AMENDMENT){
            rateCardList = returnRateCardsForAmendments(quoteId,upgradedSubscription);
        }
        return rateCardList;
    }

    /**
     * @description Fetch the Rate Cards for Amendment Quote
     * @param quoteId
     * @param upgradedSubscription
     * @return List<Rate_Card__c>
     */
    public static List<Rate_Card__c> returnRateCardsForAmendments(Id quoteId, Id upgradedSubscription) {
        List<Rate_Card__c> rateCardList = new List<Rate_Card__c>();
        if(upgradedSubscription != null){
            rateCardList.addAll(getRateCardsUsingSubscriptionId(upgradedSubscription));
        } else{
            List<SBQQ__QuoteLine__c> quoteLinesList = QuoteLineItemsSelector.newInstance()
                .selectMarketplaceAlcoholDeliveryQuoteLinesFromQuoteIds(new Set<Id>{ quoteId });
            if(quoteLinesList != null && !quoteLinesList.isEmpty()){
                rateCardList.addAll(getRateCardsUsingSubscriptionId(quoteLinesList[0].SBQQ__UpgradedSubscription__c));
            }
        }
        return rateCardList;
    }

    /**
     * @description It is used to fetch the Rate Cards and Rate Card Tiers related to Quote Line based on Subscription Id
     * @param upgradedSubscription
     * @return List<Rate_Card__c>
     */
    private static List<Rate_Card__c> getRateCardsUsingSubscriptionId(Id upgradedSubscription) {
        List<Rate_Card__c> rateCardList = new List<Rate_Card__c>();
        List<SBQQ__Subscription__c> subscriptionList = SubscriptionSelector.newInstance()
            .selectBySubscriptionIds(new Set<Id>{ upgradedSubscription });

        List<Rate_Card__c> amendmentRateCardList = RateCardsSelector.newInstance()
            .selectByQuoteLineIds(new Set<Id>{ subscriptionList[0].SBQQ__QuoteLine__c });

        for (Rate_Card__c rateCard : amendmentRateCardList) {
            rateCard.Id = null;
            for(Rate_Card_Tier__c rateCardTier : rateCard.Rate_Card_Tiers__r){
                rateCardTier.Id = null;
            }
            rateCardList.add(rateCard);
        }
        return rateCardList;
    }

    /**
     * @description It is used to fetch the Standard Rate Card Tiers Custom Metadata
     * @return List<Standard_Rate_Card_Tier__mdt>
     */
    @AuraEnabled(cacheable=true)
    public static List<Standard_Rate_Card_Tier__mdt> getStandardRateCardTiers() {
        List<Standard_Rate_Card_Tier__mdt> standardRateCardsTiers = StandardRateCardTiersSelector.newInstance()
            .getAllValues();
        return standardRateCardsTiers;
    }
    /**
     * @description A common method to commit unit of work LEM-8769
     * @param uow
     */
    private static void commitWork(fflib_ISObjectUnitOfWork uow) {
        try {
            uow.commitWork();
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
            throw ex;
        }
    }

    /**
     * @description It is used to store the Rate Card and Rate Card Tiers which are related to Rate Card
     */
    public class RateCardsContainer {
        @AuraEnabled
        public Rate_Card__c rateCard;
        @AuraEnabled
        public List<Rate_Card_Tier__c> relatedRateCardTiers;
        @AuraEnabled
        public List<Rate_Card_Tier__c> deleteRateCardTiers;
    }
}