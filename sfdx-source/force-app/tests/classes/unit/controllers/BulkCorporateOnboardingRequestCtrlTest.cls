/**
 * @author BizApps
 * @date 31-July-2023
 * @description Test class for the BulkCorporateOnboardingRequestCtrl class.
 **/
@isTest
@SuppressWarnings('PMD.NcssTypeCount')
private class BulkCorporateOnboardingRequestCtrlTest {
    private static final String ASSERT_MESSAGE_FOR_INVALID_DATA = 'Accounts count should match.';
    private static final String ACCOUNT_BILLING_CITY = 'Missoula';
    private static final String ACCOUNT_BILLING_COUNTRY = 'United States';
    private static final String ACCOUNT_BILLING_POSTAL_CODE = '1234';
    private static final String ACCOUNT_BILLING_STATE = 'California';
    private static final String ACCOUNT_BILLING_STREET = '221B Baker Street';
    private static final Schema.Fieldset FIELDS_TO_SHOW_ON_DUPLICATE_ACCOUNT_PAGE = SObjectType.Account.FieldSets.Bulk_Onboarding_Duplicate_Account_Fields;
    private static final String PARENT_CORPORATE_ACCOUNT_NAME = 'Test Business Parent';
    private static final String STORE_ACCOUNT_NAME = 'Test Store Account';
    private static final String REQUEST_STATUS_IN_PROGRESS = 'In Progress';
    private static final String REQUEST_STATUS_ABORTED = 'Aborted';
    private static final String REQUEST_STATUS_COMPLETED = 'Completed';
    private static final String REQUEST_WO_SELECTION_NEW = 'Created New';
    private static final String REQUEST_WO_SELECTION_EXISTING = 'Selected Existing';
    private static final String REQUEST_STAGE_ACCOUNT_FILE_UPLOAD = 'Account File Upload';
    private static final String REQUEST_STAGE_SELECT_ENTITELEMENT = 'Select Entitlement';
    private static final String REQUEST_STAGE_PAYMENT_ACCOUNT = 'Payment Account';
    private static final String REQUEST_STAGE_PROCESSING_STORES = 'Processing Stores';
    private static final String REQUEST_STAGE_FINAL_ERROR_CHECK = 'Final Error Check';
    private static final String UNVERIFIED_STATUS = 'Unverified';
    private static final String VERIFIED_STATUS = 'Verified';
    private static final String REJECTED_STATUS = 'Rejected';
    private static final String IN_COVERAGE = 'In Coverage';
    private static final String NOT_IN_COVERAGE = 'Not in Coverage';
    private static final String ACTIVATE_CENTRALLY_YES = 'Yes';
    private static final String MENU_TO_BE_COMPLETED_BY_ACCOUNT_OWNER = 'Account Owner';
    private static final String STATIC_RESOURCE_TEST_CSV = 'Bulk_Store_Upload_CSV_Test';

    private static final Set<String> DSD_FIELDS_TO_CHECK = new Set<String>{
        'Menu_UI_Type__c',
        'Shopping_Protocol__c',
        'Order_Protocol__c'
    };

    @isTest
    static void testWhenCreatingRequestThenReturnNewRequest() {
        Id contractId = Fake.generateId(Contract.class);
        Id workOrderId = Fake.generateId(WorkOrder.class);

        Process_Flow_Request__c result = BulkCorporateOnboardingRequestCtrl.createRequest(
            contractId,
            workOrderId
        );
        System.assertEquals(
            BulkCorporateOnboardingRequestCtrl.stagesByOrder.get(1),
            result.Stage__c,
            'Stage should be defaulted correctly'
        );
        System.assertEquals(
            REQUEST_STATUS_IN_PROGRESS,
            result.Status__c,
            'Status should be set to In Progress by default'
        );
        System.assertEquals(
            contractId,
            result.Contract__c,
            'The Contract__c field should be set to the Contract.Id by default'
        );
        System.assertEquals(
            workOrderId,
            result.Work_Order__c,
            'The Work_Order__c should be initialized by default.'
        );
    }

    @isTest
    static void testWhenClosingExistingRequetThenSetToAbortedStatus() {
        Id flowRequestId = Fake.generateId(Process_Flow_Request__c.class);

        Process_Flow_Request__c fakeRequest = new Process_Flow_Request__c(
            Id = flowRequestId,
            Status__c = REQUEST_STATUS_IN_PROGRESS
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);

        IProcessFlowRequestsSelector pfrSelectorMock = (IProcessFlowRequestsSelector) mocks.mock(
            IProcessFlowRequestsSelector.class
        );

        mocks.startStubbing();
        mocks.when(pfrSelectorMock.sObjectType()).thenReturn(Process_Flow_Request__c.SObjectType);
        mocks.when(pfrSelectorMock.selectById(new Set<Id>{ flowRequestId }))
            .thenReturn(new List<Process_Flow_Request__c>{ fakeRequest });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(pfrSelectorMock);

        Test.startTest();
        BulkCorporateOnboardingRequestCtrl.closeExistingRequest(flowRequestId);
        Test.stopTest();

        System.assertEquals(
            REQUEST_STATUS_ABORTED,
            fakeRequest.Status__c,
            'Status should be changed to Aborted'
        );
    }

    @isTest
    static void testWhenProvidingContractIdThenReturnOpenRequest() {
        Id contractId = Fake.generateId(Contract.class);
        Id workOrderId = Fake.generateId(WorkOrder.class);

        Process_Flow_Request__c resultShouldBeNull = BulkCorporateOnboardingRequestCtrl.getRequestForContract(
            contractId
        );
        System.assertEquals(
            null,
            resultShouldBeNull,
            'There is no existing PFR for this Contract, so null is expected.'
        );

        Process_Flow_Request__c request1 = (Process_Flow_Request__c) new Fake(
                Process_Flow_Request__c.class
            )
            .setField(Process_Flow_Request__c.Contract__c, contractId)
            .setField(Process_Flow_Request__c.Work_Order__c, workOrderId)
            .setField(
                Process_Flow_Request__c.Stage__c,
                BulkCorporateOnboardingRequestCtrl.stagesByOrder.get(1)
            )
            .setField(Process_Flow_Request__c.Status__c, REQUEST_STATUS_IN_PROGRESS)
            .setFakeId()
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);

        IProcessFlowRequestsSelector pfrSelectorMock = (IProcessFlowRequestsSelector) mocks.mock(
            IProcessFlowRequestsSelector.class
        );

        mocks.startStubbing();
        mocks.when(pfrSelectorMock.sObjectType()).thenReturn(Process_Flow_Request__c.SObjectType);
        mocks.when(pfrSelectorMock.selectOpenRequestsForContractAndUser(contractId))
            .thenReturn(new List<Process_Flow_Request__c>{ request1 });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(pfrSelectorMock);

        Process_Flow_Request__c result = BulkCorporateOnboardingRequestCtrl.getRequestForContract(
            contractId
        );

