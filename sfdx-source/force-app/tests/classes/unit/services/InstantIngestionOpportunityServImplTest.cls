/**
 * @author Deloitte
 * @date 05/15/2024
 * @description Test class for InstantIngestionOpportunityServiceImpl
 */
@isTest
private class InstantIngestionOpportunityServImplTest {
    private static final String BUSINESS_ACCOUNT_NAME = 'Hello world';
    private static final String CURRENCY_ISO_CODE = 'USD';
    private static final String STATIC_RESOURCE_TEST_JSON = 'Inbound_Ingestion_Payload_Data';
    private static final String STATIC_RESOURCE_TEST_SSOB_JSON = 'Inbound_Ingestion_Payload_Data_SSOB';
    private static final String STATIC_RESOURCE_MX_PORTAL_JSON = 'Inbound_Ingestion_Payload_Mx_Portal_Data';
    private static final string INVALID_ASSERT_MESSAGE = 'Unexpected results';
    private static final string SOURCE_SSMO = 'SSMO';
    private static final string SOURCE_SSOB = 'SSOB';
    private static final String MXP_EVENT_TYPE_ADS_AND_PROMOS = 'Mx Portal Ads And Promos';

    /**
     * @description It is used to test whether an Opportunity is created or not when the payload is passed
     */
    @isTest
    private static void testWhenPayloadReceivedThenCreateOpportunity() {
        Id mockAccountId = Fake.generateId(Account.class);
        Id mockContactId = Fake.generateId(Contact.class);
        Id mockingestionLogId = Fake.generateId(Inbound_ingestion_Log__c.class);
        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_JSON
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        InstantIngestionPayloadParser payload = (InstantIngestionPayloadParser) System.JSON.deserialize(
            payloadString,
            InstantIngestionPayloadParser.class
        );
        Account mockAccount = new Account(Id = mockAccountId);
        Contact mockContact = new Contact(Id = mockContactId);
        Test.startTest();
        Opportunity opportunity = InstantIngestionOpportunityService.createOpportunity(
            payload,
            null,
            mockAccount,
            mockContact,
            SOURCE_SSMO,
            mockingestionLogId
        );
        Test.stopTest();
        System.assertEquals(payload.Uuid, opportunity.Unique_Identifier__c, INVALID_ASSERT_MESSAGE);
        System.assertEquals(
            mockingestionLogId,
            opportunity.Ingestion_log_Id__c,
            INVALID_ASSERT_MESSAGE
        );
        System.assertEquals(payload.store.storeId, opportunity.Store_Id__c, INVALID_ASSERT_MESSAGE);
    }
    /**
     * @description It is used to test whether an Opportunity is created or not when the SSOB payload is passed.
     */
    @isTest
    private static void testWhenPayloadReceivedThenCreateSSOBOpportunity() {
        Id mockAccountId = Fake.generateId(Account.class);
        Id mockContactId = Fake.generateId(Contact.class);
        Id mockingestionLogId = Fake.generateId(Inbound_ingestion_Log__c.class);
        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_SSOB_JSON
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();

        SSOBOnboardingPayloadParser payload = (SSOBOnboardingPayloadParser) System.JSON.deserialize(
            payloadString,
            SSOBOnboardingPayloadParser.class
        );
        Account mockAccount = new Account(Id = mockAccountId);
        Contact mockContact = new Contact(Id = mockContactId);
        Test.startTest();
        Opportunity opportunity = InstantIngestionOpportunityService.createOpportunity(
            null,
            payload,
            mockAccount,
            mockContact,
            SOURCE_SSOB,
            mockingestionLogId
        );
        Test.stopTest();
        System.assertEquals(payload.Uuid, opportunity.Unique_Identifier__c, INVALID_ASSERT_MESSAGE);
        System.assertEquals(
            mockingestionLogId,
            opportunity.Ingestion_log_Id__c,
            INVALID_ASSERT_MESSAGE
        );
        System.assertEquals(true, String.isBlank(opportunity.Store_Id__c), INVALID_ASSERT_MESSAGE);
    }

    /**
     * @description It is used to test whether an Opportunity is created or not when the mx portal
     * payload is passed.
     */
    @isTest
    private static void testWhenMxPortalPayloadReceivedThenCreateOpportunity() {
        Id mockAccountId = Fake.generateId(Account.class);
        Id mockingestionLogId = Fake.generateId(Inbound_ingestion_Log__c.class);
        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_MX_PORTAL_JSON
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        MxPortalPayloadParser payload = (MxPortalPayloadParser) System.JSON.deserialize(
            payloadString,
            MxPortalPayloadParser.class
        );
        Account mockAccount = new Account(
            Id = mockAccountId,
            Name = 'Test1',
            CurrencyIsoCode = CURRENCY_ISO_CODE
        );
        Test.startTest();
        Opportunity opportunity = InstantIngestionOpportunityService.createAmendmentOpportunityForMxPortal(
            payload,
            mockAccount,
            MXP_EVENT_TYPE_ADS_AND_PROMOS,
            mockingestionLogId
        );
        Test.stopTest();
        System.assertEquals(payload.Uuid, opportunity.Unique_Identifier__c, INVALID_ASSERT_MESSAGE);
        System.assertEquals(payload.store.storeId, opportunity.Store_Id__c, INVALID_ASSERT_MESSAGE);
        System.assertEquals(
            mockingestionLogId,
            opportunity.Ingestion_log_Id__c,
            INVALID_ASSERT_MESSAGE
        );
    }
}