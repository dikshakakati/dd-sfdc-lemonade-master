import { LightningElement, wire, api } from 'lwc';
import fetchAccountResultsList from '@salesforce/apex/DisplayAccountsController.fetchAccountResultsList'
import { updateRecord } from 'lightning/uiRecordApi'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex'
const columns = [

    { label: 'Name', fieldName: 'Name', editable: false },
    { label: 'Hours of Operation', fieldName: 'Hours_of_Operation__c', editable: true },
    { label: 'Proposed Date of Activation', fieldName: 'Proposed_Date_of_Activation__c', editable: true },
    { label: 'Legal Business Name', fieldName: 'Legal_Business_Name__c', editable: true }
]

export default class DisplayAccountResultsTable extends LightningElement {

    columns = columns
    draftValues = []
    ids = []
    @api
    get results() {
        return this._results;
    }

    set results(results) {
        this._results = results;
        this.ids = results.map(row => row.Id);
    }



    @wire(fetchAccountResultsList, { ids: '$ids' })
    oppty;

    handleSave(event) {
        console.log(event.detail.draftValues)
        const recordInputs = event.detail.draftValues.slice().map(draft => {
            const fields = Object.assign({}, draft)
            return { fields }
        })
        console.log("recordInputs", recordInputs)

        const promises = recordInputs.map(recordInput => updateRecord(recordInput))
        Promise.all(promises).then(result => {
            this.showToastMsg('Success', 'Account updated')
            this.draftValues = []
            return refreshApex(this.oppty)
        }).catch(error => {
            this.showToastMsg('Error creating record', error.body.message, error)
        })
    }
    showToastMsg(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant || 'success'
            })
        )
    }



}