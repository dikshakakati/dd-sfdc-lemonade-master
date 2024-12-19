/**
 * @author Deloitte
 * @date 05/05/2022
 * @description Selector Class for Merchant service Object
 */
public inherited sharing class MerchantSelector extends fflib_SObjectSelector implements IMerchantSelector {
    private static final String SELECT_CLAUSE = 'SELECT ';
    private static final String ACCOUNT_AGGREGATE_QUERY_FIELDS = 'Account__c storeId';
    private static final String ACCOUNT_AGGREGATE_QUERY_GROUP_BY_FIELDS = 'Account__c';
    private static final String WHERE_CLAUSE = ' FROM Merchant_Service__c WHERE ';
    private static final String ACCOUNT_AGGREGATE_QUERY_FILTER_BY_FIELD = 'Subscription__c';
    private static final String ACCOUNT_AGGREGATE_QUERY_FILTER_CONDITION = ' IN :subIds AND Product__r.platform__c != NULL';
    private static final String GROUP_BY_CLAUSE = ' GROUP BY ';
    private static final String ACTIVE_YES = 'Yes';
    private static final List<String> ALCOHOL_PRODUCT_NAMES = new List<String>{
        'Alcohol Delivery',
        'Alcohol Pickup'
    };
    private static final Set<String> DRIVE_PRODUCT_CODES = new Set<String>{ '10012%', '10044%' };
    private static final Set<String> MARKETPLACE_PRODUCT_CODES = new Set<String>{
        '10007%',
        '10017%',
        '10027%',
        '10047%',
        '10056%',
        '10057%'
    };
    private static final String STATUS_DRAFT = 'Draft';

    /**
     * @description New instance method to call application selector
     * @param Merchant_Service__c.SObjectType - Merchant_Service__c object type
     * @return IMerchantSelector - interface of IMerchantSelector
     */
    public static IMerchantSelector newInstance() {
        return (IMerchantSelector) Application.Selector.newInstance(
            Merchant_Service__c.SObjectType
        );
    }

    /**
     * @description This method is for getting the fields on Merchant Service object
     * @return Merchant Service object fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Merchant_Service__c.Id,
            Merchant_Service__c.Account__c,
            Merchant_Service__c.Business_Account_Id__c,
            Merchant_Service__c.Service_Product_Name__c,
            Merchant_Service__c.Trial_Commission__c,
            Merchant_Service__c.Trial_Fee__c,
            Merchant_Service__c.Account__r.Name,
            Merchant_Service__c.Start_Date__c,
            Merchant_Service__c.Product__c,
            Merchant_Service__c.Product_Code__c,
            Merchant_Service__c.Order_Product__c,
            Merchant_Service__c.Subscription__c,
            Merchant_Service__c.Active__c,
            Merchant_Service__c.Mx_Agreed_to_Product__c,
            Merchant_Service__c.Name,
            Merchant_Service__c.Final_Fee__c,
            Merchant_Service__c.Final_Commission__c,
            Merchant_Service__c.Bundle__c,
            Merchant_Service__c.Account__r.CreatedDate
        };
    }

    /**
     * @description This method is for getting the Merchant Service based on provided Ids
     * @return Database.query- DML operation result
     * @param merchantRecIds - Merchant_Service__c Record Ids
     */
    public List<Merchant_Service__c> queryMerchantRecords(Set<Id> merchantRecIds) {
        return Database.query(
            newQueryFactory()
                .selectField('Account__r.ParentId')
                .setCondition('Id IN: merchantRecIds')
                .toSOQL()
        );
    }
    /**
     * @description This method is for getting the Merchant Service based on provided Ids
     * @param accountIds  - Merchant_Service__c Record Ids
     * @return Database.query- DML operation result
     */
    public List<Merchant_Service__c> queryMerchantRecordsWithAccountIds(Set<Id> accountIds) {
        ignoreCRUD();
        return Database.query(
            newQueryFactory()
                .selectField('Account__r.ParentId')
                .selectField('Account__r.Franchise_Parent__c')
                .selectField('Product__r.Family')
                .selectField('Order_Product__c')
                .selectField('Order_Product__r.Product2.Family')
                .selectField('Order_Product__r.Product2.Name')
                .selectField('Order_Product__r.SBQQ__BundleRoot__r.Product2.Family')
                .selectField('Order_Product__r.SBQQ__BundleRoot__r.Product2.Name')
                .selectField('Order_Product__r.Primary_Order_Product__c')
                .selectField(
                    'Order_Product__r.SBQQ__BundleRoot__r.Product2.Package_Eligible_For_Nintex_Options__c'
                )
                .selectField('Order_Product__r.Product2.Package_Eligible_For_Nintex_Options__c')
                .selectField('Order_Product__r.Fee_Type__c')
                .selectField('Group__c')
                .selectField('Subscription__c')
                .selectField('Subscription__r.SBQQ__RootId__c')
                .selectField('Subscription__r.SBQQ__RequiredById__c')
                .selectField('Order_Product__r.Existing_Store_Processed__c')
                .selectField('Subscription__r.SBQQ__OrderProduct__c')
                .selectField('Order_Product__r.Original_Provisioned_Date__c')
                .selectField('Order_Product__r.ServiceDate')
                .selectField('Rate_Card__c')
                .selectField('Active_Rates_Applied__c')
                .selectField(
                    'Subscription__r.Subscription_Rate_Change__r.Rate_Change_Request__r.Activation_Status__c'
                )
                .selectField('Subscription__r.SBQQ__ProductOption__r.Active_Rate_Eligible__c')
                .selectField('Order_Product__r.Active_Rate_Change_Start_Date__c')
                .setCondition('Account__c IN: accountIds')
                .toSOQL()
        );
    }

    /**
     * @description This method is used for getting Merchant Service Records with which comes under Package Exclusion
     * @param storeRecIds
     * @param mxRecIds
     * @param packageExclusion
     * @return List<Merchant_Service__c>
     */
    public List<Merchant_Service__c> selectExistingMerchantServiceToExcludeByStoreIdsAndPackage(
        Set<Id> storeRecIds,
        Set<Id> mxRecIds,
        set<String> packageExclusion
    ) {
        return Database.query(
            newQueryFactory()
                .selectField('Subscription__r.SBQQ__QuoteLine__r.SBQQ__Quote__c')
                .setCondition(
                    'Account__c IN :storeRecIds ' +
                        'AND (Subscription__r.SBQQ__QuoteLine__r.SBQQ__ProductName__c IN :packageExclusion ' +
                        'OR Subscription__r.SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__ProductName__c IN :packageExclusion)'
                )
                .toSOQL()
        );
    }

    /**
     * @description This method is for getting the Merchant Service based on provided Ids
     * @param accountIds  - Franchise Parent Record Ids
     * @return Database.query- DML operation result
     */
    public List<Merchant_Service__c> queryMerchantRecordsWithFranchiseParentAccountIds(
        Set<Id> accountIds
    ) {
        return Database.query(
            newQueryFactory()
                .selectField('Account__r.ParentId')
                .selectField('Product__r.Family')
                .selectField('Order_Product__r.Product2.Family')
                .selectField('Order_Product__r.Product2.Name')
                .selectField('Order_Product__r.Product2.Package_Eligible_For_Nintex_Options__c')
                .selectField(
                    'Order_Product__r.SBQQ__BundleRoot__r.Product2.Package_Eligible_For_Nintex_Options__c'
                )
                .selectField('Order_Product__r.SBQQ__BundleRoot__r.Product2.Family')
                .selectField('Order_Product__r.SBQQ__BundleRoot__r.Product2.Name')
                .selectField('Account__r.Franchise_Parent__c')
                .selectField('Active_Rates_Applied__c')
                .setCondition('Account__r.Franchise_Parent__c IN: accountIds')
                .toSOQL()
        );
    }

    /**
     * @description returns Order Products that should should now be activated.
     * @return List<Merchant_Service__c> List of Merchant Service Records.
     * @param accountIds - account Ids to search.
     */
    public List<Merchant_Service__c> queryActiveMarketplaceServicesWithDraftOrderProductsByAccountId(
        Set<Id> accountIds
    ) {
        return Database.query(
            newQueryFactory()
                .selectField('Account__r.Proposed_Date_of_Activation__c')
                .selectField('Order_Product__r.Product_Code__c')
                .selectField('Order_Product__r.SBQQ__Status__c')
                .selectField('Order_Product__r.Order.Id')
                .selectField('Order_Product__r.Order.EffectiveDate')
                .selectField('Subscription__r.Subscription_Rate_Change__c')
                .selectField('Active_Rates_Applied__c')
                .selectField('Order_Product__r.Existing_Store_Processed__c')
                .setCondition(
                    'Active__c = :ACTIVE_YES' +
                        ' AND Account__c IN :accountIds' +
                        ' AND Order_Product__r.SBQQ__Status__c = :STATUS_DRAFT' +
                        ' AND Order_Product__r.Product_Code__c LIKE :MARKETPLACE_PRODUCT_CODES'
                )
                .toSOQL()
        );
    }

    /**
     * @description returns Order Products that should should now be activated.
     * @return List<Merchant_Service__c> List of Merchant Service Records.
     * @param accountIds - account Ids to search.
     */
    public List<Merchant_Service__c> queryActiveDriveServicesWithDraftOrderProductsByAccountId(
        Set<Id> accountIds
    ) {
        return Database.query(
            newQueryFactory()
                .selectField('Account__r.Proposed_Date_of_Activation__c')
                .selectField('Order_Product__r.Product_Code__c')
                .selectField('Order_Product__r.SBQQ__Status__c')
                .selectField('Order_Product__r.Order.Id')
                .selectField('Order_Product__r.Order.EffectiveDate')
                .selectField('Subscription__r.Subscription_Rate_Change__c')
                .selectField('Active_Rates_Applied__c')
                .selectField('Order_Product__r.Existing_Store_Processed__c')
                .setCondition(
                    'Active__c = :ACTIVE_YES' +
                        ' AND Account__c IN :accountIds' +
                        ' AND Order_Product__r.SBQQ__Status__c = :STATUS_DRAFT' +
                        ' AND Order_Product__r.Product_Code__c LIKE :DRIVE_PRODUCT_CODES'
                )
                .toSOQL()
        );
    }

    /**
     * @description This method id for getting object type
     * @return Merchant_Service__c Object type
     */

    public Schema.SObjectType getSObjectType() {
        return Merchant_Service__c.SObjectType;
    }

    /**
     * @description It is used for getting Accounts Ids linked to Merchant Services
     * based on the passed Subscription ids.
     * @param subIds
     * @return Aggregate[]
     */
    public Aggregate[] selectServicesBySubIdsGroupedByAccount(Set<Id> subIds) {
        String merchantServiceQuery =
            SELECT_CLAUSE +
            ACCOUNT_AGGREGATE_QUERY_FIELDS +
            WHERE_CLAUSE +
            ACCOUNT_AGGREGATE_QUERY_FILTER_BY_FIELD +
            ACCOUNT_AGGREGATE_QUERY_FILTER_CONDITION +
            GROUP_BY_CLAUSE +
            ACCOUNT_AGGREGATE_QUERY_GROUP_BY_FIELDS;
        AggregateResult[] serviceAggregateCountQueryResult = (List<AggregateResult>) Database.Query(
            String.escapeSingleQuotes(merchantServiceQuery)
        );
        return Aggregate.convertResults(serviceAggregateCountQueryResult);
    }

    /**
     * @description It queries Merchant Services based on the associated Account
     * with product name as Alcohol Delivery or Alcohol Pickup.
     * @param accountIds
     * @return List<Merchant_Service__c>
     */
    public List<Merchant_Service__c> selectServicesWithAlcoholProductsByAccountIds(
        Set<Id> accountIds
    ) {
        /* It is used for validating Services associated with store or business Account
         * populated on Work Orders.
         * Store readiness can be run by any user which may not have access to
         * the objects used in the query.
         * Store readiness check runs in the background and does not expose any
         * encrypted/confidential data on UI.
         * Caution: DO NOT use this query for UI related scenarios.
         */
        ignoreCRUD();
        fflib_QueryFactory merchantServicesQuery = newQueryFactory()
            .setCondition(
                'Active__c = :ACTIVE_YES AND Product__r.Name IN :ALCOHOL_PRODUCT_NAMES' +
                ' AND Account__c IN :accountIds'
            );
        return (List<Merchant_Service__c>) Database.query(merchantServicesQuery.toSOQL());
    }

    /**
     * @description returns active services by account Ids.
     * @JIRA #LEM-15980
     * @return List<Merchant_Service__c> List of Merchant Service Records.
     * @param accountIds - account Ids to search.
     @param contractIds - account Ids to search.
     */
    public List<Merchant_Service__c> selectActiveServicesByAccountIds(
        Set<Id> accountIds,
        Set<Id> contractIds
    ) {
        return Database.query(
            newQueryFactory()
                .selectField('Mx_Agreed_to_Product__c')
                .selectField('Account__c')
                .setCondition(
                    'Active__c = :ACTIVE_YES AND Account__c IN :accountIds AND Subscription__r.SBQQ__Contract__c IN :contractIds'
                )
                .toSOQL()
        );
    }

    /**
     * @description It is for getting the records on Merchant Service object
     * @param businessAccountId
     * @param contractId
     * @return Merchant_Service__c
     */
    public List<Merchant_Service__c> selectMerchantServiceToShowUnderContractsAmendment(
        Id businessAccountId,
        Id contractId
    ) {
        fflib_QueryFactory merchantServicesQuery = newQueryFactory(false)
            .selectField('Account__c')
            .selectField('Account__r.Name')
            .selectField('Service_Product_Name__c')
            .selectField('Product__c')
            .selectField('Name')
            .selectField('Bundle__c')
            .selectField('Active__c')
            .selectField('Mx_Agreed_to_Product__c')
            .selectField('Trial_Commission__c')
            .selectField('Trial_Fee__c')
            .selectField('Final_Commission__c')
            .selectField('Final_Fee__c')
            .selectField('Start_Date__c')
            .setCondition(
                'Account__r.ParentId  = :businessAccountId AND Subscription__r.SBQQ__Contract__c =: contractId AND Active__c =:ACTIVE_YES'
            )
            .setOrdering('Account__r.CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING)
            .addOrdering('Account__c', fflib_QueryFactory.SortOrder.DESCENDING)
            .addOrdering('Subscription__r.Sort_Order__c', fflib_QueryFactory.SortOrder.ASCENDING);

        return (List<Merchant_Service__c>) Database.query(merchantServicesQuery.toSOQL());
    }

    /**
     * @description It is used to fetch churned merchant services by the passed contract ids.
     * @JIRA #LEM-23780
     * @param contractIds
     * @return List<Merchant_Service__c>
     */
    public List<Merchant_Service__c> selectChurnedMxServicesByContractIds(Set<Id> contractIds) {
        return Database.query(
            newQueryFactory(false)
                .selectField('Account__c')
                .setCondition('Subscription__r.SBQQ__Contract__c IN :contractIds')
                .toSOQL()
        );
    }
}