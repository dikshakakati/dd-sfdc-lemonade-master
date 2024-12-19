import {
    LightningElement,
    api
} from "lwc";

import StartEndSeparator from '@salesforce/resourceUrl/Store_Hours_Start_End_Separator';
import DisabledAdd from '@salesforce/resourceUrl/Store_Hours_Add_Circle_Disabled';
import EnabledAdd from '@salesforce/resourceUrl/Store_Hours_Add_Circle_Enabled';
import Remove from '@salesforce/resourceUrl/Store_Hours_Remove_Circle';

export default class StoreHoursDay extends LightningElement {
    @api dayInfo;
    StartEndSeparatorIcon = StartEndSeparator;
    DisabledAddIcon = DisabledAdd;
    EnabledAddIcon = EnabledAdd;
    RemoveIcon = Remove;
    startTimeOptions = [{
        label: "12:00 AM",
        value: "12:00AM"
    },
    {
        label: "12:30 AM",
        value: "12:30AM"
    },
    {
        label: "1:00 AM",
        value: "1:00AM"
    },
    {
        label: "1:30 AM",
        value: "1:30AM"
    },
    {
        label: "2:00 AM",
        value: "2:00AM"
    },
    {
        label: "2:30 AM",
        value: "2:30AM"
    },
    {
        label: "3:00 AM",
        value: "3:00AM"
    },
    {
        label: "3:30 AM",
        value: "3:30AM"
    },
    {
        label: "4:00 AM",
        value: "4:00AM"
    },
    {
        label: "4:30 AM",
        value: "4:30AM"
    },
    {
        label: "5:00 AM",
        value: "5:00AM"
    },
    {
        label: "5:30 AM",
        value: "5:30AM"
    },
    {
        label: "6:00 AM",
        value: "6:00AM"
    },
    {
        label: "6:30 AM",
        value: "6:30AM"
    },
    {
        label: "7:00 AM",
        value: "7:00AM"
    },
    {
        label: "7:30 AM",
        value: "7:30AM"
    },
    {
        label: "8:00 AM",
        value: "8:00AM"
    },
    {
        label: "8:30 AM",
        value: "8:30AM"
    },
    {
        label: "9:00 AM",
        value: "9:00AM"
    },
    {
        label: "9:30 AM",
        value: "9:30AM"
    },
    {
        label: "10:00 AM",
        value: "10:00AM"
    },
    {
        label: "10:30 AM",
        value: "10:30AM"
    },
    {
        label: "11:00 AM",
        value: "11:00AM"
    },
    {
        label: "11:30 AM",
        value: "11:30AM"
    },
    {
        label: "12:00 PM",
        value: "12:00PM"
    },
    {
        label: "12:30 PM",
        value: "12:30PM"
    },
    {
        label: "1:00 PM",
        value: "1:00PM"
    },
    {
        label: "1:30 PM",
        value: "1:30PM"
    },
    {
        label: "2:00 PM",
        value: "2:00PM"
    },
    {
        label: "2:30 PM",
        value: "2:30PM"
    },
    {
        label: "3:00 PM",
        value: "3:00PM"
    },
    {
        label: "3:30 PM",
        value: "3:30PM"
    },
    {
        label: "4:00 PM",
        value: "4:00PM"
    },
    {
        label: "4:30 PM",
        value: "4:30PM"
    },
    {
        label: "5:00 PM",
        value: "5:00PM"
    },
    {
        label: "5:30 PM",
        value: "5:30PM"
    },
    {
        label: "6:00 PM",
        value: "6:00PM"
    },
    {
        label: "6:30 PM",
        value: "6:30PM"
    },
    {
        label: "7:00 PM",
        value: "7:00PM"
    },
    {
        label: "7:30 PM",
        value: "7:30PM"
    },
    {
        label: "8:00 PM",
        value: "8:00PM"
    },
    {
        label: "8:30 PM",
        value: "8:30PM"
    },
    {
        label: "9:00 PM",
        value: "9:00PM"
    },
    {
        label: "9:30 PM",
        value: "9:30PM"
    },
    {
        label: "10:00 PM",
        value: "10:00PM"
    },
    {
        label: "10:30 PM",
        value: "10:30PM"
    },
    {
        label: "11:00 PM",
        value: "11:00PM"
    },
    {
        label: "11:30 PM",
        value: "11:30PM"
    },
    {
        label: "11:59 PM",
        value: "11:59PM"
    }
    ];

