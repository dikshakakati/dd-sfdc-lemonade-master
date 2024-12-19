/**
 * @author Deloitte
 * @date 07/28/2024
 * @description This is test class for DiscountSchedulesSelector class
 */
@isTest
public class DiscountSchedulesSelectorTest {
    private static final String ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST = 'Unexpected result: There is a mismatch in fields list.';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE = 'Unexpected result: The object type must be Discount Schedule.';
    private static final String STATIC_RESOURCE_TEST_SSOB = 'Inbound_Ingestion_Payload_Data_SSOB';
    private static final String LIST_SIZE_ERROR_MESSAGE = 'Lists size does not match.';

    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        DiscountSchedulesSelector discountSchedules = new DiscountSchedulesSelector();

        Schema.SObjectType typeOfObj = discountSchedules.getSObjectType();
        List<Schema.SObjectField> fieldList = discountSchedules.getSObjectFieldList();
        DiscountSchedulesSelector.newInstance();
        System.assertEquals(
            Schema.SBQQ__DiscountSchedule__c.SObjectType,
            typeOfObj,
            ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE
        );
        System.assertEquals(
            new List<Schema.SObjectField>{ SBQQ__DiscountSchedule__c.Id },
            fieldList,
            ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST
        );
    }

    @isTest
    private static void testWhenSSOBPayloadPassedWithProductNamesThenCorrespondingProductDiscountSchedulesReturned() {
        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_SSOB
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        SSOBOnboardingPayloadParser payload = (SSOBOnboardingPayloadParser) System.JSON.deserialize(
            payloadString,
            SSOBOnboardingPayloadParser.class
        );
        Map<String, SSOBOnboardingPayloadParser.ProductOptionsDetails> optionProductNameWithProductDetails = new Map<String, SSOBOnboardingPayloadParser.ProductOptionsDetails>();
        for (
            SSOBOnboardingPayloadParser.ProductOptionsDetails eachProductOption : payload.opportunity.orderProducts.productOptions
        ) {
            optionProductNameWithProductDetails.put(eachProductOption.name, eachProductOption);
        }
        Test.startTest();
        List<SBQQ__DiscountSchedule__c> discountScheduleList = new DiscountSchedulesSelector()
            .selectByProductName(optionProductNameWithProductDetails.keySet());
        Test.stopTest();
        System.assertEquals(0, discountScheduleList.size(), LIST_SIZE_ERROR_MESSAGE);
    }
}