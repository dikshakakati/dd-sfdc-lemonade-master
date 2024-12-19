/**
 * @author Deloitte
 * @date 17/06/2022
 * @description Test class for OpportunitiesServiceImpl class.
 */
@isTest(seeAllData=false)
private class OpportunitiesServiceImplTest {
    private static final String ACCOUNT_PRIMARY_VERTICAL = 'Rx';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ADS_AND_PROMOS_PRODUCT_FAMILY_ADVERTISEMENT = 'Advertisement';
    private static final String ADS_AND_PROMOS_PRODUCT_FAMILY_MARKETPLACE_PROMOTION = 'Marketplace Promotion';
    private static final String AGGREGATE_OPPORTUNITY_ID_FIELD_ALIAS = 'opportunityId';
    private static final String AGGREGATE_OPPORTUNITY_PRODUCT_FAMILY_FIELD_ALIAS = 'productFamily';
    private static final String CONTRACTING_OPPORTUNITIES_ERROR_ASSERT_MESSAGE = 'Unexpected result: The error message was thrown for Opportunity with Work Order';
    private static final String OPPORTUNITIES_WITH_RELATIONSHIPS_ERROR_ASSERT_MESSAGE = 'Unexpected result: The opportunity Id with Brand Relationship was not retrieved.';
    private static final String CONTRACTING_STAGENAME_ERROR_ASSERT_MESSAGE = 'Unexpected result: The error message was thrown for Opportunity where Stage Name is not Contracting or Closed Won';
    private static final String DRIVE_PROMOTION_PRODUCT_FAMILY = 'Drive Promotion';
    private static final String MARKETPLACE_PRODUCT_FAMILY = 'Marketplace';
    private static final String NINTEX_USE_CASE_NEW_FRANCHISE = 'New Franchise - Unknown';
    private static final String NINTEX_USE_CASE_DRIVE_FORM = 'Drive - Amendment';
    private static final String OPPORTUNITY_DRIVE_NINTEX_ID = 'OpportunitiesServiceImplTestDriveNintexId';
    private static final String OPPORTUNITY_MARKETPLACE_NINTEX_ID = 'OpportunitiesServiceImplTestMarketPlaceNintexId';
    private static final String OPPORTUNITY_NAME = 'Test Opportunity';
    private static final String OPPORTUNITY_NINTEX_USE_CASE_RATE_CHANGE = 'Rate Change';
    private static final String OPPORTUNITY_SOURCE = 'Nintex';
    private static final String OPPORTUNITY_STAGE_PROSPECTING = 'Prospecting';
    private static final String OPPORTUNITY_STAGE_CLOSED_WON = 'Closed Won';
    private static final String OPPORTUNITY_STAGE_CONTRACTING = 'Contracting';
    private static final String SOURCE_NINTEX = 'Nintex';
    private static final String STAGENAME_CONTRACTING = 'Contracting';
    private static final String WORK_ORDER_TYPE_MARKETPLACE = 'Marketplace';
    private static final String USE_CASE = 'Drive - Amendment';
    private static final Decimal QUOTE_NUMBER_OF_STORES = 10;
    static final String EVENT_TOPIC_OPPORTUNITY_TEAM_MEMBER_CREATION = 'EVENT_TOPIC_OPPORTUNITY_TEAM_MEMBER_CREATION';
    static final String UPDATE_ACCOUNT_CURRENCY_ON_OPPORTUNITY = 'UPDATE_ACCOUNT_CURRENCY_ON_OPPORTUNITY';
    static final String CREATE_OPPORTUNITIES_FOR_NINTEX_USECASES = 'CREATE_OPPORTUNITIES_FOR_NINTEX_USECASES';
    private static final String OPPORTUNITY_CREATION_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG = 'Opportunity_Creation_Payload_Chunk_Size';
    private static final String NINTEX_WORK_ORDERS_PROCESSOR_BATCH_SIZE_STATIC_CONFIG = 'Nintex_Work_Orders_Processor_Batch_Size';
    private static final String METADATA_VALUE = '1';

