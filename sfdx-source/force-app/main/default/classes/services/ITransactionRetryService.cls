/**
 * @author Deloitte
 * @date 2/3/2022
 * @description Interfrace for TransactionRetryService
 */
public interface ITransactionRetryService {
    /**
     * @description method to be implemented in TransactionRetryServiceIml class.
     * @param transactionIds - Interface_Transaction__c record Ids
     * @return IRetryableCalloutTransaction
     */
    IRetryableServiceTransaction getRetryableTransactions(Set<Id> transactionIds);

    /**
     * @description method to be implemented in TransactionRetryServiceIml class.
     * @param processInterfaceAndSerializedPayload - map of Interface Type and Payload
     */
    void scheduleRetryableTransactions(Map<Type, String> processInterfaceAndSerializedPayload);

    /**
     * @description method to be implemented in TransactionRetryServiceIml class.
     * @param retryTransactionIds - Interface_Transaction__c record Ids
     */
    void retryAttemptSuccessful(Set<Id> retryTransactionIds);

    /**
     * @description method to be implemented in TransactionRetryServiceIml class.
     * @param retryTransactionIds - Interface_Transaction__c record Ids
     */
    void retryAttemptFailed(Set<Id> retryTransactionIds);
}