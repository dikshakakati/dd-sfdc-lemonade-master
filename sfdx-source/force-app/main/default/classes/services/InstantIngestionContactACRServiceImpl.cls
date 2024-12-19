/**
 * @author Deloitte
 * @date 05/15/2024
 * @description Service implementation class for Contact creation from payload related logic.
 *
 */
public inherited sharing class InstantIngestionContactACRServiceImpl implements IInstantIngestionContactACRService {
    private static final String CONTACT_SOURCE_INTEGRATION = 'Integration';
    private static final String CONTACT_EVENT_TYPE_ONBOARDING = 'Onboarding Event';
    private static final String CONTACT_EVENT_TYPE_SSOB_ONBOARDING = 'SSOB Onboarding Event';
    private static final String VALID = 'Valid';
    private static final String INVALID = 'Invalid';
    private static final String BOOLEAN_TRUE = 'true';
    private static final String SOURCE_SSOB = 'SSOB';
    private static final String CONTACT = 'contact';
    private static final String DECISION_MAKER = 'Decision Maker';
    private static final String ACCOUNTING_CONTACT = 'Accounting Contact';
    private static final String SEMICOLON_DELIMITER = ';';

    /**
     * @description It is used to create the Contact using the Payload and Account
     * @param payload
     * @param accountRecord
     * @return Contact
     */
    public Contact createContact(InstantIngestionPayloadParser payload, Account accountRecord) {
        Contact contact = new Contact();
        contact.FirstName = payload.merchantOwner.firstName;
        contact.LastName = payload.merchantOwner.lastName;
        contact.Email = payload.merchantOwner.email;
        contact.MobilePhone = payload.merchantOwner.mobilePhone;
        contact.AccountId = accountRecord.Id;
        contact.Contact_Source__c = CONTACT_SOURCE_INTEGRATION;
        contact.Event_Type__c = CONTACT_EVENT_TYPE_ONBOARDING;
        contact.Unique_Identifier__c = payload.Uuid;
        contact.Email_Verification_Status__c = payload.store.hasValidEmail ? VALID : INVALID;
        return contact;
    }
    /**
     * @description It is used to create the Contact using the SSOB Payload and Account
     * @param account
     * @param payload
     * @param parsedPayload
     * @return List<Contact>
     */
    public List<Contact> createContactForSSOB(
        Account account,
        String payload,
        SSOBOnboardingPayloadParser parsedPayload
    ) {

        List<Contact> contacts = new List<Contact>();
        String verificationStatus = parsedPayload.opportunity.hasValidEmail ? VALID : INVALID;
        if (parsedPayload.contact.accounting.email == parsedPayload.contact.decisionMaker.email) {
            contacts.add(
                new Contact(
                    FirstName = parsedPayload.contact.decisionMaker.firstName,
                    LastName = parsedPayload.contact.decisionMaker.lastName,
                    Email = parsedPayload.contact.decisionMaker.email,
                    Integration_Contact_Type__c = DECISION_MAKER+SEMICOLON_DELIMITER+ACCOUNTING_CONTACT,
                    Event_Type__c = CONTACT_EVENT_TYPE_SSOB_ONBOARDING,
                    AccountId = account.Id,
                    Email_Verification_Status__c = verificationStatus,
                    Unique_Identifier__c = parsedpayload.uuid,
                    MobilePhone = parsedPayload.contact.decisionMaker.mobilePhone,
                    Phone = parsedPayload.contact.decisionMaker.phone
                )
            );
        } else {
            contacts.add(
                new Contact(
                    FirstName = parsedPayload.contact.decisionMaker.firstName,
                    LastName = parsedPayload.contact.decisionMaker.lastName,
                    Email = parsedPayload.contact.decisionMaker.email,
                    Integration_Contact_Type__c = DECISION_MAKER,
                    Event_Type__c = CONTACT_EVENT_TYPE_SSOB_ONBOARDING,
                    AccountId = account.Id,
                    Email_Verification_Status__c = verificationStatus,
                    Unique_Identifier__c = parsedpayload.uuid,
                    MobilePhone = parsedPayload.contact.decisionMaker.mobilePhone,
                    Phone = parsedPayload.contact.decisionMaker.phone
                )
            );
            contacts.add(
                new Contact(
                    FirstName = parsedPayload.contact.accounting.firstName,
                    LastName = parsedPayload.contact.accounting.lastName,
                    Email = parsedPayload.contact.accounting.email,
                    Integration_Contact_Type__c = ACCOUNTING_CONTACT,
                    Event_Type__c = CONTACT_EVENT_TYPE_SSOB_ONBOARDING,
                    AccountId = account.Id,
                    Email_Verification_Status__c = verificationStatus,
                    Unique_Identifier__c = parsedpayload.uuid,
                    MobilePhone = parsedPayload.contact.accounting.mobilePhone,
                    Phone = parsedPayload.contact.accounting.phone
                )
            );
        }
        return contacts;
    }

    /**
     * @description It is used to create the AccountContactRelation using the Payload,
     * the passed Account,businessAccount, Contact and ContactRole.
     * @param storeAccount
     * @param businessAccount
     * @param contactRecord
     * @param contactRole
     * @return AccountContactRelation
     */
    public List<AccountContactRelation> createACR(
        Account storeAccount,
        Account businessAccount,
        Contact contactRecord,
        String contactRole
    ) {
        List<AccountContactRelation> accountContactRelations = new List<AccountContactRelation>();
        if(!storeAccount.Is_Additional_Store__c){
            accountContactRelations = createBusinessACR(businessAccount,contactRecord,contactRole);
        }
        if (storeAccount != null && contactRecord != null && ( storeAccount.Unique_Identifier__c !=null && contactRecord.Unique_Identifier__c != null && storeAccount.Unique_Identifier__c == contactRecord.Unique_Identifier__c) && String.isNotBlank(contactRole)) {
            accountContactRelations.add(
                new AccountContactRelation(
                    AccountId = storeAccount.Id,
                    ContactId = contactRecord.Id,
                    Roles = String.isNotBlank(contactRole) ? contactRole : ''
                )
            );
        }
        return accountContactRelations;
    }

    /**
     * @description It is used to create the AccountContactRelation using the Payload,
     * the passed businessAccount, Contact and ContactRole.
     * @param businessAccount
     * @param contactRecord
     * @param contactRole
     * @return List<AccountContactRelation>
     */
    public List<AccountContactRelation> createBusinessACR(Account businessAccount,Contact contactRecord,String contactRole){
        List<AccountContactRelation> accountContactRelations = new List<AccountContactRelation>();
        if (businessAccount != null && contactRecord != null && (businessAccount.Id != contactRecord.AccountId) && String.isNotBlank(contactRole)) {
            accountContactRelations.add(
                new AccountContactRelation(
                    AccountId = businessAccount.Id,
                    ContactId = contactRecord.Id,
                    Roles = String.isNotBlank(contactRole) ? contactRole : ''
                )
            );
        }
        return accountContactRelations;
    }
}