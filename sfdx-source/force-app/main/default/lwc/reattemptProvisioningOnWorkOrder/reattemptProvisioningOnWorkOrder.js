
/**
 * @author BizApps
 * @date 07/08/2023
 * @description JavaScript controller for reattempProvisioningOnWorkOrder lightning web component.
 */
import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import isViewOnly from '@salesforce/customPermission/View_Only';
import hideOnboardingActivationsQuickActions from '@salesforce/customPermission/Hide_Onboarding_Activations_Quick_Actions';
import showOnboardingActivationsQuickActions from '@salesforce/customPermission/Show_Onboarding_Activations_Quick_Actions';
import viewOnlyToastMessage from '@salesforce/label/c.View_Only_Toast_Message';
import createLog from '@salesforce/apex/LogController.createLog';
import reattemptProvisioning from '@salesforce/apex/ReattemptProvisioningOnWorkOrderCtrl.reattemptProvisioning';

import reattemptProvisioningSuccess from '@salesforce/label/c.Reattempt_Provisioning_Success';
import reattemptProvisioningWarning from '@salesforce/label/c.Reattempt_Provisioning_Warning';
import toastMessage from '@salesforce/label/c.Toast_Message';
import toastVariantError from '@salesforce/label/c.Toast_Variant_Error';
import toastVariantWarning from '@salesforce/label/c.Toast_Variant_Warning';
import toastVariantSuccess from '@salesforce/label/c.Toast_Variant_Success';

const REATTEMPT_PROVISIONING_METHOD_NAME = 'reattemptProvisioning';
const ERROR_CALLBACK_METHOD_NAME = 'errorCallback';
const LWC_NAME = 'ReattemptProvisioningOnWorkOrder';

export default class ReattemptProvisioningOnWorkOrder extends LightningElement {
    @api recordId;
    toastMessage = toastMessage;
    viewOnlyToastMessage = viewOnlyToastMessage;
    toastVariantError = toastVariantError;

    /**
    * @description To perform logic after component is inserted into the DOM.
    */
    connectedCallback() {
        if (isViewOnly || (hideOnboardingActivationsQuickActions && !showOnboardingActivationsQuickActions)) {
            this.showToast(viewOnlyToastMessage, toastVariantError);
            return;
        }
        if (this.recordId) {
            this.triggerReattmeptProvisioning();
        }
    }

    /**
     * @description This will log & show error on UI if any error occurs.
     * @JIRA# LEM-7366
     * @param error
     * @param stack
     */
    errorCallback(error, stack) {
        //show error message when an error occurs
        this.showToast(toastMessage, toastVariantError);
        createLog({
            lwcName: LWC_NAME,
            methodName: ERROR_CALLBACK_METHOD_NAME,
            message: JSON.stringify(error).concat(JSON.stringify(stack))
        });
    }

    /**
    * @description To Reattempt Provisioning of Xrefs and Rusiness References.
    * @JIRA# LEM-7366
    */
    triggerReattmeptProvisioning() {
        reattemptProvisioning({
            parentWorkOrderId: this.recordId
        })
            .then(result => {
                let reAttemptToastMessage;
                let reAttemptToastVariant;
                if (result) {
                    reAttemptToastVariant = toastVariantSuccess;
                    reAttemptToastMessage = reattemptProvisioningSuccess;
                } else {
                    reAttemptToastVariant = toastVariantWarning;
                    reAttemptToastMessage = reattemptProvisioningWarning;
                }
                this.showToast(reAttemptToastMessage, reAttemptToastVariant);
            })
            .catch((error) => {
                //show toast message on Errors
                this.showToast(toastMessage, toastVariantError);
                createLog({
                    lwcName: LWC_NAME,
                    methodName: REATTEMPT_PROVISIONING_METHOD_NAME,
                    message: JSON.stringify(error.body)
                });
            });
    }

    /**
     * @description To show toast message.
     * @JIRA# LEM-7366
     * @param message
     * @param variant
     */
    showToast(message, variant) {
        const toastEvent = new ShowToastEvent({
            message: message,
            variant: variant,
        });
        this.dispatchEvent(toastEvent);
    }
}