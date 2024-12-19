/**
 * @author Sanidhya Jain
 * @date Sept 2024
 * @decription Custom cell renderer for custom 'recordUrl' type, which sends a custom event to the datatable's parent component
 *             with details of the item being clicked on
 */
/*****************************************************************************************************************************
*
* Imports
*
*****************************************************************************************************************************/
import { LightningElement,api } from 'lwc';

export default class DdDatatableRecordUrl extends LightningElement {
    /*****************************************************************************************************************************
    *
    * Public Variables
    *
    *****************************************************************************************************************************/
    // {String} (Required) - Id of the record to navigate to
    @api navigateToId;
    // {String} - What text to display on the anchor tag
    @api displayValue = "Click Here";
    // {String} - in what mode the hyperlink will work - Options: tab/subTab/newBrowserTab
    @api openMode = "tab";
    // {String} - Get field names to display in lwcDdGridReportQuickViewPanel
    @api quickViewFieldSetName;

    /*****************************************************************************************************************************
    *
    * Event Handlers
    *
    *****************************************************************************************************************************/
    // When hyperlink is clicked, notify custom datatable's parent component.
    handleOnClick(event) {
        event.preventDefault();
        event.stopPropagation();
        const evt = new CustomEvent('datatableurlclick', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                openMode: this.openMode,
                navigateToId: this.navigateToId,
                quickViewFieldSetName: this.quickViewFieldSetName,
                displayValue: this.displayValue
            },
        });
        this.dispatchEvent(evt);
    }
}