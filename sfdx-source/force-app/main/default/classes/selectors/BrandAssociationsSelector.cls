/**
 * @author Deloitte
 * @date 04/04/2022
 * @description Selector class for BrandsAssociations custom metadata.
 */
public inherited sharing class BrandAssociationsSelector extends fflib_SObjectSelector implements IBrandAssociationsSelector {
    private static final String AGGREGATE_COUNT_QUERY_GROUPBY_FIELD_BUSINESSACCOUNTNAME_AND_BRANDNAME = 'Business_Account_Name__c, Brand_Name__c';
    private static final String AGGREGATE_COUNT_QUERY_GROUPBY_FIELD_BUSINESSACCOUNTNAME = 'Business_Account_Name__c';
    private static final String AGGREGATE_QUERY_FILTER_CONDITION_BUSINESSACCOUNTNAME = ' IN: businessAccountIds';
    private static final String AGGREGATE_COUNT_QUERY_ON_BRAND_ASSOCIATION_FIELDS = 'COUNT(Id) brandAssociationsCount, Business_Account_Name__c businessAccountName, Brand_Name__c brandName';
    private static final String GROUP_BY_CLAUSE = ' GROUP BY ';
    static final String LICENSOR = 'Licensor';
    static final String EXTERNAL_ID_SOURCE_MDS = 'MDS';
    private static final String SELECT_CLAUSE = 'SELECT ';
    private static final String WHERE_CLAUSE = ' FROM Brand_Association__c WHERE ';

    /**
     * @description Default constructor for the class
     * @return IBrandAssociationsSelector - interface of IBrandAssociationsSelector.
     */
    public static IBrandAssociationsSelector newInstance() {
        return (IBrandAssociationsSelector) Application.Selector.newInstance(
            Brand_Association__c.SObjectType
        );
    }

    /**
     * @description override default getSObjectType method.
     * @return SObjectType - object type
     */
    public Schema.SObjectType getSObjectType() {
        return Brand_Association__c.SObjectType;
    }

    /**
     * @description This method is for getting the fields on Brand_Association__c.
     * @return List<Schema.SObjectField>- Brand_Association__c fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Brand_Association__c.Brand_Name__c,
            Brand_Association__c.Business_Account_Name__c,
            Brand_Association__c.Id
        };
    }

    /**
     * @description This method is used to get Brand Association records with Licensor relationship which are
     * associated with given brands and bussiness accounts.
     * @param brandIds
     * @param businessIds
     * @return List<Brand_Association__c>
     */
    public List<Brand_Association__c> selectBrandAssociations(
        Set<Id> brandIds,
        Set<Id> businessIds
    ) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition(
            '(Brand_Name__c IN: brandIds OR' +
            ' Business_Account_Name__c IN: businessIds)'
        );
        query.selectField('Id');
        query.selectField('Brand_Name__c');
        query.selectField('Business_Account_Name__c');
        return (List<Brand_Association__c>) Database.query(query.toSOQL());
    }

    /**
     * @description  It is used to get Brand Associations by Brands and Business Account Ids.
     * @param brands
     * @param businessAccountIds
     * @return List<Brand_Association__c>
     */
    public List<Brand_Association__c> selectByBrandsAndBusinessAccountIds(
        Set<Id> brands,
        Set<Id> businessAccountIds
    ) {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition(
                'Brand_Name__c IN :brands AND Business_Account_Name__c IN :businessAccountIds'
            );
        return (List<Brand_Association__c>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used to get Brand Associations by AccountId and ignores those brands having MDS business references.
     * @param accountId
     * @return List<Brand_Association__c>
     */
    public List<Brand_Association__c> selectBrandAssociationsByAccountIdAndIgnoringExternalSourceMds(
        Id accountId
    ) {
        fflib_QueryFactory query = newQueryFactory(true)
            .selectField('Brand_Name__r.Name')
            .selectField('Business_Account_Name__r.Name')
            .setCondition(
                'Business_Account_Name__c = :accountId AND ' +
                    'Brand_Name__c NOT IN (select Brand__c from Business_Reference__c WHERE Brand__c != NULL AND ' +
                    ' External_Id_Source__c = :EXTERNAL_ID_SOURCE_MDS ) '
            );

        return (List<Brand_Association__c>) Database.query(query.toSOQL());
    }

    /**
     * @description  It is used to get Brand Associations by Business Account Ids.
     * @param businessAccountIds
     * @return List<Brand_Association__c>
     */
    public List<Brand_Association__c> selectByBusinessAccountIds(Set<Id> businessAccountIds) {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition('Business_Account_Name__c IN :businessAccountIds');
        return (List<Brand_Association__c>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used for getting number of Brand Associations
     * grouped by Brand Name values using passed set of business Account Ids.
     * @JIRA# LEM-13447
     * @param businessAccountIds
     * @return Aggregate[]
     */
    public Aggregate[] getBrandAssociationsCountFilteredByBusinessAccountIdsGroupedByBrandName(
        Set<Id> businessAccountIds
    ) {
        String brandAssociationsQuery =
            SELECT_CLAUSE +
            AGGREGATE_COUNT_QUERY_ON_BRAND_ASSOCIATION_FIELDS +
            WHERE_CLAUSE +
            AGGREGATE_COUNT_QUERY_GROUPBY_FIELD_BUSINESSACCOUNTNAME +
            AGGREGATE_QUERY_FILTER_CONDITION_BUSINESSACCOUNTNAME +
            GROUP_BY_CLAUSE +
            AGGREGATE_COUNT_QUERY_GROUPBY_FIELD_BUSINESSACCOUNTNAME_AND_BRANDNAME;
        AggregateResult[] brandAssociationsAggregateCountQueryResult = (List<AggregateResult>) Database.Query(
            String.escapeSingleQuotes(brandAssociationsQuery)
        );
        return Aggregate.convertResults(brandAssociationsAggregateCountQueryResult);
    }

    /**
     * @description This method is used for getting BrandAssoication by UUIds
     * @param uniqueIdentifiers
     * @return List<Brand_Association__c>
     */
    public List<Brand_Association__c> selectBrandAssociationsByUniqueIdentifiers(
        Set<String> uniqueIdentifiers
    ) {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectField('Id')
            .selectField('Business_Account_Name__r.Unique_Identifier__c')
            .setCondition('Business_Account_Name__r.Unique_Identifier__c IN :uniqueIdentifiers');
        return (List<Brand_Association__c>) Database.query(query.toSOQL());
    }
}