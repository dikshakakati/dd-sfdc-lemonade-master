import { LightningElement, api, track, wire } from "lwc";
import manageStoresEntitlementsScreenInstructions from "@salesforce/label/c.Manage_Stores_Entitlements_Screen_Instructions";
import CCPConfirmationMessage from "@salesforce/label/c.CCP_Confirmation_Message";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import selectExistingSubscriptionsWithGroup from "@salesforce/apex/ManageEntitlementsScreenController.selectExistingSubscriptionsWithGroup";
import processSubmitButtonData from "@salesforce/apex/ManageEntitlementsScreenController.processSubmitButtonData";
import selectWorkOrdersByAccountId from "@salesforce/apex/ManageEntitlementsScreenController.selectWorkOrdersByAccountId";
import uploadFile from "@salesforce/apex/ManageEntitlementsScreenController.uploadFile";
import getAllSubscriptionFromContract from "@salesforce/apex/ManageEntitlementsScreenController.getAllSubscriptionFromContract";
import { getEntitlementSelectionDeselectionWhenCCPApplied, handleRowSelection, handleCheckboxChange } from "c/ccpUtils";
import createLog from "@salesforce/apex/LogController.createLog";
import LightningConfirm from 'lightning/confirm';

const columns = [
  {
    label: "Product Name",
    fieldName: "SBQQ__ProductName__c"
  }
];
const ERROR_PRODUCT_PACKAGE_SELECTION =
  "Please ensure you select the package in addition to selecting the corresponding product.";
const LWC_NAME = "LwcManageEntitlementsScreen";
const GET_ALL_SUBSCRIPTIONS = "getAllSubscriptionFromContract";
const SELECT_WORKORDER_BY_ACCOUNTID = "selectWorkOrdersByAccountId";
const SELECT_WORKORDER_BY_ACCOUNTID_OR_VALIDATIONRULES =
  "selectWorkOrdersByAccountId or Validations";
const SELECT_EXISTING_SUBSCRIPTIONS_WITH_GROUP =
  "selectExistingSubscriptionsWithGroup";
const PROCESS_SUBMIT_BUTTON_DATA = "processSubmitButtonData";
const SUBSCRIPTIONS_LOADING_ERROR =
  "An issue occurred while retrieving the subscriptions. Please reach out to your system administrator for assistance.";

export default class LwcManageEntitlementsScreen extends LightningElement {
  @api record;
  @api accountsString;
  @api filename;
  @api filecontents;
  @api isProcessingExistingAccounts;
  @api isBusinessIdsImported;
  @api isProcessingNewAndCoo;
  @api isProcessingOnlyCoo;
  @api isProcessingOnlyNew;
  @track wrapperList;
  @track showSpinner = true;
  @track preSelectedRows;
  @track importShowError = true;
  @track importErrorMessages = [];
  working = true;
  columns = columns;
  selectedPackages;
  selectedProducts;
  selectedProductIds;
  packIdNamePair;
  productPackageIds;
  deselectedPackages;
  isDriveProductsAvailable;
  resultVariableToBooleanMap;
  @track workorderError = false;
  @track packageError = false;
  @track storefrontError = false;
  finalData;
  allSubscriptionsList;
  allProductIds;
  allPackageIds;
  defaultProductList;
  groupId;
  showPricingScreenComponent = false;
  showWrapperList;
  showSubscriptionsError;
  fetchSubscriptionsError;
  labels = {
    manageStoresEntitlementsScreenInstructions,
    CCPConfirmationMessage
  };

  @wire(selectExistingSubscriptionsWithGroup, {
    mapofSelectedAccounts: "$accountsString",
    contractId: "$record"
  })
  wireSubsData({ data, error }) {
    this.wrapperList = data;
    let listProductSubs = [];
    let packIdNameList = {};
    let allProductIds = [];
    let allPackageIds = [];
    if (data) {
      data.forEach((eachkey) => {
        this.groupId = eachkey.groupId;
        eachkey.packageList.forEach(function (eachPack) {
          eachPack.subsList.forEach(function (eachChildSub) {
            let productSubs = {};
            productSubs.Id = eachChildSub.Id;
            productSubs.SBQQ__RequiredById__c =
              eachChildSub.SBQQ__RequiredById__c;
            listProductSubs.push(productSubs);
            allProductIds.push(eachChildSub.Id);
          });
          allPackageIds.push(eachPack.packageId);
          packIdNameList[eachPack.packageId] = eachPack.packageName;
        });
      });
      this.preSelectedRows = allProductIds;
      this.working = false;
      this.showSpinner = false;
      this.packIdNamePair = this.packIdNameList;
      this.allProductIds = allProductIds;
      this.allPackageIds = allPackageIds;
      this.showWrapperList = true;
    } else if (error) {
      createLog({
        lwcName: LWC_NAME,
        methodName: SELECT_EXISTING_SUBSCRIPTIONS_WITH_GROUP,
        message: JSON.stringify(error.body)
      });
      this.showSubscriptionsError = true;
      this.fetchSubscriptionsError = SUBSCRIPTIONS_LOADING_ERROR;
      this.showSpinner = !this.showSpinner;
    }
  }

