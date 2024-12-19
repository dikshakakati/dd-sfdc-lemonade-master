/**
 * @author Deloitte
 * @date 04/21/2024
 * @description Selector class for Criterion object.
 */
public inherited sharing class CriteriaSelector extends fflib_SObjectSelector implements ICriteriaSelector {
    /**
     * @description Default constructor for the class.
     * @return ICriteriaSelector
     */
    public static ICriteriaSelector newInstance() {
        return (ICriteriaSelector) Application.Selector.newInstance(Criterion__c.SObjectType);
    }

    /**
     * @description Overriding default getSObjectType method.
     * @return SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Criterion__c.SObjectType;
    }

    /**
     * @description This method is for getting the fields on Criterion.
     * @JIRA# LEM-13778
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Criterion__c.Comparator__c,
            Criterion__c.Name,
            Criterion__c.Criterion_Name__c,
            Criterion__c.Field__c,
            Criterion__c.Field_Reference_Type__c,
            Criterion__c.Integration_Template__c,
            Criterion__c.Service_Method_Name__c,
            Criterion__c.Value__c,
            Criterion__c.Work_Order_Template_Entry__c
        };
    }
}