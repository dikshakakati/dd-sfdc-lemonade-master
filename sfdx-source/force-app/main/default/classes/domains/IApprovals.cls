/**
 * @author Deloitte
 * @date 04/30/2024
 * @description Approvals interface to add domain class methods.
 */
public interface IApprovals extends fflib_ISObjects {
    /**
     * @description It is used to initiate the Advanced Approvals Approve/Reject REST API on
     * update of a custom field 'Approval Status' from Slack notification.
     * @param changedApprovals
     */
    void initiateAdvancedApprovalsAPI(List<sbaa__Approval__c> changedApprovals);

    /**
     * @description It is used to stamp the existing values on the fields 'Approval Status' and
     * 'Record Field' even though the value is changed by user in the slack notification.
     * @param existingApprovals
     */
    void updateApprovalFieldsWithExistingValues(Map<Id, SObject> existingApprovals);

    /**
     * @description It is used to stamp the Requesting Reason field value from Quote to it's related requested Approvals.
     */
    void updateRequestedReasonFromQuote();
}