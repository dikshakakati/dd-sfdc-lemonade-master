/**
 * @author Deloitte
 * @date 06/13/2024
 * @description Interface to add Selector class methods.
 */
public interface ISolutionsSelector extends fflib_ISObjectSelector {
    /**
     * @description It is used to get the active Solutions by passed vsp codes.
     * @return List<Campaign_Product__c>
     */
    List<Campaign_Product__c> selectActiveSolutionsByVSPCodes();
}