import { LightningElement, wire, api, track } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import RATE_CARD_OBJECT from '@salesforce/schema/Rate_Card__c';
import STATE_FIELD from '@salesforce/schema/Rate_Card__c.State__c';
import FEE_TYPE_FIELD from '@salesforce/schema/Rate_Card__c.Fee_Type__c';
import insertRateCard from '@salesforce/apex/ConfigureRateCardController.upsertRateCards';
import getRateCards from '@salesforce/apex/ConfigureRateCardController.getRateCardsForQuoteLine';
import getStandardRateCardTiers from '@salesforce/apex/ConfigureRateCardController.getStandardRateCardTiers';
import LightningConfirm from "lightning/confirm";
import ErrorMessageforSelectedProduct from '@salesforce/label/c.ErrorMessageForSelectedProductOtherThanAlcoholDeliveryPickup';
import ErrorMessageToEnterValidRateCards from '@salesforce/label/c.ErrorMessageToEnterValidRateCards';
import ErrorMessageToEnterValidRateCardTiers from '@salesforce/label/c.ErrorMessageToEnterValidRateCardTiers';
import ErrorMessageWhenSameStateSelectedAgain from '@salesforce/label/c.ErrorMessageWhenSameStateSelectedAgain';
import MessageWhenRateCardsSavedSuccessfully from '@salesforce/label/c.MessageWhenRateCardsSavedSuccessfully';
import QuickSaveBeforeAddingRateCardsForNewQuoteLine from '@salesforce/label/c.QuickSaveBeforeAddingRateCardsForNewQuoteLine';
const TIERED_PRICING = 'Tiered Pricing';

export default class DynamicallyAddRow extends LightningElement {
    @api recordId;
    @api productCode;
    @api quoteId;
    @api packageName;
    @api packageCode;
    @api type;
    @api upgradedSubscription;
    @api groupId;

    stateOptions = [{ value: '', label: '-None-' }];
    feeTypeOptions = [{ value: '', label: '-None-' }];
    keyIndex = 0;
    keyIndexRateCardTier = 0;
    isSpinner = false;
    isSaveInProgess = false;
    showModal = false;
    isEligibleProduct = false;
    isQuoteLineSaved = false;
    errorMessageForSelectedProduct = ErrorMessageforSelectedProduct;
    errorMessageForBlankQLId = QuickSaveBeforeAddingRateCardsForNewQuoteLine;

    @track filterList = [];
    @track deleteRateCards = [];
    @track standardRateCardTierList = [];
    @track rateCardTier = [];
    @track deleteRateCardTiers = [];
    @track selectedRateCard;

    /**
     * @description This method is used to get the Object info of Rate Card object
     */
    @wire(getObjectInfo, { objectApiName: RATE_CARD_OBJECT })
    ratecardinfo;

    /**
     * @description This method is used to get the picklist values of Rate Card State field
     */
    @wire(getPicklistValues, { recordTypeId: '$ratecardinfo.data.defaultRecordTypeId', fieldApiName: STATE_FIELD })
    stateValues({ data, error }) {
        if (data) {
            data.values.forEach(val => {
                this.stateOptions = [...this.stateOptions, { value: val.value, label: val.label }];
            });
        }
        else if (error) {
            this.processErrorMessage(error);
        }
    }

    /**
     * @description This method is used to get the picklist values of Rate Card Fee Type field
     */
    @wire(getPicklistValues, { recordTypeId: '$ratecardinfo.data.defaultRecordTypeId', fieldApiName: FEE_TYPE_FIELD })
    feeTypeValues({ data, error }) {
        if (data) {
            data.values.forEach(val => {
                this.feeTypeOptions = [...this.feeTypeOptions, { value: val.value, label: val.label }];
            });
        }
        else if (error) {
            this.processErrorMessage(error);
        }
    }

    /**
     * @description This method is used to get Standard Rate Card Tiers details.
     */
    @wire(getStandardRateCardTiers)
    getRateCardsTier({ error, data }) {
        if (error) {
            this.processErrorMessage(error);
        } else if (data) {
            this.standardRateCardTierList = data;
        }
    }

