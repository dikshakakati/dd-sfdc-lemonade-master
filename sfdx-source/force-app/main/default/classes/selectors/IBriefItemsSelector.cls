/**
 * @author Deloitte
 * @date 11/30/2022
 * @description Interface to add Selector class methods
 */
public interface IBriefItemsSelector extends fflib_ISObjectSelector {
    /**
     * @description This method is used for fetching Brief Items related to the passed Brief Ids
     * @param briefIds
     * @return List<Brief_Item__c>
     */
    List<Brief_Item__c> selectByBrief(Set<Id> briefIds);

    /**
     * @description This method is used for fetching Brief Items related to the passed Brief Ids
     * @param briefIds
     * @return List<Brief_Item__c>
     */
    List<Brief_Item__c> selectByBriefAndStatus(Set<Id> briefIds);

    /**
     * @description This method is used for fetching Brief Items related to the passed Quote Line Items
     * @param quoteLineItemIds
     * @return List<Brief_Item__c>
     */
    List<Brief_Item__c> selectByQuoteLineItems(Set<Id> quoteLineItemIds);
     /**
     * @description fetches brief items by opp Ids
     * @param oppIds
     * @return List<Brief_Item__C>
     */
    List<Brief_Item__c> selectByOpportunities(Set<Id> oppIds);
    /**
     * @description fetches brief Items by brief Item Ids
     * @param briefItemIds
     * @return List<Brief_Item__c>
     */
    List<Brief_Item__c> selectByIds(Set<Id> briefItemIds);
    /**
     * @description This method is used to query brief items with fields required for setting
     * configuration field on associated brief
     * @param briefIds
     * @return List<Brief_Item__c>
     */
    List<Brief_Item__c> selectBriefItemsWithRoutingAndCustomCreative(Set<Id> briefIds);

    /**
     * @description This method is used to query brief items with quote Ids
     * @param quoteIds
     * @return List<Brief_Item__c>
     */
    List<Brief_Item__c> selectBriefItemsWithQuoteIds(Set<Id> quoteIds);

}