    endTimeOptions = [{
        label: "12:00 AM",
        value: "12:00AM"
    },
    {
        label: "12:30 AM",
        value: "12:30AM"
    },
    {
        label: "1:00 AM",
        value: "1:00AM"
    },
    {
        label: "1:30 AM",
        value: "1:30AM"
    },
    {
        label: "2:00 AM",
        value: "2:00AM"
    },
    {
        label: "2:30 AM",
        value: "2:30AM"
    },
    {
        label: "3:00 AM",
        value: "3:00AM"
    },
    {
        label: "3:30 AM",
        value: "3:30AM"
    },
    {
        label: "4:00 AM",
        value: "4:00AM"
    },
    {
        label: "4:30 AM",
        value: "4:30AM"
    },
    {
        label: "5:00 AM",
        value: "5:00AM"
    },
    {
        label: "5:30 AM",
        value: "5:30AM"
    },
    {
        label: "6:00 AM",
        value: "6:00AM"
    },
    {
        label: "6:30 AM",
        value: "6:30AM"
    },
    {
        label: "7:00 AM",
        value: "7:00AM"
    },
    {
        label: "7:30 AM",
        value: "7:30AM"
    },
    {
        label: "8:00 AM",
        value: "8:00AM"
    },
    {
        label: "8:30 AM",
        value: "8:30AM"
    },
    {
        label: "9:00 AM",
        value: "9:00AM"
    },
    {
        label: "9:30 AM",
        value: "9:30AM"
    },
    {
        label: "10:00 AM",
        value: "10:00AM"
    },
    {
        label: "10:30 AM",
        value: "10:30AM"
    },
    {
        label: "11:00 AM",
        value: "11:00AM"
    },
    {
        label: "11:30 AM",
        value: "11:30AM"
    },
    {
        label: "12:00 PM",
        value: "12:00PM"
    },
    {
        label: "12:30 PM",
        value: "12:30PM"
    },
    {
        label: "1:00 PM",
        value: "1:00PM"
    },
    {
        label: "1:30 PM",
        value: "1:30PM"
    },
    {
        label: "2:00 PM",
        value: "2:00PM"
    },
    {
        label: "2:30 PM",
        value: "2:30PM"
    },
    {
        label: "3:00 PM",
        value: "3:00PM"
    },
    {
        label: "3:30 PM",
        value: "3:30PM"
    },
    {
        label: "4:00 PM",
        value: "4:00PM"
    },
    {
        label: "4:30 PM",
        value: "4:30PM"
    },
    {
        label: "5:00 PM",
        value: "5:00PM"
    },
    {
        label: "5:30 PM",
        value: "5:30PM"
    },
    {
        label: "6:00 PM",
        value: "6:00PM"
    },
    {
        label: "6:30 PM",
        value: "6:30PM"
    },
    {
        label: "7:00 PM",
        value: "7:00PM"
    },
    {
        label: "7:30 PM",
        value: "7:30PM"
    },
    {
        label: "8:00 PM",
        value: "8:00PM"
    },
    {
        label: "8:30 PM",
        value: "8:30PM"
    },
    {
        label: "9:00 PM",
        value: "9:00PM"
    },
    {
        label: "9:30 PM",
        value: "9:30PM"
    },
    {
        label: "10:00 PM",
        value: "10:00PM"
    },
    {
        label: "10:30 PM",
        value: "10:30PM"
    },
    {
        label: "11:00 PM",
        value: "11:00PM"
    },
    {
        label: "11:30 PM",
        value: "11:30PM"
    },
    {
        label: "11:59 PM",
        value: "11:59PM"
    },
    {
        label: "12:30 AM (next day)",
        value: "12:30AM(next day)"
    },
    {
        label: "1:00 AM (next day)",
        value: "1:00AM(next day)"
    },
    {
        label: "1:30 AM (next day)",
        value: "1:30AM(next day)"
    },
    {
        label: "2:00 AM (next day)",
        value: "2:00AM(next day)"
    },
    {
        label: "2:30 AM (next day)",
        value: "2:30AM(next day)"
    }
    ];

    valueChanged = false;
    @api
    resetValueChanged() {
        this.valueChanged = false;
    }

    changeInValue() {
        if (!this.valueChanged) {
            this.dispatchEvent(new CustomEvent('changeinvalue'));
            this.valueChanged = true;
        }
    }

    connectedCallback() {
        this.generateStartEndTimeOptions();
    }

