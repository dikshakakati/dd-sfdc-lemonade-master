/**
 * @author Deloitte
 * @date 05/20/2024
 * @description This is  the test class for SSMO Contact Creation
 */
@isTest(seeAllData=false)
private class SSMOContactCreationServiceImplTest {
    private static final String FIELD_MISMATCH_ASSERT_MESSAGE = 'Unexpected result: there was a mismatch in field values populated.';
    private static final String PRIMARY_VERTICAL_RX = 'Rx';
    private static final String STATIC_RESOURCE_TEST_JSON = 'SSMO_Contact_Ingestion_Mock_Payload';
    private static final String SSMO_UUID = '79k4d787-66TH-4bb0-93ed-4b0bc2ec1cf8';
    private static final String PRIMARY_VERTICAL_MARKETING = 'Marketing';
    private static final String STATIC_RESOURCE_TEST_JSON_REJECTED_ADDRESS = 'SSMO_Contact_Ingestion_Mock_Payload_Rejected_Address';
    private static final Integer FIRSTNAME_LASTNAME_MAX_LENGTH = 40;
    private static final Integer HOURS_OF_OPERATION_MAX_LENGTH = 255;

    /**
     * @description It is used verify contact creation scenario when no matched records are
     * present in the payload
     * */

    @isTest
    private static void testWhenNoMatchingRecordThenCreateContactFromPayload() {
        StaticResource sr = fetchStaticResource(STATIC_RESOURCE_TEST_JSON);
        Blob blobJSON = sr.Body;
        String payloadString = blobJSON.toString();
        SSMOFalloutWrapper parsedPayloads = (SSMOFalloutWrapper) System.JSON.deserialize(
            payloadString,
            SSMOFalloutWrapper.class
        );
        Contact contactToInsert = new Contact();
        Contact contactsTobeInserted = SSMOContactCreationService.insertContactSSMO(
            parsedPayloads,
            contactToInsert
        );
        System.assertEquals(
            parsedPayloads.storeName,
            contactsTobeInserted.Company__c,
            FIELD_MISMATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            (parsedPayloads.ownerFirstName).substring(0, FIRSTNAME_LASTNAME_MAX_LENGTH),
            contactsTobeInserted.FirstName,
            FIELD_MISMATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            (parsedPayloads.ownerLastName).substring(0, FIRSTNAME_LASTNAME_MAX_LENGTH),
            contactsTobeInserted.LastName,
            FIELD_MISMATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            parsedPayloads.ownerPhone,
            contactsTobeInserted.MobilePhone,
            FIELD_MISMATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            parsedPayloads.email,
            contactsTobeInserted.Email,
            FIELD_MISMATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description It is used verify contact updation scenario when matched records are
     * present in the payload
     * */
    @isTest
    private static void testWhenMatchingContactFoundThenUpdateContactFromPayload() {
        StaticResource sr = fetchStaticResource(STATIC_RESOURCE_TEST_JSON);
        Blob blobJSON = sr.Body;
        String payloadString = blobJSON.toString();
        SSMOFalloutWrapper parsedPayloads = (SSMOFalloutWrapper) System.JSON.deserialize(
            payloadString,
            SSMOFalloutWrapper.class
        );
        Contact testInsertContactSSMO = new Contact();
        Contact contactsTobeUpdated = SSMOContactCreationService.updateContactSSMO(
            parsedPayloads,
            testInsertContactSSMO
        );
        System.assertEquals(
            parsedPayloads.sourceUniqueId,
            contactsTobeUpdated.Unique_Identifier__c,
            FIELD_MISMATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            parsedPayloads.addressVerificationInfo?.alcoholRules?.alcoholAllowanceCategory,
            contactsTobeUpdated.Alcohol_Eligibility__c,
            FIELD_MISMATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            parsedPayloads.addressVerificationInfo?.addressVerificationStatus,
            contactsTobeUpdated.Address_Verification_Status__c,
            FIELD_MISMATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            parsedPayloads.addressVerificationInfo?.rejectedReason,
            contactsTobeUpdated.Address_Rejection_Reason__c,
            FIELD_MISMATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            PRIMARY_VERTICAL_RX,
            contactsTobeUpdated.Primary_Vertical__c,
            FIELD_MISMATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            SSMO_UUID,
            contactsTobeUpdated.Unique_Identifier__c,
            FIELD_MISMATCH_ASSERT_MESSAGE
        );
        System.assertEquals('Rx', contactsTobeUpdated.Primary_Vertical__c, 'False');
        System.assertEquals(PRIMARY_VERTICAL_MARKETING, contactsTobeUpdated.Self_Serve_Step__c , 'False');
        System.assertEquals(
            parsedPayloads.matchedRecords.account[0].Id,
            contactsTobeUpdated.SSMO_Matching_Account_Id__c,
            FIELD_MISMATCH_ASSERT_MESSAGE
        );
    }
    /**
     * @description It is used verify contact updation with new submarket creation scenario when matched records are
     * present in the payload
     * */
    @isTest
    private static void testWhenContactPresentThenUpdateContactWithNewSubmarket() {
        StaticResource sr = fetchStaticResource(STATIC_RESOURCE_TEST_JSON);
        Blob blobJSON = sr.Body;
        String payloadString = blobJSON.toString();
        SSMOFalloutWrapper parsedPayloads = (SSMOFalloutWrapper) System.JSON.deserialize(
            payloadString,
            SSMOFalloutWrapper.class
        );
        Contact testInsertContactSSMO = new Contact();

        Contact contactsTobeUpdated = SSMOContactCreationService.updateContactSSMO(
            parsedPayloads,
            testInsertContactSSMO
        );
        System.assertEquals(
            parsedPayloads.sourceUniqueId,
            contactsTobeUpdated.Unique_Identifier__c,
            FIELD_MISMATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            String.valueOf(parsedPayloads.businessId),
            contactsTobeUpdated.Business_Id__c,
            FIELD_MISMATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            (parsedPayloads.storeHours).substring(0, HOURS_OF_OPERATION_MAX_LENGTH),
            contactsTobeUpdated.Hours_of_Operation__c,
            FIELD_MISMATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            String.valueof(parsedPayloads.storeId),
            contactsTobeUpdated.Store_Id__c,
            FIELD_MISMATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description It is used verify contact updation scenario when matched records are
     * present in the payload
     * */
    @isTest
    private static void testWhenMatchingContactFoundAndVerificationStatusFailedThenUpdateContactFromPayload() {
        Id subMarketIdMock = fflib_IDGenerator.generate(Submarket__c.SObjectType);
        StaticResource sr = fetchStaticResource(STATIC_RESOURCE_TEST_JSON_REJECTED_ADDRESS);
        Blob blobJSON = sr.Body;
        String payloadString = blobJSON.toString();
        SSMOFalloutWrapper parsedPayloads = (SSMOFalloutWrapper) System.JSON.deserialize(
            payloadString,
            SSMOFalloutWrapper.class
        );
        Contact testInsertContactSSMO = new Contact();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ISubmarketsSelector mockSubmarketsSelector = (ISubmarketsSelector) mocks.mock(
            ISubmarketsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockSubmarketsSelector.sObjectType()).thenReturn(Submarket__c.SObjectType);
        mocks.when(mockSubmarketsSelector.getSubmarketById('9094'))
            .thenReturn(new List<Submarket__c>{ new Submarket__c(Id = subMarketIdMock) });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockSubmarketsSelector);
        Test.StartTest();
        Contact contactsTobeUpdated = SSMOContactCreationService.updateContactSSMO(
            parsedPayloads,
            testInsertContactSSMO
        );
        Test.StopTest();
        String ssmoStreet = (String.isNotBlank(parsedPayloads.storeAddress?.addressLine1) ?
            parsedPayloads.storeAddress?.addressLine1 : '') +
            (String.isNotBlank(parsedPayloads.storeAddress?.addressLine2) ?
            parsedPayloads.storeAddress?.addressLine2 : '');
        System.assertEquals(ssmoStreet, contactsTobeUpdated.MailingStreet, 'Street should match');
        System.assertEquals(
            parsedPayloads.storeAddress?.city,
            contactsTobeUpdated.MailingCity,
            'City Should match'
        );
        System.assertEquals(
            parsedPayloads.storeAddress?.state,
            contactsTobeUpdated.MailingStateCode,
            'state Should match'
        );
        System.assertEquals(
            parsedPayloads.storeAddress?.country,
            contactsTobeUpdated.MailingCountryCode,
            'country Should match'
        );
        System.assertEquals(
            parsedPayloads.storeAddress?.postalCode,
            contactsTobeUpdated.MailingPostalCode,
            'postalCode Should match'
        );
    }
    /**
     * @description To query static resources
     * @param staticResourceName
     * @return StaticResource
     * */
    private static StaticResource fetchStaticResource(String staticResourceName) {
        StaticResource stresource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :staticResourceName
        ];
        return stresource;
    }
}