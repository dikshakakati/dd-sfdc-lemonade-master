import { LightningElement,api} from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import dateformatcss from '@salesforce/resourceUrl/RemoveDateFormatcss';

export default class SendSSMOActiveMx extends LightningElement {
    @api mxlinkid;
    loading = true;

    renderedCallback(){
        Promise.all([
            loadStyle(this, dateformatcss)
          ]).then(() => {
            window.console.log('Files loaded.');
          }).catch(error => {
            window.console.log("Error " + error.body.message);
          });
    }

    loadScreen(){
        this.loading = false;
    }

    handleMxClick(event){
        event.preventDefault();
        let recordurl = window.location.origin + '/' + this.mxlinkid;
        window.location.href = recordurl;
    }
}