import { LightningElement, api } from "lwc";
export default class LwcIllustration extends LightningElement {
	@api heading;
	@api message;
	@api recordId;
	@api objectApiName;
}