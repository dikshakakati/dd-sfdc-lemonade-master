/**
 * @author Deloitte
 * date 2/3/2022
 * @description Class to return payload on the Interface_Transaction__c record
 */
public with sharing class RetryableServiceTransaction implements IRetryableServiceTransaction {
    /**
     * @description Variable for get and set
     * @return String - Paylod of Interface Transation Record
     */
    public Map<Id, String> transactionIdToPayload = new Map<Id, String>();

    /**
     * @description Constructor of the class
     * @param inerfaceTransaction - Interface Transaction Record
     */
    public RetryableServiceTransaction(List<Interface_Transaction__c> inerfaceTransaction) {
        for (Interface_Transaction__c inerfaceTransactionRecord : inerfaceTransaction) {
            this.transactionIdToPayload.put(
                inerfaceTransactionRecord.id,
                inerfaceTransactionRecord.Payload__c
            );
        }
    }

    /**
     * @description This method returns payload
     * @return String - Payload of the Transaction
     */
    public Map<Id, String> getSerializedPayload() {
        return transactionIdToPayload;
    }
}