/**
 * @author Deloitte
 * @date 07/05/2024
 * @description Service implementation class for Mx Fraud Document related logic.
 */
public inherited sharing class MxFraudDocumentsServiceImpl implements IMxFraudDocumentsService {
    private static final String DISABLE_MX_FRAUD_DOCUMENTS_SYNC_CUSTOM_PERMISSION = 'Disable_Mx_Fraud_Documents_Sync';
    private static final String INTERFACE_TRANSACTION_CONFIGURATION_NAME_MX_FRAUD = 'Mx_Fraud_Document_Integration';
    private static final String LOG_DOMAIN_FRAUD_DOCUMENT = 'Mx Fraud Documents';
    private static final String LOG_SERVICE_MX_FRAUD_DOCUMENT = 'Mx Fraud Documents Service';
    private static final String WORK_PLAN_TYPE_ONBOARDING = 'Onboarding';
    private static final String INTERFACE_TRANSACTION_STATUS_NEW = 'New';
    private static Map<Id, List<Mx_Fraud_Document__c>> storeAccountIdToMxFraudDocuments;
    private static Map<String, List<Mx_Fraud_Document__c>> storeIdToMxFraudDocuments;
    private static Map<String, String> storeIdToMxFraudDocumentsPayload;

    /**
     * @description Default Constructor to initialize class variables.
     */
    public MxFraudDocumentsServiceImpl() {
        storeAccountIdToMxFraudDocuments = new Map<Id, List<Mx_Fraud_Document__c>>();
        storeIdToMxFraudDocuments = new Map<String, List<Mx_Fraud_Document__c>>();
        storeIdToMxFraudDocumentsPayload = new Map<String, String>();
    }

    /**
     * @description It generates payload based on Mx Fraud Document details
     * and sends payload for outbound integration.
     * @JIRA# LEM-15836
     * @param mxFraudDocuments
     */
    public void sendMxFraudDocumentDetailsForOutboundIntegration(
        List<Mx_Fraud_Document__c> mxFraudDocuments
    ) {
        if (isNonEligibleForMxFraudDocumentsSync(mxFraudDocuments)) {
            return;
        }
        try {
            collectMxFraudDocumentsByStoreIds(mxFraudDocuments);
            collectStoreIdBasedOnStoreAccountIds();
            removeRecentlyProcessedStoreIds();
            generateMxFraudDocumentPayloads();
            createInterfaceTransactionsToInitiateOutboundIntegration();
        } catch (Exception mxFraudOutboundException) {
            Logger.publish(
                LogEntry.newExceptionLog(mxFraudOutboundException, LogEntry.SeverityLevel.HIGH)
            );
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_SERVICE_MX_FRAUD_DOCUMENT,
                        LOG_DOMAIN_FRAUD_DOCUMENT,
                        GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logException(mxFraudOutboundException)
            );
        }
    }

    /**
     * @description It creates Interface Transaction records based on
     * generated Mx Fraud Document details payload.
     * @JIRA# LEM-15836
     * @return Interface_Transaction_Configuration__mdt
     */
    private Interface_Transaction_Configuration__mdt collectInterfaceTransactionConfigDetails() {
        return InterfaceTransactionConfigSelector.newInstance()
            .getInstanceValue(INTERFACE_TRANSACTION_CONFIGURATION_NAME_MX_FRAUD);
    }

    /**
     * @description It creates Interface Transaction records based on
     * generated Mx Fraud Document details payload.
     * TODO: Move this logic to common service method.
     * @JIRA# LEM-15836
     */
    private void createInterfaceTransactionsToInitiateOutboundIntegration() {
        if (storeIdToMxFraudDocumentsPayload.isEmpty()) {
            return;
        }
        Interface_Transaction_Configuration__mdt mxFraudConfig = collectInterfaceTransactionConfigDetails();
        List<Interface_Transaction__c> interfaceTransactionsToInsert = new List<Interface_Transaction__c>();
        for (String eachStoreId : storeIdToMxFraudDocumentsPayload.keySet()) {
            interfaceTransactionsToInsert.add(
                new Interface_Transaction__c(
                    Interface_Transaction_Configuration_Name__c = INTERFACE_TRANSACTION_CONFIGURATION_NAME_MX_FRAUD,
                    Payload__c = storeIdToMxFraudDocumentsPayload.get(eachStoreId),
                    Record_Id__c = eachStoreId,
                    Remaining_Retry_Attempts__c = mxFraudConfig.Retry_Limit__c,
                    Status__c = INTERFACE_TRANSACTION_STATUS_NEW
                )
            );
        }
        insertSObjects(interfaceTransactionsToInsert);
    }

    /**
     * @description It fires Insert DML statement to create sObject records.
     * @JIRA# LEM-15836
     * @param sObjectsToInsert
     */
    private void insertSObjects(List<sObject> sObjectsToInsert) {
        if (sObjectsToInsert.isEmpty()) {
            return;
        }
        fflib_ISObjectUnitOfWork unitOfWorkInstance = Application.UNITOFWORK.newInstance();
        unitOfWorkInstance.registerNew(sObjectsToInsert);
        try {
            unitOfWorkInstance.commitWork();
        } catch (Exception sObjectInsertException) {
            Logger.publish(
                LogEntry.newExceptionLog(sObjectInsertException, LogEntry.SeverityLevel.HIGH)
            );
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_SERVICE_MX_FRAUD_DOCUMENT,
                        LOG_DOMAIN_FRAUD_DOCUMENT,
                        GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logException(sObjectInsertException)
            );
        }
    }

    /**
     * @description It generates the payload with Mx Fraud Document details for each Store.
     * @JIRA# LEM-15836
     */
    private void generateMxFraudDocumentPayloads() {
        if (storeIdToMxFraudDocuments.isEmpty()) {
            return;
        }
        MxFraudDocumentsPayloads mxFraudDocumentsPayloadInstance = new MxFraudDocumentsPayloads();
        MxFraudDocumentsPayloads.MxFraudDocumentDetails mxFraudDocumentDetails;
        Boolean isWorkPlanIdExists;
        for (String eachStoreId : storeIdToMxFraudDocuments.keySet()) {
            mxFraudDocumentDetails = new MxFraudDocumentsPayloads.MxFraudDocumentDetails(
                eachStoreId
            );
            isWorkPlanIdExists = false;
            for (
                Mx_Fraud_Document__c eachMxFraudDocument : storeIdToMxFraudDocuments.get(
                    eachStoreId
                )
            ) {
                if (
                    eachMxFraudDocument.Work_Plan__c != null &&
                    String.isNotBlank(eachMxFraudDocument.Work_Plan__c) &&
                    !isWorkPlanIdExists
                ) {
                    mxFraudDocumentsPayloadInstance.setExternalId(
                        mxFraudDocumentDetails,
                        eachMxFraudDocument.Work_Plan__c
                    );
                    isWorkPlanIdExists = true;
                }
                mxFraudDocumentsPayloadInstance.setVerificationDocumentDetails(
                    mxFraudDocumentDetails,
                    eachMxFraudDocument
                );
            }
            storeIdToMxFraudDocumentsPayload.put(
                eachStoreId,
                JSON.serialize(mxFraudDocumentDetails)
            );
        }
    }

    /**
     * @description It collects the Store Id (External Id) for Mx Fraud Documents
     * based on Store Account Ids.
     * @JIRA# LEM-15836
     */
    private void collectStoreIdBasedOnStoreAccountIds() {
        if (storeAccountIdToMxFraudDocuments.isEmpty()) {
            return;
        }
        for (
            Xref__c eachXref : XrefsSelector.newInstance()
                .selectActiveXrefsBySalesforceAccountName(storeAccountIdToMxFraudDocuments.keySet())
        ) {
            if (storeIdToMxFraudDocuments.containsKey(eachXref.External_ID__c)) {
                storeIdToMxFraudDocuments.get(eachXref.External_ID__c)
                    .addAll(
                        storeAccountIdToMxFraudDocuments.get(eachXref.Salesforce_Account_Name__c)
                    );
            } else {
                storeIdToMxFraudDocuments.put(
                    eachXref.External_ID__c,
                    storeAccountIdToMxFraudDocuments.get(eachXref.Salesforce_Account_Name__c)
                );
            }
        }
    }

    /**
     * @description It collects Mx Fraud Documents based on Store Id (External Id)
     * or Store Account Id if Store Id is not present.
     * @JIRA# LEM-15836
     * @param mxFraudDocuments
     */
    private void collectMxFraudDocumentsByStoreIds(List<Mx_Fraud_Document__c> mxFraudDocuments) {
        for (Mx_Fraud_Document__c eachMxFraudDocument : mxFraudDocuments) {
            if (
                eachMxFraudDocument.Store_Id__c != null &&
                String.isNotBlank(eachMxFraudDocument.Store_Id__c)
            ) {
                if (!storeIdToMxFraudDocuments.containsKey(eachMxFraudDocument.Store_Id__c)) {
                    storeIdToMxFraudDocuments.put(
                        eachMxFraudDocument.Store_Id__c,
                        new List<Mx_Fraud_Document__c>()
                    );
                }
                storeIdToMxFraudDocuments.get(eachMxFraudDocument.Store_Id__c)
                    .add(eachMxFraudDocument);
            } else if (
                eachMxFraudDocument.Mx_Store_Id__c != null &&
                String.isNotBlank(eachMxFraudDocument.Mx_Store_Id__c)
            ) {
                if (
                    !storeAccountIdToMxFraudDocuments.containsKey(
                        eachMxFraudDocument.Mx_Store_Id__c
                    )
                ) {
                    storeAccountIdToMxFraudDocuments.put(
                        eachMxFraudDocument.Mx_Store_Id__c,
                        new List<Mx_Fraud_Document__c>()
                    );
                }
                storeAccountIdToMxFraudDocuments.get(eachMxFraudDocument.Mx_Store_Id__c)
                    .add(eachMxFraudDocument);
            }
        }
    }

    /*
     * @description It checks whether the conditions for "Mx Fraud Documents" sync
     * are satisfied or not.
     * @param mxFraudDocuments
     * @return Boolean
     */
    private Boolean isNonEligibleForMxFraudDocumentsSync(
        List<Mx_Fraud_Document__c> mxFraudDocuments
    ) {
        return mxFraudDocuments == null ||
            mxFraudDocuments.isEmpty() ||
            FeatureManagementService.newInstance()
                .checkPermission(DISABLE_MX_FRAUD_DOCUMENTS_SYNC_CUSTOM_PERMISSION);
    }

    /**
     * @description It removes the Store Id (External Id) of Mx Fraud Documents that are processed.
     * It checks whether an Interface Transaction record exists already for the current Store Id
     * @JIRA# LEM-18563
     */
    private void removeRecentlyProcessedStoreIds() {
        if (storeIdToMxFraudDocuments.isEmpty()) {
            return;
        }
        for (
            Interface_Transaction__c eachInterfaceTransaction : InterfaceTransactionSelector.newInstance()
                .selectByOriginRecordIds(storeIdToMxFraudDocuments.keySet())
        ) {
            if (
                storeIdToMxFraudDocuments.containsKey(eachInterfaceTransaction.Record_Id__c) &&
                eachInterfaceTransaction.Interface_Transaction_Configuration_Name__c ==
                INTERFACE_TRANSACTION_CONFIGURATION_NAME_MX_FRAUD &&
                eachInterfaceTransaction.CreatedDate > System.now().addMinutes(-5)
            ) {
                storeIdToMxFraudDocuments.remove(eachInterfaceTransaction.Record_Id__c);
            }
        }
    }
}