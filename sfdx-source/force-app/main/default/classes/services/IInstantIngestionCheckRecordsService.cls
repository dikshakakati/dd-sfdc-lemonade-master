/**
 * @author Deloitte
 * @date 06/06/2024
 * @description Interface class for InstantIngestionCheckRecordsService.
 */
public interface IInstantIngestionCheckRecordsService {
    /**
     * @description It is used to get existing Accounts by the passed businessIds.
     * @param payLoadWrapperByIngestionLogUUID
     * @param payLoadWrapperByIngestionLogUUIDForSSOB
     * @return set<String>
     */
    Map<String, Account> getExistingBusinessAccounts(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID,
        Map<String, SSOBOnboardingPayloadParser> payLoadWrapperByIngestionLogUUIDForSSOB
    );

    /**
     * @description It is used to get existing Opporunities by the passed accountIds.
     * @param accountIds
     * @return Map<Id, Opportunity>
     */
    Map<Id, Opportunity> fetchRelatedOpportunitiesAndQuotes(Set<Id> accountIds);

    /**
     * @description It is used to get existing Opporunities by the passed accountIds.
     * @param accountIds
     * @return Map<Id, Opportunity>
     */
    Map<Id, Opportunity> fetchRelatedExistingOpportunitiesAndPrimaryQuotes(Set<Id> accountIds);

    /**
     * @description It is used to get existing Contacts by the passed businessAccountIds.
     * @param businessAccountIds
     * @return Map<Id, Contact>
     */
    Map<Id, Contact> getExistingContactsByBusinessAccount(Set<Id> businessAccountIds);

    /**
     * @description It is used to get existing Business references by the passed businessIds.
     * @param businessIds
     * @return Map<Id, Business_Reference__c>
     */
    Map<String, Business_Reference__c> getExistingBusinessReferences(Set<String> businessIds);

    /**
     * @description It is used to get existing Brands by the passed accountIds.
     * @param accountIds
     * @return Map<Id, Brand__c>
     */
    Map<Id, Brand__c> getExistingBrands(Set<Id> accountIds);

    /**
     * @description It is used to get existing Store Accounts by the passed businessIds.
     * @param payLoadWrapperByIngestionLogUUID
     * @return Map<Id, Account>
     */
    Map<String, Account> getExistingStoreAccounts(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID
    );

    /**
     * @description It is used to get existing Quotes by the passed accountIds.
     * @param opportunityIds
     * @return Map<Id, SBQQ__Quote__c>
     */
    Map<Id, SBQQ__Quote__c> getExistingQuotesByAccountIds(Set<Id> opportunityIds);

    /**
     * @description It is used to get existing QuotesLineGroups by the passed quoteIds.
     * @param quoteIds
     * @return Map<Id, SBQQ__QuoteLineGroup__c>
     */
    Map<Id, SBQQ__QuoteLineGroup__c> getQuoteLineGroupsByAccountIds(Set<Id> quoteIds);

    /**
     * @description It is used to check if lead exists for the passed payload.
     * @param payloadWrapperByIngestionLogUUID
     * @param sObjectName
     * @return Map<Id,String>
     */
    Map<Id, String> getExistingSObjectsByMatchedRecordId(
        Map<String, InstantIngestionPayloadParser> payloadWrapperByIngestionLogUUID,
        String sObjectName
    );

    /**
     * @description It is used to get existing Subscriptions by the passed payload.
     * @param payLoadWrapperByIngestionLogUUID
     * @return Map<String, SBQQ__Subscription__c>
     */
    Map<String, SBQQ__Subscription__c> getExistingSubscriptionsByBusinessAccount(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID
    );

    /**
     * @description It is used to get existing Store Accounts by the passed storeIds.
     * @param mxPortalPayloadWrapperByUUID
     * @return Map<String, Account>
     */
    Map<String, Account> checkAndFetchExistingStoreAccountsByStoreId(
        Map<String, MxPortalPayloadParser> mxPortalPayloadWrapperByUUID
    );
}