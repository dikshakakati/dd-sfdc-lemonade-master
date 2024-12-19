/**
 * @author Deloitte
 * @date 04/25/2024
 * @description Selector Class for Product Bundle
 */
public inherited sharing class ProductBundlesSelector extends fflib_SObjectSelector implements IProductBundlesSelector {
    /**
     * @description Default Constructor for the Product Bundle Selector Class
     * @return IProductBundlesSelector - Interface of IProductBundlesSelector
     */
    public static IProductBundlesSelector newInstance() {
        return (IProductBundlesSelector) Application.Selector.newInstance(
            Mx_Order_Product_Bundle__c.SObjectType
        );
    }

    /**
     * @description This method is used for getting fields on Product Bundle Object
     * @return List of Schema.SObjectField
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Mx_Order_Product_Bundle__c.Id,
            Mx_Order_Product_Bundle__c.Name,
            Mx_Order_Product_Bundle__c.Bundle_Name__c
        };
    }

    /**
     * @description This method is used for getting Object Type
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Mx_Order_Product_Bundle__c.SObjectType;
    }

    /**
     * @description This method is used for getting Product Bundle based on Id
     * @param setIds
     * @return list of Mx_Order_Product_Bundle__c records
     */
    public List<Mx_Order_Product_Bundle__c> selectById(Set<Id> setIds) {
        return (List<Mx_Order_Product_Bundle__c>) selectSObjectsById(setIds);
    }

    /**
     * @description This method is used for getting Product Bundle based on Id
     * @param productBundleNames
     * @return list of Mx_Order_Product_Bundle__c records
     */
    public List<Mx_Order_Product_Bundle__c> selectByName(List<String> productBundleNames) {
        fflib_QueryFactory query = newQueryFactory().setCondition('Name IN :productBundleNames');
        return (List<Mx_Order_Product_Bundle__c>) Database.query(query.toSOQL());
    }
}