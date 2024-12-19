/**
 * @author Deloitte
 * @date 02/07/2024
 * @description Interface of service class for MerchantServicesService related logic.
 */
public interface IMerchantServicesService {
    /**
     * @description Sets the Mx Agreed to Product Field to No
     * @JIRA #LEM-15980
     * @param mxServices
     * @param allAccountIdSet
     */
    void setMxAgreedToProductValueNo(List<Merchant_Service__c> mxServices, Set<Id> allAccountIdSet);

    /**
     * @description Sets the Mx Agreed to Product Field to No
     * @JIRA #LEM-15980
     * @param agreementsList
     */
    void setMxAgreedToProductValueNoFromFlow(List<List<Agreement__c>> agreementsList);

    /**
     * @description It is used to delete the Merchant Services by the passed contract ids.
     * @param contractIds
     * @param uow
     * @return fflib_ISObjectUnitOfWork
     */
    fflib_ISObjectUnitOfWork deleteChurnedMxServices(
        Set<Id> contractIds,
        fflib_ISObjectUnitOfWork uow
    );
}