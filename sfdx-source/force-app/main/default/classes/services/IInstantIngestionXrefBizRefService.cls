/**
 * @author Deloitte
 * @date 05/15/2024
 * @description Interface class for InstantIngestionXrefBizRefService.
 */
@SuppressWarnings('PMD.ExcessiveParameterList')
public interface IInstantIngestionXrefBizRefService {
    /**
     * @description It is used to create the business references from the Payload.
     * @param payload
     * @param ssobPayload
     * @param brandId
     * @param currencyIsoCode
     * @param businessVertical
     * @param source
     * @return Business_Reference__c
     */
    Business_Reference__c createBusinessReference(
        InstantIngestionPayloadParser payload,
        SSOBOnboardingPayloadParser ssobPayload,
        Id brandId,
        String currencyIsoCode,
        Business_Vertical__c businessVertical,
        String source
    );

    /**
     * @description It is used to create the xrefs from the Payload.
     * @param payload
     * @param ssobPayload
     * @param businessAccount
     * @param storeAccount
     * @param businessReference
     * @param source
     * @return Xref__c
     */
    Xref__c createXref(
        InstantIngestionPayloadParser payload,
        SSOBOnboardingPayloadParser ssobPayload,
        Account businessAccount,
        Account storeAccount,
        Business_Reference__c businessReference,
        String source
    );
}