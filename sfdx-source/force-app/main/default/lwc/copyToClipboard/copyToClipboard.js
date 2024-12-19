// copyTextComponent.js
import { LightningElement, api } from 'lwc';
import { LightningIcon } from 'lightning/icon';

export default class CopyTextComponent extends LightningElement {
    @api displayText;
    @api copyText;
    @api iconResentAfterCopiedInSeconds;
    @api clickToCopyToolTip;
    @api copiedToolTip;
    copied = false;

    get getVariant(){
        return !this.copied? "brand-outline" : "success";
    }

    get getIcon(){
        return !this.copied? "utility:copy" : "utility:success";
    }

    get getTitle(){
        return !this.copied? this.clickToCopyToolTip : this.copiedToolTip;
    }

    get getButtonClass(){
        return!this.copied? "my-button" : "my-success-button";
    }

    get getIconColor(){
        return!this.copied? "grey" : "black";
    }

    copyToClipboard() {
        // Create a temporary textarea element to copy the text
        const textArea = document.createElement('textarea');
        textArea.value = this.copyText;
        document.body.appendChild(textArea);
        textArea.select();
        document.execCommand('copy');
        document.body.removeChild(textArea);

        // Set the variable to true initially
        this.copied = true;
        
        // After 1 second, set the variable back to false
        setTimeout(() => {
            this.copied = false;
        }, this.iconResentAfterCopiedInSeconds*1000);
    }

    handleMouseOver() {
        //this.copied = false; // Reset copied when hovering over the icon
    }
    
    handleMouseOut() {
        //this.copied = false; // Ensure copied is false when moving out
    }
}