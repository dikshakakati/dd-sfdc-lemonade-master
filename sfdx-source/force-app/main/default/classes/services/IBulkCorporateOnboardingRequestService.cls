/**
 * @author BizApps
 * @date 07/26/2023
 * @description Interface of service class for BulkCorporateOnboardingRequestService related logic.
 */
public interface IBulkCorporateOnboardingRequestService {
    /**
     * @description It is used to Parse CSV file and check all the validations whether the CSV file is having
     * all required fields or not and also checking the CSV Header column name is correct or not. Also Validating
     * the Store Account Validations.
     * @param csvRows - (List<List<String>>) Rows from relevant portion of CSV
     * @param flowRequestId - (Id) Id of the related PFR record
     * @param chunkId - (Integer) Id of the related PFR record
     * @param totalChunks - (Integer) Id of the related PFR record
     * @return BulkCorporateOnboardingWrappers.StoreValidationResult
     **/
    BulkCorporateOnboardingWrappers.StoreValidationResult parseAndValidateCsv(
        List<List<String>> csvRows,
        Id flowRequestId,
        Integer chunkId,
        Integer totalChunks
    );

    /**
     * @description Queries the Process_Flow_Request_Chunk__c related to a PFR Id and then deserializes the Serialized_Data__c
     *              into `List<Account>` of Stores. These should then be inserted.
     * @param flowRequestId - (Id) Id of the related PFR record
     * @param chunksToProcess - (Integer) Number of chunks to use
     * @param results - (StoreValidationResult) Upload results
     * @return BulkCorporateOnboardingWrappers.StoreValidationResult
     **/
    BulkCorporateOnboardingWrappers.StoreValidationResult parseAndInsertStores(
        Id flowRequestId,
        Integer chunksToProcess,
        BulkCorporateOnboardingWrappers.StoreValidationResult results
    );

    /**
     * @description Populates a Store SObject record with default values from the WorkOrder
     * @param flowRequestId - (Id) Id of the related PFR record
     * @param businessAccount - (Account) The related Business Account
     * @param thisWorkOrder - (WorkOrder) Selected WorkOrder record
     * @return SObject
     **/
    SObject populateStoreWithDefaults(
        Id flowRequestId,
        Account businessAccount,
        WorkOrder thisWorkOrder
    );

    /**
     * @description Retrieves the Business Account details for an ANSO request, by the Contract
     * @param thisContract - (Contract) The Contract from the request
     * @return Account
     **/
    Account getBusinessAccountForContract(Contract thisContract);

    /**
     * @description Determines if the Stores related to the `Process Flow Request` have had their addresses verified by the API.
     *              Also updates the `Serialized_Object_Data__c` on the related Process Flow Request with the address details.
     * @param flowRequestId - (Id) Id of the related PFR record
     * @return BulkCorporateOnboardingWrappers.AddressVerificationResult
     **/
    BulkCorporateOnboardingWrappers.AddressVerificationResult updateAndRetrieveAddressJobStatus(
        Id flowRequestId
    );

    /**
     * @description Throws an exception if we cannot retrieve a PFR from a given ID.
     * @param flowRequestId - (Id) Id of the related PFR record
     * @return Process_Flow_Request__c
     **/
    Process_Flow_Request__c getBulkOnboardingRequestOrAbort(Id flowRequestId);

    /**
     * @description Determines whether the Onboarding Batch is ready to be executed, and, if not, then adds a delay to the job.
     * @param flowRequestId - (Id) Id of the related PFR record
     **/
    void checkAndExecuteBatch(Id flowRequestId);

    /**
     * @description Returns the `CustomNotificationType` used in Automated New Store Onboarding
     * @return CustomNotificationType
     **/
    CustomNotificationType getNewStoreOnboardingCustomNotificationType();

    /**
     * @description Takes array of `StoreInfo` objects and converts it into tight serialized format
     * @param storeInfos - (List<BulkCorporateOnboardingWrappers.StoreInfo>) List of objects to minify
     * @return String
     **/
    String packStoreInfos(List<BulkCorporateOnboardingWrappers.StoreInfo> storeInfos);

    /**
     * @description Takes serialized string of raw data and converts to `StoreInfo` objects
     * @param flowRequestId - (String) Id of the relevant PFR record
     * @param storeInfoString - (String) Serialized string of StoreInfo data
     * @return List<BulkCorporateOnboardingWrappers.StoreInfo>
     **/
    List<BulkCorporateOnboardingWrappers.StoreInfo> unpackStoreInfos(
        Id flowRequestId,
        String storeInfoString
    );

    /**
     * @description Retrieves the Stores that did not have their addresses verified successfully
     * @param flowRequestId - Id of the related Process_Flow_Request__c driving the process
     * @return List<Account>
     **/
    List<Account> getFailedStores(Id flowRequestId);
}