    /**
     * @description To perform logic after component is inserted into the DOM.
     */
    connectedCallback() {
        if (this.productCode != '10061' || this.packageName != 'Marketplace') {
            this.isEligibleProduct = false;
        } else if (this.recordId == undefined) {
            this.isQuoteLineSaved = false;
            this.isEligibleProduct = true;
        } else {
            this.isEligibleProduct = true;
            this.isQuoteLineSaved = true;
            this.getRateCards();
        }
    }
    get displayTable() {
        return this.isQuoteLineSaved && this.isEligibleProduct;
    }
    get eligibleProductCheck() {
        return !this.isEligibleProduct;
    }
    get quoteLineIdExists() {
        return !this.isQuoteLineSaved;
    }
    /**
     * @description This method is used to get Rate Cards and Rate Card Tiers details related to Quote Line.
     */
    getRateCards() {
        this.isSpinner = true;
        getRateCards({
            quoteLineRecId: this.recordId,
            type: this.type,
            upgradedSubscription: this.upgradedSubscription,
            quoteId: this.quoteId,
            groupId: this.groupId
        })
            .then(data => {
                data.forEach(val => {
                    let objRow = {
                        Id: val.Id,
                        State__c: val.State__c,
                        Fee_Type__c: val.Fee_Type__c,
                        Requested_Fee__c: val.Requested_Fee__c,
                        Quote_Line__c: this.recordId,
                        RateCardKey: ++this.keyIndex,
                        showRateCard: val.Fee_Type__c == TIERED_PRICING ? true : false
                    };
                    if (val.Rate_Card_Tiers__r != undefined) {
                        var rateCardTiers = [];
                        val.Rate_Card_Tiers__r.forEach(rateCardTierVal => {
                            let rateCardTierObjRow = {
                                Id: rateCardTierVal.Id,
                                Lower_Bound__c: rateCardTierVal.Lower_Bound__c,
                                Upper_Bound__c: rateCardTierVal.Upper_Bound__c,
                                Fee_Value__c: rateCardTierVal.Fee_Value__c,
                                Rate_Card__c: val.Id,
                                RateCardTierKey: ++this.keyIndexRateCardTier
                            };
                            rateCardTiers.push(rateCardTierObjRow);
                        });
                        objRow.relatedRateCardTiers = rateCardTiers;
                    } else {
                        objRow.relatedRateCardTiers = [];
                    }
                    objRow.deleteRateCardTiers = [];
                    this.filterList.push(objRow);
                });
                if (data.length == 0) {
                    this.handleAddRow();
                }
                this.isSpinner = false;
            }).catch(error => {
                this.processErrorMessage(error);
                this.isSpinner = false;
            });
    }

    /**
     * @description This method is used to store the Rate Card fields values when they are changed
     * @param event
     */
    handleChange(event) {
        var record = this.filterList[event.currentTarget.dataset.index];
        if (event.target.name === 'state') {
            let isStateExist = false;
            this.filterList.forEach((val) => {
                if (val.State__c == event.target.value) {
                    isStateExist = true;
                }
            });
            if (isStateExist) {
                this.showMessage('error', ErrorMessageWhenSameStateSelectedAgain, 'Error!');
                event.target.value = '';
                record.State__c = '';
            } else {
                record.State__c = event.target.value;
            }
        }
        else if (event.target.name === 'feeType') {
            let objRow = {
                Id: record.Id != undefined ? record.Id : undefined,
                State__c: record.State__c,
                Fee_Type__c: event.target.value,
                Requested_Fee__c: event.target.value == TIERED_PRICING ? '' : record.Requested_Fee__c,
                Quote_Line__c: this.recordId,
                RateCardKey: ++this.keyIndex,
                showRateCard: event.target.value == TIERED_PRICING ? true : false,
                relatedRateCardTiers: record.relatedRateCardTiers,
                deleteRateCardTiers: record.deleteRateCardTiers
            };
            this.filterList.splice(event.currentTarget.dataset.index, 1, objRow);
        }
        else if (event.target.name === 'feeValue') {
            record.Requested_Fee__c = event.target.value;
        }
    }

    /**
     * @description This method is used to store the Rate Card Tier fields values when they are changed
     * @param event
     */
    handleChangeRateCardTierValues(event) {
        var record = this.rateCardTier.filter(ele => ele.RateCardTierKey == event.target.dataset.rowId)[0];
        if (event.target.name === 'LowerBand') {
            record.Lower_Bound__c = parseFloat(event.target.value);
        } else if (event.target.name === 'UpperBand') {
            record.Upper_Bound__c = parseFloat(event.target.value);
            if (event.target.value == '') {
                record.Upper_Bound__c = null;
            }
        } else if (event.target.name === 'FlatFee') {
            record.Fee_Value__c = parseFloat(event.target.value);
        }
    }

