/**
 * @author Deloitte
 * @date 2/3/2022
 * @description Implementation class for TransactionRetryService Class
 */
public inherited sharing class TransactionRetryServiceImpl implements ITransactionRetryService {
    private static final String SUCCESS_STATUS = 'Success';
    private static final String FAILURE_STATUS = 'Failure';

    /**
     * @description Creates a new instance of IRetryableServiceTransaction from the
     * InterfaceTransaction__c record
     * @param transactionIds - Interface_Transaction__c Record Ids
     * @return IRetryableServiceTransaction - Type of IRetryableServiceTransaction
     */
    public IRetryableServiceTransaction getRetryableTransactions(Set<Id> transactionIds) {
        List<Interface_Transaction__c> interfaceTransaction = InterfaceTransactionSelector.newInstance()
            .selectById(transactionIds);
        if (interfaceTransaction.isEmpty()) {
            return null;
        }
        return new RetryableServiceTransaction(interfaceTransaction);
    }

    /**
     * @description Marks the Interface_Transaction__c record status to "Success"
     * @param retryTransactionIds - Interface_Transaction__c Record Ids
     */
    public void retryAttemptSuccessful(Set<Id> retryTransactionIds) {
        if (retryTransactionIds.isEmpty()) {
            return;
        }
        List<Interface_Transaction__c> interfaceTransactions = InterfaceTransactionSelector.newInstance()
            .selectById(retryTransactionIds);
        if (interfaceTransactions.isEmpty()) {
            return;
        }
        fflib_ISobjectUnitOfWork uowInterfaceTransactionUpdate = Application.UnitOfWork.newInstance();
        for (Interface_Transaction__c interfaceRecord : interfaceTransactions) {
            interfaceRecord.Status__c = SUCCESS_STATUS;
            uowInterfaceTransactionUpdate.registerDirty(interfaceRecord);
        }
        try {
            uowInterfaceTransactionUpdate.commitWork();
        } catch (Exception interfaceTransactionUpdateException) {
            Logger.publish(
                LogEntry.newExceptionLog(
                    interfaceTransactionUpdateException,
                    LogEntry.SeverityLevel.HIGH
                )
            );
        }
    }

    /**
     * @description Creates a new InterfaceTransaction__c record for a callout process
     * @param processInterfaceAndSerializedPayload - map of Interface Type and Payload
     */
    public void scheduleRetryableTransactions(
        Map<Type, String> processInterfaceAndSerializedPayload
    ) {
        if (processInterfaceAndSerializedPayload.isEmpty()) {
            return;
        }
        List<String> typeNames = new List<String>();
        for (Type processInterface : processInterfaceAndSerializedPayload.keyset()) {
            String typeName = processInterface.getName();
            typeNames.add(typeName);
        }
        if (typeNames.isEmpty()) {
            return;
        }
        List<Interface__c> interfaceRecords = InterfaceSelector.newInstance()
            .selectByClassName(typeNames);
        fflib_ISobjectUnitOfWork uowCreateInterfaceTransaction = Application.UnitOfWork.newInstance();
        if (interfaceRecords.isEmpty()) {
            return;
        }
        for (Interface__c interfaceRecord : interfaceRecords) {
            Interface_Transaction__c interfaceTransaction = new Interface_Transaction__c();
            interfaceTransaction.Remaining_Retry_Attempts__c = interfaceRecord.Retry_Limit__c;
            interfaceTransaction.Interface__c = interfaceRecord.Id;
            interfaceTransaction.Status__c = FAILURE_STATUS;
            interfaceTransaction.Payload__c = processInterfaceAndSerializedPayload.get(
                Type.forname(interfaceRecord.Class_Interface_Name__c)
            );
            uowCreateInterfaceTransaction.registerNew(interfaceTransaction);
        }

        try {
            uowCreateInterfaceTransaction.commitWork();
        } catch (Exception interfaceTransactionCreateException) {
            Logger.publish(
                LogEntry.newExceptionLog(
                    interfaceTransactionCreateException,
                    LogEntry.SeverityLevel.HIGH
                )
            );
        }
    }

    /**
     * @description Decrements the retry count on the InterfaceTransaction__c record
     * @param retryTransactionIds - Interface_Transaction__c Record Ids
     */
    public void retryAttemptFailed(Set<Id> retryTransactionIds) {
        if (retryTransactionIds.isEmpty()) {
            return;
        }
        List<Interface_Transaction__c> interfaceTransactions = InterfaceTransactionSelector.newInstance()
            .selectById(retryTransactionIds);
        if (interfaceTransactions.isEmpty()) {
            return;
        }
        fflib_ISobjectUnitOfWork uowInterfaceTransactionUpdate = Application.UnitOfWork.newInstance();
        for (Interface_Transaction__c interfaceRecord : interfaceTransactions) {
            interfaceRecord.Remaining_Retry_Attempts__c -= 1;
            uowInterfaceTransactionUpdate.registerDirty(interfaceRecord);
        }
        try {
            uowInterfaceTransactionUpdate.commitWork();
        } catch (Exception interfaceTransactionUpdateException) {
            Logger.publish(
                LogEntry.newExceptionLog(
                    interfaceTransactionUpdateException,
                    LogEntry.SeverityLevel.HIGH
                )
            );
        }
    }
}