/**
 * @author Sanidhya Jain
 * @date  Sept 2024
 * @decription Root component of the Grid Report Tool
 */

/*****************************************************************************************************************************
 *
 * Imports
 *
 *****************************************************************************************************************************/
import { LightningElement,api,wire,track } from 'lwc';
import { reduceErrors,stringIsBlank,stringIsNotBlank,chunkArray,isUndefinedOrNull,cloneObject } from 'c/lwcDdUtils';
import { BLANK_STRING} from 'c/lwcDdConst';
import getReportDefinition from '@salesforce/apex/GridReportCtrl.getReportDefinition';
import getRecordIds from '@salesforce/apex/GridReportCtrl.getRecordIds';
import getData from '@salesforce/apex/GridReportCtrl.getData';
import { loadStyle } from 'lightning/platformResourceLoader';
import ASSETS from '@salesforce/resourceUrl/DdLightningResource';
import { downloadCsvFile } from 'c/lwcDdCsvDownload';

/*****************************************************************************************************************************
 *
 * CSS Class Consts
 *
 *****************************************************************************************************************************/

const RIGHTPANEL_REGULAR_CLASS = 'rightPanel rightPanel-regular';
const RIGHTPANEL_EXPANDED_CLASS = 'rightPanel rightPanel-expanded';
const RIGHTPANEL_REGULAR_QUICK_VIEW_CLASS = 'rightPanel rightPanel-regular-quick-view';
const RIGHTPANEL_EXPANDED_QUICK_VIEW_CLASS = 'rightPanel rightPanel-expanded-quick-view';
const TABLE_WITH_QUICK_VIEW_CLASS = 'slds-var-p-left_large slds-var-p-top_large slds-var-p-bottom_large rightPanel-DataTable';
const TABLE_WITHOUT_QUICK_VIEW_CLASS = 'slds-var-p-around_large rightPanel-DataTable';
/*****************************************************************************************************************************
 *
 * Functional Consts
 *
 *****************************************************************************************************************************/

const TOGGLE = 'Toggle';
const BACKDROP_TEXT_NO_SEARCH = 'Please add one or more filters and click \'Search\'';
const BACKDROP_TEXT_NO_RECORDS = 'No records found matching the search filter criteria';
const COMPONENT_ROWACTIONHANDLER = '[data-id="rowActionHandler"]';
const ELE_MODAL = '[data-id="modal"]';
const MEDIUM = 'medium';
const SMALL = 'small';
const LARGE = 'large';
const INFO = 'info';
const CONFIRM = 'confirm';
const DIALOG = 'dialog';
const ASCENDING = 'asc';

/*****************************************************************************************************************************
 *
 * @api Picklist Value consts
 *
 *****************************************************************************************************************************/

export default class LwcDdGridReport extends LightningElement {
    /*****************************************************************************************************************************
     *
     * Public Variables
     *
     *****************************************************************************************************************************/
    // {Object[]} - (Required) - Passes array of report options to display.
    _reportOptions;
    get reportOptions() {
        return this._reportOptions;
    }
    @api
    set reportOptions(value) {
        this._reportOptions = value;
        for (const reportOption of value) {
            if (reportOption.active) {
                this.activateReport(reportOption.developerName);
                break;
            }
        }
    }

    /*****************************************************************************************************************************
     *
     * Private Variables
     *
     *****************************************************************************************************************************/

    isPageLoading = false;
    isGridLoading = false;
    isQuickViewPanelVisible = false;
    invalidReportDefinition = false;
    reportDefinition;
    isLeftPanelExpanded = true;
    recordIds = [];
    allRecordIds = [];
    totalRecords = 0;
    availableRecords = 0; // LIMIT considered
    currentPage = 0;
    exportCurrentPage = 0;
    currentNumberOfRecords = 0;
    @track data = [];
    @track exportData = [];
    columns = [];
    sortConfig = {
        sortedBy: BLANK_STRING,
        sortDirection: BLANK_STRING,
        sortNulls: BLANK_STRING
    }
    hasSearchExecuted = false;
    showNoRecords = false;
    @track filters;
    enableInfiniteLoading = false;
    quickViewRecordId = BLANK_STRING;
    quickViewFieldSetName = BLANK_STRING;
    quickViewHeaderValue = BLANK_STRING;
    modalTitle = BLANK_STRING;
    modalSize = MEDIUM;
    modalType = INFO;
    modalContent = BLANK_STRING;

    /*****************************************************************************************************************************
     *
     * LifeCycle Hooks
     *
     *****************************************************************************************************************************/

    cssAdded = false;
    renderedCallback() {
        if (!this.cssAdded) {
            this.cssAdded = true;
            Promise.all([
                loadStyle(this, ASSETS +'/css/DD_CSS.css'),
                loadStyle(this, ASSETS +'/css/DD_CSS_RemoveDefaultPadding.css')
            ]).then(() => {})
            .catch(error => {
                console.log('Cannot unable to load DD_CSS.css',error);
            });
        }
    }

