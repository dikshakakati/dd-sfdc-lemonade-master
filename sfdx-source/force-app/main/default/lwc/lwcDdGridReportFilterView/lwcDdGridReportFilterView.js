/**
 * @author Sanidhya Jain
 * @date   Sept 2024
 * @decription Table displaying the filter information.
 */ 

/*****************************************************************************************************************************
 *
 * Imports
 *
 *****************************************************************************************************************************/

import { LightningElement,api,track } from 'lwc';
import { stringIsBlank,stringIsNotBlank,isUndefinedOrNull } from 'c/lwcDdUtils';
import { BLANK_STRING, YES, NO } from 'c/lwcDdConst';

/*****************************************************************************************************************************
 *
 * CSS Class Consts
 *
 *****************************************************************************************************************************/

const TABLE_FULL_HEIGHT = 'table-fullHeight';
const TABLE_70_HEIGHT = 'table-70Height';
/*****************************************************************************************************************************
 *
 * Functional Consts
 *
 *****************************************************************************************************************************/
const TOGGLE = 'Toggle';
const MULTISELECT = 'MultiSelect Picklist';
const PERCENT = 'Percent';
const NUMBER = 'Number';
const DATETIME = 'DateTime';
const DATE = 'Date';
const EQUALS = 'Equals';
const DOES_NOT_EQUAL = 'Does Not Equal';

export default class LwcDdGridReportFilterView extends LightningElement {
    /*****************************************************************************************************************************
     *
     * Public Variables
     *
     *****************************************************************************************************************************/

    _filterConfiguration = [];
    get filterConfiguration() {
        return this._filterConfiguration;
    }
    @api
    set filterConfiguration(value) {
        this._filterConfiguration = value;
        this.setFilterData();
    }

    _sortConfiguration = {
        sortedBy : BLANK_STRING,
        sortDirection: 'asc'
    };
    get sortConfiguration() {
        return this._sortConfiguration;
    }
    @api
    set sortConfiguration(value) {
        this._sortConfiguration = value;
        this.setSortData();
    }

    _fieldConfiguration = [];
    get fieldConfiguration() {
        return this._fieldConfiguration;
    }
    @api
    set fieldConfiguration(value) {
        this._fieldConfiguration = value;
        this.setSortData();
    }

    _savedSearchJsonString;
    get savedSearchJsonString() {
        return this._savedSearchJsonString;
    }
    @api
    set savedSearchJsonString(value) {
        this.parseSavedSearchJsonString(value);
        this._savedSearchJsonString = value;
    }

    /*****************************************************************************************************************************
     *
     * private Variables
     *
     *****************************************************************************************************************************/
    @track filterData = [];
    @track sortData = {
        sortedByLabel: BLANK_STRING,
        sortDirectionLabel: 'Ascending'
    };

    /*****************************************************************************************************************************
     *
     * UI Getters
     *
     *****************************************************************************************************************************/

    get tableClass() {
        return this.sortData && this.sortData.sortedByLabel ? TABLE_70_HEIGHT : TABLE_FULL_HEIGHT;
    }
    /*****************************************************************************************************************************
     *
     * Helper Methods
     *
     *****************************************************************************************************************************/

    setFilterData() {
        let rows = [];
        for (const filter of this.filterConfiguration) {
            let val;
            switch (filter.definition.Type__c) {
                case MULTISELECT:
                    val = [];
                    if (filter.value.length === 1) {
                        val.push({
                            textBefore: BLANK_STRING,
                            value: filter.value[0].pillLabel,
                            textAfter: BLANK_STRING
                        });
                        break;
                    };
                    for (let i = 0; i < filter.value.length; i++) {
                        let lastItem = (i == (filter.value.length - 1));
                        let item = filter.value[i];
                        let nextItem = lastItem ? null : filter.value[i+1];
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
                        val.push({
                            textBefore: textBefore,
                            value: item.pillLabel,
                            textAfter: textAfter,
                        });
                    }
                    break;
                case NUMBER:
                case PERCENT:
                case DATE:
                case DATETIME:
                    val = [];
                    for (const filterVal of filter.value) {
                        val.push(filterVal.label);
                    }
                    break;
                case TOGGLE:
                    if (!isUndefinedOrNull(filter.value)) {
                        val = [filter.value ? YES : NO];
                    }
                    break;
            }
            if (!isUndefinedOrNull(val) && (!Array.isArray(val) || (Array.isArray(val) && val.length > 0))) {
                const label = filter.definition.Type__c === MULTISELECT ?
                    filter.definition.MultiSelect_Ref__r.Field_Label__c : filter.definition.Label__c;
                rows.push({
                    label: label,
                    values: val,
                    isMultiSelect: filter.definition.Type__c === MULTISELECT
                })
            }
        }
        this.filterData = rows;
    }

    setSortData() {
        this.sortData.sortedByLabel = BLANK_STRING;
        if (!this.sortConfiguration || stringIsBlank(this.sortConfiguration.sortedBy) || !this.fieldConfiguration) {
            return;
        }
        this.sortData.sortDirectionLabel = this.sortConfiguration.sortDirection ?
            (this.sortConfiguration.sortDirection === 'asc' ? 'Ascending' : 'Descending') : BLANK_STRING;
        for (const field of this.fieldConfiguration) {
            if (this.sortConfiguration.sortedBy === field.apiName) {
                this.sortData.sortedByLabel = field.label;
                break;
            }
        }
    }

    parseSavedSearchJsonString(value) {

    }

}