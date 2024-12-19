/**
 * @author DoorDash
 * @date 06/02/2023
 * @description it is reusable class for creating contacts and respective acrs based on the roles by account.
 * The process will be running async because making callout to check existing contacts.
 * This service can be called without making callout by modifying.
 */
public class ContactAndAcrCreateServiceImpl implements IContactAndAcrCreateService {
    ContactDto dto = new ContactDto();
    fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    private static final String SEPARATOR = System.Label.Separator;
    private static final String SOURCE_ONBOARDING_INPUTS = 'Onboarding Inputs';
    private string contactCreationSource;

    /**
     * @description Processes the contacts payload by handling existing contacts, searching
     * and creating related contacts, and finding or creating associated ACRs (Account Contact Relationships).
     * @param contactsInfo  A List of contact information in serialized form.
     */
    public void processContactsPayload(List<String> contactsInfo) {
        List<Contact> existingContacts = getExistingContacts(contactsInfo);
        List<Contact> relatedContacts = searchAndCreateRelatedContacts(existingContacts);
        // Find or create ACRs (Account Contact Relationships) for the related contacts and existing contacts
        findOrCreateAcr(relatedContacts, existingContacts);
    }
    /**
     * @description Processes the contacts payload by handling existing contacts, searching and creating related contacts,
     * and finding or creating associated ACRs (Account Contact Relationships).
     * @param contactsInfo  A List of contact information in serialized form.
     */
    public void processContactsPayloadAsyncly(List<String> contactsInfo) {
        try {
            processContactsPayload(contactsInfo);
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
        }
    }
    @testVisible
    private void deserializeContactInfo(List<String> contactsInfo) {
        dto.deserialize(contactsInfo);
        contactCreationSource = dto.contactsInfo.size() > 0 ? dto.contactsInfo[0]?.source : null;
    }
    /**
     * @description Retrieves the existing Contact records based on the provided contact information.
     * deserialize contact info received as paylaod.
     * @param contactsInfo  A List of contact information in serialized form.
     * @return  List<Contact> A List of existing Contact records.
     */
    private List<Contact> getExistingContacts(List<String> contactsInfo) {
        deserializeContactInfo(contactsInfo);
        List<Contact> existingcons = ContactsSelector.newInstance()
            .selectContactByEmailFirstNameLastName(
                dto.getFirstNames(),
                dto.getLastNames(),
                dto.getEmailAddress()
            );
        return existingcons;
    }
    /**
     * @description Searches for related contacts based on the existing contacts and creates new contacts if necessary.
     * Returns a list of final contacts including the newly created contacts and the related contacts.
     * Make call out to check for existing contact baased on the fuzzy match use salesforce service.
     * @param existingContacts  A List of existing Contact records.
     * @return  List<Contact>  A List of final Contact records.
     */
    @testVisible
    private List<Contact> searchAndCreateRelatedContacts(List<Contact> existingContacts) {
        Map<Id, contact> existingRelatedContactMap = new Map<Id, contact>();
        List<Contact> finalContacts = new List<Contact>();
        List<Contact> cons = dto.foundAndCreateContact(existingContacts, existingRelatedContactMap);
        for (Contact eachCon : cons) {
            // make a call out to salesforce service to check duplicates
            if (
                test.isrunningTest() ||
                Datacloud.FindDuplicates.findDuplicates(new List<Contact>{ eachCon }).size() > 0
            ) {
                uow.registerNew(eachCon);
                finalContacts.add(eachCon);
            }
        }
        updateContactsForOnboardingInputs(existingRelatedContactMap.values());
        uow.commitWork();
        uow = Application.UnitOfWork.newInstance();
        finalContacts.addAll(existingRelatedContactMap.values());
        return finalContacts;
    }
    /**
     * @description Finds or creates AccountContactRelations (ACRs) for the related contacts and existing contacts.
     * Update roles by account if updating acrs.
     * @param relatedContacts  A List of related Contact records.
     * @param existingContacts   A List of existing Contact records.
     */
    @testVisible
    private void findOrCreateAcr(List<Contact> relatedContacts, List<Contact> existingContacts) {
        Set<Id> contactIds = new Set<Id>();
        existingContacts.addAll(relatedContacts);
        for (contact eachCon : existingContacts) {
            contactIds.add(eachCon.Id);
        }
        Map<String, AccountContactRelation> contActIdToAcr = new Map<String, AccountContactRelation>();
        for (
            AccountContactRelation eachAcr : AccountContactRelationsSelector.newInstance()
                .selectAccountContactRelationsByContactIds(contactIds)
        ) {
            contActIdToAcr.put(getTrimmedString(eachAcr.contactId, eachAcr.accountId), eachAcr);
        }
        for (contact eachCon : relatedContacts) {
            // use payload contact info to search created info like roles and account Ids.
            Map<String, String> accountIdToRoles = getAccountIdAndRoles(eachCon);
            for (String accountId : accountIdToRoles.keySet()) {
                String roles = accountIdToRoles.get(accountId);
                String contactToAccountId = getTrimmedString(eachCon.Id, accountId);
                findOrCreateAcrByAccountType(
                    contactToAccountId,
                    contActIdToAcr,
                    accountId,
                    eachCon.Id,
                    roles
                );
            }
        }
        uow.commitWork();
        uow = Application.UnitOfWork.newInstance();
    }
    /**
     * @description Finds or creates an AccountContactRelation (ACR) based on the account type.
     * @param conIdToActId  The string representing the concatenated Contact ID and Account ID.
     * @param contActIdToAcr A map of Contact ID and Account ID to AccountContactRelation.
     * @param actId  The Account ID.
     * @param contactId  The Contact ID.
     * @param roles The roles associated with the ACR.
     */
    @testVisible
    private void findOrCreateAcrByAccountType(
        String conIdToActId,
        Map<String, AccountContactRelation> contActIdToAcr,
        Id actId,
        Id contactId,
        String roles
    ) {
        if (contActIdToAcr.containsKey(conIdToActId)) {
            updateAcr(contActIdToAcr.get(conIdToActId), roles);
        } else {
            uow.registerNew(
                new AccountContactRelation(
                    ContactId = contactId,
                    isActive = true,
                    AccountId = actId,
                    Roles = roles
                )
            );
        }
    }

