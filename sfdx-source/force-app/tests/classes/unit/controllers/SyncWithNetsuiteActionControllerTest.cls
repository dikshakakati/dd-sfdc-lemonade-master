/**
 * @author Deloitte
 * @date 12/10/2022
 * @description Test  class for SyncWithNetsuiteActionController class.
 * Suppressed Warnings since mock verify method does not require System Assert statements.
 */
@isTest(seeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
public class SyncWithNetsuiteActionControllerTest {
    private static final String ALLOW_SYNC_WITH_NETSUITE = System.Label.SYNC_WITH_NETSUITE_CUSTOM_PERMISSION;
    private static final String ASSERT_MESSAGE_ERROR_MSG_NOT_RETURNED = 'Unexpected result: error message is not returned.';
    private static final String ASSERT_MESSAGE_SUCCESS_MSG_NOT_RETURNED = 'Unexpected result: success message is not returned.';
    private static final String ERROR_KEY = 'error';
    private static final String MESSAGE_KEYWORD = 'message';
    private static final String RECORD_TYPE = 'Invoice';
    private static final String SCRIPT_THROWN_EXCEPTION = 'Script-thrown exception';
    private static final String STATUS_KEYWORD = 'status';
    private static final Id STORE_RECORD_TYPE_ID;
    private static final String SUCCESS_MESSAGE = System.Label.SYNC_WITH_NETSUITE_SUCCESS_MESSAGE;
    private static final String SUCCESS_STATUS = 'success';
    private static final String VALIDATION_PERMISSION_ISSUE = System.Label.PAYMENT_ACCOUNT_VALIDATION_ERROR_PERMISSION_SET;
    static {
        STORE_RECORD_TYPE_ID = Schema.SObjectType.Payment_Account__c.getRecordTypeInfosByDeveloperName()
            .get(RECORD_TYPE)
            .getRecordTypeId();
    }

    /**
     * @description To test when 'Restlet_API_Call__c' = True and 'Allow Sync With Netsuite'
     * permission set is not assigned to user then error message is returned.
     */
    @isTest
    private static void testWhenRestletApiCallTrueThenCallNetsuiteIntegratorRestletServiceImpl() {
        Sync_With_Netsuite_Process__c syncWithNetsuiteProcessCustomSetting = new Sync_With_Netsuite_Process__c();
        syncWithNetsuiteProcessCustomSetting.Restlet_API_Call__c = true;
        insert syncWithNetsuiteProcessCustomSetting;
        Id paymentAccountId = fflib_IDGenerator.generate(Payment_Account__c.SObjectType);
        Fake paymentAccountFakeInstance = new Fake(Payment_Account__c.class)
            .setField(Payment_Account__c.Id, paymentAccountId)
            .setField(Payment_Account__c.recordTypeId, STORE_RECORD_TYPE_ID);
        Payment_Account__c paymentAccount = (Payment_Account__c) ServiceMockDataBuilder.convertToSObject(
            paymentAccountFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IPaymentAccountsService mockPaymentAccountsService = (IPaymentAccountsService) mocks.mock(
            IPaymentAccountsService.class
        );
        IPaymentAccountsSelector mockPaymentAccountsSelector = (IPaymentAccountsSelector) mocks.mock(
            IPaymentAccountsSelector.class
        );
        IFeatureManagementService mockFeatureManagementService = (IFeatureManagementService) mocks.mock(
            IFeatureManagementService.class
        );
        List<String> errorMessages = new List<String>();
        errorMessages.add(VALIDATION_PERMISSION_ISSUE);
        mocks.startStubbing();
        mocks.when(mockPaymentAccountsSelector.sObjectType())
            .thenReturn(Payment_Account__c.SObjectType);
        mocks.when(mockPaymentAccountsSelector.selectById(new Set<Id>{ paymentAccountId }))
            .thenReturn(new List<Payment_Account__c>{ paymentAccount });
        mocks.when(mockFeatureManagementService.checkPermission(ALLOW_SYNC_WITH_NETSUITE))
            .thenReturn(false);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IPaymentAccountsService.class, mockPaymentAccountsService);
        Application.SERVICE.setMock(IFeatureManagementService.class, mockFeatureManagementService);
        Application.SELECTOR.setMock(mockPaymentAccountsSelector);
        String noAccessExceptionMessage;
        try {
            SyncWithNetsuiteActionController.syncWithNetsuite(paymentAccountId);
        } catch (AuraHandledException exceptionMessage) {
            noAccessExceptionMessage = exceptionMessage.getMessage();
        }
        System.assertEquals(
            SCRIPT_THROWN_EXCEPTION,
            noAccessExceptionMessage,
            ASSERT_MESSAGE_ERROR_MSG_NOT_RETURNED
        );
    }

    /**
     * @description To test when 'Restlet_API_Call__c' = False and 'Allow Sync With Netsuite'
     * permission set is not assigned to user then error message is returned.
     */
    @isTest
    private static void testWhenRestletApiCallFalseThenCallNetsuiteIntegratorMiddlewareServiceImpl() {
        Sync_With_Netsuite_Process__c syncWithNetsuiteProcessCustomSetting = new Sync_With_Netsuite_Process__c();
        syncWithNetsuiteProcessCustomSetting.Restlet_API_Call__c = false;
        insert syncWithNetsuiteProcessCustomSetting;
        Id paymentAccountId = fflib_IDGenerator.generate(Payment_Account__c.SObjectType);
        Fake paymentAccountFakeInstance = new Fake(Payment_Account__c.class)
            .setField(Payment_Account__c.Id, paymentAccountId)
            .setField(Payment_Account__c.recordTypeId, STORE_RECORD_TYPE_ID);
        Payment_Account__c paymentAccount = (Payment_Account__c) ServiceMockDataBuilder.convertToSObject(
            paymentAccountFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IPaymentAccountsService mockPaymentAccountsService = (IPaymentAccountsService) mocks.mock(
            IPaymentAccountsService.class
        );
        IPaymentAccountsSelector mockPaymentAccountsSelector = (IPaymentAccountsSelector) mocks.mock(
            IPaymentAccountsSelector.class
        );
        IFeatureManagementService mockFeatureManagementService = (IFeatureManagementService) mocks.mock(
            IFeatureManagementService.class
        );
        List<String> errorMessages = new List<String>();
        errorMessages.add(VALIDATION_PERMISSION_ISSUE);
        mocks.startStubbing();
        mocks.when(mockPaymentAccountsSelector.sObjectType())
            .thenReturn(Payment_Account__c.SObjectType);
        mocks.when(mockPaymentAccountsSelector.selectById(new Set<Id>{ paymentAccountId }))
            .thenReturn(new List<Payment_Account__c>{ paymentAccount });
        mocks.when(mockFeatureManagementService.checkPermission(ALLOW_SYNC_WITH_NETSUITE))
            .thenReturn(false);
        mocks.stopStubbing();
        Application.SERVICE.setMock(IPaymentAccountsService.class, mockPaymentAccountsService);
        Application.SERVICE.setMock(IFeatureManagementService.class, mockFeatureManagementService);
        Application.SELECTOR.setMock(mockPaymentAccountsSelector);
        String noAccessExceptionMessage;
        try {
            SyncWithNetsuiteActionController.syncWithNetsuite(paymentAccountId);
        } catch (AuraHandledException exceptionMessage) {
            noAccessExceptionMessage = exceptionMessage.getMessage();
        }
        System.assertEquals(
            SCRIPT_THROWN_EXCEPTION,
            noAccessExceptionMessage,
            ASSERT_MESSAGE_ERROR_MSG_NOT_RETURNED
        );
    }

    /**
     * @description To test when all Readiness validations passes then Payment Account is synced
     * and success message is returned.
     */
    @isTest
    private static void testWhenReadinessValidationsPassesThenReturnSuccessMessage() {
        Sync_With_Netsuite_Process__c syncWithNetsuiteProcessCustomSetting = new Sync_With_Netsuite_Process__c();
        syncWithNetsuiteProcessCustomSetting.Restlet_API_Call__c = true;
        insert syncWithNetsuiteProcessCustomSetting;

        Id paymentAccountId = fflib_IDGenerator.generate(Payment_Account__c.SObjectType);
        Contact con = new Contact(
            Id = fflib_IDGenerator.generate(Contact.SObjectType),
            Email = 'randomJoe@domain.com'
        );

        Fake paymentAccountFakeInstance = new Fake(Payment_Account__c.class)
            .setField(Payment_Account__c.Id, paymentAccountId)
            .setField(Payment_Account__c.Address_Line_1__c, 'any street 0909')
            .setField(Payment_Account__c.Postal_Code__c, '94808')
            .setField(Payment_Account__c.Country__c, 'United States')
            .setField(Payment_Account__c.Billing_Contact_Name__c, con.Id)
            .setField(Payment_Account__c.Currency__c, 'USD')
            .setField(Payment_Account__c.Country_Code_Alpha_2__c, '12')
            .setField(Payment_Account__c.CurrencyIsoCode, 'USD')
            .setField(Payment_Account__c.Billing_Contact_Email__c, 'randomJoe@domain.com')
            .setField(Payment_Account__c.Bill_To_Company_Name__c, 'any inc')
            .setField(Payment_Account__c.State__c, 'theState')
            .setField(Payment_Account__c.Payment_Terms__c, 'Net 30')
            .setField(Payment_Account__c.City__c, 'Golden City')
            .setField(Payment_Account__c.recordTypeId, STORE_RECORD_TYPE_ID);
        Payment_Account__c paymentAccount = (Payment_Account__c) ServiceMockDataBuilder.convertToSObject(
            paymentAccountFakeInstance
        );

        List<OAuth_Config__c> dataMap = new List<OAuth_Config__c>{
            new OAuth_Config__c(
                Id = fflib_IDGenerator.generate(OAuth_Config__c.SObjectType),
                Key__c = 'Address_Line_1__c',
                Value__c = 'address.addr1'
            ),
            new OAuth_Config__c(
                Id = fflib_IDGenerator.generate(OAuth_Config__c.SObjectType),
                Key__c = 'Postal_Code__c',
                Value__c = 'address.zip'
            ),
            new OAuth_Config__c(
                Id = fflib_IDGenerator.generate(OAuth_Config__c.SObjectType),
                Key__c = 'Country_Code_Alpha_2__c',
                Value__c = 'address.country'
            ),
            new OAuth_Config__c(
                Id = fflib_IDGenerator.generate(OAuth_Config__c.SObjectType),
                Key__c = 'Billing_Contact_Email__c',
                Value__c = 'email'
            ),
            new OAuth_Config__c(
                Id = fflib_IDGenerator.generate(OAuth_Config__c.SObjectType),
                Key__c = 'NetSuite_Subsidiary__c',
                Value__c = 'subsidiaryId'
            ),
            new OAuth_Config__c(
                Id = fflib_IDGenerator.generate(OAuth_Config__c.SObjectType),
                Key__c = 'NetSuite_Currency__c',
                Value__c = 'currencyId'
            ),
            new OAuth_Config__c(
                Id = fflib_IDGenerator.generate(OAuth_Config__c.SObjectType),
                Key__c = 'Bill_To_Company_Name__c',
                Value__c = 'company_name'
            ),
            new OAuth_Config__c(
                Id = fflib_IDGenerator.generate(OAuth_Config__c.SObjectType),
                Key__c = 'State__c',
                Value__c = 'address.state'
            ),
            new OAuth_Config__c(
                Id = fflib_IDGenerator.generate(OAuth_Config__c.SObjectType),
                Key__c = 'NetSuite_Payment_Terms__c',
                Value__c = 'term_id'
            ),
            new OAuth_Config__c(
                Id = fflib_IDGenerator.generate(OAuth_Config__c.SObjectType),
                Key__c = 'City__c',
                Value__c = 'address.city'
            )
        };

        List<OAuth_Config__c> headers = new List<OAuth_Config__c>{
            new OAuth_Config__c(
                Id = fflib_IDGenerator.generate(OAuth_Config__c.SObjectType),
                Include_In_Authorization__c = true,
                Include_In_Header__c = false,
                Include_In_Signature__c = false,
                Key__c = 'realm',
                Value__c = '',
                Encrypted_Value__c = 'therealm',
                Value_Encrypted__c = true,
                Value_Generated__c = false
            ),
            new OAuth_Config__c(
                Id = fflib_IDGenerator.generate(OAuth_Config__c.SObjectType),
                Include_In_Authorization__c = true,
                Include_In_Header__c = false,
                Include_In_Signature__c = false,
                Key__c = 'oauth_signature',
                Value__c = '',
                Encrypted_Value__c = '',
                Value_Encrypted__c = false,
                Value_Generated__c = true
            ),
            new OAuth_Config__c(
                Id = fflib_IDGenerator.generate(OAuth_Config__c.SObjectType),
                Include_In_Authorization__c = true,
                Include_In_Header__c = false,
                Include_In_Signature__c = true,
                Key__c = 'oauth_signature_method',
                Value__c = 'HMAC-SHA256',
                Encrypted_Value__c = '',
                Value_Encrypted__c = false,
                Value_Generated__c = false
            ),
            new OAuth_Config__c(
                Id = fflib_IDGenerator.generate(OAuth_Config__c.SObjectType),
                Include_In_Authorization__c = false,
                Include_In_Header__c = false,
                Include_In_Signature__c = false,
                Key__c = 'consumerSecret',
                Value__c = '',
                Encrypted_Value__c = 'theconsumersecret',
                Value_Encrypted__c = true,
                Value_Generated__c = false
            ),
            new OAuth_Config__c(
                Id = fflib_IDGenerator.generate(OAuth_Config__c.SObjectType),
                Include_In_Authorization__c = true,
                Include_In_Header__c = false,
                Include_In_Signature__c = true,
                Key__c = 'oauth_timestamp',
                Value__c = '',
                Encrypted_Value__c = '',
                Value_Encrypted__c = false,
                Value_Generated__c = true
            ),
            new OAuth_Config__c(
                Id = fflib_IDGenerator.generate(OAuth_Config__c.SObjectType),
                Include_In_Authorization__c = false,
                Include_In_Header__c = false,
                Include_In_Signature__c = false,
                Key__c = 'method',
                Value__c = 'POST',
                Encrypted_Value__c = '',
                Value_Encrypted__c = false,
                Value_Generated__c = false
            ),
            new OAuth_Config__c(
                Id = fflib_IDGenerator.generate(OAuth_Config__c.SObjectType),
                Include_In_Authorization__c = true,
                Include_In_Header__c = false,
                Include_In_Signature__c = true,
                Key__c = 'oauth_consumer_key',
                Value__c = '',
                Encrypted_Value__c = 'theoauthconsumerkey',
                Value_Encrypted__c = true,
                Value_Generated__c = false
            ),
            new OAuth_Config__c(
                Id = fflib_IDGenerator.generate(OAuth_Config__c.SObjectType),
                Include_In_Authorization__c = false,
                Include_In_Header__c = false,
                Include_In_Signature__c = false,
                Key__c = 'tokenSecret',
                Value__c = '',
                Encrypted_Value__c = 'thetokensecret',
                Value_Encrypted__c = true,
                Value_Generated__c = false
            ),
            new OAuth_Config__c(
                Id = fflib_IDGenerator.generate(OAuth_Config__c.SObjectType),
                Include_In_Authorization__c = true,
                Include_In_Header__c = false,
                Include_In_Signature__c = true,
                Key__c = '1.0',
                Value__c = 'oauth_version',
                Encrypted_Value__c = '',
                Value_Encrypted__c = false,
                Value_Generated__c = false
            ),
            new OAuth_Config__c(
                Id = fflib_IDGenerator.generate(OAuth_Config__c.SObjectType),
                Include_In_Authorization__c = true,
                Include_In_Header__c = false,
                Include_In_Signature__c = true,
                Key__c = 'oauth_token',
                Value__c = '',
                Encrypted_Value__c = 'theoauthtoken',
                Value_Encrypted__c = true,
                Value_Generated__c = false
            ),
            new OAuth_Config__c(
                Id = fflib_IDGenerator.generate(OAuth_Config__c.SObjectType),
                Include_In_Authorization__c = false,
                Include_In_Header__c = true,
                Include_In_Signature__c = false,
                Key__c = 'authorization',
                Value__c = '',
                Encrypted_Value__c = '',
                Value_Encrypted__c = false,
                Value_Generated__c = true
            ),
            new OAuth_Config__c(
                Id = fflib_IDGenerator.generate(OAuth_Config__c.SObjectType),
                Include_In_Authorization__c = false,
                Include_In_Header__c = true,
                Include_In_Signature__c = false,
                Key__c = 'content_type',
                Value__c = 'application/json',
                Encrypted_Value__c = '',
                Value_Encrypted__c = false,
                Value_Generated__c = false
            ),
            new OAuth_Config__c(
                Id = fflib_IDGenerator.generate(OAuth_Config__c.SObjectType),
                Include_In_Authorization__c = false,
                Include_In_Header__c = true,
                Include_In_Signature__c = false,
                Key__c = 'oauth_nonce',
                Value__c = '',
                Encrypted_Value__c = '',
                Value_Encrypted__c = false,
                Value_Generated__c = true
            ),
            new OAuth_Config__c(
                Id = fflib_IDGenerator.generate(OAuth_Config__c.SObjectType),
                Include_In_Authorization__c = false,
                Include_In_Header__c = false,
                Include_In_Signature__c = true,
                Key__c = 'url',
                Value__c = 'https://3938860-sb4.restlets.api.netsuite.com/app/site/hosting/restlet.nl?script=592&deploy=1',
                Encrypted_Value__c = '',
                Value_Encrypted__c = false,
                Value_Generated__c = false
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IPaymentAccountsService mockPaymentAccountsService = (IPaymentAccountsService) mocks.mock(
            IPaymentAccountsService.class
        );
        IFeatureManagementService mockFeatureManagementService = (IFeatureManagementService) mocks.mock(
            IFeatureManagementService.class
        );
        IOAuth1ConfigsSelector configSelectorMock = (IOAuth1ConfigsSelector) mocks.mock(
            IOAuth1ConfigsSelector.class
        );
        IPaymentAccountsSelector paSelectorMock = (IPaymentAccountsSelector) mocks.mock(
            IPaymentAccountsSelector.class
        );

        Map<String, Object> mockSuccessMessage = new Map<String, Object>();
        mockSuccessMessage.put(STATUS_KEYWORD, SUCCESS_STATUS);
        mockSuccessMessage.put(MESSAGE_KEYWORD, SUCCESS_MESSAGE);
        IPaymentAccountsSelector mockPaymentAccountsSelector = (IPaymentAccountsSelector) mocks.mock(
            IPaymentAccountsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockPaymentAccountsSelector.selectById(new Set<Id>{ paymentAccountId }))
            .thenReturn(new List<Payment_Account__c>{ paymentAccount });
        mocks.when(mockFeatureManagementService.checkPermission(ALLOW_SYNC_WITH_NETSUITE))
            .thenReturn(true);
        mocks.when(paSelectorMock.sObjectType()).thenReturn(Payment_Account__c.SObjectType);
        mocks.when(paSelectorMock.selectPaymentAccountByIdForNetsuiteIntegration(paymentAccountId))
            .thenReturn(paymentAccount);
        mocks.when(configSelectorMock.sObjectType()).thenReturn(OAuth_Config__c.SObjectType);
        mocks.when(configSelectorMock.getNetsuiteIntegrationDatamap()).thenReturn(dataMap);
        mocks.when(configSelectorMock.getNetsuiteIntegrationHeaders()).thenReturn(headers);
        mocks.stopStubbing();

        Application.SERVICE.setMock(IPaymentAccountsService.class, mockPaymentAccountsService);
        Application.SERVICE.setMock(IFeatureManagementService.class, mockFeatureManagementService);
        Application.SELECTOR.setMock(paSelectorMock);
        Application.SELECTOR.setMock(configSelectorMock);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NetsuiteIntegratorMockResponseGenerator());
        Map<String, Object> successMessage = SyncWithNetsuiteActionController.syncWithNetsuite(
            paymentAccountId
        );
        Test.stopTest();
        System.assertEquals(
            mockSuccessMessage,
            successMessage,
            ASSERT_MESSAGE_SUCCESS_MSG_NOT_RETURNED
        );
    }
}