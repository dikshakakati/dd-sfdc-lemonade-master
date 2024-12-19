/**
 * @author Deloitte
 * @date 04/25/2024
 * @description Interface for ProductOptionsSelector class
 */
public interface IProductOptionsSelector extends fflib_ISObjectSelector {
    /**
     * @description This method is used for getting Product Options based on Id
     * @param setIds
     * @return List of Options records
     */
    List<Mx_Order_Product_Option__c> selectById(Set<Id> setIds);

    /**
     * @description Query for all Product Options records present in the system
     * @param productBundleIds
     * @return List<Mx_Order_Product_Option__c>
     */
    List<Mx_Order_Product_Option__c> selectProductOptionsByProductBundle(Set<Id> productBundleIds);
}