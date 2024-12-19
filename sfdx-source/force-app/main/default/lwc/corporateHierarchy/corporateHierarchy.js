import { LightningElement, wire, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { CloseActionScreenEvent } from "lightning/actions";
import modal from "@salesforce/resourceUrl/DynamicHierarchy";
import { loadStyle } from "lightning/platformResourceLoader";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import NAME_FIELD from "@salesforce/schema/Account.Name";
import corporateHierarchy from "@salesforce/label/c.Display_Corporate_Hierarchy_View_Title";
import toggleStores from "@salesforce/label/c.Toggle_Stores_To_View_Business_Store_Accounts_In_Hierarchy";

export default class CorporateHierarchy extends NavigationMixin(
  LightningElement
) {
  @api recordId;
  objectName = "Account";
  fieldSetName = "Default_Fields_In_Corporate_Hierarchy";
  maxColumns = "10";
  gridColumns;
  gridFields;
  requiredOptions = [
    "Name",
    "ParentId",
    "Franchise_Parent__c",
    "Total_Number_Of_Stores__c"
  ];
  reportName = "Corporate_Hierarchy_Report_Id";

  label = {
    corporateHierarchy,
    toggleStores
  };

  // Get Account Name
  @wire(getRecord, {
    recordId: "$recordId",
    fields: [NAME_FIELD]
  })
  account;

  // Set Account Name
  get name() {
    let accountName = getFieldValue(this.account.data, NAME_FIELD);
    return accountName !== undefined ? accountName.toUpperCase() : null;
  }

  // To load style to increate quick action modal view
  connectedCallback() {
    loadStyle(this, modal);
  }

  // To disable toggle checkbox on component render
  renderedCallback() {
    let checkboxElement = this.template.querySelector("input");
    checkboxElement.checked = false;
  }

  // To set values on event callback
  datashow(event) {
    this.gridColumns = event.detail.map((v) => {
      return v.value === "Name" ? { ...v, initialWidth: 250 } : v;
    });
    this.gridFields = event.detail.map((obj) => obj.apiName);
  }

  // To call child components method to toggle store and business accounts
  changeToggle(event) {
    if (event.target.checked) {
      this.template
        .querySelector("c-display-account-hierarchy")
        .displayStoreAccounts();
    } else {
      this.template
        .querySelector("c-display-account-hierarchy")
        .displayBusinessAccounts();
    }
  }

  // Navigate to the Pinned Account list view.
  handleListViewNavigation() {
    this[NavigationMixin.Navigate]({
      type: "standard__objectPage",
      attributes: {
        objectApiName: this.objectName,
        actionName: "list"
      }
    });
  }

  // Close quick action modal
  handleRecordNavigation() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }
}