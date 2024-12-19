import { LightningElement, api } from "lwc";
export default class GuidedFlowHeader extends LightningElement {
	@api headerText;
	@api subHeaderText;
	@api headerCSS;
	@api subHeaderCSS;
	@api isSubHeaderBackGroundColor;
	@api subHeaderStyle;
}