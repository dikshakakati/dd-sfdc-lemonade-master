/**
 * @author Deloitte
 * @date 16/03/2022
 * @description Selector Class for Contact Object
 */
public inherited sharing class ContactsSelector extends fflib_SObjectSelector implements IContactsSelector, IEncryptedDataSelector {
    private static final String LEGACY_CONTACT_BATCH_UPDATE_CRITERIA = System.Label.selectLegacyContactsWithCassieIdsAsNull_Query_Condition;
    private static final String SMB = System.Label.AccountSegmentSMB;

    /**
     * @description default constructor for the class
     * @return IContactsSelector - interface of IContactsSelector
     */
    public static IContactsSelector newInstance() {
        return (IContactsSelector) Application.Selector.newInstance(Contact.SObjectType);
    }

    /**
     * @description This method is for getting the fields on Contact object
     * @return Contact- Contact fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Contact.Id,
            Contact.Name,
            Contact.AccountId,
            Contact.Birthdate,
            Contact.Description,
            Contact.SSN_Last_4Digits__c,
            Contact.FirstName,
            Contact.LastName,
            Contact.Email,
            Contact.Count_of_Calls_Outbound_Inbound__c,
            Contact.Count_of_Emails_Sent__c,
            Contact.Event_Type__c,
            Contact.Unique_Identifier__c,
            Contact.Phone,
            Contact.Order_Protocol_Email__c,
            Contact.POS_System__c,
            Contact.SSMO_Matching_Account_Id__c,
            Contact.Menu_URL__c,
            Contact.Business_Id__c,
            Contact.Store_Id__c,
            Contact.Package__c,
            Contact.MailingAddress,
            Contact.Hours_of_Operation__c,
            Contact.Preferred_Language__c,
            Contact.Order_Protocol__c,
            Contact.Primary_Vertical__c,
            Contact.Order_Protocol_Phone__c,
            Contact.Coverage__c,
            Contact.SSMO_Business_Account_Id__c,
            Contact.Integration_Contact_Type__c,
            contact.Submarket__c
        };
    }

    /**
     * @description This method id for getting object type
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Contact.SObjectType;
    }

    /**
     * @description This method is used for getting Contacts based on ID
     * @param setIds Set of Ids
     * @return List of Contacts
     */
    public List<Contact> selectById(Set<Id> setIds) {
        return (List<Contact>) selectSObjectsById(setIds);
    }

    /**
     * @description Retrieves Contacts by the inputted IDs with the fields from the FieldSet
     * @param fieldSet
     * @param contactIds
     * @return List<Contact>
     **/
    public List<Contact> selectContactsByIdAndFieldSet(
        Schema.FieldSet fieldSet,
        Set<Id> contactIds
    ) {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectFieldSet(fieldSet)
            .setCondition('Id IN :contactIds');
        return (List<Contact>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used to get the encrypted data stored in the passed fields
     * by the passed sObjectIds.
     * @JIRA# LEM-2255
     * @param fieldSet
     * @param sobjectIds
     * @return List<SObject>
     */
    public List<SObject> selectEncryptedData(Schema.FieldSet fieldSet, Set<Id> sobjectIds) {
        fflib_QueryFactory contactQuery = newQueryFactory()
            .selectFieldSet(fieldSet)
            .setCondition('Id IN :sobjectIds');
        return (List<Contact>) Database.query(contactQuery.toSOQL());
    }

    /**
     * @description It is used to get the Contacts where Account_Team_Member_Id__c is populated
     * and Created Date is less than today.
     * @JIRA# LEM-5727
     * @return Database.QueryLocator
     */
    public Database.QueryLocator selectByAccountTeamMemberId() {
        fflib_QueryFactory contactQuery = newQueryFactory()
            .setCondition('Account_Team_Member_Id__c != null AND CreatedDate < TODAY');
        return Database.getQueryLocator(contactQuery.toSOQL());
    }

    /**
     * @description This is used for getting contacts by firstName, last Name and email.
     * @param firstName
     * @param lastName
     * @param email
     * @return Database.QueryLocator
     */
    public List<contact> selectContactByEmailFirstNameLastName(
        Set<String> firstName,
        Set<String> lastName,
        Set<String> email
    ) {
        fflib_QueryFactory contactQuery = newQueryFactory()
            .selectField('MobilePhone')
            .setCondition(
                '(FirstName IN: firstName AND ' +
                'LastName IN: lastName) OR ' +
                'Email IN: email'
            );
        return (List<Contact>) Database.query(contactQuery.toSOQL());
    }
    /**
     * @description select dummy contact for templatized emails
     * @return Contact
     */
    public Contact selectDummyContact() {
        fflib_QueryFactory contactQuery = newQueryFactory().setLimit(1);
        return (Contact) Database.query(contactQuery.toSOQL());
    }

    /**
     * @description It is used to get Contact record by Unique Identifier.
     * @param uniqueIdentifiers
     * @return List<Contact>
     */
    public List<Contact> selectContactsByUniqueIdentifier(Set<String> uniqueIdentifiers) {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectField('Id')
            .selectField('AccountId')
            .selectField('Unique_Identifier__c')
            .setCondition('Unique_Identifier__c IN :uniqueIdentifiers')
            .setOrdering('Unique_Identifier__c', fflib_QueryFactory.SortOrder.ASCENDING);
        return (List<Contact>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used to get Contact record by passed Account Ids.
     * @param accountIds
     * @return List<Contact>
     */
    public List<Contact> selectContactsByAccountIds(Set<Id> accountIds) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Id')
            .selectField('Email')
            .selectField('AccountId')
            .selectField('Unique_Identifier__c')
            .setCondition('AccountId IN :accountIds')
            .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.ASCENDING);
        return (List<Contact>) Database.query(query.toSOQL());
    }

    /**
     * @description Retrieves Contact details dynamically from a FieldSet
     * @param fieldSet
     * @param contactIds
     * @return List<Contact>
     **/
    public List<Contact> selectByIdsAndFieldSet(Schema.FieldSet fieldSet, Set<Id> contactIds) {
        fflib_QueryFactory contactQuery = newQueryFactory()
            .selectFieldSet(fieldSet)
            .setCondition('Id IN :contactIds');
        return (List<Contact>) Database.query(contactQuery.toSOQL());
    }

    /**
     * @description - This is used for getting contacts by firstName, last Name and email and AccountID(business and store).
     * @author Soumya Dash | 09-02-2024
     * @param firstName
     * @param lastName
     * @param email
     * @param storeAccountId
     * @param businessAccountId
     * @return List<contact>
     **/
    public List<contact> selectContactByEmailFirstNameLastNameAccountIds(
        Set<String> firstName,
        Set<String> lastName,
        Set<String> email,
        Id storeAccountId,
        Id businessAccountId
    ) {
        fflib_QueryFactory contactQuery = newQueryFactory()
            .selectField('FirstName')
            .selectField('LastName')
            .selectField('Email')
            .selectField('Phone')
            .setCondition(
                '(FirstName IN: firstName AND LastName IN: lastName) AND (AccountId = :businessAccountId OR Account.ParentId = :businessAccountId)'
            );

        new AccountContactRelationsSelector()
            .addQueryFactorySubselect(contactQuery, 'AccountContactRelations')
            .selectField('AccountId')
            .selectField('Roles')
            .setCondition('AccountId = :storeAccountId');

        return (List<Contact>) Database.query(contactQuery.toSOQL());
    }

    /**
     * @description select dummy contact for No reply emails
     * @param contactIds
     * @return List<Contact>
     */
    public List<Contact> selectDummyContactByRecordId(Set<Id> contactIds) {
        fflib_QueryFactory contactQuery = newQueryFactory()
            .selectField('Contact_Name__c')
            .selectField('Email')
            .setCondition('Id IN :contactIds')
            .setLimit(1);
        return (List<Contact>) Database.query(contactQuery.toSOQL());
    }

    /**
     * @description Select migrated Contacts where Cassie Ids are null.
     * @return Database.QueryLocator
     */
    public Database.QueryLocator selectLegacyContactsWithCassieIdsAsNull() {
        fflib_QueryFactory contactQuery = newQueryFactory(false)
            .selectField('Email_Cassie_ID__c')
            .selectField('Contact_Name__c')
            .selectField('Secondary_Email__c')
            .selectField('Secondary_Email_Cassie_ID__c')
            .selectField('Email')
            .setCondition(LEGACY_CONTACT_BATCH_UPDATE_CRITERIA);
        return Database.getQueryLocator(contactQuery.toSOQL());
    }
}