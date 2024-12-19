import { LightningElement, wire, track, api } from "lwc";
import getFields from "@salesforce/apex/DynamicColumnsController.getAllColumnsDetail";
import getDefaultFields from "@salesforce/apex/DynamicColumnsController.getDefaultFields";
import selectColumnsHeader from "@salesforce/label/c.Select_Columns_Header";
import maxText from "@salesforce/label/c.Max_Text_For_Max_Columns";
import columnsText from "@salesforce/label/c.Columns_Text_For_Max_Columns";
import selectFields from "@salesforce/label/c.Select_Fields";
import selectFieldsHelpText from "@salesforce/label/c.Select_Fields_Help_Text";
import availableFields from "@salesforce/label/c.Available_Fields";
import selectedFields from "@salesforce/label/c.Selected_Fields";
import modifyColumns from "@salesforce/label/c.Modify_Columns";
import saveAction from "@salesforce/label/c.Save_Action";
import cancelAction from "@salesforce/label/c.Cancel_Action";
import reviewMessage from "@salesforce/label/c.Display_Review_Error_Message_Title";
import displayUptoText from "@salesforce/label/c.Display_Upto_Message_In_Dynamic_Columns";
import fieldsText from "@salesforce/label/c.Fields_Text_In_Dynamic_Columns";

export default class DynamicColumns extends LightningElement {
  @track isColumnSelectorOpened = false;
  @track allFields = [];
  @track allSelectedFields = [];
  @track fieldsForColumn = [];
  @api objectName;
  @api fieldSetName;
  @api maxColumns;
  @api requiredOptions;
  displayError = false;
  storeSelectedFields = [];

  label = {
    selectColumnsHeader,
    selectFields,
    selectFieldsHelpText,
    availableFields,
    selectedFields,
    modifyColumns,
    saveAction,
    cancelAction,
    maxText,
    columnsText,
    reviewMessage,
    displayUptoText,
    fieldsText
  };

  @wire(getDefaultFields, {
    objectName: "$objectName",
    fieldSetName: "$fieldSetName"
  })
  setObjectField({ error, data }) {
    if (data) {
      this.fieldsForColumn = JSON.parse(data);
      this.allSelectedFields = this.fieldsForColumn.map((obj) => obj.value);
      this.storeSelectedFields = [...this.allSelectedFields];
      const selectedEvent = new CustomEvent("selected", {
        detail: this.fieldsForColumn
      });

      // Dispatches the event.
      this.dispatchEvent(selectedEvent);
    } else if (error) {
      console.log(error);
    }
  }

  // To retrieve all sobject fields
  @wire(getFields, { objectApiName: "$objectName" }) setAllField({
    error,
    data
  }) {
    if (data) {
      this.allFields = JSON.parse(data);
    } else if (error) {
      console.log(error);
    }
  }

  // Assign updated column values
  updateSelectedColumns(event) {
    const valueSelected = event.target.value;
    if (valueSelected.length > 10) {
      this.displayError = true;
      this.storeSelectedFields = valueSelected.slice(0, this.maxColumns);
      this.allSelectedFields = valueSelected.slice(0, this.maxColumns);
    } else {
      this.displayError = false;
      this.storeSelectedFields = valueSelected;
    }
  }

  // Open column selection modal
  showColumnSelectionWindow() {
    this.displayError = false;
    this.isColumnSelectorOpened = true;
  }

  // Close modal action
  closeModel(event) {
    const eventName = event.target.name;
    if (eventName === "saveAction") {
      // Assign values in selected order on save
      const addfields = [];
      this.storeSelectedFields.forEach((selectedField) => {
        addfields.push(
          this.allFields.find((field) => field.value === selectedField)
        );
      });

      this.fieldsForColumn = addfields;
      this.allSelectedFields = [...this.storeSelectedFields];

      // Fire event on parent component
      const selectedEvent = new CustomEvent("selected", {
        detail: this.fieldsForColumn
      });
      this.dispatchEvent(selectedEvent);
    }
    this.isColumnSelectorOpened = false;
  }
}
