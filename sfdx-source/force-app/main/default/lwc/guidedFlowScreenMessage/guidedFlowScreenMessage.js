import { LightningElement, api } from 'lwc';
import { FlowNavigationNextEvent, FlowNavigationFinishEvent } from "lightning/flowSupport";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
export default class GuidedFlowScreenMessage extends NavigationMixin(LightningElement) {
    @api recordId;
    @api title;
    @api message;
    @api mode;
    @api messageData;
    @api variant;
    @api triggerNavigationNextEvent;
    @api label;
    @api
    availableActions = [];
    /**
    * @description call showToastMessage on rerender event
    */
    renderedCallback() {
        if (!this.hasRendered) {
            this.hasRendered = true;
            this.showToastMessage();
        }
    }
    /**
    * @description call showToastMessage on button click
    */
    connectedCallback() {
        this.showToastMessage();
    }
    showToastMessage() {
        console.log('this.availableAction=', JSON.stringify(this.availableAction));
        if (this.availableActions.find(action => action === 'NEXT')) {
            this.showMessage();
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);

        } else if (this.availableActions.find(action => action === 'FINISH')) {
            this.showMessage();
            const navigateFinishEvent = new FlowNavigationFinishEvent();
            this.dispatchEvent(navigateFinishEvent);
        }
    }
    /**
    * @description sow toast message on button click
    */
    showMessage() {
        if(this.recordId){
            console.log("Record Id=",this.recordId);
            this[NavigationMixin.GenerateUrl]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.recordId,
                    actionName: 'view',
                },
            }).then((url) => {
                const eventMessage = new ShowToastEvent({
                    title: this.title,
                    variant : this.variant,
                    message: this.message,
                    messageData: [
                        {
                            url,
                            label: this.label,
                        },
                    ],
                });
                this.dispatchEvent(eventMessage);
            });
        }else{
            const event = new ShowToastEvent({
                "title": this.title,
                "variant": this.variant,
                "message": this.message
            });
            this.dispatchEvent(event);
        }
        notifyRecordUpdateAvailable([{ recordId: this.recordId }]);
    }
}