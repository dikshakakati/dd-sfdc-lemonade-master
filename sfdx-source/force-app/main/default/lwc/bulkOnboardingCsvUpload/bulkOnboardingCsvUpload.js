import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import finishUploadSave from "@salesforce/apex/BulkCorporateOnboardingRequestCtrl.processStoreUploadData";
import uploadCsvChunks from "@salesforce/apex/BulkCorporateOnboardingRequestCtrl.uploadFileRows";
import getNumberOfChunks from "@salesforce/apex/BulkCorporateOnboardingRequestCtrl.retrieveNumberOfCompletedChunksForRequest";
import createLog from "@salesforce/apex/LogController.createLog";
import getMatchingAccountsDetails from "@salesforce/apex/BulkCorporateOnboardingRequestCtrl.getMatchingAccountsDetails";
import getTemplateFieldsInformation from "@salesforce/apex/BulkCorporateOnboardingRequestCtrl.getTemplateFieldsInformation";
import getIsProduction from "@salesforce/apex/BulkCorporateOnboardingRequestCtrl.getIsProduction";
import getIsLaunchOperationsUser from "@salesforce/apex/BulkCorporateOnboardingRequestCtrl.getIsLaunchOperationsUser";
import getAllSubscriptionFromContract from "@salesforce/apex/BulkCorporateOnboardingEntitlementCtrl.getAllSubscriptionFromContract";
import saveEntitlementsSelectionDeselection from "@salesforce/apex/BulkCorporateOnboardingEntitlementCtrl.saveEntitlementsSelectionDeselection";
import { getEntitlementSelectionDeselectionWhenCCPSkipped } from "c/ccpUtils";
import csvTemplateStoragePlatform from "@salesforce/label/c.Bulk_Store_CSV_Storage_Platform";
import csvTemplateLink from "@salesforce/label/c.Bulk_Store_CSV_Template_Link";
import csvSandboxTemplateLink from "@salesforce/label/c.Bulk_Store_CSV_Sandbox_Template_Link";
import csvExampleLink from "@salesforce/label/c.Bulk_Store_CSV_Example_Link";
import DUPLICATE_ACCOUNT_ERROR_MESSAGE from "@salesforce/label/c.Duplicate_Account_Error_Message";
import CSV_TEMPLATE_URL from "@salesforce/resourceUrl/Bulk_Store_Upload_CSV_Template";

const CHUNK_SIZE = 50;
const CHUNKS_PER_TRANSACTION = 2;
const BULK_RUN_INITIAL_BATCH_SIZE = 12; // # of our store batches SFDC executes simultaneously initially
const BULK_RUN_APPROX_INITIAL_BATCH_TIME = 10000; // milliseconds for the initial batch
const BULK_RUN_APPROX_THROTTLED_INTERVAL = 21000; // milliseconds for each subsequent batch

const STARTING_BRACKET = "(";
const CLOSING_BRACKET = ")";
const COMMA = ",";
const MAXIMUM_STORES_FOR_LAUNCH_OPS = 2000;
const MAXIMUM_STORES_FOR_ALL_USERS = 10;
const GENERIC_ERROR_HEADER = "Errors were encountered while processing the CSV";
const ERROR_MESSAGE_MUST_INCLUDE_ONE_STORE =
  "You must include at least one Store.";
const ERROR_MESSAGE_MAX_SIZE_EXCEEDED_ALL_USER = `You can upload a maximum of ${MAXIMUM_STORES_FOR_ALL_USERS} Stores at a time.`;
const ERROR_MESSAGE_MAX_SIZE_EXCEEDED_LAUNCH_OPS = `File size exceeded. Launch Ops users can upload up to ${MAXIMUM_STORES_FOR_LAUNCH_OPS} Stores. For normal users, the limit is ${MAXIMUM_STORES_FOR_ALL_USERS} Stores per upload.`;
const ERROR_MESSAGE_TOAST_TITLE = "Error Processing Stores";
const ERROR_MESSAGE_TITLE_FINISHED = "Upload Unsuccessful";
const ERROR_MESSAGE_FINISHED = "Your Stores CSV file contains some errors. Please address the following issues and try again:";
const ERROR_MESSAGE_TITLE_IN_PROGRESS = "Upload In Progress - Errors Detected";
const ERROR_MESSAGE_IN_PROGRESS = "Your CSV file is currently being processed, and some issues have been detected. The below issues have been detected so far. A link to refresh this list may appear in the upper right as new issues are detected.";
const ERROR_MESSAGE_SHOW_ERRORS_LINK = "Your CSV file is currently being processed, and some issues have been detected. You can preview these errors now by clicking the 'Show Errors' link, or wait until the upload completes to review all issues.";
const SAVING_MSG_VALIDATING_FILE = "Uploading and validating file. Please wait...";
const SAVING_MSG_INSERTING_STORES = "Completing store insertion. Please wait and do not close this window...";

const LWC_NAME = "bulkOnboardingCsvUpload";
const GET_EXISTING_ACCOUNTS = "getMatchingAccountsDetails";
const GET_ALL_SUBSCRIPTIONS = "getAllSubscriptionFromContract";
const SAVE_ENTITLEMENT_METHOD_NAME =
  "saveEntitlementsSelectionDeselectiononPFR";
