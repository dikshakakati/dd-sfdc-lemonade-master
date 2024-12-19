/**
 * @author Deloitte
 * @date 07/07/2022
 * @description Selector class for Store_Readiness_Validation_Rule__mdt custom metadata.
 */
public inherited sharing class StoreReadinessValidationRulesSelector extends fflib_SObjectSelector implements IStoreReadinessValidationRulesSelector {
    /**
     * @description Default constructor for the StoreReadinessValidationRulesSelector class.
     * @return IStoreReadinessValidationRulesSelector - interface of IStoreReadinessValidationRulesSelector
     */
    public static IStoreReadinessValidationRulesSelector newInstance() {
        return (IStoreReadinessValidationRulesSelector) Application.Selector.newInstance(
            Store_Readiness_Validation_Rule__mdt.SObjectType
        );
    }

    /**
     * @description It is used for getting Store_Readiness_Validation_Rule__mdt object type.
     * @return SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Store_Readiness_Validation_Rule__mdt.SObjectType;
    }

    /**
     * @description It is used for getting the fields on Store_Readiness_Validation_Rule__mdt.
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Store_Readiness_Validation_Rule__mdt.Description__c,
            Store_Readiness_Validation_Rule__mdt.DeveloperName,
            Store_Readiness_Validation_Rule__mdt.Error_Message__c,
            Store_Readiness_Validation_Rule__mdt.Field_Label__c,
            Store_Readiness_Validation_Rule__mdt.Field_Name__c,
            Store_Readiness_Validation_Rule__mdt.Is_Active__c,
            Store_Readiness_Validation_Rule__mdt.Object_Label__c,
            Store_Readiness_Validation_Rule__mdt.Object_Name__c,
            Store_Readiness_Validation_Rule__mdt.Service_Class_Name__c,
            Store_Readiness_Validation_Rule__mdt.Service_Method_Name__c
        };
    }

    /**
     * @description It is used for getting all active Store_Readiness_Validation_Rule__mdt records
     * having service class and method name fields populated.
     * @return List<Store_Readiness_Validation_Rule__mdt>
     */
    public List<Store_Readiness_Validation_Rule__mdt> selectAllValidReadinessValidationRules() {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition(
                'Is_Active__c = true' +
                ' AND Service_Method_Name__c != null' +
                ' AND Service_Class_Name__c != null'
            );
        new ReadinessValidationTypeBindingsSelector()
            .addQueryFactorySubselect(query, 'ReadinessValidationSobjectTypeBindings__r')
            .selectField('Sobject_Type_Sub_Type_Mapping__r.Sub_Type__c')
            .selectField('Sobject_Type_Sub_Type_Mapping__r.Type__c');
        return (List<Store_Readiness_Validation_Rule__mdt>) Database.query(query.toSOQL());
    }
}