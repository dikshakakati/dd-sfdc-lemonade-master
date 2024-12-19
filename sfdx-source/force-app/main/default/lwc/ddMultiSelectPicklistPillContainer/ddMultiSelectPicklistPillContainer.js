/**
 * @author Sanidhya Jain
 * @date   Sept 2024
 * @decription Child of ddMultiSelectPicklist component, has the Pills with selected records
 */

/*****************************************************************************************************************************
 *
 * Imports
 *
 *****************************************************************************************************************************/
import { LightningElement,api } from 'lwc';
import { stringIsNotBlank } from 'c/lwcDdUtils';
import { BLANK_STRING } from 'c/lwcDdConst';

/*****************************************************************************************************************************
 *
 * CSS Class Consts
 *
 *****************************************************************************************************************************/
const MAINDIV_CLASS = 'slds-var-m-top_x-small display-flex ';

/*****************************************************************************************************************************
 *
 * Functional Consts
 *
 *****************************************************************************************************************************/
const EQUALS = 'Equals';
const DOES_NOT_EQUAL = 'Does Not Equal';

export default class DdMultiSelectPicklistPillContainer extends LightningElement {
    /*****************************************************************************************************************************
     *
     * Public Variables
     *
     *****************************************************************************************************************************/
   // {DD_Multi_Select_Picklist_Master_Mdt}
    @api searchInfo;
    // {Integer} Used to highlight Pill
    @api pillFocusIndex;
    // {String} label variant in the parent component
    @api labelVariant;

    // {CDdMultiSelectPicklistWrapper[]}
    _selectedRecords = [];
    get selectedRecords() {
        return this._selectedRecords;
    }
    @api
    set selectedRecords(value) {
        if (!value)
            value = [];
        this._selectedRecords = value;
        this.setSelectedRecordsWithOperators();
    }

    /*****************************************************************************************************************************
     *
     * Private Variables
     *
     *****************************************************************************************************************************/
    _selectedRecordsWithOperators = [];
    get selectedRecordsWithOperators() {
        return this._selectedRecordsWithOperators;
    }

    /*****************************************************************************************************************************
     *
     * Lifecycle Hooks
     *
     *****************************************************************************************************************************/
    isSearchInfoAvailable = false;
    renderedCallback() {
        if (this.isSearchInfoAvailable == false) {
            if (this.searchInfo) {
                this.isSearchInfoAvailable = true;
                this.setSelectedRecordsWithOperators();
            }
        }
    }

    /*****************************************************************************************************************************
     *
     * UI Getters
     *
     *****************************************************************************************************************************/
    get mainDivClass() {
        return (stringIsNotBlank(this.fieldLabelVariant) ?
            MAINDIV_CLASS +
            (this.searchInfo && this.searchInfo.Dropdown_Selected_Additional_CSS__c ?
                this.searchInfo.Dropdown_Selected_Additional_CSS__c : BLANK_STRING) : BLANK_STRING);
    }

    /*****************************************************************************************************************************
     *
     * Logic/Helper Method
     *
     *****************************************************************************************************************************/

    // If component has advanced operators, method helps display the values with proper parenthesis with AND OR text
    setSelectedRecordsWithOperators() {
        if (!this.searchInfo)
            return;
        let selectedRecords = this.selectedRecords;
        if (selectedRecords.length > 0 && this.searchInfo.Filter_Allow_Advanced_Operators__c) {
            let selectedRecordsWithOperators = new Array();
            if (selectedRecords.length == 1) {
                selectedRecordsWithOperators.push({
                    textBefore: null,
                    item: selectedRecords[0],
                    textAfter: null,
                });
            } else {
                for (let i = 0; i < selectedRecords.length; i++) {
                    let lastItem = (i == (selectedRecords.length - 1));
                    let item = selectedRecords[i];
                    let nextItem = lastItem ? null : selectedRecords[i+1];
                    if (!stringIsNotBlank(item.operator))
                        item.operator = EQUALS;

                    let textBefore = (i === 0) ? '(' : BLANK_STRING;
                    let textAfter = BLANK_STRING;
                    if (lastItem)
                        textAfter = ')';
                    else {
                        if (item.operator === EQUALS && nextItem.operator === item.operator)
                            textAfter = 'OR';
                        else if (item.operator === DOES_NOT_EQUAL && nextItem.operator === item.operator)
                            textAfter = ' AND ';
                        else
                            textAfter = ') AND (';
                    }
                    selectedRecordsWithOperators.push({
                        textBefore: textBefore,
                        item: item,
                        textAfter: textAfter,
                    });
                }
            }
            this._selectedRecordsWithOperators = selectedRecordsWithOperators;
        }
    }
}