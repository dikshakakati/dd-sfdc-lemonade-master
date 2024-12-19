/**
 * @author Deloitte
 * @date 05/15/2024
 * @description Interface class for InstantIngestionAccountService.
 */

public interface IInstantIngestionAccountService {
    /**
     * @description It is used to create the Business Account from the Payload.
     * @param payload
     * @param submarketId
     * @param integrationTypeByUUID
     * @return Account
     */
    Account createBusinessAccount(
        InstantIngestionPayloadParser payload,
        String submarketId,
        String integrationTypeByUUID
    );

    /**
     * @description It is used to create the Business Account from the SSOB Payload.
     * @param payload
     * @param parsedpayload
     * @return Account
     */
    Account createBusinessAccountSSOB(String payload, SSOBOnboardingPayloadParser parsedpayload);

    /**
     * @description It is used to create the Brand using the Payload and Account.
     * @param account
     * @return Brand__c
     */
    Brand__c createBrand(Account account);

    /**
     * @description It is used to create Store Account using the Payload, BrandId,
     * Business Vertical and SubmarketId.
     * @param payload
     * @param brandId
     * @param businessAccount
     * @param businessVertical
     * @param submarketId
     * @return Account
     */
    Account createStoreAccount(
        InstantIngestionPayloadParser payload,
        Id brandId,
        Account businessAccount,
        Business_Vertical__c businessVertical,
        String submarketId
    );
}