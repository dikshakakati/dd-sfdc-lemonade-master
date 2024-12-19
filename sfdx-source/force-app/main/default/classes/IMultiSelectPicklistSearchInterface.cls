/**
 * @author CriticalRiver
 * @date   Sep 20, 2024
 * @description Interface to implement 'Custom search' type of lwcDdMultiSelectPicklist LWC component
 *             Refer to CDdMultiSelectPicklistCustomExample to see how to implement this interface.
 */
public interface IMultiSelectPicklistSearchInterface extends fflib_ISObjects {
    /**
     * @description Accepts Arguments etc, and has custom code to return data back to the UI
     * @param searchKeyword - Word to use as a search param
     * @param sInfo - Driving CMT which has the config for the search
     * @param excludeItemsSet - This has list of already selected records in the UI, so that it can be ignored for current search
     * @param args - Has Arguments passed by the UI for dynamic queries, etc.
     * @return  List<MultiSelectPicklistWrapper> - Resultant Data
     */
    List<MultiSelectPicklistWrapper> getData(String searchKeyword,
        DD_Multi_Select_Picklist_Master__mdt sInfo,
        Set<String> excludeItemsSet,Map<String, Object> args);
}