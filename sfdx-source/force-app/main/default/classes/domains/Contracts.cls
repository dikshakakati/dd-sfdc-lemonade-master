/**
 * @author ATG
 * @date 2022-04-11
 * @description Domain Class for Contract Object
 */
public inherited sharing class Contracts extends fflib_SObjects implements IContracts {
    public static final String ACTIVATED = 'Activated';
    private static final String ADS_PROMOS = 'A&P';
    private static final String CORPORATE_ACCOUNT_IDS_CHUNK_SIZE_TO_SWITCH_PAYMENT_METHOD_STATIC_CONFIG = 'Corp_Acc_Size_To_Switch_Payment_Method';
    private static final String EVENT_TOPIC_UPDATE_FRANCHISE_ACCOUNT_TO_WITHHOLDING = 'UPDATE_FRANCHISE_ACCOUNT_TO_WITHHOLDING';
    private static final String EVENT_TOPIC_UPDATE_ADS_PROMOS_CONTRACT_TO_NULLIFY_CONTRACT_TERM = 'EVENT_TOPIC_UPDATE_ADS_PROMOS_CONTRACT_TO_NULLIFY_CONTRACT_TERM';
    private static final String PAYMENT_METHOD_INVOICING = 'Invoicing';
    private static final String PAYMENT_METHOD_WITHHOLDING = 'Withholding';
    private static final String CONTRACT_STATUS_ACTIVATED = 'Activated';
    private static final String SOURCE_SSOB = 'SSOB';
    private static final String INTEGRATION_SOURCE_NINTEX = 'Nintex';
    private static final String ADS_PROMO = 'A&P';
    private static final String QUOTE_SEGMENT_SMB = 'SMB';
    private static final String AMENDMENT = 'Amendment';
    private static final String CORE = 'Core';
    private Set<Id> adsAndPromosContractIds = new Set<Id>();
    private Set<String> contractIntegrationSourceForDrive = new Set<String>{
        INTEGRATION_SOURCE_NINTEX,
        SOURCE_SSOB
    };
    /**
     * @description This method is used to return the IContract interface
     * @param recordList - Contract record list
     * @return IContracts - Returns IContracts Interface
     */
    public static IContracts newInstance(List<Contract> recordList) {
        return (IContracts) Application.Domain.newInstance(recordList);
    }

    /**
     * @description Default constructor for the class
     * @param sObjectList
     */
    public Contracts(List<Contract> sObjectList) {
        super(sObjectList, Schema.Contract.SObjectType);
    }

    /**
     * @description set Order as Status = 'Activated'
     */
    public void activate() {
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        Set<Id> contractIds = new Set<Id>();
        for (Contract contract : (List<Contract>) getRecords()) {
            Contract newContract = new Contract(Id = contract.Id, Status = ACTIVATED);
            contractIds.add(contract.Id);
            uow.registerDirty(newContract);
        }

        uow.commitWork();
        fireBulkNotifierEvents(
            EVENT_TOPIC_UPDATE_ADS_PROMOS_CONTRACT_TO_NULLIFY_CONTRACT_TERM,
            30,
            contractIds
        );
    }

    /**
     * @description It is used to publish notifier events on contract's withholding amendment.
     * @param existingRecords
     * @JIRA# LEM-10617
     */
    public void publishNotifierEventsOnWithholdingAmendment(Map<Id, Contract> existingRecords) {
        Set<Id> corporateAccountIds = new Set<Id>();
        for (Contract eachContract : (List<Contract>) getRecords()) {
            if (
                existingRecords.containsKey(eachContract.Id) &&
                isEligibleContractToUpdateWithholdingOnFranchiseAccounts(
                    eachContract,
                    existingRecords.get(eachContract.Id)
                )
            ) {
                corporateAccountIds.add(eachContract.AccountId);
            }
        }
        if (corporateAccountIds.isEmpty()) {
            return;
        }
        Integer corporateAccountIdsChunkSizeToSwitchPaymentAccount = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(
                    CORPORATE_ACCOUNT_IDS_CHUNK_SIZE_TO_SWITCH_PAYMENT_METHOD_STATIC_CONFIG
                )
                .Configuration_Value__c
        );
        fireBulkNotifierEvents(
            EVENT_TOPIC_UPDATE_FRANCHISE_ACCOUNT_TO_WITHHOLDING,
            corporateAccountIdsChunkSizeToSwitchPaymentAccount,
            corporateAccountIds
        );
    }

    /**
     * @description Set Associated Accounts on the Contract with group and serialized entitlements data
     * @param associatedAccountsWrapperList
     * @param ccpApplied
     * @param ccpAnsoFlow
     */
    public void setAssociatedAccountsWithGroups(
        List<AssociatedAccountsWrapper> associatedAccountsWrapperList,
        Boolean ccpApplied,
        String ccpAnsoFlow
    ) {
        ContractAssociatedAccountsService.generateContractAssociationsWithGroupForExistingAndNewStores(
            associatedAccountsWrapperList,
            ccpApplied,
            ccpAnsoFlow
        );
    }

    /**
     * @description Sets the Quotes Fields On Contract on before insert scenario
     */
    public void setQuotesFieldsOnContract() {
        Map<Id, Contract> quoteIdsToContract = new Map<Id, Contract>();

        for (Contract con : (List<Contract>) getRecords()) {
            if (con.SBQQ__Quote__c == null) {
                continue;
            }
            quoteIdsToContract.put(con.SBQQ__Quote__c, con);
        }
        for (
            SBQQ__Quote__c quote : QuotesSelector.newInstance()
                .selectById(quoteIdsToContract.keySet())
        ) {
            quoteIdsToContract.get(quote.Id)
                .Franchise_Supplemental_Agreement_URL__c = quote.Franchise_Supplemental_Agreement_Link__c;
            quoteIdsToContract.get(quote.Id)
                .Master_Supplemental_Agreement_URL__c = quote.Signed_Contract_link__c;
        }
    }
    /**
     * @description It is utilized to initiate the store agreement creation for A&P Contracts once the contract is activated.
     * @JIRA #LEM-16431
     */
    public void initiateAdsAndPromoStoreAgreementsCreationOnContracts() {
        Set<Id> applicableBusinessAccounts = getApplicableBusinessAccounts();
        if (applicableBusinessAccounts.isEmpty()) {
            return;
        }
        Set<Id> adsAndPromoBusinessAccounts = new Set<Id>();
        Set<Id> coreContractIds = getCoreContractIds(
            applicableBusinessAccounts,
            adsAndPromoBusinessAccounts
        );
        if (coreContractIds.isEmpty()) {
            return;
        }

        Map<Id, Agreement__c> storeAgreements = getStoreAccountsForAssociation(coreContractIds);
        if (storeAgreements.isEmpty()) {
            return;
        }

        Map<Id, Set<String>> storeAccountsByParentId = getStoreAccountsByParentId(storeAgreements);

        getContractsForStoreAssociation(adsAndPromoBusinessAccounts, storeAccountsByParentId);
    }
    /**
     * @description Its used to filter Ads and Promo Contracts applicable for store association.
     * @JIRA #LEM-16431
     * @return Set<Id>
     */
    private Set<Id> getApplicableBusinessAccounts() {
        Set<Id> applicableBusinessAccounts = new Set<Id>();
        for (Contract eachContract : (List<Contract>) getRecords()) {
            if (
                (eachContract.Ads_Promo_Applicability__c ||
                eachContract.Has_Store_Count_Changed_On_Amendment__c) &&
                eachContract.Contract_Split_Category__c == ADS_PROMO &&
                eachContract.Status == CONTRACT_STATUS_ACTIVATED
            ) {
                adsAndPromosContractIds.add(eachContract.Id);
                applicableBusinessAccounts.add(eachContract.AccountId);
            }
        }
        return applicableBusinessAccounts;
    }
    /**
     * @description It is used to filter Ads and Promo Contracts applicable for store association by verifying the existence of any core contract on the Account.
     * @JIRA #LEM-16431
     * @param applicableBusinessAccounts
     * @param adsAndPromoBusinessAccounts
     * @return Set<Id>
     */
    private Set<Id> getCoreContractIds(
        Set<Id> applicableBusinessAccounts,
        set<Id> adsAndPromoBusinessAccounts
    ) {
        Set<Id> coreContractIds = new Set<Id>();
        for (
            Contract eachContract : ContractsSelector.newInstance()
                .selectCoreContractsByAccountIds(applicableBusinessAccounts)
        ) {
            coreContractIds.add(eachContract.Id);
            adsAndPromoBusinessAccounts.add(eachContract.AccountId);
        }
        return coreContractIds;
    }
    /**
     * @description It is used to retrieve and store accounts based on the provided business accounts.
     * @JIRA #LEM-16431
     * @param coreContractIds
     * @return Map<Id, Account>
     */
    private Map<Id, Agreement__c> getStoreAccountsForAssociation(Set<Id> coreContractIds) {
        return new Map<Id, Agreement__c>(
            AgreementsSelector.newInstance()
                .selectActiveAgreementsByCoreContractIds(coreContractIds)
        );
    }
    /**
     * @description It is used to map Store Account to there parent business Accounts.
     * @JIRA #LEM-16431
     * @param storeAgreements
     * @return Map<Id, Set<String>>
     */
    private Map<Id, Set<String>> getStoreAccountsByParentId(Map<Id, Agreement__c> storeAgreements) {
        Map<Id, Set<String>> storeAccountsByParentId = new Map<Id, Set<String>>();
        Set<Id> adsAndPromosStoreAccountIds = new Set<Id>();
        for (
            Agreement__c eachAdsAndPromosAgreement : AgreementsSelector.newInstance()
                .selectActiveAgreementsByAdsPromosContractIds(adsAndPromosContractIds)
        ) {
            adsAndPromosStoreAccountIds.add(eachAdsAndPromosAgreement.Account__c);
        }

        for (Agreement__c eachCoreAgreement : storeAgreements.values()) {
            if (adsAndPromosStoreAccountIds.contains(eachCoreAgreement.Account__c)) {
                continue;
            }
            if (!storeAccountsByParentId.containsKey(eachCoreAgreement.Account__r.ParentId)) {
                storeAccountsByParentId.put(
                    eachCoreAgreement.Account__r.ParentId,
                    new Set<String>()
                );
            }
            storeAccountsByParentId.get(eachCoreAgreement.Account__r.ParentId)
                .add(String.valueOf(eachCoreAgreement.Account__c));
        }

        return storeAccountsByParentId;
    }
    /**
     * @description It is utilized to initiate the creation of Agreements for validated Contracts.
     * @JIRA #LEM-16431
     * @param adsAndPromoBusinessAccounts
     * @param storeAccountsByParentId
     */
    private void getContractsForStoreAssociation(
        Set<Id> adsAndPromoBusinessAccounts,
        Map<Id, Set<String>> storeAccountsByParentId
    ) {
        List<Contract> contractsForStoreAssociation = new List<Contract>();
        Map<Id, Set<String>> contractsIdToStoreAccounts = new Map<Id, Set<String>>();
        for (Contract eachContract : (List<Contract>) getRecords()) {
            if (
                adsAndPromoBusinessAccounts.contains(eachContract.AccountId) &&
                storeAccountsByParentId.containsKey(eachContract.AccountId)
            ) {
                contractsIdToStoreAccounts.put(
                    eachContract.Id,
                    storeAccountsByParentId.get(eachContract.AccountId)
                );
                contractsForStoreAssociation.add(eachContract);
            }
        }
        if (contractsForStoreAssociation.isEmpty() || contractsIdToStoreAccounts.isEmpty()) {
            return;
        }

        AgreementsService.createAgreementsfromContractsWithGroup(
            contractsForStoreAssociation,
            contractsIdToStoreAccounts,
            new Map<Id, Map<Id, String>>{}
        );
    }

    /**
     * @description It is used to initiate the store agreement creation for SSMO process after the contract is Activated.
     * @JIRA #LEM-14589
     */
    public void initiateSSMOStoreAgreementCreationOnContracts() {
        List<Contract> updatedContracts = new List<Contract>();
        Map<Id, Id> businessAccountIdToContractId = new Map<Id, Id>();
        Map<Id, String> storeIdsByContractIds = new Map<Id, String>();
        Map<Id, Set<String>> contractIdWithDriveAccountIds = new Map<Id, Set<String>>();
        for (Contract eachContract : (List<Contract>) getRecords()) {
            updatedContracts.add(eachContract);
            if (contractIntegrationSourceForDrive.contains(eachContract.Integration_Source__c)) {
                contractIdWithDriveAccountIds.put(
                    eachContract.Id,
                    new Set<String>{ eachContract.AccountId }
                );
            } else if (eachContract.Unique_Identifier__c != null) {
                businessAccountIdToContractId.put(eachContract.Id, eachContract.AccountId);
                storeIdsByContractIds.put(eachContract.Id, eachContract.Store_Id__c);
            }
        }
        if (!contractIdWithDriveAccountIds.isEmpty()) {
            AgreementsService.createAgreementsfromContractsWithGroup(
                updatedContracts,
                contractIdWithDriveAccountIds,
                new Map<Id, Map<Id, String>>{}
            );
        } else if (!businessAccountIdToContractId.isEmpty()) {
            invokeAgreementsCreationForIntegration(
                businessAccountIdToContractId,
                storeIdsByContractIds,
                updatedContracts
            );
        }
    }

    /**
     * @description It is used to invoke the agreement creation process for integration sources.
     * @param businessAccountIdToContractId
     * @param storeIdsByContractIds
     * @param updatedContracts
     */
    private void invokeAgreementsCreationForIntegration(
        Map<Id, Id> businessAccountIdToContractId,
        Map<Id, String> storeIdsByContractIds,
        List<Contract> updatedContracts
    ) {
        Map<Id, Set<String>> contractIdWithAccountIds = new Map<Id, Set<String>>();
        Map<Id, Set<String>> storeAccountIdsByParentId = new Map<Id, Set<String>>();
        Map<Id, String> storeIdsByAccountIds = new Map<Id, String>();
        Map<Id, Account> storeAccountsById = new Map<Id, Account>(
            AccountsSelector.newInstance()
                .selectChildAccountsByCorporateOrFranchiseParent(
                    new Set<Id>(businessAccountIdToContractId.values())
                )
        );
        for (
            Xref__c eachXref : XrefsSelector.newInstance()
                .selectXrefByExternalIdOnly(storeIdsByContractIds.values())
        ) {
            storeIdsByAccountIds.put(eachXref.Salesforce_Account_Name__c, eachXref.External_ID__c);
        }
        for (Account eachStoreAccount : storeAccountsById.values()) {
            if (!storeIdsByAccountIds.containsKey(eachStoreAccount.Id)) {
                continue;
            }
            if (storeAccountIdsByParentId.containsKey(eachStoreAccount.Franchise_Parent__c)) {
                storeAccountIdsByParentId.get(eachStoreAccount.Franchise_Parent__c)
                    .add(eachStoreAccount.Id);
            } else if (storeAccountIdsByParentId.containsKey(eachStoreAccount.parentId)) {
                storeAccountIdsByParentId.get(eachStoreAccount.parentId).add(eachStoreAccount.Id);
            } else {
                storeAccountIdsByParentId = collectStoreAccountByParentOrFranchiseId(
                    eachStoreAccount,
                    storeAccountIdsByParentId
                );
            }
        }
        for (Contract eachContract : updatedContracts) {
            contractIdWithAccountIds = new Map<Id, Set<String>>{
                eachContract.Id => storeAccountIdsByParentId.get(eachContract.AccountId)
            };
        }
        if (storeAccountIdsByParentId.isEmpty()) {
            return;
        }
        AgreementsService.createAgreementsfromContractsWithGroup(
            updatedContracts,
            contractIdWithAccountIds,
            new Map<Id, Map<Id, String>>{}
        );
    }

    private Map<Id, Set<String>> collectStoreAccountByParentOrFranchiseId(
        Account eachStoreAccount,
        Map<Id, Set<String>> storeAccountIdsByParentId
    ) {
        if (eachStoreAccount.Franchise_Parent__c != null) {
            storeAccountIdsByParentId.put(
                eachStoreAccount.Franchise_Parent__c,
                new Set<String>{ eachStoreAccount.Id }
            );
        } else {
            storeAccountIdsByParentId.put(
                eachStoreAccount.ParentId,
                new Set<String>{ eachStoreAccount.Id }
            );
        }
        return storeAccountIdsByParentId;
    }

    /*
     * @description Holds a mock instance of the constructor inner class.
     * Setting this will provide the ability to test the records being injected into
     * the domain class when it is instantiated.
     */
    private static fflib_IDomainConstructor constructorMock;

    /**
     * @description It checks whether the contract eligible to update
     * "Payment Method" as 'Withholding' on franchise accounts.
     * @JIRA# LEM-10617
     * @param newContract
     * @param oldContract
     * @return Boolean
     */
    private Boolean isEligibleContractToUpdateWithholdingOnFranchiseAccounts(
        Contract newContract,
        Contract oldContract
    ) {
        return ((isPaymentMethodChangedFromInvoicingToWithholdingOnContractAmendment(
            newContract,
            oldContract
        ) || isMpBzIdChangedFromBlankToValueOnWithholdingContract(newContract, oldContract)));
    }

    /**
     * @description It is used to check whether "Payment Method" is changed
     * from 'Invoicing' to 'Withholding' on contract amendment.
     * @JIRA# LEM-10617
     * @param newContract
     * @param oldContract
     * @return Boolean
     */
    private Boolean isPaymentMethodChangedFromInvoicingToWithholdingOnContractAmendment(
        Contract newContract,
        Contract oldContract
    ) {
        return (oldContract.SBQQ__Order__c != newContract.SBQQ__Order__c &&
        oldContract.Payment_Method__c == PAYMENT_METHOD_INVOICING &&
        newContract.Payment_Method__c == PAYMENT_METHOD_WITHHOLDING &&
        newContract.MP_Bz_Id__c != null);
    }

    /**
     * @description It is used to check whether "Mp Bz Id" is changed from blank
     * to a value on 'Withholding' contract.
     * @JIRA# LEM-10617
     * @param newContract
     * @param oldContract
     * @return Boolean
     */
    private Boolean isMpBzIdChangedFromBlankToValueOnWithholdingContract(
        Contract newContract,
        Contract oldContract
    ) {
        return (oldContract.MP_Bz_Id__c == null &&
        oldContract.MP_Bz_Id__c != newContract.MP_Bz_Id__c &&
        newContract.Payment_Method__c == PAYMENT_METHOD_WITHHOLDING);
    }

    /**
     * @description It is used to publish the bulk notifier events for the passed values.
     * @param eventTopic
     * @param chunkSize
     * @param sObjectIds
     */
    private void fireBulkNotifierEvents(String eventTopic, Integer chunkSize, Set<Id> sObjectIds) {
        NotifierEventsService.publishBulkEvents(
            new Map<String, List<String>>{
                eventTopic => NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                    sObjectIds,
                    chunkSize
                )
            }
        );
    }

    /**
     * @description Private method that allows the domain constructor mock to be set by test class.
     * @param mock fflib_IDomainConstructor
     */
    @TestVisible
    private static void setConstructorMock(fflib_IDomainConstructor mock) {
        constructorMock = mock;
    }

    /**
     * @description This class is used for implementing fflib_IDomainConstructor Interface
     */
    public class Constructor implements fflib_IDomainConstructor {
        /**
         * @description Constructor method implementation from fflib_IDomainConstructor class
         * @param objectList
         * @return Contracts - List of Contracts
         */
        public fflib_SObjects construct(List<Object> objectList) {
            if (Contracts.constructorMock != null) {
                return (fflib_SObjects) Contracts.constructorMock.construct(objectList);
            }
            return new Contracts((List<SObject>) objectList);
        }
    }
}