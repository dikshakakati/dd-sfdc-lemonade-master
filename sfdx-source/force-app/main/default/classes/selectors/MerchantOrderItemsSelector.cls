/**
 * @author Deloitte
 * @date 04/23/2024
 * @description Selector class for Merchant Order Items object.
 */
public inherited sharing class MerchantOrderItemsSelector extends fflib_SObjectSelector implements IMerchantOrderItemsSelector {
    private static final String MX_ORDER_TYPE_OF_REQUEST_NET_NEW = 'Net-New';

    /**
     * @description Default constructor for the class
     * @return IMerchantOrderItemsSelector
     */
    public static IMerchantOrderItemsSelector newInstance() {
        return (IMerchantOrderItemsSelector) Application.Selector.newInstance(
            MX_Order_Item__c.SObjectType
        );
    }

    /**
     * @description Overriding default getSObjectType method
     * @return SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return MX_Order_Item__c.SObjectType;
    }

    /**
     * @description This method is for getting the fields on Merchant Order Items.
     * @JIRA# LEM-13506
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            MX_Order_Item__c.Identifier__c,
            MX_Order_Item__c.Legacy_ID__c,
            MX_Order_Item__c.Mx_Order__c,
            MX_Order_Item__c.Name,
            MX_Order_Item__c.Product__c,
            MX_Order_Item__c.Product_Bundle__c,
            MX_Order_Item__c.Product_Family__c,
            MX_Order_Item__c.Quantity__c,
            MX_Order_Item__c.SKU__c,
            MX_Order_Item__c.Password__c,
            MX_Order_Item__c.Username__c,
            MX_Order_Item__c.Identifier__c
        };
    }

    /**
     * @description It queries Merchant Orders Items with related details
     * based on passed Tablet Merchant Order Ids.
     * @JIRA# LEM-15028
     * @param mxOrderIds
     * @return List<MX_Order_Item__c>
     */
    public List<MX_Order_Item__c> selectMxOrderItemWithMxOrderIds(Set<Id> mxOrderIds) {
        fflib_QueryFactory mxOrderItemQuery = newQueryFactory(false)
            .selectField('Mx_Order__c')
            .selectField('Mx_Order__r.Vendor_Order_ID__c')
            .selectField('Identifier__c')
            .setCondition('Mx_Order__c IN :mxOrderIds');

        return (List<MX_Order_Item__c>) Database.query(mxOrderItemQuery.toSOQL());
    }
    /**
     * @description It queries Merchant Orders Items with related details
     * based on Identifier.
     * @JIRA# LEM-15028
     * @param identifierValues
     * @return List<MX_Order_Item__c>
     */
    public List<MX_Order_Item__c> selectMxOrderItemWithIdentifiers(Set<String> identifierValues) {
        fflib_QueryFactory mxOrderItemQuery = newQueryFactory(false)
            .selectField('Mx_Order__r.Vendor_Order_ID__c')
            .selectField('Mx_Order__r.Type_Of_Request__c')
            .selectField('Mx_Order__c')
            .selectField('Identifier__c')
            .setCondition(
                'Identifier__c IN :identifierValues AND Mx_Order__r.Type_Of_Request__c = :MX_ORDER_TYPE_OF_REQUEST_NET_NEW'
            );

        return (List<MX_Order_Item__c>) Database.query(mxOrderItemQuery.toSOQL());
    }
    /**
     * @description It queries Merchant Orders Items with related details
     * based on Identifier.
     * @JIRA# LEM-15028
     * @param identifierValues
     * @param types
     * @return List<MX_Order_Item__c>
     */
    public List<MX_Order_Item__c> selectMxOrderItemWithIdentifiersAndTypes(
        Set<String> identifierValues,
        Set<String> types
    ) {
        fflib_QueryFactory mxOrderItemQuery = newQueryFactory(false)
            .selectField('Mx_Order__r.Vendor_Order_ID__c')
            .selectField('Mx_Order__r.Type_Of_Request__c')
            .selectField('Mx_Order__c')
            .selectField('Product__c')
            .selectField('Product__r.Family')
            .selectField('Identifier__c')
            .setCondition(
                'Identifier__c IN :identifierValues AND Mx_Order__r.Type_Of_Request__c IN :types'
            )
            .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING);

        return (List<MX_Order_Item__c>) Database.query(mxOrderItemQuery.toSOQL());
    }
}