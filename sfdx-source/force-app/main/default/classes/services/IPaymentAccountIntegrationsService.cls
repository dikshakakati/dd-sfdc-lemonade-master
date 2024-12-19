/**
 * @author Deloitte
 * @date 20/10/2022
 * @description Interface for PaymentAccountIntegration class.
 */
public interface IPaymentAccountIntegrationsService {
    /**
     * @description It creates events of type Payment_Account_Integration__e using the passed Payment Account payload
     * @param paymentAccountIds - set of Payment Account Ids
     * @return Boolean
     */
    Boolean publishPaymentAccountIntegrationEvents(Set<Id> paymentAccountIds);
}