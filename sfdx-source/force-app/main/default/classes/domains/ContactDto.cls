/**
 * @author DoorDash
 * @date 06/02/2023
 * @description wrappper for holding contact info for creating contacts and acrs.
 */
@SuppressWarnings('PMD.ExcessivePublicCount')
public class ContactDto {
    public List<contactInfo> contactsInfo;
    /**
     * @description Represents contact information including email, first name, last name, phone number, SSN (Social Security Number),
     * address, and a mapping of account IDs to roles.
     */
    public class ContactInfo {
        public String email;
        public String firstName;
        public String lastName;
        public String phone;
        public String ssn;
        public Address address;
        public Date dateOfBirth;
        public String mobilePhone;
        public String source;
        public Map<String, String> accountIdToRoles;
    }
    /**
     * @description Represents an address including street, city, postal code, country, state, and owner phone.
     */
    public class Address {
        public String street;
        public String city;
        public String postalCode;
        public String country;
        public String state;
        public String ownerPhone;
    }

    private static final String SEPARATOR = System.Label.Separator;
    private static final String SOURCE_ONBOARDING_INPUTS = 'Onboarding Inputs';
    private enum ContactSource {
        ONBOARDING_INPUTS
    }
    private static final Map<String, ContactSource> CONTACT_SOURCES_MAPPINGS = new Map<String, ContactSource>{
        SOURCE_ONBOARDING_INPUTS => ContactSource.ONBOARDING_INPUTS
    };
    Map<String, contact> emailNameIdentifierToContact = new Map<String, contact>();

    /**
     * @description Deserializes a list of contact JSON strings into a list of ContactInfo objects.
     * @param contacts  A list of contact JSON strings.
     * @return List<ContactInfo> A list of deserialized ContactInfo objects.
     */
    public List<ContactInfo> deserialize(List<String> contacts) {
        contactsInfo = new List<contactInfo>();
        for (String eachCon : contacts) {
            if (string.isNotBlank(eachCon)) {
                contactInfo conInfo = (contactInfo) JSON.deserialize(eachCon, contactInfo.class);
                if (checkForMinimumRequiredValues(conInfo)) {
                    contactsInfo.add(conInfo);
                }
            }
        }
        removeDuplicates();
        return contactsInfo;
    }
    private Boolean checkForMinimumRequiredValues(ContactInfo conInfo) {
        Boolean validContact = false;
        if (
            String.isNotBlank(conInfo.FirstName) &&
            (String.isNotBlank(conInfo.Email) || String.isNotBlank(conInfo.Phone))
        ) {
            validContact = true;
        }
        return validContact;
    }
    /**
     * @description Retrieves a set of email addresses from the ContactInfo objects.
     * @return  A set of email addresses.
     */
    public Set<String> getEmailAddress() {
        Set<String> emailAddress = new Set<String>();
        for (contactInfo eachCon : contactsInfo) {
            if (String.isNotBlank(eachCon.email)) {
                emailAddress.add(eachCon.email);
            }
        }
        return emailAddress;
    }
    /**
     * @description Retrieves a set of concatenated first names and last names from the ContactInfo objects.
     * @return  A set of concatenated first names and last names.
     */
    public Set<String> firstAndLastName() {
        Set<String> firstAndLastName = new Set<String>();
        for (contactInfo eachCon : contactsInfo) {
            firstAndLastName.add(eachCon.firstName + eachCon.lastName);
        }
        return firstAndLastName;
    }
    /**
     * @description Retrieves a set of last names from the ContactInfo objects.
     * @return  A set of last names.
     */
    public Set<String> getLastNames() {
        Set<String> lastNames = new Set<String>();
        for (contactInfo eachCon : contactsInfo) {
            if (string.isNotBlank(eachCon.lastName)) {
                lastNames.add(eachCon.lastName);
            }
        }
        return lastNames;
    }
    /**
     * @description Retrieves a set of first names from the ContactInfo objects.
     * @return  A set of first names.
     */
    public Set<String> getFirstNames() {
        Set<String> firstNames = new Set<String>();
        for (contactInfo eachCon : contactsInfo) {
            firstNames.add(eachCon.firstName);
        }
        return firstNames;
    }
    /**
     * @description Searches for existing contacts based on the provided existingContacts list and contactMap,
     * creates new contacts if necessary, and returns a list of newly created contacts.
     * @param existingContacts  A list of existing Contact records.
     * @param contactMap A map of Contact ID to Contact record.
     * @return List<Contact> A list of newly created Contact records.
     */
    public List<Contact> foundAndCreateContact(
        List<Contact> existingContacts,
        Map<Id, contact> contactMap
    ) {
        List<Contact> contacts = new List<Contact>();
        Map<String, contact> emailToContact = new Map<String, contact>();
        Map<String, contact> nameToContact = new Map<String, contact>();
        for (contact eachCon : existingContacts) {
            emailToContact.put(eachCon.email, eachCon);
            nameToContact.put(eachCon.firstName + eachCon.lastName, eachCon);
            emailNameIdentifierToContact.put(
                convertToLowerCase(eachCon.email,eachCon.firstName,eachCon.lastName),
                eachCon
            );
        }
        existingContacts = new List<Contact>();
        for (contactInfo eachCon : contactsInfo) {
            Boolean contactFound = checkIfContactAlreadyPresent(
                eachCon,
                emailToContact,
                nameToContact
            );
            if (!contactFound) {
                contacts.add(createContactInstance(eachCon));
            } else {
                Contact con = getExistingContact(eachCon, emailToContact, nameToContact);
                contactMap.put(con.Id, con);
            }
        }
        return contacts;
    }

