import {
    LightningElement,
    api,
    wire
} from "lwc";
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
import {
    updateRecord,
    getRecord
} from 'lightning/uiRecordApi';
import {
    loadStyle
} from 'lightning/platformResourceLoader';

import storeHoursSR from '@salesforce/resourceUrl/storeHoursSR';

import createLog from "@salesforce/apex/LogController.createLog";

import ID_FIELD from '@salesforce/schema/Account.Id';
import HOURS_OF_OPERATION_FIELD from '@salesforce/schema/Account.Hours_of_Operation__c';

const LWC_NAME = "StoreHours";

export default class StoreHours extends LightningElement {
    @api accountId;
    loadComponent = false;
    loadSpinner = true;
    isAllDaysSame = false;

    valueChanged = false;

    allDays = [{
        name: "All days",
        isOpen: true,
        open24Hours: false,
        hours: [{
            start: "8:00AM",
            end: "10:00PM"
        }]
    }]
    weekDays = [{
        name: "Monday",
        isOpen: true,
        open24Hours: false,
        hours: [{
            start: "8:00AM",
            end: "10:00PM"
        }]
    },
    {
        name: "Tuesday",
        isOpen: true,
        open24Hours: false,
        hours: [{
            start: "8:00AM",
            end: "10:00PM"
        }]
    },
    {
        name: "Wednesday",
        isOpen: true,
        open24Hours: false,
        hours: [{
            start: "8:00AM",
            end: "10:00PM"
        }]
    },
    {
        name: "Thursday",
        isOpen: true,
        open24Hours: false,
        hours: [{
            start: "8:00AM",
            end: "10:00PM"
        }]
    },
    {
        name: "Friday",
        isOpen: true,
        open24Hours: false,
        hours: [{
            start: "8:00AM",
            end: "10:00PM"
        }]
    },
    {
        name: "Saturday",
        isOpen: true,
        open24Hours: false,
        hours: [{
            start: "8:00AM",
            end: "10:00PM"
        }]
    },
    {
        name: "Sunday",
        isOpen: true,
        open24Hours: false,
        hours: [{
            start: "8:00AM",
            end: "10:00PM"
        }]
    }
    ];

    backupValuesToShow = new Map();
    valuesToShow;

    @api
    resetValueChanged() {
        this.valueChanged = false;
        const storeHoursDayElements = this.template.querySelectorAll('c-store-hours-day');
        storeHoursDayElements.forEach(element => {
            element.resetValueChanged();
        });
    }

    connectedCallback() {
        this.backupValuesToShow.set(true, this.allDays);
        this.backupValuesToShow.set(false, this.weekDays);
        loadStyle(this, storeHoursSR).then(() => { }).catch(error => {
            console.error("Error in loading the CSS")
        })
    }

    @wire(getRecord, {
        recordId: '$accountId',
        fields: [HOURS_OF_OPERATION_FIELD]
    })
    wiredAccount({
        error,
        data
    }) {
        if (data) {
            if (data.fields.Hours_of_Operation__c.value == null) {
                this.setInitialValuesAfterWire();
                this.changeInValue();
            } else {
                this.processDefaultResult(this.parseHoursOfOperation(data.fields.Hours_of_Operation__c.value));
            }
        } else if (error) {
            this.showErrorToast(error.message, 'Error occurred while loading hours of operation', 'error');
            this.createLogRecord(error.message, 'wiredAccount');
        }
    }

    changeInValue() {
        if (!this.valueChanged) {
            this.dispatchEvent(new CustomEvent('changeinvalue'));
            this.valueChanged = true;
        }
    }

    @api parseHoursOfOperation(hoursOfOperation) {
        let replaced = hoursOfOperation
            .replaceAll('All days', 'Alldays')
            .replaceAll('next day', 'nextDay')
            .replaceAll(' ', ',');
        let weekDays = [];
        let daysWithHours = replaced.split(',');
        for (let i = 0; i < daysWithHours.length; i++) {
            if (daysWithHours[i].includes('day')) {
                let dayName = daysWithHours[i++];
                let isOpen = !(daysWithHours[i] === 'Closed');
                let hours = [];
                for (let j = i; j < daysWithHours.length && daysWithHours[j].includes('-'); j++) {
                    let hourSet = daysWithHours[j].split('-');
                    let hourMap = {
                        'start': hourSet[0],
                        'end': hourSet[1].replace('nextDay', 'next day')
                    };
                    hours.push(hourMap);
                    i++;
                }
                i--;
                let dayMap = {
                    'name': dayName.replace('Alldays', 'All days'),
                    'isOpen': isOpen,
                    'hours': hours
                };
                weekDays.push(dayMap);
            } else {
                continue;
            }
        }
        return JSON.stringify(weekDays);
    }

