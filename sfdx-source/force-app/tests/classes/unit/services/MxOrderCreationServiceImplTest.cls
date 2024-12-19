/**
 * @author Deloitte
 * @date 05/27/2022
 * @description Test class for MxOrderCreationServiceImpl class.
 */
@isTest(seeAllData=false)
public class MxOrderCreationServiceImplTest {
    private static final String ACCOUNT_BILLING_STREET = '221B Baker Street';
    private static final String ACTIVATE_CENTRALLY = 'Yes';
    private static final String BUSINESS_ACCOUNT_NAME = 'Test McDonald Account';
    private static final String CREATION_SOURCE_GUIDED_FLOW = 'Guided Flow';
    private static final String DECISION_MAKER_ROLE = 'Decision Maker';
    private static final String TABLET_BUNDLE_AUS = 'Tablet Bundle (AUS)';
    private static final String TABLET_BUNDLE_US = 'Tablet Bundle (US)';
    private static final String TABLET_BUNDLE_CAN = 'Tablet Bundle (CAN)';
    private static final String TABLET_BUNDLE_NZ = 'Tablet Bundle (NZ)';
    private static final String TABLET_AND_PRINTER_BUNDLE_AUS = 'Tablet & Printer Bundle (AUS)';
    private static final String TABLET_AND_PRINTER_BUNDLE_US = 'Tablet & Printer Bundle (US)';
    private static final String TABLET_AND_PRINTER_BUNDLE_CAN = 'Tablet & Printer Bundle (CAN)';
    private static final String TABLET_AND_PRINTER_BUNDLE_NZ = 'Tablet & Printer Bundle (NZ)';
    private static final String TABLET_DOORDASH_OWNS_ORDER_PROTOCOL = 'Tablet (DoorDash Owns)';
    private static final String TABLET_AND_PRINTER_ORDER_PROTOCOL = 'Tablet and Printer (DoorDash Owns)';
    private static final String US_COUNTRY_CODE = 'US';
    private static final String AUS_COUNTRY_CODE = 'AU';
    private static final String TEST_STATE_CODE = 'CA';
    private static final String TEST_CITY = 'New Jersey';
    private static final String TEST_STREET = 'ABC Street';
    private static final String TEST_POSTAL_CODE = '12345';
    private static final String DELIVER_TABLET = 'Deliver Tablet';
    private static final String TYPE_MARKETING_KIT = 'Marketing Kit';
    private static final String STATUS_NOT_STARTED = 'Not Started';
    private static final String TYPE_PHOTOSHOOT = 'Photoshoot';
    private static final String WORK_PLAN_NAME = 'Photoshoot';
    private static final String WORK_STEP_TYPE_RETURN = 'Deliver Return Label';
    private static final String MOCK_MENU_URL = 'www.MockURL.test';
    private static final String ORDER_PROTOCOL = 'Email';
    private static final String MENU_COMPLETED_BY = 'Account Owner';
    private static final String PHOTOSHOOT_ROLE = 'Photoshoot';
    private static final String WORK_PLAN_STATUS_NOT_STARTED = 'Not Started';
    public static final String STATUS_DRAFT = 'Draft';
    private static final String STATUS_CONFIRMED = 'Confirmed';
    private static final String RETURN_LABEL_BUNDLE = 'Return Label';
    private static final String TYPE_TABLET = 'Tablet';
    private static final String STATUS_SUCCESS = 'Success';
    private static final String SUB_TYPE_SUCCESS = 'Return';
    private static final String DEFECTIVE_TABLET_IMEI = 'ABC00000';
    private static final String ASSERT_MESSAGE_ERROR_MESSAGE_MISMATCH = 'Exception message does not match';
    private static final String NET_NEW = 'Net-New';

