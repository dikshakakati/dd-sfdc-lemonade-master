/**
 * @author Deloitte
 * @date 07/02/2024
 * @description Service class for MerchantServicesServiceImpl related logic.
 */
public inherited sharing class MerchantServicesService {
    /**
     * @description Sets the Mx Agreed to Product Field to No
     * @JIRA #LEM-15980
     * @param mxServices
     * @param allAccountIdSet
     */
    public static void setMxAgreedToProductValueNo(
        List<Merchant_Service__c> mxServices,
        Set<Id> allAccountIdSet
    ) {
        service().setMxAgreedToProductValueNo(mxServices, allAccountIdSet);
    }

    /**
     * @description Sets the Mx Agreed to Product Field to No
     * @JIRA #LEM-15980
     * @param deactivatedAgreementsList
     */
    @InvocableMethod(
        label='Update MxAgreedToProductValue No'
        description='It sets the merchant services MxAgreedToProductValue to No'
    )
    public static void setMxAgreedToProductValueNoFromFlow(
        List<List<Agreement__c>> deactivatedAgreementsList
    ) {
        service().setMxAgreedToProductValueNoFromFlow(deactivatedAgreementsList);
    }

    /**
     * @description It is used to delete Merchant Services by the passed contract ids of churned
     * merchants.
     * @JIRA# LEM-23780
     * @param contractIds
     * @param uow
     * @return fflib_ISObjectUnitOfWork
     */
    public static fflib_ISObjectUnitOfWork deleteChurnedMxServices(
        Set<Id> contractIds,
        fflib_ISObjectUnitOfWork uow
    ) {
        return service().deleteChurnedMxServices(contractIds, uow);
    }

    /**
     * @description It creates an instance of MerchantServicesService class.
     * @return IMerchantServicesService - return instance of CampaignMembersServiceImpl
     */
    private static IMerchantServicesService service() {
        return (IMerchantServicesService) Application.SERVICE.newInstance(
            IMerchantServicesService.class
        );
    }
}