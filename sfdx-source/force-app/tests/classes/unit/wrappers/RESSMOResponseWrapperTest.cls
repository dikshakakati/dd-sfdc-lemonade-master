/**
 * @description       : Test class of RESSMOHelper
 * @author            : Pankaj
 * @group             :
 * @last modified on  : 07-12-2024
 * @last modified by  : SamikshaDD
**/
@isTest(SeeAllData=false)
public class RESSMOResponseWrapperTest {
    public static final String SSMO_STATIC_RESOURCE_NAME = 'RESSMO_Sample_Response';
    /**
    * @description cover wrapper class.
    */
    @isTest
    private static void testWhenPayloadThenResponse() {
        // Sample JSON string
        StaticResource sr = StaticResourcesSelector.newInstance().selectByName(SSMO_STATIC_RESOURCE_NAME)[0];
        Blob blobJSON = sr.Body;
        String payloadString = blobJSON.toString();
        // Call the parse method
        RESSMOResponseWrapper response = RESSMOResponseWrapper.parse(payloadString);
        Assert.areEqual(true, response.banking.success, 'Banking Succcess');
    }

}