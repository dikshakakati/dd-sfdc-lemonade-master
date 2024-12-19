import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import createLog from "@salesforce/apex/LogController.createLog";
import ACCOUNT_SEGMENT from '@salesforce/schema/Opportunity.Account.Segment__c';
import ACCOUNT_RECORDTYPE from '@salesforce/schema/Opportunity.Account.RecordType.Name';
import ACCOUNT_LEGAL_BUSINESS_NAME from '@salesforce/schema/Opportunity.Account.Legal_Business_Name__c';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

const COMPONENTDEF = "c:contractsSummary";
const WEB_PAGE = "standard__webPage";
const URL_LINK = "/one/one.app#";
const LWC_NAME = "amendContracts";
const fields = [ACCOUNT_SEGMENT, ACCOUNT_RECORDTYPE, ACCOUNT_LEGAL_BUSINESS_NAME];


export default class AmendContract extends NavigationMixin(LightningElement) {

    @api recordId;
    isComponentLoaded = false;

    @wire(getRecord, { recordId: '$recordId', fields })
    record({ error, data }) {
        if (data) {
            let accountSegment = getFieldValue(data, ACCOUNT_SEGMENT);
            let accountRecType = getFieldValue(data, ACCOUNT_RECORDTYPE);
            let accountLegalBusinessName = getFieldValue(data, ACCOUNT_LEGAL_BUSINESS_NAME);
            if (accountRecType == 'Business' && accountSegment == 'SMB' && accountLegalBusinessName == null) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Legal Business Name on Account must be populated in order to create a quote against the opportunity.',
                        variant: 'Error'
                    })
                );
                this.dispatchEvent(new CloseActionScreenEvent());
            }
            else {
                if (!this.isComponentLoaded) {
                    this.navigateToPage();
                    this.isComponentLoaded = true;
                }
            }
        }
    }

    navigateToPage() {
        try {
            let definition = {
                componentDef: COMPONENTDEF,
                attributes: {
                    recordId: this.recordId
                }
            };
            this[NavigationMixin.Navigate]({
                type: WEB_PAGE,
                attributes: {
                    url: URL_LINK + btoa(JSON.stringify(definition))
                }
            });

        } catch (error) {
            console.log('error' + error);
            createLog({
                lwcName: LWC_NAME,
                methodName: NAVIGATE_TO_PAGE,
                message: JSON.stringify(error)
            });
        }
    }
}
