/**
 * @author DoorDash
 * @date   10/12/2022
 * @description This is the service interface for Sync with Netsuite implementation
 */
public interface INetsuiteIntegrator extends INetsuiteIntegratorService{
    /**
     * @description method to perform readiness check before netsuite Restlet API call
     * @param paymentAccountId list of IOpportunities
     * @return List<String> 
     */
	List<String> performReadinessCheckValidations(
        Id paymentAccountId
    );
    /**
     * @description method to call Sync With Netsuite implementation
     * @param recordId Selected Payment Account record Id
     * @return Map<String, Object>
     */
    Map<String, Object> syncWithNetsuite(
        String recordId
    );
}