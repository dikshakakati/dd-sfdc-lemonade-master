/**
 * @author Deloitte
 * @date 09/05/2022
 * @description This is the Selector interface for Subscription Selector related logic
 */
public interface ISubscriptionSelector extends fflib_ISObjectSelector {
    /**
     * @description method to be implemented in child class.
     * @return List of SBQQ__Subscription__c records
     * @param subsciptionRecIds - SBQQ__Subscription__c Record Ids
     */
    List<SBQQ__Subscription__c> querySubscriptionRecords(Set<Id> subsciptionRecIds);

    /**
     * @description method to be implemented in child class.
     * @return List of SBQQ__Subscription__c records
     * @param accountIds - SBQQ__Subscription__c Record Ids
     */
    List<SBQQ__Subscription__c> querySubscriptionRecordsWithAccountIds(Set<Id> accountIds);

    /**
     * @description This method is for getting Subscription based on the parent Contract and CoD product
     * @param contractIds
     * @return List<SBQQ__Subscription__c>
     */
    List<SBQQ__Subscription__c> selectByContractAndCoDProduct(Set<String> contractIds);

    /**
     * @description This method is for getting Subscription based on the parent Contract and Drive product
     * @param contractIds
     * @return List<SBQQ__Subscription__c>
     */
    List<SBQQ__Subscription__c> selectByContractAndDriveProduct(Set<String> contractIds);

    /**
     * @description This method is used for getting a map of Order Item Ids to Active Subscription Ids
     * @param contractIds
     * @param driveProductsOnly
     * @return Map<Id, Id>
     */
    Map<Id, Id> selectOrderItemActiveSubscriptionMap(
        Set<Id> contractIds,
        Boolean driveProductsOnly
    );

    /**
     * @description This method is used for getting a List of Active Subscription for Contracts
     * @param contractIds
     * @param driveProductsOnly
     * @return List<SBQQ__Subscription__c>
     */
    List<SBQQ__Subscription__c> selectActiveSubscriptionsList(
        Set<Id> contractIds,
        Boolean driveProductsOnly
    );

    /**
     * @description This method is used for getting a List of Active Subscription for Contracts and given Product Code
     * @param contractId
     * @param productCodes
     * @return List<SBQQ__Subscription__c>
     */
    List<SBQQ__Subscription__c> selectActiveSubscriptionListBasedOnProductCode(
        Id contractId,
        Set<String> productCodes
    );

    /**
     * @description This method is for getting Subscription based on the parent Contract and if any product name with following values (Delivery, Pickup, DashPass)
     * @param contractIds
     * @return List<SBQQ__Subscription__c>
     */
    List<SBQQ__Subscription__c> selectByContractAndProducts(Set<String> contractIds);

    /**
     * @description This method is for getting Subscription based on the parent Contract and if any package name with following values (Storefront)
     * @JIRA# LEM-13995
     * @param contractIds
     * @return List<SBQQ__Subscription__c>
     */
    List<SBQQ__Subscription__c> selectByContractAndPackages(Set<String> contractIds);

    /**
     * @description It is used for getting Subscription based on the parent Account
     * and if any product name with following values (Alcohol Delivery and Alcohol Pickup)
     * @param accountIds
     * @return List<SBQQ__Subscription__c>
     */
    List<SBQQ__Subscription__c> selectSubscriptionsWithAlcoholProductsByAccountIds(
        Set<Id> accountIds
    );

    /**
     * @description This method is for getting Subscription based on the parent Contract and if any product name with following Alcohol values (Alcohol Delivery, Alcohol Pickup)
     * @param contractIds
     * @return List<SBQQ__Subscription__c>
     */
    List<SBQQ__Subscription__c> selectCorporateSubscriptionsByContractIdsAndAlcoholProducts(
        Set<String> contractIds
    );

    /**
     * @description This method is for getting Subscription with Merchant services
     * @param subscriptionIds
     * @return List<SBQQ__Subscription__c>
     */
    List<SBQQ__Subscription__c> selectSubsriptionsWithServices(Set<Id> subscriptionIds);

