/**
 * @author Deloitte
 * @date 08/25/2022
 * @description Test class for ParentWorkOrdersCreationServiceImpl class.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.NcssTypeCount')
private class ParentWorkOrdersCreationServiceImplTest {
    private static final String ACCOUNT_DATA_VERIFICATION_STATUS = 'Verified';
    private static final String ACCOUNT_PRIMARY_VERTICAL = 'Rx';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ADDRESS_VERIFICATION_STATUS = 'Verified';
    private static final String CONFIRMED_STATUS = 'Confirmed';
    private static final String CONTRACT_CURRENCY_ISO_CODE = 'USD - U.S. Dollar';
    private static final String CONTRACT_STATUS_ACTIVATED = 'Activated';
    private static final String DATETIME_DAY_OF_WEEK_SYMBOL = 'E';
    private static final String DAY_OF_WEEK_SAT = 'Sat';
    private static final String DAY_OF_WEEK_SUN = 'Sun';
    private static final String DRIVE_AUTO_ACTIVATION_SUPPORTED = 'Yes';
    private static final String DRIVE_AUTO_ACTIVATION_NOT_SUPPORTED = 'No';
    private static final String ACCOUNT_BILLING_COUNTRY_CODE = 'AUS';
    private static final String ACCOUNT_SEGMENT_ENTERPRISE = 'Enterprise';
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    private static final String ACCOUNT_ACTIVATION_STATUS = 'Active';
    private static final String ACCOUNT_BILLING_CITY = 'Port Byron';
    private static final String ACCOUNT_BILLING_COUNTRY = 'United States';
    private static final String ACCOUNT_BILLING_POSTALCODE = '13140';
    private static final String ACCOUNT_BILLING_STATE = 'New York';
    private static final String ACCOUNT_BILLING_STREET = 'South Street Road';
    private static final String BUSINESS_ACCOUNT_NAME = 'Subway';
    private static final String ACCOUNT_BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get(ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
        .getRecordTypeId();
    private static final String ACCOUNT_TYPE = 'Franchisee';
    private static final String ACCOUNT_PARTNERSHIP_STATUS = 'Prospective Partner';
    private static final Schema.DescribeFieldResult DRIVE_AUTO_PROVISIONING_INDICATOR_FIELD = Schema.getGlobalDescribe()
        .get('Contract')
        .getDescribe()
        .fields.getMap()
        .get(System.Label.DriveAutoProvisioningIndicator)
        .getDescribe();
    private static final String BUNDLED_WITH_MARKETPLACE_NO = 'No';
    private static final String DRIVE_WORK_ORDER_SUB_TYPE_AUTO_ACTIVATIONS = 'Auto-Activations';
    private static final String FIELD_TO_REFER = 'CloseDate';
    private static final String FIELD_TO_REFER_ACCOUNT = 'Change_of_Ownership_Effective_Date__c';
    private static final string OBJECT_TO_REFER = 'Opportunity';
    private static final string OBJECT_TO_REFER_ACCOUNT = 'Account';
    private static final string OPERATOR_GREATER_THAN_EQUALS = 'GREATER_THAN_EQUALS';
    private static final string OPERATOR_LESS_THAN = 'LESS_THAN';
    private static final string ORDER_PROTOCOL_EMAIL = 'Email';
    private static final String IN_COVERAGE = 'In Coverage';
    private static final String NET_NEW_SUB_TYPE = 'Net - New';
    private static final String PHOTOSHOOT_REQUESTED_YES = 'Yes';
    private static final String NINTEX_MAPPING_CHANGE_OF_OWNERSHIP = 'Change_of_Ownership';
    private static final String NINTEX_MAPPING_DRIVE_AMENDMENT = 'Drive_Amendment';
    private static final String NINTEX_USE_CASE_NEW_FRANCHISE = 'New Franchise - Unknown';
    private static final String NINTEX_USE_CASE_MIDDLEWARE_PROVIDER = 'Middleware Provider';
    private static final String NINTEX_USE_CASE_SSMO = 'SSMO';
    private static final String NINTEX_USE_CASE_DRIVE_AMENDMENT = 'Drive - Amendment';
    private static final String NINTEX_USE_CASE_DRIVE_FORM = 'Drive - Amendment';
    private static final String NINTEX_USE_CASE_DRIVE_FORM_INTEGRATED_FRANCHISE = 'Integrated Franchise';
    private static final String NINTEX_USE_CASE_CHANGE_OF_OWNERSHIP = 'Change of Ownership';
    private static final String NINTEX_USE_CASE_NEW_ADDITIONAL_STORES = 'New additional stores';
    private static final String ONBOARDING_SCENARIO_NET_NEW_MX_ONBOARDING = 'Net-New';
    private static final String OPPORTUNITY_DRIVE_NINTEX_ID = 'WorkOrdersCreationServiceImplTestDriveNintexId';
    private static final String OPPORTUNITY_FRANCHISE_AMENDMENT_PROCESS_OPT_IN = 'Opt-In';
    private static final String OPPORTUNITY_FRANCHISE_AMENDMENT_PROCESS_OPT_OUT = 'Opt-Out';
    private static final String OPPORTUNITY_MARKETPLACE_NINTEX_ID = 'WorkOrdersCreationServiceImplTestMarketPlaceNintexId';
    private static final String OPPORTUNITY_NAME = 'Test Opportunity';
    private static final String OPPORTUNITY_SOURCE = 'Nintex';
    private static final String OPPORTUNITY_STAGE_PITCHING = 'Pitching';
    private static final String OPPORTUNITY_STAGE_PROSPECTING = 'Prospecting';
    private static final String OPPORTUNITY_STAGE_CLOSED_WON = 'Closed Won';
    private static final String PROVISIONING_PROCESS_AUTOMATIC = 'Automatic';
    private static final String PROVISIONING_PROCESS_FIELD = 'Business_to_Store_Assignment__c';
    private static final String PROVISIONING_PROCESS_MANUAL = 'Manual';
    private static final String PROVISIONING_PROCESS_VALUE_ASSERT_MESSAGE = 'Unexpected result: failed to populate provisioning process value on parent Work Order';
    private static final String POS_ORDER_PROTOCOL = 'POS';
    private static final String RATE_CHANGE = 'Rate Change';
    private static final String RECORD_CREATION_STATUS_SUCCESS = 'Success';
    private static final String READINESS_CHECK_COMPLETE = 'Readiness Check Complete';
    private static final String SSMO_CREATION_SOURCE = 'SSMO';
    private static final String TEST_USER_ALIAS = 'MockUser';
    private static final String TEST_USER_EMAIL_ID = 'mockUser@ParentWorkOrdersCreationSrvcImplTest.com';
    private static final String TEST_USER_NAME = 'mockUser@ParentWorkOrdersCreationSrvcImplTest.com.test';
    private static final String TYPE_COO = 'COO';
    private static final String TYPE_DRIVE = 'Drive';
    private static final String TYPE_POST_SALES = 'Post-Sales';
    private static final String TYPE_MARKETPLACE = 'Marketplace';
    private static final String TYPE_STOREFRONT = 'Storefront';
    private static final String USER_ENCODING = 'UTF-8';
    private static final String USER_LAST_NAME = 'Mock User';
    private static final String USER_LOCALE = 'en_US';
    private static final String USER_TIMEZONE = 'GMT';
    private static final string VALUE_TO_APPLY_TYPE_DATE = 'Date';
    private static final string VALUE_TO_APPLY_TYPE_SELF = 'Self';
    private static final string VALUE_TO_COMPARE_TODAY = 'Today';
    private static final String WITHHOLDING = 'Withholding';
    private static final String WORK_ORDER_ACCOUNT_ID_FIELD = 'AccountId';
    private static final String WORK_ORDER_NOT_REGISTERED_ASSERT_MESSAGE = 'Unexpected result: failed to skip parent Work Order creation';
    private static final String WORK_ORDER_PDOA_FIELD = 'Proposed_Date_of_Activation__c';
    private static final String WORK_ORDER_SOURCE_ONBOARDING_INPUTS = 'Onboarding Inputs';
    private static final String WORK_ORDER_SUB_TYPE_FIELD = 'Sub_Type__c';
    private static final String WORK_ORDER_PDOA_MISMATCH_ASSERT_MESSAGE = 'Unexpected result: there is a mismatch in PDOA on parent Work Order created';
    private static final String WORK_ORDER_REGISTERED_ASSERT_MESSAGE = 'Unexpected result: failed to register expected parent Work Order';
    private static final String WORK_ORDER_SUB_TYPE = 'Partnership creation/update';
    private static final String WORK_ORDER_SUB_TYPE_AUTO_ACTIVATIONS = 'Auto-Activations';
    private static final String WORK_ORDER_SUB_TYPE_MISMATCH_ASSERT_MESSAGE = 'Unexpected result: there is a mismatch in Sub-Type on parent Work Order created';
    private static final String WORK_ORDER_SUB_TYPE_NET_NEW_BUSINESS = 'Net-new business';
    private static final String WORK_ORDER_TYPE_FIELD = 'Type__c';
    private static final String ACCOUNT_LIFECYCLE_STATUS = 'Unvetted';
    private static final String WORK_ORDER_WITHHOLDING_WITH_AUTO_ACTIVATIONS_MISMATCH_ASSERT_MESSAGE = 'Unexpected result: there is a mismatch in Withholding with Auto-autoactivations on parent Work Order created';
    private static final String WORK_ORDER_WITH_SSMO_NINTEX_USE_CASE_FIELDS_MISMATCH_ASSERT_MESSAGE = 'Unexpected result: there is a mismatch in fields on created parent Work Order.';
    private static final Date TODAY_DATE = System.today();
    private static final String READY_FOR_ACTIVATION = 'Ready for Activation';
    private static final String MENU_SETUP_METHOD_NONE = 'None - Menu Setup Complete';
    private static final String MENU_COMPLETED_BY_NONE = 'None - Menu Setup Complete';
    private static final String INTERFACE_TRANSACTION_CONFIGURATION_NAME_WORK_ORDER_PAYLOAD_INBOUND_INTEGRATION = 'WORK_ORDER_PAYLOAD_INBOUND_INTEGRATION';
    private static final String WORKORDER_FOUND_ALERT_MESSAGE = 'Unexpected result: It failed to skip work order creation';
    private static final String UNIQUE_IDENTIFIER = '59faf5ab-1c35-17b5-be2c-5747db5a2bba';
    private static final String PACKAGES_WITH_PRODUCTS = '{"packageDetails":[{"packageName":"Marketplace","products":"Pickup,Delivery,Dashpass"},{"packageName":"Storefront","products":""}]}';

    /**
     * @description To test parent Work Order is created when
     * Opportunities with Nintex Id are received.
     */
    @isTest
    private static void testWhenOpportunitiesReceivedThenParentWorkOrdersCreatedByOpportunityNintexUseCase() {
        Id opportunityWithMarketplaceNintexSubmissionId = fflib_IDGenerator.generate(
            Opportunity.SObjectType
        );
        Id opportunityWithDriveNintexSubmissionId = fflib_IDGenerator.generate(
            Opportunity.SObjectType
        );
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake opportunityWithMarketplaceNintexIdFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityWithMarketplaceNintexSubmissionId)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.Marketplace_Nintex_Id__c, OPPORTUNITY_MARKETPLACE_NINTEX_ID)
            .setField(Opportunity.AccountId, parentBusinessAccount.Id)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_PROSPECTING)
            .setField(Opportunity.Source__c, OPPORTUNITY_SOURCE)
            .setField(Opportunity.Nintex_Use_Case__c, NINTEX_USE_CASE_NEW_FRANCHISE);
        Opportunity opportunityWithMarketplaceNintexId = (Opportunity) opportunityWithMarketplaceNintexIdFakeInstance.toSObject();
        Fake contractFakeInstance = new Fake(Contract.class)
            .setField(Contract.AccountId, parentBusinessAccount.Id)
            .setField(Contract.CurrencyIsoCode, CONTRACT_CURRENCY_ISO_CODE)
            .setField(
                (DRIVE_AUTO_PROVISIONING_INDICATOR_FIELD.getSObjectField()),
                DRIVE_AUTO_ACTIVATION_NOT_SUPPORTED
            )
            .setField(Contract.Status, CONTRACT_STATUS_ACTIVATED)
            .setField(Contract.SBQQ__Opportunity__c, opportunityWithDriveNintexSubmissionId)
            .setFakeId();
        Contract contract = (Contract) contractFakeInstance.toSObject();
        Fake opportunityWithDriveNintexIdFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityWithDriveNintexSubmissionId)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.Drive_Nintex_Id__c, OPPORTUNITY_DRIVE_NINTEX_ID)
            .setField(Opportunity.AccountId, parentBusinessAccount.Id)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_PROSPECTING)
            .setField(Opportunity.Source__c, OPPORTUNITY_SOURCE)
            .setField(Opportunity.Nintex_Use_Case__c, NINTEX_USE_CASE_DRIVE_FORM)
            .setParent('Contract', contractFakeInstance);
        Opportunity opportunityWithDriveNintexId = (Opportunity) opportunityWithDriveNintexIdFakeInstance.toSObject();
        Fake parentWorkOrderInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentBusinessAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(Account.Proposed_Date_of_Activation__c, System.today() + 40)
            .setField(WorkOrder.Opportunity__c, opportunityWithMarketplaceNintexId.Id)
            .setParent('Account', parentBusinessAccountFakeInstance)
            .setParent('Opportunity__r', opportunityWithMarketplaceNintexIdFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderInstance
        );
        Fake storeAccountWithDriveNintexIdFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL
            )
            .setField(Account.Drive_Nintex_Id__c, OPPORTUNITY_DRIVE_NINTEX_ID)
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(Account.Data_Verification_Status__c, ACCOUNT_DATA_VERIFICATION_STATUS);
        Account storeAccountWithDriveNintexId = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountWithDriveNintexIdFakeInstance
        );
        Fake marketplaceNintexUseCaseFakeInstance = new Fake(Nintex_Work_Order_Mapping__mdt.class)
            .setField(
                Nintex_Work_Order_Mapping__mdt.Nintex_Use_Case__c,
                NINTEX_USE_CASE_NEW_FRANCHISE
            )
            .setField(Nintex_Work_Order_Mapping__mdt.Work_Order_Type__c, TYPE_MARKETPLACE)
            .setFakeId();
        Nintex_Work_Order_Mapping__mdt marketplaceNintexUseCase = (Nintex_Work_Order_Mapping__mdt) marketplaceNintexUseCaseFakeInstance.toSObject();
        Fake driveNintexUseCaseFakeInstance = new Fake(Nintex_Work_Order_Mapping__mdt.class)
            .setField(Nintex_Work_Order_Mapping__mdt.Nintex_Use_Case__c, NINTEX_USE_CASE_DRIVE_FORM)
            .setField(Nintex_Work_Order_Mapping__mdt.Work_Order_Type__c, TYPE_DRIVE)
            .setField(Nintex_Work_Order_Mapping__mdt.Work_Order_Sub_Type__c, WORK_ORDER_SUB_TYPE)
            .setField(
                Nintex_Work_Order_Mapping__mdt.Work_Order_Provisioning_Process__c,
                PROVISIONING_PROCESS_MANUAL
            )
            .setFakeId();
        Nintex_Work_Order_Mapping__mdt driveNintexUseCaseToWorkOrderType = (Nintex_Work_Order_Mapping__mdt) driveNintexUseCaseFakeInstance.toSObject();
        List<Nintex_Work_Order_Mapping__mdt> nintexToWorkOrderMappings = new List<Nintex_Work_Order_Mapping__mdt>{
            marketplaceNintexUseCase,
            driveNintexUseCaseToWorkOrderType
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        INintexWorkOrderMappingsSelector mockNintexWorkOrderMappings = (INintexWorkOrderMappingsSelector) mocks.mock(
            INintexWorkOrderMappingsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockNintexWorkOrderMappings.getAllMappings())
            .thenReturn(nintexToWorkOrderMappings);
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByOpportunityIds(
                    new Set<Id>{
                        opportunityWithMarketplaceNintexId.Id,
                        opportunityWithDriveNintexId.Id
                    }
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                mockAccountsSelector.selectStoreAccountsByMarketplaceOrDriveNintexIds(
                    new Set<String>{ OPPORTUNITY_DRIVE_NINTEX_ID }
                )
            )
            .thenReturn(new List<Account>{ storeAccountWithDriveNintexId });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockNintexWorkOrderMappings);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockAccountsSelector);
        ParentWorkOrdersCreationService.createParentWorkOrdersByNintexUseCases(
            new List<Opportunity>{
                opportunityWithMarketplaceNintexId,
                opportunityWithDriveNintexId
            }
        );
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());
        WorkOrder parentWorkOrderInserted = (WorkOrder) ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
            .sObjectsToInsert[0];
        Boolean hasParentOrderRegistered =
            parentWorkOrderInserted.get(WORK_ORDER_ACCOUNT_ID_FIELD) ==
            opportunityWithDriveNintexId.AccountId;
        System.assertEquals(true, hasParentOrderRegistered, WORK_ORDER_REGISTERED_ASSERT_MESSAGE);
        System.assertEquals(
            PROVISIONING_PROCESS_MANUAL,
            parentWorkOrderInserted.get(PROVISIONING_PROCESS_FIELD),
            PROVISIONING_PROCESS_VALUE_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test parent Work Order creation with Sub-Type = "Auto-Activations"
     * when Type = "Drive" and Drive auto provisioning indicator on the associated Contract is "Yes".
     */
    @isTest
    private static void testWhenDriveAutoActivationSupportedOnContractThenParentWorkOrderWithSubTypeAutoActivationsCreated() {
        Id opportunityWithDriveNintexSubmissionId = fflib_IDGenerator.generate(
            Opportunity.SObjectType
        );
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake contractFakeInstance = new Fake(Contract.class)
            .setField(Contract.AccountId, parentBusinessAccount.Id)
            .setField(Contract.CurrencyIsoCode, CONTRACT_CURRENCY_ISO_CODE)
            .setField(
                (DRIVE_AUTO_PROVISIONING_INDICATOR_FIELD.getSObjectField()),
                DRIVE_AUTO_ACTIVATION_SUPPORTED
            )
            .setField(Contract.Status, CONTRACT_STATUS_ACTIVATED)
            .setField(Contract.SBQQ__Opportunity__c, opportunityWithDriveNintexSubmissionId)
            .setFakeId();
        Contract contract = (Contract) contractFakeInstance.toSObject();
        Fake opportunityWithDriveNintexIdFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityWithDriveNintexSubmissionId)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.Drive_Nintex_Id__c, OPPORTUNITY_DRIVE_NINTEX_ID)
            .setField(Opportunity.AccountId, parentBusinessAccount.Id)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_PROSPECTING)
            .setField(Opportunity.Source__c, OPPORTUNITY_SOURCE)
            .setField(
                Opportunity.Nintex_Use_Case__c,
                NINTEX_USE_CASE_DRIVE_FORM_INTEGRATED_FRANCHISE
            )
            .setParent('Contract', contractFakeInstance);
        Opportunity opportunityWithDriveNintexId = (Opportunity) opportunityWithDriveNintexIdFakeInstance.toSObject();
        Fake storeAccountWithDriveNintexIdFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL
            )
            .setField(Account.Drive_Nintex_Id__c, OPPORTUNITY_DRIVE_NINTEX_ID)
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(Account.Data_Verification_Status__c, ACCOUNT_DATA_VERIFICATION_STATUS);
        Account storeAccountWithDriveNintexId = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountWithDriveNintexIdFakeInstance
        );
        Fake driveNintexUseCaseFakeInstance = new Fake(Nintex_Work_Order_Mapping__mdt.class)
            .setField(
                Nintex_Work_Order_Mapping__mdt.Nintex_Use_Case__c,
                NINTEX_USE_CASE_DRIVE_FORM_INTEGRATED_FRANCHISE
            )
            .setField(Nintex_Work_Order_Mapping__mdt.Work_Order_Type__c, TYPE_DRIVE)
            .setField(Nintex_Work_Order_Mapping__mdt.Work_Order_Sub_Type__c, WORK_ORDER_SUB_TYPE)
            .setField(
                Nintex_Work_Order_Mapping__mdt.Work_Order_Provisioning_Process__c,
                PROVISIONING_PROCESS_AUTOMATIC
            )
            .setFakeId();
        Nintex_Work_Order_Mapping__mdt driveNintexUseCaseToWorkOrderType = (Nintex_Work_Order_Mapping__mdt) driveNintexUseCaseFakeInstance.toSObject();
        List<Nintex_Work_Order_Mapping__mdt> nintexToWorkOrderMappings = new List<Nintex_Work_Order_Mapping__mdt>{
            driveNintexUseCaseToWorkOrderType
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        INintexWorkOrderMappingsSelector mockNintexWorkOrderMappings = (INintexWorkOrderMappingsSelector) mocks.mock(
            INintexWorkOrderMappingsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockNintexWorkOrderMappings.getAllMappings())
            .thenReturn(nintexToWorkOrderMappings);
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByOpportunityIds(
                    new Set<Id>{ opportunityWithDriveNintexId.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                mockAccountsSelector.selectStoreAccountsByMarketplaceOrDriveNintexIds(
                    new Set<String>{ OPPORTUNITY_DRIVE_NINTEX_ID }
                )
            )
            .thenReturn(new List<Account>{ storeAccountWithDriveNintexId });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockNintexWorkOrderMappings);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockAccountsSelector);
        ParentWorkOrdersCreationService.createParentWorkOrdersByNintexUseCases(
            new List<Opportunity>{ opportunityWithDriveNintexId }
        );
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());
        Boolean hasParentOrderRegisteredWithSubTypeAutoActivations =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_SUB_TYPE_FIELD) == DRIVE_WORK_ORDER_SUB_TYPE_AUTO_ACTIVATIONS;
        System.assertEquals(
            true,
            hasParentOrderRegisteredWithSubTypeAutoActivations,
            WORK_ORDER_REGISTERED_ASSERT_MESSAGE
        );
        Boolean hasProvisioningProcessFieldPopulated =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(PROVISIONING_PROCESS_FIELD) == PROVISIONING_PROCESS_AUTOMATIC;
        System.assertEquals(
            true,
            hasProvisioningProcessFieldPopulated,
            PROVISIONING_PROCESS_VALUE_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test PDOA is calculated by value to apply and offset to apply from
     * "Opportunity Status To PDOA Mappings" custom metadata when COO Opportunity is
     * Closed Won and less than 5 days in future.
     */
    @isTest
    private static void testWhenOppCOOClosedWonLessThanFiveDaysInFutureThenPDOACalculatedByValueOffset() {
        Id opportunityWithDriveNintexSubmissionId = fflib_IDGenerator.generate(
            Opportunity.SObjectType
        );
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake contractFakeInstance = new Fake(Contract.class)
            .setField(Contract.AccountId, parentBusinessAccount.Id)
            .setField(Contract.CurrencyIsoCode, CONTRACT_CURRENCY_ISO_CODE)
            .setField(Contract.Status, CONTRACT_STATUS_ACTIVATED)
            .setField(Contract.SBQQ__Opportunity__c, opportunityWithDriveNintexSubmissionId)
            .setFakeId();
        Contract contract = (Contract) contractFakeInstance.toSObject();
        Fake opportunityWithDriveNintexIdFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityWithDriveNintexSubmissionId)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.Drive_Nintex_Id__c, OPPORTUNITY_DRIVE_NINTEX_ID)
            .setField(Opportunity.AccountId, parentBusinessAccount.Id)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_CLOSED_WON)
            .setField(Opportunity.Source__c, OPPORTUNITY_SOURCE)
            .setField(Opportunity.Nintex_Use_Case__c, NINTEX_USE_CASE_CHANGE_OF_OWNERSHIP)
            .setParent('Contract', contractFakeInstance);
        Opportunity opportunityWithDriveNintexId = (Opportunity) opportunityWithDriveNintexIdFakeInstance.toSObject();
        Fake storeAccountWithDriveNintexIdFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL
            )
            .setField(Account.Change_of_Ownership_Effective_Date__c, System.today().addDays(3))
            .setField(Account.Drive_Nintex_Id__c, OPPORTUNITY_DRIVE_NINTEX_ID)
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(Account.BillingCountryCode, ACCOUNT_BILLING_COUNTRY_CODE)
            .setField(Account.Data_Verification_Status__c, ACCOUNT_DATA_VERIFICATION_STATUS);
        Account storeAccountWithDriveNintexId = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountWithDriveNintexIdFakeInstance
        );
        Fake cooNintexUseCaseFakeInstance = new Fake(Nintex_Work_Order_Mapping__mdt.class)
            .setField(
                Nintex_Work_Order_Mapping__mdt.DeveloperName,
                NINTEX_MAPPING_CHANGE_OF_OWNERSHIP
            )
            .setField(
                Nintex_Work_Order_Mapping__mdt.Nintex_Use_Case__c,
                NINTEX_USE_CASE_CHANGE_OF_OWNERSHIP
            )
            .setField(Nintex_Work_Order_Mapping__mdt.Work_Order_Type__c, TYPE_COO)
            .setField(
                Nintex_Work_Order_Mapping__mdt.Work_Order_Provisioning_Process__c,
                PROVISIONING_PROCESS_AUTOMATIC
            )
            .setFakeId();
        Nintex_Work_Order_Mapping__mdt cooNintexUseCaseToWorkOrderType = (Nintex_Work_Order_Mapping__mdt) cooNintexUseCaseFakeInstance.toSObject();
        List<Nintex_Work_Order_Mapping__mdt> nintexToWorkOrderMappings = new List<Nintex_Work_Order_Mapping__mdt>{
            cooNintexUseCaseToWorkOrderType
        };
        Opportunity_Status_PDOA_Mapping__mdt opportunityStatusToPDOAMapping = (Opportunity_Status_PDOA_Mapping__mdt) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createOpportunityStatusPDOAMappingFakeInstance(
                    FIELD_TO_REFER_ACCOUNT,
                    OBJECT_TO_REFER_ACCOUNT,
                    OPPORTUNITY_STAGE_CLOSED_WON,
                    2
                )
                .setField(Opportunity_Status_PDOA_Mapping__mdt.Compare_Values__c, true)
                .setField(
                    Opportunity_Status_PDOA_Mapping__mdt.Value_To_Compare__c,
                    VALUE_TO_COMPARE_TODAY
                )
                .setField(Opportunity_Status_PDOA_Mapping__mdt.Operator__c, OPERATOR_LESS_THAN)
                .setField(
                    Opportunity_Status_PDOA_Mapping__mdt.Offset_To_Compare__c,
                    String.valueOf(5)
                )
                .setField(
                    Opportunity_Status_PDOA_Mapping__mdt.Value_To_Apply_Type__c,
                    VALUE_TO_APPLY_TYPE_DATE
                )
                .setField(
                    Opportunity_Status_PDOA_Mapping__mdt.Value_To_Apply__c,
                    VALUE_TO_COMPARE_TODAY
                )
                .setField(
                    Opportunity_Status_PDOA_Mapping__mdt.Offset_To_Apply__c,
                    String.valueOf(5)
                )
                .setField(
                    Opportunity_Status_PDOA_Mapping__mdt.Nintex_Mapping__c,
                    cooNintexUseCaseToWorkOrderType.Id
                )
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        INintexWorkOrderMappingsSelector mockNintexWorkOrderMappings = (INintexWorkOrderMappingsSelector) mocks.mock(
            INintexWorkOrderMappingsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IOpportunityStatusPDOAMappingsSelector mockOpportunityStatusPDOAMappingsSelector = (IOpportunityStatusPDOAMappingsSelector) mocks.mock(
            IOpportunityStatusPDOAMappingsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockNintexWorkOrderMappings.getAllMappings())
            .thenReturn(nintexToWorkOrderMappings);
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByOpportunityIds(
                    new Set<Id>{ opportunityWithDriveNintexId.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                mockAccountsSelector.selectStoreAccountsByMarketplaceOrDriveNintexIds(
                    new Set<String>{ OPPORTUNITY_DRIVE_NINTEX_ID }
                )
            )
            .thenReturn(new List<Account>{ storeAccountWithDriveNintexId });
        mocks.when(
                mockOpportunityStatusPDOAMappingsSelector.selectByNintexUseCaseMappings(
                    new Set<String>{ NINTEX_MAPPING_CHANGE_OF_OWNERSHIP }
                )
            )
            .thenReturn(
                new List<Opportunity_Status_PDOA_Mapping__mdt>{ opportunityStatusToPDOAMapping }
            );
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockNintexWorkOrderMappings);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockAccountsSelector);
        Application.SELECTOR.setMock(mockOpportunityStatusPDOAMappingsSelector);
        ParentWorkOrdersCreationService.createParentWorkOrdersByNintexUseCases(
            new List<Opportunity>{ opportunityWithDriveNintexId }
        );
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());
        WorkOrder parentWorkOrderInserted = (WorkOrder) ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
            .sObjectsToInsert[0];
        Boolean hasParentOrderRegisteredWithTypeCOO =
            parentWorkOrderInserted.get(WORK_ORDER_TYPE_FIELD) == TYPE_COO;
        Date proposedDateOfActivationResult = (Date) parentWorkOrderInserted
            .get(WORK_ORDER_PDOA_FIELD);
        DateTime dateTimeValueOfPDOA = DateTime.newInstance(
            proposedDateOfActivationResult.year(),
            proposedDateOfActivationResult.month(),
            proposedDateOfActivationResult.day()
        );
        Boolean isPDOAOnWeekend =
            dateTimeValueOfPDOA.formatGmt(DATETIME_DAY_OF_WEEK_SYMBOL) == DAY_OF_WEEK_SAT ||
            dateTimeValueOfPDOA.formatGmt(DATETIME_DAY_OF_WEEK_SYMBOL) == DAY_OF_WEEK_SUN;
        Boolean hasProvisioningProcessFieldPopulated =
            parentWorkOrderInserted.get(PROVISIONING_PROCESS_FIELD) ==
            PROVISIONING_PROCESS_AUTOMATIC;
        System.assertEquals(
            true,
            hasParentOrderRegisteredWithTypeCOO,
            WORK_ORDER_REGISTERED_ASSERT_MESSAGE
        );
        System.assertEquals(false, isPDOAOnWeekend, WORK_ORDER_PDOA_MISMATCH_ASSERT_MESSAGE);
        System.assertEquals(
            true,
            hasProvisioningProcessFieldPopulated,
            PROVISIONING_PROCESS_VALUE_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test PDOA is calculated by value to apply and offset to apply
     * from "Opportunity Status To PDOA Mappings" custom metadata
     * when Drive - Amendment Opportunity is "Closed Won".
     */
    @isTest
    private static void testWhenOpportunityDriveAmendmentClosedWonThenPDOACalculatedByValueOffset() {
        Id opportunityWithDriveNintexSubmissionId = fflib_IDGenerator.generate(
            Opportunity.SObjectType
        );
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake contractFakeInstance = new Fake(Contract.class)
            .setField(Contract.AccountId, parentBusinessAccount.Id)
            .setField(Contract.CurrencyIsoCode, CONTRACT_CURRENCY_ISO_CODE)
            .setField(
                (DRIVE_AUTO_PROVISIONING_INDICATOR_FIELD.getSObjectField()),
                DRIVE_AUTO_ACTIVATION_NOT_SUPPORTED
            )
            .setField(Contract.Status, CONTRACT_STATUS_ACTIVATED)
            .setField(Contract.SBQQ__Opportunity__c, opportunityWithDriveNintexSubmissionId)
            .setFakeId();
        Contract contract = (Contract) contractFakeInstance.toSObject();
        Fake opportunityWithDriveNintexIdFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityWithDriveNintexSubmissionId)
            .setField(Opportunity.CloseDate, System.today().addDays(8))
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.Drive_Nintex_Id__c, OPPORTUNITY_DRIVE_NINTEX_ID)
            .setField(Opportunity.AccountId, parentBusinessAccount.Id)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_CLOSED_WON)
            .setField(Opportunity.Source__c, OPPORTUNITY_SOURCE)
            .setField(Opportunity.Nintex_Use_Case__c, NINTEX_USE_CASE_DRIVE_AMENDMENT)
            .setParent('Contract', contractFakeInstance);
        Opportunity opportunityWithDriveNintexId = (Opportunity) opportunityWithDriveNintexIdFakeInstance.toSObject();
        Fake storeAccountWithDriveNintexIdFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL
            )
            .setField(Account.Drive_Nintex_Id__c, OPPORTUNITY_DRIVE_NINTEX_ID)
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(Account.BillingCountryCode, ACCOUNT_BILLING_COUNTRY_CODE)
            .setField(Account.Data_Verification_Status__c, ACCOUNT_DATA_VERIFICATION_STATUS);
        Account storeAccountWithDriveNintexId = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountWithDriveNintexIdFakeInstance
        );
        Fake driveNintexUseCaseFakeInstance = new Fake(Nintex_Work_Order_Mapping__mdt.class)
            .setField(Nintex_Work_Order_Mapping__mdt.DeveloperName, NINTEX_MAPPING_DRIVE_AMENDMENT)
            .setField(
                Nintex_Work_Order_Mapping__mdt.Nintex_Use_Case__c,
                NINTEX_USE_CASE_DRIVE_AMENDMENT
            )
            .setField(Nintex_Work_Order_Mapping__mdt.Work_Order_Type__c, TYPE_DRIVE)
            .setFakeId();
        Nintex_Work_Order_Mapping__mdt driveNintexUseCaseToWorkOrderType = (Nintex_Work_Order_Mapping__mdt) driveNintexUseCaseFakeInstance.toSObject();
        List<Nintex_Work_Order_Mapping__mdt> nintexToWorkOrderMappings = new List<Nintex_Work_Order_Mapping__mdt>{
            driveNintexUseCaseToWorkOrderType
        };
        Opportunity_Status_PDOA_Mapping__mdt opportunityStatusToPDOAMapping = (Opportunity_Status_PDOA_Mapping__mdt) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createOpportunityStatusPDOAMappingFakeInstance(
                    FIELD_TO_REFER,
                    OBJECT_TO_REFER,
                    OPPORTUNITY_STAGE_CLOSED_WON,
                    1
                )
                .setField(Opportunity_Status_PDOA_Mapping__mdt.Compare_Values__c, false)
                .setField(
                    Opportunity_Status_PDOA_Mapping__mdt.Offset_To_Apply__c,
                    String.valueOf(3)
                )
                .setField(
                    Opportunity_Status_PDOA_Mapping__mdt.Sub_Type_To_Override__c,
                    DRIVE_WORK_ORDER_SUB_TYPE_AUTO_ACTIVATIONS
                )
                .setField(
                    Opportunity_Status_PDOA_Mapping__mdt.Override_Offset_To_Apply__c,
                    String.valueOf(0)
                )
                .setField(
                    Opportunity_Status_PDOA_Mapping__mdt.Nintex_Mapping__c,
                    driveNintexUseCaseToWorkOrderType.Id
                )
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        INintexWorkOrderMappingsSelector mockNintexWorkOrderMappings = (INintexWorkOrderMappingsSelector) mocks.mock(
            INintexWorkOrderMappingsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IOpportunityStatusPDOAMappingsSelector mockOpportunityStatusPDOAMappingsSelector = (IOpportunityStatusPDOAMappingsSelector) mocks.mock(
            IOpportunityStatusPDOAMappingsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockNintexWorkOrderMappings.getAllMappings())
            .thenReturn(nintexToWorkOrderMappings);
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByOpportunityIds(
                    new Set<Id>{ opportunityWithDriveNintexId.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                mockAccountsSelector.selectStoreAccountsByMarketplaceOrDriveNintexIds(
                    new Set<String>{ OPPORTUNITY_DRIVE_NINTEX_ID }
                )
            )
            .thenReturn(new List<Account>{ storeAccountWithDriveNintexId });
        mocks.when(
                mockOpportunityStatusPDOAMappingsSelector.selectByNintexUseCaseMappings(
                    new Set<String>{ NINTEX_MAPPING_DRIVE_AMENDMENT }
                )
            )
            .thenReturn(
                new List<Opportunity_Status_PDOA_Mapping__mdt>{ opportunityStatusToPDOAMapping }
            );
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockNintexWorkOrderMappings);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockAccountsSelector);
        Application.SELECTOR.setMock(mockOpportunityStatusPDOAMappingsSelector);
        ParentWorkOrdersCreationService.createParentWorkOrdersByNintexUseCases(
            new List<Opportunity>{ opportunityWithDriveNintexId }
        );
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());
        Boolean hasParentOrderRegisteredWithTypeDrive =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_TYPE_FIELD) == TYPE_DRIVE;
        Date proposedDateOfActivationResult = (Date) ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
            .sObjectsToInsert[0]
            .get(WORK_ORDER_PDOA_FIELD);
        DateTime dateTimeValueOfPDOA = DateTime.newInstance(
            proposedDateOfActivationResult.year(),
            proposedDateOfActivationResult.month(),
            proposedDateOfActivationResult.day()
        );
        Boolean isPDOAOnWeekend =
            dateTimeValueOfPDOA.formatGmt(DATETIME_DAY_OF_WEEK_SYMBOL) == DAY_OF_WEEK_SAT ||
            dateTimeValueOfPDOA.formatGmt(DATETIME_DAY_OF_WEEK_SYMBOL) == DAY_OF_WEEK_SUN;
        System.assertEquals(
            true,
            hasParentOrderRegisteredWithTypeDrive,
            WORK_ORDER_REGISTERED_ASSERT_MESSAGE
        );
        System.assertEquals(false, isPDOAOnWeekend, WORK_ORDER_PDOA_MISMATCH_ASSERT_MESSAGE);
    }

    /**
     * @description To test PDOA is calculated by value to apply and override offset to apply
     * from "Opportunity Status To PDOA Mappings" custom metadata when Drive - Integrated Franchise
     * with sub-type Auto-Activations and Opportunity is Closed Won.
     */
    @isTest
    private static void testWhenOpportunityDriveIntegratedFranchiseWithAutoActivationsThenPDOACalculatedByOverridenOffset() {
        Id opportunityWithDriveNintexSubmissionId = fflib_IDGenerator.generate(
            Opportunity.SObjectType
        );
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake contractFakeInstance = new Fake(Contract.class)
            .setField(Contract.AccountId, parentBusinessAccount.Id)
            .setField(Contract.CurrencyIsoCode, CONTRACT_CURRENCY_ISO_CODE)
            .setField(
                (DRIVE_AUTO_PROVISIONING_INDICATOR_FIELD.getSObjectField()),
                DRIVE_AUTO_ACTIVATION_SUPPORTED
            )
            .setField(Contract.Status, CONTRACT_STATUS_ACTIVATED)
            .setField(Contract.SBQQ__Opportunity__c, opportunityWithDriveNintexSubmissionId)
            .setFakeId();
        Contract contract = (Contract) contractFakeInstance.toSObject();
        Fake opportunityWithDriveNintexIdFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityWithDriveNintexSubmissionId)
            .setField(Opportunity.CloseDate, System.now().dateGMT())
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.Drive_Nintex_Id__c, OPPORTUNITY_DRIVE_NINTEX_ID)
            .setField(Opportunity.AccountId, parentBusinessAccount.Id)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_CLOSED_WON)
            .setField(Opportunity.Source__c, OPPORTUNITY_SOURCE)
            .setField(
                Opportunity.Nintex_Use_Case__c,
                NINTEX_USE_CASE_DRIVE_FORM_INTEGRATED_FRANCHISE
            )
            .setParent('Contract', contractFakeInstance);
        Opportunity opportunityWithDriveNintexId = (Opportunity) opportunityWithDriveNintexIdFakeInstance.toSObject();
        Fake storeAccountWithDriveNintexIdFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL
            )
            .setField(Account.Drive_Nintex_Id__c, OPPORTUNITY_DRIVE_NINTEX_ID)
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(Account.Data_Verification_Status__c, ACCOUNT_DATA_VERIFICATION_STATUS)
            .setField(Account.BillingCountryCode, ACCOUNT_BILLING_COUNTRY_CODE);
        Account storeAccountWithDriveNintexId = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountWithDriveNintexIdFakeInstance
        );
        Fake driveNintexUseCaseFakeInstance = new Fake(Nintex_Work_Order_Mapping__mdt.class)
            .setField(Nintex_Work_Order_Mapping__mdt.DeveloperName, NINTEX_MAPPING_DRIVE_AMENDMENT)
            .setField(
                Nintex_Work_Order_Mapping__mdt.Nintex_Use_Case__c,
                NINTEX_USE_CASE_DRIVE_FORM_INTEGRATED_FRANCHISE
            )
            .setField(Nintex_Work_Order_Mapping__mdt.Work_Order_Type__c, TYPE_DRIVE)
            .setFakeId();
        Nintex_Work_Order_Mapping__mdt driveNintexUseCaseToWorkOrderType = (Nintex_Work_Order_Mapping__mdt) driveNintexUseCaseFakeInstance.toSObject();
        Opportunity_Status_PDOA_Mapping__mdt opportunityStatusToPDOAMapping = (Opportunity_Status_PDOA_Mapping__mdt) ServiceMockDataBuilder.convertToSObject(
            ServiceMockDataBuilder.createOpportunityStatusPDOAMappingFakeInstance(
                    FIELD_TO_REFER,
                    OBJECT_TO_REFER,
                    OPPORTUNITY_STAGE_CLOSED_WON,
                    1
                )
                .setField(Opportunity_Status_PDOA_Mapping__mdt.Compare_Values__c, false)
                .setField(
                    Opportunity_Status_PDOA_Mapping__mdt.Offset_To_Apply__c,
                    String.valueOf(3)
                )
                .setField(
                    Opportunity_Status_PDOA_Mapping__mdt.Nintex_Mapping__c,
                    driveNintexUseCaseToWorkOrderType.Id
                )
                .setField(
                    Opportunity_Status_PDOA_Mapping__mdt.Sub_Type_To_Override__c,
                    DRIVE_WORK_ORDER_SUB_TYPE_AUTO_ACTIVATIONS
                )
                .setField(
                    Opportunity_Status_PDOA_Mapping__mdt.Override_Offset_To_Apply__c,
                    String.valueOf(0)
                )
        );
        List<Nintex_Work_Order_Mapping__mdt> nintexToWorkOrderMappings = new List<Nintex_Work_Order_Mapping__mdt>{
            driveNintexUseCaseToWorkOrderType
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        INintexWorkOrderMappingsSelector mockNintexWorkOrderMappings = (INintexWorkOrderMappingsSelector) mocks.mock(
            INintexWorkOrderMappingsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockNintexWorkOrderMappings.getAllMappings())
            .thenReturn(nintexToWorkOrderMappings);
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByOpportunityIds(
                    new Set<Id>{ opportunityWithDriveNintexId.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                mockAccountsSelector.selectStoreAccountsByMarketplaceOrDriveNintexIds(
                    new Set<String>{ OPPORTUNITY_DRIVE_NINTEX_ID }
                )
            )
            .thenReturn(new List<Account>{ storeAccountWithDriveNintexId });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockNintexWorkOrderMappings);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockAccountsSelector);
        ParentWorkOrdersCreationService.createParentWorkOrdersByNintexUseCases(
            new List<Opportunity>{ opportunityWithDriveNintexId }
        );
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());
        Boolean hasParentOrderRegisteredWithTypeDrive =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_TYPE_FIELD) == TYPE_DRIVE;
        Date proposedDateOfActivationResult = (Date) ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
            .sObjectsToInsert[0]
            .get(WORK_ORDER_PDOA_FIELD);
        System.assertEquals(
            true,
            hasParentOrderRegisteredWithTypeDrive,
            WORK_ORDER_REGISTERED_ASSERT_MESSAGE
        );
        System.assertEquals(
            opportunityWithDriveNintexId.CloseDate.addDays(
                (Integer) opportunityStatusToPDOAMapping.Override_Offset_To_Apply__c
            ),
            proposedDateOfActivationResult,
            WORK_ORDER_PDOA_MISMATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description To Test PDOA is calculated by value to apply and offset to apply
     * from "Opportunity Status To PDOA Mappings" custom metadata when COO Opportunity is
     * Closed Won and more than 5 days in future.
     */
    @isTest
    private static void testWhenOpportunityCOOClosedWonFiveDaysInFutureThenPDOACalculatedByValueOffset() {
        Date mockWorkingDay = Date.newInstance(2123, 4, 7);
        Id opportunityWithDriveNintexSubmissionId = fflib_IDGenerator.generate(
            Opportunity.SObjectType
        );
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake contractFakeInstance = new Fake(Contract.class)
            .setField(Contract.AccountId, parentBusinessAccount.Id)
            .setField(Contract.CurrencyIsoCode, CONTRACT_CURRENCY_ISO_CODE)
            .setField(
                (DRIVE_AUTO_PROVISIONING_INDICATOR_FIELD.getSObjectField()),
                DRIVE_AUTO_ACTIVATION_NOT_SUPPORTED
            )
            .setField(Contract.Status, CONTRACT_STATUS_ACTIVATED)
            .setField(Contract.SBQQ__Opportunity__c, opportunityWithDriveNintexSubmissionId)
            .setFakeId();
        Contract contract = (Contract) contractFakeInstance.toSObject();
        Fake opportunityWithDriveNintexIdFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityWithDriveNintexSubmissionId)
            .setField(Opportunity.CloseDate, mockWorkingDay.addMonths(5))
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.Drive_Nintex_Id__c, OPPORTUNITY_DRIVE_NINTEX_ID)
            .setField(Opportunity.AccountId, parentBusinessAccount.Id)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_CLOSED_WON)
            .setField(Opportunity.Source__c, OPPORTUNITY_SOURCE)
            .setField(Opportunity.Nintex_Use_Case__c, NINTEX_USE_CASE_CHANGE_OF_OWNERSHIP)
            .setParent('Contract', contractFakeInstance);
        Opportunity opportunityWithDriveNintexId = (Opportunity) opportunityWithDriveNintexIdFakeInstance.toSObject();
        Fake storeAccountWithDriveNintexIdFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL
            )
            .setField(Account.Proposed_Date_of_Activation__c, mockWorkingDay)
            .setField(Account.Change_of_Ownership_Effective_Date__c, mockWorkingDay)
            .setField(Account.Drive_Nintex_Id__c, OPPORTUNITY_DRIVE_NINTEX_ID)
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(Account.Data_Verification_Status__c, ACCOUNT_DATA_VERIFICATION_STATUS);
        Account storeAccountWithDriveNintexId = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountWithDriveNintexIdFakeInstance
        );
        Fake cooNintexUseCaseFakeInstance = new Fake(Nintex_Work_Order_Mapping__mdt.class)
            .setField(
                Nintex_Work_Order_Mapping__mdt.DeveloperName,
                NINTEX_MAPPING_CHANGE_OF_OWNERSHIP
            )
            .setField(
                Nintex_Work_Order_Mapping__mdt.Nintex_Use_Case__c,
                NINTEX_USE_CASE_CHANGE_OF_OWNERSHIP
            )
            .setField(Nintex_Work_Order_Mapping__mdt.Work_Order_Type__c, TYPE_COO)
            .setField(
                Nintex_Work_Order_Mapping__mdt.Work_Order_Provisioning_Process__c,
                PROVISIONING_PROCESS_AUTOMATIC
            )
            .setFakeId();
        Nintex_Work_Order_Mapping__mdt cooNintexUseCaseToWorkOrderType = (Nintex_Work_Order_Mapping__mdt) cooNintexUseCaseFakeInstance.toSObject();
        List<Nintex_Work_Order_Mapping__mdt> nintexToWorkOrderMappings = new List<Nintex_Work_Order_Mapping__mdt>{
            cooNintexUseCaseToWorkOrderType
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        INintexWorkOrderMappingsSelector mockNintexWorkOrderMappings = (INintexWorkOrderMappingsSelector) mocks.mock(
            INintexWorkOrderMappingsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockNintexWorkOrderMappings.getAllMappings())
            .thenReturn(nintexToWorkOrderMappings);
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByOpportunityIds(
                    new Set<Id>{ opportunityWithDriveNintexId.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                mockAccountsSelector.selectStoreAccountsByMarketplaceOrDriveNintexIds(
                    new Set<String>{ OPPORTUNITY_DRIVE_NINTEX_ID }
                )
            )
            .thenReturn(new List<Account>{ storeAccountWithDriveNintexId });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockNintexWorkOrderMappings);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockAccountsSelector);
        User mockUser = new User(
            Alias = TEST_USER_ALIAS,
            Email = TEST_USER_EMAIL_ID,
            EmailEncodingKey = USER_ENCODING,
            LastName = USER_LAST_NAME,
            LanguageLocaleKey = USER_LOCALE,
            LocaleSidKey = USER_LOCALE,
            ProfileId = UserInfo.getProfileId(),
            TimeZoneSidKey = USER_TIMEZONE,
            UserName = TEST_USER_NAME
        );
        System.runAs(mockUser) {
            ParentWorkOrdersCreationService.createParentWorkOrdersByNintexUseCases(
                new List<Opportunity>{ opportunityWithDriveNintexId }
            );
        }
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());
        WorkOrder parentWorkOrderInserted = (WorkOrder) ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
            .sObjectsToInsert[0];
        Boolean hasParentOrderRegisteredWithTypeCOO =
            parentWorkOrderInserted.get(WORK_ORDER_TYPE_FIELD) == TYPE_COO;
        Date proposedDateOfActivationResult = (Date) parentWorkOrderInserted
            .get(WORK_ORDER_PDOA_FIELD);
        DateTime dateTimeValueOfPDOA = DateTime.newInstance(
                proposedDateOfActivationResult.year(),
                proposedDateOfActivationResult.month(),
                proposedDateOfActivationResult.day()
            )
            .dateGMT();
        Boolean isPDOAOnWeekend =
            dateTimeValueOfPDOA.formatGmt(DATETIME_DAY_OF_WEEK_SYMBOL) == DAY_OF_WEEK_SAT ||
            dateTimeValueOfPDOA.formatGmt(DATETIME_DAY_OF_WEEK_SYMBOL) == DAY_OF_WEEK_SUN;
        Boolean hasProvisioningProcessFieldPopulated =
            parentWorkOrderInserted.get(PROVISIONING_PROCESS_FIELD) ==
            PROVISIONING_PROCESS_AUTOMATIC;
        System.assertEquals(
            true,
            hasParentOrderRegisteredWithTypeCOO,
            WORK_ORDER_REGISTERED_ASSERT_MESSAGE
        );
        System.assertEquals(false, isPDOAOnWeekend, WORK_ORDER_PDOA_MISMATCH_ASSERT_MESSAGE);
        System.assertEquals(
            true,
            hasProvisioningProcessFieldPopulated,
            PROVISIONING_PROCESS_VALUE_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test when Opportunity for Rate Change Nintex use-case is received then
     * parent Work Order is not created when "Franchise Amendment Process" field value on
     * Opportunity is "Opt-Out".
     */
    @isTest
    private static void testWhenRateChangeOptOutOpportunitiesReceivedThenParentWorkOrdersNotCreated() {
        Id opportunityWithMarketplaceNintexSubmissionId = fflib_IDGenerator.generate(
            Opportunity.SObjectType
        );
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake opportunityWithMarketplaceNintexIdFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityWithMarketplaceNintexSubmissionId)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.Marketplace_Nintex_Id__c, OPPORTUNITY_MARKETPLACE_NINTEX_ID)
            .setField(Opportunity.AccountId, parentBusinessAccount.Id)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_PROSPECTING)
            .setField(Opportunity.Source__c, OPPORTUNITY_SOURCE)
            .setField(Opportunity.Nintex_Use_Case__c, RATE_CHANGE)
            .setField(
                Opportunity.FranchiseAmendmentProcess__c,
                OPPORTUNITY_FRANCHISE_AMENDMENT_PROCESS_OPT_OUT
            );
        Opportunity opportunityWithMarketplaceNintexId = (Opportunity) opportunityWithMarketplaceNintexIdFakeInstance.toSObject();
        Fake contractFakeInstance = new Fake(Contract.class)
            .setField(Contract.AccountId, parentBusinessAccount.Id)
            .setField(Contract.CurrencyIsoCode, CONTRACT_CURRENCY_ISO_CODE)
            .setField(
                (DRIVE_AUTO_PROVISIONING_INDICATOR_FIELD.getSObjectField()),
                DRIVE_AUTO_ACTIVATION_NOT_SUPPORTED
            )
            .setField(Contract.Status, CONTRACT_STATUS_ACTIVATED)
            .setField(Contract.SBQQ__Opportunity__c, opportunityWithMarketplaceNintexSubmissionId)
            .setFakeId();
        Contract contract = (Contract) contractFakeInstance.toSObject();
        Fake parentWorkOrderInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentBusinessAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today() + 40)
            .setField(WorkOrder.Opportunity__c, opportunityWithMarketplaceNintexId.Id)
            .setParent('Account', parentBusinessAccountFakeInstance)
            .setParent('Opportunity__r', opportunityWithMarketplaceNintexIdFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderInstance
        );
        Fake storeAccountWithMarketplaceNintexIdFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL
            )
            .setField(Account.Marketplace_Nintex_Id__c, OPPORTUNITY_MARKETPLACE_NINTEX_ID)
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(Account.Data_Verification_Status__c, ACCOUNT_DATA_VERIFICATION_STATUS);
        Account storeAccountWithMarketplaceNintexId = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountWithMarketplaceNintexIdFakeInstance
        );
        Fake postSalesNintexUseCaseFakeInstance = new Fake(Nintex_Work_Order_Mapping__mdt.class)
            .setField(Nintex_Work_Order_Mapping__mdt.Nintex_Use_Case__c, RATE_CHANGE)
            .setField(Nintex_Work_Order_Mapping__mdt.Work_Order_Type__c, TYPE_POST_SALES)
            .setField(Nintex_Work_Order_Mapping__mdt.Work_Order_Sub_Type__c, RATE_CHANGE)
            .setFakeId();
        Nintex_Work_Order_Mapping__mdt marketplaceNintexUseCase = (Nintex_Work_Order_Mapping__mdt) postSalesNintexUseCaseFakeInstance.toSObject();
        List<Nintex_Work_Order_Mapping__mdt> nintexToWorkOrderMappings = new List<Nintex_Work_Order_Mapping__mdt>{
            marketplaceNintexUseCase
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        INintexWorkOrderMappingsSelector mockNintexWorkOrderMappings = (INintexWorkOrderMappingsSelector) mocks.mock(
            INintexWorkOrderMappingsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockNintexWorkOrderMappings.getAllMappings())
            .thenReturn(nintexToWorkOrderMappings);
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByOpportunityIds(
                    new Set<Id>{ opportunityWithMarketplaceNintexId.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                mockAccountsSelector.selectStoreAccountsByMarketplaceOrDriveNintexIds(
                    new Set<String>{ OPPORTUNITY_MARKETPLACE_NINTEX_ID }
                )
            )
            .thenReturn(new List<Account>{ storeAccountWithMarketplaceNintexId });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockNintexWorkOrderMappings);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockAccountsSelector);
        ParentWorkOrdersCreationService.createParentWorkOrdersByNintexUseCases(
            new List<Opportunity>{ opportunityWithMarketplaceNintexId }
        );
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());
        List<SObject> sObjectsToInsert = ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
            .sObjectsToInsert;
        System.assertEquals(
            true,
            sObjectsToInsert.isEmpty(),
            WORK_ORDER_NOT_REGISTERED_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test when Opportunity for Rate Change Nintex use-case is received then
     * parent Work Order is created when "Franchise Amendment Process" field value on
     * Opportunity is "Opt-In".
     */
    @isTest
    private static void testWhenRateChangeOptInOpportunitiesReceivedThenParentWorkOrdersCreated() {
        Id opportunityWithMarketplaceNintexSubmissionId = fflib_IDGenerator.generate(
            Opportunity.SObjectType
        );
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake contractFakeInstance = new Fake(Contract.class)
            .setField(Contract.AccountId, parentBusinessAccount.Id)
            .setField(Contract.CurrencyIsoCode, CONTRACT_CURRENCY_ISO_CODE)
            .setField(
                (DRIVE_AUTO_PROVISIONING_INDICATOR_FIELD.getSObjectField()),
                DRIVE_AUTO_ACTIVATION_NOT_SUPPORTED
            )
            .setField(Contract.Payment_Method__c, WITHHOLDING)
            .setField(Contract.Status, CONTRACT_STATUS_ACTIVATED)
            .setField(Contract.SBQQ__Opportunity__c, opportunityWithMarketplaceNintexSubmissionId)
            .setFakeId();
        Contract contract = (Contract) contractFakeInstance.toSObject();
        Fake opportunityWithMarketplaceNintexIdFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityWithMarketplaceNintexSubmissionId)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.Marketplace_Nintex_Id__c, OPPORTUNITY_MARKETPLACE_NINTEX_ID)
            .setField(Opportunity.AccountId, parentBusinessAccount.Id)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_PROSPECTING)
            .setField(Opportunity.Source__c, OPPORTUNITY_SOURCE)
            .setField(Opportunity.Nintex_Use_Case__c, RATE_CHANGE)
            .setField(
                Opportunity.FranchiseAmendmentProcess__c,
                OPPORTUNITY_FRANCHISE_AMENDMENT_PROCESS_OPT_IN
            )
            .setParent('Contract', contractFakeInstance);
        Opportunity opportunityWithMarketplaceNintexId = (Opportunity) opportunityWithMarketplaceNintexIdFakeInstance.toSObject();
        Fake parentWorkOrderInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentBusinessAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today() + 40)
            .setField(WorkOrder.Opportunity__c, opportunityWithMarketplaceNintexId.Id)
            .setParent('Account', parentBusinessAccountFakeInstance)
            .setParent('Opportunity__r', opportunityWithMarketplaceNintexIdFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderInstance
        );
        Fake postSalesNintexUseCaseFakeInstance = new Fake(Nintex_Work_Order_Mapping__mdt.class)
            .setField(Nintex_Work_Order_Mapping__mdt.Nintex_Use_Case__c, RATE_CHANGE)
            .setField(Nintex_Work_Order_Mapping__mdt.Work_Order_Type__c, TYPE_POST_SALES)
            .setField(Nintex_Work_Order_Mapping__mdt.Work_Order_Sub_Type__c, RATE_CHANGE)
            .setFakeId();
        Nintex_Work_Order_Mapping__mdt marketplaceNintexUseCase = (Nintex_Work_Order_Mapping__mdt) postSalesNintexUseCaseFakeInstance.toSObject();
        List<Nintex_Work_Order_Mapping__mdt> nintexToWorkOrderMappings = new List<Nintex_Work_Order_Mapping__mdt>{
            marketplaceNintexUseCase
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        INintexWorkOrderMappingsSelector mockNintexWorkOrderMappings = (INintexWorkOrderMappingsSelector) mocks.mock(
            INintexWorkOrderMappingsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockNintexWorkOrderMappings.getAllMappings())
            .thenReturn(nintexToWorkOrderMappings);
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByOpportunityIds(
                    new Set<Id>{ opportunityWithMarketplaceNintexId.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                mockAccountsSelector.selectStoreAccountsByMarketplaceOrDriveNintexIds(
                    new Set<String>{ OPPORTUNITY_MARKETPLACE_NINTEX_ID }
                )
            )
            .thenReturn(new List<Account>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockNintexWorkOrderMappings);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockAccountsSelector);
        ParentWorkOrdersCreationService.createParentWorkOrdersByNintexUseCases(
            new List<Opportunity>{ opportunityWithMarketplaceNintexId }
        );
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());
        Boolean hasParentOrderRegistered =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_ACCOUNT_ID_FIELD) == opportunityWithMarketplaceNintexId.AccountId;
        System.assertEquals(true, hasParentOrderRegistered, WORK_ORDER_REGISTERED_ASSERT_MESSAGE);
    }

    /**
     * @description To test parent Work Order creation with Sub-Type = "Net-new business"
     * and Provisioning Process = "Automatic" when Type = "Drive" and
     * Drive auto provisioning indicator on Contract is "No".
     */
    @isTest
    private static void testWhenDriveAutoActivationNotSupportedOnContractThenParentWorkOrderWithSubTypeNetNewBusinessCreated() {
        Id opportunityWithDriveNintexSubmissionId = fflib_IDGenerator.generate(
            Opportunity.SObjectType
        );
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake contractFakeInstance = new Fake(Contract.class)
            .setField(Contract.AccountId, parentBusinessAccount.Id)
            .setField(Contract.CurrencyIsoCode, CONTRACT_CURRENCY_ISO_CODE)
            .setField(
                (DRIVE_AUTO_PROVISIONING_INDICATOR_FIELD.getSObjectField()),
                DRIVE_AUTO_ACTIVATION_NOT_SUPPORTED
            )
            .setField(Contract.Status, CONTRACT_STATUS_ACTIVATED)
            .setField(Contract.SBQQ__Opportunity__c, opportunityWithDriveNintexSubmissionId)
            .setFakeId();
        Contract contract = (Contract) contractFakeInstance.toSObject();
        Fake opportunityWithDriveNintexIdFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityWithDriveNintexSubmissionId)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.Drive_Nintex_Id__c, OPPORTUNITY_DRIVE_NINTEX_ID)
            .setField(Opportunity.AccountId, parentBusinessAccount.Id)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_PROSPECTING)
            .setField(Opportunity.Source__c, OPPORTUNITY_SOURCE)
            .setField(
                Opportunity.Nintex_Use_Case__c,
                NINTEX_USE_CASE_DRIVE_FORM_INTEGRATED_FRANCHISE
            )
            .setParent('Contract', contractFakeInstance);
        Opportunity opportunityWithDriveNintexId = (Opportunity) opportunityWithDriveNintexIdFakeInstance.toSObject();
        Fake storeAccountWithDriveNintexIdFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL
            )
            .setField(Account.Drive_Nintex_Id__c, OPPORTUNITY_DRIVE_NINTEX_ID)
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(Account.Data_Verification_Status__c, ACCOUNT_DATA_VERIFICATION_STATUS);
        Account storeAccountWithDriveNintexId = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountWithDriveNintexIdFakeInstance
        );
        Fake driveNintexUseCaseFakeInstance = new Fake(Nintex_Work_Order_Mapping__mdt.class)
            .setField(
                Nintex_Work_Order_Mapping__mdt.Nintex_Use_Case__c,
                NINTEX_USE_CASE_DRIVE_FORM_INTEGRATED_FRANCHISE
            )
            .setField(Nintex_Work_Order_Mapping__mdt.Work_Order_Type__c, TYPE_DRIVE)
            .setField(
                Nintex_Work_Order_Mapping__mdt.Work_Order_Sub_Type__c,
                WORK_ORDER_SUB_TYPE_NET_NEW_BUSINESS
            )
            .setField(
                Nintex_Work_Order_Mapping__mdt.Work_Order_Provisioning_Process__c,
                PROVISIONING_PROCESS_AUTOMATIC
            )
            .setFakeId();
        Nintex_Work_Order_Mapping__mdt driveNintexUseCaseToWorkOrderType = (Nintex_Work_Order_Mapping__mdt) driveNintexUseCaseFakeInstance.toSObject();
        List<Nintex_Work_Order_Mapping__mdt> nintexToWorkOrderMappings = new List<Nintex_Work_Order_Mapping__mdt>{
            driveNintexUseCaseToWorkOrderType
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        INintexWorkOrderMappingsSelector mockNintexWorkOrderMappings = (INintexWorkOrderMappingsSelector) mocks.mock(
            INintexWorkOrderMappingsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockNintexWorkOrderMappings.getAllMappings())
            .thenReturn(nintexToWorkOrderMappings);
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByOpportunityIds(
                    new Set<Id>{ opportunityWithDriveNintexId.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                mockAccountsSelector.selectStoreAccountsByMarketplaceOrDriveNintexIds(
                    new Set<String>{ OPPORTUNITY_DRIVE_NINTEX_ID }
                )
            )
            .thenReturn(new List<Account>{ storeAccountWithDriveNintexId });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockNintexWorkOrderMappings);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockAccountsSelector);
        ParentWorkOrdersCreationService.createParentWorkOrdersByNintexUseCases(
            new List<Opportunity>{ opportunityWithDriveNintexId }
        );
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());
        Boolean hasParentOrderRegisteredWithSubTypeNetNewBusiness =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_SUB_TYPE_FIELD) == WORK_ORDER_SUB_TYPE_NET_NEW_BUSINESS;
        System.assertEquals(
            true,
            hasParentOrderRegisteredWithSubTypeNetNewBusiness,
            WORK_ORDER_REGISTERED_ASSERT_MESSAGE
        );
        Boolean hasProvisioningProcessFieldPopulated =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(PROVISIONING_PROCESS_FIELD) == PROVISIONING_PROCESS_AUTOMATIC;
        System.assertEquals(
            true,
            hasProvisioningProcessFieldPopulated,
            PROVISIONING_PROCESS_VALUE_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test when Opportunity for Integrated Franchise Nintex use-case
     * having Drive Auto Activations supported on Contract is received then
     * parent Work Order is created having Sub Type field value as Auto-activations and
     * Withholding with Auto activations field value as true.
     */
    @isTest
    private static void testWhenIntegratedFranchiseOpportunitiesReceivedWithDriveAutoActivationsSupportedThenParentWorkOrdersCreatedHavingWithholdingWithAutoActivationsAsTrue() {
        Id opportunityWithMarketplaceNintexSubmissionId = fflib_IDGenerator.generate(
            Opportunity.SObjectType
        );
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake contractFakeInstance = new Fake(Contract.class)
            .setField(Contract.AccountId, parentBusinessAccount.Id)
            .setField(Contract.CurrencyIsoCode, CONTRACT_CURRENCY_ISO_CODE)
            .setField(
                (DRIVE_AUTO_PROVISIONING_INDICATOR_FIELD.getSObjectField()),
                DRIVE_AUTO_ACTIVATION_SUPPORTED
            )
            .setField(Contract.Payment_Method__c, WITHHOLDING)
            .setField(Contract.Status, CONTRACT_STATUS_ACTIVATED)
            .setField(Contract.SBQQ__Opportunity__c, opportunityWithMarketplaceNintexSubmissionId)
            .setFakeId();
        Contract contract = (Contract) contractFakeInstance.toSObject();
        Fake opportunityWithMarketplaceNintexIdFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityWithMarketplaceNintexSubmissionId)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.Marketplace_Nintex_Id__c, OPPORTUNITY_MARKETPLACE_NINTEX_ID)
            .setField(Opportunity.AccountId, parentBusinessAccount.Id)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_PROSPECTING)
            .setField(Opportunity.Source__c, OPPORTUNITY_SOURCE)
            .setField(
                Opportunity.Nintex_Use_Case__c,
                NINTEX_USE_CASE_DRIVE_FORM_INTEGRATED_FRANCHISE
            )
            .setField(
                Opportunity.FranchiseAmendmentProcess__c,
                OPPORTUNITY_FRANCHISE_AMENDMENT_PROCESS_OPT_IN
            )
            .setParent('Contract', contractFakeInstance);
        Opportunity opportunityWithMarketplaceNintexId = (Opportunity) opportunityWithMarketplaceNintexIdFakeInstance.toSObject();
        Fake parentWorkOrderInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentBusinessAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today() + 40)
            .setField(WorkOrder.Opportunity__c, opportunityWithMarketplaceNintexId.Id)
            .setParent('Account', parentBusinessAccountFakeInstance)
            .setParent('Opportunity__r', opportunityWithMarketplaceNintexIdFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderInstance
        );
        Fake postSalesNintexUseCaseFakeInstance = new Fake(Nintex_Work_Order_Mapping__mdt.class)
            .setField(
                Nintex_Work_Order_Mapping__mdt.Nintex_Use_Case__c,
                NINTEX_USE_CASE_DRIVE_FORM_INTEGRATED_FRANCHISE
            )
            .setField(Nintex_Work_Order_Mapping__mdt.Work_Order_Type__c, TYPE_DRIVE)
            .setField(Nintex_Work_Order_Mapping__mdt.Work_Order_Sub_Type__c, WORK_ORDER_SUB_TYPE)
            .setField(
                Nintex_Work_Order_Mapping__mdt.Work_Order_Provisioning_Process__c,
                PROVISIONING_PROCESS_AUTOMATIC
            )
            .setFakeId();
        Nintex_Work_Order_Mapping__mdt marketplaceNintexUseCase = (Nintex_Work_Order_Mapping__mdt) postSalesNintexUseCaseFakeInstance.toSObject();
        List<Nintex_Work_Order_Mapping__mdt> nintexToWorkOrderMappings = new List<Nintex_Work_Order_Mapping__mdt>{
            marketplaceNintexUseCase
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        INintexWorkOrderMappingsSelector mockNintexWorkOrderMappings = (INintexWorkOrderMappingsSelector) mocks.mock(
            INintexWorkOrderMappingsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockNintexWorkOrderMappings.getAllMappings())
            .thenReturn(nintexToWorkOrderMappings);
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByOpportunityIds(
                    new Set<Id>{ opportunityWithMarketplaceNintexId.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                mockAccountsSelector.selectStoreAccountsByMarketplaceOrDriveNintexIds(
                    new Set<String>{ OPPORTUNITY_MARKETPLACE_NINTEX_ID }
                )
            )
            .thenReturn(new List<Account>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockNintexWorkOrderMappings);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockAccountsSelector);
        ParentWorkOrdersCreationService.createParentWorkOrdersByNintexUseCases(
            new List<Opportunity>{ opportunityWithMarketplaceNintexId }
        );
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());
        WorkOrder parentWorkOrderInserted = (WorkOrder) ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
            .sObjectsToInsert[0];
        Boolean hasParentOrderRegistered =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_ACCOUNT_ID_FIELD) == opportunityWithMarketplaceNintexId.AccountId;
        System.assertEquals(true, hasParentOrderRegistered, WORK_ORDER_REGISTERED_ASSERT_MESSAGE);
        System.assertEquals(
            true,
            parentWorkOrderInserted.Withholding_with_Auto_Activations__c,
            WORK_ORDER_WITHHOLDING_WITH_AUTO_ACTIVATIONS_MISMATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            WORK_ORDER_SUB_TYPE_AUTO_ACTIVATIONS,
            parentWorkOrderInserted.Sub_Type__c,
            WORK_ORDER_SUB_TYPE_MISMATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test when Opportunity for Integrated Franchise Nintex use-case
     * having Drive Auto Activations not supported on Contract is received then
     * parent Work Order is created having Sub Type field value as Withholding and
     * Withholding with Auto activations field value as false.
     */
    @isTest
    private static void testWhenIntegratedFranchiseOpportunitiesReceivedWithDriveAutoActivationsNotSupportedThenWithholdingParentWorkOrdersCreatedHavingWithholdingWithAutoActivationsAsFalse() {
        Id opportunityWithMarketplaceNintexSubmissionId = fflib_IDGenerator.generate(
            Opportunity.SObjectType
        );
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake contractFakeInstance = new Fake(Contract.class)
            .setField(Contract.AccountId, parentBusinessAccount.Id)
            .setField(Contract.CurrencyIsoCode, CONTRACT_CURRENCY_ISO_CODE)
            .setField(
                (DRIVE_AUTO_PROVISIONING_INDICATOR_FIELD.getSObjectField()),
                DRIVE_AUTO_ACTIVATION_NOT_SUPPORTED
            )
            .setField(Contract.Payment_Method__c, WITHHOLDING)
            .setField(Contract.Status, CONTRACT_STATUS_ACTIVATED)
            .setField(Contract.SBQQ__Opportunity__c, opportunityWithMarketplaceNintexSubmissionId)
            .setFakeId();
        Contract contract = (Contract) contractFakeInstance.toSObject();
        Fake opportunityWithMarketplaceNintexIdFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityWithMarketplaceNintexSubmissionId)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.Marketplace_Nintex_Id__c, OPPORTUNITY_MARKETPLACE_NINTEX_ID)
            .setField(Opportunity.AccountId, parentBusinessAccount.Id)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_PROSPECTING)
            .setField(Opportunity.Source__c, OPPORTUNITY_SOURCE)
            .setField(
                Opportunity.Nintex_Use_Case__c,
                NINTEX_USE_CASE_DRIVE_FORM_INTEGRATED_FRANCHISE
            )
            .setField(
                Opportunity.FranchiseAmendmentProcess__c,
                OPPORTUNITY_FRANCHISE_AMENDMENT_PROCESS_OPT_IN
            )
            .setParent('Contract', contractFakeInstance);
        Opportunity opportunityWithMarketplaceNintexId = (Opportunity) opportunityWithMarketplaceNintexIdFakeInstance.toSObject();
        Fake parentWorkOrderInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentBusinessAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today() + 40)
            .setField(WorkOrder.Opportunity__c, opportunityWithMarketplaceNintexId.Id)
            .setParent('Account', parentBusinessAccountFakeInstance)
            .setParent('Opportunity__r', opportunityWithMarketplaceNintexIdFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderInstance
        );
        Fake postSalesNintexUseCaseFakeInstance = new Fake(Nintex_Work_Order_Mapping__mdt.class)
            .setField(
                Nintex_Work_Order_Mapping__mdt.Nintex_Use_Case__c,
                NINTEX_USE_CASE_DRIVE_FORM_INTEGRATED_FRANCHISE
            )
            .setField(Nintex_Work_Order_Mapping__mdt.Work_Order_Type__c, TYPE_DRIVE)
            .setField(Nintex_Work_Order_Mapping__mdt.Work_Order_Sub_Type__c, WORK_ORDER_SUB_TYPE)
            .setFakeId();
        Nintex_Work_Order_Mapping__mdt marketplaceNintexUseCase = (Nintex_Work_Order_Mapping__mdt) postSalesNintexUseCaseFakeInstance.toSObject();
        List<Nintex_Work_Order_Mapping__mdt> nintexToWorkOrderMappings = new List<Nintex_Work_Order_Mapping__mdt>{
            marketplaceNintexUseCase
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        INintexWorkOrderMappingsSelector mockNintexWorkOrderMappings = (INintexWorkOrderMappingsSelector) mocks.mock(
            INintexWorkOrderMappingsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockNintexWorkOrderMappings.getAllMappings())
            .thenReturn(nintexToWorkOrderMappings);
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByOpportunityIds(
                    new Set<Id>{ opportunityWithMarketplaceNintexId.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                mockAccountsSelector.selectStoreAccountsByMarketplaceOrDriveNintexIds(
                    new Set<String>{ OPPORTUNITY_MARKETPLACE_NINTEX_ID }
                )
            )
            .thenReturn(new List<Account>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockNintexWorkOrderMappings);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockAccountsSelector);
        ParentWorkOrdersCreationService.createParentWorkOrdersByNintexUseCases(
            new List<Opportunity>{ opportunityWithMarketplaceNintexId }
        );
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());
        WorkOrder parentWorkOrderInserted = (WorkOrder) ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
            .sObjectsToInsert[0];
        Boolean hasParentOrderRegistered =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_ACCOUNT_ID_FIELD) == opportunityWithMarketplaceNintexId.AccountId;
        System.assertEquals(true, hasParentOrderRegistered, WORK_ORDER_REGISTERED_ASSERT_MESSAGE);
        System.assertEquals(
            false,
            parentWorkOrderInserted.Withholding_with_Auto_Activations__c,
            WORK_ORDER_WITHHOLDING_WITH_AUTO_ACTIVATIONS_MISMATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            WITHHOLDING,
            parentWorkOrderInserted.Sub_Type__c,
            WORK_ORDER_SUB_TYPE_MISMATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test the creation of parent Work Order when Interface Transaction
     * records are passed.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenInterfaceTransactionsArePassedThenCreateParentWorkOrder() {
        Id userId = fflib_IDGenerator.generate(User.SObjectType);
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SobjectType);
        Id mxOnboardingLinkId = fflib_IDGenerator.generate(Mx_Onboarding_Link__c.SObjectType);
        WorkOrderGenerationWrapper workOrderGenerationWrapper = new WorkOrderGenerationWrapper();
        workOrderGenerationWrapper.setType(TYPE_STOREFRONT);
        workOrderGenerationWrapper.setSubType(NET_NEW_SUB_TYPE);
        workOrderGenerationWrapper.setStatus(CONFIRMED_STATUS);
        workOrderGenerationWrapper.setAccountId(accountId);
        workOrderGenerationWrapper.setOpportunityId(opportunityId);
        workOrderGenerationWrapper.setMxOnboardingLinkId(mxOnboardingLinkId);
        workOrderGenerationWrapper.setContractId(contractId);
        workOrderGenerationWrapper.setProposedDateOfActivation(System.today());
        workOrderGenerationWrapper.setCreationSource(SSMO_CREATION_SOURCE);
        workOrderGenerationWrapper.setUniqueIdentifier(UNIQUE_IDENTIFIER);
        workOrderGenerationWrapper.setProvisioningProcess(PROVISIONING_PROCESS_MANUAL);
        workOrderGenerationWrapper.setProvisioningStatus(READINESS_CHECK_COMPLETE);
        workOrderGenerationWrapper.setOrderProtocol(POS_ORDER_PROTOCOL);
        workOrderGenerationWrapper.setStoreAccountIds('');
        workOrderGenerationWrapper.setActivatedCentrally('');
        workOrderGenerationWrapper.setMenuToBeCompletedBy('');
        workOrderGenerationWrapper.setWorkOrderSource(SSMO_CREATION_SOURCE);
        workOrderGenerationWrapper.setPhotoShootRequest(PHOTOSHOOT_REQUESTED_YES);
        workOrderGenerationWrapper.setMenuSetUpMethod(MENU_SETUP_METHOD_NONE);
        workOrderGenerationWrapper.setSalesNotesForMenuTeam('');
        workOrderGenerationWrapper.setPhotoShootDate(System.today());
        workOrderGenerationWrapper.setPhotoShootTime(null);
        workOrderGenerationWrapper.setBundledWithMarketplace(BUNDLED_WITH_MARKETPLACE_NO);
        workOrderGenerationWrapper.setSalesRepName(userId);

        WorkOrder workOrderInstance = new WorkOrder(
            Type__c = TYPE_STOREFRONT,
            Sub_Type__c = NET_NEW_SUB_TYPE,
            Status = CONFIRMED_STATUS,
            AccountId = accountId,
            Opportunity__c = opportunityId,
            Mx_Onboarding_Link__c = mxOnboardingLinkId,
            Business_Id__c = '',
            Contract__c = contractId,
            Proposed_Date_of_Activation__c = System.today(),
            HasWorkPlansGenerated__c = false,
            Integration_Request_Id__c = '',
            POS_Integration_Type__c = '',
            Proposed_Date_of_Implementation__c = null,
            Creation_Source__c = SSMO_CREATION_SOURCE,
            Unique_Identifier__c = UNIQUE_IDENTIFIER,
            Business_to_Store_Assignment__c = PROVISIONING_PROCESS_MANUAL,
            Provisioning_Status__c = READINESS_CHECK_COMPLETE,
            Order_Protocol__c = 'POS',
            Associated_Account_Ids__c = '',
            Activated_Centrally_AC__c = '',
            Menu_to_be_Completed_By__c = '',
            Work_Order_Source__c = SSMO_CREATION_SOURCE,
            Mx_Requested_Photoshoot__c = PHOTOSHOOT_REQUESTED_YES,
            Menu_Setup_Method__c = MENU_SETUP_METHOD_NONE,
            Sales_Notes_for_Menu_Team__c = '',
            Photoshoot_Date__c = System.today(),
            Photoshoot_Time__c = null,
            Bundled_with_Marketplace__c = BUNDLED_WITH_MARKETPLACE_NO,
            Sales_Rep_Name__c = userId
        );

        Interface_Transaction__c interfaceTransaction = new Interface_Transaction__c(
            Payload__c = JSON.serialize(workOrderGenerationWrapper),
            Remaining_Retry_Attempts__c = 3,
            Interface_Transaction_Configuration_Name__c = INTERFACE_TRANSACTION_CONFIGURATION_NAME_WORK_ORDER_PAYLOAD_INBOUND_INTEGRATION
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        ParentWorkOrdersCreationService.createParentWorkOrder(
            new List<Interface_Transaction__c>{ interfaceTransaction }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW)).registerNew(workOrderInstance);
    }

    /**
     * @description To test parent Work Order is created when
     * Opportunities with Nintex Id are received.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts,PMD.UnusedLocalVariable')
    private static void testWhenRateChangeRequestUpdatedThenParentWorkOrdersCreated() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                ACCOUNT_PRIMARY_VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Id, businessAccountId)
            .setField(Account.Activated_Centrally_AC__c, true)
            .setField(Account.Menu_Setup_Method__c, MENU_SETUP_METHOD_NONE)
            .setField(Account.Menu_to_be_Completed_By__c, MENU_COMPLETED_BY_NONE)
            .setField(Account.Order_Protocol__c, 'POS');
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
    }

    /**
     * @description To test parent Work Order is created when
     * Opportunities with Nintex Id are received.
     */
    @isTest
    private static void testWhenOpportunitiesReceivedThenParentWorkOrdersCreatedBySMBOpportunityNintexUseCase() {
        Id opportunityWithMarketplaceNintexSubmissionId = fflib_IDGenerator.generate(
            Opportunity.SObjectType
        );

        Fake parentBusinessAccountFakeInstance = new Fake(Account.class)
            .setField(Account.Account_Lifecycle_Status__c, ACCOUNT_LIFECYCLE_STATUS)
            .setField(Account.BillingCity, ACCOUNT_BILLING_CITY)
            .setField(Account.BillingCountry, ACCOUNT_BILLING_COUNTRY)
            .setField(Account.BillingCountryCode, ACCOUNT_BILLING_COUNTRY_CODE)
            .setField(Account.BillingPostalCode, ACCOUNT_BILLING_POSTALCODE)
            .setField(Account.BillingState, ACCOUNT_BILLING_STATE)
            .setField(Account.BillingStreet, ACCOUNT_BILLING_STREET)
            .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
            .setField(Account.Partnership_Status__c, ACCOUNT_PARTNERSHIP_STATUS)
            .setField(Account.Primary_Vertical__c, ACCOUNT_PRIMARY_VERTICAL)
            .setField(Account.RecordTypeId, ACCOUNT_BUSINESS_RECORD_TYPE_ID)
            .setField(Account.Type, ACCOUNT_TYPE)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setFakeId()
            .setParent(
                'RecordType',
                new Fake(RecordType.class)
                    .setField(RecordType.DeveloperName, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
                    .setField(RecordType.Id, ACCOUNT_BUSINESS_RECORD_TYPE_ID)
                    .setField(RecordType.Name, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            );
        Account parentBusinessAccount = (Account) parentBusinessAccountFakeInstance.toSObject();
        Fake contractFakeInstance = new Fake(Contract.class)
            .setField(Contract.AccountId, parentBusinessAccount.Id)
            .setField(Contract.CurrencyIsoCode, CONTRACT_CURRENCY_ISO_CODE)
            .setField(
                (DRIVE_AUTO_PROVISIONING_INDICATOR_FIELD.getSObjectField()),
                DRIVE_AUTO_ACTIVATION_SUPPORTED
            )
            .setField(Contract.Payment_Method__c, WITHHOLDING)
            .setField(Contract.Status, CONTRACT_STATUS_ACTIVATED)
            .setField(Contract.SBQQ__Opportunity__c, opportunityWithMarketplaceNintexSubmissionId)
            .setFakeId();
        Contract contract = (Contract) contractFakeInstance.toSObject();
        Fake opportunityWithMarketplaceNintexIdFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityWithMarketplaceNintexSubmissionId)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.Marketplace_Nintex_Id__c, OPPORTUNITY_MARKETPLACE_NINTEX_ID)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_CLOSED_WON)
            .setField(Opportunity.Source__c, OPPORTUNITY_SOURCE)
            .setField(Opportunity.Nintex_Use_Case__c, NINTEX_USE_CASE_MIDDLEWARE_PROVIDER)
            .setField(
                Opportunity.FranchiseAmendmentProcess__c,
                OPPORTUNITY_FRANCHISE_AMENDMENT_PROCESS_OPT_IN
            )
            .setParent('Contract', contractFakeInstance)
            .setParent('Account', parentBusinessAccountFakeInstance);
        Opportunity opportunityWithMarketplaceNintexId = (Opportunity) opportunityWithMarketplaceNintexIdFakeInstance.toSObject();
        Fake parentWorkOrderInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentBusinessAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today() + 40)
            .setField(WorkOrder.Opportunity__c, opportunityWithMarketplaceNintexId.Id)
            .setParent('Account', parentBusinessAccountFakeInstance)
            .setParent('Opportunity__r', opportunityWithMarketplaceNintexIdFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderInstance
        );
        Fake postSalesNintexUseCaseFakeInstance = new Fake(Nintex_Work_Order_Mapping__mdt.class)
            .setField(
                Nintex_Work_Order_Mapping__mdt.Nintex_Use_Case__c,
                NINTEX_USE_CASE_MIDDLEWARE_PROVIDER
            )
            .setField(Nintex_Work_Order_Mapping__mdt.Work_Order_Type__c, TYPE_DRIVE)
            .setField(Nintex_Work_Order_Mapping__mdt.Work_Order_Sub_Type__c, WORK_ORDER_SUB_TYPE)
            .setField(
                Nintex_Work_Order_Mapping__mdt.Work_Order_Provisioning_Process__c,
                PROVISIONING_PROCESS_AUTOMATIC
            )
            .setFakeId();
        Nintex_Work_Order_Mapping__mdt marketplaceNintexUseCase = (Nintex_Work_Order_Mapping__mdt) postSalesNintexUseCaseFakeInstance.toSObject();
        List<Nintex_Work_Order_Mapping__mdt> nintexToWorkOrderMappings = new List<Nintex_Work_Order_Mapping__mdt>{
            marketplaceNintexUseCase
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        INintexWorkOrderMappingsSelector mockNintexWorkOrderMappings = (INintexWorkOrderMappingsSelector) mocks.mock(
            INintexWorkOrderMappingsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockNintexWorkOrderMappings.getAllMappings())
            .thenReturn(nintexToWorkOrderMappings);
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByOpportunityIds(
                    new Set<Id>{ opportunityWithMarketplaceNintexId.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                mockAccountsSelector.selectStoreAccountsByMarketplaceOrDriveNintexIds(
                    new Set<String>{ OPPORTUNITY_MARKETPLACE_NINTEX_ID }
                )
            )
            .thenReturn(new List<Account>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockNintexWorkOrderMappings);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockAccountsSelector);
        Test.startTest();
        ParentWorkOrdersCreationService.createParentWorkOrdersByNintexUseCases(
            new List<Opportunity>{ opportunityWithMarketplaceNintexId }
        );
        Test.stopTest();
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());
        WorkOrder parentWorkOrderInserted = (WorkOrder) ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
            .sObjectsToInsert[0];
        Boolean hasParentOrderRegistered =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_ACCOUNT_ID_FIELD) == opportunityWithMarketplaceNintexId.AccountId;
        System.assertEquals(true, hasParentOrderRegistered, WORK_ORDER_REGISTERED_ASSERT_MESSAGE);
        System.assertEquals(
            false,
            parentWorkOrderInserted.Withholding_with_Auto_Activations__c,
            WORK_ORDER_WITHHOLDING_WITH_AUTO_ACTIVATIONS_MISMATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            WORK_ORDER_SUB_TYPE_AUTO_ACTIVATIONS,
            parentWorkOrderInserted.Sub_Type__c,
            WORK_ORDER_SUB_TYPE_MISMATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test parent Work Order is created when
     * Opportunities with Nintex Id are received.
     */
    @isTest
    private static void testWhenOpportunitiesReceivedThenParentWorkOrdersShouldNotBeCreatedBySMBOpportunityNintexUseCaseSSMO() {
        Id opportunityWithMarketplaceNintexSubmissionId = fflib_IDGenerator.generate(
            Opportunity.SObjectType
        );

        Fake parentBusinessAccountFakeInstance = new Fake(Account.class)
            .setField(Account.Account_Lifecycle_Status__c, ACCOUNT_LIFECYCLE_STATUS)
            .setField(Account.BillingCity, ACCOUNT_BILLING_CITY)
            .setField(Account.BillingCountry, ACCOUNT_BILLING_COUNTRY)
            .setField(Account.BillingCountryCode, ACCOUNT_BILLING_COUNTRY_CODE)
            .setField(Account.BillingPostalCode, ACCOUNT_BILLING_POSTALCODE)
            .setField(Account.BillingState, ACCOUNT_BILLING_STATE)
            .setField(Account.BillingStreet, ACCOUNT_BILLING_STREET)
            .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
            .setField(Account.Partnership_Status__c, ACCOUNT_PARTNERSHIP_STATUS)
            .setField(Account.Primary_Vertical__c, ACCOUNT_PRIMARY_VERTICAL)
            .setField(Account.RecordTypeId, ACCOUNT_BUSINESS_RECORD_TYPE_ID)
            .setField(Account.Type, ACCOUNT_TYPE)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setFakeId()
            .setParent(
                'RecordType',
                new Fake(RecordType.class)
                    .setField(RecordType.DeveloperName, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
                    .setField(RecordType.Id, ACCOUNT_BUSINESS_RECORD_TYPE_ID)
                    .setField(RecordType.Name, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            );
        Account parentBusinessAccount = (Account) parentBusinessAccountFakeInstance.toSObject();
        Fake contractFakeInstance = new Fake(Contract.class)
            .setField(Contract.AccountId, parentBusinessAccount.Id)
            .setField(Contract.CurrencyIsoCode, CONTRACT_CURRENCY_ISO_CODE)
            .setField(
                (DRIVE_AUTO_PROVISIONING_INDICATOR_FIELD.getSObjectField()),
                DRIVE_AUTO_ACTIVATION_SUPPORTED
            )
            .setField(Contract.Payment_Method__c, WITHHOLDING)
            .setField(Contract.Status, CONTRACT_STATUS_ACTIVATED)
            .setField(Contract.SBQQ__Opportunity__c, opportunityWithMarketplaceNintexSubmissionId)
            .setFakeId();
        Contract contract = (Contract) contractFakeInstance.toSObject();
        Fake opportunityWithMarketplaceNintexIdFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityWithMarketplaceNintexSubmissionId)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.Marketplace_Nintex_Id__c, OPPORTUNITY_MARKETPLACE_NINTEX_ID)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_CLOSED_WON)
            .setField(Opportunity.Source__c, OPPORTUNITY_SOURCE)
            .setField(
                Opportunity.FranchiseAmendmentProcess__c,
                OPPORTUNITY_FRANCHISE_AMENDMENT_PROCESS_OPT_IN
            )
            .setParent('Contract', contractFakeInstance)
            .setParent('Account', parentBusinessAccountFakeInstance);
        Opportunity opportunityWithMarketplaceNintexId = (Opportunity) opportunityWithMarketplaceNintexIdFakeInstance.toSObject();
        Fake parentWorkOrderInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentBusinessAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today() + 40)
            .setField(WorkOrder.Opportunity__c, opportunityWithMarketplaceNintexId.Id)
            .setParent('Account', parentBusinessAccountFakeInstance)
            .setParent('Opportunity__r', opportunityWithMarketplaceNintexIdFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderInstance
        );
        Fake postSalesNintexUseCaseFakeInstance = new Fake(Nintex_Work_Order_Mapping__mdt.class)
            .setField(Nintex_Work_Order_Mapping__mdt.Work_Order_Type__c, TYPE_DRIVE)
            .setField(Nintex_Work_Order_Mapping__mdt.Work_Order_Sub_Type__c, WORK_ORDER_SUB_TYPE)
            .setField(
                Nintex_Work_Order_Mapping__mdt.Work_Order_Provisioning_Process__c,
                PROVISIONING_PROCESS_AUTOMATIC
            )
            .setFakeId();
        Nintex_Work_Order_Mapping__mdt marketplaceNintexUseCase = (Nintex_Work_Order_Mapping__mdt) postSalesNintexUseCaseFakeInstance.toSObject();
        List<Nintex_Work_Order_Mapping__mdt> nintexToWorkOrderMappings = new List<Nintex_Work_Order_Mapping__mdt>{
            marketplaceNintexUseCase
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        INintexWorkOrderMappingsSelector mockNintexWorkOrderMappings = (INintexWorkOrderMappingsSelector) mocks.mock(
            INintexWorkOrderMappingsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockNintexWorkOrderMappings.getAllMappings())
            .thenReturn(nintexToWorkOrderMappings);
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByOpportunityIds(
                    new Set<Id>{ opportunityWithMarketplaceNintexId.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                mockAccountsSelector.selectStoreAccountsByMarketplaceOrDriveNintexIds(
                    new Set<String>{ OPPORTUNITY_MARKETPLACE_NINTEX_ID }
                )
            )
            .thenReturn(new List<Account>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockNintexWorkOrderMappings);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockAccountsSelector);
        Test.startTest();
        ParentWorkOrdersCreationService.createParentWorkOrdersByNintexUseCases(
            new List<Opportunity>{ opportunityWithMarketplaceNintexId }
        );
        Test.stopTest();
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        Integer woCreated = ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
            .sObjectsToInsert.size();
        System.assertEquals(0, woCreated, WORKORDER_FOUND_ALERT_MESSAGE);
    }

    /**
     * @description To test parent Work Order creation when
     * 'SMB' Opportunity with Nintex Use Case as 'SSMO' is received.
     */
    /*@isTest
    private static void testWhenSMBOpportunityWithSSMONintexUseCaseReceivedThenCreateParentWorkOrder() {
        Id ssmoNintexOpportunityWithMarketplaceNintexSubmissionId = fflib_IDGenerator.generate(
            Opportunity.SObjectType
        );
        Fake parentBusinessAccountFakeInstance = new Fake(Account.class)
            .setField(Account.Account_Lifecycle_Status__c, ACCOUNT_LIFECYCLE_STATUS)
            .setField(Account.BillingCity, ACCOUNT_BILLING_CITY)
            .setField(Account.BillingCountry, ACCOUNT_BILLING_COUNTRY)
            .setField(Account.BillingCountryCode, ACCOUNT_BILLING_COUNTRY_CODE)
            .setField(Account.BillingPostalCode, ACCOUNT_BILLING_POSTALCODE)
            .setField(Account.BillingState, ACCOUNT_BILLING_STATE)
            .setField(Account.BillingStreet, ACCOUNT_BILLING_STREET)
            .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
            .setField(Account.Partnership_Status__c, ACCOUNT_PARTNERSHIP_STATUS)
            .setField(Account.Primary_Vertical__c, ACCOUNT_PRIMARY_VERTICAL)
            .setField(Account.RecordTypeId, ACCOUNT_BUSINESS_RECORD_TYPE_ID)
            .setField(Account.Type, ACCOUNT_TYPE)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setFakeId()
            .setParent(
                'RecordType',
                new Fake(RecordType.class)
                    .setField(RecordType.DeveloperName, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
                    .setField(RecordType.Id, ACCOUNT_BUSINESS_RECORD_TYPE_ID)
                    .setField(RecordType.Name, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            );
        Account parentBusinessAccount = (Account) parentBusinessAccountFakeInstance.toSObject();
        Fake storeAccountWithMarketplaceNintexIdFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL
            )
            .setField(Account.Marketplace_Nintex_Id__c, OPPORTUNITY_MARKETPLACE_NINTEX_ID)
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(Account.Data_Verification_Status__c, ACCOUNT_DATA_VERIFICATION_STATUS)
            .setField(Account.Order_Protocol__c, ORDER_PROTOCOL_EMAIL)
            .setField(Account.Nintex_Mx_Requested_Photoshoot__c, PHOTOSHOOT_REQUESTED_YES);
        Account storeAccountWithMarketplaceNintexId = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountWithMarketplaceNintexIdFakeInstance
        );
        Fake contractFakeInstance = new Fake(Contract.class)
            .setField(Contract.AccountId, parentBusinessAccount.Id)
            .setField(Contract.CurrencyIsoCode, CONTRACT_CURRENCY_ISO_CODE)
            .setField(Contract.Status, CONTRACT_STATUS_ACTIVATED)
            .setField(
                Contract.SBQQ__Opportunity__c,
                ssmoNintexOpportunityWithMarketplaceNintexSubmissionId
            )
            .setFakeId();
        Contract contract = (Contract) contractFakeInstance.toSObject();
        Fake ssmoNintexOpportunityWithMarketplaceNintexIdFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, ssmoNintexOpportunityWithMarketplaceNintexSubmissionId)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.Marketplace_Nintex_Id__c, OPPORTUNITY_MARKETPLACE_NINTEX_ID)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_CLOSED_WON)
            .setField(Opportunity.Source__c, OPPORTUNITY_SOURCE)
            .setField(Opportunity.Nintex_Use_Case__c, NINTEX_USE_CASE_SSMO)
            .setField(
                Opportunity.FranchiseAmendmentProcess__c,
                OPPORTUNITY_FRANCHISE_AMENDMENT_PROCESS_OPT_IN
            )
            .setParent('Contract', contractFakeInstance)
            .setParent('Account', parentBusinessAccountFakeInstance);
        Opportunity ssmoNintexOpportunityWithMarketplaceNintex = (Opportunity) ssmoNintexOpportunityWithMarketplaceNintexIdFakeInstance.toSObject();
        Fake ssmoNintexUseCaseFakeInstance = new Fake(Nintex_Work_Order_Mapping__mdt.class)
            .setField(Nintex_Work_Order_Mapping__mdt.Nintex_Use_Case__c, NINTEX_USE_CASE_SSMO)
            .setField(Nintex_Work_Order_Mapping__mdt.Work_Order_Type__c, TYPE_MARKETPLACE)
            .setField(
                Nintex_Work_Order_Mapping__mdt.Work_Order_Provisioning_Process__c,
                PROVISIONING_PROCESS_AUTOMATIC
            )
            .setFakeId();
        Nintex_Work_Order_Mapping__mdt ssmoNintexUseCase = (Nintex_Work_Order_Mapping__mdt) ssmoNintexUseCaseFakeInstance.toSObject();
        List<Nintex_Work_Order_Mapping__mdt> nintexToWorkOrderMappings = new List<Nintex_Work_Order_Mapping__mdt>{
            ssmoNintexUseCase
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        INintexWorkOrderMappingsSelector mockNintexWorkOrderMappings = (INintexWorkOrderMappingsSelector) mocks.mock(
            INintexWorkOrderMappingsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockNintexWorkOrderMappings.getAllMappings())
            .thenReturn(nintexToWorkOrderMappings);
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByOpportunityIds(
                    new Set<Id>{ ssmoNintexOpportunityWithMarketplaceNintexSubmissionId }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                mockAccountsSelector.selectStoreAccountsByMarketplaceOrDriveNintexIds(
                    new Set<String>{ OPPORTUNITY_MARKETPLACE_NINTEX_ID }
                )
            )
            .thenReturn(new List<Account>{ storeAccountWithMarketplaceNintexId });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockNintexWorkOrderMappings);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockAccountsSelector);
        Test.startTest();
        ParentWorkOrdersCreationService.createParentWorkOrdersByNintexUseCases(
            new List<Opportunity>{ ssmoNintexOpportunityWithMarketplaceNintex }
        );
        Test.stopTest();
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());
        WorkOrder parentWorkOrderInserted = (WorkOrder) ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
            .sObjectsToInsert[0];
        Boolean hasParentWorkOrderOrderRegistered =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_ACCOUNT_ID_FIELD) ==
            ssmoNintexOpportunityWithMarketplaceNintex.AccountId;
        System.assertEquals(
            true,
            hasParentWorkOrderOrderRegistered,
            WORK_ORDER_REGISTERED_ASSERT_MESSAGE
        );
        System.assertEquals(
            System.today().addDays(10),
            parentWorkOrderInserted.Proposed_Date_of_Activation__c,
            WORK_ORDER_WITH_SSMO_NINTEX_USE_CASE_FIELDS_MISMATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            PHOTOSHOOT_REQUESTED_YES,
            parentWorkOrderInserted.Mx_Requested_Photoshoot__c,
            WORK_ORDER_WITH_SSMO_NINTEX_USE_CASE_FIELDS_MISMATCH_ASSERT_MESSAGE
        );
    }*/

    /**
     * @description To test parent Work Order is created when
     * Opportunities with Nintex Id are received for New Additional Stores Nintex Use Case.
     */
    @isTest
    private static void testWhenOpportunitiesReceivedThenParentWorkOrdersCreatedBySMBOpportunityNintexUseCaseNewAdditionalStores() {
        Id opportunityWithMarketplaceNintexSubmissionId = fflib_IDGenerator.generate(
            Opportunity.SObjectType
        );
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Map<Id, Set<String>> contractIdToWorkOrderTypesToBeCreated = new Map<Id, Set<String>>{
            contractId => new Set<String>{ TYPE_MARKETPLACE }
        };
        Fake parentBusinessAccountFakeInstance = new Fake(Account.class)
            .setField(Account.Account_Lifecycle_Status__c, ACCOUNT_LIFECYCLE_STATUS)
            .setField(Account.BillingCity, ACCOUNT_BILLING_CITY)
            .setField(Account.BillingCountry, ACCOUNT_BILLING_COUNTRY)
            .setField(Account.BillingCountryCode, ACCOUNT_BILLING_COUNTRY_CODE)
            .setField(Account.BillingPostalCode, ACCOUNT_BILLING_POSTALCODE)
            .setField(Account.BillingState, ACCOUNT_BILLING_STATE)
            .setField(Account.BillingStreet, ACCOUNT_BILLING_STREET)
            .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
            .setField(Account.Partnership_Status__c, ACCOUNT_PARTNERSHIP_STATUS)
            .setField(Account.Primary_Vertical__c, ACCOUNT_PRIMARY_VERTICAL)
            .setField(Account.RecordTypeId, ACCOUNT_BUSINESS_RECORD_TYPE_ID)
            .setField(Account.Type, ACCOUNT_TYPE)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setFakeId()
            .setParent(
                'RecordType',
                new Fake(RecordType.class)
                    .setField(RecordType.DeveloperName, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
                    .setField(RecordType.Id, ACCOUNT_BUSINESS_RECORD_TYPE_ID)
                    .setField(RecordType.Name, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            );
        Account parentBusinessAccount = (Account) parentBusinessAccountFakeInstance.toSObject();
        Fake contractFakeInstance = new Fake(Contract.class)
            .setField(Contract.AccountId, parentBusinessAccount.Id)
            .setField(Contract.CurrencyIsoCode, CONTRACT_CURRENCY_ISO_CODE)
            .setField(
                (DRIVE_AUTO_PROVISIONING_INDICATOR_FIELD.getSObjectField()),
                DRIVE_AUTO_ACTIVATION_SUPPORTED
            )
            .setField(Contract.Payment_Method__c, WITHHOLDING)
            .setField(Contract.Status, CONTRACT_STATUS_ACTIVATED)
            .setField(Contract.SBQQ__Opportunity__c, opportunityWithMarketplaceNintexSubmissionId)
            .setField(Contract.Id, contractId);
        Contract contract = (Contract) contractFakeInstance.toSObject();
        Fake opportunityWithMarketplaceNintexIdFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityWithMarketplaceNintexSubmissionId)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.Marketplace_Nintex_Id__c, OPPORTUNITY_MARKETPLACE_NINTEX_ID)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_CLOSED_WON)
            .setField(Opportunity.Source__c, OPPORTUNITY_SOURCE)
            .setField(Opportunity.Nintex_Use_Case__c, NINTEX_USE_CASE_NEW_ADDITIONAL_STORES)
            .setField(
                Opportunity.FranchiseAmendmentProcess__c,
                OPPORTUNITY_FRANCHISE_AMENDMENT_PROCESS_OPT_IN
            )
            .setField(Opportunity.ContractId, contractId)
            .setParent('Contract', contractFakeInstance)
            .setParent('Account', parentBusinessAccountFakeInstance);
        Opportunity opportunityWithMarketplaceNintexId = (Opportunity) opportunityWithMarketplaceNintexIdFakeInstance.toSObject();
        Fake postSalesNintexUseCaseFakeInstance = new Fake(Nintex_Work_Order_Mapping__mdt.class)
            .setField(
                Nintex_Work_Order_Mapping__mdt.Nintex_Use_Case__c,
                NINTEX_USE_CASE_NEW_ADDITIONAL_STORES
            )
            .setField(Nintex_Work_Order_Mapping__mdt.Work_Order_Type__c, TYPE_MARKETPLACE)
            .setField(
                Nintex_Work_Order_Mapping__mdt.Work_Order_Provisioning_Process__c,
                PROVISIONING_PROCESS_AUTOMATIC
            )
            .setFakeId();
        Nintex_Work_Order_Mapping__mdt marketplaceNintexUseCase = (Nintex_Work_Order_Mapping__mdt) postSalesNintexUseCaseFakeInstance.toSObject();
        List<Nintex_Work_Order_Mapping__mdt> nintexToWorkOrderMappings = new List<Nintex_Work_Order_Mapping__mdt>{
            marketplaceNintexUseCase
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        INintexWorkOrderMappingsSelector mockNintexWorkOrderMappings = (INintexWorkOrderMappingsSelector) mocks.mock(
            INintexWorkOrderMappingsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        ISubscriptionsService subscriptionServiceMock = (ISubscriptionsService) mocks.mock(
            ISubscriptionsService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockNintexWorkOrderMappings.getAllMappings())
            .thenReturn(nintexToWorkOrderMappings);
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByOpportunityIds(
                    new Set<Id>{ opportunityWithMarketplaceNintexId.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                mockAccountsSelector.selectStoreAccountsByMarketplaceOrDriveNintexIds(
                    new Set<String>{ OPPORTUNITY_MARKETPLACE_NINTEX_ID }
                )
            )
            .thenReturn(new List<Account>{});
        mocks.when(
                subscriptionServiceMock.getExistingSubscriptionsForContracts(
                    new Set<Id>{ contractId }
                )
            )
            .thenReturn(contractIdToWorkOrderTypesToBeCreated);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockNintexWorkOrderMappings);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockAccountsSelector);
        Application.SERVICE.setMock(ISubscriptionsService.class, subscriptionServiceMock);
        Test.startTest();
        ParentWorkOrdersCreationService.createParentWorkOrdersByNintexUseCases(
            new List<Opportunity>{ opportunityWithMarketplaceNintexId }
        );
        Test.stopTest();
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());
        Boolean hasParentOrderRegistered =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_ACCOUNT_ID_FIELD) == opportunityWithMarketplaceNintexId.AccountId;
        System.assertEquals(true, hasParentOrderRegistered, WORK_ORDER_REGISTERED_ASSERT_MESSAGE);
    }

    /**
     * @description To test parent Work Order is created when
     * Opportunities with Nintex Id received for Change of Ownership Nintex Use Case.
     */
    @isTest
    private static void testWhenOpportunitiesReceivedThenParentWorkOrdersCreatedBySMBOpportunityNintexUseCaseChangeOfOwnership() {
        Id opportunityWithMarketplaceNintexSubmissionId = fflib_IDGenerator.generate(
            Opportunity.SObjectType
        );

        Fake parentBusinessAccountFakeInstance = new Fake(Account.class)
            .setField(Account.Account_Lifecycle_Status__c, ACCOUNT_LIFECYCLE_STATUS)
            .setField(Account.BillingCity, ACCOUNT_BILLING_CITY)
            .setField(Account.BillingCountry, ACCOUNT_BILLING_COUNTRY)
            .setField(Account.BillingCountryCode, ACCOUNT_BILLING_COUNTRY_CODE)
            .setField(Account.BillingPostalCode, ACCOUNT_BILLING_POSTALCODE)
            .setField(Account.BillingState, ACCOUNT_BILLING_STATE)
            .setField(Account.BillingStreet, ACCOUNT_BILLING_STREET)
            .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
            .setField(Account.Partnership_Status__c, ACCOUNT_PARTNERSHIP_STATUS)
            .setField(Account.Primary_Vertical__c, ACCOUNT_PRIMARY_VERTICAL)
            .setField(Account.RecordTypeId, ACCOUNT_BUSINESS_RECORD_TYPE_ID)
            .setField(Account.Type, ACCOUNT_TYPE)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setFakeId()
            .setParent(
                'RecordType',
                new Fake(RecordType.class)
                    .setField(RecordType.DeveloperName, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
                    .setField(RecordType.Id, ACCOUNT_BUSINESS_RECORD_TYPE_ID)
                    .setField(RecordType.Name, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            );
        Account parentBusinessAccount = (Account) parentBusinessAccountFakeInstance.toSObject();
        Fake contractFakeInstance = new Fake(Contract.class)
            .setField(Contract.AccountId, parentBusinessAccount.Id)
            .setField(Contract.CurrencyIsoCode, CONTRACT_CURRENCY_ISO_CODE)
            .setField(
                (DRIVE_AUTO_PROVISIONING_INDICATOR_FIELD.getSObjectField()),
                DRIVE_AUTO_ACTIVATION_SUPPORTED
            )
            .setField(Contract.Payment_Method__c, WITHHOLDING)
            .setField(Contract.Status, CONTRACT_STATUS_ACTIVATED)
            .setField(Contract.SBQQ__Opportunity__c, opportunityWithMarketplaceNintexSubmissionId)
            .setFakeId();
        Contract contract = (Contract) contractFakeInstance.toSObject();
        Fake opportunityWithMarketplaceNintexIdFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityWithMarketplaceNintexSubmissionId)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.Marketplace_Nintex_Id__c, OPPORTUNITY_MARKETPLACE_NINTEX_ID)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_CLOSED_WON)
            .setField(Opportunity.Source__c, OPPORTUNITY_SOURCE)
            .setField(Opportunity.Nintex_Use_Case__c, NINTEX_USE_CASE_CHANGE_OF_OWNERSHIP)
            .setField(
                Opportunity.FranchiseAmendmentProcess__c,
                OPPORTUNITY_FRANCHISE_AMENDMENT_PROCESS_OPT_IN
            )
            .setParent('Contract', contractFakeInstance)
            .setParent('Account', parentBusinessAccountFakeInstance);
        Opportunity opportunityWithMarketplaceNintexId = (Opportunity) opportunityWithMarketplaceNintexIdFakeInstance.toSObject();
        Fake parentWorkOrderInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentBusinessAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today() + 40)
            .setField(WorkOrder.Opportunity__c, opportunityWithMarketplaceNintexId.Id)
            .setParent('Account', parentBusinessAccountFakeInstance)
            .setParent('Opportunity__r', opportunityWithMarketplaceNintexIdFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderInstance
        );
        Fake postSalesNintexUseCaseFakeInstance = new Fake(Nintex_Work_Order_Mapping__mdt.class)
            .setField(
                Nintex_Work_Order_Mapping__mdt.Nintex_Use_Case__c,
                NINTEX_USE_CASE_CHANGE_OF_OWNERSHIP
            )
            .setField(Nintex_Work_Order_Mapping__mdt.Work_Order_Type__c, TYPE_COO)
            .setField(
                Nintex_Work_Order_Mapping__mdt.Work_Order_Provisioning_Process__c,
                PROVISIONING_PROCESS_AUTOMATIC
            )
            .setFakeId();
        Nintex_Work_Order_Mapping__mdt cooNintexUseCase = (Nintex_Work_Order_Mapping__mdt) postSalesNintexUseCaseFakeInstance.toSObject();
        List<Nintex_Work_Order_Mapping__mdt> nintexToWorkOrderMappings = new List<Nintex_Work_Order_Mapping__mdt>{
            cooNintexUseCase
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        INintexWorkOrderMappingsSelector mockNintexWorkOrderMappings = (INintexWorkOrderMappingsSelector) mocks.mock(
            INintexWorkOrderMappingsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockNintexWorkOrderMappings.getAllMappings())
            .thenReturn(nintexToWorkOrderMappings);
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByOpportunityIds(
                    new Set<Id>{ opportunityWithMarketplaceNintexId.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                mockAccountsSelector.selectStoreAccountsByMarketplaceOrDriveNintexIds(
                    new Set<String>{ OPPORTUNITY_MARKETPLACE_NINTEX_ID }
                )
            )
            .thenReturn(new List<Account>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockNintexWorkOrderMappings);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockAccountsSelector);
        Test.startTest();
        ParentWorkOrdersCreationService.createParentWorkOrdersByNintexUseCases(
            new List<Opportunity>{ opportunityWithMarketplaceNintexId }
        );
        Test.stopTest();
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());
        Boolean hasParentOrderRegistered =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_ACCOUNT_ID_FIELD) == opportunityWithMarketplaceNintexId.AccountId;
        System.assertEquals(true, hasParentOrderRegistered, WORK_ORDER_REGISTERED_ASSERT_MESSAGE);
    }

    /**
     * @description To test when Interface Transaction is created for Onboarding Inputs then
     * create Parent Work Order.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenInterfaceTransactionsAreInsertedForOnboardingInputsThenCreateParentWorkOrder() {
        Id userId = fflib_IDGenerator.generate(User.SObjectType);
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id mxOnboardingLinkId = fflib_IDGenerator.generate(Mx_Onboarding_Link__c.SObjectType);
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SobjectType);
        WorkOrderGenerationWrapper workOrderGenerationWrapper = new WorkOrderGenerationWrapper();
        workOrderGenerationWrapper.setType(TYPE_STOREFRONT);
        workOrderGenerationWrapper.setSubType(NET_NEW_SUB_TYPE);
        workOrderGenerationWrapper.setStatus(CONFIRMED_STATUS);
        workOrderGenerationWrapper.setAccountId(accountId);
        workOrderGenerationWrapper.setOpportunityId(opportunityId);
        workOrderGenerationWrapper.setContractId(contractId);
        workOrderGenerationWrapper.setProposedDateOfActivation(System.today());
        workOrderGenerationWrapper.setCreationSource(WORK_ORDER_SOURCE_ONBOARDING_INPUTS);
        workOrderGenerationWrapper.setUniqueIdentifier(UNIQUE_IDENTIFIER);
        workOrderGenerationWrapper.setProvisioningProcess(PROVISIONING_PROCESS_MANUAL);
        workOrderGenerationWrapper.setProvisioningStatus(READINESS_CHECK_COMPLETE);
        workOrderGenerationWrapper.setOrderProtocol(POS_ORDER_PROTOCOL);
        workOrderGenerationWrapper.setStoreAccountIds('');
        workOrderGenerationWrapper.setActivatedCentrally('');
        workOrderGenerationWrapper.setMenuToBeCompletedBy('');
        workOrderGenerationWrapper.setWorkOrderSource(WORK_ORDER_SOURCE_ONBOARDING_INPUTS);
        workOrderGenerationWrapper.setPhotoShootRequest(PHOTOSHOOT_REQUESTED_YES);
        workOrderGenerationWrapper.setMenuSetUpMethod(MENU_SETUP_METHOD_NONE);
        workOrderGenerationWrapper.setSalesNotesForMenuTeam('');
        workOrderGenerationWrapper.setPhotoShootDate(System.today());
        workOrderGenerationWrapper.setPhotoShootTime(null);
        workOrderGenerationWrapper.setBundledWithMarketplace(BUNDLED_WITH_MARKETPLACE_NO);
        workOrderGenerationWrapper.setSalesRepName(userId);
        workOrderGenerationWrapper.setMxOnboardingLinkId(mxOnboardingLinkId);

        Mx_Onboarding_Link__c mxOnboardingLinkFake = (Mx_Onboarding_Link__c) new Fake(
                Mx_Onboarding_Link__c.class
            )
            .setField(Mx_Onboarding_Link__c.Id, mxOnboardingLinkId)
            .setField(
                Mx_Onboarding_Link__c.Onboarding_Scenario__c,
                ONBOARDING_SCENARIO_NET_NEW_MX_ONBOARDING
            )
            .setField(Mx_Onboarding_Link__c.Contract__c, contractId)
            .setField(Mx_Onboarding_Link__c.Source__c, WORK_ORDER_SOURCE_ONBOARDING_INPUTS)
            .setField(
                Mx_Onboarding_Link__c.Record_Creation_Status__c,
                RECORD_CREATION_STATUS_SUCCESS
            )
            .setField(Mx_Onboarding_Link__c.UUID__c, UNIQUE_IDENTIFIER)
            .setField(Mx_Onboarding_Link__c.CreatedById, userId)
            .toSobject();
        Interface_Transaction__c interfaceTransaction = new Interface_Transaction__c(
            Payload__c = JSON.serialize(workOrderGenerationWrapper),
            Remaining_Retry_Attempts__c = 3,
            Interface_Transaction_Configuration_Name__c = INTERFACE_TRANSACTION_CONFIGURATION_NAME_WORK_ORDER_PAYLOAD_INBOUND_INTEGRATION
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IMxOnboardingLinksSelector mxOnboardingLinksSelectorMock = (IMxOnboardingLinksSelector) mocks.mock(
            IMxOnboardingLinksSelector.class
        );
        mocks.startStubbing();
        mocks.when(mxOnboardingLinksSelectorMock.sObjectType())
            .thenReturn(Mx_Onboarding_Link__c.SObjectType);
        mocks.when(mxOnboardingLinksSelectorMock.selectByUUID(new Set<String>{ UNIQUE_IDENTIFIER }))
            .thenReturn(new List<Mx_Onboarding_Link__c>{ mxOnboardingLinkFake });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mxOnboardingLinksSelectorMock);
        ParentWorkOrdersCreationService.createParentWorkOrder(
            new List<Interface_Transaction__c>{ interfaceTransaction }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
    }

    /**
     * @description To test when Opportunities with Nintex Id are received for any Nintex
     * use case and Contract contains Storefront Products then create Marketplace and Storefront Work Orders.
     */
    @isTest
    private static void testWhenOpportunitiesReceivedForSMBNintexUseCasesAndContractContainsStorefrontProductsThenCreateMarketplaceAndStorefrontWorkOrder() {
        Id opportunityWithMarketplaceNintexSubmissionId = fflib_IDGenerator.generate(
            Opportunity.SObjectType
        );
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Map<Id, Set<String>> contractIdToWorkOrderTypesToBeCreated = new Map<Id, Set<String>>{
            contractId => new Set<String>{ TYPE_MARKETPLACE, TYPE_STOREFRONT }
        };
        Fake parentBusinessAccountFakeInstance = new Fake(Account.class)
            .setField(Account.Account_Lifecycle_Status__c, ACCOUNT_LIFECYCLE_STATUS)
            .setField(Account.BillingCity, ACCOUNT_BILLING_CITY)
            .setField(Account.BillingCountry, ACCOUNT_BILLING_COUNTRY)
            .setField(Account.BillingCountryCode, ACCOUNT_BILLING_COUNTRY_CODE)
            .setField(Account.BillingPostalCode, ACCOUNT_BILLING_POSTALCODE)
            .setField(Account.BillingState, ACCOUNT_BILLING_STATE)
            .setField(Account.BillingStreet, ACCOUNT_BILLING_STREET)
            .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
            .setField(Account.Partnership_Status__c, ACCOUNT_PARTNERSHIP_STATUS)
            .setField(Account.Primary_Vertical__c, ACCOUNT_PRIMARY_VERTICAL)
            .setField(Account.RecordTypeId, ACCOUNT_BUSINESS_RECORD_TYPE_ID)
            .setField(Account.Type, ACCOUNT_TYPE)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .setFakeId()
            .setParent(
                'RecordType',
                new Fake(RecordType.class)
                    .setField(RecordType.DeveloperName, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
                    .setField(RecordType.Id, ACCOUNT_BUSINESS_RECORD_TYPE_ID)
                    .setField(RecordType.Name, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            );
        Account parentBusinessAccount = (Account) parentBusinessAccountFakeInstance.toSObject();
        Fake contractFakeInstance = new Fake(Contract.class)
            .setField(Contract.AccountId, parentBusinessAccount.Id)
            .setField(Contract.CurrencyIsoCode, CONTRACT_CURRENCY_ISO_CODE)
            .setField(
                (DRIVE_AUTO_PROVISIONING_INDICATOR_FIELD.getSObjectField()),
                DRIVE_AUTO_ACTIVATION_SUPPORTED
            )
            .setField(Contract.Payment_Method__c, WITHHOLDING)
            .setField(Contract.Status, CONTRACT_STATUS_ACTIVATED)
            .setField(Contract.SBQQ__Opportunity__c, opportunityWithMarketplaceNintexSubmissionId)
            .setField(Contract.Id, contractId);
        Contract contract = (Contract) contractFakeInstance.toSObject();
        Fake opportunityWithMarketplaceNintexIdFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityWithMarketplaceNintexSubmissionId)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.Marketplace_Nintex_Id__c, OPPORTUNITY_MARKETPLACE_NINTEX_ID)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_CLOSED_WON)
            .setField(Opportunity.Source__c, OPPORTUNITY_SOURCE)
            .setField(Opportunity.Nintex_Use_Case__c, NINTEX_USE_CASE_NEW_ADDITIONAL_STORES)
            .setField(Opportunity.Packages_with_Products__c, PACKAGES_WITH_PRODUCTS)
            .setField(
                Opportunity.FranchiseAmendmentProcess__c,
                OPPORTUNITY_FRANCHISE_AMENDMENT_PROCESS_OPT_IN
            )
            .setField(Opportunity.ContractId, contractId)
            .setParent('Contract', contractFakeInstance)
            .setParent('Account', parentBusinessAccountFakeInstance);
        Opportunity opportunityWithMarketplaceNintexId = (Opportunity) opportunityWithMarketplaceNintexIdFakeInstance.toSObject();
        Fake postSalesNintexUseCaseFakeInstance = new Fake(Nintex_Work_Order_Mapping__mdt.class)
            .setField(
                Nintex_Work_Order_Mapping__mdt.Nintex_Use_Case__c,
                NINTEX_USE_CASE_NEW_ADDITIONAL_STORES
            )
            .setField(Nintex_Work_Order_Mapping__mdt.Work_Order_Type__c, TYPE_MARKETPLACE)
            .setField(
                Nintex_Work_Order_Mapping__mdt.Work_Order_Provisioning_Process__c,
                PROVISIONING_PROCESS_AUTOMATIC
            )
            .setFakeId();
        Nintex_Work_Order_Mapping__mdt marketplaceNintexUseCase = (Nintex_Work_Order_Mapping__mdt) postSalesNintexUseCaseFakeInstance.toSObject();
        List<Nintex_Work_Order_Mapping__mdt> nintexToWorkOrderMappings = new List<Nintex_Work_Order_Mapping__mdt>{
            marketplaceNintexUseCase
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        INintexWorkOrderMappingsSelector mockNintexWorkOrderMappings = (INintexWorkOrderMappingsSelector) mocks.mock(
            INintexWorkOrderMappingsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        ISubscriptionsService subscriptionServiceMock = (ISubscriptionsService) mocks.mock(
            ISubscriptionsService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockNintexWorkOrderMappings.getAllMappings())
            .thenReturn(nintexToWorkOrderMappings);
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByOpportunityIds(
                    new Set<Id>{ opportunityWithMarketplaceNintexId.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                mockAccountsSelector.selectStoreAccountsByMarketplaceOrDriveNintexIds(
                    new Set<String>{ OPPORTUNITY_MARKETPLACE_NINTEX_ID }
                )
            )
            .thenReturn(new List<Account>{});
        mocks.when(
                subscriptionServiceMock.getExistingSubscriptionsForContracts(
                    new Set<Id>{ contractId }
                )
            )
            .thenReturn(contractIdToWorkOrderTypesToBeCreated);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockNintexWorkOrderMappings);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockAccountsSelector);
        Application.SERVICE.setMock(ISubscriptionsService.class, subscriptionServiceMock);
        Test.startTest();
        ParentWorkOrdersCreationService.createParentWorkOrdersByNintexUseCases(
            new List<Opportunity>{ opportunityWithMarketplaceNintexId }
        );
        Test.stopTest();
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());
        Boolean hasStorefrontWorkOrderRegistered =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_TYPE_FIELD) == TYPE_STOREFRONT;
        Boolean hasMarketpplaceWorkOrderRegistered =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[1]
                .get(WORK_ORDER_TYPE_FIELD) == TYPE_MARKETPLACE;
        System.assertEquals(
            true,
            hasStorefrontWorkOrderRegistered,
            WORK_ORDER_REGISTERED_ASSERT_MESSAGE
        );
        System.assertEquals(
            true,
            hasMarketpplaceWorkOrderRegistered,
            WORK_ORDER_REGISTERED_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test when Opportunities with Nintex Id are received for any Nintex
     * use case and Contract contains Storefront Products then create Marketplace and Storefront Work Orders.
     */
    @isTest
    private static void testWhenOpportunitiesReceivedForNintexUseCasesAndContractContainsStorefrontProductsThenCreateMarketplaceAndStorefrontWorkOrder() {
        Id opportunityWithMarketplaceNintexSubmissionId = fflib_IDGenerator.generate(
            Opportunity.SObjectType
        );
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Map<Id, Set<String>> contractIdToWorkOrderTypesToBeCreated = new Map<Id, Set<String>>{
            contractId => new Set<String>{ TYPE_MARKETPLACE, TYPE_STOREFRONT }
        };
        Fake parentBusinessAccountFakeInstance = new Fake(Account.class)
            .setField(Account.Account_Lifecycle_Status__c, ACCOUNT_LIFECYCLE_STATUS)
            .setField(Account.BillingCity, ACCOUNT_BILLING_CITY)
            .setField(Account.BillingCountry, ACCOUNT_BILLING_COUNTRY)
            .setField(Account.BillingCountryCode, ACCOUNT_BILLING_COUNTRY_CODE)
            .setField(Account.BillingPostalCode, ACCOUNT_BILLING_POSTALCODE)
            .setField(Account.BillingState, ACCOUNT_BILLING_STATE)
            .setField(Account.BillingStreet, ACCOUNT_BILLING_STREET)
            .setField(Account.Name, BUSINESS_ACCOUNT_NAME)
            .setField(Account.Partnership_Status__c, ACCOUNT_PARTNERSHIP_STATUS)
            .setField(Account.Primary_Vertical__c, ACCOUNT_PRIMARY_VERTICAL)
            .setField(Account.RecordTypeId, ACCOUNT_BUSINESS_RECORD_TYPE_ID)
            .setField(Account.Type, ACCOUNT_TYPE)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_ENTERPRISE)
            .setFakeId()
            .setParent(
                'RecordType',
                new Fake(RecordType.class)
                    .setField(RecordType.DeveloperName, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
                    .setField(RecordType.Id, ACCOUNT_BUSINESS_RECORD_TYPE_ID)
                    .setField(RecordType.Name, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            );
        Account parentBusinessAccount = (Account) parentBusinessAccountFakeInstance.toSObject();
        Fake contractFakeInstance = new Fake(Contract.class)
            .setField(Contract.AccountId, parentBusinessAccount.Id)
            .setField(Contract.CurrencyIsoCode, CONTRACT_CURRENCY_ISO_CODE)
            .setField(
                (DRIVE_AUTO_PROVISIONING_INDICATOR_FIELD.getSObjectField()),
                DRIVE_AUTO_ACTIVATION_SUPPORTED
            )
            .setField(Contract.Payment_Method__c, WITHHOLDING)
            .setField(Contract.Status, CONTRACT_STATUS_ACTIVATED)
            .setField(Contract.SBQQ__Opportunity__c, opportunityWithMarketplaceNintexSubmissionId)
            .setField(Contract.Id, contractId);
        Contract contract = (Contract) contractFakeInstance.toSObject();
        Fake opportunityWithMarketplaceNintexIdFakeInstance = new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityWithMarketplaceNintexSubmissionId)
            .setField(Opportunity.CloseDate, System.today().addMonths(5))
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.Pricebook2Id, Test.getStandardPricebookId())
            .setField(Opportunity.Marketplace_Nintex_Id__c, OPPORTUNITY_MARKETPLACE_NINTEX_ID)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_CLOSED_WON)
            .setField(Opportunity.Source__c, OPPORTUNITY_SOURCE)
            .setField(Opportunity.Nintex_Use_Case__c, NINTEX_USE_CASE_NEW_ADDITIONAL_STORES)
            .setField(Opportunity.Packages_with_Products__c, PACKAGES_WITH_PRODUCTS)
            .setField(
                Opportunity.FranchiseAmendmentProcess__c,
                OPPORTUNITY_FRANCHISE_AMENDMENT_PROCESS_OPT_IN
            )
            .setField(Opportunity.ContractId, contractId)
            .setParent('Contract', contractFakeInstance)
            .setParent('Account', parentBusinessAccountFakeInstance);
        Opportunity opportunityWithMarketplaceNintexId = (Opportunity) opportunityWithMarketplaceNintexIdFakeInstance.toSObject();
        Fake postSalesNintexUseCaseFakeInstance = new Fake(Nintex_Work_Order_Mapping__mdt.class)
            .setField(
                Nintex_Work_Order_Mapping__mdt.Nintex_Use_Case__c,
                NINTEX_USE_CASE_NEW_ADDITIONAL_STORES
            )
            .setField(Nintex_Work_Order_Mapping__mdt.Work_Order_Type__c, TYPE_MARKETPLACE)
            .setField(
                Nintex_Work_Order_Mapping__mdt.Work_Order_Provisioning_Process__c,
                PROVISIONING_PROCESS_AUTOMATIC
            )
            .setFakeId();
        Nintex_Work_Order_Mapping__mdt marketplaceNintexUseCase = (Nintex_Work_Order_Mapping__mdt) postSalesNintexUseCaseFakeInstance.toSObject();
        List<Nintex_Work_Order_Mapping__mdt> nintexToWorkOrderMappings = new List<Nintex_Work_Order_Mapping__mdt>{
            marketplaceNintexUseCase
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        INintexWorkOrderMappingsSelector mockNintexWorkOrderMappings = (INintexWorkOrderMappingsSelector) mocks.mock(
            INintexWorkOrderMappingsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        ISubscriptionsService subscriptionServiceMock = (ISubscriptionsService) mocks.mock(
            ISubscriptionsService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockNintexWorkOrderMappings.getAllMappings())
            .thenReturn(nintexToWorkOrderMappings);
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectParentWorkOrdersByOpportunityIds(
                    new Set<Id>{ opportunityWithMarketplaceNintexId.Id }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                mockAccountsSelector.selectStoreAccountsByMarketplaceOrDriveNintexIds(
                    new Set<String>{ OPPORTUNITY_MARKETPLACE_NINTEX_ID }
                )
            )
            .thenReturn(new List<Account>{});
        mocks.when(
                subscriptionServiceMock.getExistingSubscriptionsForContracts(
                    new Set<Id>{ contractId }
                )
            )
            .thenReturn(contractIdToWorkOrderTypesToBeCreated);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockNintexWorkOrderMappings);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockAccountsSelector);
        Application.SERVICE.setMock(ISubscriptionsService.class, subscriptionServiceMock);
        Test.startTest();
        ParentWorkOrdersCreationService.createParentWorkOrdersByNintexUseCases(
            new List<Opportunity>{ opportunityWithMarketplaceNintexId }
        );
        Test.stopTest();
        fflib_ArgumentCaptor capturedInsertUOWArguments = fflib_ArgumentCaptor.forClass(
            InsertUnitOfWorkHelper.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerWork((InsertUnitOfWorkHelper) capturedInsertUOWArguments.capture());
        Boolean hasStorefrontWorkOrderRegistered =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[0]
                .get(WORK_ORDER_TYPE_FIELD) == TYPE_STOREFRONT;
        Boolean hasMarketpplaceWorkOrderRegistered =
            ((InsertUnitOfWorkHelper) capturedInsertUOWArguments.getValue())
                .sObjectsToInsert[1]
                .get(WORK_ORDER_TYPE_FIELD) == TYPE_MARKETPLACE;
        System.assertEquals(
            true,
            hasStorefrontWorkOrderRegistered,
            WORK_ORDER_REGISTERED_ASSERT_MESSAGE
        );
        System.assertEquals(
            true,
            hasMarketpplaceWorkOrderRegistered,
            WORK_ORDER_REGISTERED_ASSERT_MESSAGE
        );
    }
}