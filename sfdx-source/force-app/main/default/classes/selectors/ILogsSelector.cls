/**
 * @author Deloitte
 * @date 01/11/2024
 * @description Interface for Logs selector class methods.
 */
public interface ILogsSelector extends fflib_ISObjectSelector {
    /**
     * @description It is used for querying Log__c records which satisfies the criteria to
     * send notification.
     * @param parentField
     * @param parentIds
     * @param secondaryParentFieldToExclude
     * @return List<Log__c>
     */
    List<Log__c> selectLogsEligibleToSendNotification(
        Schema.SObjectField parentField,
        Set<Id> parentIds,
        Schema.SObjectField secondaryParentFieldToExclude
    );
}