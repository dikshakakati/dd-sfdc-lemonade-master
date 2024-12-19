/**
 * @author Deloitte
 * @date 10/10/2024
 * @description Interface Class for Approver Object
 */
public interface IApproversSelector extends fflib_ISObjectSelector {
    /**
     * @description It is used to get Approvers based on passed user ids.
     * @param userIds
     * @return List<sbaa__Approver__c>
     */
    List<sbaa__Approver__c> selectByUserIds(Set<Id> userIds);
}