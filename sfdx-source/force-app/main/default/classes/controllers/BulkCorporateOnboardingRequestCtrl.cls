/**
 * @description (LEM-8212) Manages the Flow and LWCS for Bulk Store Onboarding
 * @author BizApps
 * @date 31-July-2023
 **/
@SuppressWarnings(
    'PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity, PMD.ExcessivePublicCount, PMD.ApexSOQLInjection, PMD.ExcessiveClassLength'
)
public without sharing class BulkCorporateOnboardingRequestCtrl {
    private static final String DELIMETER_COMMA = ',';
    private static final String DELIMETER_PERIOD = '.';
    private static final String SPLIT_BY_PERIOD = '\\.';
    private static final String SUB_FIELDS_UI_DELIMETER = ' • ';
    private static final String KEY_DEFAULT = 'default';
    private static final String KEY_VALUES = 'values';
    private static final String PAYMENT_ACCOUNT_OBJECT_API_NAME = 'Payment_Account__c';
    private static final String RECORD_TYPE_INVOICE = 'RecordType.Name != \'Invoice\'';
    private static final String REQUEST_STATUS_IN_PROGRESS = 'In Progress';
    private static final String REQUEST_STATUS_COMPLETED = 'Completed';
    private static final String REQUEST_STATUS_FAILED = 'Failed';
    private static final String REQUEST_STATUS_ABORTED = 'Aborted';
    private static final String REQUEST_STAGE_WORK_ORDER_TYPE_SELECTION = 'Work Order Type Selection';
    private static final String REQUEST_STAGE_WORK_ORDER_CREATION = 'Work Order Creation';
    private static final String REQUEST_STAGE_WORK_ORDER_ASSOCIATION = 'Work Order Association';
    private static final String REQUEST_STAGE_ACCOUNT_FILE_UPLOAD = 'Account File Upload';
    private static final String REQUEST_STAGE_SELECT_ENTITELEMENT = 'Select Entitlement';
    private static final String REQUEST_STAGE_PAYMENT_ACCOUNT = 'Payment Account';
    private static final String REQUEST_STAGE_DECISION_MAKER = 'Decision Maker';
    private static final String REQUEST_STAGE_FINAL_ERROR_CHECK = 'Final Error Check';
    private static final String PROCESSING_STORES = 'Processing Stores';
    private static final String UPLOAD_COMPLETE = 'Upload Complete';

    private static final String REQUEST_WO_SELECTION_NEW = 'Created New';
    private static final String REQUEST_WO_SELECTION_EXISTING = 'Selected Existing';

    private static final String ACTIVATE_CENTRALLY_NO = 'No';
    private static final String ORDER_PROTOCOL_POS = 'POS';
    private static final String MENU_TO_BE_COMPLETED_BY_ACCOUNT_OWNER = 'Account Owner';

    private static final String WO_RULE_ACTIVATE_CENTRALLY = 'Activate_Centrally_equals_No_on_WO';
    private static final String WO_RULE_POS_ID_REQUIRED = 'POSIntegrationID_req_on_Store_when_POS';
    private static final String WO_RULE_POS_TYPE_REQUIRED = 'POSIntegrationType_req_on_Store_when_POS';
    private static final Set<String> WORK_ORDER_RULES = new Set<String>{
        WO_RULE_ACTIVATE_CENTRALLY,
        WO_RULE_POS_ID_REQUIRED,
        WO_RULE_POS_TYPE_REQUIRED
    };

    private static final Id BULK_ONBOARDING_RT_ID = Schema.SObjectType.Process_Flow_Request__c.getRecordTypeInfosByDeveloperName()
        .get('Bulk_Store_Onboarding')
        .getRecordTypeId();
    private static final String ALLOW_HIGH_VOLUME_BULK_ONBOARD_STORES_CUSTOM_PERMISSION = 'Allow_High_Volume_Bulk_Onboard_Stores';
    private static final String WO_TYPE_VALIDATION_MSG_CONTENT = 'ANSO_WorkOrder_Type_Error_Message';

    /**
     * @description Gets a map of the PFR Stages and the order in which they appear
     * @return Map<Integer, String>
     **/
    public static Map<Integer, String> stagesByOrder {
        get {
            if (stagesByOrder == null) {
                stagesByOrder = new Map<Integer, String>{
                    1 => REQUEST_STAGE_WORK_ORDER_TYPE_SELECTION,
                    2 => REQUEST_STAGE_WORK_ORDER_CREATION,
                    3 => REQUEST_STAGE_WORK_ORDER_ASSOCIATION,
                    4 => REQUEST_STAGE_ACCOUNT_FILE_UPLOAD,
                    5 => REQUEST_STAGE_SELECT_ENTITELEMENT,
                    7 => REQUEST_STAGE_PAYMENT_ACCOUNT,
                    8 => REQUEST_STAGE_DECISION_MAKER,
                    9 => REQUEST_STAGE_FINAL_ERROR_CHECK,
                    10 => PROCESSING_STORES,
                    11 => UPLOAD_COMPLETE
                };
            }
            return stagesByOrder;
        }
        set;
    }

    /**
     * @description (LEM-8466) Closes an existing Process_Flow_Request__c.
     * @param flowRequestId - Id of the Process Flow Request to close out
     **/
    @AuraEnabled
    public static void closeExistingRequest(Id flowRequestId) {
        Process_Flow_Request__c flowRequest = getFlowRequestById(flowRequestId);
        flowRequest.Status__c = REQUEST_STATUS_ABORTED;
        flowRequest = commitProcessFlowRequestUpdates(flowRequest);
    }
    /**
     * @description (LEM-8466) Creates a NEW Process_Flow_Request__c for a Contract/WorkOrder.
                        This will onboarding Stores in bulk for that Account.
     * @param contractId - Id of the parent Contract
     * @param workOrderId - Id of the selected WorkOrder
     * @return Process_Flow_Request__c
    **/
    @TestVisible
    private static Process_Flow_Request__c createRequest(Id contractId, Id workOrderId) {
        Process_Flow_Request__c newRequest = new Process_Flow_Request__c();
        newRequest.RecordTypeId = BULK_ONBOARDING_RT_ID;
        newRequest.Contract__c = contractId;
        newRequest.Work_Order__c = workOrderId;
        newRequest.Status__c = REQUEST_STATUS_IN_PROGRESS;
        newRequest.Stage__c = stagesByOrder.get(1);
        return newRequest;
    }

    /**
     * @description (LEM-8474) Retrieves related Work Orders from the given Account.
     * @param accountId - Id of the Account the user is currently on.
     * @return List<WorkOrder>
     **/
    @AuraEnabled(cacheable=true)
    public static List<WorkOrder> getExistingWorkOrders(Id accountId) {
        return WorkOrdersSelector.newInstance().selectWorkOrderDetailsForAccount(accountId);
    }

    /**
     * @description (LEM-19661) Validate the Subscription Pacakge of the WorkOrder Type Present or not.
     * @param type - String of the Work Order
     * @param contractId - Id of the Contract
     * @return String
    **/
    public static String validateWorkOrderType(String type, Id contractId) {
        String validationMessage = '';
        Map<String, Eligible_Package_To_Wo_Type_Mapping__mdt> packageToWoTypeMappingRecords = Eligible_Package_To_Wo_Type_Mapping__mdt.getAll();
        Set<String> productCodes = new Set<String>();

        for(String eachMetadata: packageToWoTypeMappingRecords.keySet()){
            if(packageToWoTypeMappingRecords.get(eachMetadata).Work_Order_Type__c == type){
                productCodes.add(packageToWoTypeMappingRecords.get(eachMetadata).Product_Code__c);
            }
        }
        List<SBQQ__Subscription__c> activeSubList = SubscriptionSelector.newInstance().selectActiveSubscriptionListBasedOnProductCode(contractId,productCodes);
        if(activeSubList == null || activeSubList.isEmpty()){
            validationMessage += getPackageAndWorkOrderTypeMismatchValidationMessage(type);
        }
        return validationMessage;
    }

    /**
     * @description Create a validation message for Package and WO type missmatch
     * @param workOrderType
     * @return String
    **/
    private static String getPackageAndWorkOrderTypeMismatchValidationMessage(String workOrderType){
        String validationMessage = '';
        Static_Configurations__mdt woTypeValidationMessage = Static_Configurations__mdt.getInstance(
            WO_TYPE_VALIDATION_MSG_CONTENT
        );

        if(workOrderType == System.Label.WorkOrder_Type_Marketplace){
            validationMessage = WoTypeValidationMessage.Configuration_Value__c;
        }
        return validationMessage;
    }

    /**
     * @description Indicates whether we are working on a Tablet scenario
     * @param flowRequestId - Id of the PFR to get the WorkOrder from
     * @return Boolean
     **/
    @AuraEnabled(cacheable=true)
    public static Boolean checkIfTabletWorkOrder(Id flowRequestId) {
        try {
            Process_Flow_Request__c flowRequest = getFlowRequestById(flowRequestId);
            List<WorkOrder> workOrders = WorkOrdersSelector.newInstance()
                .selectById(new Set<Id>{ flowRequest.Work_Order__c });

            return workOrders[0]
                .Order_Protocol__c.contains(System.Label.LaunchEventOrderProtocolTablet);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description It is used to get the match account's details.
     * by the passed ids.
     * JIRA# LEM-11012
     * @param accountIds
     * @return List<Account>
     **/
    @AuraEnabled
    public static List<Account> getMatchingAccountsDetails(List<Id> accountIds) {
        return AccountsSelector.newInstance()
            .selectAccountsByIdAndFieldSet(
                SObjectType.Account.FieldSets.Bulk_Onboarding_Duplicate_Account_Fields,
                new Set<Id>(accountIds)
            );
    }

    /**
     * @description Retrieves the `Status` picklist values for the `WorkOrder` object as
     *              this field should be read-only.
     * @return Map<String, Object>
     **/
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getStatusPicklistValues() {
        Map<String, Object> result = new Map<String, Object>();
        List<String> picklistValuesList = new List<String>();
        String defaultPicklistValue;

        Schema.DescribeFieldResult fieldResult = WorkOrder.Status.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry picklistValue : ple) {
            picklistValuesList.add(picklistValue.getLabel());
            if (picklistValue.isDefaultValue()) {
                defaultPicklistValue = picklistValue.getLabel();
            }
        }

        result.put('values', picklistValuesList);
        result.put('default', defaultPicklistValue);
        return result;
    }

    /**
     * @description It is used to retrieve the Work Order's 'Type' picklist values.
     * JIRA# LEM-10202
     * @return Map<String, Object>
     **/
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getTypePicklistValues() {
        List<String> typePicklistValues = new List<String>();
        Map<String, Object> workOrderTypes = new Map<String, Object>();
        for (
            Schema.PicklistEntry eachPicklistEntry : WorkOrder.Type__c.getDescribe()
                .getPicklistValues()
        ) {
            typePicklistValues.add(eachPicklistEntry.getLabel());
        }
        workOrderTypes.put(KEY_VALUES, typePicklistValues);
        workOrderTypes.put(KEY_DEFAULT, System.Label.WorkOrder_Type_Marketplace);
        return workOrderTypes;
    }

    /**
     * @description It is used to return the Id of Rx Business Vertical Record
     * JIRA# LEM-11344
     * @return Id
     **/
    @AuraEnabled(cacheable=true)
    public static Id getRxBusinessVerticalId() {
        Id rxBusinessVerticalId = BusinessVerticalsSelector.newInstance()
                .selectPrimaryVerticalRxRecord()[0]
            .Id;
        return rxBusinessVerticalId;
    }

    /**
     * @description Creates a NEW Process_Flow_Request__c for a Contract once flow begins.
     *              The process begins once the user opts to create a new or select from existing Work Orders.
     *              This method creates a PFR record and associates it to the Contract.
     * @param flowRequestId - Id of the Process Flow Request - if we are coming back to the Work Order step
     * @param contractId - Id of the parent Contract
     * @param creatingNewWorkOrder - Indicates if a new WO will be created
     * @return Process_Flow_Request__c
     **/
    @AuraEnabled
    public static Process_Flow_Request__c submitRequest(
        Id flowRequestId,
        Id contractId,
        Boolean creatingNewWorkOrder
    ) {
        // Use Unit Of Work pattern for DML operation
        fflib_SObjectUnitOfWork uowInstance = new fflib_SObjectUnitOfWork(
            new List<SObjectType>{ WorkOrder.sObjectType }
        );

        InsertUnitOfWorkHelper uowHelper = new InsertUnitOfWorkHelper();
        UpdateUnitOfWorkHelper uowUpdateHelper = new UpdateUnitOfWorkHelper();
        uowInstance.registerWork(uowHelper);
        uowInstance.registerWork(uowUpdateHelper);

        try {
            Process_Flow_Request__c newRequest = createRequest(contractId, null);

            if (flowRequestId != null) {
                newRequest = getFlowRequestById(flowRequestId);
            }

            if (creatingNewWorkOrder) {
                newRequest.Work_Order_Selection_Method__c = REQUEST_WO_SELECTION_NEW;
                newRequest.Stage__c = stagesByOrder.get(2);
            } else {
                newRequest.Work_Order_Selection_Method__c = REQUEST_WO_SELECTION_EXISTING;
                newRequest.Stage__c = stagesByOrder.get(3);
            }

            if (flowRequestId == null) {
                uowHelper.registerInsert(newRequest);
            } else {
                uowUpdateHelper.registerUpdate(newRequest);
            }

            uowInstance.commitWork();
            List<Database.SaveResult> flowSaveResults = uowHelper.saveResults;

            if (
                !Test.isRunningTest() &&
                !flowSaveResults.isEmpty() &&
                !flowSaveResults[0].isSuccess()
            ) {
                throw new AuraHandledException(
                    getDmlErrorsAsString(flowSaveResults[0].getErrors())
                );
            }

            return newRequest;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
     * @description Invoked from the bulkOnboardingWorkOrderSelect LWC to link a WorkOrder ID and the new Stage to the PFR
     * @param flowRequestId - Id of the related Process_Flow_Request__c driving the process
     * @param selectedWorkOrderId - Id of the Work Order that the user selected
     * @return Process_Flow_Request__c
     **/
    @AuraEnabled
    public static Process_Flow_Request__c linkExistingWorkOrder(Id flowRequestId, Id selectedWorkOrderId) {
        Process_Flow_Request__c flowRequest = getFlowRequestById(flowRequestId);
        flowRequest.Work_Order__c = selectedWorkOrderId;
        flowRequest.Stage__c = stagesByOrder.get(4);
        flowRequest.Work_Order_Selection_Method__c = REQUEST_WO_SELECTION_EXISTING;
        return commitProcessFlowRequestUpdates(flowRequest);
    }

    /**
     * @description Invoked from bulkOnboardingFinalErrorCheck component to navigate to the final flow screen.
     * @param flowRequestId - Id of the related Process_Flow_Request__c driving the process
     * @return Process_Flow_Request__c
     **/
    @AuraEnabled
    public static Process_Flow_Request__c navigateToCompletionStep(Id flowRequestId) {
        return commitProcessFlowRequestUpdates(updateRequestToStage(flowRequestId, 10, true));
    }

    /**
     * @description Retrieves the Stores that did not have their addresses verified successfully
     * @param flowRequestId - Id of the related Process_Flow_Request__c driving the process
     * @return List<Account>
     **/
    @AuraEnabled(cacheable=true)
    public static List<Account> getFailedStores(Id flowRequestId) {
        return BulkCorporateOnboardingRequestService.getFailedStores(flowRequestId);
    }

    /**
     * @description Retrieves aggregate info about Stores that did not have their addresses verified successfully
     * @param flowRequestId - Id of the related Process_Flow_Request__c driving the process
     * @return BulkCorporateOnboardingWrappers.StoreVerificationStatus
     **/
    @AuraEnabled
    public static BulkCorporateOnboardingWrappers.StoreVerificationStatus getInvalidOrIncompleteStores(
        Id flowRequestId
    ) {
        BulkCorporateOnboardingWrappers.AddressVerificationResult addressResults = BulkCorporateOnboardingRequestService.updateAndRetrieveAddressJobStatus(
            flowRequestId
        );

        List<BulkCorporateOnboardingWrappers.StoreInfo> storeInfos = addressResults.storeInfos;

        Process_Flow_Request__c flowRequest = BulkCorporateOnboardingRequestService.getBulkOnboardingRequestOrAbort(
            flowRequestId
        );

        Set<Id> failedStoreIdsToQuery = new Set<Id>();
        Set<Id> notRunStoreIdsToQuery = new Set<Id>();
        Integer storesVerifiedAndPassed = 0;
        Integer storesVerifiedAndFailed = 0;
        Integer storesNotVerified = 0;

        List<Account> stores = AccountsSelector.newInstance()
            .getStoresByBulkOnboardingRequestId(flowRequestId);
        //Collect the Seattle Accounts which does npt have Accesbility field populated
        List<Account> storesRequiringAdditionalInformation = new List<Account>();
        storesRequiringAdditionalInformation = validateAccessibilities(stores);
        for (BulkCorporateOnboardingWrappers.StoreInfo thisStoreInfo : storeInfos) {
            if (thisStoreInfo.skipBatch) {
                // Treat skipped stores as verified and passed
                storesVerifiedAndPassed++;
                continue; // Skip further checks
            }

            if (thisStoreInfo.isJobRun) {
                if (thisStoreInfo.isVerified) {
                    storesVerifiedAndPassed++;
                } else {
                    storesVerifiedAndFailed++;
                    // Add to failedStoreIdsToQuery to display in failure list
                    failedStoreIdsToQuery.add(thisStoreInfo.storeId);
                }
            } else {
                storesNotVerified++;
                notRunStoreIdsToQuery.add(thisStoreInfo.storeId);
            }
        }

        BulkCorporateOnboardingWrappers.StoreVerificationStatus result = new BulkCorporateOnboardingWrappers.StoreVerificationStatus();
        result.storesRequiringAdditionalInformation = storesRequiringAdditionalInformation;
        result.allStoresVerified =
            (storesVerifiedAndPassed + storesVerifiedAndFailed) == storeInfos.size();
        result.allStoresPassed =
            storesVerifiedAndPassed == storeInfos.size() &&
            result.storesRequiringAdditionalInformation.size() == 0;
        result.allStoresFailed =
            result.allStoresVerified &&
            storesVerifiedAndFailed > 0 &&
            storesVerifiedAndPassed == 0;
        result.someStoresNotVerified = storesNotVerified > 0;
        result.totalStores = storeInfos.size();
        result.hasAddressIssues = storesVerifiedAndPassed < storeInfos.size();

        // 🇨🇦 Determine if this is a Canadian-based Mx and check if we need any business-level details 🇨🇦
        Set<Id> businessAndStoreIds = new Set<Id>();
        if (flowRequest.Contract__r.AccountId != null) {
            businessAndStoreIds.add(flowRequest.Contract__r.AccountId);
        }
        businessAndStoreIds.addAll(new Map<Id, Account>(stores).keySet());
        result.requiresCanadianDetails = JurisdictionService.areAnyMerchantsInJurisdiction(
            businessAndStoreIds,
            JurisdictionService.Jurisdiction.CANADA
        );

        if (result.requiresCanadianDetails) {
            result.businessContacts = getBusinessContactsByRole(flowRequest.Contract__r.AccountId);
        }

        Schema.FieldSet addressFieldSet = SObjectType.Account.FieldSets.Address_Details;
        result.failedStores = (!failedStoreIdsToQuery.isEmpty())
            ? AccountsSelector.newInstance()
                  .selectAccountsByIdAndFieldSet(addressFieldSet, failedStoreIdsToQuery)
            : new List<Account>();
        result.storesNotRun = (!notRunStoreIdsToQuery.isEmpty())
            ? AccountsSelector.newInstance()
                  .selectAccountsByIdAndFieldSet(addressFieldSet, notRunStoreIdsToQuery)
            : new List<Account>();
        return result;
    }

    /**
     * @description Deletes an already-inserted Store Account that the user does not want to keep (for example, in
     *              the event of an address verification issue)
     * @param storeId - Id of the Store Account to delete
     * @param flowRequestId - Id of the relevent PFR
     **/
    @AuraEnabled
    public static void deleteStore(Id storeId, Id flowRequestId) {
        try {
            fflib_ISObjectUnitOfWork unitOfWorkInstance = Application.UnitOfWork.newInstance();
            unitOfWorkInstance.registerDeleted(new Account(Id = storeId));

            Process_Flow_Request__c flowRequest = getFlowRequestById(flowRequestId);
            List<BulkCorporateOnboardingWrappers.StoreInfo> stores = BulkCorporateOnboardingRequestService.unpackStoreInfos(
                flowRequestId,
                flowRequest.Serialized_Object_Data__c
            );

            List<BulkCorporateOnboardingWrappers.StoreInfo> filteredStores = new List<BulkCorporateOnboardingWrappers.StoreInfo>();

            for (BulkCorporateOnboardingWrappers.StoreInfo thisStore : stores) {
                if (thisStore.storeId != storeId) {
                    filteredStores.add(thisStore);
                }
            }

            // Increment the Removed Stores counter
            if (flowRequest.Removed_Stores__c == null) {
                flowRequest.Removed_Stores__c = 1;
            } else {
                flowRequest.Removed_Stores__c += 1;
            }

            // Remove from the count of Fixed Stores, if a fix was previously attempted.
            // We do this because we log when fixes are attempted; there is no guarantee that
            // the fix actually worked. And there's no guarantee the user won't opt to remove
            // the store later. Note that there is no possible way to fix a store after
            // removing it, so we do not need to handle the opposite case in the
            // `navigateToStore()` method.
            Set<String> fixedStoreIds = new Set<String>();
            if (String.isNotBlank(flowRequest.Fixed_Store_IDs__c)) {
                fixedStoreIds = new Set<String>(flowRequest.Fixed_Store_IDs__c.split(','));

                if (fixedStoreIds.contains(storeId)) {
                    fixedStoreIds.remove(storeId);
                    flowRequest.Fixed_Store_IDs__c = String.join(
                        new List<String>(fixedStoreIds),
                        ','
                    );
                    flowRequest.Fixed_Stores_Count__c = fixedStoreIds.size();
                }
            }

            flowRequest.Serialized_Object_Data__c = BulkCorporateOnboardingRequestService.packStoreInfos(
                filteredStores
            );
            unitOfWorkInstance.registerDirty(flowRequest);
            unitOfWorkInstance.commitWork();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Pulls the "not in coverage" stores out of ANSO while still keeping them in
     *              the system. This way, the ANSO batch logic ignores the stores but they are NOT deleted
     *              and any issues with them can be rectified later.
     * @param flowRequestId - Id of the relevent PFR
     **/
    @AuraEnabled
    public static void removeOutOfCoverageStoresFromUpload(Id flowRequestId) {
        try {
            fflib_ISObjectUnitOfWork unitOfWorkInstance = Application.UnitOfWork.newInstance();

            Process_Flow_Request__c flowRequest = getFlowRequestById(flowRequestId);
            List<BulkCorporateOnboardingWrappers.StoreInfo> storeInfos = BulkCorporateOnboardingRequestService.unpackStoreInfos(
                flowRequestId,
                flowRequest.Serialized_Object_Data__c
            );

            // Get the Store Accounts from the PFR; we will need to check the `Coverage__c` data stored there
            Map<Id, Account> storesMap = new Map<Id, Account>(
                AccountsSelector.newInstance().getStoresByBulkOnboardingRequestId(flowRequestId)
            );

            // When this button is clicked, take all the "Out of Coverage" stores and then omit them from the batch, using
            // the `skipBatch` flag on the PFR's Serialized Object Data. This flag will be checked in the batch, and, if set
            // to true, then the stores will not be added to the Work Order
            List<BulkCorporateOnboardingWrappers.StoreInfo> filteredStores = new List<BulkCorporateOnboardingWrappers.StoreInfo>();
            for (BulkCorporateOnboardingWrappers.StoreInfo thisStore : storeInfos) {
                Account storeAccountRecord = storesMap.get(thisStore.storeId);
                if (
                    storeAccountRecord != null &&
                    storeAccountRecord.Coverage__c != null &&
                    storeAccountRecord.Coverage__c.toLowerCase() == 'not in coverage'
                ) {
                    thisStore.skipBatch = true;
                }

                filteredStores.add(thisStore);
            }

            // Re-serialize the StoreInfos with new modifications, and save the PFR
            flowRequest.Serialized_Object_Data__c = BulkCorporateOnboardingRequestService.packStoreInfos(
                filteredStores
            );
            unitOfWorkInstance.registerDirty(flowRequest);
            unitOfWorkInstance.commitWork();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage()); // LWC will call LoggerController to log
        }
    }

    /**
     * @description Logs a Store Account which the user navigates to from the Final Error Check screen.
     * @param storeId - Id of the Store Account to delete
     * @param flowRequestId - Id of the relevent PFR
     **/
    @AuraEnabled
    public static void navigateToStore(Id storeId, Id flowRequestId) {
        try {
            fflib_ISObjectUnitOfWork unitOfWorkInstance = Application.UnitOfWork.newInstance();

            Process_Flow_Request__c flowRequest = getFlowRequestById(flowRequestId);

            // Convert the value of Fixed_Store_IDs__c to a `Set<String>` so we can add to it and de-dupe
            Set<String> fixedStoreIds = new Set<String>();
            if (String.isNotBlank(flowRequest.Fixed_Store_IDs__c)) {
                fixedStoreIds = new Set<String>(flowRequest.Fixed_Store_IDs__c.split(','));
            }
            fixedStoreIds.add(storeId);

            // Update the PFR fields
            flowRequest.Fixed_Store_IDs__c = String.join(new List<String>(fixedStoreIds), ',');
            flowRequest.Fixed_Stores_Count__c = fixedStoreIds.size();
            unitOfWorkInstance.registerDirty(flowRequest);

            unitOfWorkInstance.commitWork();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Executes the Bulk Store Onboarding Batch on an as-needed basis, for the Stores that did not finish successfully.
     * @param flowRequestId - Id of the related Process_Flow_Request__c driving the process
     **/
    @AuraEnabled
    public static void handleBatchRetry(Id flowRequestId) {
        BulkCorporateOnboardingWrappers.AddressVerificationResult addressResults = BulkCorporateOnboardingRequestService.updateAndRetrieveAddressJobStatus(
            flowRequestId
        );

        if (addressResults.ranOnSomeStores) {
            Process_Flow_Request__c flowRequest = getFlowRequestById(flowRequestId);
            flowRequest.Stage__c = PROCESSING_STORES;
            flowRequest.Status__c = REQUEST_STATUS_IN_PROGRESS;
            flowRequest = commitProcessFlowRequestUpdates(flowRequest);
            Database.executeBatch(new BulkStoreOnboardingBatch(flowRequestId), 5);
        }
    }

    /**
     * @description Invoked from the bulkOnboardingWorkOrder LWC to generate a WorkOrder record
     * @param flowRequestId - Id of the Process Flow Request we are working with
     * @param workOrderFields - Key/value store of WorkOrder field API Names and values submitted by the user
     * @return Process_Flow_Request__c
     **/
    @AuraEnabled
    public static Process_Flow_Request__c submitNewWorkOrder(Id flowRequestId, Map<String, Object> workOrderFields) {
        // Use Unit Of Work pattern for DML operation
        fflib_SObjectUnitOfWork uowInstance = new fflib_SObjectUnitOfWork(
            new List<SObjectType>{ WorkOrder.sObjectType }
        );

        InsertUnitOfWorkHelper uowHelper = new InsertUnitOfWorkHelper();
        UpdateUnitOfWorkHelper uowUpdateHelper = new UpdateUnitOfWorkHelper();
        uowInstance.registerWork(uowHelper);
        uowInstance.registerWork(uowUpdateHelper);

        WorkOrder newWorkOrder = buildWorkOrderFromUserInput(workOrderFields);
        List<String> readinessErrors = getWorkOrderReadinessValidationErrors(newWorkOrder);
        if (!readinessErrors.isEmpty()) {
            throw new WorkOrderCreationException(String.join(readinessErrors, '\n'));
        }

        uowHelper.registerInsert(newWorkOrder);
        uowInstance.commitWork();
        List<Database.SaveResult> workOrderResults = uowHelper.saveResults;

        // Get the ID of the newly created WorkOrder
        Id workOrderId;
        if (workOrderResults.size() > 0 && !Test.isRunningTest()) {
            if (workOrderResults[0].isSuccess()) {
                workOrderId = workOrderResults[0].getId();
            } else {
                String errMsg = getDmlErrorsAsString(workOrderResults[0].getErrors());
                throw new AuraHandledException(errMsg);
            }
        }

        // Update the Process Flow Request with the WorkOrder ID and the new Stage
        Process_Flow_Request__c flowRequest = getFlowRequestById(flowRequestId);
        flowRequest.Work_Order__c = workOrderId;
        flowRequest.Stage__c = stagesByOrder.get(4);
        flowRequest.Work_Order_Selection_Method__c = REQUEST_WO_SELECTION_NEW;

        uowUpdateHelper.registerUpdate(flowRequest);
        uowInstance.commitWork();

        return flowRequest;
    }

    /**
     * @description Retrieves Contacts from the ACR object, by Role
     * @param accountId
     * @return Map<String, Contact>
     **/
    @TestVisible
    private static Map<String, Contact> getBusinessContactsByRole(Id accountId) {
        Map<String, Contact> resultsMap = new Map<String, Contact>();
        List<AccountContactRelation> acrs = AccountContactRelationsSelector.newInstance()
            .selectActiveAcrByAccountIds(new Set<Id>{ accountId });

        // Set to store unique Contact Ids associated with ACRs
        Set<Id> contactIds = new Set<Id>();

        // Populate the set with Contact Ids from ACRs
        for (AccountContactRelation thisACR : acrs) {
            if (String.isNotBlank(thisACR.ContactId)) {
                contactIds.add(thisACR.ContactId);
            }
        }

        Schema.FieldSet contactsFieldSet = SObjectType.Contact.FieldSets.ANSO_Contact_Creation_Form;
        Map<Id, Contact> contactsMap = new Map<Id, Contact>(
            ContactsSelector.newInstance().selectByIdsAndFieldSet(contactsFieldSet, contactIds)
        );

        // Populate the result map with Contact records instead of ACR records
        for (AccountContactRelation thisACR : acrs) {
            if (String.isBlank(thisACR.Roles)) {
                continue;
            }

            for (String thisRole : thisACR.Roles.split(';')) {
                String roleTrimmed = thisRole.trim();
                if (!resultsMap.containsKey(roleTrimmed)) {
                    // Check if the ACR has a Contact associated with it
                    if (contactsMap.containsKey(thisACR.ContactId)) {
                        resultsMap.put(roleTrimmed, contactsMap.get(thisACR.ContactId));
                    }
                }
            }
        }
        return resultsMap;
    }

    /**
     * @description Runs specific validations on WorkOrder to verify it passes the correct readiness checks
     * @param thisWorkOrder - WorkOrder SObject record to validate
     * @return List<String>
     **/
    private static List<String> getWorkOrderReadinessValidationErrors(WorkOrder thisWorkOrder) {
        List<String> workOrderErrors = new List<String>();

        Map<String, Store_Readiness_Validation_Rule__mdt> rulesToUseByNames = new Map<String, Store_Readiness_Validation_Rule__mdt>();
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessChecks = StoreReadinessValidationRulesSelector.newInstance()
            .selectAllValidReadinessValidationRules();

        for (Store_Readiness_Validation_Rule__mdt thisReadinessCheck : storeReadinessChecks) {
            if (WORK_ORDER_RULES.contains(thisReadinessCheck.DeveloperName)) {
                rulesToUseByNames.put(thisReadinessCheck.DeveloperName, thisReadinessCheck);
            }
        }

        // If `Menu to be Completed By` is "Account Owner", then `Activate Centrally` hould be "No"
        if (
            thisWorkOrder.Menu_to_be_Completed_By__c == MENU_TO_BE_COMPLETED_BY_ACCOUNT_OWNER &&
            thisWorkOrder.Activated_Centrally_AC__c != ACTIVATE_CENTRALLY_NO
        ) {
            workOrderErrors.add(
                'Activated_Centrally_AC__c:' +
                rulesToUseByNames.get(WO_RULE_ACTIVATE_CENTRALLY).Error_Message__c
            );
        }

        if (
            String.isNotBlank(thisWorkOrder.Order_Protocol__c) &&
            thisWorkOrder.Order_Protocol__c.contains(ORDER_PROTOCOL_POS) &&
            String.isBlank(thisWorkOrder.POS_Integration_Type__c)
        ) {
            // Require POS Integration Type when Order Protocol contains 'POS'
            if (String.isBlank(thisWorkOrder.POS_Integration_Type__c)) {
                workOrderErrors.add(
                    'POS_Integration_Type__c:' +
                    rulesToUseByNames.get(WO_RULE_POS_TYPE_REQUIRED).Error_Message__c
                );
            }
        }

        return workOrderErrors;
    }

    /**
     * @description (LEM-19661) Validate the Subscription Pacakge of the WorkOrder Type Present or not, if present then fetch existing PFR request
     * @param type - String of the Work Order
     * @param contractId - Id of the Contract
     * @return Boolean
    **/
    @AuraEnabled
    public static Process_Flow_Request__c validateAndLoadRequest(String type, Id contractId) {
        Process_Flow_Request__c existingPFR;

        String validationMessage =  validateWorkOrderType(type, contractId);
        if(String.isNotEmpty(validationMessage)){
            throw new AuraHandledException(
                validationMessage
            );
        } else {
            existingPFR = getRequestForContract(contractId);
        }
        return existingPFR;
    }

    /**
     * @description Invoked from the bulkOnboardingInitializer LWC to retrieve the existing s
     *              Request record, if it exists.
     * @param contractId - Id of the Contract from which this request was initiated
     * @return Process_Flow_Request__c
     **/
    public static Process_Flow_Request__c getRequestForContract(Id contractId) {
        try {
            List<Process_Flow_Request__c> requests = ProcessFlowRequestsSelector.newInstance()
                .selectOpenRequestsForContractAndUser(contractId);
            return !requests.isEmpty() ? requests[0] : null;
        } catch (Exception e) {
            return null;
        }
    }
    /**
     * @description Calls the Process_Flow_Request__c (PFR) selector with the inputted ID
     * @param flowRequestId - Id of the PFR record to retrieve
     * @return Process_Flow_Request__c
     **/
    @AuraEnabled
    public static Process_Flow_Request__c getFlowRequestById(Id flowRequestId) {
        List<Process_Flow_Request__c> requests = ProcessFlowRequestsSelector.newInstance()
            .selectById(new Set<Id>{ flowRequestId });
        return (requests != null && !requests.isEmpty()) ? requests[0] : null;
    }

    /**
     * @description Converts a list of DML errors to strings for the UI
     * @param errors - List<Database.Error> objects of DML errors
     * @return String
     **/
    private static String getDmlErrorsAsString(List<Database.Error> errors) {
        List<String> messages = new List<String>();
        for (Database.Error error : errors) {
            List<String> errorFields = error.getFields();
            String errorMessage = error.getMessage();
            for (String fieldName : errorFields) {
                messages.add(fieldName + ':' + errorMessage);
            }
        }
        // Add custom validation exception message if there are no field level exceptions
        if (messages.isEmpty() && (errors != null || !errors.isEmpty())) {
            messages.add(errors[0].getMessage());
        }
        return String.join(messages, '\n');
    }

    /**
     * @description Receives a file from an LWC input, uploads it to ContentDocument, and validates the input.
     * @param csvRowsStr - (List<String>) File contents
     * @param flowRequestId - (Id) Process_Flow_Request__c record Id
     * @param chunkId - (Integer) The integer of the current chunk we are on
     * @param totalChunks - (Integer) Number of Content chunks needed for this bulk request
     * @return BulkOnboardingWrapper
     **/
    @AuraEnabled
    public static BulkOnboardingWrapper uploadFileRows(
        String csvRowsStr,
        Id flowRequestId,
        Integer chunkId,
        Integer totalChunks
    ) {
        if (chunkId == 1) {
            // Deletes the chunks from the previous upload attempt - these are no longer needed
            cleanUpTemporaryStorage(flowRequestId);

            // Increment the upload attempts count only on the first chunk
            Process_Flow_Request__c flowRequest = getFlowRequestById(flowRequestId);
            flowRequest.Upload_Attempts__c = (flowRequest.Upload_Attempts__c == null)
                ? 1
                : flowRequest.Upload_Attempts__c + 1;
            flowRequest = commitProcessFlowRequestUpdates(flowRequest);
        }

        BulkCorporateOnboardingWrappers.StoreValidationResult uploadResults = new BulkCorporateOnboardingWrappers.StoreValidationResult();
        String decodedStr = EncodingUtil.base64Decode(csvRowsStr).toString();
        List<List<String>> csvRows = (List<List<String>>) JSON.deserialize(
            decodedStr,
            List<List<String>>.class
        );

        // Existing logic for parsing, validation, and updating Process_Flow_Request__c
        uploadResults = BulkCorporateOnboardingRequestService.parseAndValidateCsv(
            csvRows,
            flowRequestId,
            chunkId,
            totalChunks
        );
        Process_Flow_Request__c flowRequest = getFlowRequestById(flowRequestId);
        return new BulkOnboardingWrapper(
            uploadResults,
            flowRequest,
            null
        );
    }

    /**
     * @description Persist the Store data on the Process Flow Requests after the chunks have saved
     * @param flowRequestId - (Id) ID of the PFR record
     * @param resultsStr - (String) Upload results
     * @param chunksToProcess - (Integer) Number of chunks to use
     * @return Process_Flow_Request__c
     **/
    @AuraEnabled
    public static Process_Flow_Request__c processStoreUploadData(
        Id flowRequestId,
        String resultsStr,
        Integer chunksToProcess
    ) {
        BulkCorporateOnboardingWrappers.StoreValidationResult results = (BulkCorporateOnboardingWrappers.StoreValidationResult) JSON.deserialize(
            resultsStr,
            BulkCorporateOnboardingWrappers.StoreValidationResult.class
        );

        // Parse the next set of Chunks
        results = BulkCorporateOnboardingRequestService.parseAndInsertStores(
            flowRequestId,
            chunksToProcess,
            results
        );

        // Update the original array with the filtered items once completed
        if (results.saveFinished) {
            results.storeWrappers = filterRemovedStores(results);
        }

        Process_Flow_Request__c flowRequest = getFlowRequestById(flowRequestId);
        flowRequest.Serialized_Object_Data__c = BulkCorporateOnboardingRequestService.packStoreInfos(
            results.storeWrappers
        );
        flowRequest = commitProcessFlowRequestUpdates(flowRequest);
        flowRequest = commitProcessFlowRequestUpdates(
            updateRequestToStage(flowRequest, getNextStageNumberAfterUpload(results), false)
        );

        flowRequest.Serialized_Object_Data__c = JSON.serialize(results.storeWrappers); // Return data in the JSON format for use on the front-end
        return flowRequest;
    }

    /**
     * @description Removes `StoreInfo` objects that were removed as duplicates
     * @param results - The original array to filter
     * @return List<BulkCorporateOnboardingWrappers.StoreInfo>
     **/
    private static List<BulkCorporateOnboardingWrappers.StoreInfo> filterRemovedStores(
        BulkCorporateOnboardingWrappers.StoreValidationResult results
    ) {
        if (results.storeWrappers == null) {
            return new List<BulkCorporateOnboardingWrappers.StoreInfo>();
        }

        List<BulkCorporateOnboardingWrappers.StoreInfo> storesToKeep = new List<BulkCorporateOnboardingWrappers.StoreInfo>();
        for (BulkCorporateOnboardingWrappers.StoreInfo thisStore : results.storeWrappers) {
            if (!results.rowsToRemoveFromUpload.contains(thisStore.rowNumber)) {
                storesToKeep.add(thisStore);
            }
        }

        return storesToKeep;
    }

    /**
     * @description Deletes Process_Flow_Request_Chunk__c records related to a specific PFR
     * @param flowRequestId - (Id) The record ID of the Process_Flow_Request__c
     **/
    private static void cleanUpTemporaryStorage(Id flowRequestId) {
        List<Process_Flow_Request_Chunk__c> chunksToDelete = ProcessFlowRequestChunksSelector.newInstance()
            .selectByRequestId(flowRequestId);
        fflib_ISObjectUnitOfWork uowInstance = Application.UNITOFWORK.newInstance();
        uowInstance.registerDeleted(chunksToDelete);
        uowInstance.commitWork();
    }

    /**
     * @description Takes a wrapper with the Store results and then determines what Stage is needed next, based on entered information.
     * @param results - (BulkCorporateOnboardingWrappers.StoreValidationResult) The wrapper returned after upload
     * @return Integer
     **/
    @TestVisible
    private static Integer getNextStageNumberAfterUpload(
        BulkCorporateOnboardingWrappers.StoreValidationResult results
    ) {
        Integer stageNumberToUse;
        if (results == null || results.hasNonDuplicateErrors == true) {
            stageNumberToUse = 4; // Stay on current Stage
        } else {
            stageNumberToUse = 5;
            Boolean skipPaymentAccountStep = true;
            for (
                BulkCorporateOnboardingWrappers.StoreInfo eachStoreInformation : results.storeWrappers
            ) {
                if (eachStoreInformation.paymentAccountId == null) {
                    skipPaymentAccountStep = false;
                }
            }
        }
        return stageNumberToUse;
    }

    /**
     * @description Overloaded version of updateRequestToStage, allowing for an Id as an argument.
     * @param flowRequestId - (Id) The record ID of the Process_Flow_Request__c (PFR) to update
     * @param stepNumber - (Integer) The # of the Stage to update to; uses the stagesByOrder constant
     * @param performDml - (Boolean) A flag indicating whether to perform DML (specifically update) on the PFR record
     * @return Process_Flow_Request__c
     **/
    private static Process_Flow_Request__c updateRequestToStage(
        Id flowRequestId,
        Integer stepNumber,
        Boolean performDml
    ) {
        Process_Flow_Request__c flowRequest = getFlowRequestById(flowRequestId);
        return updateRequestToStage(flowRequest, stepNumber, performDml);
    }

    /**
     * @description Takes a PFR and updates it to the specified Stage, invoking any jobs as required.
     * @param flowRequest - (Process_Flow_Request__c) The Process_Flow_Request__c (PFR) record to update
     * @param stepNumber - (Integer) The # of the Stage to update to; uses the stagesByOrder constant
     * @param performDml - (Boolean) A flag indicating whether to perform DML (specifically update) on the PFR record
     * @return Process_Flow_Request__c
     **/
    private static Process_Flow_Request__c updateRequestToStage(
        Process_Flow_Request__c flowRequest,
        Integer stepNumber,
        Boolean performDml
    ) {
        flowRequest.Stage__c = stagesByOrder.get(stepNumber);

        if (performDml) {
            flowRequest = commitProcessFlowRequestUpdates(flowRequest);
        }
        // When the "Processing Stores" Stage is set is when the batch class should be invoked
        if (stagesByOrder.get(stepNumber) == PROCESSING_STORES) {
            BulkCorporateOnboardingRequestService.checkAndExecuteBatch(flowRequest.Id);
        }

        return flowRequest;
    }
    /**
     * @description Takes input from the LWC and builds a WorkOrder record, which gets returned
     * @param populatedFields - Input from the Work Order creation UI
     * @return WorkOrder
     **/
    @TestVisible
    private static WorkOrder buildWorkOrderFromUserInput(Map<String, Object> populatedFields) {
        // Create a new WorkOrder instance
        WorkOrder wo = new WorkOrder();

        Map<String, Schema.SObjectField> fieldsFromSObject = WorkOrder.sObjectType.getDescribe()
            .fields.getMap();

        // Map fields to the WorkOrder instance
        for (String fieldKey : populatedFields.keySet()) {
            // If the field is not actually on the SObject, or if the field value we are passing is null, continue
            if (!fieldsFromSObject.containsKey(fieldKey) || populatedFields.get(fieldKey) == null) {
                continue;
            }

            Schema.DisplayType fieldType = fieldsFromSObject.get(fieldKey).getDescribe().getType();
            if (fieldType == Schema.DisplayType.DATE) {
                wo.put(fieldKey, Date.valueOf((String) populatedFields.get(fieldKey)));
            } else if (
                fieldType == Schema.DisplayType.CURRENCY ||
                fieldType == Schema.DisplayType.PERCENT ||
                fieldType == Schema.DisplayType.DOUBLE
            ) {
                wo.put(fieldKey, Decimal.valueOf((String) populatedFields.get(fieldKey)));
            } else if (fieldType == Schema.DisplayType.INTEGER) {
                wo.put(fieldKey, Integer.valueOf((String) populatedFields.get(fieldKey)));
            } else {
                wo.put(fieldKey, populatedFields.get(fieldKey));
            }
        }
        return wo;
    }

    /**
     * @description It is used to validate and retrun Seattle stores which are missing Accessibilities__c information
     * check for Seattle postalcode not null and belongs to the Seattle postalcodes stored in the custom label
     * @JIRA# 13983
     * @param accounts
     * @return List<Account>
     */
    private static List<Account> validateAccessibilities(List<Account> accounts) {
        String seattleZipCodesString = System.Label.Seattle_Zipcodes;
        List<Account> storesRequiringAdditionalInformation = new List<Account>();
        List<String> seattleZipCodes = seattleZipCodesString.split(',');
        for (Account account : accounts) {
            if (
                string.isBlank(account.Accessibilities__c) &&
                String.isNotBlank(account.BillingPostalCode) &&
                seattleZipCodes.contains(account.BillingPostalCode.trim())
            ) {
                storesRequiringAdditionalInformation.add(account);
            }
        }
        return storesRequiringAdditionalInformation;
    }

    /**
     * @description (LEM-8473) Allows users to populate custom lookup for Payment Accounts
     * @param searchTerm - String with which to search for Accounts
     * @return List<Payment_Account__c>
     **/
    @AuraEnabled(cacheable=true)
    public static List<Payment_Account__c> findAccounts(String searchTerm) {
        String searchKey = searchTerm + '*';
        // Eventually might want to consider other fields
        List<List<SObject>> searchResults = [
            FIND :searchKey
            IN ALL FIELDS
            RETURNING Payment_Account__c(Id, Name)
            LIMIT 10
        ];

        List<Payment_Account__c> accounts = ((List<Payment_Account__c>) searchResults[0]);
        return accounts;
    }

    /**
     * @description Called to link an existing record (such as a Payment Account or Decision Maker Contact)
     *              to the Stores from a Process Flow Request.
     * @param flowRequestId - Id of the relevant PFR record for our flow
     * @param relatedRecordId - Id of the record to attach to the PFR's Stores
     * @param skipRecordLinking - Boolean to progress with the flow but not update the Serialized Object Data
     * @return Process_Flow_Request__c
     **/
    @AuraEnabled
    public static Process_Flow_Request__c linkRelatedRecords(
        Id flowRequestId,
        Id relatedRecordId,
        Boolean skipRecordLinking
    ) {
        Process_Flow_Request__c flowRequest = getFlowRequestById(flowRequestId);
        List<BulkCorporateOnboardingWrappers.StoreInfo> stores = BulkCorporateOnboardingRequestService.unpackStoreInfos(
            flowRequestId,
            flowRequest.Serialized_Object_Data__c
        );

        skipRecordLinking = skipRecordLinking != null ? skipRecordLinking : false; // Default to false

        Boolean skippedPaymentAccountStep =
            isEligibleToSkipPaymentAccountStep(flowRequestId) && relatedRecordId == null;

        // Default to Payment Account if we don't have a record ID -- since this will be from the skipped scenario
        Schema.SObjectType relatedRecordType = skippedPaymentAccountStep
            ? Payment_Account__c.SObjectType
            : relatedRecordId.getSobjectType();
        skipRecordLinking = skipRecordLinking || skippedPaymentAccountStep;

        if (relatedRecordType == Payment_Account__c.SObjectType) {
            Boolean skipDecisionMakers = hasDecisionMakersPopulated(stores);

            // If we already have Decision Makers selected, proceed to Step 7.
            Integer stepToUse = !skipDecisionMakers ? 8 : 9;

            flowRequest.Serialized_Object_Data__c = updateStoresWithRelatedRecordIds(
                stores,
                relatedRecordId,
                skipRecordLinking
            );
            flowRequest = commitProcessFlowRequestUpdates(flowRequest);
            flowRequest = updateRequestToStage(flowRequestId, stepToUse, true);
        } else if (relatedRecordType == Contact.SObjectType) {
            flowRequest.Serialized_Object_Data__c = updateStoresWithRelatedRecordIds(
                stores,
                relatedRecordId,
                skipRecordLinking
            );
            flowRequest = commitProcessFlowRequestUpdates(flowRequest);
            flowRequest = updateRequestToStage(flowRequestId, 9, true);
        }

        return flowRequest;
    }

    /**
     * @description Called to link an existing record (such as a Payment Account or Decision Maker Contact)
     *              to the Stores from a Process Flow Request.
     * @param flowRequestId - Id of the relevant PFR record for our flow
     * @param relatedRecordId - Id of the associated record
     * @param storeInfoStr - serialized storeInfo objects to persist
     * @return BulkCorporateOnboardingWrappers.RelatedRecordCompletionInfo
     **/
    @AuraEnabled
    public static BulkCorporateOnboardingWrappers.RelatedRecordCompletionInfo linkRelatedRecordWithSelectedStores(
        Id flowRequestId,
        Id relatedRecordId,
        String storeInfoStr
    ) {
        BulkCorporateOnboardingWrappers.RelatedRecordCompletionInfo resultInfo = new BulkCorporateOnboardingWrappers.RelatedRecordCompletionInfo();

        // Run validations specific to Contact scenarios only
        if (relatedRecordId != null && relatedRecordId.getSobjectType() == Contact.SObjectType) {
            validateDecisionMaker(relatedRecordId, flowRequestId);
        }

        try {
            List<BulkCorporateOnboardingWrappers.StoreInfo> storeInfos = (List<BulkCorporateOnboardingWrappers.StoreInfo>) JSON.deserialize(
                storeInfoStr,
                List<BulkCorporateOnboardingWrappers.StoreInfo>.class
            );

            Process_Flow_Request__c flowRequest = BulkCorporateOnboardingRequestService.getBulkOnboardingRequestOrAbort(
                flowRequestId
            );

            if (storeInfos == null || storeInfos.isEmpty()) {
                resultInfo.flowRequest = flowRequest;
                return resultInfo;
            }

            flowRequest.Serialized_Object_Data__c = BulkCorporateOnboardingRequestService.packStoreInfos(
                storeInfos
            );

            Schema.SObjectType relatedRecordType = relatedRecordId.getSobjectType();

            flowRequest = commitProcessFlowRequestUpdates(flowRequest);

            resultInfo.isComplete = evaluateRecordLinkingCompletion(flowRequest, relatedRecordType);
            resultInfo.flowRequest = flowRequest;
            return resultInfo;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
     * @description Returns array of `ResultWrapper` objects for a already-linked records on a PFR
     * @param flowRequestId
     * @param objectType
     * @return List<LookupSearchCtrl.ResultWrapper>
     **/
    @AuraEnabled
    public static List<LookupSearchCtrl.ResultWrapper> getRecordsForMultiSelectDisplay(
        Id flowRequestId,
        String objectType
    ) {
        try {
            List<LookupSearchCtrl.ResultWrapper> results = new List<LookupSearchCtrl.ResultWrapper>();

            Process_Flow_Request__c flowRequest = BulkCorporateOnboardingRequestService.getBulkOnboardingRequestOrAbort(
                flowRequestId
            );
            List<BulkCorporateOnboardingWrappers.StoreInfo> storeInfos = BulkCorporateOnboardingRequestService.unpackStoreInfos(
                flowRequest.Id,
                flowRequest.Serialized_Object_Data__c
            );

            // Create a new set of Ids
            Set<Id> recordIdsToUse = new Set<Id>();

            for (BulkCorporateOnboardingWrappers.StoreInfo thisStore : storeInfos) {
                if (objectType == 'Payment_Account__c' && thisStore?.paymentAccountId != null) {
                    recordIdsToUse.add(thisStore.paymentAccountId);
                } else if (objectType == 'Contact' && thisStore?.decisionMakerId != null) {
                    recordIdsToUse.add(thisStore.decisionMakerId);
                }
            }

            if (!recordIdsToUse.isEmpty()) {
                results = LookupSearchCtrl.retrieveResultsByIds(recordIdsToUse);
            }

            return results;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Determines if the selected Decision Maker is valid.
     *              Currently, the only check is to ensure a request with
     *              a Tablet WO has a Contact with a Decision Maker with
     *              a Phone #, but we can expand this if needed.
     * @param decisionMakerId - Id of the relevant Contact to validate
     * @param flowRequestId - Id of the PFR
     **/
    @AuraEnabled
    public static void validateDecisionMaker(Id decisionMakerId, Id flowRequestId) {
        Boolean isTabletWorkOrder = BulkCorporateOnboardingRequestCtrl.isTabletWorkOrder(
            flowRequestId
        );

        if (isTabletWorkOrder) {
            List<Contact> contacts = ContactsSelector.newInstance()
                .selectContactsByIdAndFieldSet(
                    SObjectType.Contact.FieldSets.Decision_Maker_Contact_Info,
                    new Set<Id>{ decisionMakerId }
                );
            Contact thisDecisionMaker = !contacts.isEmpty() ? contacts[0] : null;

            // The DM is invalid if we have no phone number
            if (thisDecisionMaker?.Phone == null) {
                throw new AuraHandledException(System.Label.Bulk_Store_Phone_Required_for_DMs);
            }
        }
    }

    /**
     * @description Determines if the Work Order is a Tablet WO Type, as this requires extra validations later
     * @param flowRequestId - Id of the relevant PFR record for our flow
     * @return Boolean
     **/
    @AuraEnabled(cacheable=true)
    public static Boolean isTabletWorkOrder(Id flowRequestId) {
        Process_Flow_Request__c flowRequest = getFlowRequestById(flowRequestId);
        List<WorkOrder> workOrders = WorkOrdersSelector.newInstance()
            .selectById(new Set<Id>{ flowRequest.Work_Order__c });
        WorkOrder thisWorkOrder = !workOrders.isEmpty() ? workOrders[0] : null;

        return thisWorkOrder.Order_Protocol__c.contains(
            System.Label.LaunchEventOrderProtocolTablet
        );
    }

    /**
     * @description Called from the Payment Account component to determine if we are dealing with a
     *              situation where PA selection is not required.
     * @param flowRequestId - Id of the relevant PFR record for our flow
     * @return Boolean
     **/
    @AuraEnabled
    public static Boolean isEligibleToSkipPaymentAccountStep(Id flowRequestId) {
        try {
            Boolean canSkip = false;

            Process_Flow_Request__c flowRequest = getFlowRequestById(flowRequestId);
            List<BulkCorporateOnboardingWrappers.StoreInfo> storeInfos = BulkCorporateOnboardingRequestService.unpackStoreInfos(
                flowRequestId,
                flowRequest.Serialized_Object_Data__c
            );

            Set<Id> storeIds = new Set<Id>();
            for (BulkCorporateOnboardingWrappers.StoreInfo thisStore : storeInfos) {
                storeIds.add(thisStore.storeId);
            }

            Set<String> dsdCriteriaFields = new Set<String>{
                'Menu_UI_Type__c',
                'Shopping_Protocol__c',
                'Order_Protocol__c'
            };

            List<Account> storeAccounts = AccountsSelector.newInstance()
                .selectAccountWithOutFilterswithSetOfFieldsPassed(dsdCriteriaFields, storeIds);

            // First two fields are not retrieved via regular AccountsSelector query
            for (Account thisStore : storeAccounts) {
                if (
                    thisStore.Menu_UI_Type__c == 'Retail' &&
                    thisStore.Shopping_Protocol__c == 'Dasher Pick' &&
                    thisStore.Order_Protocol__c == 'POS'
                ) {
                    canSkip = true;
                    break;
                }
            }

            return canSkip;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
     * @description Exposes Payments RT Id to LWC
     * @return String
     **/
    @AuraEnabled
    public static String getPaymentsRecordType() {
        return Schema.SObjectType.Payment_Account__c.getRecordTypeInfosByName()
            .get('Payments')
            .getRecordTypeId();
    }

    /**
     * @description Called on the final screen for the user to submit feedback on the oboarding process.
     * @param flowRequestId - Id of the relevant PFR record for our flow
     * @param userFeedbackStr - Stringified JSON of the feedback properties
     * @return Process_Flow_Request__c
     **/
    @AuraEnabled
    public static Process_Flow_Request__c saveUserFeedback(
        Id flowRequestId,
        String userFeedbackStr
    ) {
        try {
            Process_Flow_Request__c flowRequest = getFlowRequestById(flowRequestId);
            flowRequest.User_Feedback__c = userFeedbackStr;
            return commitProcessFlowRequestUpdates(flowRequest);
        } catch (Exception ex) {
            throw new AuraHandledException(
                'Problem encountered when saving user feedback: ' + ex.getMessage()
            );
        }
    }

    /**
     * @description Gets information based on fields in the CSV template, including:
     *                  - The Field Labels of the template's REQUIRED fields
     *                  - Picklist values (and their field names) from the picklist fields in the template
     *              This information is displayed in our "CSV Uplaod Instructions" help section.
     * @return TemplateFieldInformation
     **/
    @AuraEnabled
    public static TemplateFieldInformation getTemplateFieldsInformation() {
        TemplateFieldInformation info = new TemplateFieldInformation();

        List<PicklistInfo> picklistInfoList = new List<PicklistInfo>();
        Map<String, Data_Transfer_Mapping__mdt> fieldMappingByNames = new Map<String, Data_Transfer_Mapping__mdt>();
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Account.fields.getMap();

        // Go through the Data Transfer Mappings and get the Field API Names (Field_API_Name__c) by labels (Field_Label__c)
        for (
            Data_Transfer_Mapping__mdt thisFieldMapping : DataTransferMappingsSelector.newInstance()
                .getAllActiveValues()
        ) {
            fieldMappingByNames.put(thisFieldMapping.Field_API_Name__c, thisFieldMapping);
        }

        // Go through all the fields in our CSV Mappings, and, if they are picklist fields, get the acceptable values
        for (String fieldApiName : fieldMappingByNames.keySet()) {
            Schema.SObjectField field = fieldMap.get(fieldApiName);
            Data_Transfer_Mapping__mdt thisFieldMapping = fieldMappingByNames.get(fieldApiName);

            if (thisFieldMapping.Is_Required__c) {
                info.requiredFieldLabels.add(thisFieldMapping.Field_Label__c);
            }

            if (field != null && thisFieldMapping != null) {
                Schema.DescribeFieldResult fieldDescribe = field.getDescribe();

                if (fieldDescribe.getType() != Schema.DisplayType.PICKLIST) {
                    continue;
                }

                List<Schema.PicklistEntry> picklistEntries = fieldDescribe.getPicklistValues();

                List<String> valueList = new List<String>();
                for (Schema.PicklistEntry entry : picklistEntries) {
                    valueList.add(entry.getValue());
                }

                PicklistInfo thisPicklistInfo = new PicklistInfo();
                thisPicklistInfo.fieldLabel = thisFieldMapping.Field_Label__c;
                thisPicklistInfo.valuesString = String.join(valueList, ', ');
                picklistInfoList.add(thisPicklistInfo);
            }
        }

        info.picklistValues = picklistInfoList;
        return info;
    }

    /**
     * @description Takes an inputted Process_Flow_Request__c record and commits the updates using fflib Unit of Work pattern
     * @param flowRequest - Process_Flow_Request__c record (with updates already applied) to commit DML on
     * @return Process_Flow_Request__c
     **/
    public static Process_Flow_Request__c commitProcessFlowRequestUpdates(
        Process_Flow_Request__c flowRequest
    ) {
        fflib_SObjectUnitOfWork uowInstance = new fflib_SObjectUnitOfWork(
            new List<SObjectType>{ Process_Flow_Request__c.sObjectType }
        );
        UpdateUnitOfWorkHelper uowUpdateHelper = new UpdateUnitOfWorkHelper();
        uowInstance.registerWork(uowUpdateHelper);
        uowUpdateHelper.registerUpdate(flowRequest);
        uowInstance.commitWork();
        return flowRequest;
    }

    /**
     * @description Serializes a collection of BulkCorporateOnboardingWrappers.StoreInfo objects with the related record IDs for
     *              the Process Flow Request.
     * @param stores - BulkCorporateOnboardingWrappers.StoreInfo to use as the basis for serialization
     * @param idToUse - Id of the linked record
     * @param skipRecordLinking - Determines whether or not to actually perform the linking -- the step could be skipped, for example
     * @return String
     **/
    public static String updateStoresWithRelatedRecordIds(
        List<BulkCorporateOnboardingWrappers.StoreInfo> stores,
        Id idToUse,
        Boolean skipRecordLinking
    ) {
        if (idToUse == null || skipRecordLinking) {
            return BulkCorporateOnboardingRequestService.packStoreInfos(stores);
        }

        Schema.SObjectType relatedRecordType = idToUse.getSobjectType();

        for (BulkCorporateOnboardingWrappers.StoreInfo thisStore : stores) {
            if (relatedRecordType == Payment_Account__c.SObjectType) {
                thisStore.paymentAccountId = idToUse;
            } else if (relatedRecordType == Contact.SObjectType) {
                thisStore.decisionMakerId = idToUse;
            }
        }

        return BulkCorporateOnboardingRequestService.packStoreInfos(stores);
    }

    /**
     * @description Returns `true` if we can skip the `Add Decision Maker` Step - i.e., if all Decision Makers were already linked
     * @param stores - BulkCorporateOnboardingWrappers.StoreInfo objects to check for `decisionMakerId`
     * @return Boolean
     **/
    private static Boolean hasDecisionMakersPopulated(
        List<BulkCorporateOnboardingWrappers.StoreInfo> stores
    ) {
        for (BulkCorporateOnboardingWrappers.StoreInfo thisStore : stores) {
            if (thisStore.decisionMakerId == null) {
                return false; // Return immediately if a store lacks a decision maker
            }
        }
        return true; // Only returns true if all stores have decision makers populated
    }

    /**
     * @description Used in the LWC to determine if we are in sandbox or production
     * @return Boolean
     **/
    @SuppressWarnings('PMD.ApexCRUDViolation')
    @AuraEnabled(cacheable=true)
    public static Boolean getIsProduction() {
        Organization org = [SELECT IsSandbox FROM Organization LIMIT 1];
        return !org.IsSandbox;
    }

    /**
     * @description Used in the LWC to determine if the user is Launch Ops
     * @return Boolean
     **/
    @SuppressWarnings('PMD.ApexCRUDViolation')
    @AuraEnabled(cacheable=true)
    public static Boolean getIsLaunchOperationsUser() {
        return (FeatureManagementService.newInstance()
            .checkPermission(ALLOW_HIGH_VOLUME_BULK_ONBOARD_STORES_CUSTOM_PERMISSION));
    }

    /**
     * @description update the Accounts.Accessbilities with the Accessbilities  info collected during the
     * final error check sceen on the ANSO flow
     * @param accessibilitiesMap
     **/
    @AuraEnabled
    public static void saveAccessibilities(Map<Id, String> accessibilitiesMap) {
        fflib_ISObjectUnitOfWork unitOfWorkInstance = Application.UnitOfWork.newInstance();
        for (Id accountId : accessibilitiesMap.keySet()) {
            String serializedData = accessibilitiesMap.get(accountId);
            // Assuming Accessibilities__c is a Text field that stores the serialized JSON
            Account account = new Account(Id = accountId, Accessibilities__c = serializedData);
            unitOfWorkInstance.registerDirty(account);
        }
        // Commit the work to update the stores
        unitOfWorkInstance.commitWork();
    }

    /**
     * @description Saves the new or existing Contact and creates or updates the ACR, as needed.
     * @param flowRequestId
     * @param contactRole
     * @param contactId
     * @param updatedContactData
     * @param fieldNames
     **/
    @AuraEnabled
    public static void saveContactRole(
        Id flowRequestId,
        String contactRole,
        String contactId,
        Contact updatedContactData,
        List<String> fieldNames
    ) {
        if (flowRequestId == null || String.isEmpty(contactId)) {
            throw new ContactRoleException(
                String.format(
                    'Invalid Flow Request ID ({0}) and/or Contact ID ({1})',
                    new List<String>{ flowRequestId, contactId }
                )
            );
        }

        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Process_Flow_Request__c flowRequest = BulkCorporateOnboardingRequestService.getBulkOnboardingRequestOrAbort(
            flowRequestId
        );
        Id accountId = flowRequest.Contract__r.AccountId;

        List<Contact> foundContacts = ContactsSelector.newInstance()
            .selectById(new Set<Id>{ contactId });
        Contact contactToUse = !foundContacts.isEmpty() ? foundContacts[0] : null;

        if (contactToUse.AccountId == null || (updatedContactData != null && fieldNames != null)) {
            if ((updatedContactData != null && fieldNames != null)) {
                // Dynamically assign fields from updatedContactData to contact
                for (String fieldName : fieldNames) {
                    Object value = updatedContactData.get(fieldName); // This will work because we're using SObject's dynamic get method
                    contactToUse.put(fieldName, value); // Update the field, allowing for null values explicitly
                }
            }

            if (contactToUse.AccountId == null) {
                contactToUse.AccountId = accountId; // Reassign private Contact
            }

            uow.registerDirty(contactToUse);
        }

        AccountContactRelation acr = findOrInitializeNewAccountContactRelation(
            accountId,
            contactId,
            contactRole
        );

        // SFDC should always insert an ACR record but make sure we have this insert covered anyway
        if (acr.Id == null) {
            uow.registerNew(acr);
        } else {
            uow.registerDirty(acr);
        }

        uow.commitWork();
    }

    /**
     * @description Returns the # of Chunks for a given PFR
     * @param flowRequestId
     * @param countOnlyCompleted
     * @return Integer
     **/
    @AuraEnabled
    public static Integer retrieveNumberOfCompletedChunksForRequest(
        Id flowRequestId,
        Boolean countOnlyCompleted
    ) {
        Integer total = 0;

        for (
            Process_Flow_Request_Chunk__c thisChunk : ProcessFlowRequestChunksSelector.newInstance()
                .selectByRequestId(flowRequestId)
        ) {
            if (!countOnlyCompleted || thisChunk.Status__c == REQUEST_STATUS_COMPLETED) {
                total++;
            }
        }

        return total;
    }

    /**
     * @description Returns the StoreInfo wrappers to the LWC for a given PFR Id
     * @param flowRequestId
     * @return List<BulkCorporateOnboardingWrappers.StoreInfoWithAccountRecord>
     **/
    @AuraEnabled
    public static List<BulkCorporateOnboardingWrappers.StoreInfoWithAccountRecord> getStoreInfosForFlowRequest(
        Id flowRequestId
    ) {
        List<BulkCorporateOnboardingWrappers.StoreInfoWithAccountRecord> returnList = new List<BulkCorporateOnboardingWrappers.StoreInfoWithAccountRecord>();

        Process_Flow_Request__c flowRequest = BulkCorporateOnboardingRequestService.getBulkOnboardingRequestOrAbort(
            flowRequestId
        );

        List<BulkCorporateOnboardingWrappers.StoreInfo> storeInfos = BulkCorporateOnboardingRequestService.unpackStoreInfos(
            flowRequest.Id,
            flowRequest.Serialized_Object_Data__c
        );

        Map<Id, Account> storesMap = new Map<Id, Account>(
            AccountsSelector.newInstance().getStoresByBulkOnboardingRequestId(flowRequestId)
        );

        for (BulkCorporateOnboardingWrappers.StoreInfo thisStore : storeInfos) {
            returnList.add(
                new BulkCorporateOnboardingWrappers.StoreInfoWithAccountRecord(
                    thisStore,
                    storesMap.get(thisStore.storeId)
                )
            );
        }

        return returnList;
    }

    /**
     * @description Finds an existing ACR, if applicable; otherwise, Instantiates a new record
     * @param accountId
     * @param contactId
     * @param contactRole
     * @return AccountContactRelation
     **/
    private static AccountContactRelation findOrInitializeNewAccountContactRelation(
        Id accountId,
        Id contactId,
        String contactRole
    ) {
        AccountContactRelation acrToUpsert;

        // TODO - Do we need Account hierarchy information?
        // ManageStoresController.validateAccountHierarchy()
        List<AccountContactRelation> foundACRs = AccountContactRelationsSelector.newInstance()
            .selectByAccountIdsAndContactIds(new Set<Id>{ accountId }, new Set<Id>{ contactId });

        if (!foundACRs.isEmpty()) {
            for (AccountContactRelation thisACR : foundACRs) {
                if (String.isNotBlank(thisACR.Roles) && !thisACR.Roles.contains(contactRole)) {
                    thisACR.Roles = thisACR.Roles + '; ' + contactRole;
                } else if (String.isBlank(thisACR.Roles)) {
                    thisACR.Roles = contactRole;
                }

                acrToUpsert = thisACR;
                acrToUpsert.IsActive = true;
                break;
            }
        }

        // If there was no ACR found, then instantiate a new one
        if (acrToUpsert == null) {
            return initAccountContactRelation(accountId, contactId, contactRole);
        }

        return acrToUpsert;
    }

    /**
     * @description Instantiates a new ACR record
     * @param accountId
     * @param contactId
     * @param contactRole
     * @return AccountContactRelation
     **/
    private static AccountContactRelation initAccountContactRelation(
        Id accountId,
        Id contactId,
        String contactRole
    ) {
        return new AccountContactRelation(
            IsActive = true,
            AccountId = accountId,
            ContactId = contactId,
            Roles = contactRole
        );
    }

    /**
     * @description Confirms if all the related records of a given type have been set
     * @param flowRequest
     * @param relatedRecordType
     * @return Boolean
     **/
    private static Boolean evaluateRecordLinkingCompletion(
        Process_Flow_Request__c flowRequest,
        Schema.SObjectType relatedRecordType
    ) {
        Boolean isComplete = true;

        List<BulkCorporateOnboardingWrappers.StoreInfo> storeInfos = BulkCorporateOnboardingRequestService.unpackStoreInfos(
            flowRequest.Id,
            flowRequest.Serialized_Object_Data__c
        );

        for (BulkCorporateOnboardingWrappers.StoreInfo thisStoreInfo : storeInfos) {
            isComplete =
                (relatedRecordType == Payment_Account__c.SObjectType &&
                thisStoreInfo.paymentAccountId != null) ||
                (relatedRecordType == Contact.SObjectType &&
                thisStoreInfo.decisionMakerId != null);

            // If one isn't complete then just exit
            if (!isComplete) {
                break;
            }
        }

        return isComplete;
    }

    /**
     * @description Used in the LWCs that display the "CSV Upload Instructions". This helps the user visualize
     *              what values are accepted for fields in the CSV.
     **/
    public class TemplateFieldInformation {
        @AuraEnabled
        public List<PicklistInfo> picklistValues;
        @AuraEnabled
        public List<String> requiredFieldLabels;

        /**
         * @description Constructor for initializing wrapper values
         **/
        public TemplateFieldInformation() {
            this.picklistValues = new List<PicklistInfo>();
            this.requiredFieldLabels = new List<String>();
        }
    }

    /**
     * @description Used in the LWCs that display the "CSV Upload Instructions". This helps the user visualize
     *              what values are accepted for fields in the CSV.
     **/
    public class PicklistInfo {
        @AuraEnabled
        public String fieldLabel;
        @AuraEnabled
        public String valuesString;
    }

    /**
     * @description Returns consolidated information to the front-end, including the new Stores, the PFR, and file.
     **/
    public class BulkOnboardingWrapper {
        @AuraEnabled
        public BulkCorporateOnboardingWrappers.StoreValidationResult results;
        @AuraEnabled
        public Process_Flow_Request__c flowRequestObj;
        @AuraEnabled
        public Id contentVersionId;
        /**
         * @description Constructor for wrapping Onboarding results and returning to the front-end
         * @param results
         * @param flowRequest
         * @param versionId
         **/
        public BulkOnboardingWrapper(
            BulkCorporateOnboardingWrappers.StoreValidationResult results,
            Process_Flow_Request__c flowRequest,
            Id versionId
        ) {
            this.results = results;
            this.flowRequestObj = flowRequest;
            this.contentVersionId = versionId;
        }
    }

    /**
     * @description Exception type thrown if there is an issue with the created WorkOrder
     **/
    public class WorkOrderCreationException extends Exception {
    }

    /**
     * @description Exception type thrown if there is an issue with the created WorkOrder
     **/
    public class ContactRoleException extends Exception {
    }
}