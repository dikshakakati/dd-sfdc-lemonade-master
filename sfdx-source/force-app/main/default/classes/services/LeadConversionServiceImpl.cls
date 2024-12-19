/**
 * @author Deloitte
 * @date 06/03/2024
 * @description Service implementation class for Lead Conversion service related logic.
 */
public inherited sharing class LeadConversionServiceImpl implements ILeadConversionService {
    private static final String LOG_DOMAIN = 'Sales';
    private static final String LOG_SOBJECT_CREATION_ERROR = 'Business Reference and Xref creation failed on manual Lead conversion.';
    private static final String LEAD_SOBJECT_TYPE = 'Lead';
    private static final Schema.SObjectType SOBJECTTYPE = ((SObject) Type.forName(LEAD_SOBJECT_TYPE)
            .newInstance())
        .getSObjectType()
        .getDescribe()
        .getSObjectType();
    private static final Map<String, Schema.SObjectField> SOBJECTFIELDS = SOBJECTTYPE.getDescribe()
        .fields.getMap();
    private static List<StaticResource> leadSObjectsConversionFieldMappingStaticResource;
    private Business_Reference__c businessReferenceToBeMappedOnXRef;

    static {
        leadSObjectsConversionFieldMappingStaticResource = StaticResourcesSelector.newInstance()
            .selectByName(System.Label.LeadConversionSObjectsMapping);
    }

    /**
     * @description It is used to return 'Active' Contracts on the passed Opportunities
     * associated Accounts.
     * @JIRA# LEM-16299
     * @param opportunities
     * @return Map<Id, List<Contract>>
     */
    public Map<Id, List<Contract>> collectContractsOnAssociatedAccounts(
        List<Opportunity> opportunities
    ) {
        Map<Id, List<Contract>> accountIdToContracts = new Map<Id, List<Contract>>();
        Set<Id> accountIds = new Set<Id>();
        for (Opportunity eachOpportunity : opportunities) {
            accountIds.add(eachOpportunity.AccountId);
        }
        if (accountIds.isEmpty()) {
            return accountIdToContracts;
        }
        for (
            Contract eachContract : ContractsSelector.newInstance()
                .selectByParentAccountId(accountIds)
        ) {
            if (eachContract.Account.Is_Lead_Converted_To_Existing_Account__c) {
                if (!accountIdToContracts.containsKey(eachContract.AccountId)) {
                    accountIdToContracts.put(eachContract.AccountId, new List<Contract>());
                }
                accountIdToContracts.get(eachContract.AccountId).add(eachContract);
            }
        }
        return accountIdToContracts;
    }

    /**
     * @description It initiates sObjects creation on passed manually converted Lead Ids.
     * @JIRA# LEM-14727
     * @param manuallyConvertedLeadIds
     * @param leadToNewStoreAccount
     */
    public void initiateSObjectsCreationOnManualLeadConversion(
        Set<Id> manuallyConvertedLeadIds,
        Map<Id, Account> leadToNewStoreAccount
    ) {
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        Business_Reference__c businessReferenceToCreate = new Business_Reference__c();
        List<Lead> convertedLeads = new List<Lead>();
        Set<String> storeIdsOnConvertedLead = new Set<String>();
        Set<String> businessIdsOnConvertedLead = new Set<String>();
        for (Lead eachLead : LeadsSelector.newInstance().selectById(manuallyConvertedLeadIds)) {
            if (eachLead.SSMO_UUID__c != null) {
                convertedLeads.add(eachLead);
                storeIdsOnConvertedLead.add(eachLead.Store_ID__c);
                businessIdsOnConvertedLead.add(eachLead.Business_ID__c);
            }
        }
        List<Business_Reference__c> existingBusinessReferences = BusinessReferencesSelector.newInstance()
            .selectBusRefByExternalId(businessIdsOnConvertedLead);
        if (!existingBusinessReferences.isEmpty()) {
            businessReferenceToBeMappedOnXRef = existingBusinessReferences[0];
        } else {
            businessReferenceToCreate = createBusinessRef(convertedLeads, uow);
        }
        if (searchStoresByStoreId(storeIdsOnConvertedLead).isEmpty()) {
            createXref(convertedLeads, leadToNewStoreAccount, uow);
        }
        try {
            uow.commitWork();
        } catch (Exception ex) {
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_SOBJECT_CREATION_ERROR,
                        LOG_DOMAIN,
                        GenericLogEntry.SeverityLevel.LOW
                    )
                    .logException(ex)
            );
        }
    }

    /**
     * @description It collects Accounts from the passed converted Account Ids.
     * @param convertedAccountIds
     * @return List<Account>
     */
    private List<Account> collectAccounts(Set<Id> convertedAccountIds) {
        return AccountsSelector.newInstance().selectById(convertedAccountIds);
    }

    /**
     * @description It creates Business Ref on Account.
     * @param convertedLeads
     * @param uow
     * @return Business_Reference__c
     */
    private Business_Reference__c createBusinessRef(
        List<Lead> convertedLeads,
        fflib_ISObjectUnitOfWork uow
    ) {
        Map<String, String> businessReferenceFieldToValue = new Map<String, String>();
        Business_Reference__c businessReferenceToCreate = new Business_Reference__c();
        String valueToApply;
        Set<Id> convertedAccountIds = new Set<Id>();
        if (leadSObjectsConversionFieldMappingStaticResource != null) {
            businessReferenceFieldToValue = LeadConversionMappingService.collectFieldValueMappings(
                LeadConversionMappingService.collectFields(
                    leadSObjectsConversionFieldMappingStaticResource[0].Body
                ),
                'Business_Reference__c'
            );
        }
        if (!businessReferenceFieldToValue.isEmpty()) {
            for (Lead eachLead : convertedLeads) {
                for (String eachBusinessReferenceField : businessReferenceFieldToValue.keySet()) {
                    valueToApply = businessReferenceFieldToValue.get(eachBusinessReferenceField);
                    businessReferenceToCreate.put(
                        eachBusinessReferenceField,
                        SOBJECTFIELDS.containsKey(valueToApply)
                            ? eachLead.get(ValueToApply)
                            : valueToApply
                    );
                }
                convertedAccountIds.add(eachLead.ConvertedAccountId);
                businessReferenceToCreate.put(
                    'CurrencyIsoCode',
                    populateAccountCurrency(convertedAccountIds)
                );
            }
        }
        uow.registerNew(businessReferenceToCreate);
        businessReferenceToBeMappedOnXRef = businessReferenceToCreate;
        return businessReferenceToCreate;
    }

    /**
     * @description It creates XREF on Account.
     * @param convertedLeads
     * @param leadToNewStoreAccount
     * @param uow
     */
    private void createXref(
        List<Lead> convertedLeads,
        Map<Id, Account> leadToNewStoreAccount,
        fflib_ISObjectUnitOfWork uow
    ) {
        Map<String, String> xrefFieldToValue = new Map<String, String>();
        Xref__c xrefToCreate = new Xref__c();
        String valueToApply;
        Id storeAccountId = null;
        if (
            leadSObjectsConversionFieldMappingStaticResource == null ||
            leadSObjectsConversionFieldMappingStaticResource.isEmpty()
        ) {
            return;
        }
        xrefFieldToValue = LeadConversionMappingService.collectFieldValueMappings(
            LeadConversionMappingService.collectFields(
                leadSObjectsConversionFieldMappingStaticResource[0].Body
            ),
            'Xref__c'
        );
        if (xrefFieldToValue.isEmpty()) {
            return;
        }
        for (Lead eachLead : convertedLeads) {
            for (String eachXrefField : xrefFieldToValue.keySet()) {
                valueToApply = xrefFieldToValue.get(eachXrefField);
                xrefToCreate.put(
                    eachXrefField,
                    SOBJECTFIELDS.containsKey(valueToApply)
                        ? eachLead.get(ValueToApply)
                        : valueToApply
                );
            }
            if (leadToNewStoreAccount != null && leadToNewStoreAccount.containsKey(eachLead.Id)) {
                storeAccountId = leadToNewStoreAccount.get(eachLead.Id).Id;
            }
            xrefToCreate.Salesforce_Account_Name__c = storeAccountId;
        }
        uow.registerNew(
            xrefToCreate,
            Xref__c.Business_Reference__c,
            businessReferenceToBeMappedOnXRef
        );
    }

    /**
     * @description It gets Account currency to be populated on Business Reference.
     * @param convertedAccountIds
     * @return String
     */
    private String populateAccountCurrency(Set<Id> convertedAccountIds) {
        String accountCurrency;
        for (Account eachAccount : collectAccounts(convertedAccountIds)) {
            accountCurrency = eachAccount.CurrencyIsoCode;
        }
        return accountCurrency;
    }

    /**
     * @description It checks for the related XREF for the given Store Accounts.
     * @param storeIdsToSearch
     * @return Map<String, Account>
     */
    private Map<String, Account> searchStoresByStoreId(Set<String> storeIdsToSearch) {
        Map<String, Account> storeIdToStoreAccount = new Map<String, Account>();
        if (storeIdsToSearch.isEmpty()) {
            return storeIdToStoreAccount;
        }
        for (
            Xref__c eachXref : XrefsSelector.newInstance()
                .selectXrefByExternalId(new List<String>(storeIdsToSearch))
        ) {
            storeIdToStoreAccount.put(eachXref.External_ID__c, eachXref.Salesforce_Account_Name__r);
        }
        return storeIdToStoreAccount;
    }
}