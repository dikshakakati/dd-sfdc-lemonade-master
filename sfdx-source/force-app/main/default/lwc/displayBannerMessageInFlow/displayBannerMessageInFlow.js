import { LightningElement, api } from "lwc";
export default class DisplayBannerMessageInFlow extends LightningElement {
	@api message;
	@api messageList = [];
	@api messageType;
	@api displayMessage;
	get displayMessageText() {
		let messageHtml;
		let messages;
		let message
		if (this.messageList.length > 0) {
			let message = this.messageList.toString() + ',';
			messages = message.split(',~,');
			messages = [...new Set(messages)];
			messages.forEach(function (item) {
				if (item.length > 0) {
					if (messageHtml)
						messageHtml = messageHtml + item + '\n';
					else
						messageHtml = item + '\n';
				}
			});
		} else {
			if (this.message) {
				messageHtml = this.message;
			}
		}

		return messageHtml;
	}
	get messageTypeClass() {
		if (this.messageType)
			return 'slds-text-align_left slds-notify slds-notify_alert slds-alert' + this.messageType;
		return 'slds-text-align_left slds-notify slds-notify_alert slds-alert';
	}
}