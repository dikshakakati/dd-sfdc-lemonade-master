/**
 * @author Sanidhya Jain
 * @date   Sept 2024
 * @decription UI to accept one or more number/percent in a filter form
 */

/*****************************************************************************************************************************
 *
 * Imports
 *
 *****************************************************************************************************************************/

import { LightningElement,api,track } from 'lwc';
import { stringIsBlank,stringIsNotBlank,isUndefinedOrNull,cloneObject } from 'c/lwcDdUtils';
import { BLANK_STRING } from 'c/lwcDdConst';
import { loadScript } from 'lightning/platformResourceLoader';
import ASSETS from '@salesforce/resourceUrl/DdLightningResource';

/*****************************************************************************************************************************
 *
 * CSS Class Consts
 *
 *****************************************************************************************************************************/
const MAINDIV_CLASS = 'slds-var-p-around_small slds-border_top ';
const LABEL_CLASS = 'filter-label';
const EXPAND_BUTTON_CLASS = 'expand-button';
const LABEL_WITHPOINTER_CLASS = 'filter-label cursor-pointer';
const COLLAPSE_BUTTON_CLASS = 'collapse-button';

/*****************************************************************************************************************************
 *
 * Functional Consts
 *
 *****************************************************************************************************************************/
const EQUALS  = 'Equals';

const OPTIONS = [
    {label:"Equals",value:"Equals"},
    {label:"Less than",value:"Less than"},
    {label:"Greater than",value:"Greater than"},
    {label:"Less than or equals",value:"Less than or equals"},
    {label:"Greater than or equals",value:"Greater than or equals"},
    {label:"Between (and including)",value:"Between (and including)"}
];

const OPTIONS_WITH_ISBLANK_ISNOTBLANK = [
    {label:"Equals",value:"Equals"},
    {label:"Less than",value:"Less than"},
    {label:"Greater than",value:"Greater than"},
    {label:"Less than or equals",value:"Less than or equals"},
    {label:"Greater than or equals",value:"Greater than or equals"},
    {label:"Between (and including)",value:"Between (and including)"},
    {label:"Is Blank",value:"Is Blank"},
    {label:"Is Not Blank",value:"Is Not Blank"}
];

const OPERATOR_IS_BLANK = 'Is Blank';
const OPERATOR_IS_NOT_BLANK = 'Is Not Blank'
const OPERATOR_BETWEEN = 'Between (and including)';

const IS_BLANK = 'IS BLANK';
const IS_NOT_BLANK = 'IS NOT BLANK';
const BETWEEN = 'BETWEEN';

const OPERATOR_TEXT_TO_SYMBOL_MAP = new Map([
    ['Equals', '='],
    ['Less than', '<'],
    ['Greater than', '>'],
    ['Less than or equals', '<='],
    ['Greater than or equals', '>='],
    ['Between (and including)', 'BETWEEN'],
    ['Is Blank', 'IS BLANK'],
    ['Is Not Blank', 'IS NOT BLANK']
]);
const OPERATOR_SYMBOL_TO_TEXT_MAP = new Map([
    ['=','Equals'],
    ['<','Less than'],
    ['>','Greater than'],
    ['<=','Less than or equals'],
    ['>=','Greater than or equals'],
    ['BETWEEN','Between (and including)'],
    ['IS BLANK', 'Is Blank'],
    ['IS NOT BLANK', 'Is Not Blank']
]);

const ADD = 'Add';
const UPDATE = 'Update';
const PLACEHOLDER_NUMBER_TEXT = 'Example: 10,000';
const PLACEHOLDER_PERCENT_TEXT = 'Example: 50 = 50%';

const ELE_MINVALUEINPUT = '[data-id="minValueInput"]';
const ELE_MAXVALUEINPUT = '[data-id="maxValueInput"]';
const ELE_VALUEINPUT = '[data-id="valueInput"]';

const FORMAT_NUMBER = 'number';
const FORMAT_PERCENT = 'percent';

/*****************************************************************************************************************************
 *
 * @api Picklist Consts
 *
 *****************************************************************************************************************************/
const ALLOWED_FORMATS = new Set([FORMAT_NUMBER,FORMAT_PERCENT]);

