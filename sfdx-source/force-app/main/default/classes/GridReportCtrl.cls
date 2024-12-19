/**
 * @author CriticalRiver
 * @date Sept 20, 2024
 * @description Controller for lwcDdGridReport Lightning Web Component
 */
public without sharing class GridReportCtrl {

    public static final String ERROR_MSG = 'There was an error fetching the report data and the error has been logged. Please contact your system administrator for assistance.';
    public static final String LOG_GRID_REPORT_GET_DATA = 'Grid Report';
    public static final String LOG_GET_DATA = 'Get Data From Figment';
    public static final String LOG_RECORD_ID = 'Get Actual Data From from Record Id';

	/*****************************************************************************************************************************
	 *
	 * Public Methods
	 *
	 *****************************************************************************************************************************/
	/**
	 * @description Returns the CMT with the Grid Report Detail
	 * @param reportName - Developer name of DD_Grid_Report_Master__mdt
	 * @return DD_Grid_Report_Master__mdt
	 */

	@AuraEnabled(cacheable=true)
	public static DD_Grid_Report_Master__mdt getReportDefinition(String reportName){
        return GridReportCustomMetadataSelector.newInstance().getReportDefinition(reportName);
	}

	/**
	 * @description Send a list of upto 50k record ids to the UI, UI can call later to get the actual data
	 * @param apexClass - Name of the apex class implementing the IGridReportInterface, which will process the filter config and return the ids
	 * @param filterConfig - JSON of the filter values and configuration
	 * @param sortConfig - JSON of the sort config for the fields values
	 * @return GridReportHelper.GridReportRecordIdWrapper - Wrapper Storing record Ids
	 */
	@AuraEnabled
	public static GridReportHelper.GridReportRecordIdWrapper getRecordIds(String apexClass,String filterConfig,String sortConfig) {
        GridReportHelper.GridReportRecordIdWrapper retVal = new GridReportHelper.GridReportRecordIdWrapper();

		if (String.isBlank(apexClass) || String.isBlank(filterConfig)) {
			return retVal;
		}

		try {
            retVal = FigmentIntegrationService.getRecordIdsForGridReport(apexClass, filterConfig, sortConfig);
		} catch (Exception unitOfWorkException) {
			//set the static error message so that we can search by Id in Scalayr
            unitOfWorkException.setMessage(unitOfWorkException.getMessage());

            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                    LOG_GRID_REPORT_GET_DATA,LOG_RECORD_ID,GenericLogEntry.SeverityLevel.MEDIUM
                ).logException(unitOfWorkException)
            );
            throw new AuraHandledException(ERROR_MSG);
		}
		return retVal;
	}

	/**
	 * @description Send a list of upto 50k record ids to the UI, UI can call later to get the actual data
	 * @param apexClass - Name of the apex class implementing the IGridReportInterface, which will process the filter config and return the ids
	 * @param recordIds - Ids to fetch data for
	 * @return String - JSON string with data to return back to the Grid. The JSON string can be created from List<sObject>/List<Map<String,Object>>/List<Custom Wrapper>.
	 */
	@AuraEnabled
	public static String getData(String apexClass,List<Id> recordIds) {
		String retval = '[]';

		// Call the Apex class via the interface
		try {
            retVal = FigmentIntegrationService.getDataForGridReport(apexClass, recordIds);
		} catch (Exception unitOfWorkException) {
             //set the static error message so that we can search by Id in Scalayr
            unitOfWorkException.setMessage(ERROR_MSG);

            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                    LOG_GRID_REPORT_GET_DATA,LOG_GET_DATA,GenericLogEntry.SeverityLevel.MEDIUM
                ).logException(unitOfWorkException)
            );
            throw new AuraHandledException(ERROR_MSG);
		}
		return retVal;
	}

	/**
	 * @description Provides a list of DD Grid Report Saved Search for a particular DD Grid Report
	 * @param reportName - Name of the DD Grid Report for which Saved Search records need to be retrieved
	 * @return List<DD_Grid_Report_Saved_Search__c> Returns a list of DD Grid Report Saved Search
	 */
	@AuraEnabled(cacheable=true)
	public static List<DD_Grid_Report_Saved_Search__c> getDDGridReportSavedSearchForCurrentUser(String reportName){
		return GridReportSavedSearchSelector.newInstance().getDDGridReportSavedSearchForReportByUser(UserInfo.getUserId(), reportName);
	}
}