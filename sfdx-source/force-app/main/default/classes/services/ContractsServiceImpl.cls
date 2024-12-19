/**
 * @author Deloitte
 * @date 17/06/2022
 * @description Service class implementation for Contracts
 * Suppressed Warning to deliver P0 Hotfix Enhancement (LEM-23361).
 * TODO: Resolve the CyclomaticCmplexity issue.
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
public inherited sharing class ContractsServiceImpl implements IContractsService {
    private static final String CONTRACT_STATUS_ACTIVATED = 'Activated';
    @testvisible
    private static final String STATUS_ACTIVE = 'Active';
    @testvisible
    private static final String LIST_DELIMETER = ', ';
    @testvisible
    private static final String LIST_HAS_MORE = 'etc';
    @testvisible
    private static final String LIST_END = ' ';
    @testvisible
    private static final String MSA_CONTRACT = 'MSA';
    @testvisible
    private static final String AD_PROMO_CONTRACT = 'Ads and Promotion';
    private static final String CONTRACT_SPLIT_CATEGORY_ADS_PROMOS = 'A&P';
    private static final String AGGREGATE_AGREEMENT_COUNT_FIELD_ALIAS = 'agreementsCount';
    private static final String AGGREGATE_CORPORATEACCOUNTID_FIELD_ALIAS = 'corporateAccountId';
    private Integer corporateAccountIdsChunkSizeToSwitchPaymentAccount;
    private static final String CORPORATE_ACCOUNT_IDS_CHUNK_SIZE_TO_SWITCH_PAYMENT_METHOD_STATIC_CONFIG = 'Corp_Acc_Size_To_Switch_Payment_Method';
    private static final String DRIVE_PLATFORM = 'Drive';
    private static final String ESCAPE_SEQUENCE = '\\';
    private static final String EVENT_TOPIC_UPDATE_FRANCHISE_ACCOUNT_TO_WITHHOLDING = 'UPDATE_FRANCHISE_ACCOUNT_TO_WITHHOLDING';
    private static final String EVENT_TOPIC_UPDATE_ADS_PROMOS_CONTRACT_TO_NULLIFY_CONTRACT_TERM = 'EVENT_TOPIC_UPDATE_ADS_PROMOS_CONTRACT_TO_NULLIFY_CONTRACT_TERM';
    private enum EventTopics {
        EVENTTOPIC_UPDATE_FRANCHISE_ACCOUNT_TO_WITHHOLDING,
        EVENT_TOPIC_UPDATE_ADS_PROMOS_CONTRACT_TO_NULLIFY_CONTRACT_TERM
    }
    private static final Map<String, EventTopics> EVENT_TOPIC_MAPPINGS = new Map<String, EventTopics>{
        EVENT_TOPIC_UPDATE_FRANCHISE_ACCOUNT_TO_WITHHOLDING => EventTopics.EVENTTOPIC_UPDATE_FRANCHISE_ACCOUNT_TO_WITHHOLDING,
        EVENT_TOPIC_UPDATE_ADS_PROMOS_CONTRACT_TO_NULLIFY_CONTRACT_TERM => EventTopics.EVENT_TOPIC_UPDATE_ADS_PROMOS_CONTRACT_TO_NULLIFY_CONTRACT_TERM
    };
    private static final String FRANCHISE_ACCOUNTS_WITHHOLDING_QUERY_LIMIT_STATIC_CONFIG = 'Franchise_Acc_Withholding_Query_Limit';
    private Integer franchiseAccountWithholdingQueryLimit;
    private static final String MARKETPLACE_PLATFORM = 'Marketplace';
    private static final String ONBOARDING_SCENARIO_NET_NEW_MX_ONBOARDING = 'Net-New';
    private static final String ONBOARDING_SCENARIO_NEW_STORE_EXPANSION = 'NSE';
    private static final String ONBOARDING_SCENARIO_PRODUCT_ADDITION = 'Product Addition';
    private static final String PAYMENT_METHOD_WITHHOLDING = 'Withholding';
    private static final String PAYMENT_METHOD_SWITCH_COUNT_ERROR = 'An exception occurred while switching payment method on Fz Accounts, check logs for more details. Corporate Record Ids: ';
    private static final String PLUS_OPERATOR = '+';
    private static final String LOG_DOMAIN_SALES_TO_CONTRACT = 'Sales To Contract';
    private static final String SEPARATOR = System.Label.Separator;
    private static final String STOREFRONT_PLATFORM = 'Storefront';
    private static final Boolean EVERGREEN = true;
    private enum OnboardingScenarios {
        NET_NEW_MX_ONBOARDING,
        NEW_STORE_ADDITION,
        PRODUCT_ADDITION
    }
    private static final Map<String, OnboardingScenarios> ONBOARDINGSCENARIOSMAPPINGS = new Map<String, OnboardingScenarios>{
        ONBOARDING_SCENARIO_NET_NEW_MX_ONBOARDING => OnboardingScenarios.NET_NEW_MX_ONBOARDING,
        ONBOARDING_SCENARIO_NEW_STORE_EXPANSION => OnboardingScenarios.NEW_STORE_ADDITION,
        ONBOARDING_SCENARIO_PRODUCT_ADDITION => OnboardingScenarios.PRODUCT_ADDITION
    };
    Set<String> contractIdToWorkOrderToBeCreated;

    /**
     * @description Default constructor for this class.
     */
    public ContractsServiceImpl() {
        collectStaticConfigurations();
        contractIdToWorkOrderToBeCreated = new Set<String>();
    }
    /**
     * @description It is used to handle Notifier Events to further process
     * corporate account ids from the received payload.
     * @JIRA# LEM-10617
     * @param events
     */
    public void handleNotifierEvents(List<Notifier__e> events) {
        Set<Id> corporateAccountIds = new Set<Id>();
        Set<Id> recordIdsByPayload;
        Set<Id> activatedContractIdToUpdate;
        for (Notifier__e eachEvent : events) {
            switch on EVENT_TOPIC_MAPPINGS.get(eachEvent.Topic__c) {
                when EVENTTOPIC_UPDATE_FRANCHISE_ACCOUNT_TO_WITHHOLDING {
                    recordIdsByPayload = (Set<Id>) JSON.deserialize(
                        eachEvent.Payload__c,
                        Set<Id>.class
                    );
                    corporateAccountIds.addAll(recordIdsByPayload);
                }
                when EVENT_TOPIC_UPDATE_ADS_PROMOS_CONTRACT_TO_NULLIFY_CONTRACT_TERM {
                    activatedContractIdToUpdate = (Set<Id>) JSON.deserialize(
                        eachEvent.Payload__c,
                        Set<Id>.class
                    );
                    nullifyContractTermOnActivatedAdsAndPromosContract(activatedContractIdToUpdate);
                }
            }
        }
        processCorporateAccounts(corporateAccountIds);
    }

    /**
     * @description Used to Map Contracts to their parent Account Ids
     * @param parentAccountIds
     * @return Map<Id, List<Contract>>
     */
    public Map<Id, Contract> setContractOnParentAccount(Set<Id> parentAccountIds) {
        Map<Id, Contract> accountIdToChildContracts = new Map<Id, Contract>();
        for (
            Contract eachContract : ContractsSelector.newInstance()
                .selectByParentAccountId(parentAccountIds)
        ) {
            if (!accountIdToChildContracts.containsKey(eachContract.AccountId)) {
                accountIdToChildContracts.put(eachContract.AccountId, eachContract);
            }
        }
        return accountIdToChildContracts;
    }

    /**
     * @description Used to Map Contracts to their parent Account Ids
     * @param parentAccountIds
     * @return Map<Id, List<Contract>>
     */
    public Map<Id, List<Contract>> setAllContractOnParentAccount(Set<Id> parentAccountIds) {
        Map<Id, List<Contract>> accountIdToChildContracts = new Map<Id, List<Contract>>();
        for (
            Contract eachContract : ContractsSelector.newInstance()
                .selectByParentAccountId(parentAccountIds)
        ) {
            if (!accountIdToChildContracts.containsKey(eachContract.AccountId)) {
                accountIdToChildContracts.put(eachContract.AccountId, new List<Contract>());
            }
            accountIdToChildContracts.get(eachContract.AccountId).add(eachContract);
        }
        return accountIdToChildContracts;
    }

    /**
     * @description It used to create a map of Parent Account to Middleware Providers' Contracts.
     * @param parentAccountIds
     * @return Map<Id, List<Contract>>
     */
    public Map<Id, List<Contract>> setMiddlewareProviderContractOnParentAccount(
        Set<Id> parentAccountIds
    ) {
        Map<Id, List<Contract>> parentAccountIdToMWPContracts = new Map<Id, List<Contract>>();
        if (parentAccountIds.isEmpty()) {
            return parentAccountIdToMWPContracts;
        }
        for (
            Contract eachContract : ContractsSelector.newInstance()
                .selectContractSplitCategoryByParentAccountIds(parentAccountIds)
        ) {
            if (!parentAccountIdToMWPContracts.containsKey(eachContract.AccountId)) {
                parentAccountIdToMWPContracts.put(eachContract.AccountId, new List<Contract>());
            }
            parentAccountIdToMWPContracts.get(eachContract.AccountId).add(eachContract);
        }
        return parentAccountIdToMWPContracts;
    }

    /**
     * @description Sets the contract on the related opportunity.
     *
     * @param contractIds
     */
    public void setContractsOnRelatedOpportunities(Set<Id> contractIds) {
        fflib_ISObjectUnitOfWork unitOfWork = Application.UNITOFWORK.newInstance();
        Map<Id, Id> opportunityIdToContractIdMap = new Map<Id, id>();
        List<Opportunity> oppList = new List<Opportunity>();
        for (Contract contract : ContractsSelector.newInstance().selectById(contractIds)) {
            if (contract.SBQQ__Opportunity__c != null) {
                opportunityIdToContractIdMap.put(contract.SBQQ__Opportunity__c, contract.Id);
            }
        }
        if (opportunityIdToContractIdMap.isEmpty()) {
            return;
        }
        for (
            Opportunity opportunityObj : OpportunitiesSelector.newInstance()
                .selectById(opportunityIdToContractIdMap.keySet())
        ) {
            Id contractId = opportunityIdToContractIdMap.containskey(opportunityObj.Id)
                ? opportunityIdToContractIdMap.get(opportunityObj.Id)
                : null;

            if (contractId != null) {
                opportunityObj.ContractId = contractId;
                oppList.add(opportunityObj);
            }
        }
        unitOfWork.registerDirty(oppList);
        commitWork(unitOfWork);
    }
    /**
     * @description This method creates the Contract Brand Association.
     * @param contractOppIdMap
     */
    public void createContractBrandAssociationOnContract(Map<Id, Id> contractOppIdMap) {
        fflib_ISObjectUnitOfWork unitOfWork = Application.UNITOFWORK.newInstance();
        List<Contract_Brand_Association__c> contractBrandAssociations = new List<Contract_Brand_Association__c>();
        Map<Id, List<String>> contractToBrandNameList = new Map<Id, List<String>>();
        Set<Id> opportunityIds = new Set<Id>();
        if (contractOppIdMap.isEmpty()) {
            return;
        }
        opportunityIds.addAll(contractOppIdMap.values());
        List<Opportunity_Brand_Relationship__c> opportunityToBrandRelationships = OpportunityBrandRelationshipsSelector.newInstance()
            .selectByOpportunity(opportunityIds);
        for (
            Opportunity_Brand_Relationship__c oppBrandRelationship : opportunityToBrandRelationships
        ) {
            if (String.isNotBlank(oppBrandRelationship.Brand__r.Brand_Name__r.Name)) {
                if (
                    !contractToBrandNameList.containsKey(
                        oppBrandRelationship.Opportunity__r.ContractId
                    )
                ) {
                    contractToBrandNameList.put(
                        oppBrandRelationship.Opportunity__r.ContractId,
                        new List<String>()
                    );
                }
                contractToBrandNameList.get(oppBrandRelationship.Opportunity__r.ContractId)
                    .add(oppBrandRelationship.Brand__r.Brand_Name__r.Name);
            }
            contractBrandAssociations.add(
                new Contract_Brand_Association__c(
                    Contract__c = oppBrandRelationship.Opportunity__r.ContractId,
                    Brand__c = oppBrandRelationship.Brand__r.Brand_Name__c,
                    Opportunity__c = oppBrandRelationship.Opportunity__c,
                    Status__c = STATUS_ACTIVE
                )
            );
        }
        unitOfWork.registerNew(contractBrandAssociations);
        commitWork(unitOfWork);

        stampTheBrandNameOntheContract(contractToBrandNameList);
    }

    /**
     * @description This method stamps the Brand Names on the Contract
     * @param contractToBrandNameList
     */
    private void stampTheBrandNameOntheContract(Map<Id, List<String>> contractToBrandNameList) {
        fflib_ISObjectUnitOfWork unitOfWork = Application.UNITOFWORK.newInstance();
        List<String> brandNameList = new List<String>();
        if (contractToBrandNameList.isEmpty()) {
            return;
        }
        for (Id contractId : contractToBrandNameList.keySet()) {
            String brandNameStr = '';
            brandNameList = contractToBrandNameList.get(contractId);
            if (brandNameList.isEmpty()) {
                continue;
            }
            Integer index = 0;

            while (index < 3) {
                if (index == brandNameList.size()) {
                    break;
                }
                if (index > 0) {
                    brandNameStr += LIST_DELIMETER;
                }
                if (index > 1) {
                    brandNameStr += LIST_HAS_MORE;
                } else {
                    brandNameStr += brandNameList[index];
                }
                index++;
            }
            if (String.isNotBlank(contractId)) {
                unitOfWork.registerDirty(
                    new Contract(Id = contractId, Contract_Name__c = brandNameStr)
                );
            }
        }
        commitWork(unitOfWork);
    }

    /**
     * @description This method stamps the MSA / Ads and Promotion indicator on the Contract
     * @param contractIdToContractName
     */
    public void stampMsaOrAdsPromoOntheContract(Map<Id, String> contractIdToContractName) {
        fflib_ISObjectUnitOfWork unitOfWork = Application.UNITOFWORK.newInstance();
        List<Contract> contractList = new List<Contract>();
        List<Contract> contractsWithAdsAndPromoSubs = ContractsSelector.newInstance()
            .selectContractsWithAdsAndPromoSubscriptions(contractIdToContractName.keySet());
        Boolean isThisAdsOrPromo = false;

        for (Contract con : contractsWithAdsAndPromoSubs) {
            String contractName;
            if (con.SBQQ__Subscriptions__r.isEmpty()) {
                contractName = returnNameValue(contractIdToContractName.get(con.Id), MSA_CONTRACT);
            } else {
                contractName = returnNameValue(
                    contractIdToContractName.get(con.Id),
                    AD_PROMO_CONTRACT
                );
                isThisAdsOrPromo = true;
            }
            if (contractName == contractIdToContractName.get(con.Id)) {
                continue;
            }
            Contract contractObj = new Contract(
                Id = con.Id,
                Contract_Name__c = contractName,
                Is_This_Ads_Or_Promo__c = isThisAdsOrPromo
            );
            contractList.add(contractObj);
        }
        unitOfWork.registerDirty(contractList);
        commitWork(unitOfWork);
    }
    /**
     * @description This method is used to append the msa/ads and promo Indicator
     * @param contractName
     * @param indicator
     * @return String
     */
    private String returnNameValue(String contractName, String indicator) {
        if (String.isEmpty(contractName)) {
            contractName = indicator;
        } else if (
            !contractName.endsWith(LIST_END + indicator) && !contractName.equals(indicator)
        ) {
            contractName += LIST_END;
            contractName += indicator;
        }
        return contractName;
    }
    /**
     * @description Sets the Quotes Fields On Contract when contract is amended
     * @param contractIds
     */
    public void setQuotesFieldsOnContract(Set<Id> contractIds) {
        fflib_ISObjectUnitOfWork unitOfWork = Application.UNITOFWORK.newInstance();
        if (contractIds.isEmpty()) {
            return;
        }
        for (Contract con : ContractsSelector.newInstance().selectById(contractIds)) {
            if (con.SBQQ__Order__c != null && con.SBQQ__Order__r.SBQQ__Quote__c != null) {
                con.Franchise_Supplemental_Agreement_URL__c = con.SBQQ__Order__r.SBQQ__Quote__r.Franchise_Supplemental_Agreement_Link__c;
                con.Master_Supplemental_Agreement_URL__c = con.SBQQ__Order__r.SBQQ__Quote__r.Signed_Contract_link__c;
                unitOfWork.registerDirty(con);
            }
        }
        commitWork(unitOfWork);
    }

    /**
     * @description A common method to commit unit of work.
     * @param uow
     */
    private void commitWork(fflib_ISObjectUnitOfWork uow) {
        try {
            uow.commitWork();
        } catch (Exception e) {
            Logger.publish(e, LogEntry.SeverityLevel.HIGH);
            String serviceName = 'Contracts Service';
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        serviceName,
                        LOG_DOMAIN_SALES_TO_CONTRACT,
                        GenericLogEntry.SeverityLevel.MEDIUM
                    )
                    .logException(e)
            );
        }
    }
    /**
     * @description this method checks the agency on the opportunity for contracts and sets the
     * corresponding field on contract to that if it is not null
     * @param contractOppIdMap
     */
    public void setAgencyFieldOnContract(Map<Id, Id> contractOppIdMap) {
        fflib_ISObjectUnitOfWork unitOfWork = Application.UNITOFWORK.newInstance();
        if (contractOppIdMap.isEmpty()) {
            return;
        }
        List<Contract> contracts = ContractsSelector.newInstance()
            .selectById(contractOppIdMap.keySet());

        for (Contract contractToUpdate : contracts) {
            if (contractToUpdate.SBQQ__Opportunity__r.Agency__c != null) {
                contractToUpdate.Agency__c = contractToUpdate.SBQQ__Opportunity__r.Agency__c;
                unitOfWork.registerDirty(contractToUpdate);
            }
        }
        commitWork(unitOfWork);
    }
    /**
     * @description It is used to get static configurations.
     */
    private void collectStaticConfigurations() {
        this.corporateAccountIdsChunkSizeToSwitchPaymentAccount = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(
                    CORPORATE_ACCOUNT_IDS_CHUNK_SIZE_TO_SWITCH_PAYMENT_METHOD_STATIC_CONFIG
                )
                .Configuration_Value__c
        );
        this.franchiseAccountWithholdingQueryLimit = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(FRANCHISE_ACCOUNTS_WITHHOLDING_QUERY_LIMIT_STATIC_CONFIG)
                .Configuration_Value__c
        );
    }

    /**
     * @description It is used to process corporate Accounts.
     * @JIRA# LEM-10617
     * @param corporateAccountIds
     */
    private void processCorporateAccounts(Set<Id> corporateAccountIds) {
        Set<Id> corporateAccountIdsWithNonWithholdingFranchiseAccount = new Set<Id>();
        Integer countOfNonWithHoldingFranchiseAccountsBeforeSwitch = 0;
        Integer countOfNonWithHoldingFranchiseAccountsAfterSwitch = 0;
        //LEM-10617: Get the count of Fz Accounts with Payment Method as Withholding
        //before and after switching the Payment Method.
        for (
            Aggregate eachAggregate : AgreementsSelector.newInstance()
                .selectCountOfNonWithholdingFranchiseAccountsByActiveAgreements(corporateAccountIds)
        ) {
            corporateAccountIdsWithNonWithholdingFranchiseAccount.add(
                (Id) eachAggregate.get(AGGREGATE_CORPORATEACCOUNTID_FIELD_ALIAS)
            );
            countOfNonWithHoldingFranchiseAccountsBeforeSwitch += (Integer) eachAggregate.get(
                AGGREGATE_AGREEMENT_COUNT_FIELD_ALIAS
            );
        }
        //Switch Payment Method to 'Withholding' on Fz Accounts
        switchPaymentMethodOnFranchiseAccounts(corporateAccountIds);
        for (
            Aggregate eachAggregate : AgreementsSelector.newInstance()
                .selectCountOfNonWithholdingFranchiseAccountsByActiveAgreements(corporateAccountIds)
        ) {
            corporateAccountIdsWithNonWithholdingFranchiseAccount.add(
                (Id) eachAggregate.get(AGGREGATE_CORPORATEACCOUNTID_FIELD_ALIAS)
            );
            countOfNonWithHoldingFranchiseAccountsAfterSwitch += (Integer) eachAggregate.get(
                AGGREGATE_AGREEMENT_COUNT_FIELD_ALIAS
            );
        }
        if (
            !corporateAccountIdsWithNonWithholdingFranchiseAccount.isEmpty() &&
            countOfNonWithHoldingFranchiseAccountsBeforeSwitch !=
            countOfNonWithHoldingFranchiseAccountsAfterSwitch
        ) {
            NotifierEventsService.publishBulkEvents(
                new Map<String, List<String>>{
                    EVENT_TOPIC_UPDATE_FRANCHISE_ACCOUNT_TO_WITHHOLDING => NotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                        corporateAccountIdsWithNonWithholdingFranchiseAccount,
                        corporateAccountIdsChunkSizeToSwitchPaymentAccount
                    )
                }
            );
        } else if (
            countOfNonWithHoldingFranchiseAccountsBeforeSwitch != 0 &&
            //Count didn't change after switching the Payment Method.
            countOfNonWithHoldingFranchiseAccountsBeforeSwitch ==
            countOfNonWithHoldingFranchiseAccountsAfterSwitch
        ) {
            Logger.publish(
                PAYMENT_METHOD_SWITCH_COUNT_ERROR + JSON.serialize(corporateAccountIds),
                LogEntry.SeverityLevel.HIGH
            );
        }
        // Removed unprocessed corporate account Ids
        corporateAccountIds.removeAll(corporateAccountIdsWithNonWithholdingFranchiseAccount);
        // Update Franchise Account processed indicator
        if (!corporateAccountIds.isEmpty()) {
            updateAllFranchisesProcessedIndicatorOnCorporateAccount(corporateAccountIds);
        }
    }

    /**
     * @description It is used to update Payment Method field on franchise Account
     * with Withholding value using the passed corporateAccountIds.
     * @JIRA# LEM-10617
     * @param corporateAccountIds
     */
    private void switchPaymentMethodOnFranchiseAccounts(Set<Id> corporateAccountIds) {
        fflib_ISObjectUnitOfWork uowToUpdateFranchiseAccount = Application.UNITOFWORK.newInstance();
        UpdateUnitOfWorkHelper uowUpdateHelper = new UpdateUnitOfWorkHelper();
        uowToUpdateFranchiseAccount.registerWork(uowUpdateHelper);
        Map<Id, Account> accountsToUpdate = new Map<Id, Account>();
        for (
            Agreement__c eachAgreement : AgreementsSelector.newInstance()
                .selectNonWithholdingFranchiseAccountsByActiveAgreements(
                    corporateAccountIds,
                    franchiseAccountWithholdingQueryLimit
                )
        ) {
            accountsToUpdate.put(
                eachAgreement.Account__c,
                new Account(
                    Id = eachAgreement.Account__c,
                    Payment_Method__c = PAYMENT_METHOD_WITHHOLDING
                )
            );
        }
        if (accountsToUpdate.isEmpty()) {
            return;
        }
        uowUpdateHelper.registerUpdate(accountsToUpdate.values());
        commitWork(uowToUpdateFranchiseAccount);
        List<Database.SaveResult> saveResults = uowUpdateHelper.saveResults;
        ILogger loggerInstance = Logger.add(
            LogEntry.newDmlLog(saveResults, accountsToUpdate.values(), LogEntry.SeverityLevel.HIGH)
        );
        loggerInstance.publish();
    }

    /**
     * @description It is used to get contracts that are eligible for Work Order Creation.
     * @JIRA# LEM-15321
     * @param mxOnboardingLinks
     * @param contractIdToExistingSubscriptions
     * @return Set<String>
     */
    public Set<String> getEligibleContractsForOnboardingInputsWorkOrderCreation(
        List<Mx_Onboarding_Link__c> mxOnboardingLinks,
        Map<Id, Set<String>> contractIdToExistingSubscriptions
    ) {
        for (Mx_Onboarding_Link__c eachMxOnboardingLink : mxOnboardingLinks) {
            switch on ONBOARDINGSCENARIOSMAPPINGS.get(eachMxOnboardingLink.Onboarding_Scenario__c) {
                when NET_NEW_MX_ONBOARDING {
                    evaluateAndAddWorkOrderTypesToBeCreated(
                        eachMxOnboardingLink.Contract__c,
                        contractIdToExistingSubscriptions,
                        eachMxOnboardingLink.Onboarding_Scenario__c
                    );
                }
                when NEW_STORE_ADDITION {
                    evaluateAndAddWorkOrderTypesToBeCreated(
                        eachMxOnboardingLink.Contract__c,
                        contractIdToExistingSubscriptions,
                        eachMxOnboardingLink.Onboarding_Scenario__c
                    );
                }
                when PRODUCT_ADDITION {
                    evaluateAndAddWorkOrderTypesToBeCreatedForProductAddition(
                        eachMxOnboardingLink.Product_on_Contract__c,
                        eachMxOnboardingLink.Contract__c
                    );
                }
            }
        }
        return contractIdToWorkOrderToBeCreated;
    }

    /**
     * @description It is used to evaluate and add Work Order types to be created for given Contract Id
     * for Onboarding Inputs Product Addition scenario.
     * @JIRA# LEM-15321
     * @param productsOnContract
     * @param contractId
     */
    private void evaluateAndAddWorkOrderTypesToBeCreatedForProductAddition(
        String productsOnContract,
        Id contractId
    ) {
        if (String.isNotBlank(productsOnContract)) {
            List<String> allProducts = productsOnContract.split(ESCAPE_SEQUENCE + PLUS_OPERATOR);
            /*'Products on Contract' field stores the newly added Products seperated by '+' operator.
               Hence iterating from the first newly added product which starts from index 1 of the splitted array.
            */
            for (Integer iterator = 0; iterator < allProducts.size(); iterator++) {
                contractIdToWorkOrderToBeCreated.add(
                    contractId + SEPARATOR + allProducts[iterator].trim()
                );
            }
        }
    }

    /**
     * @description It is used to evaluate and add Work Order types to be created for given Contract Id.
     * @JIRA# LEM-15321
     * @param contractId
     * @param contractIdToExistingSubscriptions
     * @param onboardingScenario
     */
    private void evaluateAndAddWorkOrderTypesToBeCreated(
        Id contractId,
        Map<Id, Set<String>> contractIdToExistingSubscriptions,
        String onboardingScenario
    ) {
        if (contractIdToExistingSubscriptions.get(contractId).contains(MARKETPLACE_PLATFORM)) {
            contractIdToWorkOrderToBeCreated.add(contractId + SEPARATOR + MARKETPLACE_PLATFORM);
        }
        if (contractIdToExistingSubscriptions.get(contractId).contains(STOREFRONT_PLATFORM)) {
            contractIdToWorkOrderToBeCreated.add(contractId + SEPARATOR + STOREFRONT_PLATFORM);
        }
        if (
            contractIdToExistingSubscriptions.get(contractId).contains(DRIVE_PLATFORM) &&
            onboardingScenario != ONBOARDING_SCENARIO_NEW_STORE_EXPANSION
        ) {
            contractIdToWorkOrderToBeCreated.add(contractId + SEPARATOR + DRIVE_PLATFORM);
        }
    }

    /**
     * @description It is used to enable franchise accounts processed indicator (Are_All_Franchise_Accounts_Processed__c)
     * on the corporate account using the passed corporateAccountIds.
     * @JIRA# LEM-9497
     * @param corporateAccountIds
     */
    private void updateAllFranchisesProcessedIndicatorOnCorporateAccount(
        Set<Id> corporateAccountIds
    ) {
        fflib_ISObjectUnitOfWork unitOfWork = Application.UNITOFWORK.newInstance();
        for (Id corporateAccountId : corporateAccountIds) {
            unitOfWork.registerDirty(
                new Account(Id = corporateAccountId, Are_All_Franchise_Accounts_Processed__c = true)
            );
        }
        commitWork(unitOfWork);
    }

    /**
     * @description It is used to update the Ads and Promos Contract's field 'Contract Term' to blank
     * and 'Evergreen' to true.
     * @param activatedContractIdToUpdate
     */
    private void nullifyContractTermOnActivatedAdsAndPromosContract(
        Set<Id> activatedContractIdToUpdate
    ) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        for (
            Contract eachContract : ContractsSelector.newInstance()
                .selectById(activatedContractIdToUpdate)
        ) {
            if (eachContract.Contract_Split_Category__c != CONTRACT_SPLIT_CATEGORY_ADS_PROMOS) {
                continue;
            }
            eachContract.ContractTerm = null;
            if (eachContract.SBQQ__Evergreen__c) {
                eachContract.SBQQ__Evergreen__c = false;
            }
            uow.registerDirty(eachContract);
        }
        try {
            SBQQ.TriggerControl.disable();
            uow.commitWork();
            SBQQ.TriggerControl.enable();
        } catch (Exception changesFailedCommit) {
            Logger.publish(
                LogEntry.newExceptionLog(changesFailedCommit, LogEntry.SeverityLevel.HIGH)
            );
        }
    }
}