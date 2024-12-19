/**
 * @description (LEM-8212) Manages the Flow and Lightning Components for Bulk Store Onboarding
 * @author BizApps
 * @date 24-July-2023
 **/
public with sharing class BulkCorporateOnboardingRequestService {
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
    public static BulkCorporateOnboardingWrappers.StoreValidationResult parseAndValidateCsv(
        List<List<String>> csvRows,
        Id flowRequestId,
        Integer chunkId,
        Integer totalChunks
    ) {
        return service().parseAndValidateCsv(csvRows, flowRequestId, chunkId, totalChunks);
    }

    /**
     * @description Queries the Process_Flow_Request_Chunk__c related to a PFR Id and then deserializes the Serialized_Data__c
     *              into `List<Account>` of Stores. These should then be inserted.
     * @param flowRequestId - (Id) Id of the related PFR record
     * @param chunksToProcess - (Integer) Number of chunks to use
     * @param results - (StoreValidationResult) Upload results
     * @return BulkCorporateOnboardingWrappers.StoreValidationResult
     **/
    public static BulkCorporateOnboardingWrappers.StoreValidationResult parseAndInsertStores(
        Id flowRequestId,
        Integer chunksToProcess,
        BulkCorporateOnboardingWrappers.StoreValidationResult results
    ) {
        return service().parseAndInsertStores(flowRequestId, chunksToProcess, results);
    }

    /**
     * @description Populates a Store SObject record with default values from the WorkOrder
     * @param flowRequestId - (Id) Id of the related PFR record
     * @param businessAccount - (Account) The related Business Account
     * @param thisWorkOrder - (WorkOrder) Selected WorkOrder record
     * @return SObject
     **/
    public static SObject populateStoreWithDefaults(
        Id flowRequestId,
        Account businessAccount,
        WorkOrder thisWorkOrder
    ) {
        return service().populateStoreWithDefaults(flowRequestId, businessAccount, thisWorkOrder);
    }

    /**
     * @description Retrieves the Business Account details for an ANSO request, by the Contract
     * @param thisContract - (Contract) The Contract from the request
     * @return Account
     **/
    public static Account getBusinessAccountForContract(Contract thisContract) {
        return service().getBusinessAccountForContract(thisContract);
    }

    /**
     * @description Determines if the Stores related to the `Process Flow Request` have had their addresses verified by the API.
     *              Also updates the `Serialized_Object_Data__c` on the related Process Flow Request with the address details.
     * @param flowRequestId - (Id) Id of the related PFR record
     * @return BulkCorporateOnboardingWrappers.AddressVerificationResult
     **/
    public static BulkCorporateOnboardingWrappers.AddressVerificationResult updateAndRetrieveAddressJobStatus(
        Id flowRequestId
    ) {
        return service().updateAndRetrieveAddressJobStatus(flowRequestId);
    }

    /**
     * @description Throws an exception if we cannot retrieve a PFR from a given ID.
     * @param flowRequestId - (Id) Id of the related PFR record
     * @return Process_Flow_Request__c
     **/
    public static Process_Flow_Request__c getBulkOnboardingRequestOrAbort(Id flowRequestId) {
        return service().getBulkOnboardingRequestOrAbort(flowRequestId);
    }

    /**
     * @description Determines whether the Onboarding Batch is ready to be executed, and, if not, then adds a delay to the job.
     * @param flowRequestId - (Id) Id of the related PFR record
     **/
    public static void checkAndExecuteBatch(Id flowRequestId) {
        service().checkAndExecuteBatch(flowRequestId);
    }

    /**
     * @description Returns the `CustomNotificationType` used in Automated New Store Onboarding
     * @return CustomNotificationType
     **/
    public static CustomNotificationType getNewStoreOnboardingCustomNotificationType() {
        return service().getNewStoreOnboardingCustomNotificationType();
    }

    /**
     * @description Takes array of `StoreInfo` objects and converts it into tight serialized format
     * @param storeInfos - (List<BulkCorporateOnboardingWrappers.StoreInfo>) List of objects to minify
     * @return String
     **/
    public static String packStoreInfos(
        List<BulkCorporateOnboardingWrappers.StoreInfo> storeInfos
    ) {
        return service().packStoreInfos(storeInfos);
    }

    /**
     * @description Takes serialized string of raw data and converts to `StoreInfo` objects
     * @param flowRequestId - (String) Id of the relevant PFR record
     * @param storeInfoString - (String) Serialized string of StoreInfo data
     * @return List<BulkCorporateOnboardingWrappers.StoreInfo>
     **/
    public static List<BulkCorporateOnboardingWrappers.StoreInfo> unpackStoreInfos(
        Id flowRequestId,
        String storeInfoString
    ) {
        return service().unpackStoreInfos(flowRequestId, storeInfoString);
    }

    /**
     * @description Retrieves the Stores that did not have their addresses verified successfully
     * @param flowRequestId - Id of the related Process_Flow_Request__c driving the process
     * @return List<Account>
     **/
    public static List<Account> getFailedStores(Id flowRequestId) {
        return service().getFailedStores(flowRequestId);
    }

    /**
     * @description It creates instance of BulkCorporateOnboardingReqSrvcImpl class.
     * @return IBulkCorporateOnboardingRequestService - return instance of BulkCorporateOnboardingReqSrvcImpl
     */
    private static IBulkCorporateOnboardingRequestService service() {
        return (IBulkCorporateOnboardingRequestService) Application.Service.newInstance(
            IBulkCorporateOnboardingRequestService.class
        );
    }

    /**
     * @description Exception type thrown if there is an issue with the inputted PFR
     **/
    public class InvalidStoreOnboardingException extends Exception {
    }

    /**
     * @description Exception type thrown if the persisted `StoreInfo` is invalid or missing
     **/
    public class InvalidStoreWrapperException extends Exception {
    }
}