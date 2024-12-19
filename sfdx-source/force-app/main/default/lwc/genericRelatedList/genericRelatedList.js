import { track, api, LightningElement } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import viewAllText from "@salesforce/label/c.View_All_Link_In_LWC";
import exportButtonDefaultLabel from "@salesforce/label/c.Export_Button_Label";
import createLog from "@salesforce/apex/LogController.createLog";
import { exportDataByFormat } from 'c/utils';

const OBJECT_PAGE = "standard__objectPage"
const WEB_PAGE = "standard__webPage"
const RECORD_PAGE = "standard__recordPage";
const LWC_NAME = "GenericRelatedList";
const NAVIGATE_TO_PAGE = "navigateToPage";
const HANDLE_LIST_VIEW_NAVIGATION = "handleListViewNavigation";
const HANDLE_RECORD_NAVIGATION = "handleRecordNavigation";
const EXPORT_FILE_DEFAULT_TITLE = 'export';
const FILE_FORMAT_CSV = 'csv';

export default class GenericRelatedList extends NavigationMixin(LightningElement) {
    @api segment;
    @api viewAll;
    @api relatedData = [];
    @api columns = [];
    @api viewAllColumns = [];
    @api title;
    @api recordId;
    @api objectName;
    @api recordName
    @api parentComponentName;
    @api wrapTextMaxLines = 3;
    @api showExportButton = false;
    @api exportButtonLabel = exportButtonDefaultLabel;
    @api exportFileTitle = EXPORT_FILE_DEFAULT_TITLE;
    @track data = [];
    sortedBy;
    numberOfItems;
    showTable = false;
    defaultSortDirection = "asc";
    sortDirection = "asc";

    labels = {
        viewAllText
    };

    /**
     * @description To perform logic after component is inserted into the DOM.
     */
    connectedCallback() {
        let count = this.recordCount();
        if (count > 0) {
            this.showTable = true;
        }
        if (this.viewAll) {
            this.data = [...this.relatedData];
            if (count > 1) {
                this.numberOfItems = count + " items";
            } else {
                this.numberOfItems = count + " item";
            }

        } else {
            if (count > 6) {
                this.numberOfItems = "(6+)";
                this.data = this.relatedData.slice(0, 6);
            } else {
                this.numberOfItems = "(" + count + ")";
                this.data = this.relatedData.slice();
            }
        }
    }

    /**
     * @description To Navigate to the display view all records page.
     */
    navigateToPage() {
        try {
            let definition = {
                componentDef: this.parentComponentName,
                attributes: {
                    recordId: this.recordId,
                    viewAll: true,
                    segment: this.segment
                }
            };
            this[NavigationMixin.Navigate]({
                type: WEB_PAGE,
                attributes: {
                    url: "/one/one.app#" + btoa(JSON.stringify(definition))
                }
            });
        }
        catch (error) {
            createLog({
                lwcName: LWC_NAME,
                methodName: NAVIGATE_TO_PAGE,
                message: JSON.stringify(error)
            });
        }
    }

    /**
     * @description To Navigate to the object's pinned list view.
     */
    handleListViewNavigation() {
        try {
            this[NavigationMixin.Navigate]({
                type: OBJECT_PAGE,
                attributes: {
                    objectApiName: this.objectName,
                    actionName: "list"
                }
            });
        } catch (error) {
            createLog({
                lwcName: LWC_NAME,
                methodName: HANDLE_LIST_VIEW_NAVIGATION,
                message: JSON.stringify(error)
            });
        }
    }

    /**
     * @description To Navigate to the record page.
     */
    handleRecordNavigation() {
        try {
            this[NavigationMixin.Navigate]({
                type: RECORD_PAGE,
                attributes: {
                    recordId: this.recordId,
                    objectApiName: this.objectName,
                    actionName: "view"
                }
            });
        } catch (error) {
            createLog({
                lwcName: LWC_NAME,
                methodName: HANDLE_RECORD_NAVIGATION,
                message: JSON.stringify(error)
            });
        }
    }

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

    /**
     * @description To sort table by selected column.
     */
    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.data];
        cloneData.sort(this.sortBy(sortedBy, sortDirection === "asc" ? 1 : -1));
        this.data = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    /**
     * @description To get total no. of records.
     */
    recordCount() {
        return this.relatedData.length;
    }

    /**
     * @description To export datatable into .csv file.
     */
    exportData() {
        const exportEvent = new CustomEvent("exportdata", {
            bubbles: true,
        });
        //To start the spinner
        this.dispatchEvent(exportEvent);
        exportDataByFormat(this.columns, this.relatedData, this.exportFileTitle, FILE_FORMAT_CSV);
        //To stop the spinner
        this.dispatchEvent(exportEvent);
    }
}