/**
 * @author Deloitte
 * @date 01/22/2025
 * @description It is a generic utility to export data in different formats
 * [currently supported format(s): csv].
 */
const ANCHOR_ELEMENT = 'a';
const COLUMN_DELIMITER = ',';
const DOWNLOAD = 'download';
const HIDDEN = 'hidden';
const HREF = 'href';
const HREF_FOR_MAC = 'data:text/csv;charset=utf-8,';
const LINE_DELIMITER = '\r\n';
const NAVIGATION_FOR_MAC = '/iPhone|iPad|iPod|Mac/i';
const OBJECT = 'object';
const REPLACE_COMMA_EXPRESSION = '/,/g';
const TARGET_BLANK = '_blank';

/**
 * @description To export the passed data in csv format.
 * @param headersToExport
 * @param dataToExport
 * @param fileTitle
 */
const exportDataToCSV = (headersToExport, dataToExport, fileTitle) => {
    if (!dataToExport) {
        return null;
    }
    let headers = formatHeaders(headersToExport);
    let convertedData = convertToCSV(JSON.stringify(dataToExport), headers);
    if (!convertedData) {
        return null;
    }
    downloadFile(convertedData, fileTitle);

};

/**
 * @description To convert the passed headers and data to csv format.
 * @param dataToConvert
 * @param headers
 */
function convertToCSV(dataToConvert, headers) {
    let headerKeys = Object.keys(headers);
    let headerValues = Object.values(headers);
    let csvRows = "";
    csvRows += headerValues.join(COLUMN_DELIMITER);
    csvRows += LINE_DELIMITER;
    let dataToIterate = typeof dataToConvert !== OBJECT ? JSON.parse(dataToConvert) : dataToConvert;
    dataToIterate.forEach((eachDataItem) => {
        let csvRow = "";
        headerKeys.forEach((key) => {
            if (csvRow != "") {
                csvRow += COLUMN_DELIMITER;
            }
            let csvRowItem = eachDataItem[key] ? eachDataItem[key] + "" : "";
            csvRow += csvRowItem ? csvRowItem.replace(REPLACE_COMMA_EXPRESSION, "") : csvRowItem;
        });
        csvRows += csvRow + LINE_DELIMITER;
    });
    return csvRows.trim();
}

/**
 * @description To format the headers.
 * @param headersToExport
 * @return headers
 */
function formatHeaders(headersToExport) {
    let headers = {};
    headersToExport.forEach(eachColumnItem => {
        if (eachColumnItem.typeAttributes) {
            headers[eachColumnItem.typeAttributes.label.fieldName] = eachColumnItem.label;
        }
        else {
            headers[eachColumnItem.fieldName] = eachColumnItem.label;
        }
    });
    return headers;
}

/**
 * @description To download the file using the passed data and title.
 * @param fileData
 * @param fileTitle
 */
function downloadFile(fileData, fileTitle) {
    let fileDataBlob = new Blob([fileData]);
    let downloadFileLink = window.document.createElement(ANCHOR_ELEMENT);
    if (!navigator) {
        return null;
    }
    if (navigator.msSaveBlob) {
        navigator.msSaveBlob(fileDataBlob, fileTitle);
    } else if (navigator.userAgent.match(NAVIGATION_FOR_MAC)) {
        downloadFileLink.download = fileTitle;
        downloadFileLink.href = HREF_FOR_MAC + encodeURI(convertedData);
        downloadFileLink.target = TARGET_BLANK;
        downloadFileLink.click();
    } else if (!downloadFileLink.download) {
        let url = URL.createObjectURL(fileDataBlob);
        downloadFileLink.setAttribute(DOWNLOAD, fileTitle);
        downloadFileLink.setAttribute(HREF, url);
        downloadFileLink.style.visibility = HIDDEN;
        document.body.appendChild(downloadFileLink);
        downloadFileLink.click();
        document.body.removeChild(downloadFileLink);
    }
}

export { exportDataToCSV };