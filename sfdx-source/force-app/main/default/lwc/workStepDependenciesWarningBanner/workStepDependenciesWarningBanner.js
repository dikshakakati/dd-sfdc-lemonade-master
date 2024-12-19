/**
 * @author Deloitte
 * @date 29/04/2022
 * @description JavaScript controller for workStepDependenciesWarningBanner lightning web component.
 */
import { LightningElement, api, wire } from 'lwc';
import loading from '@salesforce/label/c.Spinner_Alternative_Text';
import getBannerMessageDetails from '@salesforce/apex/WorkStepDependenciesWarningBannerCtrl.getBannerMessageDetails';
import createLog from '@salesforce/apex/LogController.createLog';


const ICON_VARIANT_WARNING = 'warning';
const ICON_VARIANT_ERROR = 'error';
const LWC_NAME = 'workStepDependenciesWarningBanner';
const WIRED_BANNER_MESSAGE_METHOD = 'wiredBannerMessage';

export default class WorkStepDependenciesWarningBanner extends LightningElement {
   @api recordId;
   showMessage = true;
   warningIconVariant = ICON_VARIANT_WARNING;
   bannerMessage;
   loaded = false;
   loadingAlternativeText = loading;

   /**
     * @description To get banner message on basis of WorkStep dependencies.
     * @JIRA# LEM-1217
     * @param currentRecordId
     */
    @wire(getBannerMessageDetails, { currentRecordId: '$recordId'})
    wiredBannerMessage({data, error}) {
        try {
            if (data) {
                this.showMessage = data.showMessage;
                this.bannerMessage = data.bannerMessage;
                this.warningIconVariant = ICON_VARIANT_WARNING;
                this.loaded = true;
            } else if (error) {
                this.showMessage = true;
                this.bannerMessage = error.body.exceptionType + ': ' + error.body.message;
                this.warningIconVariant = ICON_VARIANT_ERROR;
                this.loaded = true;
                createLog({lwcName: LWC_NAME , methodName: WIRED_BANNER_MESSAGE_METHOD, message: JSON.stringify(error.body)});
            }
        } catch(getBannerMessageException) {
            this.showMessage = false;
            this.loaded = true;
            //Commenting to control logging due to Wire method loading
            //createLog({lwcName: LWC_NAME , methodName: WIRED_BANNER_MESSAGE_METHOD, message: getBannerMessageException.message});
        }
    }
}