    /**
     * @description This method is used to open a Modal show the Rate Card Tiers related to Rate Card or
     * show the Standard Rate Card Tiers if there are not Rate Card Tiers associated to Rate Card
     * @param event
     */
    handleViewRateCard(event) {
        this.showModal = true;
        this.rateCardTier = [];
        this.deleteRateCardTiers = [];
        this.selectedRateCard = this.filterList[event.currentTarget.dataset.index];
        if (this.selectedRateCard.relatedRateCardTiers.length > 0) {
            this.rateCardTier = this.selectedRateCard.relatedRateCardTiers;
        } else {
            this.standardRateCardTierList.forEach((val) => {
                let objRow = {
                    Lower_Bound__c: val.Lower_Bound__c,
                    Upper_Bound__c: val.Upper_Bound__c,
                    Fee_Value__c: val.Fee_Value__c,
                    Rate_Card__c: this.selectedRateCard.Id != undefined ? this.selectedRateCard.Id : undefined,
                    RateCardTierKey: ++this.keyIndexRateCardTier
                };
                this.rateCardTier.push(objRow);
            });
        }
    }

    /**
     * @description This method is used to insert, update and delete the Rate Cards and Rate Card Tiers
     */
    handleSave() {
        this.isSaveInProgess = true;
        this.isSpinner = true;
        var finalList = [];
        var isValidData = true;
        this.filterList.forEach(ele => {
            if (ele.State__c === '' || ele.Fee_Type__c === '') {
                isValidData = false;
            }
            if (ele.Fee_Type__c == TIERED_PRICING && ele.relatedRateCardTiers.length == 0) {
                isValidData = false;
            }
            if (ele.Fee_Type__c != TIERED_PRICING && (ele.Requested_Fee__c === '' || ele.Requested_Fee__c < 0)) {
                isValidData = false;
            }
            let objRate = {
                Id: ele.Id,
                State__c: ele.State__c,
                Fee_Type__c: ele.Fee_Type__c,
                Requested_Fee__c: ele.Requested_Fee__c,
                Quote_Line__c: this.recordId,
            };
            let obj = {
                rateCard: objRate,
                deleteRateCardTiers: ele.deleteRateCardTiers
            }
            var relatedRateCardTiers = [];
            if (objRate.Fee_Type__c != TIERED_PRICING) {
                ele.relatedRateCardTiers.forEach(rateCardTier => {
                    if (rateCardTier.Id != undefined) {
                        relatedRateCardTiers.push(rateCardTier);
                    }
                });
                obj.relatedRateCardTiers = relatedRateCardTiers;
            } else {
                obj.relatedRateCardTiers = ele.relatedRateCardTiers;
            }
            finalList.push(obj);
        });
        if (isValidData) {
            insertRateCard({ lstRateCards: JSON.stringify(finalList), deleteRateCards: this.deleteRateCards, quoteLineRecId: this.recordId })
                .then(result => {
                    this.isSpinner = false;
                    this.isSaveInProgess = false;
                    this.refreshPage('success', MessageWhenRateCardsSavedSuccessfully, 'Success');
                }).catch(error => {
                    this.processErrorMessage(error);
                    this.isSaveInProgess = false;
                    this.isSpinner = false;
                })
        } else {
            this.isSaveInProgess = false;
            this.isSpinner = false;
            this.showMessage('error', ErrorMessageToEnterValidRateCards, 'Error!');
        }
    }

    /**
     * @description This method is used to add the Related Rate Card Tiers and Delete Rate Card Tiers to the Rate Card
     */
    handleSaveRateCards() {
        this.isSaveInProgess = true;
        const cloneData = [...this.rateCardTier];
        cloneData.sort(this.sortBy('Fee_Value__c', 'asc' === 'asc' ? 1 : -1));
        this.rateCardTier = cloneData;

        var isValidData = true;
        let upperBoundValue = 0.00;
        var lastRateCardTier = this.rateCardTier[this.rateCardTier.length - 1];
        if (lastRateCardTier.Upper_Bound__c != '' && lastRateCardTier.Upper_Bound__c != null) {
            isValidData = false;
        }
        this.rateCardTier.forEach(ele => {
            if (ele.Lower_Bound__c === '' || ele.Fee_Value__c === '' || ele.Lower_Bound__c < 0 || ele.Fee_Value__c < 0) {
                isValidData = false;
            }
            if (parseFloat(ele.Lower_Bound__c) != parseFloat(upperBoundValue)) {
                isValidData = false;
            }
            upperBoundValue = parseFloat(ele.Upper_Bound__c) + 0.01;
        })
        if (isValidData) {
            this.filterList.forEach((ele) => {
                if (ele.RateCardKey == this.selectedRateCard.RateCardKey) {
                    ele.relatedRateCardTiers = this.rateCardTier;
                    ele.deleteRateCardTiers = this.deleteRateCardTiers;
                }
            });
            this.showModal = false;
            this.isSaveInProgess = false;
        } else {
            this.isSaveInProgess = false;
            this.showMessage('error', ErrorMessageToEnterValidRateCardTiers, 'Error!');
        }
    }

