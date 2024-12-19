import { LightningElement,api } from 'lwc';

const REDINESSS_SECTION_HEADER_TEXT = 'Required Fields';

export default class SendSSMOReadinessCheck extends LightningElement {
    headerText = REDINESSS_SECTION_HEADER_TEXT;
    @api eligibilityMessages;
    formatedElligibilityMessages;

    connectedCallback(){
        this.formatedElligibilityMessages = this.eligibilityMessages.map((messages,index) => {
            return {
              id:index+1,
              message:messages
            };
          });
    }
}