    @api processDefaultResult(hoursOfOperationString) {
        let returnedValue = JSON.parse(hoursOfOperationString);
        if (returnedValue.length == 1 && returnedValue[0].name == 'All days') {
            this.isAllDaysSame = true;
            this.backupValuesToShow.set(this.isAllDaysSame, returnedValue);
        } else if (returnedValue.length == 7 &&
            returnedValue[0].name == 'Monday' &&
            returnedValue[1].name == 'Tuesday' &&
            returnedValue[2].name == 'Wednesday' &&
            returnedValue[3].name == 'Thursday' &&
            returnedValue[4].name == 'Friday' &&
            returnedValue[5].name == 'Saturday' &&
            returnedValue[6].name == 'Sunday') {
            this.backupValuesToShow.set(this.isAllDaysSame, returnedValue);
        }
        this.setInitialValuesAfterWire();
    }

    setInitialValuesAfterWire() {
        this.updateValuesToShow();
        this.loadComponent = true;
        this.loadSpinner = false;

        const event = new CustomEvent('loadcomponent', {
            detail: {
                loadComponent: this.loadComponent
            }
        });
        this.dispatchEvent(event);

    }

    handleAllDaysToggle(event) {
        this.changeInValue();
        this.takeBackUpBeforeToggle();
        this.isAllDaysSame = event.target.checked;
        this.updateValuesToShow();
    }

    updateValuesToShow() {
        this.valuesToShow = this.backupValuesToShow.get(this.isAllDaysSame);
    }

    takeBackUpBeforeToggle() {
        const storeHoursDayElements = this.template.querySelectorAll('c-store-hours-day');
        let backUp = [];
        storeHoursDayElements.forEach(element => {
            // 'dayInfo' is a public property on the 'store-hours-day' component
            backUp.push(element.dayInfo);
        });
        this.backupValuesToShow.set(this.isAllDaysSame, backUp);
    }

    @api
    saveData() {
        this.handleSave();
    }

    @api
    getHoursOfOperationInString() {
        this.takeBackUpBeforeToggle();
        this.updateValuesToShow();
        this.dispatchEvent(new CustomEvent('hoursofoperation', { detail: this.returnOperatingHoursInSfFormat(this.valuesToShow) }));
    }

    handleSave() {
        this.takeBackUpBeforeToggle();
        this.updateValuesToShow();
        this.loadSpinner = true;
        let updateValue = this.returnOperatingHoursInSfFormat(this.valuesToShow);
        if (updateValue == 'Invalid Input') {
            this.loadSpinner = false;
            this.showErrorToast(updateValue, 'Please check the errors on the page', 'error');
            return;
        }
        this.updateHoursOfOperation(updateValue);
    }

    updateHoursOfOperation(operatingHours) {
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.accountId;
        fields[HOURS_OF_OPERATION_FIELD.fieldApiName] = operatingHours;

        const recordInput = {
            fields
        };
        updateRecord(recordInput)
            .then(() => {
                this.loadSpinner = false;
                this.saveUpdateEvent(true, 'Hours of Operation updated successfully');
                this.regenerateStoreHoursDay();
            })
            .catch(error => {
                this.loadSpinner = false;
                this.saveUpdateEvent(false, error.body.message);
                this.createLogRecord(error.body.message, 'updateHoursOfOperation');
                this.regenerateStoreHoursDay();
            });
    }

    createLogRecord(message, methodName) {
        createLog({
            name: LWC_NAME,
            message: JSON.stringify(message),
            methodName: methodName
        });
    }

    saveUpdateEvent(updateStatus, message) {
        const event = new CustomEvent('updatestatus', {
            detail: {
                status: updateStatus,
                message: message
            }
        });
        this.dispatchEvent(event);
    }

    regenerateStoreHoursDay() {
        const storeHoursDayComponents = this.template.querySelectorAll('c-store-hours-day');

        storeHoursDayComponents.forEach(component => {
            component.generateStartEndTimeOptions();
        });
    }

    showErrorToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    returnOperatingHoursInSfFormat(jsObject) {
        let output = '';
        for (let i = 0; i < jsObject.length; i++) {
            output += jsObject[i].name + ' ';
            if (jsObject[i].isOpen) {
                for (let j = 0; j < jsObject[i].hours.length; j++) {
                    if (jsObject[i].hours[j].invalidInput) {
                        return 'Invalid Input';
                    }
                    output += jsObject[i].hours[j].start + '-' + jsObject[i].hours[j].end;
                    if (j < jsObject[i].hours.length - 1) {
                        output += ',';
                    }
                }
            } else {
                output += 'Closed';
            }
            if (i < jsObject.length - 1) {
                output += ', ';
            }
        }
        return output;
    }

}