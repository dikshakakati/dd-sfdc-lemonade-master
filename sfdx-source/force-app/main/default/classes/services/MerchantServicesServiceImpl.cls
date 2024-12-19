/**
 * @author Deloitte
 * @date 07/02/2024
 * @description Service implementation class for MerchantServices related logic.
 */
public inherited sharing class MerchantServicesServiceImpl implements IMerchantServicesService {
    private static final String MX_AGREED_TO_PRODUCT_NO = 'No';
    /**
     * @description Sets the Mx Agreed to Product Field to No for flow
     * @JIRA #LEM-15980
     * @param agreementsList
     */
    public void setMxAgreedToProductValueNoFromFlow(List<List<Agreement__c>> agreementsList) {
        if (agreementsList == null || agreementsList.isEmpty()) {
            return;
        }
        List<Agreement__c> allAgreementsList = new List<Agreement__c>();

        for (List<Agreement__c> eachAgreement : agreementsList) {
            allAgreementsList.addAll(eachAgreement);
        }

        if (allAgreementsList == null) {
            return;
        }
        AgreementsService.updateMxServicesBasedOnRecordsCount(allAgreementsList, true);
    }

    /**
     * @description Sets the Mx Agreed to Product Field to No
     * @JIRA #LEM-15980
     * @param mxServicesList mxServicesList
     * @param allAccountIdSet
     */
    public void setMxAgreedToProductValueNo(
        List<Merchant_Service__c> mxServicesList,
        Set<Id> allAccountIdSet
    ) {
        if (mxServicesList == null || mxServicesList.isEmpty()) {
            return;
        }
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Merchant_Service__c> mxServiceToBeUpdated = new List<Merchant_Service__c>();
        for (Merchant_Service__c mxservice : mxServicesList) {
            mxservice.Mx_Agreed_to_Product__c = MX_AGREED_TO_PRODUCT_NO;
            mxServiceToBeUpdated.add(mxservice);
        }
        if (mxServiceToBeUpdated != null) {
            uow.registerDirty(mxServiceToBeUpdated);
        }
        commitWork(uow);
        if (allAccountIdSet == null) {
            return;
        }
        AccountsService.updateFieldsOnAccount(allAccountIdSet);
    }

    /**
     * @description It is used to delete Merchant Services by the passed contract ids of churned
     * merchants.
     * @JIRA# LEM-23780
     * @param contractIds
     * @param uow
     * @return fflib_ISObjectUnitOfWork
     */
    public fflib_ISObjectUnitOfWork deleteChurnedMxServices(
        Set<Id> contractIds,
        fflib_ISObjectUnitOfWork uow
    ) {
        uow.registerDeleted(
            MerchantSelector.newInstance().selectChurnedMxServicesByContractIds(contractIds)
        );
        return uow;
    }

    /**
     * @description A common method to commit unit of work.
     * @param uow
     */
    private void commitWork(fflib_ISObjectUnitOfWork uow) {
        try {
            uow.commitWork();
        } catch (Exception e) {
            Logger.publish(e, LogEntry.SeverityLevel.HIGH);
        }
    }
}