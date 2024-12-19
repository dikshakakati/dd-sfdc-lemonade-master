/**
 * @author Deloitte
 * @date 06/06/2024
 * @description Interface for Stakeholder selector.
 */
public interface IStakeholdersSelector extends fflib_ISObjectSelector {
    /**
     * @description It gets count of Stakeholders filtered by and grouped by
     * passed Mx Touchpoint Ids.
     * @param mxTouchpointIds
     * @return Aggregate[]
     */
    Aggregate[] getStakeholdersCountFilteredAndGroupedByMxTouchpointIds(Set<Id> mxTouchpointIds);

    /**
     * @description It fetches Stakeholders having Contacts by passed set of
     * Mx Touchpoint Ids.
     * @param mxTouchpointIds
     * @return List<Stakeholder__c>
     */
    List<Stakeholder__c> getStakeholderContactsByMxTouchPointIds(Set<Id> mxTouchpointIds);
    /**
     * @description It fetches Stakeholders having users by passed set of
     * Mx Touchpoint Ids.
     * @param mxTouchpointIds
     * @return List<Stakeholder__c>
     */
    List<Stakeholder__c> getStakeholderUsersByMxTouchPointIds(Set<Id> mxTouchpointIds);
}