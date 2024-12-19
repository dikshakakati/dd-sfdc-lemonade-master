import { LightningElement, wire, api } from "lwc";

import getAccountDetails from "@salesforce/apex/AccountHierarchyController.getAccountDetails";
import getChildAccounts from "@salesforce/apex/AccountHierarchyController.getChildAccounts";
import getMetadataRecord from "@salesforce/apex/AccountHierarchyController.getMetadataRecord";
import storeLimitMessage from "@salesforce/label/c.Warning_Message_To_Limit_Store_Records";

import { ShowToastEvent } from "lightning/platformShowToastEvent";

const BUSINESS = "Business";
const STORE = "Store";
const FRANCHISEPARENT = "Franchise_Parent__c";
const TOTAL_NUMBER_OF_STORES = "Total_Number_Of_Stores__c";

export default class DisplayAccountHierarchy extends LightningElement {
  @api recordId;
  @api gridColumns;
  @api gridFields;
  @api accountLookup;
  @api reportName;
  showWarningMessage = false;
  metadataRecord;
  gridData = [];
  currentExpanded = [];
  businessParentAccounts = [];
  businessAccounts = [];
  expandOnLoad = [];
  selectedRow = [];
  highlightRow = [];
  isLoading;
  soql;
  businessRecordType = false;
  recordCountExceedsLimit = false;

  label = {
    storeLimitMessage
  };

  /**
   * @description To get related metadata record
   */
  @wire(getMetadataRecord, { metadataName: "$reportName" })
  retrivedMetadataRecord({ error, data }) {
    if (data) {
      this.metadataRecord = data;
    } else if (error) {
      this.showErrorToastMessage(error.body.message);
    }
  }

  /**
   * @description To get selected account details
   */
  @wire(getAccountDetails, { columns: "$gridFields", recordId: "$recordId" })
  setUltimateParentId({ error, data }) {
    this.isLoading = true;
    if (error) {
      this.showErrorToastMessage(error.body.message);
    } else if (data) {
      this.showWarningMessage = false;
      this.gridData = data.map((account) => ({
        ...account
      }));

      // To set up lookup fields
      this.setLookupFields(this.gridData);

      this.highlightRow.push(data[0].Id);
      this.assignIdsToExpandOnLoad(data[0]);

      if (
        data[0].RecordType.DeveloperName === STORE &&
        this.accountLookup === FRANCHISEPARENT
      ) {
        this.setFranchiseUltimateParent(data[0]);
      } else {
        this.setCorporateUltimateParent(data[0]);
      }

      if (data[0].RecordType.DeveloperName === BUSINESS) {
        // To store business accounts
        this.businessRecordType = true;
        this.businessAccounts.push(data[0].Id);
      } else {
        // To display store hierarchy
        this.currentExpanded = [...this.expandOnLoad];
      }
    }
  }

  /**
   * @description To store parent id's to expand on load
   */
  assignIdsToExpandOnLoad(data) {
    let assignId = [];
    if (
      data.RecordType.DeveloperName === STORE &&
      this.accountLookup === FRANCHISEPARENT
    ) {
      this.pushToArray(assignId, data.Franchise_Parent__c);
      this.pushToArray(assignId, data.Franchise_Parent__r?.ParentId);
      this.pushToArray(assignId, data.Franchise_Parent__r?.Parent?.ParentId);
      this.pushToArray(
        assignId,
        data.Franchise_Parent__r?.Parent?.Parent?.ParentId
      );
    } else {
      this.pushToArray(assignId, data.ParentId);
      this.pushToArray(assignId, data.Parent?.ParentId);
      this.pushToArray(assignId, data.Parent?.Parent?.ParentId);
      this.pushToArray(assignId, data.Parent?.Parent?.Parent?.ParentId);
    }

    this.expandOnLoad = [...assignId];
  }

  /**
   * @description To push not null values
   */
  pushToArray(assignId, value) {
    if (value) {
      assignId.push(value);
    }
  }

  /**
   * @description To set franchise ultimate parent
   */
  setFranchiseUltimateParent(record) {
    let ultimateParent = record.Franchise_Parent__r?.Ultimate_Parent_Account__c;
    let franchiseParent = record.Franchise_Parent__c;

    if (ultimateParent) {
      this.getUtimateParentAccount(ultimateParent);
    } else if (franchiseParent) {
      this.getUtimateParentAccount(franchiseParent);
    } else {
      let parentIds = [];
      parentIds.push(record.Id);
      this.getDirectChildRecords(parentIds);
    }
  }

  /**
   * @description To set corporate ultimate parent
   */
  setCorporateUltimateParent(record) {
    let ultimateParent = record.Ultimate_Parent_Account__c;

    if (ultimateParent) {
      this.getUtimateParentAccount(ultimateParent);
    } else {
      let parentIds = [];
      parentIds.push(record.Id);
      this.getDirectChildRecords(parentIds);
    }
  }

