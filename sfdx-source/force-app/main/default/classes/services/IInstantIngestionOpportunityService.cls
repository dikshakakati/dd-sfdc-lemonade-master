/**
 * @author Deloitte
 * @date 05/15/2024
 * @description Interface class for InstantIngestionOpportunityService.
 */
@SuppressWarnings('PMD.ExcessiveParameterList')
public interface IInstantIngestionOpportunityService {
    /**
     * @description It is used to create Opportunity from the Payload.
     * @param payload
     * @param ssobpayload
     * @param accountRecord
     * @param contact
     * @param source
     * @param ingestionLogId
     * @return Opportunity
     */
    Opportunity createOpportunity(
        InstantIngestionPayloadParser payload,
        SSOBOnboardingPayloadParser ssobpayload,
        Account accountRecord,
        Contact contact,
        String source,
        Id ingestionLogId
    );

    /**
     * @description It is used to create an amendment opportunity from the details received within the
     * mx portal payload.
     * @param eachParsedMxPortalPayload
     * @param accountforAssociation
     * @param integrationType
     * @param ingestionLogId
     * @return Opportunity
     */
    Opportunity createAmendmentOpportunityForMxPortal(
        MxPortalPayloadParser eachParsedMxPortalPayload,
        Account accountforAssociation,
        String integrationType,
        Id ingestionLogId
    );
}