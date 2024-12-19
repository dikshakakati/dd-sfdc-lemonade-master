/**
 * @author Deloitte
 * @date 09/11/2023
 * @description Service class for Franchise Form Requests related logic.
 */
public inherited sharing class FranchiseFormRequestsService {
    /**
     * @description It is used to expire the approved Withholding Opt-out Franchise Form Request records
     * by updating the field 'Disable Mx Form Submission For This URL' to true
     * where the 'Number of Days to Opt out' is 0 on the corporate Account.
     * @JIRA# LEM-9550
     * @param franchiseFormsToExpire
     */
    public static void expireWithholdingOptOutFranchiseForms(
        List<Merchant_Pop_Up_Response__c> franchiseFormsToExpire
    ) {
        service().expireWithholdingOptOutFranchiseForms(franchiseFormsToExpire);
    }

    /**
     * @description It creates instance of FranchiseFormRequestsServiceImpl class.
     * @return IFranchiseFormRequestsService - return instance of FranchiseFormRequestsServiceImpl
     */
    private static IFranchiseFormRequestsService service() {
        return (IFranchiseFormRequestsService) Application.Service.newInstance(
            IFranchiseFormRequestsService.class
        );
    }
}