/**
 * @author Sanidhya Jain
 * @date Sept 2024
 * @decription Generic Modal Component with predefined Type like Info/Confirm/Dialog.
 */

/*****************************************************************************************************************************
*
* Imports
*
*****************************************************************************************************************************/
import { LightningElement,api,wire } from 'lwc';
import { stringIsBlank,stringIsNotBlank,isUndefinedOrNull,cloneObject } from 'c/lwcDdUtils';
import { BLANK_STRING,KEYCODE_ESC } from 'c/lwcDdConst';

/*****************************************************************************************************************************
*
* CSS Class Consts
*
*****************************************************************************************************************************/

const BACKDROP_CLASS = ' slds-backdrop slds-backdrop_open ';
const BACKDROP_ABSOLUTE_CLASS = ' slds-backdrop slds-backdrop_open slds-backdrop_absolute';
const MODALDIV_CLASS = ' slds-modal slds-fade-in-open ';
const MODALDIV_WITHTHEME_CLASS = ' slds-modal slds-fade-in-open slds-modal_prompt ';
const MODALDIV_SIZE_PREFIX_CLASS = ' slds-modal_';
const HEADERDIV_CLASS = 'slds-modal__header ';
const HEADERDIV_NOHEADER_CLASS = 'slds-modal__header slds-modal__header_empty';
const CONTENT_NOOVERFLOW_CLASS = ' dd_modalDialog_content-nooverflow ';
const CONTENT_CLASS = 'slds-modal__content customScrollbar slds-var-p-left_large slds-var-p-right_large slds-var-p-top_small slds-var-p-bottom_small ';
const HEADERDIV_WITHTHEME_PREFIX_CLASS = ' slds-theme_alert-texture slds-theme_';
const NOFOOTER_CLASS = ' slds-modal__content_has-hidden-footer ';
const FOOTER_CLASS = 'slds-modal__footer';
const HIDE_CLASS = 'slds-hide';

/*****************************************************************************************************************************
*
* Functional Consts
*
*****************************************************************************************************************************/

const PRIMARY_BUTTON_LABEL_DEFAULT = 'OK';
const PRIMARY_BUTTON_LABEL_INFO_DEFAULT = 'OK';
const PRIMARY_BUTTON_LABEL_CONFIRM_DEFAULT = 'Yes';
const SECONDARY_BUTTON_LABEL_DEFAULT = 'Cancel';
const SECONDARY_BUTTON_LABEL_CONFIRM_DEFAULT = 'No';

const INFO = 'info';
const CONFIRM = 'confirm';
const DIALOG = 'dialog';

/*****************************************************************************************************************************
*
* @api Picklist Value consts
*
*****************************************************************************************************************************/
const ALLOWED_TYPES = new Set([INFO,CONFIRM,DIALOG]);
const ALLOWED_SIZES = new Set(['small','medium','large']);

export default class DdModal extends LightningElement {
    /*****************************************************************************************************************************
    *
    * Public Variables
    *
    *****************************************************************************************************************************/

    // {String} (Required) - Unique Identifier/Name of the component instances
    @api uniqueIdentifier;
    // {String}
    @api title;

    // {String} - Type/Variant
    _type;
    get type() {
        return this._type;
    }
    @api
    set type(value) {
        if (stringIsNotBlank(value) && value.toLowerCase() == 'confirmation')
            value = CONFIRM;
        else if (stringIsNotBlank(value) && value.toLowerCase() == 'information')
            value = INFO;
        else if (stringIsBlank(value) || !ALLOWED_TYPES.has(value.toLowerCase()))
            value = DIALOG;
        else
            value = value.toLowerCase();

        this._type = value;
        this.resetButtonsBasedOnType();
    }

    // {String} - Primary Button variant
    @api primaryButtonVariant = "brand";
    @api disablePrimaryButton = false;
    _primaryButtonLabelOverride;
    get primaryButtonLabelOverride() {
        return this._primaryButtonLabelOverride;
    }
    @api
    set primaryButtonLabelOverride(value) {
        this._primaryButtonLabelOverride = value;
        this.resetButtonsBasedOnType();
    }

    // {String} - Secondary Button variant
    @api secondaryButtonVariant = 'bare';
    _secondaryButtonLabelOverride;
    get secondaryButtonLabelOverride() {
        return this._secondaryButtonLabelOverride;
    }
    @api
    set secondaryButtonLabelOverride(value) {
        this._secondaryButtonLabelOverride = value;
        this.resetButtonsBasedOnType();
    }

