/**
 * @author Deloitte
 * @date 11/14/2022
 * @description Interface for Opportunity Line Item Selector class.
 */
public interface IOpportunityLineItemsSelector extends fflib_ISObjectSelector {
    /**
     * @description It is used to fetch Opportunity Line Item based on related Opportunity and
     * product family of the related Product.
     * @param opportunityIds
     * @return List<OpportunityLineItem>
     */
    List<OpportunityLineItem> selectByOpportunities(Set<Id> opportunityIds);

    /**
     * @description It is used for getting count of Opportunity Products filtered and grouped by
     * the passed Opportunity Ids and Product Families.
     * @param opportunityIds
     * @return Aggregate[]
     */
    Aggregate[] getOpportunityProductsCountFilteredAndGroupedByOpportunityIdsAndProductFamilies(
        Set<Id> opportunityIds
    );
}