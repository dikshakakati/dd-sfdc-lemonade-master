/**
 * @author Deloitte
 * @date 10/09/2023
 * @description SubscriptionRateChanges Object Trigger Handler.
 */
public class SubscriptionRateChangesHandler extends ApplicationDomainHandler {
    private static final String APPROVED = 'Approved';
    /**
     * @description Constructor Method
     * @param sObjectList
     */
    public SubscriptionRateChangesHandler(List<Subscription_Rate_Change__c> sObjectList) {
        super(sObjectList);
        setContextBypass(
            Subscription_Rate_Change__c.sObjectType,
            SubscriptionRateChangesHandler.class
        );
    }

    /**
     * @description Constructor class implements fflib_SObjectDomain Class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description This method implements construct method of fflib_SObjectDomain.IConstructable
         * @param sObjectList List<SObject>
         * @return Subscription_Rate_Change__c
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new SubscriptionRateChangesHandler(sObjectList);
        }
    }

    /**
     * @description Called to perform after insert processing
     */
    public override void onAfterInsert() {
        SubscriptionService.updateSubscriptionActiveRatesFromSRC(
            getApprovedAndEffectiveSRCs(getRecordIds())
        );
    }

    /**
     * @description Called to perform after update processing
     * @param existing
     */
    public override void onAfterUpdate(Map<Id, SObject> existing) {
        List<Subscription_Rate_Change__c> updatedSRCs = new List<Subscription_Rate_Change__c>(
            (List<Subscription_Rate_Change__c>) getChangedRecords(
                new Set<SObjectField>{ Subscription_Rate_Change__c.Update_Complete__c }
            )
        );
        RateChangeRequestService.setRateChangeRequestComplete(getCompletedSRCs(updatedSRCs));
    }

    /**
     * @description It is used to get approved and immediately effective Subscription Rate Change requests.
     * @param subscriptionRateChangeIds
     * @return approvedAndEffectiveSRCs
     */
    private List<Subscription_Rate_Change__c> getApprovedAndEffectiveSRCs(
        Set<Id> subscriptionRateChangeIds
    ) {
        List<Subscription_Rate_Change__c> approvedAndEffectiveSRCs = new List<Subscription_Rate_Change__c>();
        Set<Id> srcIds = new Set<Id>();
        for (
            Subscription_Rate_Change__c src : SubscriptionRateChangeSelector.newInstance()
                .selectById(subscriptionRateChangeIds)
        ) {
            if (src.Rate_Change_Request__r.Effective_Date__c == System.today()) {
                approvedAndEffectiveSRCs.add(src);
                srcIds.add(src.Id);
            }
        }
        return approvedAndEffectiveSRCs;
    }

    /**
     * @description It is used to get completed Subscription Rate Change requests.
     * @param updatedSRCs
     * @return completedSRCs
     */
    private List<Subscription_Rate_Change__c> getCompletedSRCs(
        List<Subscription_Rate_Change__c> updatedSRCs
    ) {
        List<Subscription_Rate_Change__c> completedSRCs = new List<Subscription_Rate_Change__c>();
        Set<Id> srcIds = new Set<Id>();
        for (Subscription_Rate_Change__c src : updatedSRCs) {
            if (src.Rate_Change_Request__c != null && src.Update_complete__c) {
                completedSRCs.add(src);
                srcIds.add(src.Id);
            }
        }
        return completedSRCs;
    }
}