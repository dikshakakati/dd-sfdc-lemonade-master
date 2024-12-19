/**
  * @author Deloitte
  * @date 06/10/2024
  * @description It is parent container to display everything related to SMB business below
  * contracts tab.
*/
import { LightningElement, api, track } from 'lwc';

const ADS_AND_PROMOS = 'Ads & Promos';
export default class LwcContractExtendedDetails extends LightningElement {
  @track columns = [];
  @api contractId;
  @api splitCategory;
  @api businessAccountId;
  @track bool = false;
  connectedCallback() {
    this.checkTabName();
  }

  checkTabName() {
    this.bool = (this.splitCategory !== ADS_AND_PROMOS);
  }
}