/**
 * @author BizApps
 * @date 10 January 2024
 * @description Test class for the BulkOnboardingCsvProcessor class
 **/
@IsTest
private class BulkOnboardingCsvProcessorTest {
    private static final String REQUEST_STATUS_IN_PROGRESS = 'In Progress';
    private static final Integer CHUNKS_PER_TRANSACTION = 2;
    private static final String DATATYPE_BOOLEAN = 'Boolean';
    private static final String DATATYPE_DATE = 'Date';
    private static final String DATATYPE_DECIMAL = 'Decimal';
    private static final String DATATYPE_INTEGER = 'Integer';
    private static final String DATATYPE_STRING = 'String';
    private static final String DATATYPE_OTHER = 'Other';
    private static final String DEFAULT_TYPE_CORPORATE = 'Corporate';
    private static final String EXTERNAL_ID_SOURCE_MDS = 'MDS';
    private static final String PRIMARY_VERTICAL_ALCOHOL = 'Alochol';
    private static final string PAYMENT_ACCOUNT_PAYMENT_RECORD_TYPE_ID = Schema.SObjectType.Payment_Account__c.getRecordTypeInfosByName()
        .get('Payments')
        .getRecordTypeId();
    private static final string ACCOUNT_BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Business')
        .getRecordTypeId();

    @IsTest
    static void testWhenValidCsvIsInputtedThenUploadFile() {
        BulkCorporateOnboardingWrappers.StoreValidationResult uploadResults = getResultOfFileUploadFromStaticResource(
            'Bulk_Store_Upload_CSV_Test',
            new List<WorkOrder>()
        );
        System.assertNotEquals(null, uploadResults, 'The result should not be null.');

        String allErrors = '';
        for (BulkCorporateOnboardingWrappers.ErrorMessage thisError : uploadResults.errorMessages) {
            allErrors += thisError.fullMessage + '; ';
        }

        System.assert(!uploadResults.failedRuntimeValidations, 'Errors encountered: ' + allErrors);
    }

    @IsTest
    static void testWhenInvalidCsvIsInputtedThenReturnErrors() {
        String csvWithNoStores = 'Name,Type,Segment,Business ID,Legal Business Name,Country Code,Country,State,City,Street,Postal Code,Phone,Activated Centrally,In-Store Pickup Instructions,Parking / Arrival Instructions,Minimum Prep Time,Menu UI Type,Hours of Operation,Menu to be Completed By,Shopping Protocol,Order Protocol,POS Integration Type,POS System,POS Integration Id,Tablet Delivery Method,Payment Account ID,Decision Maker ID,Tax Override Rate\n';

        Id workOrderId = Fake.generateId(WorkOrder.class);
        Id contractId = Fake.generateId(Contract.class);
        Id flowRequestId = Fake.generateId(Process_Flow_Request__c.class);

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

        IProcessFlowRequestsSelector pfrSelectorMock = (IProcessFlowRequestsSelector) mocks.mock(
            IProcessFlowRequestsSelector.class
        );

        mocks.startStubbing();
        mocks.when(pfrSelectorMock.sObjectType()).thenReturn(Process_Flow_Request__c.SObjectType);
        mocks.when(pfrSelectorMock.selectById(new Set<Id>{ flowRequestId }))
            .thenReturn(new List<Process_Flow_Request__c>{ mockFlowRequest });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(pfrSelectorMock);

        // Call the method under test
        List<String> headerRow = csvWithNoStores.split(',');
        List<List<String>> csvRows = new List<List<String>>{ headerRow };
        BulkOnboardingCsvProcessor processor = new BulkOnboardingCsvProcessor();
        BulkCorporateOnboardingWrappers.StoreValidationResult uploadResults = processor.parseAndValidateCsv(
            csvRows,
            flowRequestId,
            1,
            CHUNKS_PER_TRANSACTION
        );

        // Assertions to validate behavior.
        System.assertNotEquals(null, uploadResults, 'The result should not be null.');
        System.assert(
            uploadResults.failedRuntimeValidations,
            'There should be no runtime (readiness check) errors for this csv file.'
        );

        Boolean found = false;
        for (BulkCorporateOnboardingWrappers.ErrorMessage thisError : uploadResults.errorMessages) {
            if (thisError.message.trim().equalsIgnoreCase('You must include at least one store')) {
                found = true;
                break;
            }
        }
        System.assert(found, 'Should have a Missing Stores Error');

        Boolean foundValidColumnNameError = false;
        for (BulkCorporateOnboardingWrappers.ErrorMessage thisError : uploadResults.errorMessages) {
            String trimmedMsg = thisError.message.trim();

            if (trimmedMsg.containsIgnoreCase('valid column name')) {
                foundValidColumnNameError = true;
            }
        }

        System.assert(foundValidColumnNameError, 'Should have an Invalid Column Name error');
    }

