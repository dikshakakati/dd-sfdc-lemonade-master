/**
 * @author DoorDash
 * @date 06/02/2023
 * @description it is reusable class for creating contacts and respective acrs based on the roles by account.
 * The process will be running async because making callout to check existing contacts.
 * This service can be called without making callout by modifying.
 */
public class ContactAndAcrCreateService {
    private static IContactAndAcrCreateService service() {
        return (IContactAndAcrCreateService) Application.SERVICE.newInstance(
            IContactAndAcrCreateService.class
        );
    }
    /**
     * @description Processes the contacts payload by handling existing contacts, searching and creating related contacts,
     * and finding or creating associated ACRs (Account Contact Relationships).
     * @param contactsInfo  A List of contact information in serialized form.
     */
    @future
    public static void processContactsPayloadAsyncly(List<String> contactsInfo) {
        service().processContactsPayloadAsyncly(contactsInfo);
    }

    /**
     * @description Processes the contacts payload by handling existing contacts, searching and creating related contacts,
     * and finding or creating associated ACRs (Account Contact Relationships) Synchronously.
     * @JIRA# LEM-18245
     * @param contactsInfo  A List of contact information in serialized form.
     */
    public static void processContactsPayloadSync(List<String> contactsInfo) {
        service().processContactsPayloadAsyncly(contactsInfo);
    }
}