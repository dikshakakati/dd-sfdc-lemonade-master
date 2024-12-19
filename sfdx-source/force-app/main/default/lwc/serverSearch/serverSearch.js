/**
 * @author Deloitte
 * @date 10/28/2022
 * @description JavaScript controller for reusable server search component.
 */
import { LightningElement, api } from 'lwc';
import icon from '@salesforce/label/c.Server_Search_Icon';
import label from '@salesforce/label/c.Server_Search_Label';
import title from '@salesforce/label/c.Server_Search_Title';
const SERVER_SEARCH_EVENT_NAME = 'triggerserversearch';

export default class ServerSearch extends LightningElement {
  @api enableServerSearch;
  icon = icon;
  label = label;
  title = title;

  /**
   * @description It triggers server search event.
   */
  notifyServerSearch() {
    // Sending server search called indicator
    this.dispatchEvent(
      new CustomEvent(SERVER_SEARCH_EVENT_NAME, {
        bubbles: true,
        composed: true,
        detail: true
      })
    );
  }
}