const VALIDATION_MESSAGE_BASE =
  "An error occurred while uploading Stores. Please see below:";
const ERROR_MESSAGE_BASE =
  "An error occurred while processing the Store upload. Please try again.";
const UNKNOWN_ERROR_MESSAGE =
  "If the problem persists, please contact an administrator for assistance.";
const RELATIONSHIP_FIELDS_EXAMPLE = [
  {
    fieldLabel: "ParentId",
    objectLabel: "Account",
    exampleId: "0017600000ZuxpWAAR"
  },
  {
    fieldLabel: "Decision Maker",
    objectLabel: "Contact",
    exampleId: "0037600000Umx2oAAB"
  },
  {
    fieldLabel: "Payment Account",
    objectLabel: "Payment Account",
    exampleId: "a3e760000004aM2AAI"
  }
];

export default class BulkOnboardingCsvUpload extends LightningElement {
  csvExampleUrl = csvExampleLink;
  storagePlatformName = csvTemplateStoragePlatform;
  csvTemplateStaticResourceUrl = CSV_TEMPLATE_URL;
  isProduction = true;
  isLaunchOps = false;
  isLargeUpload = false;
  launchOpsMaxUploadSize = MAXIMUM_STORES_FOR_LAUNCH_OPS;
  allUsersMaxUploadSize = MAXIMUM_STORES_FOR_ALL_USERS;
  showOngoingErrorsMessage = ERROR_MESSAGE_SHOW_ERRORS_LINK;
  showSpinner = true;
  hasNotFinishedDuplicateSelections = true;

  @api flowRequestId;
  flowRequestObj;
  @api contractId;
  @api hasValidFile;
  bulkOnboardingContainer = null;
  bulkOnboardingReturnWrapper = null;
  bulkOnboardingResultChunks = {};
  duplicatesToRemoveFromInsertion = [];
  duplicatesToForceInsertion = [];
  contentVersionId = null;
  totalChunks = 0;
  finishedChunks = 0;
  uploadedValidFile;

  _currentStep; // For currentStep string value

  isUploading = false;
  @track showSelectEntitlementScreen = false;
  @track isInstructionsVisible = false;
  @track isTemplateVisible = false;
  @track isUploadButtonHidden = false;
  @track isNextDisabled = true;
  @track hasUploadedValidFile = false;
  @track showErrorMessages = false;
  @track errorMessages = [];
  @track pendingErrorMessages = [];
  @track warnings = []; // For duplicate warnings, etc.
  @track showRefreshErrorsLink = false;
  @track displayShowErrorsLink = false;
  @track potentialDuplicatesList = [];
  @track renderDuplicates = false;
  @track indexWithPotentialAccountMatchIds = new Map();
  @track selectedRowNumber;
  @track selectedRowName;
  @track allStoresFromFileRemoved = false;
  @track millisecondsRemaining;
  @track percentageCompleted;
  @track showPercentageLoader;
  @track savingStoresMessage;
  acceptedValues = [];
  requiredFields = [];
  relationshipFields = RELATIONSHIP_FIELDS_EXAMPLE;
  showPaymentAccountSkipOption = false;
  showBrandCountTable = false;
  businessVerticalName;
  businessVerticalId;
  rowNumberToBrand = [];
  brandToStoreCount = [];
  processStartTime;
  percentageCalculationTimeout;

  connectedCallback() {
    this.loadTemplateInformation();
    this.loadEnvironmentInformation();
    this.loadUserPermissions();
    this.uploadedValidFile = this.hasValidFile;
    this.isNextDisabled = this.uploadedValidFile ? false : true;
  }

  get acceptedFormats() {
    return [".csv"];
  }

  // @api setter for currentStep
  @api
  set currentStep(value) {
    this._currentStep = value ? value.toString() : "1"; // convert to string and store in private property
  }

  // getter for currentStep
  get currentStep() {
    return this._currentStep; // return the private property value
  }

