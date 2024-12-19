/**
 * @author Deloitte
 * @date 06/12/2024
 * @description Selector class for OIAttributesConfig__mdt custom metadata.
 */
public inherited sharing class OIAttributesConfigsSelector extends fflib_SObjectSelector implements IOIAttributesConfigsSelector {
    /**
     * @description default constructor for the class.
     * @return IOIAttributesConfigsSelector - interface of IOIAttributesConfigsSelector
     */
    public static IOIAttributesConfigsSelector newInstance() {
        return (IOIAttributesConfigsSelector) Application.Selector.newInstance(
            OIAttributesConfig__mdt.SObjectType
        );
    }

    /**
     * @description It is used for getting Object type.
     * @return SObjectType - object type of metadata
     */
    public Schema.SObjectType getSObjectType() {
        return OIAttributesConfig__mdt.SObjectType;
    }

    /**
     * @description It is for getting the fields on OIAttributesConfig__mdt.
     * @return List<Schema.SObjectField> - OIAttributesConfig__mdt fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            OIAttributesConfig__mdt.Attribute_HelpText__c,
            OIAttributesConfig__mdt.Attribute_Order__c,
            OIAttributesConfig__mdt.Auto_Applied_To_All_Store__c,
            OIAttributesConfig__mdt.DeveloperName,
            OIAttributesConfig__mdt.Is_PrePopulated__c,
            OIAttributesConfig__mdt.Is_Required__c,
            OIAttributesConfig__mdt.OIAttribute__c,
            OIAttributesConfig__mdt.OIAttributesValidation__c,
            OIAttributesConfig__mdt.OISectionCondition__c
        };
    }
}