/**
 * @author CriticlRiver
 * @date Sept 2024
 * @description Test class for the lwcDdGridReport component and framework. Note that this class is purely to makes sure code coverage exists.
 *              Project specific grid report helper classes (example MxpUserReportHelper) should have its own test classes (example MxpUserReportHelperTest)
 *              which takes care of ensuring that the query formed by the GridReportHelper class is accurate and error free.
 */

 @isTest
public without sharing class GridReportTest {

	/**
	 * Begin - Test class to execute if one of these classes is updated
	 */
	private static List<System.Type> classReference = new List<System.Type>{
		GridReportCtrl.class,
		GridReportFilterWrapper.class,
		GridReportHelper.class,
		GridReportSortWrapper.class
	};

	@isTest
	public static void testWhenIncreaseThenCodeCoverage() {
		GridReportCtrl.getRecordIds(null, '[]', null);

		try {
			GridReportCtrl.getData(null, new List<Id>());
			System.assert(false,'Should not come here');
		} catch (AuraHandledException ex) {
			System.assert(true,'Should come here');
		}

		try {
			GridReportCtrl.getRecordIds('ThisDoesNotExist', '[]', null);
			System.assert(false,'Should not come here');
		} catch (AuraHandledException ex) {
			System.assert(true,'Should come here');
		}

		try {
			GridReportCtrl.getData('ThisDoesNotExist', new List<Id>());
			System.assert(false,'Should not come here');
		} catch (AuraHandledException ex) {
			System.assert(true,'Should come here');
		}
		DD_Grid_Report_Filter__mdt testRecord = new DD_Grid_Report_Filter__mdt();

		GridReportFilterWrapper filterWrapper = new GridReportFilterWrapper();
		filterWrapper.name = 'IncCodeCoverage';
        filterWrapper.definition = testRecord;
        filterWrapper.value = null;
		GridReportSortWrapper sortWrapper = new GridReportSortWrapper();
		sortWrapper.sortedBy = 'CreatedDate';
	}

	@IsTest
	public static void testWhenGetReportDefinitionThenValid(){
		String reportName = 'TestClass';
		DD_Grid_Report_Master__mdt reportMaster = (DD_Grid_Report_Master__mdt)new Fake(DD_Grid_Report_Master__mdt.class)
			.setField(DD_Grid_Report_Master__mdt.Id , Fake.generateId(DD_Grid_Report_Master__mdt.SObjectType))
			.setField(DD_Grid_Report_Master__mdt.Label, reportName)
			.setField(DD_Grid_Report_Master__mdt.Apex_Class__c, reportName)
			.setField(DD_Grid_Report_Master__mdt.DeveloperName, reportName)
			.toSObject();

		// create an instance of fflib_ApexMocks class part of apex mock framework.
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		// create an instance of fflib_SObjectUnitOfWork class part of apex mock framework.
		IGridReportCustomMetadataSelector gridReportMasterSelector = (IGridReportCustomMetadataSelector) mocks.mock(
			IGridReportCustomMetadataSelector.class
		);

		mocks.startStubbing();
		mocks.when(gridReportMasterSelector.sObjectType()).thenReturn(DD_Grid_Report_Master__mdt.SObjectType);
		mocks.when(gridReportMasterSelector.getReportDefinition(reportName)).thenReturn(reportMaster);
		mocks.stopStubbing();

		Application.SELECTOR.setMock(gridReportMasterSelector);

		DD_Grid_Report_Master__mdt expectedReportMaster = GridReportCtrl.getReportDefinition(reportName);
		Assert.areEqual(expectedReportMaster.Id, reportMaster.Id, 'Report Master Id is not same as expected.');
	}

	private static MultiSelectPicklistWrapper getMultiSelectWrapper(String value,String operator) {
		MultiSelectPicklistWrapper wrapper = new MultiSelectPicklistWrapper();
		wrapper.value = value;
		wrapper.pillLabel = value;
		wrapper.dropDownLabel = value;
		wrapper.operator = operator;
		return wrapper;
	}

	@isTest
	public static void testWhenGetDDGridReportSavedSearchForCurrentUserThenSavedFilters() {
		String reportName = 'MXP_User_Report';

		List<DD_Grid_Report_Saved_Search__c> savedSearch = new List<DD_Grid_Report_Saved_Search__c>{
			(DD_Grid_Report_Saved_Search__c) new Fake(DD_Grid_Report_Saved_Search__c.class)
				.setField(DD_Grid_Report_Saved_Search__c.Id , Fake.generateId(DD_Grid_Report_Saved_Search__c.SObjectType))
				.setField(DD_Grid_Report_Saved_Search__c.Report_Name__c,reportName)
				.setField(DD_Grid_Report_Saved_Search__c.Config__c , 'Test Config')
				.setField(DD_Grid_Report_Saved_Search__c.Name, 'Test Save Search')
				.setField(DD_Grid_Report_Saved_Search__c.OwnerId, UserInfo.getUserId())
				.toSObject()
		};

		// create an instance of fflib_ApexMocks class part of apex mock framework.
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		// create an instance of fflib_SObjectUnitOfWork class part of apex mock framework.
		IGridReportSavedSearchSelector savedSearchSelector = (IGridReportSavedSearchSelector) mocks.mock(
			IGridReportSavedSearchSelector.class
		);

		mocks.startStubbing();
		mocks.when(savedSearchSelector.sObjectType()).thenReturn(DD_Grid_Report_Saved_Search__c.SObjectType);
		mocks.when(savedSearchSelector.getDDGridReportSavedSearchForReportByUser(UserInfo.getUserId(), reportName)).thenReturn(savedSearch);
		mocks.stopStubbing();

		Application.SELECTOR.setMock(savedSearchSelector);

		List<DD_Grid_Report_Saved_Search__c> expectedSaveSearch = GridReportCtrl.getDDGridReportSavedSearchForCurrentUser(reportName);
		Assert.areEqual(1, expectedSaveSearch.size(), 'Number of Save Search records are not same as expected.');
		Assert.areEqual(expectedSaveSearch[0].Id, savedSearch[0].Id, 'Save Search record Id is not same as expected.');
	}

	@isTest
    public static void testWhenGridReportRecordIdWrapperThenIncreaseCodeCoverage(){
        List<SObject> testList = new List<SObject>();
        GridReportHelper.GridReportRecordIdWrapper retVal = new GridReportHelper.GridReportRecordIdWrapper(0,testList);
        Assert.areEqual(0, retVal.count, 'Count Should be set to 0');
        GridReportSortWrapper gridReWrap = new GridReportSortWrapper();
        gridReWrap.sortDirection = 'Test';
        gridReWrap.sortNulls = 'Test';
        Assert.areEqual('Test', gridReWrap.sortDirection, 'Sort direct should match');
    }

    @isTest
    public static void testWhenNumberFilterWrapperThenIncreaseCoverage(){
        //Variable Initialization
        NumberFilterWrapper testNumberFilter = new NumberFilterWrapper();
        testNumberFilter.maxValue = 100;
        testNumberFilter.minValue = 0;
        testNumberFilter.value = 10;
        testNumberFilter.operator = 'Test';
        Assert.areEqual('Test', testNumberFilter.operator, 'Operator should match');
    }

    @isTest
    public static void testWhenDateFilterWrapperThenIncreaseCoverage(){
        //Variable Initialization
        DateFilterWrapper testDateFilter = new DateFilterWrapper();
        testDateFilter.minValue = System.today();
        testDateFilter.maxValue = System.today();
        testDateFilter.value = System.today();
        testDateFilter.operator = 'Test';
        Assert.areEqual('Test', testDateFilter.operator, 'Operator should match');
    }

	private static NumberFilterWrapper getNumberFilterWrapper(Decimal value,String operator) {
		NumberFilterWrapper wrapper = new NumberFilterWrapper();
		wrapper.value = value;
		wrapper.operator = operator;
		return wrapper;
	}

	private static NumberFilterWrapper getNumberFilterWrapper(Decimal minValue,Decimal maxValue) {
		NumberFilterWrapper wrapper = new NumberFilterWrapper();
		wrapper.minValue = minValue;
		wrapper.maxValue = maxValue;
		wrapper.operator = 'BETWEEN';
		return wrapper;
	}

	private static DateFilterWrapper getDateFilterWrapper(Datetime value,String operator) {
		DateFilterWrapper wrapper = new DateFilterWrapper();
		wrapper.value = value;
		wrapper.operator = operator;
		return wrapper;
	}

	private static DateFilterWrapper getDateFilterWrapper(Datetime minValue,Datetime maxValue) {
		DateFilterWrapper wrapper = new DateFilterWrapper();
		wrapper.minValue = minValue;
		wrapper.maxValue = maxValue;
		wrapper.operator = 'BETWEEN';
		return wrapper;
	}
}