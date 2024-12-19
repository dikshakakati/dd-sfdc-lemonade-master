/**
 * @author Deloitte
 * @date 06/23/2024
 * @description Service Implementation class for InstantIngestionRecordsGetterService.
 *
 */
public inherited sharing class InstantIngestionRecordsGetterServiceImpl implements IInstantIngestionRecordsGetterService {
    private static final Id BUSNINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Business')
        .getRecordTypeId();
    private static final Id STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Store')
        .getRecordTypeId();
    private static final String NINTEX_USECASE_MIDDLEWARE_PROVIDER = 'Middleware Provider';
    private static final String CONTRACT_SEGEMENT_SMB = 'SMB';
    private static final String CONTRACT_SPLIT_CATEGORY_ADS_PROMOS = 'A&P';

    /**
     * @description It is used to get the business verticals by the unique identifiers.
     * @return Business_Vertical__c
     */
    public Business_Vertical__c getRxBusinessVertical() {
        List<Business_Vertical__c> businessVertical = BusinessVerticalsSelector.newInstance()
            .selectBusinessVerticalByName(System.label.RestaurantMenuUIType);
        return businessVertical[0];
    }

    /**
     * @description Retrieves a list of Account records associated with a given set of InstantIngestionPayloadParser objects.
     * @param payLoadWrapperByIngestionLogUUID A map of InstantIngestionPayloadParser objects, where the key is the Ingestion Log UUID and the value is the payload wrapper.
     * @return A list of Account records associated with the given InstantIngestionPayloadParser objects.
     */
    public List<Account> getStoreAccountWithXref(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID
    ) {
        Set<String> bizIds = new Set<String>();
        for (
            InstantIngestionPayloadParser eachPayload : payLoadWrapperByIngestionLogUUID.values()
        ) {
            bizIds.add(eachPayload.business.businessId);
        }

        return AccountsSelector.newInstance()
            .selectStoreAccountByUUIDWithXrefs(payLoadWrapperByIngestionLogUUID.keyset(), bizIds);
    }

    /**
     * @description It is used to get the business accounts by the unique identifiers.
     * @param payLoadWrapperByIngestionLogUUID
     * @param payLoadWrapperBySSOBUUID
     * @return Map<String, Account>
     */
    public Map<String, Account> getBusinessAccountByUUID(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID,
        Map<String, SSOBOnboardingPayloadParser> payLoadWrapperBySSOBUUID
    ) {
        Map<String, Account> businessAccountByUUID = new Map<String, Account>();
        Set<String> uniqueIdentifiers = payLoadWrapperByIngestionLogUUID != null
            ? payLoadWrapperByIngestionLogUUID.keySet()
            : payLoadWrapperBySSOBUUID.keySet();
        for (
            Account eachAccount : AccountsSelector.newInstance()
                .selectAccountsByUniqueIdentifiersAndRecordType(
                    uniqueIdentifiers,
                    BUSNINESS_RECORD_TYPE_ID
                )
        ) {
            businessAccountByUUID.put(eachAccount.Unique_Identifier__c, eachAccount);
        }
        return businessAccountByUUID;
    }

    /**
     * @description It is used to get the brands by the unique identifiers.
     * @param payLoadWrapperByIngestionLogUUID
     * @param payLoadWrapperBySSOBUUID
     * @return Map<String, Brand__c>
     */
    public Map<String, Brand__c> getBrandByUUID(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID,
        Map<String, SSOBOnboardingPayloadParser> payLoadWrapperBySSOBUUID
    ) {
        Map<String, Brand__c> brandsByUUID = new Map<String, Brand__c>();
        Set<String> uniqueIdentifiers = payLoadWrapperByIngestionLogUUID != null
            ? payLoadWrapperByIngestionLogUUID.keySet()
            : payLoadWrapperBySSOBUUID.keySet();
        for (
            Brand__c eachBrand : BrandsSelector.newInstance()
                .selectBrandsByUniqueIdentifiers(uniqueIdentifiers)
        ) {
            brandsByUUID.put(eachBrand.Unique_Identifier__c, eachBrand);
        }
        return brandsByUUID;
    }

    /**
     * @description It is used to get the store accounts by the unique identifiers.
     * @param payLoadWrapperByIngestionLogUUID
     * @return Map<String, Account>
     */
    public Map<String, Account> getStoreAccountByUUID(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID
    ) {
        Map<String, Account> storeAccountByUUID = new Map<String, Account>();
        for (
            Account eachStoreAccount : AccountsSelector.newInstance()
                .selectAccountsByUniqueIdentifiersAndRecordType(
                    payLoadWrapperByIngestionLogUUID.keySet(),
                    STORE_RECORD_TYPE_ID
                )
        ) {
            storeAccountByUUID.put(eachStoreAccount.Unique_Identifier__c, eachStoreAccount);
        }
        return storeAccountByUUID;
    }

    /**
     * @description It is used to get the business references by the unique identifiers.
     * @param payLoadWrapperByIngestionLogUUID
     * @param payLoadWrapperBySSOBUUID
     * @return Map<String, Business_Reference__c>
     */
    public Map<String, Business_Reference__c> getBizRefByUUID(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID,
        Map<String, SSOBOnboardingPayloadParser> payLoadWrapperBySSOBUUID
    ) {
        Set<String> uniqueIdentifiers = payLoadWrapperByIngestionLogUUID != null
            ? payLoadWrapperByIngestionLogUUID.keySet()
            : payLoadWrapperBySSOBUUID.keySet();
        Map<String, Business_Reference__c> bizRefByUUID = new Map<String, Business_Reference__c>();
        for (
            Business_Reference__c eachBizRef : BusinessReferencesSelector.newInstance()
                .selectBusinessReferenceByUniqueIdentifiers(uniqueIdentifiers)
        ) {
            bizRefByUUID.put(eachBizRef.Unique_Identifier__c, eachBizRef);
        }
        return bizRefByUUID;
    }

    /**
     * @description It is used to get the Quotes by the unique identifiers.
     * @param payLoadWrapperByIngestionLogUUID
     * @param payLoadWrapperBySSOBUUID
     * @return Map<String, SBQQ__Quote__c>
     */
    public Map<String, SBQQ__Quote__c> getQuotesByUUID(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID,
        Map<String, SSOBOnboardingPayloadParser> payLoadWrapperBySSOBUUID
    ) {
        Set<String> uniqueIdentifiers = payLoadWrapperByIngestionLogUUID != null
            ? payLoadWrapperByIngestionLogUUID.keySet()
            : payLoadWrapperBySSOBUUID.keySet();
        Map<String, SBQQ__Quote__c> quotesByUUID = new Map<String, SBQQ__Quote__c>();
        for (
            SBQQ__Quote__c eachQuote : QuotesSelector.newInstance()
                .selectQuotesbyUniqueIdentifiers(uniqueIdentifiers)
        ) {
            quotesByUUID.put(eachQuote.Unique_Identifier__c, eachQuote);
        }
        return quotesByUUID;
    }

    /**
     * @description It is used to get the Quote Lines by the unique identifiers.
     * @param payLoadWrapperByIngestionLogUUID
     * @param payLoadWrapperBySSOBUUID
     * @return Map<String, SBQQ__QuoteLine__c>
     */
    public Map<String, SBQQ__QuoteLine__c> getQuoteLinesByUUID(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID,
        Map<String, SSOBOnboardingPayloadParser> payLoadWrapperBySSOBUUID
    ) {
        Set<String> uniqueIdentifiers = payLoadWrapperByIngestionLogUUID != null
            ? payLoadWrapperByIngestionLogUUID.keySet()
            : payLoadWrapperBySSOBUUID.keySet();
        Map<String, SBQQ__QuoteLine__c> quoteLinesByUUID = new Map<String, SBQQ__QuoteLine__c>();
        for (
            SBQQ__QuoteLine__c eachQuoteLine : QuoteLineItemsSelector.newInstance()
                .selectQuoteLinesbyUniqueIdentifiers(uniqueIdentifiers)
        ) {
            quoteLinesByUUID.put(eachQuoteLine.SBQQ__ProductName__c, eachQuoteLine);
        }
        return quoteLinesByUUID;
    }

    /**
     * @description It is used to get the Quotes by the unique identifiers.
     * @param payLoadWrapperByIngestionLogUUID
     * @return Map<String, SBQQ__Quote__c>
     */
    public Map<String, SBQQ__Quote__c> getQuotesByMxPortalUUID(
        Map<String, MxPortalPayloadParser> payLoadWrapperByIngestionLogUUID
    ) {
        Map<String, SBQQ__Quote__c> quotesByUUID = new Map<String, SBQQ__Quote__c>();
        for (
            SBQQ__Quote__c eachQuote : QuotesSelector.newInstance()
                .selectQuotesbyUniqueIdentifiers(payLoadWrapperByIngestionLogUUID.keySet())
        ) {
            quotesByUUID.put(eachQuote.Unique_Identifier__c, eachQuote);
        }
        return quotesByUUID;
    }

    /**
     * @description It is used to get the Quote Lines by the unique identifiers.
     * @param payLoadWrapperByIngestionLogUUID
     * @return Map<String, SBQQ__QuoteLine__c>
     */
    public Map<String, SBQQ__QuoteLine__c> getQuoteLinesByMxPortalUUID(
        Map<String, MxPortalPayloadParser> payLoadWrapperByIngestionLogUUID
    ) {
        Map<String, SBQQ__QuoteLine__c> quoteLinesByUUID = new Map<String, SBQQ__QuoteLine__c>();
        for (
            SBQQ__QuoteLine__c eachQuoteLine : QuoteLineItemsSelector.newInstance()
                .selectQuoteLinesbyUniqueIdentifiers(payLoadWrapperByIngestionLogUUID.keySet())
        ) {
            quoteLinesByUUID.put(eachQuoteLine.SBQQ__ProductName__c, eachQuoteLine);
        }
        return quoteLinesByUUID;
    }

    /**
     * @description It is used to get the Opportunities by the unique identifiers.
     * @param mxPortalPayLoadWrapperByIngestionLogUUID
     * @param ssobPayLoadWrapperByIngestionLogUUID
     * @return Map<String, Opportunity>
     */
    public Map<String, Opportunity> getOpportunitiesByUUID(
        Map<String, MxPortalPayloadParser> mxPortalPayLoadWrapperByIngestionLogUUID,
        Map<String, SSOBOnboardingPayloadParser> ssobPayLoadWrapperByIngestionLogUUID
    ) {
        Set<String> uniqueIdentifiers = mxPortalPayLoadWrapperByIngestionLogUUID != null
            ? mxPortalPayLoadWrapperByIngestionLogUUID.keySet()
            : ssobPayLoadWrapperByIngestionLogUUID.keySet();
        Map<String, Opportunity> opportunitiesByUUID = new Map<String, Opportunity>();
        for (
            Opportunity eachOpportunity : OpportunitiesSelector.newInstance()
                .getOpportunitiesbyUniqueIdentifiers(uniqueIdentifiers)
        ) {
            opportunitiesByUUID.put(eachOpportunity.Unique_Identifier__c, eachOpportunity);
        }
        return opportunitiesByUUID;
    }

    /**
     * @description It is used to get the existing Contract by the business account.
     * @param accountIds
     * @return Map<Id, Contract>
     */
    public Map<Id, Contract> getExistingContractByBusinessAccount(Set<Id> accountIds) {
        Map<Id, Contract> existingContractByBusinessAccountId = new Map<Id, Contract>();
        for (
            Agreement__c eachAgreement : AgreementsSelector.newInstance()
                .selectAgreementsByAccounts(accountIds)
        ) {
            if (
                (eachAgreement.Contract__r.Nintex_Use_Case__c ==
                NINTEX_USECASE_MIDDLEWARE_PROVIDER ||
                eachAgreement.Contract__r.Contract_Split_Category__c ==
                CONTRACT_SPLIT_CATEGORY_ADS_PROMOS) &&
                eachAgreement.Contract__r.Account.Segment__c == CONTRACT_SEGEMENT_SMB
            ) {
                continue;
            }
            existingContractByBusinessAccountId.put(
                eachAgreement.Contract__r.AccountId,
                eachAgreement.Contract__r
            );
        }
        //to handle for drive SSOB scenario where agreements are associated at stores.
        if (existingContractByBusinessAccountId.isEmpty()) {
            for (
                Contract eachContract : ContractsSelector.newInstance()
                    .selectCoreContractsByAccountIds(accountIds)
            ) {
                if (!existingContractByBusinessAccountId.containsKey(eachContract.AccountId)) {
                    existingContractByBusinessAccountId.put(eachContract.AccountId, eachContract);
                    break;
                }
            }
        }
        return existingContractByBusinessAccountId;
    }

    /**
     * @description It is used to get the Submarket records for the Submarket Ids
     * received in the payload.
     * @param payloads
     * @return Map<String, Submarket__c>
     */
    public Map<String, Submarket__c> getSubmarkets(List<InstantIngestionPayloadParser> payloads) {
        Set<String> submarketIdsByPayload = new Set<String>();
        Map<String, Submarket__c> submarketsToReturn = new Map<String, Submarket__c>();
        for (InstantIngestionPayloadParser eachInstantIngestionPayload : payloads) {
            submarketIdsByPayload.add(
                eachInstantIngestionPayload.store?.addressVerificationInfo?.submarket?.id
            );
        }
        if (!submarketIdsByPayload.isEmpty()) {
            for (
                Submarket__c eachSubmarket : SubmarketsSelector.newInstance()
                    .getSubmarketsByIds(submarketIdsByPayload)
            ) {
                submarketsToReturn.put(eachSubMarket.Submarket_ID__c, eachSubmarket);
            }
        }
        return submarketsToReturn;
    }

    /**
     * @description It is used to get the Contacts present in the system by the passed payload.
     * @param payLoadWrapperByIngestionLogUUID
     * @return Map<String,Contact>
     */
    public Map<String, Contact> getContactsByMatchedRecord(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID
    ) {
        List<Contact> contacts = new List<Contact>();
        Map<String, Contact> contactsFromMatchedRecord = new Map<String, Contact>();
        for (
            InstantIngestionPayloadParser eachPayload : payLoadWrapperByIngestionLogUUID.values()
        ) {
            for (Contact eachMatchedRecordsContact : eachPayload.store.matchedRecords.contact) {
                contacts.add(eachMatchedRecordsContact);
            }
            for (
                Contact contactFromMatchedRecor : ContactsSelector.newInstance()
                    .selectById(new Map<Id, Contact>(contacts).keySet())
            ) {
                contactsFromMatchedRecord.put(eachPayload.uuid, contactFromMatchedRecor);
            }
        }
        return contactsFromMatchedRecord;
    }
}