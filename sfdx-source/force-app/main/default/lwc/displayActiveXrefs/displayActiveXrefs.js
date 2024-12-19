import { LightningElement, wire, api, track } from "lwc";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import NAME_FIELD from "@salesforce/schema/Account.Name";
import SEGMENT_FIELD from "@salesforce/schema/Account.Segment__c";
import getFields from "@salesforce/apex/DisplayActiveXrefController.getFields";
import getXrefDetails from "@salesforce/apex/DisplayActiveXrefController.getXrefDetails";
import relatedStoreIds from "@salesforce/label/c.Related_Active_Store_IDs";
import createLog from "@salesforce/apex/LogController.createLog";

const LWC_NAME = "ActiveXrefList";
const GET_FIELD_SET_FIELDS = "getFieldSetFields";
const GET_XREF_DETAILS = "getXrefDetails";
const UTILITY_TYPE = "utility:";
const TOAST_VARIANT = "error";
const SHOW_TOAST_MESSAGE_COMPONENT = "c-show-toast-message";

export default class DisplayActiveXrefs extends LightningElement {
    @api recordId;
    @api segment
    @api viewAll;
    @track relatedData = [];
    @track columns = [];
    @track viewAllColumns = [];
    showComponent = false;
    objectName = "Account";
    labels = {
        relatedStoreIds
    };

    /**
     * @description This method is used to get Account details.
     */
    @wire(getRecord, {
        recordId: "$recordId",
        fields: [NAME_FIELD, SEGMENT_FIELD]
    })
    account;

    /**
     * @description This method is used to get Account details.
     */
    get name() {
        let accountName = getFieldValue(this.account.data, NAME_FIELD);
        return accountName !== undefined ? accountName : null;
    }


    /**
     * @description This method is used to render view all records page
     */
    get viewAllRecords() {
        return this.viewAll !== undefined ? this.viewAll : false;
    }

    /**
    * @description This method is used to get columns to display
    */
    @wire(getFields, { segment: '$segment' })
    setFields({ error, data }) {
        if (data) {
            let allColumns = JSON.parse(data);
            allColumns.forEach((obj) => {
                obj.hideDefaultActions = false;
                obj.sortable = true;
            });
            this.viewAllColumns = [...allColumns];
            if (this.segment == 'SMB') {
                this.columns = [allColumns[0], allColumns[2], ...allColumns.slice(4, 7)];
            }
            else {
                this.columns = [...allColumns].splice(0, 5);
            }
        } else if (error) {
            createLog({
                lwcName: LWC_NAME,
                methodName: GET_FIELD_SET_FIELDS,
                message: JSON.stringify(error.body)
            });
            this.showToastMessage(TOAST_VARIANT, error.body.message, UTILITY_TYPE + TOAST_VARIANT);
        }
    }

    /**
     * @description This method is used to get active xrefs records to display
     */
    @wire(getXrefDetails, { recordId: '$recordId' })
    setXrefRecords({ error, data }) {
        if (data) {
            let allData = data.map((xref) => ({
                ...xref
            }));
            allData.forEach((obj) => {
                const mintStoreID = obj.MINT_Store_Page__c;
                if (typeof mintStoreID !== "undefined") {
                    obj.mintStorePageHyperlink = mintStoreID.substring(
                        mintStoreID.indexOf('href="') + 6,
                        mintStoreID.indexOf('" target'));
                    obj.MINT_Store_Page__c = mintStoreID.substring(
                        mintStoreID.indexOf('store/') + 6,
                        mintStoreID.indexOf('" target'));
                }

                const merchantPortalStoreID = obj.Merchant_Portal__c;
                if (typeof merchantPortalStoreID !== "undefined") {
                    obj.merchantPortalHyperlink = merchantPortalStoreID.substring(
                        merchantPortalStoreID.indexOf('href="') + 6,
                        merchantPortalStoreID.indexOf('" target')
                    );
                    obj.Merchant_Portal__c = merchantPortalStoreID.substring(
                        merchantPortalStoreID.indexOf('store_id=') + 9,
                        merchantPortalStoreID.indexOf('" target'));
                }

                const mintBusinessID = obj.Mint_BusinessPage__c;
                if (typeof mintBusinessID !== "undefined") {
                    obj.mintBusinessPageHyperlink = mintBusinessID.substring(
                        mintBusinessID.indexOf('href="') + 6,
                        mintBusinessID.indexOf('" target')
                    );
                    obj.Mint_BusinessPage__c = mintBusinessID.substring(
                        mintBusinessID.indexOf('business/') + 9,
                        mintBusinessID.indexOf('" target'));
                }
                const businessReferenceId = obj.Business_Reference__c;
                if (typeof businessReferenceId !== "undefined") {
                    obj.businessReferenceHyperlink = '/' + businessReferenceId;
                    obj.Business_Reference__c = obj.Business_Reference__r.Name;
                }
                const onlineOrderingBusinessPageId = obj.Online_Ordering_Business_Page__c;
                if (typeof onlineOrderingBusinessPageId !== "undefined") {
                    obj.onlineOrderingBusinessPageHyperlink = onlineOrderingBusinessPageId.substring(
                        onlineOrderingBusinessPageId.indexOf('href="') + 6,
                        onlineOrderingBusinessPageId.indexOf('" target')
                    );
                    obj.Online_Ordering_Business_Page__c = onlineOrderingBusinessPageId.substring(
                        onlineOrderingBusinessPageId.indexOf('business') + 9,
                        onlineOrderingBusinessPageId.indexOf('" target'));
                }
                const onlineOrderingStorePageId = obj.Online_Ordering_Store_Page__c;
                if (typeof onlineOrderingStorePageId !== "undefined") {
                    obj.onlineOrderingStorePageHyperlink = onlineOrderingStorePageId.substring(
                        onlineOrderingStorePageId.indexOf('href="') + 6,
                        onlineOrderingStorePageId.indexOf('" target')
                    );
                    obj.Online_Ordering_Store_Page__c = onlineOrderingStorePageId.substring(
                        onlineOrderingStorePageId.indexOf('onboarding') + 11,
                        onlineOrderingStorePageId.indexOf('" target'));
                }

            });
            this.relatedData = [...allData];
            this.showComponent = true;
        } else if (error) {
            createLog({
                lwcName: LWC_NAME,
                methodName: GET_XREF_DETAILS,
                message: JSON.stringify(error.body)
            });
            this.showToastMessage(TOAST_VARIANT, error.body.message, UTILITY_TYPE + TOAST_VARIANT);
        }
    }

    /**
      * @description This method is used to display toast message
      * @param titleVal
      * @param messageVal
      * @param variantVal
      * @param messageDataVal
      * @param modeVal
      */
    showToastMessage(taskVariant, messageVal, utilityType) {
        this.template.querySelector(
            SHOW_TOAST_MESSAGE_COMPONENT).showToast(
                taskVariant,
                messageVal,
                utilityType,
                10000
            );
    }
}