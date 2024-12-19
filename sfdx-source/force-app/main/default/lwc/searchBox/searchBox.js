/**
 * @author Deloitte
 * @date 02/05/2022
 * @description JavaScript controller for reusable search component for placing a field search option.
 */
import { LightningElement, api, track } from 'lwc';
import searchKeyLength from '@salesforce/label/c.Search_Key_Minimum_Length';
const CLEAR_SEARCH_DATA_EVENT_NAME = 'clearsearchdata';
const DIV_STYLING_ON_LOCAL_SEARCH = '';
const DIV_STYLING_ON_SERVER_SEARCH = 'localSearchStyling';
const SEND_SEARCH_KEY_EVENT_NAME = 'sendsearchkey';
const SHOW_FILTER_DATA_EVENT_NAME = 'showfiltereddata';
const address = 'address';
const externalIds = 'externalIds';

export default class SearchBox extends LightningElement {
  @api allRecords;
  @api enableServerSearch;
  @api nameField;
  @api searchBoxPlaceholder;
  @track filteredRecords;
  searchKey;

  /**
   * @description It returns the SLDS class name(s) based on the server search component.
   * @JIRA# LEM-3495
   */
  get parentDivStyling() {
    if (this.enableServerSearch) {
      return DIV_STYLING_ON_SERVER_SEARCH;
    }
    return DIV_STYLING_ON_LOCAL_SEARCH;
  }

  /**
   * @description To fetch filtered data on commit and keyup.
   * @JIRA# LEM-1158
   * @param event
   */
  handleCommit(event) {
    var currentSearchKeyLength = event.target.value.length;
    this.searchKey = event.target.value;
    // Sending search key for server search
    this.dispatchEvent(
      new CustomEvent(SEND_SEARCH_KEY_EVENT_NAME, {
        detail: this.searchKey
      })
    );
    if (currentSearchKeyLength >= searchKeyLength) {
      this.dataSearch();
    } else if (currentSearchKeyLength === 0) {
      this.dispatchEvent(
        new CustomEvent(CLEAR_SEARCH_DATA_EVENT_NAME, {
          detail: this.allRecords
        })
      );
    }
  }

  /**
   * @description This function contanins the logic to filter the list
   * from initial data based on the user input.
   * @JIRA# LEM-1158
   */
  dataSearch() {
    var iterator;
    var name = this.nameField;
    if (this.searchKey) {
      this.temporaryRecords = [];
      for (iterator = 0; iterator < this.allRecords.length; iterator++) {
        if (
          this.allRecords[iterator][name]
            .toUpperCase()
            .includes(this.searchKey.toUpperCase()) ||
          (Object.prototype.hasOwnProperty.call(this.allRecords[iterator], externalIds) &&
            this.allRecords[iterator][externalIds]
              .toUpperCase()
              .includes(this.searchKey.toUpperCase())) ||
          (Object.prototype.hasOwnProperty.call(this.allRecords[iterator], address) &&
            this.allRecords[iterator][address]
              .toUpperCase()
              .includes(this.searchKey.toUpperCase()))
        ) {
          this.temporaryRecords.push(this.allRecords[iterator]);
        }
      }
      this.filteredRecords = this.temporaryRecords;
    }
    this.dispatchEvent(
      new CustomEvent(SHOW_FILTER_DATA_EVENT_NAME, {
        detail: this.filteredRecords
      })
    );
  }
}