/**
 * @author Deloitte
 * @date 06/03/2024
 * @description Interface for service class of "Onboarding Inputs" related logic.
 */
public interface IOIDataService extends IRetryableService {
    /**
     * @description It is used to get active Mx Onboarding link record.
     * @param contractId
     * @return Mx_Onboarding_Link__c
     */
    Mx_Onboarding_Link__c getActiveMxOnboardingLink(Id contractId);

    /**
     * @description It saves Mx Onboarding link records.
     * @param oiMainDataWrapperJSON
     * @return Mx_Onboarding_Link__c
     */
    Mx_Onboarding_Link__c saveMxOnboardingLinkRecord(String oiMainDataWrapperJSON);

    /**
     * @description It fetches the Contract Info.
     * @JIRA# LEM-15116
     * @param contractId
     * @param onboardingScenario
     * @return ContractInfoWrapper
     */
    ContractInfoWrapper fetchContractDetails(String contractId, String onboardingScenario);

    /**
     * @description It fetches the OI metadata records based on the passed parameters.
     * @param productsOnContract - Products on contract's subscription
     * @param onboardingScenario - Onboarding Scenario
     * @param repCollectingOnMxBehalf - Yes, No value based on Rep fill or Mx Fill
     * @param formType - Sales Form, Mx Form
     * @return OISectionAttributeWrapper
     */
    OISectionAttributeWrapper fetchOIMetadataRecords(
        String productsOnContract,
        String onboardingScenario,
        String repCollectingOnMxBehalf,
        String formType
    );

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
    OISectionAttributeWrapper fetchOIMetadataRecords(
        String productsOnContract,
        String onboardingScenario,
        String repCollectingOnMxBehalf,
        String formType,
        String formLanguage
    );

    /**
     * @description It fetches State and Country picklist values with dependencies.
     * @return Map<String, List<String>>
     */
    Map<String, List<String>> fetchCountryStatePicklistValues();

    /**
     * @description It converts the passed JSON data into different sObject records.
     * @param oiMainDataWrapperJSON
     * @param mxOnboardingLinkId
     * @return Boolean
     */
    Boolean saveMxFormDetails(String oiMainDataWrapperJSON, Id mxOnboardingLinkId);

    /**
     * @description It is used to retry Onboarding Inputs data creation
     * based on passed Interface Transaction Id.
     * @param transactionId - Interface_Transaction__c record Id
     */
    void retry(String transactionId);

    /**
     * @description It is used to retry Onboarding Inputs data creation
     * based on passed Interface Transaction records.
     * @param interfaceTransactionsForRetry - Interface_Transaction__c records for retry.
     */
    void retry(List<Interface_Transaction__c> interfaceTransactionsForRetry);

    /**
     * @description It is used to handle and route the published OnboardingActivationsEvents.
     * @param onboardingActivationsEvents List of platform events with payload.
     */
    void handleOnboardingActivationsEvents(
        List<Onboarding_Activation__e> onboardingActivationsEvents
    );

    /**
     * @description It fetches the metadata for country attributes
     * @JIRA# LEM-18246
     * @return  Map<String, Country_Attributes_Mapping__mdt>
     */
    Map<String, Country_Attributes_Mapping__mdt> fetchCountryAttributesMetadata();

    /**
     * @description It fetches the Opportunity based on Onboarding Scenario.
     * @JIRA# LEM-24785
     * @param contractId
     * @param accountId
     * @param onboardingScenario
     * @return String
     */
    String fetchOpportunityBasedOnOnboardingScenario(
        String contractId,
        String accountId,
        String onboardingScenario
    );
}