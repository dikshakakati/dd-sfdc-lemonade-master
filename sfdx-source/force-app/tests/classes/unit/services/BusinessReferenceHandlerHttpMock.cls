/**
 * @author Smruti Sekhar
 * @date 7/19/2024
 * @description Test  class to generate Mock HTTPResponse for HTTPCallout made by BusinessReferenceHandler class.
 * Suppressed Warnings since mock HTTPResponse method does not require System Assert statements.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts, PMD.ClassNamingConventions')
public class BusinessReferenceHandlerHttpMock implements HttpCalloutMock {
    private static final Integer SUCCESS_STATUS_CODE = 200;
    /**
     * @description To mock HTTPCallout made by BusinessReferenceHandler
     * and respond with test data.
     * @param request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(SUCCESS_STATUS_CODE);
        return response;
    }
}