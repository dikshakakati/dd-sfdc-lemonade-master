/**
 * @author Deloitte
 * @date 17/06/2022
 * @description Test class for ContractServiceImpl class.
 */
@isTest(seeAllData=false)
private class ContractsServiceImplTest {
    private static final String STATUS_ACTIVATED = 'Activated';
    private static final String STATUS_ACTIVE = 'Active';
    private static final String ASSERT_MESSAGE = 'UnexpectedError: The Contracts were not mapped appropriately to their Parent Accounts.';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_NO_OF_VALUES_RETURNED = 'UnexpectedError: No of values returned are Wrong.';
    private static final String BRAND_NAME_MCDONALDS = 'McDonald\'s';
    private static final String BRAND_NAME_BK = 'BK';
    private static final String BRAND_NAME_KFC = 'KFC';
    private static final String EXPECTED_CONTRACT_NAME = 'Pop tates, KFC, etc...';
    private static final String UNEXPECTED_CONTRACT_NAME_MESSAGE =
        'Unexpected Result: Contract name is incorrect. Expected: \'' +
        EXPECTED_CONTRACT_NAME +
        '\' Actual: ';
    private static final String AGGREGATE_AGREEMENTSCOUNT_FIELD_ALIAS = 'agreementsCount';
    private static final String AGGREGATE_CORPORATEACCOUNTID_FIELD_ALIAS = 'corporateAccountId';
    private static final String AGREEMENT_NAME = 'Test Agreement';
    private static final String AGREEMENT_STATUS_ACTIVE = 'Active';
    private static final String AGREEMENT_TYPE_FRANCHISE_AGREEMENT = 'Franchise Agreement';
    private static final String CORPORATE_ACCOUNT_IDS_CHUNK_SIZE_TO_SWITCH_PAYMENT_METHOD = '1';
    private static final String CORPORATE_ACCOUNT_IDS_CHUNK_SIZE_TO_SWITCH_PAYMENT_METHOD_STATIC_CONFIG = 'Corp_Acc_Size_To_Switch_Payment_Method';
    private static final String DRIVE_PLATFORM = 'Drive';
    private static final String FRANCHISE_ACCOUNTS_WITHHOLDING_QUERY_LIMIT = '7500';
    private static final String FRANCHISE_ACCOUNTS_WITHHOLDING_QUERY_LIMIT_STATIC_CONFIG = 'Franchise_Acc_Withholding_Query_Limit';
    private static final String ID_FIELD_API = 'Id';
    private static final String INCORRECT_ID_ERROR_MESSAGE = 'The corporate Id does not match.';
    private static final String EVENT_TOPIC_UPDATE_FRANCHISE_ACCOUNT_TO_WITHHOLDING = 'UPDATE_FRANCHISE_ACCOUNT_TO_WITHHOLDING';
    private static final String MARKETPLACE_PLATFORM = 'Marketplace';
    private static final String ONBOARDING_SCENARIO_NET_NEW_MX_ONBOARDING = 'Net-New';
    private static final String ONBOARDING_SCENARIO_NEW_STORE_EXPANSION = 'NSE';
    private static final String ONBOARDING_SCENARIO_PRODUCT_ADDITION = 'Product Addition';
    private static final String PAYMENT_METHOD_WITHHOLDING = 'Withholding';
    private static final String STOREFRONT_PLATFORM = 'Storefront';
    private static final String WITHHOLDING_OPT_OUT_LIMIT_IN_DAYS = '40';
    private static final String WITHHOLDING_OPT_OUT_LIMIT_IN_DAYS_STATIC_CONFIG = 'Withholding_Opt_out_Limit_in_Days';
    private static final String CONTRACT_SPLIT_CATEGORY_MIDDLEWARE_PROVIDER = 'Middleware Provider';

