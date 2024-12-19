/**
 * @author DoorDash
 * @date 06/02/2023
 * @description Test class for ContactAndAcrCreateServiceImpl
 */
@isTest
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
public class ContactAndAcrCreateServiceImplTest {
    private static final String FIRST_NAME = 'Test FirstName';
    private static final String LAST_NAME = 'Test LastName';
    private static final String EMAIL = 'test.test14@doordash.com';
    private static final String PHONE = '373737923979';
    private static final String NAME = FIRST_NAME + LAST_NAME;
    private static final String ACCOUNT_ID = fflib_IDGenerator.generate(Account.getSObjectType());
    private static final String SOURCE_ONBOARDING_INPUTS = 'Onboarding Inputs';
    private static final String STREET = 'Test St';
    private static final String CITY = 'Test City';
    private static final String POSTAL_CODE = '12345';
    private static final String STATE = 'Test State';
    private static final String COUNTRY = 'Test Country';

    /**
     * @description It creates mock data for setting Contact Info Wrapper.
     * @return List<String>
     */
    public static List<String> setMockContactInfoWrapperForOnboardingInputs() {
        Map<String, Object> jsonMap = new Map<String, Object>{
            'SSN' => null,
            'phone' => PHONE,
            'lastName' => LAST_NAME,
            'firstName' => FIRST_NAME,
            'email' => EMAIL,
            'address' => setMockAddressWrapperForOnboardingInputs(),
            'source' => SOURCE_ONBOARDING_INPUTS,
            'dateOfBirth' => System.today(),
            'mobilePhone' => PHONE,
            'accountIdToRoles' => new Map<String, String>{
                ACCOUNT_ID => 'Business Admin;Legal Contact'
            }
        };
        return new List<String>{ JSON.serialize(jsonMap) };
    }

    /**
     * @description It creates mock data foe setting Address Wrapper.
     * @return Map<String, Object>
     */
    public static Map<String, Object> setMockAddressWrapperForOnboardingInputs() {
        Map<String, Object> jsonMap = new Map<String, Object>{
            'street' => STREET,
            'city' => CITY,
            'postalCode' => POSTAL_CODE,
            'country' => COUNTRY,
            'state' => STATE,
            'ownerPhone' => PHONE
        };
        return jsonMap;
    }

