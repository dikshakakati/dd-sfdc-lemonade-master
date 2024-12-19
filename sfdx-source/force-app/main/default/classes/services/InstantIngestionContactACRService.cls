/**
 * @author Deloitte
 * @date 05/15/2024
 * @description Service class for InstantIngestionContactACRService.
 */
public inherited sharing class InstantIngestionContactACRService {
    /**
     * @description It is used to create the Contact from the Payload.
     * @param payload
     * @param accountRecord
     * @return Contact
     */
    public static Contact createContact(
        InstantIngestionPayloadParser payload,
        Account accountRecord
    ) {
        return service().createContact(payload, accountRecord);
    }
    /**
     * @description It is used to create the Contact from the SSOB Payload.
     * @param account
     * @param payload
     * @param parsedPayload
     * @return List<Contact>
     */
    public static List<Contact> createContactForSSOB(
        Account account,
        String payload,
        SSOBOnboardingPayloadParser parsedPayload
    ) {
        return service().createContactForSSOB(account, payload, parsedPayload);
    }

    /**
     * @description It is used to create the AccountContactRelation using the Payload and Account.
     * @param storeAccount
     * @param businessAccount
     * @param contact
     * @param contactRole
     * @return AccountContactRelation
     */
    public static List<AccountContactRelation> createACR(
        Account storeAccount,
        Account businessAccount,
        Contact contact,
        String contactRole
    ) {
        return service().createACR(storeAccount, businessAccount, contact, contactRole);
    }

    /**
     * @description It is used to create an instance of InstantIngestionContactACRServiceImpl class.
     * @return InstantIngestionContactACRService - return instance of InstantIngestionContactACRServiceImpl
     */
    private static IInstantIngestionContactACRService service() {
        return (IInstantIngestionContactACRService) Application.Service.newInstance(
            IInstantIngestionContactACRService.class
        );
    }
}