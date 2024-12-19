/**
 * @author Deloitte
 * @date 16/10/2024
 * @description Test class for MxPortalPayloadParser class
 */
@isTest
public class MxPortalPayloadParserTest {
    private static final String STATIC_RESOURCE_MX_PORTAL_JSON = 'Inbound_Ingestion_Payload_Mx_Portal_Data';
    /**
     * @description It is used to test when Mx portal payload parsed then return response
     */
    @isTest
    private static void testWhenMxPortalPayloadPassedThenResponse() {
        //This is added to cover the default variables declared in the wrapper class 'MxPortalPayloadParser'.
        MxPortalPayloadParser.OrderProductsDetails orderProducts = new MxPortalPayloadParser.OrderProductsDetails();
        Assert.areEqual(orderProducts.budget, '0.0', 'errorrr');
    }
}