    @isTest
    private static void testWhenContactsPayloadReceivedThenGetExistingAssociatedContacts() {
        ContactDto dto = new ContactDto();
        List<String> coninfo = mockContactInfo();
        dto.deserialize(coninfo);
        Contact existingContact = new Contact(
            Id = fflib_IDGenerator.generate(Contact.SObjectType),
            FirstName = FIRST_NAME,
            LastName = LAST_NAME,
            Email = EMAIL
        );
        List<Contact> existingContacts = new List<Contact>{ existingContact };
        Set<String> firstNames = new Set<String>{ FIRST_NAME };
        Set<String> lastNames = new Set<String>{ LAST_NAME };
        Set<String> emails = new Set<String>{ EMAIL };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUow = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IContactsSelector contactsSelectorMock = (IContactsSelector) mocks.mock(
            IContactsSelector.class
        );
        mocks.startStubbing();
        mocks.when(contactsSelectorMock.SObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(
                contactsSelectorMock.selectContactByEmailFirstNameLastName(
                    firstNames,
                    lastNames,
                    emails
                )
            )
            .thenReturn(existingContacts);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(contactsSelectorMock);
        Application.UnitOfWork.setMock(mockUow);
        test.startTest();
        ContactAndAcrCreateService.processContactsPayloadAsyncly(coninfo);
        test.stopTest();
        ((IContactsSelector) mocks.verify(contactsSelectorMock, 1))
            .selectContactByEmailFirstNameLastName(firstNames, lastNames, emails);
    }
    @isTest
    private static void testWhenContactsPayloadReceivedThenCreateContact() {
        List<String> coninfo = mockContactInfo();
        Contact existingContact = new Contact(
            Id = fflib_IDGenerator.generate(Contact.SObjectType),
            FirstName = 'Test',
            LastName = 'Test',
            Email = 'Test@gmail.com'
        );
        List<Contact> existingContacts = new List<Contact>{ existingContact };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUow = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UnitOfWork.setMock(mockUow);
        ContactAndAcrCreateServiceImpl contactService = new ContactAndAcrCreateServiceImpl();
        contactService.deserializeContactInfo(coninfo);
        List<Contact> newContacts = contactService.searchAndCreateRelatedContacts(existingContacts);
        system.assertEquals(newContacts[0].FirstName, FIRST_NAME, 'New contact name not matching');
    }
    @isTest
    private static void testWhenContactPayloadReceivedThenCreateAcr() {
        List<String> coninfo = mockContactInfo();
        Contact relatedContact = new Contact(
            Id = fflib_IDGenerator.generate(Contact.SObjectType),
            FirstName = FIRST_NAME,
            LastName = LAST_NAME,
            Email = EMAIL
        );
        List<Contact> relatedContacts = new List<Contact>{ relatedContact };
        Set<Id> contactIds = new Set<Id>{ relatedContact.Id };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUow = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAccountContactRelationsSelector acrSelectorMock = (IAccountContactRelationsSelector) mocks.mock(
            IAccountContactRelationsSelector.class
        );
        mocks.startStubbing();
        mocks.when(acrSelectorMock.SObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(acrSelectorMock.selectAccountContactRelationsByContactIds(contactIds))
            .thenReturn(new List<AccountContactRelation>());
        mocks.stopStubbing();
        Application.SELECTOR.setMock(acrSelectorMock);
        Application.UnitOfWork.setMock(mockUow);

        ContactAndAcrCreateServiceImpl contactService = new ContactAndAcrCreateServiceImpl();
        contactService.deserializeContactInfo(coninfo);

        contactService.findOrCreateAcr(relatedContacts, new List<Contact>());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{ AccountContactRelation.AccountId => Account_ID }
                )
            );
    }
    @isTest
    private static void testWhenContactPayloadReceivedThenUpdateAcr() {
        List<String> coninfo = mockContactInfo();
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
        Contact relatedContact = new Contact(
            Id = contactId,
            FirstName = FIRST_NAME,
            LastName = LAST_NAME,
            Email = EMAIL
        );
        List<Contact> relatedContacts = new List<Contact>{ relatedContact };
        Set<Id> contactIds = new Set<Id>{ contactId };
        AccountContactRelation acr = new AccountContactRelation(
            Id = fflib_IDGenerator.generate(AccountContactRelation.SObjectType),
            ContactId = contactId,
            AccountId = ACCOUNT_ID
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUow = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAccountContactRelationsSelector acrSelectorMock = (IAccountContactRelationsSelector) mocks.mock(
            IAccountContactRelationsSelector.class
        );
        mocks.startStubbing();
        mocks.when(acrSelectorMock.SObjectType()).thenReturn(AccountContactRelation.SObjectType);
        mocks.when(acrSelectorMock.selectAccountContactRelationsByContactIds(contactIds))
            .thenReturn(new List<AccountContactRelation>{ acr });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(acrSelectorMock);
        Application.UnitOfWork.setMock(mockUow);

        ContactAndAcrCreateServiceImpl contactService = new ContactAndAcrCreateServiceImpl();
        contactService.deserializeContactInfo(coninfo);

        contactService.findOrCreateAcr(relatedContacts, new List<Contact>());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        AccountContactRelation.Roles => 'Business Admin;Legal Contact'
                    }
                )
            );
    }
    /**
     * @description Creates a mock ContactInfo JSON string.
     * @return  A list containing the mock ContactInfo JSON string.
     */
    public static List<String> mockContactInfo() {
        Map<String, Object> jsonMap = new Map<String, Object>{
            'SSN' => null,
            'phone' => PHONE,
            'lastName' => LAST_NAME,
            'firstName' => FIRST_NAME,
            'email' => EMAIL,
            'address' => null,
            'accountIdToRoles' => new Map<String, String>{
                ACCOUNT_ID => 'Business Admin;Legal Contact'
            }
        };
        return new List<String>{ JSON.serialize(jsonMap) };
    }

    /**
     * @description To test when Similar Contacts exits the update existing Contacts.
     */
    @isTest
    private static void testWhenSimilarContactsExistsThenUpdateExistingContacts() {
        ContactDto dto = new ContactDto();
        Contact existingContact = (Contact) new Fake(Contact.class)
            .setField(Contact.Id, fflib_IDGenerator.generate(Contact.SObjectType))
            .setField(Contact.FirstName, FIRST_NAME)
            .setField(Contact.LastName, LAST_NAME)
            .setField(Contact.Email, EMAIL)
            .toSObject();
        List<String> coninfo = setMockContactInfoWrapperForOnboardingInputs();
        dto.deserialize(coninfo);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UnitOfWork.setMock(mockUOW);
        Test.startTest();
        ContactAndAcrCreateServiceImpl contactService = new ContactAndAcrCreateServiceImpl();
        contactService.deserializeContactInfo(coninfo);
        contactService.searchAndCreateRelatedContacts(new List<Contact>{ existingContact });
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }
}