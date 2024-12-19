/**
 * @description Interface for ProductInsightsSelector class
 * @author Deloitte
 * @date 11/04/2022
 */
public interface IProductInsightsSelector extends fflib_ISObjectSelector {
    /**
     * @description This method is used for getting Product Insights based on Id
     * @param setIds
     * @return List of Insights records
     */
    List<Product_Insights__c> selectById(Set<Id> setIds);

    /**
     * @description Query for all Product Insights records present in the system
     * @param parentIds
     * @return List<Product_Insights__c>
     */
    List<Product_Insights__c> selectAllInsightsWithLookups(Set<Id> parentIds);

    /**
     * @description It is used for getting Product Insights and related Lever details by the
     * passed Ids.
     * @param productInsightIds
     * @return List<Product_Insights__c>
     */
    List<Product_Insights__c> selectProductInsightsAndLeversById(Set<Id> productInsightIds);

    /**
     * @description Query for all Product Insights related to passed Opportunity Ids.
     * @param opportunityIds
     * @return List<Product_Insights__c>
     */
    List<Product_Insights__c> selectProductInsightsByOpportunityIds(Set<Id> opportunityIds);

    /**
     * @description Query for all Product Insights related to passed Lever Ids and Accountplan Ids.
     * @param leverIds
     * @param accountPlanIds
     * @return List<Product_Insights__c>
     */
    List<Product_Insights__c> selectProductInsightsByLeverIdAndAccPlanId(
        Set<Id> leverIds,
        Set<Id> accountPlanIds
    );
    
     /**
     * @description Query for all Product Insights related to Lever Ids.
     * @param leverIds
     * @return List<Product_Insights__c>
     */
    List<Product_Insights__c> selectProductInsightsByLeverIdWithOpenOpportunity(Set<Id> leverIds);
}