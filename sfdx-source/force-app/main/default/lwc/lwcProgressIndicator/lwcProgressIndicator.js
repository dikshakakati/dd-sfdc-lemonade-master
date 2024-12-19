import { LightningElement , api , wire } from "lwc";
import { FlowNavigationNextEvent, FlowNavigationFinishEvent } from "lightning/flowSupport";
import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext,
} from 'lightning/messageService';
import recordSelected from '@salesforce/messageChannel/Progress_indicator_Event__c';
export default class LwcProgressIndicator extends LightningElement {
 @api currentStep;
 @api requestType;
 @api progressIndicatorMap;
 progressIndicators=[];
 subscription = null;
 @wire(MessageContext)
 messageContext;
 callMessageChannel = false;
 connectedCallback(){
    this.subscribeToMessageChannel();
        if(this.progressIndicatorMap && this.requestType &&  !this.callMessageChannel){
            this.generateProgressIndicator();
        }
    }
    get displayIndicator(){
        return this.progressIndicators.length>0;
    }
    generateProgressIndicator(){
        let progressIndicatorMap = JSON.parse(this.progressIndicatorMap);
        console.log('progressIndicatorMap=',progressIndicatorMap);
        console.log('this.requestType=',this.requestType);
        let progressIndicatorValue = (progressIndicatorMap.filter(item => item.RequestType === this.requestType))[0]["Value"];
        console.log('progressIndicatorValue=',progressIndicatorValue);
        let progressIndicatorValueSplit = progressIndicatorValue.split('~');
        console.log('progressIndicatorValueSplit=',progressIndicatorValueSplit);
        this.progressIndicators = [];
            for(let key in progressIndicatorValueSplit){
                    if(Object.prototype.hasOwnProperty.call(progressIndicatorValueSplit, key)){
                    this.progressIndicators.push({
                        Id:key,
                        Name:progressIndicatorValueSplit[key]
                    });
                }
            }
    }
    subscribeToMessageChannel() {
            this.subscription = subscribe(
                this.messageContext,
                recordSelected,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }
    handleMessage(message) {
        if(message){
            this.callMessageChannel = true;
            this.requestType = message.progressIndicator;
            this.generateProgressIndicator();
        }
    }
    disconnectedCallback() {
        this.requestType = undefined;
        this.unsubscribeToMessageChannel();
    }
}