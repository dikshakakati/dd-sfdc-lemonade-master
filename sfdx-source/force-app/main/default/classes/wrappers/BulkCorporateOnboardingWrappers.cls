/**
 * @author BizApps
 * @date 31-August-2023
 * @description Class to consolidate Wrappers used in the Bulk Store Onboarding process and components.
**/
@SuppressWarnings('PMD.ExcessivePublicCount')
public class BulkCorporateOnboardingWrappers {
    /**
     * @description Returns consolidated information to the front-end, including the new Stores, the PFR, and file.
     **/
    public class CsvUploadResult {
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
        public CsvUploadResult(
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
     * @description Wrapper for storing information pertinent to the CSV validation/Readiness
     *              Check results that happen when an AO uploads a Store CSV.
    **/
    public class StoreValidationResult {
        @AuraEnabled public List<sObject> newRecords;
        @AuraEnabled public List<ErrorMessage> errorMessages;
        @AuraEnabled public Boolean includesPaymentAccounts;
        @AuraEnabled public Boolean includesDecisionMakers;
        @AuraEnabled public List<StoreInfo> storeWrappers;
        @AuraEnabled public Boolean showPaymentAccountSkipOption;
        @AuraEnabled public Boolean isFinalChunk;
        @AuraEnabled public Boolean saveFinished;
        @AuraEnabled public Boolean hasNonDuplicateErrors;
        @AuraEnabled public Boolean failedRuntimeValidations;
        @AuraEnabled public List<Integer> rowsToRemoveFromUpload;
        @AuraEnabled public String businessVerticalName;
        @AuraEnabled public Id businessVerticalId;
        @AuraEnabled public Map<Integer, String> rowNumberToBrand;

        /**
         * @description Initialize the variables with a parameter-less constructor
        **/
        public StoreValidationResult() {
            this.newRecords = new List<sObject>();
            this.errorMessages = new List<BulkCorporateOnboardingWrappers.ErrorMessage>();
            this.includesPaymentAccounts = false;
            this.includesDecisionMakers = false;
            this.storeWrappers = new List<StoreInfo>();
            this.showPaymentAccountSkipOption = true;
            this.isFinalChunk = false;
            this.saveFinished = false;
            this.hasNonDuplicateErrors = false;
            this.failedRuntimeValidations = false;
            this.rowsToRemoveFromUpload = new List<Integer>();
            this.businessVerticalName = '';
            this.rowNumberToBrand = new Map<Integer, String>();
        }
    }

    /**
     * @description Wrapper for storing Store information to be used later in the transaction,
     *              specifically during the linking of Decision Makers, Payment Accounts, etc.
    **/
    public class StoreInfo {
        @AuraEnabled
        public Id storeId;
        @AuraEnabled
        public Integer index;
        @AuraEnabled
        public Integer rowNumber;
        @AuraEnabled
        public Id paymentAccountId;
        @AuraEnabled
        public Id decisionMakerId;
        @AuraEnabled
        public Boolean isVerified;
        @AuraEnabled
        public Boolean isJobRun; // Formerly `isVerificationJobRun`
        @AuraEnabled
        public Boolean isJobComplete;
        @AuraEnabled
        public Boolean isPaRequired; // Formerly `isPaymentAccountRequired`
        @AuraEnabled
        public Boolean skipBatch;
        @AuraEnabled
        public DuplicateStoreAccountResult duplicateResults;

        /**
         * @description Constructor that intakes IDs of the Store, Payment Account, and DM Contact
         * @param storeId
         * @param paymentAccountId
         * @param decisionMakerId
         **/
        public StoreInfo(Id storeId, Id paymentAccountId, Id decisionMakerId) {
            this.storeId = storeId;
            this.paymentAccountId = paymentAccountId;
            this.decisionMakerId = decisionMakerId;
            this.isVerified = false;
            this.isJobRun = false;
            this.isJobComplete = false;
            this.isPaRequired = false;
            this.skipBatch = false;
            this.duplicateResults = new DuplicateStoreAccountResult();
        }

        /**
         * @description Constructor with an empty parameters list for light initialization
         **/
        public StoreInfo() {
            this.isVerified = false;
            this.isJobRun = false;
            this.isJobComplete = false;
            this.skipBatch = false;
            this.isPaRequired = false;
        }

        /**
         * @description Takes the `StoreInfo` object instance and serializes it into a highly-minified
         *              format with comma-delimited values and semi-colon-delimited rows. This is
         *              essential to comply with ANSO's strict storage limits and is possible due to
         *              the relatively simple data structure stored here.

                        ⚠️ ⚠️ WARNING ⚠️ ⚠️:
                        - This data is serialized and stored to fit within the constraints of a long text area field,
                          which has a direct impact on our ability to scale the number of stores we can process.
                        - The current operational commitment to the business is to support up to 2000 stores.
                        - DO NOT add properties to this serialization unless absolutely necessary. Any addition must be verified
                          to ensure support for 2000 stores in the worst-case data scenario.
                        - Modifications that reduce our capacity below 2000 stores will require a review and update of ANSO requirements.
                          Such changes must be thoroughly documented and validated with stakeholders.
         * @return String
        **/
        public String serialize() {
            return String.join(
                new List<String>{
                    trimIdTo15Digits(this.storeId),
                    String.valueOf(this.index),
                    trimIdTo15Digits(this.paymentAccountId),
                    trimIdTo15Digits(this.decisionMakerId),
                    convertBooleanToBinaryString(this.isJobComplete),
                    convertBooleanToBinaryString(this.skipBatch)
                },
                ','
            );
        }

        /**
         * @description Takes the `StoreInfo` object instance and serializes it into a highly-minified
         *              format with comma-delimited values and semi-colon-delimited rows. This is
         *              essential to comply with ANSO's strict storage limits and is possible due to
         *              the relatively simple data structure stored here.
         * @param serializedStr
         * @return StoreInfo
         **/
        public StoreInfo deserialize(String serializedStr) {
            if (String.isBlank(serializedStr)) {
                return new StoreInfo(null, null, null);
            }

            List<String> parts = serializedStr.split(',');
            this.storeId = String.isNotBlank(parts[0]) ? parts[0] : null;

            if (String.isNotBlank(parts[1])) {
                this.index = Integer.valueOf(parts[1]);
                this.rowNumber = this.index + 1;
            } else {
                this.index = null;
                this.rowNumber = null;
            }

            this.paymentAccountId = String.isNotBlank(parts[2]) ? parts[2] : null;
            this.decisionMakerId = String.isNotBlank(parts[3]) ? parts[3] : null;
            this.isJobComplete = parts[4] == '1';
            this.skipBatch = (parts.size() > 5 && parts[5] == '1') ? true : false;
            return this;
        }

        /**
         * @description Receives an ID and uses the 15-digit version in order to save space in the
         *              serialized data storage.
         * @param idWith18Digits
         * @return String
         **/
        private String trimIdTo15Digits(Id idWith18Digits) {
            if (idWith18Digits == null) {
                return '';
            }

            return String.valueOf(idWith18Digits).left(15);
        }

        /**
         * @description Receives true/false and converts to a `1` or `0` in order to save space in the
         *              serialized data storage.
         * @param thisBool
         * @return String
         **/
        private String convertBooleanToBinaryString(Boolean thisBool) {
            return thisBool == true ? '1' : '0';
        }
    }

    /**
     * @description Wrapper containing the `StoreInfo` details in addition to the `Account` record
     **/
    public class StoreInfoWithAccountRecord {
        @AuraEnabled
        public StoreInfo storeInfo;
        @AuraEnabled
        public Account storeAccount;

        /**
         * @description Constructor to initialize the wrapper
         * @param storeInfo
         * @param storeAccount
         */
        public StoreInfoWithAccountRecord(
            BulkCorporateOnboardingWrappers.StoreInfo storeInfo,
            Account storeAccount
        ) {
            this.storeInfo = storeInfo;
            this.storeAccount = storeAccount;
        }
    }

    /**
     * @description Indicates whether the Address API job ran for the Stores, and if it was successful.
    **/
    public class AddressVerificationResult {
        public Boolean successOnAllStores;
        public Boolean ranOnAllStores;
        public Boolean ranOnSomeStores;
        public List<StoreInfo> storeInfos;

        /**
         * @description Constructor to set default object state
        **/
        public AddressVerificationResult() {
            this.successOnAllStores = true;
            this.ranOnAllStores = true;
            this.ranOnSomeStores = false;
            this.storeInfos = new List<StoreInfo>();
        }
    }

    /**
     * @description Error message wrappers for when the store CSVs are uploaded
     **/
    public class ErrorMessage {
        @AuraEnabled public Integer rowNumber;
        @AuraEnabled public Integer displayRow;
        @AuraEnabled public String message;
        @AuraEnabled public String fullMessage;
        @AuraEnabled public Boolean isDuplicateWarning;
        @AuraEnabled public Boolean isWarning; // True for warnings, false for critical errors

        /**
         * @description Constructor to initialize the error message details
         * @param rowNum The row number in the CSV
         * @param msg The error message body
         * @param warning Whether this is a warning or critical error
         */
        public ErrorMessage(Integer rowNum, String msg, Boolean warning) {
            this.rowNumber = rowNum;
            this.displayRow = (rowNum != null) ? rowNum + 1 : null;
            this.message = msg;
            this.isDuplicateWarning = getIsDuplicateWarning();
            this.isWarning = warning == null ? isDuplicateWarning : warning; // Default to duplicate value; set if not duplicate
            this.fullMessage = constructFullMessage(rowNum, msg);
        }

        /**
         * @description Returns `true` if the Error is a Duplicate Record error message
         * @return Boolean
        **/
        private Boolean getIsDuplicateWarning() {
            return this.message == System.Label.Duplicate_Account_Error_Message;
        }

        /**
         * @description Constructs the full error message combining row number and message body
         * @param rowNum The row number in the CSV
         * @param msg The error message body
         * @return String The full constructed error message
         */
        private String constructFullMessage(Integer rowNum, String msg) {
            if (rowNum != null) {
                return 'Row ' + rowNum + ': ' + msg;
            } else {
                return msg;
            }
        }
    }

    /**
     * @description It is used to capture the match Account Ids from the existing data.
     **/
    public class DuplicateStoreAccountResult {
        @AuraEnabled public List<Id> matchAccountIds;

        /**
         * @description Constructor to initiliaze the variables.
        **/
        public DuplicateStoreAccountResult() {
            this.matchAccountIds = new List<Id>();
        }
    }

    /**
     * @description Contains details on Store error statuses ahead of the final batch
    **/
    public class StoreVerificationStatus {
        @AuraEnabled public Boolean allStoresVerified;
        @AuraEnabled public Boolean allStoresPassed;
        @AuraEnabled public Boolean allStoresFailed;
        @AuraEnabled public Boolean someStoresNotVerified;
        @AuraEnabled public Boolean requiresCanadianDetails;
        @AuraEnabled public Integer totalStores;
        @AuraEnabled public List<Account> failedStores;
        @AuraEnabled public List<Account> storesNotRun;
        @AuraEnabled public Boolean hasAddressIssues;
        @AuraEnabled public List<Account> storesRequiringAdditionalInformation;
        @AuraEnabled public Map<String, Contact> businessContacts;

        /**
         * @description Constructor to initiliaze the variables
        **/
        public StoreVerificationStatus() {
            this.allStoresVerified = false;
            this.allStoresPassed = false;
            this.allStoresFailed = false;
            this.someStoresNotVerified = false;
            this.requiresCanadianDetails = false;
            this.totalStores = 0;
            this.failedStores = new List<Account>();
            this.storesNotRun = new List<Account>();
            this.hasAddressIssues = false;
            this.storesRequiringAdditionalInformation = new List<Account>();
            this.businessContacts = new Map<String, Contact>();
        }
    }

    /**
     * @description Contains details on performance matrics of the batch
    **/
    public class StoreProcessingMetrics {
        @AuraEnabled public Integer maxCpuTime;
        @AuraEnabled public Integer maxHeapSize;
        @AuraEnabled public Integer maxDmlStatements;
        @AuraEnabled public Integer maxSoqlQueries;
        @AuraEnabled public Integer storesProcessed;
        @AuraEnabled public Integer storesFailed;

        /**
         * @description Constructor to initiliaze the variables
        **/
        public StoreProcessingMetrics() {
            this.maxCpuTime = 0;
            this.maxHeapSize = 0;
            this.maxDmlStatements = 0;
            this.maxSoqlQueries = 0;
            this.storesProcessed = 0;
            this.storesFailed = 0;
        }
    }

    /**
     * @description Return result from the Multi-Select flow which communicates to the LWC that all
     *              selections have been made.
     **/
    public class RelatedRecordCompletionInfo {
        @AuraEnabled
        public Process_Flow_Request__c flowRequest;
        @AuraEnabled
        public Boolean isComplete;

        /**
         * @description Constructor for initializing wrapper values
         **/
        public RelatedRecordCompletionInfo() {
            this.isComplete = false;
        }
    }
}