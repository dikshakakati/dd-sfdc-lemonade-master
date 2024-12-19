/**
 * @author Deloitte
 * @date 07/06/2024
 * @description Selector Class for Account Plans Object.
 */
public inherited sharing class AccountPlansSelector extends fflib_SObjectSelector implements IAccountPlansSelector {
    private static final String ACTIVE = 'Active';
    private static final Integer QUERY_LIMIT = 1;
    /**
     * @description This method is for getting the fields on Account Plan object
     * @return List of Schema.SObjectField
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Account_Plan__c.Id,
            Account_Plan__c.Name,
            Account_Plan__c.Status__c,
            Account_Plan__c.Account__c
        };
    }

    /**
     * @description This method is used for getting Object type
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Account_Plan__c.SObjectType;
    }

    /**
     * @description This method is used for getting Sobject type Id
     * @param idSet
     * @return List<Account>
     */
    public List<Account_Plan__c> selectById(Set<Id> idSet) {
        return (List<Account_Plan__c>) selectSObjectsById(idSet);
    }

    /**
     * @description This method is used for getting active Account Plans by passing Account Ids.
     * @param accountsWithActiveAccountPlans
     * @return List<Account>
     */
    public List<Account_Plan__c> selectActiveAccountPlanByAccounts(
        Set<Id> accountsWithActiveAccountPlans
    ) {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectField('Account__c')
            .setCondition('Account__c IN :accountsWithActiveAccountPlans AND Status__c = :ACTIVE')
            .setLimit(QUERY_LIMIT);
        return (List<Account_Plan__c>) Database.query(query.toSOQL());
    }

    /**
     * @description default constructor for the AccountPlan Selector class
     * @return IAccountPlansSelector - interface of IAccountPlansSelector
     */
    public static IAccountPlansSelector newInstance() {
        return (IAccountPlansSelector) Application.Selector.newInstance(
            Account_Plan__c.SObjectType
        );
    }
}