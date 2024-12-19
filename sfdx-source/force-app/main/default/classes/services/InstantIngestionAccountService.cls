/**
 * @author Deloitte
 * @date 05/15/2024
 * @description Service class for InstantIngestionAccountServiceImpl.
 */
public inherited sharing class InstantIngestionAccountService {
    /**
     * @description It is used to create the Business Account from the Payload.
     * @param payload
     * @param submarketId
     * @param integrationTypeByUUID
     * @return Account
     */
    public static Account createBusinessAccount(
        InstantIngestionPayloadParser payload,
        String submarketId,
        String integrationTypeByUUID
    ) {
        return service().createBusinessAccount(payload, submarketId, integrationTypeByUUID);
    }

    /**
     * @description It is used to create the Business Account from the SSOB Payload.
     * @param payload
     * @param parsedpayload
     * @return Account
     */
    public static Account createBusinessAccountSSOB(
        String payload,
        SSOBOnboardingPayloadParser parsedpayload
    ) {
        return service().createBusinessAccountSSOB(payload, parsedpayload);
    }

    /**
     * @description It is used to create the Brand using the Payload and Account.
     * @param account
     * @return Brand__c
     */
    public static Brand__c createBrand(Account account) {
        return service().createBrand(account);
    }

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
    public static Account createStoreAccount(
        InstantIngestionPayloadParser payload,
        Id brandId,
        Account businessAccount,
        Business_Vertical__c businessVertical,
        String submarketId
    ) {
        return service()
            .createStoreAccount(payload, BrandId, businessAccount, businessVertical, submarketId);
    }

    /**
     * @description It is used to create an instance of InstantIngestionAccountService class.
     * @return IInstantIngestionAccountService - return instance of InstantIngestionAccountServiceImpl
     */
    private static IInstantIngestionAccountService service() {
        return (IInstantIngestionAccountService) Application.Service.newInstance(
            IInstantIngestionAccountService.class
        );
    }
}