/**
 * @author BizApps
 * @date 11-September-2023
 * @description Test class for the BulkCorporateOnboardingReqSrvcImpl class.
 **/
@IsTest
@SuppressWarnings('PMD.NcssMethodCount, PMD.CyclomaticComplexity, PMD.StdCyclomaticComplexity')
private class BulkCorporateOnboardingReqSrvcImplTest {
    private static final String ASSERT_MESSAGE_ERROR_NOT_MATCHED = 'Unexpected result: error message is not matching';
    private static final String DUPLICATE_ACCOUNT_ERROR_MESSAGE = System.Label.Duplicate_Account_Error_Message;
    private static final Integer MAX_NUM_OF_STORES = 10;
    private static final String MENU_URL_ERROR_MESSAGE = System.Label.Bulk_Store_Menu_URL_Error_Message;
    private static final String PHONE_NUMBER_ERROR_MESSAGE = 'Please ensure Phone number is populated.';
    private static final String REQUEST_STAGE_ACCOUNT_FILE_UPLOAD = 'Account File Upload';
    private static final String REQUEST_STATUS_IN_PROGRESS = 'In Progress';
    private static final String RECORDTYPE_INVOICE = 'Invoice';
    private static final String SEGMENT_ENTERPRISE = 'Enterprise';
    private static final String COUNTRYCODE_US = 'US';
    private static final Integer CHUNKS_PER_TRANSACTION = 2;
    private static final String DEFAULT_TYPE_CORPORATE = 'Corporate';
    private static final String EXTERNAL_ID_SOURCE_MDS = 'MDS';
    private static final String PRIMARY_VERTICAL_ALCOHOL = 'Alochol';

    @IsTest
    static void testWhenRetrievingMissingFlowRequestThenThrowException() {
        Id flowRequestId = Fake.generateId(Process_Flow_Request__c.class);
        Boolean exceptionThrown = false;

        try {
            BulkCorporateOnboardingRequestService.getBulkOnboardingRequestOrAbort(flowRequestId);
        } catch (Exception ex) {
            exceptionThrown = ex.getMessage()
                .containsIgnoreCase('no Process Flow Request record found');
        }

        System.assert(
            exceptionThrown,
            'An InvalidStoreOnboardingException should have been thrown due to missing PFR.'
        );
    }

