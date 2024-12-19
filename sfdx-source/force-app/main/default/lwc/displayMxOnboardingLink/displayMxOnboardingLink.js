/**
 * @author Deloitte
 * @date 06/12/2024
 * @description JavaScript controller for displayMxOnboardingLink lightning web component.
 */
import { LightningElement, api, wire } from 'lwc';
import getMxOnboardingLink from '@salesforce/apex/OIDataController.getActiveMxOnboardingLink';
import createLog from '@salesforce/apex/LogController.createLog';
import EXPIRATION_DATE_TIME_FIELD from '@salesforce/schema/Mx_Onboarding_Link__c.Expiration_Date_Time__c';
import ONE_TIME_MX_LINK_FIELD from '@salesforce/schema/Mx_Onboarding_Link__c.One_Time_Mx_Link__c';
const GET_MX_ONBOARDING_LINK_RECORD_METHOD_NAME = 'getMxOnboardingLink';
const LWC_NAME = 'DisplayMxOnboardingLink';
const SEND_MX_ONBOARDING_LINK_RECORD_EVENT_NAME = 'sendmxonboardinglink';

export default class DisplayMxOnboardingLink extends LightningElement {
    @api recordId;
    @api showMxOnboardingLink;
    @api mxOnboardingLinkRecord;
    fields = [ONE_TIME_MX_LINK_FIELD, EXPIRATION_DATE_TIME_FIELD];
    hasActiveMxOnboardingLink = false;
    mxOnboardingLink;
    objectApiName = 'Mx_Onboarding_Link__c';
    loaded = false;

    /**
     * @description To fetch mx onboarding link records from current Contract.
     * @JIRA# LEM-1158
     * @param currentWorkPlanRecordId
     * @return List<AccountWrapper>
     */
    @wire(getMxOnboardingLink, { contractId: '$recordId' })
    wiredStores({ data, error }) {
        if (data) {
            try {
                this.loaded = true;
                this.mxOnboardingLink = this.showMxOnboardingLink === true ? this.mxOnboardingLinkRecord : data;
                this.hasActiveMxOnboardingLink = (Object.prototype.hasOwnProperty.call(data, 'Id')) || this.showMxOnboardingLink;
                if (this.hasActiveMxOnboardingLink) {
                    const date2 = new Date(this.mxOnboardingLink.Expiration_Date_Time__c);
                    const formatter = new Intl.DateTimeFormat('en-US', { day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit' });
                    this.expirationDateTime = formatter.format(date2);
                }
                // Send active Mx Onboarding Link record.
                this.dispatchEvent(
                    new CustomEvent(SEND_MX_ONBOARDING_LINK_RECORD_EVENT_NAME, {
                        detail: this.mxOnboardingLink
                    })
                );
            } catch (mxOnboardingLinkException) {
                this.mxOnboardingLink = undefined;
            }
        } else if (error) {
            this.loaded = true;
            this.mxOnboardingLink = undefined;
            createLog({
                lwcName: LWC_NAME, methodName: GET_MX_ONBOARDING_LINK_RECORD_METHOD_NAME,
                message: JSON.stringify(error.body)
            });
        }
    }
}