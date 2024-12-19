/**
 * @author Deloitte
 * @date 05/14/2024
 * @description Service Class for Injestion Inbound log Contact update
 */
public inherited sharing class SSMOFalloutContactsService {
    /**
     * @description  It is used to get the Inbound Injestion log Ids from the contact and
     * process creation of ACR, OCR, Opportunity and Task records.
     * @param contactsWhereInboundInjestionLogFieldUpdated
     */
    public static void createRelatedRecordsBasedOnSSMOPayload(
        List<Contact> contactsWhereInboundInjestionLogFieldUpdated
    ) {
        service()
            .createRelatedRecordsBasedOnSSMOPayload(contactsWhereInboundInjestionLogFieldUpdated);
    }

    /**
     * @description It creates instance of SSMOFalloutContactsServiceImpl class.
     * @return ISSMOFalloutContactsService - return instance of SSMOFalloutContactsServiceImpl
     */
    private static ISSMOFalloutContactsService service() {
        return (ISSMOFalloutContactsService) Application.SERVICE.newInstance(
            ISSMOFalloutContactsService.class
        );
    }
}