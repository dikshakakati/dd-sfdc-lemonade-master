/**
 * @author CriticalRiver
 * @date   Sept 2024
 * @description Implementation of FigmentIntegrationService for querying data from Figment
 */
public inherited sharing class FigmentIntegrationServiceImpl implements IFigmentIntegrationService {
    private static final String HTTP_METHOD = 'POST';
    private static final String HTTP_HEADER_KEY_CONTENT_TYPE = 'Content-Type';
    private static final String HTTP_HEADER_VALUE_JSON = 'application/json; charset=UTF-8';
    private static final String NAMED_CREDENTIAL_FIGMENT = 'Salesforce_Figment';
    private static final String ENDPOINT_GRID_REPORT_GET_ID = 'services/apexrest/gridreport/id';
    private static final String ENDPOINT_GRID_REPORT_GET_DATA = 'services/apexrest/gridreport/data';

    /**
     * @description Get Record Ids for Grid Report Framework
     * @jira https://doordash.atlassian.net/browse/BSSF-993
     * @param apexClass - Name of the apex class implementing the IGridReportInterface
     * @param filterConfig - JSON of the filter values and configuration
     * @param sortConfig - JSON of the sorting configuration
     * @return GridReportHelper.GridReportRecordIdWrapper - Wrapper Storing record Ids
     */
    public static GridReportHelper.GridReportRecordIdWrapper getRecordIdsForGridReport(String apexClass, String filterConfig, String sortConfig){
        GridReportHelper.GridReportRecordIdWrapper retVal = new GridReportHelper.GridReportRecordIdWrapper();
        FigmentIntegrationService.GridReportRequest requestBody = new FigmentIntegrationService.GridReportRequest();
        requestBody.className = apexClass;
        requestBody.filterList = filterConfig;
        requestBody.sortConfig = sortConfig;
        requestBody.userId = UserInfo.getUserId();
        HttpRequest postRequest = new HttpRequest();
        postRequest.setBody(JSON.serialize(requestBody));
        postRequest.setEndpoint(String.format('callout:{0}/{1}', new List<String>{NAMED_CREDENTIAL_FIGMENT, ENDPOINT_GRID_REPORT_GET_ID}));
        postRequest.setMethod(HTTP_METHOD);
        postRequest.setHeader(HTTP_HEADER_KEY_CONTENT_TYPE, HTTP_HEADER_VALUE_JSON);
        postRequest.setTimeout(60000);
        HttpResponse resp = new Http().send(postRequest);
        retVal = (GridReportHelper.GridReportRecordIdWrapper)JSON.deserialize(resp.getBody(), GridReportHelper.GridReportRecordIdWrapper.class);
        return retVal;
    }

    /**
     * @description Get Case Data for Grid Report Framework
     * @jira https://doordash.atlassian.net/browse/BSSF-993
     * @param apexClass - Name of the apex class implementing the IGridReportInterface
     * @param recordIds - Set of Figment Case Ids
     * @return String - record data serialized into String
     */
    public static String getDataForGridReport(String apexClass, List<Id> recordIds){
        String retval = '[]';
        FigmentIntegrationService.GridReportRequest requestBody = new FigmentIntegrationService.GridReportRequest();
        requestBody.className = apexClass;
        requestBody.recordIds = recordIds;

        HttpRequest postRequest = new HttpRequest();
        postRequest.setBody(JSON.serialize(requestBody));
        postRequest.setEndpoint(String.format('callout:{0}/{1}', new List<String>{NAMED_CREDENTIAL_FIGMENT, ENDPOINT_GRID_REPORT_GET_DATA}));
        postRequest.setMethod(HTTP_METHOD);
        postRequest.setHeader(HTTP_HEADER_KEY_CONTENT_TYPE, HTTP_HEADER_VALUE_JSON);
        postRequest.setTimeout(60000);
        HttpResponse resp = new Http().send(postRequest);
        retVal = resp.getBody();
        return retVal;
    }
}