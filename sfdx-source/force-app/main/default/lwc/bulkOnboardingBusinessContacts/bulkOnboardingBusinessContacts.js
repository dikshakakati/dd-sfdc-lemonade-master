import { LightningElement, api, track } from "lwc";
import saveContactAndRole from "@salesforce/apex/BulkCorporateOnboardingRequestCtrl.saveContactRole";

const BIZ_DIRECTOR_FIELDS = "Title,Email,Phone,Preferred_Language__c,Birthdate,Salutation,FirstName,MiddleName,LastName,AccountId";
const BIZ_OWNER_FIELDS = "Title,Email,Phone,Preferred_Language__c,Birthdate,Salutation,FirstName,MiddleName,LastName,AccountId,MailingStreet,MailingCity,MailingCountryCode,MailingStateCode,MailingPostalCode";
const BIZ_REP_FIELDS = "Title,Email,Phone,Preferred_Language__c,Birthdate,Salutation,FirstName,MiddleName,LastName,AccountId";
const BIZ_OWNER_INSTRUCTIONS = "Select a Business Owner for the Business. Use the search field to find the right contact by entering either their Name or Email address. For the `Mailing Address`, please use the Business Owner's personal home address.";
const BIZ_DIRECTOR_INSTRUCTIONS = "Select a Business Director for the Business. Use the search field to find the right contact by entering either their Name or Email address.";
const BIZ_REP_INSTRUCTIONS = "Select a Decision Maker for the Business. Use the search field to find the right contact by entering either their Name or Email address.";
const BIZ_OWNER_KEY = "bizOwner";
const BIZ_DIRECTOR_KEY = "bizDirector";
const BIZ_REP_KEY = "bizRep";
const CSS_ACCORDION_HIDE = "accordion-content";
const CSS_ACCORDION_SHOW = "accordion-content slds-p-around_medium accordion-show";
const MSG_FOUND_BIZ_CONTACTS = "Our records indicate that your business or one of your stores is based in Canada. To adhere to Canadian regulations, we need to ensure that the KYC (Know Your Customer) details we have on file are up to date. Below, you'll find the existing information we've previously collected. Please review the below Contact forms carefully and update any information that has changed. Confirming that these details are accurate is essential for maintaining compliance with legal requirements and continuing our partnership without interruption.";
const MSG_NO_BIZ_CONTACTS = "We've noticed that your business or one of your stores is based in Canada. In compliance with Canadian regulations, we are required to collect additional KYC (Know Your Customer) details for legal purposes. Please fill in the sections below with the necessary information about the business contacts.";
const MSG_ERROR_UNKNOWN = "Unknown error. Please try again.";
const TOOLTIP_MAILING_ADDRESS = "The Mailing Address should be the personal home address of the Business Owner.";

export default class BulkOnboardingBusinessContacts extends LightningElement {
    bizContactsFoundMsg = MSG_FOUND_BIZ_CONTACTS;
    noBizContactsFoundMsg = MSG_NO_BIZ_CONTACTS;
    hideCreateFormByDefault = false;

    @api contractId;
    @track instructionalText = this.noBizContactsFoundMsg;
    @track isSaveDisabled = false;
    @track rolesRequired = [];
    @track contacts = [];
    @track isSaving = false;

    @api
    set flowRequestId(value) {
        this._recordId = value;
    }
    get flowRequestId() {
        return this._recordId;
    }

    @api
    set requiredRoles(value) {
        this.rolesRequired = value ? value.split(",").map(role => role.trim()) : [];
    }
    get requiredRoles() {
        return this.rolesRequired.join(", ");
    }

    @api
    set defaultContacts(value) {
        this._defaultContacts = value;
        this.initializeData();
    }
    get defaultContacts() {
        return this._defaultContacts;
    }

