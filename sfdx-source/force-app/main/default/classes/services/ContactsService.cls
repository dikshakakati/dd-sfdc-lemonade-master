/**
 * @author Deloitte
 * @date 02/11/2022
 * @description Service Class for Contact Object
 */
public with sharing class ContactsService {
    /**
     * @description This method returns the contact Id with an error message when the contact DOB/SSN values ​​are blank and the store's corporate parent
     * having subscriptions to alcohol delivery or alcohol pickup and the store has eligible billing country or billing state.
     * @param accountIdToContacts
     * @return Map<Id, String>
     */
    public static Map<Id, String> validateSSNAndBirthdate(
        Map<Id, List<Contact>> accountIdToContacts
    ) {
        return service().validateSSNAndBirthdate(accountIdToContacts);
    }

    /**
     * @description It is used to to update encrypted Cassie Id fields on migrated Contacts.
     * @param contactsToUpdate
     */
    public static void updateEncryptedCassieIdFieldsOnMigratedContacts(
        List<Contact> contactsToUpdate
    ) {
        service().updateEncryptedCassieIdFieldsOnMigratedContacts(contactsToUpdate);
    }

    /**
     * @description It creates instance of ContactServiceImpl class.
     * @return IContactsService - return instance of ContactServiceImpl
     */
    private static IContactsService service() {
        return (IContactsService) Application.SERVICE.newInstance(IContactsService.class);
    }
}