        System.assertEquals(
            request1.Stage__c,
            result.Stage__c,
            'The Stage value did not match the expected input'
        );
        System.assertEquals(
            request1.Status__c,
            result.Status__c,
            'The Status value did not match the expected input'
        );
        System.assertEquals(
            contractId,
            result.Contract__c,
            'The Contract__c value did not match the expected input'
        );
        System.assertEquals(
            workOrderId,
            result.Work_Order__c,
            'The Work_Order__c value did not match the expected input'
        );
    }

    @isTest
    static void testWhenSubmittingWorkOrderOptionThenProceedToRelevantStage() {
        Id contractId = Fake.generateId(Contract.class);
        Id workOrderId = Fake.generateId(WorkOrder.class);
        Id flowRequestId = Fake.generateId(Process_Flow_Request__c.class);

        Process_Flow_Request__c mockFlowRequest = new Process_Flow_Request__c(
            Id = flowRequestId,
            Work_Order__c = workOrderId,
            Contract__c = contractId,
            Status__c = REQUEST_STATUS_IN_PROGRESS,
            Stage__c = BulkCorporateOnboardingRequestCtrl.stagesByOrder.get(1)
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IProcessFlowRequestsSelector pfrSelectorMock = (IProcessFlowRequestsSelector) mocks.mock(
            IProcessFlowRequestsSelector.class
        );

        mocks.startStubbing();
        mocks.when(pfrSelectorMock.sObjectType()).thenReturn(Process_Flow_Request__c.SObjectType);
        mocks.when(pfrSelectorMock.selectById(new Set<Id>{ flowRequestId }))
            .thenReturn(new List<Process_Flow_Request__c>{ mockFlowRequest });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(pfrSelectorMock);

        // Verify expectations for scenario with new Work Order
        Process_Flow_Request__c newRequest = BulkCorporateOnboardingRequestCtrl.submitRequest(
            flowRequestId,
            contractId,
            true
        );
        System.assertEquals(contractId, newRequest.Contract__c, 'Contract ID should match');
        System.assertEquals(
            REQUEST_STATUS_IN_PROGRESS,
            newRequest.Status__c,
            'Status should be In Progress'
        );
        System.assertEquals(
            REQUEST_WO_SELECTION_NEW,
            newRequest.Work_Order_Selection_Method__c,
            'Work Order Selection Method should be Created New'
        );
        System.assertEquals(
            BulkCorporateOnboardingRequestCtrl.stagesByOrder.get(2),
            newRequest.Stage__c,
            'Stage should be set to Work Order Creation'
        );

        // Verify expectations for scenario with existing WO
        Process_Flow_Request__c existingRequest = BulkCorporateOnboardingRequestCtrl.submitRequest(
            null,
            contractId,
            false
        );
        System.assertEquals(contractId, existingRequest.Contract__c, 'Contract ID should match');
        System.assertEquals(
            REQUEST_STATUS_IN_PROGRESS,
            existingRequest.Status__c,
            'Status should be In Progress'
        );
        System.assertEquals(
            REQUEST_WO_SELECTION_EXISTING,
            existingRequest.Work_Order_Selection_Method__c,
            'Work Order Selection Method should be Selected Existing'
        );
        System.assertEquals(
            BulkCorporateOnboardingRequestCtrl.stagesByOrder.get(3),
            existingRequest.Stage__c,
            'Stage should be set to Work Order Association'
        );

        // Verify null/error scenario
        mocks.startStubbing();
        mocks.when(pfrSelectorMock.selectById(new Set<Id>{ flowRequestId })).thenReturn(null);
        mocks.stopStubbing();

        Boolean errorIsThrown = false;

        try {
            BulkCorporateOnboardingRequestCtrl.submitRequest(flowRequestId, contractId, false);
        } catch (Exception ex) {
            errorIsThrown = true;
        }

        System.assert(
            errorIsThrown,
            'An exception should have been thrown if no Process Flow Request record is found from the given ID.'
        );
    }

    @isTest
    static void testWhenAttachingAnExistingWorkOrderThenLinkWorkOrderToRequest() {
        Id flowRequestId = Fake.generateId(Process_Flow_Request__c.class);
        Id selectedWorkOrderId = Fake.generateId(WorkOrder.class);

        // Mocking the required objects and methods
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        // Assume getFlowRequestById is a method that retrieves the Process_Flow_Request__c record
        Process_Flow_Request__c mockFlowRequest = new Process_Flow_Request__c(
            Id = flowRequestId,
            Work_Order__c = selectedWorkOrderId,
            Status__c = REQUEST_STATUS_IN_PROGRESS,
            Stage__c = BulkCorporateOnboardingRequestCtrl.stagesByOrder.get(1)
        );

        IProcessFlowRequestsSelector pfrSelectorMock = (IProcessFlowRequestsSelector) mocks.mock(
            IProcessFlowRequestsSelector.class
        );

        mocks.startStubbing();
        mocks.when(pfrSelectorMock.sObjectType()).thenReturn(Process_Flow_Request__c.SObjectType);
        mocks.when(pfrSelectorMock.selectById(new Set<Id>{ flowRequestId }))
            .thenReturn(new List<Process_Flow_Request__c>{ mockFlowRequest });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(pfrSelectorMock);

        // Invoke the method
        Test.startTest();
        Process_Flow_Request__c updatedRequest = BulkCorporateOnboardingRequestCtrl.linkExistingWorkOrder(
            flowRequestId,
            selectedWorkOrderId
        );
        Test.stopTest();

        // Verify expectations based on functional requirements
        System.assertEquals(
            selectedWorkOrderId,
            updatedRequest.Work_Order__c,
            'Work Order ID should match'
        );
        System.assertEquals(
            REQUEST_WO_SELECTION_EXISTING,
            updatedRequest.Work_Order_Selection_Method__c,
            'Work Order Selection Method should be Selected Existing'
        );
        System.assertEquals(
            BulkCorporateOnboardingRequestCtrl.stagesByOrder.get(4),
            updatedRequest.Stage__c,
            'Stage should match'
        );
    }

    @isTest
    static void testWhenSubmittingIncompleteWorkOrderFieldsThenReturnError() {
        Id flowRequestId = Fake.generateId(Process_Flow_Request__c.class);
        Map<String, Object> workOrderFields = new Map<String, Object>{
            'Proposed_Date_of_Activation__c' => String.valueOf(Date.newInstance(2023, 1, 22)),
            'Order_Protocol__c' => 'POS',
            'AccountId' => Fake.generateId(Account.class),
            'Contract__c' => Fake.generateId(Contract.class)
        };

        // Mocking the required objects and methods
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        Process_Flow_Request__c mockFlowRequest = new Process_Flow_Request__c(
            Id = flowRequestId,
            Status__c = REQUEST_STATUS_IN_PROGRESS,
            Stage__c = BulkCorporateOnboardingRequestCtrl.stagesByOrder.get(1)
        );

        IProcessFlowRequestsSelector pfrSelectorMock = (IProcessFlowRequestsSelector) mocks.mock(
            IProcessFlowRequestsSelector.class
        );

        mocks.startStubbing();
        mocks.when(pfrSelectorMock.sObjectType()).thenReturn(Process_Flow_Request__c.SObjectType);
        mocks.when(pfrSelectorMock.selectById(new Set<Id>{ flowRequestId }))
            .thenReturn(new List<Process_Flow_Request__c>{ mockFlowRequest });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(pfrSelectorMock);

        Boolean errorThrown = false;

        try {
            BulkCorporateOnboardingRequestCtrl.submitNewWorkOrder(flowRequestId, workOrderFields);
        } catch (Exception ex) {
            errorThrown = true;
        }

        System.assert(errorThrown, 'This method should have generated an exception');
    }

    @IsTest
    static void testWhenSubmittingWorkOrderThatFailsReadinessValidationsThenReturnError() {
        Id flowRequestId = Fake.generateId(Process_Flow_Request__c.class);
        Map<String, Object> workOrderFields = new Map<String, Object>{
            'Proposed_Date_of_Activation__c' => String.valueOf(Date.newInstance(2023, 1, 22)),
            'Order_Protocol__c' => 'POS',
            'Activated_Centrally_AC__c' => ACTIVATE_CENTRALLY_YES,
            'Menu_to_be_Completed_By__c' => MENU_TO_BE_COMPLETED_BY_ACCOUNT_OWNER,
            'AccountId' => Fake.generateId(Account.class),
            'Contract__c' => Fake.generateId(Contract.class)
        };

        // Mocking the required objects and methods
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        Process_Flow_Request__c mockFlowRequest = new Process_Flow_Request__c(
            Id = flowRequestId,
            Status__c = REQUEST_STATUS_IN_PROGRESS,
            Stage__c = BulkCorporateOnboardingRequestCtrl.stagesByOrder.get(1)
        );

        IProcessFlowRequestsSelector pfrSelectorMock = (IProcessFlowRequestsSelector) mocks.mock(
            IProcessFlowRequestsSelector.class
        );

        mocks.startStubbing();
        mocks.when(pfrSelectorMock.sObjectType()).thenReturn(Process_Flow_Request__c.SObjectType);
        mocks.when(pfrSelectorMock.selectById(new Set<Id>{ flowRequestId }))
            .thenReturn(new List<Process_Flow_Request__c>{ mockFlowRequest });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(pfrSelectorMock);

        Boolean errorThrown = false;

        try {
            BulkCorporateOnboardingRequestCtrl.submitNewWorkOrder(flowRequestId, workOrderFields);
        } catch (Exception ex) {
            errorThrown = true;
        }
        System.assert(errorThrown, 'This method should have generated an exception');
    }

    @IsTest
    static void testWhenSubmittingValidWorkOrderFieldsThenCreate() {
        Id flowRequestId = Fake.generateId(Process_Flow_Request__c.class);
        Map<String, Object> workOrderFields = new Map<String, Object>{
            'Proposed_Date_of_Activation__c' => String.valueOf(Date.newInstance(2023, 1, 22)),
            'Order_Protocol__c' => 'Email',
            'Activated_Centrally_AC__c' => 'No',
            'Menu_to_be_Completed_By__c' => 'Merchant',
            'Type' => 'Marketplace',
            'AccountId' => Fake.generateId(Account.class),
            'Contract__c' => Fake.generateId(Contract.class)
        };

        // Mocking the required objects and methods
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        Process_Flow_Request__c mockFlowRequest = new Process_Flow_Request__c(
            Id = flowRequestId,
            Status__c = REQUEST_STATUS_IN_PROGRESS,
            Stage__c = BulkCorporateOnboardingRequestCtrl.stagesByOrder.get(1)
        );

        IProcessFlowRequestsSelector pfrSelectorMock = (IProcessFlowRequestsSelector) mocks.mock(
            IProcessFlowRequestsSelector.class
        );

        mocks.startStubbing();
        mocks.when(pfrSelectorMock.sObjectType()).thenReturn(Process_Flow_Request__c.SObjectType);
        mocks.when(pfrSelectorMock.selectById(new Set<Id>{ flowRequestId }))
            .thenReturn(new List<Process_Flow_Request__c>{ mockFlowRequest });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(pfrSelectorMock);

        Process_Flow_Request__c result = BulkCorporateOnboardingRequestCtrl.submitNewWorkOrder(
            flowRequestId,
            workOrderFields
        );
        System.assertEquals(
            result.Work_Order_Selection_Method__c,
            REQUEST_WO_SELECTION_NEW,
            'Work Order Selection Method should be set.'
        );
        System.assertEquals(
            result.Stage__c,
            REQUEST_STAGE_ACCOUNT_FILE_UPLOAD,
            'Work Order Stage should be moved to File Upload'
        );
    }

    @IsTest
    @SuppressWarnings('PMD.AvoidHardcodingId')
    static void testWhenValidCsvIsInputtedThenUploadFile() {
        StaticResource sr = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_CSV
        ];
        Blob blobCSV = sr.Body;
        String csvString = blobCSV.toString();
        String[] rows = csvString.split('\n');
        List<List<String>> csvValues = new List<List<String>>();

        for (String row : rows) {
            List<String> rowValues = row.split(',');
            rowValues = parseCsvRow(rowValues);
            csvValues.add(rowValues);
        }

        // Encode the JSON string to base64
        String base64Encoded = EncodingUtil.base64Encode(Blob.valueOf(JSON.serialize(csvValues)));

        Id parentAccountId = '0017600000ZuxpWAAR'; // Used in CSV template
        Id accountId = Fake.generateId(Account.SObjectType);
        Id workOrderId = Fake.generateId(WorkOrder.class);
        Id contractId = Fake.generateId(Contract.class);
        Id flowRequestId = Fake.generateId(Process_Flow_Request__c.class);

        List<Account> accountList = new List<Account>{
            new Account(Id = parentAccountId, Name = 'Parent 1'),
            new Account(Id = accountId, ParentId = parentAccountId, Name = 'Child 1')
        };

        List<Contract> contractList = new List<Contract>{
            new Contract(Id = contractId, AccountId = accountId, Status = 'Draft')
        };

        Process_Flow_Request__c mockFlowRequest = new Process_Flow_Request__c(
            Id = flowRequestId,
            Work_Order__c = workOrderId,
            Contract__c = contractId,
            Status__c = REQUEST_STATUS_IN_PROGRESS,
            Stage__c = BulkCorporateOnboardingRequestCtrl.stagesByOrder.get(4)
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);

        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IContractsSelector contractsSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        IProcessFlowRequestsSelector pfrSelectorMock = (IProcessFlowRequestsSelector) mocks.mock(
            IProcessFlowRequestsSelector.class
        );

        mocks.startStubbing();
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(contractsSelectorMock.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(pfrSelectorMock.sObjectType()).thenReturn(Process_Flow_Request__c.SObjectType);
        mocks.when(
                accountsSelectorMock.selectAllChildCorporateAccountsWithParent(
                    new Set<String>{ accountId }
                )
            )
            .thenReturn(accountList);
        mocks.when(contractsSelectorMock.selectById(new Set<Id>{ contractId }))
            .thenReturn(contractList);
        mocks.when(pfrSelectorMock.selectById(new Set<Id>{ flowRequestId }))
            .thenReturn(new List<Process_Flow_Request__c>{ mockFlowRequest });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(contractsSelectorMock);
        Application.SELECTOR.setMock(pfrSelectorMock);

        BulkCorporateOnboardingRequestCtrl.BulkOnboardingWrapper result = BulkCorporateOnboardingRequestCtrl.uploadFileRows(
            base64Encoded,
            flowRequestId,
            1,
            1
        );
        System.assertNotEquals(null, result, 'The result should not be null.');
    }

    @isTest
    static void testWhenGivenPaymentAccountThenLinkRelatedRecords() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        Id flowRequestId = Fake.generateId(Process_Flow_Request__c.class);
        Id paymentAccountId = Fake.generateId(Payment_Account__c.class);
        Id storeId = Fake.generateId(Account.class);

        List<BulkCorporateOnboardingWrappers.StoreInfo> stores = new List<BulkCorporateOnboardingWrappers.StoreInfo>{
            new BulkCorporateOnboardingWrappers.StoreInfo(storeId, null, null)
        };

        Process_Flow_Request__c flowRequest = new Process_Flow_Request__c(
            Id = flowRequestId,
            Serialized_Object_Data__c = BulkCorporateOnboardingRequestService.packStoreInfos(stores)
        );

        List<Account> storeAccounts = new List<Account>{
            new Account(Id = storeId, Bulk_Corporate_Onboarding_Request__c = flowRequestId)
        };

        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IProcessFlowRequestsSelector pfrSelectorMock = (IProcessFlowRequestsSelector) mocks.mock(
            IProcessFlowRequestsSelector.class
        );

        mocks.startStubbing();
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.getStoresByBulkOnboardingRequestId(flowRequestId))
            .thenReturn(storeAccounts);
        mocks.when(
                accountsSelectorMock.selectAccountWithOutFilterswithSetOfFieldsPassed(
                    DSD_FIELDS_TO_CHECK,
                    new Set<Id>{ storeId }
                )
            )
            .thenReturn(storeAccounts);
        mocks.when(pfrSelectorMock.sObjectType()).thenReturn(Process_Flow_Request__c.SObjectType);
        mocks.when(pfrSelectorMock.selectById(new Set<Id>{ flowRequestId }))
            .thenReturn(new List<Process_Flow_Request__c>{ flowRequest });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(pfrSelectorMock);

        Test.startTest();
        Process_Flow_Request__c updatedFlowRequest = BulkCorporateOnboardingRequestCtrl.linkRelatedRecords(
            flowRequestId,
            paymentAccountId,
            false
        );
        Test.stopTest();

        List<BulkCorporateOnboardingWrappers.StoreInfo> deserializedStores = BulkCorporateOnboardingRequestService.unpackStoreInfos(
            flowRequestId,
            updatedFlowRequest.Serialized_Object_Data__c
        );

        BulkCorporateOnboardingWrappers.StoreInfo firstStore = deserializedStores[0];
        System.assertEquals(
            paymentAccountId,
            firstStore.paymentAccountId,
            'Payment account should be linked'
        );
    }

    @IsTest
    static void testWhenDasherShopDeliverStoresAreLoadedThenProvidePaymentAccountSkipOption() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        Id flowRequestId = Fake.generateId(Process_Flow_Request__c.class);
        Id storeId = Fake.generateId(Account.class);
        Id storeId2 = Fake.generateId(Account.class);

        List<BulkCorporateOnboardingWrappers.StoreInfo> stores = new List<BulkCorporateOnboardingWrappers.StoreInfo>{
            new BulkCorporateOnboardingWrappers.StoreInfo(storeId, null, null),
            new BulkCorporateOnboardingWrappers.StoreInfo(storeId2, null, null)
        };

        Set<Id> storeIds = new Set<Id>{ storeId, storeId2 };

        Process_Flow_Request__c flowRequest = new Process_Flow_Request__c(
            Id = flowRequestId,
            Serialized_Object_Data__c = BulkCorporateOnboardingRequestService.packStoreInfos(stores)
        );

        List<Account> storeAccounts = new List<Account>{
            new Account(Id = storeId, Bulk_Corporate_Onboarding_Request__c = flowRequestId),
            new Account(
                Id = storeId2,
                Bulk_Corporate_Onboarding_Request__c = flowRequestId,
                Menu_UI_Type__c = 'Retail',
                Shopping_Protocol__c = 'Dasher Pick',
                Order_Protocol__c = 'POS'
            )
        };

        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IProcessFlowRequestsSelector pfrSelectorMock = (IProcessFlowRequestsSelector) mocks.mock(
            IProcessFlowRequestsSelector.class
        );

        mocks.startStubbing();
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.getStoresByBulkOnboardingRequestId(flowRequestId))
            .thenReturn(storeAccounts);
        mocks.when(
                accountsSelectorMock.selectAccountWithOutFilterswithSetOfFieldsPassed(
                    DSD_FIELDS_TO_CHECK,
                    storeIds
                )
            )
            .thenReturn(storeAccounts);
        mocks.when(pfrSelectorMock.sObjectType()).thenReturn(Process_Flow_Request__c.SObjectType);
        mocks.when(pfrSelectorMock.selectById(new Set<Id>{ flowRequestId }))
            .thenReturn(new List<Process_Flow_Request__c>{ flowRequest });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(pfrSelectorMock);

        Test.startTest();
        Boolean shouldBeTrue = BulkCorporateOnboardingRequestCtrl.isEligibleToSkipPaymentAccountStep(
            flowRequestId
        );
        Test.stopTest();

        System.assert(
            shouldBeTrue,
            'This should be eligible for skipping the PA step due to having DSD stores'
        );

        Boolean shouldThrowException = false;
        try {
            BulkCorporateOnboardingRequestCtrl.isEligibleToSkipPaymentAccountStep(null);
        } catch (AuraHandledException ex) {
            shouldThrowException = true;
        }
        System.assert(
            shouldThrowException,
            'An exception should be thrown in the null scenario, returning an error to the front-end'
        );
    }

    @isTest
    static void testWhenGivenDecisionMakerThenLinkRelatedRecords() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        Id flowRequestId = Fake.generateId(Process_Flow_Request__c.class);
        Id contactId = Fake.generateId(Contact.class);
        Id storeId = Fake.generateId(Account.class);

        List<BulkCorporateOnboardingWrappers.StoreInfo> stores = new List<BulkCorporateOnboardingWrappers.StoreInfo>{
            new BulkCorporateOnboardingWrappers.StoreInfo(storeId, null, null)
        };
        List<Account> storeAccounts = new List<Account>{
            new Account(Id = storeId, Bulk_Corporate_Onboarding_Request__c = flowRequestId)
        };

        Process_Flow_Request__c flowRequest = new Process_Flow_Request__c(
            Id = flowRequestId,
            Serialized_Object_Data__c = BulkCorporateOnboardingRequestService.packStoreInfos(stores)
        );

        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IProcessFlowRequestsSelector pfrSelectorMock = (IProcessFlowRequestsSelector) mocks.mock(
            IProcessFlowRequestsSelector.class
        );

        mocks.startStubbing();
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.getStoresByBulkOnboardingRequestId(flowRequestId))
            .thenReturn(storeAccounts);
        mocks.when(
                accountsSelectorMock.selectAccountWithOutFilterswithSetOfFieldsPassed(
                    DSD_FIELDS_TO_CHECK,
                    new Set<Id>{ storeId }
                )
            )
            .thenReturn(storeAccounts);
        mocks.when(pfrSelectorMock.sObjectType()).thenReturn(Process_Flow_Request__c.SObjectType);
        mocks.when(pfrSelectorMock.selectById(new Set<Id>{ flowRequestId }))
            .thenReturn(new List<Process_Flow_Request__c>{ flowRequest });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(pfrSelectorMock);

        Test.startTest();
        Process_Flow_Request__c updatedFlowRequest = BulkCorporateOnboardingRequestCtrl.linkRelatedRecords(
            flowRequestId,
            contactId,
            false
        );
        Test.stopTest();

        List<BulkCorporateOnboardingWrappers.StoreInfo> deserializedStores = BulkCorporateOnboardingRequestService.unpackStoreInfos(
            flowRequestId,
            updatedFlowRequest.Serialized_Object_Data__c
        );

        BulkCorporateOnboardingWrappers.StoreInfo firstStore = deserializedStores[0];
        System.assertEquals(contactId, firstStore.decisionMakerId, 'Contact should be linked');
    }

    @IsTest
    static void testWhenMultipleRecordsAreSelectedThenLinkRelatedRecords() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        Id flowRequestId = Fake.generateId(Process_Flow_Request__c.class);
        Id workOrderId = Fake.generateId(WorkOrder.class);
        Id businessId = Fake.generateId(Account.class);
        Id storeId = Fake.generateId(Account.class);
        Id storeId2 = Fake.generateId(Account.class);
        Id storeId3 = Fake.generateId(Account.class);
        Id paymentAccountId = Fake.generateId(Payment_Account__c.class);
        Id decisionMakerId = Fake.generateId(Contact.class);

        List<BulkCorporateOnboardingWrappers.StoreInfo> stores = new List<BulkCorporateOnboardingWrappers.StoreInfo>{
            new BulkCorporateOnboardingWrappers.StoreInfo(storeId, null, null),
            new BulkCorporateOnboardingWrappers.StoreInfo(storeId2, null, null),
            new BulkCorporateOnboardingWrappers.StoreInfo(storeId3, null, null)
        };
        List<Account> storeAccounts = new List<Account>{
            new Account(Id = storeId, Bulk_Corporate_Onboarding_Request__c = flowRequestId),
            new Account(Id = storeId2, Bulk_Corporate_Onboarding_Request__c = flowRequestId),
            new Account(Id = storeId3, Bulk_Corporate_Onboarding_Request__c = flowRequestId)
        };

        WorkOrder testWorkOrder = new WorkOrder(
            Id = workOrderId,
            AccountId = businessId,
            Order_Protocol__c = System.Label.LaunchEventOrderProtocolTablet
        );

        Process_Flow_Request__c flowRequest = new Process_Flow_Request__c(
            Id = flowRequestId,
            Work_Order__c = workOrderId,
            Serialized_Object_Data__c = BulkCorporateOnboardingRequestService.packStoreInfos(stores)
        );

        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IProcessFlowRequestsSelector pfrSelectorMock = (IProcessFlowRequestsSelector) mocks.mock(
            IProcessFlowRequestsSelector.class
        );
        IWorkOrdersSelector workOrdersSelectorMock = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );

        mocks.startStubbing();
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.getStoresByBulkOnboardingRequestId(flowRequestId))
            .thenReturn(storeAccounts);
        mocks.when(pfrSelectorMock.sObjectType()).thenReturn(Process_Flow_Request__c.SObjectType);
        mocks.when(pfrSelectorMock.selectById(new Set<Id>{ flowRequestId }))
            .thenReturn(new List<Process_Flow_Request__c>{ flowRequest });
        mocks.when(workOrdersSelectorMock.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(workOrdersSelectorMock.selectById(new Set<Id>{ workOrderId }))
            .thenReturn(new List<WorkOrder>{ testWorkOrder });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(pfrSelectorMock);
        Application.SELECTOR.setMock(workOrdersSelectorMock);

        // Update StoreInfos as they would be from the LWC
        stores[0].paymentAccountId = paymentAccountId;
        stores[1].paymentAccountId = paymentAccountId;

        String storeInfosStr = JSON.serialize(stores);

        // Positive Test #1 - Some records selected; isComplete should be false
        BulkCorporateOnboardingWrappers.RelatedRecordCompletionInfo completionObjNotFinished = BulkCorporateOnboardingRequestCtrl.linkRelatedRecordWithSelectedStores(
            flowRequestId,
            paymentAccountId,
            storeInfosStr
        );

        System.assert(
            !completionObjNotFinished.isComplete,
            'Not all stores have selected records; `isComplete` should be false.'
        );

        // Positive Test #2 - Remainder of records selected; isComplete should be true
        // Update StoreInfos as they would be from the LWC
        stores[2].paymentAccountId = paymentAccountId;
        storeInfosStr = JSON.serialize(stores);
        BulkCorporateOnboardingWrappers.RelatedRecordCompletionInfo completionObjFinished = BulkCorporateOnboardingRequestCtrl.linkRelatedRecordWithSelectedStores(
            flowRequestId,
            paymentAccountId,
            storeInfosStr
        );
        System.assert(
            completionObjFinished.isComplete,
            'All stores have selected records; `isComplete` should be true.'
        );

        // Negative Test #1 - No store information passed to method
        BulkCorporateOnboardingWrappers.RelatedRecordCompletionInfo emptyScenario = BulkCorporateOnboardingRequestCtrl.linkRelatedRecordWithSelectedStores(
            flowRequestId,
            paymentAccountId,
            JSON.serialize(new List<BulkCorporateOnboardingWrappers.StoreInfo>())
        );
        System.assert(!emptyScenario.isComplete, 'No records passed; `isComplete` should be true.');

        // Negative Test #2 - Null input to method
        Boolean errorThrown = false;
        try {
            BulkCorporateOnboardingRequestCtrl.linkRelatedRecordWithSelectedStores(
                flowRequestId,
                paymentAccountId,
                null
            );
        } catch (Exception ex) {
            errorThrown = ex != null;
        }
        System.assert(errorThrown, 'The null scenario should return an error to the UI');

        // Negative Test #3 - Decision Maker without a Phone on a Tablet WO
        Boolean errorThrownForDecisionMakerPhone = false;
        stores[0].decisionMakerId = decisionMakerId;
        storeInfosStr = JSON.serialize(stores);
        try {
            BulkCorporateOnboardingRequestCtrl.linkRelatedRecordWithSelectedStores(
                flowRequestId,
                decisionMakerId,
                storeInfosStr
            );
        } catch (Exception ex) {
            errorThrownForDecisionMakerPhone = true;
        }

        System.assert(
            errorThrownForDecisionMakerPhone,
            'Phone is required for DMs related to Tablet WOs'
        );
    }

    /**
     * @description It is used to check whether the match accounts are returned when
     * existing accounts are uploaded in csv.
     */
    @isTest
    private static void testWhenExistingAccountsUploadedThenMatchingAccountsReturned() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id businessAccountId = Fake.generateId(Account.class);
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Id storeAccountId = Fake.generateId(Account.class);

        Account businessAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, businessAccountId)
            .setField(Account.RecordTypeId, businessRecordTypeId)
            .toSObject();

        Account storeAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, storeAccountId)
            .setField(Account.BillingStreet, ACCOUNT_BILLING_STREET)
            .setField(Account.BillingCity, ACCOUNT_BILLING_CITY)
            .setField(Account.BillingState, ACCOUNT_BILLING_STATE)
            .setField(Account.BillingPostalCode, ACCOUNT_BILLING_POSTAL_CODE)
            .setField(Account.BillingCountry, ACCOUNT_BILLING_COUNTRY)
            .setField(Account.RecordTypeId, storeRecordTypeId)
            .setParent('Parent', new Fake(Account.class).setField(Account.Id, businessAccount.Id))
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        AccountsSelector accountsSelectorMock = (AccountsSelector) mocks.mock(
            AccountsSelector.class
        );
        mocks.startStubbing();
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                accountsSelectorMock.selectAccountsByIdAndFieldSet(
                    (Schema.Fieldset) fflib_Match.anyObject(),
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<Account>{ storeAccount });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(accountsSelectorMock);
        List<Account> accounts = BulkCorporateOnboardingRequestCtrl.getMatchingAccountsDetails(
            new List<Id>{ storeAccount.Id }
        );
        System.assertEquals(1, accounts.size(), ASSERT_MESSAGE_FOR_INVALID_DATA);
    }

    @isTest
    static void testWhenSelectWorkOrderIsSelectedThenReturnExistingWorkOrders() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        Id accountId = Fake.generateId(Account.class);
        List<WorkOrder> expectedWorkOrders = new List<WorkOrder>{
            new WorkOrder(Id = Fake.generateId(WorkOrder.class), AccountId = accountId),
            new WorkOrder(Id = Fake.generateId(WorkOrder.class), AccountId = accountId)
        };

        WorkOrdersSelector workOrderSelectorMock = (WorkOrdersSelector) mocks.mock(
            WorkOrdersSelector.class
        );
        mocks.startStubbing();
        mocks.when(workOrderSelectorMock.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(workOrderSelectorMock.selectWorkOrderDetailsForAccount(accountId))
            .thenReturn(expectedWorkOrders);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(workOrderSelectorMock);

        Test.startTest();
        List<WorkOrder> actualWorkOrders = BulkCorporateOnboardingRequestCtrl.getExistingWorkOrders(
            accountId
        );
        Test.stopTest();

        System.assertEquals(
            expectedWorkOrders.size(),
            actualWorkOrders.size(),
            'Work order count should match.'
        );
        for (Integer i = 0; i < expectedWorkOrders.size(); i++) {
            System.assertEquals(
                expectedWorkOrders[i].Id,
                actualWorkOrders[i].Id,
                'WorkOrder Id should match.'
            );
        }
    }

    @isTest
    static void testWhenProvidingWorkOrderFieldsThenBuildWorkOrder() {
        Id fakeAccountId = Fake.generateId(Account.class);

        // Setup a map of WorkOrder fields
        Map<String, Object> workOrderFields = new Map<String, Object>{
            'AccountId' => fakeAccountId,
            'Status' => 'Draft',
            'Proposed_Date_of_Activation__c' => '2022-05-15',
            'InvalidField' => 'xyz'
        };

        // Execute
        Test.startTest();
        WorkOrder resultWo = BulkCorporateOnboardingRequestCtrl.buildWorkOrderFromUserInput(
            workOrderFields
        );
        Test.stopTest();

        // Verify
        System.assertEquals(fakeAccountId, resultWo.AccountId, 'AccountId should be set correctly');
        System.assertEquals('Draft', resultWo.Status, 'Status should be set to Draft');
        System.assertEquals(
            Date.valueOf('2022-05-15'),
            resultWo.get('Proposed_Date_of_Activation__c'),
            'Proposed_Date_of_Activation__c should be set to 2022-05-15'
        );
    }

    @isTest
    static void testWhenCallingPaymentAccountRecordTypeMethodThenReturnPaymentAccountRecordTypeId() {
        Id expectedRecordTypeId = Schema.SObjectType.Payment_Account__c.getRecordTypeInfosByName()
            .get('Payments')
            .getRecordTypeId();
        System.assertEquals(
            expectedRecordTypeId,
            BulkCorporateOnboardingRequestCtrl.getPaymentsRecordType(),
            'Incorrect Id returned for `Payments` RecordType'
        );
    }

    @IsTest
    static void testWhenUsingDataMappingMetadataThenGetAcceptedPicklistValues() {
        BulkCorporateOnboardingRequestCtrl.TemplateFieldInformation fieldInfo = BulkCorporateOnboardingRequestCtrl.getTemplateFieldsInformation();
        List<BulkCorporateOnboardingRequestCtrl.PicklistInfo> picklistInfoList = fieldInfo.picklistValues;
        Boolean hasTypeField = false;
        Integer requiredFields = 0;

        for (
            Data_Transfer_Mapping__mdt thisMapping : DataTransferMappingsSelector.newInstance()
                .getAllActiveValues()
        ) {
            if (thisMapping.Is_Required__c) {
                requiredFields++;
            }
        }

        for (BulkCorporateOnboardingRequestCtrl.PicklistInfo info : picklistInfoList) {
            // Use "Type" as a random picklist field to test
            if (info.fieldLabel == 'Type') {
                hasTypeField = true;
                System.assertNotEquals(
                    null,
                    info.valuesString,
                    'Values for Type should not be null'
                );
            }
        }

        System.assert(hasTypeField, 'Type field should be present in the result');
        System.assertEquals(
            requiredFields,
            fieldInfo.requiredFieldLabels.size(),
            'The fields marked as required in the custom metadata should be flagged'
        );
        System.assertNotEquals(
            null,
            BulkCorporateOnboardingRequestCtrl.getIsProduction(),
            'The `getIsProduction()` method should return an environment-specific flag.'
        );
    }

    @IsTest
    static void testWhenAccountHasBusinessContactsThenRetrieveByRole() {
        Id accountId = Fake.generateId(Account.class);
        Id contactId = Fake.generateId(Contact.class);
        Id contactId2 = Fake.generateId(Contact.class);
        Id contactId3 = Fake.generateId(Contact.class);
        Id acrId1 = Fake.generateId(AccountContactRelation.class);
        Id acrId2 = Fake.generateId(AccountContactRelation.class);
        Id acrId3 = Fake.generateId(AccountContactRelation.class);
        String acrRoleDecisionMaker = 'Decision Maker';
        String acrRoleStoreManager = 'Store Manager';

        List<Contact> contacts = new List<Contact>{
            new Contact(Id = contactId),
            new Contact(Id = contactId2),
            new Contact(Id = contactId3)
        };

        List<AccountContactRelation> acrs = new List<AccountContactRelation>{
            new AccountContactRelation(
                Id = acrId1,
                AccountId = accountId,
                ContactId = contactId,
                Roles = acrRoleDecisionMaker
            ),
            new AccountContactRelation(
                Id = acrId2,
                AccountId = accountId,
                ContactId = contactId2,
                Roles = acrRoleStoreManager
            ),
            new AccountContactRelation(
                Id = acrId3,
                AccountId = accountId,
                ContactId = contactId3,
                Roles = null
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IAccountContactRelationsSelector acrSelectorMock = (IAccountContactRelationsSelector) mocks.mock(
            IAccountContactRelationsSelector.class
        );

        IContactsSelector contactsSelectorMock = (IContactsSelector) mocks.mock(
            IContactsSelector.class
        );

        mocks.startStubbing();
        mocks.when(acrSelectorMock.sObjectType()).thenReturn(AccountContactRelation.SObjectType);
        mocks.when(acrSelectorMock.selectActiveAcrByAccountIds(new Set<Id>{ accountId }))
            .thenReturn(acrs);
        mocks.when(contactsSelectorMock.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(
                contactsSelectorMock.selectByIdsAndFieldSet(
                    (Schema.Fieldset) fflib_Match.anyObject(),
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(contacts);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(acrSelectorMock);
        Application.SELECTOR.setMock(contactsSelectorMock);

        Test.startTest();
        Map<String, Contact> results = BulkCorporateOnboardingRequestCtrl.getBusinessContactsByRole(
            accountId
        );
        Test.stopTest();

        System.assert(!results.isEmpty(), 'The `results` map should not be empty');
        System.assert(
            results.containsKey(acrRoleDecisionMaker) && results.containsKey(acrRoleStoreManager),
            'Both Roles should be included'
        );
    }

    @isTest
    static void testWhenSavingUserFeedbackThenUpdateRequestRecord() {
        Id flowRequestId = Fake.generateId(Process_Flow_Request__c.class);

        Process_Flow_Request__c fakeRequest = new Process_Flow_Request__c(
            Id = flowRequestId,
            Status__c = REQUEST_STATUS_IN_PROGRESS
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);

        IProcessFlowRequestsSelector pfrSelectorMock = (IProcessFlowRequestsSelector) mocks.mock(
            IProcessFlowRequestsSelector.class
        );

        mocks.startStubbing();
        mocks.when(pfrSelectorMock.sObjectType()).thenReturn(Process_Flow_Request__c.SObjectType);
        mocks.when(pfrSelectorMock.selectById(new Set<Id>{ flowRequestId }))
            .thenReturn(new List<Process_Flow_Request__c>{ fakeRequest });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(pfrSelectorMock);

        Test.startTest();
        BulkCorporateOnboardingRequestCtrl.saveUserFeedback(
            flowRequestId,
            '{"rating": 4, "notes": "testing" }'
        );
        Test.stopTest();

        System.assertNotEquals(
            null,
            fakeRequest.User_Feedback__c,
            'User Feedback should be populated'
        );

        Boolean errorHandled = false;
        try {
            BulkCorporateOnboardingRequestCtrl.saveUserFeedback(
                null,
                '{"rating": 4, "notes": "testing" }'
            );
        } catch (Exception ex) {
            errorHandled = true;
        }

        System.assert(errorHandled, 'Error not thrown in null scenario');
    }

    @IsTest
    static void testWhenCreatingNewWorkOrderThenRetrievePicklistValues() {
        Map<String, Object> statusResult = BulkCorporateOnboardingRequestCtrl.getStatusPicklistValues();
        Map<String, Object> typeResult = BulkCorporateOnboardingRequestCtrl.getTypePicklistValues();

        System.assertNotEquals(null, statusResult, 'Result should not be null.');

        List<String> statusPicklistValuesList = (List<String>) statusResult.get('values');
        String defaultPicklistValue = (String) statusResult.get('default');
        List<String> typePicklistValuesList = (List<String>) typeResult.get('values');

        System.assertNotEquals(
            null,
            statusPicklistValuesList,
            'Picklist values list should not be null.'
        );
        System.assertNotEquals(
            0,
            statusPicklistValuesList.size(),
            'Picklist values list should not be empty.'
        );
        System.assertNotEquals(
            null,
            defaultPicklistValue,
            'Default picklist value should not be null.'
        );
        System.assertNotEquals(
            null,
            typePicklistValuesList,
            'Picklist values list should not be null.'
        );
        System.assertNotEquals(
            0,
            typePicklistValuesList.size(),
            'Picklist values list should not be empty.'
        );
    }

    @IsTest
    static void testWhenStoresAreFailedThenReturn() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        Id flowRequestId = Fake.generateId(Process_Flow_Request__c.class);
        Id storeId = Fake.generateId(Account.class);

        List<BulkCorporateOnboardingWrappers.StoreInfo> storeInfos = new List<BulkCorporateOnboardingWrappers.StoreInfo>{
            new BulkCorporateOnboardingWrappers.StoreInfo(storeId, null, null)
        };

        Process_Flow_Request__c flowRequest = new Process_Flow_Request__c(
            Id = flowRequestId,
            Serialized_Object_Data__c = BulkCorporateOnboardingRequestService.packStoreInfos(
                storeInfos
            )
        );

        // Mock the selector and register it
        IProcessFlowRequestsSelector pfrSelectorMock = (IProcessFlowRequestsSelector) mocks.mock(
            IProcessFlowRequestsSelector.class
        );

        mocks.startStubbing();
        mocks.when(pfrSelectorMock.sObjectType()).thenReturn(Process_Flow_Request__c.SObjectType);
        mocks.when(pfrSelectorMock.selectById(new Set<Id>{ flowRequestId }))
            .thenReturn(new List<Process_Flow_Request__c>{ flowRequest });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(pfrSelectorMock);

        Test.startTest();
        List<Account> stores = BulkCorporateOnboardingRequestCtrl.getFailedStores(flowRequestId);
        Test.stopTest();

        System.assert(stores.isEmpty(), 'Failed stores should be returned');
    }

    @IsTest
    static void testWhenStoreUploadIsFinishedThenSaveProcessFlowRequest() {
        Integer chunksToProcess = 2;
        Id flowRequestId = Fake.generateId(Process_Flow_Request__c.class);
        Id workOrderId = Fake.generateId(WorkOrder.class);
        Id contractId = Fake.generateId(Process_Flow_Request__c.class);

        Process_Flow_Request__c fakeRequest = new Process_Flow_Request__c(
            Id = flowRequestId,
            Status__c = REQUEST_STATUS_IN_PROGRESS,
            Stage__c = REQUEST_STAGE_ACCOUNT_FILE_UPLOAD,
            Work_Order__c = workOrderId,
            Contract__c = contractId
        );

        Process_Flow_Request_Chunk__c chunk1 = new Process_Flow_Request_Chunk__c(
            Process_Flow_Request__c = flowRequestId,
            Status__c = 'In Progress',
            Chunk_Number__c = 1,
            Serialized_Data__c = '{}'
        );

        Process_Flow_Request_Chunk__c chunk2 = new Process_Flow_Request_Chunk__c(
            Process_Flow_Request__c = flowRequestId,
            Status__c = 'In Progress',
            Chunk_Number__c = 1,
            Serialized_Data__c = '{}'
        );

        List<Process_Flow_Request_Chunk__c> chunks = new List<Process_Flow_Request_Chunk__c>{
            chunk1,
            chunk2
        };

        BulkCorporateOnboardingWrappers.StoreValidationResult uploadResults = new BulkCorporateOnboardingWrappers.StoreValidationResult();
        uploadResults.newRecords = new List<SObject>();
        uploadResults.errorMessages = new List<BulkCorporateOnboardingWrappers.ErrorMessage>();
        uploadResults.includesPaymentAccounts = true;
        uploadResults.includesDecisionMakers = true;

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);

        IProcessFlowRequestsSelector pfrSelectorMock = (IProcessFlowRequestsSelector) mocks.mock(
            IProcessFlowRequestsSelector.class
        );
        IProcessFlowRequestChunksSelector chunkSelectorMock = (IProcessFlowRequestChunksSelector) mocks.mock(
            IProcessFlowRequestChunksSelector.class
        );

        mocks.startStubbing();
        mocks.when(pfrSelectorMock.sObjectType()).thenReturn(Process_Flow_Request__c.SObjectType);
        mocks.when(pfrSelectorMock.selectById(new Set<Id>{ flowRequestId }))
            .thenReturn(new List<Process_Flow_Request__c>{ fakeRequest });
        mocks.when(chunkSelectorMock.sObjectType())
            .thenReturn(Process_Flow_Request_Chunk__c.SObjectType);
        mocks.when(
                chunkSelectorMock.selectSubsetOfOpenChunksByRequestId(
                    flowRequestId,
                    chunksToProcess
                )
            )
            .thenReturn(chunks);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(pfrSelectorMock);

        Test.startTest();
        Process_Flow_Request__c flowRequestResult = BulkCorporateOnboardingRequestCtrl.processStoreUploadData(
            flowRequestId,
            JSON.serialize(uploadResults),
            chunksToProcess
        );
        Test.stopTest();

        System.assert(
            String.isNotBlank(flowRequestResult.Serialized_Object_Data__c),
            'The object data should be serialized on the Process Flow Request'
        );
        System.assertEquals(
            flowRequestId,
            flowRequestResult.Id,
            'The Process Flow Request whose ID was inputted should be returned'
        );
        System.assertEquals(
            REQUEST_STAGE_SELECT_ENTITELEMENT,
            flowRequestResult.Stage__c,
            'The Stage should be advanced on the PFR'
        );
    }

    @IsTest
    static void testWhenInputtingResultsThenReturnRelevantStageNumber() {
        BulkCorporateOnboardingWrappers.StoreValidationResult uploadResults = new BulkCorporateOnboardingWrappers.StoreValidationResult();
        uploadResults.newRecords = new List<SObject>();
        uploadResults.errorMessages = new List<BulkCorporateOnboardingWrappers.ErrorMessage>{
            new BulkCorporateOnboardingWrappers.ErrorMessage(null, 'Test Error Message 1', false)
        };
        uploadResults.hasNonDuplicateErrors = true;
        uploadResults.includesPaymentAccounts = true;
        uploadResults.includesDecisionMakers = true;

        // Scenario 1: Stores have errors - stay on current screen
        Integer numberForRemainingOnCurrentStep = BulkCorporateOnboardingRequestCtrl.getNextStageNumberAfterUpload(
            uploadResults
        );
        System.assertEquals(
            4,
            numberForRemainingOnCurrentStep,
            'When Stores have any errors, we should remain on the current screen.'
        );

        // Scenario 2: Stores have no errors - move to Business Vertical screen
        uploadResults.errorMessages = new List<BulkCorporateOnboardingWrappers.ErrorMessage>();
        uploadResults.hasNonDuplicateErrors = false;
        Integer numberForGoingToNextStep = BulkCorporateOnboardingRequestCtrl.getNextStageNumberAfterUpload(
            uploadResults
        );
        System.assertEquals(
            5,
            numberForGoingToNextStep,
            'When there are no errors, we should proceed to the next screen.'
        );
    }

    @IsTest
    @SuppressWarnings('PMD.AvoidHardcodingId')
    static void testWhenUploadingFileThenHandleTemporaryStorageAndParseData() {
        Id accountId = Fake.generateId(Account.SObjectType);
        Id contractId = Fake.generateId(Contract.class);
        String parentAccountId = '0017600000ZuxpWAAR';
        Id flowRequestId = Fake.generateId(Process_Flow_Request__c.class);
        Process_Flow_Request__c fakeRequest = new Process_Flow_Request__c(
            Id = flowRequestId,
            Status__c = REQUEST_STATUS_IN_PROGRESS,
            Stage__c = REQUEST_STAGE_ACCOUNT_FILE_UPLOAD
        );

        StaticResource sr = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_CSV
        ];
        Blob blobCSV = sr.Body;
        String csvString = blobCSV.toString();
        String[] rows = csvString.split('\n');
        List<List<String>> csvValues = new List<List<String>>();

        for (String row : rows) {
            List<String> rowValues = row.split(',');
            rowValues = parseCsvRow(rowValues);
            csvValues.add(rowValues);
        }

        // Encode the JSON string to base64
        String base64Encoded = EncodingUtil.base64Encode(Blob.valueOf(JSON.serialize(csvValues)));

        List<Account> accountList = new List<Account>{
            new Account(Id = parentAccountId, Name = 'Parent 1'),
            new Account(Id = accountId, ParentId = parentAccountId, Name = 'Child 1')
        };

        List<Contract> contractList = new List<Contract>{
            new Contract(Id = contractId, AccountId = accountId, Status = 'Draft')
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);

        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IContractsSelector contractsSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        IProcessFlowRequestsSelector pfrSelectorMock = (IProcessFlowRequestsSelector) mocks.mock(
            IProcessFlowRequestsSelector.class
        );

        mocks.startStubbing();
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(contractsSelectorMock.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(pfrSelectorMock.sObjectType()).thenReturn(Process_Flow_Request__c.SObjectType);
        mocks.when(
                accountsSelectorMock.selectAllChildCorporateAccountsWithParent(
                    new Set<String>{ accountId }
                )
            )
            .thenReturn(accountList);
        mocks.when(contractsSelectorMock.selectById(new Set<Id>{ contractId }))
            .thenReturn(contractList);
        mocks.when(pfrSelectorMock.selectById(new Set<Id>{ flowRequestId }))
            .thenReturn(new List<Process_Flow_Request__c>{ fakeRequest });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(contractsSelectorMock);
        Application.SELECTOR.setMock(pfrSelectorMock);

        Test.startTest();
        BulkCorporateOnboardingRequestCtrl.BulkOnboardingWrapper result = BulkCorporateOnboardingRequestCtrl.uploadFileRows(
            base64Encoded,
            flowRequestId,
            1,
            1
        );
        Test.stopTest();

        System.assertEquals(
            flowRequestId,
            result.flowRequestObj.Id,
            'The PFR should match from the input'
        ); /*
        System.assertEquals(
            REQUEST_STAGE_ACCOUNT_FILE_UPLOAD,
            result.flowRequestObj.Stage__c,
            'The Stage of the PFR should match from earlier - Account File Input'
        );
        System.assertEquals(
            1,
            result.flowRequestObj.Upload_Attempts__c,
            'The Upload Attempts value should be set'
        );*/
    }

    @IsTest
    static void testWhenNavigateToCompletionStepIsCalledThenUpdateStage() {
        Id flowRequestId = Fake.generateId(Process_Flow_Request__c.class);
        Id storeId = Fake.generateId(Account.class);

        List<BulkCorporateOnboardingWrappers.StoreInfo> stores = new List<BulkCorporateOnboardingWrappers.StoreInfo>{
            new BulkCorporateOnboardingWrappers.StoreInfo(storeId, null, null)
        };

        // Mocking the required objects and methods
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        // Assume getFlowRequestById is a method that retrieves the Process_Flow_Request__c record
        Process_Flow_Request__c mockFlowRequest = new Process_Flow_Request__c(
            Id = flowRequestId,
            Contract__c = Fake.generateId(Contract.class),
            Work_Order__c = Fake.generateId(WorkOrder.class),
            Status__c = REQUEST_STATUS_IN_PROGRESS,
            Stage__c = BulkCorporateOnboardingRequestCtrl.stagesByOrder.get(8),
            Serialized_Object_Data__c = BulkCorporateOnboardingRequestService.packStoreInfos(stores)
        );

        IProcessFlowRequestsSelector pfrSelectorMock = (IProcessFlowRequestsSelector) mocks.mock(
            IProcessFlowRequestsSelector.class
        );

        mocks.startStubbing();
        mocks.when(pfrSelectorMock.sObjectType()).thenReturn(Process_Flow_Request__c.SObjectType);
        mocks.when(pfrSelectorMock.selectById(new Set<Id>{ flowRequestId }))
            .thenReturn(new List<Process_Flow_Request__c>{ mockFlowRequest });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(pfrSelectorMock);

        Test.startTest();
        Process_Flow_Request__c updatedRequest = BulkCorporateOnboardingRequestCtrl.navigateToCompletionStep(
            flowRequestId
        );
        Test.stopTest();

        System.assertEquals(
            BulkCorporateOnboardingRequestCtrl.stagesByOrder.get(10),
            updatedRequest.Stage__c,
            'This method should set the PFR to the `Processing Stores` stage.'
        );
    }

    @IsTest
    static void testWhenDeleteStoreIsCalledThenStoreIsDeleted() {
        Id flowRequestId = Fake.generateId(Process_Flow_Request__c.class);
        Id storeId = Fake.generateId(Account.class);
        Id storeId2 = Fake.generateId(Account.class);
        Id storeId3 = Fake.generateId(Account.class);

        List<BulkCorporateOnboardingWrappers.StoreInfo> stores = new List<BulkCorporateOnboardingWrappers.StoreInfo>{
            new BulkCorporateOnboardingWrappers.StoreInfo(storeId, null, null),
            new BulkCorporateOnboardingWrappers.StoreInfo(storeId2, null, null),
            new BulkCorporateOnboardingWrappers.StoreInfo(storeId3, null, null)
        };

        List<Account> storeAccounts = new List<Account>{
            new Account(Id = storeId, Bulk_Corporate_Onboarding_Request__c = flowRequestId),
            new Account(Id = storeId2, Bulk_Corporate_Onboarding_Request__c = flowRequestId),
            new Account(Id = storeId3, Bulk_Corporate_Onboarding_Request__c = flowRequestId)
        };

        // Mocking the required objects and methods
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUow = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        // Assume getFlowRequestById is a method that retrieves the Process_Flow_Request__c record
        Process_Flow_Request__c mockFlowRequest = new Process_Flow_Request__c(
            Id = flowRequestId,
            Contract__c = Fake.generateId(Contract.class),
            Work_Order__c = Fake.generateId(WorkOrder.class),
            Status__c = REQUEST_STATUS_IN_PROGRESS,
            Stage__c = BulkCorporateOnboardingRequestCtrl.stagesByOrder.get(8),
            Serialized_Object_Data__c = BulkCorporateOnboardingRequestService.packStoreInfos(
                stores
            ),
            Fixed_Stores_Count__c = 1,
            Fixed_Store_IDs__c = String.valueOf(storeId2)
        );

        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IProcessFlowRequestsSelector pfrSelectorMock = (IProcessFlowRequestsSelector) mocks.mock(
            IProcessFlowRequestsSelector.class
        );

        mocks.startStubbing();
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.getStoresByBulkOnboardingRequestId(flowRequestId))
            .thenReturn(storeAccounts);
        mocks.when(pfrSelectorMock.sObjectType()).thenReturn(Process_Flow_Request__c.SObjectType);
        mocks.when(pfrSelectorMock.selectById(new Set<Id>{ flowRequestId }))
            .thenReturn(new List<Process_Flow_Request__c>{ mockFlowRequest });
        mocks.stopStubbing();

        Application.UnitOfWork.setMock(mockUow);
        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(pfrSelectorMock);

        // TEST CASE: Remove a store that was in the "Fixed Stores" list
        BulkCorporateOnboardingRequestCtrl.deleteStore(storeId2, flowRequestId);

        List<BulkCorporateOnboardingWrappers.StoreInfo> storeInfos = BulkCorporateOnboardingRequestService.unpackStoreInfos(
            flowRequestId,
            mockFlowRequest.Serialized_Object_Data__c
        );
        System.assertEquals(
            2,
            storeInfos.size(),
            'The StoreInfo of the deleted store should be removed'
        );

        System.assertEquals(
            1,
            mockFlowRequest.Removed_Stores__c,
            'One Removed Store should be logged'
        );
        System.assertEquals(
            0,
            mockFlowRequest.Fixed_Stores_Count__c,
            'The Fixed Stores Count should be reset to zero'
        );

        // TEST CASE: Remove another store, incrementing the count of Removed Stores further
        BulkCorporateOnboardingRequestCtrl.deleteStore(storeId3, flowRequestId);

        storeInfos = BulkCorporateOnboardingRequestService.unpackStoreInfos(
            flowRequestId,
            mockFlowRequest.Serialized_Object_Data__c
        );

        System.assertEquals(
            1,
            storeInfos.size(),
            'The StoreInfo of the deleted store should be removed'
        );

        System.assertEquals(
            2,
            mockFlowRequest.Removed_Stores__c,
            'A second Removed Store should be logged'
        );
        System.assertEquals(
            0,
            mockFlowRequest.Fixed_Stores_Count__c,
            'The Fixed Stores Count should remain zero'
        );

        // TEST CASE: Null scenario - should throw an exception
        Boolean exceptionThrown = false;
        try {
            BulkCorporateOnboardingRequestCtrl.deleteStore(null, null);
        } catch (Exception ex) {
            exceptionThrown = true;
        }

        System.assert(exceptionThrown, 'An exception should be thrown from the null input');
    }

    @IsTest
    static void testWhenNavigateToStoreIsCalledThenLogStoreFix() {
        Id flowRequestId = Fake.generateId(Process_Flow_Request__c.class);
        Id storeId = Fake.generateId(Account.class);
        Id storeId2 = Fake.generateId(Account.class);
        Id storeId3 = Fake.generateId(Account.class);

        List<BulkCorporateOnboardingWrappers.StoreInfo> stores = new List<BulkCorporateOnboardingWrappers.StoreInfo>{
            new BulkCorporateOnboardingWrappers.StoreInfo(storeId, null, null),
            new BulkCorporateOnboardingWrappers.StoreInfo(storeId2, null, null),
            new BulkCorporateOnboardingWrappers.StoreInfo(storeId3, null, null)
        };

        // Mocking the required objects and methods
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUow = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        // Assume getFlowRequestById is a method that retrieves the Process_Flow_Request__c record
        Process_Flow_Request__c mockFlowRequest = new Process_Flow_Request__c(
            Id = flowRequestId,
            Contract__c = Fake.generateId(Contract.class),
            Work_Order__c = Fake.generateId(WorkOrder.class),
            Status__c = REQUEST_STATUS_IN_PROGRESS,
            Stage__c = BulkCorporateOnboardingRequestCtrl.stagesByOrder.get(8),
            Serialized_Object_Data__c = BulkCorporateOnboardingRequestService.packStoreInfos(
                stores
            ),
            Fixed_Store_IDs__c = String.valueOf(storeId),
            Fixed_Stores_Count__c = 1
        );

        IProcessFlowRequestsSelector pfrSelectorMock = (IProcessFlowRequestsSelector) mocks.mock(
            IProcessFlowRequestsSelector.class
        );

        mocks.startStubbing();
        mocks.when(pfrSelectorMock.sObjectType()).thenReturn(Process_Flow_Request__c.SObjectType);
        mocks.when(pfrSelectorMock.selectById(new Set<Id>{ flowRequestId }))
            .thenReturn(new List<Process_Flow_Request__c>{ mockFlowRequest });
        mocks.stopStubbing();

        Application.UnitOfWork.setMock(mockUow);
        Application.SELECTOR.setMock(pfrSelectorMock);

        BulkCorporateOnboardingRequestCtrl.navigateToStore(storeId, flowRequestId); // This should not be counted twice!
        BulkCorporateOnboardingRequestCtrl.navigateToStore(storeId2, flowRequestId);

        List<Process_Flow_Request__c> results = ProcessFlowRequestsSelector.newInstance()
            .selectById(new Set<Id>{ flowRequestId });
        System.assertEquals(
            2,
            results[0].Fixed_Stores_Count__c,
            'Two Stores should be tracked as fixed'
        );

        Boolean exceptionThrown = false;
        try {
            BulkCorporateOnboardingRequestCtrl.navigateToStore(storeId3, null);
        } catch (Exception ex) {
            exceptionThrown = true;
        }

        System.assert(exceptionThrown, 'An exception was not thrown successfully in the null case');
    }

    @IsTest
    static void testWhenOnFinalErrorCheckThenEvaluateStoreAddressExecutionStatus() {
        Id flowRequestId = Fake.generateId(Process_Flow_Request__c.class);
        Id store1 = Fake.generateId(Account.class);
        Id store2 = Fake.generateId(Account.class);
        Id store3 = Fake.generateId(Account.class);
        Id store4 = Fake.generateId(Account.class);
        Id store5 = Fake.generateId(Account.class);

        List<Account> storeRecords = new List<Account>{
            new Account(Id = store1, Address_Verification_Status__c = REJECTED_STATUS),
            new Account(Id = store2, Address_Verification_Status__c = REJECTED_STATUS),
            new Account(Id = store3, Address_Verification_Status__c = UNVERIFIED_STATUS),
            new Account(
                Id = store4,
                Address_Verification_Status__c = VERIFIED_STATUS,
                Coverage__c = IN_COVERAGE
            ),
            new Account(
                Id = store5,
                Address_Verification_Status__c = VERIFIED_STATUS,
                Coverage__c = IN_COVERAGE
            )
        };

        List<BulkCorporateOnboardingWrappers.StoreInfo> storeInfos = new List<BulkCorporateOnboardingWrappers.StoreInfo>{
            initStoreInfo(store1, true, false),
            initStoreInfo(store2, true, false),
            initStoreInfo(store3, false, false),
            initStoreInfo(store4, true, true),
            initStoreInfo(store5, true, true)
        };

        // Mocking the required objects and methods
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        // Assume getFlowRequestById is a method that retrieves the Process_Flow_Request__c record
        Process_Flow_Request__c mockFlowRequest = new Process_Flow_Request__c(
            Id = flowRequestId,
            Contract__c = Fake.generateId(Contract.class),
            Work_Order__c = Fake.generateId(WorkOrder.class),
            Status__c = REQUEST_STATUS_IN_PROGRESS,
            Stage__c = BulkCorporateOnboardingRequestCtrl.stagesByOrder.get(8),
            Serialized_Object_Data__c = BulkCorporateOnboardingRequestService.packStoreInfos(
                storeInfos
            )
        );

        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IProcessFlowRequestsSelector pfrSelectorMock = (IProcessFlowRequestsSelector) mocks.mock(
            IProcessFlowRequestsSelector.class
        );

        mocks.startStubbing();
        mocks.when(pfrSelectorMock.sObjectType()).thenReturn(Process_Flow_Request__c.SObjectType);
        mocks.when(pfrSelectorMock.selectById(new Set<Id>{ flowRequestId }))
            .thenReturn(new List<Process_Flow_Request__c>{ mockFlowRequest });
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.getStoresByBulkOnboardingRequestId(flowRequestId))
            .thenReturn(storeRecords);
        mocks.when(
                accountsSelectorMock.selectAccountsByIdAndFieldSet(
                    (Schema.Fieldset) fflib_Match.anyObject(),
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(storeRecords);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(pfrSelectorMock);

        Test.startTest();
        BulkCorporateOnboardingWrappers.StoreVerificationStatus result = BulkCorporateOnboardingRequestCtrl.getInvalidOrIncompleteStores(
            flowRequestId
        );
        Test.stopTest();

        System.assertEquals(5, result.totalStores, '5 Stores should be logged');
        System.assert(!result.allStoresPassed, 'Some stores should be failures');
        System.assert(
            !result.allStoresVerified,
            'Not every store was verified, so `allStoresVerified` should be false'
        );
        System.assert(!result.allStoresFailed, 'Some stores succeeded');
        System.assert(result.someStoresNotVerified, 'Some stores are not verified');
    }

    @IsTest
    static void testWhenOnFinalErrorCheckWithAllVerifiedStoresThenReturnSuccessStatus() {
        Id flowRequestId = Fake.generateId(Process_Flow_Request__c.class);
        Id store1 = Fake.generateId(Account.class);
        Id store2 = Fake.generateId(Account.class);
        Id store3 = Fake.generateId(Account.class);

        List<Account> storeRecords = new List<Account>{
            new Account(
                Id = store1,
                Address_Verification_Status__c = VERIFIED_STATUS,
                Coverage__c = IN_COVERAGE
            ),
            new Account(
                Id = store2,
                Address_Verification_Status__c = VERIFIED_STATUS,
                Coverage__c = IN_COVERAGE
            ),
            new Account(
                Id = store3,
                Address_Verification_Status__c = VERIFIED_STATUS,
                Coverage__c = IN_COVERAGE
            )
        };

        List<BulkCorporateOnboardingWrappers.StoreInfo> storeInfos = new List<BulkCorporateOnboardingWrappers.StoreInfo>{
            initStoreInfo(store1, true, true),
            initStoreInfo(store2, true, true),
            initStoreInfo(store3, true, true)
        };

        // Mocking the required objects and methods
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        // Assume getFlowRequestById is a method that retrieves the Process_Flow_Request__c record
        Process_Flow_Request__c mockFlowRequest = new Process_Flow_Request__c(
            Id = flowRequestId,
            Contract__c = Fake.generateId(Contract.class),
            Work_Order__c = Fake.generateId(WorkOrder.class),
            Status__c = REQUEST_STATUS_IN_PROGRESS,
            Stage__c = BulkCorporateOnboardingRequestCtrl.stagesByOrder.get(8),
            Serialized_Object_Data__c = BulkCorporateOnboardingRequestService.packStoreInfos(
                storeInfos
            )
        );

        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IProcessFlowRequestsSelector pfrSelectorMock = (IProcessFlowRequestsSelector) mocks.mock(
            IProcessFlowRequestsSelector.class
        );

        mocks.startStubbing();
        mocks.when(pfrSelectorMock.sObjectType()).thenReturn(Process_Flow_Request__c.SObjectType);
        mocks.when(pfrSelectorMock.selectById(new Set<Id>{ flowRequestId }))
            .thenReturn(new List<Process_Flow_Request__c>{ mockFlowRequest });
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.getStoresByBulkOnboardingRequestId(flowRequestId))
            .thenReturn(storeRecords);
        mocks.when(
                accountsSelectorMock.selectAccountsByIdAndFieldSet(
                    (Schema.Fieldset) fflib_Match.anyObject(),
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(storeRecords);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(pfrSelectorMock);

        Test.startTest();
        BulkCorporateOnboardingWrappers.StoreVerificationStatus result = BulkCorporateOnboardingRequestCtrl.getInvalidOrIncompleteStores(
            flowRequestId
        );
        Test.stopTest();

        System.assertEquals(3, result.totalStores, '3 Stores should be logged');
        System.assert(result.allStoresPassed, 'All stores should have passed');
        System.assert(!result.allStoresFailed, 'All stores were successful');
        System.assert(!result.someStoresNotVerified, 'Every store was verified');
    }

    @IsTest
    static void testWhenTabletWorkOrderIsSelectedThenValidateDecisionMakerPhone() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        Id accountId = Fake.generateId(Account.class);
        Id decisionMakerId = Fake.generateId(Contact.class);
        Id contractId = Fake.generateId(Contract.class);
        Id flowRequestId = Fake.generateId(Process_Flow_Request__c.class);
        Id workOrderId = Fake.generateId(WorkOrder.class);

        Process_Flow_Request__c mockFlowRequest = new Process_Flow_Request__c(
            Id = flowRequestId,
            Work_Order__c = workOrderId,
            Contract__c = contractId,
            Status__c = REQUEST_STATUS_IN_PROGRESS,
            Stage__c = BulkCorporateOnboardingRequestCtrl.stagesByOrder.get(7)
        );
        List<WorkOrder> workOrders = new List<WorkOrder>{
            new WorkOrder(
                Id = workOrderId,
                AccountId = accountId,
                Order_Protocol__c = System.Label.LaunchEventOrderProtocolTablet
            )
        };
        List<Contact> contacts = new List<Contact>{
            new Contact(Id = decisionMakerId, AccountId = accountId, LastName = 'Test Name')
        };

        WorkOrdersSelector workOrderSelectorMock = (WorkOrdersSelector) mocks.mock(
            WorkOrdersSelector.class
        );
        ContactsSelector contactsSelectorMock = (ContactsSelector) mocks.mock(
            ContactsSelector.class
        );
        IProcessFlowRequestsSelector pfrSelectorMock = (IProcessFlowRequestsSelector) mocks.mock(
            IProcessFlowRequestsSelector.class
        );
        mocks.startStubbing();
        mocks.when(pfrSelectorMock.sObjectType()).thenReturn(Process_Flow_Request__c.SObjectType);
        mocks.when(pfrSelectorMock.selectById(new Set<Id>{ flowRequestId }))
            .thenReturn(new List<Process_Flow_Request__c>{ mockFlowRequest });
        mocks.when(workOrderSelectorMock.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(workOrderSelectorMock.selectById(new Set<Id>{ workOrderId }))
            .thenReturn(workOrders);
        mocks.when(contactsSelectorMock.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(
                contactsSelectorMock.selectContactsByIdAndFieldSet(
                    SObjectType.Contact.FieldSets.Decision_Maker_Contact_Info,
                    new Set<Id>{ decisionMakerId }
                )
            )
            .thenReturn(contacts);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(pfrSelectorMock);
        Application.SELECTOR.setMock(workOrderSelectorMock);
        Application.SELECTOR.setMock(contactsSelectorMock);

        System.assert(
            BulkCorporateOnboardingRequestCtrl.checkIfTabletWorkOrder(flowRequestId),
            'This should be considered a Tablet WO'
        );

        Boolean exceptionThrown = false;
        try {
            BulkCorporateOnboardingRequestCtrl.validateDecisionMaker(
                decisionMakerId,
                flowRequestId
            );
        } catch (Exception ex) {
            exceptionThrown = true;
        }

        System.assert(
            exceptionThrown,
            'An error should be thrown if there is no Phone on the Decision Maker under a Tablet WO'
        );
    }

    @IsTest
    static void testWhenOnFinalErrorCheckThenSaveAccessibilities() {
        Id storeId = Fake.generateId(Account.class);

        // Mocking the required objects and methods
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUow = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        Application.UnitOfWork.setMock(mockUow);
        Map<Id, String> accessibilitiesMap = new Map<Id, String>{
            storeId => '{""accessibilities"":{""needToClimb"":FALSE,""hasElevatorOrRamp"":FALSE}}'
        };
        Boolean exceptionThrown = false;
        try {
            BulkCorporateOnboardingRequestCtrl.saveAccessibilities(accessibilitiesMap);
        } catch (Exception ex) {
            exceptionThrown = true;
        }
        System.assert(
            !exceptionThrown,
            'An exception was thrown while updating the Store accessibility'
        );
    }

    @IsTest
    static void testWhenRetrievingCompletedChunksForRequestThenReturnNumberOfChunks() {
        Id flowRequestId = Fake.generateId(Process_Flow_Request__c.class);

        Process_Flow_Request_Chunk__c chunk1 = new Process_Flow_Request_Chunk__c(
            Process_Flow_Request__c = flowRequestId,
            Status__c = REQUEST_STATUS_IN_PROGRESS,
            Chunk_Number__c = 1,
            Serialized_Data__c = '{}'
        );

        Process_Flow_Request_Chunk__c chunk2 = new Process_Flow_Request_Chunk__c(
            Process_Flow_Request__c = flowRequestId,
            Status__c = REQUEST_STATUS_COMPLETED,
            Chunk_Number__c = 2,
            Serialized_Data__c = '{}'
        );

        Process_Flow_Request_Chunk__c chunk3 = new Process_Flow_Request_Chunk__c(
            Process_Flow_Request__c = flowRequestId,
            Status__c = REQUEST_STATUS_COMPLETED,
            Chunk_Number__c = 3,
            Serialized_Data__c = '{}'
        );

        Process_Flow_Request_Chunk__c chunk4 = new Process_Flow_Request_Chunk__c(
            Process_Flow_Request__c = flowRequestId,
            Status__c = REQUEST_STATUS_COMPLETED,
            Chunk_Number__c = 4,
            Serialized_Data__c = '{}'
        );

        List<Process_Flow_Request_Chunk__c> chunks = new List<Process_Flow_Request_Chunk__c>{
            chunk1,
            chunk2,
            chunk3,
            chunk4
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IProcessFlowRequestChunksSelector chunkSelectorMock = (IProcessFlowRequestChunksSelector) mocks.mock(
            IProcessFlowRequestChunksSelector.class
        );

        mocks.startStubbing();
        mocks.when(chunkSelectorMock.sObjectType())
            .thenReturn(Process_Flow_Request_Chunk__c.SObjectType);
        mocks.when(chunkSelectorMock.selectByRequestId(flowRequestId)).thenReturn(chunks);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(chunkSelectorMock);

        System.assertEquals(
            4,
            BulkCorporateOnboardingRequestCtrl.retrieveNumberOfCompletedChunksForRequest(
                flowRequestId,
                false
            ),
            'Four chunks should be returned when retrieving the grand total'
        );
        System.assertEquals(
            3,
            BulkCorporateOnboardingRequestCtrl.retrieveNumberOfCompletedChunksForRequest(
                flowRequestId,
                true
            ),
            'Three should be returned when retrieving the completed total'
        );
    }

    @IsTest
    static void testWhenPassingFlowRequestIdThenReturnStoreInfos() {
        Id flowRequestId = Fake.generateId(Process_Flow_Request__c.class);
        Id storeId = Fake.generateId(Account.class);
        Id storeId2 = Fake.generateId(Account.class);
        Id paymentAccountId = Fake.generateId(Payment_Account__c.class);

        List<BulkCorporateOnboardingWrappers.StoreInfo> stores = new List<BulkCorporateOnboardingWrappers.StoreInfo>{
            new BulkCorporateOnboardingWrappers.StoreInfo(storeId, paymentAccountId, null),
            new BulkCorporateOnboardingWrappers.StoreInfo(storeId2, paymentAccountId, null)
        };
        List<Account> storeAccounts = new List<Account>{
            new Account(Id = storeId, Bulk_Corporate_Onboarding_Request__c = flowRequestId),
            new Account(Id = storeId2, Bulk_Corporate_Onboarding_Request__c = flowRequestId)
        };

        Process_Flow_Request__c flowRequest = new Process_Flow_Request__c(
            Id = flowRequestId,
            Serialized_Object_Data__c = BulkCorporateOnboardingRequestService.packStoreInfos(stores)
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);

        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IProcessFlowRequestsSelector pfrSelectorMock = (IProcessFlowRequestsSelector) mocks.mock(
            IProcessFlowRequestsSelector.class
        );

        mocks.startStubbing();
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.getStoresByBulkOnboardingRequestId(flowRequestId))
            .thenReturn(storeAccounts);
        mocks.when(pfrSelectorMock.sObjectType()).thenReturn(Process_Flow_Request__c.SObjectType);
        mocks.when(pfrSelectorMock.selectById(new Set<Id>{ flowRequestId }))
            .thenReturn(new List<Process_Flow_Request__c>{ flowRequest });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(pfrSelectorMock);

        Test.startTest();
        List<BulkCorporateOnboardingWrappers.StoreInfoWithAccountRecord> storeInfoWithAccount = BulkCorporateOnboardingRequestCtrl.getStoreInfosForFlowRequest(
            flowRequestId
        );
        Test.stopTest();

        System.assertEquals(
            2,
            storeInfoWithAccount.size(),
            'There should be two wrappers in the list'
        );
    }

    @IsTest
    static void testWhenRemovingOutOfCoverageStoresThenLogThemOnProcessFlowRequest() {
        Id flowRequestId = Fake.generateId(Process_Flow_Request__c.class);
        Id store1 = Fake.generateId(Account.class);
        Id store2 = Fake.generateId(Account.class);
        Id store3 = Fake.generateId(Account.class);

        List<Account> storeRecords = new List<Account>{
            new Account(
                Id = store1,
                Address_Verification_Status__c = VERIFIED_STATUS,
                Coverage__c = IN_COVERAGE
            ),
            new Account(
                Id = store2,
                Address_Verification_Status__c = VERIFIED_STATUS,
                Coverage__c = NOT_IN_COVERAGE
            ),
            new Account(
                Id = store3,
                Address_Verification_Status__c = REJECTED_STATUS,
                Coverage__c = NOT_IN_COVERAGE
            )
        };

        List<BulkCorporateOnboardingWrappers.StoreInfo> storeInfos = new List<BulkCorporateOnboardingWrappers.StoreInfo>{
            initStoreInfo(store1, false, false),
            initStoreInfo(store2, false, false),
            initStoreInfo(store3, false, false)
        };

        // Assume getFlowRequestById is a method that retrieves the Process_Flow_Request__c record
        Process_Flow_Request__c mockFlowRequest = new Process_Flow_Request__c(
            Id = flowRequestId,
            Contract__c = Fake.generateId(Contract.class),
            Work_Order__c = Fake.generateId(WorkOrder.class),
            Status__c = REQUEST_STATUS_IN_PROGRESS,
            Stage__c = BulkCorporateOnboardingRequestCtrl.stagesByOrder.get(9),
            Serialized_Object_Data__c = BulkCorporateOnboardingRequestService.packStoreInfos(
                storeInfos
            )
        );

        // Mocking the required objects and methods
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);

        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IProcessFlowRequestsSelector pfrSelectorMock = (IProcessFlowRequestsSelector) mocks.mock(
            IProcessFlowRequestsSelector.class
        );

        mocks.startStubbing();
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.getStoresByBulkOnboardingRequestId(flowRequestId))
            .thenReturn(storeRecords);
        mocks.when(pfrSelectorMock.sObjectType()).thenReturn(Process_Flow_Request__c.SObjectType);
        mocks.when(pfrSelectorMock.selectById(new Set<Id>{ flowRequestId }))
            .thenReturn(new List<Process_Flow_Request__c>{ mockFlowRequest });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(pfrSelectorMock);

        Test.startTest();
        BulkCorporateOnboardingRequestCtrl.removeOutOfCoverageStoresFromUpload(flowRequestId);
        Test.stopTest();

        List<BulkCorporateOnboardingWrappers.StoreInfo> resultStoreInfos = BulkCorporateOnboardingRequestService.unpackStoreInfos(
            flowRequestId,
            mockFlowRequest.Serialized_Object_Data__c
        );

        for (BulkCorporateOnboardingWrappers.StoreInfo thisStoreInfo : resultStoreInfos) {
            if (thisStoreInfo.storeId == store2 || thisStoreInfo.storeId == store3) {
                System.assert(
                    thisStoreInfo.skipBatch,
                    'The `skipBatch` flag should be set to `true` for out of coverage stores'
                );
            } else {
                System.assert(
                    !thisStoreInfo.skipBatch,
                    'The `skipBatch` flag should be set to `true` for out of coverage stores'
                );
            }
        }

        // Cover exception case
        Boolean exceptionThrown = false;
        try {
            BulkCorporateOnboardingRequestCtrl.removeOutOfCoverageStoresFromUpload(null);
        } catch (Exception ex) {
            exceptionThrown = true;
        }
        System.assert(
            exceptionThrown,
            'An exception should be returned back to the front-end when receiving invalid input'
        );
    }

    @IsTest
    static void testWhenGetMultiSelectRecordsIsCalledThenReturnWrappers() {
        Id flowRequestId = Fake.generateId(Process_Flow_Request__c.class);
        Id storeId = Fake.generateId(Account.class);
        Id storeId2 = Fake.generateId(Account.class);
        Id storeId3 = Fake.generateId(Account.class);

        Id paymentAccountId = Fake.generateId(Payment_Account__c.class);
        Id paymentAccountId2 = Fake.generateId(Payment_Account__c.class);

        Id decisionMakerId = Fake.generateId(Contact.class);

        LookupSearchCtrl.mockRecords = new List<SObject>{
            new Payment_Account__c(Id = paymentAccountId),
            new Payment_Account__c(Id = paymentAccountId2)
        };

        List<BulkCorporateOnboardingWrappers.StoreInfo> stores = new List<BulkCorporateOnboardingWrappers.StoreInfo>{
            new BulkCorporateOnboardingWrappers.StoreInfo(
                storeId,
                paymentAccountId,
                decisionMakerId
            ),
            new BulkCorporateOnboardingWrappers.StoreInfo(storeId2, paymentAccountId2, null),
            new BulkCorporateOnboardingWrappers.StoreInfo(storeId3, null, null)
        };

        List<Account> storeAccounts = new List<Account>{
            new Account(Id = storeId),
            new Account(Id = storeId2),
            new Account(Id = storeId3)
        };

        // Assume getFlowRequestById is a method that retrieves the Process_Flow_Request__c record
        Process_Flow_Request__c mockFlowRequest = new Process_Flow_Request__c(
            Id = flowRequestId,
            Contract__c = Fake.generateId(Contract.class),
            Work_Order__c = Fake.generateId(WorkOrder.class),
            Status__c = REQUEST_STATUS_IN_PROGRESS,
            Stage__c = REQUEST_STAGE_PAYMENT_ACCOUNT,
            Serialized_Object_Data__c = BulkCorporateOnboardingRequestService.packStoreInfos(stores)
        );

        // Mocking the required objects and methods
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IProcessFlowRequestsSelector pfrSelectorMock = (IProcessFlowRequestsSelector) mocks.mock(
            IProcessFlowRequestsSelector.class
        );

        mocks.startStubbing();
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.getStoresByBulkOnboardingRequestId(flowRequestId))
            .thenReturn(storeAccounts);
        mocks.when(pfrSelectorMock.sObjectType()).thenReturn(Process_Flow_Request__c.SObjectType);
        mocks.when(pfrSelectorMock.selectById(new Set<Id>{ flowRequestId }))
            .thenReturn(new List<Process_Flow_Request__c>{ mockFlowRequest });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(pfrSelectorMock);

        Test.startTest();
        List<LookupSearchCtrl.ResultWrapper> resultsForPaymentAccounts = BulkCorporateOnboardingRequestCtrl.getRecordsForMultiSelectDisplay(
            flowRequestId,
            'Payment_Account__c'
        );

        // Reset mockRecords list
        LookupSearchCtrl.mockRecords = new List<SObject>{
            new Contact(Id = decisionMakerId)
        };

        List<LookupSearchCtrl.ResultWrapper> resultsForDecisionMakers = BulkCorporateOnboardingRequestCtrl.getRecordsForMultiSelectDisplay(
            flowRequestId,
            'Contact'
        );
        Test.stopTest();

        System.assertEquals(
            2,
            resultsForPaymentAccounts.size(),
            'Two wrappers should be returned for the selected Payment Accounts'
        );

        System.assertEquals(
            1,
            resultsForDecisionMakers.size(),
            'One wrapper should be returned for the selected Decision Maker'
        );

        Boolean errorThrown = false;
        try {
            BulkCorporateOnboardingRequestCtrl.getRecordsForMultiSelectDisplay(
                null,
                'Payment_Account__c'
            );
        } catch (Exception ex) {
            errorThrown = true;
        }

        System.assert(errorThrown, 'The null scenario should throw an exception');
    }

    /**
     * @description Helper method to handle commas and quotes in CSV values
     * @param rowValues
     * @return List<String>
     **/
    private static List<String> parseCsvRow(List<String> rowValues) {
        List<String> parsedValues = new List<String>();
        String currentValue = '';
        Boolean insideQuotes = false;

        for (String val : rowValues) {
            if (val.startsWith('"') && val.endsWith('"')) {
                parsedValues.add(val.substring(1, val.length() - 1));
            } else if (val.startsWith('"')) {
                currentValue = val.substring(1) + ',';
                insideQuotes = true;
            } else if (val.endsWith('"') && insideQuotes) {
                currentValue += val.substring(0, val.length() - 1);
                parsedValues.add(currentValue);
                currentValue = '';
                insideQuotes = false;
            } else if (insideQuotes) {
                currentValue += val + ',';
            } else {
                parsedValues.add(val);
            }
        }
        return parsedValues;
    }

    @isTest
    static void testWhenValidateWorkOrderTypeInvokedwithCorrectSubscriptionPackageAndWOTypeThenReturnErrorMsg() {
        Id contractId = Fake.generateId(Contract.class);
        Id productId = Fake.generateId(Product2.class);
		Boolean errorIsThrown = false;
        Process_Flow_Request__c existingPFR;

        Product2 product1 = (Product2)new Fake(Product2.class)
            .setField(Product2.Id, productId)
            .setField(Product2.Name, 'Storefront')
            .setField(Product2.ProductCode, '10018')
            .toSObject();


        // Mocking the required objects and methods
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        ISubscriptionSelector subscriptionSelectorMock = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );

        mocks.startStubbing();
        mocks.when(subscriptionSelectorMock.sObjectType())
            .thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(subscriptionSelectorMock.selectActiveSubscriptionListBasedOnProductCode(contractId, new Set<String>{product1.ProductCode}))
            .thenReturn(new List<SBQQ__Subscription__c>());
        mocks.stopStubbing();

        Application.SELECTOR.setMock(subscriptionSelectorMock);

		try {
            existingPFR = BulkCorporateOnboardingRequestCtrl.validateAndLoadRequest(System.Label.WorkOrder_Type_Marketplace, contractId);
        } catch (Exception ex) {
            errorIsThrown = true;
        }

        System.assertEquals(
            existingPFR,
            null,
            'No exsiting PFR record should be fetched'
        );

        System.assert(
            errorIsThrown,
            'An exception should have been thrown if there is no marketplace subscription exist on the contract.'
        );
    }

    private static Map<String, Object> getFieldValuesMap(WorkOrder wo) {
        Map<String, Object> fieldsAndValues = new Map<String, Object>();

        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.WorkOrder.fields.getMap();
        List<String> fieldNames = new List<String>(fieldMap.keySet());

        for (String fieldName : fieldNames) {
            if (wo.get(fieldName) != null) {
                fieldsAndValues.put(fieldName, wo.get(fieldName));
            }
        }

        return fieldsAndValues;
    }

    /**
     * @description Used to initialize StoreInfo objects with address details
     * @param storeId
     * @param addressRun
     * @param addressSucceeded
     * @return BulkCorporateOnboardingWrappers.StoreInfo
     **/
    private static BulkCorporateOnboardingWrappers.StoreInfo initStoreInfo(
        Id storeId,
        Boolean addressRun,
        Boolean addressSucceeded
    ) {
        BulkCorporateOnboardingWrappers.StoreInfo store = new BulkCorporateOnboardingWrappers.StoreInfo(
            storeId,
            null,
            null
        );
        store.isJobRun = addressRun;
        store.isVerified = addressSucceeded;
        return store;
    }
}