/**
 * @author Deloitte
 * @date 05/21/2024
 * @description Interface Class for CPQ Product Options
 */
public interface ICPQProductOptionsSelector extends fflib_ISObjectSelector {
    /**
     * @description This method is used for getting Product Options based on Product Ids passed.
     * @param optionalSKUNames
     * @param configuredSKUNames
     * @return List<SBQQ__ProductOption__c>
     */
    List<SBQQ__ProductOption__c> selectByProductNames(
        Set<String> optionalSKUNames,
        Set<String> configuredSKUNames
    );
}