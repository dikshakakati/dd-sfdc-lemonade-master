/**
 * @author Sanidhya Jain
 * @date   Sept 2024
 * @decription Child of ddMultiSelectPicklist component, shows display result
 */

/*****************************************************************************************************************************
 *
 * Imports
 *
 *****************************************************************************************************************************/
import { LightningElement,api } from 'lwc';
import { isUndefinedOrNull,stringIsNotBlank } from 'c/lwcDdUtils';
import { BLANK_STRING } from 'c/lwcDdConst';

/*****************************************************************************************************************************
 *
 * CSS Class Consts
 *
 *****************************************************************************************************************************/
const ROOT_CLASS = 'slds-list__item cursor-pointer ';
const HAS_DIVIDER_CLASS = 'slds-has-dividers_bottom-space';
const SEPARATOR_CLASS = ' separator ';
const FOCUS_CLASS = ' slds-has-focus ';
const TILE_CLASS = 'slds-tile ';
const TILE_WITHMEDIA_CLASS = 'slds-tile slds-media';
const TITLE_CLASS = 'slds-tile__title slds-truncate';
const TITLE_BOLD_CLASS = 'slds-tile__title slds-truncate font-bold';

/*****************************************************************************************************************************
 *
 * Functional Consts
 *
 *****************************************************************************************************************************/
const MEDIUM = 'medium';
const AVATAR = 'avatar';
const ICON = 'icon';

/*****************************************************************************************************************************
 *
 * @api Picklist Value consts
 *
 *****************************************************************************************************************************/
 const ICON_AVATAR_SIZE_VARIANTS = new Set([MEDIUM,'small','x-small','large']);

export default class DdMultiSelectPicklistLookupResult extends LightningElement {
    /*****************************************************************************************************************************
    *
    * Public Variables
    *
    *****************************************************************************************************************************/
    // {String} Icon Type to display
    @api iconType;
    // {String} additional css classes to add to main div
    @api className;
    // {Integer} index of item in the list
    @api itemIndex;
    // {Integer} index of selected item
    @api selectFocusIndex;
    // {String} CSS params from Parent
    @api parentClassName;
    // {Object} Record
    @api rec;
    // {String} Name of Icon if any
    @api iconName;
    // {String} Icon size - default medium
    _iconAvatarSize = MEDIUM;
    get iconAvatarSize() {
        return this._iconAvatarSize;
    }
    @api
    set iconAvatarSize(value) {
        value = (stringIsNotBlank(value) && ICON_AVATAR_SIZE_VARIANTS.has(value.toLowerCase())) ? value.toLowerCase() : MEDIUM;
        this._iconAvatarSize = value;
    }

    /*****************************************************************************************************************************
    *
    * UI Getters
    *
    *****************************************************************************************************************************/

    get rootClass() {
        let retVal = ROOT_CLASS + (this.className ? this.className : BLANK_STRING);

        if (this.parentClassName && this.parentClassName === HAS_DIVIDER_CLASS)
            retVal += SEPARATOR_CLASS;

        if (!isUndefinedOrNull(this.selectFocusIndex) && !isUndefinedOrNull(this.itemIndex) && this.itemIndex === this.selectFocusIndex)
            retVal += FOCUS_CLASS;

        return retVal;
    }

    get tileClass() {
        return (this.hasTileBody ? TILE_WITHMEDIA_CLASS : TILE_CLASS);
    }

    get titleClass() {
        return (this.hasTileBody && stringIsNotBlank(this.rec.dropDownSubLabel) ? TITLE_BOLD_CLASS : TITLE_CLASS);
    }

    get hasTileBody() {
        return (this.rec && stringIsNotBlank(this.rec.dropDownLabel));
    }

    get hasMedia() {
        return this.isAvatar || this.isIcon;
    }

    get isAvatar() {
        if (!this.rec || !this.iconType)
            return false;
        const iconType = this.iconType.toLowerCase();
        return (iconType === AVATAR && stringIsNotBlank(this.rec.iconSrc));
    }

    get isIcon() {
        if (!this.rec || !this.iconType)
            return false;
        const iconType = this.iconType.toLowerCase();
        return (iconType === ICON && stringIsNotBlank(this.iconName));
    }

    /*****************************************************************************************************************************
     *
     * Event Handlers
     *
     *****************************************************************************************************************************/

    // On click, notify parent
    handleOnclick(event) {
        event.stopPropagation();
        const evt = new CustomEvent("select",{
            detail: {selectedRecord:this.rec}
        });
        this.dispatchEvent(evt);
    }
}