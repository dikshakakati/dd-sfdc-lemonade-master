/**
 * @author DoorDash
 * @date 08/25/2023
 * @description Selector interface for the Rate_Card__c custom object.
**/
public interface IRateCardsSelector extends fflib_ISObjectSelector {
    /**
     * @description It queries Rate Cards and Rate Card Tiers by set of Quote Line Ids.
     * @param quoteLineIds
     * @return List<Rate_Card__c>
     */
    List<Rate_Card__c> selectByQuoteLineIds(Set<Id> quoteLineIds);
}