    // {String} - HTML Content to display in the Modal. If ContentSlot is set by parent, this will not be displayed.
    @api content;
    // {String} theme
    @api variant;
    // {String} size of component - small / medium / large
    _size;
    get size() {
        return this._size;
    }
    @api
    set size(value) {
        value = (value && ALLOWED_SIZES.has(value.toLowerCase())) ? value.toLowerCase() : null;
        this._size = value;
    }
    // {String} css class to add to topmost div
    @api className;
    // {Boolean} modal is by default fixed to the whole screen, this allows it to be fixed inside a relative position div in absolute relation
    @api absoluteBackdrop = false;
    // {Boolean} hides header section
    @api hideHeader = false;
    // {Boolean} hides footer section
    @api hideFooter = false;
    // {Boolean} hides close button
    @api hideClose = false;
    // {Boolean} *** IMPORTANT PARAM *** - Default, the size of the modal is basically size of content without any overflow.
    //      Setting this to true will provide you an automatic scrollbar on the content section
    //      False is great if you will do you own scollbar of the content slot / you content slot has things like picklist dropdowns which can extend outside the modal.
    @api modalContentOverflow = false;
    // {Boolean} Allow for escape to close the modal
    _escapeAllowed = true;
    get escapeAllowed() {
        return this._escapeAllowed;
    }
    @api escapeAllowed;
    set escapeAllowed(value) {
        if (isUndefinedOrNull(value))
            value = true;
        this._escapeAllowed = value;
    }

    /*****************************************************************************************************************************
    *
    * Public Methods
    *
    *****************************************************************************************************************************/

    /**
    * @decription
    * @param
    * @return
    */
    @api
    show() {
        this.showModal = true;
    }

    /**
    * @decription
    * @param
    * @return
    */
    @api
    hide() {
        this.closeModal(false);
    }

    /*****************************************************************************************************************************
    *
    * Private Variables
    *
    *****************************************************************************************************************************/
    showModal = false;
    hidePrimaryButton = false;
    hideSecondaryButton = false;
    primaryButtonLabel = PRIMARY_BUTTON_LABEL_DEFAULT;
    secondaryButtonLabel = SECONDARY_BUTTON_LABEL_DEFAULT;
    footerSlotFilled = false;
    contentSlotFilled = false;

    /*****************************************************************************************************************************
    *
    * LifeCycle Hooks (renderedCallback,connectedCallback,disconnectedCallback)
    *
    *****************************************************************************************************************************/

    iskeyUpAdded = false;
    initFooterButtons = false;
    renderedCallback() {
        if (!this.iskeyUpAdded) {
            window.addEventListener('keyup', this.handleKeyUp,true);
            this.iskeyUpAdded = true;
        }
        if (!this.initFooterButtons) {
            this.initFooterButtons = true;
            this.resetButtonsBasedOnType();
        }
    }

    disconnectedCallback() {
        if (this.iskeyUpAdded) {
            window.removeEventListener('keyup', this.handleKeyUp);
            this.iskeyUpAdded = false;
        }
    }

    /*****************************************************************************************************************************
    *
    * UI Getters - Custom getters for variables in the HTML
    *
    *****************************************************************************************************************************/

    get backdropClass() {
        return this.absoluteBackdrop ? BACKDROP_ABSOLUTE_CLASS : BACKDROP_CLASS;
    }

    get mainDivClass() {
        return (this.className ? this.className + ' ' : BLANK_STRING);
    }

    get modalDivClass() {
        return (this.variant ? MODALDIV_WITHTHEME_CLASS : MODALDIV_CLASS) +
            (this.size ? MODALDIV_SIZE_PREFIX_CLASS + this.size : BLANK_STRING);
    }

    get headerDivClass() {
        return this.hideHeader ? HEADERDIV_NOHEADER_CLASS :
                (HEADERDIV_CLASS + (this.variant ? HEADERDIV_WITHTHEME_PREFIX_CLASS + this.variant : BLANK_STRING));
    }

