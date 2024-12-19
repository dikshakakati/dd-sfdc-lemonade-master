/**
 * @author Sanidhya Jain
 * @date   Sept 2024
 * @decription Enhanced Pill Component - has features like Hover, Custom close button, Show/Hide Remove etc.
 */
/*****************************************************************************************************************************
 *
 * Imports
 *
 *****************************************************************************************************************************/
import { LightningElement,api } from 'lwc';
import { stringIsBlank, stringIsNotBlank } from 'c/lwcDdUtils';
import { BLANK_STRING } from 'c/lwcDdConst';

/*****************************************************************************************************************************
 *
 * CSS Class Consts
 *
 *****************************************************************************************************************************/
const CLASS_PILL = 'slds-pill dd-pill slds-var-p-left_x-small slds-var-m-around_xx-small';
const CLASS_WITHOUT_REMOVE_PILL = 'slds-pill dd-pill slds-var-p-left_x-small slds-var-p-right_x-small slds-var-m-around_xx-small';
const CLASS_PILL_HASFOCUS = ' slds-pill-has-focus ';
export default class DdPill extends LightningElement {
    /*****************************************************************************************************************************
     *
     * Public Variable
     *
     *****************************************************************************************************************************/
    // {String} String, uniquely identifing this pill
    @api uniqueIdentifier;
    // {String}
    @api label;
    // {String} - if you want to hyperlink out
    @api href;
    // {String}
    @api hrefTarget = "_Blank";
    // {Boolean}
    @api showRemove = false;
    // {String}
    @api avatarSrc = BLANK_STRING;
    // {String}
    @api avatarTitle = BLANK_STRING;
    // {String}
    @api iconName = BLANK_STRING;
    // {Boolean} Changes color on focus
    @api hasFocus = false;
    // {String}
    @api closeButtonText = BLANK_STRING;

    /*****************************************************************************************************************************
     *
     * UI Getters
     *
     *****************************************************************************************************************************/
    get pillClass() {
        return (this.showRemove ? CLASS_PILL : CLASS_WITHOUT_REMOVE_PILL) +
            (this.hasFocus ? CLASS_PILL_HASFOCUS : BLANK_STRING);
    }

    get showAvatar() {
        return stringIsNotBlank(this.avatarSrc);
    }

    get showIcon() {
        return stringIsBlank(this.avatarSrc) && stringIsNotBlank(this.iconName);
    }

    /*****************************************************************************************************************************
     *
     * Event Handlers
     *
     *****************************************************************************************************************************/
    // Notify Parent on Click
    handlePillClick(event) {
        event.stopPropagation();
        const clickEvt = new CustomEvent("click",{
            detail: {uniqueIdentifier:this.uniqueIdentifier}
        });
        this.dispatchEvent(clickEvt);
    }

    // Notify Parent on remove
    handlePillRemove(event) {
        event.stopPropagation();
        const removeEvt = new CustomEvent("remove",{
            detail: {uniqueIdentifier:this.uniqueIdentifier}
        });
        this.dispatchEvent(removeEvt);
    }
}