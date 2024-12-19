/**
 * @author CriticalRiver
 * @date   Sept, 20 2024
 * @description Class for fetch Saved Grid Report Filter
 */
public inherited sharing class GridReportSavedSearchSelector extends fflib_SObjectSelector implements IGridReportSavedSearchSelector {
	/**
	* @description default constructor for the Grid Report Saved Search Selector
	* @return  - interface of IGridReportSavedSearchSelector
	*/
	public static IGridReportSavedSearchSelector newInstance() {
		return (IGridReportSavedSearchSelector) Application.Selector.newInstance(DD_Grid_Report_Saved_Search__c.SObjectType);
	}

	/**
	* @description This method is for getting the fields on this object
	* @return List of Schema.SObjectField
	*/
	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField>{
			DD_Grid_Report_Saved_Search__c.Id,
			DD_Grid_Report_Saved_Search__c.Name,
			DD_Grid_Report_Saved_Search__c.Report_Name__c,
			DD_Grid_Report_Saved_Search__c.Type__c,
			DD_Grid_Report_Saved_Search__c.Config__c
		};
	}

	/**
	* @description This method is used for getting Object type
	* @return Schema.SObjectType
	*/
	public Schema.SObjectType getSObjectType() {
		return DD_Grid_Report_Saved_Search__c.SObjectType;
	}

	/**
	* @description Provides a list of DD Grid Report Saved Search for a particular DD Grid Report
	* @param userId - Id of the user to get the saved searches for
	* @param reportName - Name of the DD Grid Report for which Saved Search records need to be retrieved
	* @return  List<DD_Grid_Report_Saved_Search__c> Returns a list of DD Grid Report Saved Search
	*/
	public List<DD_Grid_Report_Saved_Search__c> getDDGridReportSavedSearchForReportByUser(Id userId,String reportName){
		fflib_QueryFactory query = newQueryFactory()
			.selectFields(new Set<String>{'Owner.Name'})
			.setCondition('OwnerId = :userId AND Report_Name__c = :reportName');
		return (List<DD_Grid_Report_Saved_Search__c>) Database.query(query.toSOQL());
	}
}