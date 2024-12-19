/**
 * @author Deloitte
 * @date 16/08/2022
 * @description Domain inteface for Merchant Pop-Up Responses
 */
public interface IMerchantPopUpResponses extends fflib_ISObjects {
    /**
     * @description It initiates the update on corporate accounts to set
     * "Withholding Opt-out Expiry Date" for Franchise Form Requests with "Approval Status"
     * as 'Approved' and "Franchise Type" as 'Withholding Opt-out'.
     */
    void setWithholdingExpiryDateOnCorporateAccountsByEligibleFranchisFormRequests();

    /**
     * @description This method is used to set the business, store and payment account record type id
     */
    void updateRecordTypeIdsOnMerchantResponse();

    /**
     * @description This method is used to set latest COO exception emails on merchantresponse record.
     */
    void updateLatestCOOExceptionEmailListOnMerchantResponse();
}