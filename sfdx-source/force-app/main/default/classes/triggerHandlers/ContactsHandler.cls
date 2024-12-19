/**
 * @author Deloitte
 * @date 16/03/2022
 * @description Contact Object Trigger Handler
 */
public class ContactsHandler extends ApplicationDomainHandler {
    /**
     * @description constructor method
     * @param sObjectList - Contact record list
     */
    public ContactsHandler(List<Contact> sObjectList) {
        super(sObjectList);
        setContextBypass(Contact.SObjectType, ContactsHandler.class);
    }

    /**
     * @description Called to perform before update processing
     * @param existing - The map of old requests
     */
    public override void onBeforeUpdate(Map<Id, SObject> existing) {
        Contacts.newInstance(contactsWithUpdatedPhoneNumbers())
            .validateAndNormalizePhoneNumberFormat();
        Contacts.newInstance(contactsWithChangedBirthdateOrSSN())
            .validateSSNAndBirthdateWithAccountingContactRole();
        List<Contact> contactsFromConvertedLeads = new List<Contact>(
            (List<Contact>) getChangedRecords(new Set<SObjectField>{ Contact.Converted_Lead_Id__c })
        );
        Contacts.newInstance(contactsFromConvertedLeads).processContactsOnLeadConversion(existing);
        CassieIdEncryptionService.encryptCassieId(
            contactsWithUpdatedEmail(),
            'Email',
            'Email_Cassie_ID__c'
        );
        CassieIdEncryptionService.encryptCassieId(
            contactsWithUpdatedSecondaryEmail(),
            'Secondary_Email__c',
            'Secondary_Email_Cassie_ID__c'
        );
        OptOutOfCommunicationsService.updateDoNotCallAndSMSOptedOut(contactsWithUpdatedPhone());
        OptOutOfCommunicationsService.updateDateSMSOptedOutOrIn(contactsWithUpdatedSMSOptedOut());
    }

    /**
     * @description this method used to get changed records.
     * @return List<Contact>
     */
    private List<Contact> contactsWithUpdatedSMSOptedOut() {
        return new List<Contact>(
            (List<Contact>) getChangedRecords(new Set<SObjectField>{ Contact.SMS_Opted_Out__c })
        );
    }

    /**
     * @description this method used to get changed records.
     * @return List<Contact>
     */
    private List<Contact> contactsWithUpdatedEmail() {
        return new List<Contact>(
            (List<Contact>) getChangedRecords(new Set<SObjectField>{ Contact.Email })
        );
    }

    /**
     * @description this method used to get changed records.
     * @return List<Contact>
     */
    private List<Contact> contactsWithUpdatedPhone() {
        return new List<Contact>(
            (List<Contact>) getChangedRecords(new Set<SObjectField>{ Contact.Phone })
        );
    }
    /**
     * @description this method used to get changed records.
     * @return List<Contact>
     */
    private List<Contact> contactsWithUpdatedSecondaryEmail() {
        return new List<Contact>(
            (List<Contact>) getChangedRecords(new Set<SObjectField>{ Contact.Secondary_Email__c })
        );
    }

    /**
     * @description Called to perform before insert processing
     */
    public override void onBeforeInsert() {
        Contacts.newInstance(this.records).validateAndNormalizePhoneNumberFormat();
        CassieIdEncryptionService.encryptCassieId(this.records, 'Email', 'Email_Cassie_ID__c');
        CassieIdEncryptionService.encryptCassieId(
            this.records,
            'Secondary_Email__c',
            'Secondary_Email_Cassie_ID__c'
        );
    }

    /**
     * @description Called to perform after insert processing
     */
    public override void onAfterInsert() {
        SSMOCreateStoreBizRefXrefService.createStoreAccountBusinessReferenceAndXReferenceForSSMOContacts(
            this.records
        );
    }
    /**
     * @description Called to perform after update processing.
     * @param existing - The map of old requests
     */
    public override void onAfterUpdate(Map<Id, SObject> existing) {
        List<Contact> contactsWhereInboundIngestionLogFieldUpdated = getChangedRecords(
            new Set<SObjectField>{ Contact.Inbound_Ingestion_Log__c }
        );
        SSMOCreateStoreBizRefXrefService.createStoreAccountBusinessReferenceAndXReferenceForSSMOContacts(
            contactsWhereInboundIngestionLogFieldUpdated
        );
    }

    /**
     * @description It is used to collect Contacts with changed Birthdate or SSN.
     * @return List<Contact>
     */
    private List<Contact> contactsWithChangedBirthdateOrSSN() {
        return new List<Contact>(
            (List<Contact>) getChangedRecords(
                new Set<SObjectField>{ Contact.Birthdate, Contact.SSN_Last_4Digits__c }
            )
        );
    }
    /**
     * @description this method used to get changed records.
     * @return List<Contact>
     */
    private List<Contact> contactsWithUpdatedPhoneNumbers() {
        Set<SObjectField> phoneFields = SObjectDescribeService.getFieldsByDisplayType(
            Contact.SObjectType,
            Schema.DisplayType.PHONE
        );
        return new List<Contact>((List<Contact>) getChangedRecords(phoneFields));
    }

    /**
     * @description Constructor Class implements fflib_SObjectDomain class
     */
    public class Constructor implements fflib_SObjectDomain.Iconstructable {
        /**
         * @description this method implements construct class in fflib_SObjectDomain
         * @param sObjectList
         * @return ContactsHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new ContactsHandler(sObjectList);
        }
    }
}