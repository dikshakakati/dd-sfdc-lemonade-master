/**
 * @author Deloitte
 * @date 04/08/2024
 * @description Selector class to query activation checklist validation metadata.
 */
public inherited sharing class ActivationChecklistValidationSelector extends fflib_SObjectSelector implements IActivationChecklistValidationSelector {
    private static final Boolean ACTIVE_YES = true;
    /**
     * @description Default constructor for the ActivationChecklistValidationSelector class.
     * @return IActivationChecklistValidationSelector - interface of IActivationChecklistValidationSelector
     */
    public static IActivationChecklistValidationSelector newInstance() {
        return (IActivationChecklistValidationSelector) Application.Selector.newInstance(
            Activation_Checklist_Validation__mdt.SObjectType
        );
    }

    /**
     * @description It is used for getting Activation_Checklist_Validation__mdt object type.
     * @return SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Activation_Checklist_Validation__mdt.SObjectType;
    }

    /**
     * @description It is used for getting the fields on Activation_Checklist_Validation__mdt.
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Activation_Checklist_Validation__mdt.Success_Message__c,
            Activation_Checklist_Validation__mdt.Activation_Validation_Name__c,
            Activation_Checklist_Validation__mdt.DeveloperName,
            Activation_Checklist_Validation__mdt.Error_Message__c,
            Activation_Checklist_Validation__mdt.Is_Active__c,
            Activation_Checklist_Validation__mdt.Object_Name__c,
            Activation_Checklist_Validation__mdt.Service_Class_Name__c,
            Activation_Checklist_Validation__mdt.Service_Method_Name__c,
            Activation_Checklist_Validation__mdt.Source__c
        };
    }

    /**
     * @description It is used for getting all active Activation_Checklist_Validation__mdt records
     * having service class and method name fields populated.
     * @return List<Activation_Checklist_Validation__mdt>
     */
    public List<Activation_Checklist_Validation__mdt> getAllActiveValidations() {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition('Is_Active__c = ' + ACTIVE_YES + ' AND Service_Method_Name__c != null');
        return (List<Activation_Checklist_Validation__mdt>) Database.query(query.toSOQL());
    }
}