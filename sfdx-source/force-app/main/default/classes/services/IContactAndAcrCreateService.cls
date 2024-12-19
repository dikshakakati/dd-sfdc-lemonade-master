/**
 * @author DoorDash
 * @date 06/02/2023
 * @description Interface for ContactAndAcrCreateService.
 */
public interface IContactAndAcrCreateService {
    /**
    * @description Processes the contacts payload by handling existing contacts, searching and creating related contacts, 
    * and finding or creating associated ACRs (Account Contact Relationships).
    * @param contactsInfo  A List of contact information in serialized form.
    */
	void processContactsPayloadAsyncly(List<String> contactsInfo);
}