    private static final List<String> PRODUCT_BUNDLE_NAMES = new List<String>{
        TABLET_BUNDLE_AUS,
        TABLET_BUNDLE_US,
        TABLET_BUNDLE_CAN,
        TABLET_BUNDLE_NZ,
        TABLET_AND_PRINTER_BUNDLE_AUS,
        TABLET_AND_PRINTER_BUNDLE_US,
        TABLET_AND_PRINTER_BUNDLE_CAN,
        TABLET_AND_PRINTER_BUNDLE_NZ
    };
    /**
     * @description To test when Tablet WorkStep status is changed from Not Workable to Not Started, then
     * create Mx Order by selecting the approriate ProductBundle.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenTabletWorkStepStatusChangedAndBundleIsTabletBundleThenCreateMxOrder() {
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id productBundleId = fflib_IDGenerator.generate(Mx_Order_Product_Bundle__c.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        WorkStep workStep = new WorkStep(
            Id = workStepId,
            Name = DELIVER_TABLET,
            Status__c = STATUS_NOT_STARTED,
            Type__c = DELIVER_TABLET,
            Store_Account__c = storeAccountId
        );
        Account storeAccount = new Account(
            Id = storeAccountId,
            RecordTypeId = storeRecordTypeId,
            ParentId = businessAccountId,
            BillingCountryCode = US_COUNTRY_CODE,
            BillingStateCode = TEST_STATE_CODE,
            BillingCity = TEST_CITY,
            BillingStreet = TEST_STREET,
            BillingPostalCode = TEST_POSTAL_CODE,
            Order_Protocol__c = TABLET_DOORDASH_OWNS_ORDER_PROTOCOL
        );
        Mx_Order_Product_Bundle__c productBundle = new Mx_Order_Product_Bundle__c(
            Name = TABLET_BUNDLE_US,
            Id = productBundleId
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IProductBundlesSelector mockProductBundleSelector = (IProductBundlesSelector) mocks.mock(
            IProductBundlesSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockAccountsSelector.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(mockProductBundleSelector.SObjectType())
            .thenReturn(Mx_Order_Product_Bundle__c.SObjectType);
        mocks.when(mockAccountsSelector.selectById(new Set<Id>{ storeAccountId }))
            .thenReturn(new List<Account>{ storeAccount });
        mocks.when(mockProductBundleSelector.selectByName(PRODUCT_BUNDLE_NAMES))
            .thenReturn(new List<Mx_Order_Product_Bundle__c>{ productBundle });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockAccountsSelector);
        Application.SELECTOR.setMock(mockProductBundleSelector);
        MxOrderCreationService.generateMxOrderAndSelectProduct(new List<WorkStep>{ workStep });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test when flow input is sent then Merchant Order is created successfully.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenFlowInputsReceivedThenCreateMxOrder() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id relatedContactId = fflib_IDGenerator.generate(Contact.SObjectType);
        Id relatedAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id productBundleId = fflib_IDGenerator.generate(Mx_Order_Product_Bundle__c.SObjectType);
        GuidedFlowInputs flowInput = new GuidedFlowInputs();
        flowInput.workOrderId = parentWorkOrderId;
        flowInput.typeOfRequest = 'Net-New';
        flowInput.productBundleName = 'Tablet Bundle (US)';
        flowInput.tabletIMEI = null;
        flowInput.printerIMEI = null;
        flowInput.contactId = relatedContactId;
        flowInput.accountId = relatedAccountId;
        flowInput.shippingStateCode = 'CA';
        flowInput.shippingCountryCode = 'US';
        flowInput.shippingCity = 'City';
        flowInput.shippingStreet = 'Street';
        flowInput.shippingPostalCode = '12345';
        flowInput.workOrder = new WorkOrder(Id = parentWorkOrderId);
        flowInput.replacementReason = null;
        flowInput.reasonForReturn = null;

        Mx_Order_Product_Bundle__c productBundle = new Mx_Order_Product_Bundle__c(
            Name = TABLET_BUNDLE_US,
            Id = productBundleId
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IProductBundlesSelector mockProductBundleSelector = (IProductBundlesSelector) mocks.mock(
            IProductBundlesSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockAccountsSelector.SObjectType()).thenReturn(Account.SobjectType);
        mocks.when(mockProductBundleSelector.SObjectType())
            .thenReturn(Mx_Order_Product_Bundle__c.SObjectType);
        mocks.when(mockAccountsSelector.selectById(new Set<Id>{ relatedAccountId }))
            .thenReturn(
                new List<Account>{
                    new Account(
                        Name = 'Test',
                        Id = relatedAccountId,
                        Order_Protocol__c = 'Tablet (DoorDash Owns)'
                    )
                }
            );
        mocks.when(mockProductBundleSelector.selectByName(new List<String>{ 'Tablet Bundle (US)' }))
            .thenReturn(new List<Mx_Order_Product_Bundle__c>{ productBundle });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockAccountsSelector);
        Application.SELECTOR.setMock(mockProductBundleSelector);
        MxOrderCreationService.generateMerchantOrder(flowInput, true);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test when flow input is sent then Merchant Order is created successfully.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenFlowInputsReceivedForReturnThenCreateMxOrder() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id relatedContactId = fflib_IDGenerator.generate(Contact.SObjectType);
        Id relatedAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id productBundleId = fflib_IDGenerator.generate(Mx_Order_Product_Bundle__c.SObjectType);
        GuidedFlowInputs flowInput = new GuidedFlowInputs();
        flowInput.workOrderId = parentWorkOrderId;
        flowInput.typeOfRequest = 'Return';
        flowInput.productBundleName = 'Tablet Bundle (US)';
        flowInput.tabletIMEI = 'IMEI-TB-001';
        flowInput.printerIMEI = 'IMEI-PT-001';
        flowInput.contactId = relatedContactId;
        flowInput.accountId = relatedAccountId;
        flowInput.shippingStateCode = 'CA';
        flowInput.shippingCountryCode = 'US';
        flowInput.shippingCity = 'City';
        flowInput.shippingStreet = 'Street';
        flowInput.shippingPostalCode = '12345';
        flowInput.workOrder = new WorkOrder(Id = parentWorkOrderId);
        flowInput.replacementReason = null;
        flowInput.reasonForReturn = null;

        Mx_Order_Product_Bundle__c productBundle = new Mx_Order_Product_Bundle__c(
            Name = RETURN_LABEL_BUNDLE,
            Id = productBundleId
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IProductBundlesSelector mockProductBundleSelector = (IProductBundlesSelector) mocks.mock(
            IProductBundlesSelector.class
        );
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockAccountsSelector.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(mockProductBundleSelector.SObjectType())
            .thenReturn(Mx_Order_Product_Bundle__c.SObjectType);
        mocks.when(mockWorkStepsSelector.SObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(mockAccountsSelector.selectById(new Set<Id>{ relatedAccountId }))
            .thenReturn(
                new List<Account>{
                    new Account(
                        Name = 'Test',
                        Id = relatedAccountId,
                        Order_Protocol__c = 'Tablet (DoorDash Owns)'
                    )
                }
            );
        mocks.when(mockProductBundleSelector.selectByName(new List<String>{ RETURN_LABEL_BUNDLE }))
            .thenReturn(new List<Mx_Order_Product_Bundle__c>{ productBundle });
        mocks.when(
                mockWorkStepsSelector.selectReturnLabelWorkStepsByWorkOrderIdsAndType(
                    new Set<Id>{ parentWorkOrderId },
                    new Set<String>{ WORK_STEP_TYPE_RETURN }
                )
            )
            .thenReturn(
                new List<WorkStep>{ new WorkStep(Id = workStepId, WorkPlanId = workPlanId) }
            );
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockAccountsSelector);
        Application.SELECTOR.setMock(mockProductBundleSelector);
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        MxOrderCreationService.generateMerchantOrder(flowInput, false);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test when Tablet WorkStep status is changed from Not Workable to Not Started, then
     * create Mx Order by selecting the approriate ProductBundle.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenTabletWorkStepStatusChangedAndBundleIsTabletBundleAUThenCreateMxOrder() {
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id productBundleId = fflib_IDGenerator.generate(Mx_Order_Product_Bundle__c.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        WorkStep workStep = new WorkStep(
            Id = workStepId,
            Name = DELIVER_TABLET,
            Status__c = STATUS_NOT_STARTED,
            Type__c = DELIVER_TABLET,
            Store_Account__c = storeAccountId
        );
        Account storeAccount = new Account(
            Id = storeAccountId,
            RecordTypeId = storeRecordTypeId,
            ParentId = businessAccountId,
            BillingCountryCode = AUS_COUNTRY_CODE,
            BillingStateCode = TEST_STATE_CODE,
            BillingCity = TEST_CITY,
            BillingStreet = TEST_STREET,
            BillingPostalCode = TEST_POSTAL_CODE,
            Order_Protocol__c = TABLET_DOORDASH_OWNS_ORDER_PROTOCOL
        );
        Mx_Order_Product_Bundle__c productBundle = new Mx_Order_Product_Bundle__c(
            Name = TABLET_BUNDLE_US,
            Id = productBundleId
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IProductBundlesSelector mockProductBundleSelector = (IProductBundlesSelector) mocks.mock(
            IProductBundlesSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockAccountsSelector.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(mockProductBundleSelector.SObjectType())
            .thenReturn(Mx_Order_Product_Bundle__c.SObjectType);
        mocks.when(mockAccountsSelector.selectById(new Set<Id>{ storeAccountId }))
            .thenReturn(new List<Account>{ storeAccount });
        mocks.when(mockProductBundleSelector.selectByName(PRODUCT_BUNDLE_NAMES))
            .thenReturn(new List<Mx_Order_Product_Bundle__c>{ productBundle });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockAccountsSelector);
        Application.SELECTOR.setMock(mockProductBundleSelector);
        MxOrderCreationService.generateMxOrderAndSelectProduct(new List<WorkStep>{ workStep });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test when Tablet WorkStep status is changed from Not Workable to Not Started, then
     * create Mx Order by selecting the approriate ProductBundle.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenTabletWorkStepStatusChangedAndBundleIsTabletANDPrinterBundleThenCreateMxOrder() {
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id productBundleId = fflib_IDGenerator.generate(Mx_Order_Product_Bundle__c.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        WorkStep workStep = new WorkStep(
            Id = workStepId,
            Name = DELIVER_TABLET,
            Status__c = STATUS_NOT_STARTED,
            Type__c = DELIVER_TABLET,
            Store_Account__c = storeAccountId
        );
        Account storeAccount = new Account(
            Id = storeAccountId,
            RecordTypeId = storeRecordTypeId,
            ParentId = businessAccountId,
            BillingCountryCode = US_COUNTRY_CODE,
            BillingStateCode = TEST_STATE_CODE,
            BillingCity = TEST_CITY,
            BillingStreet = TEST_STREET,
            BillingPostalCode = TEST_POSTAL_CODE,
            Order_Protocol__c = TABLET_AND_PRINTER_ORDER_PROTOCOL
        );
        Mx_Order_Product_Bundle__c productBundle = new Mx_Order_Product_Bundle__c(
            Name = TABLET_AND_PRINTER_BUNDLE_US,
            Id = productBundleId
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Product2 tabletProduct = new Product2(Name = 'Tablet');
        insert tabletProduct;
        Mx_Order_Product_Bundle__c mxOrderProductBundle = new Mx_Order_Product_Bundle__c(
            Name = 'Tablet US'
        );
        insert mxOrderProductBundle;
        Mx_Order_Product_Option__c productOptionsForTablet = new Mx_Order_Product_Option__c(
            Mx_Order_Product_Bundle__c = mxOrderProductBundle.Id,
            Product__c = tabletProduct.Id
        );
        insert productOptionsForTablet;
        Mx_Order__c mxOrderToBeInserted = new Mx_Order__c(
            Product_Bundle__c = mxOrderProductBundle.Id
        );
        insert mxOrderToBeInserted;

        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IProductBundlesSelector mockProductBundleSelector = (IProductBundlesSelector) mocks.mock(
            IProductBundlesSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockAccountsSelector.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(mockProductBundleSelector.SObjectType())
            .thenReturn(Mx_Order_Product_Bundle__c.SObjectType);
        mocks.when(mockAccountsSelector.selectById(new Set<Id>{ storeAccountId }))
            .thenReturn(new List<Account>{ storeAccount });
        mocks.when(mockProductBundleSelector.selectByName(PRODUCT_BUNDLE_NAMES))
            .thenReturn(new List<Mx_Order_Product_Bundle__c>{ productBundle });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockAccountsSelector);
        Application.SELECTOR.setMock(mockProductBundleSelector);
        MxOrderCreationService.generateMxOrderAndSelectProduct(new List<WorkStep>{ workStep });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test when Tablet WorkStep status is changed from Not Workable to Not Started, then
     * create Mx Order by selecting the approriate ProductBundle.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenPhotoshootWorkOrderInsertedThenCreateMxOrder() {
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id contactId = Fake.generateId(Contact.class);
        Id acrId = Fake.generateId(AccountContactRelation.class);

        Fake storeAccountFake = new Fake(Account.class)
            .setField(Account.Id, storeAccountId)
            .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
            .setField(Account.BillingCountryCode, US_COUNTRY_CODE)
            .setField(Account.BillingCity, TEST_CITY)
            .setField(Account.BillingStateCode, TEST_STATE_CODE)
            .setField(Account.BillingStreet, ACCOUNT_BILLING_STREET)
            .setField(Account.BillingPostalCode, TEST_POSTAL_CODE)
            .setField(Account.Menu_URL__c, MOCK_MENU_URL);

        Fake mockWorkOrderFake = new Fake(WorkOrder.class)
            .setField(WorkOrder.Status, STATUS_CONFIRMED)
            .setField(WorkOrder.Type__c, TYPE_PHOTOSHOOT)
            .setField(WorkOrder.AccountId, storeAccountId)
            .setField(WorkOrder.ContactId, contactId)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
            .setField(WorkOrder.Menu_to_be_Completed_By__c, MENU_COMPLETED_BY)
            .setField(workOrder.Store_Location_for_Photoshoot__c, storeAccountId)
            .setField(WorkOrder.Id, workOrderId)
            .setParent('Store_Location_for_Photoshoot__r', storeAccountFake);

        WorkPlan mockWorkPlan = (WorkPlan) new Fake(WorkPlan.class)
            .setField(WorkPlan.Id, workPlanId)
            .setField(WorkPlan.Status__c, WORK_PLAN_STATUS_NOT_STARTED)
            .setField(WorkPlan.Name, WORK_PLAN_NAME)
            .setField(WorkPlan.WorkOrderId, workOrderId)
            .setParent('WorkOrder', mockWorkOrderFake)
            .toSObject();

        List<AccountContactRelation> acrList = new List<AccountContactRelation>{
            new AccountContactRelation(
                Id = acrID,
                AccountId = storeAccountId,
                ContactId = contactId,
                Roles = PHOTOSHOOT_ROLE,
                IsActive = true
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkPlansSelector mockWorkPlansSelector = (IWorkPlansSelector) mocks.mock(
            IWorkPlansSelector.class
        );
        IAccountContactRelationsSelector acrSelectorMock = (IAccountContactRelationsSelector) mocks.mock(
            IAccountContactRelationsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkPlansSelector.SObjectType()).thenReturn(WorkPlan.SObjectType);
        mocks.when(
                mockWorkPlansSelector.selectWorkPlansWithWorkOrderAndPhotoShootStoreLocationDetails(
                    new Set<Id>{ workPlanId }
                )
            )
            .thenReturn(new List<WorkPlan>{ mockWorkPlan });
        mocks.when(acrSelectorMock.SObjectType()).thenReturn(AccountContactRelation.SObjectType);
        mocks.when(
                acrSelectorMock.selectPhotoshootContactRolesByAccountIds(
                    new Set<Id>{ storeAccountId }
                )
            )
            .thenReturn(acrList);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkPlansSelector);
        Application.SELECTOR.setMock(acrSelectorMock);
        MxOrderCreationService.generatePhotoShootMxOrder(new List<WorkPlan>{ mockWorkPlan });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test when Marketing Kit Work Plans are inserted then Mx Order is
     * created for it.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMarketingKitWorkPlansAreInsertedThenCreateMxOrder() {
        Id productBundleId = fflib_IDGenerator.generate(Mx_Order_Product_Bundle__c.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id contactId = Fake.generateId(Contact.class);

        Fake storeAccountFake = new Fake(Account.class)
            .setField(Account.Id, storeAccountId)
            .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
            .setField(Account.BillingCountryCode, US_COUNTRY_CODE)
            .setField(Account.BillingCity, TEST_CITY)
            .setField(Account.BillingStateCode, TEST_STATE_CODE)
            .setField(Account.BillingStreet, ACCOUNT_BILLING_STREET)
            .setField(Account.BillingPostalCode, TEST_POSTAL_CODE)
            .setField(Account.Menu_URL__c, MOCK_MENU_URL);

        Fake mockWorkOrderFake = new Fake(WorkOrder.class)
            .setField(WorkOrder.Status, STATUS_CONFIRMED)
            .setField(WorkOrder.Type__c, TYPE_MARKETING_KIT)
            .setField(WorkOrder.AccountId, storeAccountId)
            .setField(WorkOrder.ContactId, contactId)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
            .setField(WorkOrder.Menu_to_be_Completed_By__c, MENU_COMPLETED_BY)
            .setField(WorkOrder.Id, workOrderId)
            .setParent('Account', storeAccountFake)
            .setParent(
                'ParentWorkOrder',
                new Fake(WorkOrder.class)
                    .setField(WorkOrder.ContactId, contactId)
                    .setField(WorkOrder.Creation_Source__c, CREATION_SOURCE_GUIDED_FLOW)
                    .setField(WorkOrder.Product_Bundle__c, TABLET_BUNDLE_AUS)
                    .setField(WorkOrder.Photoshoot_Address__City__s, TEST_CITY)
                    .setField(WorkOrder.Photoshoot_Address__PostalCode__s, TEST_POSTAL_CODE)
                    .setField(WorkOrder.Photoshoot_Address__Street__s, TEST_STREET)
                    .setField(WorkOrder.Photoshoot_Address__StateCode__s, TEST_STATE_CODE)
                    .setField(WorkOrder.Photoshoot_Address__CountryCode__s, US_COUNTRY_CODE)
            );

        WorkPlan mockWorkPlan = (WorkPlan) new Fake(WorkPlan.class)
            .setField(WorkPlan.Id, workPlanId)
            .setField(WorkPlan.Status__c, WORK_PLAN_STATUS_NOT_STARTED)
            .setField(WorkPlan.Name, WORK_PLAN_NAME)
            .setField(WorkPlan.Parent_Work_Plan__c, parentWorkPlanId)
            .setField(WorkPlan.WorkOrderId, workOrderId)
            .setField(WorkPlan.Type__c, TYPE_MARKETING_KIT)
            .setParent('WorkOrder', mockWorkOrderFake)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkPlansSelector mockWorkPlansSelector = (IWorkPlansSelector) mocks.mock(
            IWorkPlansSelector.class
        );
        IAccountContactRelationsSelector acrSelectorMock = (IAccountContactRelationsSelector) mocks.mock(
            IAccountContactRelationsSelector.class
        );
        IWorkStepsSelector workStepsSelectorMock = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        IProductBundlesSelector productBundlesSelectorMock = (IProductBundlesSelector) mocks.mock(
            IProductBundlesSelector.class
        );
        mocks.startStubbing();
        mocks.when(productBundlesSelectorMock.SObjectType())
            .thenReturn(Mx_Order_Product_Bundle__c.SObjectType);
        mocks.when(productBundlesSelectorMock.selectByName(new List<String>{ TABLET_BUNDLE_AUS }))
            .thenReturn(
                new List<Mx_Order_Product_Bundle__c>{
                    new Mx_Order_Product_Bundle__c(Id = productBundleId, Name = TABLET_BUNDLE_AUS)
                }
            );
        mocks.when(workStepsSelectorMock.SObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(workStepsSelectorMock.selectByWorkPlanIds(new Set<Id>{ workPlanId }))
            .thenReturn(
                new List<WorkStep>{ new WorkStep(Id = workStepId, WorkPlanId = workPlanId) }
            );
        mocks.when(mockWorkPlansSelector.SObjectType()).thenReturn(WorkPlan.SObjectType);
        mocks.when(
                mockWorkPlansSelector.selectWorkPlansByWorkPlanIdsAndTypes(
                    new Set<Id>{ workPlanId },
                    new Set<String>{ TYPE_MARKETING_KIT }
                )
            )
            .thenReturn(new List<WorkPlan>{ mockWorkPlan });
        mocks.when(acrSelectorMock.SObjectType()).thenReturn(AccountContactRelation.SObjectType);
        mocks.when(acrSelectorMock.selectByAccountIds(new Set<Id>()))
            .thenReturn(new List<AccountContactRelation>());
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkPlansSelector);
        Application.SELECTOR.setMock(acrSelectorMock);
        Test.startTest();
        MxOrderCreationService.generateMarketingKitMxOrders(new List<WorkPlan>{ mockWorkPlan });
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test when Non-Marketing Kit Work Plans are inserted then No Mx Order is
     * created for it.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenNonMarketingKitWorkPlansInsertedThenDoNotCreateMxOrders() {
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id contactId = Fake.generateId(Contact.class);
        Id acrId = Fake.generateId(AccountContactRelation.class);

        Fake storeAccountFake = new Fake(Account.class)
            .setField(Account.Id, storeAccountId)
            .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
            .setField(Account.BillingCountryCode, US_COUNTRY_CODE)
            .setField(Account.BillingCity, TEST_CITY)
            .setField(Account.BillingStateCode, TEST_STATE_CODE)
            .setField(Account.BillingStreet, ACCOUNT_BILLING_STREET)
            .setField(Account.BillingPostalCode, TEST_POSTAL_CODE)
            .setField(Account.Menu_URL__c, MOCK_MENU_URL);

        Fake mockWorkOrderFake = new Fake(WorkOrder.class)
            .setField(WorkOrder.Status, STATUS_CONFIRMED)
            .setField(WorkOrder.Type__c, TYPE_PHOTOSHOOT)
            .setField(WorkOrder.AccountId, storeAccountId)
            .setField(WorkOrder.ContactId, contactId)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL)
            .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
            .setField(WorkOrder.Menu_to_be_Completed_By__c, MENU_COMPLETED_BY)
            .setField(WorkOrder.Id, workOrderId)
            .setParent('Account', storeAccountFake);

        WorkPlan mockWorkPlan = (WorkPlan) new Fake(WorkPlan.class)
            .setField(WorkPlan.Id, workPlanId)
            .setField(WorkPlan.Status__c, WORK_PLAN_STATUS_NOT_STARTED)
            .setField(WorkPlan.Name, WORK_PLAN_NAME)
            .setField(WorkPlan.WorkOrderId, workOrderId)
            .setField(WorkPlan.Type__c, TYPE_PHOTOSHOOT)
            .setParent('WorkOrder', mockWorkOrderFake)
            .toSObject();

        List<AccountContactRelation> acrList = new List<AccountContactRelation>{
            new AccountContactRelation(
                Id = acrID,
                AccountId = storeAccountId,
                ContactId = contactId,
                Roles = DECISION_MAKER_ROLE,
                IsActive = true
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkPlansSelector mockWorkPlansSelector = (IWorkPlansSelector) mocks.mock(
            IWorkPlansSelector.class
        );
        IAccountContactRelationsSelector acrSelectorMock = (IAccountContactRelationsSelector) mocks.mock(
            IAccountContactRelationsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkPlansSelector.SObjectType()).thenReturn(WorkPlan.SObjectType);
        mocks.when(
                mockWorkPlansSelector.selectWorkPlansByWorkPlanIdsAndTypes(
                    new Set<Id>{ workPlanId },
                    new Set<String>{ TYPE_MARKETING_KIT }
                )
            )
            .thenReturn(new List<WorkPlan>{});
        mocks.when(acrSelectorMock.SObjectType()).thenReturn(AccountContactRelation.SObjectType);
        mocks.when(acrSelectorMock.selectByAccountIds(new Set<Id>{ storeAccountId }))
            .thenReturn(acrList);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkPlansSelector);
        Application.SELECTOR.setMock(acrSelectorMock);
        Test.startTest();
        MxOrderCreationService.generateMarketingKitMxOrders(new List<WorkPlan>{ mockWorkPlan });
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description To test when Tablet Type Bulk Order is created from Bulk Equipment Tab
     * then create Mx orders
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenTabletTypeBulkOrderCreatedFromBulkEquipmentTabThenCreateMxOrder() {
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id productBundleId = fflib_IDGenerator.generate(Mx_Order_Product_Bundle__c.SObjectType);

        Account storeAccount = new Account(
            Id = storeAccountId,
            RecordTypeId = storeRecordTypeId,
            ParentId = businessAccountId,
            BillingCountryCode = US_COUNTRY_CODE,
            BillingStateCode = TEST_STATE_CODE,
            BillingCity = TEST_CITY,
            BillingStreet = TEST_STREET,
            BillingPostalCode = TEST_POSTAL_CODE,
            Order_Protocol__c = TABLET_AND_PRINTER_ORDER_PROTOCOL
        );
        Id workOrderId = Fake.generateId(WorkOrder.class);
        WorkOrder childWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, workOrderId)
            .setField(WorkOrder.AccountId, storeAccount.Id)
            .toSObject();
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        WorkPlan workPlan = new WorkPlan(
            Id = workPlanId,
            WorkOrderId  = childWorkOrder.Id
        );

        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        WorkStep workStep = (WorkStep) new Fake(WorkStep.class)
            .setField(WorkStep.Id, workStepId)
            .setField(WorkStep.Name, DELIVER_TABLET)
            .setField(WorkStep.Status__c, STATUS_NOT_STARTED)
            .setField(WorkStep.Store_Account__c, storeAccountId)
            .setField(WorkStep.WorkPlanId, workPlanId)
            .setField(WorkStep.WorkOrderId, workOrderId)
            .toSObject();

        Id stagingBulkReferenceId = Fake.generateId(Staging_Bulk_Upload_Reference__c.class);
        Staging_Bulk_Upload_Reference__c stagingReferenceRec = (Staging_Bulk_Upload_Reference__c) new Fake(Staging_Bulk_Upload_Reference__c.class)
            .setField(Staging_Bulk_Upload_Reference__c.Id, stagingBulkReferenceId)
            .setField(Staging_Bulk_Upload_Reference__c.Type__c, TYPE_TABLET)
            .setField(Staging_Bulk_Upload_Reference__c.Request_Type__c, SUB_TYPE_SUCCESS)
            .setField(Staging_Bulk_Upload_Reference__c.Status__c, STATUS_SUCCESS)
            .toSObject();

        Id stagingBulkRequestId = Fake.generateId(Staging_Bulk_Upload_Request__c.class);
        Staging_Bulk_Upload_Request__c stagingRequestRec = (Staging_Bulk_Upload_Request__c) new Fake(Staging_Bulk_Upload_Request__c.class)
            .setField(Staging_Bulk_Upload_Request__c.Staging_Upload_Ref__c, stagingReferenceRec.Id)
            .setField(Staging_Bulk_Upload_Request__c.Type__c, TYPE_TABLET)
            .setField(Staging_Bulk_Upload_Request__c.Product_Bundle__c, TABLET_AND_PRINTER_BUNDLE_US)
            .setField(Staging_Bulk_Upload_Request__c.Request_Type__c, SUB_TYPE_SUCCESS)
            .setField(Staging_Bulk_Upload_Request__c.Store_ID__c, storeAccount.id)
            .setField(Staging_Bulk_Upload_Request__c.Id, stagingBulkRequestId)
            .setField(Staging_Bulk_Upload_Request__c.Defective_Tablet_IMEI__c,DEFECTIVE_TABLET_IMEI)
            .toSObject();
        Map<Id,Staging_Bulk_Upload_Request__c> childWOToStagingRequest = new Map<Id,Staging_Bulk_Upload_Request__c>();
        childWOToStagingRequest.put(workOrderId,stagingRequestRec);

        Mx_Order_Product_Bundle__c productBundle = new Mx_Order_Product_Bundle__c(
            Name = TABLET_AND_PRINTER_BUNDLE_US,
            Id = productBundleId
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Product2 tabletProduct = new Product2(Name = 'Tablet');
        insert tabletProduct;
        Mx_Order_Product_Bundle__c mxOrderProductBundle = new Mx_Order_Product_Bundle__c(
            Name = 'Tablet US'
        );
        insert mxOrderProductBundle;
        Mx_Order_Product_Option__c productOptionsForTablet = new Mx_Order_Product_Option__c(
            Mx_Order_Product_Bundle__c = mxOrderProductBundle.Id,
            Product__c = tabletProduct.Id
        );
        insert productOptionsForTablet;
        Mx_Order__c mxOrderToBeInserted = new Mx_Order__c(
            Product_Bundle__c = mxOrderProductBundle.Id
        );
        insert mxOrderToBeInserted;

        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IProductBundlesSelector mockProductBundleSelector = (IProductBundlesSelector) mocks.mock(
            IProductBundlesSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockAccountsSelector.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(mockProductBundleSelector.SObjectType())
            .thenReturn(Mx_Order_Product_Bundle__c.SObjectType);
        mocks.when(mockAccountsSelector.selectById(new Set<Id>{ storeAccountId }))
            .thenReturn(new List<Account>{ storeAccount });
        mocks.when(mockProductBundleSelector.selectByName(new List<String>{TABLET_AND_PRINTER_BUNDLE_US}))
            .thenReturn(new List<Mx_Order_Product_Bundle__c>{ productBundle });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockAccountsSelector);
        Application.SELECTOR.setMock(mockProductBundleSelector);
        Test.startTest();
        MxOrderCreationService.generateMxOrderForTabletBulkRequest(new Map<Id,WorkStep> (new List<WorkStep>{ workStep }),childWOToStagingRequest);
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test when flow input is sent then Exception Thrown.
     */
    @isTest
    private static void testWhenGenerateMerchantOrderThenExceptionThrown() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id relatedContactId = fflib_IDGenerator.generate(Contact.SObjectType);
        Id relatedAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id productBundleId = fflib_IDGenerator.generate(Mx_Order_Product_Bundle__c.SObjectType);
        GuidedFlowInputs flowInput = new GuidedFlowInputs();
        flowInput.workOrderId = parentWorkOrderId;
        flowInput.typeOfRequest = NET_NEW;
        flowInput.productBundleName = TABLET_BUNDLE_US;
        flowInput.tabletIMEI = null;
        flowInput.printerIMEI = null;
        flowInput.contactId = relatedContactId;
        flowInput.accountId = relatedAccountId;
        flowInput.shippingStateCode = TEST_STATE_CODE;
        flowInput.shippingCountryCode = US_COUNTRY_CODE;
        flowInput.shippingCity = TEST_CITY;
        flowInput.shippingStreet = TEST_STREET;
        flowInput.shippingPostalCode = TEST_POSTAL_CODE;
        flowInput.workOrder = new WorkOrder(Id = parentWorkOrderId);
        flowInput.replacementReason = null;
        flowInput.reasonForReturn = null;

