/**
 * @author CriticalRiver
 * @date   Sept, 20 2024
 * @description Interface for fetch Saved Grid Report Filter
 */
public interface IGridReportSavedSearchSelector extends fflib_ISObjectSelector {
	/**
	* @description Provides a list of DD Grid Report Saved Search for a particular DD Grid Report
	* @param userId - Id of the user to get the saved searches for
	* @param reportName - Name of the DD Grid Report for which Saved Search records need to be retrieved
	* @return  List<DD_Grid_Report_Saved_Search__c> Returns a list of DD Grid Report Saved Search
	*/
	List<DD_Grid_Report_Saved_Search__c> getDDGridReportSavedSearchForReportByUser(Id userId,String reportName);
}