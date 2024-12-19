/**
 * @author DoorDash
 * @date 04/05/2023
 * @description This is the service interface for Sync with Netsuite implementation
 */
public interface INetSuiteSync {
    /**
     * @description method to perform readiness check before netsuite Restlet API call
     * @param paymentAccountId list of IOpportunities
     * @return List<String>
     */
    Map<Id, List<String>> performReadinessCheckValidationsOnMultiplePaymentAccounts(
        Set<Id> paymentAccountId
    );
    /**
     * @description method to call Sync With Netsuite implementation
     * @param recordIds Selected Payment Account record Id
     */
    void syncWithNetsuite(Set<Id> recordIds);
}