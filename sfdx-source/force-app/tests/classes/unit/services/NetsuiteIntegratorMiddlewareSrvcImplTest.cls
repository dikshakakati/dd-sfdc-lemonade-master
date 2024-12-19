/**
 * @author Deloitte
 * @date 18/10/2022
 * @description Test class for NetsuiteIntegratorMiddlewareServiceImpl class.
 * Suppressed Warnings since mock verify method does not require System Assert statements.
 */
@isTest(seeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class NetsuiteIntegratorMiddlewareSrvcImplTest {
    private static final String VALIDATION_ERROR_DOORDASH_LEGAL_ENTITY = System.Label.PAYMENT_ACCOUNT_VALIDATION_ERROR_DDORDASH_LEGAL_ENTITY;
    private static final String ADDRESS_LINE1_VALUE = 'any street 0909';
    private static final String ALLOW_SYNC_WITH_NETSUITE = System.Label.SYNC_WITH_NETSUITE_CUSTOM_PERMISSION;
    private static final String ASSERT_MESSAGE_VALIDATION_ERROR_NOT_RETURNED = 'Unexpected result: Validation Error is not returned';
    private static final String ASSERT_MESSAGE_SUCCESS_MESSAGE_RETURNED = 'Unexpected result: Success Message is not returned';
    private static final String CITY_VALUE = 'Golden City';
    private static final String CONTRACT_SIGNED = 'Contract Signed';
    private static final String MESSAGE_KEY = 'message';
    private static final String MOCK_EXCEPTION_MESSAGE = 'Exception occurred while performing DML operation';
    private static final String NETSUITE_ID = 'PaymentAccountNetsuiteId';
    private static final String PAYMENT_TERM_NET_30 = 'Net 30';
    private static final Id PAYMENTS_RECORD_TYPE_ID;
    private static final String PENDING_STATUS = 'Pending';
    private static final String RECORD_TYPE = 'Invoice';
    private static final String RECORD_TYPE_PAYMENTS = 'Payments';
    private static final String STATE_VALUE = 'theState';
    private static final Id STORE_RECORD_TYPE_ID;
    private static final String SUCCESS_KEY = 'success';
    private static final String STATUS_KEY = 'status';
    private static final String SUCCESS_MESSAGE = System.Label.SYNC_WITH_MIDDLEWARE_NETSUITE_SUCCESS_MESSAGE;
    private static final String VALIDATION_ERROR_ADDRESS = System.Label.PAYMENT_ACCOUNT_VALIDATION_ERROR_ADDRESS;
    private static final String VALIDATION_ERROR_BILL_TO_COMPANY_NAME = System.Label.PAYMENT_ACCOUNT_VALIDATION_ERROR_BILL_TO_COMPANY_NAME;
    private static final String VALIDATION_ERROR_BILLING_CONTACT_EMAIL = System.Label.PAYMENT_ACCOUNT_VALIDATION_ERROR_BILLING_CONTACT_EMAIL;
    private static final String VALIDATION_ERROR_COUNTRY_CODE_ALPHA2 = System.Label.PAYMENT_ACCOUNT_VALIDATION_ERROR_COUNTRY_CODE_ALPHA2;
    private static final String VALIDATION_ERROR_CURRENCY = System.Label.PAYMENT_ACCOUNT_VALIDATION_ERROR_CURRENCY;
    private static final String VALIDATION_ERROR_NET_SUITE_SYNC_PROCESSES = System.Label.PAYMENT_ACCOUNT_VALIDATION_ERROR_NET_SUITE_SYNC_PROCESSES;
    private static final String VALIDATION_ERROR_PENDING_STATUS = System.Label.PAYMENT_ACCOUNT_VALIDATION_ERROR_PENDING_STATUS;
    private static final String VALIDATION_ERROR_RECORD_TYPE = System.Label.PAYMENT_ACCOUNT_VALIDATION_ERROR_RECORD_TYPE;
    private static final String VALIDATION_PERMISSION_ISSUE = System.Label.PAYMENT_ACCOUNT_VALIDATION_ERROR_PERMISSION_SET;
    private static final String VALIDATION_ERROR_BUSINESS_UNIT = System.Label.PAYMENT_ACCOUNT_VALIDATION_BUSINESS_UNIT;
    private static final String VALIDATION_ERROR_CURRENCY_BY_LEGAL_ENTITY = System.Label.PAYMENT_ACCOUNT_VALIDATION_ERROR_CURRENCY_BY_LEGAL_ENTITY;
    private static final String VALIDATION_ERROR_PAYMENT_TERMS = System.Label.PAYMENT_ACCOUNT_VALIDATION_ERROR_PAYMENT_TERMS;

    static {
        STORE_RECORD_TYPE_ID = Schema.SObjectType.Payment_Account__c.getRecordTypeInfosByDeveloperName()
            .get(RECORD_TYPE)
            .getRecordTypeId();
        PAYMENTS_RECORD_TYPE_ID = Schema.SObjectType.Payment_Account__c.getRecordTypeInfosByDeveloperName()
            .get(RECORD_TYPE_PAYMENTS)
            .getRecordTypeId();
    }

    /**
     * @description To test validation error is returned
     * when user do not have Sync With Netsuite Permission.
     */
    @isTest
    private static void testWhenSyncWithNetsuitePermissionNotPresentThenReturnValidationError() {
        Id paymentAccountId = fflib_IDGenerator.generate(Payment_Account__c.SObjectType);
        Fake paymentAccountFakeInstance = new Fake(Payment_Account__c.class)
            .setField(Payment_Account__c.Id, paymentAccountId)
            .setField(Payment_Account__c.recordTypeId, STORE_RECORD_TYPE_ID);
        Payment_Account__c paymentAccount = (Payment_Account__c) ServiceMockDataBuilder.convertToSObject(
            paymentAccountFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IFeatureManagementService mockFeatureManagementService = (IFeatureManagementService) mocks.mock(
            IFeatureManagementService.class
        );
        IPaymentAccountsSelector mockPaymentAccountsSelector = (IPaymentAccountsSelector) mocks.mock(
            IPaymentAccountsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockPaymentAccountsSelector.sObjectType())
            .thenReturn(Payment_Account__c.SObjectType);
        mocks.when(mockPaymentAccountsSelector.selectById(new Set<Id>{ paymentAccountId }))
            .thenReturn(new List<Payment_Account__c>{ paymentAccount });
        mocks.when(mockFeatureManagementService.checkPermission(ALLOW_SYNC_WITH_NETSUITE))
            .thenReturn(false);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IFeatureManagementService.class, mockFeatureManagementService);
        Application.SELECTOR.setMock(mockPaymentAccountsSelector);
        NetsuiteIntegratorMiddlewareServiceImpl netsuiteIntegratorMiddlewareServiceInstance = new NetsuiteIntegratorMiddlewareServiceImpl();
        List<String> validationErrors = netsuiteIntegratorMiddlewareServiceInstance.performReadinessCheckValidations(
            paymentAccountId
        );
        Map<Id, List<String>> idToValidationErrors = netsuiteIntegratorMiddlewareServiceInstance.performReadinessCheckValidationsOnMultiplePaymentAccounts(
            new Set<Id>{ paymentAccountId }
        );
        System.assertEquals(
            validationErrors,
            new List<String>{ VALIDATION_PERMISSION_ISSUE },
            ASSERT_MESSAGE_VALIDATION_ERROR_NOT_RETURNED
        );
        System.assertEquals(
            idToValidationErrors,
            new Map<Id, List<String>>{
                paymentAccountId => new List<String>{ VALIDATION_PERMISSION_ISSUE }
            },
            ASSERT_MESSAGE_VALIDATION_ERROR_NOT_RETURNED
        );
    }

    /**
     * @description To test validation error is returned
     * when payment account record type is Payments.
     */
    @isTest
    private static void testWhenPaymentsRecordTypeThenReturnValidationError() {
        Id paymentAccountId = fflib_IDGenerator.generate(Payment_Account__c.SObjectType);
        Fake paymentAccountFakeInstance = new Fake(Payment_Account__c.class)
            .setField(Payment_Account__c.Id, paymentAccountId)
            .setField(Payment_Account__c.recordTypeId, PAYMENTS_RECORD_TYPE_ID);
        Payment_Account__c paymentAccount = (Payment_Account__c) ServiceMockDataBuilder.convertToSObject(
            paymentAccountFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IFeatureManagementService mockFeatureManagementService = (IFeatureManagementService) mocks.mock(
            IFeatureManagementService.class
        );
        IPaymentAccountsSelector mockPaymentAccountsSelector = (IPaymentAccountsSelector) mocks.mock(
            IPaymentAccountsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockPaymentAccountsSelector.sObjectType())
            .thenReturn(Payment_Account__c.SObjectType);
        mocks.when(mockPaymentAccountsSelector.selectById(new Set<Id>{ paymentAccountId }))
            .thenReturn(new List<Payment_Account__c>{ paymentAccount });
        mocks.when(mockFeatureManagementService.checkPermission(ALLOW_SYNC_WITH_NETSUITE))
            .thenReturn(true);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IFeatureManagementService.class, mockFeatureManagementService);
        Application.SELECTOR.setMock(mockPaymentAccountsSelector);
        NetsuiteIntegratorMiddlewareServiceImpl netsuiteIntegratorMiddlewareServiceInstance = new NetsuiteIntegratorMiddlewareServiceImpl();
        List<String> validationErrors = netsuiteIntegratorMiddlewareServiceInstance.performReadinessCheckValidations(
            paymentAccountId
        );
        System.assertEquals(
            validationErrors,
            new List<String>{ VALIDATION_ERROR_RECORD_TYPE },
            ASSERT_MESSAGE_VALIDATION_ERROR_NOT_RETURNED
        );
    }

    /**
     * @description To test validation error is returned
     * when Netsuite Id is present.
     */
    @isTest
    private static void testWhenNetsuiteIdPresentThenReturnValidationError() {
        Id paymentAccountId = fflib_IDGenerator.generate(Payment_Account__c.SObjectType);
        Fake paymentAccountFakeInstance = new Fake(Payment_Account__c.class)
            .setField(Payment_Account__c.Id, paymentAccountId)
            .setField(Payment_Account__c.NetSuite_ID__c, NETSUITE_ID)
            .setField(Payment_Account__c.recordTypeId, STORE_RECORD_TYPE_ID);
        Payment_Account__c paymentAccount = (Payment_Account__c) ServiceMockDataBuilder.convertToSObject(
            paymentAccountFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IFeatureManagementService mockFeatureManagementService = (IFeatureManagementService) mocks.mock(
            IFeatureManagementService.class
        );
        IPaymentAccountsSelector mockPaymentAccountsSelector = (IPaymentAccountsSelector) mocks.mock(
            IPaymentAccountsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockPaymentAccountsSelector.sObjectType())
            .thenReturn(Payment_Account__c.SObjectType);
        mocks.when(mockPaymentAccountsSelector.selectById(new Set<Id>{ paymentAccountId }))
            .thenReturn(new List<Payment_Account__c>{ paymentAccount });
        mocks.when(mockFeatureManagementService.checkPermission(ALLOW_SYNC_WITH_NETSUITE))
            .thenReturn(true);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IFeatureManagementService.class, mockFeatureManagementService);
        Application.SELECTOR.setMock(mockPaymentAccountsSelector);
        NetsuiteIntegratorMiddlewareServiceImpl netsuiteIntegratorMiddlewareServiceInstance = new NetsuiteIntegratorMiddlewareServiceImpl();
        List<String> validationErrors = netsuiteIntegratorMiddlewareServiceInstance.performReadinessCheckValidations(
            paymentAccountId
        );
        System.assertEquals(
            8,
            validationErrors.size(),
            ASSERT_MESSAGE_VALIDATION_ERROR_NOT_RETURNED
        );
    }

    /**
     * @description To test validation error is returned
     * when Netsuite Sync Status is 'Pending'.
     */
    @isTest
    private static void testWhenNetsuiteSyncStatusPendingThenReturnValidationError() {
        Id paymentAccountId = fflib_IDGenerator.generate(Payment_Account__c.SObjectType);
        Fake paymentAccountFakeInstance = new Fake(Payment_Account__c.class)
            .setField(Payment_Account__c.Id, paymentAccountId)
            .setField(Payment_Account__c.NetSuite_Sync_Status__c, PENDING_STATUS)
            .setField(Payment_Account__c.recordTypeId, STORE_RECORD_TYPE_ID);
        Payment_Account__c paymentAccount = (Payment_Account__c) ServiceMockDataBuilder.convertToSObject(
            paymentAccountFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IFeatureManagementService mockFeatureManagementService = (IFeatureManagementService) mocks.mock(
            IFeatureManagementService.class
        );
        IPaymentAccountsSelector mockPaymentAccountsSelector = (IPaymentAccountsSelector) mocks.mock(
            IPaymentAccountsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockPaymentAccountsSelector.sObjectType())
            .thenReturn(Payment_Account__c.SObjectType);
        mocks.when(mockPaymentAccountsSelector.selectById(new Set<Id>{ paymentAccountId }))
            .thenReturn(new List<Payment_Account__c>{ paymentAccount });
        mocks.when(mockFeatureManagementService.checkPermission(ALLOW_SYNC_WITH_NETSUITE))
            .thenReturn(true);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IFeatureManagementService.class, mockFeatureManagementService);
        Application.SELECTOR.setMock(mockPaymentAccountsSelector);
        NetsuiteIntegratorMiddlewareServiceImpl netsuiteIntegratorMiddlewareServiceInstance = new NetsuiteIntegratorMiddlewareServiceImpl();
        List<String> validationErrors = netsuiteIntegratorMiddlewareServiceInstance.performReadinessCheckValidations(
            paymentAccountId
        );
        System.assertEquals(
            validationErrors,
            new List<String>{ VALIDATION_ERROR_PENDING_STATUS },
            ASSERT_MESSAGE_VALIDATION_ERROR_NOT_RETURNED
        );
    }

    /**
     * @description To test validation errors are returned
     * when payment account fields are not populated.
     */
    @isTest
    private static void testWhenValidationFieldsNotPopulatedThenReturnValidationError() {
        Id paymentAccountId = fflib_IDGenerator.generate(Payment_Account__c.SObjectType);
        Fake paymentAccountFakeInstance = new Fake(Payment_Account__c.class)
            .setField(Payment_Account__c.Id, paymentAccountId)
            .setField(Payment_Account__c.Address_Line_1__c, ADDRESS_LINE1_VALUE)
            .setField(Payment_Account__c.State__c, STATE_VALUE)
            .setField(Payment_Account__c.City__c, CITY_VALUE)
            .setField(Payment_Account__c.recordTypeId, STORE_RECORD_TYPE_ID);
        Payment_Account__c paymentAccount = (Payment_Account__c) ServiceMockDataBuilder.convertToSObject(
            paymentAccountFakeInstance
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IFeatureManagementService mockFeatureManagementService = (IFeatureManagementService) mocks.mock(
            IFeatureManagementService.class
        );
        IPaymentAccountsSelector mockPaymentAccountsSelector = (IPaymentAccountsSelector) mocks.mock(
            IPaymentAccountsSelector.class
        );

        mocks.startStubbing();
        mocks.when(mockPaymentAccountsSelector.sObjectType())
            .thenReturn(Payment_Account__c.SObjectType);
        mocks.when(mockPaymentAccountsSelector.selectById(new Set<Id>{ paymentAccountId }))
            .thenReturn(new List<Payment_Account__c>{ paymentAccount });
        mocks.when(mockFeatureManagementService.checkPermission(ALLOW_SYNC_WITH_NETSUITE))
            .thenReturn(true);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IFeatureManagementService.class, mockFeatureManagementService);
        Application.SELECTOR.setMock(mockPaymentAccountsSelector);
        NetsuiteIntegratorMiddlewareServiceImpl netsuiteIntegratorMiddlewareServiceInstance = new NetsuiteIntegratorMiddlewareServiceImpl();
        List<String> result = netsuiteIntegratorMiddlewareServiceInstance.performReadinessCheckValidations(
            paymentAccountId
        );
        Set<String> validationErrors = new Set<String>();
        validationErrors.addAll(result);
        System.assertEquals(
            validationErrors,
            new Set<String>{
                VALIDATION_ERROR_BILLING_CONTACT_EMAIL,
                VALIDATION_ERROR_BILL_TO_COMPANY_NAME,
                VALIDATION_ERROR_COUNTRY_CODE_ALPHA2,
                VALIDATION_ERROR_ADDRESS,
                VALIDATION_ERROR_CURRENCY,
                VALIDATION_ERROR_PAYMENT_TERMS,
                VALIDATION_ERROR_DOORDASH_LEGAL_ENTITY,
                VALIDATION_ERROR_BUSINESS_UNIT
            },
            ASSERT_MESSAGE_VALIDATION_ERROR_NOT_RETURNED
        );
    }

    /**
     * @description To test validation error is returned
     * when CurrencyIsoCode on Payment Account is not matching with the DoorDash Legal Entity.
     */
    @isTest
    private static void testWhenCurrencyCodeNotMatchingWithDoordashLegalEntityThenReturnValidationError() {
        Id paymentAccountId = fflib_IDGenerator.generate(Payment_Account__c.SObjectType);
        Fake paymentAccountFakeInstance = new Fake(Payment_Account__c.class)
            .setField(Payment_Account__c.Id, paymentAccountId)
            .setField(Payment_Account__c.Address_Line_1__c, ADDRESS_LINE1_VALUE)
            .setField(Payment_Account__c.State__c, STATE_VALUE)
            .setField(Payment_Account__c.City__c, CITY_VALUE)
            .setField(Payment_Account__c.Payment_Terms__c, PAYMENT_TERM_NET_30)
            .setField(Payment_Account__c.recordTypeId, STORE_RECORD_TYPE_ID)
            .setField(Payment_Account__c.DoorDash_Legal_Entity__c, 'Doordash Inc')
            .setField(Payment_Account__c.CurrencyIsoCode, 'AUD');

        Payment_Account__c paymentAccount = (Payment_Account__c) ServiceMockDataBuilder.convertToSObject(
            paymentAccountFakeInstance
        );
        List<Legal_Entity_Mapping__mdt> customMetadataMocks = new List<Legal_Entity_Mapping__mdt>{
            new Legal_Entity_Mapping__mdt(
                Label = 'US',
                DeveloperName = 'United States',
                Legal_Entity_Name__c = 'Doordash Inc',
                Currency_ISO_Code__c = 'AUD'
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IFeatureManagementService mockFeatureManagementService = (IFeatureManagementService) mocks.mock(
            IFeatureManagementService.class
        );
        IPaymentAccountsSelector mockPaymentAccountsSelector = (IPaymentAccountsSelector) mocks.mock(
            IPaymentAccountsSelector.class
        );
        ILegalEntityMappingSelector mockLegalEntityMappingSelector = (ILegalEntityMappingSelector) mocks.mock(
            ILegalEntityMappingSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockPaymentAccountsSelector.sObjectType())
            .thenReturn(Payment_Account__c.SObjectType);
        mocks.when(mockPaymentAccountsSelector.selectById(new Set<Id>{ paymentAccountId }))
            .thenReturn(new List<Payment_Account__c>{ paymentAccount });
        mocks.when(mockLegalEntityMappingSelector.getAllValues()).thenReturn(customMetadataMocks);
        mocks.when(mockFeatureManagementService.checkPermission(ALLOW_SYNC_WITH_NETSUITE))
            .thenReturn(true);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IFeatureManagementService.class, mockFeatureManagementService);
        Application.SELECTOR.setMock(mockPaymentAccountsSelector);
        Application.SELECTOR.setMock(mockLegalEntityMappingSelector);
        NetsuiteIntegratorMiddlewareServiceImpl netsuiteIntegratorMiddlewareServiceInstance = new NetsuiteIntegratorMiddlewareServiceImpl();
        List<String> result = netsuiteIntegratorMiddlewareServiceInstance.performReadinessCheckValidations(
            paymentAccountId
        );
        Set<String> validationErrors = new Set<String>();
        validationErrors.addAll(result);
        System.assertEquals(
            validationErrors,
            new Set<String>{
                VALIDATION_ERROR_BILLING_CONTACT_EMAIL,
                VALIDATION_ERROR_BILL_TO_COMPANY_NAME,
                VALIDATION_ERROR_COUNTRY_CODE_ALPHA2,
                VALIDATION_ERROR_ADDRESS,
                VALIDATION_ERROR_BUSINESS_UNIT,
                VALIDATION_ERROR_CURRENCY_BY_LEGAL_ENTITY
            },
            ASSERT_MESSAGE_VALIDATION_ERROR_NOT_RETURNED
        );
    }

    /**
     * @description To test payment account Net Suite Sync Status is updated
     * and success message is returned when payment account is synced with Netsuite.
     */
    @isTest
    private static void testWhenNetsuiteSyncThenUpdatePaymentAccountAndReturnSuccessMessage() {
        Id paymentAccountId = fflib_IDGenerator.generate(Payment_Account__c.SObjectType);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IPaymentAccountIntegrationsService mockPaymentAccountIntegrationsService = (IPaymentAccountIntegrationsService) mocks.mock(
            IPaymentAccountIntegrationsService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(
                mockPaymentAccountIntegrationsService.publishPaymentAccountIntegrationEvents(
                    new Set<Id>{ paymentAccountId }
                )
            )
            .thenReturn(true);
        mocks.stopStubbing();
        Application.SERVICE.setMock(
            IPaymentAccountIntegrationsService.class,
            mockPaymentAccountIntegrationsService
        );
        Application.UNITOFWORK.setMock(mockUOW);
        NetsuiteIntegratorMiddlewareServiceImpl netsuiteIntegratorMiddlewareServiceInstance = new NetsuiteIntegratorMiddlewareServiceImpl();
        Map<String, Object> result = netsuiteIntegratorMiddlewareServiceInstance.syncWithNetsuite(
            paymentAccountId
        );
        netsuiteIntegratorMiddlewareServiceInstance.syncWithNetsuite(
            new Set<Id>{ paymentAccountId }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Payment_Account__c.Id => paymentAccountId,
                        Payment_Account__c.NetSuite_Sync_Status__c => PENDING_STATUS,
                        Payment_Account__c.Netsuite_Sync_Initiator__c => UserInfo.getUserId()
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
        System.assertEquals(
            new Map<String, Object>{ STATUS_KEY => SUCCESS_KEY, MESSAGE_KEY => SUCCESS_MESSAGE },
            result,
            ASSERT_MESSAGE_SUCCESS_MESSAGE_RETURNED
        );
    }

    /**
     * @description To test Exception is logged when DML exception occurs
     * while updating payment account.
     */
    @isTest
    private static void testWhenDMLExceptionThenCreateLog() {
        Id paymentAccountId = fflib_IDGenerator.generate(Payment_Account__c.SObjectType);
        String exceptionMessage;
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IPaymentAccountIntegrationsService mockPaymentAccountIntegrationsService = (IPaymentAccountIntegrationsService) mocks.mock(
            IPaymentAccountIntegrationsService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(
                mockPaymentAccountIntegrationsService.publishPaymentAccountIntegrationEvents(
                    new Set<Id>{ paymentAccountId }
                )
            )
            .thenReturn(true);
        ((fflib_ISObjectUnitOfWork) mocks.doThrowWhen(
                new TestCommitException(MOCK_EXCEPTION_MESSAGE),
                mockUOW
            ))
            .commitWork();
        mocks.stopStubbing();
        Application.SERVICE.setMock(
            IPaymentAccountIntegrationsService.class,
            mockPaymentAccountIntegrationsService
        );
        Application.UNITOFWORK.setMock(mockUOW);
        NetsuiteIntegratorMiddlewareServiceImpl netsuiteIntegratorMiddlewareServiceInstance = new NetsuiteIntegratorMiddlewareServiceImpl();
        try {
            netsuiteIntegratorMiddlewareServiceInstance.syncWithNetsuite(paymentAccountId);
            ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        } catch (Exception mockException) {
            exceptionMessage = mockException.getMessage();
        }
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Log__c.Detailed_Message__c => MOCK_EXCEPTION_MESSAGE,
                        Log__c.Severity_Level__c => LogEntry.SeverityLevel.HIGH.name()
                    }
                )
            );
    }

    /**
     * @author Deloitte
     * @date 18/10/2022
     * @description Exception class for customising exception on commitWork function for Tests.
     */
    class TestCommitException extends Exception {
    }
}