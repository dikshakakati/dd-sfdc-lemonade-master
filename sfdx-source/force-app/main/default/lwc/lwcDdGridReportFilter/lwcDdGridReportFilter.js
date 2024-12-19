/**
 * @author Sanidhya Jain
 * @date   Sept 2024
 * @decription Displays the filter definition and passes event to parent
 */

/*****************************************************************************************************************************
 *
 * Imports
 *
 *****************************************************************************************************************************/
import { LightningElement,api } from 'lwc';
import { cloneObject } from 'c/lwcDdUtils';

/*****************************************************************************************************************************
 *
 * Functional Consts
 *
 *****************************************************************************************************************************/

const MULTISELECT_PICKLIST = 'MultiSelect Picklist';
const DATE = 'Date';
const DATETIME = 'DateTime';
const NUMBER = 'Number';
const PERCENT = 'Percent';
const TOGGLE = 'Toggle';

export default class LwcDdGridReportFilter extends LightningElement {
    /*****************************************************************************************************************************
     *
     * Public Variables
     *
     *****************************************************************************************************************************/
    // {Object} (Required) - Filter Definition + Filter Value
    /*{
        'name': DD_Grid_Report_Filter__mdt.DeveloperName
        'definition': DD_Grid_Report_Filter__mdt
        'value': Object/[] - Object (Boolean,etc) or Array of selected values against this filter
    }*/
    @api filter;

    /*****************************************************************************************************************************
     *
     * private Variables
     *
     *****************************************************************************************************************************/

    get isMultiSelectFilter() {
        return this.filter.definition.Type__c === MULTISELECT_PICKLIST;
    }

    get isDateFilter() {
        return this.filter.definition.Type__c === DATE || this.filter.definition.Type__c === DATETIME;
    }

    get isNumberFilter() {
        return this.filter.definition.Type__c === NUMBER;
    }

    get isPercentFilter() {
        return this.filter.definition.Type__c === PERCENT;
    }

    get isPercentFilter() {
        return this.filter.definition.Type__c === PERCENT;
    }

    get isToggleFilter() {
        return this.filter.definition.Type__c === TOGGLE;
    }

    /*****************************************************************************************************************************
     *
     * Event Handlers
     *
     *****************************************************************************************************************************/

    // When Filter value is added or removed
    handleOnChange(event) {
        event.stopPropagation();
        let filter = cloneObject(this.filter);
        if (this.isToggleFilter) {
            filter.value = event.detail.checked;
        } else {
            let selectedFilters = this.isMultiSelectFilter ? event.detail.selectedOptions : event.detail.selectedFilters;
            filter.value = cloneObject(selectedFilters);
        }
        this.notifyParent(filter);
    }

    /*****************************************************************************************************************************
    *
    * Wire / Logic / Helper methods
    *
    *****************************************************************************************************************************/
    notifyParent = (filter) => {
        const evt = new CustomEvent("change",{
            detail: {
                item:filter
            }
        });
        this.dispatchEvent(evt);
    }
}