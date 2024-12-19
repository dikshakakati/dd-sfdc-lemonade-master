import { LightningElement, api, wire } from "lwc";
import { getRecord } from 'lightning/uiRecordApi';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import BILLING_ADDRESS from "@salesforce/schema/Account.BillingAddress";
import BILLING_CITY from "@salesforce/schema/Account.BillingCity";
import BILLING_COUNTRY from "@salesforce/schema/Account.BillingCountry";
import BILLING_COUNTRY_CODE from "@salesforce/schema/Account.BillingCountryCode";
import BILLING_STATE from "@salesforce/schema/Account.BillingState";
import BILLING_STATE_CODE from "@salesforce/schema/Account.BillingStateCode";
import BILLING_STREET from "@salesforce/schema/Account.BillingStreet";
import BILLING_POSTAL_CODE from "@salesforce/schema/Account.BillingPostalCode";
import FIRST_NAME from "@salesforce/schema/Contact.FirstName";
import LAST_NAME from "@salesforce/schema/Contact.LastName";
import EMAIL from "@salesforce/schema/Contact.Email";
import PHONE from "@salesforce/schema/Contact.Phone";
import MOBILE_PHONE from "@salesforce/schema/Contact.MobilePhone";
import {
	subscribe,
	unsubscribe,
	APPLICATION_SCOPE,
	MessageContext,
} from 'lightning/messageService';
import selectedLookUpRecord from '@salesforce/messageChannel/Lookup_Event__c';
const accountFields = [
	"Account.BillingCity", "Account.BillingCountry", "Account.BillingCountryCode", "Account.BillingState", "Account.BillingStateCode", "Account.BillingStreet", "Account.BillingPostalCode", "Account.Menu_URL__c"
];
const contactFields = [
	"Contact.FirstName", "Contact.LastName", "Contact.Email", "Contact.Phone", "Contact.MobilePhone"
]
/*const accountFields = [
	BILLING_CITY,
	BILLING_COUNTRY,
	BILLING_COUNTRY_CODE,
	BILLING_STATE,
	BILLING_STATE_CODE,
	BILLING_STREET,
	BILLING_POSTAL_CODE
];
const contactFields = [
	FIRST_NAME, LAST_NAME,EMAIL,PHONE,MOBILE_PHONE
];*/
export default class GuidedFlowGetRecordDetails extends LightningElement {
	@api recordId;
	@api billingAddress;
	@api billingCity;
	@api billingCountry = 'US';
	@api billingCountryCode;
	@api billingState;
	@api billingStreet;
	@api billingPostalCode;
	@api contactFirstName;
	@api contactLastName;
	@api contactEmail;
	@api contactPhone;
	@api contactMobilePhone;
	@api billingStateCode;
	@api selectedAccountRecordId;
	@api selectedContactRecordId;
	@api selectedObjectName;
	@api menuURL;
	isNotHiddenField = false;
	subscription = null;
	address = {};
	disabledAddress = true;
	contactDetails = true;
	countryProvinceMap = {
		"US": [
			{
				"label": "Alabama",
				"value": "AL"
			},
			{
				"label": "Alaska",
				"value": "AK"
			},
			{
				"label": "American Samoa",
				"value": "AS"
			},
			{
				"label": "Arizona",
				"value": "AZ"
			},
			{
				"label": "Arkansas",
				"value": "AR"
			},
			{
				"label": "California",
				"value": "CA"
			},
			{
				"label": "Colorado",
				"value": "CO"
			},
			{
				"label": "Connecticut",
				"value": "CT"
			},
			{
				"label": "Delaware",
				"value": "DE"
			},
			{
				"label": "District Of Columbia",
				"value": "DC"
			},
			{
				"label": "Federated States Of Micronesia",
				"value": "FM"
			},
			{
				"label": "Florida",
				"value": "FL"
			},
			{
				"label": "Georgia",
				"value": "GA"
			},
			{
				"label": "Guam",
				"value": "GU"
			},
			{
				"label": "Hawaii",
				"value": "HI"
			},
			{
				"label": "Idaho",
				"value": "ID"
			},
			{
				"label": "Illinois",
				"value": "IL"
			},
			{
				"label": "Indiana",
				"value": "IN"
			},
			{
				"label": "Iowa",
				"value": "IA"
			},
			{
				"label": "Kansas",
				"value": "KS"
			},
			{
				"label": "Kentucky",
				"value": "KY"
			},
			{
				"label": "Louisiana",
				"value": "LA"
			},
			{
				"label": "Maine",
				"value": "ME"
			},
			{
				"label": "Marshall Islands",
				"value": "MH"
			},
			{
				"label": "Maryland",
				"value": "MD"
			},
			{
				"label": "Massachusetts",
				"value": "MA"
			},
			{
				"label": "Michigan",
				"value": "MI"
			},
			{
				"label": "Minnesota",
				"value": "MN"
			},
			{
				"label": "Mississippi",
				"value": "MS"
			},
			{
				"label": "Missouri",
				"value": "MO"
			},
			{
				"label": "Montana",
				"value": "MT"
			},
			{
				"label": "Nebraska",
				"value": "NE"
			},
			{
				"label": "Nevada",
				"value": "NV"
			},
			{
				"label": "New Hampshire",
				"value": "NH"
			},
			{
				"label": "New Jersey",
				"value": "NJ"
			},
			{
				"label": "New Mexico",
				"value": "NM"
			},
			{
				"label": "New York",
				"value": "NY"
			},
			{
				"label": "North Carolina",
				"value": "NC"
			},
			{
				"label": "North Dakota",
				"value": "ND"
			},
			{
				"label": "Northern Mariana Islands",
				"value": "MP"
			},
			{
				"label": "Ohio",
				"value": "OH"
			},
			{
				"label": "Oklahoma",
				"value": "OK"
			},
			{
				"label": "Oregon",
				"value": "OR"
			},
			{
				"label": "Palau",
				"value": "PW"
			},
			{
				"label": "Pennsylvania",
				"value": "PA"
			},
			{
				"label": "Puerto Rico",
				"value": "PR"
			},
			{
				"label": "Rhode Island",
				"value": "RI"
			},
			{
				"label": "South Carolina",
				"value": "SC"
			},
			{
				"label": "South Dakota",
				"value": "SD"
			},
			{
				"label": "Tennessee",
				"value": "TN"
			},
			{
				"label": "Texas",
				"value": "TX"
			},
			{
				"label": "Utah",
				"value": "UT"
			},
			{
				"label": "Vermont",
				"value": "VT"
			},
			{
				"label": "Virgin Islands",
				"value": "VI"
			},
			{
				"label": "Virginia",
				"value": "VA"
			},
			{
				"label": "Washington",
				"value": "WA"
			},
			{
				"label": "West Virginia",
				"value": "WV"
			},
			{
				"label": "Wisconsin",
				"value": "WI"
			},
			{
				"label": "Wyoming",
				"value": "WY"
			}
		]
	};
	//fields;
	@wire(MessageContext)
	messageContext;