    @IsTest
    static void testWhenInputtingValuesToSafeConvertThenReturnCorrectType() {
        Object booleanResult = BulkOnboardingCsvProcessor.safeConvert('true', DATATYPE_BOOLEAN);
        System.assertEquals(true, booleanResult, 'Boolean conversion failed');

        Object dateResult = BulkOnboardingCsvProcessor.safeConvert('2022-01-11', DATATYPE_DATE);
        System.assertEquals(Date.valueOf('2022-01-11'), dateResult, 'Date conversion failed');

        Object invalidDateResult = BulkOnboardingCsvProcessor.safeConvert('k', DATATYPE_DATE);
        System.assertEquals(null, invalidDateResult, 'Date conversion failed');

        Object decimalResult = BulkOnboardingCsvProcessor.safeConvert('123.45', DATATYPE_DECIMAL);
        System.assertEquals(Decimal.valueOf('123.45'), decimalResult, 'Decimal conversion failed');

        Object integerResult = BulkOnboardingCsvProcessor.safeConvert('42', DATATYPE_INTEGER);
        System.assertEquals(Integer.valueOf('42'), integerResult, 'Integer conversion failed');

        Object stringResult = BulkOnboardingCsvProcessor.safeConvert('Test', DATATYPE_STRING);
        System.assertEquals('Test', stringResult, 'String conversion failed');

        Object blankStringResult = BulkOnboardingCsvProcessor.safeConvert('', DATATYPE_STRING);
        System.assertEquals(
            null,
            blankStringResult,
            'Conversion of blank value should return null'
        );

        // Test case for an unknown data type that should result in null
        Object invalidDataTypeResult = BulkOnboardingCsvProcessor.safeConvert(
            'Test',
            DATATYPE_OTHER
        );
        System.assertEquals(
            null,
            invalidDataTypeResult,
            'Conversion with unknown data type should return null'
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
        // Used in CSV template
        Id paymentAccountId1 = 'a3e760000004aM2AAI';
        Id paymentAccountId2 = 'a3e760000004aM7AAI';
        Id paymentAccountId3 = 'a3e760000004aq7AAA';
        Id paymentAccountId4 = 'a3e760000004aozAAA';
        Id paymentAccountId5 = 'a3e760000004aqDAAQ';
        Id decisionMakerId1 = '0037600000Umx2yAAB';
        Id decisionMakerId2 = '0037600000Umx2oAAB';
        Id decisionMakerId3 = '0037600000UnOqPAAV';
        Id accountId = Fake.generateId(Account.SObjectType);
        Id workOrderId = Fake.generateId(WorkOrder.SObjectType);
        Id contractId = Fake.generateId(Contract.class);
        Id flowRequestId = Fake.generateId(Process_Flow_Request__c.class);
        Id businessVerticalID = Fake.generateId(Business_Vertical__c.class);
        Id brandID = Fake.generateId(Brand__c.class);
        Id contractBrandAssoID = Fake.generateId(Contract_Brand_Association__c.class);
        List<WorkOrder> mockWorkOrders = new List<WorkOrder>();
        List<Business_Reference__c> mockBuisnessRefs = new List<Business_Reference__c>();

        List<Account> accountList = new List<Account>{
            new Account(
                Id = parentAccountId,
                Name = 'Parent 1',
                BillingCountryCode = 'US',
                Segment__c = 'Enterprise'
            ),
            new Account(Id = accountId, ParentId = parentAccountId, Name = 'Child 1')
        };

        List<Payment_Account__c> paymentAccountList = new List<Payment_Account__c>{
            new Payment_Account__c(Id = paymentAccountId1),
            new Payment_Account__c(Id = paymentAccountId2),
            new Payment_Account__c(Id = paymentAccountId3),
            new Payment_Account__c(Id = paymentAccountId4),
            new Payment_Account__c(Id = paymentAccountId5)
        };

        List<Contact> contactList = new List<Contact>{
            new Contact(Id = decisionMakerId1, LastName = 'Test 1', Phone = '7745678'),
            new Contact(Id = decisionMakerId2, LastName = 'Test 2', Phone = '7745578'),
            new Contact(Id = decisionMakerId3, LastName = 'Test 3', Phone = '7745278')
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
        mockBuisnessRefs = bussinessRefExternalIdToMockBusineesReference.values();
        Set<String> mockBusinessRefIds = bussinessRefExternalIdToMockBusineesReference.keySet();

        for (Business_Reference__c mockBussRef : mockBuisnessRefs) {
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
        IPaymentAccountsSelector mockPaymentAccountsSelector = (IPaymentAccountsSelector) mocks.mock(
            IPaymentAccountsSelector.class
        );
        IContactsSelector mockContactsSelector = (IContactsSelector) mocks.mock(
            IContactsSelector.class
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
                    new Set<String>{ 'Corporate' },
                    new Set<String>{ 'MDS' }
                )
            )
            .thenReturn(mockBuisnessRefs);
        mocks.when(mockContractBrandSelector.sObjectType())
            .thenReturn(Contract_Brand_Association__c.SObjectType);
        mocks.when(mockContractBrandSelector.selectByContracts(new Set<String>{ contractId }))
            .thenReturn(contractBrandAssociation);
        mocks.when(mockPaymentAccountsSelector.sObjectType())
            .thenReturn(Payment_Account__c.SObjectType);
        mocks.when(
                mockPaymentAccountsSelector.selectById(
                    new Set<Id>{
                        paymentAccountId1,
                        paymentAccountId2,
                        paymentAccountId3,
                        paymentAccountId4,
                        paymentAccountId5
                    }
                )
            )
            .thenReturn(paymentAccountList);
        mocks.when(mockContactsSelector.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(
                mockContactsSelector.selectById(
                    new Set<Id>{ decisionMakerId1, decisionMakerId2, decisionMakerId3 }
                )
            )
            .thenReturn(contactList);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(contractsSelectorMock);
        Application.SELECTOR.setMock(pfrSelectorMock);
        Application.SELECTOR.setMock(mockWorkOrderSelector);
        Application.SELECTOR.setMock(mockBusinessRefSelector);
        Application.SELECTOR.setMock(mockContractBrandSelector);
        Application.SELECTOR.setMock(mockPaymentAccountsSelector);
        Application.SELECTOR.setMock(mockContactsSelector);

        BulkOnboardingCsvProcessor processor = new BulkOnboardingCsvProcessor();
        return processor.parseAndValidateCsv(csvRows, flowRequestId, 1, CHUNKS_PER_TRANSACTION);
    }

    /**
     * @description creates mock business references, number of records created = number of stores in the static resource
     * if the number of records in the csv is 2, return a Map(Size 2) Buisness reference external Id to Buiness Reference
     * @param numberOfStores - The number of the stores in the static resource
     * @return bussRefExternalIDToMockBusineesReference
     **/
    private static Map<String, Business_Reference__c> generateMockBusinessRefs(
        Integer numberOfStores
    ) {
        Map<String, Business_Reference__c> bussinessRefExternalIdToMockBusineesReference = new Map<String, Business_Reference__c>();
        Business_Reference__c businessRef;
        for (Integer i = 1; i <= numberOfStores; i++) {
            Id bizzRefID = Fake.generateId(Business_Reference__c.class);
            businessRef = new Business_Reference__c(
                Id = bizzRefID,
                Default_Type__c = DEFAULT_TYPE_CORPORATE,
                External_Id_Source__c = EXTERNAL_ID_SOURCE_MDS,
                CurrencyIsoCode = 'USD',
                External_Id__c = String.valueOf(i)
            );
            bussinessRefExternalIdToMockBusineesReference.put(
                businessRef.External_Id__c,
                businessRef
            );
        }
        return bussinessRefExternalIdToMockBusineesReference;
    }
}