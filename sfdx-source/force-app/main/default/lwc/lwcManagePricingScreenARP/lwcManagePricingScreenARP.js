import createLog from "@salesforce/apex/LogController.createLog";
import createRateChangeRequest from '@salesforce/apex/ManagePricingScreenController.createRateChangeRequest';
import selectExistingSubscriptionsWithGroup from "@salesforce/apex/ManagePricingScreenController.selectExistingSubscriptionsWithGroup";
import uploadFile from '@salesforce/apex/ManagePricingScreenController.uploadFile';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { api, track, wire, LightningElement } from "lwc";

const columns = [
  {
    label: "Package",
    fieldName: "Package__c"
  },
  {
    label: "Product Name",
    fieldName: "SBQQ__ProductName__c"
  },
  {
    label: "Fee Type",
    fieldName: "Fee_Type__c"
  },
  {
    label: "Current Active Commission",
    fieldName: "Active_Commission__c"
  },
  {
    label: "Current Active Fee",
    fieldName: "Active_Fee__c"
  },
  {
    label: "Updated Active Commission",
    fieldName: "UpdatedActiveCommission",
    editable: { fieldName: 'enableCommissionEdit' },
    wrapText: true,
    type: 'number',
    typeAttributes: {
      minimumFractionDigits: '2',
      maximumFractionDigits: '2',
    }
  },
  {
    label: "Updated Active Fee",
    fieldName: "UpdatedActiveFee",
    editable: { fieldName: 'enableFeeEdit' },
    wrapText: true,
    type: 'currency'
  }
];
const LWC_NAME = "lwcManagePricingScreenARP";
const SELECT_EXISTING_SUBSCRIPTIONS_WITH_GROUP = "selectExistingSubscriptionsWithGroup";
const CREATE_RATE_CHANGE_REQUEST = "createRateChangeRequest";
const UPLOAD_FILE = "uploadFile";
const EFFECTIVE_DATE_ERROR = "Effective Date cannot be in the past. Please update the effective date to a future date";

export default class lwcManagePricingScreenARP extends LightningElement {
  @api record;
  columns = columns;
  @track wrapperList;
  @track subscriptionList;
  working = true;
  showPricingScreenComponent = false;
  effectiveDate;
  soSupportCaseId;
  subWrapperList = [];
  draftValues = [];
  @api accountsString;
  @api accountsData;
  @api filename;
  @api filecontents;
  @track mapUpdatedActiveCommission = new Map();
  @track mapUpdatedActiveFee = new Map();
  @track subscriptionIds = [];
  @track submitButtonVisible = false;
  @track effectiveDateVisible = false;
  @track caseVisible = false;
  @track submitButtonDisable = true;
  @wire(selectExistingSubscriptionsWithGroup, { parentId: "$record" })

  wireSubscriptionsData({ data, error }) {
   if (data) {
    let tempWrapper = [];
    data.forEach((eachGrp) => {
      eachGrp.subsList.forEach((eachSubWrap) => {
        var enableCommissionEdit = false;
        var enableFeeEdit = false;
        var eachSub;
        eachSub = { ...eachSubWrap };
      if(eachSubWrap.Fee_Type__c == undefined || eachSubWrap.Fee_Type__c == null) {
        enableCommissionEdit = true;
        enableFeeEdit = true;
      } else {
        if (eachSubWrap.Fee_Type__c.includes('Commission')) {
          enableCommissionEdit = true;
        }
        if (eachSubWrap.Fee_Type__c.includes('Fee')) {
          enableFeeEdit = true;
        }
      }
      eachSub.enableCommissionEdit = enableCommissionEdit;
      eachSub.enableFeeEdit = enableFeeEdit;
      tempWrapper.push(eachSub);
      this.subscriptionIds.push(eachSubWrap.Id);
    });
   });
     this.subscriptionList = tempWrapper;
     this.working = false;
   } else if (error) {
     this.working = false;
     createLog({
       lwcName: LWC_NAME,
       methodName: SELECT_EXISTING_SUBSCRIPTIONS_WITH_GROUP,
       message: JSON.stringify(error.body)
     });
   }
 }

  backToParentComp() {
    const backButtonEvent = new CustomEvent("passshowpricingscreencomponentvalue", {
      detail: {
        'showPricingScreenComponent': this.showPricingScreenComponent,
        'accountRecords': this.accountsString,
      }
    });
    this.dispatchEvent(backButtonEvent);
  }

