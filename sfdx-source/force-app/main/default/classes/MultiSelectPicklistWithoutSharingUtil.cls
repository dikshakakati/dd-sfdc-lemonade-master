/**
 * @author CriticalRiver
 * @date   Sep 20, 2024
 * @description MultiSelectPicklist code uses this to force 'without sharing' mode for the queries
 */
public without sharing class MultiSelectPicklistWithoutSharingUtil {
    /**
     * @description Main method which routes request to the other helepr methods based on the type of the search
     * @param searchKeyword Word to use as a search param
     * @param excludeItems JSON string form of List<MultiSelectPicklistWrapper> This has list of already selected records in the UI, so that it can be ignored for current search
     * @param arguments JSON string form of Map<String,Object> This is used for the custom search type, to pass to the handling apex class
     * @param sInfo CMT used to know how to retreive data
     * @param sInfoSOSL List<CMT> which has info to formulate SOSL
     * @return MultiSelectPicklistValuesWrapper - Wrapper which has keyword and lookup result (if user is typing at a regular pace, its important to know which results stack against which keyword)
     */
    @SuppressWarnings('PMD.ApexDoc')
    public static MultiSelectPicklistValuesWrapper fetchLookupResult(String searchKeyWord, String excludeItems, String arguments, DD_Multi_Select_Picklist_Master__mdt sInfo, List<DD_Multi_Select_Picklist_SOSL_Return__mdt> sInfoSOSL) {
        return MultiSelectPicklistHelper.fetchLookupResult(
            searchKeyWord,excludeItems,arguments,sInfo,sInfoSOSL
        );
    }
}