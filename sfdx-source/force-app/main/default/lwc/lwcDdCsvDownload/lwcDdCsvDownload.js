/**
 * @author Sanidhya Jain
 * @date   Sept 2024
 * @decription Component to download CSV File
 */

/*****************************************************************************************************************************
 *
 * Imports
 *
 *****************************************************************************************************************************/
import { BLANK_STRING, DELIMITER_COMMA, NEW_LINE, DELIMITER_DOUBLE_QUOTE } from 'c/lwcDdConst';
import TIME_ZONE from '@salesforce/i18n/timeZone';
import LOCALE from '@salesforce/i18n/locale';

/*****************************************************************************************************************************
 *
 * Functional Consts
 *
 *****************************************************************************************************************************/
const EXPORT_FILE_TYPE = 'data:text/csv;charset=utf-8';
const DEFAULT_DATE_FORMAT = {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    timeZone: TIME_ZONE
};

/**
 * @decription Prepare Export CSV field and download it
 * @param   {Object[]} columns - Columns to be added in CSV File - Object has 3 required properties: apiName, label and type
 * @param   {Object[]} exportData - records to be added in CSV File
 * @param   {String} fileName - Name of CSV file
 * @return  None
 */
export function downloadCsvFile(columns, exportData, fileName) {
    let rowEnd = NEW_LINE;
    let csvString = BLANK_STRING;
    //Set of field Api Names for column Headers
    let columnHeaders = new Set();
    let apiNameLabelMap = new Map();
    let dateTypeAttributeMap = new Map();
    let columnLabelHeaders = new Set();

    columns.forEach(function (record) {
        apiNameLabelMap.set(record.apiName, record.label);
        if(record.type === 'date'){
            dateTypeAttributeMap.set(record.apiName, record.typeAttributes);
        }
    });

    columnLabelHeaders = Array.from(apiNameLabelMap.values());
    columnHeaders = Array.from(apiNameLabelMap.keys());
    csvString += columnLabelHeaders.join(DELIMITER_COMMA);
    csvString += rowEnd;

    for(let i=0; i < exportData.length; i++){
        let colValue = 0;

        for(let key in columnHeaders) {
            let rowKey = columnHeaders[key];
            if(colValue > 0){
                csvString += DELIMITER_COMMA;
            }

            let value;
            if(exportData[i][rowKey] === undefined || exportData[i][rowKey] === null ) {
                value = BLANK_STRING;
            }
            else {
                if(dateTypeAttributeMap.has(rowKey)){
                    let typeAttribute = dateTypeAttributeMap.get(rowKey) === undefined ? DEFAULT_DATE_FORMAT : dateTypeAttributeMap.get(rowKey);
                    value = new Intl.DateTimeFormat(LOCALE, typeAttribute).format(new Date(exportData[i][rowKey]));
                }
                else {
                    value = exportData[i][rowKey];
                }
            }
            if(typeof value === 'string' && value.indexOf(DELIMITER_DOUBLE_QUOTE) != -1){
                value = value.replaceAll(DELIMITER_DOUBLE_QUOTE, DELIMITER_DOUBLE_QUOTE+DELIMITER_DOUBLE_QUOTE);
            }
            csvString += DELIMITER_DOUBLE_QUOTE+ value +DELIMITER_DOUBLE_QUOTE;
            colValue++;
        }
        csvString += rowEnd;
    }

    let downloadElement = document.createElement('a');
    downloadElement.href =  EXPORT_FILE_TYPE + DELIMITER_COMMA + encodeURIComponent(csvString);
    downloadElement.target = '_self';
    downloadElement.download = fileName + '.csv';
    document.body.appendChild(downloadElement);
    downloadElement.click();
}