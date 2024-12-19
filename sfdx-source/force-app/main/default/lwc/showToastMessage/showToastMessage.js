import { LightningElement , api , track } from "lwc";
export default class ShowToastMessage extends LightningElement  {
	@api
	recordId;
	@api
	objectApiName;
    @track type='success';
    @track message;
    @track messageIsHtml = false;
    @track showToastBar = false;
    @api autoCloseTime = 5000;
    @track icon='';
    @api
    showToast(type, message , icon, time){
        this.type = type;
        this.message = message;
        this.icon = icon;
        this.autoCloseTime = time;
        this.showToastBar = true;
        setTimeout(() =>{
            this.closeModal();
        }, this.autoCloseTime);
    }
    closeModal(){
        this.showToastBar = false;
        this.type = '';
        this.message = '';

    }
    get getIconName(){

        if(this.icon){
            return this.icon;
        }
        return 'utility:' + this.type;
    }
    get innerClass(){
        return 'slds-icon_container slds-icon-utility-'+this.type+' slds-m-right_small slds-no-flex slds-align-top';
    }
    get outerClass(){
        return 'slds-notify slds-notify_toast slds-theme_'+this.type;
    }

}