    @IsTest
    static void testWhenSubmittingOnboardingJobWithUnverifiedStoresThenDelay() {
        Id parentAccountId = Fake.generateId(Account.SObjectType);
        Id flowRequestId = Fake.generateId(Process_Flow_Request__c.class);

        List<Account> mockStores = new List<Account>{
            new Account(
                Id = Fake.generateId(Account.SObjectType),
                Name = 'Store 1',
                ParentId = parentAccountId,
                Coverage__c = '',
                Address_Verification_Status__c = 'Unverified'
            ),
            new Account(
                Id = Fake.generateId(Account.SObjectType),
                Name = 'Store 2',
                ParentId = parentAccountId,
                Coverage__c = '',
                Address_Verification_Status__c = 'Unverified'
            ),
            new Account(
                Id = Fake.generateId(Account.SObjectType),
                Name = 'Store 3',
                ParentId = parentAccountId,
                Coverage__c = '',
                Address_Verification_Status__c = 'Unverified'
            )
        };

        Process_Flow_Request__c mockFlowRequest = new Process_Flow_Request__c(
            Id = flowRequestId,
            Work_Order__c = Fake.generateId(WorkOrder.class),
            Contract__c = Fake.generateId(Contract.class),
            Status__c = REQUEST_STATUS_IN_PROGRESS,
            Stage__c = BulkCorporateOnboardingRequestCtrl.stagesByOrder.get(4),
            Serialized_Object_Data__c = serializeStoreData(mockStores),
            OwnerId = UserInfo.getUserId()
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
        mocks.when(pfrSelectorMock.sObjectType()).thenReturn(Process_Flow_Request__c.SObjectType);
        mocks.when(accountsSelectorMock.getStoresByBulkOnboardingRequestId(flowRequestId))
            .thenReturn(mockStores);
        mocks.when(pfrSelectorMock.selectById(new Set<Id>{ flowRequestId }))
            .thenReturn(new List<Process_Flow_Request__c>{ mockFlowRequest });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(pfrSelectorMock);

        // Call the method to attempt batch execution
        BulkCorporateOnboardingRequestService.checkAndExecuteBatch(flowRequestId);

        // Run through this all three times and verify the final updates were done.
        for (Integer i = 1; i <= 3; i++) {
            mockFlowRequest.Batch_Delay_Number__c = i;
            BulkCorporateOnboardingRequestService.checkAndExecuteBatch(flowRequestId);
        }

        // Assertions
        System.assertEquals(
            3,
            mockFlowRequest.Batch_Delay_Number__c,
            'Batch_Delay_Number__c should be updated correctly'
        );
    }

    @IsTest
    static void testWhenAccountsAreVerifiedThenUpdateAndRetrieveAddressJobStatus() {
        Id parentAccountId = Fake.generateId(Account.SObjectType);
        Id flowRequestId = Fake.generateId(Process_Flow_Request__c.class);

        List<Account> mockStores = new List<Account>{
            new Account(
                Id = Fake.generateId(Account.SObjectType),
                Name = 'Store 1',
                ParentId = parentAccountId,
                Coverage__c = 'In Coverage',
                Address_Verification_Status__c = 'Verified'
            ),
            new Account(
                Id = Fake.generateId(Account.SObjectType),
                Name = 'Store 2',
                ParentId = parentAccountId,
                Coverage__c = 'In Coverage',
                Address_Verification_Status__c = 'Verified'
            ),
            new Account(
                Id = Fake.generateId(Account.SObjectType),
                Name = 'Store 3',
                ParentId = parentAccountId,
                Coverage__c = 'In Coverage',
                Address_Verification_Status__c = 'Verified'
            )
        };

        Process_Flow_Request__c mockFlowRequest = new Process_Flow_Request__c(
            Id = flowRequestId,
            Work_Order__c = Fake.generateId(WorkOrder.class),
            Contract__c = Fake.generateId(Contract.class),
            Status__c = REQUEST_STATUS_IN_PROGRESS,
            Stage__c = BulkCorporateOnboardingRequestCtrl.stagesByOrder.get(4),
            Serialized_Object_Data__c = serializeStoreData(mockStores),
            OwnerId = UserInfo.getUserId()
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
        mocks.when(pfrSelectorMock.sObjectType()).thenReturn(Process_Flow_Request__c.SObjectType);
        mocks.when(accountsSelectorMock.getStoresByBulkOnboardingRequestId(flowRequestId))
            .thenReturn(mockStores);
        mocks.when(pfrSelectorMock.selectById(new Set<Id>{ flowRequestId }))
            .thenReturn(new List<Process_Flow_Request__c>{ mockFlowRequest });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(pfrSelectorMock);

        BulkCorporateOnboardingWrappers.AddressVerificationResult addressResults = BulkCorporateOnboardingRequestService.updateAndRetrieveAddressJobStatus(
            flowRequestId
        );
        System.assert(
            addressResults.ranOnSomeStores,
            'The Batch Job should be ready for execution'
        );
    }

    @IsTest
    static void testWhenMenuUITypeNotRetailThenSkipStepIsFalse() {
        BulkCorporateOnboardingWrappers.StoreValidationResult uploadResults = getResultOfFileUploadFromStaticResource(
            'Bulk_Upload_Payment_Account_Step_Skip_Test',
            new List<WorkOrder>()
        );
        System.assertEquals(
            false,
            uploadResults.showPaymentAccountSkipOption,
            'Value should be false'
        );
    }

    /**
     * @description Creates a string of the CSV with excessive rows for testing. Includes two columns - one valid and one invalid.
     * @return String
     **/
    private static String generateInvalidCsvWithSeveralRows() {
        List<String> csvRows = new List<String>();
        csvRows.add('Name,NameInvalid'); // Add header
        for (Integer i = 1; i <= (MAX_NUM_OF_STORES + 1); i++) {
            csvRows.add('Name' + i + ',NameInvalid');
        }
        String csvString = String.join(csvRows, '\n');
        return csvString;
    }

    /**
     * @description Creates a JSON string from an inputted list of Stores.
     * @param mockStores
     * @return String
     **/
    private static String serializeStoreData(List<Account> mockStores) {
        List<BulkCorporateOnboardingWrappers.StoreInfo> storeInfos = new List<BulkCorporateOnboardingWrappers.StoreInfo>();

        for (Account thisStore : mockStores) {
            BulkCorporateOnboardingWrappers.StoreInfo wrapperObj;
            wrapperObj = new BulkCorporateOnboardingWrappers.StoreInfo(
                thisStore.Id,
                Fake.generateId(Payment_Account__c.SObjectType),
                null
            );
            storeInfos.add(wrapperObj);
        }

        return BulkCorporateOnboardingRequestService.packStoreInfos(storeInfos);
    }

    /**
     * @description It is used to show a validation message when a csv file is uploaded with Payment Account of 'Invoice' record type.
     * @JIRA# LEM-10203
     */
    @isTest
    @SuppressWarnings('PMD.AvoidHardcodingId')
    private static void testWhenInvalidDataGivenThenErrorThrown() {
        String parentAccountId = '0017600000ZuxpWAAR'; // Used in CSV template
        Id paymentAccountId = 'a3e760000004aM2AAI'; // Used in CSV Template
        Id accountId = Fake.generateId(Account.SObjectType);
        Id workOrderId = Fake.generateId(WorkOrder.class);
        Id contractId = Fake.generateId(Contract.class);
        Id flowRequestId = Fake.generateId(Process_Flow_Request__c.class);
        Id recordTypeInvoiceId = Schema.SObjectType.Payment_Account__c.getRecordTypeInfosByDeveloperName()
            .get('Invoice')
            .getRecordTypeId();
        Id bizzRefID1 = Fake.generateId(Business_Reference__c.class);
        Id businessVerticalID = Fake.generateId(Business_Vertical__c.class);
        Id brandID = Fake.generateId(Brand__c.class);
        Id contractBrandAssoID = Fake.generateId(Contract_Brand_Association__c.class);

        List<Account> accountList = new List<Account>{
            new Account(Id = parentAccountId, Name = 'Parent 1'),
            new Account(Id = accountId, ParentId = parentAccountId, Name = 'Child 1')
        };

        List<Contract> contractList = new List<Contract>{
            new Contract(Id = contractId, AccountId = accountId, Status = 'Draft')
        };

        Set<Id> paymentAccountIds = new Set<Id>();
        paymentAccountIds.add(paymentAccountId);

        List<Payment_Account__c> paymentAccountList = new List<Payment_Account__c>{
            new Payment_Account__c(Id = paymentAccountId, RecordtypeId = recordTypeInvoiceId)
        };

        Process_Flow_Request__c mockFlowRequest = new Process_Flow_Request__c(
            Id = flowRequestId,
            Work_Order__c = workOrderId,
            Contract__c = contractId,
            Status__c = REQUEST_STATUS_IN_PROGRESS,
            Stage__c = BulkCorporateOnboardingRequestCtrl.stagesByOrder.get(4)
        );

        Business_Vertical__c businessVertical = new Business_Vertical__c(
            id = businessVerticalID,
            Primary_Vertical__c = 'Alcohol'
        );
        Brand__c brand = new Brand__c(id = brandID, Name = 'test brand');
        List<Contract_Brand_Association__c> contractBrandAssociation = new List<Contract_Brand_Association__c>{
            new Contract_Brand_Association__c(id = contractBrandAssoID, Brand__c = brand.id)
        };
        List<Business_Reference__c> businessReferenceList = new List<Business_Reference__c>{
            new Business_Reference__c(
                Id = bizzRefID1,
                Default_Type__c = 'Corporate',
                External_Id_Source__c = 'MDS',
                External_Id__c = '123',
                CurrencyIsoCode = 'USD',
                Business_Vertical__c = businessVertical.id,
                Brand__c = brand.id
            )
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
        IPaymentAccountsSelector mockPaymentAccountSelector = (IPaymentAccountsSelector) mocks.mock(
            IPaymentAccountsSelector.class
        );
        IBusinessReferencesSelector mockBusinessRefSelector = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        IContractBrandAssociationsSelector mockContractBrandSelector = (IContractBrandAssociationsSelector) mocks.mock(
            IContractBrandAssociationsSelector.class
        );

        mocks.startStubbing();
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                accountsSelectorMock.selectAllChildCorporateAccountsWithParent(
                    new Set<String>{ accountId }
                )
            )
            .thenReturn(accountList);
        mocks.when(contractsSelectorMock.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(contractsSelectorMock.selectById(new Set<Id>{ contractId }))
            .thenReturn(contractList);
        mocks.when(pfrSelectorMock.sObjectType()).thenReturn(Process_Flow_Request__c.SObjectType);
        mocks.when(pfrSelectorMock.selectById(new Set<Id>{ flowRequestId }))
            .thenReturn(new List<Process_Flow_Request__c>{ mockFlowRequest });
        mocks.when(mockPaymentAccountSelector.sObjectType())
            .thenReturn(Payment_Account__c.SObjectType);
        mocks.when(mockPaymentAccountSelector.selectById(paymentAccountIds))
            .thenReturn(paymentAccountList);
        mocks.stopStubbing();
        mocks.when(mockBusinessRefSelector.sObjectType())
            .thenReturn(Business_Reference__c.SObjectType);
        mocks.when(
                mockBusinessRefSelector.selectByDefaultTypeAndExternalIdSource(
                    new Set<String>{ '123' },
                    new Set<String>{ 'Corporate' },
                    new Set<String>{ 'MDS' }
                )
            )
            .thenReturn(businessReferenceList);
        mocks.when(mockContractBrandSelector.sObjectType())
            .thenReturn(Contract_Brand_Association__c.SObjectType);
        mocks.when(mockContractBrandSelector.selectByContracts(new Set<String>{ contractId }))
            .thenReturn(contractBrandAssociation);

        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(contractsSelectorMock);
        Application.SELECTOR.setMock(pfrSelectorMock);
        Application.SELECTOR.setMock(mockPaymentAccountSelector);
        Application.SELECTOR.setMock(mockBusinessRefSelector);
        Application.SELECTOR.setMock(mockContractBrandSelector);

        List<List<String>> csvRows = BulkOnboardingCsvProcessor.getCsvRowsFromResource(
            'Bulk_Upload_Invoice_Payment_Account_Test'
        );
        BulkCorporateOnboardingWrappers.StoreValidationResult uploadResults = BulkCorporateOnboardingRequestService.parseAndValidateCsv(
            csvRows,
            flowRequestId,
            1,
            CHUNKS_PER_TRANSACTION
        );

        // Assertions to validate behavior
        System.assertNotEquals(null, uploadResults, 'The result should not be null.');
        Boolean foundError = false;
        for (
            BulkCorporateOnboardingWrappers.ErrorMessage eachErrorMessage : uploadResults.errorMessages
        ) {
            if (
                eachErrorMessage.fullMessage.contains(
                    'Record Type of the Payment Account should not be Invoice.'
                )
            ) {
                foundError = true;
            }
        }
        System.assertEquals(
            true,
            foundError,
            'Payment Account with Invoice record type not found ' +
            JSON.serialize(uploadResults.errorMessages)
        );
    }

    /**
     * @description Identifies potential issues around Store CSVs with special characters, linebreaks and other inputs.
     **/
    @IsTest
    static void testWhenUploadingCsvWithCommasAndSpecialCharactersThenParseCorrectly() {
        BulkCorporateOnboardingWrappers.StoreValidationResult uploadResults = getResultOfFileUploadFromStaticResource(
            'Bulk_Store_Upload_CSV_Special_Characters_Test',
            new List<WorkOrder>()
        );
        System.assertNotEquals(
            0,
            uploadResults.newRecords.size(),
            'Stores should have been included in the `newRecords` list.'
        );
    }

    /**
     * @description Tests the scenario where there are commas and special characters added to the CSV, and NOT wrapped in quotes. This should throw an error.
     **/
    @IsTest
    static void testWhenUploadingCsvWithCommasAndWithoutQuotesThenReturnError() {
        BulkCorporateOnboardingWrappers.StoreValidationResult uploadResults = getResultOfFileUploadFromStaticResource(
            'Bulk_Store_Upload_CSV_Invalid_Commas_Test',
            new List<WorkOrder>()
        );

        // There might be additional error types, so look through the list of errors and make sure we have the one we need.
        Boolean foundCommasError = false;
        for (BulkCorporateOnboardingWrappers.ErrorMessage errorMsg : uploadResults.errorMessages) {
            String trimmedMsg = errorMsg.message.trim();
            if (trimmedMsg.containsIgnoreCase(System.Label.Bulk_Store_Invalid_CSV)) {
                foundCommasError = true;
            }
        }

        System.assert(
            foundCommasError,
            'Should have a `Too Many Cells` error which indicates there are no quotes wrapped around the commas'
        );
    }

    /**
     * @description Identifies potential issues around Store CSVs with special characters, linebreaks and other inputs.
     * @param resourceName - The name of the StaticResource where the CSV is stored
     * @param workOrders
     * @return BulkCorporateOnboardingWrappers.StoreValidationResult
     **/
    @SuppressWarnings('PMD.AvoidHardcodingId')
    private static BulkCorporateOnboardingWrappers.StoreValidationResult getResultOfFileUploadFromStaticResource(
        String resourceName,
        List<WorkOrder> workOrders
    ) {
        List<List<String>> csvRows = BulkOnboardingCsvProcessor.getCsvRowsFromResource(
            resourceName
        );
        String parentAccountId = '0017600000ZuxpWAAR'; // Used in CSV template
        Id accountId = Fake.generateId(Account.SObjectType);
        Id workOrderId = Fake.generateId(WorkOrder.SObjectType);
        Id contractId = Fake.generateId(Contract.class);
        Id flowRequestId = Fake.generateId(Process_Flow_Request__c.class);
        Id businessVerticalID = Fake.generateId(Business_Vertical__c.class);
        Id brandID = Fake.generateId(Brand__c.class);
        Id contractBrandAssoID = Fake.generateId(Contract_Brand_Association__c.class);
        List<WorkOrder> mockWorkOrders = new List<WorkOrder>();
        List<Business_Reference__c> mockBusinessRefs = new List<Business_Reference__c>();

        List<Account> accountList = new List<Account>{
            new Account(
                Id = parentAccountId,
                Name = 'Parent 1',
                BillingCountryCode = COUNTRYCODE_US,
                Segment__c = SEGMENT_ENTERPRISE
            ),
            new Account(Id = accountId, ParentId = parentAccountId, Name = 'Child 1')
        };

        List<Contract> contractList = new List<Contract>{
            new Contract(Id = contractId, AccountId = parentAccountId, Status = 'Draft')
        };
        if (workorders != null && !workOrders.isEmpty()) {
            workOrderId = workOrders[0].Id;
            mockWorkOrders = workOrders;
        }
        Process_Flow_Request__c mockFlowRequest = new Process_Flow_Request__c(
            Id = flowRequestId,
            Work_Order__c = workOrderId,
            Contract__c = contractId,
            Status__c = REQUEST_STATUS_IN_PROGRESS,
            Stage__c = BulkCorporateOnboardingRequestCtrl.stagesByOrder.get(4)
        );

        Business_Vertical__c businessVertical = new Business_Vertical__c(
            Id = businessVerticalID,
            Primary_Vertical__c = PRIMARY_VERTICAL_ALCOHOL
        );
        Brand__c brand = new Brand__c(Id = brandID, Name = 'test brand');
        List<Contract_Brand_Association__c> contractBrandAssociation = new List<Contract_Brand_Association__c>{
            new Contract_Brand_Association__c(
                Id = contractBrandAssoID,
                Brand__c = brand.id,
                Contract__c = contractId
            )
        };

        Map<String, Business_Reference__c> bussinessRefExternalIdToMockBusineesReference = generateMockBusinessRefs(
            csvRows.size() - 1
        );
        mockBusinessRefs = bussinessRefExternalIdToMockBusineesReference.values();
        Set<String> mockBusinessRefIds = bussinessRefExternalIdToMockBusineesReference.keySet();

        for (Business_Reference__c mockBussRef : mockBusinessRefs) {
            mockBussRef.Brand__c = brand.Id;
            mockBussRef.Business_Vertical__c = businessVertical.id;
        }

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
        IWorkOrdersSelector mockWorkOrderSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IBusinessReferencesSelector mockBusinessRefSelector = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        IContractBrandAssociationsSelector mockContractBrandSelector = (IContractBrandAssociationsSelector) mocks.mock(
            IContractBrandAssociationsSelector.class
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
        mocks.when(accountsSelectorMock.selectById(new Set<Id>{ parentAccountId }))
            .thenReturn(new List<Account>{ accountList[0] });
        mocks.when(contractsSelectorMock.selectById(new Set<Id>{ contractId }))
            .thenReturn(contractList);
        mocks.when(pfrSelectorMock.selectById(new Set<Id>{ flowRequestId }))
            .thenReturn(new List<Process_Flow_Request__c>{ mockFlowRequest });
        mocks.when(mockWorkOrderSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrderSelector.selectById(new Set<Id>{ workOrderId }))
            .thenReturn(mockWorkOrders);
        mocks.when(mockBusinessRefSelector.sObjectType())
            .thenReturn(Business_Reference__c.SObjectType);
        mocks.when(
                mockBusinessRefSelector.selectByDefaultTypeAndExternalIdSource(
                    mockBusinessRefIds,
                    new Set<String>{ DEFAULT_TYPE_CORPORATE },
                    new Set<String>{ EXTERNAL_ID_SOURCE_MDS }
                )
            )
            .thenReturn(mockBusinessRefs);
        mocks.when(mockContractBrandSelector.sObjectType())
            .thenReturn(Contract_Brand_Association__c.SObjectType);
        mocks.when(mockContractBrandSelector.selectByContracts(new Set<String>{ contractId }))
            .thenReturn(contractBrandAssociation);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(contractsSelectorMock);
        Application.SELECTOR.setMock(pfrSelectorMock);
        Application.SELECTOR.setMock(mockWorkOrderSelector);
        Application.SELECTOR.setMock(mockBusinessRefSelector);
        Application.SELECTOR.setMock(mockContractBrandSelector);

        return BulkCorporateOnboardingRequestService.parseAndValidateCsv(
            csvRows,
            flowRequestId,
            1,
            CHUNKS_PER_TRANSACTION
        );
    }

    /**
     * @description To validate that an error message is returned when Store Accounts uploaded
     * without "Merchant Supplied ID" on Work Order with Order Protocol as 'POS'.
     * @JIRA# LEM-10219
     */
    @isTest
    @SuppressWarnings('PMD.AvoidHardcodingId')
    private static void testWhenStoreAccountsUploadedWithoutMerchantSuppliedIDOnWorkOrderWithPOSOrderProtocolThenErrorMessageReturned() {
        Id workOrderId = Fake.generateId(WorkOrder.class);
        List<WorkOrder> mockWorkOrders = new List<WorkOrder>{
            new WorkOrder(
                Id = workOrderId,
                Order_Protocol__c = 'POS',
                POS_Integration_Type__c = 'adora'
            )
        };
        Test.startTest();
        BulkCorporateOnboardingWrappers.StoreValidationResult uploadResults = getResultOfFileUploadFromStaticResource(
            'Bulk_Upload_Merchant_Supplied_ID_Test',
            mockWorkOrders
        );
        Test.stopTest();
        // Assertions to validate behavior
        System.assertNotEquals(null, uploadResults, 'The upload results returned as null.');
        Boolean merchantSuppliedIDErrorReceived = false;
        for (
            BulkCorporateOnboardingWrappers.ErrorMessage eachErrorMessage : uploadResults.errorMessages
        ) {
            if (
                eachErrorMessage.message.contains(
                    'You must provide Merchant Supplied ID for these stores since Order Protocol contains POS.'
                )
            ) {
                merchantSuppliedIDErrorReceived = true;
            }
        }
        System.assertEquals(
                true,
                merchantSuppliedIDErrorReceived,
                'Unexpected result: Merchant Supplied ID error not thrown for Store Accounts: ' + JSON.serialize(uploadResults.errorMessages)
        );
    }

    /**
     * @description To validate that an error message is not returned when Store Accounts uploaded
     * without "Merchant Supplied ID" on Work Order with Order Protocol value other than 'POS'
     * @JIRA# LEM-10219
     */
    @isTest
    @SuppressWarnings('PMD.AvoidHardcodingId')
    private static void testWhenStoreAccountsUploadedWithoutMerchantSuppliedIDOnWorkOrderWithNonPOSOrderProtocolThenErrorMessageNotReturned() {
        Id workOrderId = Fake.generateId(WorkOrder.class);
        List<WorkOrder> mockWorkOrders = new List<WorkOrder>{
            new WorkOrder(Id = workOrderId, Order_Protocol__c = 'Email')
        };
        BulkCorporateOnboardingWrappers.StoreValidationResult uploadResults = getResultOfFileUploadFromStaticResource(
            'Bulk_Upload_Merchant_Supplied_ID_Test',
            mockWorkOrders
        );
        // Assertions to validate behavior
        System.assertNotEquals(null, uploadResults, 'The upload results returned as null.');
        Boolean merchantSuppliedIDErrorReceived = false;
        for (
            BulkCorporateOnboardingWrappers.ErrorMessage eachErrorMessage : uploadResults.errorMessages
        ) {
            if (
                eachErrorMessage.message.contains(
                    'You must provide Merchant Supplied ID for these stores since Order Protocol contains POS.'
                )
            ) {
                merchantSuppliedIDErrorReceived = true;
            }
        }
        System.assertEquals(
                false,
                merchantSuppliedIDErrorReceived,
                'Unexpected result: Merchant Supplied ID error thrown for Store Accounts: ' + JSON.serialize(uploadResults.errorMessages)
        );
    }

    /**
     * @description To validate that an error message is returned when Store Accounts uploaded
     * without "Menu URL" on Work Order with "Order Protocol" value does not contains 'POS'
     * and "Menu to be Completed By" value is not 'Account Owner'.
     * @JIRA# LEM-10223
     */
    @isTest
    @SuppressWarnings('PMD.AvoidHardcodingId')
    private static void testWhenMenuURLNotPopulatedAndNonPosOrderProtocolAndMxMenuToBeCompletedByThenReturnError() {
        Id workOrderId = Fake.generateId(WorkOrder.class);
        List<WorkOrder> mockWorkOrders = new List<WorkOrder>{
            new WorkOrder(
                Id = workOrderId,
                Order_Protocol__c = 'Email',
                Menu_to_be_Completed_By__c = 'Merchant'
            )
        };
        Test.startTest();
        BulkCorporateOnboardingWrappers.StoreValidationResult uploadResults = getResultOfFileUploadFromStaticResource(
            'Bulk_Upload_Menu_URL_Test',
            mockWorkOrders
        );
        Test.stopTest();
        // Assertions to validate behavior
        System.assertNotEquals(null, uploadResults, 'The upload results returned as null.');
        Boolean menuURLErrorReceived = false;
        for (
            BulkCorporateOnboardingWrappers.ErrorMessage eachErrorMessage : uploadResults.errorMessages
        ) {
            if (eachErrorMessage.message.contains(MENU_URL_ERROR_MESSAGE)) {
                menuURLErrorReceived = true;
            }
        }
        System.assertEquals(
                true,
                menuURLErrorReceived,
                'Unexpected result: Menu URL error not thrown for Store Accounts: ' + JSON.serialize(uploadResults.errorMessages)
        );
    }

    /**
     * @description To validate that an error message is not returned when Store Accounts uploaded
     * without "Menu URL" on Work Order with "Order Protocol" value contains 'POS'
     * and "Menu to be Completed By" value is not 'Account Owner'. Also, adds logic to ensure Tablet
     * Delivery Method and other derived values populate.
     * @JIRA# LEM-10223
     */
    @isTest
    @SuppressWarnings('PMD.AvoidHardcodingId')
    private static void testWhenMenuURLNotPopulatedAndPosOrderProtocolThenNoError() {
        Id workOrderId = Fake.generateId(WorkOrder.class);
        List<WorkOrder> mockWorkOrders = new List<WorkOrder>{
            new WorkOrder(
                Id = workOrderId,
                Order_Protocol__c = 'POS and Tablet (DoorDash Owns)',
                Menu_to_be_Completed_By__c = 'Merchant'
            )
        };
        BulkCorporateOnboardingWrappers.StoreValidationResult uploadResults = getResultOfFileUploadFromStaticResource(
            'Bulk_Upload_Menu_URL_Test',
            mockWorkOrders
        );
        // Assertions to validate behavior
        System.assertNotEquals(null, uploadResults, 'The upload results returned as null.');
        Boolean menuURLErrorReceived = false;
        for (
            BulkCorporateOnboardingWrappers.ErrorMessage eachErrorMessage : uploadResults.errorMessages
        ) {
            if (eachErrorMessage.message.contains(MENU_URL_ERROR_MESSAGE)) {
                menuURLErrorReceived = true;
            }
        }
        System.assertEquals(
            false,
            menuURLErrorReceived,
            'Unexpected result: Menu URL error thrown for Store Accounts: ' +
            JSON.serialize(uploadResults.errorMessages)
        );

        // Tablet Delivery Method should be populated as "Drop-ship" due to the Tablet Order Protocol on the WO
        for (Account thisStore : (List<Account>) uploadResults.newRecords) {
            System.assertEquals(
                'Drop-ship',
                thisStore.Tablet_Delivery_Method__c,
                'Tablet Delivery Method should be populated'
            );

            System.assertEquals(
                SEGMENT_ENTERPRISE,
                thisStore.Segment__c,
                'Segment should be populated with the parent\'s value'
            );
            System.assertEquals(
                COUNTRYCODE_US,
                thisStore.BillingCountryCode,
                'Country Code should be populated with the parent\'s value'
            );
        }
    }

    /**
     * @description To validate that an error message is not returned when Store Accounts uploaded
     * without "Menu URL" on Work Order with "Order Protocol" value does contains 'POS'
     * and "Menu to be Completed By" value is 'Account Owner'.
     * @JIRA# LEM-10223
     */
    @isTest
    @SuppressWarnings('PMD.AvoidHardcodingId')
    private static void testWhenMenuURLNotPopulatedAndNonPosOrderProtocolThenNoError() {
        Id workOrderId = Fake.generateId(WorkOrder.class);
        List<WorkOrder> mockWorkOrders = new List<WorkOrder>{
            new WorkOrder(
                Id = workOrderId,
                Order_Protocol__c = 'Email',
                Menu_to_be_Completed_By__c = 'Account Owner'
            )
        };
        BulkCorporateOnboardingWrappers.StoreValidationResult uploadResults = getResultOfFileUploadFromStaticResource(
            'Bulk_Upload_Menu_URL_Test',
            mockWorkOrders
        );
        // Assertions to validate behavior
        System.assertNotEquals(null, uploadResults, 'The upload results returned as null.');
        Boolean menuURLErrorReceived = false;
        for (
            BulkCorporateOnboardingWrappers.ErrorMessage eachErrorMessage : uploadResults.errorMessages
        ) {
            if (eachErrorMessage.message.contains(MENU_URL_ERROR_MESSAGE)) {
                menuURLErrorReceived = true;
            }
        }
        System.assertEquals(
                false,
                menuURLErrorReceived,
                'Unexpected result: Menu URL error thrown for Store Accounts: ' + JSON.serialize(uploadResults.errorMessages)
        );
    }

    /**
     * @description To validate that an error message is returned when Store Accounts uploaded
     * without "Phone" on csv file
     * @JIRA# LEM-11438
     */
    @isTest
    @SuppressWarnings('PMD.AvoidHardcodingId')
    private static void testWhenStoreAccountsUploadedWithoutPhoneNumberThenNoErrorThrown() {
        BulkCorporateOnboardingWrappers.StoreValidationResult uploadResults = getResultOfFileUploadFromStaticResource(
            'Bulk_Upload_Menu_URL_Test',
            new List<WorkOrder>()
        );
        System.assertNotEquals(null, uploadResults, 'The result should not be null.');
        Boolean hasPhoneRequiredErrorOccurred = false;
        for (
            BulkCorporateOnboardingWrappers.ErrorMessage eachErrorMessage : uploadResults.errorMessages
        ) {
            if (eachErrorMessage.message.contains(PHONE_NUMBER_ERROR_MESSAGE)) {
                hasPhoneRequiredErrorOccurred = true;
            }
        }
        System.assertEquals(
                false,
                hasPhoneRequiredErrorOccurred,
                ASSERT_MESSAGE_ERROR_NOT_MATCHED + JSON.serialize(uploadResults.errorMessages)
        );
    }

    @IsTest
    static void testWhenRetrievingCustomNotificationTypeThenReturn() {
        CustomNotificationType notificationType = BulkCorporateOnboardingRequestService.getNewStoreOnboardingCustomNotificationType();
        System.assertNotEquals(
            null,
            notificationType,
            'A Custom Notification Type should have been returned.'
        );
    }

    @IsTest
    static void testWhenCallingToParseDataThenInsertChunks() {
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
        BulkCorporateOnboardingWrappers.StoreValidationResult result = BulkCorporateOnboardingRequestService.parseAndInsertStores(
            flowRequestId,
            1,
            uploadResults
        );
        Test.stopTest();

        System.assert(result.saveFinished, 'The saveFinished variable should be set');
        // System.assertNotEquals(0, result.storeWrappers.size(), 'Stores should be in the `storeWrappers` array.');

        // for(BulkCorporateOnboardingWrappers.StoreInfo thisStore : result.storeWrappers) {
        //     System.assertNotEquals(null, thisStore.storeId, 'Each Store should have an associated record ID');
        // }
    }

    /**
     * @description creates mock business references, number of records created = number of stores in the static resource
     * if the number of records in the csv is 2, return a Map(Size 2) Buisness reference external Id to Buiness Reference
     * @param numberOfStores - The number of stores in the Static resource
     * @return bussRefExternalIDToMockBusineesReference
     **/
    private static Map<String, Business_Reference__c> generateMockBusinessRefs(
        Integer numberOfStores
    ) {
        Map<String, Business_Reference__c> bussRefExternalIDToMockBusineesReference = new Map<String, Business_Reference__c>();
        Business_Reference__c businessRef;
        for (Integer i = 1; i <= numberOfStores; i++) {
            Id bizzRefID = Fake.generateId(Business_Reference__c.class);
            businessRef = new Business_Reference__c(
                Id = bizzRefID,
                Default_Type__c = DEFAULT_TYPE_CORPORATE,
                External_Id_Source__c = EXTERNAL_ID_SOURCE_MDS,
                External_Id__c = String.valueOf(i)
            );
            bussRefExternalIDToMockBusineesReference.put(businessRef.External_Id__c, businessRef);
        }
        return bussRefExternalIDToMockBusineesReference;
    }
}