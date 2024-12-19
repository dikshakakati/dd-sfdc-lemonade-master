/**
 * @author Deloitte
 * @date 08/21/2023
 * @description Service implementation class for Active Rate Provisioning update flow.
 */
public inherited sharing class SubscriptionRateChangeServiceImpl implements ISubscriptionRateChangeService {
    private static final String PRIMARY_ORDER_RECORD_TYPE_ID = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName()
        .get('Primary_Order')
        .getRecordTypeId();

    /**
     * @description This method is used to set Subscription Rate change to Complete once associated
     * Subscription and Primary Order Products are updated with correct active rates.
     * @param arpAppliedPrimaryOrderItems
     */
    public void setSubscriptionRateChangeComplete(List<OrderItem> arpAppliedPrimaryOrderItems) {
        Set<Id> orderItemIds = new Set<Id>();
        Map<Id, SBQQ__Subscription__c> srcToSubscriptionMap = new Map<Id, SBQQ__Subscription__c>();
        List<Subscription_Rate_Change__c> subscriptionRateChangesToBeUpdated = new List<Subscription_Rate_Change__c>();
        Subscription_Rate_Change__c srcToBeAdded = new Subscription_Rate_Change__c();

        orderItemIds = collectPrimaryOrderProductIds(arpAppliedPrimaryOrderItems);

        List<SBQQ__Subscription__c> subscriptionsAssociated = SubscriptionSelector.newInstance()
            .selectSubscriptionRecordsByPrimaryOrderProduct(orderItemIds);

        if (subscriptionsAssociated.isEmpty()) {
            return;
        }

        srcToSubscriptionMap = getSrcToSubscriptionMap(subscriptionsAssociated);

        List<Subscription_Rate_Change__c> subscriptionRateChanges = SubscriptionRateChangeSelector.newInstance()
            .selectById(srcToSubscriptionMap.keySet());

        for (Subscription_Rate_Change__c eachRateChange : subscriptionRateChanges) {
            SBQQ__Subscription__c associatedSubscription = srcToSubscriptionMap.get(
                eachRateChange.Id
            );
            if (associatedSubscription == null) {
                continue;
            }
            srcToBeAdded = checkIfActiveRatesAreInSync(eachRateChange, associatedSubscription);
            if (srcToBeAdded != null) {
                subscriptionRateChangesToBeUpdated.add(srcToBeAdded);
            }
        }
        updateSubscriptionRateChanges(subscriptionRateChangesToBeUpdated);
    }

    /**
     * @description Collect all primary order item ids
     * @param arpAppliedPrimaryOrderItems
     * @return orderItemIds
     */
    private Set<Id> collectPrimaryOrderProductIds(List<OrderItem> arpAppliedPrimaryOrderItems) {
        Set<Id> orderItemIds = new Set<Id>();
        if (!arpAppliedPrimaryOrderItems.isEmpty()) {
            for (OrderItem eachOrderItem : arpAppliedPrimaryOrderItems) {
                if (eachOrderItem.Order.RecordTypeId == PRIMARY_ORDER_RECORD_TYPE_ID) {
                    orderItemIds.add(eachOrderItem.Id);
                }
            }
        }
        return orderItemIds;
    }

    /**
     * @description Create srcToSubscriptionMap using subscriptions
     * @param subscriptionsAssociated
     * @return srcToSubscriptionMap
     */
    private Map<Id, SBQQ__Subscription__c> getSrcToSubscriptionMap(
        List<SBQQ__Subscription__c> subscriptionsAssociated
    ) {
        Map<Id, SBQQ__Subscription__c> srcToSubscriptionMap = new Map<Id, SBQQ__Subscription__c>();
        for (SBQQ__Subscription__c sub : subscriptionsAssociated) {
            if (
                sub.Active_Fee__c == sub.SBQQ__OrderProduct__r.Active_Fee__c &&
                sub.Active_Commission__c == sub.SBQQ__OrderProduct__r.Active_Commission__c
            ) {
                srcToSubscriptionMap.put(sub.Subscription_Rate_Change__c, sub);
            }
        }
        return srcToSubscriptionMap;
    }

    /**
     * @description Check if the Active rates are in sync along Primary Order products, Subscription Rate Change and Subscriptions in
     * order to complete the Subscription Rate Change
     * @param eachRateChange
     * @param associatedSubscription
     * @return srcToBeAdded
     */
    private Subscription_Rate_Change__c checkIfActiveRatesAreInSync(
        Subscription_Rate_Change__c eachRateChange,
        SBQQ__Subscription__c associatedSubscription
    ) {
        Subscription_Rate_Change__c srcToBeAdded = new Subscription_Rate_Change__c();
        Boolean activeFeeMatch = false;
        Boolean activeCommissionMatch = false;
        Boolean activeFeeUpdated = true;
        Boolean activeCommissionUpdated = true;
        if (eachRateChange.Updated_Active_fee__c != null) {
            if (isActiveFeeMatch(eachRateChange, associatedSubscription)) {
                activeFeeMatch = true;
            }
        } else {
            activeFeeUpdated = false;
        }
        if (eachRateChange.Updated_Active_Commission__c != null) {
            if (isActiveCommissionMatch(eachRateChange, associatedSubscription)) {
                activeCommissionMatch = true;
            }
        } else {
            activeCommissionUpdated = false;
        }
        if (
            (activeFeeUpdated && activeFeeMatch) ||
            (activeCommissionUpdated && activeCommissionMatch)
        ) {
            srcToBeAdded = new Subscription_Rate_Change__c(
                Id = eachRateChange.Id,
                Update_Complete__c = true
            );
        }
        return srcToBeAdded;
    }

    /**
     * @description Check if the Active Fee rates are in sync along Primary Order products, Subscription Rate Change and Subscriptions in
     * order to complete the Subscription Rate Change
     * @param eachRateChange
     * @param associatedSubscription
     * @return isActiveFeeMatch
     */
    private Boolean isActiveFeeMatch(
        Subscription_Rate_Change__c eachRateChange,
        SBQQ__Subscription__c associatedSubscription
    ) {
        Boolean isActiveFeeMatch =
            eachRateChange.Updated_Active_fee__c == associatedSubscription.Active_fee__c &&
            eachRateChange.Updated_Active_Fee__c ==
            associatedSubscription.SBQQ__OrderProduct__r.Active_Fee__c;
        return isActiveFeeMatch;
    }

    /**
     * @description Check if the Active Commission rates are in sync along Primary Order products, Subscription Rate Change and Subscriptions in
     * order to complete the Subscription Rate Change
     * @param eachRateChange
     * @param associatedSubscription
     * @return isActiveCommissionMatch
     */
    private Boolean isActiveCommissionMatch(
        Subscription_Rate_Change__c eachRateChange,
        SBQQ__Subscription__c associatedSubscription
    ) {
        Boolean isActiveCommissionMatch =
            eachRateChange.Updated_Active_Commission__c ==
            associatedSubscription.Active_Commission__c &&
            eachRateChange.Updated_Active_Commission__c ==
            associatedSubscription.SBQQ__OrderProduct__r.Active_Commission__c;
        return isActiveCommissionMatch;
    }

    /**
     * @description Update Subscription Rate Change
     * @param subscriptionRateChangesToUpdate
     */
    private void updateSubscriptionRateChanges(
        List<Subscription_Rate_Change__c> subscriptionRateChangesToUpdate
    ) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerDirty(subscriptionRateChangesToUpdate);
        try {
            uow.commitWork();
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
        }
    }
}