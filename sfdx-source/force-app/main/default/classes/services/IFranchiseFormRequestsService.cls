/**
 * @author Deloitte
 * @date 09/11/2023
 * @description Interface for service class for Franchise Form Requests related logic.
 */
public interface IFranchiseFormRequestsService {
    /**
     * @description It is used to expire the approved Withholding Opt-out Franchise Form Request records
     * by updating the field 'Disable Mx Form Submission For This URL' to true
     * where the 'Number of Days to Opt out' is 0 on the corporate Account.
     * @param franchiseFormsToExpire
     */
    void expireWithholdingOptOutFranchiseForms(
        List<Merchant_Pop_Up_Response__c> franchiseFormsToExpire
    );
}