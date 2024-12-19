/**
 * @author DoorDash
 * @date 06/02/2023
 * @description Test class for ContactDTO
 */
@isTest
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
public class ContactDtoTest {
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
    private static final String ERROR_RETURNED_SIZE_DOES_NOT_MATCH = 'Returned Size does not Match';
    private static final Integer RETURNED_SIZE_ONE = 1;
    private static final Integer RETURNED_SIZE_ZERO = 0;
    private static final String SEPARATOR = System.Label.Separator;

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
    static void testWhenContactInfoReceivedThenReturnNecessaryResultsForMethods() {
        ContactDto dto = new ContactDto();
        dto.deserialize(mockContactInfo());
        System.assertEquals(
            EMAIL,
            new List<String>(dto.getEmailAddress())[0],
            'Email address not matching'
        );
        System.assertEquals(
            FIRST_NAME,
            new List<String>(dto.getFirstNames())[0],
            'First Name not matching'
        );
        System.assertEquals(
            LAST_NAME,
            new List<String>(dto.getLastNames())[0],
            'Last name not matching'
        );
        System.assertEquals(
            NAME,
            new List<String>(dto.firstAndLastName())[0],
            'first and last name not matching'
        );
    }
    @isTest
    static void testWhenContactInfoReceivedThenSearchAndCreateNewContact() {
        Contact con = new Contact(
            FirstName = 'TestFirstName',
            LastName = 'TestLastName',
            Email = 'test.test15@doordash.com'
        );
        List<Contact> cons = new List<Contact>{ con };
        ContactDto dto = new ContactDto();
        dto.deserialize(mockContactInfo());
        List<Contact> newCont = dto.foundAndCreateContact(cons, new Map<Id, Contact>());
        System.assertEquals(EMAIL, newCont[0].Email, 'Contact Email address not matching');
    }
    @isTest
    static void testWhenContactInfoReceivedThenSearchAndDoNotCreateContact() {
        Contact con = new Contact(FirstName = FIRST_NAME, LastName = LAST_NAME, Email = EMAIL);
        List<Contact> cons = new List<Contact>{ con };
        ContactDto dto = new ContactDto();
        dto.deserialize(mockContactInfo());
        Map<Id, Contact> conMap = new Map<Id, Contact>();
        dto.foundAndCreateContact(cons, conMap);
        System.assertEquals(EMAIL, conMap.values()[0].Email, 'Contact Email address not matching');
    }

