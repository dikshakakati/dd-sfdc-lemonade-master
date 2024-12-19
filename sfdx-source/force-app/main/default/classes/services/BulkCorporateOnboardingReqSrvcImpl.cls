/**
 * @author BizApps
 * @date 07/26/2023
 * @description Service implementation class for BulkCorporateOnboardingRequestService related logic
 */
public with sharing class BulkCorporateOnboardingReqSrvcImpl implements IBulkCorporateOnboardingRequestService {
    // ⚠️ Important ⚠️: Organize class variables in a logical sequence for better readability.
    // Start with Constants, grouped by their type (e.g., Strings, Integers), followed by Enums.
    // Then, list private member variables and other elements. Maintain this order consistently.

    // CONSTANTS
    private static final String ACCOUNT_OBJECT = 'Account';
    private static final String NOTIFICATION_NAME = 'Bulk_Onboarding_Notification';
    private static final String IN_COVERAGE = 'In Coverage';
    private static final String UNVERIFIED_STATUS = 'Unverified';
    private static final String VERIFIED_STATUS = 'Verified';
    private static final String REQUEST_STATUS_FAILED = 'Failed';
    private static final String RESULT_FAILURE = 'Failure';
    private static final String ERR_MSG_NO_PFR = 'No Process Flow Request record found for the specified ID: ';
    private static final String CHUNK_STATUS_COMPLETED = 'Completed';
    private static final String CHUNK_STATUS_IN_PROGRESS = 'In Progress';
    private static final String TABLET_SHIPPING_METHOD = 'Drop-ship';

    private static final Integer CHUNK_SIZE = 50;
    private static final Integer BATCH_DELAY_1 = 5;
    private static final Integer BATCH_DELAY_2 = 15;
    private static final Integer BATCH_DELAY_3 = 30;
    // PRIVATE MEMBER VARIABLES
    private Process_Flow_Request__c flowRequest { get; set; }
    private Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Store')
        .getRecordTypeId();

    private BulkOnboardingCsvProcessor csvProcessor {
        get {
            if (csvProcessor == null) {
                csvProcessor = new BulkOnboardingCsvProcessor();
            }
            return csvProcessor;
        }
        set;
    }

    private Integer batchSize {
        get {
            if (batchSize == null) {
                List<Static_Configurations__mdt> configs = StaticConfigurationsSelector.newInstance()
                    .selectByDeveloperName('ANSO_Batch_Limit');
                if (!configs.isEmpty()) {
                    batchSize = Integer.valueOf(configs[0].Configuration_Value__c);
                } else {
                    batchSize = 5; // a default value for safety
                }
            }
            return batchSize;
        }
        set;
    }

    /**
     * @description Determines if the Stores related to the `Process Flow Request` have had their addresses verified by the API.
     * @param flowRequestId - (Id) Id of the related PFR record
     * @return Boolean
     **/
    public BulkCorporateOnboardingWrappers.AddressVerificationResult updateAndRetrieveAddressJobStatus(
        Id flowRequestId
    ) {
        BulkCorporateOnboardingWrappers.AddressVerificationResult addressResults = getIsAddressJobCompleted(
            flowRequestId
        );
        writeAddressJobResults(flowRequestId, addressResults.storeInfos);

        return addressResults;
    }

    /**
     * @description Throws an exception if we cannot retrieve a PFR from a given ID.
     * @param flowRequestId - (Id) Id of the related PFR record
     * @return Process_Flow_Request__c
     **/
    public Process_Flow_Request__c getBulkOnboardingRequestOrAbort(Id flowRequestId) {
        List<Process_Flow_Request__c> results = ProcessFlowRequestsSelector.newInstance()
            .selectById(new Set<Id>{ flowRequestId });

        if (results.isEmpty()) {
            throw new BulkCorporateOnboardingRequestService.InvalidStoreOnboardingException(
                ERR_MSG_NO_PFR + flowRequestId
            );
        }

        return results[0];
    }

    /**
     * @description Determines whether the Onboarding Batch is ready to be executed, and, if not, then adds a delay to the job.
     * @param flowRequestId - (Id) Id of the related PFR record
     **/
    public void checkAndExecuteBatch(Id flowRequestId) {
        flowRequest = BulkCorporateOnboardingRequestService.getBulkOnboardingRequestOrAbort(
            flowRequestId
        );

        fflib_SObjectUnitOfWork uowInstance = new fflib_SObjectUnitOfWork(
            new List<SObjectType>{ Process_Flow_Request__c.sObjectType }
        );
        UpdateUnitOfWorkHelper uowUpdateHelper = new UpdateUnitOfWorkHelper();
        uowInstance.registerWork(uowUpdateHelper);

        // If the Store Address Verification API is complete, then execute the batch right away
        BulkCorporateOnboardingWrappers.AddressVerificationResult addressResults = BulkCorporateOnboardingRequestService.updateAndRetrieveAddressJobStatus(
            flowRequestId
        );
        if (addressResults.ranOnSomeStores) {
            if (!Test.isRunningTest()) {
                Database.executeBatch(new BulkStoreOnboardingBatch(flowRequestId), batchSize);
            }
        } else {
            Integer delayMinutes = 0;
            flowRequest.Batch_Delay_Number__c = flowRequest.Batch_Delay_Number__c == null
                ? 0
                : flowRequest.Batch_Delay_Number__c;

            // Calculate delay based on Batch_Delay_Number__c
            if (flowRequest.Batch_Delay_Number__c == 0) {
                delayMinutes = BATCH_DELAY_1;
            } else if (flowRequest.Batch_Delay_Number__c == 1) {
                delayMinutes = BATCH_DELAY_2;
            } else if (flowRequest.Batch_Delay_Number__c == 2) {
                delayMinutes = BATCH_DELAY_3;
            } else {
                // Failure Case - Maximum number of retries
                flowRequest.Status__c = REQUEST_STATUS_FAILED;
                flowRequest.Result__c = RESULT_FAILURE;
                flowRequest.Batch_Delay_Number__c = 3;
                uowUpdateHelper.registerUpdate(flowRequest);
                uowInstance.commitWork();

                sendFailureEmail(flowRequest.OwnerId);
                sendFailureNotification(flowRequest.OwnerId);
                return;
            }

            enqueueJobWithDelay(delayMinutes);
            flowRequest.Batch_Delay_Number__c += 1;
            uowUpdateHelper.registerUpdate(flowRequest);
            uowInstance.commitWork();
        }
    }

    /**
     * @description Returns the `CustomNotificationType` used in Automated New Store Onboarding
     * @return CustomNotificationType
     **/
    @SuppressWarnings('PMD.ApexCRUDViolation')
    public CustomNotificationType getNewStoreOnboardingCustomNotificationType() {
        CustomNotificationType notificationType;

        try {
            notificationType = [
                SELECT Id, DeveloperName
                FROM CustomNotificationType
                WHERE DeveloperName = :NOTIFICATION_NAME
            ];
        } catch (Exception ex) {
            notificationType = null;
        }

        return notificationType;
    }

    /**
     * @description Takes array of `StoreInfo` objects and converts it into tight serialized format
     * @param storeInfos - (List<BulkCorporateOnboardingWrappers.StoreInfo>) List of objects to minify
     * @return String
     **/
    public String packStoreInfos(List<BulkCorporateOnboardingWrappers.StoreInfo> storeInfos) {
        if (storeInfos == null || storeInfos.isEmpty()) {
            return '';
        }

        List<String> listOfStoreStrings = new List<String>();

        for (BulkCorporateOnboardingWrappers.StoreInfo thisStoreInfo : storeInfos) {
            listOfStoreStrings.add(thisStoreInfo.serialize());
        }

        return String.join(listOfStoreStrings, ';');
    }

    /**
     * @description Takes serialized string of raw data and converts to `StoreInfo` objects
     * @param flowRequestId - (String) Id of the relevant PFR record
     * @param storeInfoString - (String) Serialized string of StoreInfo data
     * @return List<BulkCorporateOnboardingWrappers.StoreInfo>
     **/
    public List<BulkCorporateOnboardingWrappers.StoreInfo> unpackStoreInfos(
        Id flowRequestId,
        String storeInfoString
    ) {
        List<BulkCorporateOnboardingWrappers.StoreInfo> returnList = new List<BulkCorporateOnboardingWrappers.StoreInfo>();

        if (String.isBlank(storeInfoString)) {
            return returnList;
        }

        List<String> listOfStoreStrings = storeInfoString.split(';');

        for (String thisStoreInfoString : listOfStoreStrings) {
            returnList.add(
                new BulkCorporateOnboardingWrappers.StoreInfo().deserialize(thisStoreInfoString)
            );
        }

        return getAddressInformationOnStoreInfos(flowRequestId, returnList);
    }

    /**
     * @description Retrieves the Stores that did not have their addresses verified successfully
     * @param flowRequestId - Id of the related Process_Flow_Request__c driving the process
     * @return List<Account>
     **/
    public List<Account> getFailedStores(Id flowRequestId) {
        List<Account> failedStores = new List<Account>();
        Set<Id> failedStoreIds = new Set<Id>();
        Process_Flow_Request__c flowRequest = BulkCorporateOnboardingRequestService.getBulkOnboardingRequestOrAbort(
            flowRequestId
        );

        List<BulkCorporateOnboardingWrappers.StoreInfo> storeInfos = BulkCorporateOnboardingRequestService.unpackStoreInfos(
            flowRequest.Id,
            flowRequest.Serialized_Object_Data__c
        );

        // We have the verification details in the StoreInfo objects in the Serialized Object JSON. Use that to
        // retrieve the Account IDs of the Stores, then all we have to do is call `selectByIds()` with those Stores.
        for (BulkCorporateOnboardingWrappers.StoreInfo thisStoreInfo : storeInfos) {
            if (!thisStoreInfo.isVerified) {
                failedStoreIds.add(thisStoreInfo.storeId);
            }
        }

        if (!failedStoreIds.isEmpty()) {
            failedStores = AccountsSelector.newInstance()
                .selectAccountsWithParentDetailsById(failedStoreIds);
        }
        return failedStores;
    }

    /**
     * @description Used to notify the user who is performing the Bulk Onboarding Request that the job has failed and retried the maximum number of times.
     * @param ownerId - (Id) PFR Owner to whom the email should be sent
     **/
    private void sendFailureEmail(Id ownerId) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject('Store Onboarding Failed');
        mail.setTargetObjectId(ownerId);
        mail.setSaveAsActivity(false);
        mail.setPlainTextBody(
            'The Store addresses were unable to be verified and onboarding could not be completed. Please contact support for assistance.'
        );
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
    }

    /**
     * @description Notifies the user, via Custom Notification, that the Bulk Onboarding job has failed the maximum number of times.
     * @param ownerId - (Id) PFR Owner to whom the email should be sent
     **/
    private void sendFailureNotification(Id ownerId) {
        CustomNotificationType notificationType = getNewStoreOnboardingCustomNotificationType();

        if (notificationType == null) {
            return;
        }

        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(ownerId);
        notification.setTitle('Store Onboarding Failed');
        notification.setBody(
            'The Store addresses were unable to be verified and onboarding could not be completed. Please contact support for assistance.'
        );
        notification.send(new Set<String>{ ownerId });
    }

    /**
     * @description It is used to Parse CSV file and check all the validations whether the CSV file is having
     * all required fields or not and also checking the CSV Header column name is correct or not. Also Validating
     * the Store Account Validations.
     * @param csvRows - (List<List<String>>) Rows for the CSV portion evaluated here
     * @param flowRequestId - (Id) Id of the related PFR record
     * @param chunkId - (Integer) Number of this current chunk/portion of CSV
     * @param totalChunks - (Integer) Number of total chunks/portions needed to parse
     * @return BulkCorporateOnboardingWrappers.StoreValidationResult
     **/
    public BulkCorporateOnboardingWrappers.StoreValidationResult parseAndValidateCsv(
        List<List<String>> csvRows,
        Id flowRequestId,
        Integer chunkId,
        Integer totalChunks
    ) {
        BulkCorporateOnboardingWrappers.StoreValidationResult onboardingResult = csvProcessor.parseAndValidateCsv(
            csvRows,
            flowRequestId,
            chunkId,
            totalChunks
        );
        processAndCommitChunks(onboardingResult, flowRequestId, chunkId);
        return onboardingResult;
    }

    /**
     * @description Queries the Process_Flow_Request_Chunk__c related to a PFR Id and then deserializes the Serialized_Data__c
     *              into `List<Account>` of Stores. These should then be inserted.
     * @param flowRequestId - (Id) Id of the related PFR record
     * @param chunksToProcess - (Integer) Number of chunks to query
     * @param results - (BulkCorporateOnboardingWrappers.StoreValidationResult) Store upload details
     * @return BulkCorporateOnboardingWrappers.StoreValidationResult
     **/
    public BulkCorporateOnboardingWrappers.StoreValidationResult parseAndInsertStores(
        Id flowRequestId,
        Integer chunksToProcess,
        BulkCorporateOnboardingWrappers.StoreValidationResult results
    ) {
        fflib_ISObjectUnitOfWork uowInstance = Application.UNITOFWORK.newInstance();
        InsertUnitOfWorkHelper uowHelper = new InsertUnitOfWorkHelper();
        UpdateUnitOfWorkHelper uowUpdateHelper = new UpdateUnitOfWorkHelper();
        uowInstance.registerWork(uowHelper);
        uowInstance.registerWork(uowUpdateHelper);
        List<Process_Flow_Request_Chunk__c> chunks = ProcessFlowRequestChunksSelector.newInstance()
            .selectSubsetOfOpenChunksByRequestId(flowRequestId, chunksToProcess);
        Integer startIndex = (chunks != null && !chunks.isEmpty())
            ? ((Integer.valueOf(chunks[0].Chunk_Number__c) - 1) * CHUNK_SIZE)
            : 0;
        List<Account> allStores = new List<Account>();
        Database.DMLOptions dmlOptions = new Database.DMLOptions();
        dmlOptions.DuplicateRuleHeader.allowSave = true;
        uowHelper.setDmlOptions(dmlOptions);

        Set<Integer> storeIndicesToSkip = new Set<Integer>();
        if (results.rowsToRemoveFromUpload != null) {
            storeIndicesToSkip = new Set<Integer>(results.rowsToRemoveFromUpload);
        }

        for (Process_Flow_Request_Chunk__c chunk : chunks) {
            Integer index = 1;
            List<Account> accountsToInsert = (List<Account>) JSON.deserialize(
                chunk.Serialized_Data__c,
                List<Account>.class
            );

            for (Account acc : accountsToInsert) {
                Integer storeIndex =
                    (Integer.valueOf(chunk.Chunk_Number__c) - 1) * CHUNK_SIZE + index;
                allStores.add(acc);

                // Do not add to this if we did not click the "Upload" button
                if (!storeIndicesToSkip.contains(storeIndex)) {
                    uowHelper.registerInsert(acc);
                }

                index++;
            }

            chunk.Status__c = CHUNK_STATUS_COMPLETED;
            uowUpdateHelper.registerUpdate(chunk);
        }

        uowInstance.commitWork();

        // Populate the StoreInfo objects with the newly-set record IDs
        for (Integer i = 0; i < allStores.size(); i++) {
            Account acc = allStores[i];
            results.storeWrappers[startIndex + i].storeId = acc.Id;
        }

        results.saveFinished = (startIndex + allStores.size()) == results.storeWrappers.size();
        return results;
    }

    /**
     * @description Populates a Store SObject record with default values from the WorkOrder
     * @param flowRequestId - (Id) Id of the related PFR record
     * @param businessAccount - (Account) The related Business Account
     * @param thisWorkOrder - (WorkOrder) Selected WorkOrder record
     * @return SObject
     **/
    public SObject populateStoreWithDefaults(
        Id flowRequestId,
        Account businessAccount,
        WorkOrder thisWorkOrder
    ) {
        SObject newRecord = Schema.getGlobalDescribe().get(ACCOUNT_OBJECT).newSObject();
        newRecord.put('RecordTypeId', storeRecordTypeId);
        newRecord.put('Bulk_Corporate_Onboarding_Request__c', flowRequestId);

        // Derive values from the parent
        if (businessAccount != null) {
            newRecord.put('ParentId', businessAccount.Id);
            newRecord.put('Segment__c', businessAccount.Segment__c);
            newRecord.put('BillingCountryCode', businessAccount.BillingCountryCode);
        }

        // Include defaults from the WorkOrder so we do not need to populate it separately
        if (thisWorkOrder != null) {
            newRecord.put('Activated_Centrally_AC__c', thisWorkOrder.Activated_Centrally_AC__c);
            newRecord.put('Menu_to_be_Completed_By__c', thisWorkOrder.Menu_to_be_Completed_By__c);
            newRecord.put('Order_Protocol__c', thisWorkOrder.Order_Protocol__c);
            newRecord.put('POS_Integration_Type__c', thisWorkOrder.POS_Integration_Type__c);
            newRecord.put('Menu_Setup_Method__c', thisWorkOrder.Menu_Setup_Method__c);
            newRecord.put('Tablet_Delivery_Method__c', getTabletDeliveryMethod(thisWorkOrder));
        }

        return newRecord;
    }

    /**
     * @description Retrieves the Business Account details for an ANSO request, by the Contract
     * @param thisContract - (Contract) The Contract from the request
     * @return Account
     **/
    public Account getBusinessAccountForContract(Contract thisContract) {
        Account businessAccount;

        if (thisContract?.AccountId != null) {
            List<Account> matchedAccounts = AccountsSelector.newInstance()
                .selectById(new Set<Id>{ thisContract.AccountId });
            businessAccount = (matchedAccounts != null && !matchedAccounts.isEmpty())
                ? matchedAccounts[0]
                : null;
        }

        return businessAccount;
    }

    /**
     * @description Serializes a List of Accounts for the current transaction so they can be bulk inserted later.
     * @param flowRequestId
     * @param storeResults
     * @param chunkNumber
     * @return Process_Flow_Request_Chunk__c
     **/
    private static Process_Flow_Request_Chunk__c processDataAsChunk(
        Id flowRequestId,
        BulkCorporateOnboardingWrappers.StoreValidationResult storeResults,
        Integer chunkNumber
    ) {
        Process_Flow_Request_Chunk__c newChunk = new Process_Flow_Request_Chunk__c();
        newChunk.Process_Flow_Request__c = flowRequestId;
        newChunk.Serialized_Data__c = JSON.serialize(storeResults.newRecords);
        newChunk.Error_Message__c = JSON.serialize(storeResults.errorMessages);
        newChunk.Chunk_Number__c = chunkNumber;
        newChunk.Status__c = CHUNK_STATUS_IN_PROGRESS;
        return newChunk;
    }

    /**
     * @description Takes the results from the upload and commits them as Process Flow Request Chunks
     * @param bulkCorporateOnboardings - The results of the Store validation process
     * @param flowRequestId - The ID of the parent Process Flow Request
     * @param chunkId - The chunk # we are currently processing
     **/
    private void processAndCommitChunks(
        BulkCorporateOnboardingWrappers.StoreValidationResult bulkCorporateOnboardings,
        Id flowRequestId,
        Integer chunkId
    ) {
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();

        // Insert the PFR Chunks
        Process_Flow_Request_Chunk__c newChunk = processDataAsChunk(
            flowRequestId,
            bulkCorporateOnboardings,
            chunkId
        );
        uow.registerNew(newChunk);
        uow.commitWork();
    }

    /**
     * @description Updates the Process Flow Request record with the new addresses
     * @param flowRequestId - (Id) Id of the related PFR record
     * @param storeInfos - StoreInfo wrappers to update in the Serialized_Object_JSON__c
     **/
    private void writeAddressJobResults(
        Id flowRequestId,
        List<BulkCorporateOnboardingWrappers.StoreInfo> storeInfos
    ) {
        Process_Flow_Request__c flowRequest = getBulkOnboardingRequestOrAbort(flowRequestId);

        fflib_SObjectUnitOfWork uowInstance = new fflib_SObjectUnitOfWork(
            new List<SObjectType>{ Process_Flow_Request__c.sObjectType }
        );

        UpdateUnitOfWorkHelper uowUpdateHelper = new UpdateUnitOfWorkHelper();
        uowInstance.registerWork(uowUpdateHelper);

        flowRequest.Serialized_Object_Data__c = BulkCorporateOnboardingRequestService.packStoreInfos(
            storeInfos
        );
        uowUpdateHelper.registerUpdate(flowRequest);
        uowInstance.commitWork();
    }

    /**
     * @description Determines if the Stores related to the `Process Flow Request` have had their addresses verified by the API.
     *              This method gets values for the `AddressVerificationResult` objects.
     * @param flowRequestId - (Id) Id of the related PFR record
     * @return BulkCorporateOnboardingWrappers.AddressVerificationResult
     **/
    private BulkCorporateOnboardingWrappers.AddressVerificationResult getIsAddressJobCompleted(
        Id flowRequestId
    ) {
        Process_Flow_Request__c flowRequest = getBulkOnboardingRequestOrAbort(flowRequestId);
        BulkCorporateOnboardingWrappers.AddressVerificationResult addressInfo = new BulkCorporateOnboardingWrappers.AddressVerificationResult();

        List<BulkCorporateOnboardingWrappers.StoreInfo> storeInfos = BulkCorporateOnboardingRequestService.unpackStoreInfos(
            flowRequest.Id,
            flowRequest.Serialized_Object_Data__c
        );
        addressInfo.storeInfos = getAddressInformationOnStoreInfos(flowRequestId, storeInfos);

        for (BulkCorporateOnboardingWrappers.StoreInfo thisStoreInfo : addressInfo.storeInfos) {
            if (!thisStoreInfo.isVerified) {
                addressInfo.successOnAllStores = false;
            }

            if (!thisStoreInfo.isJobRun) {
                addressInfo.ranOnAllStores = false;
            }

            if (thisStoreInfo.isJobRun) {
                addressInfo.ranOnSomeStores = true;
            }
        }

        return addressInfo;
    }

    /**
     * @description Determines if the Stores related to the `Process Flow Request` have had their addresses verified by the API
     *              This is the method that computes the values for all the address-based `StoreInfo` properties.
     * @param flowRequestId - (Id) Id of the related PFR record
     * @param storeInfos - (List<BulkCorporateOnboardingWrappers.StoreInfo>) StoreInfo list to run
     * @return List<BulkCorporateOnboardingWrappers.StoreInfo>
     **/
    private List<BulkCorporateOnboardingWrappers.StoreInfo> getAddressInformationOnStoreInfos(
        Id flowRequestId,
        List<BulkCorporateOnboardingWrappers.StoreInfo> storeInfos
    ) {
        List<BulkCorporateOnboardingWrappers.StoreInfo> filteredStoreInfos = new List<BulkCorporateOnboardingWrappers.StoreInfo>();
        Map<Id, Account> storesByIds = new Map<Id, Account>(
            AccountsSelector.newInstance().getStoresByBulkOnboardingRequestId(flowRequestId)
        );

        for (BulkCorporateOnboardingWrappers.StoreInfo thisStoreInfo : storeInfos) {
            Account thisStoreAccount = storesByIds.get(thisStoreInfo.storeId);

            // Remove any Store that no longer exists as an Account record!
            if (thisStoreAccount == null) {
                continue;
            }

            thisStoreInfo.isVerified =
                thisStoreAccount.Address_Verification_Status__c == VERIFIED_STATUS &&
                thisStoreAccount.Coverage__c == IN_COVERAGE;
            thisStoreInfo.isJobRun =
                thisStoreAccount.Address_Verification_Status__c != UNVERIFIED_STATUS; // "Unverified" is the default on Store insertion

            filteredStoreInfos.add(thisStoreInfo);
        }

        return filteredStoreInfos;
    }

    /**
     * @description Executes our scheduled batch job after a predefined delay
     * @param delayMinutes - (Integer) Delay to apply, in minutes
     **/
    private void enqueueJobWithDelay(Integer delayMinutes) {
        // Schedule the job to run again after the delay
        DateTime timeToExecute = System.now().addMinutes(delayMinutes);
        String cronExpression =
            '' +
            timeToExecute.second() +
            ' ' +
            timeToExecute.minute() +
            ' ' +
            timeToExecute.hour() +
            ' ' +
            timeToExecute.day() +
            ' ' +
            timeToExecute.month() +
            ' ? ' +
            timeToExecute.year();

        if (!Test.isRunningTest()) {
            System.schedule(
                'Bulk Onboarding Scheduler - Retry' + System.currentTimeMillis(),
                cronExpression,
                new BulkStoreOnboardingScheduler(flowRequest.Id)
            );
        }
    }

    /**
     * @description Determines if the Work Order requires tablet delivery
     * @param thisWorkOrder - (WorkOrder) WorkOrder record to evaluate
     * @return String
     **/
    private String getTabletDeliveryMethod(WorkOrder thisWorkOrder) {
        // Can move these to class-level constants later if there is another use for them
        Set<String> dropShipTabletTypes = new Set<String>{
            '2 Tablets (Caviar and DoorDash Own)',
            'Tablet (DoorDash Owns)',
            'Tablet and Printer (DoorDash Owns)',
            'POS and 2 Tablets (Caviar POS, DoorDash and Caviar Tablets)',
            'POS and 2 Tablets (DoorDash POS, DoorDash and Caviar Tablets)',
            'POS and Tablet (DoorDash Owns)'
        };

        return dropShipTabletTypes.contains(thisWorkOrder?.Order_Protocol__c)
            ? TABLET_SHIPPING_METHOD
            : null;
    }
}