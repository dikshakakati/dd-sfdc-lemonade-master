import { LightningElement, track, api } from "lwc";

const CSS_CLASS_COLOR_SUCCESS = "green";
const CSS_CLASS_COLOR_FAILURE = "red";
const CSS_CLASS_COLOR_WARNING = "orange";
const CSS_CLASS_BASE = "circular-chart";
const MSG_TIME_REMAINING_PENDING = "Calculating time remaining...";
const MSG_TIME_REMAINING_LESS_THAN_ONE_MIN = "Less than one minute remaining...";

export default class BulkOnboardingSavingIndicator extends LightningElement {
    @api showPercentageLoader;
    @api loadingMessage;
    @api errors;
    @api warnings;

    @api
    set millisecondsRemaining(value) {
        this.msRemaining = value;
        if(this.msRemaining !== undefined || this.msRemaining !== null) {
            this.minutesRemaining = Math.floor((this.millisecondsRemaining / 60000));
            this.secondsRemaining = Math.floor((this.millisecondsRemaining % 60000) / 1000);
            this.setTimeRemainingMessage();
        } else {
            this.msRemaining = 0;
        }
    }

    get millisecondsRemaining() {
        return this.msRemaining;
    }

    @api
    set percentageCompleted(value) {
        this._percentageCompleted = value;
        this.percentage = this._percentageCompleted;
        if(this.percentage) {
            this.dashArray = `${this.percentage}, 100`;
        }
    }

    get percentageCompleted() {
        return this.percentage;
    }

    @track percentage = 0;
    @track msRemaining;
    @track timeRemainingMessage = "";
    @track dashArray = "0, 100";
    @track minutesRemaining;
    @track secondsRemaining;

    setTimeRemainingMessage() {
        console.log(`Minutes Remaining: ${this.minutesRemaining} / Seconds remaining: ${this.secondsRemaining}`)
        if(!this.minutesRemaining && !this.secondsRemaining) {
            this.timeRemainingMessage = MSG_TIME_REMAINING_PENDING;
        } else if(this.minutesRemaining > 1) {
            this.timeRemainingMessage = `About ${this.minutesRemaining} minutes remaining...`;
        } else if(this.minutesRemaining === 1) {
            this.timeRemainingMessage = `About ${this.minutesRemaining} minute remaining...`;
        } else {
            this.timeRemainingMessage = MSG_TIME_REMAINING_LESS_THAN_ONE_MIN;
        }
    }

    get classIndicator() {
        let classToUse;

        if(this.errors && this.errors.length) {
            classToUse = CSS_CLASS_COLOR_FAILURE;
        } else if(this.warnings && this.warnings.length) {
            classToUse = CSS_CLASS_COLOR_WARNING;
        } else {
            classToUse = CSS_CLASS_COLOR_SUCCESS;
        }

        return `${CSS_CLASS_BASE} ${classToUse}`;
    }
}