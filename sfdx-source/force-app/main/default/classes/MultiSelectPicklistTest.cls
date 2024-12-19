/**
 * @author Critical River
 * @date Sept 2024
 * @description Test class for the ddMultiSelectPicklist component and framework
 */

@IsTest
public without sharing class MultiSelectPicklistTest {
    /**
     * Begin - Test class to execute if one of these classes is updated
     */
    private static List<System.Type> classReference = new List<System.Type>{
        MultiSelectPicklistHelper.class,
        MultiSelectPicklistCtrl.class,
        MultiSelectPicklistWithoutSharingUtil.class,
        MultiSelectPicklistWrapperSorter.class
    };

    @IsTest
    public static void testWhenObjectRecordsThenValid() {
        MultiSelectPicklistCtrl.InitWrapper initWrapper = MultiSelectPicklistCtrl.getSearchInfo('Example_Object_Records');
        system.assert(initWrapper.searchInfo.Query_and_Cache_on_Init__c == false,'Example_Object_Records Query and Cache on Init is incorrect');

        List<MultiSelectPicklistWrapper> recordIdsToIgnore = new List<MultiSelectPicklistWrapper>();
        List<User> users = [SELECT Id,Name FROM User WHERE Name LIKE 'John%' and isActive = true LIMIT 1];
        if (!users.isEmpty()) {
            recordIdsToIgnore.add(createTestWrapper(users[0].Id,users[0].Name));
        }

        MultiSelectPicklistValuesWrapper valuesWrapper = MultiSelectPicklistCtrl.getLookupResultBySearchInfo(
            'John',
            JSON.serialize(recordIdsToIgnore),
            null,
            initWrapper.searchInfo,
            initWrapper.searchInfo.DD_Multi_Select_Picklist_SOSL_Return__r == null ?
                new List<DD_Multi_Select_Picklist_SOSL_Return__mdt>() : initWrapper.searchInfo.DD_Multi_Select_Picklist_SOSL_Return__r
        );

        system.assertEquals(valuesWrapper.keyWord,'John','Invalid keyword');
        for (MultiSelectPicklistWrapper value : valuesWrapper.values) {
            if (!users.isEmpty()) {
                system.assertNotEquals(value.value,users[0].Id,'Example_Object_Records exclude record did not work');
            }
            system.assert(value.pillLabel.containsIgnoreCase('john'),'Did not find keyword in return value');
        }
    }

    @IsTest
    public static void testWhenAggregateQueryThenIsSuccess() {
        MultiSelectPicklistCtrl.InitWrapper initWrapper = MultiSelectPicklistCtrl.getSearchInfo('Example_Aggregate_Query');
        system.assert(initWrapper.searchInfo.Query_and_Cache_on_Init__c == true,'Example_Aggregate_Query Query and Cache on Init is incorrect');
        system.assert(!initWrapper.lookupResults.isEmpty(),'Example_Aggregate_Query lookupResult is empty');
    }

    @IsTest
    public static void testWhenSOSLThenIsSuccess() {
        MultiSelectPicklistCtrl.InitWrapper initWrapper = MultiSelectPicklistCtrl.getSearchInfo('Example_SOSL');
        system.assert(initWrapper.searchInfo.Query_and_Cache_on_Init__c == false,'Example_SOSL Query and Cache on Init is incorrect');
        List<DD_Multi_Select_Picklist_SOSL_Return__mdt> soslMdt = initWrapper.searchInfo.DD_Multi_Select_Picklist_SOSL_Return__r;
        system.assert(soslMdt != null && !soslMdt.isEmpty(),'Example_SOSL Did not have sosl cmt records');

        List<MultiSelectPicklistWrapper> recordIdsToIgnore = new List<MultiSelectPicklistWrapper>();
        List<User> users = [SELECT Id,Name FROM User WHERE Name LIKE 'John%' and isActive = true LIMIT 2];
        List<Id> fixedSearchResults = new List<Id>();
        if (!users.isEmpty()) {
            recordIdsToIgnore.add(createTestWrapper(users[0].Id,users[0].Name));

            if (users.size() == 2) {
                fixedSearchResults.add(users[1].Id);
            }
        }
        Test.setFixedSearchResults( fixedSearchResults );

        MultiSelectPicklistValuesWrapper valuesWrapper = MultiSelectPicklistCtrl.getLookupResultBySearchInfo(
            'John',
            JSON.serialize(recordIdsToIgnore),
            null,
            initWrapper.searchInfo,
            initWrapper.searchInfo.DD_Multi_Select_Picklist_SOSL_Return__r
        );

        system.assertEquals(valuesWrapper.keyWord,'John','Invalid keyword');
    }

    @IsTest
    public static void testWhenPicklistMetadataThenIsValid() {
        MultiSelectPicklistCtrl.InitWrapper initWrapper = MultiSelectPicklistCtrl.getSearchInfo('Example_Object_Picklist');
        system.assert(initWrapper.searchInfo.Query_and_Cache_on_Init__c == true,'Example_Object_Picklist Query and Cache on Init is incorrect');
        system.assert(!initWrapper.lookupResults.isEmpty(),'Example_Object_Picklist Lookupresult is empty');
    }

    @IsTest
    public static void testWhenStaticValuesThenCorrect() {
        MultiSelectPicklistCtrl.InitWrapper initWrapper = MultiSelectPicklistCtrl.getSearchInfo('Example_Filter_Static_Values');
        system.assert(initWrapper.searchInfo.Query_and_Cache_on_Init__c == true,'Example_Filter_Static_Values Query and Cache on Init is incorrect');
        system.assert(!initWrapper.lookupResults.isEmpty(),'Example_Filter_Static_Values Lookupresult is empty');
    }

    @IsTest
    public static void testWhenCustomSearchThenIsSuccess() {
        MultiSelectPicklistCtrl.InitWrapper initWrapper = MultiSelectPicklistCtrl.getSearchInfo('Example_Custom_Search');
        system.assert(initWrapper.searchInfo.Query_and_Cache_on_Init__c == false,'Example_Custom_Search Query and Cache on Init is incorrect');

        Map<String,Object> arguments = new Map<String,Object> {
            'IsActive' => 'true'
        };

        MultiSelectPicklistValuesWrapper valuesWrapper = MultiSelectPicklistCtrl.getLookupResultBySearchInfo(
            'John',
            DdConstants.BLANK_STRING,
            JSON.serialize(arguments),
            initWrapper.searchInfo,
            initWrapper.searchInfo.DD_Multi_Select_Picklist_SOSL_Return__r == null ?
                new List<DD_Multi_Select_Picklist_SOSL_Return__mdt>() : initWrapper.searchInfo.DD_Multi_Select_Picklist_SOSL_Return__r
        );

        system.assertEquals(valuesWrapper.keyWord,'John','Invalid keyword');
    }

    @isTest
    public static void testWhenLookupResultThenIsCorrect() {
        MultiSelectPicklistValuesWrapper valuesWrapper = new MultiSelectPicklistValuesWrapper();
        valuesWrapper = MultiSelectPicklistCtrl.getLookupResult(
            'John', '[]', null, 'Example_Object_Records');
        system.assertEquals(valuesWrapper.keyWord,'John','Invalid keyword');
    }

    @isTest
    public static void testWhenIncreaseThenCodeCoverage() {

        List<MultiSelectPicklistWrapper> toSort = new List<MultiSelectPicklistWrapper>();
        toSort.add(createTestWrapper('1'));
        toSort.add(createTestWrapper('3'));
        toSort.add(createTestWrapper('0'));
        toSort.add(createTestWrapper('2'));
        toSort.add(createTestWrapper('4'));

        List<MultiSelectPicklistWrapperSorter> dropdownLabelSorter = new List<MultiSelectPicklistWrapperSorter>();
        List<MultiSelectPicklistWrapperSorter> valueSorter = new List<MultiSelectPicklistWrapperSorter>();
        for (MultiSelectPicklistWrapper wrapper : toSort) {
            dropdownLabelSorter.add(new MultiSelectPicklistWrapperSorter(wrapper));
            valueSorter.add(new MultiSelectPicklistWrapperSorter(wrapper,'value'));
        }

        dropdownLabelSorter.sort();
        valueSorter.sort();
        for (Integer i = 0; i<5; i++) {
            Assert.areEqual(String.valueOf(i), valueSorter[i].w.value,'Values are not sorted correctly.');
        }
    }

    private static MultiSelectPicklistWrapper createTestWrapper(String value) {
        return createTestWrapper(value,value);
    }

    private static MultiSelectPicklistWrapper createTestWrapper(String value,String label) {
        MultiSelectPicklistWrapper wrapper = new MultiSelectPicklistWrapper();
        wrapper.dropDownLabel = label;
        wrapper.pillLabel = label;
        wrapper.value = value;
        return wrapper;
    }
}