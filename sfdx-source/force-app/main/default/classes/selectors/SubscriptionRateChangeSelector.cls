/**
 * @author Deloitte
 * @date 16/09/2023
 * @description SubscriptionRateChanges Selector.
 */
public inherited sharing class SubscriptionRateChangeSelector extends fflib_SObjectSelector implements ISubscriptionRateChangeSelector {
    private static final String APPROVED = 'Approved';
    private static final Date DATE_TODAY = System.today();

    /**
     * @description default constructor for the SubscriptionRateChange Selector class
     * @return ISubscriptionRateChangeSelector - interface of ISubscriptionRateChangeSelector
     */
    public static ISubscriptionRateChangeSelector newInstance() {
        return (ISubscriptionRateChangeSelector) Application.Selector.newInstance(
            Subscription_Rate_Change__c.SObjectType
        );
    }

    /**
     * @description This method is for getting the fields on account object
     * @return List of Schema.SObjectField
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Subscription_Rate_Change__c.Rate_Change_Request__c,
            Subscription_Rate_Change__c.Subscription__c,
            Subscription_Rate_Change__c.Update_complete__c,
            Subscription_Rate_Change__c.Updated_Active_Commission__c,
            Subscription_Rate_Change__c.Updated_Active_Fee__c,
            Subscription_Rate_Change__c.Rate_Change_Request_Status__c,
            Subscription_Rate_Change__c.Name,
            Subscription_Rate_Change__c.Current_Active_Fee__c,
            Subscription_Rate_Change__c.Current_Active_Commission__c
        };
    }

    /**
     * @description This method is used for getting Object type
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Subscription_Rate_Change__c.SObjectType;
    }

    /**
     * @description This method is used for getting Subscription_Rate_Change__c records
     * @param subscriptionRateChangeIds
     * @return List<Subscription_Rate_Change__c>
     */
    public List<Subscription_Rate_Change__c> selectById(Set<Id> subscriptionRateChangeIds) {
        fflib_QueryFactory query = newQueryFactory(true)
            .selectField('Subscription__r.Active_fee__c')
            .selectField('Subscription__c.Active_Commission__c')
            .selectField('Rate_Change_Request__r.Effective_Date__c')
            .setCondition('Id IN :subscriptionRateChangeIds');
        return (List<Subscription_Rate_Change__c>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is used for getting Subscription_Rate_Change__c records by RCRIds
     * @param rateChangeIds
     * @return List<Subscription_Rate_Change__c>
     */
    public Database.QueryLocator selectByRateChangeIds(Set<Id> rateChangeIds) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Rate_Change_Request__r.Effective_Date__c')
            .selectField('Rate_Change_Request__r.Activation_Status__c')
            .selectField('Rate_Change_Request__r.Associated_stores_updated__c')
            .setCondition(
                'Rate_Change_Request__c IN :rateChangeIds AND Rate_Change_Request__r.Effective_Date__c =: DATE_TODAY AND Rate_Change_Request_Status__c =: APPROVED AND Rate_Change_Request__r.Associated_stores_updated__c = TRUE'
            )
            .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.ASCENDING);
        return Database.getQueryLocator(query.toSOQL());
    }
}