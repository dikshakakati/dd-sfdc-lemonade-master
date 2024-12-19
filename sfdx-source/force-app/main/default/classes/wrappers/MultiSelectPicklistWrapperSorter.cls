/**
 * @author CriticalRiver
 * @date   Sep 20, 2024
 * @description - Sorter Class used by the 'Picklist Metadata' type of lwcDdMultiSelectPicklist component
 *               to sort values different from the sort order of the picklist metadata itself.
 */
public without sharing class MultiSelectPicklistWrapperSorter implements Comparable {
    public MultiSelectPicklistWrapper w;

    /**
     * @description To set and get the sort by for the fields
     * return String
     */
    public String sortBy {get;set;}

    /**
     * @author CriticalRiver
     * @date   Sep, 2024
     * @description compareTo : Compare the value and return thr Integer
     * @param w1 : Set Wrapper values
     */
    public MultiSelectPicklistWrapperSorter(MultiSelectPicklistWrapper w1) {
        w = w1;
        sortBy = 'dropDownLabel';
    }

    /**
     * @author CriticalRiver
     * @date   Sep, 2024
     * @description compareTo : Compare the value and return thr Integer
     * @param w1 : Set Wrapper values
     * @param s : String to define value of sort order
     */
    public MultiSelectPicklistWrapperSorter(MultiSelectPicklistWrapper w1, String s) {
        w = w1;
        sortBy = s;
    }

    /**
     * @author CriticalRiver
     * @date   Sep, 2024
     * @description compareTo : Compare the value and return thr Integer
     * @param compareTo : To compare the values of sort Order
     * @return Integer : Used to sort the values
     */
    public Integer compareTo(Object compareTo) {
        MultiSelectPicklistWrapperSorter wS = (MultiSelectPicklistWrapperSorter)compareTo;
        Integer returnValue = 0;

        if (sortBy == 'dropDownLabel') {
            if (w.dropDownLabel < wS.w.dropDownLabel){
                returnValue = -1;
            }
            else if (w.dropDownLabel >= wS.w.dropDownLabel){
                returnValue = 1;
            }
        } else if (sortBy == 'value') {
            if (w.value < wS.w.value){
                returnValue = -1;
            }
            else if (w.value >= wS.w.value){
                returnValue = 1;
            }
        }
        return returnValue;
    }
}