export default class DdNumberFilter extends LightningElement {
    /*****************************************************************************************************************************
     *
     * Public Variables
     *
     *****************************************************************************************************************************/
    // {String} - (Required)helps parent identify this component
    @api uniqueIdentifier;
    // {String} - CSS classes to be applied to Main Div
    @api className;
    // {String} - Filter Label
    @api label;
    // {Boolean} - Show expanded/collapsed
    @api isExpanded = false;
    // {Number} - min value for the date range
    @api minValue;
    // {Number} - max value for date range
    @api maxValue;
    // {Object[]} - Filters passed from parent
    @track _filters = [];
    get filters() {
        return this._filters;
    }
    @api
    set filters(value) {
        value = value ? cloneObject(value) : [];
        this._filters = value;
    }
    // {String} - Filter Format - Number or Percent
    _formatter = FORMAT_NUMBER;
    get formatter() {
        return this._formatter;
    }
    @api
    set formatter(value) {
        value = (stringIsBlank(value) || !ALLOWED_FORMATS.has(value.toLowerCase())) ? NUMBER : value.toLowerCase();
        this._formatter = value;
    }
    // {Boolean} - choice multiple filter/single filter
    _allowMultipleFilters = true;
    get allowMultipleFilters() {
        return this._allowMultipleFilters;
    }
    @api
    set allowMultipleFilters(value) {
        if (isUndefinedOrNull(value)) {
            value = true;
        }
        this._allowMultipleFilters = value;
    }
    // {Boolean} - has the + - expand collapse UI
    _hasExpandCollapse = true;
    get hasExpandCollapse() {
        return this._hasExpandCollapse;
    }
    @api
    set hasExpandCollapse(value) {
        if (isUndefinedOrNull(value)) {
            value = true;
        }
        this._hasExpandCollapse = value;
    }
    // {Boolean} - Allow the Is Blank and Is Not Blank operators
    _allowIsBlankAndIsNotBlank = true;
    get allowIsBlankAndIsNotBlank() {
        return this._allowIsBlankAndIsNotBlank;
    }
    @api
    set allowIsBlankAndIsNotBlank(value) {
        if (isUndefinedOrNull(value))
            value = true;
        this._allowIsBlankAndIsNotBlank = value;
    }

    /*****************************************************************************************************************************
     *
     * Public Methods
     *
     *****************************************************************************************************************************/
    /**
     * @decription Clear/Reset Filters
     * @param   None
     * @return  None
     */
    clear() {
        this.filters = [];
        this.filterDefinition = this.getDefaultFilterDefinition();
        this.resetLightningInput(null);
        this.resetValidity();
        this.operator = EQUALS;
        this.notifyParent();
    }

    /*****************************************************************************************************************************
     *
     * Private Variables
     *
     *****************************************************************************************************************************/
    filterDefinition = this.getDefaultFilterDefinition();
    operator = EQUALS;

    /*****************************************************************************************************************************
     *
     * LifeCycle Hooks
     *
     *****************************************************************************************************************************/
    externalJSAdded = false;
    filterDefinitionSet = false;
    renderedCallback() {
        if (!this.externalJSAdded) {
            this.externalJSAdded = true;
            Promise.all([
                loadScript(this, ASSETS + '/js/numeral.js'),
                loadScript(this, ASSETS + '/js/formatNumber.js')
            ]).then(() => {
            })
            .catch(error => {
                console.log('Cannot load Numeral.js and FormatNumber.js',error);
            });
        }
        if (!this.filterDefinitionSet) {
            this.filterDefinitionSet = true;
            if (!this.allowMultipleFilters && this._filters && this._filters.length) {
                this.operator = OPERATOR_SYMBOL_TO_TEXT_MAP.get(this._filters[0].operator);
                this.filterDefinition = this._filters[0];
            }
        }
    }

    /*****************************************************************************************************************************
     *
     * UI Getters
     *
     *****************************************************************************************************************************/
    get mainDivClass() {
        return MAINDIV_CLASS + (this.className ? this.className : BLANK_STRING);
    }

