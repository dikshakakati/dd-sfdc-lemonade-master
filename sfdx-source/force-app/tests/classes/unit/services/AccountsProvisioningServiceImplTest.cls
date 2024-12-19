/**
 * @description Test class for AccountsProvisioningServiceImpl
 * Suppressed Warnings since mock verify method does not require System Assert statements.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts, PMD.NcssTypeCount')
public class AccountsProvisioningServiceImplTest {
    private static final String BRAND_NAME = 'US KFC';
    private static final String CURRENCY_CODE_USD = 'USD';
    public static final String PROVISIONING_EVENT_CREATION_METHOD_MANUAL = 'Manual';
    public static final String PROVISIONING_EVENT_CREATION_METHOD_AUTOMATIC = 'Automatic';
    private static final String INACTIVE = 'Inactive';
    private static final String INTEGRATION_STATUS_WAITING_FOR_BUSINESS_PROVISIONING = 'Waiting for Business';
    private static final String INTEGRATION_STATUS_READY_FOR_INTEGRATION = 'Ready for Integration';
    private static final String INTEGRATION_STATUS_FAILURE = 'Failure';
    private static final String INTEGRATION_STATUS_SUCCESS = 'Success';
    private static final String INTEGRATION_STATUS_NEW = 'New';
    private static final String MOCK_BUSINESS_ID = 'mockId123';
    private static final String PRIMARY_VERTICAL_RX = 'Rx';
    private static final String VERTICAL_NAME = 'Restaurant';
    private static final String WORKORDER_TYPE_DRIVE = 'Drive';
    private static final String WORKORDER_TYPE_MARKETPLACE = 'Marketplace';
    private static final string XREF_EXTERNAL_ID = '12345';
    private static final string XREF_EXTERNAL_ID_SOURCE = 'DriveDb';
    private static final String XREF_STATUS_ACTIVE = 'Active';
    private static final String ACCOUNT_PRIMARY_VERTICAL_GIFTS = 'Gifts';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    private static final String ORDER_BACKEND_SYSTEMS = 'MDS;MDS - Catering;DriveDB';
    private static final string XREF_EXTERNAL_ID_SOURCE_MDS = 'MDS';
    private static final String ACCOUNT_DATA_VERIFICATION_STATUS = 'Verified';
    private static final String ADDRESS_VERIFICATION_STATUS = 'Verified';
    private static final String BUNDLED_WITH_MARKETPLACE_YES = 'Yes';
    private static final String DISALLOW_PDOA_OVERRIDE_NO = 'No';
    private static final String DISALLOW_PDOA_OVERRIDE_YES = 'Yes';
    private static final String IN_COVERAGE = 'In Coverage';
    private static final String NET_NEW_SUB_TYPE = 'Net-new Business';
    private static final String AUTO_ACTIVATIONS_SUB_TYPE = 'Auto-Activations';
    private static final String BUSINESS_VERTICAL_NAME = 'Business Vertical';
    private static final String ASSERT_ERROR_MSG = 'Unexpected Error: Integration Status Do Not Match';
    private static final String PROVISIONING_STATUS_READY_FOR_PROVISIONING = 'Ready for Provisioning';
    /**
     * @description Test manual provisioning of store accounts.
     */
    @isTest
    public static void testWhenAccountsAreManuallyCreatedThenProvisioned() {
        Id storeAccountId1 = fflib_IDGenerator.generate(Account.SObjectType);
        Id storeAccountId2 = fflib_IDGenerator.generate(Account.SObjectType);

        Map<String, Set<Id>> storeAccountIdMap = new Map<String, Set<Id>>();
        storeAccountIdMap.put(
            PROVISIONING_EVENT_CREATION_METHOD_MANUAL,
            new Set<Id>{ storeAccountId1, storeAccountId2 }
        );

        Id xrefId1 = Fake.generateId(Xref__c.class);
        Id xrefId2 = Fake.generateId(Xref__c.class);

        Id businessReferenceId1 = Fake.generateId(Business_Reference__c.class);
        Id businessReferenceId2 = Fake.generateId(Business_Reference__c.class);

        List<Xref__c> xrefList = new List<Xref__c>{
            new Xref__c(
                Id = xrefId1,
                Integration_Status__c = INTEGRATION_STATUS_WAITING_FOR_BUSINESS_PROVISIONING,
                Business_Reference__c = businessReferenceId1
            ),
            new Xref__c(
                Id = xrefId2,
                Integration_Status__c = INTEGRATION_STATUS_WAITING_FOR_BUSINESS_PROVISIONING,
                Business_Reference__c = businessReferenceId2
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );

        IXrefsSelector xrefsSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);

        mocks.startStubbing();
        mocks.when(xrefsSelectorMock.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                xrefsSelectorMock.selectBySalesforceAccountName(
                    new Set<Id>{ storeAccountId1, storeAccountId2 }
                )
            )
            .thenReturn(xrefList);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(xrefsSelectorMock);
        Application.UNITOFWORK.setMock(uowMock);

        AccountsProvisioningServiceImpl.provisionMarketplaceAccountsByCreationMethod(
            storeAccountIdMap
        );

        ((IXrefsSelector) mocks.verify(xrefsSelectorMock, 1))
            .selectBySalesforceAccountName(new Set<Id>{ storeAccountId1, storeAccountId2 });

        ((fflib_SObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
    }

    /**
     * @description Test Automatic provisioning for Drive WorkOrders
     */
    @isTest
    public static void testWhenAccountsAreAutomaticCreatedThenInitiateProvisioningForMarketplace() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id businessVerticalId = fflib_IDGenerator.generate(Business_Vertical__c.SObjectType);
        Id brandId = fflib_IDGenerator.generate(Brand__c.SObjectType);

        Fake businessVerticalRxFakeInstance = new Fake(Business_Vertical__c.class)
            .setField(Business_Vertical__c.Name, 'TEST Business Vertical')
            .setField(Business_Vertical__c.Id, businessVerticalId);

        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        parentAccountFakeInstance
            .setField(Account.Business_Vertical__c, businessVerticalId)
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance);
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Fake brandFakeInstance = new Fake(Brand__c.class)
            .setField(Brand__c.Brand_Owner__c, businessAccount.Id)
            .setField(Brand__c.Price_Range__c, null)
            .setField(Brand__c.Name, 'US KFC')
            .setField(Brand__c.Id, brandId);
        Brand__c brandInstance = (Brand__c) ServiceMockDataBuilder.convertToSObject(
            brandFakeInstance
        );
        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_GIFTS
            )
            .setField(Account.ParentId, businessAccount.Id)
            .setField(Account.CurrencyIsoCode, CURRENCY_CODE_USD)
            .setField(Account.Order_Protocol__c, null)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(Account.Primary_Vertical__c, ACCOUNT_PRIMARY_VERTICAL_GIFTS)
            .setField(Account.Business_Vertical__c, businessVerticalId)
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance)
            .setParent('Parent', parentAccountFakeInstance)
            .setParent('Brand__r', brandFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );

        Fake childAccountFakeInstance2 = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_GIFTS
            )
            .setField(Account.ParentId, businessAccount.Id)
            .setField(Account.Order_Protocol__c, null)
            .setField(Account.CurrencyIsoCode, CURRENCY_CODE_USD)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(Account.Primary_Vertical__c, ACCOUNT_PRIMARY_VERTICAL_GIFTS)
            .setField(Account.Business_Vertical__c, businessVerticalId)
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance)
            .setParent('Parent', parentAccountFakeInstance)
            .setParent('Brand__r', brandFakeInstance);
        Account childAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance2
        );
        Fake orderFakeInstance = ServiceMockDataBuilder.createActivationOrderFakeInstance(
                storeAccount.Id
            )
            .setField(Order.Backend_Systems__c, ORDER_BACKEND_SYSTEMS);
        Fake orderFakeInstance2 = ServiceMockDataBuilder.createActivationOrderFakeInstance(
                childAccount.Id
            )
            .setField(Order.Backend_Systems__c, ORDER_BACKEND_SYSTEMS);
        Order orderVar = (Order) ServiceMockDataBuilder.convertToSObject(orderFakeInstance);
        Order order1 = (Order) ServiceMockDataBuilder.convertToSObject(orderFakeInstance2);
        Business_Reference__c businessRef1 = (Business_Reference__c) new Fake(
                Business_Reference__c.class
            )
            .setField(Business_Reference__c.Business_Vertical__c, businessVerticalId)
            .setField(Business_Reference__c.Brand__c, brandInstance.Id)
            .setField(Business_Reference__c.Brand__c, brandId)
            .setField(Business_Reference__c.CurrencyIsoCode, CURRENCY_CODE_USD)
            .setParent('Brand__r', brandFakeInstance)
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance)
            .setFakeId()
            .toSObject();
        Business_Reference__c businessRef2 = (Business_Reference__c) new Fake(
                Business_Reference__c.class
            )
            .setField(Business_Reference__c.Business_Vertical__c, businessVerticalId)
            .setField(Business_Reference__c.Brand__c, brandInstance.Id)
            .setField(Business_Reference__c.Brand__c, brandId)
            .setField(Business_Reference__c.CurrencyIsoCode, CURRENCY_CODE_USD)
            .setParent('Brand__r', brandFakeInstance)
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance)
            .setFakeId()
            .toSObject();
        Map<String, Set<Id>> accountIdsByCreationMethod = new Map<String, Set<Id>>();
        accountIdsByCreationMethod.put(
            PROVISIONING_EVENT_CREATION_METHOD_AUTOMATIC,
            new Set<Id>{ storeAccount.Id, childAccount.Id }
        );
        Map<Id, Set<String>> externalIdSourceWithAccountIdMap = new Map<Id, Set<String>>();
        externalIdSourceWithAccountIdMap.put(
            storeAccount.Id,
            new Set<string>{ 'TEST Business Vertical' }
        );
        externalIdSourceWithAccountIdMap.put(
            childAccount.Id,
            new Set<string>{ 'TEST Business Vertical' }
        );
        Set<Id> accountIdSet = new Set<Id>();
        accountIdSet.addAll(externalIdSourceWithAccountIdMap.keyset());
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Menu_to_be_Completed_By__c, null);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Fake childWorkOrderStoreCAFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                childAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id);
        WorkOrder childWorkOrderStoreCA = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderStoreCAFakeInstance
        );
        List<Account> accountsList = new List<Account>{ storeAccount, childAccount };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IBusinessReferencesSelector businessRefSelectorMock = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IOrdersSelector mockOrdersSelector = (IOrdersSelector) mocks.mock(IOrdersSelector.class);
        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                accountSelectorMock.selectAccountsWithXrefs(
                    new Set<Id>{ storeAccount.Id, childAccount.Id }
                )
            )
            .thenReturn(accountsList);
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersByAccountIds(
                    new Set<Id>{ storeAccount.Id, childAccount.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{ childWorkOrder, childWorkOrderStoreCA });
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersBySegment(
                    new Set<Id>{ storeAccount.Id, childAccount.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(mockOrdersSelector.sObjectType()).thenReturn(Order.SObjectType);
        mocks.when(
                mockOrdersSelector.selectOrdersByAccountIds(
                    new Set<Id>{ storeAccount.Id, childAccount.Id }
                )
            )
            .thenReturn(new List<Order>{ orderVar, order1 });
        mocks.when(businessRefSelectorMock.sObjectType())
            .thenReturn(Business_Reference__c.SObjectType);
        mocks.when(
                businessRefSelectorMock.selectByBusinessVerticalsBrandNamesAndCurrencyISOCodes(
                    new Set<String>{ businessVerticalId },
                    new Set<String>{ BRAND_NAME },
                    new Set<String>{ CURRENCY_CODE_USD }
                )
            )
            .thenReturn(new List<Business_Reference__c>{ businessRef1, businessRef2 });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockOrdersSelector);
        Application.SELECTOR.setMock(businessRefSelectorMock);
        Application.UNITOFWORK.setMock(uowMock);
        AccountsProvisioningServiceImpl.provisionMarketplaceAccountsByCreationMethod(
            accountIdsByCreationMethod
        );
        ((fflib_SObjectUnitOfWork) mocks.verify(uowMock, 2)).commitWork();
    }

    /**
     * @description It is used to test whether provisioning is initiated and the xref's
     * status is updated when accounts are automatically created.
     */
    @isTest
    public static void testWhenAccountsAreAutomaticCreatedThenInitiateProvisioningAndUpdateStatusForMarketplaceXrefs() {
        Id businessReferenceId = Fake.generateId(Business_Reference__c.class);
        Id storeId = fflib_IDGenerator.generate(Account.SObjectType);
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
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
            .setField(Account.Id, storeId)
            .setField(Account.Proposed_Date_of_Activation__c, System.today())
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
                }
            );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake orderFakeInstance = ServiceMockDataBuilder.createActivationOrderFakeInstance(
                storeAccount.Id
            )
            .setField(Order.Backend_Systems__c, ORDER_BACKEND_SYSTEMS);
        Order orderVar = (Order) ServiceMockDataBuilder.convertToSObject(orderFakeInstance);
        Map<String, Set<Id>> accountIdsByCreationMethod = new Map<String, Set<Id>>();
        accountIdsByCreationMethod.put(
            PROVISIONING_EVENT_CREATION_METHOD_AUTOMATIC,
            new Set<Id>{ storeAccount.Id }
        );
        Map<Id, Set<String>> externalIdSourceWithAccountIdMap = new Map<Id, Set<String>>();
        externalIdSourceWithAccountIdMap.put(
            storeAccount.Id,
            new Set<string>{ ACCOUNT_PRIMARY_VERTICAL_GIFTS }
        );
        Set<Id> accountIdSet = new Set<Id>();
        accountIdSet.addAll(externalIdSourceWithAccountIdMap.keyset());
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentBusinessAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Menu_to_be_Completed_By__c, null);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Id mockBVId = fflib_IDGenerator.generate(Business_Vertical__c.SObjectType);
        List<Business_Vertical__c> businessVerticalsRecords = new List<Business_Vertical__c>{
            new Business_Vertical__c(
                Id = mockBVId,
                Active__c = true,
                Description__c = 'for Unit Testing',
                Menu_UI_Type__c = 'Restaurant',
                Primary_Vertical__c = 'Rx',
                Product__c = 'Marketplace',
                Vertical_Name__c = 'Restaurant',
                Business_Vertical_ID__c = ''
            )
        };
        List<Account> accountsList = new List<Account>{ storeAccount };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IBusinessReferencesSelector businessRefSelectorMock = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IOrdersSelector mockOrdersSelector = (IOrdersSelector) mocks.mock(IOrdersSelector.class);
        IBusinessVerticalsSelector mockBusinessVerticalsSelector = (IBusinessVerticalsSelector) mocks.mock(
            IBusinessVerticalsSelector.class
        );
        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountSelectorMock.selectAccountsWithXrefs(new Set<Id>{ storeAccount.Id }))
            .thenReturn(accountsList);
        mocks.when(accountSelectorMock.selectAccountsWithBrandName(new Set<Id>{ storeAccount.Id }))
            .thenReturn(accountsList);
        mocks.when(mockBusinessVerticalsSelector.sObjectType())
            .thenReturn(Business_Vertical__c.SObjectType);
        mocks.when(mockBusinessVerticalsSelector.selectPrimaryVerticalRxRecord())
            .thenReturn(businessVerticalsRecords);
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersByAccountIds(new Set<Id>{ storeAccount.Id })
            )
            .thenReturn(new List<WorkOrder>{ childWorkOrder });
        mocks.when(mockWorkOrdersSelector.selectWorkOrdersBySegment(new Set<Id>{ storeAccount.Id }))
            .thenReturn(new List<WorkOrder>{});
        mocks.when(mockOrdersSelector.sObjectType()).thenReturn(Order.SObjectType);
        mocks.when(mockOrdersSelector.selectOrdersByAccountIds(new Set<Id>{ storeAccount.Id }))
            .thenReturn(new List<Order>{ orderVar });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockOrdersSelector);
        Application.SELECTOR.setMock(businessRefSelectorMock);
        Application.SELECTOR.setMock(mockBusinessVerticalsSelector);
        Application.UNITOFWORK.setMock(uowMock);
        AccountsProvisioningService.provisionMarketplaceAccountsByCreationMethod(
            accountIdsByCreationMethod
        );
        ((fflib_SObjectUnitOfWork) mocks.verify(uowMock, 2)).commitWork();
    }

    /**
     * @description It is used to test whether provisioning is initiated and the xref's
     * status is updated when accounts are automatically created.
     */
    @isTest
    public static void testWhenSMBAccountsAreAutomaticCreatedThenInitiateProvisioning() {
        Id businessReferenceId = Fake.generateId(Business_Reference__c.class);
        Id storeId = fflib_IDGenerator.generate(Account.SObjectType);
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id businessVerticalId = fflib_IDGenerator.generate(Business_Vertical__c.SObjectType);
        Fake businessVerticalRxFakeInstance = new Fake(Business_Vertical__c.class)
            .setField(Business_Vertical__c.Name, 'TEST Business Vertical')
            .setField(Business_Vertical__c.Id, businessVerticalId);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        parentBusinessAccountFakeInstance.setField(Account.Business_Vertical__c, businessVerticalId)
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance);
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Id brandId = fflib_IDGenerator.generate(Brand__c.SObjectType);
        Fake brandFakeInstance = new Fake(Brand__c.class)
            .setField(Brand__c.Brand_Owner__c, parentBusinessAccount.Id)
            .setField(Brand__c.Price_Range__c, null)
            .setField(Brand__c.Name, 'US KFC')
            .setField(Brand__c.Id, brandId);
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_GIFTS
            )
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(Account.Data_Verification_Status__c, ACCOUNT_DATA_VERIFICATION_STATUS)
            .setField(Account.Id, storeId)
            .setField(Account.CurrencyIsoCode, CURRENCY_CODE_USD)
            .setField(Account.Proposed_Date_of_Activation__c, System.today())
            .setField(Account.Activation_Status__c, INACTIVE)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(Account.Business_Vertical__c, businessVerticalId)
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance)
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
                }
            )
            .setParent('Brand__r', brandFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake orderFakeInstance = ServiceMockDataBuilder.createActivationOrderFakeInstance(
                storeAccount.Id
            )
            .setField(Order.Backend_Systems__c, ORDER_BACKEND_SYSTEMS);

        Order orderVar = (Order) ServiceMockDataBuilder.convertToSObject(orderFakeInstance);
        Map<String, Set<Id>> accountIdsByCreationMethod = new Map<String, Set<Id>>();
        accountIdsByCreationMethod.put(
            PROVISIONING_EVENT_CREATION_METHOD_AUTOMATIC,
            new Set<Id>{ storeAccount.Id }
        );
        Map<Id, Set<String>> externalIdSourceWithAccountIdMap = new Map<Id, Set<String>>();
        externalIdSourceWithAccountIdMap.put(
            storeAccount.Id,
            new Set<string>{ ACCOUNT_PRIMARY_VERTICAL_GIFTS }
        );
        Set<Id> accountIdSet = new Set<Id>();
        accountIdSet.addAll(externalIdSourceWithAccountIdMap.keyset());
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentBusinessAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Menu_to_be_Completed_By__c, null);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setField(WorkOrder.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setField(WorkOrder.AccountId, storeAccount.Id)
            .setParent(
                'ParentWorkOrder',
                new Fake(WorkOrder.class)
                    .setField(WorkOrder.Id, parentWorkOrder.Id)
                    .setField(WorkOrder.AccountId, parentBusinessAccount.Id)
                    .setField(
                        WorkOrder.Provisioning_Status__c,
                        PROVISIONING_STATUS_READY_FOR_PROVISIONING
                    )
            );

        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        List<Business_Vertical__c> businessVerticalsRecords = new List<Business_Vertical__c>{
            new Business_Vertical__c(
                Active__c = true,
                Description__c = 'for Unit Testing',
                Menu_UI_Type__c = 'Restaurant',
                Primary_Vertical__c = 'Rx',
                Product__c = 'Marketplace',
                Vertical_Name__c = 'Grocery',
                Business_Vertical_ID__c = ''
            )
        };
        List<Account> accountsList = new List<Account>{ storeAccount };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IBusinessReferencesSelector businessRefSelectorMock = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IOrdersSelector mockOrdersSelector = (IOrdersSelector) mocks.mock(IOrdersSelector.class);
        IBusinessVerticalsSelector mockBusinessVerticalsSelector = (IBusinessVerticalsSelector) mocks.mock(
            IBusinessVerticalsSelector.class
        );
        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountSelectorMock.selectAccountsWithXrefs(new Set<Id>{ storeAccount.Id }))
            .thenReturn(accountsList);
        mocks.when(accountSelectorMock.selectAccountsWithBrandName(new Set<Id>{ storeAccount.Id }))
            .thenReturn(accountsList);
        mocks.when(
                mockWorkOrdersSelector.selectBusinessReferenceCreationEligibleWorkOrdersByAccountIds(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{ childWorkOrder });
        mocks.when(
                mockWorkOrdersSelector.selectByParentWorkOrderIds(new Set<Id>{ parentWorkOrder.Id })
            )
            .thenReturn(new List<WorkOrder>{ childWorkOrder });
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersByAccountIds(new Set<Id>{ storeAccount.Id })
            )
            .thenReturn(new List<WorkOrder>{ childWorkOrder });
        mocks.when(mockWorkOrdersSelector.selectWorkOrdersBySegment(new Set<Id>{ storeAccount.Id }))
            .thenReturn(new List<WorkOrder>{ childWorkOrder });
        mocks.when(mockOrdersSelector.sObjectType()).thenReturn(Order.SObjectType);
        mocks.when(mockOrdersSelector.selectOrdersByAccountIds(new Set<Id>{ storeAccount.Id }))
            .thenReturn(new List<Order>{ orderVar });
        mocks.when(mockBusinessVerticalsSelector.sObjectType())
            .thenReturn(Business_Vertical__c.SObjectType);
        mocks.when(mockBusinessVerticalsSelector.selectPrimaryVerticalRxRecord())
            .thenReturn(businessVerticalsRecords);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockOrdersSelector);
        Application.SELECTOR.setMock(businessRefSelectorMock);
        Application.SELECTOR.setMock(mockBusinessVerticalsSelector);
        Application.UNITOFWORK.setMock(uowMock);
        AccountsProvisioningService.provisionMarketplaceAccountsByCreationMethod(
            accountIdsByCreationMethod
        );
        ((fflib_SObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
    }

    /**
     * @description Test Automatic provisioning for Drive WorkOrders.
     */
    @isTest
    public static void testWhenAccountsAreAutomaticCreatedThenInitiateProvisioningForMarketplaceWithXrefs() {
        Id storeId = fflib_IDGenerator.generate(Account.SObjectType);
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id businessVerticalId = fflib_IDGenerator.generate(Business_Vertical__c.SObjectType);
        Fake businessVerticalRxFakeInstance = new Fake(Business_Vertical__c.class)
            .setField(Business_Vertical__c.Name, 'TEST Business Vertical')
            .setField(Business_Vertical__c.Id, businessVerticalId);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        parentBusinessAccountFakeInstance.setField(Account.Business_Vertical__c, businessVerticalId)
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance);
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Id brandId = fflib_IDGenerator.generate(Brand__c.SObjectType);
        Fake brandFakeInstance = new Fake(Brand__c.class)
            .setField(Brand__c.Brand_Owner__c, parentBusinessAccount.Id)
            .setField(Brand__c.Price_Range__c, null)
            .setField(Brand__c.Name, 'US KFC')
            .setField(Brand__c.Id, brandId);
        Brand__c brandInstance = (Brand__c) ServiceMockDataBuilder.convertToSObject(
            brandFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_GIFTS
            )
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(Account.Data_Verification_Status__c, ACCOUNT_DATA_VERIFICATION_STATUS)
            .setField(Account.Id, storeId)
            .setField(Account.CurrencyIsoCode, CURRENCY_CODE_USD)
            .setField(Account.Proposed_Date_of_Activation__c, System.today())
            .setField(Account.Business_Vertical__c, businessVerticalId)
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance)
            .setChildren(
                'Xrefs__r',
                new List<Fake>{
                    new Fake(Xref__c.class)
                        .setField(Xref__c.Id, xrefId)
                        .setField(Xref__c.External_ID__c, XREF_EXTERNAL_ID)
                        .setField(Xref__c.External_ID_Source__c, XREF_EXTERNAL_ID_SOURCE_MDS)
                        .setField(Xref__c.Salesforce_Account_Name__c, storeId)
                        .setField(Xref__c.Xref_Status__c, XREF_STATUS_ACTIVE)
                }
            )
            .setParent('Brand__r', brandFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake orderFakeInstance = ServiceMockDataBuilder.createActivationOrderFakeInstance(
                storeAccount.Id
            )
            .setField(Order.Backend_Systems__c, ORDER_BACKEND_SYSTEMS);

        Order orderVar = (Order) ServiceMockDataBuilder.convertToSObject(orderFakeInstance);
        Business_Reference__c businessRef1 = (Business_Reference__c) new Fake(
                Business_Reference__c.class
            )
            .setField(Business_Reference__c.Business_Vertical__c, businessVerticalId)
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance)
            .setField(Business_Reference__c.Brand__c, brandInstance.Id)
            .setField(Business_Reference__c.Brand__c, brandId)
            .setField(Business_Reference__c.CurrencyIsoCode, CURRENCY_CODE_USD)
            .setParent('Brand__r', brandFakeInstance)
            .setFakeId()
            .toSObject();
        Business_Reference__c businessRef2 = (Business_Reference__c) new Fake(
                Business_Reference__c.class
            )
            .setField(Business_Reference__c.Business_Vertical__c, businessVerticalId)
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance)
            .setField(Business_Reference__c.Brand__c, brandInstance.Id)
            .setField(Business_Reference__c.Brand__c, brandId)
            .setField(Business_Reference__c.CurrencyIsoCode, CURRENCY_CODE_USD)
            .setParent('Brand__r', brandFakeInstance)
            .setFakeId()
            .toSObject();
        Map<String, Set<Id>> accountIdsByCreationMethod = new Map<String, Set<Id>>();
        accountIdsByCreationMethod.put(
            PROVISIONING_EVENT_CREATION_METHOD_AUTOMATIC,
            new Set<Id>{ storeAccount.Id }
        );
        Map<Id, Set<String>> externalIdSourceWithAccountIdMap = new Map<Id, Set<String>>();
        externalIdSourceWithAccountIdMap.put(
            storeAccount.Id,
            new Set<string>{ ACCOUNT_PRIMARY_VERTICAL_GIFTS }
        );
        Set<Id> accountIdSet = new Set<Id>();
        accountIdSet.addAll(externalIdSourceWithAccountIdMap.keyset());
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentBusinessAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Menu_to_be_Completed_By__c, null);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        List<Business_Vertical__c> businessVerticalsRecords = new List<Business_Vertical__c>{
            new Business_Vertical__c(
                Active__c = true,
                Description__c = 'for Unit Testing',
                Menu_UI_Type__c = 'Restaurant',
                Primary_Vertical__c = 'Rx',
                Product__c = 'Marketplace',
                Vertical_Name__c = 'Grocery',
                Business_Vertical_ID__c = ''
            )
        };
        List<Account> accountsList = new List<Account>{ storeAccount };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IBusinessReferencesSelector businessRefSelectorMock = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IOrdersSelector mockOrdersSelector = (IOrdersSelector) mocks.mock(IOrdersSelector.class);
        IBusinessVerticalsSelector mockBusinessVerticalsSelector = (IBusinessVerticalsSelector) mocks.mock(
            IBusinessVerticalsSelector.class
        );
        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountSelectorMock.selectAccountsWithXrefs(new Set<Id>{ storeAccount.Id }))
            .thenReturn(accountsList);
        mocks.when(accountSelectorMock.selectAccountsWithBrandName(new Set<Id>{ storeAccount.Id }))
            .thenReturn(accountsList);
        mocks.when(mockBusinessVerticalsSelector.sObjectType())
            .thenReturn(Business_Vertical__c.SObjectType);
        mocks.when(mockBusinessVerticalsSelector.selectPrimaryVerticalRxRecord())
            .thenReturn(businessVerticalsRecords);
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersByAccountIds(new Set<Id>{ storeAccount.Id })
            )
            .thenReturn(new List<WorkOrder>{ childWorkOrder });
        mocks.when(mockWorkOrdersSelector.selectWorkOrdersBySegment(new Set<Id>{ storeAccount.Id }))
            .thenReturn(new List<WorkOrder>{});
        mocks.when(mockOrdersSelector.sObjectType()).thenReturn(Order.SObjectType);
        mocks.when(mockOrdersSelector.selectOrdersByAccountIds(new Set<Id>{ storeAccount.Id }))
            .thenReturn(new List<Order>{ orderVar });
        mocks.when(businessRefSelectorMock.sObjectType())
            .thenReturn(Business_Reference__c.SObjectType);
        mocks.when(
                businessRefSelectorMock.selectByBusinessVerticalsBrandNamesAndCurrencyISOCodes(
                    new Set<String>{ businessVerticalId },
                    new Set<String>{ BRAND_NAME },
                    new Set<String>{ CURRENCY_CODE_USD }
                )
            )
            .thenReturn(new List<Business_Reference__c>{ businessRef1, businessRef2 });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockOrdersSelector);
        Application.SELECTOR.setMock(businessRefSelectorMock);
        Application.SELECTOR.setMock(mockBusinessVerticalsSelector);
        Application.UNITOFWORK.setMock(uowMock);
        AccountsProvisioningService.provisionMarketplaceAccountsByCreationMethod(
            accountIdsByCreationMethod
        );
        ((fflib_SObjectUnitOfWork) mocks.verify(uowMock, 2)).commitWork();
    }

    /*
     * @description Test when the provisioning is triggered for an amendement scenario then
     * no new xref is created.
     */
    @isTest
    public static void testWhenAmendmentProvisioningThenNoNewXrefCreated() {
        Id storeId = fflib_IDGenerator.generate(Account.SObjectType);
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
            .setField(Account.Id, storeId)
            .setField(Account.Proposed_Date_of_Activation__c, System.today());
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Map<String, Set<Id>> accountIdsByCreationMethod = new Map<String, Set<Id>>();
        accountIdsByCreationMethod.put(
            PROVISIONING_EVENT_CREATION_METHOD_AUTOMATIC,
            new Set<Id>{ storeAccount.Id }
        );
        Map<Id, Set<String>> externalIdSourceWithAccountIdMap = new Map<Id, Set<String>>();
        externalIdSourceWithAccountIdMap.put(
            storeAccount.Id,
            new Set<string>{ ACCOUNT_PRIMARY_VERTICAL_GIFTS }
        );
        Set<Id> accountIdSet = new Set<Id>();
        accountIdSet.addAll(externalIdSourceWithAccountIdMap.keyset());
        List<Account> accountsList = new List<Account>{ storeAccount };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountSelectorMock.selectAccountsWithXrefs(new Set<Id>{ storeAccount.Id }))
            .thenReturn(accountsList);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.UNITOFWORK.setMock(uowMock);
        Test.startTest();
        AccountsProvisioningServiceImpl.provisionMarketplaceAccountsByCreationMethod(
            accountIdsByCreationMethod,
            true
        );
        Test.stopTest();
        ((fflib_SObjectUnitOfWork) mocks.verify(uowMock, 0)).commitWork();
    }

    /**
     * @description To test automatic provisioning when Business Reference "Integration Status" is
     * 'New' then update Xref "Integration Status" to 'Waiting for Business'.
     */
    @isTest
    public static void testWhenAccountCreationMethodAutomaticAndBizRefIntegrationStatusNewThenInitiateProvisioningWithXrefIntegrationStatusWaitingForBusiness() {
        Id storeId = fflib_IDGenerator.generate(Account.SObjectType);
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id businessVerticalId = fflib_IDGenerator.generate(Business_Vertical__c.SObjectType);
        Id businessReferenceId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);
        Fake businessVerticalRxFakeInstance = new Fake(Business_Vertical__c.class)
            .setField(Business_Vertical__c.Name, BUSINESS_VERTICAL_NAME)
            .setField(Business_Vertical__c.Id, businessVerticalId);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        parentBusinessAccountFakeInstance.setField(Account.Business_Vertical__c, businessVerticalId)
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance);
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Id brandId = fflib_IDGenerator.generate(Brand__c.SObjectType);
        Fake brandFakeInstance = new Fake(Brand__c.class)
            .setField(Brand__c.Price_Range__c, null)
            .setField(Brand__c.Name, BRAND_NAME)
            .setField(Brand__c.Id, brandId);
        Fake businessRefFakeInstance = new Fake(Business_Reference__c.class)
            .setField(Business_Reference__c.Business_Vertical__c, businessVerticalId)
            .setField(Business_Reference__c.CurrencyIsoCode, CURRENCY_CODE_USD)
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance)
            .setField(Business_Reference__c.Id, businessReferenceId)
            .setField(Business_Reference__c.Business_Vertical__c, businessVerticalId)
            .setField(Business_Reference__c.Integration_Status__c, INTEGRATION_STATUS_NEW)
            .setParent('Brand__r', brandFakeInstance);
        Business_Reference__c businessReference = (Business_Reference__c) ServiceMockDataBuilder.convertToSObject(
            businessRefFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_GIFTS
            )
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(Account.Data_Verification_Status__c, ACCOUNT_DATA_VERIFICATION_STATUS)
            .setField(Account.Id, storeId)
            .setField(Account.currencyIsoCode, CURRENCY_CODE_USD)
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
            )
            .setParent('Brand__r', brandFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake orderFakeInstance = ServiceMockDataBuilder.createActivationOrderFakeInstance(
                storeAccount.Id
            )
            .setField(Order.Backend_Systems__c, ORDER_BACKEND_SYSTEMS);

        Order orderVar = (Order) ServiceMockDataBuilder.convertToSObject(orderFakeInstance);
        Map<String, Set<Id>> accountIdsByCreationMethod = new Map<String, Set<Id>>();
        accountIdsByCreationMethod.put(
            PROVISIONING_EVENT_CREATION_METHOD_AUTOMATIC,
            new Set<Id>{ storeAccount.Id }
        );
        Map<Id, Set<String>> externalIdSourceWithAccountIdMap = new Map<Id, Set<String>>();
        externalIdSourceWithAccountIdMap.put(
            storeAccount.Id,
            new Set<string>{ ACCOUNT_PRIMARY_VERTICAL_GIFTS }
        );
        Set<Id> accountIdSet = new Set<Id>();
        accountIdSet.addAll(externalIdSourceWithAccountIdMap.keyset());
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentBusinessAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Menu_to_be_Completed_By__c, null);

        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        List<Business_Vertical__c> businessVerticalsRecords = new List<Business_Vertical__c>{
            new Business_Vertical__c(
                Active__c = true,
                Description__c = 'for Unit Testing',
                Menu_UI_Type__c = 'Restaurant',
                Primary_Vertical__c = 'Rx',
                Product__c = 'Marketplace',
                Vertical_Name__c = 'Grocery',
                Business_Vertical_ID__c = ''
            )
        };
        List<Account> accountsList = new List<Account>{ storeAccount };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IBusinessReferencesSelector businessRefSelectorMock = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IOrdersSelector mockOrdersSelector = (IOrdersSelector) mocks.mock(IOrdersSelector.class);
        IBusinessVerticalsSelector mockBusinessVerticalsSelector = (IBusinessVerticalsSelector) mocks.mock(
            IBusinessVerticalsSelector.class
        );
        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountSelectorMock.selectAccountsWithXrefs(new Set<Id>{ storeAccount.Id }))
            .thenReturn(accountsList);
        mocks.when(accountSelectorMock.selectAccountsWithBrandName(new Set<Id>{ storeAccount.Id }))
            .thenReturn(accountsList);
        mocks.when(mockBusinessVerticalsSelector.sObjectType())
            .thenReturn(Business_Vertical__c.SObjectType);
        mocks.when(mockBusinessVerticalsSelector.selectPrimaryVerticalRxRecord())
            .thenReturn(businessVerticalsRecords);
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersByAccountIds(new Set<Id>{ storeAccount.Id })
            )
            .thenReturn(new List<WorkOrder>{ childWorkOrder });
        mocks.when(mockOrdersSelector.sObjectType()).thenReturn(Order.SObjectType);
        mocks.when(mockOrdersSelector.selectOrdersByAccountIds(new Set<Id>{ storeAccount.Id }))
            .thenReturn(new List<Order>{ orderVar });
        mocks.when(mockWorkOrdersSelector.selectWorkOrdersBySegment(new Set<Id>{ storeAccount.Id }))
            .thenReturn(new List<WorkOrder>{});
        mocks.when(businessRefSelectorMock.sObjectType())
            .thenReturn(Business_Reference__c.SObjectType);
        mocks.when(
                businessRefSelectorMock.selectByBusinessVerticalsBrandNamesAndCurrencyISOCodes(
                    new Set<String>{ businessVerticalId },
                    new Set<String>{ BRAND_NAME },
                    new Set<String>{ CURRENCY_CODE_USD }
                )
            )
            .thenReturn(new List<Business_Reference__c>{ businessReference });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockOrdersSelector);
        Application.SELECTOR.setMock(businessRefSelectorMock);
        Application.SELECTOR.setMock(mockBusinessVerticalsSelector);
        Application.UNITOFWORK.setMock(uowMock);
        AccountsProvisioningService.provisionMarketplaceAccountsByCreationMethod(
            accountIdsByCreationMethod
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Xref__c.Id => xrefId,
                        Xref__c.Integration_Status__c => INTEGRATION_STATUS_WAITING_FOR_BUSINESS_PROVISIONING
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Business_Reference__c.Id => businessReferenceId,
                        Business_Reference__c.Integration_Status__c => INTEGRATION_STATUS_READY_FOR_INTEGRATION
                    }
                )
            );
    }
    /**
     * @description To test automatic provisioning when Business Reference "Integration Status" is
     * 'Failure' then update Xref "Integration Status" to 'Waiting for Business'.
     */
    @isTest
    public static void testWhenAccountCreationMethodAutomaticAndBizRefIntegrationStatusFailureThenInitiateProvisioningWithXrefIntegrationStatusWaitingForBusiness() {
        Id storeId = fflib_IDGenerator.generate(Account.SObjectType);
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id businessVerticalId = fflib_IDGenerator.generate(Business_Vertical__c.SObjectType);
        Id businessReferenceId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);
        Fake businessVerticalRxFakeInstance = new Fake(Business_Vertical__c.class)
            .setField(Business_Vertical__c.Name, BUSINESS_VERTICAL_NAME)
            .setField(Business_Vertical__c.Id, businessVerticalId);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        parentBusinessAccountFakeInstance.setField(Account.Business_Vertical__c, businessVerticalId)
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance);
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Id brandId = fflib_IDGenerator.generate(Brand__c.SObjectType);
        Fake brandFakeInstance = new Fake(Brand__c.class)
            .setField(Brand__c.Price_Range__c, null)
            .setField(Brand__c.Name, BRAND_NAME)
            .setField(Brand__c.Id, brandId);
        Fake businessRefFakeInstance = new Fake(Business_Reference__c.class)
            .setField(Business_Reference__c.Id, businessReferenceId)
            .setField(Business_Reference__c.CurrencyIsoCode, CURRENCY_CODE_USD)
            .setField(Business_Reference__c.Business_Vertical__c, businessVerticalId)
            .setField(Business_Reference__c.Integration_Status__c, INTEGRATION_STATUS_FAILURE)
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance)
            .setParent('Brand__r', brandFakeInstance);

        Business_Reference__c businessReference = (Business_Reference__c) ServiceMockDataBuilder.convertToSObject(
            businessRefFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_GIFTS
            )
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(Account.Data_Verification_Status__c, ACCOUNT_DATA_VERIFICATION_STATUS)
            .setField(Account.Id, storeId)
            .setField(Account.currencyIsoCode, CURRENCY_CODE_USD)
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
            )
            .setParent('Brand__r', brandFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake orderFakeInstance = ServiceMockDataBuilder.createActivationOrderFakeInstance(
                storeAccount.Id
            )
            .setField(Order.Backend_Systems__c, ORDER_BACKEND_SYSTEMS);
        Order orderVar = (Order) ServiceMockDataBuilder.convertToSObject(orderFakeInstance);
        Map<String, Set<Id>> accountIdsByCreationMethod = new Map<String, Set<Id>>();
        accountIdsByCreationMethod.put(
            PROVISIONING_EVENT_CREATION_METHOD_AUTOMATIC,
            new Set<Id>{ storeAccount.Id }
        );
        Map<Id, Set<String>> externalIdSourceWithAccountIdMap = new Map<Id, Set<String>>();
        externalIdSourceWithAccountIdMap.put(
            storeAccount.Id,
            new Set<string>{ ACCOUNT_PRIMARY_VERTICAL_GIFTS }
        );
        Set<Id> accountIdSet = new Set<Id>();
        accountIdSet.addAll(externalIdSourceWithAccountIdMap.keyset());
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentBusinessAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Menu_to_be_Completed_By__c, null);

        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        List<Business_Vertical__c> businessVerticalsRecords = new List<Business_Vertical__c>{
            new Business_Vertical__c(
                Active__c = true,
                Description__c = 'for Unit Testing',
                Menu_UI_Type__c = 'Restaurant',
                Primary_Vertical__c = 'Rx',
                Product__c = 'Marketplace',
                Vertical_Name__c = 'Grocery',
                Business_Vertical_ID__c = ''
            )
        };
        List<Account> accountsList = new List<Account>{ storeAccount };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IBusinessReferencesSelector businessRefSelectorMock = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IOrdersSelector mockOrdersSelector = (IOrdersSelector) mocks.mock(IOrdersSelector.class);
        IBusinessVerticalsSelector mockBusinessVerticalsSelector = (IBusinessVerticalsSelector) mocks.mock(
            IBusinessVerticalsSelector.class
        );
        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountSelectorMock.selectAccountsWithXrefs(new Set<Id>{ storeAccount.Id }))
            .thenReturn(accountsList);
        mocks.when(accountSelectorMock.selectAccountsWithBrandName(new Set<Id>{ storeAccount.Id }))
            .thenReturn(accountsList);
        mocks.when(mockBusinessVerticalsSelector.sObjectType())
            .thenReturn(Business_Vertical__c.SObjectType);
        mocks.when(mockBusinessVerticalsSelector.selectPrimaryVerticalRxRecord())
            .thenReturn(businessVerticalsRecords);
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersByAccountIds(new Set<Id>{ storeAccount.Id })
            )
            .thenReturn(new List<WorkOrder>{ childWorkOrder });
        mocks.when(mockOrdersSelector.sObjectType()).thenReturn(Order.SObjectType);
        mocks.when(mockOrdersSelector.selectOrdersByAccountIds(new Set<Id>{ storeAccount.Id }))
            .thenReturn(new List<Order>{ orderVar });
        mocks.when(mockWorkOrdersSelector.selectWorkOrdersBySegment(new Set<Id>{ storeAccount.Id }))
            .thenReturn(new List<WorkOrder>{});
        mocks.when(businessRefSelectorMock.sObjectType())
            .thenReturn(Business_Reference__c.SObjectType);
        mocks.when(
                businessRefSelectorMock.selectByBusinessVerticalsBrandNamesAndCurrencyISOCodes(
                    new Set<String>{ businessVerticalId },
                    new Set<String>{ BRAND_NAME },
                    new Set<String>{ CURRENCY_CODE_USD }
                )
            )
            .thenReturn(new List<Business_Reference__c>{ businessReference });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockOrdersSelector);
        Application.SELECTOR.setMock(businessRefSelectorMock);
        Application.SELECTOR.setMock(mockBusinessVerticalsSelector);

        Application.UNITOFWORK.setMock(uowMock);
        AccountsProvisioningService.provisionMarketplaceAccountsByCreationMethod(
            accountIdsByCreationMethod
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Xref__c.Id => xrefId,
                        Xref__c.Integration_Status__c => INTEGRATION_STATUS_WAITING_FOR_BUSINESS_PROVISIONING
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Business_Reference__c.Id => businessReferenceId,
                        Business_Reference__c.Integration_Status__c => INTEGRATION_STATUS_READY_FOR_INTEGRATION
                    }
                )
            );
    }

    /**
     * @description To test automatic provisioning when Business Reference "Integration Status" is
     * 'Success' then update Xref "Integration Status" to 'Ready for Integration'.
     */
    @isTest
    public static void testWhenAccountCreationMethodAutomaticAndBizRefIntegrationStatusSuccessThenInitiateProvisioningWithXrefIntegrationStatusReadyForIntegration() {
        Id storeId = fflib_IDGenerator.generate(Account.SObjectType);
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id businessVerticalId = fflib_IDGenerator.generate(Business_Vertical__c.SObjectType);
        Id businessReferenceId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);
        Fake businessVerticalRxFakeInstance = new Fake(Business_Vertical__c.class)
            .setField(Business_Vertical__c.Name, BUSINESS_VERTICAL_NAME)
            .setField(Business_Vertical__c.Id, businessVerticalId);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        parentBusinessAccountFakeInstance.setField(Account.Business_Vertical__c, businessVerticalId)
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance);
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Id brandId = fflib_IDGenerator.generate(Brand__c.SObjectType);
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
        Business_Reference__c businessReference = (Business_Reference__c) ServiceMockDataBuilder.convertToSObject(
            businessRefFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
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
            )
            .setParent('Brand__r', brandFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake orderFakeInstance = ServiceMockDataBuilder.createActivationOrderFakeInstance(
                storeAccount.Id
            )
            .setField(Order.Backend_Systems__c, ORDER_BACKEND_SYSTEMS);
        Order orderVar = (Order) ServiceMockDataBuilder.convertToSObject(orderFakeInstance);
        Map<String, Set<Id>> accountIdsByCreationMethod = new Map<String, Set<Id>>();
        accountIdsByCreationMethod.put(
            PROVISIONING_EVENT_CREATION_METHOD_AUTOMATIC,
            new Set<Id>{ storeAccount.Id }
        );
        Map<Id, Set<String>> externalIdSourceWithAccountIdMap = new Map<Id, Set<String>>();
        externalIdSourceWithAccountIdMap.put(
            storeAccount.Id,
            new Set<string>{ ACCOUNT_PRIMARY_VERTICAL_GIFTS }
        );
        Set<Id> accountIdSet = new Set<Id>();
        accountIdSet.addAll(externalIdSourceWithAccountIdMap.keyset());
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentBusinessAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Menu_to_be_Completed_By__c, null);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        List<Business_Vertical__c> businessVerticalsRecords = new List<Business_Vertical__c>{
            new Business_Vertical__c(
                Active__c = true,
                Description__c = 'for Unit Testing',
                Menu_UI_Type__c = 'Restaurant',
                Primary_Vertical__c = 'Rx',
                Product__c = 'Marketplace',
                Vertical_Name__c = 'Grocery',
                Business_Vertical_ID__c = ''
            )
        };
        List<Account> accountsList = new List<Account>{ storeAccount };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IBusinessReferencesSelector businessRefSelectorMock = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IOrdersSelector mockOrdersSelector = (IOrdersSelector) mocks.mock(IOrdersSelector.class);
        IBusinessVerticalsSelector mockBusinessVerticalsSelector = (IBusinessVerticalsSelector) mocks.mock(
            IBusinessVerticalsSelector.class
        );
        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountSelectorMock.selectAccountsWithXrefs(new Set<Id>{ storeAccount.Id }))
            .thenReturn(accountsList);
        mocks.when(accountSelectorMock.selectAccountsWithBrandName(new Set<Id>{ storeAccount.Id }))
            .thenReturn(accountsList);
        mocks.when(mockBusinessVerticalsSelector.sObjectType())
            .thenReturn(Business_Vertical__c.SObjectType);
        mocks.when(mockBusinessVerticalsSelector.selectPrimaryVerticalRxRecord())
            .thenReturn(businessVerticalsRecords);
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersByAccountIds(new Set<Id>{ storeAccount.Id })
            )
            .thenReturn(new List<WorkOrder>{ childWorkOrder });
        mocks.when(mockWorkOrdersSelector.selectWorkOrdersBySegment(new Set<Id>{ storeAccount.Id }))
            .thenReturn(new List<WorkOrder>{});
        mocks.when(mockOrdersSelector.sObjectType()).thenReturn(Order.SObjectType);
        mocks.when(mockOrdersSelector.selectOrdersByAccountIds(new Set<Id>{ storeAccount.Id }))
            .thenReturn(new List<Order>{ orderVar });
        mocks.when(businessRefSelectorMock.sObjectType())
            .thenReturn(Business_Reference__c.SObjectType);
        mocks.when(
                businessRefSelectorMock.selectByBusinessVerticalsBrandNamesAndCurrencyISOCodes(
                    new Set<String>{ businessVerticalId },
                    new Set<String>{ BRAND_NAME },
                    new Set<String>{ CURRENCY_CODE_USD }
                )
            )
            .thenReturn(new List<Business_Reference__c>{ businessReference });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockOrdersSelector);
        Application.SELECTOR.setMock(businessRefSelectorMock);
        Application.SELECTOR.setMock(mockBusinessVerticalsSelector);
        Application.UNITOFWORK.setMock(uowMock);
        AccountsProvisioningService.provisionMarketplaceAccountsByCreationMethod(
            accountIdsByCreationMethod
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Xref__c.Id => xrefId,
                        Xref__c.Integration_Status__c => INTEGRATION_STATUS_READY_FOR_INTEGRATION
                    }
                )
            );
    }

    /**
     * @description To test automatic provisioning when Business Reference "Integration Status" is
     * 'Failure' then update Xref "Integration Status" to 'Waiting for Business' for amendment
     * scenario.
     */
    @isTest
    public static void testWhenAccountCreationMethodAutomaticAndBizRefIntegrationStatusFailureForAmendmentThenInitiateProvisioningWithXrefIntegrationStatusWaitingForBusiness() {
        Id storeId = fflib_IDGenerator.generate(Account.SObjectType);
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id businessVerticalId = fflib_IDGenerator.generate(Business_Vertical__c.SObjectType);
        Id businessReferenceId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);
        Fake businessVerticalRxFakeInstance = new Fake(Business_Vertical__c.class)
            .setField(Business_Vertical__c.Name, BUSINESS_VERTICAL_NAME)
            .setField(Business_Vertical__c.Id, businessVerticalId);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        parentBusinessAccountFakeInstance.setField(Account.Business_Vertical__c, businessVerticalId)
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance);
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake businessRefFakeInstance = new Fake(Business_Reference__c.class)
            .setField(Business_Reference__c.Business_Vertical__c, businessVerticalId)
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance)
            .setField(Business_Reference__c.Id, businessReferenceId)
            .setField(Business_Reference__c.Business_Vertical__c, businessVerticalId)
            .setField(Business_Reference__c.Integration_Status__c, INTEGRATION_STATUS_FAILURE);
        Business_Reference__c businessReference = (Business_Reference__c) ServiceMockDataBuilder.convertToSObject(
            businessRefFakeInstance
        );

        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_GIFTS
            )
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
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
        Fake orderFakeInstance = ServiceMockDataBuilder.createActivationOrderFakeInstance(
                storeAccount.Id
            )
            .setField(Order.Backend_Systems__c, ORDER_BACKEND_SYSTEMS);
        Order orderVar = (Order) ServiceMockDataBuilder.convertToSObject(orderFakeInstance);
        Map<String, Set<Id>> accountIdsByCreationMethod = new Map<String, Set<Id>>();
        accountIdsByCreationMethod.put(
            PROVISIONING_EVENT_CREATION_METHOD_AUTOMATIC,
            new Set<Id>{ storeAccount.Id }
        );
        Map<Id, Set<String>> externalIdSourceWithAccountIdMap = new Map<Id, Set<String>>();
        externalIdSourceWithAccountIdMap.put(
            storeAccount.Id,
            new Set<string>{ ACCOUNT_PRIMARY_VERTICAL_GIFTS }
        );
        Set<Id> accountIdSet = new Set<Id>();
        accountIdSet.addAll(externalIdSourceWithAccountIdMap.keyset());
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentBusinessAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Menu_to_be_Completed_By__c, null);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        List<Business_Vertical__c> businessVerticalsRecords = new List<Business_Vertical__c>{
            new Business_Vertical__c(
                Active__c = true,
                Description__c = 'for Unit Testing',
                Menu_UI_Type__c = 'Restaurant',
                Primary_Vertical__c = 'Rx',
                Product__c = 'Marketplace',
                Vertical_Name__c = 'Grocery',
                Business_Vertical_ID__c = ''
            )
        };
        List<Account> accountsList = new List<Account>{ storeAccount };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IBusinessReferencesSelector businessRefSelectorMock = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IOrdersSelector mockOrdersSelector = (IOrdersSelector) mocks.mock(IOrdersSelector.class);
        IBusinessVerticalsSelector mockBusinessVerticalsSelector = (IBusinessVerticalsSelector) mocks.mock(
            IBusinessVerticalsSelector.class
        );
        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountSelectorMock.selectAccountsWithXrefs(new Set<Id>{ storeAccount.Id }))
            .thenReturn(accountsList);
        mocks.when(accountSelectorMock.selectAccountsWithBrandName(new Set<Id>{ storeAccount.Id }))
            .thenReturn(accountsList);
        mocks.when(mockBusinessVerticalsSelector.sObjectType())
            .thenReturn(Business_Vertical__c.SObjectType);
        mocks.when(mockBusinessVerticalsSelector.selectPrimaryVerticalRxRecord())
            .thenReturn(businessVerticalsRecords);
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersByAccountIds(new Set<Id>{ storeAccount.Id })
            )
            .thenReturn(new List<WorkOrder>{ childWorkOrder });
        mocks.when(mockOrdersSelector.sObjectType()).thenReturn(Order.SObjectType);
        mocks.when(mockOrdersSelector.selectOrdersByAccountIds(new Set<Id>{ storeAccount.Id }))
            .thenReturn(new List<Order>{ orderVar });
        mocks.when(mockWorkOrdersSelector.selectWorkOrdersBySegment(new Set<Id>{ storeAccount.Id }))
            .thenReturn(new List<WorkOrder>{});
        mocks.when(businessRefSelectorMock.sObjectType())
            .thenReturn(Business_Reference__c.SObjectType);
        mocks.when(
                businessRefSelectorMock.selectByBusinessVerticals(
                    new Set<String>{ businessVerticalId }
                )
            )
            .thenReturn(new List<Business_Reference__c>{ businessReference });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockOrdersSelector);
        Application.SELECTOR.setMock(businessRefSelectorMock);
        Application.SELECTOR.setMock(mockBusinessVerticalsSelector);
        Application.UNITOFWORK.setMock(uowMock);
        AccountsProvisioningServiceImpl.provisionMarketplaceAccountsByCreationMethod(
            accountIdsByCreationMethod,
            true
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Xref__c.Id => xrefId,
                        Xref__c.Integration_Status__c => INTEGRATION_STATUS_WAITING_FOR_BUSINESS_PROVISIONING
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Business_Reference__c.Id => businessReferenceId,
                        Business_Reference__c.Integration_Status__c => INTEGRATION_STATUS_READY_FOR_INTEGRATION
                    }
                )
            );
    }

    /**
     * @description To test automatic provisioning when Business Reference "Integration Status" is
     * 'Success' then update Xref "Integration Status" to 'Ready for Integration' for amendment
     * scenario.
     */
    @isTest
    public static void testWhenAccountCreationMethodAutomaticAndBizRefIntegrationStatusSuccessForAmendmentThenInitiateProvisioningWithXrefIntegrationStatusReadyForIntegration() {
        Id storeId = fflib_IDGenerator.generate(Account.SObjectType);
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id businessVerticalId = fflib_IDGenerator.generate(Business_Vertical__c.SObjectType);
        Id businessReferenceId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);
        Fake businessVerticalRxFakeInstance = new Fake(Business_Vertical__c.class)
            .setField(Business_Vertical__c.Name, BUSINESS_VERTICAL_NAME)
            .setField(Business_Vertical__c.Id, businessVerticalId);

        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        parentBusinessAccountFakeInstance.setField(Account.Business_Vertical__c, businessVerticalId)
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance);
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake businessRefFakeInstance = new Fake(Business_Reference__c.class)
            .setField(Business_Reference__c.Business_Vertical__c, businessVerticalId)
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance)
            .setField(Business_Reference__c.Id, businessReferenceId)
            .setField(Business_Reference__c.Business_Vertical__c, businessVerticalId)
            .setField(Business_Reference__c.Integration_Status__c, INTEGRATION_STATUS_SUCCESS);
        Business_Reference__c businessReference = (Business_Reference__c) ServiceMockDataBuilder.convertToSObject(
            businessRefFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_GIFTS
            )
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
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
        Fake orderFakeInstance = ServiceMockDataBuilder.createActivationOrderFakeInstance(
                storeAccount.Id
            )
            .setField(Order.Backend_Systems__c, ORDER_BACKEND_SYSTEMS);
        Order orderVar = (Order) ServiceMockDataBuilder.convertToSObject(orderFakeInstance);
        Map<String, Set<Id>> accountIdsByCreationMethod = new Map<String, Set<Id>>();
        accountIdsByCreationMethod.put(
            PROVISIONING_EVENT_CREATION_METHOD_AUTOMATIC,
            new Set<Id>{ storeAccount.Id }
        );
        Map<Id, Set<String>> externalIdSourceWithAccountIdMap = new Map<Id, Set<String>>();
        externalIdSourceWithAccountIdMap.put(
            storeAccount.Id,
            new Set<string>{ ACCOUNT_PRIMARY_VERTICAL_GIFTS }
        );
        Set<Id> accountIdSet = new Set<Id>();
        accountIdSet.addAll(externalIdSourceWithAccountIdMap.keyset());
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentBusinessAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Menu_to_be_Completed_By__c, null);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        List<Business_Vertical__c> businessVerticalsRecords = new List<Business_Vertical__c>{
            new Business_Vertical__c(
                Active__c = true,
                Description__c = 'for Unit Testing',
                Menu_UI_Type__c = 'Restaurant',
                Primary_Vertical__c = 'Rx',
                Product__c = 'Marketplace',
                Vertical_Name__c = 'Grocery',
                Business_Vertical_ID__c = ''
            )
        };
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        List<Account> accountsList = new List<Account>{ storeAccount };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IBusinessReferencesSelector businessRefSelectorMock = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IOrdersSelector mockOrdersSelector = (IOrdersSelector) mocks.mock(IOrdersSelector.class);
        IBusinessVerticalsSelector mockBusinessVerticalsSelector = (IBusinessVerticalsSelector) mocks.mock(
            IBusinessVerticalsSelector.class
        );
        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountSelectorMock.selectAccountsWithXrefs(new Set<Id>{ storeAccount.Id }))
            .thenReturn(accountsList);
        mocks.when(accountSelectorMock.selectAccountsWithBrandName(new Set<Id>{ storeAccount.Id }))
            .thenReturn(accountsList);
        mocks.when(mockBusinessVerticalsSelector.sObjectType())
            .thenReturn(Business_Vertical__c.SObjectType);
        mocks.when(mockBusinessVerticalsSelector.selectPrimaryVerticalRxRecord())
            .thenReturn(businessVerticalsRecords);
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersByAccountIds(new Set<Id>{ storeAccount.Id })
            )
            .thenReturn(new List<WorkOrder>{ childWorkOrder });
        mocks.when(mockOrdersSelector.sObjectType()).thenReturn(Order.SObjectType);
        mocks.when(mockOrdersSelector.selectOrdersByAccountIds(new Set<Id>{ storeAccount.Id }))
            .thenReturn(new List<Order>{ orderVar });
        mocks.when(mockWorkOrdersSelector.selectWorkOrdersBySegment(new Set<Id>{ storeAccount.Id }))
            .thenReturn(new List<WorkOrder>{});
        mocks.when(businessRefSelectorMock.sObjectType())
            .thenReturn(Business_Reference__c.SObjectType);
        mocks.when(
                businessRefSelectorMock.selectByBusinessVerticals(
                    new Set<String>{ businessVerticalId }
                )
            )
            .thenReturn(new List<Business_Reference__c>{ businessReference });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockOrdersSelector);
        Application.SELECTOR.setMock(businessRefSelectorMock);
        Application.SELECTOR.setMock(mockBusinessVerticalsSelector);
        Application.UNITOFWORK.setMock(uowMock);
        AccountsProvisioningServiceImpl.provisionMarketplaceAccountsByCreationMethod(
            accountIdsByCreationMethod,
            true
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Xref__c.Id => xrefId,
                        Xref__c.Integration_Status__c => INTEGRATION_STATUS_READY_FOR_INTEGRATION
                    }
                )
            );
    }

    /**
     * @description To test manual provisioning when Business Reference "Integration Status" is
     * 'New' then update Xref "Integration Status" to 'Waiting for Business'.
     */
    @isTest
    public static void testWhenAccountCreationMethodManualAndBizRefIntegrationStatusNewThenInitiateProvisioningWithXrefIntegrationStatusWaitingForBusiness() {
        Id storeId = fflib_IDGenerator.generate(Account.SObjectType);
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id businessVerticalId = fflib_IDGenerator.generate(Business_Vertical__c.SObjectType);
        Id businessReferenceId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);
        Fake businessVerticalRxFakeInstance = new Fake(Business_Vertical__c.class)
            .setField(Business_Vertical__c.Name, BUSINESS_VERTICAL_NAME)
            .setField(Business_Vertical__c.Id, businessVerticalId);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        parentBusinessAccountFakeInstance.setField(Account.Business_Vertical__c, businessVerticalId)
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance);
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake businessRefFakeInstance = new Fake(Business_Reference__c.class)
            .setField(Business_Reference__c.Business_Vertical__c, businessVerticalId)
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance)
            .setField(Business_Reference__c.Id, businessReferenceId)
            .setField(Business_Reference__c.Business_Vertical__c, businessVerticalId)
            .setField(Business_Reference__c.Integration_Status__c, INTEGRATION_STATUS_NEW);
        Fake xrefFakeInstance = new Fake(Xref__c.class)
            .setField(Xref__c.Id, xrefId)
            .setField(Xref__c.External_ID__c, XREF_EXTERNAL_ID)
            .setField(Xref__c.External_ID_Source__c, XREF_EXTERNAL_ID_SOURCE_MDS)
            .setField(Xref__c.Salesforce_Account_Name__c, storeId)
            .setField(Xref__c.Xref_Status__c, XREF_STATUS_ACTIVE)
            .setField(Xref__c.Business_Reference__c, businessReferenceId)
            .setParent('Business_Reference__r', businessRefFakeInstance);
        Xref__c xRefRecord = (Xref__c) ServiceMockDataBuilder.convertToSObject(xrefFakeInstance);
        List<Xref__c> xrefList = new List<Xref__c>{ xRefRecord };
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_GIFTS
            )
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(Account.Data_Verification_Status__c, ACCOUNT_DATA_VERIFICATION_STATUS)
            .setField(Account.Id, storeId)
            .setField(Account.Proposed_Date_of_Activation__c, System.today())
            .setField(Account.Business_Vertical__c, businessVerticalId)
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance)
            .setField(Account.Activation_Status__c, INACTIVE)
            .setChildren('Xrefs__r', new List<Fake>{ xrefFakeInstance });
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Map<String, Set<Id>> accountIdsByCreationMethod = new Map<String, Set<Id>>();
        accountIdsByCreationMethod.put(
            PROVISIONING_EVENT_CREATION_METHOD_MANUAL,
            new Set<Id>{ storeAccount.Id }
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );
        IXrefsSelector xrefsSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        mocks.startStubbing();
        mocks.when(xrefsSelectorMock.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(xrefsSelectorMock.selectBySalesforceAccountName(new Set<Id>{ storeAccount.Id }))
            .thenReturn(xrefList);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(xrefsSelectorMock);
        Application.UNITOFWORK.setMock(uowMock);
        AccountsProvisioningService.provisionMarketplaceAccountsByCreationMethod(
            accountIdsByCreationMethod
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Xref__c.Id => xrefId,
                        Xref__c.Integration_Status__c => INTEGRATION_STATUS_WAITING_FOR_BUSINESS_PROVISIONING
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Business_Reference__c.Id => businessReferenceId,
                        Business_Reference__c.Integration_Status__c => INTEGRATION_STATUS_READY_FOR_INTEGRATION
                    }
                )
            );
    }
    /**
     * @description To test manual provisioning when Business Reference "Integration Status" is
     * 'Failure' then update Xref "Integration Status" to 'Waiting for Business'.
     */
    @isTest
    public static void testWhenAccountCreationMethodManualAndBizRefIntegrationStatusFailureThenInitiateProvisioningWithXrefIntegrationStatusWaitingForBusiness() {
        Id storeId = fflib_IDGenerator.generate(Account.SObjectType);
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id businessVerticalId = fflib_IDGenerator.generate(Business_Vertical__c.SObjectType);
        Id businessReferenceId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);
        Fake businessVerticalRxFakeInstance = new Fake(Business_Vertical__c.class)
            .setField(Business_Vertical__c.Name, BUSINESS_VERTICAL_NAME)
            .setField(Business_Vertical__c.Id, businessVerticalId);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        parentBusinessAccountFakeInstance.setField(Account.Business_Vertical__c, businessVerticalId)
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance);
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake businessRefFakeInstance = new Fake(Business_Reference__c.class)
            .setField(Business_Reference__c.Business_Vertical__c, businessVerticalId)
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance)
            .setField(Business_Reference__c.Id, businessReferenceId)
            .setField(Business_Reference__c.Business_Vertical__c, businessVerticalId)
            .setField(Business_Reference__c.Integration_Status__c, INTEGRATION_STATUS_FAILURE);
        Fake xrefFakeInstance = new Fake(Xref__c.class)
            .setField(Xref__c.Id, xrefId)
            .setField(Xref__c.External_ID__c, XREF_EXTERNAL_ID)
            .setField(Xref__c.External_ID_Source__c, XREF_EXTERNAL_ID_SOURCE_MDS)
            .setField(Xref__c.Salesforce_Account_Name__c, storeId)
            .setField(Xref__c.Xref_Status__c, XREF_STATUS_ACTIVE)
            .setField(Xref__c.Business_Reference__c, businessReferenceId)
            .setParent('Business_Reference__r', businessRefFakeInstance);
        Xref__c xRefRecord = (Xref__c) ServiceMockDataBuilder.convertToSObject(xrefFakeInstance);
        List<Xref__c> xrefList = new List<Xref__c>{ xRefRecord };
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_GIFTS
            )
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(Account.Data_Verification_Status__c, ACCOUNT_DATA_VERIFICATION_STATUS)
            .setField(Account.Id, storeId)
            .setField(Account.Proposed_Date_of_Activation__c, System.today())
            .setField(Account.Business_Vertical__c, businessVerticalId)
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance)
            .setField(Account.Activation_Status__c, INACTIVE)
            .setChildren('Xrefs__r', new List<Fake>{ xrefFakeInstance });
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Map<String, Set<Id>> accountIdsByCreationMethod = new Map<String, Set<Id>>();
        accountIdsByCreationMethod.put(
            PROVISIONING_EVENT_CREATION_METHOD_MANUAL,
            new Set<Id>{ storeAccount.Id }
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );
        IXrefsSelector xrefsSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        mocks.startStubbing();
        mocks.when(xrefsSelectorMock.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(xrefsSelectorMock.selectBySalesforceAccountName(new Set<Id>{ storeAccount.Id }))
            .thenReturn(xrefList);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(xrefsSelectorMock);
        Application.UNITOFWORK.setMock(uowMock);
        AccountsProvisioningService.provisionMarketplaceAccountsByCreationMethod(
            accountIdsByCreationMethod
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Xref__c.Id => xrefId,
                        Xref__c.Integration_Status__c => INTEGRATION_STATUS_WAITING_FOR_BUSINESS_PROVISIONING
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Business_Reference__c.Id => businessReferenceId,
                        Business_Reference__c.Integration_Status__c => INTEGRATION_STATUS_READY_FOR_INTEGRATION
                    }
                )
            );
    }

    /**
     * @description @description To test manual provisioning when Business Reference "Integration Status" is
     * 'Success' then update Xref "Integration Status" to 'Ready for Integration'.
     */
    @isTest
    public static void testWhenAccountCreationMethodManualAndBizRefIntegrationStatusSuccessThenInitiateProvisioningWithXrefIntegrationStatusReadyForIntegration() {
        Id storeId = fflib_IDGenerator.generate(Account.SObjectType);
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id businessVerticalId = fflib_IDGenerator.generate(Business_Vertical__c.SObjectType);
        Id businessReferenceId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);
        Fake businessVerticalRxFakeInstance = new Fake(Business_Vertical__c.class)
            .setField(Business_Vertical__c.Name, BUSINESS_VERTICAL_NAME)
            .setField(Business_Vertical__c.Id, businessVerticalId);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        parentBusinessAccountFakeInstance.setField(Account.Business_Vertical__c, businessVerticalId)
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance);
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake businessRefFakeInstance = new Fake(Business_Reference__c.class)
            .setField(Business_Reference__c.Business_Vertical__c, businessVerticalId)
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance)
            .setField(Business_Reference__c.Id, businessReferenceId)
            .setField(Business_Reference__c.Business_Vertical__c, businessVerticalId)
            .setField(Business_Reference__c.Integration_Status__c, INTEGRATION_STATUS_SUCCESS);
        Fake xrefFakeInstance = new Fake(Xref__c.class)
            .setField(Xref__c.Id, xrefId)
            .setField(Xref__c.External_ID__c, XREF_EXTERNAL_ID)
            .setField(Xref__c.External_ID_Source__c, XREF_EXTERNAL_ID_SOURCE_MDS)
            .setField(Xref__c.Salesforce_Account_Name__c, storeId)
            .setField(Xref__c.Xref_Status__c, XREF_STATUS_ACTIVE)
            .setField(Xref__c.Business_Reference__c, businessReferenceId)
            .setParent('Business_Reference__r', businessRefFakeInstance);
        Xref__c xRefRecord = (Xref__c) ServiceMockDataBuilder.convertToSObject(xrefFakeInstance);
        List<Xref__c> xrefList = new List<Xref__c>{ xRefRecord };
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_GIFTS
            )
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(Account.Data_Verification_Status__c, ACCOUNT_DATA_VERIFICATION_STATUS)
            .setField(Account.Id, storeId)
            .setField(Account.Proposed_Date_of_Activation__c, System.today())
            .setField(Account.Business_Vertical__c, businessVerticalId)
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance)
            .setField(Account.Activation_Status__c, INACTIVE)
            .setChildren('Xrefs__r', new List<Fake>{ xrefFakeInstance });
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Map<String, Set<Id>> accountIdsByCreationMethod = new Map<String, Set<Id>>();
        accountIdsByCreationMethod.put(
            PROVISIONING_EVENT_CREATION_METHOD_MANUAL,
            new Set<Id>{ storeAccount.Id }
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );
        IXrefsSelector xrefsSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        mocks.startStubbing();
        mocks.when(xrefsSelectorMock.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(xrefsSelectorMock.selectBySalesforceAccountName(new Set<Id>{ storeAccount.Id }))
            .thenReturn(xrefList);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(xrefsSelectorMock);
        Application.UNITOFWORK.setMock(uowMock);
        AccountsProvisioningService.provisionMarketplaceAccountsByCreationMethod(
            accountIdsByCreationMethod
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Xref__c.Id => xrefId,
                        Xref__c.Integration_Status__c => INTEGRATION_STATUS_READY_FOR_INTEGRATION
                    }
                )
            );
    }

    /**
     * @description To test manual provisioning when Business Reference "Integration Status" is
     * 'Failure' then update Xref "Integration Status" to 'Waiting for Business' for amendment
     * scenario.
     */
    @isTest
    public static void testWhenAccountCreationMethodManualAndBizRefIntegrationStatusFailureForAmendmentThenInitiateProvisioningWithXrefIntegrationStatusWaitingForBusiness() {
        Id storeId = fflib_IDGenerator.generate(Account.SObjectType);
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id businessVerticalId = fflib_IDGenerator.generate(Business_Vertical__c.SObjectType);
        Id businessReferenceId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);
        Fake businessVerticalRxFakeInstance = new Fake(Business_Vertical__c.class)
            .setField(Business_Vertical__c.Name, BUSINESS_VERTICAL_NAME)
            .setField(Business_Vertical__c.Id, businessVerticalId);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        parentBusinessAccountFakeInstance.setField(Account.Business_Vertical__c, businessVerticalId)
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance);
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake businessRefFakeInstance = new Fake(Business_Reference__c.class)
            .setField(Business_Reference__c.Business_Vertical__c, businessVerticalId)
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance)
            .setField(Business_Reference__c.Id, businessReferenceId)
            .setField(Business_Reference__c.Business_Vertical__c, businessVerticalId)
            .setField(Business_Reference__c.Integration_Status__c, INTEGRATION_STATUS_FAILURE);
        Fake xrefFakeInstance = new Fake(Xref__c.class)
            .setField(Xref__c.Id, xrefId)
            .setField(Xref__c.External_ID__c, XREF_EXTERNAL_ID)
            .setField(Xref__c.External_ID_Source__c, XREF_EXTERNAL_ID_SOURCE_MDS)
            .setField(Xref__c.Salesforce_Account_Name__c, storeId)
            .setField(Xref__c.Xref_Status__c, XREF_STATUS_ACTIVE)
            .setField(Xref__c.Business_Reference__c, businessReferenceId)
            .setParent('Business_Reference__r', businessRefFakeInstance);
        Xref__c xRefRecord = (Xref__c) ServiceMockDataBuilder.convertToSObject(xrefFakeInstance);
        List<Xref__c> xrefList = new List<Xref__c>{ xRefRecord };
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_GIFTS
            )
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(Account.Data_Verification_Status__c, ACCOUNT_DATA_VERIFICATION_STATUS)
            .setField(Account.Id, storeId)
            .setField(Account.Proposed_Date_of_Activation__c, System.today())
            .setField(Account.Business_Vertical__c, businessVerticalId)
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance)
            .setField(Account.Activation_Status__c, INACTIVE)
            .setChildren('Xrefs__r', new List<Fake>{ xrefFakeInstance });
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Map<String, Set<Id>> accountIdsByCreationMethod = new Map<String, Set<Id>>();
        accountIdsByCreationMethod.put(
            PROVISIONING_EVENT_CREATION_METHOD_MANUAL,
            new Set<Id>{ storeAccount.Id }
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );
        IXrefsSelector xrefsSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        mocks.startStubbing();
        mocks.when(xrefsSelectorMock.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(xrefsSelectorMock.selectBySalesforceAccountName(new Set<Id>{ storeAccount.Id }))
            .thenReturn(xrefList);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(xrefsSelectorMock);
        Application.UNITOFWORK.setMock(uowMock);
        AccountsProvisioningServiceImpl.provisionMarketplaceAccountsByCreationMethod(
            accountIdsByCreationMethod,
            true
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Xref__c.Id => xrefId,
                        Xref__c.Integration_Status__c => INTEGRATION_STATUS_WAITING_FOR_BUSINESS_PROVISIONING
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Business_Reference__c.Id => businessReferenceId,
                        Business_Reference__c.Integration_Status__c => INTEGRATION_STATUS_READY_FOR_INTEGRATION
                    }
                )
            );
    }

    /**
     * @description To test manual provisioning when Business Reference "Integration Status" is
     * 'Success' then update Xref "Integration Status" to 'Ready for Integration' for amendment
     * scenario.
     */
    @isTest
    public static void testWhenAccountCreationMethodManualAndBizRefIntegrationStatusSuccessForAmendmentThenInitiateProvisioningWithXrefIntegrationStatusReadyForIntegration() {
        Id storeId = fflib_IDGenerator.generate(Account.SObjectType);
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id businessVerticalId = fflib_IDGenerator.generate(Business_Vertical__c.SObjectType);
        Id businessReferenceId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);
        Fake businessVerticalRxFakeInstance = new Fake(Business_Vertical__c.class)
            .setField(Business_Vertical__c.Name, BUSINESS_VERTICAL_NAME)
            .setField(Business_Vertical__c.Id, businessVerticalId);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        parentBusinessAccountFakeInstance.setField(Account.Business_Vertical__c, businessVerticalId)
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance);
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake businessRefFakeInstance = new Fake(Business_Reference__c.class)
            .setField(Business_Reference__c.Business_Vertical__c, businessVerticalId)
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance)
            .setField(Business_Reference__c.Id, businessReferenceId)
            .setField(Business_Reference__c.Business_Vertical__c, businessVerticalId)
            .setField(Business_Reference__c.Integration_Status__c, INTEGRATION_STATUS_SUCCESS);

        Fake xrefFakeInstance = new Fake(Xref__c.class)
            .setField(Xref__c.Id, xrefId)
            .setField(Xref__c.External_ID__c, XREF_EXTERNAL_ID)
            .setField(Xref__c.External_ID_Source__c, XREF_EXTERNAL_ID_SOURCE_MDS)
            .setField(Xref__c.Salesforce_Account_Name__c, storeId)
            .setField(Xref__c.Xref_Status__c, XREF_STATUS_ACTIVE)
            .setField(Xref__c.Business_Reference__c, businessReferenceId)
            .setParent('Business_Reference__r', businessRefFakeInstance);
        Xref__c xRefRecord = (Xref__c) ServiceMockDataBuilder.convertToSObject(xrefFakeInstance);
        List<Xref__c> xrefList = new List<Xref__c>{ xRefRecord };
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_GIFTS
            )
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(Account.Data_Verification_Status__c, ACCOUNT_DATA_VERIFICATION_STATUS)
            .setField(Account.Id, storeId)
            .setField(Account.Proposed_Date_of_Activation__c, System.today())
            .setField(Account.Business_Vertical__c, businessVerticalId)
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance)
            .setField(Account.Activation_Status__c, INACTIVE)
            .setChildren('Xrefs__r', new List<Fake>{ xrefFakeInstance });
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Map<String, Set<Id>> accountIdsByCreationMethod = new Map<String, Set<Id>>();
        accountIdsByCreationMethod.put(
            PROVISIONING_EVENT_CREATION_METHOD_MANUAL,
            new Set<Id>{ storeAccount.Id }
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );
        IXrefsSelector xrefsSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        mocks.startStubbing();
        mocks.when(xrefsSelectorMock.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(xrefsSelectorMock.selectBySalesforceAccountName(new Set<Id>{ storeAccount.Id }))
            .thenReturn(xrefList);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(xrefsSelectorMock);
        Application.UNITOFWORK.setMock(uowMock);
        AccountsProvisioningServiceImpl.provisionMarketplaceAccountsByCreationMethod(
            accountIdsByCreationMethod,
            true
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Xref__c.Id => xrefId,
                        Xref__c.Integration_Status__c => INTEGRATION_STATUS_READY_FOR_INTEGRATION
                    }
                )
            );
    }

    /**
     * @description It is used to test no new Xrefs are created and existing Xref's
     * status is updated during SMB Accounts provisioning.
     */
    @isTest
    public static void testWhenSMBAccountsProvisioningThenUpdateExistingXref() {
        Id businessReferenceId = Fake.generateId(Business_Reference__c.class);
        Id storeId = fflib_IDGenerator.generate(Account.SObjectType);
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id mockBVId = fflib_IDGenerator.generate(Business_Vertical__c.SObjectType);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                ACCOUNT_PRIMARY_VERTICAL_GIFTS,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB);
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
            .setField(Account.Id, storeId)
            .setField(Account.Proposed_Date_of_Activation__c, System.today())
            .setField(Account.Activation_Status__c, INACTIVE)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
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
                        .setParent(
                            'Business_Reference__r',
                            new Fake(Business_Reference__c.class)
                                .setField(
                                    Business_Reference__c.Integration_Status__c,
                                    INTEGRATION_STATUS_SUCCESS
                                )
                                .setField(Business_Reference__c.Id, businessReferenceId)
                        )
                }
            );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake orderFakeInstance = ServiceMockDataBuilder.createActivationOrderFakeInstance(
                storeAccount.Id
            )
            .setField(Order.Backend_Systems__c, ORDER_BACKEND_SYSTEMS);
        Order orderVar = (Order) ServiceMockDataBuilder.convertToSObject(orderFakeInstance);
        Map<String, Set<Id>> accountIdsByCreationMethod = new Map<String, Set<Id>>();
        accountIdsByCreationMethod.put(
            PROVISIONING_EVENT_CREATION_METHOD_AUTOMATIC,
            new Set<Id>{ storeAccount.Id }
        );
        Map<Id, Set<String>> externalIdSourceWithAccountIdMap = new Map<Id, Set<String>>();
        externalIdSourceWithAccountIdMap.put(
            storeAccount.Id,
            new Set<string>{ ACCOUNT_PRIMARY_VERTICAL_GIFTS }
        );
        Set<Id> accountIdSet = new Set<Id>();
        accountIdSet.addAll(externalIdSourceWithAccountIdMap.keyset());
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentBusinessAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Menu_to_be_Completed_By__c, null);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        List<Business_Vertical__c> businessVerticalsRecords = new List<Business_Vertical__c>{
            new Business_Vertical__c(
                Id = mockBVId,
                Active__c = true,
                Menu_UI_Type__c = VERTICAL_NAME,
                Primary_Vertical__c = PRIMARY_VERTICAL_RX,
                Product__c = WORKORDER_TYPE_MARKETPLACE,
                Vertical_Name__c = VERTICAL_NAME,
                Business_Vertical_ID__c = ''
            )
        };
        List<Account> accountsList = new List<Account>{ storeAccount };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IBusinessReferencesSelector businessRefSelectorMock = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IOrdersSelector mockOrdersSelector = (IOrdersSelector) mocks.mock(IOrdersSelector.class);
        IBusinessVerticalsSelector mockBusinessVerticalsSelector = (IBusinessVerticalsSelector) mocks.mock(
            IBusinessVerticalsSelector.class
        );
        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountSelectorMock.selectAccountsWithXrefs(new Set<Id>{ storeAccount.Id }))
            .thenReturn(accountsList);
        mocks.when(accountSelectorMock.selectAccountsWithBrandName(new Set<Id>{ storeAccount.Id }))
            .thenReturn(accountsList);
        mocks.when(mockBusinessVerticalsSelector.sObjectType())
            .thenReturn(Business_Vertical__c.SObjectType);
        mocks.when(mockBusinessVerticalsSelector.selectPrimaryVerticalRxRecord())
            .thenReturn(businessVerticalsRecords);
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrdersSelector.selectWorkOrdersBySegment(new Set<Id>{ storeAccount.Id }))
            .thenReturn(new List<WorkOrder>{ childWorkOrder });
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersByAccountIds(new Set<Id>{ storeAccount.Id })
            )
            .thenReturn(new List<WorkOrder>{ childWorkOrder });
        mocks.when(mockOrdersSelector.sObjectType()).thenReturn(Order.SObjectType);
        mocks.when(mockOrdersSelector.selectOrdersByAccountIds(new Set<Id>{ storeAccount.Id }))
            .thenReturn(new List<Order>{ orderVar });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockOrdersSelector);
        Application.SELECTOR.setMock(businessRefSelectorMock);
        Application.SELECTOR.setMock(mockBusinessVerticalsSelector);
        Application.UNITOFWORK.setMock(uowMock);
        Test.startTest();
        AccountsProvisioningService.provisionMarketplaceAccountsByCreationMethod(
            accountIdsByCreationMethod,
            true
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Xref__c.Id => xrefId,
                        Xref__c.Integration_Status__c => INTEGRATION_STATUS_READY_FOR_INTEGRATION
                    }
                )
            );
        ((fflib_SObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
    }

    /**
     * @description It is used to test existing Business Reference is asscoiated to Xref
     * based on Business Id on parent Work Order during SMB Accounts provisioning.
     */
    @isTest
    public static void testWhenSMBAccountsProvisioningThenAssociateExistingBusinessReference() {
        Id businessReferenceId = Fake.generateId(Business_Reference__c.class);
        Id storeId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id mockBVId = fflib_IDGenerator.generate(Business_Vertical__c.SObjectType);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                ACCOUNT_PRIMARY_VERTICAL_GIFTS,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB);
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
            .setField(Account.Id, storeId)
            .setField(Account.Proposed_Date_of_Activation__c, System.today())
            .setField(Account.Activation_Status__c, INACTIVE)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake orderFakeInstance = ServiceMockDataBuilder.createActivationOrderFakeInstance(
                storeAccount.Id
            )
            .setField(Order.Backend_Systems__c, XREF_EXTERNAL_ID_SOURCE_MDS);
        Order orderVar = (Order) ServiceMockDataBuilder.convertToSObject(orderFakeInstance);
        Map<String, Set<Id>> accountIdsByCreationMethod = new Map<String, Set<Id>>();
        accountIdsByCreationMethod.put(
            PROVISIONING_EVENT_CREATION_METHOD_AUTOMATIC,
            new Set<Id>{ storeAccount.Id }
        );
        Map<Id, Set<String>> externalIdSourceWithAccountIdMap = new Map<Id, Set<String>>();
        externalIdSourceWithAccountIdMap.put(
            storeAccount.Id,
            new Set<string>{ ACCOUNT_PRIMARY_VERTICAL_GIFTS }
        );
        Set<Id> accountIdSet = new Set<Id>();
        accountIdSet.addAll(externalIdSourceWithAccountIdMap.keyset());
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentBusinessAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Business_Id__c, MOCK_BUSINESS_ID)
            .setField(WorkOrder.Menu_to_be_Completed_By__c, null);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        List<Business_Vertical__c> businessVerticalsRecords = new List<Business_Vertical__c>{
            new Business_Vertical__c(
                Id = mockBVId,
                Active__c = true,
                Menu_UI_Type__c = VERTICAL_NAME,
                Primary_Vertical__c = PRIMARY_VERTICAL_RX,
                Product__c = WORKORDER_TYPE_MARKETPLACE,
                Vertical_Name__c = VERTICAL_NAME,
                Business_Vertical_ID__c = ''
            )
        };
        List<Account> accountsList = new List<Account>{ storeAccount };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IBusinessReferencesSelector businessRefSelectorMock = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IOrdersSelector mockOrdersSelector = (IOrdersSelector) mocks.mock(IOrdersSelector.class);
        IBusinessVerticalsSelector mockBusinessVerticalsSelector = (IBusinessVerticalsSelector) mocks.mock(
            IBusinessVerticalsSelector.class
        );
        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountSelectorMock.selectAccountsWithXrefs(new Set<Id>{ storeAccount.Id }))
            .thenReturn(accountsList);
        mocks.when(accountSelectorMock.selectAccountsWithBrandName(new Set<Id>{ storeAccount.Id }))
            .thenReturn(accountsList);
        mocks.when(mockBusinessVerticalsSelector.sObjectType())
            .thenReturn(Business_Vertical__c.SObjectType);
        mocks.when(mockBusinessVerticalsSelector.selectPrimaryVerticalRxRecord())
            .thenReturn(businessVerticalsRecords);
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrdersSelector.selectWorkOrdersBySegment(new Set<Id>{ storeAccount.Id }))
            .thenReturn(new List<WorkOrder>{ childWorkOrder });
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersByAccountIds(new Set<Id>{ storeAccount.Id })
            )
            .thenReturn(new List<WorkOrder>{ childWorkOrder });
        mocks.when(mockOrdersSelector.sObjectType()).thenReturn(Order.SObjectType);
        mocks.when(mockOrdersSelector.selectOrdersByAccountIds(new Set<Id>{ storeAccount.Id }))
            .thenReturn(new List<Order>{ orderVar });
        mocks.when(businessRefSelectorMock.sObjectType())
            .thenReturn(Business_Reference__c.SObjectType);
        mocks.when(
                businessRefSelectorMock.selectMDSBusinessReferencesWithSuccessIntegrationStatusByBusinessIds(
                    new Set<String>{ MOCK_BUSINESS_ID }
                )
            )
            .thenReturn(
                new List<Business_Reference__c>{
                    new Business_Reference__c(
                        Id = businessReferenceId,
                        External_Id__c = MOCK_BUSINESS_ID,
                        Integration_Status__c = INTEGRATION_STATUS_SUCCESS
                    )
                }
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockOrdersSelector);
        Application.SELECTOR.setMock(businessRefSelectorMock);
        Application.SELECTOR.setMock(mockBusinessVerticalsSelector);
        Application.UNITOFWORK.setMock(uowMock);
        Test.startTest();
        AccountsProvisioningService.provisionMarketplaceAccountsByCreationMethod(
            accountIdsByCreationMethod
        );
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Xref__c.Business_Reference__c => businessReferenceId,
                        Xref__c.Integration_Status__c => INTEGRATION_STATUS_READY_FOR_INTEGRATION
                    }
                )
            );
    }
}