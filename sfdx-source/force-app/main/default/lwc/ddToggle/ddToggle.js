/**
 * @author Sanidhya Jain
 * @date   Sept 2024
 * @decription Toggle/Switch Component, has 2 display formats - field and filter.
 */
/*****************************************************************************************************************************
 *
 * Imports
 *
 *****************************************************************************************************************************/

import { LightningElement,api } from 'lwc';
import { stringIsNotBlank } from 'c/lwcDdUtils';
import { BLANK_STRING,YES,NO } from 'c/lwcDdConst';

/*****************************************************************************************************************************
 *
 * CSS Class Consts
 *
 *****************************************************************************************************************************/

const MAINDIV_FIELD_CLASS = 'slds-form-element mainDiv ';
const MAINDIV_FILTER_CLASS = 'slds-var-p-around_small slds-border_top ';

const TOGGLE_FIELD_CLASS = 'slds-checkbox_toggle slds-grid';
const TOGGLE_FILTER_CLASS = 'slds-align_absolute-center slds-var-m-top_x-small slds-checkbox_toggle slds-grid';

const FILTERLABEL_WITHPOINTER_CLASS = 'filter-label cursor-pointer ';
const FILTER_LABEL_CLASS = 'filter-label';

const COLLAPSE_BUTTON_CLASS = 'collapse-button';
const EXPAND_BUTTON_CLASS = 'expand-button';

/*****************************************************************************************************************************
 *
 * Functional Consts
 *
 *****************************************************************************************************************************/
const RIGHT = 'right';
const LEFT = 'left';
const FIELD = 'field';
const FILTER = 'filter';

/*****************************************************************************************************************************
 *
 * @api Picklist Consts
 *
 *****************************************************************************************************************************/
const VARIANT_OPTIONS = new Set([FIELD,FILTER]);
const LABEL_POSITION_OPTIONS = new Set([RIGHT,LEFT]);

export default class DdToggle extends LightningElement {

    /*****************************************************************************************************************************
     *
     * Public Variable
     *
     *****************************************************************************************************************************/
    // {String} uniquely identifing this toggle
    @api uniqueIdentifier;
    // {String} Label
    @api label;
    // {String} CSS to apply to main div
    @api className;
    // {Boolean} Show as disabled
    @api disabled;
    // {Boolean} Show Expand Collapse
    @api hasExpandCollapse = false;
    // {Boolean} Filter selection required
    @api filterSelectionIsRequired;
    // {Boolean} Shows a text under the checkbox with the selection status as text
    @api showCheckedText = false;
    // {String} Checked text when checkbox is checked
    @api checkedTextTrue = YES;
    // {String} Checked text when checkbox is unchecked
    @api checkedTextFalse = NO;
    // {String} Variant of component
    _variant = FIELD;
    get variant() {
        return this._variant;
    }
    @api
    set variant(value) {
        this._variant = (stringIsNotBlank(value) && VARIANT_OPTIONS.has(value.toLowerCase())) ? value.toLowerCase() : FIELD;
    }
    // {String} Label Position (for field variant)
    _labelPosition = RIGHT;
    get labelPosition() {
        return this._labelPosition;
    }
    @api
    set labelPosition(value) {
        this._labelPosition = (stringIsNotBlank(value) && LABEL_POSITION_OPTIONS.has(value.toLowerCase())) ? value.toLowerCase() : ROGHT;
    }
    // {Boolean} Current checked state
    @api checked;

    /*****************************************************************************************************************************
     *
     * Private Variable
     *
     *****************************************************************************************************************************/

    applyFilter = false;
    isExpanded = false;

    /*****************************************************************************************************************************
     *
     * UI Getters
     *
     *****************************************************************************************************************************/
    get mainDivClass(){
        return (this.isFilterVariant ? MAINDIV_FILTER_CLASS : MAINDIV_FIELD_CLASS) +
            (this.className ? this.className : BLANK_STRING);
    }

    get filterLabelClass() {
        return this.hasExpandCollapse ? FILTERLABEL_WITHPOINTER_CLASS : FILTER_LABEL_CLASS;
    }

    get expandCollapseClass() {
        return this.isExpanded ? COLLAPSE_BUTTON_CLASS : EXPAND_BUTTON_CLASS;
    }

    get toggleClass() {
        return this.isFilterVariant ? TOGGLE_FILTER_CLASS : TOGGLE_FIELD_CLASS;
    }

    get showLabelOnLeft(){
        return !this.isFilterVariant && this.labelPosition === LEFT && stringIsNotBlank(this.label);
    }

    get showLabelOnRight(){
        return !this.isFilterVariant && this.labelPosition === RIGHT && stringIsNotBlank(this.label);
    }

    get isFilterVariant() {
        return this.variant === FILTER;
    }

    get applyFilterCheckedText() {
        return this.applyFilter ? YES : NO;
    }

    get collapsedPillText() {
        return this.isFilterVariant && !this.isExpanded && this.applyFilter ? (this.checked ? YES : NO) : null;
    }
    /*****************************************************************************************************************************
     *
     * LifeCycle Hooks
     *
     *****************************************************************************************************************************/

    processFilterConfigOnInit = false;

    renderedCallback() {
        if (!this.processFilterConfigOnInit) {
            this.processFilterConfigOnInit = true;
            if (!this.isFilterVariant) {
                this.isExpanded = true;
            } else {
                if (this.filterSelectionIsRequired) {
                    this.hasExpandCollapse = false;
                    this.isExpanded = true;
                } else {
                    if (this.checked) {
                        this.checked = false;
                        this.notifyParent();
                    }
                    this.disabled = true;
                    this.showCheckedText = true;
                    this.checkedTextFalse = "Disabled";
                    this.hasExpandCollapse = true;
                    this.isExpanded = false;
                }
            }
            this.applyFilter = this.filterSelectionIsRequired;
        }
    }

    /*****************************************************************************************************************************
     *
     * Event Handlers
     *
     *****************************************************************************************************************************/

    // Generic stop prop event
    stopEventPropagation(event) {
        event.stopPropagation();
    }

    // Toggle expand/collapse of filter
    handleFilterShowHideToggle() {
        if (this.hasExpandCollapse)
            this.isExpanded = !this.isExpanded;
    }

    // Handle Toggle change - Notify Parent
    handleOnClick(event) {
        event.stopPropagation();
        if (this.disabled)
            return;
        this.checked = event.target.checked;
        this.notifyParent();
    }

    // When 'apply filter' toggle is checked, then it enables the value filter; else it disables value filter
    handleApplyFilterOnClick(event) {
        this.applyFilter = event.target.checked;
        if (!this.applyFilter) {
            this.checked = false;
            this.disabled = true;
            this.checkedTextFalse = "Disabled";
        } else {
            this.disabled = false;
            this.checkedTextFalse = "No";
            this.checkedTextTrue = "Yes";
        }
        this.notifyParent();
    }

    /*****************************************************************************************************************************
     *
     * Helper Methods
     *
     *****************************************************************************************************************************/

    // Three states can exist - true/false (field variant / no apply filter toggle / apply filter toggle is displayed and checked) and
    //                          null (apply filter toggle is displayed and unchecked)
    notifyParent() {
        const isChecked = this.isFilterVariant ? (this.applyFilter ? this.checked : null) : this.checked;
        const clickEvt = new CustomEvent("click",{
            detail: {
                uniqueIdentifier:this.uniqueIdentifier,
                checked:isChecked
            }
        });
        this.dispatchEvent(clickEvt);
    }
}