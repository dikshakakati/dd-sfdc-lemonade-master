/**
 * @author Deloitte
 * @date 07/05/2024
 * @description Service implementation class for SSMO fallout Store account, Business Reference and XRef creation on Contact.
 */
public interface ISSMOCreateStoreBizRefXrefService {
    /**
     * @description It is used to create store account, BizRef and XRef for SSMO Contacts.
     * @param contactsWhereInboundInjestionLogFieldUpdated
     */
    void createStoreAccountBusinessReferenceAndXReferenceForSSMOContacts(
        List<Contact> contactsWhereInboundInjestionLogFieldUpdated
    );
}