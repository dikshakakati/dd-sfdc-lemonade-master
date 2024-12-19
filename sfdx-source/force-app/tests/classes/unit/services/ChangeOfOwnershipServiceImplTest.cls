/**
 * @description Test class for ChangeOfOwnershipServiceImpl.
 * Suppressed Warnings since mock verify method does not require System Assert statements.
 */
@isTest(seeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
public class ChangeOfOwnershipServiceImplTest {
    public static final String PROVISIONING_EVENT_CREATION_METHOD_MANUAL = 'Manual';
    public static final String PROVISIONING_EVENT_CREATION_METHOD_AUTOMATIC = 'Automatic';
    private static final String INTEGRATION_STATUS_WAITING_FOR_BUSINESS = 'Waiting for Business';
    private static final String INTEGRATION_STATUS_READY_FOR_INTEGRATION = 'Ready for Integration';
    private static final String INTEGRATION_STATUS_READY_FOR_COO_INTEGRATION = 'Ready for COO Integration';
    private static final String INTEGRATION_STATUS_SUCCESS = 'Success';
    private static final String INTEGRATION_STATUS_COO_SUCCESS = 'COO Success';
    private static final String MENU_UI_TYPE_RESTAURANT = 'Restaurant';
    private static final String PRIMARY_VERTICAL_RX = 'Rx';
    private static final String SEGMENT_ENTERPRISE = 'ENTERPRISE';
    private static final String SEGMENT_SMB = 'SMB';
    private static final String WORKORDER_TYPE_DRIVE = 'Drive';
    private static final String WORKORDER_TYPE_MARKETPLACE = 'Marketplace';
    private static final string XREF_EXTERNAL_ID = '12345';
    private static final string XREF_EXTERNAL_ID_SOURCE = 'DriveDb';
    private static final String XREF_STATUS_ACTIVE = 'Active';
    private static final String ACCOUNT_PRIMARY_VERTICAL_GIFTS = 'Gifts';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final String ORDER_BACKEND_SYSTEMS = 'MDS;MDS - Catering';
    private static final string XREF_EXTERNAL_ID_SOURCE_MDS = 'MDS';
    private static final String ACCOUNT_DATA_VERIFICATION_STATUS = 'Verified';
    private static final String ADDRESS_VERIFICATION_STATUS = 'Verified';
    private static final String BUNDLED_WITH_MARKETPLACE_YES = 'Yes';
    private static final String DISALLOW_PDOA_OVERRIDE_NO = 'No';
    private static final String DISALLOW_PDOA_OVERRIDE_YES = 'Yes';
    private static final String IN_COVERAGE = 'In Coverage';
    private static final String BUSINESS_REFERENCE_GRAVEYARD = 'Graveyard';
    private static final String GRAVEYARD_ID = '123456';
    private static final String DEFAULT_TYPE_COO_GRAVEYARD = 'COO Graveyard';
    private static final String BUSINESS_REFERENCE_FRANCHISE = 'Franchise';
    private static final String BUSINESS_REFERENCE_CORPORATE = 'Corporate';
    private static final String COO_TEST = 'COO Test';
    private static final String COO_PROCESS_VIA_ASYNC = 'Process via Async Mode';
    private static final String EXTERNAL_DB_SOURCE_MDS = 'MDS';

    /**
     * @description test provisionCOO.
     */
    @isTest
    public static void testWhenProvisionCOOCalledThenGraveyardCreated() {
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        String accountIdString = JSON.serialize(new List<Id>{ storeAccountId });
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);

        List<Provisioning_Event__e> provisionEventList = new List<Provisioning_Event__e>();
        Provisioning_Event__e event = new Provisioning_Event__e(
            COO_Graveyard_Id__c = GRAVEYARD_ID,
            WO_Type__c = 'COO',
            Accounts__c = accountIdString
        );
        provisionEventList.add(event);

        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_GIFTS
            )
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(Account.Data_Verification_Status__c, ACCOUNT_DATA_VERIFICATION_STATUS)
            .setField(Account.Id, storeAccountId)
            .setField(Account.Proposed_Date_of_Activation__c, System.today())
            .setParent(
                'Parent',
                new Fake(Account.class).setField(Account.Name, ACCOUNT_RECORD_TYPE_NAME_STORE)
            )
            .setChildren(
                'Xrefs__r',
                new List<Fake>{
                    new Fake(Xref__c.class)
                        .setField(Xref__c.Id, xrefId)
                        .setField(Xref__c.External_ID__c, XREF_EXTERNAL_ID)
                        .setField(Xref__c.External_ID_Source__c, XREF_EXTERNAL_ID_SOURCE_MDS)
                        .setField(Xref__c.Salesforce_Account_Name__c, storeAccountId)
                        .setField(Xref__c.Xref_Status__c, XREF_STATUS_ACTIVE)
                }
            );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        List<Account> accountsList = new List<Account>{ storeAccount };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountSelectorMock.selectAccountsWithXrefs(new Set<Id>{ storeAccountId }))
            .thenReturn(accountsList);
        mocks.when(
                accountSelectorMock.selectAccountsWithInActiveXrefs(new Set<Id>{ storeAccountId })
            )
            .thenReturn(accountsList);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);

        ChangeOfOwnershipService.provisionCOO(provisionEventList);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Xref__c.Id => xrefId,
                        Xref__c.Coo_Process__c => COO_PROCESS_VIA_ASYNC
                    }
                )
            );
    }

    /**
     * @description test provisionCOO with an existing COO graveyard.
     */
    @isTest
    public static void testWhenProvisionCOOCalledThenExistingGraveyardUsed() {
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        String accountIdString = JSON.serialize(new List<Id>{ storeAccountId });
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);

        List<Provisioning_Event__e> provisionEventList = new List<Provisioning_Event__e>();
        Provisioning_Event__e event = new Provisioning_Event__e(
            COO_Graveyard_Id__c = GRAVEYARD_ID,
            WO_Type__c = 'COO',
            Accounts__c = accountIdString
        );
        provisionEventList.add(event);

        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_GIFTS
            )
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(Account.Data_Verification_Status__c, ACCOUNT_DATA_VERIFICATION_STATUS)
            .setField(Account.Id, storeAccountId)
            .setField(Account.Proposed_Date_of_Activation__c, System.today())
            .setChildren(
                'Xrefs__r',
                new List<Fake>{
                    new Fake(Xref__c.class)
                        .setField(Xref__c.Id, xrefId)
                        .setField(Xref__c.External_ID__c, XREF_EXTERNAL_ID)
                        .setField(Xref__c.External_ID_Source__c, XREF_EXTERNAL_ID_SOURCE_MDS)
                        .setField(Xref__c.Salesforce_Account_Name__c, storeAccountId)
                        .setField(Xref__c.Xref_Status__c, XREF_STATUS_ACTIVE)
                }
            );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        List<Account> accountsList = new List<Account>{ storeAccount };

        List<Business_Reference__c> businessReferenceList = new List<Business_Reference__c>{
            new Business_Reference__c(
                CurrencyIsoCode = 'USD',
                External_Id_Source__c = XREF_EXTERNAL_ID_SOURCE_MDS,
                External_Id__c = GRAVEYARD_ID,
                Business_Name__c = BUSINESS_REFERENCE_GRAVEYARD,
                Default_Type__c = DEFAULT_TYPE_COO_GRAVEYARD,
                Integration_Status__c = INTEGRATION_STATUS_COO_SUCCESS
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IBusinessReferencesSelector busRefSelectorMock = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountSelectorMock.selectAccountsWithXrefs(new Set<Id>{ storeAccountId }))
            .thenReturn(accountsList);
        mocks.when(
                accountSelectorMock.selectAccountsWithInActiveXrefs(new Set<Id>{ storeAccountId })
            )
            .thenReturn(accountsList);
        mocks.when(busRefSelectorMock.sObjectType()).thenReturn(Business_Reference__c.SObjectType);
        mocks.when(busRefSelectorMock.selectByGraveyardIds(new Set<String>{ GRAVEYARD_ID }))
            .thenReturn(businessReferenceList);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(busRefSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);

        ChangeOfOwnershipService.provisionCOO(provisionEventList);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Xref__c.Id => xrefId,
                        Xref__c.Coo_Process__c => COO_PROCESS_VIA_ASYNC
                    }
                )
            );
    }

    /**
     * @description test provisionCOO with an Account with No Xrefs.
     * (This should not happen, but the code will create an xref to keep the process going.)
     */
    @isTest
    public static void testWhenProvisionCOOCalledThenXrefCreated() {
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        String accountIdString = JSON.serialize(new List<Id>{ storeAccountId });

        List<Provisioning_Event__e> provisionEventList = new List<Provisioning_Event__e>();
        Provisioning_Event__e event = new Provisioning_Event__e(
            COO_Graveyard_Id__c = GRAVEYARD_ID,
            WO_Type__c = 'COO',
            Accounts__c = accountIdString
        );
        provisionEventList.add(event);

        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_GIFTS
            )
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(Account.Data_Verification_Status__c, ACCOUNT_DATA_VERIFICATION_STATUS)
            .setField(Account.Id, storeAccountId)
            .setField(Account.Proposed_Date_of_Activation__c, System.today());
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        List<Account> accountsList = new List<Account>{ storeAccount };

        List<Business_Reference__c> businessReferenceList = new List<Business_Reference__c>{
            new Business_Reference__c(
                CurrencyIsoCode = 'USD',
                External_Id_Source__c = XREF_EXTERNAL_ID_SOURCE_MDS,
                External_Id__c = GRAVEYARD_ID,
                Business_Name__c = BUSINESS_REFERENCE_GRAVEYARD,
                Default_Type__c = DEFAULT_TYPE_COO_GRAVEYARD,
                Integration_Status__c = INTEGRATION_STATUS_COO_SUCCESS
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IBusinessReferencesSelector busRefSelectorMock = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountSelectorMock.selectAccountsWithXrefs(new Set<Id>{ storeAccountId }))
            .thenReturn(accountsList);
        mocks.when(
                accountSelectorMock.selectAccountsWithInActiveXrefs(new Set<Id>{ storeAccountId })
            )
            .thenReturn(accountsList);
        mocks.when(busRefSelectorMock.sObjectType()).thenReturn(Business_Reference__c.SObjectType);
        mocks.when(busRefSelectorMock.selectByGraveyardIds(new Set<String>{ GRAVEYARD_ID }))
            .thenReturn(businessReferenceList);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(busRefSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);

        ChangeOfOwnershipService.provisionCOO(provisionEventList);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Xref__c.Salesforce_Account_Name__c => storeAccountId,
                        Xref__c.Integration_Status__c => INTEGRATION_STATUS_READY_FOR_COO_INTEGRATION
                    }
                )
            );
    }

    /**
     * @description test provisionCOO.
     */
    @isTest
    public static void testWhenGetDefaultBusinessThenMapReturned() {
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id franchiseBusRef = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);
        Id businessVerticalId = fflib_IDGenerator.generate(Business_Vertical__c.SObjectType);

        Id brandId = fflib_IDGenerator.generate(Brand__c.SObjectType);
        string brandName = 'COO Test';
        Fake brandFakeInstance = new Fake(Brand__c.class)
            .setField(Brand__c.Price_Range__c, null)
            .setField(Brand__c.Name, brandName)
            .setField(Brand__c.Id, brandId);
        Brand__c brandInstance = (Brand__c) ServiceMockDataBuilder.convertToSObject(
            brandFakeInstance
        );

        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );

        Fake businessVerticalRxFakeInstance = new Fake(Business_Vertical__c.class)
            .setField(Business_Vertical__c.Name, 'TEST Business Vertical')
            .setField(Business_Vertical__c.Id, businessVerticalId);

        Business_Vertical__c businessVerticalRxInstance = (Business_Vertical__c) ServiceMockDataBuilder.convertToSObject(
            businessVerticalRxFakeInstance
        );

        Fake franchiseParentAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_GIFTS
            )
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Segment__c, SEGMENT_SMB)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(Account.Data_Verification_Status__c, ACCOUNT_DATA_VERIFICATION_STATUS)
            .setField(Account.Legal_Business_Name__c, 'COO Test')
            .setField(Account.CurrencyIsoCode, 'USD')
            .setField(Account.Proposed_Date_of_Activation__c, System.today())
            .setField(Account.Business_Vertical__c, businessVerticalId)
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance)
            .setFakeId();

        Account franchiseParentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            franchiseParentAccountFakeInstance
        );

        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_GIFTS
            )
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Segment__c, 'SMB')
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(Account.Data_Verification_Status__c, ACCOUNT_DATA_VERIFICATION_STATUS)
            .setField(Account.Id, storeAccountId)
            .setField(Account.Proposed_Date_of_Activation__c, System.today())
            .setField(Account.Franchise_Parent__c, franchiseParentAccount.Id)
            .setField(Account.Business_Vertical__c, businessVerticalId)
            .setParent('Franchise_Parent__r', franchiseParentAccountFakeInstance)
            .setParent('Brand__r', new Fake(Brand__c.class).setField(Brand__c.Name, COO_TEST));
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );

        Business_Reference__c businessRef1 = (Business_Reference__c) new Fake(
                Business_Reference__c.class
            )
            .setField(Business_Reference__c.Primary_Vertical__c, ACCOUNT_PRIMARY_VERTICAL_GIFTS)
            .setField(Business_Reference__c.CurrencyIsoCode, 'USD')
            .setField(Business_Reference__c.External_Id_Source__c, XREF_EXTERNAL_ID_SOURCE_MDS)
            .setField(Business_Reference__c.Default_Type__c, BUSINESS_REFERENCE_FRANCHISE)
            .setField(Business_Reference__c.Business_Name__c, 'COO Test')
            .setField(Business_Reference__c.Id, franchiseBusRef)
            .setField(Account.Business_Vertical__c, businessVerticalId)
            .setField(Business_Reference__c.Brand__c, brandInstance.Id)
            .setField(Business_Reference__c.Brand__c, brandId)
            .setParent('Brand__r', brandFakeInstance)
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance)
            .toSObject();

        string currencyIsoCode = 'USD';
        string externalIdSource = 'MDS';
        string defaultType = 'Franchise';
        String expectedKey =
            currencyIsoCode +
            businessVerticalId +
            externalIdSource +
            defaultType +
            brandName.toUpperCase();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IBusinessVerticalsSelector businessSelectorMock = (IBusinessVerticalsSelector) mocks.mock(
            IBusinessVerticalsSelector.class
        );
        IBusinessReferencesSelector businessRefSelectorMock = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        IBusinessVerticalsSelector businessVerticalsSelectorMock = (IBusinessVerticalsSelector) mocks.mock(
            IBusinessVerticalsSelector.class
        );
        IXrefAndBizRefMatchingService xrefBizRefMatchingService = (IXrefAndBizRefMatchingService) mocks.mock(
            IXrefAndBizRefMatchingService.class
        );

        mocks.startStubbing();
        mocks.when(businessVerticalsSelectorMock.sObjectType())
            .thenReturn(Business_Vertical__c.SObjectType);
        mocks.when(businessVerticalsSelectorMock.selectPrimaryVerticalRxRecord())
            .thenReturn(
                new List<Business_Vertical__c>{
                    new Business_Vertical__c(
                        Id = businessVerticalId,
                        Primary_Vertical__c = PRIMARY_VERTICAL_RX,
                        Menu_UI_Type__c = MENU_UI_TYPE_RESTAURANT
                    )
                }
            );
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountSelectorMock.selectAccountsWithXrefs(new Set<Id>{ storeAccountId }))
            .thenReturn(new List<Account>{ storeAccount });

        mocks.when(businessSelectorMock.sObjectType()).thenReturn(Business_Vertical__c.SObjectType);
        mocks.when(businessSelectorMock.selectPrimaryVerticalRxRecord())
            .thenReturn(new List<Business_Vertical__c>{ businessVerticalRxInstance });
        mocks.when(businessRefSelectorMock.sObjectType())
            .thenReturn(Business_Reference__c.SObjectType);
        mocks.when(
                businessRefSelectorMock.selectByBusinessVerticals(
                    new Set<String>{ businessVerticalId }
                )
            )
            .thenReturn(new List<Business_Reference__c>{ businessRef1 });
        mocks.when(
                xrefBizRefMatchingService.getBusinessReferencesByMatchingKey(
                    new List<Account>{ storeAccount }
                )
            )
            .thenReturn(new Map<String, Business_Reference__c>{ expectedKey => businessRef1 });
        mocks.when(
                xrefBizRefMatchingService.matchTheBizRefWithAccountByExternalSource(
                    storeAccount,
                    new Map<String, Business_Reference__c>{ expectedKey => businessRef1 },
                    'MDS'
                )
            )
            .thenReturn(businessRef1);

        mocks.stopStubbing();
        Application.SELECTOR.setMock(businessVerticalsSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(businessRefSelectorMock);
        Application.SELECTOR.setMock(businessSelectorMock);
        Application.SERVICE.setMock(IXrefAndBizRefMatchingService.class, xrefBizRefMatchingService);

        Set<Id> cooSoldAccounts = new Set<Id>{ storeAccountId };
        Map<Id, Business_Reference__c> accountIdBusinessRefMap = ChangeOfOwnershipService.getDefaultBusinessReferenceForCOO(
            cooSoldAccounts
        );
        system.assertEquals(1, accountIdBusinessRefMap.size(), 'Map is incorrect size');
        system.assertEquals(
            accountIdBusinessRefMap.get(storeAccount.Id).External_Id_Source__c,
            EXTERNAL_DB_SOURCE_MDS,
            'Default Type should be Franchise'
        );
    }

    @isTest
    static void testWhenStoreHasDriveStoreIdThenMarkXrefReadyForCoo() {
        String storeAccountName = 'test-store';
        String parentAccountName = 'parent-account';
        String response = '{"drive_store_id": "12345"}';
        Integer statusCode = 200;

        Xref__c xref = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.External_Id__c, '12345-store-id')
            .setField(Xref__c.Coo_Process__c, COO_PROCESS_VIA_ASYNC)
            .setParent(
                'Salesforce_Account_Name__r',
                new Fake(Account.class)
                    .setField(Account.Name, storeAccountName)
                    .setField(Account.currencyIsoCode, 'USD')
                    .setParent(
                        'Parent',
                        new Fake(Account.class).setField(Account.Name, parentAccountName)
                    )
            )
            .setFakeId()
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IXrefsSelector xrefsSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        mocks.startStubbing();
        mocks.when(xrefsSelectorMock.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                xrefsSelectorMock.selectXrefsByIdAndCooProcess(
                    new Set<Id>{ xref.Id },
                    new Set<String>{ COO_PROCESS_VIA_ASYNC }
                )
            )
            .thenReturn(new List<Xref__c>{ xref });
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(xrefsSelectorMock);

        Test.setMock(
            HttpCalloutMock.class,
            new GetStoreServiceMockResponseGenerator(response, statusCode)
        );

        Test.startTest();
        ChangeOfOwnershipService.processCooXrefsMarkedForAsyncProcess(new Set<Id>{ xref.Id });
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Xref__c.Id => xref.Id,
                        Xref__c.Coo_Process__c => ChangeOfOwnershipServiceImpl.COO_PROCESSED,
                        Xref__c.Integration_Status__c => INTEGRATION_STATUS_READY_FOR_COO_INTEGRATION,
                        Xref__c.Drive_Store_Id__c => '12345'
                    }
                )
            );
    }

    @isTest
    static void testWhenStoreDoesNotHasDriveStoreIdThenAssociateToExistingGraveyardBusinessReference() {
        String storeAccountName = 'test-store';
        String parentAccountName = 'parent-account';
        String response = '{"drive_store_id": ""}';
        Integer statusCode = 200;

        Id accountId = Fake.generateId(Account.class);
        Id parentId = Fake.generateId(Account.class);
        Xref__c xref = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.External_Id__c, '12345-store-id')
            .setField(Xref__c.Coo_Process__c, COO_PROCESS_VIA_ASYNC)
            .setField(Xref__c.Salesforce_account_Name__c, accountId)
            .setParent(
                'Salesforce_Account_Name__r',
                new Fake(Account.class)
                    .setField(Account.ParentId, parentId)
                    .setField(Account.Name, storeAccountName)
                    .setField(Account.currencyIsoCode, 'USD')
                    .setParent(
                        'Parent',
                        new Fake(Account.class).setField(Account.Name, parentAccountName)
                    )
            )
            .setFakeId()
            .toSObject();

        String businessRefName = BUSINESS_REFERENCE_GRAVEYARD + ' ' + parentAccountName;
        Business_reference__c busRef = (Business_reference__c) new Fake(Business_reference__c.class)
            .setField(
                Business_reference__c.Business_Name__c,
                BUSINESS_REFERENCE_GRAVEYARD + ' ' + parentAccountName
            )
            .setField(Business_reference__c.Integration_Status__c, INTEGRATION_STATUS_COO_SUCCESS)
            .setFakeId()
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IXrefsSelector xrefsSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IBusinessReferencesSelector busRefSelectorMock = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        mocks.startStubbing();
        mocks.when(xrefsSelectorMock.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                xrefsSelectorMock.selectXrefsByIdAndCooProcess(
                    new Set<Id>{ xref.Id },
                    new Set<String>{ COO_PROCESS_VIA_ASYNC }
                )
            )
            .thenReturn(new List<Xref__c>{ xref });
        mocks.when(busRefSelectorMock.sObjectType()).thenReturn(Business_reference__c.SObjectType);
        mocks.when(busRefSelectorMock.selectByBusRefName(new List<String>{ businessRefName }))
            .thenReturn(new List<Business_reference__c>{ busRef });
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(xrefsSelectorMock);
        Application.SELECTOR.setMock(busRefSelectorMock);

        Test.setMock(
            HttpCalloutMock.class,
            new GetStoreServiceMockResponseGenerator(response, statusCode)
        );

        Test.startTest();
        ChangeOfOwnershipService.processCooXrefsMarkedForAsyncProcess(new Set<Id>{ xref.Id });
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Xref__c.Id => xref.Id,
                        Xref__c.Coo_Process__c => ChangeOfOwnershipServiceImpl.COO_PROCESSED,
                        Xref__c.Integration_Status__c => INTEGRATION_STATUS_READY_FOR_COO_INTEGRATION,
                        Xref__c.Business_Reference__c => busRef.Id
                    }
                )
            );
    }

    @isTest
    static void testWhenStoreDoesNotHasDriveStoreIdThenAssociateToExistingCooGraveyardBusinessReference() {
        String storeAccountName = 'test-store';
        String parentAccountName = 'parent-account';
        String response = '{"drive_store_id": ""}';
        String busRefExternalId = '87867878';
        Integer statusCode = 200;

        Id accountId = Fake.generateId(Account.class);
        Id parentId = Fake.generateId(Account.class);
        Xref__c xref = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.External_Id__c, '12345-store-id')
            .setField(Xref__c.Coo_Process__c, COO_PROCESS_VIA_ASYNC)
            .setField(Xref__c.Salesforce_account_Name__c, accountId)
            .setField(Xref__c.COO_Graveyard_Id__c, busRefExternalId)
            .setParent(
                'Salesforce_Account_Name__r',
                new Fake(Account.class)
                    .setField(Account.ParentId, parentId)
                    .setField(Account.Name, storeAccountName)
                    .setField(Account.currencyIsoCode, 'USD')
                    .setParent(
                        'Parent',
                        new Fake(Account.class).setField(Account.Name, parentAccountName)
                    )
            )
            .setFakeId()
            .toSObject();

        String businessRefName = BUSINESS_REFERENCE_GRAVEYARD + ' ' + parentAccountName;
        Business_reference__c cooBusRef = (Business_reference__c) new Fake(
                Business_reference__c.class
            )
            .setField(
                Business_reference__c.Business_Name__c,
                BUSINESS_REFERENCE_GRAVEYARD + ' ' + parentAccountName
            )
            .setField(Business_reference__c.Integration_Status__c, INTEGRATION_STATUS_COO_SUCCESS)
            .setField(Business_reference__c.External_Id__c, busRefExternalId)
            .setFakeId()
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IXrefsSelector xrefsSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IBusinessReferencesSelector busRefSelectorMock = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        mocks.startStubbing();
        mocks.when(xrefsSelectorMock.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                xrefsSelectorMock.selectXrefsByIdAndCooProcess(
                    new Set<Id>{ xref.Id },
                    new Set<String>{ COO_PROCESS_VIA_ASYNC }
                )
            )
            .thenReturn(new List<Xref__c>{ xref });
        mocks.when(busRefSelectorMock.sObjectType()).thenReturn(Business_reference__c.SObjectType);
        mocks.when(busRefSelectorMock.selectByBusRefName(new List<String>{ businessRefName }))
            .thenReturn(new List<Business_reference__c>());
        mocks.when(busRefSelectorMock.selectByGraveyardIds(new Set<String>{ busRefExternalId }))
            .thenReturn(new List<Business_reference__c>{ cooBusRef });
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(xrefsSelectorMock);
        Application.SELECTOR.setMock(busRefSelectorMock);

        Test.setMock(
            HttpCalloutMock.class,
            new GetStoreServiceMockResponseGenerator(response, statusCode)
        );

        Test.startTest();
        ChangeOfOwnershipService.processCooXrefsMarkedForAsyncProcess(new Set<Id>{ xref.Id });
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Xref__c.Id => xref.Id,
                        Xref__c.Coo_Process__c => ChangeOfOwnershipServiceImpl.COO_PROCESSED,
                        Xref__c.Integration_Status__c => INTEGRATION_STATUS_READY_FOR_COO_INTEGRATION,
                        Xref__c.Business_Reference__c => cooBusRef.Id
                    }
                )
            );
    }

    @isTest
    static void testWhenStoreDoesNotHasDriveStoreIdThenAssociateToNewGraveyardBusinessReference() {
        String storeAccountName = 'test-store';
        String parentAccountName = 'parent-account';
        String response = '{"drive_store_id": ""}';
        Integer statusCode = 200;

        Id accountId = Fake.generateId(Account.class);
        Id parentId = Fake.generateId(Account.class);
        Xref__c xref = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.External_Id__c, '12345-store-id')
            .setField(Xref__c.Coo_Process__c, COO_PROCESS_VIA_ASYNC)
            .setField(Xref__c.Salesforce_account_Name__c, accountId)
            .setParent(
                'Salesforce_Account_Name__r',
                new Fake(Account.class)
                    .setField(Account.ParentId, parentId)
                    .setField(Account.Name, storeAccountName)
                    .setField(Account.currencyIsoCode, 'USD')
                    .setParent(
                        'Parent',
                        new Fake(Account.class).setField(Account.Name, parentAccountName)
                    )
            )
            .setFakeId()
            .toSObject();

        String businessRefName = BUSINESS_REFERENCE_GRAVEYARD + ' ' + parentAccountName;

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IXrefsSelector xrefsSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IBusinessReferencesSelector busRefSelectorMock = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        mocks.startStubbing();
        mocks.when(xrefsSelectorMock.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                xrefsSelectorMock.selectXrefsByIdAndCooProcess(
                    new Set<Id>{ xref.Id },
                    new Set<String>{ COO_PROCESS_VIA_ASYNC }
                )
            )
            .thenReturn(new List<Xref__c>{ xref });
        mocks.when(busRefSelectorMock.sObjectType()).thenReturn(Business_reference__c.SObjectType);
        mocks.when(busRefSelectorMock.selectByBusRefName(new List<String>{ businessRefName }))
            .thenReturn(new List<Business_reference__c>());
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(xrefsSelectorMock);
        Application.SELECTOR.setMock(busRefSelectorMock);

        Test.setMock(
            HttpCalloutMock.class,
            new GetStoreServiceMockResponseGenerator(response, statusCode)
        );

        Test.startTest();
        ChangeOfOwnershipService.processCooXrefsMarkedForAsyncProcess(new Set<Id>{ xref.Id });
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Business_Reference__c.Business_Name__c => businessRefName,
                        Business_Reference__c.Default_Type__c => DEFAULT_TYPE_COO_GRAVEYARD,
                        Business_Reference__c.External_Id_Source__c => 'MDS'
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Xref__c.Id => xref.Id,
                        Xref__c.Coo_Process__c => ChangeOfOwnershipServiceImpl.COO_PROCESSED,
                        Xref__c.Integration_Status__c => INTEGRATION_STATUS_WAITING_FOR_BUSINESS
                    }
                )
            );
    }
}