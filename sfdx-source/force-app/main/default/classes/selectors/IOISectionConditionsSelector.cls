/**
 * @author Deloitte
 * @date 06/13/2024
 * @description Interface to add Selector class methods.
 */
public interface IOISectionConditionsSelector extends fflib_ISObjectSelector {
    /**
     * @description It is for getting the fields on OISectionCondition__mdt.
     * @return List<Schema.SObjectField> - OISectionCondition__mdt fields
     */
    List<Schema.SObjectField> getSObjectFieldList();

    /**
     * @description It is for getting the records for OISectionCondition__mdt.
     * @param productsOnContract - products on contract's subscription semicolon seperated
     * @param onboardingScenario - Onboarding Scenario
     * @param repCollectingOnMxBehalf - Yes, No value based on Rep fill or Mx Fill
     * @param formType - Sales form, Mx Form
     * @return OISectionCondition__mdt - records of metadata
     */
    List<OISectionCondition__mdt> fetchOIMetadataRecords(
        String productsOnContract,
        String onboardingScenario,
        String repCollectingOnMxBehalf,
        String formType
    );
}