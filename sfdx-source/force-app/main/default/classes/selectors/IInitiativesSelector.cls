/**
 * @description Interface for Initiative Selector class
 * @author Deloitte
 * @date 06/04/2022
 */
public interface IInitiativesSelector extends fflib_ISObjectSelector {
    /**
     * @description This method is used for getting Opportunities based on Id
     * @param setIds
     * @return List<Initiative__c>
     */
    List<Initiative__c> selectById(Set<Id> setIds);

    /**
     * @description This method is used to query the parent Initiative records
     *              from child Insights
     * @param childInsights
     * @return List<Initiative__c>
     */
    List<Initiative__c> selectByInsights(List<Product_Insights__c> childInsights);

    /**
     * @description This method is used to fetch all Initiatives having Campaign Members
     * @param campaignMemberIds
     * @return List<Initiative__c>
     */
    List<Initiative__c> selectByCampaignMembers(Set<Id> campaignMemberIds);

    /**
     * @description This method is used to fetch all Initiatives by AccountIds.
     * @param accountIds
     * @return List<Initiative__c>
     */
    List<Initiative__c> selectByAccounts(Set<Id> accountIds);
}