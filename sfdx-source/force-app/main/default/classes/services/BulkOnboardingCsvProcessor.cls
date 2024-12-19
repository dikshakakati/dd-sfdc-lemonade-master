/**
 * @author BizApps
 * @date 4 January 2024
 * @description Service implementation for Automated New Store Onboarding, specifically around CSV operations.
 */
@SuppressWarnings('PMD.CyclomaticComplexity,PMD.TooManyFields,PMD.ExcessiveClassLength')
public with sharing class BulkOnboardingCsvProcessor {
    // ⚠️ Important ⚠️: Organize class variables in a logical sequence for better readability.
    // Start with Constants, grouped by their type (e.g., Strings, Integers), followed by Enums.
    // Then, list private member variables and other elements. Maintain this order consistently.

    // CONSTANTS
    private static final String COLUMN_BUSINESS_ID = 'Business ID';
    private static final String COLUMN_BUSINESS_VERTICAL_ID = 'Business Vertical ID';
    private static final String COLUMN_DECISION_MAKER = 'Decision Maker ID';
    private static final String COLUMN_HEADER_COUNTRY = 'Country';
    private static final String COLUMN_HEADER_MENU_UI_TYPE = 'Menu UI Type';
    private static final String COLUMN_HEADER_MENU_URL = 'Menu URL';
    private static final String COLUMN_HEADER_MERCHANT_SUPPLIER_ID = 'Merchant Supplied ID';
    private static final String COLUMN_HEADER_SHOPPING_PROTOCOL = 'Shopping Protocol';
    private static final String COLUMN_HEADER_STATE = 'State';
    private static final String COLUMN_PAYMENT_ACCOUNT = 'Payment Account ID';
    private static final String COUNTRY_SKIP_VR_NZ = 'New Zealand';
    private static final String DATATYPE_BOOLEAN = 'Boolean';
    private static final String DATATYPE_DATE = 'Date';
    private static final String DATATYPE_DATETIME = 'DateTime';
    private static final String DATATYPE_DECIMAL = 'Decimal';
    private static final String DATATYPE_INTEGER = 'Integer';
    private static final String DATATYPE_PERCENT = 'Percent';
    private static final String DATATYPE_STRING = 'String';
    private static final String DATATYPE_OTHER = 'Other';
    private static final String DECISION_MAKER_INVALID_ERROR = '. Please ensure this is a valid 18-digit Salesforce ID corresponding to an existing Contact in DDMx.';
    private static final String DEFAULT_TYPE_CORPORATE = 'Corporate';
    private static final String DECISION_MAKER_REQ_ALL_STORES_ERROR = 'Decision Makers are required for all Stores. If you would like to select a single Decision Maker, leave this column blank and proceed to the next step.';
    private static final String EXTERNAL_ID_SOURCE_MDS = 'MDS';
    private static final String HYPHEN_SEPARATOR = ' - ';
    private static final String INVALID_PA_ID = 'Invalid Payment Account ID: ';
    private static final String INVALID_DM_ID = 'Invalid Decision Maker ID: ';
    private static final String MENU_TO_BE_COMPLETED_BY_ACCOUNT_OWNER = 'Account Owner';
    private static final String MENU_UI_TYPE_RETAIL = 'Retail';
    private static final String MENU_URL_ERROR = System.Label.Bulk_Store_Menu_URL_Error_Message;
    private static final String MERCHANT_SUPPLIED_ID_ERROR = ': You must provide Merchant Supplied ID for these stores since Order Protocol contains POS.';
    private static final String ORDER_PROTOCOL_POS = 'POS';
    private static final String PAYMENT_ACCOUNT_INVALID_ERROR = '. Please ensure this is a valid 18-digit Salesforce ID corresponding to an existing Payment Account in DDMx.';
    private static final String PAYMENT_ACCOUNT_INVOICE_ERROR = 'Record Type of the Payment Account should not be Invoice.';
    private static final String PAYMENT_ACCOUNT_REQ_ALL_STORES_ERROR = 'Payment Accounts are required for all Stores other than Dasher Shop Deliver Stores. If you would like to select a single Payment Account, leave this column blank and proceed to the next step.';
    private static final String SHOPPING_PROTOCOL_DASHER_PICK = 'Dasher Pick';
    private static final Id INVOICE_RECORD_TYPE_ID = Schema.SObjectType.Payment_Account__c.getRecordTypeInfosByDeveloperName()
        .get('Invoice')
        .getRecordTypeId();

    private static final Integer CHUNK_SIZE = 50;

    private static final Map<String, String> CURRENCY_ISOCODE_TO_COUNTRY = new Map<String, String>{
        'AUD' => 'AU',
        'NZD' => 'NZ',
        'USD' => 'US',
        'CAD' => 'CA'
    };
    private static final Map<String, String> COUNTRY_TO_CURRENCY_ISOCODE;

    static {
        COUNTRY_TO_CURRENCY_ISOCODE = getReverseMap(CURRENCY_ISOCODE_TO_COUNTRY);
    }

    // These collections are for global, sheet-wide validations. This means that we must consider the values in every row in order to perform certain validations.
    // An example of this is `menuUITypes`, where an error should be displayed if the user imported more than one `Menu UI Type` value per upload.
    private static Set<String> menuUITypes = new Set<String>();
    private static Map<Id, List<Integer>> decisionMakerIdToCsvRowNumbers = new Map<Id, List<Integer>>(); // This is used to flag errors for Invalid Decision Maker Ids.
    private static Map<Id, List<Integer>> paymentAccountIdToCsvRowNumbers = new Map<Id, List<Integer>>(); // This is used to flag errors from "Invoice" RT Payment Accounts
    private static Set<String> businessIds = new Set<String>();
    private static Set<Id> businessVerticalIds = new Set<Id>();
    private static List<String> businessVerticalNames = new List<String>();
    private static Map<String, Business_Reference__c> businessIdCurrencyCodeToBusinessReference = new Map<String, Business_Reference__c>();
    private static Map<String, Id> businessIdToBusinessVerticalId = new Map<String, Id>();
    private static Set<Id> contractBrandIds = new Set<Id>();
    private static List<Contract_Brand_Association__c> contractBrandAssociation = new List<Contract_Brand_Association__c>();
    private static Map<String, String> rowNumberToBusinessId = new Map<String, String>();
    private static String businessVerticalName;
    private static Id businessVerticalId;
    private static Map<Integer, String> rowNumberToBrand = new  Map<Integer, String>();
    private static Integer countryColumnIndex = 0;


    // PRIVATE MEMBER VARIABLES
    private Process_Flow_Request__c flowRequest { get; set; }
    private WorkOrder thisWorkOrder { get; set; }
    private Account businessAccount { get; set; }

    private Boolean isWorkOrderPos = false;
    private Boolean includesPaymentAccounts = false;
    private Boolean includesDecisionMakers = false;
    private Boolean showPaymentAccountSkipOption = false;

    private List<BulkCorporateOnboardingWrappers.ErrorMessage> errorMessages = new List<BulkCorporateOnboardingWrappers.ErrorMessage>();
    private List<String> columnHeaders = new List<String>();
    List<sObject> newRecords = new List<sObject>();
    List<BulkCorporateOnboardingWrappers.StoreInfo> storeWrappers = new List<BulkCorporateOnboardingWrappers.StoreInfo>();
    private List<Contract> contracts = new List<Contract>();

    private Map<String, Data_Transfer_Mapping__mdt> dataTransferMappingsMap {
        get {
            if (dataTransferMappingsMap == null) {
                dataTransferMappingsMap = new Map<String, Data_Transfer_Mapping__mdt>();

                for (
                    Data_Transfer_Mapping__mdt thisMapping : DataTransferMappingsSelector.newInstance()
                        .getAllActiveValues()
                ) {
                    dataTransferMappingsMap.put(thisMapping.MasterLabel, thisMapping);
                }
            }
            return dataTransferMappingsMap;
        }
        set;
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
        newRecords = new List<sObject>();
        storeWrappers = new List<BulkCorporateOnboardingWrappers.StoreInfo>();

        List<List<String>> filelines = csvRows;
        columnHeaders = getSheetHeaders(csvRows);

        validateHasRows(filelines);
        validateRequiredColumns();
        validateHeaderRow(chunkId);

        setParentDetails(flowRequestId);

        // If we have no global errors in the sheet (e.g., missing columns, invalid column names, etc), then start processing each Store/row
        if (errorMessages.isEmpty()) {
            fetchDependentInfoForValidations(filelines);
            queryDependentDataForValidations();
            processRows(filelines, flowRequestId, chunkId, totalChunks);
        }

        performValidationsOnPaymentAccountsAndDecisionMakers(storeWrappers);
        performGlobalValidations();

        // Handle the results - create a result object and then insert the PFR Chunk records
        BulkCorporateOnboardingWrappers.StoreValidationResult bulkCorporateOnboardings = calculateOnboardingResults(
            chunkId,
            totalChunks
        );

        return bulkCorporateOnboardings;
    }

    /**
     * @description It is used to collect the csv row values for buiness related validations
     * example: check for the column header = Buiness Id and store the  Business ids in the businessIds Set
     * use this method in future to collect the  row values for any other business related validations after checking the column header
     * @param filelines
     **/
    private void fetchDependentInfoForValidations(List<List<String>> filelines) {
        for (Integer i = 1; i < filelines.size(); i++) {
            List<String> rowValues = filelines[i];
            for (Integer j = 0; j < rowValues.size(); j++) {
                //Boolean currentColumnHasHeader:  collect the row values only if the each cell has a column header
                // Introduced the Boolean: currentColumnHasHeader to avoid the List out of Bounds error
                Boolean currentColumnHasHeader = j < columnHeaders.size();
                if (
                    currentColumnHasHeader &&
                    String.isBlank(rowValues[j]) &&
                    dataTransferMappingsMap.get(columnHeaders[j]).Is_Required__c
                ) {
                    continue;
                }
                if (
                    currentColumnHasHeader &&
                    columnHeaders[j] == COLUMN_BUSINESS_ID &&
                    String.isNotBlank(rowValues[j])
                ) {
                    businessIds.add(rowValues[j]);
                }
            }
        }
    }

    /**
     * @description it is used to query the records using the csv values collected in the fetchDependentInfoForValidations method
     * and prepare the data set which is used for further Business Validations
     * It can be used to query other dependent data for validation, example used to collect the BrandIds associated with the contract
     **/
    private void queryDependentDataForValidations() {
        Map<Id, Business_Reference__c> businessReferenceIdToBusinessReference = new Map<Id, Business_Reference__c>(
            BusinessReferencesSelector.newInstance()
                .selectByDefaultTypeAndExternalIdSource(
                    businessIds,
                    new Set<String>{ DEFAULT_TYPE_CORPORATE },
                    new Set<String>{ EXTERNAL_ID_SOURCE_MDS }
                )
        );
        if (!businessReferenceIdToBusinessReference.isEmpty()) {
            for (
                Business_Reference__c businessRef : businessReferenceIdToBusinessReference.values()
            ) {
                String bussinessRefCountryKey =
                    businessRef.External_Id__c +
                    CURRENCY_ISOCODE_TO_COUNTRY.get(businessRef.CurrencyIsoCode);
                businessIdCurrencyCodeToBusinessReference.put(bussinessRefCountryKey, businessRef);
                businessIdToBusinessVerticalId.put(
                    businessRef.External_Id__c,
                    businessRef.Business_Vertical__c
                );
                businessVerticalNames.add(businessRef.Business_Vertical__r.Name);
            }
        }
        contractBrandAssociation = ContractBrandAssociationsSelector.newInstance()
            .selectByContracts(new Set<String>{ contracts[0].Id });
        for (Contract_Brand_Association__c contractBrandAccociation : contractBrandAssociation) {
            contractBrandIds.add(contractBrandAccociation.Brand__c);
        }
    }

    /**
     * @description Processes the CSV rows line by line
     * @param filelines
     * @param flowRequestId
     * @param chunkId
     * @param totalChunks
     **/
    private void processRows(
        List<List<String>> filelines,
        Id flowRequestId,
        Integer chunkId,
        Integer totalChunks
    ) {
        // Each row (Store) in the sheet...
        for (Integer i = 1; i < filelines.size(); i++) {
            List<String> rowValues = filelines[i];

            if(rowValues.size() > columnHeaders.size()) {
                errorMessages.add(createError(null, System.Label.Bulk_Store_Invalid_CSV, false));
                break; // Skip further processing because we won't really know what cell maps to what column header anyway
            }

            SObject newRecord = BulkCorporateOnboardingRequestService.populateStoreWithDefaults(
                flowRequestId,
                businessAccount,
                thisWorkOrder
            );

            BulkCorporateOnboardingWrappers.StoreInfo wrapperObj = new BulkCorporateOnboardingWrappers.StoreInfo(
                null,
                null,
                null
            );
            wrapperObj.index = (chunkId - 1) * CHUNK_SIZE + (i - 1);
            wrapperObj.rowNumber = wrapperObj.index + 1;

            // Each column of the row...
            for(Integer j = 0; j < rowValues.size(); j++) {
                if(String.isBlank(rowValues[j]) && dataTransferMappingsMap.get(columnHeaders[j]).Is_Required__c) {
                        errorMessages.add(
                            createError(wrapperObj.rowNumber, columnHeaders[j] + ' is Required', false)
                        );
                    continue;
                }
                //LEM-10718 - Produce errors - if country is not 'NZ' and state detail is not present or if country is not 'NZ' and state column is not present
                if((columnHeaders[j] == COLUMN_HEADER_COUNTRY || columnHeaders[j] == COLUMN_HEADER_STATE) && countryColumnIndex != 0 && !rowValues[countryColumnIndex].equalsIgnoreCase(COUNTRY_SKIP_VR_NZ)){
                    validateStateAvailabilityCheck(rowValues, columnHeaders[j], j, wrapperObj.rowNumber);
                    continue;
                }
                Data_Transfer_Mapping__mdt thisMapping = dataTransferMappingsMap.get(columnHeaders[j]);


                Object convertedValue = safeConvert(rowValues[j], thisMapping.Field_Data_Type__c);

                if (thisMapping.Field_Data_Type__c == DATATYPE_OTHER) {
                    wrapperObj = handleOtherDataTypeFields(
                        wrapperObj,
                        columnHeaders[j],
                        rowValues[j]
                    );
                } else {
                    newRecord = addValueToRecord(
                        newRecord,
                        thisMapping.Field_API_Name__c,
                        convertedValue,
                        rowValues[j],
                        thisMapping.Is_Required__c
                    );
                }

                handleSpecificFields(newRecord, wrapperObj, columnHeaders[j], rowValues[j]);

                wrapperObj = determinePaymentAccountSkipStatus(
                    j,
                    wrapperObj,
                    i == (filelines.size() - 1),
                    rowValues
                );

                inspectValuesBasedOnPosWorkOrder(i, columnHeaders[j], rowValues[j]);
            }

            validateRequiredFields(rowValues, wrapperObj);
            validateAndPrepopulateBusinessRefDependentInfo(newRecord, wrapperObj);
            runReadinessChecksForRow(newRecord, wrapperObj);

            newRecords.add(newRecord);
            storeWrappers.add(wrapperObj);
        }
    }

    /**
     * @description Checks if state column is present or if state info is blank for a row.
     * @param rowValues  Cell values for a row.
     * @param columnHeader  Corresponding column name of the cell value in a row.
     * @param currentColumnIndex  Corresponding column index of the cell value in a row.
     * @param wrpObjRowNum  Wrapper object row number.
     * @jira #LEM-10718
     */
    private void validateStateAvailabilityCheck(List<String> rowValues, String columnHeader, Integer currentColumnIndex, Integer wrpObjRowNum){
        if((!columnHeaders.contains(COLUMN_HEADER_STATE)) || (columnHeader == COLUMN_HEADER_STATE && String.isBlank(rowValues[currentColumnIndex]))){
            errorMessages.add(
                createError(wrpObjRowNum, 'State is Required', false)
            );
        }
    }

    /**
     * @description It is used for Business Id related validations for each store in the csv
     * 1: validates if the matching MDS, Corporate Business reference records is found in system
     * 2: validates if the Business Ids belong to the same Business Vertical
     * 3: validates if the Brand on the Buisness reference is associated with the Contract brands
     * @param newrecord
     * @param wrapperObj
     **/
    private void validateAndPrepopulateBusinessRefDependentInfo(
        SObject newrecord,
        BulkCorporateOnboardingWrappers.StoreInfo wrapperObj
    ) {
        Id brandOnbusinessReferenceId;
        String brandName;
        String businessId = rowNumberToBusinessId.get(String.valueOf(wrapperObj.rowNumber));
        String matchingKey = businessId + newRecord.get('BillingCountryCode');
        // throw error if the matching Business reference(Corporate, MDS) is not found in the System
        if (
            businessId != null &&
            !businessIdCurrencyCodeToBusinessReference.containsKey(matchingKey)
        ) {
            String countryCode = String.valueOf(newRecord.get('BillingCountryCode'));
            String currencyIsoCode = COUNTRY_TO_CURRENCY_ISOCODE.get(countryCode);
            String bizRefMsg =
                'A Business Reference with the following criteria could not be found. Ensure a Business Reference exists in the system with Curreny=' +
                currencyIsoCode +
                ', External ID Source=MDS, Default Type=Corporate, Business ID=' +
                businessId +
                ' for the Account : ' +
                newrecord.get('Name');

            errorMessages.add(createError(wrapperObj.rowNumber, bizRefMsg, false));
            return;
        }
        if (businessIdCurrencyCodeToBusinessReference.containsKey(matchingKey)) {
            brandOnbusinessReferenceId = businessIdCurrencyCodeToBusinessReference.get(matchingKey)
                .Brand__c;
            brandName = businessIdCurrencyCodeToBusinessReference.get(matchingKey).Brand__r.Name;
            newrecord.put('Brand__c', brandOnbusinessReferenceId);
            newrecord.put('Business_Vertical__c', businessIdToBusinessVerticalId.get(businessId));
            // throw error if the Brand on the Business Reference is not associated with the Contract
            if (contractBrandIds.isEmpty() || !contractBrandIds.contains(brandOnbusinessReferenceId)){
                String brandNotRelatedToContractMsg =
                    'The store is not able to be associated to the contract because the Brand : ' +
                    brandName +
                    ' associated with Business ID : ' +
                    businessId +
                    ' is not related to the contract. Add ' +
                    brandName +
                    ' to the contract to continue.';
                errorMessages.add(
                    createError(wrapperObj.rowNumber, brandNotRelatedToContractMsg, false)
                );
            } else {
                rowNumberToBrand.put(wrapperObj.rowNumber, brandName);
                businessVerticalName = businessVerticalNames[0];
                businessVerticalId = businessIdToBusinessVerticalId.get(businessId);
            }
            handleSpecificFields(
                newRecord,
                wrapperObj,
                COLUMN_BUSINESS_VERTICAL_ID,
                businessIdToBusinessVerticalId.get(businessId)
            );
        }
    }

    /**
     * @description Validates the header row of the first chunk of the CSV, ensuring the valid column names are present.
     * @param chunkId
     **/
    private void validateHeaderRow(Integer chunkId) {
        // Global validations for the entire sheet should only be run once
        if (chunkId != 1) {
            return;
        }

        // Add an error if the CSV has a column name that is not in our mappings
        for(String column : columnHeaders) {
            if (!dataTransferMappingsMap.containsKey(column)) {
                errorMessages.add(
                    createError(null, column + ' Please enter the valid column name', false)
                );
            }
        }

        // Validate required fields are in the sheet - display an error if any are missing from the CSV
        for(Data_Transfer_Mapping__mdt dataTransferMapping : dataTransferMappingsMap.values()) {
            if(!columnHeaders.contains(dataTransferMapping.MasterLabel) && dataTransferMapping.Is_Required__c) {
                errorMessages.add(
                    createError(
                        null,
                        dataTransferMapping.MasterLabel +
                        ' field is required. If entered please check spelling and spaces',
                        false
                    )
                );
            }
        }
    }

    /**
     * @description Adds to the errors list if any required fields are not in the CSV sheet
     **/
    private void validateRequiredColumns() {
        // Validate required fields - display an error if any are missing from the CSV
        for(Data_Transfer_Mapping__mdt dataTransferMapping : dataTransferMappingsMap.values()) {
            if(!columnHeaders.contains(dataTransferMapping.MasterLabel) && dataTransferMapping.Is_Required__c) {
                errorMessages.add(
                    createError(
                        null,
                        dataTransferMapping.MasterLabel +
                        ' field is required. If entered please check spelling and spaces',
                        false
                    )
                );
            }
        }
    }

    /**
     * @description Adds to the errors list if the sheet is missing rows
     * @param filelines
     **/
    private void validateHasRows(List<List<String>> filelines) {
        // Validate that the CSV contains at least one row (excluding the header)
        if(filelines.size() <= 1) {
            errorMessages.add(createError(null, 'You must include at least one Store', false));
        }
    }

    /**
     * @description Adds to the errors list if any Stores are missing values in the required fields
     * @param rowValues
     * @param wrapperObj
     **/
    private void validateRequiredFields(
        List<String> rowValues,
        BulkCorporateOnboardingWrappers.StoreInfo wrapperObj
    ) {
        if (rowValues.size() < columnHeaders.size()) {
            for (Integer j = rowValues.size(); j < columnHeaders.size(); j++) {
                if (!dataTransferMappingsMap.get(columnHeaders[j]).Is_Required__c) {
                    continue;
                }

                errorMessages.add(
                    createError(wrapperObj.rowNumber, columnHeaders[j] + ' is Required', false)
                );
            }
        }
    }

    /**
     * @description Perform the validation / requirements for Payment Accounts and Decision Makers. These are required, but
                    not in the normal way. Here, the user can skip adding these columns (or keep the column and omit the values)
                    in the CSV, but, if they do so, they will be prompted to select a PA / DM in an upcoming step which will
                    apply to ALL stores. However, if they add even a single PA to the CSV, they will have to include PAs for
                    every store other than Dasher Shop Deliver Stores. The same goes with DMs - if one is specified here, then
                    they all must be. If they are not included, then a single DM must be selected in an upcoming step
                    which applies to all stores.
     * @param storeWrappers
    **/
    private void performValidationsOnPaymentAccountsAndDecisionMakers(
        List<BulkCorporateOnboardingWrappers.StoreInfo> storeWrappers
    ) {
        for (BulkCorporateOnboardingWrappers.StoreInfo thisStore : storeWrappers) {
            validatePaymentAccounts(thisStore);
            validateDecisionMakers(thisStore);
        }

        //To add an error if any payment account of record type 'Invoice' is used.
        if (includesPaymentAccounts && !paymentAccountIdToCsvRowNumbers.isEmpty()) {
            validateForInvalidOrInvoicePaymentAccounts();
        }

        if (includesDecisionMakers && !decisionMakerIdToCsvRowNumbers.isEmpty()) {
            validateForInvalidDecisionMakersId();
        }
    }

    /**
     * @description Performs validation on PaymentAccountID passed in csv, if they are valid DDMX Ids or if the passed Payment Account is of Invoice Record Type.
     **/
    private void validateForInvalidOrInvoicePaymentAccounts() {
        Map<Id, Payment_Account__c> paymentAccountsFromFile = new Map<Id, Payment_Account__c>();
        String paymentAccountErrorVerbiage;
        paymentAccountsFromFile = new Map<Id, Payment_Account__c>(
            PaymentAccountsSelector.newInstance()
                .selectById(paymentAccountIdToCsvRowNumbers.keySet())
        );

        for (Id eachPaymentAccountId : paymentAccountIdToCsvRowNumbers.keySet()) {
            if (paymentAccountsFromFile.containsKey(eachPaymentAccountId)) {
                if (
                    paymentAccountsFromFile.get(eachPaymentAccountId).RecordTypeId ==
                    INVOICE_RECORD_TYPE_ID
                ) {
                    createPaymentAccountOrDecisionMakerError(
                        eachPaymentAccountId,
                        null,
                        PAYMENT_ACCOUNT_INVOICE_ERROR
                    );
                }
                continue;
            }
            paymentAccountErrorVerbiage =
                INVALID_PA_ID +
                eachPaymentAccountId +
                PAYMENT_ACCOUNT_INVALID_ERROR;
            createPaymentAccountOrDecisionMakerError(
                eachPaymentAccountId,
                null,
                paymentAccountErrorVerbiage
            );
        }
    }

    /**
     * @description Performs validation on DecisionMakerId passed in csv, if they are valid DDMX Ids
     **/
    private void validateForInvalidDecisionMakersId() {
        Map<Id, Contact> decisionMakersFromFile = new Map<Id, Contact>();
        decisionMakersFromFile = new Map<Id, Contact>(
            ContactsSelector.newInstance().selectById(decisionMakerIdToCsvRowNumbers.keySet())
        );
        String decisionMakerErrorVerbiage;
        for (Id eachDecisionMakerId : decisionMakerIdToCsvRowNumbers.keySet()) {
            if (decisionMakersFromFile.containsKey(eachDecisionMakerId)) {
                continue;
            }
            decisionMakerErrorVerbiage =
                INVALID_DM_ID +
                eachDecisionMakerId +
                DECISION_MAKER_INVALID_ERROR;
            createPaymentAccountOrDecisionMakerError(
                null,
                eachDecisionMakerId,
                decisionMakerErrorVerbiage
            );
        }
    }

    /**
     * @description Method to throw error for Payment Account or Decision Maker Validation
     * @param eachPaymentAccountId
     * @param eachDecisionMakerId
     * @param paymentAccountOrDecisionMakerError
     **/
    private void createPaymentAccountOrDecisionMakerError(
        Id eachPaymentAccountId,
        Id eachDecisionMakerId,
        String paymentAccountOrDecisionMakerError
    ) {
        List<Integer> rowNumbers = eachPaymentAccountId != null
            ? paymentAccountIdToCsvRowNumbers.get(eachPaymentAccountId)
            : decisionMakerIdToCsvRowNumbers.get(eachDecisionMakerId);
        for (Integer eachRowNumber : rowNumbers) {
            errorMessages.add(
                        createError(eachRowNumber, paymentAccountOrDecisionMakerError, false));
        }
    }

    /**
     * @description Perform Payment Account-specific validations
     * @param thisStore
     **/
    private void validatePaymentAccounts(BulkCorporateOnboardingWrappers.StoreInfo thisStore) {
        if(includesPaymentAccounts && thisStore.paymentAccountId == null && thisStore.isPaRequired) {
            errorMessages.add(
                createError(thisStore.index + 1, PAYMENT_ACCOUNT_REQ_ALL_STORES_ERROR, false)
            );
        }

        //If there is a single DSD account included then set the flag to show the skip PA option to true.
        if (thisStore.isPaRequired == false) {
            this.showPaymentAccountSkipOption = true;
        }

        if (!paymentAccountIdToCsvRowNumbers.containsKey(thisStore.paymentAccountId)) {
            paymentAccountIdToCsvRowNumbers.put(thisStore.paymentAccountId, new List<Integer>{});
        }

        paymentAccountIdToCsvRowNumbers.get(thisStore.paymentAccountId).add(thisStore.rowNumber);
    }

    /**
     * @description Perform Decision Maker-specific validations
     * @param thisStore
     **/
    private void validateDecisionMakers(BulkCorporateOnboardingWrappers.StoreInfo thisStore) {
        if(includesDecisionMakers && thisStore.decisionMakerId == null) {
            errorMessages.add(
                createError((thisStore.index + 1), DECISION_MAKER_REQ_ALL_STORES_ERROR, false)
            );
        }

        if (!decisionMakerIdToCsvRowNumbers.containsKey(thisStore.decisionMakerId)) {
            decisionMakerIdToCsvRowNumbers.put(thisStore.decisionMakerId, new List<Integer>{});
        }

        decisionMakerIdToCsvRowNumbers.get(thisStore.decisionMakerId).add(thisStore.rowNumber);
    }

    /**
     * @description Perform validations on global, sheet-wide validations. This means that we must consider the values in every row in order
     *              to perform certain validations. An example of this is `menuUITypes`, where an error should be displayed if the user
     *              imported more than one `Menu UI Type` value per upload.
     *               Another example of this is `businessVerticalIds`, where an error should be displayed if the user
     *              imported more than one `Buiness Vertical ID` value per upload.
     *
     **/
    private void performGlobalValidations() {
        // Add 'Menu UI Type must match on all uploaded stores' error message if there are multiple values uploaded
        if (menuUITypes.size() > 1) {
            errorMessages.add(createError(null, System.Label.Menu_UI_Type_Error_Message, false));
        }

        if (businessVerticalIds.size() > 1) {
            errorMessages.add(
                createError(
                    null,
                    System.Label.Business_Vertical_Error_Message +
                        ' The sheet has Business Verticals of ' +
                        String.join(businessVerticalNames, ','),
                    false
                )
            );
        }
    }

    /**
     * @description Called when specific fields need unique validations imposed on them
     * @param newRecord
     * @param wrapperObj
     * @param columnName
     * @param fieldValue
     **/
    private void handleSpecificFields(
        SObject newRecord,
        BulkCorporateOnboardingWrappers.StoreInfo wrapperObj,
        String columnName,
        String fieldValue
    ) {
        switch on columnName {
            when 'Phone' {
                // Phone is no longer required and might not need valiation if a value is not present
                if (String.isNotBlank(fieldValue)) {
                    processPotentialValidationCheck(
                        BulkOnboardingReadinessCheckService.runPhoneValidation(
                            newRecord,
                            columnName
                        ),
                        wrapperObj.rowNumber
                    );
                }
            }
            when 'Menu UI Type' {
                menuUITypes.add(fieldValue);
            }
            when 'Business Vertical ID' {
                businessVerticalIds.add(fieldValue);
            }
        }
    }

    /**
     * @description Sets variables responsible for providing Payment Account skip option later in the flow.
     * @param rowIndex
     * @param wrapperObj
     * @param isLastRow
     * @param rowValues
     * @return BulkCorporateOnboardingWrappers.StoreInfo
    **/
    private BulkCorporateOnboardingWrappers.StoreInfo determinePaymentAccountSkipStatus(
        Integer rowIndex,
        BulkCorporateOnboardingWrappers.StoreInfo wrapperObj,
        Boolean isLastRow,
        List<String> rowValues
    ) {
        if (shouldSkipOptionBeConsidered(rowValues[rowIndex], columnHeaders[rowIndex])) {
            //To ensure if some stores are DSD with no payment account record associated in csv then show the skip option.
            if (
                (columnHeaders[rowIndex] == COLUMN_PAYMENT_ACCOUNT &&
                rowValues[rowIndex] != null)
            ) {
                this.showPaymentAccountSkipOption = false;
            }

            //To check if all the stores are non-DSD then do not show the skip option.
            if (isLastRow && this.showPaymentAccountSkipOption) {
                this.showPaymentAccountSkipOption = false;
            }

            wrapperObj.isPaRequired = true;
        }

        return wrapperObj;
    }

    /**
     * @description Returns true if Menu UI Type is not Retail or if Shopping Protocol is not Dasher Pick or Order Protocol on Work Order is POS
     * @param currentValue
     * @param columnName
     * @return Boolean
     **/
    private Boolean shouldSkipOptionBeConsidered(String currentValue, String columnName) {
        return (columnName == COLUMN_HEADER_MENU_UI_TYPE &&
            currentValue != MENU_UI_TYPE_RETAIL) ||
            (columnName == COLUMN_HEADER_SHOPPING_PROTOCOL &&
            currentValue != SHOPPING_PROTOCOL_DASHER_PICK) ||
            (thisWorkOrder != null &&
            thisWorkOrder.Order_Protocol__c != ORDER_PROTOCOL_POS);
    }

    /**
     * @description Checks Store value population based on the Order Protocol of the Work Order
     * @param rowNumber
     * @param columnName
     * @param currentRowValue
    **/
    private void inspectValuesBasedOnPosWorkOrder(
        Integer rowNumber,
        String columnName,
        String currentRowValue
    ) {
        //To check when Work Order's "Order Protocol" is 'POS' then Merchant Supplied Id should be populated.
        if (
            isWorkOrderPos &&
            columnName == COLUMN_HEADER_MERCHANT_SUPPLIER_ID &&
            String.isBlank(currentRowValue)
        ) {
            errorMessages.add(createError(rowNumber, MERCHANT_SUPPLIED_ID_ERROR, false));
        }
        //To check when Work Order's "Order Protocol" does not contains 'POS' and "Menu to be Completed By" is not 'Account Owner' then "Menu URL" should be populated.
        if (
            !isWorkOrderPos &&
            thisWorkOrder.Menu_to_be_Completed_By__c != MENU_TO_BE_COMPLETED_BY_ACCOUNT_OWNER &&
            columnName == COLUMN_HEADER_MENU_URL &&
            String.isBlank(currentRowValue)
        ) {
            errorMessages.add(createError(rowNumber, MENU_URL_ERROR, false));
        }
    }

    /**
     * @description Takes the rows in the sheet and returns the column headers, performing any cleanup tasks.
     * @param csvRows - (List<List<String>>) List that contains the rows in the sheet
     * @return List<String>
     **/
    private List<String> getSheetHeaders(List<List<String>> csvRows) {
        List<String> columnHeaders = new List<String>();
        List<String> columnRowList = csvRows[0];
        String thisHeaderCell;
        for(Integer i = 0 ; i < columnRowList.size(); i++){
            thisHeaderCell = columnRowList[i].replace('*', '');
            columnHeaders.add(thisHeaderCell);
            if(thisHeaderCell == COLUMN_HEADER_COUNTRY){
                countryColumnIndex = i;
            }
        }
        return columnHeaders;
    }

    /**
     * @description Adds a generic value to the generic Store SObject record
     * @param newRecord
     * @param fieldName
     * @param convertedValue
     * @param stringValue
     * @param isRequired
     * @return SObject
     **/
    private SObject addValueToRecord(
        SObject newRecord,
        String fieldName,
        Object convertedValue,
        String stringValue,
        Boolean isRequired
    ) {
        if (convertedValue != null || (String.isBlank(stringValue) && !isRequired)) {
            newRecord.put(fieldName, convertedValue);
        }

        return newRecord;
    }

    /**
     * @description Does an attempted insert of the Stores so we can get the system validation errors, if any, upfront.
     * @param bulkCorporateOnboardings
     * @return BulkCorporateOnboardingWrappers.StoreValidationResult
     **/
    private static BulkCorporateOnboardingWrappers.StoreValidationResult trialInsertStores(
        BulkCorporateOnboardingWrappers.StoreValidationResult bulkCorporateOnboardings
    ) {
        // Initialize a Savepoint for rollback
        Savepoint sp = Database.setSavepoint();

        // Attempt to insert the newRecords and capture the save results
        List<Database.SaveResult> saveResults = Database.insert(
            bulkCorporateOnboardings.newRecords,
            false
        );

        // Iterate through the save results to collect error messages
        for (Integer i = 0; i < saveResults.size(); i++) {
            Database.SaveResult sr = saveResults[i];
            if (!sr.isSuccess()) {
                // There were errors during insert, collect them
                for (Database.Error err : sr.getErrors()) {
                    // Prepend the row number to the error message
                    Integer rowNum = bulkCorporateOnboardings.storeWrappers[i].rowNumber;
                    if (err instanceof Database.DuplicateError) {
                        bulkCorporateOnboardings = addErrorMessageByDuplicateAccounts(
                            err,
                            bulkCorporateOnboardings,
                            rowNum,
                            i
                        );
                    } else {
                        bulkCorporateOnboardings.errorMessages.add(
                            createError(rowNum, err.getMessage(), false)
                        );
                    }
                }
            }
        }
        // Rollback to undo the inserts since this is a trial
        Database.rollback(sp);

        // Reset the IDs on the original records to ensure they are treated as new records for subsequent DML
        for (SObject acc : bulkCorporateOnboardings.newRecords) {
            acc.Id = null;
        }

        for (
            BulkCorporateOnboardingWrappers.ErrorMessage thisError : bulkCorporateOnboardings.errorMessages
        ) {
            if (!thisError.isDuplicateWarning) {
                bulkCorporateOnboardings.hasNonDuplicateErrors = true;
                break;
            }
        }

        // Return the bulkCorporateOnboardings with the error messages collected
        return bulkCorporateOnboardings;
    }

    /**
     * @description It is used to add the error messages for each duplicate account found in the csv.
     * @param error
     * @param bulkCorporateOnboardings
     * @param rowNumber
     * @param index
     * @return BulkCorporateOnboardingWrappers.StoreValidationResult
     */
    private static BulkCorporateOnboardingWrappers.StoreValidationResult addErrorMessageByDuplicateAccounts(
        Database.Error error,
        BulkCorporateOnboardingWrappers.StoreValidationResult bulkCorporateOnboardings,
        Integer rowNumber,
        Integer index
    ) {
        bulkCorporateOnboardings.errorMessages.add(
            createError(rowNumber, System.Label.Duplicate_Account_Error_Message, true)
        );

        Datacloud.MatchRecord[] matchRecords = ((Database.DuplicateError) error).getDuplicateResult().getMatchResults()[0].getMatchRecords();
        for (Datacloud.MatchRecord eachMatchRecord : matchRecords) {
            bulkCorporateOnboardings.storeWrappers[index]
                .duplicateResults.matchAccountIds.add(((Account) eachMatchRecord.getRecord()).Id);
        }
        return bulkCorporateOnboardings;
    }

    /**
     * @description Populates instance variable of the AccountId related to the PFR's Contract
     * @param flowRequestId - Id of the PFR record to use in the validation
     **/
    private void setParentDetails(Id flowRequestId) {
        Process_Flow_Request__c flowRequest = ProcessFlowRequestsSelector.newInstance()
            .selectById(new Set<Id>{ flowRequestId })[0];

        if (flowRequest == null || flowRequest.Contract__c == null) {
            return;
        }

        contracts = ContractsSelector.newInstance()
            .selectById(new Set<Id>{ flowRequest.Contract__c });

        if (contracts == null || contracts.isEmpty()) {
            return;
        }

        businessAccount = BulkCorporateOnboardingRequestService.getBusinessAccountForContract(
            contracts[0]
        );

        if (flowRequest.Work_Order__c != null) {
            try {
                thisWorkOrder = WorkOrdersSelector.newInstance()
                    .selectById(new Set<Id>{ flowRequest.Work_Order__c })[0];
                isWorkOrderPos =
                    thisWorkOrder != null &&
                    String.isNotBlank(thisWorkOrder.Order_Protocol__c) &&
                    (thisWorkOrder.Order_Protocol__c).contains(ORDER_PROTOCOL_POS);
            } catch (Exception ex) {
                thisWorkOrder = new WorkOrder();
            }
        }
    }

    /**
     * @description Executes the Readiness Checks for the given Store by invoking the Readiness Check Service
     * @param newRecord - Store SObject record
     * @param wrapperObj - StoreInfo wrapper with extra details on the Store
    **/
    private void runReadinessChecksForRow(
        SObject newRecord,
        BulkCorporateOnboardingWrappers.StoreInfo wrapperObj
    ) {
        List<BulkCorporateOnboardingWrappers.ErrorMessage> errorsForStore = BulkOnboardingReadinessCheckService.runReadinessChecksAndGetErrors(
            newRecord,
            wrapperObj
        );

        if (!errorsForStore.isEmpty()) {
            errorMessages.addAll(errorsForStore);
        }
    }

    /**
     * @description Adds Payment Account Id or Decision Maker Id to the Store Wrapper for later use
     * @param wrapperObj - StoreInfo wrapper on which we need to set the PA/DM properties
     * @param headerValue - String in the column header
     * @param thisRowValue - String in the cell of the row
     * @return BulkCorporateOnboardingWrappers.StoreInfo
     **/
    private BulkCorporateOnboardingWrappers.StoreInfo handleOtherDataTypeFields(
        BulkCorporateOnboardingWrappers.StoreInfo wrapperObj,
        String headerValue,
        String thisRowValue
    ) {
        if (
            headerValue != COLUMN_PAYMENT_ACCOUNT &&
            headerValue != COLUMN_DECISION_MAKER &&
            headerValue != COLUMN_BUSINESS_ID
        ) {
            return wrapperObj;
        }
        if (headerValue == COLUMN_PAYMENT_ACCOUNT) {
            if (String.isNotBlank(thisRowValue)) {
                wrapperObj.paymentAccountId = thisRowValue;
                this.includesPaymentAccounts = true; // Set this if there are any PA values
            }
        }

        if (headerValue == COLUMN_DECISION_MAKER) {
            if (String.isNotBlank(thisRowValue)) {
                wrapperObj.decisionMakerId = thisRowValue;
                this.includesDecisionMakers = true; // Set this if there are any DM values
            }
        }

        if (headerValue == COLUMN_BUSINESS_ID && String.isNotBlank(thisRowValue)) {
            rowNumberToBusinessId.put(String.valueOf(wrapperObj.rowNumber), thisRowValue); // set the row Number to Business Id value
        }

        return wrapperObj;
    }

    /**
     * @description Adds error message to `errorMessages` array if it exists
     * @param validationMessage - The possible validation error that might have been returned
     * @param rowNumber - The CSV row number of the errant store
     **/
    private void processPotentialValidationCheck(String validationMessage, Integer rowNumber) {
        if (String.isNotBlank(validationMessage)) {
            errorMessages.add(createError(rowNumber, validationMessage, false));
        }
    }

    /**
     * @description Takes the results from the upload and commits them as Process Flow Request Chunks
     * @param chunkId - The chunk # we are currently processing
     * @param totalChunks - The chunk # we are currently processing
     * @return BulkCorporateOnboardingWrappers.StoreValidationResult
     **/
    private BulkCorporateOnboardingWrappers.StoreValidationResult calculateOnboardingResults(
        Integer chunkId,
        Integer totalChunks
    ) {
        BulkCorporateOnboardingWrappers.StoreValidationResult bulkCorporateOnboardings = new BulkCorporateOnboardingWrappers.StoreValidationResult();
        bulkCorporateOnboardings.newRecords = newRecords;
        bulkCorporateOnboardings.errorMessages = errorMessages;
        bulkCorporateOnboardings.failedRuntimeValidations = !errorMessages.isEmpty(); // Tracks all errors we validate at runtime
        bulkCorporateOnboardings.storeWrappers = storeWrappers;
        bulkCorporateOnboardings = trialInsertStores(bulkCorporateOnboardings);
        bulkCorporateOnboardings.includesPaymentAccounts = includesPaymentAccounts;
        bulkCorporateOnboardings.includesDecisionMakers = includesDecisionMakers;
        bulkCorporateOnboardings.showPaymentAccountSkipOption = showPaymentAccountSkipOption;
        bulkCorporateOnboardings.isFinalChunk = (chunkId == totalChunks);
        bulkCorporateOnboardings.businessVerticalName = businessVerticalName;
        bulkCorporateOnboardings.businessVerticalId = businessVerticalId;
        bulkCorporateOnboardings.rowNumberToBrand = rowNumberToBrand;

        return bulkCorporateOnboardings;
    }

    /**
     * @description Takes a Static Resource file and puts the CSV data into this format: List<List<String>>
     * @param resourceName
     * @return List<List<String>>
     **/
    @SuppressWarnings('PMD.ApexCRUDViolation')
    public static List<List<String>> getCsvRowsFromResource(String resourceName) {
        StaticResource sr = [SELECT Body FROM StaticResource WHERE Name = :resourceName];
        Blob blobCSV = sr.Body;
        String csvString = blobCSV.toString();
        // Normalize line endings to Unix-style
        csvString = csvString.replace('\r\n', '\n').replace('\r', '\n');
        String[] rows = csvString.split('\n');
        List<List<String>> csvValues = new List<List<String>>();

        for (String row : rows) {
            // Trim to remove any trailing carriage return character
            String trimmedRow = row.trim();
            List<String> rowValues = trimmedRow.split(',');
            rowValues = parseCsvRow(rowValues);
            csvValues.add(rowValues);
        }

        return csvValues;
    }

    /**
     * @description Helper method to handle commas and quotes in CSV values
     * @param rowValues
     * @return List<String>
     **/
    private static List<String> parseCsvRow(List<String> rowValues) {
        List<String> parsedValues = new List<String>();
        String currentValue = '';
        Boolean insideQuotes = false;

        for (String val : rowValues) {
            if (val.startsWith('"') && val.endsWith('"')) {
                parsedValues.add(val.substring(1, val.length() - 1));
            } else if (val.startsWith('"')) {
                currentValue = val.substring(1) + ',';
                insideQuotes = true;
            } else if (val.endsWith('"') && insideQuotes) {
                currentValue += val.substring(0, val.length() - 1);
                parsedValues.add(currentValue);
                currentValue = '';
                insideQuotes = false;
            } else if (insideQuotes) {
                currentValue += val + ',';
            } else {
                parsedValues.add(val);
            }
        }
        return parsedValues;
    }

    /**
     * @description Takes a value from the CSV -- and the expected data type -- and safely converts it.
     *              This is needed to avoid null pointer exceptions from missing optional values.
     * @param value - Raw value validate
     * @param dataType - Data type of the string from the CSV
     * @return BulkCorporateOnboardingWrappers.StoreValidationResult
     **/
    @TestVisible
    private static Object safeConvert(String value, String dataType) {
        if (String.isBlank(value)) {
            return null;
        }
        try {
            if (dataType == DATATYPE_BOOLEAN) {
                return Boolean.valueOf(value);
            } else if (dataType == DATATYPE_DATE) {
                return Date.valueOf(value);
            } else if (dataType == DATATYPE_DATETIME) {
                return DateTime.valueOf(value);
            } else if (dataType == DATATYPE_DECIMAL) {
                return Decimal.valueOf(value);
            } else if (dataType == DATATYPE_INTEGER) {
                return Integer.valueOf(value);
            } else if (dataType == DATATYPE_STRING) {
                return value;
            } else {
                return null;
            }
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * @description get the reverse Map of CURRENCY_ISOCODE_TO_COUNTRY
     * @param currencyIsoCodeToCountry CURRENCY_ISOCODE_TO_COUNTRY Map
     * @return  Map<String, String> COUNTRY_TO_CURRENCY_ISOCODE Map
     **/
    @TestVisible
    private static Map<String, String> getReverseMap(Map<String, String> currencyIsoCodeToCountry) {
        Map<String, String> countryCodeToCurrencyIsoCode = new Map<String, String>();
        for (String currencyIsoCode : currencyIsoCodeToCountry.keySet()) {
            String countryCode = currencyIsoCodeToCountry.get(currencyIsoCode);
            countryCodeToCurrencyIsoCode.put(countryCode, currencyIsoCode);
        }
        return countryCodeToCurrencyIsoCode;
    }

    /**
     * @description Facade to build error messages without calling constructor everywhere
     * @param rowNumber
     * @param msg
     * @param warning
     * @return BulkCorporateOnboardingWrappers.ErrorMessage
     **/
    private static BulkCorporateOnboardingWrappers.ErrorMessage createError(
        Integer rowNumber,
        String msg,
        Boolean warning
    ) {
        if (warning == null) {
            warning = false;
        }

        return new BulkCorporateOnboardingWrappers.ErrorMessage(rowNumber, msg, warning);
    }
}