  submitProcess() {
    this.working = true;
    this.subscriptionIds.forEach((sub) => {
      let subWrapper;
      if (this.mapUpdatedActiveFee.has(sub) || this.mapUpdatedActiveCommission.has(sub)) {
        subWrapper = {
          subscriptionId: sub,
          updatedActiveFee: this.mapUpdatedActiveFee.has(sub) && this.mapUpdatedActiveFee.get(sub) !== "" ? this.mapUpdatedActiveFee.get(sub) : null,
          updatedActiveCommission: this.mapUpdatedActiveCommission.has(sub) && this.mapUpdatedActiveCommission.get(sub) !== "" ? this.mapUpdatedActiveCommission.get(sub) : null
        }
      }
      if (subWrapper !== undefined) {
        this.subWrapperList.push(subWrapper);
      }
    });

   let subData = {
     contractId: this.record,
     effectiveDate: this.effectiveDate,
     soSupportCaseId: this.soSupportCaseId,
     existingAccountsToUpdate: this.accountsString,
     subscriptionWrappers: this.subWrapperList
   }
   let subDataList = [];
   let filecontents = this.filecontents;
   let filename = this.filename;
   subDataList.push(subData);

   createRateChangeRequest({ managePricingWrapper: JSON.stringify(subDataList) })
    .then(() => {
      //Once rate change request is created upload csv file and close quick action
      uploadFile({ base64: filecontents, filename: filename, recordId: this.record }).then(result => {
        this.closeAction();
      }).catch(err => {
        this.working = false;
        createLog({
          lwcName: LWC_NAME,
          methodName: UPLOAD_FILE,
       message: JSON.stringify(err.body)
     });
      this.ShowToast('Error!!', err.body, 'error', 'dismissable');
    })
   }).catch((error) => {
     this.working = false;
     createLog({
       lwcName: LWC_NAME,
       methodName: CREATE_RATE_CHANGE_REQUEST,
       message: JSON.stringify(error.body)
     });
     this.ShowToast('Error!!', error.body, 'error', 'dismissable');
   });
 }

  handleInputChange(event) {
   let effectiveDateCmp = this.template.querySelector(".inputStyle");
   this.effectiveDate = event.target.value;

    //Converting system time to PST as per organizations timezone
    var pstDate = new Date().toLocaleString("en-US", {
      timeZone: "America/Los_Angeles"
    }).slice(0, 10);
    const formattedDate = `${new Date(pstDate).getFullYear()}-${`0${new Date(pstDate).getMonth() + 1}`.slice(-2)}-${`0${new Date(pstDate).getDate()}`.slice(-2)}`;

    if (this.effectiveDate < formattedDate) {
     effectiveDateCmp.setCustomValidity(EFFECTIVE_DATE_ERROR);
   } else {
     effectiveDateCmp.setCustomValidity("");
   }
   effectiveDateCmp.reportValidity();

    this.effectiveDateVisible = this.effectiveDate !== null && this.effectiveDate >= formattedDate ? true : false;
   this.disableSubmmitButton();
 }

  handleCaseSelected(event) {
    const selectedCaseRecord = event.detail;
    this.soSupportCaseId = selectedCaseRecord ? selectedCaseRecord.id : null;
    this.caseVisible = this.soSupportCaseId !== null ? true : false;
    this.disableSubmmitButton();
  }

  handleCaseRemoved() {
    this.caseVisible = false;
    this.soSupportCaseId = null;
    this.disableSubmmitButton();
  }

  handleCellChange(event) {
    let updatedFields = event.detail.draftValues;
    updatedFields.forEach((draft) => {
      if (draft.UpdatedActiveCommission !== undefined) {
        this.mapUpdatedActiveCommission.set(draft.Id, draft.UpdatedActiveCommission);
        if (draft.UpdatedActiveCommission === "" && this.mapUpdatedActiveCommission.has(draft.Id)) {
          this.mapUpdatedActiveCommission.delete(draft.Id);
        }
      }
    if (draft.UpdatedActiveFee !== undefined) {
      this.mapUpdatedActiveFee.set(draft.Id, draft.UpdatedActiveFee);
      if (draft.UpdatedActiveFee === "" && this.mapUpdatedActiveFee.has(draft.Id)) {
        this.mapUpdatedActiveFee.delete(draft.Id);
      }
    }
  });
   this.submitButtonVisible = this.mapUpdatedActiveFee.size > 0 || this.mapUpdatedActiveCommission.size > 0 ? true : false;
   this.disableSubmmitButton();
 }

  closeAction() {
    this.dispatchEvent(
      new ShowToastEvent({
        title: 'Success',
        message: 'Accounts With Revised Fee is getting Updated. Please refresh to view the details',
        variant: 'Success',
      }),
    );
    const closeQA = new CustomEvent('close');
    this.dispatchEvent(closeQA);
  }

  disableSubmmitButton() {
    this.submitButtonDisable = this.submitButtonVisible && this.effectiveDateVisible && this.caseVisible ? false : true;
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

}