    /**
     * @description It is used to check if contact is already present.
     * @param contactInfoRecord
     * @param emailToContact
     * @param nameToContact
     * @return Boolean
     */
    private Boolean checkIfContactAlreadyPresent(
        contactInfo contactInfoRecord,
        Map<String, contact> emailToContact,
        Map<String, contact> nameToContact
    ) {
        String name = contactInfoRecord.firstName + contactInfoRecord.lastName;
        Boolean contactFound;
        switch on CONTACT_SOURCES_MAPPINGS.get(contactInfoRecord.source) {
            when ONBOARDING_INPUTS {
                contactFound = emailNameIdentifierToContact.containsKey(
                    convertToLowerCase(contactInfoRecord.email,
                        contactInfoRecord.firstName,
                        contactInfoRecord.lastName)
                );
            }
            when else {
                contactFound = (!String.isNotblank(contactInfoRecord.email) &&
                    emailToContact.containsKey(contactInfoRecord.email)) ||
                    nameToContact.containsKey(name)
                    ? true
                    : false;
            }
        }
        return contactFound;
    }
    /**
     * @description Creates a new Contact instance based on the provided ContactInfo.
     * @param eachCon  The ContactInfo object containing the contact details.
     * @return contact The created Contact instance.
     */
    private contact createContactInstance(contactInfo eachCon) {
        Contact contactToBeCreated = new Contact(
            FirstName = eachCon.FirstName,
            LastName = eachCon.LastName,
            Email = eachCon.Email,
            Phone = eachCon.Phone,
            AccountId = eachCon.accountIdToRoles != null &&
                eachCon.accountIdToRoles.size() > 0
                ? new List<String>(eachCon.accountIdToRoles.keySet())[0]
                : null
        );
        setContactInstanceForOnboardingInputs(eachCon, contactToBeCreated);
        return contactToBeCreated;
    }
    /**
     * @description Removes duplicate ContactInfo objects from the contactsInfo list.
     * if found duplicates copy roles to the one contact info.
     */
    private void removeDuplicates() {
        Map<String, ContactInfo> searchTextToCon = new Map<String, ContactInfo>();
        for (Integer i = 0; i < contactsInfo.size(); i++) {
            ContactInfo eachCon = contactsInfo[i];
            String seachText = eachCon.firstName + eachCon.lastName + eachCon.email;
            Map<String, String> curretActToRoles = eachCon.accountIdToRoles;
            if (searchTextToCon.containsKey(seachText)) {
                ContactInfo otherCon = searchTextToCon.get(seachText);
                Map<String, String> otherActToRoles = otherCon.accountIdToRoles;
                for (String eachActId : otherActToRoles.keySet()) {
                    if (curretActToRoles.containsKey(eachActId)) {
                        String currentRoles = curretActToRoles.get(eachActId);
                        String otherRoles = otherActToRoles.get(eachActId) + ';' + currentRoles;
                        otherActToRoles.put(eachActId, otherRoles);
                    }
                }
                contactsInfo.remove(i);
            } else {
                searchTextToCon.put(seachText, eachCon);
            }
        }
    }
    /**
     * @description Retrieves the account ID and roles based on the provided searchTexts.
     * @param searchTexts  A set of search texts to retrieve the account ID and roles.
     * @return Map<String, String> A map of account ID to roles.
     */
    public Map<String, String> getAccountIdAndRoles(Set<String> searchTexts) {
        Map<String, String> accountIdToRoles = new Map<String, String>();
        ContactInfo conInfo = getContanctInfo(searchTexts);
        if (conInfo != null) {
            accountIdToRoles = conInfo.accountIdToRoles;
        }
        return accountIdToRoles;
    }

    /**
     * @description It is used to get existing contact based on the ContactWrapper Source.
     * @param contactInfoRecord
     * @param emailToContact
     * @param nameToContact
     * @return Contact
     */
    private Contact getExistingContact(
        contactInfo contactInfoRecord,
        Map<String, contact> emailToContact,
        Map<String, contact> nameToContact
    ) {
        Contact contactToBeReturned;
        switch on CONTACT_SOURCES_MAPPINGS.get(contactInfoRecord.source) {
            when ONBOARDING_INPUTS {
                contactToBeReturned = emailNameIdentifierToContact.get(
                    convertToLowerCase(contactInfoRecord.email,
                        contactInfoRecord.firstName,
                        contactInfoRecord.lastName)
                );
            }
            when else {
                contactToBeReturned = (String.isNotblank(contactInfoRecord.email) &&
                    emailToContact.containsKey(contactInfoRecord.email))
                    ? emailToContact.get(contactInfoRecord.email)
                    : nameToContact.get(contactInfoRecord.firstName + contactInfoRecord.lastName);
            }
        }
        return contactToBeReturned;
    }

