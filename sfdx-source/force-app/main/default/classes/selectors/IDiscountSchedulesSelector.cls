/**
 * @author Deloitte
 * @date 28/07/2024
 * @description Interface Class for Discount Schedule Object
 */
public interface IDiscountSchedulesSelector extends fflib_ISObjectSelector {
    /**
     * @description This method is used for getting Disccount Schedule based on Product name.
     * @param optionProductNameWithProductDetails
     * @return List<SBQQ__DiscountSchedule__c>
     */
    List<SBQQ__DiscountSchedule__c> selectByProductName(
        Set<String> optionProductNameWithProductDetails
    );
}