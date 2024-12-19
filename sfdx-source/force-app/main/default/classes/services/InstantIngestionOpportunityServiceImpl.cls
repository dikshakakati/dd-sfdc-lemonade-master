/**
 * @author Deloitte
 * @date 05/07/2024
 * @description Service implementation class for InstantIngestionOpportunityService.
 */
public inherited sharing class InstantIngestionOpportunityServiceImpl implements IInstantIngestionOpportunityService {
    private static final String MXP_EVENT_TYPE_ADS_AND_PROMOS = 'Mx Portal Ads And Promos';
    private static final String MXP_EVENT_TYPE_NEW_STORE_EXPANSION = 'Mx Portal New Store Expansion';
    private static final String OPPORTUNITY_TYPE_NEW = 'New';
    private static final String OPPORTUNITY_TYPE_EXISTING = 'Existing';
    private static final String OPPORTUNITY_SUB_TYPE_NET_NEW_PARTNER = 'Net New Partner';
    private static final String OPPORTUNITY_SUB_TYPE_NEW_STORE_EXPANSION = 'New Store Expansion';
    private static final String OPPORTUNITY_SUB_TYPE_UPGRADE = 'Upgrade';
    private static final String OPPORTUNITY_SUB_TYPE_ADS_PROMOS = 'Ads & Promos';
    private static final String OPPORTUNITY_STAGE_NEGOTIATING = 'Negotiating';
    private static final String OPPORTUNITY_STAGE_CLOSED_WON = 'Closed Won';
    private static final String OPPORTUNITY_LEAD_SOURCE = 'Get.doordash.com';
    private static final String OPPORTUNITY_SOURCE_MX_PORTAL = 'Mx Portal';
    private static final String OPPORTUNITY_SOURCE_SSOB = 'SSOB';
    private static final String OPPORTUNITY_SOURCE_SSOB_EXISTING = 'Existing SSOB';
    private static final String OPPORTUNITY_DEAL_TYPE_STANDARD = 'Standard';
    private static final String OPPORTUNITY_DEAL_TYPE_SELF_SERVE = 'Self-Serve';

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
    @SuppressWarnings('PMD.CyclomaticComplexity,PMD.ExcessiveParameterList')
    public Opportunity createOpportunity(
        InstantIngestionPayloadParser payload,
        SSOBOnboardingPayloadParser ssobpayload,
        Account businessAccount,
        Contact contact,
        String source,
        Id ingestionLogId
    ) {
        Opportunity opportunity = new Opportunity();
        opportunity.StageName = OPPORTUNITY_STAGE_NEGOTIATING;
        opportunity.Unique_Identifier__c = source.contains(OPPORTUNITY_SOURCE_SSOB)
            ? ssobpayload.uuid
            : payload.Uuid;
        opportunity.CloseDate = System.today();
        opportunity.Type = source == OPPORTUNITY_SOURCE_MX_PORTAL ||
            source == OPPORTUNITY_SOURCE_SSOB_EXISTING
            ? OPPORTUNITY_TYPE_EXISTING
            : OPPORTUNITY_TYPE_NEW;
        opportunity.Opportunity_Sub_Type__c = source == OPPORTUNITY_SOURCE_MX_PORTAL ||
            source == OPPORTUNITY_SOURCE_SSOB_EXISTING
            ? OPPORTUNITY_SUB_TYPE_UPGRADE
            : OPPORTUNITY_SUB_TYPE_NET_NEW_PARTNER;
        opportunity.AccountId = businessAccount.Id;
        opportunity.CurrencyIsoCode = businessAccount.CurrencyIsoCode;
        opportunity.LeadSource = OPPORTUNITY_LEAD_SOURCE;
        opportunity.Source__c = source == OPPORTUNITY_SOURCE_SSOB_EXISTING
            ? OPPORTUNITY_SOURCE_SSOB
            : source;
        opportunity.Deal_Type__c = OPPORTUNITY_DEAL_TYPE_STANDARD;
        opportunity.Store_Id__c = !source.contains(OPPORTUNITY_SOURCE_SSOB)
            ? payload.store.storeId
            : '';
        opportunity.Ingestion_log_Id__c = String.valueOf(ingestionLogId);
        if (
            payload?.store?.numberOfAddressableLocations != null &&
            !source.contains(OPPORTUNITY_SOURCE_SSOB)
        ) {
            opportunity.Estimated_Number_of_Stores__c = Integer.valueOf(
                InstantIngestionEnumMappingsService.getEstimatedStore(
                    payload.store.numberOfAddressableLocations
                )
            );
        }
        if (source == MXP_EVENT_TYPE_NEW_STORE_EXPANSION) {
            opportunity.Opportunity_Sub_Type__c = OPPORTUNITY_SUB_TYPE_NEW_STORE_EXPANSION;
            opportunity.Type = OPPORTUNITY_TYPE_EXISTING;
            opportunity.Source__c = OPPORTUNITY_SOURCE_MX_PORTAL;
            opportunity.StageName = OPPORTUNITY_STAGE_CLOSED_WON;
        }
        if (source == OPPORTUNITY_SOURCE_SSOB) {
            opportunity.Activation_Notes__c = ssobpayload.opportunity.activationNotes;
            opportunity.Estimated_Number_of_Stores__c = ssobpayload.opportunity.contractDetails.ofAddressableLocations;
            opportunity.Custom_Notes_to_Display_on_Invoice__c = ssobpayload.opportunity.invoicingInformation;
        }
        return opportunity;
    }

    /**
     * @description It is used to create an amendment Opportunity from the payload received via mx portal.
     * @JIRA #16260
     * @param eachParsedMxPortalPayload
     * @param accountforAssociation
     * @param integrationType
     * @param ingestionLogId
     * @return Opportunity
     */
    public Opportunity createAmendmentOpportunityForMxPortal(
        MxPortalPayloadParser eachParsedMxPortalPayload,
        Account accountforAssociation,
        String integrationType,
        Id ingestionLogId
    ) {
        Opportunity amendmentOpportunity = new Opportunity();
        amendmentOpportunity.StageName = OPPORTUNITY_STAGE_NEGOTIATING;
        amendmentOpportunity.Unique_Identifier__c = eachParsedMxPortalPayload.Uuid;
        amendmentOpportunity.CloseDate = System.today();
        amendmentOpportunity.Type = OPPORTUNITY_TYPE_EXISTING;
        amendmentOpportunity.Opportunity_Sub_Type__c = integrationType ==
            MXP_EVENT_TYPE_ADS_AND_PROMOS
            ? OPPORTUNITY_SUB_TYPE_ADS_PROMOS
            : OPPORTUNITY_SUB_TYPE_UPGRADE;
        amendmentOpportunity.AccountId = accountforAssociation.Id;
        amendmentOpportunity.CurrencyIsoCode = accountforAssociation.CurrencyIsoCode;
        amendmentOpportunity.Source__c = OPPORTUNITY_SOURCE_MX_PORTAL;
        amendmentOpportunity.Deal_Type__c = integrationType == MXP_EVENT_TYPE_ADS_AND_PROMOS
            ? OPPORTUNITY_DEAL_TYPE_SELF_SERVE
            : OPPORTUNITY_DEAL_TYPE_STANDARD;
        amendmentOpportunity.Store_Id__c = eachParsedMxPortalPayload.store.storeId;
        amendmentOpportunity.Ingestion_log_Id__c = String.valueOf(ingestionLogId);
        return amendmentOpportunity;
    }
}