        Mx_Order_Product_Bundle__c productBundle = new Mx_Order_Product_Bundle__c(
            Name = TABLET_BUNDLE_US,
            Id = productBundleId
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IProductBundlesSelector mockProductBundleSelector = (IProductBundlesSelector) mocks.mock(
            IProductBundlesSelector.class
        );
        IGenericLogger genericLoggerService = (IGenericLogger) mocks.mock(GenericLoggerImpl.class);

        mocks.startStubbing();
        mocks.when(mockAccountsSelector.SObjectType()).thenReturn(Account.SobjectType);
        mocks.when(mockProductBundleSelector.SObjectType())
            .thenReturn(Mx_Order_Product_Bundle__c.SObjectType);
        mocks.when(mockAccountsSelector.selectById(new Set<Id>{ relatedAccountId }))
            .thenReturn(
                new List<Account>{
                    new Account(
                        Name = BUSINESS_ACCOUNT_NAME,
                        Id = relatedAccountId,
                        Order_Protocol__c = TABLET_DOORDASH_OWNS_ORDER_PROTOCOL
                    )
                }
            );
        mocks.when(mockProductBundleSelector.selectByName(new List<String>{ TABLET_BUNDLE_US }))
            .thenReturn(new List<Mx_Order_Product_Bundle__c>{ productBundle });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockAccountsSelector);
        Application.SELECTOR.setMock(mockProductBundleSelector);
        Application.SERVICE.setMock(IGenericLogger.class, genericLoggerService);
        try {
            MxOrderCreationService.generateMerchantOrder(flowInput, true);
        } catch (Exception mockException) {
            System.assertNotEquals(
                null,
                mockException.getMessage(),
                ASSERT_MESSAGE_ERROR_MESSAGE_MISMATCH
            );
        }
    }
}