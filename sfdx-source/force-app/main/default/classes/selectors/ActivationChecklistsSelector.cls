/**
 * @author Deloitte
 * @date 04/09/2024
 * @description Selector class for Activation Checklist records.
 */
public inherited sharing class ActivationChecklistsSelector extends fflib_SObjectSelector implements IActivationChecklistsSelector {
    private static final String WORK_ORDER_STATUS_DEAD = 'Dead';
    /**
     * @description Default constructor for the Activation_Checklist__c selector class.
     * @return IActivationChecklistsSelector
     */
    public static IActivationChecklistsSelector newInstance() {
        return (IActivationChecklistsSelector) Application.Selector.newInstance(
            Activation_Checklist__c.SObjectType
        );
    }

    /**
     * @description It is for getting the fields on Activation_Checklist__c object.
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Activation_Checklist__c.Id,
            Activation_Checklist__c.Activation_Validation_Name__c,
            Activation_Checklist__c.Result__c,
            Activation_Checklist__c.Work_Plan__c,
            Activation_Checklist__c.Work_Step__c,
            Activation_Checklist__c.Parent_Work_Step__c,
            Activation_Checklist__c.MINT_Value__c,
            Activation_Checklist__c.SFDC_Value__c,
            Activation_Checklist__c.Store_Account__c,
            Activation_Checklist__c.Status__c,
            Activation_Checklist__c.MINT_Store_Page__c
        };
    }

    /**
     * @description It is used for getting object type.
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Activation_Checklist__c.SObjectType;
    }

    /**
     * @description It is used for getting list of AccountTeamMember having Franchise Representative role by an account.
     * @param storeIds
     * @return List<Activation_Checklist__c>
     */
    public List<Activation_Checklist__c> selectByStoreIds(Set<Id> storeIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition(
            'Store_Account__c IN :storeIds AND Work_Step__r.WorkOrder.Status != :WORK_ORDER_STATUS_DEAD'
        );
        return (List<Activation_Checklist__c>) Database.query(query.toSOQL());
    }
}