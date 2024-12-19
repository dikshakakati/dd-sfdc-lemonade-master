/**
 * @author Deloitte
 * @date 04/25/2024
 * @description Selector Class for Product Options
 */
public inherited sharing class ProductOptionsSelector extends fflib_SObjectSelector implements IProductOptionsSelector {
    /**
     * @description Default Constructor for the Product Options Selector Class
     * @return IProductOptionsSelector - Interface of IProductOptionsSelector
     */
    public static IProductOptionsSelector newInstance() {
        return (IProductOptionsSelector) Application.Selector.newInstance(
            Mx_Order_Product_Option__c.SObjectType
        );
    }

    /**
     * @description This method is used for getting fields on Product Options Object
     * @return List of Schema.SObjectField
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Mx_Order_Product_Option__c.Id,
            Mx_Order_Product_Option__c.Name,
            Mx_Order_Product_Option__c.Product__c,
            Mx_Order_Product_Option__c.Product_Option_Name__c,
            Mx_Order_Product_Option__c.Mx_Order_Product_Bundle__c
        };
    }

    /**
     * @description This method is used for getting Object Type
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Mx_Order_Product_Option__c.SObjectType;
    }

    /**
     * @description This method is used for getting Product Options based on Id
     * @param setIds
     * @return list of Insight records
     */
    public List<Mx_Order_Product_Option__c> selectById(Set<Id> setIds) {
        return (List<Mx_Order_Product_Option__c>) selectSObjectsById(setIds);
    }

    /**
     * @description Query for all Product Options records present in the system
     * @param productBundleIds
     * @return List<Mx_Order_Product_Option__c>
     */
    public List<Mx_Order_Product_Option__c> selectProductOptionsByProductBundle(
        Set<Id> productBundleIds
    ) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('Name');
        query.selectField('Product_Option_Name__c');
        query.selectField('Product__c');
        query.selectField('Product__r.Name');
        query.selectField('Mx_Order_Product_Bundle__c');
        query.selectField('Product__r.Family');
        query.selectField('Product__r.CurrencyIsoCode');
        query.selectField('Product__r.Language__c');
        query.selectfield('Assigned_Vendor__c');
        query.setCondition('Mx_Order_Product_Bundle__c IN :productBundleIds');
        return (List<Mx_Order_Product_Option__c>) Database.query(query.toSOQL());
    }
}