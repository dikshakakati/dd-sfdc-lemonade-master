/**
 * @author Deloitte
 * @date 06/13/2024
 * @description Selector class for OISectionCondition__mdt custom metadata.
 */
public without sharing class OISectionConditionsSelector extends fflib_SObjectSelector implements IOISectionConditionsSelector {
    /**
     * @description default constructor for the class
     * @return IOISectionConditionsSelector - interface of IOISectionConditionsSelector
     */
    public static IOISectionConditionsSelector newInstance() {
        return (IOISectionConditionsSelector) Application.Selector.newInstance(
            OISectionCondition__mdt.SObjectType
        );
    }

    /**
     * @description It is used for getting Object type.
     * @return SObjectType - object type of metadata
     */
    public Schema.SObjectType getSObjectType() {
        return OISectionCondition__mdt.SObjectType;
    }

    /**
     * @description It is for getting the fields on OISectionCondition__mdt.
     * @return List<Schema.SObjectField> - OISectionCondition__mdt fields.
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            OISectionCondition__mdt.Alcohol__c,
            OISectionCondition__mdt.DeveloperName,
            OISectionCondition__mdt.Form_Type__c,
            OISectionCondition__mdt.Is_it_Store_Section__c,
            OISectionCondition__mdt.Onboarding_Scenario__c,
            OISectionCondition__mdt.Order_Protocol__c,
            OISectionCondition__mdt.Products_on_Contract__c,
            OISectionCondition__mdt.Rep_Filling_on_Mx_Behalf__c,
            OISectionCondition__mdt.Seattle__c,
            OISectionCondition__mdt.Section__c,
            OISectionCondition__mdt.Payment_Method__c,
            OISectionCondition__mdt.Store_Section_For_No_Rep_Scenario__c
        };
    }

    /**
     * @description It is for getting the records for OISectionCondition__mdt.
     * @param productsOnContract - products on contract's subscription semicolon seperated
     * @param onboardingScenario - Onboarding Scenario
     * @param repCollectingOnMxBehalf - Yes, No value based on Rep fill or Mx Fill
     * @param formType - Sales form, Mx Form
     * @return OISectionCondition__mdt - records of metadata
     */
    @SuppressWarnings('PMD.UnusedLocalVariable')
    public List<OISectionCondition__mdt> fetchOIMetadataRecords(
        String productsOnContract,
        String onboardingScenario,
        String repCollectingOnMxBehalf,
        String formType
    ) {
        String searchKeyMatcher = String.escapeSingleQuotes(productsOnContract);
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Mx_Input_Not_Needed__c')
            .setCondition(
                'Products_on_Contract__c =:searchKeyMatcher AND ' +
                    'Onboarding_Scenario__c = :onboardingScenario AND ' +
                    'Rep_Filling_on_Mx_Behalf__c = :repCollectingOnMxBehalf AND ' +
                    'Form_Type__c = :formType'
            );
        //.setOrdering('Order__c', fflib_QueryFactory.SortOrder.ASCENDING);
        new OIAttributesConfigsSelector()
            .addQueryFactorySubselect(query, 'OIAttributesConfigs__r')
            .selectField('Attribute_HelpText__c')
            .selectField('OIAttribute__r.Data_Type__c')
            .selectField('OIAttribute__r.Decimal_Places__c')
            .selectField('OIAttribute__r.DeveloperName')
            .selectField('OIAttribute__r.Field_API_Name__c')
            .selectField('OIAttribute__r.Field_length__c')
            .selectField('OIAttribute__r.Field_Name__c')
            .selectField('OIAttribute__r.Picklist_Values__c')
            .selectField('OISectionCondition__r.Store_Section_For_No_Rep_Scenario__c')
            .selectField('OIAttributesValidation__r.Action__c')
            .selectField('OIAttributesValidation__r.Allow_Not_Allow_value__c')
            .selectField('OIAttributesValidation__r.Custom_Code__c')
            .selectField('OIAttributesValidation__r.DeveloperName')
            .selectField('OIAttributesValidation__r.FieldConditionOperator__c')
            .selectField('OIAttributesValidation__r.FieldConditionValue__c')
            .selectField('OIAttributesValidation__r.FieldSource__c')
            .selectField('OIAttributesValidation__r.FieldTocheck__c')
            .selectField('OIAttributesValidation__r.Object_Name__c')
            .selectField('OIAttributesValidation__r.Validation_Type__c')
            .setOrdering('Attribute_Order__c', fflib_QueryFactory.SortOrder.ASCENDING);

        return (List<OISectionCondition__mdt>) Database.query(query.toSOQL());
    }
}