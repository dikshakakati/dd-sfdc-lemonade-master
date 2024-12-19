
/**
 * @author atg
 * @date 05/11/2022
 * @description Selector Class for Email Template Object
 */
public inherited sharing class AQS_AAEmailTemplateSelector extends fflib_SObjectSelector implements IAQS_AAEmailTemplateSelector {
    /**
     * @description default constructor for the class
     * @return IAQS_AAEmailTemplateSelector - interface of IContactsSelector
     */
    public static IAQS_AAEmailTemplateSelector newInstance() {
        return (IAQS_AAEmailTemplateSelector) Application.Selector.newInstance(sbaa__EmailTemplate__c.SObjectType);
    }

    /**
     * @description This method is for getting the fields on Contact object
     * @return Contact- Contact fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            sbaa__EmailTemplate__c.Id,
            sbaa__EmailTemplate__c.Name,
            sbaa__EmailTemplate__c.sbaa__TemplateId__c,
            sbaa__EmailTemplate__c.CreatedDate,
            sbaa__EmailTemplate__c.CreatedById
        };
    }

    /**
     * @description This method id for getting object type
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return sbaa__EmailTemplate__c.SObjectType;
    }

    /**
    * @description This method is used for getting all sbaa__EmailTemplate__c
    * @return List of sbaa__EmailTemplate__c
    */
    public List<sbaa__EmailTemplate__c> selectAllOrderedByName() {
       fflib_QueryFactory query = newQueryFactory();
       query.selectField('CreatedBy.Name');
       query.addOrdering('Name', fflib_QueryFactory.SortOrder.ASCENDING);
       query.setLimit(2000);
       return (List<sbaa__EmailTemplate__c>) Database.query(query.toSOQL());
    }
}