    get showLabelSection() {
        return stringIsNotBlank(this.label) || this.hasExpandCollapse;
    }

    get labelClass() {
        return this.hasExpandCollapse ? LABEL_WITHPOINTER_CLASS : LABEL_CLASS;
    }

    get expandCollapseClass() {
        return this.isExpanded ? COLLAPSE_BUTTON_CLASS : EXPAND_BUTTON_CLASS;
    }

    get hasFilters() {
        return this.filters && this.filters.length;
    }

    get operatorOptions() {
        return this.allowIsBlankAndIsNotBlank ? OPTIONS_WITH_ISBLANK_ISNOTBLANK : OPTIONS;
    }

    get isOperatorIsBlankOrIsNotBlank() {
        return this.operator === OPERATOR_IS_BLANK|| this.operator === OPERATOR_IS_NOT_BLANK;
    }

    get showMinAndMaxValueInput() {
        return this.operator === OPERATOR_BETWEEN;
    }

    get placeholderText() {
        return this.formatter === FORMAT_NUMBER ? PLACEHOLDER_NUMBER_TEXT : PLACEHOLDER_PERCENT_TEXT;
    }

    get showValueInput() {
        return this.operator !== OPERATOR_BETWEEN;
    }

    get primaryButtonLabel() {
        return this.filterDefinition.label ? UPDATE : ADD;
    }

    get showRemoveButton() {
        return stringIsNotBlank(this.filterDefinition.label) && !this.allowMultipleFilters;
    }

    /*****************************************************************************************************************************
     *
     * Event Handlers
     *
     *****************************************************************************************************************************/

    // Toggle expand/collapse of filter
    handleButtonToggle() {
        if (this.hasExpandCollapse)
            this.isExpanded = !this.isExpanded;
    }

    // When the pill is clicked, render the pill definition in the filter fields
    handleFilterPillClick(event) {
        event.stopPropagation();
        const selectedFilterLabel = event.detail.uniqueIdentifier;
        let filterToOpen = null;
        for (let i = 0; i < this.filters.length; i++) {
            if (this.filters[i].label === selectedFilterLabel) {
                filterToOpen = this.filters[i];
                break;
            }
        }
        if (filterToOpen) {
            this.isExpanded = true;
            this.filterDefinition = filterToOpen;
            this.operator = OPERATOR_SYMBOL_TO_TEXT_MAP.get(filterToOpen.operator);
        }
    }

    // When the pill remove is clicked, remove the item from filters and notify parent
    handleFilterPillOnRemove(event) {
        event.stopPropagation();
        const selectedFilterLabel = event.detail.uniqueIdentifier;
        for (let i = 0; i < this._filters.length; i++) {
            if (this._filters[i].label === selectedFilterLabel) {
                this._filters.splice(i, 1);
            }
        }
        if (this.filterDefinition.label === selectedFilterLabel) {
            this.filterDefinition = this.getDefaultFilterDefinition();
            this.resetValidity();
        }

        this.notifyParent();
    }

    // When operator changes, set/reset filter fields
    handleOperatorOnChange(event) {
        event.stopPropagation();
        const operator = event.detail.value;
        if (operator === OPERATOR_IS_BLANK || operator === OPERATOR_IS_NOT_BLANK) {
            this.filterDefinition.value = null;
            this.filterDefinition.minValue = null;
            this.filterDefinition.maxValue = null;
            this.resetLightningInput(null);
        } else if (operator === OPERATOR_BETWEEN) {
            this.filterDefinition.value = null;
            this.resetLightningInput([ELE_VALUEINPUT]);
        } else {
            this.filterDefinition.minValue = null;
            this.filterDefinition.maxValue = null;
            this.resetLightningInput([ELE_MAXVALUEINPUT,ELE_MINVALUEINPUT]);
        }
        this.filterDefinition.operator = this.getOperatorSymbolForText(operator);
        this.operator = operator;
    }

    // When user is setting a date, then value it
    handleValueInputChange(event) {
        event.stopPropagation();
        this.filterDefinition.value = event.target.value ? event.target.value : BLANK_STRING;
        this.checkValidity(ELE_VALUEINPUT,this.filterDefinition.value);
    }