    @api
    generateStartEndTimeOptions() {
        let hoursWithOptions = this.dayInfo.hours.map((hour, index) => {
            if (this.dayInfo.hours.length == 1) {
                let endTimeOptionsWithoutFirst = [...this.endTimeOptions];
                endTimeOptionsWithoutFirst.splice(0, 1);
                return {
                    ...hour,
                    startTimeOptions: this.startTimeOptions,
                    endTimeOptions: endTimeOptionsWithoutFirst,
                    invalidInput: !this.isHoursUpdateValid(hour),
                    showRemove: index != 0
                };
            } else {
                return {
                    ...hour,
                    startTimeOptions: this.getTimesBetween(index == 0 ? '' : this.dayInfo.hours[index - 1].end, hour.end, this.startTimeOptions),
                    endTimeOptions: this.getTimesBetween(hour.start, index != this.dayInfo.hours.length - 1 ? this.dayInfo.hours[index + 1].start : '', this.endTimeOptions),
                    invalidInput: !this.isHoursUpdateValid(hour),
                    showRemove: index != 0
                };

            }
        });

        this.dayInfo = {
            ...this.dayInfo,
            hours: hoursWithOptions
        };

    }

    findTimeIndex(time, list) {
        for (let i = 0; i < list.length; i++) {
            if (list[i].value === time) {
                return i;
            }
        }
        return -1; // return -1 if the time is not found in the list
    }

    getTimesBetween(start, end, optionsToFilter) {
        let result = [];
        let foundStart = start === '' ? true : false;
        optionsToFilter.forEach(option => {
            if (option.value === start) {
                foundStart = true;
            }
            if (foundStart) {
                result.push(option);
            }
            if (option.value === end) {
                foundStart = false;
            }
        });
        return result;
    }

    get canAddMoreHours() {
        return this.dayInfo.hours.length < 3 && this.dayInfo.isOpen && !(this.dayInfo.hours[this.dayInfo.hours.length - 1].end).includes('next day') && !this.dayInfo.hours[0].invalidInput;
    }

    get isClosed() {
        return !this.dayInfo.isOpen;
    }

    get showIsClosed() {
        return this.dayInfo.name != 'All Days'
    }

    handleTimeChange(event) {
        this.changeInValue();
        try {
            const field = event.target.name;
            const index = event.target.dataset.index;
            const value = event.target.value;

            let tempHours = JSON.parse(JSON.stringify(this.dayInfo.hours));

            if (field === "open") {
                tempHours[index].start = value;
            } else if (field === "close") {
                tempHours[index].end = value;
            }

            tempHours[index].invalidInput = !this.isHoursUpdateValid(tempHours[index]);
            this.dayInfo = {
                ...this.dayInfo,
                hours: tempHours
            };

            if (this.dayInfo.hours.length != 1) {
                this.generateStartEndTimeOptions();
            }
        } catch (error) {
            console.error('An error occurred:');

        }
    }

    isHoursUpdateValid(tempHour) {
        return this.findTimeIndex(tempHour.start, this.startTimeOptions) <= this.findTimeIndex(tempHour.end, this.endTimeOptions);
    }

    findTimeIndex(time, list) {
        for (let i = 0; i < list.length; i++) {
            if (list[i].value === time) {
                return i;
            }
        }
        return -1; // return -1 if the time is not found in the list
    }

    addTimeWindow() {
        this.changeInValue();
        if (this.canAddMoreHours) {

            let endingOfPrevious = this.dayInfo.hours[this.dayInfo.hours.length - 1].end;

            const newHourSet = {
                start: endingOfPrevious,
                end: "11:30PM",
                showRemove: true
            };

            const updatedHours = [...this.dayInfo.hours, newHourSet];
            this.dayInfo = {
                ...this.dayInfo,
                hours: updatedHours
            };

            this.generateStartEndTimeOptions();
        }
    }

    removeTimeWindow(event) {
        this.changeInValue();
        const index = event.currentTarget.dataset.index;
        this.dayInfo.hours.splice(index, 1); // Remove this element from the object

        this.dayInfo = {
            ...this.dayInfo
        }; // Trigger reactivity to update UI
        this.generateStartEndTimeOptions();
    }

    toggleClosed(event) {
        this.changeInValue();
        const isClosed = event.target.checked;
        const hours = this.dayInfo.hours.length == 0 ? [{
            start: "8:00AM",
            end: "10:00PM"
        }] : this.dayInfo.hours;
        // TODO - How do we represent closed days? Update this logic accordingly
        this.dayInfo = {
            ...this.dayInfo,
            isOpen: !isClosed,
            hours: hours
        };
        this.generateStartEndTimeOptions();
    }

}