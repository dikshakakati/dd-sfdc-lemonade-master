/**
 * @author Sanidhya Jain
 * @date Sept 2024
 * @decription Custom Datatable component which extends ootb datatable with custom cell renderers.
 *             https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.data_table_custom_types
 *             Note: the template.html file should exist in the same folder as this component.
 */
/*****************************************************************************************************************************
*
* Imports
*
*****************************************************************************************************************************/
import LightningDatatable from 'lightning/datatable';
import ddDatatableRecordUrlTemplate from './ddDatatableRecordUrlTemplate.html';
import ddDatatablePicklistRead from './ddDatatablePicklistRead.html';
import ddDatatablePicklistEdit from './ddDatatablePicklistEdit.html';

export default class DdDatatable extends LightningDatatable {
    static customTypes = {
        // Displays a custom <a> tag in the UI via the ddDatatableRecordUrl component.
        recordUrl : {
            template: ddDatatableRecordUrlTemplate,
            typeAttributes:['navigateToId','displayValue','openMode','quickViewFieldSetName']
        },
        picklist : {
            template: ddDatatablePicklistRead,
            editTemplate: ddDatatablePicklistEdit,
            standardCellLayout: true,
            typeAttributes:['options', 'value']
        }
    };
}