    get contentTextClass() {
        return (this.contentSlotFilled) ? HIDE_CLASS : BLANK_STRING;
    }
    get contentSlotClass() {
        return (this.contentSlotFilled) ? BLANK_STRING : HIDE_CLASS;
    }
    get contentClass() {
        return (this.modalContentOverflow ? BLANK_STRING : CONTENT_NOOVERFLOW_CLASS) + CONTENT_CLASS +
            (this.hideFooter ? NOFOOTER_CLASS : BLANK_STRING);
    }

    get footerDivClass() {
        return (this.footerSlotFilled) ? HIDE_CLASS : FOOTER_CLASS;
    }
    get footerSlotClass() {
        return (this.footerSlotFilled) ? FOOTER_CLASS : HIDE_CLASS;
    }

    /*****************************************************************************************************************************
    *
    * Event Handlers
    *
    *****************************************************************************************************************************/

    // Method Description
    handleKeyUp = (event) => {
        if (!this.escapeAllowed)
            return;

        const keyCode = event.which || event.keyCode || 0;
        if (keyCode === KEYCODE_ESC && this.showModal) {
            this.closeModal(true);
        }
    }

    handleFooterSlotChange(event) {
        this.footerSlotFilled = true;
    }

    handleContentSlotChange(event) {
        this.contentSlotFilled = true;
    }

    handlePrimaryButtonClick(event) {
        event.stopPropagation();
        const evt = new CustomEvent("primarybuttonclick",{
            detail: {uniqueIdentifier:this.uniqueIdentifier}
        });
        this.dispatchEvent(evt);
        if (this.type === INFO)
            this.closeModal(false);
    }

    handleSecondaryButtonClick(event) {
        event.stopPropagation();
        const evt = new CustomEvent("secondarybuttonclick",{
            detail: {uniqueIdentifier:this.uniqueIdentifier}
        });
        this.dispatchEvent(evt);
        this.closeModal(false);
    }

    // Generic Stop Prop event
    stopEventPropagation(event) {
        event.stopPropagation();
    }

    /*****************************************************************************************************************************
    *
    * Logic / Helper methods
    *
    *****************************************************************************************************************************/

    /**
     * @decription
     * @param   {String} param1 - <Description>
     *          {Boolean} param2 - <Descrption>
     * @return  {String} - <Optional Description>
     */
    resetButtonsBasedOnType() {
        if (stringIsBlank(this.type)) {
            this.hidePrimaryButton = false;
            this.hideSecondaryButton = false;
            this.primaryButtonLabel = PRIMARY_BUTTON_LABEL_DEFAULT;
            this.secondaryButtonLabel = SECONDARY_BUTTON_LABEL_DEFAULT;
            return;
        }
        switch (this.type) {
            case 'info':
                this.hidePrimaryButton = false;
                this.hideSecondaryButton = true;
                this.primaryButtonLabel = stringIsNotBlank(this.primaryButtonLabelOverride) ?
                    this.primaryButtonLabelOverride : PRIMARY_BUTTON_LABEL_INFO_DEFAULT;
                this.secondaryButtonLabel = SECONDARY_BUTTON_LABEL_DEFAULT;
                break;
            case 'confirm':
                this.hidePrimaryButton = false;
                this.hideSecondaryButton = false;
                this.primaryButtonLabel = stringIsNotBlank(this.primaryButtonLabelOverride) ?
                    this.primaryButtonLabelOverride : PRIMARY_BUTTON_LABEL_CONFIRM_DEFAULT;
                this.secondaryButtonLabel = stringIsNotBlank(this.secondaryButtonLabelOverride) ?
                    this.secondaryButtonLabelOverride : SECONDARY_BUTTON_LABEL_CONFIRM_DEFAULT;
                break;
            default:
                this.hidePrimaryButton = false;
                this.hideSecondaryButton = false;
                this.primaryButtonLabel = stringIsNotBlank(this.primaryButtonLabelOverride) ?
                    this.primaryButtonLabelOverride : PRIMARY_BUTTON_LABEL_DEFAULT;
                this.secondaryButtonLabel = stringIsNotBlank(this.secondaryButtonLabelOverride) ?
                    this.secondaryButtonLabelOverride : SECONDARY_BUTTON_LABEL_DEFAULT;
                break;
        }
    }

    closeModal(notifyParent) {
        this.showModal = false;
        if (notifyParent) {
            const evt = new CustomEvent("close",{
                detail: {uniqueIdentifier:this.uniqueIdentifier}
            });
            this.dispatchEvent(evt);
        }
    }
 }