    /*****************************************************************************************************************************
     *
     * UI Getters
     *
     *****************************************************************************************************************************/

    get rightPanelClass() {
        let className = BLANK_STRING;
        if(this.isLeftPanelExpanded) {
            className = this.isQuickViewPanelVisible ? RIGHTPANEL_REGULAR_QUICK_VIEW_CLASS : RIGHTPANEL_REGULAR_CLASS;
        }
        else {
            className = this.isQuickViewPanelVisible ? RIGHTPANEL_EXPANDED_QUICK_VIEW_CLASS : RIGHTPANEL_EXPANDED_CLASS;
        }
        return className;
    }

    get backdropText() {
        let text = BLANK_STRING;
        if (!this.hasSearchExecuted)
            text = BACKDROP_TEXT_NO_SEARCH;
        else if (this.showNoRecords)
            text = BACKDROP_TEXT_NO_RECORDS;
        return text;
    }

    get recordCountText() {
        return (this.hasSearchExecuted && !this.showNoRecords ? `Showing ${this.currentNumberOfRecords} items of ${this.availableRecords}` : null);
    }

    get datatableDivClass() {
        return this.isQuickViewPanelVisible ? TABLE_WITH_QUICK_VIEW_CLASS : TABLE_WITHOUT_QUICK_VIEW_CLASS;
    }

    get disableExportButton() {
        return !this.hasSearchExecuted || this.isGridLoading || this.showNoRecords;
    }

    /*****************************************************************************************************************************
     *
     * Wires
     *
     *****************************************************************************************************************************/

    /*****************************************************************************************************************************
     *
     * Event Handlers
     *
     *****************************************************************************************************************************/

    // When Report Menu is selected
    handleReportSelection(event) {
        const reportName = event.detail.value;
        if (reportName &&
            (!this.reportDefinition || (this.reportDefinition && this.reportDefinition.DeveloperName !== reportName )))
            this.activateReport(reportName);
    }

    // When a gridFilter is added
    handleGridFilterChange(event) {
        let item = event.detail.item;
        for (let i = 0; i < this.filters.length; i++) {
            if (this.filters[i].name === item.name) {
                this.filters[i] = item;
                break;
            }
        }
        this.resetData();
    }

    // Toggle show/hide of the left panel
    toggleLeftPanel(event) {
        this.isLeftPanelExpanded = !this.isLeftPanelExpanded;
    }

    // On Search button click
    handleSearchButtonClick(event) {
        this.hideQuickViewPanel();
        this.fetchRecordIds();
    }

    // On Clear button click
    handleClearFilterButtonClick(event) {
        if (this.reportDefinition.DD_Grid_Report_Filters__r)
            this.setFilters(this.reportDefinition.DD_Grid_Report_Filters__r);

        this.resetData();
    }

    // Datatable loads data in infinite loading (lazy loading) mode by calling this funtion
    loadMoreData(event) {
        this.enableInfiniteLoading = false;
        if (this.currentPage !== this.recordIds.length) {
            this.tableElement = event.target;
            this.fetchData();
        }
    }

