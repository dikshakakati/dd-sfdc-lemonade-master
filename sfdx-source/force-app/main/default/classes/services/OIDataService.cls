/**
 * @author Deloitte
 * @date 06/03/2024
 * @description Service class for "Onboarding Inputs" related logic.
 */
public inherited sharing class OIDataService implements IHandleOnboardingActivationsEvents {
    /**
     * @description It allows OnboardingActivationsEvents handler to
     * pass events to the service class corresponding to a topic.
     * @param onboardingActivationsEvents
     */
    public static void execute(List<Onboarding_Activation__e> onboardingActivationsEvents) {
        service().handleOnboardingActivationsEvents(onboardingActivationsEvents);
    }

    /**
     * @description It fetches the Contract Info.
     * @JIRA# LEM-15116
     * @param contractId
     * @param onboardingScenario
     * @return ContractInfoWrapper
     */
    public static ContractInfoWrapper fetchContractDetails(
        String contractId,
        String onboardingScenario
    ) {
        return service().fetchContractDetails(contractId, onboardingScenario);
    }

    /**
     * @description It fetches State and Country picklist values with dependencies.
     * @return Map<String, List<String>> - Country to List of States
     */
    public static Map<String, List<String>> fetchCountryStatePicklistValues() {
        return service().fetchCountryStatePicklistValues();
    }

    /**
     * @description It fetches the OI metadata records based on the passed parameters.
     * @JIRA# LEM-15116
     * @param productsOnContract - Products on contract's subscription
     * @param onboardingScenario - Onboarding Scenario
     * @param repCollectingOnMxBehalf - Yes, No value based on Rep fill or Mx Fill
     * @param formType - Sales Form, Mx Form
     * @return OISectionAttributeWrapper
     */
    public static OISectionAttributeWrapper fetchOIMetadataRecords(
        String productsOnContract,
        String onboardingScenario,
        String repCollectingOnMxBehalf,
        String formType
    ) {
        return service()
            .fetchOIMetadataRecords(
                productsOnContract,
                onboardingScenario,
                repCollectingOnMxBehalf,
                formType
            );
    }

    /**
     * @description It fetches the translated OI Metadata record Info based on Mx Form Language.
     * @JIRA# LEM-24213
     * @param productsOnContract - Products on contract's subscription
     * @param onboardingScenario - Onboarding Scenario
     * @param repCollectingOnMxBehalf - Yes, No value based on Rep fill or Mx Fill
     * @param formType - Sales Form, Mx Form
     * @param formLanguage - Mx Form Language
     * @return OISectionAttributeWrapper
     */
    public static OISectionAttributeWrapper fetchOIMetadataRecords(
        String productsOnContract,
        String onboardingScenario,
        String repCollectingOnMxBehalf,
        String formType,
        String formLanguage
    ) {
        return service()
            .fetchOIMetadataRecords(
                productsOnContract,
                onboardingScenario,
                repCollectingOnMxBehalf,
                formType,
                formLanguage
            );
    }

    /**
     * @description It fetches the metadata for country attributes
     * @JIRA# LEM-18246
     * @return Map<String, Country_Attributes_Mapping__mdt>
     */
    public static Map<String, Country_Attributes_Mapping__mdt> fetchCountryAttributesMetadata() {
        return service().fetchCountryAttributesMetadata();
    }

    /**
     * @description It is used to get active Mx Onboarding link record.
     * @JIRA# LEM-15116
     * @param contractId
     * @return Mx_Onboarding_Link__c
     */
    public static Mx_Onboarding_Link__c getActiveMxOnboardingLink(Id contractId) {
        return service().getActiveMxOnboardingLink(contractId);
    }

    /**
     * @description It saves Mx Onboarding link records.
     * @JIRA# LEM-15116
     * @param oiMainDataWrapperJSON
     * @return Mx_Onboarding_Link__c
     */
    public static Mx_Onboarding_Link__c saveMxOnboardingLinkRecord(String oiMainDataWrapperJSON) {
        return service().saveMxOnboardingLinkRecord(oiMainDataWrapperJSON);
    }

    /**
     * @description It converts the passed JSON data into different sObject records.
     * @JIRA# LEM-15116
     * @param oiMainDataWrapperJSON
     * @param mxOnboardingLinkId
     * @return Boolean
     */
    public static Boolean saveMxFormDetails(String oiMainDataWrapperJSON, Id mxOnboardingLinkId) {
        return service().saveMxFormDetails(oiMainDataWrapperJSON, mxOnboardingLinkId);
    }

    /**
     * @description It fetches the Opportunity based on Onboarding Scenario.
     * @JIRA# LEM-24785
     * @param contractId
     * @param accountId
     * @param onboardingScenario
     * @return String
     */
    public static String fetchOpportunityBasedOnOnboardingScenario(
        String contractId,
        String accountId,
        String onboardingScenario
    ) {
        return service()
            .fetchOpportunityBasedOnOnboardingScenario(contractId, accountId, onboardingScenario);
    }
    /**
     * @description It creates instance of OIDataServiceImpl class.
     * @return IOIDataService - instance of OIDataServiceImpl
     */
    private static IOIDataService service() {
        return (IOIDataService) Application.Service.newInstance(IOIDataService.class);
    }
}