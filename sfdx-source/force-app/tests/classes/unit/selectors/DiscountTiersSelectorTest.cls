/**
 * @author Deloitte
 * @date 07/28/2024
 * @description This is test class for DiscountTiersSelector class.
 */
@isTest
public class DiscountTiersSelectorTest {
    private static final String ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST = 'Unexpected result: There is a mismatch in fields list.';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE = 'Unexpected result: The object type must be Discount Schedule.';
    private static final String STATIC_RESOURCE_TEST_SSOB = 'Inbound_Ingestion_Payload_Data_SSOB';
    private static final String LIST_SIZE_ERROR_MESSAGE = 'Lists size does not match.';

    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        DiscountTiersSelector discountTier = new DiscountTiersSelector();
        Schema.SObjectType typeOfObj = discountTier.getSObjectType();
        List<Schema.SObjectField> fieldList = discountTier.getSObjectFieldList();
        DiscountTiersSelector.newInstance();
        System.assertEquals(
            Schema.SBQQ__DiscountTier__c.SObjectType,
            typeOfObj,
            ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE
        );
        System.assertEquals(
            new List<Schema.SObjectField>{ SBQQ__DiscountTier__c.Id },
            fieldList,
            ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST
        );
    }

    @isTest
    private static void testWhenPayloadPassedThenDiscountTiersReturned() {
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
        Set<String> uuidList = new Set<String>();
        uuidList.add(payload.uuid);
        Test.startTest();
        List<SBQQ__DiscountTier__c> discountTiersList = new DiscountTiersSelector()
            .selectByUUID(uuidList);
        Test.stopTest();
        System.assertEquals(0, discountTiersList.size(), LIST_SIZE_ERROR_MESSAGE);
    }
}