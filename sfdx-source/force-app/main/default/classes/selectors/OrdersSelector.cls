/**
 * @author DoorDash QTC
 * @date 07/31/2022
 * @description Selector class for Orders object.
 */
public inherited sharing class OrdersSelector extends fflib_SObjectSelector implements IOrdersSelector {
    private static final String ACTIVATION_ORDER_RECORD_TYPE_ID = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName()
        .get('Activation_Order')
        .getRecordTypeId();
    private static final String PRIMARY_ORDER_RECORD_TYPE_ID = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName()
        .get('Primary_Order')
        .getRecordTypeId();
    private static final String MARKETPLACE_PRODUCT_NAME = 'Marketplace';
    private static final String ORDERSTATUSDRAFT = 'Draft';
    private static final String SPLIT_CATEGORY_CORE = 'Core';

    /**
     * @description default constructor for the Order Selector class
     * @return IOrdersSelector - interface of IOrdersSelector
     */
    public static IOrdersSelector newInstance() {
        return (IOrdersSelector) Application.Selector.newInstance(Order.SObjectType);
    }

    /**
     * @description This method is for getting the fields on OrderItem object
     * @return List of Schema.SObjectField
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Order.Id,
            Order.Backend_Systems__c,
            Order.SBQQ__Quote__c,
            Order.EffectiveDate,
            Order.Type
        };
    }

    /**
     * @description This method is used for getting Object type
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Order.SObjectType;
    }

    /**
     * @description This method is used for getting Sobject type Id
     * @param idSet
     * @return List<Order>
     */
    public List<Order> selectById(Set<Id> idSet) {
        return (List<Order>) selectSObjectsById(idSet);
    }
    /**
     * @description This method is used for getting orders by quote Id
     * @param accountIds
     * @return List<Order>
     */
    public List<Order> selectOrdersByAccountIds(Set<Id> accountIds) {
        //added ignoreCRUD method to bypass CRUD permissions for Bulk Upload on Marketplace Work Order
        ignoreCRUD();
        fflib_QueryFactory query = newQueryFactory()
            .selectField('AccountId')
            .setCondition(
                'AccountId IN :accountIds AND RecordTypeId = :ACTIVATION_ORDER_RECORD_TYPE_ID'
            );
        return (List<Order>) Database.query(query.toSOQL());
    }
    /**
     * @description This method is used for getting orders by opportunity Id
     * @param opportunityIds
     * @return List<Order>
     */
    public List<Order> selectOrdersByOpportunityIds(Set<Id> opportunityIds) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('SBQQ__Quote__r.SBQQ__Opportunity2__c')
            .setCondition(
                'SBQQ__Quote__r.SBQQ__Opportunity2__c IN :opportunityIds AND ' +
                'RecordTypeId = :PRIMARY_ORDER_RECORD_TYPE_ID AND SBQQ__Quote__r.SBQQ__Primary__c = true'
            );
        return (List<Order>) Database.query(query.toSOQL());
    }
    /**
     * @description This method is used for getting orders by quote Id
     * @param accountIds
     * @return List<Order>
     */
    public List<Order> selectDraftActivationOrdersWithCxDeliverFeeOrderItemsByAccountIds(
        Set<Id> accountIds
    ) {
        //added ignoreCRUD method to bypass CRUD permissions for Bulk Upload on Marketplace Work Order
        ignoreCRUD();
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Status')
            .selectField('AccountId')
            .selectField('Pricing_Tier__c')
            .setCondition(
                'RecordTypeId = :ACTIVATION_ORDER_RECORD_TYPE_ID AND ' +
                    'Id IN (SELECT OrderId FROM OrderItem WHERE Product2.Family = :MARKETPLACE_PRODUCT_NAME AND ' +
                    'Order.AccountId IN :accountIds)'
            )
            .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING);
        return (List<Order>) Database.query(query.toSOQL());
    }
}