    // When user is setting a date, then value it
    handleMaxValueInputChange(event) {
        event.stopPropagation();
        this.filterDefinition.maxValue = event.target.value ? event.target.value : BLANK_STRING;
        this.checkValidity(ELE_MAXVALUEINPUT,this.filterDefinition.maxValue);
    }

    // When user is setting a date, then value it
    handleMinValueInputChange(event) {
        event.stopPropagation();
        this.filterDefinition.minValue = event.target.value ? event.target.value : BLANK_STRING;
        this.checkValidity(ELE_MINVALUEINPUT,this.filterDefinition.minValue);
    }

    // When remove button is clicked
    handleRemoveButtonClick(event) {
        event.stopPropagation();
        this.clear();
    }

    // When Add/Update button is clicked
    handlePrimaryButtonClick(event) {
        event.stopPropagation();
        if (!this.validateInput())
            return;
        if (this.primaryButtonLabel === ADD) {
            this.setFilterDefinitionLabel();
            if (this.validateDupe())
                return;
            this._filters.push(this.filterDefinition);
        } else {
            this.setFilterDefinitionLabel();
        }
        if (this.allowMultipleFilters) {
            this.filterDefinition = this.getDefaultFilterDefinition();
            this.operator = EQUALS;
            this.resetLightningInput(null);
        } else {
            this.filterDefinition = this._filters[0];
        }
        this.resetValidity();
        this.notifyParent();
    }

    // Generic stop prop event
    stopPropagation(event) {
        event.stopPropagation();
    }

    /*****************************************************************************************************************************
     *
     * Logic / Helper methods
     *
     *****************************************************************************************************************************/

    /**
     * @decription Gets the symbol for the text - ex. Equals => =
     * @param   {String} text - Text value
     *          {String} - Corresponding Symbol
     * @return  None
     */
    getOperatorSymbolForText(text) {
        return OPERATOR_TEXT_TO_SYMBOL_MAP.get(text);
    }

    /**
     * @decription Gets the text for symbol - ex. = => Equals
     * @param   {String} text - Symbol/Operator
     *          {String} - Corresponding text
     * @return  None
     */
    getOperatorTextForOperator(symbol) {
        return OPERATOR_SYMBOL_TO_TEXT_MAP.get(symbol);
    }

    /**
    * @decription Sets the Label for the filter, which is also passed to the pill to display
    * @param   None
    * @return  None
    */
    setFilterDefinitionLabel() {
        if (this.isFilterDefinitionOperatorIsBlankOrIsNotBlank())
            filter.label = filter.operator;
        else
            this.filterDefinition.label = this.filterDefinition.operator === BETWEEN ?
            'Between ' + this.commafyNumber(this.filterDefinition.minValue) + ' AND ' + this.commafyNumber(this.filterDefinition.maxValue) :
            this.filterDefinition.operator + ' ' + this.commafyNumber(this.filterDefinition.value);
    }

    /**
    * @decription returns Empty Filter definition
    * @param   None
    * @return  {Object} - Empty filter definition
    */
    getDefaultFilterDefinition() {
        return {
            label:BLANK_STRING,
            operator:'=',
            value:null,
            minValue:null,
            maxValue:null
        };
    }

    /**
    * @decription Notifies parent of change
    * @param   None
    * @return  None
    */
    notifyParent() {
        const evt = new CustomEvent("change",{
            detail: {
                uniqueIdentifier:this.uniqueIdentifier,
                selectedFilters:this.filters
            }
        });
        this.dispatchEvent(evt);
    }

    /**
    * @decription Prevents user from adding the same filter twice
    * @param   None
    * @return  {Boolean} - true = no dupe
    */
    validateDupe() {
        for (let item of this.filters) {
            if (this.filterDefinition.label === item.label)
                return true;
        }
        return false;
    }

