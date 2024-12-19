/**
 * @author Deloitte
 * @date 05/15/2024
 * @description Service implementation class for inbound ingestion log update on contact object.
 */
public interface ISSMOFalloutContactsService {
    /**
     * @description  It is used to get the Inbound Injestion log Ids from the contact and
     * process creation of ACR, OCR, Opportunity and Task records based on SSMO payload.
     * @param contactsWhereInboundInjestionLogFieldUpdated
     */
    void createRelatedRecordsBasedOnSSMOPayload(
        List<Contact> contactsWhereInboundInjestionLogFieldUpdated
    );
}