  handleFileUpload(event) {
    this.processStartTime = performance.now();
    this.bulkOnboardingResultChunks = {};
    this.isUploading = true;
    this.isUploadButtonHidden = true;
    this.showErrorMessages = false;
    this.hasNotFinishedDuplicateSelections = true;
    this.errorMessages = []; // Reset the error messages when the file is uploaded
    this.pendingErrorMessages = [];
    this.rowNumberToBrand = [];
    this.duplicatesToRemoveFromInsertion = [];
    this.duplicatesToForceInsertion = [];
    this.totalChunks = 0;
    this.finishedChunks = 0;

    const file = event.target.files[0];
    const reader = new FileReader();

    reader.onload = () => {
      try {
        // All checks should be MAX_LENGTH + 1 to account for the header
        const lines = this.csvParse(atob(btoa(reader.result)).split("\n"));
        const header = lines[0]; // Save the header row
        this.totalChunks = Math.ceil((lines.length - 1) / CHUNK_SIZE); // Exclude header row from count
        this.isLargeUpload = this.totalChunks > 1;
        this.showPercentageLoader = this.isLargeUpload;
        this.savingStoresMessage = SAVING_MSG_VALIDATING_FILE;
        this.percentageCompleted = 0;

        if (lines.length <= 1) {
          this.errorMessages.push(this.buildError(null, ERROR_MESSAGE_MUST_INCLUDE_ONE_STORE, false));
        } else if (
          this.isLaunchOps &&
          lines.length > MAXIMUM_STORES_FOR_LAUNCH_OPS + 1
        ) {
          this.errorMessages.push(this.buildError(null, ERROR_MESSAGE_MAX_SIZE_EXCEEDED_LAUNCH_OPS, false));
        } else if (
          !this.isLaunchOps &&
          lines.length > MAXIMUM_STORES_FOR_ALL_USERS + 1
        ) {
          this.errorMessages.push(this.buildError(null, ERROR_MESSAGE_MAX_SIZE_EXCEEDED_ALL_USER, false));
        }

        // Only throw an error if there are error messages to display
        if (this.errorMessages.length > 0) {
          throw new Error(GENERIC_ERROR_HEADER);
        }

        this.calculateCompletionPercentage();

        for (let i = 0; i < this.totalChunks; i++) {
          const start = i * CHUNK_SIZE + 1; // Skip the header row
          const end = start + CHUNK_SIZE;
          const chunkLines = lines.slice(start, end);
          chunkLines.unshift(header);

          chunkLines.map((row) => {
            return row.map((field) => `"${field}"`);
          });

          const chunkLinesStr = JSON.stringify(chunkLines).replace(/\\r/g, "");
          const base64Str = btoa(chunkLinesStr);
          this.callApexToInsertFile(base64Str, i + 1);
        }
      } catch (error) {
        this.handleUploadError(error);
      }
    };

    reader.readAsBinaryString(file);
  }

  callApexToInsertFile(base64Str, chunkId) {
    uploadCsvChunks({
      csvRowsStr: base64Str,
      flowRequestId: this.flowRequestId,
      chunkId: chunkId,
      totalChunks: this.totalChunks
    })
      .then((result) => {
        this.bulkOnboardingResultChunks[chunkId] = result.results;
        this.finishedChunks++;

        // There is a possibility that the the APEX finishes processing an earlier chunk AFTER a later chunk,
        // so we cannot strictly rely on the `chunkId === this.totalChunks` check. We should instead make sure that
        // we have ALL the chunk values back in our aggregate object.
        if (
          Object.keys(this.bulkOnboardingResultChunks).length ===
          this.totalChunks
        ) {
          this.finishedChunks = this.totalChunks;
          this.calculateCompletionPercentage(); // Final update to ensure 100% completion is shown
          clearTimeout(this.percentageCalculationTimeout);

          this.consolidateResultChunks();
          this.contentVersionId =
            this.bulkOnboardingReturnWrapper.contentVersionId; // TODO - Do we need this?

          if (this.errorMessages.length > 0) {
            // Throw an error to go into the catch block
            throw new Error(GENERIC_ERROR_HEADER);
          } else {
            this.showBrandCountTable = true;
            this.isUploading = false;
          }
        } else if(this.isLargeUpload) {
          this.populateErrorsInAdvance();
        }
      })
      .catch((error) => {
        this.handleUploadError(error);
      });
  }

  // This method calculates the approximate percentage complete and time remaining for Launch Ops bulk insert scenarios.
  // It is designed to address the complexities of bulk processing where Salesforce initially processes a set of batches simultaneously
  // (defined by BULK_RUN_INITIAL_BATCH_SIZE) and then throttles subsequent batches.
  // This non-linear progression makes it challenging to estimate progress and time remaining using simple linear calculations.
  // Therefore, this method combines the elapsed time with the number of transactions completed to provide a more accurate progress estimation.
  // The initial fast processing of batches is factored into the time calculations to adjust the progress and time estimates after the first few batches.
  // The method dynamically adjusts the time remaining based on actual progress:
  // - Before all initial batches are processed, it uses time-based calculations.
  // - After the initial batches, it checks the actual number of chunks completed to recalibrate the time and progress estimates.
  // This method does not apply to non-bulk scenarios (less than 50 stores inserted), where there is a single batch of stores and we do
  // not need to show a percentage completed/time elapsed indicator.
  async calculateCompletionPercentage() {
      if(!this.isLargeUpload) {
        return;
      }

      const elapsedTime = performance.now() - this.processStartTime; // Current elapsed time
      let chunksProcessed = this.finishedChunks;
      let initialEstimateTotalTime = BULK_RUN_APPROX_INITIAL_BATCH_TIME + (this.totalChunks - BULK_RUN_INITIAL_BATCH_SIZE) * BULK_RUN_APPROX_THROTTLED_INTERVAL; // 10000 + (50 - 12) * 21000
      let isFinished = this.finishedChunks >= this.totalChunks;

      // Dynamic time estimation based on actual progress
      if (chunksProcessed < BULK_RUN_INITIAL_BATCH_SIZE) {
          this.millisecondsRemaining = initialEstimateTotalTime - elapsedTime;
          let percentageFromTime = (elapsedTime / initialEstimateTotalTime) * 100;
          let percentageFromChunksCompleted = (chunksProcessed / this.totalChunks) * 100;
          let percentageToUse = Math.max(percentageFromTime, percentageFromChunksCompleted);
          this.percentageCompleted = Math.round(percentageToUse); // Ensuring the chunksProcessed does not exceed totalChunks
          this.runCompletionRecalculation(3000, isFinished);
      } else {
          try {
            let result = await getNumberOfChunks({
                flowRequestId: this.flowRequestId,
                countOnlyCompleted: false
            });

            this.finishedChunks = result;
            chunksProcessed = this.finishedChunks;

            // Adjusted calculations for elapsed time and remaining time
            let adjustedElapsedTime = elapsedTime - BULK_RUN_APPROX_INITIAL_BATCH_TIME;
            let adjustedChunks = chunksProcessed - BULK_RUN_INITIAL_BATCH_SIZE;

            // This is the transition point in the calculation. Here, if we don't have any newly
            // processed chunks, the time remaining may incorrectly compute to some large number
            // (like JavaScript's `Infinity` value), so we have to wait until we have processed data
            // chunks to correctly compute the remaining time.
            if (adjustedChunks === 0) {
                this.runCompletionRecalculation(15000, isFinished);
                return;
            }

            let averageTimePerBatch = adjustedElapsedTime / adjustedChunks;
            let estimatedTimeForRemainingBatches = averageTimePerBatch * (this.totalChunks - chunksProcessed);
            this.millisecondsRemaining = estimatedTimeForRemainingBatches;

            // Console log statements and final calculations...
            this.percentageCompleted = Math.round((Math.min(chunksProcessed, this.totalChunks) / this.totalChunks) * 100);
            console.log(`Percentage completed: ${this.percentageCompleted.toFixed(2)}%. About ${Math.floor(this.millisecondsRemaining / 60000)} minutes and ${Math.floor((this.millisecondsRemaining % 60000) / 1000)} seconds remaining...`);

            this.runCompletionRecalculation(15000, isFinished);

          } catch (error) {
              console.error(error);
          }
      }
  }

