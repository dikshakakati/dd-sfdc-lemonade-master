/**
 * @author CriticalRiver
 * @date   Sept 2024
 * @description Test class for FigmentIntegrationService class.
 */
@isTest(SeeAllData=false)
private class FigmentIntegrationServiceImplTest {

    /**
     * @description Test method for getRecordIdsForGridReport
     */
    @isTest
    private static void testWhenGetRecordIdsForGridReportThenRecords() {
        Id fakeCaseId = fflib_IDGenerator.generate(Case.SObjectType);
        String fakeResponseBody = '{ "count": 1, "recordIds": ["'+ fakeCaseId + '"]}';
        Test.setMock(HttpCalloutMock.class, new FigmentIntegrationMock(fakeResponseBody, 200));
        GridReportHelper.GridReportRecordIdWrapper gridReportWrapper = FigmentIntegrationService.getRecordIdsForGridReport('AnyClassName',
            'AnyFilterConfig', 'AnySortConfig');

        Assert.areEqual(1, gridReportWrapper.count, 'Record count is not same as expected.');
        Assert.areEqual(fakeCaseId, gridReportWrapper.recordIds[0], 'Record Id is not same as expected.');
    }

    /**
     * @description Test method for getDataForGridReport
     */
    @isTest
    private static void testWhenGetDataForGridReportThenRecords() {
        Id fakeCaseId = fflib_IDGenerator.generate(Case.SObjectType);
        List<Map<String,Object>> caseData = new List<Map<String,Object>>();

        Map<String,Object> data = new Map<String,Object>{
            'Id' => fakeCaseId,
            'Subject' => 'Test Subject'
        };
        caseData.add(data);

        String fakeResponseBody = JSON.serialize(caseData);
        Test.setMock(HttpCalloutMock.class, new FigmentIntegrationMock(fakeResponseBody, 200));
        String recordData = FigmentIntegrationService.getDataForGridReport('AnyClassName', new List<Id>{fakeCaseId});

        Assert.areEqual(recordData, '[{"Subject":"Test Subject","Id":"' + fakeCaseId + '"}]', 'Record data is not same as expected.');
    }

    /**
     * @description Create HttpMock Response for successful response from Email Action API
     */
    private class FigmentIntegrationMock implements HttpCalloutMock {
        private String body;
        private Integer statusCode;

        /**
         * @description Parameterized constructor for FigmentIntegrationMock
         * @param body
         * @param statusCode
         */
        public FigmentIntegrationMock(String body, Integer statusCode){
            this.body = body;
            this.statusCode = statusCode;
        }

        /**
         * @description Returns Mock HttpReponse with provided body and status code
         * @param req
         * @return HTTPResponse - mock response body
         */
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(this.body);
            res.setStatusCode(this.statusCode);
            return res;
        }
    }
}