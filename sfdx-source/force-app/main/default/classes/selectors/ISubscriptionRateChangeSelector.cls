/**
 * @author Deloitte
 * @date 12/09/2023
 * @description Selector Class for Subscription_Rate_Change__c Object
 */
public interface ISubscriptionRateChangeSelector extends fflib_ISObjectSelector {
    /**
     * @description This method is used for getting Subscription_Rate_Change__c records
     * @param subscriptionIds
     * @return List<Subscription_Rate_Change__c>
     */
    List<Subscription_Rate_Change__c> selectById(Set<Id> subscriptionIds);

    /**
     * @description This method is used for getting Subscription_Rate_Change__c records by RCRIds
     * @param rateChangeIds
     * @return Database.QueryLocator
     */
    Database.QueryLocator selectByRateChangeIds(Set<Id> rateChangeIds);
}