    /**
     * @description It is used to get trimmed Contact Id to Account Id.
     * @param contactId
     * @param accountId
     * @return String
     */
    private String getTrimmedString(String contactId, String accountId) {
        contactId = String.isNotBlank(contactId) && contactId.length() > 15
            ? contactId.substring(0, 15)
            : contactId;
        accountId = String.isNotBlank(accountId) && accountId.length() > 15
            ? accountId.substring(0, 15)
            : accountId;
        return contactId + accountId;
    }
    /**
     * @description Updates an AccountContactRelation (ACR) with the provided roles.
     * @param acr The AccountContactRelation to update.
     * @param roles The roles to update the ACR with.
     */
    @testVisible
    private void updateAcr(AccountContactRelation acr, String roles) {
        // Split the provided roles into a list and add them to the existing roles list
        List<String> existingRoles = acr.Roles != null ? acr.Roles.split(';') : new List<String>();
        existingRoles.addAll(roles.split(';'));
        Set<String> uniqueRoles = new Set<String>(existingRoles);
        uow.registerDirty(
            new AccountContactRelation(
                Id = acr.Id,
                isActive = true,
                Roles = String.join(new List<String>(uniqueRoles), ';')
            )
        );
    }

    /**
     * @description It is used to get AccountId and roles.
     * @JIRA# LEM-18245
     * @param eachCon
     * @return Map<String, String>
     */
    private Map<String, String> getAccountIdAndRoles(contact eachCon) {
        String searchFieldName = eachCon.FirstName + eachCon.LastName;
        Set<String> searchTexts = new Set<String>{ eachCon.email, searchFieldName };
        if (contactCreationSource != SOURCE_ONBOARDING_INPUTS) {
            return dto.getAccountIdAndRoles(searchTexts);
        }
        return dto.getAccountIdAndRolesForOnboardingInputs(
            convertToLowerCase(eachCon.Email,eachCon.FirstName,eachCon.LastName)
        );
    }

    /**
     * @description It is used to update existing Contacts for Onboarding Inputs.
     * @param existingContacts
     */
    private void updateContactsForOnboardingInputs(List<contact> existingContacts) {
        if (contactCreationSource != SOURCE_ONBOARDING_INPUTS) {
            return;
        }
        Map<String, Contact> emailNameIdentifierToContact = new Map<String, Contact>();
        String emailNameIdentifier;
        for (Contact eachContact : existingContacts) {
            emailNameIdentifierToContact.put(
                convertToLowerCase(eachContact.email,
                    eachContact.firstName,
                    eachContact.lastName),
                eachContact
            );
        }
        for (ContactDto.contactInfo eachContactInfo : dto.contactsInfo) {
            emailNameIdentifier =
                convertToLowerCase(eachContactInfo.email,
                eachContactInfo.firstName,
                eachContactInfo.lastName);
            if (!emailNameIdentifierToContact.containsKey(emailNameIdentifier)) {
                continue;
            }
            Contact contactRecord = emailNameIdentifierToContact.get(emailNameIdentifier);
            contactRecord.Phone = String.isNotBlank(eachContactInfo.Phone)
                ? eachContactInfo.Phone
                : contactRecord.Phone;
            contactRecord.MobilePhone = String.isNotBlank(eachContactInfo.mobilePhone)
                ? eachContactInfo.mobilePhone
                : contactRecord.MobilePhone;
            contactRecord.Birthdate = String.isNotBlank(String.valueOf(eachContactInfo.dateOfBirth))
                ? eachContactInfo.dateOfBirth
                : contactRecord.Birthdate;
            contactRecord.SSN_Last_4Digits__c = String.isNotBlank(eachContactInfo.ssn)
                ? eachContactInfo.ssn
                : contactRecord.SSN_Last_4Digits__c;
            updateAddressOnContact(eachContactInfo, contactRecord);
            uow.registerDirty(contactRecord);
        }
    }

    /**
     * @description It is used to update Address fields on Contact.
     * @JIRA# LEM-20949
     * @param eachContactInfo
     * @param contactRecord
     */
    private void updateAddressOnContact(
        ContactDto.contactInfo eachContactInfo,
        Contact contactRecord
    ) {
        if (String.isNotBlank(eachContactInfo.address.country)) {
            contactRecord.MailingCountryCode = eachContactInfo.address.country;
            contactRecord.MailingStateCode = eachContactInfo.address.state;
            contactRecord.MailingStreet = eachContactInfo.address.street;
            contactRecord.MailingCity = eachContactInfo.address.city;
            contactRecord.MailingPostalCode = eachContactInfo.address.postalCode;
        }
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