/**
 * @author Deloitte
 * @date 05/17/2024
 * @description Batch class for sending Return Labels (Shipping label, AWB label and Invoice) to Merchants
 * after Mulesoft attaches the files to MxOrder
 */
public with sharing class MxReturnLabelEmailBatch implements System.Schedulable, Database.Batchable<SObject> {
    private static final String EMAIL_BATCH_SIZE_STATIC_CONFIG = 'Mx_Return_Label_Email_Batch_Size';
    private static final String RETURN_LABEL_STATUS_BINDING_NAME = 'returnLabelStatus';
    private static final String STATUS_FAILED_RETURN_LABEL_TO_MX = 'Failed to Send to Mx';
    private static final String STATUS_RETURN_LABEL_GENERATED = 'Return Label Generated';

    /**
     * @description Start method of Batch class to initiate return label outbound email.
     * @param batchableContext - Database.BatchableContext
     * @return Database.QueryLocator - MxOrders with return labels
     */
    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        return MerchantOrdersSelector.newInstance()
            .queryLocatorMxOrdersWithReturnLabels(
                new Map<String, Object>{
                    RETURN_LABEL_STATUS_BINDING_NAME => new Set<String>{
                        STATUS_RETURN_LABEL_GENERATED,
                        STATUS_FAILED_RETURN_LABEL_TO_MX
                    }
                }
            );
    }

    /**
     * @description Execute method to send outbound email with return label attachments to Merchant.
     * @param batchableContext - Database.BatchableContext
     * @param mxOrdersWithReturnLabels
     */
    public void execute(
        Database.BatchableContext batchableContext,
        List<MX_Order__c> mxOrdersWithReturnLabels
    ) {
        MxReturnLabelEmailService.sendReturnLabelEmailsToMerchants(mxOrdersWithReturnLabels);
    }

    /**
     * @description schedulable method to execute batch class to send Mx return label email
     * with scope size = 5.
     * @param schedulableContext - SchedulableContext
     */
    public void execute(SchedulableContext schedulableContext) {
        Database.executeBatch(
            new MxReturnLabelEmailBatch(),
            Integer.valueof(
                StaticConfigurationsSelector.newInstance()
                    .getInstanceValue(EMAIL_BATCH_SIZE_STATIC_CONFIG)
                    .Configuration_Value__c
            )
        );
    }

    /**
     * @description Finish method to execute logic after return label email sent to Mx.
     * @param batchableContext - Database.BatchableContext
     */
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext batchableContext) {
    }
}