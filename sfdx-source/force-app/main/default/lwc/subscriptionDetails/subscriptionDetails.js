import { LightningElement, api, wire, track } from 'lwc';
import fetchAllSubscriptions from "@salesforce/apex/ContractsSummaryController.fetchAllSubscriptions";
import createLog from "@salesforce/apex/LogController.createLog";

const LWC_NAME = "subscriptionDetails";
const FETCH_SUBSCRIPTION = "fetchAllSubscription";
const FEE_TYPE_COMMISSION = "Commission";
const FEE_TYPE_FEE = "Fee";

export default class SubscriptionDetails extends LightningElement {
  @api contractId;
  @track subscriptions = [];
  showComponent = true;
  noRecordFound = "No records found";
  activeRateLabel = "Active Rates";
  historicalRateLabel = "Historical Rates";
  activeRateColumns = [
    {
      label: "Product Name",
      fieldName: "Product_URL",
      type: "url",
      typeAttributes: { label: { fieldName: "Product_Name" }, target: "_blank" }
    },
    { label: "Fee Type", fieldName: "Product_Fee_Type__c" },
    { label: "Final Commission/Fee", fieldName: "Final_Computed_Fee__c" },
    { label: "Start Date", fieldName: "SBQQ__StartDate__c" }
  ];
  historicalRateColumns = [
    {
      label: "Product Name",
      fieldName: "Product_URL",
      type: "url",
      typeAttributes: { label: { fieldName: "Product_Name" }, target: "_blank" }
    },
    { label: "Fee Type", fieldName: "Product_Fee_Type__c" },
    { label: "Final Commission/Fee", fieldName: "Final_Computed_Fee__c" },
    { label: "Start Date", fieldName: "SBQQ__StartDate__c" },
    { label: "End Date", fieldName: "SBQQ__TerminatedDate__c" }
  ];
  showHistoricalSection = false;

  /**
   * @description returns helptext for Rate Change History Dashboard.
   */
  get rateChangeHistoryDashboard() {
    return (
      'To see the Amendment History for this Contract <a href ="' +
      window.location.origin +
      "/" +
      this.contractId +
      '" target="_blank"> click here </a> and open the “Amendment History” tab.'
    );
  }

  /**
   * @description check if the subscriptions records found.
   */
  get areSubscriptionRecordsFound() {
    return this.subscriptions.length > 0 ? true : false;
  }

  /**
   * @description connectedcallback, used to fetch all the subscriptions records and further map them according
   * to active or historical rates.
   */
  connectedCallback() {
    this.mapSubscriptionList();
  }

  /**
   * @description It fetches all the contracts.
   */
  mapSubscriptionList() {
    this.showComponent = false;
    fetchAllSubscriptions({ contractId: this.contractId })
      .then((result) => {
        if (result) {
          this.subscriptions = result;
          this.subscriptions.forEach((item, index) => {
            item.showPackage = index == 0 ? true : false;
            item.showActiveSubscription = true;
            item.showHistoricalSubscription = false;
            item.areActiveRateRecordsFound =
              item.activeSubscriptions.length > 0 ? true : false;
          });
          if (this.subscriptions) {
            this.subscriptions.forEach((item) => {
              item.activeSubscriptions.forEach((rates) => {
                // computing final fee, commission or their combination.

                let finalFee =
                  rates.Final_Fee__c !== undefined &&
                    rates.Final_Fee__c !== null
                    ? rates.CurrencyIsoCode +
                    " " +
                    parseFloat(rates.Final_Fee__c).toFixed(2)
                    : " ";
                let finalCommission =
                  rates.Final_Commission__c !== undefined &&
                    rates.Final_Commission__c !== null
                    ? parseFloat(rates.Final_Commission__c).toFixed(2) + "% "
                    : " ";
                let computedFee = "";

                if (finalFee === " " && finalCommission !== " ") {
                  computedFee = finalCommission;
                } else if (finalCommission === " " && finalFee !== " ") {
                  computedFee = finalFee;
                } else if (finalFee !== " " && finalCommission !== " ") {
                  computedFee = finalCommission + " + " + finalFee;
                }

                rates.Product_Name = rates.SBQQ__Product__r.Name;
                rates.Product_Fee_Type__c = rates.SBQQ__Product__r.Fee_Type__c;
                rates.Product_URL = "/" + rates.Id;
                rates.Final_Computed_Fee__c = rates.SBQQ__Product__r.Fee_Type__c
                  ? rates.SBQQ__Product__r.Fee_Type__c == FEE_TYPE_COMMISSION
                    ? finalCommission
                    : rates.SBQQ__Product__r.Fee_Type__c == FEE_TYPE_FEE
                      ? finalFee
                      : computedFee
                  : " ";
              });
            });
          }
          this.showComponent = true;
        }
      })
      .catch((error) => {
        this.error = error;
        createLog({
          lwcName: LWC_NAME,
          methodName: FETCH_SUBSCRIPTION,
          message: JSON.stringify(error)
        });
      });
  }

  /**
   * @description accordion handler for package.
   */
  handlePackageAccordion(event) {
    let index = parseInt(event.target.dataset.rowIndex, 10);
    this.subscriptions = this.subscriptions.map((row, i) =>
      i == index
        ? { ...row, showPackage: !this.subscriptions[index].showPackage }
        : row
    );
  }

  /**
   * @description accordion handler for active rates.
   */
  handleActiveRateAccordion(event) {
    let index = parseInt(event.target.dataset.rowIndex, 10);
    this.subscriptions = this.subscriptions.map((row, i) =>
      i == index
        ? {
          ...row,
          showActiveSubscription:
            !this.subscriptions[index].showActiveSubscription
        }
        : row
    );
  }

  /**
   * @description accordion handler for historical section.
   */
  handleHistoricalAccordion(event) {
    this.showHistoricalSection = !this.showHistoricalSection;
  }
}
