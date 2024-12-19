/**
 * @author Deloitte
 * @date 05/15/2024
 * @description Test class for InstantIngestionAccountServiceImpl
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class InstantIngestionAccountServiceImplTest {
    private static final String STATIC_RESOURCE_TEST_JSON = 'Inbound_Ingestion_Payload_Data';
    private static final String STATIC_RESOURCE_TEST_SSOB_JSON = 'Inbound_Ingestion_Payload_Data_SSOB';
    private static final String STATIC_RESOURCE_TEST_SSOB_WITHOUT_ADDRESS_JSON = 'Inbound_Ingestion_Payload_Test_Data_SSOB_Without_Address';
    private static final Id BUSNINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Business')
        .getRecordTypeId();
    private static final string INVALID_ASSERT_MESSAGE = 'Unexpected results';
    private static final string INTEGRATION_TYPE = 'Mx Portal Ads And Promos';

    /*
     * @description It is used to test when a business account received in payload.
     */
    @isTest
    private static void testWhenPayloadReceivedThenCreateBusinessAccount() {
        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_JSON
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        Id mockSubmarketId = Fake.generateId(Submarket__c.class);
        Submarket__c mockSubmarket = new Submarket__c(Id = mockSubmarketId);
        InstantIngestionPayloadParser payload = (InstantIngestionPayloadParser) System.JSON.deserialize(
            payloadString,
            InstantIngestionPayloadParser.class
        );
        Test.startTest();
        Account businessAccount = InstantIngestionAccountService.createBusinessAccount(
            payload,
            mockSubmarket.Id,
            INTEGRATION_TYPE
        );
        Test.stopTest();
        System.assertEquals(payload.business.name, businessAccount.Name, INVALID_ASSERT_MESSAGE);
    }

    /*
     * @description It is used to test when a business account received in SSOB payload.
     */
    @isTest
    private static void testWhenPayloadReceivedThenCreateSSOBBusinessAccount() {
        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_SSOB_JSON
        ];
        List<Inbound_Ingestion_Payload_Mapping__mdt> mockCustomMetadata = new List<Inbound_Ingestion_Payload_Mapping__mdt>{
            new Inbound_Ingestion_Payload_Mapping__mdt(
                Field_Name__c = 'Name',
                Integration_Type__c = 'SSOB',
                Object__c = 'Account',
                Payload_Attribute__c = 'name',
                Payload_Type__c = 'String',
                Default_Value__c = '',
                Attribute_Key__c = ''
            ),
            new Inbound_Ingestion_Payload_Mapping__mdt(
                Field_Name__c = 'Segment__c',
                Integration_Type__c = 'SSOB',
                Object__c = 'Account',
                Default_Value__c = 'SMB',
                Payload_Type__c = 'String',
                Attribute_Key__c = '',
                Payload_Attribute__c = ''
            ),
            new Inbound_Ingestion_Payload_Mapping__mdt(
                Field_Name__c = 'BillingCity',
                Integration_Type__c = 'SSOB',
                Object__c = 'Account',
                Payload_Attribute__c = 'city',
                Payload_Type__c = 'String',
                Attribute_Key__c = 'Address',
                Default_Value__c = ''
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        InstantIngestionFieldMappingSelector selectorMock = (InstantIngestionFieldMappingSelector) mocks.mock(
            InstantIngestionFieldMappingSelector.class
        );

        mocks.startStubbing();
        mocks.when(selectorMock.getSObjectType())
            .thenReturn(Inbound_Ingestion_Payload_Mapping__mdt.SObjectType);
        mocks.when(selectorMock.getAllValues()).thenReturn(mockCustomMetadata);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        SSOBOnboardingPayloadParser payload = (SSOBOnboardingPayloadParser) System.JSON.deserialize(
            payloadString,
            SSOBOnboardingPayloadParser.class
        );
        Test.startTest();

        Account businessAccount = InstantIngestionAccountService.createBusinessAccountSSOB(
            payloadString,
            payload
        );

        Test.stopTest();
        System.assertEquals(payload.account.name, businessAccount.Name, INVALID_ASSERT_MESSAGE);
    }

    /*
     * @description It is used to test when a business account received in SSOB payload with incomplete address.
     */
    @isTest
    private static void testWhenPayloadReceivedWithIncompleteAddressThenCreateSSOBBusinessAccount() {
        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_SSOB_WITHOUT_ADDRESS_JSON
        ];
        List<Inbound_Ingestion_Payload_Mapping__mdt> mockCustomMetadata = new List<Inbound_Ingestion_Payload_Mapping__mdt>{
            new Inbound_Ingestion_Payload_Mapping__mdt(
                Field_Name__c = 'Name',
                Integration_Type__c = 'SSOB',
                Object__c = 'Account',
                Payload_Attribute__c = 'name',
                Payload_Type__c = 'String',
                Default_Value__c = '',
                Attribute_Key__c = ''
            ),
            new Inbound_Ingestion_Payload_Mapping__mdt(
                Field_Name__c = 'Segment__c',
                Integration_Type__c = 'SSOB',
                Object__c = 'Account',
                Default_Value__c = 'SMB',
                Payload_Type__c = 'String',
                Attribute_Key__c = '',
                Payload_Attribute__c = ''
            ),
            new Inbound_Ingestion_Payload_Mapping__mdt(
                Field_Name__c = 'BillingCity',
                Integration_Type__c = 'SSOB',
                Object__c = 'Account',
                Payload_Attribute__c = 'city',
                Payload_Type__c = 'String',
                Attribute_Key__c = 'Address',
                Default_Value__c = ''
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        InstantIngestionFieldMappingSelector selectorMock = (InstantIngestionFieldMappingSelector) mocks.mock(
            InstantIngestionFieldMappingSelector.class
        );

        mocks.startStubbing();
        mocks.when(selectorMock.getSObjectType())
            .thenReturn(Inbound_Ingestion_Payload_Mapping__mdt.SObjectType);
        mocks.when(selectorMock.getAllValues()).thenReturn(mockCustomMetadata);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        SSOBOnboardingPayloadParser payload = (SSOBOnboardingPayloadParser) System.JSON.deserialize(
            payloadString,
            SSOBOnboardingPayloadParser.class
        );
        Test.startTest();

        Account businessAccount = InstantIngestionAccountService.createBusinessAccountSSOB(
            payloadString,
            payload
        );

        Test.stopTest();
        System.assertEquals(payload.account.name, businessAccount.Name, INVALID_ASSERT_MESSAGE);
    }

    /*
     * @description It is used to test when a business account received in payload and create brand.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenPayloadPassedThenCreateBrand() {
        Id mockAccountId = Fake.generateId(Account.class);
        Account mockAccount = new Account(Id = mockAccountId);
        Test.startTest();
        Brand__c brand = InstantIngestionAccountService.createBrand(mockAccount);
        Test.stopTest();
        System.assertEquals(mockAccount.Id, brand.Brand_Owner__c, INVALID_ASSERT_MESSAGE);
    }

    /*
     * @description To test store account creation via received payload.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenPayloadThenCreateStoreAccount() {
        Id mockAccountId = Fake.generateId(Account.class);
        Id mockBrandId = Fake.generateId(Brand__c.class);
        Id mockBusinessVerticalId = Fake.generateId(Business_Vertical__c.class);
        StaticResource staticResource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_JSON
        ];
        Blob blobJSON = staticResource.Body;
        String payloadString = blobJSON.toString();
        Account mockAccount = new Account(Id = mockAccountId);
        Brand__c mockBrand = new Brand__c(Id = mockBrandId);
        Business_Vertical__c mockBusinessVertical = new Business_Vertical__c(
            Id = mockBusinessVerticalId
        );
        Id mockSubmarketId = Fake.generateId(Submarket__c.class);
        Submarket__c mockSubmarket = new Submarket__c(Id = mockSubmarketId);
        InstantIngestionPayloadParser payload = (InstantIngestionPayloadParser) System.JSON.deserialize(
            payloadString,
            InstantIngestionPayloadParser.class
        );
        Test.startTest();
        Account storeAccount = InstantIngestionAccountService.createStoreAccount(
            payload,
            mockBrand.Id,
            mockAccount,
            mockBusinessVertical,
            mockSubmarket.Id
        );
        Test.stopTest();
        System.assertEquals(storeAccount.ParentId, mockAccount.Id, INVALID_ASSERT_MESSAGE);
        System.assertEquals(storeAccount.Menu_UI_Type__c, null,INVALID_ASSERT_MESSAGE);
    }
}