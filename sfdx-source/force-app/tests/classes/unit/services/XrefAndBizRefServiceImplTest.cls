/**
 * @author Deloitte
 * @date 17/10/2024
 * @description Test Class For XrefAndBizRefServiceImpl.
 * Suppressed Warnings since mock verify method does not require system assert statements
 */
@isTest
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class XrefAndBizRefServiceImplTest {
    private static final String ACCOUNT_PRIMARY_VERTICAL_GIFTS = 'Gifts';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ACCOUNT_DATA_VERIFICATION_STATUS = 'Verified';
    private static final String ADDRESS_VERIFICATION_STATUS = 'Verified';
    private static final String AUTO_ACTIVATIONS_SUB_TYPE = 'Auto-Activations';
    private static final String BRAND_NAME = 'US KFC';
    private static final String BUSINESS_VERTICAL_NAME = 'Business Vertical';
    private static final String CURRENCY_CODE_USD = 'USD';
    private static final String IN_COVERAGE = 'In Coverage';
    private static final String INTEGRATION_STATUS_READY_FOR_INTEGRATION = 'Ready for Integration';
    private static final String INTEGRATION_STATUS_SUCCESS = 'Success';
    private static final String INACTIVE = 'Inactive';
    private static final String MARKETPLACE_ID_STRING = 'Testid';
    private static final String PROVISIONING_EVENT_CREATION_METHOD_AUTOMATIC = 'Automatic';
    private static final String RX_PRODUCT = 'Marketplace';
    private static final String RX_PRIMARY_VERTICAL = 'Rx';
    private static final String RX_MENU_UI_TYPE = 'Restaurant';
    private static final String READY_FOR_PROVISIONING = 'Ready for Provisioning';
    private static final String STORE = 'Store';
    private static final String TEST_ACCOUNT_NAME = 'TEST ACCOUNT LEGAL NAME';
    private static final String WORKORDER_TYPE_DRIVE = 'Drive';
    private static final string XREF_EXTERNAL_ID = '12345';
    private static final string XREF_EXTERNAL_ID_SOURCE = 'DriveDb';
    private static final String XREF_STATUS_ACTIVE = 'Active';
    private static final string XREF_EXTERNAL_ID_SOURCE_MDS = 'MDS';
    private static final String BUSINESS_ID = '12820285';
    private static final string INVALID_ASSERT_MESSAGE = 'Unexpected results';
    private static final Id BUSNINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Business')
        .getRecordTypeId();
    private static final Id STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Store')
        .getRecordTypeId();

    /**
     * @description To test creation of Xrefs and Business References for DriveDb scenario.
     */
    @isTest
    private static void testWhenCreateXrefsAndBusinessRefsInvokedThenCreateDriveDbXrefsAndBizRefs() {
        Id storeId = fflib_IDGenerator.generate(Account.SObjectType);
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id businessVerticalId = fflib_IDGenerator.generate(Business_Vertical__c.SObjectType);
        Id businessReferenceId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);
        Id brandId = fflib_IDGenerator.generate(Brand__c.SObjectType);
        Fake businessVerticalRxFakeInstance = new Fake(Business_Vertical__c.class)
            .setField(Business_Vertical__c.Name, BUSINESS_VERTICAL_NAME)
            .setField(Business_Vertical__c.Id, businessVerticalId);
        Fake brandFakeInstance = new Fake(Brand__c.class)
            .setField(Brand__c.Price_Range__c, null)
            .setField(Brand__c.Name, BRAND_NAME)
            .setField(Brand__c.Id, brandId);
        Fake businessRefFakeInstance = new Fake(Business_Reference__c.class)
            .setField(Business_Reference__c.Id, businessReferenceId)
            .setField(Business_Reference__c.CurrencyIsoCode, CURRENCY_CODE_USD)
            .setField(Business_Reference__c.Business_Vertical__c, businessVerticalId)
            .setField(Business_Reference__c.Integration_Status__c, INTEGRATION_STATUS_SUCCESS)
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance)
            .setParent('Brand__r', brandFakeInstance);
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                ACCOUNT_PRIMARY_VERTICAL_GIFTS,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Legal_Business_Name__c, TEST_ACCOUNT_NAME);
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_GIFTS
            )
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(Account.CurrencyIsoCode, CURRENCY_CODE_USD)
            .setField(Account.Data_Verification_Status__c, ACCOUNT_DATA_VERIFICATION_STATUS)
            .setField(Account.Id, storeId)
            .setField(Account.Proposed_Date_of_Activation__c, System.today())
            .setField(Account.Business_Vertical__c, businessVerticalId)
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance)
            .setField(Account.Activation_Status__c, INACTIVE)
            .setChildren(
                'Xrefs__r',
                new List<Fake>{
                    new Fake(Xref__c.class)
                        .setField(Xref__c.Id, xrefId)
                        .setField(Xref__c.External_ID__c, XREF_EXTERNAL_ID)
                        .setField(Xref__c.External_ID_Source__c, XREF_EXTERNAL_ID_SOURCE)
                        .setField(Xref__c.Salesforce_Account_Name__c, storeId)
                        .setField(Xref__c.Xref_Status__c, XREF_STATUS_ACTIVE)
                        .setField(Xref__c.Business_Reference__c, businessReferenceId)
                        .setParent('Business_Reference__r', businessRefFakeInstance)
                }
            )
            .setParent('Brand__r', brandFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Map<Id, String> accountIdToMpBzId = new Map<Id, String>();
        accountIdToMpBzId.put(storeAccount.Id, MARKETPLACE_ID_STRING);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountSelectorMock.selectAccountsWithBrandName(new Set<Id>{ storeAccount.Id }))
            .thenReturn(new List<Account>{ storeAccount });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.UNITOFWORK.setMock(uowMock);
        Test.startTest();
        XrefAndBizRefService.createXRefsAndBusinessRefs(
            accountIdToMpBzId.keySet(),
            INTEGRATION_STATUS_READY_FOR_INTEGRATION,
            INTEGRATION_STATUS_SUCCESS,
            false,
            true
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Business_Reference__c.External_Id_Source__c => XREF_EXTERNAL_ID_SOURCE,
                        Business_Reference__c.Auto_Create_Business_Configuration__c => false
                    }
                )
            );
    }

    /**
     * @description To test creation of Xrefs and Business References with the existing Business Reference for SMB.
     */
    @isTest
    private static void testWhenCreateXrefsAndBusinessRefsForSMBInvokedThenUpdateExistingBusinessReferences() {
        Id storeId = fflib_IDGenerator.generate(Account.SObjectType);
        Id franchiseParentId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id childWoId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id businessVerticalId = fflib_IDGenerator.generate(Business_Vertical__c.SObjectType);
        Id businessReferenceId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);
        Id brandId = fflib_IDGenerator.generate(Brand__c.SObjectType);
        Fake businessVerticalRxFakeInstance = new Fake(Business_Vertical__c.class)
            .setField(Business_Vertical__c.Name, BUSINESS_VERTICAL_NAME)
            .setField(Business_Vertical__c.Product__c, RX_PRODUCT)
            .setField(Business_Vertical__c.Primary_Vertical__c, RX_PRIMARY_VERTICAL)
            .setField(Business_Vertical__c.Menu_UI_Type__c, RX_MENU_UI_TYPE)
            .setField(Business_Vertical__c.Business_Vertical_ID__c, '')
            .setField(Business_Vertical__c.Id, businessVerticalId);
        Business_Vertical__c businessVertical = (Business_Vertical__c) ServiceMockDataBuilder.convertToSObject(
            businessVerticalRxFakeInstance
        );
        Fake brandFakeInstance = new Fake(Brand__c.class)
            .setField(Brand__c.Price_Range__c, null)
            .setField(Brand__c.Name, BRAND_NAME)
            .setField(Brand__c.Id, brandId);
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                ACCOUNT_PRIMARY_VERTICAL_GIFTS,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Legal_Business_Name__c, TEST_ACCOUNT_NAME);
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                RX_PRODUCT
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.Provisioning_Status__c, READY_FOR_PROVISIONING)
            .setField(
                WorkOrder.Business_to_Store_Assignment__c,
                PROVISIONING_EVENT_CREATION_METHOD_AUTOMATIC
            );
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake businessRefFakeInstance = new Fake(Business_Reference__c.class)
            .setField(Business_Reference__c.Id, businessReferenceId)
            .setField(Business_Reference__c.CurrencyIsoCode, CURRENCY_CODE_USD)
            .setField(Business_Reference__c.Business_Vertical__c, businessVerticalId)
            .setField(Business_Reference__c.Integration_Status__c, INTEGRATION_STATUS_SUCCESS)
            .setField(
                Business_Reference__c.Created_Source_Parent_Work_Order_Id__c,
                String.valueOf(parentWorkOrder.Id)
            )
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance)
            .setParent('Brand__r', brandFakeInstance);
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_GIFTS
            )
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(Account.CurrencyIsoCode, CURRENCY_CODE_USD)
            .setField(Account.Data_Verification_Status__c, ACCOUNT_DATA_VERIFICATION_STATUS)
            .setField(Account.Id, storeId)
            .setField(Account.Proposed_Date_of_Activation__c, System.today())
            .setField(Account.Business_Vertical__c, businessVerticalId)
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance)
            .setField(Account.Activation_Status__c, INACTIVE)
            .setField(Account.Franchise_Parent__c, franchiseParentId)
            .setField(Account.Brand__c, brandId)
            .setChildren(
                'Xrefs__r',
                new List<Fake>{
                    new Fake(Xref__c.class)
                        .setField(Xref__c.Id, xrefId)
                        .setField(Xref__c.External_ID__c, XREF_EXTERNAL_ID)
                        .setField(Xref__c.External_ID_Source__c, XREF_EXTERNAL_ID_SOURCE)
                        .setField(Xref__c.Salesforce_Account_Name__c, storeId)
                        .setField(Xref__c.Xref_Status__c, XREF_STATUS_ACTIVE)
                        .setField(Xref__c.Business_Reference__c, businessReferenceId)
                        .setParent('Business_Reference__r', businessRefFakeInstance)
                }
            )
            .setParent('Brand__r', brandFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake chilWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                RX_PRODUCT
            )
            .setField(WorkOrder.Id, childWoId)
            .setField(WorkOrder.AccountId, storeAccount.Id)
            .setField(WorkOrder.Account_Record_Type_Name__c, STORE)
            .setField(WorkOrder.Provisioning_Status__c, READY_FOR_PROVISIONING)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setField(
                WorkOrder.Business_to_Store_Assignment__c,
                PROVISIONING_EVENT_CREATION_METHOD_AUTOMATIC
            )
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            chilWorkOrderFakeInstance
        );
        Fake xRefFakeInstance = new Fake(Xref__c.class)
            .setField(Xref__c.Id, xrefId)
            .setField(Xref__c.External_ID__c, XREF_EXTERNAL_ID)
            .setField(Xref__c.External_ID_Source__c, XREF_EXTERNAL_ID_SOURCE_MDS)
            .setField(Xref__c.Salesforce_Account_Name__c, storeId)
            .setField(Xref__c.Xref_Status__c, XREF_STATUS_ACTIVE)
            .setField(Xref__c.Business_Reference__c, businessReferenceId)
            .setParent('Business_Reference__r', businessRefFakeInstance)
            .setParent('Salesforce_Account_Name__r', storeAccountFakeInstance);
        Xref__c xReference = (Xref__c) ServiceMockDataBuilder.convertToSObject(xRefFakeInstance);
        Map<Id, String> accountIdToMpBzId = new Map<Id, String>();
        accountIdToMpBzId.put(storeAccount.Id, MARKETPLACE_ID_STRING);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IXrefsSelector xrefsSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IWorkOrdersSelector workOrdersSelectorMock = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IBusinessVerticalsSelector businessVerticalsSelectorMock = (IBusinessVerticalsSelector) mocks.mock(
            IBusinessVerticalsSelector.class
        );
        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountSelectorMock.selectAccountsWithBrandName(new Set<Id>{ storeAccount.Id }))
            .thenReturn(new List<Account>{ storeAccount });
        mocks.when(xrefsSelectorMock.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                xrefsSelectorMock.selectMDSXrefsByAccountIdsAndParentWorkOrderIds(
                    new Set<Id>{ storeAccount.Id },
                    new Set<String>{ String.valueOf(parentWorkOrder.Id) }
                )
            )
            .thenReturn(new List<Xref__c>{ xReference });
        mocks.when(workOrdersSelectorMock.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                workOrdersSelectorMock.selectBusinessReferenceCreationEligibleWorkOrdersByAccountIds(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{ childWorkOrder });
        mocks.when(
                workOrdersSelectorMock.selectByParentWorkOrderIds(new Set<Id>{ parentWorkOrder.Id })
            )
            .thenReturn(new List<WorkOrder>{ childWorkOrder });
        mocks.when(businessVerticalsSelectorMock.sObjectType())
            .thenReturn(Business_Vertical__c.SObjectType);
        mocks.when(businessVerticalsSelectorMock.selectPrimaryVerticalRxRecord())
            .thenReturn(new List<Business_Vertical__c>{ businessVertical });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(workOrdersSelectorMock);
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(xrefsSelectorMock);
        Application.SELECTOR.setMock(businessVerticalsSelectorMock);
        Application.UNITOFWORK.setMock(uowMock);
        Test.startTest();
        XrefAndBizRefService.createXrefsAndBusinessRefsForSMB(
            accountIdToMpBzId.keySet(),
            INTEGRATION_STATUS_READY_FOR_INTEGRATION,
            INTEGRATION_STATUS_SUCCESS,
            false,
            true
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Business_Reference__c.External_Id_Source__c => XREF_EXTERNAL_ID_SOURCE_MDS
                    }
                )
            );
    }

    /**
     * @description To test creation of Xrefs and Business References for MDS scenario.
     */
    @isTest
    private static void testWhenCreateXrefsAndBusinessRefsInvokedForSMBThenCreateMDSXrefsAndBizRefs() {
        Id storeId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id businessVerticalId = fflib_IDGenerator.generate(Business_Vertical__c.SObjectType);
        Id businessReferenceId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);
        Id brandId = fflib_IDGenerator.generate(Brand__c.SObjectType);
        Fake businessVerticalRxFakeInstance = new Fake(Business_Vertical__c.class)
            .setField(Business_Vertical__c.Name, BUSINESS_VERTICAL_NAME)
            .setField(Business_Vertical__c.Product__c, RX_PRODUCT)
            .setField(Business_Vertical__c.Primary_Vertical__c, RX_PRIMARY_VERTICAL)
            .setField(Business_Vertical__c.Menu_UI_Type__c, RX_MENU_UI_TYPE)
            .setField(Business_Vertical__c.Business_Vertical_ID__c, '')
            .setField(Business_Vertical__c.Id, businessVerticalId);
        Business_Vertical__c businessVertical = (Business_Vertical__c) ServiceMockDataBuilder.convertToSObject(
            businessVerticalRxFakeInstance
        );
        Fake brandFakeInstance = new Fake(Brand__c.class)
            .setField(Brand__c.Price_Range__c, null)
            .setField(Brand__c.Name, BRAND_NAME)
            .setField(Brand__c.Id, brandId);
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                ACCOUNT_PRIMARY_VERTICAL_GIFTS,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Legal_Business_Name__c, TEST_ACCOUNT_NAME);
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                WORKORDER_TYPE_DRIVE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.Sub_Type__c, AUTO_ACTIVATIONS_SUB_TYPE)
            .setField(
                WorkOrder.Business_to_Store_Assignment__c,
                PROVISIONING_EVENT_CREATION_METHOD_AUTOMATIC
            );
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake businessRefFakeInstance = new Fake(Business_Reference__c.class)
            .setField(Business_Reference__c.Id, businessReferenceId)
            .setField(Business_Reference__c.CurrencyIsoCode, CURRENCY_CODE_USD)
            .setField(Business_Reference__c.Business_Vertical__c, businessVerticalId)
            .setField(Business_Reference__c.Integration_Status__c, INTEGRATION_STATUS_SUCCESS)
            .setField(
                Business_Reference__c.Created_Source_Parent_Work_Order_Id__c,
                parentWorkOrder.Id
            )
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance)
            .setParent('Brand__r', brandFakeInstance);
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_GIFTS
            )
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(Account.CurrencyIsoCode, CURRENCY_CODE_USD)
            .setField(Account.Data_Verification_Status__c, ACCOUNT_DATA_VERIFICATION_STATUS)
            .setField(Account.Id, storeId)
            .setField(Account.Proposed_Date_of_Activation__c, System.today())
            .setField(Account.Business_Vertical__c, businessVerticalId)
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance)
            .setField(Account.Activation_Status__c, INACTIVE)
            .setChildren(
                'Xrefs__r',
                new List<Fake>{
                    new Fake(Xref__c.class)
                        .setField(Xref__c.Id, xrefId)
                        .setField(Xref__c.External_ID__c, XREF_EXTERNAL_ID)
                        .setField(Xref__c.External_ID_Source__c, XREF_EXTERNAL_ID_SOURCE_MDS)
                        .setField(Xref__c.Salesforce_Account_Name__c, storeId)
                        .setField(Xref__c.Xref_Status__c, XREF_STATUS_ACTIVE)
                        .setField(Xref__c.Business_Reference__c, businessReferenceId)
                        .setParent('Business_Reference__r', businessRefFakeInstance)
                }
            );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Map<Id, String> accountIdToMpBzId = new Map<Id, String>();
        accountIdToMpBzId.put(storeAccount.Id, MARKETPLACE_ID_STRING);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IBusinessVerticalsSelector businessVerticalsSelectorMock = (IBusinessVerticalsSelector) mocks.mock(
            IBusinessVerticalsSelector.class
        );
        IXrefsSelector xrefsSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountSelectorMock.selectAccountsWithBrandName(new Set<Id>{ storeAccount.Id }))
            .thenReturn(new List<Account>{ storeAccount });
        mocks.when(businessVerticalsSelectorMock.sObjectType())
            .thenReturn(Business_Vertical__c.SObjectType);
        mocks.when(businessVerticalsSelectorMock.selectPrimaryVerticalRxRecord())
            .thenReturn(new List<Business_Vertical__c>{ businessVertical });
        mocks.when(xrefsSelectorMock.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                xrefsSelectorMock.selectMDSXrefsByAccountIdsAndParentWorkOrderIds(
                    new Set<Id>{ storeAccount.Id },
                    new Set<String>{ String.valueOf(parentWorkOrder.Id) }
                )
            )
            .thenReturn(
                new List<Xref__c>{
                    new Xref__c(
                        External_ID__c = XREF_EXTERNAL_ID,
                        Salesforce_Account_Name__c = storeId,
                        External_ID_Source__c = XREF_EXTERNAL_ID_SOURCE_MDS
                    )
                }
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(businessVerticalsSelectorMock);
        Application.UNITOFWORK.setMock(uowMock);
        Test.startTest();
        XrefAndBizRefService.createXrefsAndBusinessRefsForSMB(
            new Set<Id>{ storeAccount.Id },
            INTEGRATION_STATUS_READY_FOR_INTEGRATION,
            INTEGRATION_STATUS_SUCCESS,
            false,
            true
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Business_Reference__c.External_Id_Source__c => XREF_EXTERNAL_ID_SOURCE_MDS
                    }
                )
            );
    }

    /**
     * @description To test creation of Xrefs and Business References for DriveDb scenario for SMB.
     */
    @isTest
    private static void testWhenCreateXrefsAndBusinessRefsInvokedThenUpsertDriveDbXrefsAndBizRefs() {
        Id storeId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id franchiseParentId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id businessVerticalId = fflib_IDGenerator.generate(Business_Vertical__c.SObjectType);
        Id businessReferenceId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);
        Id brandId = fflib_IDGenerator.generate(Brand__c.SObjectType);
        Fake businessVerticalRxFakeInstance = new Fake(Business_Vertical__c.class)
            .setField(Business_Vertical__c.Name, BUSINESS_VERTICAL_NAME)
            .setField(Business_Vertical__c.Product__c, RX_PRODUCT)
            .setField(Business_Vertical__c.Primary_Vertical__c, RX_PRIMARY_VERTICAL)
            .setField(Business_Vertical__c.Menu_UI_Type__c, RX_MENU_UI_TYPE)
            .setField(Business_Vertical__c.Business_Vertical_ID__c, '')
            .setField(Business_Vertical__c.Id, businessVerticalId);
        Business_Vertical__c businessVertical = (Business_Vertical__c) ServiceMockDataBuilder.convertToSObject(
            businessVerticalRxFakeInstance
        );
        Fake brandFakeInstance = new Fake(Brand__c.class)
            .setField(Brand__c.Price_Range__c, null)
            .setField(Brand__c.Name, BRAND_NAME)
            .setField(Brand__c.Id, brandId);
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                ACCOUNT_PRIMARY_VERTICAL_GIFTS,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Legal_Business_Name__c, TEST_ACCOUNT_NAME)
            .setField(Account.Id, parentAccountId);
        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                WORKORDER_TYPE_DRIVE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.Sub_Type__c, AUTO_ACTIVATIONS_SUB_TYPE)
            .setField(
                WorkOrder.Business_to_Store_Assignment__c,
                PROVISIONING_EVENT_CREATION_METHOD_AUTOMATIC
            );
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake businessRefFakeInstance = new Fake(Business_Reference__c.class)
            .setField(Business_Reference__c.Id, businessReferenceId)
            .setField(Business_Reference__c.CurrencyIsoCode, CURRENCY_CODE_USD)
            .setField(Business_Reference__c.Business_Vertical__c, businessVerticalId)
            .setField(Business_Reference__c.Integration_Status__c, INTEGRATION_STATUS_SUCCESS)
            .setField(
                Business_Reference__c.Created_Source_Parent_Work_Order_Id__c,
                parentWorkOrder.Id
            )
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance)
            .setParent('Brand__r', brandFakeInstance);
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_GIFTS
            )
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(Account.CurrencyIsoCode, CURRENCY_CODE_USD)
            .setField(Account.Data_Verification_Status__c, ACCOUNT_DATA_VERIFICATION_STATUS)
            .setField(Account.Id, storeId)
            .setField(Account.Franchise_Parent__c, franchiseParentId)
            .setField(Account.Proposed_Date_of_Activation__c, System.today())
            .setField(Account.Business_Vertical__c, businessVerticalId)
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance)
            .setField(Account.Activation_Status__c, INACTIVE)
            .setField(Account.ParentId, parentAccount.Id)
            .setChildren(
                'Xrefs__r',
                new List<Fake>{
                    new Fake(Xref__c.class)
                        .setField(Xref__c.Id, xrefId)
                        .setField(Xref__c.External_ID__c, XREF_EXTERNAL_ID)
                        .setField(Xref__c.External_ID_Source__c, XREF_EXTERNAL_ID_SOURCE)
                        .setField(Xref__c.Salesforce_Account_Name__c, storeId)
                        .setField(Xref__c.Xref_Status__c, XREF_STATUS_ACTIVE)
                        .setField(Xref__c.Business_Reference__c, businessReferenceId)
                        .setParent('Business_Reference__r', businessRefFakeInstance)
                }
            )
            .setParent('Brand__r', brandFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake xRefFakeInstance = new Fake(Xref__c.class)
            .setField(Xref__c.Id, xrefId)
            .setField(Xref__c.External_ID__c, XREF_EXTERNAL_ID)
            .setField(Xref__c.External_ID_Source__c, XREF_EXTERNAL_ID_SOURCE)
            .setField(Xref__c.Salesforce_Account_Name__c, storeAccount.Id)
            .setField(Xref__c.Xref_Status__c, XREF_STATUS_ACTIVE)
            .setField(Xref__c.Business_Reference__c, businessReferenceId)
            .setParent('Business_Reference__r', businessRefFakeInstance)
            .setParent('Salesforce_Account_Name__r', storeAccountFakeInstance);
        Xref__c xReference = (Xref__c) ServiceMockDataBuilder.convertToSObject(xRefFakeInstance);
        Fake xRefFakeInstance2 = new Fake(Xref__c.class)
            .setField(Xref__c.Id, xrefId)
            .setField(Xref__c.External_ID__c, XREF_EXTERNAL_ID)
            .setField(Xref__c.External_ID_Source__c, XREF_EXTERNAL_ID_SOURCE)
            .setField(Xref__c.Salesforce_Account_Name__c, franchiseParentId)
            .setField(Xref__c.Xref_Status__c, XREF_STATUS_ACTIVE)
            .setField(Xref__c.Business_Reference__c, businessReferenceId)
            .setParent('Business_Reference__r', businessRefFakeInstance)
            .setParent('Salesforce_Account_Name__r', storeAccountFakeInstance);
        Xref__c xReference2 = (Xref__c) ServiceMockDataBuilder.convertToSObject(xRefFakeInstance2);
        Map<Id, String> accountIdToMpBzId = new Map<Id, String>();
        accountIdToMpBzId.put(storeAccount.Id, MARKETPLACE_ID_STRING);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IBusinessVerticalsSelector businessVerticalsSelectorMock = (IBusinessVerticalsSelector) mocks.mock(
            IBusinessVerticalsSelector.class
        );
        IXrefsSelector xrefsSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountSelectorMock.selectAccountsWithBrandName(new Set<Id>{ storeAccount.Id }))
            .thenReturn(new List<Account>{ storeAccount });
        mocks.when(businessVerticalsSelectorMock.sObjectType())
            .thenReturn(Business_Vertical__c.SObjectType);
        mocks.when(businessVerticalsSelectorMock.selectPrimaryVerticalRxRecord())
            .thenReturn(new List<Business_Vertical__c>{ businessVertical });
        mocks.when(xrefsSelectorMock.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                xrefsSelectorMock.selectDriveDbXrefsBySalesforceAccountName(
                    new Set<Id>{ storeId, franchiseParentId }
                )
            )
            .thenReturn(new List<Xref__c>{ xReference, xReference2 });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(xrefsSelectorMock);
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(businessVerticalsSelectorMock);
        Application.UNITOFWORK.setMock(uowMock);
        Test.startTest();
        XrefAndBizRefService.createXrefsAndBusinessRefsByMpBzIds(
            accountIdToMpBzId,
            INTEGRATION_STATUS_READY_FOR_INTEGRATION,
            INTEGRATION_STATUS_SUCCESS,
            false,
            true
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1))
            .registerUpsert(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Xref__c.External_Id_Source__c => XREF_EXTERNAL_ID_SOURCE
                    }
                )
            );
    }

    /**
     * @description It is used to test weather Xrefs Records Status is updated to Inactive
     * for Churned Merchant Contract Type.
     * @JIRA #LEM-23780
     */
    @isTest
    private static void testWhenChurnedMxServicesByStoreAccountIdsThenUpdateXrefAsInactive() {
        Id businessAccountId = Fake.generateId(Account.class);
        Id storeAccountId = Fake.generateId(Account.class);
        Id xrefId = Fake.generateId(Xref__c.class);
        Id bizRefId = Fake.generateId(Business_Reference__c.class);
        Fake testAccount = new Fake(Account.class)
            .setField(Account.Id, storeAccountId)
            .setField(Account.Name, TEST_ACCOUNT_NAME)
            .setField(Account.RecordTypeId, STORE_RECORD_TYPE_ID)
            .setParent(
                'Parent',
                new Fake(Account.class)
                    .setField(Account.Id, businessAccountId)
                    .setField(Account.Name, TEST_ACCOUNT_NAME)
                    .setField(Account.RecordTypeId, BUSNINESS_RECORD_TYPE_ID)
            );

        Xref__c testXref = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Id, xrefId)
            .setField(Xref__c.Business_Reference__c, bizRefId)
            .setField(Xref__c.Xref_Status__c, XREF_STATUS_ACTIVE)
            .setField(Xref__c.BusinessID__c, BUSINESS_ID)
            .setField(Xref__c.Account_Record_Type__c, STORE)
            .setParent('Salesforce_Account_Name__r', testAccount)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IXrefsSelector xrefsSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        mocks.startStubbing();
        mocks.when(xrefsSelectorMock.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                xrefsSelectorMock.selectActiveXrefsBySalesforceAccountName(
                    new Set<Id>{ storeAccountId }
                )
            )
            .thenReturn(new List<Xref__c>{ testXref });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(uowMock);
        Application.SELECTOR.setMock(xrefsSelectorMock);
        Test.startTest();
        XrefAndBizRefService.deactivateChurnedMxXrefs(new Set<Id>{ storeAccountId }, uowMock);
        Test.stopTest();
        System.assertEquals(INACTIVE, testXref.Xref_Status__c, INVALID_ASSERT_MESSAGE);
    }
}