  processSubscriptionData(subscriptionData) {
    const result = {
      preSelectedRows: [],
      packIdNamePair: {},
      productPackageIds: {}
    };
    subscriptionData.forEach(({ packageList }) => {
      packageList.forEach(({ packageId, packageName, subsList }) => {
        subsList.forEach(({ Id, SBQQ__RequiredById__c }) => {
          result.preSelectedRows.push(Id);
          result.productPackageIds[Id] = SBQQ__RequiredById__c;
          this.allProductIds.push(Id);
        });

        result.packIdNamePair[packageId] = packageName;
      });
    });
    return result;
  }

  handleProductSelection() {
    let eachTableSelections = [
      ...this.template.querySelectorAll('[data-id="SubscriptionTable"]')
    ].map((table) => table.getSelectedRows());

    this.preSelectedRows = handleRowSelection(
      this.preSelectedRows,
      eachTableSelections
    );
  }

  handlePackageCheckboxChange(event) {
    this.preSelectedRows = handleCheckboxChange(
      event,
      this.preSelectedRows,
      this.wrapperList
    );
  }

  backToUploadScreen() {
    const backButtonEvent = new CustomEvent(
      "passshowpricingscreencomponentvalue",
      {
        detail: {
          showPricingScreenComponent: this.showPricingScreenComponent,
          accountRecords: this.accountsString
        }
      }
    );

    this.dispatchEvent(backButtonEvent);
  }

  getSelectedProducts() {
    const eachTableSelections = [
      ...this.template.querySelectorAll('[data-id="SubscriptionTable"]')
    ].map((table) => table.getSelectedRows());

    return [].concat(...eachTableSelections);
  }

  getSelectedPackages() {
    return [...this.template.querySelectorAll('[data-id="packages"]')]
      .filter((key) => key.checked)
      .map((key) => key.value);
  }

  validateSelections() {
    const self = this;
    const selectedProdIds = [];

    function showCustomError(message = "") {
      this.message = message;
    }
    this.selectedProducts.forEach((products) => {
      selectedProdIds.push(products.Id);
      if (!this.selectedPackages.includes(products.SBQQ__RequiredById__c)) {
        const e = new showCustomError(ERROR_PRODUCT_PACKAGE_SELECTION);
        self.packageError = true;
        throw e;
      }
    });
    this.selectedProductIds = selectedProdIds;
  }

  async handleSubmitforConfirmationMsg() {
    const result = await LightningConfirm.open({
      message: CCPConfirmationMessage,
      variant: 'header',
      theme: 'warning',
      label: 'Confirmation',
    });

    if (result) {
      this.showSpinner = true;
      this.getEntitlementSelectionDeselection();
    }
  }

  submitProcess() {
    try {
      this.importErrorMessages = [];
      this.workorderError = false;
      this.packageError = false;
      this.showSpinner = true;
      this.selectedPackages = this.getSelectedPackages();
      this.selectedProducts = this.getSelectedProducts();
      // Validate selected products and packages
      this.validateSelections();

      this.resultVariableToBooleanMap = { 'isProcessingExistingAccounts': this.isProcessingExistingAccounts, 'isProcessingNewAndCoo': this.isProcessingNewAndCoo, 'isProcessingOnlyCoo': this.isProcessingOnlyCoo, 'isProcessingOnlyNew': this.isProcessingOnlyNew };
      if (!this.packageError) {
        selectWorkOrdersByAccountId({
          mapofSelectedAccounts: this.accountsString,
          contractId: this.record,
          selectedPackages: this.selectedPackages,
          resultVariableToBooleanMap: JSON.stringify(this.resultVariableToBooleanMap)
        })
          .then(() => {
            const productDifference = this.allProductIds.filter((element) => !this.selectedProductIds.includes(element));
            const packageDifference = this.allPackageIds.filter((element) => !this.selectedPackages.includes(element));

            if (((productDifference != null && productDifference.length != 0) || (packageDifference.length != 0 && packageDifference != null)) && this.isProcessingExistingAccounts) {
              this.showSpinner = false;
              this.handleSubmitforConfirmationMsg();
            } else {
              this.getEntitlementSelectionDeselection();
            }
          })
          .catch((error) => {
            createLog({
              lwcName: LWC_NAME,
              methodName: SELECT_WORKORDER_BY_ACCOUNTID,
              message: JSON.stringify(error.body)
            });
            this.handleError(error);
            this.workorderError = true;
            throw error;
          });
      }
    } catch (error) {
      this.handleError(error);
      createLog({
        lwcName: LWC_NAME,
        methodName: SELECT_WORKORDER_BY_ACCOUNTID_OR_VALIDATIONRULES,
        message: JSON.stringify(error.body)
      });
    }
  }