    /**
     * @description To test logic for fetching OpportunitiesService.
     * Suppressed Warnings since mock verify method is equivalent of System.assert statement.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenReparentedOpportunitiesAreProvidedThenFetchOpportunityAccountRelationships() {
        String enterpriseOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        String smbOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Set<String> opportunityIds = new Set<String>{ enterpriseOpportunityId, smbOpportunityId };
        String enterpriseAccountRelationshipId = fflib_IDGenerator.generate(
            Opportunity_Account_Relationship__c.SObjectType
        );
        String smbAccountRelationshipId = fflib_IDGenerator.generate(
            Opportunity_Account_Relationship__c.SObjectType
        );
        List<sObject> sobjectsToBeDeleted = new List<sObject>();
        List<Opportunity_Account_Relationship__c> opportunityAccountRelationships = new List<Opportunity_Account_Relationship__c>{
            (Opportunity_Account_Relationship__c) new Fake(
                    Opportunity_Account_Relationship__c.class
                )
                .setField(Opportunity_Account_Relationship__c.Id, enterpriseAccountRelationshipId)
                .setField(
                    Opportunity_Account_Relationship__c.Opportunity__c,
                    enterpriseAccountRelationshipId
                )
                .toSObject(),
            (Opportunity_Account_Relationship__c) new Fake(
                    Opportunity_Account_Relationship__c.class
                )
                .setField(Opportunity_Account_Relationship__c.Id, smbAccountRelationshipId)
                .setField(Opportunity_Account_Relationship__c.Opportunity__c, smbOpportunityId)
                .toSObject()
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        OpportunityAccountRelationshipsSelector selectorMock = (OpportunityAccountRelationshipsSelector) mocks.mock(
            OpportunityAccountRelationshipsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType())
            .thenReturn(Opportunity_Account_Relationship__c.SObjectType);
        mocks.when(selectorMock.fetchRelationshipsByParentOpportunities(opportunityIds))
            .thenReturn(opportunityAccountRelationships);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        OpportunitiesService.deleteOpportunityAccountRelationships(opportunityIds);
        sobjectsToBeDeleted.addAll(opportunityAccountRelationships);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2))
            .registerDeleted(fflib_Match.anySObject());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description Tests if Opportunities of Negotiating stage are created with owner as franchise rep when set of franchise Account Ids are provided.
     * Suppressed Warnings since mock verify method is equivalent of System.assert statement.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenFranchiseAccountsAreProvidedThenCreateOpportunitiesWithOwnerIdAsFranchiseRep() {
        List<String> franchiseAccountIds = new List<String>{
            fflib_IDGenerator.generate(Account.SObjectType),
            fflib_IDGenerator.generate(Account.SObjectType)
        };
        Id corporateAccountOwnerId = fflib_IDGenerator.generate(User.SObjectType);
        Id corporateAccountTeamMemberUserId = fflib_IDGenerator.generate(User.SObjectType);
        Id corporateAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        String closedDateForOpportunities = '90';
        List<Account> franchiseAccounts = new List<Account>{
            new Account(
                Id = franchiseAccountIds[0],
                Name = 'Parent 1',
                Legal_Business_Name__c = 'Legal Parent 1'
            ),
            new Account(
                Id = franchiseAccountIds[1],
                Name = 'Parent 2',
                Legal_Business_Name__c = 'Legal Parent 2'
            )
        };

        Contract mockContract = (Contract) new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.AccountId, corporateAccountId)
            .setParent(
                'Account',
                new Fake(Account.class)
                    .setField(Account.Id, corporateAccountId)
                    .setField(Account.OwnerId, corporateAccountOwnerId)
            )
            .toSObject();

        AccountTeamMember mockAccountTeamMember = new AccountTeamMember(
            Id = fflib_IDGenerator.generate(AccountTeamMember.SObjectType),
            TeamMemberRole = 'Franchise Representative',
            UserId = corporateAccountTeamMemberUserId,
            AccountId = corporateAccountId
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        IContractsSelector contractsSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        IAccountTeamMembersSelector accountTeamMemberSelectorMock = (IAccountTeamMembersSelector) mocks.mock(
            IAccountTeamMembersSelector.class
        );

        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                selectorMock.selectById(
                    new Set<Id>{ franchiseAccountIds[0], franchiseAccountIds[1] }
                )
            )
            .thenReturn(franchiseAccounts);
        mocks.when(selectorMock.selectById(new Set<String>(franchiseAccountIds)))
            .thenReturn(franchiseAccounts);
        mocks.when(contractsSelectorMock.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(contractsSelectorMock.selectById(new Set<Id>{ contractId }))
            .thenReturn(new List<Contract>{ mockContract });
        mocks.when(accountTeamMemberSelectorMock.sObjectType())
            .thenReturn(AccountTeamMember.SObjectType);
        mocks.when(
                accountTeamMemberSelectorMock.selectFranchiseRepRoleAccountTeamMembersByAccountId(
                    corporateAccountId
                )
            )
            .thenReturn(new List<AccountTeamMember>{ mockAccountTeamMember });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        Application.SELECTOR.setMock(contractsSelectorMock);
        Application.SELECTOR.setMock(accountTeamMemberSelectorMock);

        Application.UNITOFWORK.setMock(mockUOW);
        OpportunitiesService.createOpportunitiesOnFranchiseAccounts(
            franchiseAccountIds,
            contractId,
            USE_CASE,
            closedDateForOpportunities
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Opportunity.AccountId => franchiseAccountIds[0],
                        Opportunity.Name => 'Legal Parent 1',
                        Opportunity.CloseDate => Date.today().addDays(90),
                        Opportunity.Opportunity_Sub_Type__c => 'Upgrade',
                        Opportunity.StageName => 'Negotiating',
                        Opportunity.Type => 'Existing',
                        Opportunity.Source__c => 'Nintex',
                        Opportunity.Nintex_Use_Case__c => USE_CASE,
                        Opportunity.Deal_Type__c => 'Standard',
                        Opportunity.ContractId => contractId,
                        Opportunity.OwnerId => corporateAccountTeamMemberUserId
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Opportunity.AccountId => franchiseAccountIds[1],
                        Opportunity.CloseDate => Date.today().addDays(90),
                        Opportunity.Name => 'Legal Parent 2',
                        Opportunity.Opportunity_Sub_Type__c => 'Upgrade',
                        Opportunity.StageName => 'Negotiating',
                        Opportunity.Type => 'Existing',
                        Opportunity.Source__c => 'Nintex',
                        Opportunity.Nintex_Use_Case__c => USE_CASE,
                        Opportunity.Deal_Type__c => 'Standard',
                        Opportunity.ContractId => contractId,
                        Opportunity.OwnerId => corporateAccountTeamMemberUserId
                    }
                )
            );
    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenReparentedOpportunitiesAreProvidedThenExceptionIsThrown() {
        String enterpriseOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        String smbOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Set<String> opportunityIds = new Set<String>{ enterpriseOpportunityId, smbOpportunityId };
        String enterpriseAccountRelationshipId = fflib_IDGenerator.generate(
            Opportunity_Account_Relationship__c.SObjectType
        );
        String smbAccountRelationshipId = fflib_IDGenerator.generate(
            Opportunity_Account_Relationship__c.SObjectType
        );
        List<Opportunity_Account_Relationship__c> opportunityAccountRelationships = new List<Opportunity_Account_Relationship__c>{
            (Opportunity_Account_Relationship__c) new Fake(
                    Opportunity_Account_Relationship__c.class
                )
                .setField(Opportunity_Account_Relationship__c.Id, enterpriseAccountRelationshipId)
                .setField(
                    Opportunity_Account_Relationship__c.Opportunity__c,
                    enterpriseAccountRelationshipId
                )
                .toSObject(),
            (Opportunity_Account_Relationship__c) new Fake(
                    Opportunity_Account_Relationship__c.class
                )
                .setField(Opportunity_Account_Relationship__c.Id, smbAccountRelationshipId)
                .setField(Opportunity_Account_Relationship__c.Opportunity__c, smbOpportunityId)
                .toSObject()
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        OpportunityAccountRelationshipsSelector selectorMock = (OpportunityAccountRelationshipsSelector) mocks.mock(
            OpportunityAccountRelationshipsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType())
            .thenReturn(Opportunity_Account_Relationship__c.SObjectType);
        mocks.when(selectorMock.fetchRelationshipsByParentOpportunities(opportunityIds))
            .thenReturn(opportunityAccountRelationships);
        ((fflib_ISObjectUnitOfWork) mocks.doThrowWhen(
                new TestCommitException('Exception occurred while performing DML operation'),
                mockUOW
            ))
            .commitWork();
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        try {
            OpportunitiesService.deleteOpportunityAccountRelationships(opportunityIds);
            ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        } catch (Exception mockException) {
            System.assertEquals(
                'Exception occurred while performing DML operation',
                mockException.getMessage(),
                'Unexpected Error: The Exception fired was not a TestCommitException.'
            );
        }
    }

    /**
     * @description This method validates that currency on open Opportunity is updated where currency on account is updated.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenNotifierEventsReceivedThenCurrencyOnOpportunityWithoutQuotesUpdatedWithAccountCurrency() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Account[] newAccounts = new List<Account>{
            new Account(Id = businessAccountId, Name = 'Test 2')
        };
        Id smbOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        OpportunitiesSelector opportunitiesSelectorMock = (OpportunitiesSelector) mocks.mock(
            OpportunitiesSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(opportunitiesSelectorMock.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(
                opportunitiesSelectorMock.selectOpenOpportunitiesByAccountIds(
                    new Set<Id>{ businessAccountId }
                )
            )
            .thenReturn(new List<Opportunity>{ new Opportunity(Id = smbOpportunityId) });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(opportunitiesSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        String eventPayload = JSON.serialize(new Set<Id>{ newAccounts[0].Id });
        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = UPDATE_ACCOUNT_CURRENCY_ON_OPPORTUNITY
        );
        OpportunitiesService.execute(new List<Notifier__e>{ mockNotifierEvent });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(fflib_Match.anySObject());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description This method validates that the opportunities are created for chunked data
     * consisting of the given franchise account ids,
     * contract and use case using notifier events
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenFranchiseAccountsAreProvidedThenOpportunitiesAreCreatedForChunkedData() {
        List<String> franchiseAccountIds = new List<String>{
            fflib_IDGenerator.generate(Account.SObjectType),
            fflib_IDGenerator.generate(Account.SObjectType)
        };
        List<Account> franchiseAccounts = new List<Account>{
            new Account(
                Id = franchiseAccountIds[0],
                Name = 'Parent 1',
                Legal_Business_Name__c = 'Legal Parent 1'
            ),
            new Account(
                Id = franchiseAccountIds[1],
                Name = 'Parent 2',
                Legal_Business_Name__c = 'Legal Parent 2'
            )
        };
        Set<Id> franchiseAccountId1 = new Set<Id>{ franchiseAccountIds[0] };
        Set<Id> franchiseAccountId2 = new Set<Id>{ franchiseAccountIds[1] };
        List<String> franchiseAccountId1Wrapper = new List<String>{ franchiseAccountIds[0] };
        List<String> franchiseAccountId2Wrapper = new List<String>{ franchiseAccountIds[1] };
        String contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        String closedDateForOpportunities = '90';

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IStaticConfigurationsSelector mockStaticConfigurations = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        INotifierEventsService notifierEventServiceMock = (INotifierEventsService) mocks.mock(
            INotifierEventsService.class
        );
        INotifierEventsPayloadGenerationService notifierEventsPayloadGenerationServiceMock = (INotifierEventsPayloadGenerationService) mocks.mock(
            INotifierEventsPayloadGenerationService.class
        );

        NintexOpportunityCreationWrapper wrapperChunk1 = new NintexOpportunityCreationWrapper(
            franchiseAccountId1Wrapper,
            contractId,
            USE_CASE,
            closedDateForOpportunities
        );
        NintexOpportunityCreationWrapper wrapperChunk2 = new NintexOpportunityCreationWrapper(
            franchiseAccountId2Wrapper,
            contractId,
            USE_CASE,
            closedDateForOpportunities
        );

        List<String> payloads = new List<String>{
            JSON.serialize(franchiseAccountId1),
            JSON.serialize(franchiseAccountId2)
        };

        List<String> payloadsWithWrapper = new List<String>{
            JSON.serialize(wrapperChunk1),
            JSON.serialize(wrapperChunk2)
        };

        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectById(new Set<String>(franchiseAccountIds)))
            .thenReturn(franchiseAccounts);
        mocks.when(mockStaticConfigurations.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurations.getInstanceValue(
                    NINTEX_WORK_ORDERS_PROCESSOR_BATCH_SIZE_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = NINTEX_WORK_ORDERS_PROCESSOR_BATCH_SIZE_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(
                mockStaticConfigurations.getInstanceValue(
                    OPPORTUNITY_CREATION_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = OPPORTUNITY_CREATION_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(
                notifierEventsPayloadGenerationServiceMock.generateChunkedPayloadsBySobjectIds(
                    new Set<Id>{ franchiseAccounts[0].Id, franchiseAccounts[1].Id },
                    Integer.valueOf(METADATA_VALUE)
                )
            )
            .thenReturn(payloads);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        Application.SELECTOR.setMock(mockStaticConfigurations);
        Application.SERVICE.setMock(INotifierEventsService.class, notifierEventServiceMock);
        Application.SERVICE.setMock(
            INotifierEventsPayloadGenerationService.class,
            notifierEventsPayloadGenerationServiceMock
        );
        OpportunitiesService.createOpportunitiesOnFranchiseAccounts(
            franchiseAccountIds,
            contractId,
            USE_CASE,
            closedDateForOpportunities
        );
        ((INotifierEventsPayloadGenerationService) mocks.verify(
                notifierEventsPayloadGenerationServiceMock,
                1
            ))
            .generateChunkedPayloadsBySobjectIds(
                new Set<Id>{ franchiseAccounts[0].Id, franchiseAccounts[1].Id },
                Integer.valueOf(METADATA_VALUE)
            );
        ((INotifierEventsService) mocks.verify(notifierEventServiceMock, 1))
            .publishBulkEvents(
                new Map<String, List<String>>{
                    CREATE_OPPORTUNITIES_FOR_NINTEX_USECASES => payloadsWithWrapper
                }
            );
    }

    /**
     * @description This method validates scenarios where Opportunities will not be updated as a
     * result of Currency update on Account.
     *  1. Currency on Opportunities with Quotes will not be updated.
     *  2. Currency on Closed Opportunities will not be updated
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenNotifierEventsReceivedThenCurrencyOnIneligibleOpportunitiesAreNotUpdated() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Account[] newAccounts = new List<Account>{
            new Account(Id = businessAccountId, Name = 'Test 2')
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        OpportunitiesSelector opportunitiesSelectorMock = (OpportunitiesSelector) mocks.mock(
            OpportunitiesSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(opportunitiesSelectorMock.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(
                opportunitiesSelectorMock.selectOpenOpportunitiesByAccountIds(
                    new Set<Id>{ businessAccountId }
                )
            )
            .thenReturn(new List<Opportunity>());
        mocks.stopStubbing();
        Application.SELECTOR.setMock(opportunitiesSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        String eventPayload = JSON.serialize(new Set<Id>{ newAccounts[0].Id });
        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = UPDATE_ACCOUNT_CURRENCY_ON_OPPORTUNITY
        );
        OpportunitiesService.execute(new List<Notifier__e>{ mockNotifierEvent });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0))
            .registerDirty(fflib_Match.anySObject());
    }

    /**
     * @description This method validates scenarios where Opportunities Stage is changed to ClosedWon
     * based on value of Franchise Amendent process field on Quote.
     */
    @isTest
    private static void testWhenFranchiseAmendOnQuoteThenOpportunityStageChangestoClosedWon() {
        List<Account> accountList = new List<Account>{
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 1')
        };
        Id opportunityRecordId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id quoteId = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType);
        Id orderId = fflib_IDGenerator.generate(Order.SObjectType);
        Fake quoteFakeInstance = new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id, quoteId)
            .setField(SBQQ__Quote__c.SBQQ__Opportunity2__c, opportunityRecordId)
            .setField(SBQQ__Quote__c.SBQQ__Primary__c, 'true')
            .setField(SBQQ__Quote__c.Opt_In_Opt_Out_Decision__c, 'FSA')
            .setField(SBQQ__Quote__c.Opt_In_Opt_Out_Response_Time_in_Days__c, '2')
            .setField(SBQQ__Quote__c.Opt_Out_Save_Period_days__c, '1')
            .setField(SBQQ__Quote__c.Opt_In_Out_Responsible_Party__c, 'Merchant');
        SBQQ__Quote__c quote1 = (SBQQ__Quote__c) quoteFakeInstance.toSObject();
        Fake orderFakeInstance = new Fake(Order.class)
            .setField(Order.Id, orderId)
            .setField(Order.SBQQ__Quote__c, quoteId)
            .setField(Order.AccountId, accountList[0].Id)
            .setParent('SBQQ__Quote__r', quoteFakeInstance)
            .setFakeId();
        Fake contractFakeInstance = new Fake(Contract.class)
            .setField(Contract.AccountId, accountList[0].Id)
            .setField(Contract.CurrencyIsoCode, 'USD - U.S. Dollar')
            .setField(Contract.Status, 'Activated')
            .setField(Contract.SBQQ__Opportunity__c, opportunityRecordId)
            .setField(Contract.SBQQ__Order__c, orderId)
            .setParent('SBQQ__Order__r', orderFakeInstance)
            .setFakeId();
        Contract contract = (Contract) contractFakeInstance.toSObject();
        Opportunity opportunityRecord1 = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityRecordId)
            .setField(Opportunity.Name, 'Test opportunity 1')
            .setField(Opportunity.AccountId, accountList[0].Id)
            .setField(Opportunity.ContractId, contract.Id)
            .setField(Opportunity.Nintex_Use_Case__c, 'Rate Change')
            .setField(Opportunity.createdDate, System.today())
            .setField(Opportunity.Nintex_Signed_Date__c, System.today().addDays(2))
            .setParent('Contract', contractFakeInstance)
            .toSObject();
        List<Opportunity> opportunityList = new List<Opportunity>{ opportunityRecord1 };
        Set<Id> opportunityIds = new Set<Id>{ opportunityRecord1.Id };
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>{ quote1 };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        OpportunitiesSelector opportunitiesSelectorMock = (OpportunitiesSelector) mocks.mock(
            OpportunitiesSelector.class
        );
        QuotesSelector quotesSelectorMock = (QuotesSelector) mocks.mock(QuotesSelector.class);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(opportunitiesSelectorMock.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(opportunitiesSelectorMock.selectOpportunitiesWithNintexUseCase(opportunityIds))
            .thenReturn(opportunityList);
        mocks.when(quotesSelectorMock.sObjectType()).thenReturn(SBQQ__Quote__c.SObjectType);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(opportunitiesSelectorMock);
        Application.SELECTOR.setMock(quotesSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        Map<Id, SBQQ__Quote__c> quoteMap = new Map<Id, SBQQ__Quote__c>();
        for (SBQQ__Quote__c eachQuote : quoteList) {
            quoteMap.put(eachQuote.SBQQ__Opportunity2__c, eachQuote);
        }
        OpportunitiesService.updateStageToClosedByFranchiseAmendmentProcessByChangeEvent(
            opportunityIds,
            true
        );
        System.assertEquals(
            'Closed Won',
            opportunityList[0].StageName,
            'Mismatch in Opportunity Stage Name'
        );
    }

    /**
     * @description To test restriction on corporate Opportunity Stage change to Contracting
     * when it has no associated Work Order.
     */
    @isTest
    private static void testWhenStageChangedToContractingThenRestrictUpdateOnOpportunityWithoutWorkOrder() {
        Id mockOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        List<Opportunity> mockOpportunities = new List<Opportunity>{
            new Opportunity(Id = mockOpportunityId, StageName = STAGENAME_CONTRACTING)
        };
        Aggregate mockAggregateMarketplace = new Aggregate();
        mockAggregateMarketplace.put(AGGREGATE_OPPORTUNITY_ID_FIELD_ALIAS, mockOpportunityId);
        mockAggregateMarketplace.put(
            AGGREGATE_OPPORTUNITY_PRODUCT_FAMILY_FIELD_ALIAS,
            MARKETPLACE_PRODUCT_FAMILY
        );
        Aggregate mockAggregateAdvertisement = new Aggregate();
        mockAggregateAdvertisement.put(AGGREGATE_OPPORTUNITY_ID_FIELD_ALIAS, mockOpportunityId);
        mockAggregateAdvertisement.put(
            AGGREGATE_OPPORTUNITY_PRODUCT_FAMILY_FIELD_ALIAS,
            ADS_AND_PROMOS_PRODUCT_FAMILY_ADVERTISEMENT
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersService mockWorkOrdersService = (IWorkOrdersService) mocks.mock(
            IWorkOrdersService.class
        );
        IOpportunityLineItemsSelector opportunityLineItemsSelectorMock = (IOpportunityLineItemsSelector) mocks.mock(
            IOpportunityLineItemsSelector.class
        );
        mocks.startStubbing();
        mocks.when(opportunityLineItemsSelectorMock.sObjectType())
            .thenReturn(OpportunityLineItem.SObjectType);
        mocks.when(
                opportunityLineItemsSelectorMock.getOpportunityProductsCountFilteredAndGroupedByOpportunityIdsAndProductFamilies(
                    new Set<Id>{ mockOpportunityId }
                )
            )
            .thenReturn(
                new List<Aggregate>{ mockAggregateMarketplace, mockAggregateAdvertisement }
            );
        mocks.when(mockWorkOrdersService.collectOpportunitiesWithoutWorkOrder(mockOpportunities))
            .thenReturn(mockOpportunities);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(opportunityLineItemsSelectorMock);
        Application.SERVICE.setMock(IWorkOrdersService.class, mockWorkOrdersService);
        Test.startTest();
        List<Opportunity> opportunitiesWithoutWorkOrder = OpportunitiesService.collectOpportunitiesWithoutWorkOrderInContractingStage(
            mockOpportunities
        );
        Test.stopTest();
        System.assertEquals(
            opportunitiesWithoutWorkOrder,
            mockOpportunities,
            CONTRACTING_STAGENAME_ERROR_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test there is no restriction on corporate Opportunity Stage change
     * to Contracting when it has only Ads and Promos Product Families associated.
     */
    @isTest
    private static void testWhenStageChangedToContractingWithOnlyAdsAndPromosProductFamiliesThenUpdateOfOpportunityWithoutWorkOrderNotRestricted() {
        Id mockOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        List<Opportunity> mockOpportunities = new List<Opportunity>{
            new Opportunity(Id = mockOpportunityId, StageName = STAGENAME_CONTRACTING)
        };
        Aggregate mockAggregateAdvertisement = new Aggregate();
        mockAggregateAdvertisement.put(AGGREGATE_OPPORTUNITY_ID_FIELD_ALIAS, mockOpportunityId);
        mockAggregateAdvertisement.put(
            AGGREGATE_OPPORTUNITY_PRODUCT_FAMILY_FIELD_ALIAS,
            ADS_AND_PROMOS_PRODUCT_FAMILY_ADVERTISEMENT
        );
        Aggregate mockAggregateMarketplacePromotion = new Aggregate();
        mockAggregateMarketplacePromotion.put(
            AGGREGATE_OPPORTUNITY_ID_FIELD_ALIAS,
            mockOpportunityId
        );
        mockAggregateMarketplacePromotion.put(
            AGGREGATE_OPPORTUNITY_PRODUCT_FAMILY_FIELD_ALIAS,
            ADS_AND_PROMOS_PRODUCT_FAMILY_MARKETPLACE_PROMOTION
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersService mockWorkOrdersService = (IWorkOrdersService) mocks.mock(
            IWorkOrdersService.class
        );
        IOpportunityLineItemsSelector opportunityLineItemsSelectorMock = (IOpportunityLineItemsSelector) mocks.mock(
            IOpportunityLineItemsSelector.class
        );
        mocks.startStubbing();
        mocks.when(opportunityLineItemsSelectorMock.sObjectType())
            .thenReturn(OpportunityLineItem.SObjectType);
        mocks.when(
                opportunityLineItemsSelectorMock.getOpportunityProductsCountFilteredAndGroupedByOpportunityIdsAndProductFamilies(
                    new Set<Id>{ mockOpportunityId }
                )
            )
            .thenReturn(
                new List<Aggregate>{ mockAggregateAdvertisement, mockAggregateMarketplacePromotion }
            );
        mocks.when(mockWorkOrdersService.collectOpportunitiesWithoutWorkOrder(mockOpportunities))
            .thenReturn(mockOpportunities);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(opportunityLineItemsSelectorMock);
        Application.SERVICE.setMock(IWorkOrdersService.class, mockWorkOrdersService);
        Test.startTest();
        List<Opportunity> opportunitiesWithError = OpportunitiesService.collectOpportunitiesWithoutWorkOrderInContractingStage(
            mockOpportunities
        );
        Test.stopTest();
        System.assertEquals(
            0,
            opportunitiesWithError.size(),
            CONTRACTING_OPPORTUNITIES_ERROR_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test there is no restriction on corporate Opportunity Stage change
     * to Contracting when it has only Drive Promotion Product Family associated.
     */
    @isTest
    private static void testWhenStageChangedToContractingWithOnlyDrivePromotionProductFamilyThenUpdateOfOpportunityWithoutWorkOrderNotRestricted() {
        Id mockOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        List<Opportunity> mockOpportunities = new List<Opportunity>{
            new Opportunity(Id = mockOpportunityId, StageName = STAGENAME_CONTRACTING)
        };
        Aggregate mockAggregateDrivePromotion = new Aggregate();
        mockAggregateDrivePromotion.put(AGGREGATE_OPPORTUNITY_ID_FIELD_ALIAS, mockOpportunityId);
        mockAggregateDrivePromotion.put(
            AGGREGATE_OPPORTUNITY_PRODUCT_FAMILY_FIELD_ALIAS,
            DRIVE_PROMOTION_PRODUCT_FAMILY
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersService mockWorkOrdersService = (IWorkOrdersService) mocks.mock(
            IWorkOrdersService.class
        );
        IOpportunityLineItemsSelector opportunityLineItemsSelectorMock = (IOpportunityLineItemsSelector) mocks.mock(
            IOpportunityLineItemsSelector.class
        );
        mocks.startStubbing();
        mocks.when(opportunityLineItemsSelectorMock.sObjectType())
            .thenReturn(OpportunityLineItem.SObjectType);
        mocks.when(
                opportunityLineItemsSelectorMock.getOpportunityProductsCountFilteredAndGroupedByOpportunityIdsAndProductFamilies(
                    new Set<Id>{ mockOpportunityId }
                )
            )
            .thenReturn(new List<Aggregate>{ mockAggregateDrivePromotion });
        mocks.when(mockWorkOrdersService.collectOpportunitiesWithoutWorkOrder(mockOpportunities))
            .thenReturn(mockOpportunities);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(opportunityLineItemsSelectorMock);
        Application.SERVICE.setMock(IWorkOrdersService.class, mockWorkOrdersService);
        Test.startTest();
        List<Opportunity> opportunitiesWithError = OpportunitiesService.collectOpportunitiesWithoutWorkOrderInContractingStage(
            mockOpportunities
        );
        Test.stopTest();
        System.assertEquals(
            0,
            opportunitiesWithError.size(),
            CONTRACTING_OPPORTUNITIES_ERROR_ASSERT_MESSAGE
        );
    }

    /**
     * @description Verifies that Opportunities do not bypass Contracting Work Order validation by going straight to Closed Won.
     **/
    @IsTest
    private static void testWhenStageChangedToClosedWonThenRestrictUpdateOnOpportunityWithoutWorkOrder() {
        Id mockOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        List<Opportunity> mockOpportunities = new List<Opportunity>{
            new Opportunity(Id = mockOpportunityId, StageName = OPPORTUNITY_STAGE_CLOSED_WON)
        };

        Aggregate mockAggregateMarketplace = new Aggregate();
        mockAggregateMarketplace.put(AGGREGATE_OPPORTUNITY_ID_FIELD_ALIAS, mockOpportunityId);
        mockAggregateMarketplace.put(
            AGGREGATE_OPPORTUNITY_PRODUCT_FAMILY_FIELD_ALIAS,
            MARKETPLACE_PRODUCT_FAMILY
        );
        Aggregate mockAggregateAdvertisement = new Aggregate();
        mockAggregateAdvertisement.put(AGGREGATE_OPPORTUNITY_ID_FIELD_ALIAS, mockOpportunityId);
        mockAggregateAdvertisement.put(
            AGGREGATE_OPPORTUNITY_PRODUCT_FAMILY_FIELD_ALIAS,
            ADS_AND_PROMOS_PRODUCT_FAMILY_ADVERTISEMENT
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersService mockWorkOrdersService = (IWorkOrdersService) mocks.mock(
            IWorkOrdersService.class
        );
        IOpportunityLineItemsSelector opportunityLineItemsSelectorMock = (IOpportunityLineItemsSelector) mocks.mock(
            IOpportunityLineItemsSelector.class
        );

        mocks.startStubbing();
        mocks.when(opportunityLineItemsSelectorMock.sObjectType())
            .thenReturn(OpportunityLineItem.SObjectType);
        mocks.when(
                opportunityLineItemsSelectorMock.getOpportunityProductsCountFilteredAndGroupedByOpportunityIdsAndProductFamilies(
                    new Set<Id>{ mockOpportunityId }
                )
            )
            .thenReturn(
                new List<Aggregate>{ mockAggregateMarketplace, mockAggregateAdvertisement }
            );
        mocks.when(mockWorkOrdersService.collectOpportunitiesWithoutWorkOrder(mockOpportunities))
            .thenReturn(mockOpportunities);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(opportunityLineItemsSelectorMock);
        Application.SERVICE.setMock(IWorkOrdersService.class, mockWorkOrdersService);

        Test.startTest();
        List<Opportunity> oppsWithoutWorkOrder = OpportunitiesService.collectOpportunitiesWithoutWorkOrderInContractingStage(
            mockOpportunities
        );
        Test.stopTest();

        System.assertEquals(
            oppsWithoutWorkOrder,
            mockOpportunities,
            CONTRACTING_STAGENAME_ERROR_ASSERT_MESSAGE
        );
    }

    /**
     * @description This method validates scenarios where Opportunities Stage is changed to ClosedLost
     * based on value of Franchise Amendent process field on Quote.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenFranchiseAmendOnQuoteThenOpportunityStageChangestoClosedLost() {
        List<Account> accountList = new List<Account>{
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 1')
        };

        Id opportunityRecordId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id quoteId = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType);
        Id orderId = fflib_IDGenerator.generate(Order.SObjectType);
        Fake quoteFakeInstance = new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id, quoteId)
            .setField(SBQQ__Quote__c.SBQQ__Opportunity2__c, opportunityRecordId)
            .setField(SBQQ__Quote__c.SBQQ__Primary__c, 'true')
            .setField(SBQQ__Quote__c.Opt_In_Opt_Out_Decision__c, 'Opt-In')
            .setField(SBQQ__Quote__c.Opt_In_Opt_Out_Response_Time_in_Days__c, '2')
            .setField(SBQQ__Quote__c.Opt_Out_Save_Period_days__c, '1')
            .setField(SBQQ__Quote__c.Opt_In_Out_Responsible_Party__c, 'Merchant');
        SBQQ__Quote__c quote1 = (SBQQ__Quote__c) quoteFakeInstance.toSObject();
        Fake orderFakeInstance = new Fake(Order.class)
            .setField(Order.Id, orderId)
            .setField(Order.SBQQ__Quote__c, quoteId)
            .setField(Order.AccountId, accountList[0].Id)
            .setParent('SBQQ__Quote__r', quoteFakeInstance)
            .setFakeId();
        Fake contractFakeInstance = new Fake(Contract.class)
            .setField(Contract.AccountId, accountList[0].Id)
            .setField(Contract.CurrencyIsoCode, 'USD - U.S. Dollar')
            .setField(Contract.Status, 'Activated')
            .setField(Contract.SBQQ__Opportunity__c, opportunityRecordId)
            .setField(Contract.SBQQ__Order__c, orderId)
            .setParent('SBQQ__Order__r', orderFakeInstance)
            .setFakeId();
        Contract contract = (Contract) contractFakeInstance.toSObject();
        Opportunity opportunityRecord1 = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityRecordId)
            .setField(Opportunity.Name, 'Test opportunity 1')
            .setField(Opportunity.AccountId, accountList[0].Id)
            .setField(Opportunity.ContractId, contract.Id)
            .setField(Opportunity.Nintex_Use_Case__c, 'Rate Change')
            .setField(Opportunity.createdDate, System.today().addDays(-370))
            .setField(Opportunity.Nintex_Signed_Date__c, null)
            .setParent('Contract', contractFakeInstance)
            .toSObject();
        List<Opportunity> opportunityList = new List<Opportunity>{ opportunityRecord1 };
        Set<Id> opportunityIds = new Set<Id>{ opportunityRecord1.Id };
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>{ quote1 };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        OpportunitiesSelector opportunitiesSelectorMock = (OpportunitiesSelector) mocks.mock(
            OpportunitiesSelector.class
        );
        QuotesSelector quotesSelectorMock = (QuotesSelector) mocks.mock(QuotesSelector.class);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(opportunitiesSelectorMock.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(opportunitiesSelectorMock.selectOpportunitiesWithNintexUseCase(opportunityIds))
            .thenReturn(opportunityList);
        mocks.when(quotesSelectorMock.sObjectType()).thenReturn(SBQQ__Quote__c.SObjectType);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(opportunitiesSelectorMock);
        Application.SELECTOR.setMock(quotesSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        Map<Id, SBQQ__Quote__c> quoteMap = new Map<Id, SBQQ__Quote__c>();
        for (SBQQ__Quote__c eachQuote : quoteList) {
            quoteMap.put(eachQuote.SBQQ__Opportunity2__c, eachQuote);
        }
        OpportunitiesService.updateStageToClosedByFranchiseAmendmentProcessByChangeEvent(
            opportunityIds,
            true
        );
        System.assertEquals(
            'Closed Lost',
            opportunityList[0].StageName,
            'Mismatch in Opportunity Stage Name'
        );
    }

    /**
     * @description This method validates scenarios where Opportunities Type is changed to Rescue
     * based on value of Franchise Amendent process field on Quote
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenFranchiseAmendOnQuoteThenOpportunityTypeChangestoRescue() {
        List<Account> accountList = new List<Account>{
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 1')
        };
        Id opportunityRecordId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id quoteId = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType);
        Id orderId = fflib_IDGenerator.generate(Order.SObjectType);
        Fake quoteFakeInstance = new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id, quoteId)
            .setField(SBQQ__Quote__c.SBQQ__Opportunity2__c, opportunityRecordId)
            .setField(SBQQ__Quote__c.SBQQ__Primary__c, 'true')
            .setField(SBQQ__Quote__c.Opt_In_Opt_Out_Decision__c, 'Opt-Out')
            .setField(SBQQ__Quote__c.Opt_In_Opt_Out_Response_Time_in_Days__c, '14')
            .setField(SBQQ__Quote__c.Opt_Out_Save_Period_days__c, '1')
            .setField(SBQQ__Quote__c.Opt_In_Out_Responsible_Party__c, 'DoorDash');
        SBQQ__Quote__c quote1 = (SBQQ__Quote__c) quoteFakeInstance.toSObject();
        Fake orderFakeInstance = new Fake(Order.class)
            .setField(Order.Id, orderId)
            .setField(Order.SBQQ__Quote__c, quoteId)
            .setField(Order.AccountId, accountList[0].Id)
            .setParent('SBQQ__Quote__r', quoteFakeInstance)
            .setFakeId();
        Fake contractFakeInstance = new Fake(Contract.class)
            .setField(Contract.AccountId, accountList[0].Id)
            .setField(Contract.CurrencyIsoCode, 'USD - U.S. Dollar')
            .setField(Contract.Status, 'Activated')
            .setField(Contract.SBQQ__Opportunity__c, opportunityRecordId)
            .setField(Contract.SBQQ__Order__c, orderId)
            .setParent('SBQQ__Order__r', orderFakeInstance)
            .setFakeId();
        Contract contract = (Contract) contractFakeInstance.toSObject();
        Opportunity opportunityRecord1 = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityRecordId)
            .setField(Opportunity.Name, 'Test opportunity 1')
            .setField(Opportunity.AccountId, accountList[0].Id)
            .setField(Opportunity.ContractId, contract.Id)
            .setField(Opportunity.Nintex_Use_Case__c, 'Rate Change')
            .setField(Opportunity.createdDate, System.today().addDays(-1))
            .setField(Opportunity.CloseDate, System.today().addDays(-1))
            .setField(Opportunity.Nintex_Signed_Date__c, System.today().addDays(-1))
            .setField(Opportunity.Opt_Out_Save_Period__c, 5)
            .setParent('Contract', contractFakeInstance)
            .toSObject();
        List<Opportunity> opportunityList = new List<Opportunity>{ opportunityRecord1 };
        Set<Id> opportunityIds = new Set<Id>{ opportunityRecord1.Id };
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>{ quote1 };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        OpportunitiesSelector opportunitiesSelectorMock = (OpportunitiesSelector) mocks.mock(
            OpportunitiesSelector.class
        );
        QuotesSelector quotesSelectorMock = (QuotesSelector) mocks.mock(QuotesSelector.class);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(opportunitiesSelectorMock.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(opportunitiesSelectorMock.selectOpportunitiesWithNintexUseCase(opportunityIds))
            .thenReturn(opportunityList);
        mocks.when(quotesSelectorMock.sObjectType()).thenReturn(SBQQ__Quote__c.SObjectType);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(opportunitiesSelectorMock);
        Application.SELECTOR.setMock(quotesSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        Map<Id, SBQQ__Quote__c> quoteMap = new Map<Id, SBQQ__Quote__c>();
        for (SBQQ__Quote__c eachQuote : quoteList) {
            quoteMap.put(eachQuote.SBQQ__Opportunity2__c, eachQuote);
        }
        OpportunitiesService.updateStageToClosedByFranchiseAmendmentProcessByChangeEvent(
            opportunityIds,
            true
        );
        System.assertEquals(
            'Rescue',
            opportunityList[0].Type,
            'Mismatch in Opportunity Stage Name'
        );
    }

    /**
     * @description To test corporate Opportunity Stage change to Contracting when
     * it has associated Work Order then no error displayed.
     */
    @isTest
    private static void testWhenOpportunityHasWorkOrderThenNoErrorMessageDisplayed() {
        Id mockOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        List<Opportunity> mockOpportunities = new List<Opportunity>{
            new Opportunity(Id = mockOpportunityId, StageName = STAGENAME_CONTRACTING)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersService mockWorkOrdersService = (IWorkOrdersService) mocks.mock(
            IWorkOrdersService.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersService.collectOpportunitiesWithoutWorkOrder(mockOpportunities))
            .thenReturn(new List<Opportunity>{});
        mocks.stopStubbing();
        Application.SERVICE.setMock(IWorkOrdersService.class, mockWorkOrdersService);
        Test.startTest();
        List<Opportunity> opportunitiesWithError = OpportunitiesService.collectOpportunitiesWithoutWorkOrderInContractingStage(
            mockOpportunities
        );
        Test.stopTest();
        System.assertEquals(
            0,
            opportunitiesWithError.size(),
            CONTRACTING_OPPORTUNITIES_ERROR_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test Opportunity with source as Nintex moves to Contracting Stage without
     * an associated Work Order then no error displayed.
     */
    @isTest
    private static void testWhenNintexOpportunityInContractingStageWithoutWorkOrderThenNoErrorMessageDisplayed() {
        Id mockOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        List<Opportunity> mockOpportunities = new List<Opportunity>{
            new Opportunity(
                Id = mockOpportunityId,
                StageName = STAGENAME_CONTRACTING,
                Source__c = SOURCE_NINTEX
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersService mockWorkOrdersService = (IWorkOrdersService) mocks.mock(
            IWorkOrdersService.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersService.collectOpportunitiesWithoutWorkOrder(mockOpportunities))
            .thenReturn(mockOpportunities);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IWorkOrdersService.class, mockWorkOrdersService);
        Test.startTest();
        List<Opportunity> nintexOpportunitiesWithError = OpportunitiesService.collectOpportunitiesWithoutWorkOrderInContractingStage(
            mockOpportunities
        );
        Test.stopTest();
        ((IWorkOrdersService) mocks.verify(mockWorkOrdersService, 0))
            .collectOpportunitiesWithoutWorkOrder(mockOpportunities);
        System.assertEquals(
            0,
            nintexOpportunitiesWithError.size(),
            CONTRACTING_OPPORTUNITIES_ERROR_ASSERT_MESSAGE
        );
    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOpportunitiesReceivedThenAssociatedBrandRelationshipsAreFetched() {
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id brandId = fflib_IDGenerator.generate(Brand__c.SObjectType);
        Id relationshipId = fflib_IDGenerator.generate(
            Opportunity_Brand_Relationship__c.SObjectType
        );
        List<Opportunity_Brand_Relationship__c> relationshipList = new List<Opportunity_Brand_Relationship__c>{
            new Opportunity_Brand_Relationship__c(
                Id = relationshipId,
                Brand__c = brandId,
                Opportunity__c = opportunityId
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        OpportunityBrandRelationshipsSelector opportunityRelationshipsSelectorMock = (OpportunityBrandRelationshipsSelector) mocks.mock(
            OpportunityBrandRelationshipsSelector.class
        );
        mocks.startStubbing();
        mocks.when(opportunityRelationshipsSelectorMock.sObjectType())
            .thenReturn(Opportunity_Brand_Relationship__c.SObjectType);
        mocks.when(
                opportunityRelationshipsSelectorMock.selectByOpportunity(
                    new Set<Id>{ opportunityId }
                )
            )
            .thenReturn(relationshipList);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(opportunityRelationshipsSelectorMock);
        Test.startTest();
        Set<Id> opportunitiesWithBrandRelationships = OpportunitiesService.getOpportunitiesWithOpportunityBrandRelationships(
            new List<Opportunity>{ new Opportunity(Id = opportunityId) }
        );
        Test.stopTest();

        System.assertEquals(
            1,
            opportunitiesWithBrandRelationships.size(),
            OPPORTUNITIES_WITH_RELATIONSHIPS_ERROR_ASSERT_MESSAGE
        );
    }

    /**
     * @description To validate Opportunities with Nintex Id are collected and
     * parent Work Order creation process is initiated.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOpportunityIdsReceivedThenParentWorkOrderCreationInitiated() {
        Id opportunityWithNoNintexSubmissionId = fflib_IDGenerator.generate(
            Opportunity.SObjectType
        );
        Id opportunityWithMarketplaceNintexSubmissionId = fflib_IDGenerator.generate(
            Opportunity.SObjectType
        );
        Id opportunityWithDriveNintexSubmissionId = fflib_IDGenerator.generate(
            Opportunity.SObjectType
        );
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake opportunityWithNoNintexIdFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityWithNoNintexSubmissionId)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.AccountId, parentBusinessAccount.Id)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_PROSPECTING)
            .setField(Opportunity.Source__c, OPPORTUNITY_SOURCE);
        Opportunity opportunityWithNoNintexId = (Opportunity) opportunityWithNoNintexIdFakeInstance.toSObject();
        Fake opportunityWithMarketplaceNintexIdFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityWithMarketplaceNintexSubmissionId)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.Marketplace_Nintex_Id__c, OPPORTUNITY_MARKETPLACE_NINTEX_ID)
            .setField(Opportunity.AccountId, parentBusinessAccount.Id)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_PROSPECTING)
            .setField(Opportunity.Source__c, OPPORTUNITY_SOURCE)
            .setField(Opportunity.Nintex_Use_Case__c, NINTEX_USE_CASE_NEW_FRANCHISE);
        Opportunity opportunityWithMarketplaceNintexId = (Opportunity) opportunityWithMarketplaceNintexIdFakeInstance.toSObject();
        Fake opportunityWithDriveNintexIdFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityWithDriveNintexSubmissionId)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.Drive_Nintex_Id__c, OPPORTUNITY_DRIVE_NINTEX_ID)
            .setField(Opportunity.AccountId, parentBusinessAccount.Id)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_PROSPECTING)
            .setField(Opportunity.Source__c, OPPORTUNITY_SOURCE)
            .setField(Opportunity.Nintex_Use_Case__c, NINTEX_USE_CASE_DRIVE_FORM);
        Opportunity opportunityWithDriveNintexId = (Opportunity) opportunityWithDriveNintexIdFakeInstance.toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunitiesSelector mockOpportunitiesSelector = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );
        IParentWorkOrdersCreationService parentWorkOrdersCreationServiceMock = (IParentWorkOrdersCreationService) mocks.mock(
            IParentWorkOrdersCreationService.class
        );
        mocks.startStubbing();
        mocks.when(mockOpportunitiesSelector.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(
                mockOpportunitiesSelector.selectOpportunitiesWithNintexIdById(
                    new Set<Id>{
                        opportunityWithNoNintexId.Id,
                        opportunityWithMarketplaceNintexId.Id,
                        opportunityWithDriveNintexId.Id
                    }
                )
            )
            .thenReturn(
                new List<Opportunity>{
                    opportunityWithDriveNintexId,
                    opportunityWithMarketplaceNintexId
                }
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockOpportunitiesSelector);
        Application.SERVICE.setMock(
            IParentWorkOrdersCreationService.class,
            parentWorkOrdersCreationServiceMock
        );
        OpportunitiesService.initiateParentWorkOrdersCreation(
            new Set<Id>{
                opportunityWithNoNintexId.Id,
                opportunityWithMarketplaceNintexId.Id,
                opportunityWithDriveNintexId.Id
            }
        );
        ((IParentWorkOrdersCreationService) mocks.verify(parentWorkOrdersCreationServiceMock, 1))
            .createParentWorkOrdersByNintexUseCases(
                new List<Opportunity>{
                    opportunityWithDriveNintexId,
                    opportunityWithMarketplaceNintexId
                }
            );
    }

    /**
     * @description Tests when Opportunities are provided then IsParentAccountMerged field set to True.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenOpportunitiesAreProvidedThenIsParentAccountMergedFieldSetToTrue() {
        Opportunity opportunity1 = (Opportunity) new Fake(Opportunity.class)
            .setFakeId()
            .setField(Opportunity.Is_Parent_Account_Merged__c, false)
            .toSObject();

        Opportunity opportunity2 = (Opportunity) new Fake(Opportunity.class)
            .setFakeId()
            .setField(Opportunity.Is_Parent_Account_Merged__c, false)
            .toSObject();

        List<Opportunity> opportunities = new List<Opportunity>{ opportunity1, opportunity2 };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        OpportunitiesService.processMergedAccountsRelatedRecords(opportunities);

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2))
            .registerDirty(fflib_Match.anySObject());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Opportunity.Id => opportunity1.Id,
                        Opportunity.Is_Parent_Account_Merged__c => true
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Opportunity.Id => opportunity2.Id,
                        Opportunity.Is_Parent_Account_Merged__c => true
                    }
                )
            );
    }

    /**
     * @description Tests when Opportunities are provided then Estimated Total Investment is
     * updated.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenOpportunitiesAreProvidedThenEstimatedTotalInvestmentIsUpdated() {
        Opportunity opportunity1 = (Opportunity) new Fake(Opportunity.class)
            .setFakeId()
            .setField(Opportunity.Estimated_Total_Investment__c, 0)
            .toSObject();

        Opportunity opportunity2 = (Opportunity) new Fake(Opportunity.class)
            .setFakeId()
            .setField(Opportunity.Estimated_Total_Investment__c, 4)
            .toSObject();

        Map<Id, Decimal> updatedOpportunities = new Map<Id, Decimal>{
            opportunity1.Id => 5,
            opportunity2.Id => 10
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IOpportunitiesSelector mockOpportunitiesSelector = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockOpportunitiesSelector.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(
                mockOpportunitiesSelector.selectById(
                    new Set<Id>{ opportunity1.Id, opportunity2.Id }
                )
            )
            .thenReturn(new List<Opportunity>{ opportunity1, opportunity2 });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockOpportunitiesSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        OpportunitiesService.updateEstimatedTotalInvestmentOnOpportunity(updatedOpportunities);

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2))
            .registerDirty(fflib_Match.anySObject());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Opportunity.Id => opportunity1.Id,
                        Opportunity.Estimated_Total_Investment__c => 5
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Opportunity.Id => opportunity2.Id,
                        Opportunity.Estimated_Total_Investment__c => 10
                    }
                )
            );
    }

    /**
     * @description To validate when Quote's status changed to 'Out for Signature' then associated Opportunity's status changed to 'Contracting'.
     * @JIRA# LEM-14174
     */

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenQuoteStatusOutForSignatureThenOpportunityStageChangedToContracting() {
        Id mockOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);

        Opportunity mockOpportunity = new Opportunity(
            Id = mockOpportunityId,
            StageName = STAGENAME_CONTRACTING
        );
        Map<Id, String> mockOpportunityIdToStageName = new Map<Id, String>{
            mockOpportunityId => STAGENAME_CONTRACTING
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        IOpportunitiesSelector mockOpportunitiesSelector = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockOpportunitiesSelector.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(mockOpportunitiesSelector.selectById(new Set<Id>{ mockOpportunityId }))
            .thenReturn(new List<Opportunity>{ mockOpportunity });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(mockOpportunitiesSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        OpportunitiesService.updateOpportunityStageByQuoteStatus(mockOpportunityIdToStageName);
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(fflib_Match.anySObject());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Opportunity.Id => mockOpportunityId,
                        Opportunity.StageName => STAGENAME_CONTRACTING
                    }
                )
            );
    }
    /**
     * @description To validate when Quote's status changed to 'Contract Signed' then associated Opportunity's status changed to 'Closed Won'.
     * @JIRA# LEM-14174
     */

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenQuoteStatusContractSignedThenOpportunityStageChangedToContracted() {
        Id mockOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);

        Opportunity mockOpportunity = new Opportunity(
            Id = mockOpportunityId,
            StageName = OPPORTUNITY_STAGE_CLOSED_WON
        );
        Map<Id, String> mockOpportunityIdToStageName = new Map<Id, String>{
            mockOpportunityId => OPPORTUNITY_STAGE_CLOSED_WON
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        IOpportunitiesSelector mockOpportunitiesSelector = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockOpportunitiesSelector.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(mockOpportunitiesSelector.selectById(new Set<Id>{ mockOpportunityId }))
            .thenReturn(new List<Opportunity>{ mockOpportunity });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(mockOpportunitiesSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        OpportunitiesService.updateOpportunityStageByQuoteStatus(mockOpportunityIdToStageName);
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(fflib_Match.anySObject());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Opportunity.Id => mockOpportunityId,
                        Opportunity.StageName => OPPORTUNITY_STAGE_CLOSED_WON
                    }
                )
            );
    }

    /**
     * @description To validate when Quote is Contract Signed, value of the Quote field ‘Number of Stores’ is be stamped on the 'Estimated # of Stores’ field of Opportunity.
     * @JIRA# LEM-14946
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenQuoteNumberOfStoresIsPresentThenPopulateOpportunityNumberOfstores() {
        Id mockOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);

        Opportunity mockOpportunity = new Opportunity(
            Id = mockOpportunityId,
            Estimated_Number_of_Stores__c = QUOTE_NUMBER_OF_STORES
        );
        Map<Id, Decimal> mockOpportunityIdToStageName = new Map<Id, Decimal>{
            mockOpportunityId => QUOTE_NUMBER_OF_STORES
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        IOpportunitiesSelector mockOpportunitiesSelector = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockOpportunitiesSelector.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(mockOpportunitiesSelector.selectById(new Set<Id>{ mockOpportunityId }))
            .thenReturn(new List<Opportunity>{ mockOpportunity });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(mockOpportunitiesSelector);
        Test.startTest();
        Application.UNITOFWORK.setMock(mockUOW);
        OpportunitiesService.updateOpportunityNoOfStoresByQuoteNoOfStores(
            mockOpportunityIdToStageName
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(fflib_Match.anySObject());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Opportunity.Id => mockOpportunityId,
                        Opportunity.Estimated_Number_of_Stores__c => Quote_Number_OF_STORES
                    }
                )
            );
    }

    /**
     * @description To validate when Quote's status different from 'Out for Signature' and 'Contract Signed' then associated Opportunity's status is not changed.
     * @JIRA# LEM-14174
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenQuoteStatusProspectingThenOpportunityStageNotChanged() {
        Id mockOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);

        Opportunity mockOpportunity = new Opportunity(
            Id = mockOpportunityId,
            StageName = OPPORTUNITY_STAGE_PROSPECTING
        );
        Map<Id, String> mockOpportunityIdToStageName = new Map<Id, String>{
            mockOpportunityId => OPPORTUNITY_STAGE_PROSPECTING
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        IOpportunitiesSelector mockOpportunitiesSelector = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockOpportunitiesSelector.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(mockOpportunitiesSelector.selectById(new Set<Id>{ mockOpportunityId }))
            .thenReturn(new List<Opportunity>{ mockOpportunity });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(mockOpportunitiesSelector);
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        OpportunitiesService.updateOpportunityStageByQuoteStatus(mockOpportunityIdToStageName);
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(fflib_Match.anySObject());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Opportunity.Id => mockOpportunityId,
                        Opportunity.StageName => OPPORTUNITY_STAGE_PROSPECTING
                    }
                )
            );
    }

    /**
     * @description To test ‘Stores Association In Progress’ banner indicator toggled on parent
     * Work Order when Closed Won Opportunities with 'Rate Change' Nintex Use Case are received.
     * Suppressed Warnings since mock verify method is equivalent of system assert statement.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOpportunityIdsReceivedThenBannerIndicatorToggledOnParentWorkOrder() {
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake opportunityFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.Drive_Nintex_Id__c, OPPORTUNITY_DRIVE_NINTEX_ID)
            .setField(Opportunity.AccountId, parentBusinessAccount.Id)
            .setField(Opportunity.IsClosed, true)
            .setField(Opportunity.IsWon, true)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_CLOSED_WON)
            .setField(Opportunity.Source__c, OPPORTUNITY_SOURCE)
            .setField(Opportunity.Nintex_Use_Case__c, OPPORTUNITY_NINTEX_USE_CASE_RATE_CHANGE);
        Opportunity parentOpportunity = (Opportunity) opportunityFakeInstance.toSObject();
        WorkOrder parentWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.IsStoresAssociationInProgress__c, false)
            .setField(WorkOrder.Type__c, WORK_ORDER_TYPE_MARKETPLACE)
            .setParent('Account', parentBusinessAccountFakeInstance)
            .setParent('Opportunity__r', opportunityFakeInstance)
            .setField(WorkOrder.Opportunity__c, parentOpportunity.Id)
            .setFakeId()
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );
        IOpportunitiesSelector mockOpportunitiesSelector = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockOpportunitiesSelector.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(mockOpportunitiesSelector.selectById(new Set<Id>{ opportunityId }))
            .thenReturn(new List<Opportunity>{ parentOpportunity });
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByOpportunityIds(
                    new Set<Id>{ opportunityId }
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.when(mockWorkOrdersSelector.selectById(new Set<Id>{ parentWorkOrder.Id }))
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockOpportunitiesSelector);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.UNITOFWORK.setMock(uowMock);
        OpportunitiesService.activateBannerOnClosedWonRateChangeOpportunities(
            new Set<Id>{ opportunityId }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkOrder.Id => parentWorkOrder.Id,
                        WorkOrder.IsStoresAssociationInProgress__c => true
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
    }

    /**
     * @description To test initiation of child Work Orders creation when Closed Won Opportunities
     * with 'Rate Change' Nintex Use Case are received.
     * Suppressed Warnings since mock verify method is equivalent of system assert statement.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOpportunityIdsReceivedThenChildWorkOrderCreationInitiated() {
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake opportunityFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.Drive_Nintex_Id__c, OPPORTUNITY_DRIVE_NINTEX_ID)
            .setField(Opportunity.AccountId, parentBusinessAccount.Id)
            .setField(Opportunity.IsClosed, true)
            .setField(Opportunity.IsWon, true)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_CLOSED_WON)
            .setField(Opportunity.Source__c, OPPORTUNITY_SOURCE)
            .setField(Opportunity.Nintex_Use_Case__c, OPPORTUNITY_NINTEX_USE_CASE_RATE_CHANGE);
        Opportunity parentOpportunity = (Opportunity) opportunityFakeInstance.toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunitiesSelector mockOpportunitiesSelector = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );
        INintexWorkOrdersProcessorService nintexWorkOrderProcessServiceMock = (INintexWorkOrdersProcessorService) mocks.mock(
            INintexWorkOrdersProcessorService.class
        );
        mocks.startStubbing();
        mocks.when(mockOpportunitiesSelector.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(mockOpportunitiesSelector.selectById(new Set<Id>{ opportunityId }))
            .thenReturn(new List<Opportunity>{ parentOpportunity });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockOpportunitiesSelector);
        Application.SERVICE.setMock(
            INintexWorkOrdersProcessorService.class,
            nintexWorkOrderProcessServiceMock
        );
        OpportunitiesService.initiateChildWorkOrdersCreationByNintexUseCase(
            new Set<Id>{ opportunityId }
        );
        ((IOpportunitiesSelector) mocks.verify(mockOpportunitiesSelector, 1))
            .selectById(new Set<Id>{ opportunityId });
    }

    /**
     * @description Tests if Opportunities of Negotiating stage are created with owner as contract corporate account owner when set of franchise Account Ids are provided.
     * Suppressed Warnings since mock verify method is equivalent of System.assert statement.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenFranchiseAccountsAreProvidedThenCreateOpportunitiesWithOwnerIdAsContractCorporateAccountOwner() {
        List<String> franchiseAccountIds = new List<String>{
            fflib_IDGenerator.generate(Account.SObjectType),
            fflib_IDGenerator.generate(Account.SObjectType)
        };

        Id corporateAccountOwnerId = fflib_IDGenerator.generate(User.SObjectType);
        Id corporateAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        String closedDateForOpportunities = '90';

        List<Account> franchiseAccounts = new List<Account>{
            new Account(
                Id = franchiseAccountIds[0],
                Name = 'Parent 1',
                Legal_Business_Name__c = 'Legal Parent 1'
            ),
            new Account(
                Id = franchiseAccountIds[1],
                Name = 'Parent 2',
                Legal_Business_Name__c = 'Legal Parent 2'
            )
        };

        Contract mockContract = (Contract) new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.AccountId, corporateAccountId)
            .setParent(
                'Account',
                new Fake(Account.class)
                    .setField(Account.Id, corporateAccountId)
                    .setField(Account.OwnerId, corporateAccountOwnerId)
            )
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        IContractsSelector contractsSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        IAccountTeamMembersSelector accountTeamMemberSelectorMock = (IAccountTeamMembersSelector) mocks.mock(
            IAccountTeamMembersSelector.class
        );

        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                selectorMock.selectById(
                    new Set<Id>{ franchiseAccountIds[0], franchiseAccountIds[1] }
                )
            )
            .thenReturn(franchiseAccounts);
        mocks.when(selectorMock.selectById(new Set<String>(franchiseAccountIds)))
            .thenReturn(franchiseAccounts);
        mocks.when(contractsSelectorMock.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(contractsSelectorMock.selectById(new Set<Id>{ contractId }))
            .thenReturn(new List<Contract>{ mockContract });
        mocks.when(accountTeamMemberSelectorMock.sObjectType())
            .thenReturn(AccountTeamMember.SObjectType);
        mocks.when(
                accountTeamMemberSelectorMock.selectFranchiseRepRoleAccountTeamMembersByAccountId(
                    corporateAccountId
                )
            )
            .thenReturn(new List<AccountTeamMember>{});
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        Application.SELECTOR.setMock(contractsSelectorMock);
        Application.SELECTOR.setMock(accountTeamMemberSelectorMock);

        Application.UNITOFWORK.setMock(mockUOW);
        OpportunitiesService.createOpportunitiesOnFranchiseAccounts(
            franchiseAccountIds,
            contractId,
            USE_CASE,
            closedDateForOpportunities
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Opportunity.AccountId => franchiseAccountIds[0],
                        Opportunity.Name => 'Legal Parent 1',
                        Opportunity.CloseDate => Date.today().addDays(90),
                        Opportunity.Opportunity_Sub_Type__c => 'Upgrade',
                        Opportunity.StageName => 'Negotiating',
                        Opportunity.Type => 'Existing',
                        Opportunity.Source__c => 'Nintex',
                        Opportunity.Nintex_Use_Case__c => USE_CASE,
                        Opportunity.Deal_Type__c => 'Standard',
                        Opportunity.ContractId => contractId,
                        Opportunity.OwnerId => corporateAccountOwnerId
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Opportunity.AccountId => franchiseAccountIds[1],
                        Opportunity.CloseDate => Date.today().addDays(90),
                        Opportunity.Name => 'Legal Parent 2',
                        Opportunity.Opportunity_Sub_Type__c => 'Upgrade',
                        Opportunity.StageName => 'Negotiating',
                        Opportunity.Type => 'Existing',
                        Opportunity.Source__c => 'Nintex',
                        Opportunity.Nintex_Use_Case__c => USE_CASE,
                        Opportunity.Deal_Type__c => 'Standard',
                        Opportunity.ContractId => contractId,
                        Opportunity.OwnerId => corporateAccountOwnerId
                    }
                )
            );
    }
    /**
     * @description this method tests mapping opp Id to list of briefs
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenBriefsArePassedThenGroupTheBriefsByTheirOpportunities() {
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id briefId = fflib_IDGenerator.generate(Brief__c.SObjectType);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );

        Fake opportunityFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.AccountId, parentBusinessAccount.Id)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_CLOSED_WON)
            .setField(Opportunity.Source__c, OPPORTUNITY_SOURCE)
            .setField(Opportunity.Deal_Type__c, 'Standard');
        List<Brief__c> briefsList = new List<Brief__c>{
            (Brief__c) new Fake(Brief__c.class)
                .setField(Brief__c.Id, briefId)
                .setField(Brief__c.Opportunity_Name__c, opportunityId)
                .setField(Brief__c.Is_Created_By_System__c, true)
                .setField(Brief__c.CampaignName__c, 'Campaign Name')
                .setField(Brief__c.Additional_Notes__c, 'Additional Notes')
                .setField(Brief__c.Opportunity_Owner__c, UserInfo.getUserId())
                .setField(Brief__c.Netsuite_ID__c, 'NetSuite ID')
                .setField(Brief__c.Applicable_DoorDash_Order_Types__c, 'Delivery')
                .setField(Brief__c.Configuration__c, 'Standard (Mx Services)')
                .setParent('Opportunity_Name__r', opportunityFakeInstance)
                .toSObject()
        };
        List<Opportunity> oppList = new List<Opportunity>();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBriefsSelector mockBriefsSelector = (IBriefsSelector) mocks.mock(IBriefsSelector.class);
        IOpportunitiesSelector oppSelectorMock = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );

        //mocking
        mocks.startStubbing();
        mocks.when(mockBriefsSelector.sObjectType()).thenReturn(Brief__c.SObjectType);
        mocks.when(mockBriefsSelector.selectByOpportunities(new Set<Id>{ opportunityId }))
            .thenReturn(briefsList);
        mocks.when(oppSelectorMock.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(oppSelectorMock.selectById(new Set<Id>{ opportunityId })).thenReturn(oppList);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockBriefsSelector);
        Application.SELECTOR.setMock(oppSelectorMock);
        Brief__c brief = briefsList[0];
        List<Brief__c> briefsToMap = new List<Brief__c>{ brief };
        Map<Id, List<Brief__c>> mapOfOppIdToBriefs = new Map<Id, List<Brief__c>>();
        mapOfOppIdToBriefs = OpportunitiesService.mapOpportunityIdToListOfBrief(briefsToMap);
        OpportunitiesService.updateBriefsFromOpportunity(oppList, mapOfOppIdToBriefs);
    }
    /**
     * @description this method tests updating brief items from opportunity
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOpportunitiesArePassedThenUpdateTheBriefsItemsByTheirOpportunities() {
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id briefId = fflib_IDGenerator.generate(Brief__c.SObjectType);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Id marketplacePromotionQuoteLineItem = fflib_IDGenerator.generate(
            SBQQ__QuoteLine__c.SObjectType
        );
        Id contractSignedQuote = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType);

        Id briefItemId = fflib_IDGenerator.generate(Brief_Item__c.SObjectType);
        Fake parentQuoteLineInstane = new Fake(SBQQ__QuoteLine__c.class)
            .setField(SBQQ__QuoteLine__c.Id, marketplacePromotionQuoteLineItem)
            .setField(SBQQ__QuoteLine__c.SBQQ__Quote__c, contractSignedQuote)
            .setField(SBQQ__QuoteLine__c.Campaign_Name__c, 'Campaign Name')
            .setField(SBQQ__QuoteLine__c.Start_Date__c, System.today() - 1)
            .setField(SBQQ__QuoteLine__c.End_Date__c, System.today())
            .setField(SBQQ__QuoteLine__c.Marketing_Flat_Fee__c, 0)
            .setField(SBQQ__QuoteLine__c.SBQQ__ProductName__c, 'Sponsored Products')
            .setField(SBQQ__QuoteLine__c.Has_Brief_Item__c, true);

        Fake opportunityFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.AccountId, parentBusinessAccount.Id)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_CLOSED_WON)
            .setField(Opportunity.Source__c, OPPORTUNITY_SOURCE)
            .setField(Opportunity.Deal_Type__c, 'Standard');
        List<Brief_Item__c> briefItemsList = new List<Brief_Item__c>{
            (Brief_Item__c) new Fake(Brief_Item__c.class)
                .setField(Brief_Item__c.Id, briefItemId)
                .setField(Brief_Item__c.Brief__c, briefId)
                .setField(Brief_Item__c.Start_Date__c, System.today() - 4)
                .setField(Brief_Item__c.End_Date__c, System.today() + 1)
                .setField(Brief_Item__c.CurrencyIsoCode, 'USD')
                .setField(Brief_Item__c.Status__c, 'Waiting for Inputs')
                .setField(Brief_Item__c.Search_Bid__c, 5)
                .setField(Brief_Item__c.Quote_Line__c, marketplacePromotionQuoteLineItem)
                .setField(Brief_Item__c.Opportunity_ID__c, opportunityId)
                .setParent('Quote_Line__r', parentQuoteLineInstane)
                .setParent('Opportunity_ID__r', opportunityFakeInstance)
                .toSObject()
        };
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity parentOpportunity = (Opportunity) opportunityFakeInstance.toSobject();
        oppList.add(parentOpportunity);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBriefItemsSelector mockBriefItemsSelector = (IBriefItemsSelector) mocks.mock(
            IBriefItemsSelector.class
        );
        IOpportunitiesSelector oppSelectorMock = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );

        mocks.startStubbing();
        mocks.when(mockBriefItemsSelector.sObjectType()).thenReturn(Brief_Item__c.SObjectType);
        mocks.when(mockBriefItemsSelector.selectByOpportunities(new Set<Id>{ opportunityId }))
            .thenReturn(briefItemsList);
        mocks.when(oppSelectorMock.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(oppSelectorMock.selectById(new Set<Id>{ opportunityId })).thenReturn(oppList);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockBriefItemsSelector);
        Application.SELECTOR.setMock(oppSelectorMock);
        OpportunitiesService.updateBriefItemsFromOpportunity(oppList);
    }

    /**
     * @description It verifies if the OCR Primary contact field is updated on the Opportunity
     * when Opportunity Contact Roles are passed.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenIsPrimaryUpdatedOnOCRThenUpdatePrimaryContactOnOpportunity() {
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Map<Id, Id> opportunityToPrimaryContact = new Map<Id, Id>();
        opportunityToPrimaryContact.put(opportunityId, contactId);
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        OpportunitiesService.updatePrimaryOCRContactOnOpportunity(opportunityToPrimaryContact);
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Opportunity.Id => opportunityId,
                        Opportunity.Primary_Contact__c => contactId
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }
    /**
     * @description To test when list of accounts received then renewal opportunity created.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAccountIdsPassedThenCreateNewRenewalOpportunity() {
        Id ownerId = Fake.generateId(User.class);
        Account account1 = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Test Account 1 - Batch')
            .setField(Account.Partnership_Expiration_Date__c, '2024-08-14')
            .setField(Account.CurrencyIsoCode, 'USD')
            .setField(Account.Total_Number_Of_Active_Stores_Calculate__c, 1)
            .setField(Account.OwnerId, ownerId)
            .setField(Account.Partnership_Level__c, 'Exclusive')
            .setField(Account.Renewal_Opportunity__c, null)
            .setFakeId()
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsService serviceMock = (IAccountsService) mocks.mock(IAccountsService.class);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.SERVICE.setMock(IAccountsService.class, serviceMock);
        Application.UNITOFWORK.setMock(mockUOW);
        OpportunitiesService.createRenewalOpportunityFromBatch(new List<Account>{ account1 });
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());
    }

    /**
     * @description To test when empty list of accounts received then renewal opportunity not created.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenEmptyAccountIdsPassedThenRenewalOpportunityNotCreated() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        OpportunitiesService.createRenewalOpportunityFromBatch(new List<Account>{});
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }
}