    @isTest
    static void testWhenDuplicateContactInfoReceivedThenRemoveDuplicates() {
        ContactDto dto = new ContactDto();
        List<String> coninfo = mockContactInfo();
        coninfo.addAll(mockContactInfoForRemoveDuplicateTest());
        dto.deserialize(coninfo);

        System.assertEquals(1, dto.contactsInfo.size(), 'Contact info size not matching');
        List<String> roles = dto.contactsInfo[0].accountIdToRoles.values()[0].split(';');
        System.assertEquals(3, (new Set<String>(roles)).size(), 'Number of roles not matching');
    }
    @isTest
    static void testWhenCreatingContactsSearchTextPassedThenReturnAssociatedContactAccountRoleMap() {
        ContactDto dto = new ContactDto();
        List<String> coninfo = mockContactInfo();
        dto.deserialize(coninfo);
        Map<String, String> accountToRoleMap = dto.getAccountIdAndRoles(new Set<String>{ EMAIL });
        List<String> roles = accountToRoleMap.values()[0].split(';');
        System.assertEquals(2, (new Set<String>(roles)).size(), 'Number of roles not matching');
    }
    @isTest
    static void testWhenSearchTextPassedThenReturnAssociatedContactsInfo() {
        ContactDto dto = new ContactDto();
        List<String> coninfo = mockContactInfo();
        dto.deserialize(coninfo);
        ContactDto.ContactInfo emailCon = dto.getContanctInfo(new Set<String>{ EMAIL });
        System.assertEquals(EMAIL, emailCon.Email, 'Contact info email not matching');
        ContactDto.ContactInfo firstNameCon = dto.getContanctInfo(new Set<String>{ NAME });
        System.assertEquals(FIRST_NAME, firstNameCon.FirstName, 'FirstName and not matching');
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
     * @description Creates a mock ContactInfo JSON string.
     * @return  A list containing the mock ContactInfo JSON string.
     */
    public static List<String> mockContactInfoForRemoveDuplicateTest() {
        Map<String, Object> jsonMap = new Map<String, Object>{
            'SSN' => null,
            'phone' => '57474773383838',
            'lastName' => 'Test LastName',
            'firstName' => 'Test FirstName',
            'email' => 'test.test14@doordash.com',
            'address' => null,
            'accountIdToRoles' => new Map<String, String>{
                ACCOUNT_ID => 'Business Admin;Desicion Maker'
            }
        };
        return new List<String>{ JSON.serialize(jsonMap) };
    }

    /**
     * @description To test when non-existing Contact Wrapper is passed then create new
     * Contact Instance.
     */
    @isTest
    private static void testWhenNonExistingContactInfoWrapperPassedThenCreateContactInstance() {
        ContactDto dto = new ContactDto();
        Contact con = new Contact(
            FirstName = 'TestFirstName',
            LastName = 'TestLastName',
            Email = 'test.test15@doordash.com'
        );
        List<Contact> existingContacts = new List<Contact>{ con };
        List<String> contactInfo = setMockContactInfoWrapperForOnboardingInputs();
        dto.deserialize(contactInfo);
        Test.startTest();
        List<Contact> contactsReturned = dto.foundAndCreateContact(
            existingContacts,
            new Map<Id, Contact>()
        );
        Test.stopTest();
        System.assertEquals(
            RETURNED_SIZE_ONE,
            contactsReturned.size(),
            ERROR_RETURNED_SIZE_DOES_NOT_MATCH
        );
    }

    /**
     * @description To test when same contact already exists then do not create Contact Instance.
     */
    @isTest
    private static void testWhenDuplicateContactExistsThenDoNotCreateContactInstance() {
        ContactDto dto = new ContactDto();
        Contact con = new Contact(FirstName = FIRST_NAME, LastName = LAST_NAME, Email = EMAIL);
        List<Contact> existingContacts = new List<Contact>{ con };
        List<String> contactInfo = setMockContactInfoWrapperForOnboardingInputs();
        dto.deserialize(contactInfo);
        Test.startTest();
        List<Contact> contactsReturned = dto.foundAndCreateContact(
            existingContacts,
            new Map<Id, Contact>()
        );
        Test.stopTest();
        System.assertEquals(
            RETURNED_SIZE_ZERO,
            contactsReturned.size(),
            ERROR_RETURNED_SIZE_DOES_NOT_MATCH
        );
    }

    /**
     * @description To test when search text is present in ContactInfo wrapper then return AccountId to roles
     * Map for Onboarding Inputs.
     */
    @isTest
    private static void testWhenSearchTextPassedPresentInContactInfoWrapperThenReturnAccountIdToRolesMap() {
        ContactDto dto = new ContactDto();
        String searchText = EMAIL + SEPARATOR + FIRST_NAME + SEPARATOR + LAST_NAME;
        List<String> contactInfo = setMockContactInfoWrapperForOnboardingInputs();
        dto.deserialize(contactInfo);
        Test.startTest();
        Map<String, String> accountIdToRolesReturned = dto.getAccountIdAndRolesForOnboardingInputs(
            searchText
        );
        Test.stopTest();
        System.assertEquals(
            true,
            accountIdToRolesReturned != null,
            ERROR_RETURNED_SIZE_DOES_NOT_MATCH
        );
    }

    /**
     * @description To test when search text is not present in ContactInfo wrapper then return empty Map
     * for Onboarding Inputs.
     */
    @isTest
    private static void testWhenSearchTextPassedNotPresentInContactInfoWrapperThenReturnEmptyMap() {
        ContactDto dto = new ContactDto();
        String email = 'test.test15@doordash.com';
        String searchText = email + SEPARATOR + FIRST_NAME + SEPARATOR + LAST_NAME;
        List<String> contactInfo = setMockContactInfoWrapperForOnboardingInputs();
        dto.deserialize(contactInfo);
        Test.startTest();
        Map<String, String> accountIdToRolesReturned = dto.getAccountIdAndRolesForOnboardingInputs(
            searchText
        );
        Test.stopTest();
        System.assertEquals(
            true,
            accountIdToRolesReturned.isEmpty(),
            ERROR_RETURNED_SIZE_DOES_NOT_MATCH
        );
    }
}