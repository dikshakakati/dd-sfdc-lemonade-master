/**
 * @author Deloitte
 * @date 06/23/2024
 * @description Interface of service class for InstantIngestionRecordsGetterService related logic.
 */
public interface IInstantIngestionRecordsGetterService {
    /**
     * @description It is used to get the business verticals by the unique identifiers.
     * @return Business_Vertical__c
     */
    Business_Vertical__c getRxBusinessVertical();

    /**
     * @description Retrieves a list of Account records associated with a given set of InstantIngestionPayloadParser objects.
     * @param payLoadWrapperByIngestionLogUUID A map of InstantIngestionPayloadParser objects, where the key is the Ingestion Log UUID and the value is the payload wrapper.
     * @return A list of Account records associated with the given InstantIngestionPayloadParser objects.
     */
    List<Account> getStoreAccountWithXref(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID
    );

    /**
     * @description It is used to get the business accounts by the unique identifiers.
     * @param payLoadWrapperByIngestionLogUUID
     * @param payLoadWrapperBySSOBUUID
     * @return Map<String, Account>
     */
    Map<String, Account> getBusinessAccountByUUID(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID,
        Map<String, SSOBOnboardingPayloadParser> payLoadWrapperBySSOBUUID
    );

    /**
     * @description It is used to get the brands by the unique identifiers.
     * @param payLoadWrapperByIngestionLogUUID
     * @param payLoadWrapperBySSOBUUID
     * @return Map<String, Brand__c>
     */
    Map<String, Brand__c> getBrandByUUID(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID,
        Map<String, SSOBOnboardingPayloadParser> payLoadWrapperBySSOBUUID
    );

    /**
     * @description It is used to get the store accounts by the unique identifiers.
     * @param payLoadWrapperByIngestionLogUUID
     * @return Map<String, Account>
     */
    Map<String, Account> getStoreAccountByUUID(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID
    );

    /**
     * @description It is used to get the business references by the unique identifiers.
     * @param payLoadWrapperByIngestionLogUUID
     * @param payLoadWrapperBySSOBUUID
     * @return Map<String, Business_Reference__c>
     */
    Map<String, Business_Reference__c> getBizRefByUUID(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID,
        Map<String, SSOBOnboardingPayloadParser> payLoadWrapperBySSOBUUID
    );

    /**
     * @description It is used to get the SBQQ__Quote__c by the unique identifiers.
     * @param payLoadWrapperByIngestionLogUUID
     * @param payLoadWrapperBySSOBUUID
     * @return Map<String, Opportunity>
     */
    Map<String, SBQQ__Quote__c> getQuotesByUUID(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID,
        Map<String, SSOBOnboardingPayloadParser> payLoadWrapperBySSOBUUID
    );

    /**
     * @description It is used to get the Quote Lines by the unique identifiers.
     * @param payLoadWrapperByIngestionLogUUID
     * @param payLoadWrapperBySSOBUUID
     * @return Map<String, SBQQ__QuoteLine__c>
     */
    Map<String, SBQQ__QuoteLine__c> getQuoteLinesByUUID(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID,
        Map<String, SSOBOnboardingPayloadParser> payLoadWrapperBySSOBUUID
    );

    /**
     * @description It is used to get the Quotes by the unique identifiers.
     * @param payLoadWrapperByIngestionLogUUID
     * @return Map<String, SBQQ__Quote__c>
     */
    Map<String, SBQQ__Quote__c> getQuotesByMxPortalUUID(
        Map<String, MxPortalPayloadParser> payLoadWrapperByIngestionLogUUID
    );

    /**
     * @description It is used to get the Quote Lines by the unique identifiers.
     * @param payLoadWrapperByIngestionLogUUID
     * @return Map<String, SBQQ__QuoteLine__c>
     */
    Map<String, SBQQ__QuoteLine__c> getQuoteLinesByMxPortalUUID(
        Map<String, MxPortalPayloadParser> payLoadWrapperByIngestionLogUUID
    );

    /**
     * @description It is used to get the Opportunities by the unique identifiers.
     * @param mxPortalPayLoadWrapperByIngestionLogUUID
     * @param ssobPayLoadWrapperByIngestionLogUUID
     * @return Map<String, Opportunity>
     */
    Map<String, Opportunity> getOpportunitiesByUUID(
        Map<String, MxPortalPayloadParser> mxPortalPayLoadWrapperByIngestionLogUUID,
        Map<String, SSOBOnboardingPayloadParser> ssobPayLoadWrapperByIngestionLogUUID
    );

    /**
     * @description It is used to get the existing Contracts by the business account.
     * @param storeAccountIds
     * @return Map<Id, Contract>
     */
    Map<Id, Contract> getExistingContractByBusinessAccount(Set<Id> storeAccountIds);

    /**
     * @description It is used to get the Submarket records for the Submarket Ids
     * received in the payload.
     * @param payloads
     * @return Map<String, Submarket__c>
     */
    Map<String, Submarket__c> getSubmarkets(List<InstantIngestionPayloadParser> payloads);

    /**
     * @description It is used to get the Contacts present in the system by the passed payload.
     * @param payLoadWrapperByIngestionLogUUID
     * @return Map<String,Contact>
     */
    Map<String, Contact> getContactsByMatchedRecord(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID
    );
}