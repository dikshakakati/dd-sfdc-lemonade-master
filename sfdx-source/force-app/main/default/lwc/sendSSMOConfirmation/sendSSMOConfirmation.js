import { LightningElement,api } from 'lwc';

export default class SendSSMOConfirmation extends LightningElement {
    @api contact;
    @api ssmoLink;
    contactLink;

    connectedCallback(){
       this.contactLink = `${window.location.origin}/${this.contact.Id}`;
    }

    handleContactLink(event){
        event.preventDefault();
        window.open(this.contactLink,'_blank');
    }
}