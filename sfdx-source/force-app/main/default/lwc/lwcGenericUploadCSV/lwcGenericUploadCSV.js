import { LightningElement, track, api } from 'lwc';
import fileTooLarge from '@salesforce/label/c.File_size_too_Large';
export default class LwcDdGenericUploadCSV extends LightningElement {
    @track data;
    @track showLoadingSpinner = false;
    MAX_FILE_SIZE = 2000000; //Max file size 2.0 MB
    filesUploaded = [];
    filename;
    hasFile = false;
    fileError = false;
    errorMessage;
    labels = {
        fileTooLarge
    };
    @track filecontents;
    importcsv(event) {
        if (event.target.files.length > 0) {
            this.filesUploaded = event.target.files;
            this.filename = event.target.files[0].name;
            this.hasFile = true;
            this.readFiles();
            if (this.filesUploaded.size > this.MAX_FILE_SIZE) {
                this.filename = this.labels.fileTooLarge;
            }
        }
    }

    readFiles() {
        [...this.template
            .querySelector('lightning-input')
            .files
        ].forEach(async file => {
            try {
            const resultFile = await this.load(file);
            this.showLoadingSpinner = false;
            let jsonResult = this.convertToJson(resultFile);
            //replace double quotes in the JSON
            jsonResult = jsonResult.replace(/\\"/g, "");
            this.data = JSON.parse(jsonResult);
            this.fireFileAddedEvent();
            } catch (error) {
                // handle file load exception
                this.fileError = true;
                this.errorMessage = error;
                fireFileReadError(error);
            }
        });
    }

    async load(file) {
        return new Promise((resolve, reject) => {
            this.showLoadingSpinner = true;
            const reader = new FileReader();
            // Read file into memory as UTF-8
            reader.onload = function () {
                resolve(reader.result);
            };
            reader.onerror = function () {
                reject(reader.error);
            };
            reader.readAsText(file);
        });
    }

     //process CSV input to JSON
     convertToJson(csv) {
        let lines = csv.split(/\r\n|\n/);
        let result = [];
        let headers = lines[0].split(",");
        let csvcontents = headers + '\n';
        for (let i = 1; i <= lines.length - 1; i++) {
            let obj = {};
            let currentline = lines[i].split(",");
            csvcontents = csvcontents + currentline + '\n';
            for (let j = 0; j < headers.length; j++) {
                obj[headers[j]] = currentline[j];
            }
            result.push(obj);
        }
        this.filecontents = csvcontents;
        return JSON.stringify(result);
    }
    //Remove the file when user clicks icon
    removeFile(){
        this.filesUploaded = null;
        this.hasFile = false;
        this.fireFileRemoved();
    }
    //Fire event to parent when a file was loaded
    fireFileAddedEvent() {
        this.dispatchEvent(new CustomEvent('fileadded', { detail: {
            data : this.data,
            filename : this.filename,
            filecontents : this.filecontents
            }
        }));
    }
    //Fire event to parent if there was a parsing error
    fireFileReadError(error) {
        this.dispatchEvent(new CustomEvent('filereaderror', { detail: error }));
    }
    //Fire event to parent if a file was removed
    fireFileRemoved() {
        this.dispatchEvent(new CustomEvent('fileremoved', {}));
    }
}