  // Sets a timeout interval to re-poll the completion status - for bulk, multi-transactional uploads only
  runCompletionRecalculation(interval, isComplete) {
      if(isComplete) {
          clearTimeout(this.percentageCalculationTimeout);
          return;
      }

      this.percentageCalculationTimeout = setTimeout(() => {
          this.calculateCompletionPercentage();
      }, interval); // Poll again for a later update
  }

  // In the event that errors are accessed and viewed before completion, if the system detects
  // new entries to the errors table, a "Refresh Errors List" link will appear that will display
  // the new errors. This is generally preferable to updating the list automatically, since the
  // errors do not generate sequentially and repopulating the list could cause issues
  clickRefreshErrorsListWithUpdates() {
      this.errorMessages = this.pendingErrorMessages;
      this.pendingErrorMessages = [];
      this.showRefreshErrorsLink = false;
  }

  // Handler for the "Show Errors" link where users can preview the errors in advance for bulk uploads
  clickShowAdvanceErrors() {
      this.showErrorMessages = true;
      this.displayShowErrorsLink = false;
  }

  // Handler for the "Hide Errors" link where users can dismiss the advance errors for bulk uploads
  clickHideAdvanceErrors() {
      this.showErrorMessages = false;
      this.displayShowErrorsLink = true;
      this.populateErrorsInAdvance();
      this.clickRefreshErrorsListWithUpdates(); // Reset the errors behind the scenes when not in view
  }

  // Populates the `errorMessages` array even before upload completion. This is so the users can see the
  // error messages while the CSV is still validating, reducing their wait time. This applies only for
  // large, multi-transactional uploads ("Launch Ops").
  populateErrorsInAdvance() {
    this.pendingErrorMessages = [];

    for (let i = 1; i <= this.totalChunks; i++) {
      // All the chunks won't necessarily exist yet in the map so we need to do this check.
      if (Object.prototype.hasOwnProperty.call(this.bulkOnboardingResultChunks, i)) {

        const currentResultChunk = this.bulkOnboardingResultChunks[i];

        if(currentResultChunk && currentResultChunk.errorMessages) {
          this.pendingErrorMessages.push(
            ...currentResultChunk.errorMessages
          );
        }
      }
    }

    this.pendingErrorMessages = this.transformErrorsArray(this.pendingErrorMessages);

    // If we don't have errors yet, then display the existing errors
    if(!this.errorMessages || !this.errorMessages.length) {
      this.showRefreshErrorsLink = false;
      this.errorMessages = this.pendingErrorMessages;
      this.pendingErrorMessages = [];
    } else {
      this.showRefreshErrorsLink = this.errorMessages.length !== this.pendingErrorMessages.length;
    }

    // Show the "Show Errors" link if there are errors and we are not already looking at them!
    this.displayShowErrorsLink = !this.showErrorMessages && !!this.errorMessages.length;
    this.errorMessageTitle = ERROR_MESSAGE_TITLE_IN_PROGRESS;
    this.errorMessageText = ERROR_MESSAGE_IN_PROGRESS;
}

  clickConfirmBrandStoreCount() {
    this.showBrandCountTable = false;
    this.isUploading = true;
    this.initSaveProgressVariables();
    this.handleFinishUploadSave();
  }

