/**
 * @author Deloitte
 * @date 05/16/2024
 * @description Test class for InstantIngestionXrefBizRefServiceImpl.
 */
@isTest(seeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class InstantIngestionXrefBizRefServiceTest {
    private static final String STATIC_RESOURCE_TEST_JSON = 'Inbound_Ingestion_Payload_Data';
    private static final String STATIC_RESOURCE_TEST_SSOB = 'Inbound_Ingestion_Payload_Data_SSOB';
    private static final String UUID = '92108a53-e8d9-4a0c-9193-9152aeb86fe4';
    private static final String CURRENCYCODE = 'USD';
    private static final String SOURCE = 'SSOB';
    private static final string INVALID_ASSERT_MESSAGE = 'Unexpected results';
    private static final Id STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Store')
        .getRecordTypeId();
    private static final Id BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Business')
        .getRecordTypeId();
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenPayloadPassedThenBusinessRefCreated() {
        Id mockBusinessVerticalId = Fake.generateId(Business_Vertical__c.class);
        Id mockBrandId = Fake.generateId(Brand__c.class);
        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_JSON
        ];
        StaticResource staticResourceSSOB = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_SSOB
        ];
        Blob blobJSONSSOB = staticResourceSSOB.Body;
        String payloadStringSSOB = blobJSONSSOB.toString();
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        Business_Vertical__c businessVertical = new Business_Vertical__c(
            Id = mockBusinessVerticalId
        );
        Brand__c brand = new Brand__c(Id = mockBrandId);
        InstantIngestionPayloadParser payload = (InstantIngestionPayloadParser) System.JSON.deserialize(
            payloadString,
            InstantIngestionPayloadParser.class
        );
        SSOBOnboardingPayloadParser payloadSSOB = (SSOBOnboardingPayloadParser) System.JSON.deserialize(
            payloadStringSSOB,
            SSOBOnboardingPayloadParser.class
        );
        Test.startTest();
        Business_Reference__c returnedBizref = InstantIngestionXrefBizRefService.createBusinessReference(
            payload,
            payloadSSOB,
            brand.id,
            CURRENCYCODE,
            businessVertical,
            SOURCE
        );
        Test.stopTest();
        System.assertEquals(
            returnedBizref.Business_Vertical__c,
            mockBusinessVerticalId,
            INVALID_ASSERT_MESSAGE
        );
    }
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenPayloadThenXrefRef() {
        Id mockAccountId = Fake.generateId(Account.class);
        Id mockAccountBusinessId = Fake.generateId(Account.class);
        Id mockBusinessReferenceId = Fake.generateId(Business_Reference__c.class);
        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_JSON
        ];
        StaticResource staticResourceSSOB = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_SSOB
        ];
        Blob blobJSONSSOB = staticResourceSSOB.Body;
        String payloadStringSSOB = blobJSONSSOB.toString();
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        Business_Reference__c businessReference = new Business_Reference__c(
            Id = mockBusinessReferenceId
        );
        Account mockBusinessAccount = new Account(
            Id = mockAccountBusinessId,
            recordTypeId = STORE_RECORD_TYPE_ID
        );
        Account mockAccount = new Account(
            Id = mockAccountId,
            recordTypeId = BUSINESS_RECORD_TYPE_ID,
            parentId = mockAccountBusinessId
        );
        InstantIngestionPayloadParser payload = (InstantIngestionPayloadParser) System.JSON.deserialize(
            payloadString,
            InstantIngestionPayloadParser.class
        );
        SSOBOnboardingPayloadParser payloadSSOB = (SSOBOnboardingPayloadParser) System.JSON.deserialize(
            payloadStringSSOB,
            SSOBOnboardingPayloadParser.class
        );
        Test.startTest();
        Xref__c returnedXref = InstantIngestionXrefBizRefService.createXref(
            payload,
            payloadSSOB,
            mockBusinessAccount,
            mockAccount,
            businessReference,
            SOURCE
        );
        Test.stopTest();
        System.assertEquals(
            returnedXref.Salesforce_Account_Name__c,
            mockAccountId,
            INVALID_ASSERT_MESSAGE
        );
    }
}