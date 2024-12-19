/**
 * @author Deloitte
 * @date 04/25/2024
 * @description Interface for ProductBundlesSelector class
 */
public interface IProductBundlesSelector extends fflib_ISObjectSelector {
    /**
     * @description This method is used for getting Product Bundle based on Id
     * @param setIds
     * @return List of Bundle records
     */
    List<Mx_Order_Product_Bundle__c> selectById(Set<Id> setIds);

    /**
    * @description This method is used for getting Product Bundle based on Id
    * @param productBundleNames
    * @return list of Mx_Order_Product_Bundle__c records
    */
    List<Mx_Order_Product_Bundle__c> selectByName(List<String> productBundleNames);

}