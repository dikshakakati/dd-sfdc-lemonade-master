/**
 * @author Doordash
 * @date 04/04/2024
 * @description Test Factory class to generate Mock HTTPResponse for HTTPCallout.
 * Suppressed Warnings since mock HTTPResponse method does not require System Assert statements.
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts, PMD.ClassNamingConventions')
public class HttpCalloutMockResponseGenerator implements HttpCalloutMock {
    private String httpResponseBody = '{"HttpCalloutMockResponseGenerator_Mock_Key": "HttpCalloutMockResponseGenerator_Mock_Value"}';
    private Integer statusCode = 200;

    /**
     * @description Parameterized Constructor to initialize class variables.
     * @param responseBody
     * @param statusCode
     */
    public HttpCalloutMockResponseGenerator(string responseBody, Integer statusCode){
        this.statusCode = statusCode;
        this.httpResponseBody = responseBody;
    }
    /**
     * @description To mock HTTPCallout and respond with test data.
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