    /**
    * @decription Validates the input based on rules (required, min/max)
    * @param   None
    * @return  {Boolean} - true = valid
    */
    validateInput() {
        if (this.isFilterDefinitionOperatorIsBlankOrIsNotBlank())
            return true;

        let isValid = true;
        const maxValue = this.getFloatNull(this.filterDefinition.maxValue);
        const minValue = this.getFloatNull(this.filterDefinition.minValue);

        if (this.filterDefinition.operator === BETWEEN && maxValue && minValue) {
            let ele = this.template.querySelector(ELE_MAXVALUEINPUT);
            isValid = (maxValue > minValue);
            ele.setCustomValidity(isValid ? BLANK_STRING : 'Should be greater than minimum.');
            ele.reportValidity();
        }

        isValid = isValid && ((this.filterDefinition.operator === BETWEEN) ?
            this.validateInput_Helper([ELE_MAXVALUEINPUT,ELE_MINVALUEINPUT]) :
            this.validateInput_Helper([ELE_VALUEINPUT]));

        return isValid;
    }

    /**
    * @decription Validates the input based on rules - required in this case
    * @param   {String[]} - Names of the input fields to validate
    * @return  {Boolean} - true = valid
    */
    validateInput_Helper(controls) {
        let isValid = true;
        for (let controlId of controls) {
            let value = BLANK_STRING;
            switch (controlId) {
                case ELE_MAXVALUEINPUT:
                    value = this.filterDefinition.maxValue;
                    break;
                case ELE_MINVALUEINPUT:
                    value = this.filterDefinition.minValue;
                    break;
                default:
                    value = this.filterDefinition.value;
                    break;
            }
            let ele = this.template.querySelector(controlId);
            if (ele) {
                ele.setCustomValidity(value ? BLANK_STRING : 'Field is required');
                ele.reportValidity();
                ele.showHelpMessageIfInvalid();
                isValid = isValid && ele.checkValidity();
            }
        }
        return isValid;
    }

    /**
    * @decription Validates the input and updates UI
    * @param   {String} - Name of the input fields to validate
    *          {Date} - Date of the field
    * @return  NONE
    */
    checkValidity(controlId,value) {
        let ele = this.template.querySelector(controlId);
        if (ele) {
            ele.setCustomValidity(value ? BLANK_STRING : 'Field is required');
            ele.reportValidity();
        }
    }

    /**
    * @decription Removes all validation errors in UI
    * @param   None
    * @return  None
    */
    resetValidity() {
        let controls = [ELE_MAXVALUEINPUT,ELE_MINVALUEINPUT,ELE_VALUEINPUT];
        for (let controlId of controls) {
            let ele = this.template.querySelector(controlId);
            if (ele) {
                ele.setCustomValidity(BLANK_STRING);
                ele.reportValidity();
            }
        }
    }

    /**
    * @decription Resets input fields
    * @param   {String[]} Names of control/fields to reset
    * @return  None
    */
    resetLightningInput(controls) {
        let isValid = true;
        if (controls) {
            for (let controlId of controls) {
                let ele = this.template.querySelector(controlId);
                if (ele) {
                    ele.value = BLANK_STRING;
                }
            }
        } else {
            this.template.querySelectorAll('lightning-input').forEach(each => {
                each.value = BLANK_STRING;
            });
        }
    }

    /**
    * @decription Commafy the number
    * @param   {Object} val
    * @return  {String} - Commafied Number
    */
    commafyNumber(val) {
        return this.formatter === FORMAT_PERCENT ? formatNumber(val) + '%' : formatNumber(val);
    }

    /**
    * @decription return float from commafied number
    * @param   {String} val
    * @return  {Float} - returns 0 if val is null
    */
    getFloat(val) {
        return val ? parseFloat(formatNumber(val).replace(/,/g, BLANK_STRING)) : 0;
    }

    /**
    * @decription return float from commafied number
    * @param   {String} val
    * @return  {Float} - returns null if val is null
    */
    getFloatNull(val) {
        return val != null && window.formatNumber(val) != null ?
            parseFloat(window.formatNumber(val).replace(/,/g, BLANK_STRING)) : null;
    }

    /**
    * @decription Checking if operator is blank or is not blank
    * @param   None
    * @return  {Boolean}
    */
    isFilterDefinitionOperatorIsBlankOrIsNotBlank() {
        return this.filterDefinition.operator === IS_NOT_BLANK || this.filterDefinition.operator === IS_BLANK;
    }

}