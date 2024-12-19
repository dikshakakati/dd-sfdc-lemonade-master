/**
 * @author Sanidhya Jain
 * @date   Sept 2024
 * @decription Component which helps display grid filter filters and sort config when the left filter panel is minimized.
 */

/*****************************************************************************************************************************
 *
 * Imports
 *
 *****************************************************************************************************************************/
import { api, LightningElement } from 'lwc';

/*****************************************************************************************************************************
 *
 * Functional Consts
 *
 *****************************************************************************************************************************/
const ELE_MODAL = '[data-id="modal"]';

export default class LwcDdGridReportShowCurrentFilters extends LightningElement {
    /*****************************************************************************************************************************
     *
     * Public Variables
     *
     *****************************************************************************************************************************/
    // {Object[]} - Filter config with filter metadata and values
    @api filterConfiguration;
    // {Object} - sort config with sorted by and direction
    @api sortConfiguration;
    // {Object[]} - Fields/Column config
    @api fieldConfiguration;

    /*****************************************************************************************************************************
     *
     * Private Variables
     *
     *****************************************************************************************************************************/
    showModal = false;

    /*****************************************************************************************************************************
     *
     * Event Handlers
     *
     *****************************************************************************************************************************/
    handleShowModal(event) {
        event.stopPropagation();
        this.showModal = true;
        let control = this.template.querySelector(ELE_MODAL);
        if (control)
            control.show();
        else
            alert('Modal not found in DOM');
    }

    handleHideModal(event) {
        event.stopPropagation();
        this.showModal = false;
        let control = this.template.querySelector(ELE_MODAL);
        if (control)
            control.hide();
    }
}