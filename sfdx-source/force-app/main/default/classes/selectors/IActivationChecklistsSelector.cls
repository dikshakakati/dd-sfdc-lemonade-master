/**
 * @author Deloitte
 * @date 04/09/2024
 * @description Selector Interface for Activation Checklist object.
 */
public interface IActivationChecklistsSelector extends fflib_ISObjectSelector {
    /**
     * @description It is used to query all activation checklists by store ids
     * @param storeIds
     * @return List of Activation Checklist records
     */
    List<Activation_Checklist__c> selectByStoreIds(Set<Id> storeIds);
}