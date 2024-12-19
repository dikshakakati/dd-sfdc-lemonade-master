/**
 * @author Deloitte
 * @date 20/10/2022
 * @description Service class for Payment_Account_Integration__e related logic.
 */
public inherited sharing class PaymentAccountIntegrationsService {
    /**
     * @description - Create platform events for selected payment account records.
     * @param paymentAccountIds
     * @return Boolean
    */
    public static Boolean publishPaymentAccountIntegrationEvents(Set<Id> paymentAccountIds){
        return service().publishPaymentAccountIntegrationEvents(paymentAccountIds);
    }

    /**
     * @description It creates instance of PaymentAccountIntegrationEventsServiceImpl class.
     * @return IPaymentAccountEventsService
     */
    private static IPaymentAccountIntegrationsService service(){
        return (IPaymentAccountIntegrationsService) Application.Service.newInstance(
            IPaymentAccountIntegrationsService.class
        );
    }

}