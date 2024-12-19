/**
 * @author atg
 * @date 06/30/2022
 * @description Test class for BusReferenceIntegrationServiceImpl class.
 * Suppressed Warnings in this class since mock verify method does not require system assert statements.
 */
@isTest(seeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
public class BusReferenceIntegrationServiceImplTest {
    private static final String AGREEMENT_NAME = 'Test Agreement';
    private static final String AGREEMENT_STATUS_ACTIVE = 'Active';
    private static final String AGREEMENT_TYPE_FRANCHISE_AGREEMENT = 'Franchise Agreement';
    private static final String CORPORATE_ACCOUNT_IDS_CHUNK_SIZE_TO_PROCESS_DRIVE_WITHHOLDING = '1';
    private static final String CORPORATE_ACCOUNT_IDS_CHUNK_SIZE_TO_PROCESS_DRIVE_WITHHOLDING_STATIC_CONFIG = 'Corp_Acc_Size_To_ProcessDriveWithholding';
    private static final String EVENT_TOPIC_PROCESS_DRIVE_WITHHOLDING = 'PROCESS_DRIVE_WITHHOLDING';
    private static final String EXTERNAL_NOTIFIER_EVENT_EBID_INTEGRATION = 'EBID_INTEGRATE';
    private static final String EXTERNAL_ID_SOURCE_MDS = 'MDS';
    private static final String FRANCHISE_ACCOUNTS_WITHHOLDING_QUERY_LIMIT = '7500';
    private static final String FRANCHISE_ACCOUNTS_WITHHOLDING_QUERY_LIMIT_STATIC_CONFIG = 'Franchise_Acc_Withholding_Query_Limit';

    /**
     * @description To test when Business_Reference__c are being integrated.
     * External Notifier event with EBID_INTEGRATE topic and corresponding payload.
     */
    @isTest
    private static void testWhenCreateIntegrationPlatformEventsThenExternalNotifierEventPublishedWithPayload() {
        Id externalBusinessId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);
        Id userId = fflib_IDGenerator.generate(User.SObjectType);
        Datetime currentDateTime = DateTime.now();

        Business_Reference__c businessReference = new Business_Reference__c(
            Id = externalBusinessId,
            External_Id_Source__c = EXTERNAL_ID_SOURCE_MDS,
            CreatedById = userId,
            CreatedDate = currentDateTime
        );
        List<Business_Reference__c> businessReferenceList = new List<Business_Reference__c>{
            businessReference
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IExternalNotifierEventsService externalNotifierServiceMock = (IExternalNotifierEventsService) mocks.mock(
            IExternalNotifierEventsService.class
        );

        Application.SERVICE.setMock(
            IExternalNotifierEventsService.class,
            externalNotifierServiceMock
        );

        List<BusinessReferenceIntegration> businessReferenceIntegrationList = new List<BusinessReferenceIntegration>();
        businessReferenceIntegrationList.add(new BusinessReferenceIntegration(businessReference));
        String eventPayload = JSON.serialize(businessReferenceIntegrationList);

        BusReferenceIntegrationService.createIntegrationPlatformEvents(
            businessReferenceList,
            EXTERNAL_NOTIFIER_EVENT_EBID_INTEGRATION
        );

        ((IExternalNotifierEventsService) mocks.verify(externalNotifierServiceMock, 1))
            .publishEventsFromList(
                EXTERNAL_NOTIFIER_EVENT_EBID_INTEGRATION,
                new List<String>{ eventPayload }
            );
    }

    /**
     * @description To test when corporate Account Ids are passed then
     * Business Reference External Id is initiated.
     */
    @isTest
    private static void testWhenCorporateAccountIdsPassedThenExternalIdUpdateInitiated() {
        Id agreementId = fflib_IDGenerator.generate(Agreement__c.SObjectType);
        Id businessReferenceId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id corporateAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id franchiseAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Fake contractFakeInstance = new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.AccountId, corporateAccountId)
            .setField(Contract.MP_Bz_Id__c, '1234');
        Contract contractMock = (Contract) ServiceMockDataBuilder.convertToSObject(
            contractFakeInstance
        );
        Fake franchiseAgreementFakeInstance = new Fake(Agreement__c.class)
            .setField(Agreement__c.Id, agreementId)
            .setField(Agreement__c.Name, AGREEMENT_NAME)
            .setField(Agreement__c.Account__c, franchiseAccountId)
            .setField(Agreement__c.Contract__c, contractId)
            .setField(Agreement__c.Type__c, AGREEMENT_TYPE_FRANCHISE_AGREEMENT)
            .setField(Agreement__c.Status__c, AGREEMENT_STATUS_ACTIVE)
            .setParent('Contract__r', contractFakeInstance);
        Agreement__c franchiseAgreement = (Agreement__c) ServiceMockDataBuilder.convertToSObject(
            franchiseAgreementFakeInstance
        );
        Fake xrefFakeInstance = new Fake(Xref__c.class)
            .setField(Xref__c.Id, xrefId)
            .setField(Xref__c.Business_Reference__c, businessReferenceId)
            .setField(Xref__c.Salesforce_Account_Name__c, franchiseAccountId);
        Xref__c xrefMock = (Xref__c) ServiceMockDataBuilder.convertToSObject(xrefFakeInstance);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IAgreementsSelector agreementsSelectorMock = (IAgreementsSelector) mocks.mock(
            IAgreementsSelector.class
        );
        IContractsSelector contractsSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        IXrefsSelector xrefsSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IStaticConfigurationsSelector staticConfigurationsMock = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.selectById(new Set<Id>{ corporateAccountId }))
            .thenReturn(
                new List<Account>{
                    new Account(Id = corporateAccountId, Show_MP_Bz_Id_Update_Banner__c = false)
                }
            );
        mocks.when(contractsSelectorMock.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(
                contractsSelectorMock.selectActivatedWithholdingContractsByAccountIds(
                    new Set<Id>{ corporateAccountId }
                )
            )
            .thenReturn(new List<Contract>{ contractMock });
        mocks.when(agreementsSelectorMock.sObjectType()).thenReturn(Agreement__c.SObjectType);
        mocks.when(
                agreementsSelectorMock.selectWithholdingCorporateAccountsByActiveAgreements(
                    new Set<Id>{ corporateAccountId },
                    Integer.valueOf(FRANCHISE_ACCOUNTS_WITHHOLDING_QUERY_LIMIT)
                )
            )
            .thenReturn(new List<Agreement__c>{ franchiseAgreement });
        mocks.when(xrefsSelectorMock.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                xrefsSelectorMock.selectDriveDBXrefsBySalesforceAccountNameAndExternalId(
                    new Set<Id>{ franchiseAccountId },
                    new Set<String>{ '1234' },
                    Integer.valueOf(FRANCHISE_ACCOUNTS_WITHHOLDING_QUERY_LIMIT)
                )
            )
            .thenReturn(new List<Xref__c>{ xrefMock });
        mocks.when(
                xrefsSelectorMock.selectCountOfDriveDBXrefsBySalesforceAccountNameAndExternalId(
                    new Set<Id>{ franchiseAccountId },
                    new Set<String>{ '1234' }
                )
            )
            .thenReturn(new List<Aggregate>{});
        mocks.when(staticConfigurationsMock.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                staticConfigurationsMock.getInstanceValue(
                    CORPORATE_ACCOUNT_IDS_CHUNK_SIZE_TO_PROCESS_DRIVE_WITHHOLDING_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = CORPORATE_ACCOUNT_IDS_CHUNK_SIZE_TO_PROCESS_DRIVE_WITHHOLDING_STATIC_CONFIG,
                    Configuration_Value__c = CORPORATE_ACCOUNT_IDS_CHUNK_SIZE_TO_PROCESS_DRIVE_WITHHOLDING
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
        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(agreementsSelectorMock);
        Application.SELECTOR.setMock(contractsSelectorMock);
        Application.SELECTOR.setMock(staticConfigurationsMock);
        Application.SELECTOR.setMock(xrefsSelectorMock);
        BusReferenceIntegrationService.processDriveWithholding(new List<Id>{ corporateAccountId });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Account.Id => corporateAccountId,
                        Account.Show_MP_Bz_Id_Update_Banner__c => true
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Business_Reference__c.Id => businessReferenceId,
                        Business_Reference__c.External_Id__c => '1234'
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 3)).commitWork();
    }

    /**
     * @description To test when corporate Account Ids are passed then
     * Business Reference External Id not initiated where
     * External Id matches with MP Bz Id field present on Contract.
     */
    @isTest
    private static void testWhenCorporateAccountIdsPassedThenExternalIdUpdateNotInitiated() {
        Id agreementId = fflib_IDGenerator.generate(Agreement__c.SObjectType);
        Id businessReferenceId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id corporateAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Fake contractFakeInstance = new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.AccountId, corporateAccountId)
            .setField(Contract.MP_Bz_Id__c, '1234');
        Contract contractMock = (Contract) ServiceMockDataBuilder.convertToSObject(
            contractFakeInstance
        );
        Fake franchiseAgreementFakeInstance = new Fake(Agreement__c.class)
            .setField(Agreement__c.Id, agreementId)
            .setField(Agreement__c.Name, AGREEMENT_NAME)
            .setField(Agreement__c.Account__c, corporateAccountId)
            .setField(Agreement__c.Contract__c, contractId)
            .setField(Agreement__c.Type__c, AGREEMENT_TYPE_FRANCHISE_AGREEMENT)
            .setField(Agreement__c.Status__c, AGREEMENT_STATUS_ACTIVE)
            .setParent('Contract__r', contractFakeInstance);
        Agreement__c franchiseAgreement = (Agreement__c) ServiceMockDataBuilder.convertToSObject(
            franchiseAgreementFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IAgreementsSelector agreementsSelectorMock = (IAgreementsSelector) mocks.mock(
            IAgreementsSelector.class
        );
        IContractsSelector contractsSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        IXrefsSelector xrefsSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IStaticConfigurationsSelector staticConfigurationsMock = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.selectById(new Set<Id>{ corporateAccountId }))
            .thenReturn(
                new List<Account>{
                    new Account(Id = corporateAccountId, Show_MP_Bz_Id_Update_Banner__c = false)
                }
            );
        mocks.when(contractsSelectorMock.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(
                contractsSelectorMock.selectActivatedWithholdingContractsByAccountIds(
                    new Set<Id>{ corporateAccountId }
                )
            )
            .thenReturn(new List<Contract>{ contractMock });
        mocks.when(agreementsSelectorMock.sObjectType()).thenReturn(Agreement__c.SObjectType);
        mocks.when(
                agreementsSelectorMock.selectWithholdingCorporateAccountsByActiveAgreements(
                    new Set<Id>{ corporateAccountId },
                    Integer.valueOf(FRANCHISE_ACCOUNTS_WITHHOLDING_QUERY_LIMIT)
                )
            )
            .thenReturn(new List<Agreement__c>{ franchiseAgreement });
        mocks.when(xrefsSelectorMock.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                xrefsSelectorMock.selectDriveDBXrefsBySalesforceAccountNameAndExternalId(
                    new Set<Id>{ corporateAccountId },
                    new Set<String>{ '1234' },
                    Integer.valueOf(FRANCHISE_ACCOUNTS_WITHHOLDING_QUERY_LIMIT)
                )
            )
            .thenReturn(new List<Xref__c>{});
        mocks.when(
                xrefsSelectorMock.selectCountOfDriveDBXrefsBySalesforceAccountNameAndExternalId(
                    new Set<Id>{ corporateAccountId },
                    new Set<String>{ '1234' }
                )
            )
            .thenReturn(new List<Aggregate>{});
        mocks.when(staticConfigurationsMock.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                staticConfigurationsMock.getInstanceValue(
                    CORPORATE_ACCOUNT_IDS_CHUNK_SIZE_TO_PROCESS_DRIVE_WITHHOLDING_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = CORPORATE_ACCOUNT_IDS_CHUNK_SIZE_TO_PROCESS_DRIVE_WITHHOLDING_STATIC_CONFIG,
                    Configuration_Value__c = CORPORATE_ACCOUNT_IDS_CHUNK_SIZE_TO_PROCESS_DRIVE_WITHHOLDING
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
        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(agreementsSelectorMock);
        Application.SELECTOR.setMock(contractsSelectorMock);
        Application.SELECTOR.setMock(staticConfigurationsMock);
        Application.SELECTOR.setMock(xrefsSelectorMock);
        BusReferenceIntegrationService.processDriveWithholding(new List<Id>{ corporateAccountId });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Account.Id => corporateAccountId,
                        Account.Show_MP_Bz_Id_Update_Banner__c => true
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Business_Reference__c.Id => businessReferenceId,
                        Business_Reference__c.External_Id__c => '1234'
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 3)).commitWork();
    }

    /**
     * @description To test External Id on business reference updated when
     * "PROCESS_DRIVE_WITHHOLDING" platform event is received.
     */
    @isTest
    private static void testWhenCorporateAccountIdsPayloadReceivedThenExternalIdUpdateInitiated() {
        Id agreementId = fflib_IDGenerator.generate(Agreement__c.SObjectType);
        Id businessReferenceId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id corporateAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id franchiseAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Fake contractFakeInstance = new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.AccountId, corporateAccountId)
            .setField(Contract.MP_Bz_Id__c, '1234');
        Contract contractMock = (Contract) ServiceMockDataBuilder.convertToSObject(
            contractFakeInstance
        );
        Fake franchiseAgreementFakeInstance = new Fake(Agreement__c.class)
            .setField(Agreement__c.Id, agreementId)
            .setField(Agreement__c.Name, AGREEMENT_NAME)
            .setField(Agreement__c.Account__c, franchiseAccountId)
            .setField(Agreement__c.Contract__c, contractId)
            .setField(Agreement__c.Type__c, AGREEMENT_TYPE_FRANCHISE_AGREEMENT)
            .setField(Agreement__c.Status__c, AGREEMENT_STATUS_ACTIVE)
            .setParent('Contract__r', contractFakeInstance);
        Agreement__c franchiseAgreement = (Agreement__c) ServiceMockDataBuilder.convertToSObject(
            franchiseAgreementFakeInstance
        );
        Fake xrefFakeInstance = new Fake(Xref__c.class)
            .setField(Xref__c.Id, xrefId)
            .setField(Xref__c.Business_Reference__c, businessReferenceId)
            .setField(Xref__c.Salesforce_Account_Name__c, franchiseAccountId);
        Xref__c xrefMock = (Xref__c) ServiceMockDataBuilder.convertToSObject(xrefFakeInstance);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IAgreementsSelector agreementsSelectorMock = (IAgreementsSelector) mocks.mock(
            IAgreementsSelector.class
        );
        IContractsSelector contractsSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        IXrefsSelector xrefsSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IStaticConfigurationsSelector staticConfigurationsMock = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.selectById(new Set<Id>{ corporateAccountId }))
            .thenReturn(
                new List<Account>{
                    new Account(Id = corporateAccountId, Show_MP_Bz_Id_Update_Banner__c = false)
                }
            );
        mocks.when(contractsSelectorMock.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(
                contractsSelectorMock.selectActivatedWithholdingContractsByAccountIds(
                    new Set<Id>{ corporateAccountId }
                )
            )
            .thenReturn(new List<Contract>{ contractMock });
        mocks.when(agreementsSelectorMock.sObjectType()).thenReturn(Agreement__c.SObjectType);
        mocks.when(
                agreementsSelectorMock.selectWithholdingCorporateAccountsByActiveAgreements(
                    new Set<Id>{ corporateAccountId },
                    Integer.valueOf(FRANCHISE_ACCOUNTS_WITHHOLDING_QUERY_LIMIT)
                )
            )
            .thenReturn(new List<Agreement__c>{ franchiseAgreement });
        mocks.when(xrefsSelectorMock.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                xrefsSelectorMock.selectDriveDBXrefsBySalesforceAccountNameAndExternalId(
                    new Set<Id>{ franchiseAccountId },
                    new Set<String>{ '1234' },
                    Integer.valueOf(FRANCHISE_ACCOUNTS_WITHHOLDING_QUERY_LIMIT)
                )
            )
            .thenReturn(new List<Xref__c>{ xrefMock });
        mocks.when(
                xrefsSelectorMock.selectCountOfDriveDBXrefsBySalesforceAccountNameAndExternalId(
                    new Set<Id>{ franchiseAccountId },
                    new Set<String>{ '1234' }
                )
            )
            .thenReturn(new List<Aggregate>{});
        mocks.when(staticConfigurationsMock.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                staticConfigurationsMock.getInstanceValue(
                    CORPORATE_ACCOUNT_IDS_CHUNK_SIZE_TO_PROCESS_DRIVE_WITHHOLDING_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = CORPORATE_ACCOUNT_IDS_CHUNK_SIZE_TO_PROCESS_DRIVE_WITHHOLDING_STATIC_CONFIG,
                    Configuration_Value__c = CORPORATE_ACCOUNT_IDS_CHUNK_SIZE_TO_PROCESS_DRIVE_WITHHOLDING
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
        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(agreementsSelectorMock);
        Application.SELECTOR.setMock(contractsSelectorMock);
        Application.SELECTOR.setMock(staticConfigurationsMock);
        Application.SELECTOR.setMock(xrefsSelectorMock);
        String eventPayload = JSON.serialize(new Set<Id>{ corporateAccountId });
        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = EVENT_TOPIC_PROCESS_DRIVE_WITHHOLDING
        );
        BusReferenceIntegrationService.execute(new List<Notifier__e>{ mockNotifierEvent });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Account.Id => corporateAccountId,
                        Account.Show_MP_Bz_Id_Update_Banner__c => true
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Business_Reference__c.Id => businessReferenceId,
                        Business_Reference__c.External_Id__c => '1234'
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 3)).commitWork();
    }
}