	// Encapsulate logic for Lightning message service subscribe and unsubsubscribe
	subscribeToMessageChannel() {
		if (!this.subscription) {
			this.subscription = subscribe(
				this.messageContext,
				selectedLookUpRecord,
				(message) => this.handleMessage(message),
				{ scope: APPLICATION_SCOPE }
			);
		}
	}

	unsubscribeToMessageChannel() {
		unsubscribe(this.subscription);
		this.subscription = null;
	}

	// Handler for message received by component
	handleMessage(message) {
		if (message.selectedObjectName == 'Account') {
			//this.selectedAccountRecordId = message.selectedRecordId;
			this.recordId = message.selectedRecordId;
			//this.fields = accountFields;
		}
		if (message.selectedObjectName == 'Contact') {
			//this.selectedContactRecordId = message.selectedRecordId;
			this.recordId = message.selectedRecordId;
			//this.fields = contactFields;
		}
	}

	// Standard lifecycle hooks used to subscribe and unsubsubscribe to the message channel
	connectedCallback() {
		this.fields = this.objectFields;
		if (this.selectedAccountRecordId) {
			this.recordId = this.selectedContactRecordId;
		}
		this.subscribeToMessageChannel();
	}

	disconnectedCallback() {
		this.unsubscribeToMessageChannel();
	}

