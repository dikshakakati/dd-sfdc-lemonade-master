import { LightningElement, api, track, wire } from "lwc";
import selectExistingSubscriptionsWithGroup from "@salesforce/apex/BulkCorporateOnboardingEntitlementCtrl.selectExistingSubscriptionsWithGroup";
import saveEntitlementsSelectionDeselection from "@salesforce/apex/BulkCorporateOnboardingEntitlementCtrl.saveEntitlementsSelectionDeselection";
import getAllSubscriptionFromContract from "@salesforce/apex/BulkCorporateOnboardingEntitlementCtrl.getAllSubscriptionFromContract";
import {
  getEntitlementSelectionDeselectionWhenCCPSkipped,
  getEntitlementSelectionDeselectionWhenCCPApplied,
  handleRowSelection,
  handleCheckboxChange
} from "c/ccpUtils";
import createLog from "@salesforce/apex/LogController.createLog";

const columns = [
  {
    label: "Product Name",
    fieldName: "SBQQ__ProductName__c"
  },
  {
    label: "Final Commission",
    fieldName: "Final_Commission__c"
  },
  {
    label: "Final Fee",
    fieldName: "Final_Fee__c"
  }
];

const ERROR_PRODUCT_PACKAGE_SELECTION =
  "Please ensure you select the package in addition to selecting the corresponding product";
const ERROR_PICKUP_PRODUCT_SELECTION =
  "Please select Pickup under Marketplace Package to onboard stores";
const SUBSCRIPTIONS_LOADING_ERROR =
  "An issue occurred while retrieving the subscriptions; the contract does not have any CCP enabled products/packages.\n Please reach out to your system administrator for assistance.";
const LWC_NAME = "BulkOnboardingSelectEntitlements";
const GET_ALL_SUBSCRIPTIONS = "getAllSubscriptionFromContract";
const SAVE_ENTITLEMENT_METHOD_NAME = "saveEntitlementsSelectionDeselection";

export default class BulkOnboardingSelectEntitlements extends LightningElement {
  @api contractId;
  @api flowRequestId;
  @api showPaymentAccountSkipOption;
  @track wrapperList;
  @track showSpinner = true;
  @track preSelectedRows;
  @track importShowError = false;
  @track importErrorMessages = [];
  working = true;
  columns = columns;
  _currentStep;
  selectedPackages;
  selectedProducts;
  selectedProductIds;
  allProductIds;
  allPackageIds;
  showSubscriptionsError;
  fetchSubscriptionsError;

  @api
  set currentStep(value) {
    this._currentStep = value ? value.toString() : "1"; // convert to string and store in private property
  }

  get currentStep() {
    return this._currentStep; // return the private property value
  }

  /**
   * @description It is used to get ccp enabled subscriptions from contract to show on screen
   */
  @wire(selectExistingSubscriptionsWithGroup, {
    contractId: "$contractId",
    flowRequestId: "$flowRequestId"
  })
  wireSubsData({ data, error }) {
    if (data) {
      this.wrapperList = data;
      let allPackageIds = [];
      let allProductIds = [];
      let listProductSubs = [];

      data.forEach(function (eachkey) {
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
        });
      });

      this.preSelectedRows = allProductIds;
      this.working = false;
      this.showSpinner = false;
      this.allPackageIds = allPackageIds;
      this.allProductIds = allProductIds;
    } else if (error) {
      this.showSubscriptionsError = true;
      this.fetchSubscriptionsError = SUBSCRIPTIONS_LOADING_ERROR;
      this.showSpinner = !this.showSpinner;
    }
  }

  /**
   * @description It is used to fire custom validations on screen based on user selection/deselection
   */
  validateSelection() {
    var listProducts = [];
    var listPackages = [];
    var selectedProdIds = [];
    var i, packages, e, err;

    let eachTableSelections = [
      ...this.template.querySelectorAll('[data-id="Subs"]')
    ].map((table) => table.getSelectedRows());
    for (i = 0; i < eachTableSelections.length; i++) {
      listProducts.push(eachTableSelections[i]);
    }
    this.selectedProducts = listProducts;

    packages = [...this.template.querySelectorAll('[data-id="packages"]')];
    packages.forEach(function (key) {
      if (key.checked === true) {
        listPackages.push(key.value);
      }
    });
    this.selectedPackages = listPackages;

    function showCustomErrror(message = "") {
      this.message = message;
    }
    showCustomErrror.prototype = new Error();

    try {
      this.selectedProducts.forEach(function (products) {
        products.forEach((prod) => {
          selectedProdIds.push(prod.Id);

          //If user has selected a child Product then it's mandatory to select it's corresponding Package
          if (!listPackages.includes(prod.SBQQ__RequiredById__c)) {
            e = new showCustomErrror(ERROR_PRODUCT_PACKAGE_SELECTION);
            throw e;
          }
        });
      });

      this.selectedProductIds = selectedProdIds;
      this.handleSelectionError(null);
      //If there is no error then call method for JSON stamping
      this.getEntitlementSelectionDeselection();
    } catch (error) {
      this.selectedProductIds = selectedProdIds;
      this.handleSelectionError(error);
    }
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

  handleProductSelection() {
    let eachTableSelections = [
      ...this.template.querySelectorAll('[data-id="Subs"]')
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

  /**
   * @description It is called for default selection stamping in JSON when user skips CCP process
   */
  handleCCPSkip() {
    this.showSpinner = true;
    let finalData;
    getAllSubscriptionFromContract({ contractId: this.contractId })
      .then((result) => {
        finalData = getEntitlementSelectionDeselectionWhenCCPSkipped(
          result !== null ? result : null,
          this.flowRequestId,
          this.contractId
        );
        this.saveEntitlementsSelectionDeselectiononPFR(finalData, false, false);
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

  /**
   * @description It is called for selection/deselection stamping in JSON when user choose CCP process
   */
  getEntitlementSelectionDeselection() {
    this.showSpinner = true;
    let ccpSelectionDeselectionApplied = false;
    let finalData = {
      selected: [],
      deselected: []
    };

    getAllSubscriptionFromContract({ contractId: this.contractId })
      .then((result) => {
        finalData = getEntitlementSelectionDeselectionWhenCCPApplied(
          result !== null ? result : null,
          this.selectedPackages,
          this.selectedProductIds,
          this.allProductIds
        );

        let productDifference =
          this.allProductIds.filter((element) => !this.selectedProductIds.includes(element));
        let packageDifference =
          this.allPackageIds.filter((element) => !this.selectedPackages.includes(element));
        if (productDifference.length != 0 || packageDifference.length != 0) {
          ccpSelectionDeselectionApplied = true;
        }
        this.saveEntitlementsSelectionDeselectiononPFR(finalData, true, ccpSelectionDeselectionApplied);
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

  /**
   * @description It is called for updating ccp fields on associated PFR record
   */
  saveEntitlementsSelectionDeselectiononPFR(finalData, isManagePackageSelected, ccpSelectionDeselectionApplied) {
    if (finalData !== undefined) {
      saveEntitlementsSelectionDeselection({
        mapofSelectDeselect:
          finalData == null ? null : JSON.stringify(finalData),
        flowRequestId: this.flowRequestId,
        contractId: this.contractId,
        isManagePackageSelected: isManagePackageSelected,
        ccpApplied: ccpSelectionDeselectionApplied
      })
        .then((response) => {
          this.dispatchEvent(
            new CustomEvent("handleuploadnext", {
              detail: {
                flowRequestValue: response,
                skipStepValue: this.showPaymentAccountSkipOption
              },
              bubbles: true,
              composed: true
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
  }
}