    // If a row action is there on the grid, send it to the child row action handler component, which can house project
    // specific code
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        try {
            let rowActionHandlerComponent = this.template.querySelector(COMPONENT_ROWACTIONHANDLER);
            if (rowActionHandlerComponent)
                rowActionHandlerComponent.handleRowAction(actionName,row);
        } catch (e) {
            console.dir(e);
        }
    }

    // When the custom recordUrl column type cell is clicked, this is the event which gives what record to navigate to.
    handleDatatableRecordUrlClick(event) {
        this.processNavigateToSobject(event.detail.navigateToId,event.detail.openMode,event.detail.quickViewFieldSetName,event.detail.displayValue);
    }

    // Datatable sort has been clicked.
    handleOnSort(event) {
        this.sortConfig.sortedBy = event.detail.fieldName;
        this.sortConfig.sortDirection = event.detail.sortDirection;
        this.fetchRecordIds();
    }

    resetModal() {
        this.modalTitle = BLANK_STRING;
        this.modalSize = MEDIUM;
        this.modalType = INFO;
        this.modalContent = BLANK_STRING;
    }

    /*****************************************************************************************************************************
    *
    * Logic / Helper methods
    *
    *****************************************************************************************************************************/

    /**
     * @decription Activates report and fetches the report definition from the backend.
     * @param   {String} reportName - Custom Metadata Dev name of the DD Grid Report Master record.
     * @return  None
     */
    activateReport = (reportName) => {
        this.isPageLoading = true;
        getReportDefinition({ reportName: reportName })
            .then((result) => {
                this.isPageLoading = false;
                if (result) {
                    this.reportDefinition = result;
                    if (result.DD_Grid_Report_Filters__r)
                        this.setFilters(result.DD_Grid_Report_Filters__r);
                    if (result.DD_Grid_Report_Fields__r)
                        this.setColumns(result.DD_Grid_Report_Fields__r);
                    this.resetData();
                    this.error = null;
                    this.notifyParentOnReportActivation(this.reportDefinition.Label);
                }
            })
            .catch((error) => {
                this.isPageLoading = false;
                console.log(reduceErrors(error));
                this.records = [];
            });
    }

    /**
     * @decription Adds a custom Array of Filter object, one which has the definitions and the value in the same object.
     * @param   {DD_Grid_Report_Filter__c[]} filterDefinitions
     * @return  None
     */
    setFilters = (filterDefinitions) => {
        let filters = [];
        for (const filterDefn of filterDefinitions) {
            filters.push({
                'name':filterDefn.DeveloperName,
                'definition': filterDefn,
                'value': filterDefn.Type__c === TOGGLE ? (filterDefn.Toggle_Filter_Required__c ? filterDefn.Toggle_Default__c : null) : []
            });
        }
        this.filters = filters;
    }

    /**
     * @decription Forms the columns for the data table
     * @param   {DD_Grid_Report_Field__c[]} columnsDefinitions
     * @return  None
     */
    setColumns = (columnsDefinitions) => {
        let columns = [];
        let sortConfig = {
            sortedBy: BLANK_STRING,
            sortDirection: BLANK_STRING,
            sortNulls : BLANK_STRING
        };
        for (const columnDef of columnsDefinitions) {
            let column = columnDef.Type__c === 'action' ?
                {type:'action'} :
                {
                    label : columnDef.Label__c,
                    fieldName: columnDef.Field_Name__c,
                    apiName: columnDef.API_Name__c,
                    type: columnDef.Type__c,
                    sortable: columnDef.Sortable__c
                };
            if (columnDef.Type_Attributes_JSON__c) {
                column.typeAttributes = JSON.parse(columnDef.Type_Attributes_JSON__c);
            }
            if (columnDef.Cell_Attributes_JSON__c) {
                column.cellAttributes = JSON.parse(columnDef.Cell_Attributes_JSON__c);
            }
            if (columnDef.Initial_Width__c) {
                column.initialWidth = columnDef.Initial_Width__c;
            }
            if (columnDef.Default_Sort__c && sortConfig.sortedBy === BLANK_STRING) {
                sortConfig.sortedBy = column.fieldName;
                sortConfig.sortDirection = columnDef.Default_Sort_Direction__c || ASCENDING;
            }
            if (columnDef.Sort_Nulls_Config__c) {
                sortConfig.sortNulls = columnDef.Sort_Nulls_Config__c;
            }
            columns.push(column);
        }
        this.columns = columns;
        this.sortConfig = sortConfig;
    }

    /**
     * @decription Get the record Ids on search
     * @param   None
     * @return  None
     */
    fetchRecordIds = () => {
        this.resetData();
        this.isGridLoading = true;
        this.hasSearchExecuted = true;

        getRecordIds({
            apexClass:this.reportDefinition.Apex_Class__c,
            filterConfig: JSON.stringify(this.filters),
            sortConfig: JSON.stringify(this.sortConfig)
        }).then((result) => {
            this.isGridLoading = false;
            if (result && this.hasSearchExecuted) {
                this.availableRecords = result.recordIds ? result.recordIds.length || 0 : 0;
                this.totalRecords = result.count || 0;
                this.showNoRecords = (this.totalRecords === 0);
                // The Tool uses the PK Chunking technique. setting a default page size of 50 records to display
                // converts ['1','2',...,'50','51'] to [['1','2',...,'50'],['51']]
                this.allRecordIds = result.recordIds ? chunkArray(result.recordIds, 10000) : [];;
                this.recordIds = result.recordIds ? chunkArray(result.recordIds,50) : [];
                this.currentPage = 0;
                // get the first page of data (i.e. first item of the chunked array)
                this.fetchData();
                if (this.availableRecords !== this.totalRecords) {
                    this.modalTitle = 'Search results...';
                    this.modalContent = `The search resulted in ${this.totalRecords} records, but only ${this.availableRecords} can be retrieved and displayed. Please consider updating the filters to reduce the number of records.`;
                    this.showModal();
                }
            }
        })
        .catch((error) => {
            this.isGridLoading = false;
            console.log(reduceErrors(error));
            this.records = [];
        });
    }

    /**
     * @decription Gets the actual data.
     * @param   None
     * @return  None
     */
    fetchData = () => {
        this.currentPage++;
        if (this.currentPage > this.recordIds.length) { // All records have been returned.
            this.currentPage--;
            return;
        }
        if (isUndefinedOrNull(this.tableElement))
            this.isGridLoading = true;
        else
            this.tableElement.isLoading = true;

        getData({
            apexClass:this.reportDefinition.Apex_Class__c,
            recordIds: this.recordIds[this.currentPage - 1]
        }).then((result) => {
            this.isGridLoading = false;
            if (result) {
                const nextPageData = JSON.parse(result);
                this.currentNumberOfRecords += nextPageData.length;
                if (this.currentPage !== this.recordIds.length) {
                    this.enableInfiniteLoading = true;
                }
                this.data = this.data.concat(nextPageData);
                if (!isUndefinedOrNull(this.tableElement))
                    this.tableElement.isLoading = false;
            }
        })
        .catch((error) => {
            this.isGridLoading = false;
            this.currentPage--;
            console.log(reduceErrors(error));
        });
    }

    /**
     * @decription Resetting core private variables.
     * @param   None
     * @return  None
     */
    resetData = () => {
        this.currentNumberOfRecords = 0;
        this.availableRecords = 0;
        this.totalRecords = 0;
        this.recordIds = [];
        this.data = [];
        this.currentPage = 0;
        this.hasSearchExecuted = false;
        this.showNoRecords = false;
        this.hideQuickViewPanel();
    }

    /**
     * @decription LWC does not support console mode, if console mode, the parent wrapper aura can update the label via workspace api
     *              once workspace api is implemented in LWC by Salesforce, then the LWC should be able to send tab label updates directly.
     * @param   {String} reportName - Label of the report
     * @return  None
    */
    notifyParentOnReportActivation = (reportName) => {
        const evt = new CustomEvent("reportactivated",{
            detail: {reportName:reportName}
        });
        this.dispatchEvent(evt);
    }

    /**
     * @decription LWC does not support console mode, if console mode, the parent wrapper aura navigate to the record clicked in a new tab/subTab or new browser window.
     *             Once workspace api is implemented in LWC by Salesforce, then the LWC should be able to send navigate directly.
     * @param   {String} recordId - Id of the record to navigate to
     * @param   {String} openMode - option: tab/subTab/newBrowserTab
     * @return  None
    */
    processNavigateToSobject(recordId,openMode,quickViewFieldSetName,displayValue) {
        const message = {
            recordId: recordId,
            openMode: (openMode ?? 'tab'),
            quickViewFieldSetName: quickViewFieldSetName,
            quickViewHeaderValue: displayValue
        };
        const evt = new CustomEvent("navigatetorecord",{
            detail: message,bubbles:true,composed:true
        });
        this.dispatchEvent(evt);
    }

   /**
    * @decription Hide Quick View Panel when close button is clicked.
    * @param   None
    * @return  None
    */
    hideQuickViewPanel(){
        this.isQuickViewPanelVisible = false;
    }


    /**
    * @decription Shows Modal
    * @param   None
    * @return  None
    */
    showModal() {
        let control = this.template.querySelector(ELE_MODAL);
        if (control) {
            control.show();
        }
    }


    /**
    * @decription Hides Modal
    * @param   None
    * @return  None
    */
    hideModal() {
        let control = this.template.querySelector(ELE_MODAL);
        if (control) {
            control.hide();
        }
    }

    reloadSearchResults(event) {
        event.stopPropagation();
        const config = event.detail.config;
        this.columns = [...config.fieldConfiguration];
        this.sortConfig = config.sortConfiguration;
        this.filters = [...config.filterConfiguration];
        this.handleSearchButtonClick();
    }

    /**
     * @decription Retrieve complete data for export
     * @param   None
     * @return  None
     */
    fetchAllData() {
        if (this.exportCurrentPage < this.allRecordIds.length) {
            this.isGridLoading = true;

            getData({
                apexClass:this.reportDefinition.Apex_Class__c,
                recordIds: this.allRecordIds[this.exportCurrentPage]
            }).then((result) => {
                this.isGridLoading = false;
                if (result) {
                    const nextPageData = JSON.parse(result);
                    this.exportData = this.exportData.concat(nextPageData);
                    this.exportCurrentPage++;
                    if (this.exportCurrentPage < this.allRecordIds.length) {
                        this.fetchAllData();
                    }
                    else{
                        downloadCsvFile(this.columns, this.exportData, this.reportDefinition.Label);
                        this.exportCurrentPage = 0;
                        this.exportData = [];
                    }
                }
            })
            .catch((error) => {
                this.isGridLoading = false;
                console.log(reduceErrors(error));
            });
        }
    }

    /**
     * @decription Initiate download of export file
     * @param   None
     * @return  None
     */
    initializeDownload() {
        this.fetchAllData();
    }
}