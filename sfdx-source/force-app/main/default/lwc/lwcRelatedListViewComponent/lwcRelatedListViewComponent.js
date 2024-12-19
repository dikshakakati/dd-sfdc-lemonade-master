import { LightningElement } from "lwc";

export default class LwcRelatedListViewComponent extends LightningElement {
    connectedCallback() {
    }
    removecontainers() {

        const remContainer = this.template.querySelector('.c-container');
        if (remContainer) {
            remContainer.classList.remove('c-container');
        }
    }
}