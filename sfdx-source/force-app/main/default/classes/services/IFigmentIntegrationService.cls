/**
 * @author CriticalRiver
 * @date   Sept 2024
 * @description Interface for querying data from Figment
 */
public interface IFigmentIntegrationService {

    /**
     * @description Get Record Ids for Grid Report Framework
     * @jira https://doordash.atlassian.net/browse/BSSF-993
     * @param apexClass - Name of the apex class implementing the IGridReportInterface
     * @param filterConfig - JSON of the filter values and configuration
     * @param sortConfig - JSON of the sorting configuration
     * @return GridReportHelper.GridReportRecordIdWrapper - Wrapper Storing record Ids
     */
    GridReportHelper.GridReportRecordIdWrapper getRecordIdsForGridReport(String apexClass, String filterConfig, String sortConfig);

    /**
     * @description Get Case Data for Grid Report Framework
     * @jira https://doordash.atlassian.net/browse/BSSF-993
     * @param apexClass - Name of the apex class implementing the IGridReportInterface
     * @param recordIds - Set of Figment Case Ids
     * @return String - record data serialized into String
     */
    String getDataForGridReport(String apexClass, List<Id> recordIds);
}