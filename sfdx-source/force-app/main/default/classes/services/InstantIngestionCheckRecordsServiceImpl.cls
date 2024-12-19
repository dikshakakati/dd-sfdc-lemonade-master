/**
 * @author Deloitte
 * @date 06/06/2024
 * @description Service implementation class for InstantIngestionCheckRecordsService.
 */
public inherited sharing class InstantIngestionCheckRecordsServiceImpl implements IInstantIngestionCheckRecordsService {
    private static final String BUSINESS = 'Business';
    private static final String CONTACT_OBJECT = 'Contact';
    private static final String LEAD_OBJECT = 'Lead';
    private static final String STORE = 'Store';
    private enum SObjectTypes {
        CONTACT_OBJECT,
        LEAD_OBJECT
    }
    private static final Map<String, SObjectTypes> ELIGIBLE_SOBJECT_TYPE_MAPPING = new Map<String, SObjectTypes>{
        CONTACT_OBJECT => SObjectTypes.CONTACT_OBJECT,
        LEAD_OBJECT => SObjectTypes.LEAD_OBJECT
    };
    /**
     * @description It is used to get existing Accounts by the passed businessIds.
     * @param payLoadWrapperByIngestionLogUUID
     * @param payLoadWrapperByIngestionLogUUIDForSSOB
     * @return Map<String, Account>
     */
    public Map<String, Account> getExistingBusinessAccounts(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID,
        Map<String, SSOBOnboardingPayloadParser> payLoadWrapperByIngestionLogUUIDForSSOB
    ) {
        Map<String, Account> businessAccountByBusinessId = new Map<String, Account>();
        List<String> businessIds = new List<String>();
        if (!payLoadWrapperByIngestionLogUUID.isEmpty()) {
            businessIds = getBusinessIdForInstantIngestion(payLoadWrapperByIngestionLogUUID);
        } else {
            businessIds = getBusinessIdForSSOB(payLoadWrapperByIngestionLogUUIDForSSOB);
        }
        for (
            Xref__c existingAccountsByBusinessId : XrefsSelector.newInstance()
                .selectXrefByBusinessReferenceExternalId(businessIds)
        ) {
            if (existingAccountsByBusinessId.Account_Record_Type__c == BUSINESS) {
                businessAccountByBusinessId.put(
                    existingAccountsByBusinessId.BusinessID__c,
                    existingAccountsByBusinessId.Salesforce_Account_Name__r
                );
            } else if (existingAccountsByBusinessId.Account_Record_Type__c == STORE) {
                businessAccountByBusinessId.put(
                    existingAccountsByBusinessId.BusinessID__c,
                    existingAccountsByBusinessId.Salesforce_Account_Name__r.Parent
                );
            }
        }
        return businessAccountByBusinessId;
    }

    /**
     * @description It is used to get existing Store Accounts by the passed businessIds.
     * @param payLoadWrapperByIngestionLogUUID
     * @return Map<String, Account>
     */
    public Map<String, Account> getExistingStoreAccounts(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID
    ) {
        Map<String, Account> storeAccountByBusinessId = new Map<String, Account>();
        List<String> businessIds = new List<String>();
        for (
            InstantIngestionPayloadParser eachPayload : payLoadWrapperByIngestionLogUUID.values()
        ) {
            businessIds.add(eachPayload.business.businessId);
        }
        for (
            Xref__c existingAccountsByBusinessId : XrefsSelector.newInstance()
                .selectXrefByBusinessReferenceExternalId(businessIds)
        ) {
            if (existingAccountsByBusinessId.Account_Record_Type__c == STORE) {
                storeAccountByBusinessId.put(
                    existingAccountsByBusinessId.BusinessID__c,
                    existingAccountsByBusinessId.Salesforce_Account_Name__r
                );
            }
        }
        return storeAccountByBusinessId;
    }

    /**
     * @description It is used to get existing Opporunities by the passed accountIds.
     * @param accountIds
     * @return Map<Id, Opportunity>
     */
    public Map<Id, Opportunity> fetchRelatedOpportunitiesAndQuotes(Set<Id> accountIds) {
        Map<Id, Opportunity> existingOpportunityByAccount = new Map<Id, Opportunity>();
        for (
            Opportunity eachExistingOpportunity : OpportunitiesSelector.newInstance()
                .getExistingOpportunitiesAndPrimaryQuotesbyAccountNames(accountIds)
        ) {
            existingOpportunityByAccount.put(
                eachExistingOpportunity.AccountId,
                eachExistingOpportunity
            );
        }
        return existingOpportunityByAccount;
    }

    /**
     * @description It is used to get existing type Opporunities by the passed accountIds.
     * @param accountIds
     * @return Map<Id, Opportunity>
     */
    public Map<Id, Opportunity> fetchRelatedExistingOpportunitiesAndPrimaryQuotes(
        Set<Id> accountIds
    ) {
        Map<Id, Opportunity> existingOpportunityByAccount = new Map<Id, Opportunity>();
        for (
            Opportunity eachExistingOpportunity : OpportunitiesSelector.newInstance()
                .selectExistingNonAdsAndPromosOpportunities(accountIds)
        ) {
            existingOpportunityByAccount.put(
                eachExistingOpportunity.AccountId,
                eachExistingOpportunity
            );
        }
        return existingOpportunityByAccount;
    }

    /**
     * @description It is used to get existing Brands by the passed accountIds.
     * @param accountIds
     * @return Map<Id, Brand__c>
     */
    public Map<Id, Brand__c> getExistingBrands(Set<Id> accountIds) {
        Map<Id, Brand__c> existingBrandsByAccountId = new Map<Id, Brand__c>();
        for (
            Brand__c eachBrand : BrandsSelector.newInstance().selectBrandsByAccountIds(accountIds)
        ) {
            existingBrandsByAccountId.put(eachBrand.Brand_Owner__c, eachBrand);
        }
        return existingBrandsByAccountId;
    }

    /**
     * @description It is used to get existing Business references by the passed businessIds.
     * @param businessIds
     * @return Map<String, Business_Reference__c>
     */
    public Map<String, Business_Reference__c> getExistingBusinessReferences(
        Set<String> businessIds
    ) {
        Map<String, Business_Reference__c> bizRefByBusinessId = new Map<String, Business_Reference__c>();
        for (
            Business_Reference__c eachBizRef : BusinessReferencesSelector.newInstance()
                .selectBusRefByExternalId(businessIds)
        ) {
            bizRefByBusinessId.put(eachBizRef.External_ID__c, eachBizRef);
        }
        return bizRefByBusinessId;
    }

    /**
     * @description It is used to get existing Contacts by the passed businessAccountIds.
     * @param businessAccountIds
     * @return Map<Id, Contact>
     */
    public Map<Id, Contact> getExistingContactsByBusinessAccount(Set<Id> businessAccountIds) {
        Map<Id, Contact> contactsByBusinessAccountId = new Map<Id, Contact>();
        for (
            Contact eachContact : ContactsSelector.newInstance()
                .selectContactsByAccountIds(businessAccountIds)
        ) {
            contactsByBusinessAccountId.put(eachContact.AccountId, eachContact);
        }
        return contactsByBusinessAccountId;
    }

    /**
     * @description It is used to get existing Quotes by the passed accountIds.
     * @param opportunityIds
     * @return Map<Id, SBQQ__Quote__c>
     */
    public Map<Id, SBQQ__Quote__c> getExistingQuotesByAccountIds(Set<Id> opportunityIds) {
        Map<Id, SBQQ__Quote__c> quotesByOpportunityIds = new Map<Id, SBQQ__Quote__c>();
        for (
            SBQQ__Quote__c eachQuote : QuotesSelector.newInstance()
                .selectByOpportunity(opportunityIds)
        ) {
            quotesByOpportunityIds.put(eachQuote.SBQQ__Account__c, eachQuote);
        }
        return quotesByOpportunityIds;
    }

    /**
     * @description It is used to get existing QuotesLineGroups by the passed quoteIds.
     * @param quoteIds
     * @return Map<Id, SBQQ__QuoteLineGroup__c>
     */
    public Map<Id, SBQQ__QuoteLineGroup__c> getQuoteLineGroupsByAccountIds(Set<Id> quoteIds) {
        Map<Id, SBQQ__QuoteLineGroup__c> quoteLineGroupsByAccountIds = new Map<Id, SBQQ__QuoteLineGroup__c>();
        for (
            SBQQ__QuoteLineGroup__c eachQuoteLineGroup : QuoteLineGroupSelector.newInstance()
                .selectQuoteLineGroupsByQuoteIds(quoteIds)
        ) {
            quoteLineGroupsByAccountIds.put(
                eachQuoteLineGroup.SBQQ__Account__c,
                eachQuoteLineGroup
            );
        }
        return quoteLineGroupsByAccountIds;
    }

    /**
     * @description It is used to check if lead exists for the passed payload.
     * @param payloadWrapperByIngestionLogUUID
     * @param sObjectName
     * JIRA# LEM-14638,LEM-19353
     * @return Map<Id,String>
     */
    public Map<Id, String> getExistingSObjectsByMatchedRecordId(
        Map<String, InstantIngestionPayloadParser> payloadWrapperByIngestionLogUUID,
        String sObjectName
    ) {
        Map<Id, String> sObjectIdToUniqueId = new Map<Id, String>();
        for (
            InstantIngestionPayloadParser eachPayload : payloadWrapperByIngestionLogUUID.values()
        ) {
            switch on ELIGIBLE_SOBJECT_TYPE_MAPPING.get(sObjectName) {
                when LEAD_OBJECT {
                    sObjectIdToUniqueId = collectsObjectIdToUniqueId(
                        eachPayload.store.MatchedRecords.lead,
                        eachPayload.uuid
                    );
                }
                when CONTACT_OBJECT {
                    sObjectIdToUniqueId = collectsObjectIdToUniqueId(
                        eachPayload.store.MatchedRecords.contact,
                        eachPayload.uuid
                    );
                }
            }
        }
        return sObjectIdToUniqueId;
    }

    /**
     * @description It is used to get existing Subscriptions by the passed payload.
     * @param payLoadWrapperByIngestionLogUUID
     * @return Map<String, SBQQ__Subscription__c>
     */
    public Map<String, SBQQ__Subscription__c> getExistingSubscriptionsByBusinessAccount(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID
    ) {
        Map<String, Account> existingBusinessAccountByBusinessId = getExistingBusinessAccounts(
            payLoadWrapperByIngestionLogUUID,
            new Map<String, SSOBOnboardingPayloadParser>()
        );
        Map<Id, String> businessIdsByBusinessAccount = new Map<Id, String>();
        for (String eachBusinessId : existingBusinessAccountByBusinessId.keySet()) {
            businessIdsByBusinessAccount.put(
                existingBusinessAccountByBusinessId.get(eachBusinessId).Id,
                eachBusinessId
            );
        }
        Map<String, SBQQ__Subscription__c> existingSubscriptionsByAccountd = new Map<String, SBQQ__Subscription__c>();
        for (
            SBQQ__Subscription__c eachExistingSubscription : SubscriptionSelector.newInstance()
                .querySubscriptionRecordsWithAccountIds(
                    new Map<Id, Account>(existingBusinessAccountByBusinessId.values()).keySet()
                )
        ) {
            if (
                eachExistingSubscription.Package__c != null &&
                eachExistingSubscription.SBQQ__TerminatedDate__c == null
            ) {
                String key =
                    businessIdsByBusinessAccount.get(eachExistingSubscription.SBQQ__Account__c) +
                    eachExistingSubscription.SBQQ__QuoteLine__r.Package_Product__c;
                existingSubscriptionsByAccountd.put(key, eachExistingSubscription);
            }
        }
        return existingSubscriptionsByAccountd;
    }

    /**
     * @description It is used to get existing Store Accounts by the passed storeIds.
     * @param mxPortalPayloadWrapperByUUID
     * @return Map<String, Account>
     */
    public Map<String, Account> checkAndFetchExistingStoreAccountsByStoreId(
        Map<String, MxPortalPayloadParser> mxPortalPayloadWrapperByUUID
    ) {
        Map<String, Account> storeAccountByBusinessId = new Map<String, Account>();
        List<String> storeIds = new List<String>();
        for (MxPortalPayloadParser eachPayload : mxPortalPayloadWrapperByUUID.values()) {
            storeIds.add(eachPayload.store.storeId);
        }
        for (
            Xref__c existingAccountsByStoreExternalId : XrefsSelector.newInstance()
                .selectXrefByExternalIdOnly(storeIds)
        ) {
            storeAccountByBusinessId.put(
                existingAccountsByStoreExternalId.External_ID__c,
                existingAccountsByStoreExternalId.Salesforce_Account_Name__r
            );
        }
        return storeAccountByBusinessId;
    }

    /**
     * @description It is used to collect sObjectId to Unique Id in a map.
     * @JIRA# LEM-19353
     * @param sObjects
     * @param uniqueIdentifier
     * @return Map<Id, String>
     */
    private Map<Id, String> collectsObjectIdToUniqueId(
        List<SObject> sObjects,
        String uniqueIdentifier
    ) {
        Map<Id, String> sObjectIdToUniqueId = new Map<Id, String>();
        for (SObject eachsObject : sObjects) {
            sObjectIdToUniqueId.put(eachsObject.Id, uniqueIdentifier);
        }
        return sObjectIdToUniqueId;
    }

    /**
     * @description It is used to get business Id for SSOB.
     * @param payLoadWrapperByIngestionLogUUIDForSSOB
     * @return List<String>
     */
    private List<String> getBusinessIdForSSOB(
        Map<String, SSOBOnboardingPayloadParser> payLoadWrapperByIngestionLogUUIDForSSOB
    ) {
        List<String> businessIds = new List<String>();
        for (
            SSOBOnboardingPayloadParser eachPayload : payLoadWrapperByIngestionLogUUIDForSSOB.values()
        ) {
            businessIds.add(eachPayload.account.businessId);
        }
        return businessIds;
    }

    /**
     * @description It is used to get business Id for Instant Ingestion.
     * @param payLoadWrapperByIngestionLogUUID
     * @return List<String>
     */
    private List<String> getBusinessIdForInstantIngestion(
        Map<String, InstantIngestionPayloadParser> payLoadWrapperByIngestionLogUUID
    ) {
        List<String> businessIds = new List<String>();
        for (
            InstantIngestionPayloadParser eachPayload : payLoadWrapperByIngestionLogUUID.values()
        ) {
            businessIds.add(eachPayload.business.businessId);
        }
        return businessIds;
    }
}