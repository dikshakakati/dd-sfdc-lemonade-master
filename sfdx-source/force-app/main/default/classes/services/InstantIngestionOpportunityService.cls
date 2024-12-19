/**
 * @author Deloitte
 * @date 05/15/2024
 * @description Service class for InstantIngestionOpportunityServiceImpl.
 */
public inherited sharing class InstantIngestionOpportunityService {
    /**
     * @description It is used to create the Opportunity from the Payload.
     * @param payload
     * @param ssobpayload
     * @param businessAccount
     * @param contact
     * @param source
     * @param ingestionLogId
     * @return Opportunity
     */
    @SuppressWarnings('PMD.ExcessiveParameterList')
    public static Opportunity createOpportunity(
        InstantIngestionPayloadParser payload,
        SSOBOnboardingPayloadParser ssobpayload,
        Account businessAccount,
        Contact contact,
        String source,
        Id ingestionLogId
    ) {
        return service()
            .createOpportunity(
                payload,
                ssobpayload,
                businessAccount,
                contact,
                source,
                ingestionLogId
            );
    }

    /**
     * @description It is used to create an amendment opportunity from the details received within the
     * mx portal payload.
     * @param eachParsedMxPortalPayload
     * @param accountforAssociation
     * @param integrationType
     * @param ingestionLogId
     * @return Opportunity
     */
    public static Opportunity createAmendmentOpportunityForMxPortal(
        MxPortalPayloadParser eachParsedMxPortalPayload,
        Account accountforAssociation,
        String integrationType,
        Id ingestionLogId
    ) {
        return service()
            .createAmendmentOpportunityForMxPortal(
                eachParsedMxPortalPayload,
                accountforAssociation,
                integrationType,
                ingestionLogId
            );
    }

    /**
     * @description It is used to create an instance of InstantIngestionOpportunityService class.
     * @return IInstantIngestionOpportunityService - return instance of InstantIngestionOpportunityServiceImpl
     */
    private static IInstantIngestionOpportunityService service() {
        return (IInstantIngestionOpportunityService) Application.Service.newInstance(
            IInstantIngestionOpportunityService.class
        );
    }
}