    /**
     * @description It is used for getting Subscriptions by the passed List of Quoteline Ids
     * @param quoteLinesWithBriefItems
     * @return List<SBQQ__Subscription__c>
     */
    List<SBQQ__Subscription__c> selectSubscriptionsWithFieldsToSyncWithBriefItems(
        List<String> quoteLinesWithBriefItems
    );

    /**
     * @description It queries Subscription by set of Subscription Ids.
     * @param subscriptionIds
     * @return List<SBQQ__Subscription__c>
     */
    List<SBQQ__Subscription__c> selectBySubscriptionIds(Set<Id> subscriptionIds);

    /**
     * @description This method is for getting Subscription based on the provided list of order Item ids
     * @return List<SBQQ__Subscription__c> - DML operation result
     * @param orderItemIds Record Ids
     */
    List<SBQQ__Subscription__c> selectSubscriptionRecordsByPrimaryOrderProduct(
        Set<Id> orderItemIds
    );

    /**
     * @description This method is for getting Subscription based on the group Id
     * @param groupIds
     * @return List<SBQQ__Subscription__c>
     */
    List<SBQQ__Subscription__c> selectSubscriptionRecordsByGroup(List<Id> groupIds);

    /**
     * @description This method is for getting group Id from given contract Id
     * @param contractId
     * @return Id
     */
    Id selectQuoteLineGroupOnSubscription(Id contractId);

    /**
     * @description This method is for getting subscription records by Id.
     * @param subscriptionIds
     * @return List<SBQQ__Subscription__c>
     */
    List<SBQQ__Subscription__c> getSubscriptionsForWorkOrderCreation(Set<Id> subscriptionIds);

    /**
     * @description This method is used to get all of the child subscriptions given the ids of the
     * parent subscriptions
     * LEM-12189
     * @param parentSubscriptionIds
     * @return List<SBQQ__Subscription__c>
     */
    List<SBQQ__Subscription__c> selectChildSubscriptions(Set<String> parentSubscriptionIds);

    /**
     * @description This method is for getting Subscription based on the parent Contract and if any product name with following Alcohol values (Alcohol Delivery, Alcohol Pickup)
     * @param contractIds
     * @return List<SBQQ__Subscription__c>
     */
    List<SBQQ__Subscription__c> selectSubscriptionRecordsByContract(Set<Id> contractIds);

    /**
     * @description It is used for getting subscriptions that were Amended.
     * @param contractIds
     * @param productNames
     * @param subscriptionIds
     * @return List<SBQQ__Subscription__c>
     */
    List<SBQQ__Subscription__c> selectAmendedSubscriptions(
        Set<Id> contractIds,
        Set<String> productNames,
        Set<Id> subscriptionIds
    );

    /**
     * @description it is used for getting Subscriptions by passing in the contract Id.
     * LEM-12189
     * @param contractId
     * @return List<SBQQ__Subscription__c>
     */
    List<SBQQ__Subscription__c> selectByContractId(String contractId);

    /**
     * @description it is used for getting Subscriptions by passing in contract Id
     * @param contractId
     * @param subscriptionsFields
     * @return List<SBQQ__Subscription__c>
     */
    List<SBQQ__Subscription__c> selectActiveSubscriptionsByContractIdwithDynamicFields(
        Set<Id> contractId,
        Set<String> subscriptionsFields
    );

    /**
     * @description LEM-17960 It is used to obtain alcohol-related subscriptions by providing the account IDs.
     * @param accountIds
     * @return List<SBQQ__Subscription__c>
     */
    List<SBQQ__Subscription__c> selectAlcoholSubscriptionByAccount(Set<Id> accountIds);

    /**
     * @description It is used to get Contract's active Subscriptions' Product Families.
     * @param contractIds
     * @return List<SBQQ__Subscription__c>
     */
    List<SBQQ__Subscription__c> getSubscriptionsByContractIds(Set<Id> contractIds);
}