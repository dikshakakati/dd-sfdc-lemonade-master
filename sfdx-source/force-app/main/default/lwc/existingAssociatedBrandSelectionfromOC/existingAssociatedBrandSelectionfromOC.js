import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import fetchExistingBrands from "@salesforce/apex/CreateBrandAndBusinessIdController.fetchExistingAssociatedBrands";
import OWNER_FIELD from "@salesforce/schema/Opportunity.AccountId";
import CURRENCY_FIELD from "@salesforce/schema/Opportunity.Account.CurrencyIsoCode";
import { CloseActionScreenEvent } from 'lightning/actions';

const OPPORTUNITY_OBJECT = "Opportunity";
const CONTRACT_OBJECT = "Contract";
const NEXT_EVENT_NAME = 'nextevent';

export default class BrandTable extends LightningElement {
    rowHeading = {
        name: 'Brand Name',
        rowSelection: 'Select',
    }
    @track selectedRows = [];
    @track selectedBrandAssociationId;
    @track selectedBrandId;
    @track selectedBrandName;
    @api recordId;
    @api existingBrands = [];

    /**
    * @description It is used to get Oppirtunity record details.
    */
    @wire(getRecord, { recordId: "$recordId", fields: [OWNER_FIELD, CURRENCY_FIELD] })
    record;


    /**
    * @description It is used to fetch account id.
    */
    get accountId() {
        return getFieldValue(this.record.data, OWNER_FIELD);
    }

    get currency() {
        return getFieldValue(this.record.data, CURRENCY_FIELD);
    }

    /**
    * @description It is used to handle cancel button event.
    */
    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    /**
    * @description It is used to handle next button event and it is declared with api.
    */
    @api
    handleNext() {
        if (this.selectedBrandAssociationId) {
            const brand = this.existingBrands.find(item => item.brandAssociationId == this.selectedBrandAssociationId);


            this.dispatchEvent(new CustomEvent(NEXT_EVENT_NAME, {
                detail: {
                    rowSelected: true,
                    selectedBrandAssociation: this.selectedBrandAssociationId,
                    selectedBrand: this.selectedBrandId,
                    selectedBrandName: this.selectedBrandName,
                }
            }
            ));
        }
        else {
            this.dispatchEvent(new CustomEvent(NEXT_EVENT_NAME, {
                detail: {
                    rowSelected: false
                }
            }
            ));
        }

    }


    /**
    * @description It is used to handle change in checkbox/row selection.
    */
    handleCheckboxChange(event) {
        const isChecked = event.target.checked;
        const brandAssociationId = event.target.dataset.id;
        const brandId = event.target.dataset.brandId;

        // Update the selected row and mark it as checked
        this.existingBrands = this.existingBrands.map(row => ({
            ...row,
            isChecked: row.brandAssociationId === brandAssociationId ? isChecked : false
        }));

        // Update the selected row ID
        this.selectedBrandAssociationId = isChecked ? brandAssociationId : null;
        this.selectedBrandId = isChecked ? brandId : null;
        this.selectedBrandName = isChecked ? event.target.dataset.brandName : null;

    }
}