  /**
   * @description To get ultimate parent details
   */
  getUtimateParentAccount(ultimateAccountId) {
    getAccountDetails({ columns: this.gridFields, recordId: ultimateAccountId })
      .then((data) => {
        this.gridData = data.map((account) => ({
          ...account
        }));

        // To set up lookup fields
        this.setLookupFields(this.gridData);

        // To store business accounts
        if (data[0].RecordType.DeveloperName === BUSINESS) {
          this.businessAccounts.push(data[0].Id);
        }
        let parentIds = [];
        parentIds.push(ultimateAccountId);
        this.getDirectChildRecords(parentIds);
      })
      .catch((error) => {
        this.showErrorToastMessage(error.body.message);
      });
  }

  /**
   * @discription : To toggle child accounts
   */
  handleOnToggle() {
    this.selectedRow = [...this.highlightRow];
  }

  /**
   * @discription : Get all child accounts in hierarchy
   */
  getDirectChildRecords(parentIds) {
    getChildAccounts({
      columns: this.gridFields,
      parentField: this.accountLookup,
      recordIds: parentIds
    })
      .then((result) => {
        if (result && result.length > 0) {
          let childAccountIds = [];

          // Iterate over parent Id's
          parentIds.forEach((parentId) => {
            let newChildren = [];
            let hasChildStoreAccounts = false;

            // Iterate over child accounts and add them to parent account hierarchy
            result.forEach((data) => {
              let obj = data;

              // Store all child accounts for a particular parent
              if (
                obj.RecordType.DeveloperName === BUSINESS &&
                obj.ParentId === parentId
              ) {
                this.businessAccounts.push(obj.Id);
                childAccountIds.push(obj.Id);
                newChildren.push(obj);
              } else if (
                obj.RecordType.DeveloperName === STORE &&
                obj[this.accountLookup] === parentId
              ) {
                hasChildStoreAccounts = true;
                if (newChildren.length < 100 || obj.Id === this.recordId) {
                  newChildren.push(obj);
                } else {
                  this.recordCountExceedsLimit = true;
                }
              }
            });

            // To set up lookup fields
            this.setLookupFields(newChildren);

            // Store parent business account
            if (!hasChildStoreAccounts) {
              this.businessParentAccounts.push(parentId);
            }

            this.gridData = this.getNewDataWithChildren(
              parentId,
              this.gridData,
              newChildren
            );
          });

          // To get child accounts recursively
          if (childAccountIds) {
            this.getDirectChildRecords(childAccountIds);
          }
          this.selectedRow = [...this.highlightRow];
          if (this.businessRecordType) {
            this.currentExpanded = [...this.businessParentAccounts];
          }
        } else {
          this.isLoading = false;
        }
      })
      .catch((error) => {
        this.showErrorToastMessage(error.body.message);
      });
  }

  /**
   * @discription : To add child accounts for respective parent account recursively
   */
  getNewDataWithChildren(rowName, data, children) {
    return data.map((row) => {
      let hasChildrenContent = false;
      if (
        Object.prototype.hasOwnProperty.call(row, "_children") &&
        Array.isArray(row._children) &&
        row._children.length > 0
      ) {
        hasChildrenContent = true;
      }

      if (row.Id === rowName && children.length > 0) {
        row._children = children;
      } else if (hasChildrenContent) {
        this.getNewDataWithChildren(rowName, row._children, children);
      }
      return row;
    });
  }

  /**
   * @discription : To view all business accounts in hierarchy
   */
  @api
  displayBusinessAccounts() {
    this.showWarningMessage = false;
    this.selectedRow = [...this.highlightRow];
    this.currentExpanded = [...this.businessParentAccounts];
  }

  /**
   * @discription : To view all store accounts in hierarchy
   */
  @api
  displayStoreAccounts() {
    if (this.recordCountExceedsLimit) {
      this.showWarningMessage = true;
    }
    this.selectedRow = [...this.highlightRow];
    this.currentExpanded = [...this.businessAccounts];
  }

  /**
   * @discription : To set lookup fields value and redirection url
   */
  setLookupFields(newChildren) {
    let lookupColumns = this.gridColumns.filter((col) => col.type === "url");
    newChildren.forEach((obj) => {
      lookupColumns.forEach((col) => {
        let apiName = col.apiName.split(".");
        obj[col.typeAttributes?.label?.fieldName] =
          apiName.length === 1
            ? obj[apiName[0]]
            : obj[apiName[0]]?.[apiName[1]];

        obj[col.fieldName] =
          obj[col.typeAttributes?.label?.fieldName] !== undefined
            ? col.typeAttributes?.label?.fieldName === undefined
              ? obj[col.fieldName]
              : "/" + obj[col.fieldName]
            : null;

        if (col.fieldName === TOTAL_NUMBER_OF_STORES) {
          obj[col.fieldName] =
            "/lightning/r/Report/" +
            this.metadataRecord?.Configuration_Value__c +
            "/view?fv0=" +
            obj.Id +
            "&fv1=" +
            obj.Id +
            "&fv2=" +
            obj.Id +
            "&fv3=" +
            obj.Id;
        }
      });
      obj.Name = "/" + obj.Id;
      obj.RecordTypeId = obj.RecordType?.Name;
    });
  }

  /**
   * @discription : To show error toast message
   */
  showErrorToastMessage(errorMessage) {
    const evt = new ShowToastEvent({
      title: "Error!",
      message: errorMessage,
      variant: "error"
    });
    this.dispatchEvent(evt);
  }
}
