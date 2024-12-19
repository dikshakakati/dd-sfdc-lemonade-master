/**
 * @author Deloitte
 * @date 06/23/2024
 * @description Service class to get SObject records by ingestion unique identifiers.
 *
 */
public inherited sharing class InstantIngestionRecordsGetterService {
    /**
     * @description It is used to get the business verticals by the unique identifiers.
     * @return Business_Vertical__c
     */
    public static Business_Vertical__c getRxBusinessVertical() {
        return service().getRxBusinessVertical();
    }

    /**
     * @description It is used to get the business accounts by the unique identifiers.
     * @param payLoadWrapperByIngestionLogUUID
     * @param payLoadWrapperBySSOBUUID
     * @return Map<String, Account>
     */
    public static Map<String, Account> getBusinessAccountByUUID(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID,
        Map<String, SSOBOnboardingPayloadParser> payLoadWrapperBySSOBUUID
    ) {
        return service()
            .getBusinessAccountByUUID(payLoadWrapperByIngestionLogUUID, payLoadWrapperBySSOBUUID);
    }
    /**
     * @description Retrieves a list of Account records associated with a given set of InstantIngestionPayloadParser objects.
     * @param payLoadWrapperByIngestionLogUUID A map of InstantIngestionPayloadParser objects, where the key is the Ingestion Log UUID and the value is the payload wrapper.
     * @return A list of Account records associated with the given InstantIngestionPayloadParser objects.
     */
    public static List<Account> getStoreAccountWithXref(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID
    ) {
        return service().getStoreAccountWithXref(payLoadWrapperByIngestionLogUUID);
    }

    /**
     * @description It is used to get the brands by the unique identifiers.
     * @param payLoadWrapperByIngestionLogUUID
     * @param payLoadWrapperBySSOBUUID
     * @return Map<String, Brand__c>
     */
    public static Map<String, Brand__c> getBrandByUUID(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID,
        Map<String, SSOBOnboardingPayloadParser> payLoadWrapperBySSOBUUID
    ) {
        return service().getBrandByUUID(payLoadWrapperByIngestionLogUUID, payLoadWrapperBySSOBUUID);
    }

    /**
     * @description It is used to get the store accounts by the unique identifiers.
     * @param payLoadWrapperByIngestionLogUUID
     * @return Map<String, Account>
     */
    public static Map<String, Account> getStoreAccountByUUID(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID
    ) {
        return service().getStoreAccountByUUID(payLoadWrapperByIngestionLogUUID);
    }

    /**
     * @description It is used to get the business references by the unique identifiers.
     * @param payLoadWrapperByIngestionLogUUID
     * @param payLoadWrapperBySSOBUUID
     * @return Map<String, Business_Reference__c>
     */
    public static Map<String, Business_Reference__c> getBizRefByUUID(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID,
        Map<String, SSOBOnboardingPayloadParser> payLoadWrapperBySSOBUUID
    ) {
        return service()
            .getBizRefByUUID(payLoadWrapperByIngestionLogUUID, payLoadWrapperBySSOBUUID);
    }

    /**
     * @description It is used to get the Quotes by the unique identifiers.
     * @param payLoadWrapperByIngestionLogUUID
     * @param payLoadWrapperBySSOBUUID
     * @return Map<String, Opportunity>
     */
    public static Map<String, SBQQ__Quote__c> getQuotesByUUID(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID,
        Map<String, SSOBOnboardingPayloadParser> payLoadWrapperBySSOBUUID
    ) {
        return service()
            .getQuotesByUUID(payLoadWrapperByIngestionLogUUID, payLoadWrapperBySSOBUUID);
    }

    /**
     * @description It is used to get the Quote Lines by the unique identifiers.
     * @param payLoadWrapperByIngestionLogUUID
     * @param payLoadWrapperBySSOBUUID
     * @return Map<String, SBQQ__QuoteLine__c>
     */
    public static Map<String, SBQQ__QuoteLine__c> getQuoteLinesByUUID(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID,
        Map<String, SSOBOnboardingPayloadParser> payLoadWrapperBySSOBUUID
    ) {
        return service()
            .getQuoteLinesByUUID(payLoadWrapperByIngestionLogUUID, payLoadWrapperBySSOBUUID);
    }

    /**
     * @description It is used to get the Quotes by the unique identifiers.
     * @param payLoadWrapperByIngestionLogUUID
     * @return Map<String, SBQQ__Quote__c>
     */
    public static Map<String, SBQQ__Quote__c> getQuotesByMxPortalUUID(
        Map<String, MxPortalPayloadParser> payLoadWrapperByIngestionLogUUID
    ) {
        return service().getQuotesByMxPortalUUID(payLoadWrapperByIngestionLogUUID);
    }

    /**
     * @description It is used to get the Quote Lines by the mx portal unique identifiers.
     * @param payLoadWrapperByIngestionLogUUID
     * @return Map<String, SBQQ__QuoteLine__c>
     */
    public static Map<String, SBQQ__QuoteLine__c> getQuoteLinesByMxPortalUUID(
        Map<String, MxPortalPayloadParser> payLoadWrapperByIngestionLogUUID
    ) {
        return service().getQuoteLinesByMxPortalUUID(payLoadWrapperByIngestionLogUUID);
    }

    /**
     * @description It is used to get the Opportunities by the mx portal unique identifiers.
     * @param mxPortalPayLoadWrapperByIngestionLogUUID
     * @param ssobPayLoadWrapperByIngestionLogUUID
     * @return Map<String, Opportunity>
     */
    public static Map<String, Opportunity> getOpportunitiesByUUID(
        Map<String, MxPortalPayloadParser> mxPortalPayLoadWrapperByIngestionLogUUID,
        Map<String, SSOBOnboardingPayloadParser> ssobPayLoadWrapperByIngestionLogUUID
    ) {
        return service()
            .getOpportunitiesByUUID(
                mxPortalPayLoadWrapperByIngestionLogUUID,
                ssobPayLoadWrapperByIngestionLogUUID
            );
    }

    /**
     * @description It is used to get the existing Contracts by the business accounts.
     * @param storeAccountIds
     * @return Map<Id, Contract>
     */
    public static Map<Id, Contract> getExistingContractByBusinessAccount(Set<Id> storeAccountIds) {
        return service().getExistingContractByBusinessAccount(storeAccountIds);
    }

    /**
     * @description It is used to get the Submarket records for the Submarket Ids
     * received in the payload.
     * @param payloads
     * @return Map<String, Submarket__c>
     */
    public static Map<String, Submarket__c> getSubmarkets(
        List<InstantIngestionPayloadParser> payloads
    ) {
        return service().getSubmarkets(payloads);
    }

    /**
     * @description It is used to get the Contacts present in the system by the passed payload.
     * @param payLoadWrapperByIngestionLogUUID
     * @return Map<String,Contact>
     */
    public static Map<String, Contact> getContactsByMatchedRecord(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID
    ) {
        return service().getContactsByMatchedRecord(payLoadWrapperByIngestionLogUUID);
    }

    /**
     * @description It is used to create an instance of InstantIngestionRecordsGetterService class.
     * @return IInstantIngestionRecordsGetterService - return instance of InstantIngestionRecordsGetterServiceImpl
     */
    private static IInstantIngestionRecordsGetterService service() {
        return (IInstantIngestionRecordsGetterService) Application.Service.newInstance(
            IInstantIngestionRecordsGetterService.class
        );
    }
}