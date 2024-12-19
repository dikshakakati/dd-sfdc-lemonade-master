/**
 * @description Handles Bulk Store uploads initiated by the Bulk Store Onboarding Flow.
 * @author BizApps
 * @date 31-August-2023
 **/
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity')
public with sharing class BulkStoreOnboardingBatch implements Database.Batchable<sObject>, Database.Stateful, Database.RaisesPlatformEvents {
    private Map<Id, List<LogMessageEntry>> accountIdToLogMessageEntries;
    private Id flowRequestId;
    private Process_Flow_Request__c pfr;
    private Integer storeCount = 0;
    private Integer maxCpuTime = 0;
    private Integer maxHeapSize = 0;
    private Integer maxDmlStatements = 0;
    private Integer maxSoqlQueries = 0;
    private Boolean containsFailures = false;
    private String contractName;
    private Map<Id, BulkCorporateOnboardingWrappers.StoreInfo> storeInfoMap;
    private BulkCorporateOnboardingWrappers.StoreProcessingMetrics storeProcessMetrics;
    private Set<Id> skippedStores;
    private Set<Id> unprocessedStores;
    private Set<Id> finishedStores;
    private List<AccountContactRelation> newDecisionMakers;
    private List<Account_Payment_Account_Relation__c> newPaymentAccountRelations;
    private Map<Id, Contact> decisionMakersMap;
    private static final String COMMA_SEPARATOR = ',';
    private static final String DECISION_MAKER_CONTACT_ROLE = 'Decision Maker';
    private static final String EVENT_TOPIC_BUSINESS_ERROR_LOGS_CREATION = 'BUSINESS_ERROR_LOGS_CREATION';
    private static final String LOG_SERVICE_NAME = 'ANSO';
    private static final String LOG_DOMAIN_NAME = 'Onboarding';
    private static final String LOG_RECORD_METHOD_NAME = 'BulkStoreOnboardingBatch.finish';
    private static final String LOG_ERROR_MESSAGE_FOR_FAILED_STORES = 'This store could not be added to the Work Order due to address verification issues. Please review and update the address on it. Once this is completed, click the "Retry" button to proceed with onboarding these stores.';
    private static final String LOGS_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG = 'Logs_Payload_Chunk_Size';
    private static final String OBJECT_INSTANCE_MAP_EMPTY = '{}';
    private static final String OBJECT_INSTANCE_NULL = 'null';
    private static final String OBJECT_INSTANCE_LIST_OR_SET_EMTPY = '[]';
    private static final String REQUEST_STATUS_COMPLETED = 'Completed';
    private static final String REQUEST_STATUS_FAILED = 'Failed';
    private static final String UPLOAD_COMPLETE = 'Upload Complete';
    private static final String RESULT_SUCCESS = 'Success';
    private static final String RESULT_PARTIAL_SUCCESS = 'Partial Success';
    private static final String RESULT_FAILURE = 'Failure';
    private static final String ANNSO_BUTTON_NAME = 'Onboard Corporate Stores';
    private static final String ANSO_BUTTON_NAME = 'Onboard Corporate Stores';
    private static final String GENERIC_LOG_SERVICE_ANSO = 'ANSO';
    private static Integer logsPayloadChunkSize = Integer.valueOf(
        StaticConfigurationsSelector.newInstance()
            .getInstanceValue(LOGS_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG)
            .Configuration_Value__c
    );

    /**
     * @description Constructor to initialize and query the PFR record
     * @param flowRequestId
     **/
    public BulkStoreOnboardingBatch(Id flowRequestId) {
        this.accountIdToLogMessageEntries = new Map<Id, List<LogMessageEntry>>();
        this.skippedStores = new Set<Id>();
        this.unprocessedStores = new Set<Id>();
        this.finishedStores = new Set<Id>();
        this.flowRequestId = flowRequestId;
        this.storeProcessMetrics = new BulkCorporateOnboardingWrappers.StoreProcessingMetrics();
        this.pfr = BulkCorporateOnboardingRequestService.getBulkOnboardingRequestOrAbort(
            flowRequestId
        );
        this.contractName = (String.isNotBlank(this.pfr.Contract__r?.ContractNumber))
            ? this.pfr.Contract__r.ContractNumber
            : '';
        setStoreInfoMap();
    }

    /**
     * @description Start method to query all Stores that relate to the PFR passed to the controller
     * @param bc - Database.BatchableContext
     * @return Database.QueryLocator
     **/
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            [SELECT Id FROM Account WHERE Bulk_Corporate_Onboarding_Request__c = :pfr.Id]
        );
    }

    /**
     * @description Performs the following operations on each Store:
     *                  1. Create Payment Account Relationship(s)
     *                  2. Create Account Contact Relationship(s)
     *                  3. Manage Stores
     *                  4. Add Stores on the Work Order
     * @param bc - Database.BatchableContext
     * @param records - List<Account>
     **/
    public void execute(Database.BatchableContext bc, List<sObject> records) {
        List<Account> stores = (List<Account>) records;
        Set<Id> validStoreIds = new Set<Id>();
        this.decisionMakersMap = new Map<Id, Contact>();
        this.newDecisionMakers = new List<AccountContactRelation>();
        this.newPaymentAccountRelations = new List<Account_Payment_Account_Relation__c>();

        for (BulkCorporateOnboardingWrappers.StoreInfo thisStoreInfo : storeInfoMap.values()) {
            if (thisStoreInfo.decisionMakerId != null) {
                decisionMakersMap.put(thisStoreInfo.decisionMakerId, new Contact());
            }
        }

        decisionMakersMap = new Map<Id, Contact>(
            ContactsSelector.newInstance().selectById(decisionMakersMap.keySet())
        );

        for (Account store : stores) {
            BulkCorporateOnboardingWrappers.StoreInfo storeWrapperObj = storeInfoMap.get(store.Id);
            // Skip if we have already run the job on this Store
            if (storeWrapperObj?.isJobComplete == true) {
                if (storeWrapperObj != null) {
                    skippedStores.add(storeWrapperObj.storeId);
                }

                continue;
            }

            initStoreJunctionRecords(storeWrapperObj);

            if (storeWrapperObj.isVerified && !storeWrapperObj.skipBatch) {
                validStoreIds.add(store.Id);
            } else {
                this.unprocessedStores.add(store.Id);
            }
        }

        if (!validStoreIds.isEmpty()) {
            runManageStoresAndAddStores(validStoreIds);
        }

        // Increment the store count
        this.storeCount += stores.size();

        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        uow.registerNew(newDecisionMakers);
        uow.registerNew(newPaymentAccountRelations);

        try {
            uow.commitWork();
        } catch (Exception ex) {
            Logger.publish(ex, LogEntry.SeverityLevel.HIGH);

            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_SERVICE_NAME,
                        LOG_DOMAIN_NAME,
                        GenericLogEntry.SeverityLevel.MEDIUM
                    )
                    .logException(ex)
            );
        }
        updateMetrics();
    }

    /**
     * @description It is used to update processing metrics for batch
     */
    @TestVisible
    private void updateMetrics() {
        maxCpuTime = Limits.getCpuTime() >= maxCpuTime ? Limits.getCpuTime() : maxCpuTime;
        maxHeapSize = Limits.getHeapSize() >= maxHeapSize ? Limits.getHeapSize() : maxHeapSize;
        maxDmlStatements = Limits.getDMLStatements() >= maxDmlStatements
            ? Limits.getDMLStatements()
            : maxDmlStatements;
        maxSoqlQueries = Limits.getQueries() >= maxSoqlQueries
            ? Limits.getQueries()
            : maxSoqlQueries;
    }

    /**
     * @description Standard Batch finish() method. We will, at a minimum, need to update the PFR record's Status
     * @param bc - Database.BatchableContext
     **/
    public void finish(Database.BatchableContext bc) {
        containsFailures = !this.unprocessedStores.isEmpty();

        pfr = getFlowRequest(); // Get updated PFR
        pfr.Async_Job_Id__c = bc.getJobId();
        pfr.Stage__c = UPLOAD_COMPLETE;
        pfr.Status__c = getStatusValue();
        pfr.Result__c = getResultValue();
        pfr.Serialized_Object_Data__c = getSerializedStores();

        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new List<SObjectType>{ Process_Flow_Request__c.sObjectType }
        );
        uow.registerDirty(pfr);

        try {
            uow.commitWork();
        } catch (Exception ex) {
            logErrors(
                ex.getMessage(),
                new Contract(Id = pfr.Contract__c),
                LogEntry.LogCategory.BUSINESS_ERROR.name(),
                true,
                pfr.Contract__c,
                LogEntry.SeverityLevel.HIGH.name()
            );
        } finally {
            for (
                Account eachFailedStore : BulkCorporateOnboardingRequestService.getFailedStores(
                    pfr.Id
                )
            ) {
                logErrors(
                    LOG_ERROR_MESSAGE_FOR_FAILED_STORES,
                    eachFailedStore,
                    LogEntry.LogCategory.BUSINESS_ERROR.name(),
                    true,
                    pfr.Contract__c,
                    LogEntry.SeverityLevel.HIGH.name()
                );
            }
            createLogEntries();
        }

        // Email the Owner - Should we have the user opt-in to this?
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject(getEmailSubject());
        mail.setTargetObjectId(pfr.OwnerId);
        mail.setSaveAsActivity(false);
        mail.setPlainTextBody(getEmailBody());
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
        sendNotification();
        logStoreBatchMetrics();
    }

    /**
     * @description It is used to update processing metrics for batch
     */
    @TestVisible
    private void logStoreBatchMetrics() {
        this.storeProcessMetrics.maxCpuTime = maxCpuTime;
        this.storeProcessMetrics.maxHeapSize = maxHeapSize;
        this.storeProcessMetrics.maxDmlStatements = maxDmlStatements;
        this.storeProcessMetrics.maxSoqlQueries = maxSoqlQueries;
        this.storeProcessMetrics.storesProcessed = this.finishedStores.size();
        this.storeProcessMetrics.storesFailed = this.unprocessedStores.size();

        String limitsJson = JSON.serialize(this.storeProcessMetrics);
        GenericLoggerService.publish(
            GenericLoggerService.createGenericLog(
                    GENERIC_LOG_SERVICE_ANSO,
                    GenericLogEntry.GENERIC_LOG_DOMAIN_ONBOARDING,
                    GenericLogEntry.SeverityLevel.LOW
                )
                .logException(new DmlException('ANSO Batch execution details: ' + limitsJson))
                .setCategory(GenericLogEntry.GENERIC_LOG_INFORMATION)
                .setLogLevel(GenericLogEntry.GENERIC_LOG_INFORMATION)
        );
    }

    /**
     * @description Invoked from the `execute()` method, this creates records related to Store Accounts
     *              to link Payment Accounts and Decision Makers.
     * @param storeWrapperObj - BulkCorporateOnboardingWrappers.StoreInfo
     **/
    private void initStoreJunctionRecords(
        BulkCorporateOnboardingWrappers.StoreInfo storeWrapperObj
    ) {
        Id decisionMakerId = storeWrapperObj.decisionMakerId;

        // Add Store Decision Maker
        // Note: There is an edge case where, if the Contact does not have an `AccountId`, it is considered
        // to be a "private" Contact and then you cannot make an AccountContactRelation for it without first
        // setting its `AccountId`. There are not really any Contacts in the system that this applies to,
        // as they all have related Accounts, but possibly consider this as a future fix.
        if (decisionMakerId != null && decisionMakersMap.get(decisionMakerId).AccountId != null) {
            AccountContactRelation acr = new AccountContactRelation();
            acr.AccountId = storeWrapperObj.storeId;
            acr.ContactId = decisionMakerId;
            acr.IsActive = true;
            acr.Roles = DECISION_MAKER_CONTACT_ROLE;
            acr.StartDate = System.today();
            this.newDecisionMakers.add(acr);
        }

        // Check if the store has no payment account on it (for DSD stores) then don't create an Account-Payment Account Relation
        if (storeWrapperObj.paymentAccountId != null) {
            // Add link to Payment Account
            Account_Payment_Account_Relation__c par = new Account_Payment_Account_Relation__c();
            par.Account__c = storeWrapperObj.storeId;
            par.Payment_Account__c = storeWrapperObj.paymentAccountId;
            this.newPaymentAccountRelations.add(par);
        }
    }

    /**
     * @description Invoked from the `execute()` method, this invokes the "Manage Stores" and "Add Stores"
     *              logic in order to associate Stores to the Work Order and create Agreements.
     * @param validStoreIds - Set<Id>
     **/
    private void runManageStoresAndAddStores(Set<Id> validStoreIds) {
        // "Add Stores" logic
        String storeIdString = String.join(new List<Id>(validStoreIds), ',');
        AddStoresOnWorkOrderController.validateStores(pfr.Work_Order__c, storeIdString);
        AddStoresOnWorkOrderController.createChildWorkOrders(pfr.Work_Order__c, storeIdString);
        // Maybe implement some logic for it we get these validation errors

        AssociatedAccountsWrapper.SelectedAndDeselectedEntitlements sade;

        // "Manage Stores" logic
        List<Contract> contractsList = new List<Contract>{ new Contract(Id = pfr.Contract__c) };
        try {
            sade = (AssociatedAccountsWrapper.SelectedAndDeselectedEntitlements) JSON.deserialize(
                pfr.Serialized_Entitlements_Data__c,
                AssociatedAccountsWrapper.SelectedAndDeselectedEntitlements.class
            );
        } catch (Exception ex) {
            Logger.publish(ex, LogEntry.SeverityLevel.HIGH);
        }

        Contracts.newInstance(contractsList)
            .setAssociatedAccountsWithGroups(
                new List<AssociatedAccountsWrapper>{
                    new AssociatedAccountsWrapper(
                        pfr.Group__c,
                        storeIdString,
                        pfr.Contract__c,
                        false,
                        sade
                    )
                },
                pfr.CCP_Applied__c,
                'Yes'
            );

        this.finishedStores.addAll(validStoreIds);
    }

    /**
     * @description It is used to create log records for the issues recorded
     * while bulk onboarding stores.
     */
    @TestVisible
    private void createLogEntries() {
        Set<Object> logCreationEntries = new Set<Object>();
        if (isEmptyOrNull(accountIdToLogMessageEntries.values())) {
            return;
        }
        // Create payload for asynchronous creation of business error logs.
        for (List<LogMessageEntry> eachLogMessageEntries : accountIdToLogMessageEntries.values()) {
            logCreationEntries.add(
                new LogCreationEntry(
                    BulkStoreOnboardingBatch.class.getName(),
                    LOG_RECORD_METHOD_NAME,
                    eachLogMessageEntries
                )
            );
        }
        NotifierEventsService.publishBulkEvents(
            new Map<String, List<String>>{
                EVENT_TOPIC_BUSINESS_ERROR_LOGS_CREATION => NotifierEventsPayloadGenerationService.generateChunkedPayloadsByObjects(
                    logCreationEntries,
                    logsPayloadChunkSize
                )
            }
        );
    }

    /**
     * @description To check whether the passed list or set or map is null or empty.
     * @param objectInstance - List/Set/Map
     * @return Boolean
     */
    private Boolean isEmptyOrNull(Object objectInstance) {
        return (JSON.serialize(objectInstance) == OBJECT_INSTANCE_NULL) ||
            JSON.serialize(objectInstance).equals(OBJECT_INSTANCE_LIST_OR_SET_EMTPY) ||
            JSON.serialize(objectInstance).equals(OBJECT_INSTANCE_MAP_EMPTY);
    }

    /**
     * @description It is used to capture the log details for initializing
     * creation of Logs.
     * @param detailedMessage
     * @param sObjectInstance
     * @param logErrorType
     * @param notifyAccountOwner
     * @param sourceRecordId
     * @param severityLevel
     */
    @TestVisible
    @SuppressWarnings('PMD.ExcessiveParameterList')
    private void logErrors(
        String detailedMessage,
        SObject sObjectInstance,
        String logErrorType,
        Boolean notifyAccountOwner,
        Id sourceRecordId,
        String severityLevel
    ) {
        Id parentId;
        String accountName;
        Account accountInstance;
        Set<String> recipientIdsToNotify = new Set<String>();
        if (sObjectInstance.Id.getSObjectType() == Schema.Account.SObjectType) {
            parentId = (Id) sObjectInstance.get('ParentId');
            accountName = (String) sObjectInstance.get('Name');
            accountInstance = (Account) sObjectInstance;
        }
        if (!accountIdToLogMessageEntries.containsKey(sObjectInstance.Id)) {
            accountIdToLogMessageEntries.put(sObjectInstance.Id, new List<LogMessageEntry>());
        }
        for (
            LogMessageEntry eachLogMessageEntry : accountIdToLogMessageEntries.get(
                sObjectInstance.Id
            )
        ) {
            if (eachLogMessageEntry.detailedMessage == detailedMessage) {
                return;
            }
        }
        LogMessageEntry logMessageEntry = new LogMessageEntry(
            parentId,
            detailedMessage,
            userInfo.getUserId(),
            sourceRecordId,
            sObjectInstance.Id
        );
        if (accountInstance != null) {
            recipientIdsToNotify.add(accountInstance.Parent.OwnerId);
            recipientIdsToNotify.add(pfr.Work_Order__r.OwnerId);
        }
        logMessageEntry.logType = logErrorType;
        logMessageEntry.recipientIdsToNotify = String.join(
            new List<String>(recipientIdsToNotify),
            COMMA_SEPARATOR
        );
        logMessageEntry.sendNotification = notifyAccountOwner;
        logMessageEntry.severityLevel = severityLevel;
        logMessageEntry.storeAccountName = accountName;
        accountIdToLogMessageEntries.get(sObjectInstance.Id).add(logMessageEntry);
    }

    /**
     * @description Puts the `StoreInfo` wrapper objects into a Map data structure and uses the Store ID (`Account.Id` of the Stores) as the key
     **/
    private void setStoreInfoMap() {
        List<BulkCorporateOnboardingWrappers.StoreInfo> storeInfos = BulkCorporateOnboardingRequestService.unpackStoreInfos(
            pfr.Id,
            pfr.Serialized_Object_Data__c
        );

        storeInfoMap = new Map<Id, BulkCorporateOnboardingWrappers.StoreInfo>();
        for (BulkCorporateOnboardingWrappers.StoreInfo storeInfo : storeInfos) {
            storeInfoMap.put(storeInfo.storeId, storeInfo);
        }
    }

    /**
     * @description Returns the Process Flow Request for this Batch run
     * @return Process_Flow_Request__c
     **/
    private Process_Flow_Request__c getFlowRequest() {
        List<Process_Flow_Request__c> requests = ProcessFlowRequestsSelector.newInstance()
            .selectById(new Set<Id>{ flowRequestId });
        return (requests != null && !requests.isEmpty()) ? requests[0] : null;
    }

    /**
     * @description Returns a String indicating the result of the batch operation
     * @return String
     **/
    private String getResultValue() {
        String result;
        Integer completedStores = this.finishedStores.size() + this.skippedStores.size();

        if (completedStores == this.storeInfoMap.keySet().size()) {
            result = RESULT_SUCCESS;
        } else if (completedStores == 0) {
            result = RESULT_FAILURE;
        } else {
            result = RESULT_PARTIAL_SUCCESS;
        }

        return result;
    }

    /**
     * @description Returns a String indicating the Status of the request
     * @return String
     **/
    private String getStatusValue() {
        String status;

        if (!containsFailures) {
            status = REQUEST_STATUS_COMPLETED;
        } else {
            status = REQUEST_STATUS_FAILED;
        }

        return status;
    }

    /**
     * @description Returns a String email subject
     * @return String
     **/
    private String getEmailSubject() {
        return (!containsFailures)
            ? 'Store Onboarding Completed'
            : 'ACTION REQUIRED: Store Onboarding Results';
    }

    /**
     * @description Returns a String email body
     * @return String
     **/
    private String getEmailBody() {
        String plainTextBody = '';

        if (!containsFailures) {
            plainTextBody +=
                'Your Store Onboarding Request is now completed. ' +
                this.storeCount +
                ' stores were processed successfully.';
        } else {
            plainTextBody +=
                'Your Store Onboarding Request has been processed. ' +
                this.storeCount +
                ' stores were processed successfully. ';
            plainTextBody += getFailureNotificationBody(); // Add details on the failures
        }

        return plainTextBody;
    }

    /**
     * @description Triggers a "Bell Notification" for the incomplete Stores.
     **/
    private void sendNotification() {
        if (containsFailures) {
            CustomNotificationType notificationType = BulkCorporateOnboardingRequestService.getNewStoreOnboardingCustomNotificationType();

            if (notificationType != null) {
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                notification.setNotificationTypeId(notificationType.Id);
                notification.setTargetId(pfr.OwnerId);
                notification.setTitle('Incomplete Store Onboarding Alert');
                notification.setBody(getFailureNotificationBody());
                notification.send(new Set<String>{ pfr.OwnerId });
            }
        }
    }

    /**
     * @description Returns the ContractNumber formatted for a notification
     * @return String
     **/
    private String getContractDisplayName() {
        String displayString = '';

        if (String.isNotBlank(this.contractName)) {
            displayString = '(' + this.contractName + ')';
        }

        return displayString;
    }

    /**
     * @description Returns the String for failure notifications
     * @return String
     **/
    private String getFailureNotificationBody() {
        String textBody = 'Some stores were not completed and added to the Work Order due to unverified or out of coverage addresses. ';
        textBody +=
            'Please navigate to the Contract ' +
            getContractDisplayName() +
            ' and click on "' +
            ANSO_BUTTON_NAME +
            '" for more details. ';
        textBody += 'From there, you can retry processing these stores once the addresses are verified.';
        return textBody;
    }

    /**
     * @description Updates the Serialized_Object_Data__c with the results of the job
     * @return String
     **/
    private String getSerializedStores() {
        List<BulkCorporateOnboardingWrappers.StoreInfo> storeInfos = BulkCorporateOnboardingRequestService.unpackStoreInfos(
            pfr.Id,
            pfr.Serialized_Object_Data__c
        );
        for (BulkCorporateOnboardingWrappers.StoreInfo storeInfo : storeInfos) {
            // If the batch was already completed, OR if it was completed in this run
            storeInfo.isJobComplete =
                storeInfo.isJobComplete || this.finishedStores.contains(storeInfo.storeId);
        }

        return BulkCorporateOnboardingRequestService.packStoreInfos(storeInfos);
    }
}