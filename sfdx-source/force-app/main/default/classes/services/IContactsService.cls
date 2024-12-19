/**
 * @description Interface for Service Class of the Contact object
 */
public interface IContactsService {
    /**
     * @description This method returns the contact Id with an error message when the contact DOB/SSN values ​​are blank and the store's corporate parent
     * having subscriptions to alcohol delivery or alcohol pickup and the store has eligible billing country or billing state.
     * @param accountIdToContacts
     * @return Map<Id, String>
     */
    Map<Id, String> validateSSNAndBirthdate(Map<Id, List<Contact>> accountIdToContacts);

    /**
     * @description It is used to to update encrypted Cassie Id fields on migrated Contacts.
     * @param contactsToUpdate
     */
    void updateEncryptedCassieIdFieldsOnMigratedContacts(List<Contact> contactsToUpdate);
}