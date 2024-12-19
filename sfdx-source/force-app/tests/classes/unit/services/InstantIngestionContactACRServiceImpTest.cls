/**
 * @author Deloitte
 * @date 05/15/2024
 * @description Test class for InstantIngestionContactACRServiceImpl.
 */
@isTest
public class InstantIngestionContactACRServiceImpTest {
    private static final String STATIC_RESOURCE_TEST_JSON = 'Inbound_Ingestion_Payload_Data';
    private static final String STATIC_RESOURCE_TEST_SSOB = 'Inbound_Ingestion_Payload_Data_SSOB';
    private static final String UNIQUE_IDENTIFIER = 'f242568c-8834-454e-b405-30283be3ed78';

    /*
     * @description It is used to test when a valid payload is passed then ACR is created.
     */
    @isTest
    private static void testWhenPayloadPassedThenCreateContact() {
        Id mockAccountId = Fake.generateId(Account.class);
        Account mockAccount = new Account(Id = mockAccountId, Name = 'Parent 1');
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
        Test.startTest();
        Contact contact = InstantIngestionContactACRService.createContact(payload, mockAccount);
        Test.stopTest();
        System.assertEquals(
            payload.merchantOwner.firstName,
            contact.FirstName,
            'First name should match.'
        );
        System.assertEquals(
            payload.merchantOwner.lastName,
            contact.LastName,
            'Last name should match.'
        );
        System.assertEquals(payload.merchantOwner.email, contact.Email, 'Email should match.');
        System.assertEquals(
            payload.merchantOwner.mobilePhone,
            contact.MobilePhone,
            'Mobile phone should match.'
        );
    }

    @isTest
    private static void testWhenPayloadPassedThenCreateContactForSSOB() {
        Id mockAccountId = Fake.generateId(Account.class);
        Account mockAccount = new Account(Id = mockAccountId, Name = 'Parent 1');
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
        Test.startTest();
        List<Contact> contact = InstantIngestionContactACRService.createContactForSSOB(
            mockAccount,
            payloadString,
            payload
        );
        Test.stopTest();
        System.assertEquals(
            payload.contact.decisionMaker.firstName,
            contact[0].FirstName,
            'First name should match.'
        );
        System.assertEquals(
            payload.contact.decisionMaker.lastName,
            contact[0].LastName,
            'Last name should match.'
        );
        System.assertEquals(payload.contact.decisionMaker.email, contact[0].Email, 'Email should match.');
        System.assertEquals(
            payload.contact.decisionMaker.mobilePhone,
            contact[0].MobilePhone,
            'Mobile phone should match.'
        );
    }

    @isTest
    private static void testWhenPayloadWithDifferentEmailPassedThenCreateContactForSSOB() {
        Id mockAccountId = Fake.generateId(Account.class);
        Account mockAccount = new Account(Id = mockAccountId, Name = 'Parent 1');
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
        payload.contact.decisionMaker.email = 'String1';
        Test.startTest();
        List<Contact> contact = InstantIngestionContactACRService.createContactForSSOB(mockAccount, payloadString,payload);
        Test.stopTest();
        System.assertEquals(
            payload.contact.decisionMaker.firstName,
            contact[0].FirstName,
            'First name should match.'
        );
        System.assertEquals(
            payload.contact.decisionMaker.lastName,
            contact[0].LastName,
            'Last name should match.'
        );
        System.assertEquals(payload.contact.decisionMaker.email, contact[0].Email, 'Email should match.');
        System.assertEquals(
            payload.contact.decisionMaker.mobilePhone,
            contact[0].MobilePhone,
            'Mobile phone should match.'
        );
    }

    /**
     * @description It is used to test when an invalid payload is passed then ACR is
     * not created.
     */
    @isTest
    private static void testWhenInvalidPayloadPassedThenACRNotCreated() {
        Id mockBusinessAccountId = Fake.generateId(Account.class);
        Id mockStoreAccountId = Fake.generateId(Account.class);
        Id mockContactId = Fake.generateId(Contact.class);
        Account businessAccount = new Account(
            Id = mockBusinessAccountId,
            Name = 'Test BusinessAcc',
            Unique_Identifier__c = UNIQUE_IDENTIFIER
        );
        Contact contact = new Contact(
            Id = mockContactId,
            FirstName = 'Mariela',
            LastName = 'Esquilin',
            Email = 'john.doe@example.com',
            MobilePhone = '1234567890',
            AccountId = mockBusinessAccountId,
            Unique_Identifier__c = UNIQUE_IDENTIFIER
        );
        Account storeAccount = new Account(
            Id = mockStoreAccountId,
            Name = 'Test StoreAcc',
            Unique_Identifier__c = UNIQUE_IDENTIFIER,
            ParentId = mockBusinessAccountId
        );
        Test.startTest();
        List<AccountContactRelation> acr = InstantIngestionContactACRService.createACR(
            storeAccount,
            businessAccount,
            contact,
            System.Label.ACR_Role_Decision_Maker
        );
        Test.stopTest();
        System.assertEquals(
            mockContactId,
            acr[0].ContactId,
            'AccountContactRelation should be created.'
        );
    }
}