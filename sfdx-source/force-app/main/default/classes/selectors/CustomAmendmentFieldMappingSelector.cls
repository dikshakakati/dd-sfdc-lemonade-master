/**
 * @author Aetheueus
 * @date 29/05/2024
 * @description Selector class for Custom_Amendment_Field_Mapping__mdt custom metadata.
 */
public inherited sharing class CustomAmendmentFieldMappingSelector extends fflib_SObjectSelector implements ICustomAmendmentFieldMappingSelector {
    /**
     * @description Default constructor for the CustomAmendmentFieldMappingSelector class.
     * @return ICustomAmendmentFieldMappingSelector - interface of ICustomAmendmentFieldMappingSelector
     */
    public static ICustomAmendmentFieldMappingSelector newInstance() {
        return (ICustomAmendmentFieldMappingSelector) Application.Selector.newInstance(
            Custom_Amendment_Field_Mapping__mdt.SObjectType
        );
    }

    /**
     * @description It is used for getting Custom_Amendment_Field_Mapping__mdt  object type.
     * @return SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Custom_Amendment_Field_Mapping__mdt.SObjectType;
    }

    /**
     * @description It is used for getting the fields on Custom_Amendment_Field_Mapping__mdt .
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Custom_Amendment_Field_Mapping__mdt.Active__c,
            Custom_Amendment_Field_Mapping__mdt.DeveloperName,
            Custom_Amendment_Field_Mapping__mdt.Field_API_Name__c,
            Custom_Amendment_Field_Mapping__mdt.Type_of_Mapping__c,
            Custom_Amendment_Field_Mapping__mdt.sObject_Type__c,
            Custom_Amendment_Field_Mapping__mdt.Source_Field__c,
            Custom_Amendment_Field_Mapping__mdt.Source_Object__c,
            Custom_Amendment_Field_Mapping__mdt.Static_Value__c
        };
    }

    /**
     * @description It is used for getting all active Custom_Amendment_Field_Mapping__mdt records
     * @return List<Custom_Amendment_Field_Mapping__mdt>
     */
   	public List<Custom_Amendment_Field_Mapping__mdt> selectAllCustomAmendmentFieldsMapping() {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Active__c = True');
        return (List<Custom_Amendment_Field_Mapping__mdt>) Database.query(query.toSOQL());
    }

    /**
      * @description It is used for getting all active Custom_Amendment_Field_Mapping__mdt records whose Source is 'Contract'.
      * @param source
      * @param target
      * @return List<Custom_Amendment_Field_Mapping__mdt>
      */
      public List<Custom_Amendment_Field_Mapping__mdt> selectMappingsBySourceObjectAndTargetObject(String source, String target) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Active__c = True AND Source_Object__c = :source AND sObject_Type__c = :target');
        return (List<Custom_Amendment_Field_Mapping__mdt>) Database.query(query.toSOQL());
    }

}