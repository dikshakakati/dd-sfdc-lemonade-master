/**
 * @author Deloitte
 * @date   07/05/2024
 * @description This is the service class to create Store account,
 * Business Reference and Xreference for contact object creation from SSMO Payload.
 */
public inherited sharing class SSMOCreateStoreBizRefXrefService implements ISSMOCreateStoreBizRefXrefService {
    /**
     * @description default constructor for the class
     * @return ISSMOCreateStoreBizRefXrefService - interface of SSMOCreateStoreBizRefXrefService
     */
    public static ISSMOCreateStoreBizRefXrefService service() {
        return (ISSMOCreateStoreBizRefXrefService) Application.Service.newInstance(
            ISSMOCreateStoreBizRefXrefService.class
        );
    }

    /**
     * @description It is used to create store account, BizRef and XRef for SSMO Contacts.
     * @param contactsWhereInboundIngestionLogFieldUpdated
     */
    public static void createStoreAccountBusinessReferenceAndXReferenceForSSMOContacts(
        List<Contact> contactsWhereInboundIngestionLogFieldUpdated
    ) {
        service()
            .createStoreAccountBusinessReferenceAndXReferenceForSSMOContacts(
                contactsWhereInboundIngestionLogFieldUpdated
            );
    }
}