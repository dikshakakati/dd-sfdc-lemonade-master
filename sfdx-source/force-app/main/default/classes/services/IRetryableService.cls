/**
 * @author Deloitte
 * @date 2/3/2022
 * @description Interface for RetryableService
 */
public interface IRetryableService {
    /**
     * @description method to be implemented in child class.
     * @param transactionId - Interface_Transaction__c record Id
     */
    void retry(String transactionId);

    /**
     * @description method to be implemented in child class.
     * @param interfaceTransactionsForRetry - Interface_Transaction__c records for retry.
     */
    void retry(List<Interface_Transaction__c> interfaceTransactionsForRetry);
}