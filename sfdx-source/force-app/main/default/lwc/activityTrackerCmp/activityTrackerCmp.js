import { LightningElement, api, track, wire } from 'lwc';
import fetchActivityDetails from "@salesforce/apex/ActivityTrackerComponentController.fetchActivityDetails";
import updateEmailMessageToOpened from "@salesforce/apex/ActivityTrackerComponentController.updateEmailMessageToOpened";


const BASE_URL = window.location.origin;

export default class ActivityTrackerCmp extends LightningElement {
    @api recordId;
    @track emailMessages = [];
    showComponent = false;
    noRecordFound = 'No records found';
    areEmailMessagesFound = true;


    /**
    * @description it fetches all the email messages.
    */
    @wire(fetchActivityDetails, { workplanId: "$recordId" })
    getEmailMessages({ data, error }) {
        if (data) {
            this.emailMessages = data.map(item => ({
                ...item,
                toggleEmails: false,
                storeAccountUrl: BASE_URL + '/' + item.accountId,
                emailMessages: item.emailMessages.map(message => ({
                    ...message,
                    MessageDate: this.convertMessageSendDate(message.MessageDate),
                    FirstOpenedDate: this.calculateTimeElapsed(message.FirstOpenedDate),
                    Subject: message.Subject ? message.Subject : '[No Subject]',
                    areDetailsVisible: false,
                    emailMessageUrl: BASE_URL + '/' + message.Id
                }))
            }));

            if (this.emailMessages.length == 0) {
                this.areEmailMessagesFound = false;
            }
            this.showComponent = true;
        }
        else if (error) {
            console.log('eror' + JSON.stringify(error));
            this.showComponent = true;
        }
    }

    /**
    * @description it handles the accordion for accounts.
    */
    handleStoreAccordion(event) {
        this.showComponent = false;
        let index = event.target.dataset.index;
        this.emailMessages[index].toggleEmails = !this.emailMessages[index].toggleEmails;
        this.showComponent = true;
    }

    /**
    * @description it converts the message which needs to be displayed.
    */
    convertMessageSendDate(dateString) {
        const options = { hour: 'numeric', minute: 'numeric', hour12: true };
        const date = new Date(dateString);
        const time = date.toLocaleTimeString('en-US', options);
        const day = date.getDate();
        const month = date.toLocaleString('default', { month: 'short' });
        return `${time} | ${day}-${month}`
    }

    /**
    * @description it manipulates the time.
    */
    calculateTimeElapsed(dateString) {
        const date = new Date(dateString);
        const now = new Date();
        const secondsAgo = Math.floor((now - date) / 1000);
        let interval = Math.floor(secondsAgo / 31536000);

        if (interval > 1) {
            return interval + ' years ago';
        }
        interval = Math.floor(secondsAgo / 2592000);
        if (interval > 1) {
            return interval + ' months ago';
        }
        interval = Math.floor(secondsAgo / 86400);
        if (interval > 1) {
            return interval + ' days ago';
        }
        interval = Math.floor(secondsAgo / 3600);
        if (interval > 1) {
            return interval + ' hours ago';
        }
        interval = Math.floor(secondsAgo / 60);
        if (interval > 1) {
            return interval + ' minutes ago';
        }
        return Math.floor(secondsAgo) + ' seconds ago';
    }

    /**
    * @description it toggle the details.
    */
    handleEmailAccordion(event) {
        this.showComponent = false;
        let index = event.target.dataset.index;
        let accountIndex = event.target.dataset.accountindex;
        let emailMsgId = event.target.dataset.messageid;
        this.emailMessages[accountIndex].emailMessages[index].areDetailsVisible = !this.emailMessages[accountIndex].emailMessages[index].areDetailsVisible;
        // update email message to opened.
        if (this.emailMessages[accountIndex].emailMessages[index].areDetailsVisible) {
            updateEmailMessageToOpened({ emailMessageId: emailMsgId })
                .then(result => {
                })
                .catch(error => {
                    console.log('error ' + JSON.stringify(error));
                });

        }
        this.showComponent = true;
    }

    /**
    * @description it handles click of the link, and further tracks that email message has been opened.
    */
    handleEmailMessageLinkClick(event) {
        let index = event.target.dataset.index;
        updateEmailMessageToOpened({ emailMessageId: index })
            .then(result => {
            })
            .catch(error => {
                console.log('error ' + JSON.stringify(error));
            });

    }


}