import { LightningElement  } from "lwc";
import ERROR_ON_BLANK_NETSUITE_ID from '@salesforce/label/c.PAYMENT_ACCOUNT_VALIDATION_ON_NETSUITE_ID_BLANK'
export default class BannerPaymentAccount extends LightningElement {
    displayBannerOnScreen = true;
    bannerMessage=ERROR_ON_BLANK_NETSUITE_ID;
}