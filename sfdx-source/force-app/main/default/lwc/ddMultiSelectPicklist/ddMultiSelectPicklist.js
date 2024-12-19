/**
 * @author Sanidhya Jain
 * @date  Sept 2024
 * @decription Swiss army knife of components - multi-select picklist with any source (SOQL/SOSL,etc)
 *              Examples: /c/LDdMultiSelectPicklistLWCExamples.app
 */

/*****************************************************************************************************************************
 *
 * Imports
 *
 *****************************************************************************************************************************/
import { LightningElement, api, wire } from 'lwc';
import { stringIsBlank, stringIsNotBlank, isUndefinedOrNull, cloneObject } from 'c/lwcDdUtils';
import { BLANK_STRING, YES, NO, KEYCODE_ENTER, KEYCODE_ESC, KEYCODE_UP, KEYCODE_DOWN, KEYCODE_BACKSPACE_1, KEYCODE_BACKSPACE_2 } from 'c/lwcDdConst';
import getSearchInfo from '@salesforce/apex/MultiSelectPicklistCtrl.getSearchInfo';
import getLookupResultBySearchInfo from '@salesforce/apex/MultiSelectPicklistCtrl.getLookupResultBySearchInfo';
import { subscribe, unsubscribe, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
import RESETMC from '@salesforce/messageChannel/mcDdMultiSelectPicklistReset__c';

/*****************************************************************************************************************************
 *
 * CSS Class Consts
 *
 *****************************************************************************************************************************/
const MAINDIV_CLASS = BLANK_STRING;
const MAINDIV_FILTER_CLASS = ' slds-var-p-around_small slds-border_top ';
const FILTERLABEL_CLASS = ' filter-label ';
const FILTERLABEL_WITHCURSOR_CLASS = ' filter-label cursor-pointer ';
const COLLAPSEBUTTON_CLASS = ' collapse-button';
const EXPANDBUTTON_CLASS = ' expand-button';
const INPUTOUTERDIV_CLASS = ' slds-lookup ';
const INPUTOUTERDIV_WITHOPERATOR_CLASS = ' slds-lookup slds-m-top_x-small ';
const SLDS_IS_OPEN_CLASS = ' slds-is-open ';
const SLDS_IS_CLOSED_CLASS = ' slds-is-closed ';
const INPUTINNERDIV_CLASS = ' max-width ';
const INPUTINNERDIV_WITHERROR_CLASS = ' max-width slds-has-error ';
const LISTBOX_CLASS = 'slds-listbox slds-listbox_vertical slds-has-list-interactions customWebkitScrollbar ';
const LISTBOX_FIXED_CLASS = ' dd-multiselect-dropdown_fixed ';
const LISTBOX_ABSOLUTE_CLASS = ' dd-multiselect-dropdown_absolute ';

/*****************************************************************************************************************************
 *
 * Functional Consts
 *
 *****************************************************************************************************************************/
const LABELVARIANT_FILTER = 'Filter';
const LABELVARIANT_FIELD = 'Field';
const MAX_SELECTION_DEFAULT_MSG = 'You have reached the maximum number of selections.';
const NO_RECORDS_FOUND = 'No Records Found...';
const LOADING = 'Loading...';
const SEARCH_INPUT_FIELD = '[data-id="searchField-input"]';
const MAINCONTAINER = '[data-id="mainContainer"]';
const TOGGLE_HIDE = 'hide';
const TOGGLE_SHOW = 'show';
const DROPDOWN = 'Dropdown';
const FIXED = 'Fixed';
const TOP = 'Top';
const BELOW = 'Below';
const STARTS_WITH = 'Starts With';
const ENDS_WITH = 'Ends With';
const CONTAINS = 'Contains';
const HIDE_INPUT = 'Hide Input';
const DISABLE_INPUT = 'Disable Input';
const START_TRIM = 'Start Trim';
const TRIM = 'Trim';
const OPERATOR_IS_BLANK = 'Is Blank';
const OPERATOR_IS_NOT_BLANK = 'Is Not Blank';
const OPERATOR_EQUALS = 'Equals';
const OPERATOR_DOES_NOT_EQUAL = 'Does Not Equal';

/*****************************************************************************************************************************
 *
 * @api Picklist Value consts
 *
 *****************************************************************************************************************************/
const LABEL_DISPLAY_VARIANT_DEFAULT = 'Field';
const LABEL_DISPLAY_VARIANT_OPTIONS = new Set(['Label Hidden', 'Filter', 'Field']);
const DISABLED_OVERRIDE_OPTIONS = new Set([YES, NO]);

export default class DdMultiSelectPicklist extends LightningElement {
    /*****************************************************************************************************************************
    *
    * Public Variables
    *
    *****************************************************************************************************************************/

    // {String} (Required) Developer Name of DD_Multi_Select_Picklist_Master__mdt custom metadata type.
    @api customSearchName;
    // {String} (Required) Any text which will help uniquely identify this component
    @api uniqueIdentifier;
    // {String} CSS Classnames to be inserted in the main div
    @api className;
    // {Boolean} Show Required Asterisk
    @api required = false;
    // {CDdMultiSelectPicklistWrapper[]} Array of selected items to init on load
    @api selectedRecords = [];
    // {Boolean} Set by parent to indicate error
    @api hasError = false;
    // {String} Set by parent to provide an error message error
    @api errorMessage;

    // {Boolean} Allow component dropdown to hide when other parts of the application is clicked
    _allowOnBlur = true;
    get allowOnBlur() {
        return this._allowOnBlur;
    }
    @api
    set allowOnBlur(value) {
        if (isUndefinedOrNull(value))
            value = true;
        this._allowOnBlur = value;
    }

    // {String} Override the field label - else take value from CMT
    _label;
    get label() {
        return (this._label ? this._label : (this.searchInfo ? this.searchInfo.Field_Label__c : BLANK_STRING));
    }
    @api
    set label(value) {
        this._label = value;
    }

    // {String} Override the field label Variant - else take value from CMT
    _labelVariant;
    get labelVariant() {
        return (this._labelVariant ? this._labelVariant : (this.searchInfo ? this.searchInfo.Label_Display_Variant__c : BLANK_STRING));
    }
    @api
    set labelVariant(value) {
        value = (stringIsNotBlank(value) && LABEL_DISPLAY_VARIANT_OPTIONS.has(value)) ? value : LABEL_DISPLAY_VARIANT_DEFAULT;
        this._labelVariant = value;
    }

    // {Boolean} Override the Has Expand Collapse Variant for Filter Variant - else take value from CMT
    _showExpandCollapse = null;
    get showExpandCollapse() {
        return this._showExpandCollapse != null ?
            this._showExpandCollapse : (this.searchInfo ? this.searchInfo.Filter_Label_Has_Expand_Collapse__c : false);
    }
    @api
    set showExpandCollapse(value) {
        this._showExpandCollapse = value;
    }

    // {Boolean} Override disabled set by CMT default Override - Yes: Sets Disabled despite CMT, No: Unchecks Disabled despite CMT, Blank: No Override
    _disabledOverride;
    get disabledOverride() {
        return this._disabledOverride;
    }
    @api
    set disabledOverride(value) {
        value = (stringIsNotBlank(value) && DISABLED_OVERRIDE_OPTIONS.has(value)) ? value : BLANK_STRING;
        this._disabledOverride = value;
        this.setDisabled();
    }

    // {String} Custom Disabled Message
    @api disabledMessage = BLANK_STRING;

    // {String} Override help text set by CMT default
    _helpText;
    get helpText() {
        return this._helpText ? this._helpText : (this.searchInfo ? this.searchInfo.Label_Help_Text__c : false);
    }
    @api
    set helpText(value) {
        this._helpText = value;
    }

    // {String} Override apexClassArguments set by CMT default
    _apexClassArguments;
    get apexClassArguments() {
        return this._apexClassArguments;
    }
    @api
    set apexClassArguments(value) {
        this._apexClassArguments = value;
        this.searchHelper(this.searchKeyword ? this.searchKeyword : BLANK_STRING);
    }

    // {Boolean} Filter is expanded or collapsed
    @api isExpanded = false;

    /*****************************************************************************************************************************
     *
     * Public Methods
     *
     *****************************************************************************************************************************/
    /**
     * @decription Reset the selectedRecords
     * @param   None
     * @return  None
     */
    @api
    reset() {
        this.handleReset(null, null);
    }

    /*****************************************************************************************************************************
     *
     * Private Variables
     *
     *****************************************************************************************************************************/
    searchResults = []; // Dropdown options
    searchResultsMaster = []; //For Local Search; this has the master list of all Dropdown Options
    searchResultsMessage = BLANK_STRING;
    searchInfo;
    operator = OPERATOR_EQUALS;
    searchKeyword = BLANK_STRING;
    searchKeywordPreviousVal = BLANK_STRING;
    isLoading = false;
    selectFocusIndex; //Integer value that determines which record is focused
    pillFocusIndex; //Integer value that determines which pill is focused for remove by Backspace
    showSearchResults = false; //searchResClosed
    isBlankOrIsNotBlankAdded = false;
    resultsHeight;
    resultsTop;
    _disabled;

    /*****************************************************************************************************************************
     *
     * LifeCycle Hooks
     *
     *****************************************************************************************************************************/
    setFormAutocompleteOff = false;
    isSearchInputDisplayed = false;
    isBlurAdded = false;
    performSearchOnInit = false;

    renderedCallback() {
        if (this.allowOnBlur && !this.isBlurAdded) {
            window.addEventListener('click', this.blur);
            this.isBlurAdded = true;
        }

        // Remove Autocomplete on browser input, does not look good with dropdown and the autocomplete competing in the UI
        if (this.setFormAutocompleteOff == false) {
            let form = this.template.querySelector('.dd-multiselect-picklist-form');
            if (form) {
                form.autocomplete = "off";
                this.setFormAutocompleteOff = true;
            }
        }

        // Focus on the input field when its displayed (filter expand)
        let searchDisplay = this.template.querySelector(SEARCH_INPUT_FIELD);
        if (searchDisplay) {
            if (this.isSearchInputDisplayed == false) {
                this.isSearchInputDisplayed = true;
                this.focusSearchInputField();
            }
        } else {
            this.isSearchInputDisplayed = false;
        }

        // For 'Custom Search' type, this performs search on init of the component.
        if (!this.performSearchOnInit) {
            this.performSearchOnInit = true;
            if (this.apexClassArguments) {
                this.searchHelper(this.searchKeyword ? this.searchKeyword : BLANK_STRING);
            }
        }
    }

    // Reset Message Channel
    subscription_ResetMC = null;
    connectedCallback() {
        if (!this.subscription_ResetMC) {
            this.subscribeResetMC();
        }
    }

    // On Init, subscribe to the reset mesage channel. Example - In a multi-filter scenario, when a 'Clear Filter' button is clicked,
    // it can send a message on the channel asking multiple multiselectpicklist components to reset themselves
    subscribeResetMC() {
        this.subscription_ResetMC = subscribe(
            this.messageContext, RESETMC,
            (message) => {
                const searchType = message.uniqueIdentifierSearchType ? message.uniqueIdentifierSearchType : OPERATOR_EQUALS;
                if (stringIsNotBlank(message.uniqueIdentifier))
                    this.handleReset(searchType, message.uniqueIdentifier)
            }
            //,{ scope: APPLICATION_SCOPE }
        );
    }

    disconnectedCallback() {
        // Remove Blur
        if (this.isBlurAdded) {
            window.removeEventListener('click', this.blur);
            this.isBlurAdded = false;
        }
        // Unsubscribe from MC
        this.unsubscribeResetMC();
    }

    // Unsubscribe from MC
    unsubscribeResetMC() {
        if (this.subscription_ResetMC) {
            unsubscribe(this.subscription_ResetMC);
            this.subscription_ResetMC = null;
        }
    }

    // Hide the Search Result dropdown display
    blur = () => { this.toggleSearchResultsDisplay(TOGGLE_HIDE, true); }

    /*****************************************************************************************************************************
     *
     * Wires
     *
     *****************************************************************************************************************************/

    // Initialize messageContext for Message Service
    @wire(MessageContext)
    messageContext;

    // Wire call the getSearchInfo in the apex controller (on component init)
    @wire(getSearchInfo, { customSearchName: '$customSearchName' })
    getSearchInfo({ error, data }) {
        if (data) {

            this.searchInfo = data.searchInfo;
            // if result has lookup result, then its 'query and cache on init'
            // searchResults is the dynamic list, which on selection would have the selected item removed
            // searchResultsMaster is the initial list which the server sent, which is always in memory. When component is reset, it will be used to reset searchResults.
            if (data.lookupResults && data.lookupResults.length > 0) {
                this.searchResults = data.lookupResults;
            }
            if (this.searchInfo.Query_and_Cache_on_Init__c) {
                this.searchResultsMaster = cloneObject(this.searchResults);
            }
            this.setDisabled();
            this.notifyParentOnSearchInfoLoad();
        } else {
            //handle error;
        }
    }

    /*****************************************************************************************************************************
     *
     * UI Getters
     *
     *****************************************************************************************************************************/

    get disabled() {
        return this._disabled;
    }

    get selectFocusIndex() {
        return this.selectFocusIndex;
    }

    get mainDivClass() {
        return (this.labelVariant === LABELVARIANT_FILTER ? MAINDIV_FILTER_CLASS : MAINDIV_CLASS) +
            (this.className ? this.className : BLANK_STRING)
    }

    get showFilterLabelSection() {
        const isFilter = this.labelVariant === LABELVARIANT_FILTER;
        const hasLabel = stringIsNotBlank(this.label);
        return isFilter && (hasLabel || this.showExpandCollapse);
    }

    get filterLabelClass() {
        return (this.showExpandCollapse ? FILTERLABEL_WITHCURSOR_CLASS : FILTERLABEL_CLASS);
    }

    get filterLabelSectionButtonClass() {
        return this.isExpanded ? COLLAPSEBUTTON_CLASS : EXPANDBUTTON_CLASS;
    }

    get isLabelVariantFilter() {
        return (this.labelVariant === LABELVARIANT_FILTER);
    }

    get isLabelVariantField() {
        return (this.labelVariant === LABELVARIANT_FIELD);
    }

    get showPillContainerOnTop() {
        if (!this.searchInfo)
            return false;
        return (this.searchInfo.Pill_Variant__c === TOP && this.selectedRecords.length > 0);
    }

    get showPillContainerOnBottom() {
        if (!this.searchInfo)
            return false;
        return (this.searchInfo.Pill_Variant__c === BELOW && this.selectedRecords.length > 0);
    }

    get showOperatorSelectSection() {
        if (!this.searchInfo)
            return false;
        const allowOperator = this.searchInfo.Filter_Allow_Advanced_Operators__c;
        return (allowOperator && ((this.showExpandCollapse && this.isExpanded) || !this.showExpandCollapse));
    }

    get operatorOptions() {
        let options = [
            { label: OPERATOR_EQUALS, value: OPERATOR_EQUALS },
            { label: OPERATOR_DOES_NOT_EQUAL, value: OPERATOR_DOES_NOT_EQUAL }
        ];
        if (this.searchInfo && this.searchInfo.Filter_Allow_IS_BLANK_IS_NOT_BLANK_op__c && !this.isBlankOrIsNotBlankAdded) {
            options.push({ label: OPERATOR_IS_BLANK, value: OPERATOR_IS_BLANK });
            options.push({ label: OPERATOR_IS_NOT_BLANK, value: OPERATOR_IS_NOT_BLANK });
        }
        return options;
    }

    get showInputSection() {
        if (!this.searchInfo)
            return false;

        const operatorCheck = this.operator !== OPERATOR_IS_BLANK && this.operator !== OPERATOR_IS_NOT_BLANK;
        const maxSelectionsCheck =
            this.searchInfo.Maximum_Selections_Variant__c !== HIDE_INPUT ||
            (this.searchInfo.Maximum_Selections_Variant__c === HIDE_INPUT && this.selectedRecords.length < this.searchInfo.Maximum_Selections__c);
        const showExpandCollapseCheck = ((this.showExpandCollapse && this.isExpanded) || !this.showExpandCollapse);
        return operatorCheck && maxSelectionsCheck && showExpandCollapseCheck;
    }

    get inputOuterDivClass() {
        return (this.showOperatorSelectSection ? INPUTOUTERDIV_WITHOPERATOR_CLASS : INPUTOUTERDIV_CLASS) +
            (this.showSearchResults ? SLDS_IS_OPEN_CLASS : SLDS_IS_CLOSED_CLASS);
    }

    get inputInnerDivClass() {
        return (this.hasError ? INPUTINNERDIV_WITHERROR_CLASS : INPUTINNERDIV_CLASS);
    }

    get listBoxClass() {
        let retVal = LISTBOX_CLASS;
        if (!this.searchInfo)
            return retVal;

        if (this.searchInfo.Dropdown_Additional_CSS__c) {
            retVal += this.searchInfo.Dropdown_Additional_CSS__c;
        }
        if (this.searchInfo.Results_Variant__c == DROPDOWN) {
            retVal += (this.searchInfo.Dropdown_CSS_Position__c == FIXED ?
                LISTBOX_FIXED_CLASS : LISTBOX_ABSOLUTE_CLASS);
        }
        return retVal;
    }

    get listBoxStyle() {
        if (!this.searchInfo)
            return BLANK_STRING;

        let style = BLANK_STRING;

        if (this.resultsHeight) {
            style += `overflow-y:auto;max-height:${this.resultsHeight};`;
        } else if (this.searchInfo.Dropdown_Scroll_Height__c) {
            style += `overflow-y:auto;max-height:${this.searchInfo.Dropdown_Scroll_Height__c};`;
        }
        if (this.resultsTop) {
            style += `top:${this.resultsTop}px;`;
        }
        if (this.searchInfo.Results_Variant__c === DROPDOWN && this.searchInfo.Results_Width__c) {
            style += `width:${this.searchInfo.Results_Width__c};`;
        }
        return style;
    }

    get dropDownAdditionalStyle() {
        return this.searchInfo && this.searchInfo.Dropdown_Additional_CSS__c ?
            this.searchInfo.Dropdown_Additional_CSS__c : BLANK_STRING;
    }

    get showAddIsBlankOrIsNotBlankButton() {
        return this.operator == OPERATOR_IS_BLANK || this.operator == OPERATOR_IS_NOT_BLANK;
    }

    /*****************************************************************************************************************************
     *
     * Event Handlers
     *
     *****************************************************************************************************************************/

    //Expand / Collapse Toggle
    handleButtonToggle() {
        this.isExpanded = !this.isExpanded;
        if (this.isExpanded && this.searchInfo && this.searchInfo.Query_and_Cache_on_Init__c && !this.disabled) {
            this.searchResults = [];
            this.searchHelper(BLANK_STRING);
            this.toggleSearchResultsDisplay(TOGGLE_SHOW, false);
        }
        this.pollSearchResultPosition();
    }

    //Filter Variant - Operator Change
    handleOperatorOnChange(event) {
        event.stopPropagation();
        const operator = event.detail.value;

        if (operator == OPERATOR_IS_BLANK || operator == OPERATOR_IS_NOT_BLANK) {
            this.toggleSearchResultsDisplay(TOGGLE_HIDE, true);
        }

        this.operator = operator;
    }

    // On Focus on Search Input Field
    handleSearchFieldFocus() {
        if (!this.searchInfo)
            return;
        this.setDisabled();
        // If 'Query and Cache on Init' and search results is not open, open it
        if (this.searchInfo.Query_and_Cache_on_Init__c && !this.disabled && !this.showSearchResults) {
            this.searchResults = [];
            this.searchHelper(BLANK_STRING);
            this.toggleSearchResultsDisplay(TOGGLE_SHOW, false);
        }
    }

    // Search Input Field Key Up Listener - Listen to particular key strokes
    handleSearchFieldKeyUp(event) {
        const keyCode = event.which || event.keyCode || 0;

        const isBackspace = (keyCode === KEYCODE_BACKSPACE_1 || keyCode === KEYCODE_BACKSPACE_2);

        if (keyCode === KEYCODE_ESC && this.showSearchResults) { //On ESC, hide search result display
            event.stopPropagation();
            this.toggleSearchResultsDisplay('hide', false);
        } else if (keyCode === KEYCODE_ENTER) { // On ENTER, select the highlighted record in the search result display
            event.stopPropagation();
            this.updateSelectedRecordByFocusIndex();
        } else if (keyCode === KEYCODE_UP) { // On UP, go one record up in the search result display
            event.stopPropagation();
            this.moveRecordFocusUp()
        } else if (keyCode === KEYCODE_DOWN) { // On DOWN, go one record down in the search result display
            event.stopPropagation();
            this.moveRecordFocusDown();
        } else if (isBackspace) {
            if (!this.searchKeywordPrevious) { // On BACKSPACE, if there is no text in the input - then delete pills
                if (this.pillFocusIndex == null)
                    this.selectLastPill();
                else
                    this.removePill(this.selectedRecords[this.selectedRecords.length - 1], true);
            } else if (!this.searchKeyword) {
                this.searchKeywordPrevious = BLANK_STRING;
            }
        }
    }

    // Search Input Field Key Press Listener - Listen to particular key strokes
    handleSearchFieldKeyPress(event) {
        const keyCode = event.which || event.keyCode || 0;
        if (keyCode === KEYCODE_ENTER)
            event.preventDefault();
    }

    // Search Input Field onChange Listener - Update the search results accordingly
    handleOnChange(event) {
        this.pillFocusIndex = null;
        this.searchResults = [];
        this.searchKeywordPrevious = this.searchKeyword;
        this.searchKeyword = event.target.value ? event.target.value : BLANK_STRING;
        this.searchHelper(this.searchKeyword);
        event.stopPropagation();
    }

    // On Click on search result item - add Item to selected records
    handleOnSelect(event) {
        let item = event.detail.selectedRecord;
        this.addToSelectedRecords(item);
    }

    /**
     * Resets the component's selected records
     * @param   {String} searchType - Can be 'starts with' or 'equals'
     *          {String} uniqueIdentifier - Name or Prefix of component
     * @return  None
     */
    handleReset(searchType, uniqueIdentifier) {
        // If unique identifier is not passed
        // OR
        // If its passed - If search type is 'starts with' and current component unique identifier starts with the string passed
        //                 OR search type is 'equals' (or anything else for that matter) and current component unique identifier matches string passed
        // Then this component has to be reset.
        const resetThisComponent = stringIsBlank(uniqueIdentifier) || this.uniqueIdentifier === uniqueIdentifier ||
            (stringIsNotBlank(this.uniqueIdentifier) && stringIsNotBlank(searchType) &&
                searchType.toLowerCase() === 'starts with' && this.uniqueIdentifier.startsWith(uniqueIdentifier));

        if (!resetThisComponent)
            return;

        // Reset selected records
        this.selectedRecords = [];
        // If query and cache on init, reset searchResults
        if (this.searchInfo && this.searchInfo.Query_and_Cache_on_Init__c &&
            this.searchResultsMaster && this.searchResultsMaster.length) {
            this.searchResults = this.searchResultsMaster;
        }
        // Notify parent that the component has finished resetting.
        this.notifyParent();
    }

    // On Pill Remove, remove the item from selectedRecords
    handlePillRemove(event) {
        this.removePill(event.detail.rec, false);
    }

    // Generic Stop Prop event
    stopEventPropagation(event) {
        event.stopPropagation();
    }

    /*****************************************************************************************************************************
     *
     * Logic / Helper methods
     *
     *****************************************************************************************************************************/

    // Disable the component
    setDisabled() {
        // Dynamically, override takes priority
        if (this.disabledOverride === YES) {
            this._disabled = true;
            return;
        }

        if (this.disabledOverride === NO) {
            this._disabled = false;
            this.disabledMessage = BLANK_STRING;
            return false;
        }

        // Component is disabled if there is a Max selections specified and number of selected records match that.
        if (this.searchInfo && this.searchInfo.Maximum_Selections_Variant__c === DISABLE_INPUT) {
            if (this.selectedRecords.length >= this.searchInfo.Maximum_Selections__c) {
                this.disabledMessage = MAX_SELECTION_DEFAULT_MSG;
                this._disabled = true;
                this.toggleSearchResultsDisplay(TOGGLE_HIDE, true);
            } else {
                this.disabledMessage = null;
                this._disabled = false;
            }
        }
    }

    /**
     * @decription Toggles show or hide of the the search results
     * @param   {String} showOrHide - 'show' or 'hide'
     *          {Boolean} nullifySearchVar - Clears Search Input
     * @return  None
     */
    toggleSearchResultsDisplay(showOrHide, nullifySearchVar) {
        this.pillFocusIndex = null;
        if (showOrHide == TOGGLE_HIDE) {
            if (nullifySearchVar) {
                this.searchResults = [];
                this.searchKeyword = BLANK_STRING;
            }
            this.showSearchResults = false;
            this.selectFocusIndex = null;
        } else {
            this.showSearchResults = true;
            this.pollSearchResultPosition();
        }
    }

    /**
     * @decription Main Search Helper.
     * @param   {String} keyword
     * @return  None
     */
    searchHelper(keyword) {
        if (!this.searchInfo)
            return;
        this.pillFocusIndex = null;
        // Trim keyword
        const trimLogic = this.searchInfo.Search_Trim_Logic__c;
        if (keyword && trimLogic === START_TRIM)
            keyword = keyword.trimStart();
        else if (keyword && trimLogic == TRIM)
            keyword = keyword.trim();

        // Check Keyword length - for a new searches, you want user to enter a few characters before you call the server
        const minChar = this.searchInfo.Minimum_Characters__c;
        if (keyword.length < minChar) {
            this.toggleSearchResultsDisplay(TOGGLE_HIDE, false);
            return;
        }

        // Show the Search Results in loading mode
        this.toggleSearchResultsDisplay(TOGGLE_SHOW, false);
        this.isLoading = true;
        this.searchResultsMessage = LOADING;

        // If 'Query and Cache on Init', the search can be client side
        // Else its server side
        if (this.searchInfo.Query_and_Cache_on_Init__c && this.searchResultsMaster.length > 0) {
            this.searchHelper_Local(keyword);
        } else {
            this.searchHelper_Server(keyword);
        }
    }

    /**
     * @decription Client Side Search Helper.
     * @param   {String} keyword
     * @return  None
     */
    searchHelper_Local(keyword) {
        let selectedRecords = [];
        for (let rec of this.selectedRecords) {
            selectedRecords.push(rec.value);
        }
        keyword = keyword ? keyword.toLowerCase() : BLANK_STRING;
        const operator = this.searchInfo.Keyword_Search_Like_Operator__c ? this.searchInfo.Keyword_Search_Like_Operator__c : STARTS_WITH;
        let searchResults = [];

        // Iterate thru searchResultMaster and populate searchResult based on keyword and operator
        for (let item of this.searchResultsMaster) {
            if (selectedRecords.indexOf(item.value) != -1)
                continue;

            if (!stringIsNotBlank(keyword)) {
                searchResults.push(item);
                continue;
            }

            let itemValue = item.dropDownLabel ? item.dropDownLabel.toLowerCase() : BLANK_STRING;

            if ((operator === STARTS_WITH && itemValue.startsWith(keyword)) ||
                (operator === CONTAINS && itemValue.includes(keyword)) ||
                (operator === ENDS_WITH && itemValue.endsWith(keyword))) {
                searchResults.push(item);
            }
        }
        this.searchResultsMessage = (searchResults.length === 0) ? NO_RECORDS_FOUND : BLANK_STRING;
        this.searchResults = searchResults;
        this.selectFocusIndex = null;
        this.isLoading = false;
    }

    /**
     * @decription Server Side Search Helper.
     * @param   {String} keyword
     * @return  None
     */
    searchHelper_Server(keyword) {
        // Call Apex Controller to get Lookup Data
        getLookupResultBySearchInfo({
            searchKeyWord: keyword,
            excludeItems: JSON.stringify(this.selectedRecords),
            arguments: this.apexClassArguments,
            searchInfo: this.searchInfo,
            searchInfoSOSL: this.searchInfo.DD_Multi_Select_Picklist_SOSL_Return__r
        }).then(result => {
            this.isLoading = false;
            // Upon natural typing speed of user, there might be multiple requests to the server each being processed in a 'race'.
            // By comparing the keyword of the result and the keyword in the UI, we are making sure that stragglers in the race with old/incorrect keywords dont update the
            // search result incorrectly.
            if (result.keyWord === this.searchKeyword) {
                this.searchResultsMessage = result.values.length == 0 ? NO_RECORDS_FOUND : BLANK_STRING;
                this.searchResults = result.values;
                this.selectFocusIndex = null;
                if (this.searchInfo.Query_and_Cache_on_Init__c)
                    this.searchResultsMaster = cloneObject(result.values);
            } /* else {
                console.log('MultiSelectPicklist - ' + this.uniqueIdentifier,'Keyword return ignored: ' + result.keyWord);
            }*/
        })
            .catch(error => {
                this.isLoading = false;
                console.log('MultiSelectPicklist - ' + this.uniqueIdentifier, error);
            });
    }

    /**
     * @decription Add item to selectedRecords
     * @param   {Object} selectedRec
     * @return  None
     */
    addToSelectedRecords(selectedRec) {
        let selectedRecord = cloneObject(selectedRec);
        selectedRecord.operator = this.operator;

        // Filter Variant - Special PillLabel manipulation for 'Does Not Equal'
        if (this.operator === OPERATOR_DOES_NOT_EQUAL) {
            selectedRecord.pillLabel = `NOT ${selectedRecord.pillLabel}`;
        }

        // Filter Variant - If it allows Operators, then correctly sort the selectedRecords by operator
        if (this.searchInfo && this.searchInfo.Filter_Allow_Advanced_Operators__c) {
            let recsWithEquals = new Array();
            let recsWithDoesNotEqual = new Array();
            let recsWithIsBlankOrIsNotBlank = new Array();
            for (let rec of this.selectedRecords) {
                if (rec.operator === OPERATOR_EQUALS) {
                    recsWithEquals.push(rec);
                } else if (rec.operator === OPERATOR_DOES_NOT_EQUAL) {
                    recsWithDoesNotEqual.push(rec);
                } else {
                    recsWithIsBlankOrIsNotBlank.push(rec);
                }
            }
            if (selectedRecord.operator === OPERATOR_EQUALS) {
                recsWithEquals.push(selectedRecord);
            } else if (selectedRecord.operator === OPERATOR_DOES_NOT_EQUAL) {
                recsWithDoesNotEqual.push(selectedRecord);
            } else {
                recsWithIsBlankOrIsNotBlank.push(selectedRecord);
            }
            let selectedRecords = new Array();
            selectedRecords = selectedRecords.concat(recsWithEquals);
            selectedRecords = selectedRecords.concat(recsWithDoesNotEqual);
            selectedRecords = selectedRecords.concat(recsWithIsBlankOrIsNotBlank);
            this.selectedRecords = selectedRecords;
        } else {
            // Deep Clone current selectedRecords, add item and update selectedRecords. New Memory instance forces reactivity in lwc.
            let selectedRecords = cloneObject(this.selectedRecords);
            selectedRecords.push(selectedRecord);
            this.selectedRecords = selectedRecords;
        }

        // Check Max Selections Logic
        this.setDisabled();

        if (!this.disabled) {
            // Option to keep search result list open after selection.
            if (this.searchInfo && this.searchInfo.Keep_SearchRes_Open_After_Select__c) {
                this.searchResults = [];
                this.searchKeyword = this.searchInfo.Clear_Keyword_After_Select__c ? BLANK_STRING : this.searchKeyword;
                this.searchHelper(this.searchKeyword);
            } else {
                this.toggleSearchResultsDisplay(TOGGLE_HIDE, true);
            }
        }

        // Notify Parent, clean up and set focus
        this.notifyParent();
        this.selectFocusIndex = null;
        this.pillFocusIndex = null;
        this.focusSearchInputField();
        this.searchKeywordPrevious = BLANK_STRING;
    }

    /**
     * @decription Add item to selectedRecords
     * @param   {Object} pillToRemove
     *          {Boolean} selectLastPill - When using keyboard backspace to remove items, this can be used to highlight last pill
     * @return  None
     */
    removePill(pillToRemove, selectLastPill) {
        // Deep Clone, and remove the pill corresponding to the value
        let selectedRecords = cloneObject(this.selectedRecords);
        for (var i = 0; i < selectedRecords.length; i++) {
            if (selectedRecords[i].value == pillToRemove.value) {
                selectedRecords.splice(i, 1);
                this.selectedRecords = selectedRecords;
                break;
            }
        }

        // Max Selections logic
        this.setDisabled();

        if (!this.disabled && this.searchInfo) {
            // Option to keep search result list open after pill removal
            if (this.searchInfo.Keep_SearchRes_Open_After_Pill_Remove__c) {
                this.searchResults = [];
                this.searchHelper(this.keyword ? this.keyword : BLANK_STRING);
            } else {
                this.toggleSearchResultsDisplay(TOGGLE_HIDE, true);
            }
        }

        // Notify Parent and post processing
        this.notifyParent();

        this.selectFocusIndex = null;
        if (selectLastPill) {
            this.selectLastPill();
        }
        if (pillToRemove.operator == OPERATOR_IS_BLANK || pillToRemove.operator == OPERATOR_IS_NOT_BLANK)
            this.isBlankOrIsNotBlankAdded = false;
    }

    // On KeyUp with 'UP' key, move highlighted record one position up
    moveRecordFocusUp() {
        if (this.searchResults.length > 0) {
            if (isUndefinedOrNull(this.selectFocusIndex) || this.selectFocusIndex === 0) {
                this.selectFocusIndex = this.searchResults.length - 1;
            } else {
                this.selectFocusIndex--;
            }
        }
        this.updateLookupScrollOnSelectFocusIndexChange();
    }

    // On KeyUp with 'DOWN' key, move highlighted record one position down
    moveRecordFocusDown() {
        const isValidSearchResults = this.searchResults.length > 0;
        const isDisabled = this.disabled;
        if (!this.showSearchResults && this.searchInfo &&
            this.searchInfo.Query_and_Cache_on_Init__c && !isDisabled &&
            !isValidSearchResults) {
            this.searchResults = [];
            this.searchHelper(BLANK_STRING);
            this.toggleSearchResultsDisplay(TOGGLE_SHOW, false);
            this.setSelectFocusIndex();
        } else if (isValidSearchResults) {
            if (!this.showSearchResults)
                this.toggleSearchResultsDisplay(TOGGLE_SHOW, false);
            this.setSelectFocusIndex();
        }
    }

    // On KeyUp with 'ENTER' key, Select the record being highlighted
    updateSelectedRecordByFocusIndex() {
        if (this.searchResults.length === 0)
            return;
        const focusIndex = this.selectFocusIndex ? this.selectFocusIndex : 0;
        if (focusIndex < this.searchResults.length) {
            this.addToSelectedRecords(cloneObject(this.searchResults)[focusIndex]);
        }
    }

    // SelectFocusIndex helps with highlighting current position/record on the search results list
    setSelectFocusIndex() {
        this.selectFocusIndex = (isUndefinedOrNull(this.selectFocusIndex) || this.selectFocusIndex === this.searchResults.length - 1) ?
            0 : this.selectFocusIndex + 1;
        this.updateLookupScrollOnSelectFocusIndexChange();
    }

    // Auto-Scroll Search results box on select focus index change, to keep highlighted record always in view
    updateLookupScrollOnSelectFocusIndexChange() {
        const lookupMenu = this.template.querySelector('.slds-listbox');
        if (!lookupMenu || isUndefinedOrNull(this.selectFocusIndex)) {
            return;
        }
        if (this.selectFocusIndex == 0) {
            lookupMenu.scrollTop = 0;
            return;
        }
        const options = lookupMenu.childNodes;
        let focusScroll = 0;
        let focusScrollBottom = 0;
        let focusScrollTop = 0;

        for (let i = 0; i < options.length && i <= this.selectFocusIndex; i++) {
            focusScroll += this.getElementHeight(options[i]);
        }

        const eleHieght = this.getElementHeight(options[this.selectFocusIndex]);
        focusScrollBottom = focusScroll + eleHieght;
        focusScrollTop = focusScroll - eleHieght < 0 ? 0 : focusScroll - eleHieght;
        if (focusScrollTop < lookupMenu.scrollTop) {
            lookupMenu.scrollTop = focusScrollTop;
        } else if (focusScrollBottom > lookupMenu.scrollTop + lookupMenu.clientHeight) {
            lookupMenu.scrollTop = focusScrollBottom - lookupMenu.clientHeight;
        }
    }

    // Used to get the height to scroll in updateLookupScrollOnSelectFocusIndexChange
    getElementHeight(ele) {
        return ele ? ele.getBoundingClientRect().height : 0;
    }

    // Highlight last pill
    selectLastPill() {
        if (this.selectedRecords.length > 0) {
            this.pillFocusIndex = this.selectedRecords.length - 1;
        } else {
            this.pillFocusIndex = null;
            this.focusSearchInputField();
        }
    }

    // If POSITION of dropdown is fixed, then this helps that search result DOM element to move with the input field moves in the screen (example, vertical scroll)
    pollSearchResultPosition() {
        if (!this.searchInfo)
            return;
        const isFixedPosition = this.searchInfo.Dropdown_CSS_Position__c === FIXED;
        const isDropdownVariant = this.searchInfo.Results_Variant__c === DROPDOWN;

        // As long as the search result is open, and meets other conditions, the code will execute the polling for position changes.
        let needsPolling = isDropdownVariant && this.showSearchResults &&
            isFixedPosition &&
            (!this.showExpandCollapse || (this.showExpandCollapse && this.isExpanded));

        if (needsPolling) {
            // Identify location of main container and place the result right under that
            setTimeout(() => {
                const control = this.template.querySelector(MAINCONTAINER);
                if (!control) {
                    return;
                }
                let rect = control.getBoundingClientRect();
                this.resultsTop = rect.bottom + 2;
                let resultsHeight = window.innerHeight - rect.bottom - 5;
                const maxHeight = this.searchInfo.Dropdown_Scroll_Height__c;

                if (!this.isLoading && !isUndefinedOrNull(maxHeight)) {
                    if (resultsHeight < parseInt(maxHeight))
                        this.resultsHeight = resultsHeight + 'px';
                    else
                        this.resultsHeight = maxHeight;
                }
                this.pollSearchResultPosition();
            }, 10);
        }
    }

    // When Operator 'IS BLANK' or 'IS NOT BLANK' is selected and 'Add' button is clicked, this will add the item to selectedRecords.
    addIsBlankOrIsNotBlank() {
        this.isBlankOrIsNotBlankAdded = true;
        let item = {
            dropDownLabel: BLANK_STRING,
            dropDownSubLabel: BLANK_STRING,
            pillLabel: this.operator,
            value: this.operator,
            iconSrc: BLANK_STRING,
            operator: this.operator
        };
        this.addToSelectedRecords(item);
        this.operator = OPERATOR_EQUALS;
    }

    // Notify parent on change
    notifyParent() {
        const evt = new CustomEvent("change", {
            detail: {
                uniqueIdentifier: this.uniqueIdentifier,
                selectedOptions: this.selectedRecords
            }
        });
        this.dispatchEvent(evt);
    }

    //Notify parent that Search info has loaded
    notifyParentOnSearchInfoLoad() {
        const evt = new CustomEvent("loadcomplete", {
            detail: {
                uniqueIdentifier: this.uniqueIdentifier
            }
        });
        this.dispatchEvent(evt);
    }

    // Focus the Search Input Field
    focusSearchInputField() {
        const inputField = this.template.querySelector(SEARCH_INPUT_FIELD);
        if (inputField)
            inputField.focus();
    }
}