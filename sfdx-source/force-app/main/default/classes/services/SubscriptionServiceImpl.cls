/**
 * @author Deloitte
 * @date 08/21/2023
 * @description Service implementation class for Active Rate Provisioning update flow.
 */
public inherited sharing class SubscriptionServiceImpl implements ISubscriptionService {
    /**
     * @description This method is used to update active rates on Subscription based on Subscription Rate change.
     * @param approvedAndEffectiveSRCs
     */
    public void updateSubscriptionActiveRatesFromSRC(
        List<Subscription_Rate_Change__c> approvedAndEffectiveSRCs
    ) {
        Set<Id> subscriptionIdsToUpdate = new Set<Id>();
        List<SBQQ__Subscription__c> subscriptionsToUpdate = new List<SBQQ__Subscription__c>();

        for (Subscription_Rate_Change__c eachsrc : approvedAndEffectiveSRCs) {
            subscriptionIdsToUpdate.add(eachsrc.Subscription__c);
        }

        Map<Id, SBQQ__Subscription__c> subscriptionIdMap = new Map<Id, SBQQ__Subscription__c>(
            SubscriptionSelector.newInstance().querySubscriptionRecords(subscriptionIdsToUpdate)
        );

        for (Subscription_Rate_Change__c eachsrc : approvedAndEffectiveSRCs) {
            SBQQ__Subscription__c sub = subscriptionIdMap.get(eachsrc.Subscription__c);
            if (sub == null) {
                continue;
            }
            if (eachsrc.Updated_Active_fee__c != null) {
                sub.Active_fee__c = eachsrc.Updated_Active_fee__c;
                sub.Final_Fee__c = eachsrc.Updated_Active_fee__c;
            }
            if (eachsrc.Updated_Active_Commission__c != null) {
                sub.Active_Commission__c = eachsrc.Updated_Active_Commission__c;
                sub.Final_Commission__c = eachsrc.Updated_Active_Commission__c;
            }
            sub.Subscription_Rate_Change__c = eachsrc.Id;
            subscriptionsToUpdate.add(sub);
        }
        updateSubscriptions(subscriptionsToUpdate);
    }

    /**
     * @description Update Subscriptions
     * @param subscriptionsToUpdate
     */
    private void updateSubscriptions(List<SBQQ__Subscription__c> subscriptionsToUpdate) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerDirty(subscriptionsToUpdate);
        try {
            uow.commitWork();
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
        }
    }
}