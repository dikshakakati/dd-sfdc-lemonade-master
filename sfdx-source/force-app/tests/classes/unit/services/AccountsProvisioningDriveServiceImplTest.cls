/**
 * @description Test class for AccountsProvisioningDriveServiceImpl
 * Suppressed Warnings since mock verify method does not require System Assert statements.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
public class AccountsProvisioningDriveServiceImplTest {
    public static final String PROVISIONING_EVENT_CREATION_METHOD_MANUAL = 'Manual';
    public static final String PROVISIONING_EVENT_CREATION_METHOD_AUTOMATIC = 'Automatic';
    private static final String INTEGRATION_STATUS_WAITING_FOR_BUSINESS_PROVISIONING = 'Waiting on Business Provisioning';
    private static final String INTEGRATION_STATUS_READY_FOR_INTEGRATION = 'Ready for Integration';
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
    private static final String NET_NEW_SUB_TYPE = 'Net-new business';
    private static final String AUTO_ACTIVATIONS_SUB_TYPE = 'Auto-Activations';
    private static final String WITHHOLDING_SUB_TYPE = 'Withholding';

    /**
     * @description To test Automatic provisioning for Parent Drive WorkOrders.
     */
    @isTest
    private static void testWhenAccountsAreAutomaticCreatedThenProvisionedForDriveWorkOrders() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                ACCOUNT_PRIMARY_VERTICAL_GIFTS,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Legal_Business_Name__c, 'TEST ACCOUNT LEGAL NAME');

        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Map<String, Set<Id>> accountIdsByCreationMethod = new Map<String, Set<Id>>();
        accountIdsByCreationMethod.put(
            PROVISIONING_EVENT_CREATION_METHOD_AUTOMATIC,
            new Set<Id>{ parentAccount.Id }
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

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );

        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IGenericLogger genericLoggerService = (IGenericLogger) mocks.mock(GenericLoggerImpl.class);

        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountSelectorMock.selectAccountsWithBrandName(new Set<Id>{ parentAccount.Id }))
            .thenReturn(new List<Account>{ parentAccount });
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersByAccountIds(new Set<Id>{ parentAccount.Id })
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.UNITOFWORK.setMock(uowMock);
        Application.SERVICE.setMock(IGenericLogger.class, genericLoggerService);

        AccountsProvisioningDriveServiceImpl.provisionDriveAccountsByCreationMethod(
            accountIdsByCreationMethod
        );

        ((fflib_SObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
    }

    /**
     * @description Test Manually provisioning for Parent Drive WorkOrders.
     */
    @isTest
    private static void testWhenAccountsAreManuallyCreatedThenProvisionedForDriveWorkOrders() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                ACCOUNT_PRIMARY_VERTICAL_GIFTS,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Legal_Business_Name__c, 'TEST ACCOUNT LEGAL NAME');

        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Map<String, Set<Id>> accountIdsByCreationMethod = new Map<String, Set<Id>>();
        accountIdsByCreationMethod.put(
            PROVISIONING_EVENT_CREATION_METHOD_MANUAL,
            new Set<Id>{ parentAccount.Id }
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                WORKORDER_TYPE_DRIVE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.Sub_Type__c, NET_NEW_SUB_TYPE)
            .setField(
                WorkOrder.Business_to_Store_Assignment__c,
                PROVISIONING_EVENT_CREATION_METHOD_MANUAL
            );
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );

        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IGenericLogger genericLoggerService = (IGenericLogger) mocks.mock(GenericLoggerImpl.class);

        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountSelectorMock.selectAccountsWithBrandName(new Set<Id>{ parentAccount.Id }))
            .thenReturn(new List<Account>{ parentAccount });
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersByAccountIds(new Set<Id>{ parentAccount.Id })
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.UNITOFWORK.setMock(uowMock);
        Application.SERVICE.setMock(IGenericLogger.class, genericLoggerService);

        AccountsProvisioningDriveServiceImpl.provisionDriveAccountsByCreationMethod(
            accountIdsByCreationMethod
        );

        ((fflib_SObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
    }

    /**
     * @description Test Manually provisioning for Parent Drive WorkOrders
     */
    @isTest
    private static void testWhenChildAccountsAreManuallyCreatedThenProvisionedForDriveWorkOrders() {
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                ACCOUNT_PRIMARY_VERTICAL_GIFTS,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Legal_Business_Name__c, 'TEST ACCOUNT LEGAL NAME');

        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );

        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                ACCOUNT_PRIMARY_VERTICAL_GIFTS,
                ACCOUNT_RECORD_TYPE_NAME_STORE
            )
            .setField(Account.Id, storeAccountId)
            .setField(Account.Franchise_Parent__c, parentAccount.Id)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );

        Map<String, Set<Id>> accountIdsByCreationMethod = new Map<String, Set<Id>>();
        accountIdsByCreationMethod.put(
            PROVISIONING_EVENT_CREATION_METHOD_MANUAL,
            new Set<Id>{ storeAccount.Id }
        );

        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
            parentAccount.Id,
            WORKORDER_TYPE_DRIVE
        );
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );

        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                WORKORDER_TYPE_DRIVE
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.Sub_Type__c, NET_NEW_SUB_TYPE)
            .setField(
                WorkOrder.Business_to_Store_Assignment__c,
                PROVISIONING_EVENT_CREATION_METHOD_MANUAL
            );
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );

        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );

        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountSelectorMock.selectAccountsWithBrandName(new Set<Id>{ storeAccountId }))
            .thenReturn(new List<Account>{ storeAccount });
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersByAccountIds(new Set<Id>{ storeAccountId })
            )
            .thenReturn(new List<WorkOrder>{ childWorkOrder });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.UNITOFWORK.setMock(uowMock);

        AccountsProvisioningDriveServiceImpl.provisionDriveAccountsByCreationMethod(
            accountIdsByCreationMethod
        );

        ((fflib_SObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
    }

    /**
     * @description Test Manually provisioning for Child Drive WorkOrders
     */
    @isTest
    private static void testWhenChildAccountsAreAutomaticCreatedThenProvisionedForDriveWorkOrders() {
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                ACCOUNT_PRIMARY_VERTICAL_GIFTS,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Legal_Business_Name__c, 'TEST ACCOUNT LEGAL NAME');

        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );

        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                ACCOUNT_PRIMARY_VERTICAL_GIFTS,
                ACCOUNT_RECORD_TYPE_NAME_STORE
            )
            .setField(Account.Id, storeAccountId)
            .setField(Account.Franchise_Parent__c, parentAccount.Id)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );

        Business_Reference__c businessReference = (Business_Reference__c) new Fake(
                Business_Reference__c.class
            )
            .setFakeId()
            .toSObject();

        Xref__c xref = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Salesforce_Account_Name__c, storeAccountId)
            .setField(Xref__c.External_ID_Source__c, XREF_STATUS_ACTIVE)
            .setField(Xref__c.Business_Reference__c, businessReference.Id)
            .setParent('Salesforce_Account_Name__r', childAccountFakeInstance)
            .setFakeId()
            .toSObject();

        Map<String, Set<Id>> accountIdsByCreationMethod = new Map<String, Set<Id>>();
        accountIdsByCreationMethod.put(
            PROVISIONING_EVENT_CREATION_METHOD_AUTOMATIC,
            new Set<Id>{ storeAccount.Id }
        );

        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
            parentAccount.Id,
            WORKORDER_TYPE_DRIVE
        );
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );

        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                WORKORDER_TYPE_DRIVE
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.Sub_Type__c, NET_NEW_SUB_TYPE)
            .setField(
                WorkOrder.Business_to_Store_Assignment__c,
                PROVISIONING_EVENT_CREATION_METHOD_AUTOMATIC
            );
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );

        IXrefsSelector xrefSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );

        mocks.startStubbing();
        mocks.when(xrefSelectorMock.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                xrefSelectorMock.selectDriveDbXrefsBySalesforceAccountName(
                    new Set<Id>{ storeAccountId }
                )
            )
            .thenReturn(new List<Xref__c>{ xref });

        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountSelectorMock.selectAccountsWithBrandName(new Set<Id>{ storeAccountId }))
            .thenReturn(new List<Account>{ storeAccount });
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersByAccountIds(new Set<Id>{ storeAccountId })
            )
            .thenReturn(new List<WorkOrder>{ childWorkOrder });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(xrefSelectorMock);
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.UNITOFWORK.setMock(uowMock);

        AccountsProvisioningDriveServiceImpl.provisionDriveAccountsByCreationMethod(
            accountIdsByCreationMethod
        );

        ((fflib_SObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
    }
    /**
     * @description Test Automatic provisioning for Child WorkOrders existing Xref
     */
    @isTest
    private static void testWhenAccountsHaveXrefsThenNoUpdates() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Id externalBusinessId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                ACCOUNT_PRIMARY_VERTICAL_GIFTS,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Legal_Business_Name__c, 'TEST ACCOUNT LEGAL NAME');

        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Map<String, Set<Id>> accountIdsByCreationMethod = new Map<String, Set<Id>>();
        accountIdsByCreationMethod.put(
            PROVISIONING_EVENT_CREATION_METHOD_AUTOMATIC,
            new Set<Id>{ parentAccount.Id }
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                WORKORDER_TYPE_DRIVE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Menu_to_be_Completed_By__c, null)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );

        Fake businessReference = new Fake(Business_Reference__c.class)
            .setField(Business_Reference__c.Id, externalBusinessId)
            .setField(Business_Reference__c.External_ID_Source__c, XREF_EXTERNAL_ID_SOURCE);

        Xref__c xref = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Id, xrefId)
            .setField(Xref__c.Salesforce_Account_Name__c, parentAccount.Id)
            .setField(Xref__c.Xref_Status__c, XREF_STATUS_ACTIVE)
            .setParent('Business_Reference__r', businessReference)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );

        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IXrefsSelector xrefSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IGenericLogger genericLoggerService = (IGenericLogger) mocks.mock(GenericLoggerImpl.class);
        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountSelectorMock.selectAccountsWithBrandName(new Set<Id>{ parentAccount.Id }))
            .thenReturn(new List<Account>{ parentAccount });
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersByAccountIds(new Set<Id>{ parentAccount.Id })
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.when(xrefSelectorMock.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(xrefSelectorMock.selectBySalesforceAccountName(new Set<Id>{ parentAccount.Id }))
            .thenReturn(new List<Xref__c>{ xref });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(xrefSelectorMock);
        Application.UNITOFWORK.setMock(uowMock);
        Application.SERVICE.setMock(IGenericLogger.class, genericLoggerService);

        AccountsProvisioningDriveServiceImpl.provisionDriveAccountsByCreationMethod(
            accountIdsByCreationMethod
        );

        ((fflib_SObjectUnitOfWork) mocks.verify(uowMock, 0)).commitWork();
    }

    /**
     * @description Test when automatic provisioning for Child Drive WorkOrders for corporate parents then existing xrefs and business refs are updated
     */
    @isTest
    private static void testWhenChildCorporateAccountsAreAutomaticCreatedThenProvisionedForDriveWorkOrders() {
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                ACCOUNT_PRIMARY_VERTICAL_GIFTS,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Legal_Business_Name__c, 'TEST ACCOUNT LEGAL NAME');

        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );

        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                ACCOUNT_PRIMARY_VERTICAL_GIFTS,
                ACCOUNT_RECORD_TYPE_NAME_STORE
            )
            .setField(Account.Id, storeAccountId)
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );

        Business_Reference__c businessReference = (Business_Reference__c) new Fake(
                Business_Reference__c.class
            )
            .setFakeId()
            .toSObject();

        Xref__c xref = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.External_ID_Source__c, XREF_STATUS_ACTIVE)
            .setField(Xref__c.Account_Record_Type__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(Xref__c.Business_Reference__c, businessReference.Id)
            .setParent('Salesforce_Account_Name__r', childAccountFakeInstance)
            .setFakeId()
            .toSObject();

        Map<String, Set<Id>> accountIdsByCreationMethod = new Map<String, Set<Id>>();
        accountIdsByCreationMethod.put(
            PROVISIONING_EVENT_CREATION_METHOD_AUTOMATIC,
            new Set<Id>{ storeAccount.Id }
        );

        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
            parentAccount.Id,
            WORKORDER_TYPE_DRIVE
        );
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );

        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                WORKORDER_TYPE_DRIVE
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.Sub_Type__c, NET_NEW_SUB_TYPE)
            .setField(
                WorkOrder.Business_to_Store_Assignment__c,
                PROVISIONING_EVENT_CREATION_METHOD_AUTOMATIC
            );
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );

        IXrefsSelector xrefSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );

        mocks.startStubbing();
        mocks.when(xrefSelectorMock.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                xrefSelectorMock.selectDriveDbXrefsBySalesforceAccountName(
                    new Set<Id>{ storeAccountId }
                )
            )
            .thenReturn(new List<Xref__c>{ xref });

        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountSelectorMock.selectAccountsWithBrandName(new Set<Id>{ storeAccountId }))
            .thenReturn(new List<Account>{ storeAccount });
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersByAccountIds(new Set<Id>{ storeAccountId })
            )
            .thenReturn(new List<WorkOrder>{ childWorkOrder });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(xrefSelectorMock);
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.UNITOFWORK.setMock(uowMock);

        AccountsProvisioningDriveServiceImpl.provisionDriveAccountsByCreationMethod(
            accountIdsByCreationMethod
        );

        ((fflib_SObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1))
            .registerDirty(fflib_Match.anySObject());
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1))
            .registerUpsert(fflib_Match.anySObject());
    }

    /**
     * @description Test Manual provisioning for Parent Drive WorkOrders for corporate parents new xref and business refs are created
     */
    @isTest
    private static void testWhenCorporateChildAccountsAreManuallyCreatedThenProvisionedForDriveWorkOrders() {
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                ACCOUNT_PRIMARY_VERTICAL_GIFTS,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Legal_Business_Name__c, 'TEST ACCOUNT LEGAL NAME');

        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );

        Fake childAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                ACCOUNT_PRIMARY_VERTICAL_GIFTS,
                ACCOUNT_RECORD_TYPE_NAME_STORE
            )
            .setField(Account.Id, storeAccountId)
            .setField(Account.ParentId, parentAccount.Id)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            childAccountFakeInstance
        );

        Map<String, Set<Id>> accountIdsByCreationMethod = new Map<String, Set<Id>>();
        accountIdsByCreationMethod.put(
            PROVISIONING_EVENT_CREATION_METHOD_MANUAL,
            new Set<Id>{ storeAccount.Id }
        );

        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
            parentAccount.Id,
            WORKORDER_TYPE_DRIVE
        );
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );

        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                WORKORDER_TYPE_DRIVE
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(WorkOrder.Sub_Type__c, NET_NEW_SUB_TYPE)
            .setField(
                WorkOrder.Business_to_Store_Assignment__c,
                PROVISIONING_EVENT_CREATION_METHOD_MANUAL
            );
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );

        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );

        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountSelectorMock.selectAccountsWithBrandName(new Set<Id>{ storeAccountId }))
            .thenReturn(new List<Account>{ storeAccount });
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersByAccountIds(new Set<Id>{ storeAccountId })
            )
            .thenReturn(new List<WorkOrder>{ childWorkOrder });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.UNITOFWORK.setMock(uowMock);

        AccountsProvisioningDriveServiceImpl.provisionDriveAccountsByCreationMethod(
            accountIdsByCreationMethod
        );

        ((fflib_SObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).registerNew(fflib_Match.anySObject());
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1))
            .registerNew(
                fflib_Match.anySObject(),
                fflib_Match.anySObjectField(),
                fflib_Match.anySObject()
            );
    }

    /**
     * @description It is used to validate that when work order with Auto-Activations Withholding
     * having Provisioning Process as 'Automatic' is passed then Biz Ref with "Mp Bz Id"
     * value is created successfully.
     */
    @isTest
    private static void testWhenAutomaticDriveWorkOrdersWithAutoActivationsWithholdingEvaluatedThenBizRefCreatedSuccessfullyWithMpBzId() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                ACCOUNT_PRIMARY_VERTICAL_GIFTS,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Legal_Business_Name__c, 'TEST ACCOUNT LEGAL NAME');

        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Map<String, Set<Id>> accountIdsByCreationMethod = new Map<String, Set<Id>>();
        accountIdsByCreationMethod.put(
            PROVISIONING_EVENT_CREATION_METHOD_AUTOMATIC,
            new Set<Id>{ parentAccount.Id }
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                WORKORDER_TYPE_DRIVE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.Sub_Type__c, AUTO_ACTIVATIONS_SUB_TYPE)
            .setField(WorkOrder.Withholding_with_Auto_Activations__c, true)
            .setField(
                WorkOrder.Business_to_Store_Assignment__c,
                PROVISIONING_EVENT_CREATION_METHOD_AUTOMATIC
            );
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );

        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );

        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountSelectorMock.selectAccountsWithBrandName(new Set<Id>{ parentAccount.Id }))
            .thenReturn(new List<Account>{ parentAccount });
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersByAccountIds(new Set<Id>{ parentAccount.Id })
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.UNITOFWORK.setMock(uowMock);

        AccountsProvisioningDriveServiceImpl.provisionDriveAccountsByCreationMethod(
            accountIdsByCreationMethod
        );

        ((fflib_SObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
    }

    /**
     * @description It is used to validate that when work order with Withholding having
     * Provisioning Process as 'Automatic' is passed then Biz Ref with "Mp Bz Id"
     * value is created successfully.
     */
    @isTest
    private static void testWhenAutomaticDriveWorkOrdersWithWithholdingEvaluatedThenBizRefCreatedSuccessfullyWithMpBzId() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                ACCOUNT_PRIMARY_VERTICAL_GIFTS,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Legal_Business_Name__c, 'TEST ACCOUNT LEGAL NAME');

        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Map<String, Set<Id>> accountIdsByCreationMethod = new Map<String, Set<Id>>();
        accountIdsByCreationMethod.put(
            PROVISIONING_EVENT_CREATION_METHOD_AUTOMATIC,
            new Set<Id>{ parentAccount.Id }
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                WORKORDER_TYPE_DRIVE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.Sub_Type__c, WITHHOLDING_SUB_TYPE)
            .setField(
                WorkOrder.Business_to_Store_Assignment__c,
                PROVISIONING_EVENT_CREATION_METHOD_AUTOMATIC
            );
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );

        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );

        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountSelectorMock.selectAccountsWithBrandName(new Set<Id>{ parentAccount.Id }))
            .thenReturn(new List<Account>{ parentAccount });
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersByAccountIds(new Set<Id>{ parentAccount.Id })
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.UNITOFWORK.setMock(uowMock);

        AccountsProvisioningDriveServiceImpl.provisionDriveAccountsByCreationMethod(
            accountIdsByCreationMethod
        );

        ((fflib_SObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
    }

    /**
     * @description It is used to validate that when work order with Withholding having
     * Provisioning Process as 'Manual' is passed then Biz Reference with "Mp Bz Id"
     * value is created successfully.
     */
    @isTest
    private static void testWhenManualDriveWorkOrdersWithWithholdingEvaluatedThenBizRefCreatedSuccessfullyWithMpBzId() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Fake parentAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                ACCOUNT_PRIMARY_VERTICAL_GIFTS,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Legal_Business_Name__c, 'TEST ACCOUNT LEGAL NAME');

        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountFakeInstance
        );
        Map<String, Set<Id>> accountIdsByCreationMethod = new Map<String, Set<Id>>();
        accountIdsByCreationMethod.put(
            PROVISIONING_EVENT_CREATION_METHOD_MANUAL,
            new Set<Id>{ parentAccount.Id }
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentAccount.Id,
                WORKORDER_TYPE_DRIVE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.Sub_Type__c, WITHHOLDING_SUB_TYPE)
            .setField(
                WorkOrder.Business_to_Store_Assignment__c,
                PROVISIONING_EVENT_CREATION_METHOD_MANUAL
            );
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );

        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );

        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountSelectorMock.selectAccountsWithBrandName(new Set<Id>{ parentAccount.Id }))
            .thenReturn(new List<Account>{ parentAccount });
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrdersByAccountIds(new Set<Id>{ parentAccount.Id })
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.UNITOFWORK.setMock(uowMock);

        AccountsProvisioningDriveServiceImpl.provisionDriveAccountsByCreationMethod(
            accountIdsByCreationMethod
        );
        ((fflib_SObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
    }
}