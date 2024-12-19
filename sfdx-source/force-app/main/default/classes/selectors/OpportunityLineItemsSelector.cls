/**
 * @author Deloitte
 * @date 11/14/2022
 * @description Selector class to query Opportunity Line Items.
 */
public inherited sharing class OpportunityLineItemsSelector extends fflib_SObjectSelector implements IOpportunityLineItemsSelector {
    private static final String AGGREGATE_COUNT_QUERY_FILTERBY_FIELD = 'OpportunityId';
    private static final String AGGREGATE_COUNT_QUERY_FIELDS = 'COUNT(Id) opportunityLineItemsCount, OpportunityId opportunityId, Product2.Family productFamily';
    private static final String AGGREGATE_COUNT_QUERY_GROUPBY_FIELDS = 'OpportunityId, Product2.Family';
    private static final String AGGREGATE_QUERY_FILTER_CONDITION = ' IN :opportunityIds';
    private static final String GROUP_BY_CLAUSE = ' GROUP BY ';
    private static final String SELECT_CLAUSE = 'SELECT ';
    private static final String WHERE_CLAUSE = ' FROM OpportunityLineItem WHERE ';
    private static final List<String> PRODUCT_FAMILIES = new List<String>{
        'Marketplace Promotion',
        'Advertisement'
    };
    /**
     * @description Default constructor for the OpportunityLineItemsSelector class.
     * @return IOpportunityLineItemsSelector - interface of IOpportunityLineItemsSelector
     */
    public static IOpportunityLineItemsSelector newInstance() {
        return (IOpportunityLineItemsSelector) Application.Selector.newInstance(
            OpportunityLineItem.SObjectType
        );
    }

    /**
     * @description This method is used for getting the fields on OpportunityLineItem object
     * @return List of Schema.SObjectField
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            OpportunityLineItem.Id,
            OpportunityLineItem.Product2Id
        };
    }

    /**
     * @description This method is used for getting object type
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return OpportunityLineItem.SObjectType;
    }

    /**
     * @description It is used to fetch Opportunity Line Item based on related Opportunity and
     * product family of the related Product.
     * @param opportunityIds
     * @return List<OpportunityLineItem>
     */
    public List<OpportunityLineItem> selectByOpportunities(Set<Id> opportunityIds) {
        fflib_QueryFactory opportunityLineItemQuery = newQueryFactory(false, false, true)
            .setCondition(
                'OpportunityId IN :opportunityIds AND Product2.Family IN :PRODUCT_FAMILIES'
            );
        return (List<OpportunityLineItem>) Database.query(opportunityLineItemQuery.toSOQL());
    }

    /**
     * @description It is used for getting count of Opportunity Products filtered and grouped by
     * the passed Opportunity Ids and Product Families.
     * @JIRA# LEM-4258
     * @param opportunityIds
     * @return Aggregate[]
     */
    public Aggregate[] getOpportunityProductsCountFilteredAndGroupedByOpportunityIdsAndProductFamilies(
        Set<Id> opportunityIds
    ) {
        String opportunityLineItemsQuery =
            SELECT_CLAUSE +
            AGGREGATE_COUNT_QUERY_FIELDS +
            WHERE_CLAUSE +
            AGGREGATE_COUNT_QUERY_FILTERBY_FIELD +
            AGGREGATE_QUERY_FILTER_CONDITION +
            GROUP_BY_CLAUSE +
            AGGREGATE_COUNT_QUERY_GROUPBY_FIELDS;
        AggregateResult[] opportunityProductsAggregateCountQueryResult = (List<AggregateResult>) Database.Query(
            String.escapeSingleQuotes(opportunityLineItemsQuery)
        );
        return Aggregate.convertResults(opportunityProductsAggregateCountQueryResult);
    }
}