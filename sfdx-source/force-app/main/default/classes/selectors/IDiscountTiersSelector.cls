/**
 * @author Deloitte
 * @date 28/07/2024
 * @description Interface Class for Discount Tier Object
 */
public interface IDiscountTiersSelector extends fflib_ISObjectSelector {
    /**
     * @description This method is used for getting Disccount Tier based on UUID.
     * @param uniqueIdentifiersForSSOB
     * @return List<SBQQ__DiscountTier__c>
     */
    List<SBQQ__DiscountTier__c> selectByUUID(
        Set<String> uniqueIdentifiersForSSOB
    );
}