/**
 * @author Deloitte
 * @date 09/11/2023
 * @description Interface for Merchant_Pop_Up_Response__c selector class methods.
 */
public interface IFranchiseFormRequestsSelector extends fflib_ISObjectSelector {
    /**
     * @description It is used to get the approved Withholding Opt-out Franchise Form Request records
     * where the 'Number of Days to Opt-out' on corporate Account is 0.
     * @return Database.QueryLocator
     */
    Database.QueryLocator selectApprovedWithholdingOptOutFranchiseFormsToExpire();
}