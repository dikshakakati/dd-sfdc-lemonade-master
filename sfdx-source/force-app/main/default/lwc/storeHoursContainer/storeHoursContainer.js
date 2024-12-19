import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class StoreHoursContainer extends LightningElement {
    @api recordId;
    loadComponent = false;
    randomNumber = Math.random();

    setLoader(event) {
        this.loadComponent = event.detail.loadComponent;
    }

    handleSave() {
        const storeHoursComponent = this.template.querySelector('c-store-hours');

        if (storeHoursComponent) {
            storeHoursComponent.saveData();
        }
    }

    handleSaveStaus(event) {
        let title = 'Error updating record';
        let variant = 'error';
        if (event.detail.status) {
            title = 'Success';
            variant = 'success';
        }

        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: event.detail.message,
                variant: variant
            })
        );
    }
}