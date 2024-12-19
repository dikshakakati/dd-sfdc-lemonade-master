/**
 * @author Deloitte
 * @date 10/10/2024
 * @description Selector Class for Approver Object.
 */
public inherited sharing class ApproversSelector extends fflib_SObjectSelector implements IApproversSelector {
    /**
     * @description Default Constructor for the Approver Selector Class
     * @return IApproversSelector - Interface of IApproversSelector
     */
    public static IApproversSelector newInstance() {
        return (IApproversSelector) Application.Selector.newInstance(sbaa__Approver__c.SObjectType);
    }

    /**
     * @description It is for getting fields on Approver Object.
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            sbaa__Approver__c.Id,
            sbaa__Approver__c.sbaa__User__c
        };
    }

    /**
     * @description This method is used for getting Object Type
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return sbaa__Approver__c.SObjectType;
    }

    /**
     * @description It is used to get Approvers based on passed user ids.
     * @param userIds
     * @return List<sbaa__Approver__c>
     */
    public List<sbaa__Approver__c> selectByUserIds(Set<Id> userIds) {
        fflib_QueryFactory query = newQueryFactory().setCondition('sbaa__User__c IN :userIds');
        return (List<sbaa__Approver__c>) Database.query(query.toSOQL());
    }
}