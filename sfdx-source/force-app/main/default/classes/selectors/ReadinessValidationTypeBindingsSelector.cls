/**
 * @author Deloitte
 * @date 09/08/2022
 * @description Selector class for ReadinessValidation_SobjectType_Binding__mdt custom metadata.
 */
public inherited sharing class ReadinessValidationTypeBindingsSelector extends fflib_SObjectSelector implements IReadinessValidationTypeBindingsSelector {
    /**
     * @description Default constructor for the ReadinessValidationTypeBindingsSelector class.
     * @return IReadinessValidationTypeBindingsSelector - interface of IReadinessValidationTypeBindingsSelector
     */
    public static IReadinessValidationTypeBindingsSelector newInstance() {
        return (IReadinessValidationTypeBindingsSelector) Application.Selector.newInstance(
            ReadinessValidation_SobjectType_Binding__mdt.SObjectType
        );
    }

    /**
     * @description It is used for getting ReadinessValidation_SobjectType_Binding__mdt object type.
     * @return SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return ReadinessValidation_SobjectType_Binding__mdt.SObjectType;
    }

    /**
     * @description It is used for getting the fields of ReadinessValidation_SobjectType_Bindings__mdt.
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            ReadinessValidation_SobjectType_Binding__mdt.Sobject_Type_Sub_Type_Mapping__c,
            ReadinessValidation_SobjectType_Binding__mdt.Store_Readiness_Validation_Rule__c
        };
    }
}