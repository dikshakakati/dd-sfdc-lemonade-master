/**
 * @author Aethereus
 * @date 03/06/2024
 * @description Selector Class for Products Object
 */
public inherited sharing class ProductsSelector extends fflib_SObjectSelector implements IProductsSelector {
    /**
     * @description New instance method to call application selector
     * @param Product2.SObjectType - Products object type
     * @return IProductsSelector - interface of IProductsSelector
     */
    public static IProductsSelector newInstance() {
        return (IProductsSelector) Application.Selector.newInstance(
            Product2.SObjectType
        );
    }

    /**
     * @description This method is for getting the fields on Products object
     * @return Products object fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Product2.Id
        };
    }

    /**
     * @description This method id for getting object type
     * @return Products Object type
     */
    public Schema.SObjectType getSObjectType() {
        return Product2.SObjectType;
    }

    /**
     * @description This method is for getting Products based on the provided Product Name
     * @return List<Product2>
     * @param productName - Products Name
     */
    public List<Product2> selectProductByProductName(Set<String> productName) {
        fflib_QueryFactory groupQuery = newQueryFactory();
        groupQuery.setCondition('Name = :productName');
        return (List<Product2>) Database.query(groupQuery.toSOQL());
    }

}