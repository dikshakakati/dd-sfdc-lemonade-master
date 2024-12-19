/**
 * @author atg
 * @date 06/29/2022
 * @description Test class for XrefIntegrationServiceImpl class.
 * Suppressed Warnings in this class since mock verify method does not require system assert statements.
 */
@isTest(seeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
public class XrefIntegrationServiceImplTest {
    private static final String EXTERNAL_NOTIFIER_EVENT_XREF_INTEGRATION = 'XREF_INTEGRATE';
    private static final String STATUS_SUCCESS = 'Success';
    private static final String STATUS_WAITING_FOR_BUSINESS = 'Waiting for Business';
    private static final String STATUS_READY_FOR_INTEGRATION = 'Ready for Integration';
    private static final String STATUS_COO_SUCCESS = 'COO Success';
    private static final String XREF_STATUS_INACTIVE = 'Inactive';
    private static final String EXTERNAL_DB_SOURCE_MDS = 'MDS';
    private static final String VERTICAL = 'Floral';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String CORPORATE = 'Corporate';
    private static final String SEGEMENT_SMB = 'SMB';

    /**
     * @description To test when Xref__c are being integrated.
     * External Notifier event with XREF_INTEGRATE topic and corresponding payload.
     */
    @isTest
    private static void testWhenCreateIntegrationPlatformEventsThenExternalNotifierEventPublishedWithPayload() {
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id externalBusinessId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);
        Id userId = fflib_IDGenerator.generate(User.SObjectType);
        Datetime currentDateTime = DateTime.now();

        Xref__c xref = new Xref__c(
            Id = xrefId,
            Business_Reference__c = externalBusinessId,
            Salesforce_Account_Name__c = storeAccountId,
            CreatedById = userId,
            CreatedDate = currentDateTime
        );
        List<Xref__c> xrefList = new List<Xref__c>{ xref };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IExternalNotifierEventsService externalNotifierServiceMock = (IExternalNotifierEventsService) mocks.mock(
            IExternalNotifierEventsService.class
        );
        IXrefsSelector xrefSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);

        mocks.startStubbing();
        mocks.when(xrefSelectorMock.SObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(xrefSelectorMock.selectAllInfoNeededForPlatformEvent(new Set<Id>{xrefId})).thenReturn(xrefList);
        mocks.stopStubbing();


        Application.SERVICE.setMock(
            IExternalNotifierEventsService.class,
            externalNotifierServiceMock
        );
        Application.SELECTOR.setMock(xrefSelectorMock);

        List<XrefIntegration> xrefIntegrationList = new List<XrefIntegration>();
        xrefIntegrationList.add(new XrefIntegration(xref));
        String eventPayload = JSON.serialize(xrefIntegrationList);

        XrefIntegrationService.createIntegrationPlatformEvents(
            new List<Xref__c>(),
            EXTERNAL_NOTIFIER_EVENT_XREF_INTEGRATION
        );
        XrefIntegrationService.createIntegrationPlatformEvents(
            xrefList,
            EXTERNAL_NOTIFIER_EVENT_XREF_INTEGRATION
        );

        ((IExternalNotifierEventsService) mocks.verify(externalNotifierServiceMock, 1))
            .publishEventsFromList(EXTERNAL_NOTIFIER_EVENT_XREF_INTEGRATION, new List<String>{eventPayload});
    }

    /**
     * @description To test when Xref__c are being integrated.
     * External Notifier event with XREF_INTEGRATE topic and corresponding payload.
     */
    @isTest
    private static void testWhenBusinessReferenceSuccessThenStatusUpdated() {
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id xrefId1 = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id xrefId2 = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id externalBusinessId1 = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);

        List<Business_Reference__c> businessReferenceList = new List<Business_Reference__c>{
            new Business_Reference__c(
                Id = externalBusinessId1,
                Integration_Status__c = STATUS_SUCCESS
            )
        };

        Xref__c xref1 = new Xref__c(
            Id = xrefId1,
            Business_Reference__c = externalBusinessId1,
            Integration_Status__c = STATUS_WAITING_FOR_BUSINESS,
            Salesforce_Account_Name__c = storeAccountId
        );
        Xref__c xref2 = new Xref__c(
            Id = xrefId2,
            Business_Reference__c = externalBusinessId1,
            Integration_Status__c = STATUS_SUCCESS,
            Salesforce_Account_Name__c = storeAccountId
        );
        List<Xref__c> xrefList = new List<Xref__c>{ xref1, xref2 };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IXrefsSelector selectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        mocks.startStubbing();
        mocks.when(selectorMock.SObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                selectorMock.selectAllMatchingBusinessReference(new Set<Id>{ externalBusinessId1 })
            )
            .thenReturn(xrefList);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        Application.UNITOFWORK.setMock(mockUOW);

        XrefIntegrationService.updateStatusToReadyForIntegration(businessReferenceList, false);

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Xref__c.Id => xrefId1,
                        Xref__c.Integration_Status__c => STATUS_READY_FOR_INTEGRATION
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Xref__c.Id => xrefId2,
                        Xref__c.Integration_Status__c => STATUS_SUCCESS
                    }
                )
            );
    }

    /**
     * @description To test when Xref__c are Set to COO Success.
     */
    @isTest
    private static void testWhenCOOSuccessThenProcessCOO() {
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id xrefId1 = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id externalBusinessId1 = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);

        List<Business_Reference__c> businessReferenceList = new List<Business_Reference__c>{
            new Business_Reference__c(
                Id = externalBusinessId1,
                Integration_Status__c = STATUS_SUCCESS
            )
        };

        Xref__c xref1 = new Xref__c(
            Id = xrefId1,
            Business_Reference__c = externalBusinessId1,
            Integration_Status__c = STATUS_COO_SUCCESS,
            Salesforce_Account_Name__c = storeAccountId
        );
        List<Xref__c> xrefList = new List<Xref__c>{ xref1 };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IChangeOfOwnershipService cooServiceMock = (IChangeOfOwnershipService) mocks.mock(
            IChangeOfOwnershipService.class
        );

        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        Map<Id, Business_Reference__c> accountIdDefaultBusRefIdMap = new Map<Id, Business_Reference__c>();
        accountIdDefaultBusRefIdMap.put(storeAccountId, businessReferenceList[0]);

        mocks.startStubbing();
        mocks.when(
                cooServiceMock.getDefaultBusinessReferenceForCOO(
                    new Set<Id>{ storeAccountId }
                )
            )
            .thenReturn(accountIdDefaultBusRefIdMap);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IChangeOfOwnershipService.class, cooServiceMock);
        Application.UNITOFWORK.setMock(mockUOW);

        XrefIntegrationService.processCOOSuccess(new List<Xref__c>());
        XrefIntegrationService.processCOOSuccess(xrefList);

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Xref__c.Id => xrefId1,
                        Xref__c.Xref_Status__c => XREF_STATUS_INACTIVE
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Xref__c.Business_Reference__c => externalBusinessId1,
                        Xref__c.Integration_Status__c => STATUS_READY_FOR_INTEGRATION,
                        Xref__c.Inactive_Xref__c => xrefId1
                    }
                )
            );
    }
    /**
     * @description To test when Xref__c are being integrated.
     * LEM-3170
     */
    @isTest
    private static void testWhenXrefIsSuccessThenStatusUpdateToWaitingForBusiness() {
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id storeAccountId2 = fflib_IDGenerator.generate(Account.SObjectType);
        Id xrefId1 = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id xrefId2 = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id externalBusinessId1 = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);

        Xref__c xref1 = new Xref__c(
            Id = xrefId1,
            Business_Reference__c = externalBusinessId1,
            Integration_Status__c = STATUS_SUCCESS,
            Salesforce_Account_Name__c = storeAccountId,
            External_ID_Source__c = EXTERNAL_DB_SOURCE_MDS
        );
        Xref__c xref2 = new Xref__c(
            Id = xrefId2,
            Business_Reference__c = externalBusinessId1,
            Integration_Status__c = STATUS_SUCCESS,
            Salesforce_Account_Name__c = storeAccountId2,
            External_ID_Source__c = EXTERNAL_DB_SOURCE_MDS
        );
        List<Xref__c> xrefList = new List<Xref__c>{ xref1, xref2 };
        Set<Id> accountsIdSet = new Set<Id>{ storeAccountId, storeAccountId2 };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IXrefsSelector selectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IGenericLogger genericLoggerService = (IGenericLogger) mocks.mock(GenericLoggerImpl.class);

        mocks.startStubbing();
        mocks.when(selectorMock.SObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                selectorMock.selectBySalesforceAccountName(
                    new Set<Id>{ storeAccountId, storeAccountId2 }
                )
            )
            .thenReturn(xrefList);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        Application.SERVICE.setMock(IGenericLogger.class,genericLoggerService);
        Application.UNITOFWORK.setMock(mockUOW);

        XrefIntegrationService.updateExistingXrefsForAmendaments(accountsIdSet);

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Xref__c.Id => xrefId1,
                        Xref__c.Integration_Status__c => STATUS_WAITING_FOR_BUSINESS
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Xref__c.Id => xrefId2,
                        Xref__c.Integration_Status__c => STATUS_WAITING_FOR_BUSINESS
                    }
                )
            );
    }
    /**
     * @description To test when Xref__c fields are being rolled up on the business account.
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenRollUpXrefsThenCalculateCountOnBusinessAccount() {
        Id storeAccountId = Fake.generateId(Account.class);
        Id xrefId = Fake.generateId(Xref__c.class);
        Id xrefId2 = Fake.generateId(Xref__c.class);
        Id accParentId1 = Fake.generateId(Account.class);
        Set<Id> parentIds = new Set<Id>{ accParentId1 };
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Id, accParentId1)
            .setField(Account.Type, CORPORATE);
        Account mcDonaldCorporate = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        List<Account> corporateAcountList = new List<Account>();
        corporateAcountList.add(mcDonaldCorporate);
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                mcDonaldCorporate.Id,
                VERTICAL
            )
            .setField(Account.Id, storeAccountId)
            .setField(Account.Activation_Status__c, 'Active')
            .setParent('Parent', businessAccountFakeInstance);
        Account mcDonaldStore = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        List<Account> storeAccountList = new List<Account>{ mcDonaldStore };
        List<Aggregate> accountSumOfChildStoreCount = new List<Aggregate>{
            new Aggregate()
                .put('Id', accParentId1)
                .put('corporateCount', 0)
                .put('franchiseCount', 0)
        };
        Set<Id> storeIds = new Set<Id>{ mcDonaldStore.Id };
        Xref__c xref = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Id, xrefId)
            .setField(Xref__c.External_ID_Source__c, 'MDS')
            .setField(Xref__c.Xref_Status__c, 'Active')
            .setField(Xref__c.Salesforce_Account_Name__c, mcDonaldStore.Id)
            .setField(Xref__c.Account_Segment__c, SEGEMENT_SMB)
            .toSObject();
        Xref__c xref2 = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Id, xrefId2)
            .setField(Xref__c.External_ID_Source__c, 'Drive')
            .setField(Xref__c.Xref_Status__c, 'Active')
            .setField(Xref__c.Salesforce_Account_Name__c, mcDonaldStore.Id)
            .setField(Xref__c.Account_Segment__c, SEGEMENT_SMB)
            .toSObject();
        List<Xref__c> xrefList = new List<Xref__c>{ xref, xref2 };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectSumOfChildStoreCount(parentIds))
            .thenReturn(accountSumOfChildStoreCount);
        mocks.when(selectorMock.selectBusinessAccountIdsFromStoreAccountId(storeIds))
            .thenReturn(storeAccountList);
        mocks.when(selectorMock.selectAccountsWithMDSXrefs(parentIds)).thenReturn(storeAccountList);
        mocks.when(selectorMock.selectAccountsWithNonMDSXrefs(parentIds))
            .thenReturn(storeAccountList);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(selectorMock);
        XrefIntegrationService.updateBusinessAccountsForXrefs(xrefList);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }
}