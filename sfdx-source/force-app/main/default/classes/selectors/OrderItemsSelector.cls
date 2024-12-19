/**
 * @author atg
 * @date 05/25/2022
 * @description Selector class for OrderItems object.
 */
public inherited sharing class OrderItemsSelector extends fflib_SObjectSelector implements IOrderItemsSelector {
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final String ACTIVATION_ORDER_RECORD_TYPE_ID = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName()
        .get('Activation_Order')
        .getRecordTypeId();
    private static final String ACCOUNT_CONTRACT_AGGREGATE_COUNT_QUERY_FIELDS = 'COUNT(Id) orderItemsCount, Order.AccountId parentAccountId, SBQQ__Contract__c contractId';
    private static final String ACCOUNT_CONTRACT_AGGREGATE_COUNT_QUERY_GROUP_BY_FIELDS = 'Order.AccountId, SBQQ__Contract__c';
    private static final String ACCOUNT_CONTRACT_AGGREGATE_QUERY_FILTER_CONDITION = ' IN :orderItemIds AND SBQQ__Contract__c != null AND Order.RecordTypeId = :PRIMARY_ORDER_RECORD_TYPE_ID AND Order.Account.Record_Type_Name__c = :ACCOUNT_RECORD_TYPE_NAME_BUSINESS';
    private static final String ACCOUNT_CONTRACT_AGGREGATE_QUERY_FILTER_BY_FIELD = 'Id';
    private static final String EXISTING = 'Existing';
    private static final String GROUP_BY_CLAUSE = ' GROUP BY ';
    private static final Set<String> NON_ELIGIBLE_INTEGRATION_SOURCE = new Set<String>{
        'Mx Portal',
        'SSMO',
        'SSOB',
        'RESSMO'
    };
    private static final String ORDER_TYPE_CORE = 'Core';
    private static final String ORDER_TYPE_ADDS_AND_PROMO = 'A&P';
    private static final String PRIMARY_ORDER_RECORD_TYPE_ID = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName()
        .get('Primary_Order')
        .getRecordTypeId();
    private static final String PRODUCT_NAME_ALCOHOL_DELIVERY = 'Alcohol Delivery';
    private static final String PRODUCT_NAME_ALCOHOL_PICKUP = 'Alcohol Pickup';
    private static final String PRODUCT_NAME_MARKETPLACE = 'Marketplace';
    private static final Set<String> PRODUCT_BACK_END_SYSTEMS = new Set<String>{
        'MDS',
        'DriveDB',
        'MDS - Catering'
    };
    private static final String SELECT_CLAUSE = 'SELECT ';
    private static final String SEGMENT_TYPE_SMB = 'SMB';
    private static final String WHERE_CLAUSE = ' FROM OrderItem WHERE ';
    private static final Set<String> CORE_ORDER_SUB_TYPES = new Set<String>{
        'Upgrade',
        'Downgrade'
    };
    private static final Set<String> ADDS_AND_PROMO_SUB_TYPES = new Set<String>{
        'Upgrade',
        'Ads & Promos'
    };

    /**
     * @description default constructor for the OrderItem Selector class
     * @return IOrderItemsSelector - interface of IOrderItemsSelector
     */
    public static IOrderItemsSelector newInstance() {
        return (IOrderItemsSelector) Application.Selector.newInstance(OrderItem.SObjectType);
    }

    /**
     * @description This method is for getting the fields on OrderItem object
     * @return List of Schema.SObjectField
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            OrderItem.Id,
            OrderItem.OrderId,
            OrderItem.Product2Id,
            OrderItem.SBQQ__Contract__c,
            OrderItem.Quote_Line_Group__c,
            OrderItem.Split_Category__c
        };
    }

    /**
     * @description This method is used for getting Object type
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return OrderItem.SObjectType;
    }

    /**
     * @description This method is used for getting Sobject type Id, LEM-5922
     * @param idSet
     * @return List<OrderItem>
     */
    public List<OrderItem> selectById(Set<Id> idSet) {
        return (List<OrderItem>) selectSObjectsById(idSet);
    }

    /**
     * @description It is used for getting Account and Contract Ids linked to Order Products
     * associated to Primary Orders based on the passed Order Product Ids.
     * @JIRA# LEM-4005
     * @param orderItemIds
     * @return Aggregate[]
     */
    public Aggregate[] selectByIdsGroupedByAccountContractIds(Set<Id> orderItemIds) {
        String orderItemsQuery =
            SELECT_CLAUSE +
            ACCOUNT_CONTRACT_AGGREGATE_COUNT_QUERY_FIELDS +
            WHERE_CLAUSE +
            ACCOUNT_CONTRACT_AGGREGATE_QUERY_FILTER_BY_FIELD +
            ACCOUNT_CONTRACT_AGGREGATE_QUERY_FILTER_CONDITION +
            GROUP_BY_CLAUSE +
            ACCOUNT_CONTRACT_AGGREGATE_COUNT_QUERY_GROUP_BY_FIELDS;
        AggregateResult[] orderItemAggregateCountQueryResult = (List<AggregateResult>) Database.Query(
            String.escapeSingleQuotes(orderItemsQuery)
        );
        return Aggregate.convertResults(orderItemAggregateCountQueryResult);
    }

    /**
     * @description This method is used for getting OrderItems based on Id

     * @param fieldSet - name of the field set to read the fields from
     * @param setIds - Set of Ids
     * @return List of OrderItem
     */
    public List<OrderItem> selectOrderItemFieldSetById(Schema.FieldSet fieldSet, Set<Id> setIds) {
        if (setIds.IsEmpty()) {
            return new List<OrderItem>();
        }
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('Subscription_Rate_Change__c');
        query.selectField('Subscription_Rate_Change__r.Rate_Change_Request__c');
        query.selectField('Product2.Name');
        query.selectField('Product2.Package_Eligible_For_Nintex_Options__c');
        query.selectField('OrderItem_Type__c');
        query.selectField('Unique_Identifier__c');
        query.selectField('SBQQ__BundleRoot__c');
        query.selectField('SBQQ__RequiredBy__c');
        query.selectField('SBQQ__BundleRoot__r.Product2.Name');
        query.selectField('SBQQ__BundleRoot__r.Product_Code__c');
        query.selectField('SBQQ__BundleRoot__r.Product2.Package_Eligible_For_Nintex_Options__c');
        query.selectField('SBQQ__RequiredBy__r.Product_Code__c');
        query.selectField('SBQQ__RequiredBy__r.OrderItem_Type__c');
        query.selectField('SBQQ__QuoteLine__r.Package_Code__c');
        query.selectField('Product_Code__c');
        query.selectFieldSet(fieldSet);
        query.setCondition('Id IN: setIds');

        return (List<OrderItem>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used for getting activated OrderItems based on passed Ids.
     * @param orderItemIds
     * @param isManagePricingProcess
     * @return List<OrderItem>
     */
    public List<OrderItem> selectActivatedOrderItemsById(
        Set<Id> orderItemIds,
        Boolean isManagePricingProcess
    ) {
        String workOrderCondition;
        if (isManagePricingProcess) {
            workOrderCondition = 'AND SBQQ__RequiredBy__r.Product2.Work_Order_Type__c != null';
        } else {
            workOrderCondition =
                'AND (Product2.Work_Order_Type__c != null' +
                ' OR SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__Product__r.Work_Order_Type__c != null)';
        }
        fflib_QueryFactory orderItemsQuery = newQueryFactory(false)
            .selectField('Id')
            .selectField('OrderId')
            .selectField('Order.AccountId')
            .selectField('Order.Account.Activated_Centrally_AC__c')
            .selectField('Order.Account.Address_Verification_Status__c')
            .selectField('Order.Account.Coverage__c')
            .selectField('Order.Account.Data_Verification_Status__c')
            .selectField('Order.Account.Disallow_PDOA_Override__c')
            .selectField('Order.Account.Drive_Nintex_Id__c')
            .selectField('Order.Account.Franchise_Parent__c')
            .selectField('Order.Account.Franchise_Parent__r.OwnerId')
            .selectField('Order.Account.Franchise_Parent__r.Owner.Email')
            .selectField('Order.Account.Marketplace_Nintex_Id__c')
            .selectField('Order.Account.Menu_Setup_Method__c')
            .selectField('Order.Account.Menu_to_be_Completed_By__c')
            .selectField('Order.Account.Name')
            .selectField('Order.Account.Order_Protocol__c')
            .selectField('Order.Account.OwnerId')
            .selectField('Order.Account.Owner.Email')
            .selectField('Order.Account.ParentId')
            .selectField('Order.Account.Parent.OwnerId')
            .selectField('Order.Account.Parent.Owner.Email')
            .selectField('Order.Account.Proposed_Date_of_Activation__c')
            .selectField('Order.Account.Proposed_Date_of_Tablet__c')
            .selectField('Order.Account.RecordType.Name')
            .selectField('Order.Account.Sales_Notes_for_Menu_Team__c')
            .selectField('Order.Account.User_Sets_PDOM_Value__c')
            .selectField('Order.Account.User_Sets_PDOT_Value__c')
            .selectField('Order.Account.Mx_Onboarding_Link_Id__c')
            .selectField('Order.Opportunity.Opportunity_Sub_Type__c')
            .selectField('Order.Opportunity.Marketplace_Nintex_Id__c')
            .selectField('Order.Opportunity.Drive_Nintex_Id__c')
            .selectField('Primary_Order_Product__c')
            .selectField('Primary_Order_Product__r.OrderId')
            .selectField('Primary_Order_Product__r.Order.Opportunity.Opportunity_Sub_Type__c')
            .selectField('Primary_Order_Product__r.SBQQ__Contract__c')
            .selectField('Primary_Order_Product__r.SBQQ__Contract__r.AccountId')
            .selectField('Primary_Order_Product__r.SBQQ__Contract__r.Account.OwnerId')
            .selectField(
                'Primary_Order_Product__r.SBQQ__Contract__r.Account.Proposed_Date_of_Activation__c'
            )
            .selectField('Product2.Name')
            .selectField('Product2.Work_Order_Type__c')
            .selectField('Product2.Work_Order_Sub_Type__c')
            .selectField(
                'SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__Product__r.Work_Order_Type__c'
            )
            .selectField(
                'SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__Product__r.Work_Order_Sub_Type__c'
            )
            .selectField('SBQQ__Contract__c')
            .selectField('SBQQ__Contract__r.AccountId')
            .selectField('SBQQ__Contract__r.Account.Proposed_Date_of_Activation__c')
            .selectField('Existing_Store_Processed__c')
            .setCondition(
                'Id IN :orderItemIds AND ' +
                    'Order.RecordTypeId = :ACTIVATION_ORDER_RECORD_TYPE_ID AND ' +
                    'Order.Account.RecordType.DeveloperName = :ACCOUNT_RECORD_TYPE_NAME_STORE ' +
                    workOrderCondition
            );
        return (List<OrderItem>) Database.query(orderItemsQuery.toSOQL());
    }

    /**
     * @description It is used for getting OrderItems where Product is either Alcohol
     * Pickup or Delivery by the passed Account Ids.
     * @JIRA# LEM-1684
     * @param accountIds
     * @return List<OrderItem>
     */
    public List<OrderItem> selectAlcoholDeliveryOrPickupOrderItemsByAccountIds(Set<Id> accountIds) {
        /* It allows running store readiness check related to Products associated
         * with business Accounts of parent Work Orders.
         * Store readiness can be run by any user which may not have access to
         * the objects used in the query.
         * Store readiness check runs in the background and does not expose any data on UI.
         * Caution: DO NOT use this query for UI related scenarios.
         */
        ignoreCRUD();
        fflib_QueryFactory orderItemsQuery = newQueryFactory(false)
            .selectField('Id')
            .selectField('Order.AccountId')
            .selectField('Product2.Name')
            .setCondition(
                'Order.AccountId IN :accountIds AND' +
                    ' Order.RecordTypeId = :PRIMARY_ORDER_RECORD_TYPE_ID AND ' +
                    ' Order.Account.RecordType.Name = :ACCOUNT_RECORD_TYPE_NAME_BUSINESS AND ' +
                    ' (Product2.Name = :PRODUCT_NAME_ALCOHOL_DELIVERY OR' +
                    ' Product2.Name = :PRODUCT_NAME_ALCOHOL_PICKUP)'
            );
        return (List<OrderItem>) Database.query(orderItemsQuery.toSOQL());
    }

    /**
     * @description It is used for getting OrderItems where based on the Product
     * BackEnd Systems for the given orderItemIds
     * @JIRA# LEM-2307
     * @param orderIds
     * @return List<OrderItem>
     */
    public List<OrderItem> selectProductBackEndByOrderItemIds(Set<Id> orderIds) {
        fflib_QueryFactory orderItemsQuery = newQueryFactory()
            .selectField('Product2.Backend_System__c')
            .setCondition(
                'OrderId IN :orderIds AND ' +
                    ' Order.RecordTypeId = :ACTIVATION_ORDER_RECORD_TYPE_ID AND ' +
                    ' Product2.Backend_System__c IN : PRODUCT_BACK_END_SYSTEMS'
            );
        return (List<OrderItem>) Database.query(orderItemsQuery.toSOQL());
    }

    /**
     * @description It is used for getting activated Order Products along with Primary Order Product
     * details based on passed Account Ids and productTypes.
     * @param storeAccountIds
     * @param productTypes
     * @return List<OrderItem>
     */
    public List<OrderItem> selectActivatedOrderItemsByAccountIdsAndProductTypes(
        Set<Id> storeAccountIds,
        Set<String> productTypes
    ) {
        /* It allows to validate Order Products associated with store Account
         * through "Add Stores" functionality in the O&A persona's context
         * without assigning QTC permissions and CPQ license.
         * The fetched data is used for the back-end logic only and not exposed on UI.
         */
        ignoreCRUD();
        fflib_QueryFactory orderItemsQuery = newQueryFactory(false)
            .selectField('Id')
            .selectField('OrderId')
            .selectField('Primary_Order_Product__c')
            .selectField('Primary_Order_Product__r.OrderId')
            .selectField('Order.AccountId')
            .selectField('Product2.Work_Order_Type__c')
            .selectField('Existing_Store_Processed__c')
            .setCondition(
                'Order.AccountId IN :storeAccountIds AND ' +
                    ' Order.RecordTypeId = :ACTIVATION_ORDER_RECORD_TYPE_ID AND ' +
                    ' Order.Account.RecordType.DeveloperName = :ACCOUNT_RECORD_TYPE_NAME_STORE AND ' +
                    ' Product2.Work_Order_Type__c IN :productTypes'
            );
        return (List<OrderItem>) Database.query(orderItemsQuery.toSOQL());
    }

    /**
     * @description It is used for getting activated Order Products associated with store Account
     * based on passed Account Ids.
     * @param storeAccountIds
     * @return List<OrderItem>
     */
    public List<OrderItem> selectActivatedOrderItemsByAccountIds(Set<Id> storeAccountIds) {
        /* It allows to validate Order Products associated with store Account
         * through "Onboarding Details" functionality in the O&A persona's context
         * without assigning QTC permissions and CPQ license.
         * The fetched data is used for the back-end logic only and not exposed on UI.
         */
        ignoreCRUD();
        fflib_QueryFactory orderItemsQuery = newQueryFactory(false)
            .selectField('Id')
            .selectField('SBQQ__Contract__c')
            .setCondition(
                'Order.AccountId IN :storeAccountIds AND ' +
                    ' Order.RecordTypeId = :ACTIVATION_ORDER_RECORD_TYPE_ID AND ' +
                    ' Order.Account.RecordType.DeveloperName = :ACCOUNT_RECORD_TYPE_NAME_STORE'
            );
        return (List<OrderItem>) Database.query(orderItemsQuery.toSOQL());
    }

    /**
     * @description It is used for getting Order Products by the passed Order Ids
     * where 'Work Order Type' is populated on the associated product.
     * @JIRA# LEM-3564
     * @param orderIds
     * @return List<OrderItem>
     */
    public List<OrderItem> selectOrderItemsWithProductWorkOrderTypeMappingByOrderIds(
        Set<Id> orderIds
    ) {
        fflib_QueryFactory orderItemsQuery = newQueryFactory()
            .selectField('Order.Id')
            .selectField('Product2.Work_Order_Type__c')
            .selectField('Product2.Work_Order_Sub_Type__c')
            .setCondition('OrderId IN :orderIds AND Product2.Work_Order_Type__c != null');
        return (List<OrderItem>) Database.query(orderItemsQuery.toSOQL());
    }

    /**
     * @description It is used for getting Primary Order Products by the passed Order Ids
     * @param orderItemIds
     * @return List<OrderItem>
     */
    public List<OrderItem> selectPrimaryOrderItemsByIds(Set<Id> orderItemIds) {
        fflib_QueryFactory orderItemsQuery = newQueryFactory()
            .selectField('Order.Id')
            .selectField('Order.RecordTypeId')
            .selectField('Active_fee__c')
            .selectField('Active_Commission__c')
            .setCondition(
                'Id IN :orderItemIds AND Order.RecordTypeId = :PRIMARY_ORDER_RECORD_TYPE_ID'
            );
        return (List<OrderItem>) Database.query(orderItemsQuery.toSOQL());
    }

    /**
     * @description It is used for getting Order Products by the passed Order Ids
     * where order type is primary order
     * @param orderItemIds
     * @return List<OrderItem>
     */
    public List<OrderItem> selectOrderItemsWithPrimaryOrderFields(Set<Id> orderItemIds) {
        fflib_QueryFactory orderItemsQuery = newQueryFactory()
            .selectField('SBQQ__QuoteLine__c')
            .selectField('SBQQ__QuoteLine__r.SBQQ__Group__c')
            .selectField('SBQQ__QuoteLine__r.SBQQ__Group__r.CCP_Unique_Group_Id__c')
            .setCondition(
                'ID IN :orderItemIds ' +
                    'AND Order.RecordTypeId = :PRIMARY_ORDER_RECORD_TYPE_ID ' +
                    'AND SBQQ__QuoteLine__r.SBQQ__Group__c != NULL'
            );
        return (List<OrderItem>) Database.query(orderItemsQuery.toSOQL());
    }

    /**
     * @description It is used for getting Order Items for Amendments by the passed Order Ids.
     * @param orderIds
     * @return List<OrderItem>
     */
    public List<OrderItem> selectAmendedOrderItems(Set<Id> orderIds) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Order.Opportunity.AccountId')
            .selectField('Order.Opportunity.Opportunity_Sub_Type__c')
            .selectField('Order.Opportunity.ContractId')
            .selectField('Order.OpportunityId')
            .selectField('Order.Type')
            .selectField('order.SBQQ__Quote__c')
            .selectField('order.SBQQ__Quote__r.Integration_Source__c')
            .selectField('OrderId')
            .selectField('Package__c')
            .selectField('Product2.Family')
            .setCondition(
                '(OrderId IN :orderIds AND Order.Opportunity.Type = :EXISTING AND ' +
                    'Package__c = null AND Product2.Family != null AND Order.Opportunity.Account.Segment__c = :SEGMENT_TYPE_SMB ' +
                    'AND ((Order.Type = :ORDER_TYPE_CORE AND Order.Opportunity.Opportunity_Sub_Type__c IN :CORE_ORDER_SUB_TYPES) ' +
                    'OR (Order.Type = :ORDER_TYPE_ADDS_AND_PROMO AND Order.Opportunity.Opportunity_Sub_Type__c IN :ADDS_AND_PROMO_SUB_TYPES)))'
            );
        return (List<OrderItem>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used for querying Order Items for the passed Order Ids.
     * @param orderIds
     * @return List<OrderItem>
     */
    public List<OrderItem> selectOrderItemsByOrderIds(Set<Id> orderIds) {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectField('Package__c')
            .selectField('Product2.Family')
            .selectField('OrderId')
            .setCondition(
                '(OrderId IN :orderIds)'
            );
        return (List<OrderItem>) Database.query(query.toSOQL());
    }
}
