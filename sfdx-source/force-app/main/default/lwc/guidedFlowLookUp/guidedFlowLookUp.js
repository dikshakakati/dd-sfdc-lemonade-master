import { LightningElement, api, wire } from "lwc";
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import { publish, MessageContext } from 'lightning/messageService';
import selectedLookUpRecord from '@salesforce/messageChannel/Lookup_Event__c';
export default class GuidedFlowLookUp extends LightningElement {
    @api recordId;
    @api objectName = "Account";
    @api label = "Account"
    @api placeholder;
    @api displayInfo;
    @api matchingInfo;
    @api filter;
    @api globalSearch;
    @api selectedId;
    @api defaultValue;
    filterValue = null;
    @wire(MessageContext)
    messageContext;
    /**
    * @description Set Filter Value for the component
    */
    connectedCallback() {
        if (this.filter && !this.globalSearch) {
            this.filterValue = JSON.parse(this.filter);
        }

    }
    /**
    * @description Set Display Value of Lookup Filter
    */
    get displayInfoValue() {
        if (this.displayInfo) {
            return JSON.parse(this.displayInfo);
        }
        return null;
    }
    /**
    * @description Set Matching Value for the component
    */
    get matchingInfoValue() {
        if (this.matchingInfo) {
            return JSON.parse(this.matchingInfo);
        }
        return null;
    }
    /**
    * @description Set Selected Value for the component
    */
    handleSelect = (event) => {
        event.preventDefault();
        let selectedId = event.detail.recordId;
        const payload = { "selectedRecordId": selectedId, "selectedObjectName": this.objectName };
        console.log('payload=', payload);
        publish(this.messageContext, selectedLookUpRecord, payload);
        const attributeChangeEvent = new FlowAttributeChangeEvent('selectedId', selectedId);
        this.dispatchEvent(attributeChangeEvent);
    }
    /**
    * @description Set focus on Selected value
    */
    handleFocus(event) {
        event.preventDefault();
        //alert(this.globalSearch);
        if (!this.globalSearch) {
            this.filterValue.criteria[0].value = this.recordId;
            let lookupComponent = this.refs.lookup;
            if (lookupComponent) {
                lookupComponent.filter = this.filterValue;
            }
        }

    }
}