  clickCancelBrandStoreCount() {
    this.showSpinner = false;
    this.uploadedValidFile = false;
    this.showBrandCountTable = false;
    this.isUploadButtonHidden = false;
    this.renderDuplicates = false;
    this.isUploading = false;
    this.showPercentageLoader = false;
  }

  // Resets the saving variables in the middle of the save transaction in between file validation
  // and clicking the "Confirm" button to complete the upload.
  initSaveProgressVariables() {
      this.showPercentageLoader = false; // No need to show this on the second half of the upload
      this.savingStoresMessage = SAVING_MSG_INSERTING_STORES;
      this.percentageCompleted = 0; // Set back to 0 for this upload
      this.millisecondsRemaining = null;
      this.processStartTime = performance.now();
  }

  // Finishes the upload process when there are no validation errors
  // Uses recursion to process all the chunks
  handleFinishUploadSave(currentChunk = 1) {
    if (currentChunk > this.totalChunks) {
      // All chunks have been processed
      const msgTitle = "Stores CSV Validated Successfully";
      const msgBody =
        "The Stores CSV file has been verified and prepared for upload.";

      this.handleUploadFinished(msgTitle, msgBody, false);
      // You might want to dispatch an event or execute callback here
      return;
    }

    // Prepare the string input for the chunks that are about to be processed
    // let chunksToProcess = Math.min(CHUNKS_PER_TRANSACTION, this.totalChunks - currentChunk + 1);
    let containerToPass = this.bulkOnboardingContainer;
    containerToPass.newRecords = []; // These cause deserialization problems and we do not need them
    let resultsStringInput = JSON.stringify(containerToPass);

    finishUploadSave({
      flowRequestId: this.flowRequestId,
      resultsStr: resultsStringInput,
      chunksToProcess: CHUNKS_PER_TRANSACTION
    })
      .then((result) => {
        this.flowRequestObj = result;

        // Every transaction, we update the `Serialized_Object_Data__c` with the Account IDs from the newly-inserted Stores
        // Persist those here so they get passed back to the save method
        let storeInfosFromRecord = JSON.parse(result.Serialized_Object_Data__c);
        this.bulkOnboardingContainer.storeWrappers = storeInfosFromRecord;

        // Process next set of chunks
        this.handleFinishUploadSave(currentChunk + CHUNKS_PER_TRANSACTION);
      })
      .catch((error) => {
        this.handleUploadError(error);
      });
  }

  consolidateResultChunks() {
    this.bulkOnboardingReturnWrapper = {
      results: {
        newRecords: [],
        errorMessages: [],
        storeWrappers: [],
        rowsToRemoveFromUpload: []
      }
    }; // Reset this to its original state
    this.errorMessages = [];
    let hasNonDuplicateErrors = false;

    for (let i = 1; i <= this.totalChunks; i++) {
      const currentResultChunk = this.bulkOnboardingResultChunks[i];

      this.bulkOnboardingReturnWrapper.results.newRecords.push(
        ...currentResultChunk.newRecords
      );
      this.bulkOnboardingReturnWrapper.results.errorMessages.push(
        ...currentResultChunk.errorMessages
      );
      this.bulkOnboardingReturnWrapper.results.storeWrappers.push(
        ...currentResultChunk.storeWrappers
      );

      this.rowNumberToBrand = this.rowNumberToBrand.concat(
          Object.entries(currentResultChunk.rowNumberToBrand).map(([key, value]) => ({ key, value }))
      );

      for (
        let j = 0;
        j < this.bulkOnboardingReturnWrapper.results.newRecords.length;
        j++
      ) {
        let thisAccountSObject =
          this.bulkOnboardingReturnWrapper.results.newRecords[j];
        this.bulkOnboardingReturnWrapper.results.storeWrappers[j].storeId =
          thisAccountSObject.Id;
      }

      if (currentResultChunk.hasNonDuplicateErrors) {
        hasNonDuplicateErrors = true;
      }

      currentResultChunk.storeWrappers.forEach((item) => {
        if (item.duplicateResults) {
          this.indexWithPotentialAccountMatchIds.set(
            item.rowNumber,
            item.duplicateResults.matchAccountIds
          );
        }
      });

      if (
        currentResultChunk.showPaymentAccountSkipOption &&
        !this.showPaymentAccountSkipOption
      ) {
        this.showPaymentAccountSkipOption = true;
      }

      if (i === this.totalChunks) {
        // Set the arrays on the Result object
        this.bulkOnboardingReturnWrapper.contentVersionId =
          currentResultChunk.contentVersionId;
        this.bulkOnboardingReturnWrapper.flowRequestObj =
          currentResultChunk.flowRequestObj;
        this.errorMessages =
          this.bulkOnboardingReturnWrapper.results.errorMessages;
        this.bulkOnboardingReturnWrapper.results.includesPaymentAccounts =
          currentResultChunk.includesPaymentAccounts;
        this.bulkOnboardingReturnWrapper.results.includesDecisionMakers =
          currentResultChunk.includesDecisionMakers;
        this.bulkOnboardingReturnWrapper.results.hasNonDuplicateErrors =
          hasNonDuplicateErrors;
        this.businessVerticalName = currentResultChunk.businessVerticalName;
        this.businessVerticalId = currentResultChunk.businessVerticalId;
      }
    }

    this.brandToStoreCount = this.populateStoreBrandTable(this.rowNumberToBrand);
    this.bulkOnboardingContainer = this.bulkOnboardingReturnWrapper.results;
  }

