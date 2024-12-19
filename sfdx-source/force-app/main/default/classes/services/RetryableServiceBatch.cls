/**
 * @author Deloitte
 * @date 2/3/2022
 * @description Batch class for re-executing the failed Integration Classes
 */
public with sharing class RetryableServiceBatch implements System.Schedulable, Database.Batchable<SObject>, Database.AllowsCallouts {
    private static final String MX_ORDER_STATUS_INVALID = 'Invalid';
    private static final Set<String> MX_ORDER_STATUSES_INELIGIBLE_FOR_RETRY = new Set<String>{
        MX_ORDER_STATUS_INVALID
    };
    private static final String MX_ORDER_INTERFACE_TRANSACTION_CONFIG_TABLET = 'Tablet_Outbound_Integration';
    private static final String MX_ORDER_INTERFACE_TRANSACTION_CONFIG_PHOTOSHOOT = 'Photoshoot_Outbound_Integration';
    private static final Set<String> MX_ORDER_INTERFACE_TRANSACTION_CONFIG_NAMES = new Set<String>{
        MX_ORDER_INTERFACE_TRANSACTION_CONFIG_TABLET,
        MX_ORDER_INTERFACE_TRANSACTION_CONFIG_PHOTOSHOOT
    };
    Map<String, String> interfaceConfigNameToDetails;
    Map<Id, MX_Order__c> mxOrderIdToOrderStatus;
    Map<String, List<Interface_Transaction__c>> interfaceTransactionsForRetry;

    /**
     * @description Constructor to set interface name for batch retry.
     */
    public RetryableServiceBatch() {
        this.interfaceConfigNameToDetails = new Map<String, String>();
        this.interfaceTransactionsForRetry = new Map<String, List<Interface_Transaction__c>>();
        this.mxOrderIdToOrderStatus = new Map<Id, MX_Order__c>();
    }

    /**
     * @description Start method of Batch class
     * @param batchableContext - Database.BatchableContext
     * @return result- DML operation result
     */
    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        return new InterfaceTransactionSelector().queryLocatorReadyToRetry();
    }

    /**
     * @description Execute method to perform business logic
     * @param batchableContext - Database.BatchableContext
     * @param interfaceTransactions - Interface Transaction records
     */
    public void execute(
        Database.BatchableContext batchableContext,
        List<Interface_Transaction__c> interfaceTransactions
    ) {
        Set<Id> mxOrderIds = new Set<Id>();
        collectInterfaceTransactionConfigs();
        for (Interface_Transaction__c eachInterfaceTransactionRecord : interfaceTransactions) {
            if (
                eachInterfaceTransactionRecord.Interface_Transaction_Configuration_Name__c ==
                null ||
                !interfaceConfigNameToDetails.containsKey(
                    eachInterfaceTransactionRecord.Interface_Transaction_Configuration_Name__c
                )
            ) {
                continue;
            }
            if (
                MX_ORDER_INTERFACE_TRANSACTION_CONFIG_NAMES.contains(
                    eachInterfaceTransactionRecord.Interface_Transaction_Configuration_Name__c
                )
            ) {
                mxOrderIds.add(eachInterfaceTransactionRecord.Record_Id__c);
                continue;
            }
            collectInterfaceTransactionsByConfig(eachInterfaceTransactionRecord);
        }
        collectMxOrdersDetailsForRetry(mxOrderIds);
        MerchantOrdersService.retryPayloadGeneration(mxOrderIdToOrderStatus.values());
        for (
            Interface_Transaction__c eachInterfaceTransaction : InterfaceTransactionSelector.newInstance()
                .selectByOriginRecordIds(
                    (Set<String>) JSON.deserialize(JSON.serialize(mxOrderIds), Set<String>.class)
                )
        ) {
            collectInterfaceTransactionsByConfig(eachInterfaceTransaction);
        }
        for (String eachInterfaceTransactionsConfigName : interfaceTransactionsForRetry.keySet()) {
            retryService(
                interfaceTransactionsForRetry.get(eachInterfaceTransactionsConfigName),
                interfaceConfigNameToDetails.get(eachInterfaceTransactionsConfigName)
            );
        }
    }

    /**
     * @description schedulable method to execute batch class with size 1
     * @param schedulableContext - SchedulableContext
     */
    public void execute(SchedulableContext schedulableContext) {
        Database.executeBatch(
            new RetryableServiceBatch(),
            Integer.valueof(System.Label.Retryable_Service_Batch_Size)
        );
    }

    /**
     * @description Finish method to perform logic after retry process completion.
     * @param batchableContext - Database.BatchableContext
     */
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext batchableContext) {
    }

    /**
     * @description It collects Interface Transaction configuration metadata records.
     */
    private void collectInterfaceTransactionConfigs() {
        for (
            Interface_Transaction_Configuration__mdt eachConfig : InterfaceTransactionConfigSelector.newInstance()
                .selectAllActiveInterfaceTransactionCongis()
        ) {
            if (eachConfig.Service_Class_Name__c != null && eachConfig.Enable_Retry__c) {
                interfaceConfigNameToDetails.put(
                    eachConfig.Interface_Transaction_Name__c,
                    eachConfig.Service_Class_Name__c
                );
            }
        }
    }

    /**
     * @description It collects Mx Order details related to Interface transactions for retry.
     * @param mxOrderIds
     */
    private void collectMxOrdersDetailsForRetry(Set<Id> mxOrderIds) {
        mxOrderIdToOrderStatus = new Map<Id, MX_Order__c>(
            MerchantOrdersSelector.newInstance().selectById(mxOrderIds)
        );
    }

    /**
     * @description It collects Mx Order details related to Interface transactions for retry.
     * @param interfaceTransactionDetails
     */
    private void collectInterfaceTransactionsByConfig(
        Interface_Transaction__c interfaceTransactionDetails
    ) {
        if (
            !interfaceTransactionsForRetry.containsKey(
                interfaceTransactionDetails.Interface_Transaction_Configuration_Name__c
            )
        ) {
            interfaceTransactionsForRetry.put(
                interfaceTransactionDetails.Interface_Transaction_Configuration_Name__c,
                new List<Interface_Transaction__c>()
            );
        }
        interfaceTransactionsForRetry.get(
                interfaceTransactionDetails.Interface_Transaction_Configuration_Name__c
            )
            .add(interfaceTransactionDetails);
    }

    /**
     * @description It passes the interface transaction records to spefied service class for retry.
     * @param interfaceTransactions
     * @param serviceClassName
     */
    private void retryService(
        List<Interface_Transaction__c> interfaceTransactions,
        String serviceClassName
    ) {
        //Filtering to remove interface transactions related to Mx Orders with 'Invalid' Status.
        Set<Interface_Transaction__c> filterInterfaceTransactions = new Set<Interface_Transaction__c>(
            interfaceTransactions
        );
        for (Interface_Transaction__c eachInterfaceTransaction : interfaceTransactions) {
            if (
                eachInterfaceTransaction.Record_Id__c != null &&
                mxOrderIdToOrderStatus.containsKey(eachInterfaceTransaction.Record_Id__c) &&
                MX_ORDER_STATUSES_INELIGIBLE_FOR_RETRY.contains(
                    mxOrderIdToOrderStatus.get(eachInterfaceTransaction.Record_Id__c).Status__c
                )
            ) {
                filterInterfaceTransactions.remove(eachInterfaceTransaction);
            }
        }
        try {
            IRetryableService retryClass = (IRetryableService) Application.SERVICE.newInstance(
                Type.forName(serviceClassName)
            );
            retryClass.retry(new List<Interface_Transaction__c>(filterInterfaceTransactions));
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
        }
    }
}