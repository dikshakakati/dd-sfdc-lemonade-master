/**
 * @author Deloitte
 * @date 06/03/2024
 * @description Controller class for OIUserForm lightning web component.
 */
public with sharing class OIDataController {
    /**
     * @description It is used to get active Mx Onboarding link record.
     * @JIRA# LEM-15116
     * @param contractId
     * @return Mx_Onboarding_Link__c
     */
    @AuraEnabled(cacheable=true)
    public static Mx_Onboarding_Link__c getActiveMxOnboardingLink(Id contractId) {
        return OIDataService.getActiveMxOnboardingLink(contractId);
    }

    /**
     * @description It saves Mx Onboarding link records.
     * @JIRA# LEM-15116
     * @param oiMainDataWrapperJSON
     * @return Mx_Onboarding_Link__c
     */
    @AuraEnabled
    public static Mx_Onboarding_Link__c saveMxOnboardingLinkRecord(String oiMainDataWrapperJSON) {
        return OIDataService.saveMxOnboardingLinkRecord(oiMainDataWrapperJSON);
    }

    /**
     * @description It fetches the Contract Info.
     * @JIRA# LEM-15116
     * @param contractId
     * @param onboardingScenario
     * @return ContractInfoWrapper
     */
    @AuraEnabled(cacheable=true)
    public static ContractInfoWrapper fetchContractDetails(
        String contractId,
        String onboardingScenario
    ) {
        return OIDataService.fetchContractDetails(contractId, onboardingScenario);
    }

    /**
     * @description It fetches the OI Metadata record Info.
     * @JIRA# LEM-15116
     * @param productsOnContract - products on contract's subscription semicolon seperated
     * @param onboardingScenario - Onboarding Scenario
     * @param repCollectingOnMxBehalf - Yes, No value based on Rep fill or Mx Fill
     * @param formType - Sales form, Mx Form
     * @return OISectionAttributeWrapper
     */
    @AuraEnabled
    public static OISectionAttributeWrapper fetchOIMetadataRecords(
        String productsOnContract,
        String onboardingScenario,
        String repCollectingOnMxBehalf,
        String formType
    ) {
        return OIDataService.fetchOIMetadataRecords(
            productsOnContract,
            onboardingScenario,
            repCollectingOnMxBehalf,
            formType
        );
    }

    /**
     * @description It fetches the translated OI Metadata record Info based on Mx Form Language.
     * @JIRA# LEM-24213
     * @param productsOnContract - products on contract's subscription semicolon seperated
     * @param onboardingScenario - Onboarding Scenario
     * @param repCollectingOnMxBehalf - Yes, No value based on Rep fill or Mx Fill
     * @param formType - Sales form, Mx Form
     * @param formLanguage - Mx Form Language
     * @return OISectionAttributeWrapper
     */
    @AuraEnabled
    public static OISectionAttributeWrapper fetchOIMetadataRecordsMxForm(
        String productsOnContract,
        String onboardingScenario,
        String repCollectingOnMxBehalf,
        String formType,
        String formLanguage
    ) {
        return OIDataService.fetchOIMetadataRecords(
            productsOnContract,
            onboardingScenario,
            repCollectingOnMxBehalf,
            formType,
            formLanguage
        );
    }

    /**
     * @description It fetches State and Country picklist values with dependencies.
     * @JIRA# LEM-15113
     * @return Map<String, List<String>> - Country to List of States
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, List<String>> fetchCountryStatePicklistValues() {
        return OIDataService.fetchCountryStatePicklistValues();
    }

    /**
     * @description It fetches the metadata for country attributes for all countries.
     * @JIRA# LEM-18246
     * @return Map<String, Country_Attributes_Mapping__mdt> - Country to List of Country_Attributes_Mapping__mdt
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Country_Attributes_Mapping__mdt> fetchCountryAttributesMetadata() {
        return OIDataService.fetchCountryAttributesMetadata();
    }

    /**
     * @description It fetches the Opportunity based on Onboarding Scenario.
     * @JIRA# LEM-24785
     * @param contractId
     * @param accountId
     * @param onboardingScenario
     * @return String
     */
    @AuraEnabled(cacheable=true)
    public static String fetchOpportunityBasedOnOnboardingScenario(
        String contractId,
        String accountId,
        String onboardingScenario
    ) {
        return OIDataService.fetchOpportunityBasedOnOnboardingScenario(
            contractId,
            accountId,
            onboardingScenario
        );
    }
}