  clickFinishUpload() {
    this.renderDuplicates = false;
    this.showErrorMessages = false;
    this.isUploading = true;
    this.brandToStoreCount = this.populateStoreBrandTable(this.rowNumberToBrand);
    this.showBrandCountTable = true;
  }

  handleUploadFinished(msgTitle, msgBody, isError) {
    this.showPercentageLoader = false;
    this.bulkLoadingMessage = null;
    this.percentageCompleted = 0;
    this.isUploading = false;
    this.displayShowErrorsLink = false;
    this.uploadedValidFile = !isError;

    this.updateHiddenStatus();
    this.updateIsNextDisabled();

    if (isError) {
      this.showToast(msgTitle, msgBody, true);
    }
  }

  handleUploadError(error) {
    console.error(error);

    this.addPageMessagesToErrorsTable(error);

    this.errorMessages = this.transformErrorsArray(this.errorMessages);
    this.errorMessageTitle = ERROR_MESSAGE_TITLE_FINISHED;
    this.errorMessageText = ERROR_MESSAGE_FINISHED;

    let toastErrorMsg;

    if (this.errorMessages && this.errorMessages.length > 0) {
      this.showErrorMessages = true; // Show error messages table for CSV errors
      toastErrorMsg = VALIDATION_MESSAGE_BASE;
    } else if (error.body && error.body.message) {
      toastErrorMsg = `${ERROR_MESSAGE_BASE} Error message: ${error.body.message}`;
    } else {
      toastErrorMsg = `${ERROR_MESSAGE_BASE} ${UNKNOWN_ERROR_MESSAGE}`;
    }

    this.handleUploadFinished(ERROR_MESSAGE_TOAST_TITLE, toastErrorMsg, true);
  }

  handleNextandSkipCCP() {
    this.showSpinner = true;
    let finalData;
    getAllSubscriptionFromContract({ contractId: this.contractId })
      .then((result) => {
        finalData = getEntitlementSelectionDeselectionWhenCCPSkipped(
          result !== null ? result : null,
          this.flowRequestId,
          this.contractId
        );

        if (finalData !== undefined) {
          saveEntitlementsSelectionDeselection({
            mapofSelectDeselect:
              finalData == null ? null : JSON.stringify(finalData),
            flowRequestId: this.flowRequestId,
            contractId: this.contractId,
            isManagePackageSelected: false,
            ccpApplied: false
          })
            .then((response) => {
              this.dispatchEvent(
                new CustomEvent("handleuploadnext", {
                  detail: {
                    flowRequestValue: response,
                    skipStepValue: this.showPaymentAccountSkipOption
                  }
                })
              );
            })
            .catch((error) => {
              createLog({
                lwcName: LWC_NAME,
                methodName: SAVE_ENTITLEMENT_METHOD_NAME,
                message: JSON.stringify(error.body)
              });
            });
        }
      })
      .catch((error) => {
        console.log(error);
        createLog({
          lwcName: LWC_NAME,
          methodName: GET_ALL_SUBSCRIPTIONS,
          message: JSON.stringify(error.body)
        });
      });
  }

  loadTemplateInformation() {
    getTemplateFieldsInformation()
      .then((result) => {
        this.requiredFields = result.requiredFieldLabels;

        // Convert the retrieved values to the right format with the long and short versions of each string
        this.acceptedValues = result.picklistValues.map((fieldInfo) => {
          const isLongString = fieldInfo.valuesString.length > 200;
          return {
            ...fieldInfo,
            isLongString,
            valuesStringTruncated: isLongString
              ? fieldInfo.valuesString.substring(0, 200)
              : fieldInfo.valuesString,
            toggleSeeMore: () => {
              // Implement your toggle logic here
              // This can be used to toggle between showing the truncated vs full string
              this.acceptedValues = this.acceptedValues.map((item) => {
                if (item.fieldLabel === fieldInfo.fieldLabel) {
                  item.isLongString = !item.isLongString;
                }
                return item;
              });
            }
          };
        });
      })
      .catch((error) => {
        console.error("Error loading accepted values: ", error);
      });
  }

  loadEnvironmentInformation() {
    getIsProduction()
      .then((result) => {
        this.isProduction = result;
      })
      .catch((error) => {
        // Default to production template in case of issues
        this.isProduction = true;
        console.error(error);
      })
      .finally(() => {
        this.setTemplateLinks();
      });
  }

  loadUserPermissions() {
    getIsLaunchOperationsUser()
      .then((result) => {
        this.isLaunchOps = result;
      })
      .catch((error) => {
        console.error(error);
        this.isLaunchOps = false;
      })
      .finally(() => {
        this.showSpinner = false;
      });
  }

  setTemplateLinks() {
    this.csvTemplateUrl = this.isProduction
      ? csvTemplateLink
      : csvSandboxTemplateLink;
  }

