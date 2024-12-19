/**
 * @author Deloitte
 * @date 09/11/2023
 * @description Service Implementation class for Franchise Form Requests related logic.
 */
public inherited sharing class FranchiseFormRequestsServiceImpl implements IFranchiseFormRequestsService {
    private static final String APPROVED = 'Approved';
    private fflib_ISObjectUnitOfWork uowInstance;

    /**
     * @description Default constructor for this class.
     */
    public FranchiseFormRequestsServiceImpl() {
        this.uowInstance = Application.UNITOFWORK.newInstance();
    }

    /**
     * @description It is used to expire the approved Withholding Opt-out Franchise Form Request records
     * by updating the field 'Disable Mx Form Submission For This URL' to true
     * where the 'Number of Days to Opt out' is 0 on the corporate Account.
     * @JIRA# LEM-9550
     * @param franchiseFormsToExpire
     */
    public void expireWithholdingOptOutFranchiseForms(
        List<Merchant_Pop_Up_Response__c> franchiseFormsToExpire
    ) {
        if (franchiseFormsToExpire.isEmpty()) {
            return;
        }
        for (Merchant_Pop_Up_Response__c eachFranchiseForm : franchiseFormsToExpire) {
            eachFranchiseForm.Disable_Mx_Form_Submission_For_This_URL__c = true;
            uowInstance.registerDirty(eachFranchiseForm);
        }
        commitWork(uowInstance);
    }

    /**
     * @description A common method to commit unit of work.
     * @JIRA# LEM-9497
     * @param unitOfWork
     */
    private void commitWork(fflib_ISObjectUnitOfWork unitOfWork) {
        try {
            unitOfWork.commitWork();
        } catch (Exception unitOfWorkException) {
            Logger.publish(
                LogEntry.newExceptionLog(unitOfWorkException, LogEntry.SeverityLevel.HIGH)
            );
        }
    }
}