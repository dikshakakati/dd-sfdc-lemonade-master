/**
 * @author Deloitte
 * @date 16/03/2022
 * @description Interface to add Contact Selector class methods
 */
public interface IContactsSelector extends fflib_ISObjectSelector {
    /**
     * @description This method is used for getting Contacts based on ID
     * @param setIds - Set of Ids
     * @return List of Contacts
     */
    List<Contact> selectById(Set<Id> setIds);

    /**
     * @description Retrieves Contacts by the inputted IDs with the fields from the FieldSet
     * @param fieldSet
     * @param contactIds
     * @return List<Contact>
     **/
    List<Contact> selectContactsByIdAndFieldSet(Schema.FieldSet fieldSet, Set<Id> contactIds);

    /**
     * @description It is used to get the Contacts where Account_Team_Member_Id__c is populated
     * and Created Date is less than today.
     * @return List<Contact>
     */
    Database.QueryLocator selectByAccountTeamMemberId();

    /**
     * @description This is used for getting contacts by firstName , last Name and email.
     * @param firstName
     * @param lastName
     * @param email
     * @return Database.QueryLocator
     */
    List<Contact> selectContactByEmailFirstNameLastName(
        Set<String> firstName,
        Set<String> lastName,
        Set<String> email
    );
    /**
     * @description select dummy contact for templatized emails
     * @return Contact
     */
    Contact selectDummyContact();

    /**
     * @description It is used to get Contact record by uniqueIdentifiers.
     * @param uniqueIdentifiers
     * @return List<Contact>
     */
    List<Contact> selectContactsByUniqueIdentifier(Set<String> uniqueIdentifiers);

    /**
     * @description Retrieves Contact details dynamically from a FieldSet
     * @param fieldSet
     * @param contactIds
     * @return List<Contact>
     **/
    List<Contact> selectByIdsAndFieldSet(Schema.FieldSet fieldSet, Set<Id> contactIds);

    /**
     * @description It is used to get Contact record by passed Account Ids.
     * @param accountIds
     * @return List<Contact>
     */
    List<Contact> selectContactsByAccountIds(Set<Id> accountIds);


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
    List<contact> selectContactByEmailFirstNameLastNameAccountIds(
        Set<String> firstName,
        Set<String> lastName,
        Set<String> email,
        Id storeAccountId,
        Id businessAccountId
    );

    /**
     * @description select dummy contact for No Reply email
     * @param contactIds
     * @return List<Contact>
     */
    List<Contact> selectDummyContactByRecordId(Set<Id> contactIds);

    /**
     * @description Select migrated Contacts where Cassie Ids are null.
     * @return Database.QueryLocator
     */
    Database.QueryLocator selectLegacyContactsWithCassieIdsAsNull();
}