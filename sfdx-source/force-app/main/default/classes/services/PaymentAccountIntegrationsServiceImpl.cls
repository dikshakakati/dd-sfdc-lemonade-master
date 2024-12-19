/**
 * @author Deloitte
 * @date 20/10/2022
 * @description Service implementation class for Payment_Account_Integration__e related logic.
 */
public inherited sharing class PaymentAccountIntegrationsServiceImpl implements IPaymentAccountIntegrationsService{
    /**
     * @description - Create platform events for selected payment account records.
     * @param paymentAccountIds - Set of Payment Account Ids
     * @return Boolean
     */
    public Boolean publishPaymentAccountIntegrationEvents(Set<Id> paymentAccountIds){
        fflib_ISObjectUnitOfWork eventUOW = Application.UNITOFWORK.newInstance();
        if(paymentAccountIds == null || paymentAccountIds.isEmpty()){
            return false;
        }
        createEvents(paymentAccountIds, eventUOW);
        return commitWork(eventUOW);
    }

    /**
     * @description Create instance of Unit of Work object for the selected payment account records.
     * and corresponding payload.
     * @param paymentAccountIds - Set of Payment Account Ids
     * @param uow - instance of UnitOfWork
     */
    private void createEvents(
        Set<Id> paymentAccountIds,
        fflib_ISObjectUnitOfWork uow){
        for(Id paymentAccountId : paymentAccountIds){
            uow.registerPublishAfterSuccessTransaction(
                new Payment_Account_Integration__e(
                    Payment_Account_Id__c = paymentAccountId
                )
            );
        }
    }

    /**
     * @description - Save Platform event record.
     * @param uow - instance of UnitOfWork
     * @return Boolean
     */
    private Boolean commitWork(fflib_ISObjectUnitOfWork uow) {
        try {
            uow.commitWork();
            return true;
        } catch (Exception commitWorkException) {
            Logger.publish(
                LogEntry.newExceptionLog(commitWorkException, LogEntry.SeverityLevel.HIGH)
            );
        }
        return false;
    }

}