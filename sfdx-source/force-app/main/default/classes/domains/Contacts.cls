/**
 * @author Deloitte
 * @date 16/03/2022
 * @description Domain Class for Contact Object
 */
public inherited sharing class Contacts extends fflib_SObjects implements IContacts {
    private static final String COMMA = ',';
    private static final String FORWARDSLASH_R = '\r';
    private static final String FORWARDSLASH_N = '\n';
    private static final String FORWARDSLASH_R_N = '\r\n';
    private static final String CONTACT_SOBJECT_TYPE = 'Contact';
    private static final String LOG_FIELD_MAPPING_ERROR = 'Lead to Contact conversion field mapping is empty.';
    private static final String LOG_DOMAIN = 'Sales';
    private static List<StaticResource> leadConversionFieldsMappingStaticResource;
    fflib_ISObjectUnitOfWork unitOfWork = Application.UNITOFWORK.newInstance();

    /**
     * @description This method is to return the IContacts interface
     * @param recordList - Contacts record list
     * @return IContacts - Returns IContacts Interface
     */
    public static IContacts newInstance(List<Contact> recordList) {
        return (IContacts) Application.Domain.newInstance(recordList);
    }

    static {
        leadConversionFieldsMappingStaticResource = StaticResourcesSelector.newInstance()
            .selectByName(System.Label.LeadConversionFieldsMapping);
    }

    /**
     * @description default constructor for the class
     * @param sObjectList
     */
    public Contacts(List<Contact> sObjectList) {
        super(sObjectList, Schema.Contact.SObjectType);
    }

    /**
     * @description This method used to validate phone number.
     */
    public void validateAndNormalizePhoneNumberFormat() {
        Set<Schema.SObjectField> phoneFields = SObjectDescribeService.getFieldsByDisplayType(
            Contact.SObjectType,
            schema.displaytype.PHONE
        );
        List<Country_Attributes_Mapping__mdt> countryAttributes = CountryAttributesMappingSelector.newInstance()
            .getAllValues();
        Map<String, Country_Attributes_Mapping__mdt> countryToCountryAttributes = new Map<String, Country_Attributes_Mapping__mdt>();
        Map<String, Country_Attributes_Mapping__mdt> phoneCodesToCountryAttributes = new Map<String, Country_Attributes_Mapping__mdt>();
        Set<Id> contactAccountId = new Set<Id>();
        for (Contact objContact : (List<Contact>) getRecordsWithNotBlankFieldValues(phoneFields)) {
            if (objContact.AccountId != null) {
                contactAccountId.add(objContact.AccountId);
            }
        }
        Map<Id, Account> idsToaccount = new Map<Id, Account>();
        idsToaccount.putAll(
            (List<Account>) AccountsSelector.newInstance().selectById(contactAccountId)
        );

        for (Country_Attributes_Mapping__mdt countryAttribute : countryAttributes) {
            countryToCountryAttributes.put(countryAttribute.Country_Code__c, countryAttribute);
            phoneCodesToCountryAttributes.put(
                countryAttribute.Phone_Country_Code__c,
                countryAttribute
            );
        }
        for (Contact objContact : (List<Contact>) getRecordsWithNotBlankFieldValues(phoneFields)) {
            String billingCountryCode = '';
            for (SObjectField phoneField : phoneFields) {
                if (objContact.get(phoneField) != null) {
                    if (idsToaccount.get(objContact.AccountId)?.BillingCountryCode != null) {
                        billingCountryCode = idsToaccount.get(objContact.AccountId)
                            .BillingCountryCode;
                    }
                    PhoneValidation.validationOnPhoneFields(
                        objContact,
                        phoneField,
                        countryToCountryAttributes,
                        phoneCodesToCountryAttributes,
                        billingCountryCode
                    );
                }
            }
        }
    }
    /**
     * @description This method used to validate phone number and SSN field for a Contact having Accounting Contact role the store's corporate parent
     * having subscriptions to alcohol delivery or alcohol pickup and the store has eligible billing country or billing state.
     */
    public void validateSSNAndBirthdateWithAccountingContactRole() {
        if (UserInfo.getUserName().startsWithIgnoreCase(System.Label.NintexUserName)) {
            return;
        }
        Map<Id, Contact> contactIdToContacts = new Map<Id, Contact>((List<Contact>) getRecords());
        Map<Id, List<Contact>> accountIdToContacts = new Map<Id, List<Contact>>();
        Map<Id, Contact> contactsToValidate = new Map<Id, Contact>();
        for (
            AccountContactRelation eachACR : AccountContactRelationsSelector.newInstance()
                .selectAllAccountContactRelationsHavingAccountingContactRoleWithContact(
                    contactIdToContacts.keySet()
                )
        ) {
            if (!accountIdToContacts.containsKey(eachACR.Accountid)) {
                accountIdToContacts
                    .put(
                        eachACR.Accountid,
                        new List<Contact>{ contactIdToContacts.get(eachACR.ContactId) }
                    );
            }
            accountIdToContacts.get(eachACR.Accountid)
                .add(contactIdToContacts.get(eachACR.ContactId));
            if (!contactsToValidate.containsKey(eachACR.ContactId)) {
                contactsToValidate.put(
                    eachACR.ContactId,
                    contactIdToContacts.get(eachACR.ContactId)
                );
            }
        }
        Map<Id, String> contactIdToErrorMessage = ContactsService.validateSSNAndBirthdate(
            accountIdToContacts
        );
        for (Contact eachContact : contactsToValidate.values()) {
            if (contactIdToErrorMessage.containsKey(eachContact.Id)) {
                eachContact.addError(contactIdToErrorMessage.get(eachContact.Id));
            }
        }
    }
    /**
     * @description It collects Lead to Contact conversion field mapping from
     * static resource file.
     * @return Map<String, String>
     */
    private Map<String, String> collectFields() {
        List<String> contactFieldMappings = new List<String>();
        Map<String, String> contactFieldToIsUpdatable = new Map<String, String>();
        Blob blobCSV = leadConversionFieldsMappingStaticResource[0].Body;
        String csvString = blobCSV.toString();
        // Normalize line endings to Unix-style
        csvString = csvString.replace(FORWARDSLASH_R_N, FORWARDSLASH_N)
            .replace(FORWARDSLASH_R, FORWARDSLASH_N);
        String[] fieldMappings = csvString.split(FORWARDSLASH_N);
        if (fieldMappings.isEmpty()) {
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                    LOG_FIELD_MAPPING_ERROR,
                    LOG_DOMAIN,
                    GenericLogEntry.SeverityLevel.LOW
                )
            );
            return contactFieldToIsUpdatable;
        }
        fieldMappings.remove(0);
        for (String eachFieldMapping : fieldMappings) {
            // Trim to remove any trailing carriage return character
            contactFieldMappings = eachFieldMapping.trim().split(COMMA);
            if (contactFieldMappings[0] == CONTACT_SOBJECT_TYPE) {
                contactFieldToIsUpdatable.put(contactFieldMappings[1], contactFieldMappings[2]);
            }
        }
        return contactFieldToIsUpdatable;
    }
    /**
     * @description It is used to process contacts post lead conversion.
     * @param existing
     */
    public void processContactsOnLeadConversion(Map<Id, SObject> existing) {
        Map<String, String> contactFieldToIsUpdatable = new Map<String, String>();
        contactFieldToIsUpdatable = collectFields();
        for (Contact eachContact : (List<Contact>) getRecords()) {
            for (String eachContactField : contactFieldToIsUpdatable.keySet()) {
                if (Boolean.valueOf(contactFieldToIsUpdatable.get(eachContactField))) {
                    if (
                        ((Contact) existing.get(eachContact.Id)).get(eachContactField) == '' ||
                        ((Contact) existing.get(eachContact.Id)).get(eachContactField) == null
                    ) {
                        continue;
                    }
                }
                eachContact.put(
                    eachContactField,
                    ((Contact) existing.get(eachContact.Id)).get(eachContactField)
                );
            }
        }
    }
    /**
     * @description This method is for implementing constructor in fflib_IDomainConstructor class
     */
    public class Constructor implements fflib_IDomainConstructor {
        /**
         * @description constructor menthod implementation from fflib_IDomainConstructor class
         * @param objectList
         * @return Contacts - List of Contacts
         */
        public fflib_SObjects construct(List<Object> objectList) {
            return new Contacts((List<SObject>) objectList);
        }
    }
}