/**
 * @author atg
 * @date 05/17/2022
 * @description Selector Class for sbaa__Approval__c
 */
public inherited sharing class AQS_AAApprovalSelector extends fflib_SObjectSelector implements IAQS_AAApprovalSelector {
    static final String APPROVED = 'Approved';
    static final String REQUESTED = 'Requested';

    /**
     * @description default constructor for the class
     * @return IAQS_AAApprovalSelector - interface of IAQS_AAApprovalSelector
     */
    public static IAQS_AAApprovalSelector newInstance() {
        return (IAQS_AAApprovalSelector) Application.Selector.newInstance(sbaa__Approval__c.SObjectType);
    }

    /**
     * @description This method is for getting the fields on Contact object
     * @return Contact- Contact fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            sbaa__Approval__c.Id,
            sbaa__Approval__c.AQS_Quote__c,
            sbaa__Approval__c.sbaa__Approver__c,
            sbaa__Approval__c.sbaa__AssignedTo__c,
            sbaa__Approval__c.CreatedDate,
            sbaa__Approval__c.LastModifiedDate,
            sbaa__Approval__c.sbaa__Status__c
         };
    }

    /**
     * @description This method id for getting object type
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return sbaa__Approval__c.SObjectType;
    }

    /**
     * @description This method is used for getting all approved sbaa__Approval__c
     * @return List<sbaa__Approval__c>
     */
    public List<sbaa__Approval__c> selectApprovedOrderedByLastModifiedDate() {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('sbaa__ApprovedBy__r.Name');
        query.selectField('sbaa__Approver__r.Name');
        query.setCondition('sbaa__Status__c = :APPROVED');
        query.addOrdering('LastModifiedDate', fflib_QueryFactory.SortOrder.ASCENDING);
        query.setLimit(2000);
        return (List<sbaa__Approval__c>) Database.query(query.toSOQL());
     }

    /**
    * @description This method is used for getting requested sbaa__Approval__c by userId
    * @param userIds
    * @return List<sbaa__Approval__c>
    */
    public List<sbaa__Approval__c> selectRequestedForUserIds(Set<Id> userIds) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('AQS_Quote__r.Name');
        query.selectField('sbaa__Approver__r.AQS_18_Digit_Group_Id__c');
        query.setCondition('(sbaa__AssignedTo__c IN :userIds OR sbaa__Approver__r.AQS_18_Digit_Group_Id__c IN :userIds) AND sbaa__Status__c = :REQUESTED');
        return (List<sbaa__Approval__c>) Database.query(query.toSOQL());
    }
}