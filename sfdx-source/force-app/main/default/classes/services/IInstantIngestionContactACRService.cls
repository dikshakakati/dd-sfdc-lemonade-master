/**
 * @author Deloitte
 * @date 05/15/2024
 * @description Interface class for InstantIngestionContactACRService.
 */
public interface IInstantIngestionContactACRService {
    /**
     * @description It is used to create the Contact from the Payload.
     * @param payload
     * @param businessAccount
     * @return Contact
     */
    Contact createContact(InstantIngestionPayloadParser payload, Account businessAccount);

    /**
     * @description It is used to create the Contact using the SSOB Payload and Account
     * @param account
     * @param payload
     * @param parsedPayload
     * @return List<Contact>
     */
    List<Contact> createContactForSSOB(
        Account account,
        String payload,
        SSOBOnboardingPayloadParser parsedPayload
    );

    /**
     * @description It is used to create the AccountContactRelation using the Payload and Account.
     * @param storeAccount
     * @param businessAccount
     * @param contact
     * @param contactRole
     * @return AccountContactRelation
     */
    List<AccountContactRelation> createACR(
        Account storeAccount,
        Account businessAccount,
        Contact contact,
        String contactRole
    );
}