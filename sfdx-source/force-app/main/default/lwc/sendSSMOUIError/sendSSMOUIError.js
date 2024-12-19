import { LightningElement,api } from 'lwc';

const UI_ERROR_SUBHEADER_TEXT = 'Review the errors';
const UI_ERROR_HEADER_TEXT = 'We hit a snag.';

export default class SendSSMOUIError extends LightningElement {
    uierrorHeader= UI_ERROR_HEADER_TEXT;
    uierrorSubHeader = UI_ERROR_SUBHEADER_TEXT;
    @api uiErrorMessages;

    /**
    * @description close error icon in footer
    */
    closeErrorIcon(){
        this.dispatchEvent(new CustomEvent('closeuierror'));
    }
}