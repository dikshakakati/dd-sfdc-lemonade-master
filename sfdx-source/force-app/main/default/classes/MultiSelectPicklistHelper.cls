/**
 * @author CriticalRiver
 * @date Sep 20, 2024
 * @description Has methods to implement core logic (SOQL, SOSL, etc) of the lwcDdMultiSelectPicklist component
 *             Does inherited sharing - if called from MultiSelectPicklistCtrl, it runs in With sharing mode
 *                                      if called from MultiSelectPicklistWithoutSharingUtil, it runs in Without sharing mode
 */
@SuppressWarnings('PMD.ApexSOQLInjection, PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity, PMD.ApexCRUDViolation')
public inherited sharing class MultiSelectPicklistHelper {

    public static final String LOG_MULTI_SELECT_HELPER = 'MultiSelectPicklistHelper';
    public static final String LOG_FETCH_LOOKUP_RESULT_SEARCH = 'Get Lookup Result Custom Search';

    /**
     * @description Main method which routes request to the other helepr methods based on the type of the search
     * @param searchKeyWord Word to use as a search param
     * @param excludeItems JSON string form of List<MultiSelectPicklistWrapper>; This has list of already selected records in the UI, so that it can be ignored for current search
     * @param arguments JSON string form of Map<String,Object>; This is used for the custom search type, to pass to the handling apex class
     * @param sInfo CMT used to know how to retreive data
     * @param sInfoSOSL List<CMT> which has info to formulate SOSL
     * @return MultiSelectPicklistValuesWrapper - Wrapper which has keyword and lookup result
     *                                                (if user is typing at a regular pace, its important to know which results stack against which keyword)
     */
    public static MultiSelectPicklistValuesWrapper fetchLookupResult(String searchKeyWord, String excludeItems, String arguments, DD_Multi_Select_Picklist_Master__mdt sInfo, List<DD_Multi_Select_Picklist_SOSL_Return__mdt> sInfoSOSL) {

        // Store the searchKeyword in another param (to return back later), and pre-process the searchKeyword
        String keyWord = searchKeyword;
        searchKeyWord = searchKeyWord.removeEnd('*');

        if (sInfo.Keyword_Search_Like_Operator__c == 'Contains') {
            searchKeyWord = DdConstants.DELIMITER_PERCENT + String.escapeSingleQuotes(searchKeyWord) + DdConstants.DELIMITER_PERCENT;
        } else if (sInfo.Keyword_Search_Like_Operator__c == 'Ends With') {
            searchKeyWord = DdConstants.DELIMITER_PERCENT + String.escapeSingleQuotes(searchKeyWord);
        } else if (sInfo.Type__c != 'SOSL') {
            searchKeyWord = String.escapeSingleQuotes(searchKeyWord) + DdConstants.DELIMITER_PERCENT;
        }

        // To not show previously selected records again the UI dropdown, the component sends the items here
        // Process it to get a set of items to exclude
        Set<String> excludeItemsSet = sInfo.Exclude_Already_Selected_Records__c ?
            getItemsToExclude(excludeItems) : new Set<String>();

        List<MultiSelectPicklistWrapper> values = new List<MultiSelectPicklistWrapper>();
        // Depending on the type of operation, route to the appropriate helper methods
        switch on sInfo.Type__c {
            when 'Object Records' {
                values = fetchLookupResultObjectRecords(searchKeyword,sInfo,excludeItemsSet);
            }
            when 'Aggregate Query' {
                values = fetchLookupResultAggregateQuery(searchKeyword,sInfo,excludeItemsSet);
            }
            when 'SOSL' {
                values = fetchLookupResultSOSL(searchKeyword,sInfo,sInfoSOSL,excludeItemsSet);
            }
            when 'Object Field Picklist Metadata' {
                values = fetchLookupResultFieldPicklist(searchKeyword,sInfo,excludeItemsSet);
            }
            when 'Static Values (in DD Multi Select Picklist Search Value)' {
                values = fetchLookupResultStaticValues(searchKeyword,sInfo,excludeItemsSet);
            }
            when 'Custom Search' {
                values = fetchLookupResultCustomSearch(searchKeyWord,sInfo,excludeItemsSet,arguments);
            }
        }

        return new MultiSelectPicklistValuesWrapper(keyWord,values);
    }

    /**
     * @description Method which does SOQL to query against object
     * @param searchKeyword - Word to use as a search param
     * @param sInfo - CMT used to know how to retreive data
     * @param excludeItemsSet - Items to exclude from search
     * @return  List<MultiSelectPicklistWrapper> - Resultant Data in wrapper
     */
    private static List<MultiSelectPicklistWrapper> fetchLookupResultObjectRecords(String searchKeyword,
            DD_Multi_Select_Picklist_Master__mdt sInfo,Set<String> excludeItemsSet) {

        List<MultiSelectPicklistWrapper> retVal = new List<MultiSelectPicklistWrapper>();

        // Object needs to be accessible to the current users profile to perform this (Checking object access only, not FLS)
        // Helps with especially securing guest profile from accessing stuff in without sharing mode.
        if (!DdUtilitiesService.objectIsAccessible(sInfo.From__c)) {
            return retVal;
        }

        // Keyword can be seached across multiple fields, this formulates the where clause accordingly
        String keywordWhereClause = DdConstants.BLANK_STRING;
        for (String keywordSearchField : sInfo.Keyword_Search_Field__c.split('\\,')){
            keywordWhereClause += keywordSearchField + ' LIKE :searchKeyword OR ';
        }

        keywordWhereClause = ' (' + keywordWhereClause.removeEnd(' OR ') + ') ';

        // Creates dynamic where clause
        String whereClause = ' WHERE ' + keywordWhereClause +
            (String.isNotBlank(sInfo.Where_Clause__c) ? ' AND ' + sInfo.Where_Clause__c + DdConstants.DELIMITER_SPACE : DdConstants.BLANK_STRING) +
            (excludeItemsSet.isEmpty() ? DdConstants.BLANK_STRING : ' AND ' + sInfo.Exclude_Field_Name__c + ' NOT IN :excludeItemsSet ');

        // Creates dynamic query
        String query = 'SELECT ' + sInfo.Select__c +
            ' FROM ' + sInfo.From__c + whereClause +
            (String.isNotBlank(sInfo.Order_By__c) ? ' ORDER BY ' + sInfo.Order_By__c +DdConstants.BLANK_STRING : DdConstants.BLANK_STRING) +
            (sInfo.Limit__c != null ? ' LIMIT ' + Integer.valueOf(sInfo.Limit__c) : DdConstants.BLANK_STRING);

        //Creates the result to return back to the component
        for (sObject obj: Database.query(query)) {
            retVal.add(createWrapperForSobject(obj,sInfo));
        }
        return retVal;
    }

    /**
     * @description Creates the MultiSelectPicklistWrapper wrapper
     * @param obj - SObject containing data
     * @param sInfo - DD_Multi_Select_Picklist_Master__mdt records; this has the fields which has the format for returning data to the UI
     * @return  MultiSelectPicklistWrapper - Resultant Wrapper
     */
    public static MultiSelectPicklistWrapper createWrapperForSobject(
            Sobject obj, Sobject sInfo) {

        MultiSelectPicklistWrapper w = new MultiSelectPicklistWrapper(obj);

        // Populate wrapper fields by merging the data into the format specified in the CMT record's field
        w.value = decodeMergeStringObjectRecords((String)sInfo.get('Value_Merge_Format__c'),obj);
        w.dropDownLabel = decodeMergeStringObjectRecords((String)sInfo.get('Dropdown_Label_Merge_Format__c'),obj);
        w.pillLabel = decodeMergeStringObjectRecords((String)sInfo.get('Pill_Label_Merge_Format__c'),obj);

        String dropDownSubLabel = (String)sInfo.get('Dropdown_SubLabel_Merge_Format__c');
        if (String.isNotBlank(dropDownSubLabel)) {
            w.dropDownSubLabel = decodeMergeStringObjectRecords(dropDownSubLabel, obj);
        }

        String iconSrc = (String)sInfo.get('IconSrc_Merge_Format__c');
        if (String.isNotBlank(iconSrc)) {
            w.iconSrc = decodeMergeStringObjectRecords(iconSrc,obj);
        }

        return w;
    }

    /**
     * @description Creates Merge string
     * @param s - String to merge on
     * @param obj - Object with data
     * @return String - Resultant merged string
     */
    private static String decodeMergeStringObjectRecords(String s, Sobject obj) {
        // Fields are provided in merge string in format {<FieldAPIName>}
        // Replace all {<FieldAPIName} with the value of the Field from the Sobject record
        Integer i = s.indexOf('{',0);
        while (i != -1) {
            Integer j = s.indexOf('}', i);
            if (j == -1) {
                break;
            }

            String mergeField = s.subString(i,++j);
            if (String.isBlank(mergeField)) {
                break;
            }

            String field = mergeField.removeStart('{').removeEnd('}');

            // Gives you the field value from field in current obj or from a lookup field (x__c or y__r.z__c)
            String fieldVal = DdUtilitiesService.getFieldValAsString(obj,field,'String');

            s = s.replace(mergeField, String.isBlank(fieldVal) ? DdConstants.BLANK_STRING : fieldVal);
            i = s.indexOf('{', 0);
        }
        return s;
    }

    /**
     * @description Method which does SOQL to query an aggregate query against object
     * @param searchKeyword - Word to use as a search param
     * @param sInfo - CMT used to know how to retreive data
     * @param excludeItemsSet - Items to exclude from search
     * @return List<MultiSelectPicklistWrapper> - Resultant Data in wrapper
     */
    private static List<MultiSelectPicklistWrapper> fetchLookupResultAggregateQuery(String searchKeyword,
                DD_Multi_Select_Picklist_Master__mdt sInfo, Set<String> excludeItemsSet) {

        List<MultiSelectPicklistWrapper> retVal = new List<MultiSelectPicklistWrapper>();

        // Object needs to be accessible to the current users profile to perform this (Checking object access only, not FLS)
        // Helps with especially securing guest profile from accessing stuff in without sharing mode.
        if (!DdUtilitiesService.objectIsAccessible(sInfo.From__c)) {
            return retVal;
        }

        // Keyword can be seached across multiple fields, this formulates the where clause accordingly
        String keywordWhereClause = DdConstants.BLANK_STRING;
        for (String keywordSearchField : sInfo.Keyword_Search_Field__c.split('\\,')) {
            keywordWhereClause += keywordSearchField + ' LIKE :searchKeyword OR ';
        }

        keywordWhereClause = ' (' + keywordWhereClause.removeEnd(' OR ') + ') ';

        // Creates dynamic where clause
        String whereClause = ' WHERE ' + keywordWhereClause +
            (String.isNotBlank(sInfo.Where_Clause__c) ? ' AND ' + sInfo.Where_Clause__c + DdConstants.DELIMITER_SPACE : DdConstants.BLANK_STRING) +
            (excludeItemsSet.isEmpty() ? DdConstants.BLANK_STRING : ' AND ' + sInfo.Exclude_Field_Name__c + ' NOT IN :excludeItemsSet ');

        // Creates dynamic query
        String query = 'SELECT ' + sInfo.Select__c +
            ' FROM ' + sInfo.From__c + whereClause +
            (String.isNotBlank(sInfo.Group_By__c) ? ' GROUP BY ' + sInfo.Group_By__c + DdConstants.DELIMITER_SPACE : DdConstants.BLANK_STRING) +
            (String.isNotBlank(sInfo.Order_By__c) ? ' ORDER BY ' + sInfo.Order_By__c + DdConstants.DELIMITER_SPACE : DdConstants.BLANK_STRING) +
            (sInfo.Limit__c != null ? ' LIMIT ' + Integer.valueOf(sInfo.Limit__c) : DdConstants.BLANK_STRING);

        // Run Aggregate query and parse the result
        // Note that this does have merge capabilities like fetchLookupResultObjectRecords
        for (AggregateResult agg: Database.query(query)) {
            MultiSelectPicklistWrapper w = new MultiSelectPicklistWrapper();
            w.value = (String)agg.get(sInfo.Value_Merge_Format__c);
            w.dropDownLabel = (String)agg.get(sInfo.Dropdown_Label_Merge_Format__c);
            w.pillLabel = (String)agg.get(sInfo.Pill_Label_Merge_Format__c);
            if (String.isNotBlank(sInfo.Dropdown_SubLabel_Merge_Format__c)) {
                w.dropDownSubLabel = String.valueOf(agg.get(sInfo.Dropdown_SubLabel_Merge_Format__c));
            }
            if (String.isNotBlank(sInfo.IconSrc_Merge_Format__c)) {
                w.iconSrc = sInfo.IconSrc_Merge_Format__c;
            }
            retVal.add(w);
        }

        return retVal;
    }

    /**
     * @description Method which does SOSL text search
     * @param searchKeyword - Word to use as a search param
     * @param sInfo - CMT used to know how to retreive data
     * @param sInfoSOSL - each mdt has the object,info of fields etc to formualate SOSL query
     * @param excludeItemsSet - Items to exclude from search
     * @return List<MultiSelectPicklistWrapper> - Resultant Data in wrapper
     */
    private static List<MultiSelectPicklistWrapper> fetchLookupResultSOSL(String searchKeyword,
            DD_Multi_Select_Picklist_Master__mdt sInfo, List<DD_Multi_Select_Picklist_SOSL_Return__mdt> sInfoSOSL,
            Set<String> excludeItemsSet) {

        List<MultiSelectPicklistWrapper> retVal = new List<MultiSelectPicklistWrapper>();

        if (String.isBlank(searchKeyword) || sInfoSOSL == null || sInfoSOSL.isEmpty()) {
            return new List<MultiSelectPicklistWrapper>();
        }
        searchKeyword = DdUtilitiesService.sanitizeStringSOSL(searchKeyword.trim()) + '*';

        // Create base SOSL string from keyword and returning field (ALL fields, Name Fields, etc.)
        String sosl = 'Find {' + searchKeyword + '} in ' + sInfo.SOSL_Returning_Fields__c + ' RETURNING ';

        Map<String,DD_Multi_Select_Picklist_SOSL_Return__mdt> soslDefnMap = new Map<String,DD_Multi_Select_Picklist_SOSL_Return__mdt> ();

        // Iterate thru the sInfoSOSL to formulate the per object SOSL
        for (DD_Multi_Select_Picklist_SOSL_Return__mdt soslDefn : sInfoSOSL) {
            // Object needs to be accessible to the current users profile to perform this (Checking object access only, not FLS)
            // Helps with especially securing guest profile from accessing stuff in without sharing mode.
            if (!DdUtilitiesService.objectIsAccessible(soslDefn.SObject_Name__c)) {
                continue;
            }

            // Create dynamic where clause
            String whereClause = DdConstants.BLANK_STRING;
            if (String.isNotBlank(soslDefn.Where_Clause__c)) {
                whereClause += ' WHERE ' + soslDefn.Where_Clause__c + DdConstants.DELIMITER_SPACE;
            }

            if (String.isNotBlank(soslDefn.Exclude_Field_Name__c) && !excludeItemsSet.isEmpty()) {
                whereClause = whereClause + (String.isBlank(whereClause) ? ' WHERE ' : ' AND ') +
                     + soslDefn.Exclude_Field_Name__c + ' NOT IN :excludeItemsSet ';
            }

            // Create dynamic SOSL query string
            sosl += soslDefn.SObject_Name__c +
                ' (' + soslDefn.Return_Fields__c + whereClause +
                     (String.isNotBlank(soslDefn.Order_By__c) ?
                            ' ORDER BY ' + soslDefn.Order_By__c + DdConstants.DELIMITER_SPACE : DdConstants.BLANK_STRING) +
                     (soslDefn.Limit__c != null ? ' LIMIT ' +
                        Integer.valueOf(soslDefn.Limit__c) : DdConstants.BLANK_STRING) +
                ' ), ';

            soslDefnMap.put(soslDefn.SObject_Name__c,soslDefn);
        }

        if (soslDefnMap.isEmpty()) {
            return retVal;
        }

        sosl = sosl.trim().removeEndIgnoreCase( DdConstants.DELIMITER_COMMA);

        // Execute SOSL and create result list
        List<List<SObject>> searchResultsList = search.query(sosl);
        for (List<SObject> searchResults : searchResultsList) {
            for (SObject searchResult : searchResults) {
                DD_Multi_Select_Picklist_SOSL_Return__mdt soslDefn =
                    soslDefnMap.get(searchResult.getSObjectType().getDescribe().getName());

                retVal.add(createWrapperForSobject(searchResult,soslDefn));
            }
        }
        return retVal;
    }

    /**
     * @description Method which returns picklist metadata
     * @param searchKeyword - Word to use as a search param
     * @param sInfo - CMT used to know how to retreive data
     * @param excludeItemsSet - Items to exclude from search
     * @return List<MultiSelectPicklistWrapper> - Resultant Data in wrapper
     */
    private static List<MultiSelectPicklistWrapper> fetchLookupResultFieldPicklist(String searchKeyword,
            DD_Multi_Select_Picklist_Master__mdt sInfo,Set<String> excludeItemsSet) {

        //Gets picklist values
        Map<String, List<PicklistUtil.PicklistOption>> pickOpts =
            PicklistUtil.getPicklistOptions(sInfo.Picklist_Metadata_Object_name__c, sInfo.Picklist_Metadata_Field_Name__c);

        List<MultiSelectPicklistWrapper> retVal = new List<MultiSelectPicklistWrapper>();

        List<MultiSelectPicklistWrapperSorter> sorter = new List<MultiSelectPicklistWrapperSorter>();

        if (!pickOpts.isEmpty() && pickOpts.containsKey(sInfo.Picklist_Metadata_Field_Name__c)) {
            // Custom formatting is available {Label + Value} etc
            String format = String.isBlank(sInfo.Picklist_Metadata_Search_Label_Format__c) ?
                '{Label}' : sInfo.Picklist_Metadata_Search_Label_Format__c;

            for (PicklistUtil.PicklistOption option : pickOpts.get(sInfo.Picklist_Metadata_Field_Name__c)) {
                if (excludeItemsSet.contains(option.value)) {
                    continue;
                }
                // Create Wrapper
                MultiSelectPicklistWrapper w = new MultiSelectPicklistWrapper();
                w.value = option.value;
                String label = option.label;
                if (format == '{Value} - {Label}') {
                    label = option.value + ' - ' + option.label;
                }

                w.dropDownLabel = label;
                w.pillLabel = label;

                if (String.isNotBlank(sInfo.IconSrc_Merge_Format__c)) {
                    w.iconSrc = sInfo.IconSrc_Merge_Format__c;
                }

                // Usually, you will use the sort order as given in the picklist metadata
                // But custom sort can also be done by proving the 'Force Sort' option
                if (String.isNotBlank(sInfo.Picklist_Metadata_Force_Sort_By__c)) {
                    sorter.add(new MultiSelectPicklistWrapperSorter(w,sInfo.Picklist_Metadata_Force_Sort_By__c));
                } else {
                    retVal.add(w);
                }
            }
        }
        // If Custom Sort is needed, perform the sort
        if (String.isNotBlank(sInfo.Picklist_Metadata_Force_Sort_By__c)) {
            sorter.sort();

            for (MultiSelectPicklistWrapperSorter s : sorter) {
                retVal.add(s.w);
            }
        }
        return retVal;
    }

    /**
     * @description Static values can be provided as child records to the main sInfo CMT in DD_Multi_Select_Picklist_Search_Value__mdt object.
     * @param searchKeyword - Word to use as a search param
     * @param sInfo - CMT used to know how to retreive data
     * @param excludeItemsSet - Items to exclude from search
     * @return List<MultiSelectPicklistWrapper> - Resultant Data in wrapper
     */
    private static List<MultiSelectPicklistWrapper> fetchLookupResultStaticValues(String searchKeyword,
            DD_Multi_Select_Picklist_Master__mdt sInfo,Set<String> excludeItemsSet) {
        List<MultiSelectPicklistWrapper> retVal = new List<MultiSelectPicklistWrapper>();

        // Search in DD_Multi_Select_Picklist_Search_Value__mdt for the child static values and create result set.
        for (DD_Multi_Select_Picklist_Search_Value__mdt val :
                [SELECT Dropdown_Label__c,Dropdown_SubLabel__c,
                        Pill_Label__c,Value__c,Parent__c,Display_Sequence__c
                   FROM DD_Multi_Select_Picklist_Search_Value__mdt
                  WHERE Parent__c = :sInfo.Id
                    AND Value__c NOT IN :excludeItemsSet
               ORDER BY Display_Sequence__c asc]) {
            MultiSelectPicklistWrapper w = new MultiSelectPicklistWrapper();
            w.value = val.Value__c;
            w.dropDownLabel = val.Dropdown_Label__c;
            w.pillLabel = val.Pill_Label__c;
            if (String.isNotBlank(val.Dropdown_SubLabel__c)) {
                w.dropDownSubLabel = val.Dropdown_SubLabel__c;
            }
            retVal.add(w);
        }
        return retVal;
    }

    /**
     * @description Custom search is an option wherein a standard soql/sosl etc will not meet the requirement and you need to implement custom logic in Apex.
     *             Using this technique of interface means that one never needs to touch this code, but simply implement a class implementing the
     *             IMultiSelectPicklistSearchInterface interface (Example: CDdMultiSelectPicklistCustomExample)
     * @param searchKeyword - Word to use as a search param
     * @param sInfo - CMT used to know how to retreive data
     * @param excludeItemsSet - Items to exclude from search
     * @param arguments - JSON string form of Map<String,Object>;
     *                             This is used for the custom search type, to pass to the handling apex class
     * @return List<MultiSelectPicklistWrapper> - Resultant Data in wrapper
     */
    private static List<MultiSelectPicklistWrapper> fetchLookupResultCustomSearch(String searchKeyword,
            DD_Multi_Select_Picklist_Master__mdt sInfo,Set<String> excludeItemsSet, String arguments) {

        Type iType = null;
        IMultiSelectPicklistSearchInterface iClass = null;
        List<MultiSelectPicklistWrapper> retVal =new List<MultiSelectPicklistWrapper>();

        // Unpack the arguments
        Map<String,Object> args = String.isBlank(arguments) ?
            new Map<String,Object>() : (Map<String, Object>)JSON.deserializeUntyped(arguments);

        // Call the Apex class via the interface
        try {
            iType = Type.forName(sInfo.ApexClassName__c);
        } catch (Exception unitOfWorkException) {
            //set the static error message so that we can search by Id in Scalayr
            unitOfWorkException.setMessage(unitOfWorkException.getMessage());

            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                    LOG_MULTI_SELECT_HELPER,LOG_FETCH_LOOKUP_RESULT_SEARCH,GenericLogEntry.SeverityLevel.MEDIUM
                ).logException(unitOfWorkException)
            );
        }
        try {
            iClass = (IMultiSelectPicklistSearchInterface) iType.newInstance();
            retVal = iClass.getData(searchKeyword,sInfo,excludeItemsSet,args);
        } catch (Exception unitOfWorkException) {
            //set the static error message so that we can search by Id in Scalayr
            unitOfWorkException.setMessage(unitOfWorkException.getMessage());

            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                    LOG_MULTI_SELECT_HELPER,LOG_FETCH_LOOKUP_RESULT_SEARCH,GenericLogEntry.SeverityLevel.MEDIUM
                ).logException(unitOfWorkException)
            );
        }
        return retVal;
    }

    /**
     * @description If we dont want to show the data in the dropdown which user has already selected, it will be passed here and we process it.
     * @param excludeItems - JSON string form of List<MultiSelectPicklistWrapper>;
     *                                This has list of already selected records in the UI, so that it can be ignored for current search
     *
     * @return  List<String> - Resultant Data to ignore
     */
    public static Set<String> getItemsToExclude(String excludeItems) {
        // Deserialize the exclude Items and simply add 'value' variable to the returned set.
        List<MultiSelectPicklistWrapper> excludeItemsList = String.isNotBlank(excludeItems) ?
            (List<MultiSelectPicklistWrapper>)JSON.deserialize(excludeItems,List<MultiSelectPicklistWrapper>.class) :
            new List<MultiSelectPicklistWrapper>();

        Set<String> itemsToExclude = new Set<String>();
        if (excludeItemsList == null || excludeItemsList.isEmpty()) {
            return itemsToExclude;
        }

        for (MultiSelectPicklistWrapper item : excludeItemsList){
            itemsToExclude.add(item.value);
        }

        return itemsToExclude;
    }
}