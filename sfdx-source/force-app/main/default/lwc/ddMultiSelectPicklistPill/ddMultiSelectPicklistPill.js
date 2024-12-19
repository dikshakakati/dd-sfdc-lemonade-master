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
import { stringIsNotBlank,isUndefinedOrNull } from 'c/lwcDdUtils';

/*****************************************************************************************************************************
 *
 * Functional Consts
 *
 *****************************************************************************************************************************/

const AVATAR = 'Avatar';
const ICON = 'Icon';
const IS_BLANK_IS_NOT_BLANK = new Set(['Is Blank','Is Not Blank']);

export default class DdMultiSelectPicklistPill extends LightningElement {
    /*****************************************************************************************************************************
     *
     * Public Variables
     *
     *****************************************************************************************************************************/
    // {Integer} Index of the pill which has a focus
    @api pillFocusIndex;
    // {Integer} Index of current pill
    @api pillIndex;

    // {String} icon name
    _iconName;
    get iconName() {
        return this._iconName;
    }
    @api
    set iconName(value) {
        this._iconName = value;
        this.setDisplayProps();
    }

    // {String} icon type
    _iconType;
    get iconType() {
        return this._iconType;
    }
    @api
    set iconType(value) {
        this._iconType = value;
        this.setDisplayProps();
    }

    // {Object} record
    _rec;
    get rec() {
        return this._rec;
    }
    @api
    set rec(value) {
        this._rec = value;
        this.setDisplayProps();
    }

    /*****************************************************************************************************************************
     *
     * Private Variables
     *
     *****************************************************************************************************************************/

    showAvatar = false;
    showIcon = false;

    /*****************************************************************************************************************************
     *
     * UI Getters
     *
     *****************************************************************************************************************************/

    get hasFocus() {
        return !isUndefinedOrNull(this.pillFocusIndex) && !isUndefinedOrNull(this.pillIndex) && this.pillFocusIndex === this.pillIndex;
    }

    get hasNoIcon() {
        return this.showIcon == false && this.showAvatar == false;
    }

    /*****************************************************************************************************************************
     *
     * Event Handlers
     *
     *****************************************************************************************************************************/

    handlePillRemove(event) {
        event.stopPropagation();
        const detail = {rec:this.rec};
        const removeEvt = new CustomEvent("pillremove",
            {detail:detail, bubbles: true, composed: true} // Notify parent of parent of removal
        );
        this.dispatchEvent(removeEvt);
    }

    /*****************************************************************************************************************************
     *
     * Logic/Helper Methods
     *
     *****************************************************************************************************************************/

    // Determine if icon or avatar needs to be displayed
    setDisplayProps() {
        if (!this.rec)
            return;

        const operator = this.rec.operator;

        const iconSrcIsAvailable = stringIsNotBlank(this.rec.iconSrc);
        const iconNameIsAvailable = stringIsNotBlank(this.iconName);

        this.showAvatar = this.iconType == AVATAR && !IS_BLANK_IS_NOT_BLANK.has(operator) && iconSrcIsAvailable;

        this.showIcon = this.iconType == ICON && !IS_BLANK_IS_NOT_BLANK.has(operator) && (iconSrcIsAvailable || iconNameIsAvailable);
    }
}