import { LightningElement, api, track } from "lwc";
import linkBusinessVerticalInstructions from "@salesforce/label/c.Link_Business_Vertical_Instruction";
import getRxBusinessVerticalId from "@salesforce/apex/BulkCorporateOnboardingRequestCtrl.getRxBusinessVerticalId";
import loading from '@salesforce/label/c.Spinner_Alternative_Text';


export default class BulkOnboardingBusinessVertical extends LightningElement {
  @api flowRequestId;
  @api accountId;
  @track businessVerticalRxId;
  @track isDataLoaded = false;
  selectedBusinessVerticalId;
  loadingAlternativeText = loading;


  _currentStep; // For currentStep string value
  label = {
    linkBusinessVerticalInstructions
  };
  // @api setter for currentStep
  @api
  set currentStep(value) {
    this._currentStep = value ? value.toString() : "1"; // convert to string and store in private property
  }

  // getter for currentStep
  get currentStep() {
    return this._currentStep; // return the private property value
  }

  connectedCallback() {
    getRxBusinessVerticalId({}).then((result) => {
      this.businessVerticalRxId = result;
      this.selectedBusinessVerticalId = result;
      this.isDataLoaded = true;
    });
  }

  // Lookup search implementation - called when a value is selected from the search field
  handleBusinessVerticalSelection(event) {
    const selectedBusinessVertical = event.detail;
    this.selectedBusinessVerticalId = selectedBusinessVertical
      ? selectedBusinessVertical.id
      : null;
  }

  updateFlowRequestWithBusinessVertical() {
    // Dispatching a custom event with the selected Payment Account ID to the parent component
    this.dispatchEvent(
      new CustomEvent("businessverticalselected", {
        detail: this.selectedBusinessVerticalId
      })
    );
  }
}