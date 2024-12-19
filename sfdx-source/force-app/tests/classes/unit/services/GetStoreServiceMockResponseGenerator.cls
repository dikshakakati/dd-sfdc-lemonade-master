/**
 * @author Doordash
 * @date 04/18/2023
 * @description Test  class to generate Mock HTTPResponse for HTTPCallout made by GetStoreService class.
 * Suppressed Warnings since mock HTTPResponse method does not require System Assert statements.
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts, PMD.ClassNamingConventions')
public class GetStoreServiceMockResponseGenerator implements HttpCalloutMock {
    private String httpResponseBody = '{"drive_store_id": "12345"}';
    private Integer statusCode = 200;

    /**
     * @description Test  class to generate Mock HTTPResponse for HTTPCallout made by GetStoreService class.
     * Suppressed Warnings since mock HTTPResponse method does not require System Assert statements
     * @param responseBody
     * @param statusCode
     */
    public GetStoreServiceMockResponseGenerator(string responseBody, Integer statusCode){
        this.statusCode = statusCode;
        this.httpResponseBody = responseBody;
    }
    /**
     * @description To mock HTTPCallout made by NetsuiteIntegratorRestletServiceImpl
     * and respond with test data.
     * @param request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setBody(httpResponseBody);
        response.setStatusCode(statusCode);
        return response;
    }
}