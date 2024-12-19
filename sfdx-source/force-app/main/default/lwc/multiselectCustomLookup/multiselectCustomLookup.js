/**
 * @author Deloitte
 * @date 12/06/2023
 * @description JavaScript controller for reusable custom multi-select lookup component for placing a type ahead search option.
 */
import { LightningElement, api, track } from 'lwc';
import { setMessage, setVariant, showNotification } from 'c/utils';
import separator from '@salesforce/label/c.Separator';
import toastVariantInfo from '@salesforce/label/c.Toast_Variant_Info';

const DROP_DOWN_CLASS_NAME = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open';
const KEY_LABEL = 'label';
const SEND_LABEL_EVENT_NAME = 'sendlabel';
const SEND_SEARCH_KEY_EVENT_NAME = 'sendsearchkey';
const TEXT_CLASS_NAME = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
export default class MultiselectCustomLookup extends LightningElement {
    @api allRecords;
    @api label;
    @api searchBoxPlaceholder;
    @api selectedRecords = [];
    @track autoCompleteOptions = [];
    @track selections = [];
    @track showMessage = false;
    @track textClassName = TEXT_CLASS_NAME;
    loadingText = false;

    /**
     * @description setter for activeComponentLabel
     * @param activeLabelFromParent
     */
    @api
    set activeComponentLabel(activeLabelFromParent) {
        if (activeLabelFromParent && activeLabelFromParent !== this.label) {
            this.textClassName = TEXT_CLASS_NAME;
        } else if (activeLabelFromParent === null) {
            this.textClassName = TEXT_CLASS_NAME;
        }
    }

    /**
     * @description getter for activeComponentLabel
     */
    get activeComponentLabel() {
        return this.label;
    }

    /**
     * @description To handle input click.
     * @JIRA# LEM-12109
     */
    handleClick(event) {
        event.preventDefault();
        event.stopPropagation();
        this.autoCompleteOptions = this.allRecords;
        this.textClassName = this.autoCompleteOptions.length > 0 ? DROP_DOWN_CLASS_NAME : TEXT_CLASS_NAME;
        this.dispatchEvent(
            new CustomEvent(SEND_LABEL_EVENT_NAME, {
                detail: this.label
            })
        );
    }

    /**
     * @description To handle input change.
     * @JIRA# LEM-10966
     */
    handleInputChange(event) {
        let inputValue = event.target.value;
        this.loadingText = true;
        // To filter in real time the list received from the wired Apex method
        this.autoCompleteOptions = this.allRecords.filter(item => item.label.toLowerCase().includes(inputValue.toLowerCase()));
        this.textClassName = this.autoCompleteOptions.length > 0 ? DROP_DOWN_CLASS_NAME : TEXT_CLASS_NAME;
        if (inputValue.length === 0) {
            this.textClassName = TEXT_CLASS_NAME;
        }
        this.loadingText = false;
        if (inputValue.length > 0 && this.autoCompleteOptions.length === 0) {
            this.showMessage = true;
        } else {
            this.showMessage = false;
        }
    }

    /**
     * @description To remove selected records.
     * @JIRA# LEM-10966
     */
    removeRecord(event) {
        let selectRecId = [];
        for (let i = 0; i < this.selectedRecords.length; i++) {
            if (event.detail.name !== this.selectedRecords[i].label)
                selectRecId.push(this.selectedRecords[i]);
        }
        this.selectedRecords = [...selectRecId];
        this.sendSearchKey();
    }

    /**
     * @description To send search key event.
     * @JIRA# LEM-10966
     */
    sendSearchKey() {
        this.selections = [];
        for (let iterator = 0; iterator < this.selectedRecords.length; iterator++) {
            if ((Object.prototype.hasOwnProperty.call(this.selectedRecords[iterator], KEY_LABEL))) {
                this.selections.push(this.selectedRecords[iterator][KEY_LABEL]);
            }
        }
        let allSelections = this.selections.join(separator);
        this.dispatchEvent(
            new CustomEvent(SEND_SEARCH_KEY_EVENT_NAME, {
                detail: allSelections
            })
        );

    }

    /**
     * @description To set selected records.
     * @JIRA# LEM-10966
     */
    setSelectedRecord(event) {
        let isDuplicate = false;
        let label = event.currentTarget.dataset.label;
        this.selectedRecords.forEach(function (eachRecord) {
            isDuplicate = isDuplicate || eachRecord.label === label;
        });
        if (!isDuplicate) {
            let newsObject = { 'label': label };
            this.selectedRecords = [...this.selectedRecords, newsObject];
            this.sendSearchKey();
        } else {
            setMessage(label + ' is already selected.');
            setVariant(toastVariantInfo);
            showNotification(this);
        }
        this.textClassName = TEXT_CLASS_NAME;
        this.template.querySelectorAll('lightning-input').forEach(each => {
            each.value = '';
        });
    }
}