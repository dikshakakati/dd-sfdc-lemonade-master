/**
 * @author CriticalRiver
 * @date   Sep, 2024
 * @description Controller for the lwcDdMultiSelectPicklist LWC component
 */
//Supressing CRUD validations because we are doing updates to Custom Settings, not the database.
@SuppressWarnings('PMD.ApexCRUDViolation')
public with sharing class MultiSelectPicklistCtrl {
    /*****************************************************************************************************************************
    *
    * Wrapper for data to send back to the LWC component on INIT
    *
    *****************************************************************************************************************************/
    /**
     * @author CriticalRiver
     * @date   Sep, 2024
     * @description InitWrapper for the lwcDdMultiSelectPicklist LWC component
     */
    public with sharing class InitWrapper {
        @Auraenabled public DD_Multi_Select_Picklist_Master__mdt searchInfo;
        @Auraenabled public List<MultiSelectPicklistWrapper> lookupResults;

        /**
         * @author CriticalRiver
         * @date   Sep, 2024
         * @description InitWrapper for the lwcDdMultiSelectPicklist LWC component
         * @param customSearchName : Report name to get data
         */
        public InitWrapper(String customSearchName) {
            // Load the CMT record, so that the LWC component can refer to the values here to render itself.
            List<DD_Multi_Select_Picklist_Master__mdt> searchInfoList =
                [SELECT Id,
                        MasterLabel,
                        DeveloperName,
                        ApexClassName__c,
                        Clear_Keyword_After_Select__c,
                        Dropdown_Additional_CSS__c,
                        Dropdown_CSS_Position__c,
                        Dropdown_Icon_Avatar_Size__c,
                        Dropdown_Item_Additional_CSS__c,
                        Dropdown_Label_Merge_Format__c,
                        Dropdown_Scroll_Height__c,
                        Dropdown_SubLabel_Merge_Format__c,
                        Exclude_Already_Selected_Records__c,
                        Exclude_Field_Name__c,
                        Field_Label__c,
                        Filter_Allow_Advanced_Operators__c,
                        Filter_Allow_IS_BLANK_IS_NOT_BLANK_op__c,
                        Filter_Label_Has_Expand_Collapse__c,
                        From__c,
                        Group_By__c,
                        Icon_Name__c,
                        IconSrc_Merge_Format__c,
                        Icon_Type__c,
                        Input_Field_Placeholder__c,
                        Keep_SearchRes_Open_After_Pill_Remove__c,
                        Keep_SearchRes_Open_After_Select__c,
                        Keyword_Search_Field__c,
                        Keyword_Search_Like_Operator__c,
                        Keyword_Trim_Logic__c,
                        Label_Display_Variant__c,
                        Limit__c,
                        Maximum_Selections__c,
                        Maximum_Selections_Variant__c,
                        Minimum_Characters__c,
                        Order_By__c,
                        Picklist_Metadata_Force_Sort_By__c,
                        Picklist_Metadata_Field_Name__c,
                        Picklist_Metadata_Search_Label_Format__c,
                        Picklist_Metadata_Object_name__c,
                        Pill_Label_Merge_Format__c,
                        Pill_Variant__c,
                        Query_and_Cache_on_Init__c,
                        Results_Variant__c,
                        Results_Width__c,
                        Select__c,
                        Sharing_Model__c,
                        SOSL_Returning_Fields__c,
                        Type__c,
                        Value_Merge_Format__c,
                        Where_Clause__c,
                        (SELECT Id,
                                Value_Merge_Format__c,
                                Dropdown_Label_Merge_Format__c,
                                Dropdown_SubLabel_Merge_Format__c,
                                Pill_Label_Merge_Format__c,
                                IconSrc_Merge_Format__c,
                                Exclude_Field_Name__c,
                                Return_Fields__c,
                                Where_Clause__c,
                                Order_By__c,
                                Limit__c,
                                SObject_Name__c
                           FROM DD_Multi_Select_Picklist_SOSL_Return__r
                       ORDER BY Sequence__c)
                FROM DD_Multi_Select_Picklist_Master__mdt

            WHERE DeveloperName = :customSearchName];

            searchInfo = searchInfoList[0];
        }
    }

    /**
     * @description Called by LWC component on Init
     * @param customSearchName - DeveloperName of the CMT Record in DD_Multi_Select_Picklist_Master__mdt to render in component
     * @return InitWrapper - Wrapper which has the CMT record, and lookup result
     */
    @AuraEnabled(cacheable=true)
    public static InitWrapper getSearchInfo(String customSearchName) {
        InitWrapper w = new InitWrapper(customSearchName);

        // Query and Cache on Init is a mechanism for sending all dropdown values to the component
        // on the Init of the component, and further processing can happen on client side.
        if (w.searchInfo != null && w.searchInfo.Query_and_Cache_on_Init__c){
            w.lookupResults = getLookupResultBySearchInfo(DdConstants.BLANK_STRING,null,null,w.searchInfo,
                w.searchInfo.DD_Multi_Select_Picklist_SOSL_Return__r).values;
        }

        return w;
    }

    /**
     * @description Calls the Helper Class method to get the Lookup result
     * @param searchKeyword Word to use as a search param
     * @param excludeItems JSON string form of List<MultiSelectPicklistWrapper> This has list of already selected records in the UI, so that it can be ignored for current search
     * @param arguments JSON string form of Map<String,Object> This is used for the custom search type, to pass to the handling apex class
     * @param searchInfo CMT used to know how to retreive data
     * @param searchInfoSOSL List<CMT> which has info to formulate SOSL
     * @return MultiSelectPicklistValuesWrapper - Wrapper which has keyword and lookup result
     *                                                (if user is typing at a regular pace, its important to know which results stack against which keyword)
     */
    @SuppressWarnings('PMD.ApexDoc')
    @AuraEnabled(cacheable=true)
    public static MultiSelectPicklistValuesWrapper getLookupResultBySearchInfo(String searchKeyWord, String excludeItems, String arguments, DD_Multi_Select_Picklist_Master__mdt searchInfo, List<DD_Multi_Select_Picklist_SOSL_Return__mdt> searchInfoSOSL) {
        // Depending on sharing model, call the With Sharing/Without Sharing implementation
        return
            (getSharingModel(searchInfo) == 'Without Sharing' ?
                MultiSelectPicklistWithoutSharingUtil.fetchLookupResult(
                    searchKeyWord,excludeItems,arguments,searchInfo,searchInfoSOSL) :
                MultiSelectPicklistHelper.fetchLookupResult(
                    searchKeyWord,excludeItems,arguments,searchInfo,searchInfoSOSL)
            );
    }

    /**
     * @description Returns the sharing model to implement the logic
     * @param searchInfo - has sharing model specified
     * @return String - Sharing Model (With Sharing / Without Sharing)
     */
    private static String getSharingModel(DD_Multi_Select_Picklist_Master__mdt searchInfo) {
        return (String.isBlank(searchInfo.Sharing_Model__c) ? 'With Sharing' : searchInfo.Sharing_Model__c);
    }

    /**
     * @description - Can be used by server side 'Custom Search' code to conditionally render different configurations (if arg(x) = 'a', then load customSearchName='y' else 'customSearchName'='z')
     * @param searchKeyword Word to use as a search param
     * @param excludeItems JSON string form of List<MultiSelectPicklistWrapper> This has list of already selected records in the UI, so that it can be ignored for current search
     * @param arguments JSON string form of Map<String,Object> This is used for the custom search type, to pass to the handling apex class
     * @param customSearchName Developer name of DD_Multi_Select_Picklist_Master__mdt, which has all the params for search/UI
     * @return MultiSelectPicklistValuesWrapper - Wrapper which has keyword and lookup result (if user is typing at a regular pace, its important to know which results stack against which keyword)
     */
    @SuppressWarnings('PMD.ApexDoc')
    @AuraEnabled(cacheable=true)
    public static MultiSelectPicklistValuesWrapper getLookupResult(String searchKeyWord, String excludeItems, String arguments,String customSearchName) {

        InitWrapper w = new InitWrapper(customSearchName);

        return getLookupResultBySearchInfo(searchKeyWord,excludeItems,
            arguments,w.searchInfo,w.searchInfo.DD_Multi_Select_Picklist_SOSL_Return__r);
    }
}