	@wire(getRecord, {
		recordId: '$recordId', fields: "$dataFields"
	})
	wiredRecord({ error, data }) {
		console.log('Data', JSON.stringify(data));
		console.log('selectedObjectName');
		if (data && this.displayContactSection) {
			let contact = data;
			this.contactDetails = false;
			this.contactFirstName = contact.fields?.FirstName?.value;
			this.contactLastName = contact.fields?.LastName?.value;
			this.contactEmail = contact.fields?.Email?.value;
			this.contactPhone = contact.fields?.Phone?.value;
			this.contactMobilePhone = contact.fields?.MobilePhone?.value;
			console.log(this.contactFirstName);
			console.log(this.contactLastName);
			console.log(this.contactEmail);
			console.log(this.contactPhone);
			console.log(this.contactMobilePhone);
		}
		if (data && this.displayAccountSection) {
			let account = data;
			//this.billingAddress = account.fields.BillingAddress.value;
			this.disabledAddress = false;
			this.billingCity = account.fields?.BillingCity?.value;
			this.billingCountry = account.fields?.BillingCountry?.value;
			this.billingCountryCode = account.fields?.BillingCountryCode?.value;
			this.billingState = account.fields?.BillingState?.value;
			this.billingStateCode = account.fields?.BillingStateCode?.value;
			this.billingStreet = account.fields?.BillingStreet?.value;
			this.billingPostalCode = account.fields?.BillingPostalCode?.value;
			this.menuURL = account.fields?.Menu_URL__c?.value;
			this.address = {
				"street": account.fields?.BillingStreet?.value,
				"city": account.fields?.BillingCity?.value,
				"country": account.fields?.BillingCountryCode?.value,
				"postalCode": account.fields?.BillingPostalCode?.value,
				"province": account.fields?.BillingState?.value,
			}
			console.log('this.address=', this.address);
			/*const attributeChangeEvent = new FlowAttributeChangeEvent({
			   'billingCity' : account.fields?.BillingCity?.value,
			   'billingCountry' : account.fields?.BillingCountry?.value,
			   'billingCountryCode' : account.fields?.BillingCountryCode?.value,
				'billingState' : account.fields?.BillingState?.value,
			   'billingStateCode' : account.fields?.BillingStateCode?.value,
			   'billingStreet' : account.fields?.BillingStreet?.value,
			   'billingPostalCode' : account.fields?.BillingPostalCode?.value,
			   'menuURL' : account.fields?.Menu_URL__c?.value

			});
			this.dispatchEvent(attributeChangeEvent);*/
		}
	}
	get getProvinceOptions() {
		if (this.billingCountry)
			return this.countryProvinceMap[this.billingCountry];
		return this.countryProvinceMap['US'];
	}
	countryOptions = [
		{ label: 'United States', value: 'US' }
	];
	get getCountryOptions() {
		return this.countryOptions;
	}
	get displayContactSection() {
		if (this.selectedObjectName === 'Contact') {
			return true;
		}
		return false;
	}
	get displayAccountSection() {
		if (this.selectedObjectName === 'Account') {
			return true;
		}
		return false;
	}
	get dataFields() {
		if (this.displayAccountSection)
			return accountFields;
		if (this.displayContactSection)
			return contactFields;
		return;
	}
	handleChange(event) {
		console.log(' event.detail.country=', event.detail.country)
		this.billingCountry = event.detail.country;
		console.log('event.detail.country1=', this.billingCountry)
	}
	handleInputChange(event) {
		console.log('event.detail=', JSON.stringify(event.detail));
		const { name, value } = event.detail;
		const attributeChangeEvent = new FlowAttributeChangeEvent(name, value);
		this.dispatchEvent(attributeChangeEvent);
	}
}