  /**
   * @description To get display row by adding 1 in row attribute.
   * @param currentRow
   */
  getDisplayRow(currentRow) {
    let displayRow = parseInt(currentRow, 10) + 1;
    let rows = [];
    if (currentRow.includes(COMMA)) {
      currentRow = currentRow.replace(STARTING_BRACKET, "").trim();
      currentRow = currentRow.replace(CLOSING_BRACKET, "").trim();
      currentRow.split(COMMA).forEach((eachRow) => {
        rows.push(parseInt(eachRow, 10) + 1);
      });
      displayRow = rows.toString();
    }
    return displayRow;
  }

  transformErrorsArray(errorsList) {
    let formattedCriticalErrors = [];
    let formattedWarnings = [];
    let errorsCount = 0;

    if(errorsList.length) {
      errorsList.forEach((error) => {
        if(!error.isWarning) {
          formattedCriticalErrors.push(this.formatError(error, errorsCount));
        } else {
          formattedWarnings.push(this.formatError(error, errorsCount));
        }

        errorsCount++;
      });

      return [...formattedCriticalErrors, ...formattedWarnings];
    }

    return [];
  }

  buildError(row, message, isWarning) {
    let displayNumber;

    if(row != null && !isNaN(row)) {
      displayNumber = row + 1;
    }

    return {
      displayRow: displayNumber,
      rowNumber: row,
      message: message,
      isWarning: isWarning
    }
  }

  formatError(thisError, errorsCount) {
    let formattedError = {};
    formattedError.id = errorsCount;
    formattedError.displayRow = (thisError.displayRow || thisError.displayRow === 0) ? thisError.displayRow : "N/A";
    formattedError.rowNumber = (thisError.rowNumber || thisError.rowNumber === 0) ? thisError.rowNumber : "N/A";
    formattedError.message = thisError.message;
    formattedError.isWarning = thisError.isWarning;
    formattedError.isDuplicateAccount = !thisError.isDuplicateWarning ? false : thisError.isDuplicateWarning;
    formattedError.duplicateSelectionInfo = {
        hasMadeSelection: false,
        shouldInsert: false,
        shouldRemoveFromUpload: false
    };

    return formattedError;
  }

  addPageMessagesToErrorsTable(error) {
    if (
      error &&
      error.body &&
      error.body.pageErrors &&
      error.body.pageErrors.length
    ) {
      error.body.pageErrors.forEach((currentError) => {
        this.errorMessages.push(currentError.message);
      });
    }
  }

  downloadTemplate() {
    window.location.href = this.csvTemplateStaticResourceUrl;
  }

  openTemplateLink(event) {
    event.preventDefault();
    window.open(this.csvTemplateUrl);
  }

  openExampleLink(event) {
    event.preventDefault();
    window.open(this.csvExampleUrl);
  }