    initializeData() {
        // Determine if existing data is found
        this.instructionalText = (this.defaultContacts && Object.keys(this.defaultContacts).length) ? this.bizContactsFoundMsg : this.noBizContactsFoundMsg;

        this.contacts = [
            {
                key: BIZ_DIRECTOR_KEY,
                label: "Business Director",
                roleName: "Business Director",
                isOpen: true,
                disableSave: true,
                errorMessage: undefined,
                hideLookupSearch: false,
                isComplete: false,
                instructionalText: BIZ_DIRECTOR_INSTRUCTIONS,
                contentClass: CSS_ACCORDION_SHOW,
                fieldsToQuery: BIZ_DIRECTOR_FIELDS,
                fields: [
                    { name: "Title", required: false, column: 1 },
                    { name: "Email", required: true, column: 1 },
                    { name: "Phone", required: false, column: 1 },
                    { name: "Preferred_Language__c", required: false, column: 1 },
                    { name: "Birthdate", required: false, column: 1 },
                    { name: "Salutation", required: false, column: 2 },
                    { name: "FirstName", required: true, column: 2 },
                    { name: "MiddleName", required: false, column: 2 },
                    { name: "LastName", required: true, column: 2 },
                ]
            },
            {
                key: BIZ_OWNER_KEY,
                label: "Business Owner",
                roleName: "Business Owner",
                isOpen: false,
                disableSave: true,
                errorMessage: undefined,
                hideLookupSearch: false,
                isComplete: false,
                contentClass: CSS_ACCORDION_HIDE,
                instructionalText: BIZ_OWNER_INSTRUCTIONS,
                fieldsToQuery: BIZ_OWNER_FIELDS,
                fields: [
                    { name: "Title", required: false, column: 1 },
                    { name: "Email", required: true, column: 1 },
                    { name: "Phone", required: false, column: 1 },
                    { name: "Preferred_Language__c", required: false, column: 1 },
                    { name: "Birthdate", required: true, column: 1 },
                    { name: "Salutation", required: false, column: 2 },
                    { name: "FirstName", required: true, column: 2 },
                    { name: "MiddleName", required: false, column: 2 },
                    { name: "LastName", required: true, column: 2 },
                    { column: 2, helpText: TOOLTIP_MAILING_ADDRESS},
                    { name: "MailingStreet", required: true, column: 2 },
                    { name: "MailingCity", required: true, column: 2 },
                    { name: "MailingPostalCode", required: true, column: 2 },
                    { name: "MailingCountryCode", required: true, column: 2 },
                    { name: "MailingStateCode", required: true, column: 2 },
                ]
            },
            {
                key: BIZ_REP_KEY,
                label: "Business Representative (Decision Maker)",
                roleName: "Decision Maker",
                isOpen: false,
                disableSave: true,
                errorMessage: undefined,
                hideLookupSearch: false,
                isComplete: false,
                contentClass: CSS_ACCORDION_HIDE,
                instructionalText: BIZ_REP_INSTRUCTIONS,
                fieldsToQuery: BIZ_REP_FIELDS,
                fields: [
                    { name: "Title", required: true, column: 1 },
                    { name: "Email", required: true, column: 1 },
                    { name: "Phone", required: true, column: 1 },
                    { name: "Preferred_Language__c", required: false, column: 1 },
                    { name: "Birthdate", required: false, column: 1 },
                    { name: "Salutation", required: false, column: 2 },
                    { name: "FirstName", required: true, column: 2 },
                    { name: "MiddleName", required: false, column: 2 },
                    { name: "LastName", required: true, column: 2 },
                ]
            }
        ];

        // This is where we initialize the contacts with the defaults that our Apex method found
        this.contacts.forEach(contact => {
            const updatedContactData = this.defaultContacts[contact.roleName]; // Defaults are stored on a per-role basis
            if (updatedContactData) {
                contact.contactId = updatedContactData.Id || null;
                contact.updatedContactData = updatedContactData;
            } else {
                contact.updatedContactData = null;
                contact.contactId = null;
            }
        });
    }

    toggleSection(event) {
        const key = event.currentTarget.dataset.key;
        for(let i = 0; i < this.contacts.length; i++) {
            let thisContact = this.contacts[i];

            if(thisContact.key !== key) {
                continue;
            }

            thisContact.isOpen = !thisContact.isOpen;
            thisContact.contentClass = (thisContact.isOpen) ? CSS_ACCORDION_SHOW : CSS_ACCORDION_HIDE;
            this.contacts[i] = thisContact;
        }
    }

    handleSaveAndContinue(event) {
        this.isSaving = true; // Make sure this is still set to `true`
        const contactId = event.detail.contactId;
        const contactDetails = event.detail.contactDetails;
        const updatedContactData = event.detail.updatedContactData;
        const fieldNames = event.detail.fieldNames;
        const key = contactDetails.key;

        saveContactAndRole({ flowRequestId: this.flowRequestId, contactRole: contactDetails.roleName, contactId: contactId, updatedContactData: updatedContactData, fieldNames: fieldNames })
            .then(() => {
                // Mark this contact as completed
                const contactIndex = this.contacts.findIndex(contact => contact.key === key);
                if(contactIndex !== -1) {
                    this.contacts[contactIndex].isComplete = true;
                }

                this.updateAccordionAfterSave(key);
            })
            .catch(error => {
                let errorMessages = [MSG_ERROR_UNKNOWN]; // Default error message if no pageErrors are found

                if (error.body && error.body.pageErrors && error.body.pageErrors.length) {
                    // Construct the list of error messages
                    errorMessages = error.body.pageErrors.map(pageError => pageError.message);
                }

                console.error(`Error encountered in the handleSaveAndContinue() function! Error Messages: ${errorMessages}`);
                console.error(error); // Full error object

                const errorMessage = errorMessages.join('///'); // Construct the final error message
                const contactIndex = this.contacts.findIndex(contact => contact.key === key);
                if(contactIndex !== -1) {
                    let randomNumber = Math.random(); // Ensures uniqueness at the child level, which forces a render of the error message even if the error remains the same
                    this.contacts[contactIndex].errorMessage = `${randomNumber}: ${errorMessage}`;
                }
            })
            .finally(() => {
                this.updateSaveStatus(false);
            });

    }

    updateAccordionAfterSave(key) {
        const index = this.contacts.findIndex(contact => contact.key === key);
        const nextIndex = index + 1 < this.contacts.length ? index + 1 : 0;
        let allContactsAreCompleted = true;

        this.contacts.forEach((contact, idx) => {
            contact.isOpen = idx === nextIndex;
            contact.contentClass = (contact.isOpen) ? CSS_ACCORDION_SHOW : CSS_ACCORDION_HIDE;

            if(!contact.isComplete) {
                allContactsAreCompleted = false;
            }
        });

        if(allContactsAreCompleted) {
            this.dispatchEvent(new CustomEvent("allcontactscompleted"));
        }
    }

    handleUpdateSaveStatus(event) {
        const isSaving = event.detail.isSaving;
        this.isSaving = isSaving;
    }

    updateSaveStatus(isSaving) {
        this.isSaving = isSaving;
    }

    logger(obj) {
        if(obj) {
            console.log(JSON.parse(JSON.stringify(obj)));
        } else {
            console.log("Object is not defined or null");
        }
    }
}
