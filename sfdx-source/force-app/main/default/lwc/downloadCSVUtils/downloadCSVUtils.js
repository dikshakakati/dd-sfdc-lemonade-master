export function exportCSVFile(data, columns, fileName) {

    let rowEnd = '\n';
    let csvString = '';
    // this set elminates the duplicates if have any duplicate keys
    let headerData = new Set();
    let rowData = new Set();
    // getting keys from data
    columns.forEach(column => {
        // Adding label to headerData set
        headerData.add(column.label);
        // Adding fieldName to rowData set
        rowData.add(column.fieldName);
    });

    // Array.from() method returns an Array object from any object with a length property or an iterable object.
    headerData = Array.from(headerData);
    rowData = Array.from(rowData);
    // splitting using ','
    csvString += headerData.join(',');
    csvString += rowEnd;
    // main for loop to get the data based on key value
    for (let i = 0; i < data.length; i++) {
        let colValue = 0;
        // validating keys in data
        for (let key in rowData) {
            if (rowData.hasOwnProperty(key)) {
                // Key value
                // Ex: Id, Name
                let rowKey = rowData[key];
                // add , after every value except the first.
                if (colValue > 0) {
                    csvString += ',';
                }
                // If the column is undefined, it as blank in the CSV file.
                let value = data[i][rowKey] === undefined ? '' : data[i][rowKey];
                csvString += '"' + value + '"';
                colValue++;
            }
        }
        csvString += rowEnd;
    }
    // Creating anchor element to download
    let downloadElement = document.createElement('a');
    // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
    downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
    downloadElement.target = '_self';
    // CSV File Name
    downloadElement.download = fileName + '.csv';
    // below statement is required if you are using firefox browser
    document.body.appendChild(downloadElement);
    // click() Javascript function to download CSV file
    downloadElement.click();
}