    /**
     * @description To test logic for fetching Activated Contract of a Business Account and return the mapping of
     * parent account to contract.
     * Suppressed Warnings since mock verify method is equivalent of System.assert statement.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenParentAccountsIdsAreProvidedThenChildContractsAreFetchedAndMapped() {
        Id parentMcDAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentKfcAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        String mcDContractId = fflib_IDGenerator.generate(Contract.SObjectType);
        String mcDDuplicateContractId = fflib_IDGenerator.generate(Contract.SObjectType);
        String kfcContractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Map<Id, Contract> accountToChildContract = new Map<Id, Contract>();
        Set<Id> parentAccountIds = new Set<Id>{ parentMcDAccountId, parentKfcAccountId };
        List<Contract> contracts = new List<Contract>{
            (Contract) new Fake(Contract.class)
                .setField(Contract.Id, mcDContractId)
                .setField(Contract.AccountId, parentMcDAccountId)
                .setField(Contract.Status, STATUS_ACTIVATED)
                .toSObject(),
            (Contract) new Fake(Contract.class)
                .setField(Contract.Id, mcDDuplicateContractId)
                .setField(Contract.AccountId, parentMcDAccountId)
                .setField(Contract.Status, STATUS_ACTIVATED)
                .toSObject(),
            (Contract) new Fake(Contract.class)
                .setField(Contract.Id, kfcContractId)
                .setField(Contract.AccountId, parentKfcAccountId)
                .setField(Contract.Status, STATUS_ACTIVATED)
                .toSObject()
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ContractsSelector contractsSelectorMock = (ContractsSelector) mocks.mock(
            ContractsSelector.class
        );
        mocks.startStubbing();
        mocks.when(contractsSelectorMock.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(contractsSelectorMock.selectByParentAccountId(parentAccountIds))
            .thenReturn(contracts);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(contractsSelectorMock);
        accountToChildContract = ContractsService.setContractOnParentAccount(parentAccountIds);
        Map<Id, Contract> expectedAccountToChildContract = new Map<Id, Contract>();
        expectedAccountToChildContract.put(parentMcDAccountId, contracts[0]);
        expectedAccountToChildContract.put(parentKfcAccountId, contracts[2]);
        System.assertEquals(expectedAccountToChildContract, accountToChildContract, ASSERT_MESSAGE);
    }

    /**
     * @description Test the logic for setting contract id on related opportunity.
     *
     * Suppressed Warnings since mock verify method is equivalent of System.assert statement.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenContractIsActivatedThenOpportunityContractRelationshipIsUpdated() {
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);

        List<Opportunity> opportunities = new List<Opportunity>{
            (Opportunity) new Fake(Opportunity.class)
                .setField(Opportunity.Id, opportunityId)
                .setField(Opportunity.ContractId, '')
                .toSObject()
        };
        List<Contract> contracts = new List<Contract>{
            (Contract) new Fake(Contract.class)
                .setField(Contract.Id, contractId)
                .setField(Contract.Status, 'Activated')
                .setField(Contract.SBQQ__Opportunity__c, opportunityId)
                .toSObject()
        };
        Set<Id> contractIds = new Set<Id>{ contractId };
        Map<Id, Id> opportunityIdToContractIdMap = new Map<Id, id>();
        opportunityIdToContractIdMap.put(opportunityId, contractId);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );
        IContractsSelector contractsSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );

        IOpportunitiesSelector opportunitiesSelectorMock = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );

        mocks.startStubbing();
        mocks.when(contractsSelectorMock.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(contractsSelectorMock.selectById(contractIds)).thenReturn(contracts);
        mocks.when(opportunitiesSelectorMock.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(opportunitiesSelectorMock.selectById(opportunityIdToContractIdMap.keySet()))
            .thenReturn(opportunities);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(contractsSelectorMock);
        Application.SELECTOR.setMock(opportunitiesSelectorMock);
        Application.UNITOFWORK.setMock(uowMock);

        ContractsService.setContractsOnRelatedOpportunities(contractIds);

        ((IContractsSelector) mocks.verify(contractsSelectorMock, 1)).selectById(contractIds);
        ((fflib_SObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
    }

    /**
     * @description To test logic for fetching opportunity brand associations and creating contract
     *     brand associations.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMethodCallThenBrandRelationshipsAreFetchedAndCreated() {
        String mcDContractId = fflib_IDGenerator.generate(Contract.SObjectType);
        String bkContractId = fflib_IDGenerator.generate(Contract.SObjectType);
        String kfcContractId = fflib_IDGenerator.generate(Contract.SObjectType);
        String mcDOppId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        String bkOppId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        String kfcOppId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        String mcDBrandId = fflib_IDGenerator.generate(Brand__c.SObjectType);
        String bkBrandId = fflib_IDGenerator.generate(Brand__c.SObjectType);
        String kfcBrandId = fflib_IDGenerator.generate(Brand__c.SObjectType);
        String mcDBrandAssociationId = fflib_IDGenerator.generate(Brand_Association__c.SObjectType);
        String bkBrandAssociationId = fflib_IDGenerator.generate(Brand_Association__c.SObjectType);
        String kfcBrandAssociationId = fflib_IDGenerator.generate(Brand_Association__c.SObjectType);
        List<Contract> contracts = new List<Contract>{
            (Contract) new Fake(Contract.class)
                .setField(Contract.Id, mcDContractId)
                .setField(Contract.SBQQ__Opportunity__c, mcDOppId)
                .setField(Contract.Status, STATUS_ACTIVATED)
                .toSObject(),
            (Contract) new Fake(Contract.class)
                .setField(Contract.Id, bkContractId)
                .setField(Contract.SBQQ__Opportunity__c, bkOppId)
                .setField(Contract.Status, STATUS_ACTIVATED)
                .toSObject(),
            (Contract) new Fake(Contract.class)
                .setField(Contract.Id, kfcContractId)
                .setField(Contract.SBQQ__Opportunity__c, kfcOppId)
                .setField(Contract.Status, STATUS_ACTIVATED)
                .toSObject()
        };
        List<Opportunity_Brand_Relationship__c> oppBrandRelationships = new List<Opportunity_Brand_Relationship__c>{
            (Opportunity_Brand_Relationship__c) new Fake(Opportunity_Brand_Relationship__c.class)
                .setField(Opportunity_Brand_Relationship__c.Opportunity__c, mcDOppId)
                .setParent(
                    'Opportunity__r',
                    new Fake(Opportunity.class).setField(Opportunity.ContractId, mcDContractId)
                )
                .setParent(
                    'Brand__r',
                    new Fake(Brand_Association__c.class)
                        .setField(Brand_Association__c.Id, mcDBrandAssociationId)
                        .setField(Brand_Association__c.Brand_Name__c, mcDBrandId)
                        .setParent(
                            'Brand_Name__r',
                            new Fake(Brand__c.class)
                                .setField(Brand__c.Name, 'Pop tates')
                                .setField(Brand__c.Id, mcDBrandId)
                        )
                )
                .toSObject(),
            (Opportunity_Brand_Relationship__c) new Fake(Opportunity_Brand_Relationship__c.class)
                .setField(Opportunity_Brand_Relationship__c.Opportunity__c, bkOppId)
                .setParent(
                    'Opportunity__r',
                    new Fake(Opportunity.class).setField(Opportunity.ContractId, bkContractId)
                )
                .setParent(
                    'Brand__r',
                    new Fake(Brand_Association__c.class)
                        .setField(Brand_Association__c.Id, bkBrandAssociationId)
                        .setField(Brand_Association__c.Brand_Name__c, bkBrandId)
                        .setParent(
                            'Brand_Name__r',
                            new Fake(Brand__c.class)
                                .setField(Brand__c.Name, 'BK')
                                .setField(Brand__c.Id, bkBrandId)
                        )
                )
                .toSObject(),
            (Opportunity_Brand_Relationship__c) new Fake(Opportunity_Brand_Relationship__c.class)
                .setField(Opportunity_Brand_Relationship__c.Opportunity__c, kfcOppId)
                .setParent(
                    'Opportunity__r',
                    new Fake(Opportunity.class).setField(Opportunity.ContractId, kfcContractId)
                )
                .setParent(
                    'Brand__r',
                    new Fake(Brand_Association__c.class)
                        .setField(Brand_Association__c.Id, kfcBrandAssociationId)
                        .setField(Brand_Association__c.Brand_Name__c, kfcBrandId)
                        .setParent(
                            'Brand_Name__r',
                            new Fake(Brand__c.class)
                                .setField(Brand__c.Name, 'KFC')
                                .setField(Brand__c.Id, kfcBrandId)
                        )
                )
                .toSObject()
        };
        Set<Id> contractIds = new Set<Id>{ mcDContractId, bkContractId, kfcContractId };
        Set<Id> opportunityIds = new Set<Id>{ mcDOppId, bkOppId, kfcOppId };
        Map<Id, Id> contractOppIdMap = new Map<Id, Id>{
            mcDContractId => mcDOppId,
            bkContractId => bkOppId,
            kfcContractId => kfcOppId
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );

        ContractsSelector contractsSelectorMock = (ContractsSelector) mocks.mock(
            ContractsSelector.class
        );
        OpportunityBrandRelationshipsSelector oppBrandRelationshipsSelectorMock = (OpportunityBrandRelationshipsSelector) mocks.mock(
            OpportunityBrandRelationshipsSelector.class
        );

        List<Contract_Brand_Association__c> expectedAssns = new List<Contract_Brand_Association__c>{
            new Contract_Brand_Association__c(
                Contract__c = mcDContractId,
                Brand__c = mcDBrandId,
                Opportunity__c = mcDOppId,
                Status__c = STATUS_ACTIVE
            ),
            new Contract_Brand_Association__c(
                Contract__c = bkContractId,
                Brand__c = bkBrandId,
                Opportunity__c = bkOppId,
                Status__c = STATUS_ACTIVE
            ),
            new Contract_Brand_Association__c(
                Contract__c = kfcContractId,
                Brand__c = kfcBrandId,
                Opportunity__c = kfcOppId,
                Status__c = STATUS_ACTIVE
            )
        };

        mocks.startStubbing();
        mocks.when(contractsSelectorMock.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(contractsSelectorMock.selectById(contractIds)).thenReturn(contracts);
        mocks.when(oppBrandRelationshipsSelectorMock.sObjectType())
            .thenReturn(Opportunity_Brand_Relationship__c.SObjectType);
        mocks.when(oppBrandRelationshipsSelectorMock.selectByOpportunity(opportunityIds))
            .thenReturn(oppBrandRelationships);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(uowMock);
        Application.SELECTOR.setMock(contractsSelectorMock);
        Application.SELECTOR.setMock(oppBrandRelationshipsSelectorMock);

        ContractsService.createContractBrandAssociationOnContract(contractOppIdMap);

        ((IOpportunityBrandRelationshipsSelector) mocks.verify(
                oppBrandRelationshipsSelectorMock,
                1
            ))
            .selectByOpportunity(opportunityIds);

        ((fflib_SObjectUnitOfWork) mocks.verify(uowMock, mocks.times(1)))
            .registerNew(expectedAssns);
        ((fflib_SObjectUnitOfWork) mocks.verify(uowMock, 2)).commitWork();
    }
    /**
     * @description To test logic for stamping MSA / Ads and Promotion Indicator
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMethodCallThenStampMSAOrAdPromoIndicator() {
        Id con1 = fflib_IDGenerator.generate(Contract.SObjectType);
        Id con2 = fflib_IDGenerator.generate(Contract.SObjectType);
        Id con3 = fflib_IDGenerator.generate(Contract.SObjectType);
        Id sub1 = fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType);
        Id prod1 = fflib_IDGenerator.generate(Product2.SObjectType);

        List<Contract> contracts = new List<Contract>{
            (Contract) new Fake(Contract.class)
                .setField(Contract.Id, con1)
                .setField(Contract.Status, STATUS_ACTIVATED)
                .setField(Contract.Contract_Name__c, 'Name1')
                .setChildren(
                    'SBQQ__Subscriptions__r',
                    new List<Fake>{
                        new Fake(SBQQ__Subscription__c.class)
                            .setField(SBQQ__Subscription__c.id, sub1)
                            .setField(SBQQ__Subscription__c.SBQQ__Contract__c, con1)
                            .setField(SBQQ__Subscription__c.SBQQ__Quantity__c, 1)
                            .setParent(
                                'SBQQ__Product__r',
                                new Fake(Product2.class)
                                    .setField(Product2.Id, prod1)
                                    .setField(Product2.IsActive, true)
                                    .setField(Product2.Family, 'Advertisement')
                            )
                    }
                )
                .toSobject(),
            (Contract) new Fake(Contract.class)
                .setField(Contract.Id, con2)
                .setField(Contract.Status, STATUS_ACTIVATED)
                .setField(Contract.Contract_Name__c, '')
                .toSobject(),
            (Contract) new Fake(Contract.class)
                .setField(Contract.Id, con3)
                .setField(Contract.Status, STATUS_ACTIVATED)
                .setField(Contract.Contract_Name__c, 'Name2 MSA')
                .toSobject()
        };

        Set<Id> contractIds = new Set<Id>{ con1, con2, con3 };
        Map<Id, String> contractIdToContractName = new Map<Id, String>{
            con1 => 'Name1',
            con2 => '',
            con3 => 'Name2 MSA'
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );

        ContractsSelector contractsSelectorMock = (ContractsSelector) mocks.mock(
            ContractsSelector.class
        );

        List<contract> expectedAns = new List<contract>{
            new contract(
                Id = con1,
                Contract_Name__c = 'Name1 Ads and Promotion',
                Is_This_Ads_Or_Promo__c = true
            ),
            new contract(Id = con2, Contract_Name__c = 'MSA', Is_This_Ads_Or_Promo__c = true)
        };

        mocks.startStubbing();
        mocks.when(contractsSelectorMock.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(contractsSelectorMock.selectContractsWithAdsAndPromoSubscriptions(contractIds))
            .thenReturn(contracts);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(uowMock);
        Application.SELECTOR.setMock(contractsSelectorMock);

        ContractsService.stampMsaOrAdsPromoOntheContract(contractIdToContractName);
        ((IContractsSelector) mocks.verify(contractsSelectorMock, 1))
            .selectContractsWithAdsAndPromoSubscriptions(contractIds);

        ((fflib_SObjectUnitOfWork) mocks.verify(uowMock, mocks.times(1)))
            .registerDirty(expectedAns);
        ((fflib_SObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
    }

    /**
     * @description To test logic for updating the agency field on contracts using their existing opps.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMethodCallThenContractsUpdatedIfAgencyExistOnOpportunity() {
        String mcDContractId = fflib_IDGenerator.generate(Contract.SObjectType);
        String bkContractId = fflib_IDGenerator.generate(Contract.SObjectType);
        String kfcContractId = fflib_IDGenerator.generate(Contract.SObjectType);
        String accountId = fflib_IDGenerator.generate(Account.SObjectType);
        String mcDOppId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        String bkOppId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        String kfcOppId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        List<Contract> contracts = new List<Contract>{
            (Contract) new Fake(Contract.class)
                .setField(Contract.Id, mcDContractId)
                .setField(Contract.SBQQ__Opportunity__c, mcDOppId)
                .setField(Contract.Status, STATUS_ACTIVATED)
                .toSObject(),
            (Contract) new Fake(Contract.class)
                .setField(Contract.Id, bkContractId)
                .setField(Contract.SBQQ__Opportunity__c, bkOppId)
                .setField(Contract.Status, STATUS_ACTIVATED)
                .toSObject(),
            (Contract) new Fake(Contract.class)
                .setField(Contract.Id, kfcContractId)
                .setField(Contract.SBQQ__Opportunity__c, kfcOppId)
                .setField(Contract.Status, STATUS_ACTIVATED)
                .setField(Opportunity_Brand_Relationship__c.Opportunity__c, mcDOppId)
                .setParent(
                    'SBQQ__Opportunity__r',
                    new Fake(Opportunity.class)
                        .setField(Opportunity.ContractId, mcDContractId)
                        .setField(Opportunity.Agency__c, accountId)
                )
                .toSObject()
        };
        Set<Id> contractIds = new Set<Id>{ mcDContractId, bkContractId, kfcContractId };
        Map<Id, Id> contractOppIdMap = new Map<Id, Id>{
            mcDContractId => mcDOppId,
            bkContractId => bkOppId,
            kfcContractId => kfcOppId
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );

        ContractsSelector contractsSelectorMock = (ContractsSelector) mocks.mock(
            ContractsSelector.class
        );
        mocks.startStubbing();
        mocks.when(contractsSelectorMock.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(contractsSelectorMock.selectById(contractIds)).thenReturn(contracts);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(uowMock);
        Application.SELECTOR.setMock(contractsSelectorMock);

        ContractsService.setAgencyFieldOnContract(contractOppIdMap);
        ((fflib_SObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
    }
    /**
     * @description To test logic for setting fields on contract in amendmend scenarios
     */
    @isTest
    private static void testWhenMethodCallThenSetQuotesFieldsOnContract() {
        Id con2 = fflib_IDGenerator.generate(Contract.SObjectType);
        Id quote1 = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType);
        Id quote2 = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType);
        Id order2 = fflib_IDGenerator.generate(Order.SObjectType);

        List<Contract> amendedContractsList = new List<Contract>{
            (Contract) new Fake(Contract.class)
                .setField(Contract.Id, con2)
                .setField(Contract.SBQQ__Quote__c, quote1)
                .setField(Contract.SBQQ__Order__c, order2)
                .setParent(
                    'SBQQ__Order__r',
                    new Fake(Order.class)
                        .setField(Order.id, order2)
                        .setField(Order.SBQQ__Quote__c, quote2)
                        .setParent(
                            'SBQQ__Quote__r',
                            new Fake(SBQQ__Quote__c.class)
                                .setField(SBQQ__Quote__c.id, quote2)
                                .setField(
                                    SBQQ__Quote__c.Franchise_Supplemental_Agreement_Link__c,
                                    'FSA2'
                                )
                                .setField(SBQQ__Quote__c.Signed_Contract_link__c, 'MSA2')
                        )
                )
                .setParent(
                    'SBQQ__Quote__r',
                    new Fake(SBQQ__Quote__c.class)
                        .setField(SBQQ__Quote__c.id, quote1)
                        .setField(SBQQ__Quote__c.Franchise_Supplemental_Agreement_Link__c, 'FSA')
                        .setField(SBQQ__Quote__c.Signed_Contract_link__c, 'MSA')
                )
                .toSobject()
        };
        Set<Id> amendedContractIds = new Set<Id>{ con2 };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );

        ContractsSelector contractsSelectorMock = (ContractsSelector) mocks.mock(
            ContractsSelector.class
        );

        mocks.startStubbing();
        mocks.when(contractsSelectorMock.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(contractsSelectorMock.selectById(amendedContractIds))
            .thenReturn(amendedContractsList);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(uowMock);
        Application.SELECTOR.setMock(contractsSelectorMock);

        ContractsService.setQuotesFieldsOnContract(amendedContractIds);
        ((IContractsSelector) mocks.verify(contractsSelectorMock, 1))
            .selectById(amendedContractIds);
        system.assertEquals(
            'FSA2',
            amendedContractsList[0].Franchise_Supplemental_Agreement_URL__c,
            'Contracts field missmatch'
        );
        system.assertEquals(
            'MSA2',
            amendedContractsList[0].Master_Supplemental_Agreement_URL__c,
            'Contracts field missmatch'
        );

        ((fflib_SObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
    }

    /**
     * @description To test updation of Payment Method field on all the franchise Account
     * associated with the corporate Account Ids received when "UPDATE_FRANCHISE_ACCOUNT_TO_WITHHOLDING"
     * platform event is received.
     */
    @isTest
    private static void testWhenCorporateAccountIdsPayloadReceivedThenPaymentMethodSwitchedOnAssociatedFranchiseAccounts() {
        Id agreementId = fflib_IDGenerator.generate(Agreement__c.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id corporateAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id franchiseAccountId = fflib_IDGenerator.generate(Account.SObjectType);

        Fake franchiseAgreementFakeInstance = new Fake(Agreement__c.class)
            .setField(Agreement__c.Id, agreementId)
            .setField(Agreement__c.Name, AGREEMENT_NAME)
            .setField(Agreement__c.Account__c, franchiseAccountId)
            .setField(Agreement__c.Contract__c, contractId)
            .setField(Agreement__c.Type__c, AGREEMENT_TYPE_FRANCHISE_AGREEMENT)
            .setField(Agreement__c.Status__c, AGREEMENT_STATUS_ACTIVE);
        Agreement__c franchiseAgreement = (Agreement__c) ServiceMockDataBuilder.convertToSObject(
            franchiseAgreementFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAgreementsSelector agreementsSelectorMock = (IAgreementsSelector) mocks.mock(
            IAgreementsSelector.class
        );
        IStaticConfigurationsSelector staticConfigurationsMock = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(agreementsSelectorMock.sObjectType()).thenReturn(Agreement__c.SObjectType);
        mocks.when(
                agreementsSelectorMock.selectNonWithholdingFranchiseAccountsByActiveAgreements(
                    new Set<Id>{ corporateAccountId },
                    Integer.valueOf(FRANCHISE_ACCOUNTS_WITHHOLDING_QUERY_LIMIT)
                )
            )
            .thenReturn(new List<Agreement__c>{ franchiseAgreement });
        mocks.when(
                agreementsSelectorMock.selectCountOfNonWithholdingFranchiseAccountsByActiveAgreements(
                    new Set<Id>{ corporateAccountId }
                )
            )
            .thenReturn(new List<Aggregate>{});

        mocks.when(staticConfigurationsMock.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                staticConfigurationsMock.getInstanceValue(
                    CORPORATE_ACCOUNT_IDS_CHUNK_SIZE_TO_SWITCH_PAYMENT_METHOD_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = CORPORATE_ACCOUNT_IDS_CHUNK_SIZE_TO_SWITCH_PAYMENT_METHOD_STATIC_CONFIG,
                    Configuration_Value__c = CORPORATE_ACCOUNT_IDS_CHUNK_SIZE_TO_SWITCH_PAYMENT_METHOD
                )
            );
        mocks.when(
                staticConfigurationsMock.getInstanceValue(
                    FRANCHISE_ACCOUNTS_WITHHOLDING_QUERY_LIMIT_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = FRANCHISE_ACCOUNTS_WITHHOLDING_QUERY_LIMIT_STATIC_CONFIG,
                    Configuration_Value__c = FRANCHISE_ACCOUNTS_WITHHOLDING_QUERY_LIMIT
                )
            );
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(agreementsSelectorMock);
        Application.SELECTOR.setMock(staticConfigurationsMock);
        String eventPayload = JSON.serialize(new Set<Id>{ corporateAccountId });
        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = EVENT_TOPIC_UPDATE_FRANCHISE_ACCOUNT_TO_WITHHOLDING
        );
        ContractsService.execute(new List<Notifier__e>{ mockNotifierEvent });
        fflib_ArgumentCaptor capturedUpdateUOWArguments = fflib_ArgumentCaptor.forClass(
            UpdateUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 3)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((UpdateUnitOfWorkHelper) capturedUpdateUOWArguments.capture());
        Boolean franchiseAccountIdToProcess =
            ((UpdateUnitOfWorkHelper) capturedUpdateUOWArguments.getValue())
                .sObjectsToUpdate[0]
                .get(ID_FIELD_API) == franchiseAccountId;
        System.assertEquals(true, franchiseAccountIdToProcess, INCORRECT_ID_ERROR_MESSAGE);
    }

    /**
     * @description To test Payment Method field not updated on the franchise Account when there is no
     * associated franchise Account exist with the corporate Account Ids received
     * when "UPDATE_FRANCHISE_ACCOUNT_TO_WITHHOLDING" platform event is received.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenCorporateAccountIdsPayloadReceivedThenPaymentMethodNotSwitched() {
        Id corporateAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id franchiseAccountId = fflib_IDGenerator.generate(Account.SObjectType);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAgreementsSelector agreementsSelectorMock = (IAgreementsSelector) mocks.mock(
            IAgreementsSelector.class
        );
        IStaticConfigurationsSelector staticConfigurationsMock = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(agreementsSelectorMock.sObjectType()).thenReturn(Agreement__c.SObjectType);
        mocks.when(
                agreementsSelectorMock.selectNonWithholdingFranchiseAccountsByActiveAgreements(
                    new Set<Id>{ corporateAccountId },
                    Integer.valueOf(FRANCHISE_ACCOUNTS_WITHHOLDING_QUERY_LIMIT)
                )
            )
            .thenReturn(new List<Agreement__c>{});
        mocks.when(
                agreementsSelectorMock.selectCountOfNonWithholdingFranchiseAccountsByActiveAgreements(
                    new Set<Id>{ corporateAccountId }
                )
            )
            .thenReturn(new List<Aggregate>{});
        mocks.when(staticConfigurationsMock.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                staticConfigurationsMock.getInstanceValue(
                    CORPORATE_ACCOUNT_IDS_CHUNK_SIZE_TO_SWITCH_PAYMENT_METHOD_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = CORPORATE_ACCOUNT_IDS_CHUNK_SIZE_TO_SWITCH_PAYMENT_METHOD_STATIC_CONFIG,
                    Configuration_Value__c = CORPORATE_ACCOUNT_IDS_CHUNK_SIZE_TO_SWITCH_PAYMENT_METHOD
                )
            );
        mocks.when(
                staticConfigurationsMock.getInstanceValue(
                    FRANCHISE_ACCOUNTS_WITHHOLDING_QUERY_LIMIT_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = FRANCHISE_ACCOUNTS_WITHHOLDING_QUERY_LIMIT_STATIC_CONFIG,
                    Configuration_Value__c = FRANCHISE_ACCOUNTS_WITHHOLDING_QUERY_LIMIT
                )
            );
        mocks.when(
                staticConfigurationsMock.getInstanceValue(
                    WITHHOLDING_OPT_OUT_LIMIT_IN_DAYS_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = WITHHOLDING_OPT_OUT_LIMIT_IN_DAYS_STATIC_CONFIG,
                    Configuration_Value__c = WITHHOLDING_OPT_OUT_LIMIT_IN_DAYS
                )
            );
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(agreementsSelectorMock);
        Application.SELECTOR.setMock(staticConfigurationsMock);
        String eventPayload = JSON.serialize(new Set<Id>{ corporateAccountId });
        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = EVENT_TOPIC_UPDATE_FRANCHISE_ACCOUNT_TO_WITHHOLDING
        );
        ContractsService.execute(new List<Notifier__e>{ mockNotifierEvent });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Account.Id => franchiseAccountId,
                        Account.Payment_Method__c => PAYMENT_METHOD_WITHHOLDING
                    }
                )
            );
    }

    /**
     * @description To test updation of Payment Method field on all the franchise Account
     * associated with the corporate Account Ids received when multiple corporate Account Ids
     * are received via "UPDATE_FRANCHISE_ACCOUNT_TO_WITHHOLDING" platform event
     * and notifier event published for another corporate account.
     */
    @isTest
    private static void testWhenMultipleCorporateAccountIdsPayloadReceivedThenPaymentMethodSwitchedOnAssociatedFranchiseAccountsAndNotifierEventPublishedForNextCorporateAccount() {
        Id agreementId = fflib_IDGenerator.generate(Agreement__c.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id corporateAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id newCorporateAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id franchiseAccountId = fflib_IDGenerator.generate(Account.SObjectType);

        Fake franchiseAgreementFakeInstance = new Fake(Agreement__c.class)
            .setField(Agreement__c.Id, agreementId)
            .setField(Agreement__c.Name, AGREEMENT_NAME)
            .setField(Agreement__c.Account__c, franchiseAccountId)
            .setField(Agreement__c.Contract__c, contractId)
            .setField(Agreement__c.Type__c, AGREEMENT_TYPE_FRANCHISE_AGREEMENT)
            .setField(Agreement__c.Status__c, AGREEMENT_STATUS_ACTIVE);
        Agreement__c franchiseAgreement = (Agreement__c) ServiceMockDataBuilder.convertToSObject(
            franchiseAgreementFakeInstance
        );
        Aggregate mockAgreementAggregate = new Aggregate();
        mockAgreementAggregate.put(AGGREGATE_CORPORATEACCOUNTID_FIELD_ALIAS, newCorporateAccountId);
        mockAgreementAggregate.put(AGGREGATE_AGREEMENTSCOUNT_FIELD_ALIAS, 1);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAgreementsSelector agreementsSelectorMock = (IAgreementsSelector) mocks.mock(
            IAgreementsSelector.class
        );
        IStaticConfigurationsSelector staticConfigurationsMock = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        INotifierEventsService notifierEventsServiceMock = (INotifierEventsService) mocks.mock(
            INotifierEventsService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(agreementsSelectorMock.sObjectType()).thenReturn(Agreement__c.SObjectType);
        mocks.when(
                agreementsSelectorMock.selectNonWithholdingFranchiseAccountsByActiveAgreements(
                    new Set<Id>{ corporateAccountId, newCorporateAccountId },
                    Integer.valueOf(FRANCHISE_ACCOUNTS_WITHHOLDING_QUERY_LIMIT)
                )
            )
            .thenReturn(new List<Agreement__c>{ franchiseAgreement });
        mocks.when(
                agreementsSelectorMock.selectCountOfNonWithholdingFranchiseAccountsByActiveAgreements(
                    new Set<Id>{ corporateAccountId, newCorporateAccountId }
                )
            )
            .thenReturn(new List<Aggregate>{ mockAgreementAggregate });

        mocks.when(staticConfigurationsMock.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                staticConfigurationsMock.getInstanceValue(
                    CORPORATE_ACCOUNT_IDS_CHUNK_SIZE_TO_SWITCH_PAYMENT_METHOD_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = CORPORATE_ACCOUNT_IDS_CHUNK_SIZE_TO_SWITCH_PAYMENT_METHOD_STATIC_CONFIG,
                    Configuration_Value__c = CORPORATE_ACCOUNT_IDS_CHUNK_SIZE_TO_SWITCH_PAYMENT_METHOD
                )
            );
        mocks.when(
                staticConfigurationsMock.getInstanceValue(
                    FRANCHISE_ACCOUNTS_WITHHOLDING_QUERY_LIMIT_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = FRANCHISE_ACCOUNTS_WITHHOLDING_QUERY_LIMIT_STATIC_CONFIG,
                    Configuration_Value__c = FRANCHISE_ACCOUNTS_WITHHOLDING_QUERY_LIMIT
                )
            );
        mocks.when(
                staticConfigurationsMock.getInstanceValue(
                    WITHHOLDING_OPT_OUT_LIMIT_IN_DAYS_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = WITHHOLDING_OPT_OUT_LIMIT_IN_DAYS_STATIC_CONFIG,
                    Configuration_Value__c = WITHHOLDING_OPT_OUT_LIMIT_IN_DAYS
                )
            );
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(agreementsSelectorMock);
        Application.SELECTOR.setMock(staticConfigurationsMock);
        Application.SERVICE.setMock(INotifierEventsService.class, notifierEventsServiceMock);
        String eventPayload = JSON.serialize(
            new Set<Id>{ corporateAccountId, newCorporateAccountId }
        );
        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = EVENT_TOPIC_UPDATE_FRANCHISE_ACCOUNT_TO_WITHHOLDING
        );
        ContractsService.execute(new List<Notifier__e>{ mockNotifierEvent });
        NotifierEventsService.publishBulkEvents(
            new Map<String, List<String>>{
                EVENT_TOPIC_UPDATE_FRANCHISE_ACCOUNT_TO_WITHHOLDING => new List<String>{
                    JSON.serialize(new List<Id>{ newCorporateAccountId })
                }
            }
        );
        fflib_ArgumentCaptor capturedUpdateUOWArguments = fflib_ArgumentCaptor.forClass(
            UpdateUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 4)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((UpdateUnitOfWorkHelper) capturedUpdateUOWArguments.capture());

        Boolean franchiseAccountIdToProcess =
            ((UpdateUnitOfWorkHelper) capturedUpdateUOWArguments.getValue())
                .sObjectsToUpdate[0]
                .get(ID_FIELD_API) == franchiseAccountId;
        System.assertEquals(true, franchiseAccountIdToProcess, INCORRECT_ID_ERROR_MESSAGE);
    }

    /**
     * @description To test when Mx Onboarding Links and Subscriptions related to Onboarding Link's Contract are
     * passed for Net New Onboarding then return eligible Work Order Types to be created for each Contract.
     */
    @isTest
    private static void testWhenMxOnboardingLinksAndRelatedSubscriptionsPassedForNetNewThenReturnEligibleTypesForWorkOrderCreation() {
        Id mxOnboardingLinkId = fflib_IDGenerator.generate(Mx_Onboarding_Link__c.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Map<Id, Set<String>> contractIdToSubscriptionsPresent = new Map<Id, Set<String>>{
            contractId => new Set<String>{ MARKETPLACE_PLATFORM, STOREFRONT_PLATFORM }
        };
        Fake contractInstance = new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.Status, STATUS_ACTIVATED)
            .setField(
                Contract.SBQQ__Opportunity__c,
                fflib_IDGenerator.generate(Opportunity.SObjectType)
            );
        Mx_Onboarding_Link__c mxOnboardingLinkFake = (Mx_Onboarding_Link__c) new Fake(
                Mx_Onboarding_Link__c.class
            )
            .setField(Mx_Onboarding_Link__c.Id, mxOnboardingLinkId)
            .setField(
                Mx_Onboarding_Link__c.Onboarding_Scenario__c,
                ONBOARDING_SCENARIO_NET_NEW_MX_ONBOARDING
            )
            .setField(Mx_Onboarding_Link__c.Contract__c, contractId)
            .setParent('Contract__r', contractInstance)
            .toSobject();
        Test.startTest();
        Set<String> contractIdToWorkOrderToBeCreated = ContractsService.getEligibleContractsForOnboardingInputsWorkOrderCreation(
            new List<Mx_Onboarding_Link__c>{ mxOnboardingLinkFake },
            contractIdToSubscriptionsPresent
        );
        Test.stopTest();
        System.assertEquals(
            contractIdToWorkOrderToBeCreated.size(),
            2,
            ASSERT_MESSAGE_MISMATCH_IN_NO_OF_VALUES_RETURNED
        );
    }

    /**
     * @description To test when Mx Onboarding Links and Subscriptions related to Onboarding Link's Contract are
     * passed for Product Addition then return eligible Work Order Types to be created for each Contract.
     */
    @isTest
    private static void testWhenMxOnboardingLinksAndRelatedSubscriptionsPassedForProductAdditionThenReturnEligibleTypesForWorkOrderCreation() {
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id mxOnboardingLinkId = fflib_IDGenerator.generate(Mx_Onboarding_Link__c.SObjectType);
        String productsOnContract = 'Marketplace;Storefront + Drive ';
        Map<Id, Set<String>> contractIdToSubscriptionsPresent = new Map<Id, Set<String>>{
            contractId => new Set<String>{ MARKETPLACE_PLATFORM, STOREFRONT_PLATFORM }
        };
        Fake contractInstance = new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.Status, STATUS_ACTIVATED)
            .setField(
                Contract.SBQQ__Opportunity__c,
                fflib_IDGenerator.generate(Opportunity.SObjectType)
            );
        Mx_Onboarding_Link__c mxOnboardingLinkFake = (Mx_Onboarding_Link__c) new Fake(
                Mx_Onboarding_Link__c.class
            )
            .setField(Mx_Onboarding_Link__c.Id, mxOnboardingLinkId)
            .setField(
                Mx_Onboarding_Link__c.Onboarding_Scenario__c,
                ONBOARDING_SCENARIO_PRODUCT_ADDITION
            )
            .setField(Mx_Onboarding_Link__c.Contract__c, contractId)
            .setField(Mx_Onboarding_Link__c.Product_on_Contract__c, productsOnContract)
            .setParent('Contract__r', contractInstance)
            .toSobject();
        Test.startTest();
        Set<String> contractIdToWorkOrderToBeCreated = ContractsService.getEligibleContractsForOnboardingInputsWorkOrderCreation(
            new List<Mx_Onboarding_Link__c>{ mxOnboardingLinkFake },
            contractIdToSubscriptionsPresent
        );
        Test.stopTest();
        System.assertEquals(
            contractIdToWorkOrderToBeCreated.size(),
            2,
            ASSERT_MESSAGE_MISMATCH_IN_NO_OF_VALUES_RETURNED
        );
    }

    /**
     * @description To test when Mx Onboarding Links and Drive Subscriptions related to Onboarding Link's Contract are
     * passed for New Store Expansion then return empty Set.
     */
    @isTest
    private static void testWhenMxOnboardingLinksAndRelatedDriveSubscriptionsPassedForNewStoreAdditionThenReturnEmptySet() {
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id mxOnboardingLinkId = fflib_IDGenerator.generate(Mx_Onboarding_Link__c.SObjectType);
        Map<Id, Set<String>> contractIdToSubscriptionsPresent = new Map<Id, Set<String>>{
            contractId => new Set<String>{ DRIVE_PLATFORM }
        };
        Fake contractInstance = new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.Status, STATUS_ACTIVATED)
            .setField(
                Contract.SBQQ__Opportunity__c,
                fflib_IDGenerator.generate(Opportunity.SObjectType)
            );
        Mx_Onboarding_Link__c mxOnboardingLinkFake = (Mx_Onboarding_Link__c) new Fake(
                Mx_Onboarding_Link__c.class
            )
            .setField(Mx_Onboarding_Link__c.Id, mxOnboardingLinkId)
            .setField(
                Mx_Onboarding_Link__c.Onboarding_Scenario__c,
                ONBOARDING_SCENARIO_NEW_STORE_EXPANSION
            )
            .setField(Mx_Onboarding_Link__c.Contract__c, contractId)
            .setParent('Contract__r', contractInstance)
            .toSobject();
        Test.startTest();
        Set<String> contractIdToWorkOrderToBeCreated = ContractsService.getEligibleContractsForOnboardingInputsWorkOrderCreation(
            new List<Mx_Onboarding_Link__c>{ mxOnboardingLinkFake },
            contractIdToSubscriptionsPresent
        );
        Test.stopTest();
        System.assertEquals(
            contractIdToWorkOrderToBeCreated.size(),
            0,
            ASSERT_MESSAGE_MISMATCH_IN_NO_OF_VALUES_RETURNED
        );
    }

    /**
     * @description To test when Parent Account Ids are passed then Parent Account to Middleware Provider
     * Contracts map is returned.
     */
    @isTest
    private static void testWhenParentAccountIdsPassedThenReturnParentAccountToMiddlewareProviderContracts() {
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Map<Id, List<Contract>> parentAccountIdToMWPContracts = new Map<Id, List<Contract>>();
        Fake contractInstance = new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.AccountId, parentAccountId)
            .setField(
                Contract.SBQQ__Opportunity__c,
                fflib_IDGenerator.generate(Opportunity.SObjectType)
            )
            .setField(
                Contract.Contract_Split_Category__c,
                CONTRACT_SPLIT_CATEGORY_MIDDLEWARE_PROVIDER
            );
        Contract newContract = (Contract) contractInstance.toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IContractsSelector contractsSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        mocks.startStubbing();
        mocks.when(contractsSelectorMock.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(
                contractsSelectorMock.selectContractSplitCategoryByParentAccountIds(
                    new Set<Id>{ parentAccountId }
                )
            )
            .thenReturn(new List<Contract>{ newContract });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(contractsSelectorMock);
        Test.startTest();
        parentAccountIdToMWPContracts = ContractsService.setMiddlewareProviderContractOnParentAccount(
            new Set<Id>{ parentAccountId }
        );
        Test.stopTest();
        System.assertEquals(
            parentAccountIdToMWPContracts.size(),
            1,
            ASSERT_MESSAGE_MISMATCH_IN_NO_OF_VALUES_RETURNED
        );
    }

    /**
     * @description To test when Parent Account Ids are passed then Parent Account to
     * all Contracts map is returned.
     */
    @isTest
    private static void testWhenParentAccountIdsPassedThenReturnParentAccountToAllContracts() {
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Map<Id, List<Contract>> parentAccountIdToMWPContracts = new Map<Id, List<Contract>>();
        Fake contractInstance = new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.AccountId, parentAccountId)
            .setField(
                Contract.SBQQ__Opportunity__c,
                fflib_IDGenerator.generate(Opportunity.SObjectType)
            );
        Contract newContract = (Contract) contractInstance.toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IContractsSelector contractsSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        mocks.startStubbing();
        mocks.when(contractsSelectorMock.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(contractsSelectorMock.selectByParentAccountId(new Set<Id>{ parentAccountId }))
            .thenReturn(new List<Contract>{ newContract });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(contractsSelectorMock);
        Test.startTest();
        parentAccountIdToMWPContracts = ContractsService.setAllContractOnParentAccount(
            new Set<Id>{ parentAccountId }
        );
        Test.stopTest();
        System.assertEquals(
            parentAccountIdToMWPContracts.size(),
            1,
            ASSERT_MESSAGE_MISMATCH_IN_NO_OF_VALUES_RETURNED
        );
    }
}