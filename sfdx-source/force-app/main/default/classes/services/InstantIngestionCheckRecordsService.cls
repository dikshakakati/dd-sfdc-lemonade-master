/**
 * @author Deloitte
 * @date 06/06/2024
 * @description Service class for InstantIngestionCheckRecordsServiceImpl.
 */
public inherited sharing class InstantIngestionCheckRecordsService {
    /**
     * @description It is used to get existing Accounts by the passed businessIds.
     * @param payLoadWrapperByIngestionLogUUID
     * @param payLoadWrapperByIngestionLogUUIDForSSOB
     * @return set<String>
     */
    public static Map<String, Account> getExistingBusinessAccounts(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID,
        Map<String, SSOBOnboardingPayloadParser> payLoadWrapperByIngestionLogUUIDForSSOB
    ) {
        return service()
            .getExistingBusinessAccounts(
                payLoadWrapperByIngestionLogUUID,
                payLoadWrapperByIngestionLogUUIDForSSOB
            );
    }

    /**
     * @description It is used to get existing Opporunities by the passed accountIds.
     * @param accountIds
     * @return Map<Id, Opportunity>
     */
    public static Map<Id, Opportunity> fetchRelatedOpportunitiesAndQuotes(Set<Id> accountIds) {
        return service().fetchRelatedOpportunitiesAndQuotes(accountIds);
    }
    /**
     * @description It is used to get existing type Opporunities by the passed accountIds.
     * @param accountIds
     * @return Map<Id, Opportunity>
     */
    public static Map<Id, Opportunity> fetchRelatedExistingOpportunitiesAndPrimaryQuotes(
        Set<Id> accountIds
    ) {
        return service().fetchRelatedExistingOpportunitiesAndPrimaryQuotes(accountIds);
    }

    /**
     * @description It is used to get existing Contacts by the passed businessAccountIds.
     * @param businessAccountIds
     * @return Map<Id, Contact>
     */
    public static Map<Id, Contact> getExistingContactsByBusinessAccount(
        Set<Id> businessAccountIds
    ) {
        return service().getExistingContactsByBusinessAccount(businessAccountIds);
    }

    /**
     * @description It is used to get existing Business references by the passed businessIds.
     * @param businessIds
     * @return Map<Id, Business_Reference__c>
     */
    public static Map<String, Business_Reference__c> getExistingBusinessReferences(
        Set<String> businessIds
    ) {
        return service().getExistingBusinessReferences(businessIds);
    }

    /**
     * @description It is used to get existing Brands by the passed accountIds.
     * @param accountIds
     * @return Map<Id, Brand__c>
     */
    public static Map<Id, Brand__c> getExistingBrands(Set<Id> accountIds) {
        return service().getExistingBrands(accountIds);
    }

    /**
     * @description It is used to get existing Store Accounts by the passed businessIds.
     * @param payLoadWrapperByIngestionLogUUID
     * @return Map<String, Account>
     */
    public static Map<String, Account> getExistingStoreAccounts(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID
    ) {
        return service().getExistingStoreAccounts(payLoadWrapperByIngestionLogUUID);
    }

    /**
     * @description It is used to get existing Quotes by the passed accountIds.
     * @param opportunityIds
     * @return Map<String, SBQQ__Quote__c>
     */
    public static Map<Id, SBQQ__Quote__c> getExistingQuotesByAccountIds(Set<Id> opportunityIds) {
        return service().getExistingQuotesByAccountIds(opportunityIds);
    }

    /**
     * @description It is used to get existing QuotesLineGroups by the passed quoteIds.
     * @param quoteIds
     * @return Map<Id, SBQQ__QuoteLineGroup__c>
     */
    public static Map<Id, SBQQ__QuoteLineGroup__c> getQuoteLineGroupsByAccountIds(
        Set<Id> quoteIds
    ) {
        return service().getQuoteLineGroupsByAccountIds(quoteIds);
    }

    /**
     * @description It is used to create an instance of InstantIngestionCheckRecordsServiceImpl class.
     * @return InstantIngestionCheckRecordsService - return instance of InstantIngestionCheckRecordsServiceImpl
     */
    private static IInstantIngestionCheckRecordsService service() {
        return (IInstantIngestionCheckRecordsService) Application.Service.newInstance(
            IInstantIngestionCheckRecordsService.class
        );
    }

    /**
     * @description It is used to check if lead exists for the passed payload.
     * @param payloadWrapperByIngestionLogUUID
     * @param sObjectName
     * @return Map<Id,String>
     */
    public static Map<Id, String> getExistingSObjectsByMatchedRecordId(
        Map<String, InstantIngestionPayloadParser> payloadWrapperByIngestionLogUUID,
        String sObjectName
    ) {
        return service()
            .getExistingSObjectsByMatchedRecordId(payloadWrapperByIngestionLogUUID, sObjectName);
    }

    /**
     * @description It is used to get existing Subscriptions by the passed payload.
     * @param payLoadWrapperByIngestionLogUUID
     * @return Map<String, SBQQ__Subscription__c>
     */
    public static Map<String, SBQQ__Subscription__c> getExistingSubscriptionsByBusinessAccount(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID
    ) {
        return service()
            .getExistingSubscriptionsByBusinessAccount(payLoadWrapperByIngestionLogUUID);
    }

    /**
     * @description It is used to get existing Store Accounts by the passed storeIds.
     * @param mxPortalPayloadWrapperByUUID
     * @return Map<String, Account>
     */
    public static Map<String, Account> checkAndFetchExistingStoreAccountsByStoreId(
        Map<String, MxPortalPayloadParser> mxPortalPayloadWrapperByUUID
    ) {
        return service().checkAndFetchExistingStoreAccountsByStoreId(mxPortalPayloadWrapperByUUID);
    }
}