  showToast(title, message, isError) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: title,
        message: message,
        variant: isError ? "error" : "success"
      })
    );
  }

  csvParse(lines) {
    const chunks = [];
    let chunk = [];
    let field = "";
    let inQuote = false;

    for (const line of lines) {
      const chars = line.split("");

      for (let i = 0; i < chars.length; i++) {
        const c = chars[i];

        if (inQuote) {
          if (c === '"') {
            if (chars[i + 1] === '"') {
              field += '"'; // Escaped quote
              i++; // Skip next quote
            } else {
              inQuote = false;
            }
          } else {
            field += c;
          }
        } else {
          if (c === '"') {
            inQuote = true;
          } else if (c === ",") {
            chunk.push(field);
            field = "";
          } else {
            field += c;
          }
        }
      }

      if (inQuote) {
        field += "\n"; // Add the line break back in
      } else {
        if (field.startsWith('"') && field.endsWith('"')) {
          // Wrap field in an extra pair of quotes
          field = '"' + field + '"';
        }
        chunk.push(field);
        chunks.push(chunk);
        chunk = [];
        field = "";
      }
    }

    return chunks;
  }

  toggleTemplateVisibility() {
    this.isTemplateVisible = !this.isTemplateVisible;
  }

  toggleInstructionsVisibility() {
    this.isInstructionsVisible = !this.isInstructionsVisible;
  }

  updateHiddenStatus() {
    this.isUploadButtonHidden = !this.isUploading && this.uploadedValidFile;
  }

  updateIsNextDisabled() {
    this.isNextDisabled = this.isUploading || !this.uploadedValidFile;
  }

  selectRemoveStore(event) {
    let rowData;

    // Check if the event is coming from the same component and has 'data-row'
    if (event.target && event.target.dataset && "rowNumber" in event.target.dataset) {
      rowData = event.target.dataset.rowNumber;
    } else if (event.detail) {
      rowData = event.detail;
    }

    const rowIndex = parseInt(rowData, 10);

    if (!isNaN(rowIndex)) {
      for (let i = 0; i < this.errorMessages.length; i++) {
        let thisError = this.errorMessages[i];

        if (parseInt(thisError.rowNumber, 10) === rowIndex) {
          thisError.duplicateSelectionInfo.hasMadeSelection = true;
          thisError.duplicateSelectionInfo.shouldRemoveFromUpload = true;
          thisError.duplicateSelectionInfo.shouldInsert = false;
        }
      }

      // Remove from the lists in case that option was selected previously
      this.duplicatesToForceInsertion = this.duplicatesToForceInsertion.filter(
        (item) => item !== rowIndex
      );
      this.duplicatesToRemoveFromInsertion =
        this.duplicatesToRemoveFromInsertion.filter(
          (item) => item !== rowIndex
        );

      // We will force insert every Store, bypassing the rules EXCEPT for those we put in this array.
      // The inserted Stores will be either:
      // 1. Not duplicates, in which case force insertion should not matter; or
      // 2. Duplicates that the user opted into force insertion, we will know that if the Store is not in this array.
      this.duplicatesToRemoveFromInsertion.push(rowIndex);
      this.rowNumberToBrand = this.rowNumberToBrand.filter((item) => item.key !== rowData);
    }

    this.bulkOnboardingContainer.rowsToRemoveFromUpload =
      this.duplicatesToRemoveFromInsertion;
    this.setDuplicateSelectionsFinished();
  }

  selectInsertStore(event) {
    let rowData;

    // Check if the event is coming from the same component and has 'data-row'
    if (event.target && event.target.dataset && "rowNumber" in event.target.dataset) {
      rowData = event.target.dataset.rowNumber;
    } else if (event.detail) {
      rowData = event.detail;
    }

    const rowIndex = parseInt(rowData, 10);

    if (!isNaN(rowIndex)) {
      for (let i = 0; i < this.errorMessages.length; i++) {
        let thisError = this.errorMessages[i];

        if (parseInt(thisError.rowNumber, 10) === rowIndex) {
          thisError.duplicateSelectionInfo.hasMadeSelection = true;
          thisError.duplicateSelectionInfo.shouldInsert = true;
          thisError.duplicateSelectionInfo.shouldRemoveFromUpload = false;
        }
      }

      // Remove from the lists in case that option was selected previously
      this.duplicatesToRemoveFromInsertion =
        this.duplicatesToRemoveFromInsertion.filter(
          (item) => item !== rowIndex
        );
      this.duplicatesToForceInsertion = this.duplicatesToForceInsertion.filter(
        (item) => item !== rowIndex
      );
      this.duplicatesToForceInsertion.push(rowIndex);
    }
    this.bulkOnboardingContainer.rowsToRemoveFromUpload =
      this.duplicatesToRemoveFromInsertion;
    this.setDuplicateSelectionsFinished();
  }

  setDuplicateSelectionsFinished() {
    let selectionsRemaining = this.errorMessages.some(
      (errorMessage) =>
        errorMessage.duplicateSelectionInfo.hasMadeSelection === false
    );

    this.allStoresFromFileRemoved =
      this.duplicatesToRemoveFromInsertion.length ===
      this.bulkOnboardingContainer.newRecords.length;
    this.hasNotFinishedDuplicateSelections =
      selectionsRemaining || this.allStoresFromFileRemoved;
  }

  /**
   * @description It is used to navigate to the duplicate account's table page on click of the
   * corresponding duplicate error message.
   * @param event
   */
  navigateToDuplicateAccountPage(event) {
    this.selectedRowNumber = event.target.dataset.rowNumber;
    this.selectedRowName =
      this.bulkOnboardingContainer.newRecords[this.selectedRowNumber - 1].Name;
    this.renderDuplicates = true;
    this.showErrorMessages = false;
    this.getMatchedAccounts();
  }

  /**
   * @description It is used to navigate back to the error messages page.
   */
  returnBackToErrorMessagePage() {
    this.renderDuplicates = false;
    this.showErrorMessages = true;
  }

  /**
   * @description It is used to get the existing account's data by the passed Ids.
   */
  getMatchedAccounts() {
    this.potentialDuplicatesList = [];
    getMatchingAccountsDetails({
      accountIds: this.indexWithPotentialAccountMatchIds.get(
        Number(this.selectedRowNumber)
      )
    })
      .then((result) => {
        if (result.length > 0) {
          this.potentialDuplicatesList = result;
        }
      })
      .catch((error) => {
        createLog({
          lwcName: LWC_NAME,
          methodName: GET_EXISTING_ACCOUNTS,
          message: JSON.stringify(error.body)
        });
      });
  }

  handleManagePackages() {
    this.toggleTemplateVisibilityforEntitlement();
  }

  toggleTemplateVisibilityforEntitlement() {
    this.showSelectEntitlementScreen = !this.showSelectEntitlementScreen;
  }

  populateStoreBrandTable(array) {
    let counts = {};
    array.forEach((item) => {
      const { value } = item;
      // If the value already exists in counts, increment the count
      if (counts[value]) {
        counts[value]++;
      } else {
        // If the value doesn't exist in counts, initialize the count to 1
        counts[value] = 1;
      }
    });

    // Initialize the array to store key-value pairs of brand and the count
    let brandToStoreCountArray = [];

    for (const value in counts) {
      // If the count is greater than 1
      if (counts[value] > 0) {
        // Push the duplicated value and its count to the brandToStoreCountArray
        brandToStoreCountArray.push({ key: value, value: counts[value] });
      }
    }
    return brandToStoreCountArray;
  }
}