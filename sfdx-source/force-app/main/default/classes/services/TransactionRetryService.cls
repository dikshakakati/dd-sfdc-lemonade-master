/**
 * @author Deloitte
 * @date 2/3/2022
 * @description Transaction Retry Service Class
 */
public inherited sharing class TransactionRetryService {
    /**
     * @description Instantiates a new instance of IRetryableServiceTransaction from the
     * InterfaceTransaction__c record
     * @param transactionIds - Interface_Transaction__c record Ids
     * @return IRetryableServiceTransaction - Type of IRetryableServiceTransaction
     */
    public static IRetryableServiceTransaction getRetryableTransactions(Set<Id> transactionIds) {
        return service().getRetryableTransactions(transactionIds);
    }

    /**
     * @description Marks the InterfaceTransaction__c record status to "Success"
     * @param retryTransactionIds - Interface_Transaction__c record Ids
     */
    public static void retryAttemptSuccessful(Set<Id> retryTransactionIds) {
        service().retryAttemptSuccessful(retryTransactionIds);
    }

    /**
     * @description Creates a new InterfaceTransaction__c record for a callout process
     * @param processInterfaceAndSerializedPayload - map of Interface Type and Payload
     */
    public static void scheduleRetryableTransactions(
        Map<Type, String> processInterfaceAndSerializedPayload
    ) {
        service().scheduleRetryableTransactions(processInterfaceAndSerializedPayload);
    }

    /**
     * @description Decrements the retry count on the InterfaceTransaction__c record
     * @param retryTransactionIds - Interface_Transaction__c record Ids
     */
    public static void retryAttemptFailed(Set<Id> retryTransactionIds) {
        service().retryAttemptFailed(retryTransactionIds);
    }

    /**
     * @description Method to call the Application service method
     * @return ITransactionRetryService
     */
    private static ITransactionRetryService service() {
        return (ITransactionRetryService) Application.Service.newInstance(
            ITransactionRetryService.class
        );
    }
}