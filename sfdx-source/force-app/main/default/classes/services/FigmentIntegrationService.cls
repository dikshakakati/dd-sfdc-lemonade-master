/**
 * @author CriticalRiver
 * @date   Sept 2024
 * @description Service for querying data from Figment
 */
public class FigmentIntegrationService {

    private static IFigmentIntegrationService service() {
        return (IFigmentIntegrationService) Application.SERVICE.newInstance(IFigmentIntegrationService.class);
    }

    /**
     * @description Get Record Ids for Grid Report Framework
     * @jira https://doordash.atlassian.net/browse/BSSF-993
     * @param apexClass - Name of the apex class implementing the IGridReportInterface
     * @param filterConfig - JSON of the filter values and configuration
     * @param sortConfig - JSON of the sorting configuration
     * @return GridReportHelper.GridReportRecordIdWrapper - Wrapper Storing record Ids
     */
    public static GridReportHelper.GridReportRecordIdWrapper getRecordIdsForGridReport(String apexClass, String filterConfig, String sortConfig){
        return service().getRecordIdsForGridReport(apexClass, filterConfig, sortConfig);
    }

    /**
     * @description Get Case Data for Grid Report Framework
     * @jira https://doordash.atlassian.net/browse/BSSF-993
     * @param apexClass - Name of the apex class implementing the IGridReportInterface
     * @param recordIds - Set of Figment Case Ids
     * @return String - record data serialized into String
     */
    public static String getDataForGridReport(String apexClass, List<Id> recordIds){
        return service().getDataForGridReport(apexClass, recordIds);
    }

    /**
     * @description Wrapper for Grid Report Request sent to Figment
     */
    public class GridReportRequest {
        @AuraEnabled
        public String className;
        @AuraEnabled
        public String filterList;
        @AuraEnabled
        public String sortConfig;
        @AuraEnabled
        public List<Id> recordIds;
        @AuraEnabled
        public Id userId;
    }
}