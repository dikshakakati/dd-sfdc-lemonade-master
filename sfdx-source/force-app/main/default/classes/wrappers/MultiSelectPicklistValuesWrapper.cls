/**
 * @author CriticalRiver
 * @date   Sep 20, 2024
 * @description Wrapper used by lwcDdMultiSelectPicklist lwc/CDdMutliSelectPicklist code -- it contains keyword and result
 *             When user is typing at any speed, its important to tie the keyword against the result so that
 *             race conditions in server calls dont end up messing up the dropdown results with inaccurate values not corresponding
 *             to the current keyword in the UI.
 */
 public class MultiSelectPicklistValuesWrapper {
    /**
     * @description Set and get the keyWord
     * @return String : value of the key word
     */
    @AuraEnabled public String keyWord {get;set;}

    /**
     * @description get and set List of Multiselect picklist wrapper
     * @return List<MultiSelectPicklistWrapper> : List of Multiselect picklist wrapper
     */
    @AuraEnabled public List<MultiSelectPicklistWrapper> values {get;set;}

    /**
     * @description Set List of Multiselect picklist wrapper
     */
    public MultiSelectPicklistValuesWrapper(){
        this.keyWord = DdConstants.BLANK_STRING;
        this.values = new List<MultiSelectPicklistWrapper>();
    }

    /**
     * @description Set Wrapper values according to inputs
     * @param keyWord KeyWord for the multiplicklist value searched
     * @param values List if the values where we have to do select
     */
    public MultiSelectPicklistValuesWrapper(String keyWord,
        List<MultiSelectPicklistWrapper> values) {
        this.keyWord = keyWord;
        this.values = values;
    }
}