/**
 * @author Deloitte
 * @date 12/10/2022
 * @description Test class for NetsuiteIntegratorRestletServiceImpl class.
 * Suppressed Warnings since mock verify method does not require System Assert statements.
 */
@isTest(seeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class NetsuiteIntegratorRestletServiceImplTest {
    private static final String ASSERT_MESSAGE_SUCCESS_MSG_NOT_RETURNED = 'Unexpected result: success message is not returned.';
    private static final String DESCRIBE_NAME = 'Payment Account';
    private static final String PAYMENT_ACCOUNT_NETSUITE_ID = 'SyncWithNetsuiteTestNetsuiteId';
    private static final String SOBJECT_NAME = 'Payment_Account__c';
    private static final String ID_KEY = 'id';
    private static final String MESSAGE_KEY = 'message';
    private static final String STATUS_KEY = 'status';
    private static final String SUCCESS_KEY = 'success';
    private static final String SUCCESS_MESSAGE = System.Label.SYNC_WITH_NETSUITE_SUCCESS_MESSAGE;
    private static final String RESTRICT_ALLOW_SYNC_WITH_NETSUITE = System.Label.SYNC_WITH_NETSUITE_CUSTOM_PERMISSION;
    /**
     * @description To test when Payment Account Id is received then on successful sync with Netsuite
     * update the payment account and display success message.
     */
    @isTest
    private static void testWhenPaymentAccountSyncedSuccessfullyThenReturnSuccessMessage() {
        Contact contact = new Contact(
            Id = fflib_IDGenerator.generate(Contact.SObjectType),
            Email = 'randomJoe@domain.com'
        );
        Payment_Account__c paymentAccount = new Payment_Account__c(
            Id = fflib_IDGenerator.generate(Payment_Account__c.SObjectType),
            Address_Line_1__c = 'any street 0909',
            Postal_Code__c = '94808',
            Country__c = 'United States',
            Billing_Contact_Name__c = contact.Id,
            Billing_Contact_Name__r = contact,
            Currency__c = 'USD',
            Bill_To_Company_Name__c = 'any inc',
            State__c = 'theState',
            Payment_Terms__c = 'Net 30',
            City__c = 'Golden City'
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

        Map<String, Object> mockNetsuiteMessage = new Map<String, Object>{
            ID_KEY => PAYMENT_ACCOUNT_NETSUITE_ID,
            MESSAGE_KEY => SUCCESS_MESSAGE,
            STATUS_KEY => SUCCESS_KEY
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IOAuth1ConfigsSelector configSelectorMock = (IOAuth1ConfigsSelector) mocks.mock(
            IOAuth1ConfigsSelector.class
        );
        IPaymentAccountsSelector paSelectorMock = (IPaymentAccountsSelector) mocks.mock(
            IPaymentAccountsSelector.class
        );

        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        System.runAs(getSyncWithNetSuiteUser()){
            mocks.startStubbing();
            mocks.when(paSelectorMock.sObjectType()).thenReturn(Payment_Account__c.SObjectType);
            mocks.when(paSelectorMock.selectPaymentAccountByIdForNetsuiteIntegration(paymentAccount.Id))
                .thenReturn(paymentAccount);
            mocks.when(configSelectorMock.sObjectType()).thenReturn(OAuth_Config__c.SObjectType);
            mocks.when(configSelectorMock.getNetsuiteIntegrationDatamap()).thenReturn(dataMap);
            mocks.when(configSelectorMock.getNetsuiteIntegrationHeaders()).thenReturn(headers);
            mocks.stopStubbing();
            Application.UNITOFWORK.setMock(mockUOW);
            Application.SELECTOR.setMock(paSelectorMock);
            Application.SELECTOR.setMock(configSelectorMock);
            INetsuiteIntegrator nsIntegrator = new NetsuiteIntegratorRestletServiceImpl();
            Test.setMock(HttpCalloutMock.class, new NetsuiteIntegratorMockResponseGenerator());
            Test.startTest();
            Map<String, Object> netsuiteMessage = nsIntegrator.syncWithNetsuite(paymentAccount.Id);
            Test.stopTest();
            ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
                .registerDirty(
                    fflib_Match.sObjectWith(
                        new Map<SObjectField, Object>{
                            Payment_Account__c.Id => paymentAccount.Id,
                            Payment_Account__c.NetSuite_ID__c => PAYMENT_ACCOUNT_NETSUITE_ID,
                            Payment_Account__c.NetSuite_Sync_Response__c => null
                        }
                    )
                );
            ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
            System.assertEquals(
                netsuiteMessage,
                mockNetsuiteMessage,
                ASSERT_MESSAGE_SUCCESS_MSG_NOT_RETURNED
            );
        }
    }

    @isTest
    private static void testWhenProcessSyncWithNetsuiteWithPaymentRecordTypeFieldThenShouldReturnErrorMessage() {
        System.runAs(getSyncWithNetSuiteUser()){
            INetsuiteIntegrator nsIntegrator = new NetsuiteIntegratorRestletServiceImpl();
            List<String> validationErrorMessage;
            Payment_Account__c paymentAccount = new Payment_Account__c(
                Payment_Terms__c = 'Net 15',
                RecordTypeId = Schema.SObjectType.Payment_Account__c.getRecordTypeInfosByDeveloperName()
                    .get('Payments')
                    .getRecordTypeId()
            );
            insert paymentAccount;
            Test.startTest();
            validationErrorMessage = nsIntegrator.performReadinessCheckValidations(paymentAccount.Id);
            Test.stopTest();
            System.assertEquals(
                false,
                validationErrorMessage.isEmpty(),
                'System should return rediness failure message'
            );
        }
    }

    /**
     * @description This is method used to validate all required field validations.
     */
    @isTest
    private static void testWhenProcessSyncWithNetsuiteWithoutRequiredFieldThenShouldReturnErrorMessage() {
        System.runAs(getSyncWithNetSuiteUser()){
            INetsuiteIntegrator nsIntegrator = new NetsuiteIntegratorRestletServiceImpl();
            List<String> validationErrorMessage;
            Payment_Account__c paymentAccount = new Payment_Account__c(
                Payment_Terms__c = 'Net 15',
                RecordTypeId = Schema.SObjectType.Payment_Account__c.getRecordTypeInfosByDeveloperName()
                    .get('Invoice')
                    .getRecordTypeId()
            );
            insert paymentAccount;
            Test.startTest();
            validationErrorMessage = nsIntegrator.performReadinessCheckValidations(paymentAccount.Id);
            Test.stopTest();
            System.assertEquals(
                false,
                validationErrorMessage.isEmpty(),
                'System should return rediness failure message'
            );
        }
    }
    /**
     * @description This is method used to test for Sync With Netsuite with NetSuite Id
     */
    @isTest
    private static void testWhenProcessSyncWithNetsuiteWithExitingNetsuiteIdFieldThenShouldReturnErrorMessage() {
        INetsuiteIntegrator nsIntegrator = new NetsuiteIntegratorRestletServiceImpl();
        List<String> validationErrorMessage;
		System.runAs(getSyncWithNetSuiteUser()){
            Payment_Account__c paymentAccount = new Payment_Account__c(
                Payment_Terms__c = 'Net 15',
                NetSuite_ID__c = '12345',
                CurrencyIsoCode = null,
                RecordTypeId = Schema.SObjectType.Payment_Account__c.getRecordTypeInfosByDeveloperName()
                    .get('Invoice')
                    .getRecordTypeId()
            );
            insert paymentAccount;
            Test.startTest();
            validationErrorMessage = nsIntegrator.performReadinessCheckValidations(paymentAccount.Id);
            Test.stopTest();
            System.assertEquals(
                false,
                validationErrorMessage.isEmpty(),
                'System should return rediness failure message'
            );
        }
    }
    private static User getSyncWithNetSuiteUser(){
        PermissionSet netSuitePermissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'Allow_PA_Sync_With_Netsuite' LIMIT 1];
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User testUser = new User(Alias = 'test',
                      Email='testUser1@test.com',
                      EmailEncodingKey='UTF-8',
                      LastName='TestLastName',
                      LanguageLocaleKey='en_US',
                      LocaleSidKey='en_US',
                      ProfileId = testProfile.Id,
                      TimeZoneSidKey='America/Los_Angeles',
                      UserName='netsuitetestuser@test.com');
        Insert testUser;
		insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = netSuitePermissionSet.Id);
		return testUser;
    }
}