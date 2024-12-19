/**
 * @description Interface to add domain class methods
 * @author Deloitte
 * @date 17/05/2022
 */
public interface IMerchantServices extends fflib_ISObjects {
    /**
     * @description Filters out records with a given product family value in the set
     * @param strings Product Family name to filter out
     * @return Instance of IMerchantServices with remaining records
     */
    IMerchantServices filterByProductFamilyNotInSet(Set<String> strings);

    /**
     * @description Filters for records with a given product family value
     * @param strings Product Family name to filter for
     * @return Instance of IMerchantServices with remaining records
     */
    IMerchantServices filterByProductFamilyInSet(Set<String> strings);

    /**
     * @description Sets the Mx Agreed to Product Field to Yes
     * @param value available Values 'Yes' or 'No'
     * @return Instance of MerchantServices with the updated records
     */
    IMerchantServices setMxAgreedToProductValue(String value);

    /**
     * @description Filters for records with a given product family value
     * @param accountIdDeselectedServicesMap map of deselected services
     * @param useFranchiseParent determine the account by Franchise parent if true.
     * @return Instance of IMerchantServices with remaining records
     */
    IMerchantServices filterDeselectedServices(
        Map<Id, Map<String, String>> accountIdDeselectedServicesMap,
        Boolean useFranchiseParent
    );
    /**
     * @description publish notifier event to process payload
     */
    void publishNotifierEvent();
    
     /**
     * @description The method is used to deactivate the existing 
     * Merchant Services for Core Products in SMB when it is 
     * part of package exlusion.
     * @JIRA #LEM-16198
     */
    void inactivateExistingMxServicesOnCoreProducts();
}