/**
 * @author Deloitte
 * @date 2/3/2022
 * @description Interface for RetryableServiceTransaction
 */
public interface IRetryableServiceTransaction {
    /**
     * @description method to be implemented in child class.
     * @return String - paylod of Interface_Transaction__c
     */
    Map<Id, String> getSerializedPayload();
}