  closeAction() {
    this.dispatchEvent(
      new ShowToastEvent({
        title: "Success",
        message: "Accounts Associated to Contract sucessfully",
        variant: "Success"
      })
    );

    const closeQA = new CustomEvent("close");
    this.dispatchEvent(closeQA);
  }

  ShowToast(title, message, variant, mode) {
    const evt = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant,
      mode: mode
    });
    this.dispatchEvent(evt);
  }
  handleSelectionError(error) {
    this.importShowError = true;
    if (this.importErrorMessages.length > 0) {
      this.importErrorMessages.length = 0;
    }
    if (error != null) {
      this.importErrorMessages.push(error.message);
    }
  }

  getFinalArray() {
    const finalArray = [];
    const recordId = this.record;
    const wrap = {
      groupId: this.groupId,
      accounts: this.accountsString,
      selectedAndDeselectedEntitlements: this.finalData,
      IsProcessingExistingStores: Boolean(this.isProcessingExistingAccounts),
      contractId: recordId
    };
    finalArray.push(wrap);
    return finalArray;
  }

  processSubmitButtonData(finalArray) {
    let ccpSelectionDeselectionApplied = false;
    const productDifference =
      this.allProductIds.filter((element) => !this.selectedProductIds.includes(element));
    const packageDifference =
      this.allPackageIds.filter((element) => !this.selectedPackages.includes(element));

    if (finalArray != null) {
      if (productDifference.length != 0 || packageDifference.length != 0) {
        ccpSelectionDeselectionApplied = true;
      }

      processSubmitButtonData({
        mapofSelectedSubscriptions: JSON.stringify(finalArray),
        parentId: this.record,
        ccpApplied: ccpSelectionDeselectionApplied
      })
        .then(() => {
          this.showSpinner = false;
          this.closeAction();
        })
        .catch((error) => {
          this.handleError(error);
          createLog({
            lwcName: LWC_NAME,
            methodName: PROCESS_SUBMIT_BUTTON_DATA,
            message: JSON.stringify(error.body)
          });
        });
    }
  }

  uploadFile() {
    const { filecontents, filename } = this;
    uploadFile({
      base64: filecontents,
      filename: filename,
      recordId: this.record
    })
      .then((result) => {
        if (result) {
          this.showSpinner = false;
          const title = `${filename} uploaded successfully!!`;
          this.ShowToast("Success!", title, "success", "dismissable");
          const closeChildAction = new CustomEvent("submitdone");
          this.dispatchEvent(closeChildAction);
        }
      })
      .catch((err) => {
        this.ShowToast("Error!!", err.body, "error", "dismissable");
      });
  }

  handleError(error) {
    this.importShowError = true;
    this.showSpinner = false;
    if (error) {
      if (error.body) {
        if (Array.isArray(error.body)) {
          this.importErrorMessages.push(...error.body.map((e) => e.message));
        } else if (typeof error.body.message === "string") {
          this.importErrorMessages.push(error.body.message);
        }
      } else if (error.message) {
        this.importErrorMessages.push(error.message);
      }
    } else {
      this.importErrorMessages.length = 0;
    }
  }

  getEntitlementSelectionDeselection() {
    getAllSubscriptionFromContract({ contractId: this.record })
      .then((result) => {
        this.finalData = getEntitlementSelectionDeselectionWhenCCPApplied(
          result,
          this.selectedPackages,
          this.selectedProductIds,
          this.allProductIds
        );
        this.processSubmitButtonData(this.getFinalArray());
        this.uploadFile();
      })
      .catch((error) => {
        createLog({
          lwcName: LWC_NAME,
          methodName: GET_ALL_SUBSCRIPTIONS,
          message: JSON.stringify(error.body)
        });
      });
  }
  get isDataTableDisabled() {
    return this.pack.isDrivePackage;
  }

}
