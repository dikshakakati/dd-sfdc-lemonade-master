/**
 * @author Deloitte
 * @date 04/09/2024
 * @description Selector Class for Lever Object
 */
public inherited sharing class LeversSelector extends fflib_SObjectSelector implements ILeversSelector {
    static final List<String> OPEN_LEVER_STATUS = new List<String>{
        'Planned',
        'In Progress',
        'Blocked'
    };
    /**
     * @description Default constructor for the Levers Selector class
     * @return ILeversSelector - interface of ILeversSelector
     */
    public static ILeversSelector newInstance() {
        return (ILeversSelector) Application.Selector.newInstance(Lever__c.SObjectType);
    }

    /**
     * @description This method is for getting the fields on Lever object
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Lever__c.Id,
            Lever__c.Name,
            Lever__c.Category__c,
            Lever__c.Predicted_Incremental_Sales__c,
            Lever__c.Solution_Name__c,
            Lever__c.Lever_Points__c,
            Lever__c.Account__c
        };
    }

    /**
     * @description It is used for getting Object type.
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Lever__c.SObjectType;
    }

    /**
     * @description It is used for getting Levers by passed Ids.
     * @param idSet
     * @return List<Lever__c>
     */
    public List<Lever__c> selectById(Set<Id> idSet) {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectField('Name')
            .selectField('Category__c')
            .selectField('Account__r')
            .selectField('Account__r.Id')
            .selectField('Account__r.Name')
            .selectField('Solution_Name__c')
            .selectField('Solution__r.Product_Family__c')
            .setCondition('Id IN :idSet')
            .setOrdering('Solution_Name__c', fflib_QueryFactory.SortOrder.ASCENDING);
        return (List<Lever__c>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used for getting Levers by passed cloned Lever Ids.
     * @param clonedLeverIds
     * @return List<Lever__c>
     */
    public List<Lever__c> selectByClonedLeverId(Set<Id> clonedLeverIds) {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectField('Name')
            .selectField('Id')
            .selectField('Cloned_From_Lever_Id__c')
            .setCondition('Cloned_From_Lever_Id__c IN :clonedLeverIds');
        return (List<Lever__c>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used for getting open Levers by passed Account Plan Ids.
     * @param accountPlanIds
     * @return List<Lever__c>
     */
    public List<Lever__c> selectOpenLeversByAccountPlanId(Set<Id> accountPlanIds) {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectField('Name')
            .selectField('Account__c')
            .selectField('Confidence_Level__c')
            .selectField('Interest_Level__c')
            .selectField('Predicted_Incremental_Sales__c')
            .selectField('Rejection_Reason__c')
            .selectField('Solution__c')
            .selectField('Solution__r.VSP_Code__c')
            .selectField('Solution__r.Name')
            .selectField('Status__c')
            .setCondition('Account_Plan__c IN :accountPlanIds AND Status__c IN :OPEN_LEVER_STATUS');
        return (List<Lever__c>) Database.query(query.toSOQL());
    }
    /**
     * @description It is used for getting all open Levers for current quarter.
     * @param startDate
     * @param endDate
     * @return List<Lever__c>
     */
    public Database.QueryLocator selectOpenLeversForCurrentQuarter(Date startDate, Date endDate) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition(
            'Account_Plan__r.Start_Date__c >= :startDate AND Account_Plan__r.Start_Date__c < :endDate' +
            ' AND Status__c IN :OPEN_LEVER_STATUS'
        );
        query.selectField('Solution__r.VSP_Code__c');
        return Database.getQueryLocator(query.toSOQL());
    }

    /**
     * @description It is used for getting Levers by account Ids.
     * @JIRA# LEM-18501
     * @param accountIds
     * @return List<Lever__c>
     */
    public List<Lever__c> selectByAccountIds(Set<Id> accountIds) {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectField('Name')
            .selectField('Category__c')
            .selectField('Account__r')
            .selectField('Account__r.Id')
            .selectField('Account__r.Name')
            .selectField('Solution_Name__c')
            .selectField('Solution__r.VSP_Code__c')
            .setCondition('Account__c IN :accountIds')
            .setOrdering('Solution_Name__c', fflib_QueryFactory.SortOrder.ASCENDING);
        return (List<Lever__c>) Database.query(query.toSOQL());
    }
}