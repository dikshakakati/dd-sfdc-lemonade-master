/**
 * @description Selector Class for Product Insights
 * @author Deloitte
 * @date 11/04/2022
 */
public inherited sharing class ProductInsightsSelector extends fflib_SObjectSelector implements IProductInsightsSelector {
    /**
     * @description Default Constructor for the Product Insights Selector Class
     * @return IProductInsightsSelector - Interface of IProductsSelector
     */
    public static IProductInsightsSelector newInstance() {
        return (IProductInsightsSelector) Application.Selector.newInstance(
            Product_Insights__c.SObjectType
        );
    }

    /**
     * @description This method is used for getting fields on Product Insights Object
     * @return List of Schema.SObjectField
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Product_Insights__c.Id,
            Product_Insights__c.Name,
            Product_Insights__c.Product__c,
            Product_Insights__c.Product__r.Name,
            Product_Insights__c.Opportunity__c,
            Product_Insights__c.Initiative__c
        };
    }

    /**
     * @description This method is used for getting Object Type
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Product_Insights__c.SObjectType;
    }

    /**
     * @description This method is used for getting Product Insights based on Id
     * @param setIds
     * @return list of Insight records
     */
    public List<Product_Insights__c> selectById(Set<Id> setIds) {
        return (List<Product_Insights__c>) selectSObjectsById(setIds);
    }

    /**
     * @description It is used for getting Product Insights and related Lever details by the
     * passed Ids.
     * @param productInsightIds
     * @return List<Product_Insights__c>
     */
    public List<Product_Insights__c> selectProductInsightsAndLeversById(Set<Id> productInsightIds) {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectField('Interest_Level__c')
            .selectField('Lever__r')
            .selectField('Lever__r.Interest_Level__c')
            .setCondition('Id IN :productInsightIds');
        return (List<Product_Insights__c>) Database.query(query.toSOQL());
    }

    /**
     * @description Query for all Product Insights records present in the system
     * @param parentIds
     * @return List<Product_Insights__c>
     */
    public List<Product_Insights__c> selectAllInsightsWithLookups(Set<Id> parentIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition(
            'Opportunity__c IN :parentIds OR Initiative__c IN :parentIds OR Product__c IN :parentIds'
        );
        return (List<Product_Insights__c>) Database.query(query.toSOQL());
    }

    /**
     * @description Query for all Product Insights related to passed Opportunity Ids.
     * @param opportunityIds
     * @return List<Product_Insights__c>
     */
    public List<Product_Insights__c> selectProductInsightsByOpportunityIds(Set<Id> opportunityIds) {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectField('Lever__c')
            .selectField('Lever__r.Name')
            .selectField('Lever__r.Account__c')
            .selectField('Lever__r.Confidence_Level__c')
            .selectField('Lever__r.Interest_Level__c')
            .selectField('Lever__r.Predicted_Incremental_Sales__c')
            .selectField('Lever__r.Rejection_Reason__c')
            .selectField('Lever__r.Solution__c')
            .selectField('Product__r.name')
            .selectField('Product__r.VSP_Code__c')
            .selectField('Opportunity__c')
            .selectField('Lever__r.Status__c')
            .setCondition('Opportunity__c IN :opportunityIds')
        	.setOrdering('Product__r.name', fflib_QueryFactory.SortOrder.ASCENDING);
        return (List<Product_Insights__c>) Database.query(query.toSOQL());
    }

    /**
     * @description Query for all Product Insights related to passed Opportunity Ids.
     * @param leverIds
     * @param accountPlanIds
     * @return List<Product_Insights__c>
     */
    public List<Product_Insights__c> selectProductInsightsByLeverIdAndAccPlanId(
        Set<Id> leverIds,
        Set<Id> accountPlanIds
    ) {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectField('Lever__c')
            .selectField('Id')
            .selectField('Lever__r.Name')
            .selectField('Lever__r.Account__c')
            .selectField('Lever__r.Confidence_Level__c')
            .selectField('Lever__r.Interest_Level__c')
            .selectField('Lever__r.Predicted_Incremental_Sales__c')
            .selectField('Lever__r.Rejection_Reason__c')
            .selectField('Lever__r.Solution__c')
            .selectField('Lever__r.Status__c')
            .setCondition('Lever__c IN :leverIds AND Lever__r.Account_Plan__c IN :accountPlanIds');
        return (List<Product_Insights__c>) Database.query(query.toSOQL());
    }

    /**
     * @description Query for all Product Insights related to passed Lever Ids.
     * @param leverIds
     * @return List<Product_Insights__c>
     */
    public List<Product_Insights__c> selectProductInsightsByLeverIdWithOpenOpportunity(
        Set<Id> leverIds
    ) {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectField('Id')
            .selectField('Predicted_Sales_Uplift__c')
            .selectField('Lever__r.Predicted_Incremental_Sales__c')
            .selectField('Lever__r.Solution__r.VSP_Code__c')
            .selectField('Lever__r.Account__c')
            .setCondition('Lever__c IN :leverIds AND Opportunity__r.IsClosed = false');
        return (List<Product_Insights__c>) Database.query(query.toSOQL());
    }
}