    /**
     * @description This method is used to add a new Rate Card row to the Rate Card List
     */
    handleAddRow() {
        let objRow = {
            State__c: '',
            Fee_Type__c: '',
            Requested_Fee__c: '',
            Quote_Line__c: this.recordId,
            RateCardKey: ++this.keyIndex,
            showRateCard: false,
            relatedRateCardTiers: [],
            deleteRateCardTiers: []
        };
        this.filterList.push(objRow);
    }

    /**
     * @description This method is used to clone the Rate Card row
     * @param event
     */
    handleCloneRow(event) {
        const clonedRateCardList = JSON.parse(JSON.stringify(this.filterList));
        let cloneRateCard = clonedRateCardList.filter(ele => ele.RateCardKey == event.target.dataset.rowId)[0];
        cloneRateCard.Id = undefined;
        cloneRateCard.State__c = '';
        cloneRateCard.RateCardKey = ++this.keyIndex;
        cloneRateCard.relatedRateCardTiers.forEach(ele => {
            ele.Id = undefined;
            ele.Rate_Card__c = undefined;
            ele.RateCardTierKey = ++this.keyIndexRateCardTier;
        });
        this.filterList.push(cloneRateCard);
    }

    /**
     * @description This method is used to remove the Rate Card row to the Rate Card List
     * @param event
     */
    handleRemoveRow(event) {
        var deletedRateCard = this.filterList[event.currentTarget.dataset.index];
        if (deletedRateCard.Id != undefined) {
            this.deleteRateCards.push(deletedRateCard);
        }
        this.filterList = this.filterList.filter((ele) => {
            return parseInt(ele.RateCardKey) !== parseInt(event.target.dataset.rowId);
        });

        if (this.filterList.length === 0) {
            this.handleAddRow();
        }
    }

    /**
     * @description This method is used to add a new Rate Card Tier row to the Rate Card Tier List
     */
    handleAddRowRateCardTier() {
        let objRow = {
            Lower_Bound__c: '',
            Upper_Bound__c: null,
            Fee_Value__c: '',
            RateCardTierKey: ++this.keyIndexRateCardTier
        }

        this.rateCardTier.push(objRow);
    }

    /**
     * @description This method is used to remove the Rate Card Tier row to the Rate Card Tier List
     * @param event
     */
    handleRemoveRowRateCardTier(event) {
        var deletedRateCardTier = this.rateCardTier.filter(ele => ele.RateCardTierKey == event.target.dataset.rowId)[0];
        if (deletedRateCardTier.Id != undefined) {
            this.deleteRateCardTiers.push(deletedRateCardTier);
        }
        this.rateCardTier = this.rateCardTier.filter((ele) => {
            return parseInt(ele.RateCardTierKey) !== parseInt(event.target.dataset.rowId);
        });

        if (this.rateCardTier.length === 0) {
            this.handleAddRowRateCardTier();
        }
    }

    /**
     * @description This method is used to close the Rate Card Tier Modal popup
     */
    handleCloseModal() {
        this.showModal = false;
    }

    /**
     * @description This method is used to process the Error occurred from back end
     * @param message
     */
    processErrorMessage(message) {
        let errorMsg = '';
        if (message) {
            if (message.body) {
                if (Array.isArray(message.body)) {
                    errorMsg = message.body.map(e => e.message).join(', ');
                } else if (typeof message.body.message === 'string') {
                    errorMsg = message.body.message;
                }
            }
            else {
                errorMsg = message;
            }
        }
        this.showMessage('error', errorMsg, 'Error!');
    }

    /**
      * @description This method is used to display Lightning Confirm Popup
      * @param variant
      * @param message
      * @param title
      */
    async showMessage(variant, message, title) {
        await LightningConfirm.open({
            message: message,
            theme: variant,
            label: title
        });
    }

    /**
      * @description This method is used to display Lightning Confirm Popup and refresh the page
      * @param variant
      * @param message
      * @param title
      */
    async refreshPage(variant, message, title) {
        let quoteIdvar = this.quoteId;
        const result = await LightningConfirm.open({
            message: message,
            theme: variant,
            label: title
        });
        if (result) {
            let url =
                window.location !== window.parent.location
                    ? document.referrer
                    : document.location.href;
            let value = url + "apex/sb?scontrolCaching=1&id=" + quoteIdvar;
            window.open(value, "_top");
        }
    }

    /**
      * @description This method is used to sort the data
      * @param field
      * @param reverse
      * @param primer
      */
    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                return primer(x[field]);
            }
            : function (x) {
                return x[field];
            };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }
}