    /**
     * @description Retrieves the ContactInfo object based on the provided searchTexts.
     * @param searchTexts  A set of search texts to retrieve the ContactInfo object.
     * @return ContactInfo The ContactInfo object matching the search texts.
     */
    @testVisible
    private ContactInfo getContanctInfo(Set<String> searchTexts) {
        Map<String, ContactInfo> searchFieldToInfo = new Map<String, ContactInfo>();
        for (contactInfo eachCon : contactsInfo) {
            String name = eachCon.firstName + eachCon.lastName;
            SearchFieldToInfo.put(name, eachCon);
            SearchFieldToInfo.put(eachCon.email, eachCon);
        }
        ContactInfo conInfo = null;
        for (String searchText : searchTexts) {
            conInfo = conInfo == null && SearchFieldToInfo.containsKey(searchText)
                ? searchFieldToInfo.get(searchText)
                : conInfo;
        }
        return conInfo;
    }

    /**
     * @description It is used to get Account Id and roles for Onboarding Inputs.
     * @JIRA# LEM-18245
     * @param searchText
     * @return Map<String, String>
     */
    public Map<String, String> getAccountIdAndRolesForOnboardingInputs(String searchText) {
        Map<String, ContactInfo> searchFieldToInfo = new Map<String, ContactInfo>();
        for (ContactInfo eachContactInfo : contactsInfo) {
            String key =
                convertToLowerCase(eachContactInfo.email,
                eachContactInfo.firstName,
                eachContactInfo.lastName);
            searchFieldToInfo.put(key, eachContactInfo);
        }
        ContactInfo contactInfo = searchFieldToInfo.containsKey(searchText)
            ? searchFieldToInfo.get(searchText)
            : null;
        return contactInfo == null ? new Map<String, String>() : contactInfo.accountIdToRoles;
    }

    /**
     * @description It is used to set Contact Instance when source is Onboarding Inputs.
     * @JIRA# LEM-18245
     * @param contactInfoInstance
     * @param contactToBeCreated
     */
    private void setContactInstanceForOnboardingInputs(
        ContactInfo contactInfoInstance,
        Contact contactToBeCreated
    ) {
        if (contactInfoInstance.source != SOURCE_ONBOARDING_INPUTS) {
            return;
        }
        contactToBeCreated.AccountId = contactInfoInstance.accountIdToRoles != null &&
            contactInfoInstance.accountIdToRoles.size() > 0
            ? new List<String>(contactInfoInstance.accountIdToRoles.keySet())[
                  contactInfoInstance.accountIdToRoles.size() - 1
              ]
            : null;
        if (String.isNotBlank(String.valueOf(contactInfoInstance.dateOfBirth))) {
            contactToBeCreated.Birthdate = contactInfoInstance.dateOfBirth;
        }
        if (String.isNotBlank(contactInfoInstance.mobilePhone)) {
            contactToBeCreated.MobilePhone = contactInfoInstance.mobilePhone;
        }
        if (String.isNotBlank(contactInfoInstance.ssn)) {
            contactToBeCreated.SSN_Last_4Digits__c = contactInfoInstance.ssn;
        }
        if (String.isNotBlank(String.valueOf(contactInfoInstance.address))) {
            setMailingAddressOnContact(contactInfoInstance, contactToBeCreated);
        }
    }

    /**
     * @description It is used to set Mailing Address on Contact.
     * @JIRA# LEM-18245
     * @param contactInfoInstance
     * @param contactToBeCreated
     */
    private void setMailingAddressOnContact(
        ContactInfo contactInfoInstance,
        Contact contactToBeCreated
    ) {
        contactToBeCreated.MailingCountryCode = contactInfoInstance.address.country;
        contactToBeCreated.MailingStateCode = contactInfoInstance.address.state;
        contactToBeCreated.MailingStreet = contactInfoInstance.address.street;
        contactToBeCreated.MailingCity = contactInfoInstance.address.city;
        contactToBeCreated.MailingPostalCode = contactInfoInstance.address.postalCode;
    }

    /**
     * @description It is used to convert the contact details to lower case
     * @JIRA# LEM-18245
     * @param email
     * @param firstName
     * @param lastName
     * @return String
     */
    private String convertToLowerCase(
        String email,
        String firstName,
        String lastName
    ) {
        return (email + SEPARATOR + firstName + SEPARATOR + lastName).toLowerCase();
    }
}