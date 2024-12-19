/**
 * @author Deloitte
 * @date 01/11//2024
 * @description Selector class for Log object.
 */
public inherited sharing class LogsSelector extends fflib_SObjectSelector implements ILogsSelector {
    /**
     * @description Default constructor for the class.
     * @return ILogsSelector
     */
    public static ILogsSelector newInstance() {
        return (ILogsSelector) Application.Selector.newInstance(Log__c.SObjectType);
    }

    /**
     * @description Overriding default getSObjectType method.
     * @return SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Log__c.SObjectType;
    }

    /**
     * @description It is used to get the fields of Log__c object.
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{ Log__c.Id };
    }

    /**
     * @description It is used for querying Log__c records which satisfies the criteria to
     * send notification.
     * @param parentField
     * @param parentIds
     * @param secondaryParentFieldToExclude
     * @return List<Log__c>
     */
    public List<Log__c> selectLogsEligibleToSendNotification(
        Schema.SObjectField parentField,
        Set<Id> parentIds,
        Schema.SObjectField secondaryParentFieldToExclude
    ) {
        fflib_QueryFactory logQuery = newQueryFactory()
            .selectField('Franchise_Parent_Account_Id_18__c')
            .selectField('Parent_Account_Id_18__c')
            .selectField('Recipient_Ids_To_Send_Notification__c')
            .selectField('Send_Notification__c')
            .setCondition(
                'Send_Notification__c = TRUE' +
                ' AND Recipient_Ids_To_Send_Notification__c != null' +
                ' AND CreatedDate >= LAST_N_DAYS:5' +
                ' AND ' +
                String.valueOf(parentField) +
                ' IN :parentIds'
            );
        if (secondaryParentFieldToExclude != null) {
            logQuery.setCondition(
                logQuery.getCondition() +
                ' AND ' +
                String.valueOf(secondaryParentFieldToExclude) +
                ' = null'
            );
        }
        return (List<Log__c>) Database.query(logQuery.toSOQL());
    }
}