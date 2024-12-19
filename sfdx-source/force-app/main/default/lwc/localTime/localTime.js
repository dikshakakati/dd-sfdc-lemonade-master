import { LightningElement, api, wire } from "lwc";
import getTimeZone from "@salesforce/apex/LocalTimeController.getTimeZoneFromBackend";

export default class LocalTime extends LightningElement {
  @api recordId;
  error;
  localTime;
  intervalId;
  timezone;
  offset;

  disconnectedCallback() {
    clearInterval(this.intervalId);
  }

  @wire(getTimeZone, { recordId: "$recordId" })
  setTimeZone({ error, data }) {
    if (error) {
      this.handleError(error);
    } else if (data) {
      this.handleData(data);
    }
  }

  handleError(error) {
    console.error("Error fetching time zone", error);
    this.error = "The merchant's local time zone information is currently unavailable";
  }

  handleData(data) {
    this.timezone = data.timeZoneBackend;
    this.updateTime();
    this.startTimeInterval();
  }

  startTimeInterval() {
    this.intervalId = setInterval(() => {
      this.updateTime();
    }, 10000);
  }

  updateTime() {
    this.localTime = new Date();
    this.offset = this.getTimeZoneOffset();
  }

  getTimeZoneOffset() {
    const formattedDate = new Intl.DateTimeFormat(undefined, {
      timeZone: this.timezone,
      timeZoneName: "shortOffset"
    }).format();
    return formattedDate.split(",")[1].trim();
  }
}
