/**
 * @author Deloitte
 * @date 10/20/2022
 * @description Test  class to generate Mock HTTPResponse for HTTPCallout made by NetsuiteIntegratorRestletServiceImpl class.
 * Suppressed Warnings since mock HTTPResponse method does not require System Assert statements.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts, PMD.ClassNamingConventions')
public class NetsuiteIntegratorMockResponseGenerator implements HttpCalloutMock {
    private static final String HTTP_RESPONSE_BODY = '{"id": "SyncWithNetsuiteTestNetsuiteId"}';
    private static final Integer SUCCESS_STATUS_CODE = 200;
    /**
     * @description To mock HTTPCallout made by NetsuiteIntegratorRestletServiceImpl
     * and respond with test data.
     * @param request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setBody(HTTP_RESPONSE_BODY);
        response.setStatusCode(SUCCESS_STATUS_CODE);
        return response;
    }
}