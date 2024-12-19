/**
 * @author Deloitte
 * @date 10/09/2023
 * @description Selector for Rate_Change_Request__c class methods.
 */
public inherited sharing class RateChangeRequestSelector extends fflib_SObjectSelector implements IRateChangeRequestSelector {
    private static final String STATUS_NEW = 'New';
    private static final String DAYS_BEFORE_EFFECTIVE_DATE = 'Days_Before_Effective_Date';
    private static final String APPROVED = 'Approved';
    private static final Date TODAY_DATE = System.today();
    /**
     * @description New instance method to call application selector
     * @param Rate_Change_Request__c.SObjectType - Rate_Change_Request__c object type
     * @return IRateChangeRequestSelector - interface of IRateChangeRequestSelector
     */
    public static IRateChangeRequestSelector newInstance() {
        return (IRateChangeRequestSelector) Application.Selector.newInstance(
            Rate_Change_Request__c.SObjectType
        );
    }

    /**
     * @description This method is for getting the fields on Rate_Change_Request__c object
     * @return Rate_Change_Request__c object fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Rate_Change_Request__c.Id,
            Rate_Change_Request__c.Activation_Status__c,
            Rate_Change_Request__c.Order_Products_Updated__c,
            Rate_Change_Request__c.Contract__c,
            Rate_Change_Request__c.Effective_Date__c,
            Rate_Change_Request__c.Name,
            Rate_Change_Request__c.S_O_Support_Request_Link__c,
            Rate_Change_Request__c.Status__c,
            Rate_Change_Request__c.Associated_stores_updated__c
        };
    }

    /**
     * @description This method id for getting object type
     * @return Rate_Change_Request__c Object type
     */
    public Schema.SObjectType getSObjectType() {
        return Rate_Change_Request__c.SObjectType;
    }

    /**
     * @description This method fetches the RateChangeRequests along with all the related Subscription Rate Change records.
     * @param rcrIds
     * @return List<Rate_Change_Request__c>
     */
    public List<Rate_Change_Request__c> selectRateChangeRequestById(Set<Id> rcrIds) {
        fflib_QueryFactory rateChangeQuery = newQueryFactory()
            .selectField('Associated_stores_updated__c')
            .selectField('Contract__r.Account.Activated_Centrally_AC__c')
            .selectField('Contract__r.Account.Menu_Setup_Method__c')
            .selectField('Contract__r.Account.Menu_to_be_Completed_By__c')
            .selectField('Contract__r.Account.Order_Protocol__c')
            .selectField('Contract__r.Account.Id')
            .selectField('S_O_Support_Request_Link__r.CreatedById')
            .setCondition('Id IN :rcrIds');
        new SubscriptionRateChangeSelector()
            .addQueryFactorySubselect(rateChangeQuery, 'Subscription_Rate_Changes__r')
            .selectField('Update_complete__c')
            .selectField('Updated_Active_Fee__c')
            .selectField('Updated_Active_Commission__c')
            .selectField('Rate_Change_Request__c')
            .setCondition('Rate_Change_Request__c IN :rcrIds');
        return (List<Rate_Change_Request__c>) Database.query(rateChangeQuery.toSOQL());
    }

    /**
     * @description This method fetches the RateChangeRequests with activation status as new and effective date in past.
     * @return List<Rate_Change_Request__c>
     */
    public Database.QueryLocator selectRateChangeRequestByPastEffectiveDate() {
        Integer beforeEffectiveDate = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(DAYS_BEFORE_EFFECTIVE_DATE)
                .Configuration_Value__c
        );
        fflib_QueryFactory rateChangeQuery = newQueryFactory()
            .selectField('Activation_Status__c')
            .selectField('Effective_Date__c')
            .selectField('Status__c')
            .selectField('OwnerId')
            .selectField('Owner.Name')
            .selectField('Contract__r.Account.Name')
            .setCondition(
                'Activation_Status__c = :STATUS_NEW AND Effective_Date__c < LAST_N_DAYS:' +
                beforeEffectiveDate
            );
        return Database.getQueryLocator(rateChangeQuery.toSOQL());
    }

    /**
     * @description This method is used for getting Rate_Change_Request__c records
     * with today as effective date for batch
     * @return List<Rate_Change_Request__c>
     */
    public Database.QueryLocator selectByEffectiveDateToday() {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Effective_Date__c')
            .selectField('Activation_Status__c')
            .selectField('Associated_stores_updated__c')
            .setCondition(
                'Activation_Status__c = :STATUS_NEW AND Effective_Date__c =: TODAY_DATE AND Status__c =: APPROVED AND Associated_stores_updated__c = TRUE'
            )
            .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.ASCENDING);
        return Database.getQueryLocator(query.toSOQL());
    }
}