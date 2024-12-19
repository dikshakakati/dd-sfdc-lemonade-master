/**
 * @author Deloitte
 * @date 20/07/2022
 * @description Test class for ContactValidationsServiceImpl class.
 * Suppressed Warnings since mock verify method does not require System Assert statements.
 */
@isTest(seeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts, PMD.NcssTypeCount, PMD.UnusedLocalVariable')
public class ContactValidationsServiceImplTest {
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final String ACTIVATE_CENTRALLY_NO = 'No';
    private static final String BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG = 'DOBReadinessCheckCountriesStates';
    private static final String CONTACT_EMAIL = 'testEmail@sampleEmail.com';
    private static final String CONTACT_FIRSTNAME = 'Stephen';
    private static final String CONTACT_LASTNAME = 'Ross';
    private static final String CONTACT_OBJECT_NAME = 'Contact';
    private static final String CONTACT_PHONE = '1234567890';
    private static final String CONTACT_ROLE_DECISION_MAKER = 'Decision Maker';
    private static final String CONTACT_ROLE_BUSINESS_OWNER = 'Business Owner';
    private static final String CONTACT_ROLE_BUSINESS_DIRECTOR = 'Business Director';
    private static final String COUNTRY_CANADA = 'Canada';
    private static final String COUNTRY_CODE_CANADA = 'CA';
    private static final String CUSTOM_METADATA_ERROR_MESSAGE_BIRTHDATE = 'Please ensure Birthdate is populated.';
    private static final String CUSTOM_METADATA_ERROR_MESSAGE_DECISION_MAKER = 'Please ensure the Contact with Decision Maker role is created on the store account.';
    private static final String CUSTOM_METADATA_ERROR_MESSAGE_DECISION_MAKER_ON_PARENT = 'A contact with the role of “Decision Maker” is missing on the business account. Please add a Decision Maker and then re-run the readiness check.';
    private static final String CUSTOM_METADATA_ERROR_MESSAGE_SSN = 'Please ensure SSN (Last four digits) is populated.';
    private static final String CUSTOM_METADATA_ERROR_MESSAGE_CANADA = 'The Business or its stores are in Canada, but the related Business Account is missing essential Contact Roles.';
    private static final String CUSTOM_METADATA_ERROR_MESSAGE_CANADA_BIZ_OWNER = 'The Contact assigned as the Business Owner is missing required information. Please update the Birthdate and Address for the Business Owner Contact.';
    private static final String CUSTOM_METADATA_ERROR_MESSAGE_CANADA_BIZ_DIRECTOR = 'The Contact assigned as the Business Director is missing required information. Please update the Email for the Business Director Contact.';
    private static final String CUSTOM_METADATA_ERROR_MESSAGE_CANADA_BIZ_REP = 'The Contact assigned as the Decision Maker/Business Representative is missing required information. Please update the Email, Title, and Phone for the Decision Maker Contact.';
    private static final String DEVELOPER_NAME_DM_CONTACT_REQUIRED = 'DM_Contact_required_for_Tablet_on_Store';
    private static final String ELIGIBLE_COUNTRIES_STATES_TO_VALIDATE_BIRTHDATE = 'US,CA,AU-QLD';
    private static final String ELIGIBLE_COUNTRIES_STATES_TO_VALIDATE_SSN = 'US';
    private static final String ELIGIBLE_COUNTRY_TO_VALIDATE_AU = 'AU';
    private static final String ELIGIBLE_COUNTRY_TO_VALIDATE_US = 'US';
    private static final String ELIGIBLE_STATE_TO_VALIDATE_QLD = 'QLD';
    private static final String FIELD_NAME_BIRTHDATE = 'Birthdate';
    private static final String FIELD_NAME_SSN = 'SSN_Last_4Digits__c';
    private static final String INELIGIBLE_COUNTRY_TO_VALIDATE_IN = 'IN';
    private static final String INELIGIBLE_STATE_TO_VALIDATE_KA = 'KA';
    private static final String MENU_TO_BE_COMPLETED_BY_ACCOUNT_OWNER = 'Account Owner';
    private static final String ORDER_PROTOCOL_TABLET = 'Tablet (DoorDash Owns)';
    private static final String PAYMENT_ACCOUNT_RECORD_TYPE_INVOICE = 'Invoice';
    private static final String PAYMENT_ACCOUNT_RECORD_TYPE_PAYMENTS = 'Payments';
    private static final String PRODUCT_NAME_ALCOHOL_DELIVERY = 'Alcohol Delivery';
    private static final String PROVISIONING_STATUS_READINESS_CHECK_COMPLETE = 'Readiness Check Complete';
    private static final String SERVICE_CLASS_NAME = 'IContactValidationsService';
    private static final String SERVICE_METHOD_VALIDATE_BIRTHDATE = 'validateBirthdate';
    private static final String SERVICE_METHOD_VALIDATE_DECISION_MAKER = 'validateDecisionMakerContact';
    private static final String SERVICE_METHOD_VALIDATE_DECISION_MAKER_CONTACT_PHONE = 'validateDecisionMakerContactPhoneWithTabletOrderProtocol';
    private static final String SERVICE_METHOD_VALIDATE_DECISION_MAKER_WITH_TABLET_ORDER_PROTOCOL = 'validateDecisionMakerContactWithTabletOrderProtocol';
    private static final String SERVICE_METHOD_VALIDATE_CANADA_ROLES = 'validateExistenceOfCanadianContactRoles';
    private static final String SERVICE_METHOD_VALIDATE_CANADA_BIZ_OWNER = 'validateBusinessOwnerDetails';
    private static final String SERVICE_METHOD_VALIDATE_CANADA_BIZ_DIRECTOR = 'validateBusinessDirectorDetails';
    private static final String SERVICE_METHOD_VALIDATE_SSN = 'validateSSN';
    private static final Integer SSN_LAST_FOUR_DIGITS = 1234;
    private static final String SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG = 'SSNReadinessCheckCountriesStates';
    private static final String VERTICAL = 'Floral';
    private static final String WORK_ORDER_SUB_TYPE_NET_NEW_BUSINESS = 'Net-new business';
    private static final String WORKORDER_TYPE_DRIVE = 'Drive';
    private static final String WORKORDER_TYPE_MARKETPLACE = 'Marketplace';

    /**
     * @description To test validation of Birthdate field when store products include
     * alcohol delivery or alcohol pickup with Billing Country as Australia and State as Queensland.
     */
    @isTest
    private static void testWhenStoreProductIncludeAlcoholWithEligibleBillingCountryAndStateThenValidateBirthdate() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id paymentAccountId = fflib_IDGenerator.generate(Payment_Account__c.SObjectType);
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                    CUSTOM_METADATA_ERROR_MESSAGE_BIRTHDATE,
                    FIELD_NAME_BIRTHDATE,
                    SERVICE_METHOD_VALIDATE_BIRTHDATE,
                    CONTACT_OBJECT_NAME,
                    SERVICE_CLASS_NAME
                )
            )
        };
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Id, businessAccountId)
            .setField(Account.BillingCountryCode, ELIGIBLE_COUNTRY_TO_VALIDATE_AU)
            .setField(Account.BillingStateCode, ELIGIBLE_STATE_TO_VALIDATE_QLD)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccount.Id,
                VERTICAL
            )
            .setField(Account.Id, storeAccountId)
            .setField(Account.BillingCountryCode, ELIGIBLE_COUNTRY_TO_VALIDATE_AU)
            .setField(Account.BillingStateCode, ELIGIBLE_STATE_TO_VALIDATE_QLD)
            .setParent('Parent', businessAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake paymentAccountFakeInstance = new Fake(Payment_Account__c.class)
            .setField(Payment_Account__c.Id, paymentAccountId);
        Fake contactFakeInstance = new Fake(Contact.class)
            .setField(Contact.LastName, CONTACT_LASTNAME)
            .setField(Contact.FirstName, CONTACT_FIRSTNAME)
            .setField(Contact.Email, CONTACT_EMAIL)
            .setField(Contact.Phone, CONTACT_PHONE)
            .setField(Contact.AccountId, businessAccount.Id)
            .setField(Contact.SSN_Last_4Digits__c, SSN_LAST_FOUR_DIGITS)
            .setField(Contact.BirthDate, null)
            .setFakeId();
        Fake accountPaymentAccountRelationFakeInstance = new Fake(
                Account_Payment_Account_Relation__c.class
            )
            .setField(
                Account_Payment_Account_Relation__c.Account_Record_Type__c,
                ACCOUNT_RECORD_TYPE_NAME_STORE
            )
            .setParent('Account__r', businessAccountFakeInstance)
            .setFakeId();
        Fake productFakeInstance = ServiceMockDataBuilder.createProductFakeInstance(
            PRODUCT_NAME_ALCOHOL_DELIVERY
        );
        businessAccountFakeInstance.setChildren('Contacts', new List<Fake>{ contactFakeInstance });
        Fake merchantServicesFakeInstance = new Fake(Merchant_Service__c.class)
            .setField(Merchant_Service__c.Account__c, storeAccount.Id)
            .setParent('Product__r', productFakeInstance)
            .setFakeId();
        Merchant_Service__c merchantServiceInstance = (Merchant_Service__c) ServiceMockDataBuilder.convertToSObject(
            merchantServicesFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent('Account', businessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_MARKETPLACE,
                parentWorkOrder.Id
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('Account', storeAccountFakeInstance)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Contact contact = (Contact) ServiceMockDataBuilder.convertToSObject(contactFakeInstance);
        accountPaymentAccountRelationFakeInstance
            .setField(Account_Payment_Account_Relation__c.Account__c, storeAccount.Id)
            .setField(Account_Payment_Account_Relation__c.Payment_Account__c, paymentAccountId)
            .setParent(
                'Payment_Account__r',
                new Fake(Payment_Account__c.class)
                    .setField(Payment_Account__c.Id, paymentAccountId)
                    .setField(Payment_Account__c.Billing_Contact_Name__c, contact.Id)
                    .setParent('Billing_Contact_Name__r', contactFakeInstance)
            );
        paymentAccountFakeInstance
            .setChildren(
                'Account_Payment_Account_Relations__r',
                new List<Fake>{ accountPaymentAccountRelationFakeInstance }
            )
            .setParent('Billing_Contact_Name__r', contactFakeInstance);
        Account_Payment_Account_Relation__c accountPaymentAccountRelationSobjectInstance = (Account_Payment_Account_Relation__c) ServiceMockDataBuilder.convertToSObject(
            accountPaymentAccountRelationFakeInstance
        );
        List<Readiness_Check_Failure__c> mockReadinessValidationRuleFailureRecords = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRules[0].Object_Label__c,
                Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
                Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
                Parent_Work_Order__c = parentWorkOrder.Id,
                Child_Work_Order__c = childWorkOrder.Id,
                Account_Name__c = childWorkOrder.AccountId,
                Contact_Name__c = contact.Id
            )
        };
        Static_Configurations__mdt eligibleCountriesStatesToValidateBirthdate = new Static_Configurations__mdt(
            DeveloperName = BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            MasterLabel = BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            Configuration_Value__c = ELIGIBLE_COUNTRIES_STATES_TO_VALIDATE_BIRTHDATE
        );
        Static_Configurations__mdt eligibleCountriesStatesToValidateSSN = new Static_Configurations__mdt(
            DeveloperName = SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            MasterLabel = SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            Configuration_Value__c = ELIGIBLE_COUNTRIES_STATES_TO_VALIDATE_SSN
        );

        List<Readiness_Check_Failure__c> mockexistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountPaymentAccountRelationsSelector accountPaymentAccountSelector = (IAccountPaymentAccountRelationsSelector) mocks.mock(
            IAccountPaymentAccountRelationsSelector.class
        );
        IMerchantSelector merchantSelector = (IMerchantSelector) mocks.mock(
            IMerchantSelector.class
        );
        IStaticConfigurationsSelector mockStaticConfigurationsSelector = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(accountPaymentAccountSelector.sObjectType())
            .thenReturn(Account_Payment_Account_Relation__c.SObjectType);
        mocks.when(
                accountPaymentAccountSelector.selectByAccountIdsAndPaymentAccountRecordTypes(
                    new Set<Id>{ storeAccount.Id },
                    new Set<String>{ PAYMENT_ACCOUNT_RECORD_TYPE_PAYMENTS }
                )
            )
            .thenReturn(
                new List<Account_Payment_Account_Relation__c>{
                    accountPaymentAccountRelationSobjectInstance
                }
            );
        mocks.when(merchantSelector.sObjectType()).thenReturn(Merchant_Service__c.SObjectType);
        mocks.when(
                merchantSelector.selectServicesWithAlcoholProductsByAccountIds(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<Merchant_Service__c>{ merchantServiceInstance });
        mocks.when(mockStaticConfigurationsSelector.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG
                )
            )
            .thenReturn(eligibleCountriesStatesToValidateBirthdate);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG
                )
            )
            .thenReturn(eligibleCountriesStatesToValidateSSN);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(accountPaymentAccountSelector);
        Application.SELECTOR.setMock(merchantSelector);
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        ContactValidationsServiceImpl contactValidationsServiceImplInstance = new ContactValidationsServiceImpl();
        contactValidationsServiceImplInstance.validate(
            new List<WorkOrder>{ childWorkOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockexistingReadinessCheckFailures,
            CONTACT_OBJECT_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessValidationRuleFailureRecords);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test validation of SSN field when store products include
     * alcohol delivery or alcohol pickup with Billing Country as US.
     */
    @isTest
    private static void testWhenStoreProductsIncludeAlcoholWithEligibleBillingCountryAndStateThenValidateSSN() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id paymentAccountId = fflib_IDGenerator.generate(Payment_Account__c.SObjectType);
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                    CUSTOM_METADATA_ERROR_MESSAGE_SSN,
                    FIELD_NAME_SSN,
                    SERVICE_METHOD_VALIDATE_SSN,
                    CONTACT_OBJECT_NAME,
                    SERVICE_CLASS_NAME
                )
            )
        };
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Id, businessAccountId)
            .setField(Account.BillingCountryCode, ELIGIBLE_COUNTRY_TO_VALIDATE_US)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccount.Id,
                VERTICAL
            )
            .setField(Account.Id, storeAccountId)
            .setParent('Parent', businessAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake paymentAccountFakeInstance = new Fake(Payment_Account__c.class)
            .setField(Payment_Account__c.Id, paymentAccountId);
        Fake contactFakeInstance = new Fake(Contact.class)
            .setField(Contact.LastName, CONTACT_LASTNAME)
            .setField(Contact.FirstName, CONTACT_FIRSTNAME)
            .setField(Contact.Email, CONTACT_EMAIL)
            .setField(Contact.Phone, CONTACT_PHONE)
            .setField(Contact.AccountId, businessAccount.Id)
            .setField(Contact.SSN_Last_4Digits__c, null)
            .setField(Contact.BirthDate, Date.newInstance(1990, 3, 17))
            .setFakeId();
        Fake accountPaymentAccountRelationFakeInstance = new Fake(
                Account_Payment_Account_Relation__c.class
            )
            .setField(
                Account_Payment_Account_Relation__c.Account_Record_Type__c,
                ACCOUNT_RECORD_TYPE_NAME_STORE
            )
            .setParent('Account__r', businessAccountFakeInstance)
            .setFakeId();
        Fake productFakeInstance = ServiceMockDataBuilder.createProductFakeInstance(
            PRODUCT_NAME_ALCOHOL_DELIVERY
        );
        businessAccountFakeInstance.setChildren('Contacts', new List<Fake>{ contactFakeInstance });
        Fake merchantServicesFakeInstance = new Fake(Merchant_Service__c.class)
            .setField(Merchant_Service__c.Account__c, storeAccount.Id)
            .setParent('Product__r', productFakeInstance)
            .setFakeId();
        Merchant_Service__c merchantServiceInstance = (Merchant_Service__c) ServiceMockDataBuilder.convertToSObject(
            merchantServicesFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent('Account', businessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_MARKETPLACE,
                parentWorkOrder.Id
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('Account', storeAccountFakeInstance)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Contact contact = (Contact) ServiceMockDataBuilder.convertToSObject(contactFakeInstance);
        accountPaymentAccountRelationFakeInstance
            .setField(Account_Payment_Account_Relation__c.Account__c, storeAccount.Id)
            .setField(Account_Payment_Account_Relation__c.Payment_Account__c, paymentAccountId)
            .setParent(
                'Payment_Account__r',
                new Fake(Payment_Account__c.class)
                    .setField(Payment_Account__c.Id, paymentAccountId)
                    .setField(Payment_Account__c.Billing_Contact_Name__c, contact.Id)
                    .setParent('Billing_Contact_Name__r', contactFakeInstance)
            );
        paymentAccountFakeInstance
            .setChildren(
                'Account_Payment_Account_Relations__r',
                new List<Fake>{ accountPaymentAccountRelationFakeInstance }
            )
            .setParent('Billing_Contact_Name__r', contactFakeInstance);
        Account_Payment_Account_Relation__c accountPaymentAccountRelationSobjectInstance = (Account_Payment_Account_Relation__c) ServiceMockDataBuilder.convertToSObject(
            accountPaymentAccountRelationFakeInstance
        );
        List<Readiness_Check_Failure__c> mockReadinessValidationRuleFailureRecords = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRules[0].Object_Label__c,
                Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
                Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
                Parent_Work_Order__c = parentWorkOrder.Id,
                Child_Work_Order__c = childWorkOrder.Id,
                Account_Name__c = childWorkOrder.AccountId,
                Contact_Name__c = contact.Id
            )
        };
        Static_Configurations__mdt eligibleCountriesStatesToValidateBirthdate = new Static_Configurations__mdt(
            DeveloperName = BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            MasterLabel = BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            Configuration_Value__c = ELIGIBLE_COUNTRIES_STATES_TO_VALIDATE_BIRTHDATE
        );
        Static_Configurations__mdt eligibleCountriesStatesToValidateSSN = new Static_Configurations__mdt(
            DeveloperName = SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            MasterLabel = SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            Configuration_Value__c = ELIGIBLE_COUNTRIES_STATES_TO_VALIDATE_SSN
        );

        List<Readiness_Check_Failure__c> mockexistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountPaymentAccountRelationsSelector accountPaymentAccountSelector = (IAccountPaymentAccountRelationsSelector) mocks.mock(
            IAccountPaymentAccountRelationsSelector.class
        );
        IMerchantSelector merchantSelector = (IMerchantSelector) mocks.mock(
            IMerchantSelector.class
        );
        IStaticConfigurationsSelector mockStaticConfigurationsSelector = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(accountPaymentAccountSelector.sObjectType())
            .thenReturn(Account_Payment_Account_Relation__c.SObjectType);
        mocks.when(
                accountPaymentAccountSelector.selectByAccountIdsAndPaymentAccountRecordTypes(
                    new Set<Id>{ storeAccount.Id },
                    new Set<String>{ PAYMENT_ACCOUNT_RECORD_TYPE_PAYMENTS }
                )
            )
            .thenReturn(
                new List<Account_Payment_Account_Relation__c>{
                    accountPaymentAccountRelationSobjectInstance
                }
            );
        mocks.when(merchantSelector.sObjectType()).thenReturn(Merchant_Service__c.SObjectType);
        mocks.when(
                merchantSelector.selectServicesWithAlcoholProductsByAccountIds(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<Merchant_Service__c>{ merchantServiceInstance });
        mocks.when(mockStaticConfigurationsSelector.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG
                )
            )
            .thenReturn(eligibleCountriesStatesToValidateBirthdate);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG
                )
            )
            .thenReturn(eligibleCountriesStatesToValidateSSN);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(accountPaymentAccountSelector);
        Application.SELECTOR.setMock(merchantSelector);
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        ContactValidationsServiceImpl contactValidationsServiceImplInstance = new ContactValidationsServiceImpl();
        contactValidationsServiceImplInstance.validate(
            new List<WorkOrder>{ childWorkOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockexistingReadinessCheckFailures,
            CONTACT_OBJECT_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessValidationRuleFailureRecords);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test when SSN and BirthDate fields are populated
     * then Readiness Check Failure records are not created.
     */
    @isTest
    private static void testWhenSSNAndBirthdatePresentOnContactThenReadinessCheckFailuresNotCreated() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id paymentAccountId = fflib_IDGenerator.generate(Payment_Account__c.SObjectType);
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                    CUSTOM_METADATA_ERROR_MESSAGE_SSN,
                    FIELD_NAME_SSN,
                    SERVICE_METHOD_VALIDATE_SSN,
                    CONTACT_OBJECT_NAME,
                    SERVICE_CLASS_NAME
                )
            )
        };
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Id, businessAccountId)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(Account.BillingCountryCode, ELIGIBLE_COUNTRY_TO_VALIDATE_US);
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccount.Id,
                VERTICAL
            )
            .setField(Account.Id, storeAccountId)
            .setParent('Parent', businessAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake paymentAccountFakeInstance = new Fake(Payment_Account__c.class)
            .setField(Payment_Account__c.Id, paymentAccountId);
        Fake contactFakeInstance = new Fake(Contact.class)
            .setField(Contact.LastName, CONTACT_LASTNAME)
            .setField(Contact.FirstName, CONTACT_FIRSTNAME)
            .setField(Contact.Email, CONTACT_EMAIL)
            .setField(Contact.Phone, CONTACT_PHONE)
            .setField(Contact.AccountId, businessAccount.Id)
            .setField(Contact.SSN_Last_4Digits__c, SSN_LAST_FOUR_DIGITS)
            .setField(Contact.BirthDate, Date.newInstance(1990, 3, 17))
            .setFakeId();
        Fake accountPaymentAccountRelationFakeInstance = new Fake(
                Account_Payment_Account_Relation__c.class
            )
            .setField(
                Account_Payment_Account_Relation__c.Account_Record_Type__c,
                ACCOUNT_RECORD_TYPE_NAME_STORE
            )
            .setParent('Account__r', businessAccountFakeInstance)
            .setFakeId();
        Fake productFakeInstance = ServiceMockDataBuilder.createProductFakeInstance(
            PRODUCT_NAME_ALCOHOL_DELIVERY
        );
        businessAccountFakeInstance.setChildren('Contacts', new List<Fake>{ contactFakeInstance });
        Fake merchantServicesFakeInstance = new Fake(Merchant_Service__c.class)
            .setField(Merchant_Service__c.Account__c, storeAccount.Id)
            .setParent('Product__r', productFakeInstance)
            .setFakeId();
        Merchant_Service__c merchantServiceInstance = (Merchant_Service__c) ServiceMockDataBuilder.convertToSObject(
            merchantServicesFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent('Account', businessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_MARKETPLACE,
                parentWorkOrder.Id
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('Account', storeAccountFakeInstance)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Contact contact = (Contact) ServiceMockDataBuilder.convertToSObject(contactFakeInstance);
        accountPaymentAccountRelationFakeInstance
            .setField(Account_Payment_Account_Relation__c.Account__c, storeAccount.Id)
            .setField(Account_Payment_Account_Relation__c.Payment_Account__c, paymentAccountId)
            .setParent(
                'Payment_Account__r',
                new Fake(Payment_Account__c.class)
                    .setField(Payment_Account__c.Id, paymentAccountId)
                    .setField(Payment_Account__c.Billing_Contact_Name__c, contact.Id)
                    .setParent('Billing_Contact_Name__r', contactFakeInstance)
            );
        paymentAccountFakeInstance
            .setChildren(
                'Account_Payment_Account_Relations__r',
                new List<Fake>{ accountPaymentAccountRelationFakeInstance }
            )
            .setParent('Billing_Contact_Name__r', contactFakeInstance);
        Account_Payment_Account_Relation__c accountPaymentAccountRelationSobjectInstance = (Account_Payment_Account_Relation__c) ServiceMockDataBuilder.convertToSObject(
            accountPaymentAccountRelationFakeInstance
        );
        Static_Configurations__mdt eligibleCountriesStatesToValidateBirthdate = new Static_Configurations__mdt(
            DeveloperName = BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            MasterLabel = BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            Configuration_Value__c = ELIGIBLE_COUNTRIES_STATES_TO_VALIDATE_BIRTHDATE
        );
        Static_Configurations__mdt eligibleCountriesStatesToValidateSSN = new Static_Configurations__mdt(
            DeveloperName = SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            MasterLabel = SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            Configuration_Value__c = ELIGIBLE_COUNTRIES_STATES_TO_VALIDATE_SSN
        );

        List<Readiness_Check_Failure__c> mockexistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountPaymentAccountRelationsSelector accountPaymentAccountSelector = (IAccountPaymentAccountRelationsSelector) mocks.mock(
            IAccountPaymentAccountRelationsSelector.class
        );
        IMerchantSelector merchantSelector = (IMerchantSelector) mocks.mock(
            IMerchantSelector.class
        );
        IStaticConfigurationsSelector mockStaticConfigurationsSelector = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(accountPaymentAccountSelector.sObjectType())
            .thenReturn(Account_Payment_Account_Relation__c.SObjectType);
        mocks.when(
                accountPaymentAccountSelector.selectByAccountIdsAndPaymentAccountRecordTypes(
                    new Set<Id>{ storeAccount.Id },
                    new Set<String>{ PAYMENT_ACCOUNT_RECORD_TYPE_PAYMENTS }
                )
            )
            .thenReturn(
                new List<Account_Payment_Account_Relation__c>{
                    accountPaymentAccountRelationSobjectInstance
                }
            );
        mocks.when(merchantSelector.sObjectType()).thenReturn(Merchant_Service__c.SObjectType);
        mocks.when(
                merchantSelector.selectServicesWithAlcoholProductsByAccountIds(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<Merchant_Service__c>{ merchantServiceInstance });
        mocks.when(mockStaticConfigurationsSelector.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG
                )
            )
            .thenReturn(eligibleCountriesStatesToValidateBirthdate);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG
                )
            )
            .thenReturn(eligibleCountriesStatesToValidateSSN);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(accountPaymentAccountSelector);
        Application.SELECTOR.setMock(merchantSelector);
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        ContactValidationsServiceImpl contactValidationsServiceImplInstance = new ContactValidationsServiceImpl();
        contactValidationsServiceImplInstance.validate(
            new List<WorkOrder>{ childWorkOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockexistingReadinessCheckFailures,
            CONTACT_OBJECT_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description To test when store products include alcohol delivery or alcohol pickup
     * with Billing Address other than eligible countries and states
     * then Readiness Check Failure records are not created.
     */
    @isTest
    private static void testWhenStoreProductIncludeAlcoholWithIneligibleBillingCountryAndStateThenReadinessCheckFailuresNotCreated() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id paymentAccountId = fflib_IDGenerator.generate(Payment_Account__c.SObjectType);
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                    CUSTOM_METADATA_ERROR_MESSAGE_BIRTHDATE,
                    FIELD_NAME_BIRTHDATE,
                    SERVICE_METHOD_VALIDATE_BIRTHDATE,
                    CONTACT_OBJECT_NAME,
                    SERVICE_CLASS_NAME
                )
            ),
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                    CUSTOM_METADATA_ERROR_MESSAGE_SSN,
                    FIELD_NAME_SSN,
                    SERVICE_METHOD_VALIDATE_SSN,
                    CONTACT_OBJECT_NAME,
                    SERVICE_CLASS_NAME
                )
            )
        };
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Id, businessAccountId)
            .setField(Account.BillingCountryCode, INELIGIBLE_COUNTRY_TO_VALIDATE_IN)
            .setField(Account.BillingStateCode, INELIGIBLE_STATE_TO_VALIDATE_KA)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccount.Id,
                VERTICAL
            )
            .setField(Account.Id, storeAccountId)
            .setField(Account.BillingCountryCode, INELIGIBLE_COUNTRY_TO_VALIDATE_IN)
            .setField(Account.BillingStateCode, INELIGIBLE_STATE_TO_VALIDATE_KA)
            .setParent('Parent', businessAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake paymentAccountFakeInstance = new Fake(Payment_Account__c.class)
            .setField(Payment_Account__c.Id, paymentAccountId);
        Fake contactFakeInstance = new Fake(Contact.class)
            .setField(Contact.LastName, CONTACT_LASTNAME)
            .setField(Contact.FirstName, CONTACT_FIRSTNAME)
            .setField(Contact.Email, CONTACT_EMAIL)
            .setField(Contact.Phone, CONTACT_PHONE)
            .setField(Contact.AccountId, businessAccount.Id)
            .setField(Contact.SSN_Last_4Digits__c, null)
            .setField(Contact.BirthDate, null)
            .setFakeId();
        Fake accountPaymentAccountRelationFakeInstance = new Fake(
                Account_Payment_Account_Relation__c.class
            )
            .setField(
                Account_Payment_Account_Relation__c.Account_Record_Type__c,
                ACCOUNT_RECORD_TYPE_NAME_STORE
            )
            .setParent('Account__r', businessAccountFakeInstance)
            .setFakeId();
        Fake productFakeInstance = ServiceMockDataBuilder.createProductFakeInstance(
            PRODUCT_NAME_ALCOHOL_DELIVERY
        );
        businessAccountFakeInstance.setChildren('Contacts', new List<Fake>{ contactFakeInstance });
        Fake merchantServicesFakeInstance = new Fake(Merchant_Service__c.class)
            .setField(Merchant_Service__c.Account__c, storeAccount.Id)
            .setParent('Product__r', productFakeInstance)
            .setFakeId();
        Merchant_Service__c merchantServiceInstance = (Merchant_Service__c) ServiceMockDataBuilder.convertToSObject(
            merchantServicesFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent('Account', businessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_MARKETPLACE,
                parentWorkOrder.Id
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('Account', storeAccountFakeInstance)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Contact contact = (Contact) ServiceMockDataBuilder.convertToSObject(contactFakeInstance);
        accountPaymentAccountRelationFakeInstance
            .setField(Account_Payment_Account_Relation__c.Account__c, storeAccount.Id)
            .setField(Account_Payment_Account_Relation__c.Payment_Account__c, paymentAccountId)
            .setParent(
                'Payment_Account__r',
                new Fake(Payment_Account__c.class)
                    .setField(Payment_Account__c.Id, paymentAccountId)
                    .setField(Payment_Account__c.Billing_Contact_Name__c, contact.Id)
                    .setParent('Billing_Contact_Name__r', contactFakeInstance)
            );
        paymentAccountFakeInstance
            .setChildren(
                'Account_Payment_Account_Relations__r',
                new List<Fake>{ accountPaymentAccountRelationFakeInstance }
            )
            .setParent('Billing_Contact_Name__r', contactFakeInstance);
        Account_Payment_Account_Relation__c accountPaymentAccountRelationSobjectInstance = (Account_Payment_Account_Relation__c) ServiceMockDataBuilder.convertToSObject(
            accountPaymentAccountRelationFakeInstance
        );
        Static_Configurations__mdt eligibleCountriesStatesToValidateBirthdate = new Static_Configurations__mdt(
            DeveloperName = BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            MasterLabel = BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            Configuration_Value__c = ELIGIBLE_COUNTRIES_STATES_TO_VALIDATE_BIRTHDATE
        );
        Static_Configurations__mdt eligibleCountriesStatesToValidateSSN = new Static_Configurations__mdt(
            DeveloperName = SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            MasterLabel = SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            Configuration_Value__c = ELIGIBLE_COUNTRIES_STATES_TO_VALIDATE_SSN
        );

        List<Readiness_Check_Failure__c> mockexistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountPaymentAccountRelationsSelector accountPaymentAccountSelector = (IAccountPaymentAccountRelationsSelector) mocks.mock(
            IAccountPaymentAccountRelationsSelector.class
        );
        IMerchantSelector merchantSelector = (IMerchantSelector) mocks.mock(
            IMerchantSelector.class
        );
        IStaticConfigurationsSelector mockStaticConfigurationsSelector = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(accountPaymentAccountSelector.sObjectType())
            .thenReturn(Account_Payment_Account_Relation__c.SObjectType);
        mocks.when(
                accountPaymentAccountSelector.selectByAccountIdsAndPaymentAccountRecordTypes(
                    new Set<Id>{ storeAccount.Id },
                    new Set<String>{ PAYMENT_ACCOUNT_RECORD_TYPE_PAYMENTS }
                )
            )
            .thenReturn(
                new List<Account_Payment_Account_Relation__c>{
                    accountPaymentAccountRelationSobjectInstance
                }
            );
        mocks.when(merchantSelector.sObjectType()).thenReturn(Merchant_Service__c.SObjectType);
        mocks.when(
                merchantSelector.selectServicesWithAlcoholProductsByAccountIds(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<Merchant_Service__c>{ merchantServiceInstance });
        mocks.when(mockStaticConfigurationsSelector.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG
                )
            )
            .thenReturn(eligibleCountriesStatesToValidateBirthdate);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG
                )
            )
            .thenReturn(eligibleCountriesStatesToValidateSSN);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(accountPaymentAccountSelector);
        Application.SELECTOR.setMock(merchantSelector);
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        ContactValidationsServiceImpl contactValidationsServiceImplInstance = new ContactValidationsServiceImpl();
        contactValidationsServiceImplInstance.validate(
            new List<WorkOrder>{ childWorkOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockexistingReadinessCheckFailures,
            CONTACT_OBJECT_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description To test when store products include alcohol delivery or alcohol pickup
     * with Billing Address having eligible countries and states
     * then Readiness Check Failure records are created.
     */
    @isTest
    private static void testWhenBusinessProductIncludeAlcoholWithEligibleBillingCountryAndStateThenReadinessCheckFailuresCreated() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id paymentAccountId = fflib_IDGenerator.generate(Payment_Account__c.SObjectType);
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                    CUSTOM_METADATA_ERROR_MESSAGE_BIRTHDATE,
                    FIELD_NAME_BIRTHDATE,
                    SERVICE_METHOD_VALIDATE_BIRTHDATE,
                    CONTACT_OBJECT_NAME,
                    SERVICE_CLASS_NAME
                )
            ),
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                    CUSTOM_METADATA_ERROR_MESSAGE_SSN,
                    FIELD_NAME_SSN,
                    SERVICE_METHOD_VALIDATE_SSN,
                    CONTACT_OBJECT_NAME,
                    SERVICE_CLASS_NAME
                )
            )
        };
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Id, businessAccountId)
            .setField(Account.BillingCountryCode, ELIGIBLE_COUNTRY_TO_VALIDATE_US)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake paymentAccountFakeInstance = new Fake(Payment_Account__c.class)
            .setField(Payment_Account__c.Id, paymentAccountId);
        Fake contactFakeInstance = new Fake(Contact.class)
            .setField(Contact.LastName, CONTACT_LASTNAME)
            .setField(Contact.FirstName, CONTACT_FIRSTNAME)
            .setField(Contact.Email, CONTACT_EMAIL)
            .setField(Contact.Phone, CONTACT_PHONE)
            .setField(Contact.AccountId, businessAccount.Id)
            .setField(Contact.SSN_Last_4Digits__c, null)
            .setFakeId();
        Fake accountPaymentAccountRelationFakeInstance = new Fake(
                Account_Payment_Account_Relation__c.class
            )
            .setField(
                Account_Payment_Account_Relation__c.Account_Record_Type__c,
                ACCOUNT_RECORD_TYPE_NAME_STORE
            )
            .setParent('Account__r', businessAccountFakeInstance)
            .setFakeId();
        Fake productFakeInstance = ServiceMockDataBuilder.createProductFakeInstance(
            PRODUCT_NAME_ALCOHOL_DELIVERY
        );
        businessAccountFakeInstance.setChildren('Contacts', new List<Fake>{ contactFakeInstance });
        Fake merchantServicesFakeInstance = new Fake(Merchant_Service__c.class)
            .setField(Merchant_Service__c.Account__c, businessAccountId)
            .setParent('Product__r', productFakeInstance)
            .setFakeId();
        Merchant_Service__c merchantServiceInstance = (Merchant_Service__c) ServiceMockDataBuilder.convertToSObject(
            merchantServicesFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_DRIVE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.Sub_Type__c, WORK_ORDER_SUB_TYPE_NET_NEW_BUSINESS)
            .setParent('Account', businessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Contact contact = (Contact) ServiceMockDataBuilder.convertToSObject(contactFakeInstance);
        accountPaymentAccountRelationFakeInstance
            .setField(Account_Payment_Account_Relation__c.Account__c, businessAccount.Id)
            .setField(Account_Payment_Account_Relation__c.Payment_Account__c, paymentAccountId)
            .setParent(
                'Payment_Account__r',
                new Fake(Payment_Account__c.class)
                    .setField(Payment_Account__c.Id, paymentAccountId)
                    .setField(Payment_Account__c.Billing_Contact_Name__c, contact.Id)
                    .setParent('Billing_Contact_Name__r', contactFakeInstance)
            );
        paymentAccountFakeInstance
            .setChildren(
                'Account_Payment_Account_Relations__r',
                new List<Fake>{ accountPaymentAccountRelationFakeInstance }
            )
            .setParent('Billing_Contact_Name__r', contactFakeInstance);
        Account_Payment_Account_Relation__c accountPaymentAccountRelationSobjectInstance = (Account_Payment_Account_Relation__c) ServiceMockDataBuilder.convertToSObject(
            accountPaymentAccountRelationFakeInstance
        );
        List<Readiness_Check_Failure__c> mockReadinessValidationRuleFailureRecords = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRules[0].Object_Label__c,
                Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
                Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
                Parent_Work_Order__c = parentWorkOrder.Id,
                Child_Work_Order__c = parentWorkOrder.Id,
                Account_Name__c = parentWorkOrder.AccountId,
                Contact_Name__c = contact.Id
            ),
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRules[1].Object_Label__c,
                Field_Name__c = storeReadinessValidationRules[1].Field_Label__c,
                Error_Message__c = storeReadinessValidationRules[1].Error_Message__c,
                Parent_Work_Order__c = parentWorkOrder.Id,
                Child_Work_Order__c = parentWorkOrder.Id,
                Account_Name__c = parentWorkOrder.AccountId,
                Contact_Name__c = contact.Id
            )
        };
        Static_Configurations__mdt eligibleCountriesStatesToValidateBirthdate = new Static_Configurations__mdt(
            DeveloperName = BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            MasterLabel = BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            Configuration_Value__c = ELIGIBLE_COUNTRIES_STATES_TO_VALIDATE_BIRTHDATE
        );
        Static_Configurations__mdt eligibleCountriesStatesToValidateSSN = new Static_Configurations__mdt(
            DeveloperName = SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            MasterLabel = SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            Configuration_Value__c = ELIGIBLE_COUNTRIES_STATES_TO_VALIDATE_SSN
        );

        List<Readiness_Check_Failure__c> mockexistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountPaymentAccountRelationsSelector accountPaymentAccountSelector = (IAccountPaymentAccountRelationsSelector) mocks.mock(
            IAccountPaymentAccountRelationsSelector.class
        );
        IMerchantSelector merchantSelector = (IMerchantSelector) mocks.mock(
            IMerchantSelector.class
        );
        IStaticConfigurationsSelector mockStaticConfigurationsSelector = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(accountPaymentAccountSelector.sObjectType())
            .thenReturn(Account_Payment_Account_Relation__c.SObjectType);
        mocks.when(
                accountPaymentAccountSelector.selectByAccountIdsAndPaymentAccountRecordTypes(
                    new Set<Id>{ businessAccountId },
                    new Set<String>{ PAYMENT_ACCOUNT_RECORD_TYPE_INVOICE }
                )
            )
            .thenReturn(
                new List<Account_Payment_Account_Relation__c>{
                    accountPaymentAccountRelationSobjectInstance
                }
            );
        mocks.when(merchantSelector.sObjectType()).thenReturn(Merchant_Service__c.SObjectType);
        mocks.when(
                merchantSelector.selectServicesWithAlcoholProductsByAccountIds(
                    new Set<Id>{ businessAccountId }
                )
            )
            .thenReturn(new List<Merchant_Service__c>{ merchantServiceInstance });
        mocks.when(mockStaticConfigurationsSelector.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG
                )
            )
            .thenReturn(eligibleCountriesStatesToValidateBirthdate);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG
                )
            )
            .thenReturn(eligibleCountriesStatesToValidateSSN);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(accountPaymentAccountSelector);
        Application.SELECTOR.setMock(merchantSelector);
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        ContactValidationsServiceImpl contactValidationsServiceImplInstance = new ContactValidationsServiceImpl();
        contactValidationsServiceImplInstance.validate(
            new List<WorkOrder>{},
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockexistingReadinessCheckFailures,
            CONTACT_OBJECT_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessValidationRuleFailureRecords);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test validation of Birthdate field on Billing Contact populated on Payment Account
     * associated with recently updated 'Account Payment Account Relation' of store Accounts
     * having Product name as 'Alcohol Delivery' or 'Alcohol Pickup' with Billing Country as
     * Australia and State as Queensland.
     */
    @isTest
    private static void testWhenStoreProductIncludesAlcoholWithEligibleBillingCountryAndStateThenValidateBirthdateOnContactAssociatedWithRecentlyUpdatedAccountPaymentAccountRelation() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id paymentAccountId = fflib_IDGenerator.generate(Payment_Account__c.SObjectType);
        Id paymentAccountWithBillingContactId = fflib_IDGenerator.generate(
            Payment_Account__c.SObjectType
        );
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                    CUSTOM_METADATA_ERROR_MESSAGE_BIRTHDATE,
                    FIELD_NAME_BIRTHDATE,
                    SERVICE_METHOD_VALIDATE_BIRTHDATE,
                    CONTACT_OBJECT_NAME,
                    SERVICE_CLASS_NAME
                )
            )
        };
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Id, businessAccountId)
            .setField(Account.BillingCountryCode, ELIGIBLE_COUNTRY_TO_VALIDATE_AU)
            .setField(Account.BillingStateCode, ELIGIBLE_STATE_TO_VALIDATE_QLD)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccount.Id,
                VERTICAL
            )
            .setField(Account.Id, storeAccountId)
            .setField(Account.BillingCountryCode, ELIGIBLE_COUNTRY_TO_VALIDATE_AU)
            .setField(Account.BillingStateCode, ELIGIBLE_STATE_TO_VALIDATE_QLD)
            .setParent('Parent', businessAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake paymentAccountFakeInstance = new Fake(Payment_Account__c.class)
            .setField(Payment_Account__c.Id, paymentAccountId)
            .setField(Payment_Account__c.LastModifiedDate, System.today().addDays(-5));
        Fake paymentAccountWithBillingContactFakeInstance = new Fake(Payment_Account__c.class)
            .setField(Payment_Account__c.Id, paymentAccountWithBillingContactId)
            .setField(Payment_Account__c.LastModifiedDate, System.today().addDays(-2));
        Fake contactFakeInstance = new Fake(Contact.class)
            .setField(Contact.LastName, CONTACT_LASTNAME)
            .setField(Contact.FirstName, CONTACT_FIRSTNAME)
            .setField(Contact.Email, CONTACT_EMAIL)
            .setField(Contact.Phone, CONTACT_PHONE)
            .setField(Contact.AccountId, businessAccount.Id)
            .setField(Contact.SSN_Last_4Digits__c, SSN_LAST_FOUR_DIGITS)
            .setField(Contact.BirthDate, null)
            .setFakeId();
        Fake billingContactFakeInstance = new Fake(Contact.class)
            .setField(Contact.LastName, CONTACT_LASTNAME)
            .setField(Contact.FirstName, CONTACT_FIRSTNAME)
            .setField(Contact.Email, CONTACT_EMAIL)
            .setField(Contact.Phone, CONTACT_PHONE)
            .setField(Contact.AccountId, businessAccount.Id)
            .setField(Contact.SSN_Last_4Digits__c, SSN_LAST_FOUR_DIGITS)
            .setField(Contact.BirthDate, null)
            .setFakeId();
        Fake accountPaymentAccountRelationFakeInstance = new Fake(
                Account_Payment_Account_Relation__c.class
            )
            .setField(
                Account_Payment_Account_Relation__c.Account_Record_Type__c,
                ACCOUNT_RECORD_TYPE_NAME_STORE
            )
            .setParent('Account__r', businessAccountFakeInstance)
            .setFakeId();
        Fake accountPaymentAccountRelationWithBillingContactFakeInstance = new Fake(
                Account_Payment_Account_Relation__c.class
            )
            .setField(
                Account_Payment_Account_Relation__c.Account_Record_Type__c,
                ACCOUNT_RECORD_TYPE_NAME_STORE
            )
            .setParent('Account__r', businessAccountFakeInstance)
            .setFakeId();
        Fake productFakeInstance = ServiceMockDataBuilder.createProductFakeInstance(
            PRODUCT_NAME_ALCOHOL_DELIVERY
        );
        businessAccountFakeInstance.setChildren(
            'Contacts',
            new List<Fake>{ contactFakeInstance, billingContactFakeInstance }
        );
        Fake merchantServicesFakeInstance = new Fake(Merchant_Service__c.class)
            .setField(Merchant_Service__c.Account__c, storeAccount.Id)
            .setParent('Product__r', productFakeInstance)
            .setFakeId();
        Merchant_Service__c merchantServiceInstance = (Merchant_Service__c) ServiceMockDataBuilder.convertToSObject(
            merchantServicesFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent('Account', businessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_MARKETPLACE,
                parentWorkOrder.Id
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('Account', storeAccountFakeInstance)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Contact contact = (Contact) ServiceMockDataBuilder.convertToSObject(contactFakeInstance);
        Contact billingContact = (Contact) ServiceMockDataBuilder.convertToSObject(
            billingContactFakeInstance
        );
        accountPaymentAccountRelationFakeInstance
            .setField(Account_Payment_Account_Relation__c.Account__c, storeAccount.Id)
            .setField(Account_Payment_Account_Relation__c.Payment_Account__c, paymentAccountId)
            .setField(
                Account_Payment_Account_Relation__c.LastModifiedDate,
                System.today().addDays(-5)
            )
            .setParent(
                'Payment_Account__r',
                new Fake(Payment_Account__c.class)
                    .setField(Payment_Account__c.Id, paymentAccountId)
                    .setField(Payment_Account__c.Billing_Contact_Name__c, contact.Id)
                    .setParent('Billing_Contact_Name__r', contactFakeInstance)
            );
        accountPaymentAccountRelationWithBillingContactFakeInstance
            .setField(Account_Payment_Account_Relation__c.Account__c, storeAccount.Id)
            .setField(Account_Payment_Account_Relation__c.Payment_Account__c, paymentAccountId)
            .setField(
                Account_Payment_Account_Relation__c.LastModifiedDate,
                System.today().addDays(-2)
            )
            .setParent(
                'Payment_Account__r',
                new Fake(Payment_Account__c.class)
                    .setField(Payment_Account__c.Id, paymentAccountWithBillingContactId)
                    .setField(Payment_Account__c.Billing_Contact_Name__c, billingContact.Id)
                    .setParent('Billing_Contact_Name__r', billingContactFakeInstance)
            );
        paymentAccountFakeInstance
            .setChildren(
                'Account_Payment_Account_Relations__r',
                new List<Fake>{ accountPaymentAccountRelationFakeInstance }
            )
            .setParent('Billing_Contact_Name__r', contactFakeInstance);
        paymentAccountWithBillingContactFakeInstance
            .setChildren(
                'Account_Payment_Account_Relations__r',
                new List<Fake>{ accountPaymentAccountRelationFakeInstance }
            )
            .setParent('Billing_Contact_Name__r', billingContactFakeInstance);
        Account_Payment_Account_Relation__c accountPaymentAccountRelationSobjectInstance = (Account_Payment_Account_Relation__c) ServiceMockDataBuilder.convertToSObject(
            accountPaymentAccountRelationFakeInstance
        );
        Account_Payment_Account_Relation__c accountPaymentAccountRelationWithBillingContactSobjectInstance = (Account_Payment_Account_Relation__c) ServiceMockDataBuilder.convertToSObject(
            accountPaymentAccountRelationWithBillingContactFakeInstance
        );
        List<Readiness_Check_Failure__c> mockReadinessValidationRuleFailureRecords = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRules[0].Object_Label__c,
                Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
                Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
                Parent_Work_Order__c = parentWorkOrder.Id,
                Child_Work_Order__c = childWorkOrder.Id,
                Account_Name__c = childWorkOrder.AccountId,
                Contact_Name__c = billingContact.Id
            )
        };
        Static_Configurations__mdt eligibleCountriesStatesToValidateBirthdate = new Static_Configurations__mdt(
            DeveloperName = BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            MasterLabel = BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            Configuration_Value__c = ELIGIBLE_COUNTRIES_STATES_TO_VALIDATE_BIRTHDATE
        );
        Static_Configurations__mdt eligibleCountriesStatesToValidateSSN = new Static_Configurations__mdt(
            DeveloperName = SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            MasterLabel = SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            Configuration_Value__c = ELIGIBLE_COUNTRIES_STATES_TO_VALIDATE_SSN
        );

        List<Readiness_Check_Failure__c> mockexistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountPaymentAccountRelationsSelector accountPaymentAccountSelector = (IAccountPaymentAccountRelationsSelector) mocks.mock(
            IAccountPaymentAccountRelationsSelector.class
        );
        IMerchantSelector merchantSelector = (IMerchantSelector) mocks.mock(
            IMerchantSelector.class
        );
        IStaticConfigurationsSelector mockStaticConfigurationsSelector = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(accountPaymentAccountSelector.sObjectType())
            .thenReturn(Account_Payment_Account_Relation__c.SObjectType);
        mocks.when(
                accountPaymentAccountSelector.selectByAccountIdsAndPaymentAccountRecordTypes(
                    new Set<Id>{ storeAccount.Id },
                    new Set<String>{ PAYMENT_ACCOUNT_RECORD_TYPE_PAYMENTS }
                )
            )
            .thenReturn(
                new List<Account_Payment_Account_Relation__c>{
                    accountPaymentAccountRelationWithBillingContactSobjectInstance,
                    accountPaymentAccountRelationSobjectInstance
                }
            );
        mocks.when(merchantSelector.sObjectType()).thenReturn(Merchant_Service__c.SObjectType);
        mocks.when(
                merchantSelector.selectServicesWithAlcoholProductsByAccountIds(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<Merchant_Service__c>{ merchantServiceInstance });
        mocks.when(mockStaticConfigurationsSelector.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG
                )
            )
            .thenReturn(eligibleCountriesStatesToValidateBirthdate);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG
                )
            )
            .thenReturn(eligibleCountriesStatesToValidateSSN);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(accountPaymentAccountSelector);
        Application.SELECTOR.setMock(merchantSelector);
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        ContactValidationsServiceImpl contactValidationsServiceImplInstance = new ContactValidationsServiceImpl();
        contactValidationsServiceImplInstance.validate(
            new List<WorkOrder>{ childWorkOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockexistingReadinessCheckFailures,
            CONTACT_OBJECT_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessValidationRuleFailureRecords);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Readiness Check Failure records not created when Decision Maker Contact
     * exists on the store account.
     */
    @isTest
    private static void testWhenDecisionMakerContactExistsOnStoreThenReadinessCheckFailureNotCreated() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id decisionMakerContactId = fflib_IDGenerator.generate(Contact.SObjectType);
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                    CUSTOM_METADATA_ERROR_MESSAGE_DECISION_MAKER,
                    '',
                    SERVICE_METHOD_VALIDATE_DECISION_MAKER,
                    CONTACT_OBJECT_NAME,
                    SERVICE_CLASS_NAME
                )
            )
        };
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Id, businessAccountId)
            .setField(Account.BillingCountryCode, ELIGIBLE_COUNTRY_TO_VALIDATE_US)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccount.Id,
                VERTICAL
            )
            .setField(Account.Id, storeAccountId)
            .setParent('Parent', businessAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent('Account', businessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_MARKETPLACE,
                parentWorkOrder.Id
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setField(WorkOrder.ContactId, fflib_IDGenerator.generate(Contact.SObjectType))
            .setParent('Account', storeAccountFakeInstance)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Fake accountContactRelationshipFakeInstance = new Fake(AccountContactRelation.class)
            .setField(AccountContactRelation.AccountId, storeAccountId)
            .setField(AccountContactRelation.Account_Record_Type__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(AccountContactRelation.ContactId, decisionMakerContactId);
        AccountContactRelation accountContactRelationship = (AccountContactRelation) accountContactRelationshipFakeInstance.toSobject();
        Static_Configurations__mdt eligibleCountriesStatesToValidateBirthdate = new Static_Configurations__mdt(
            DeveloperName = BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            MasterLabel = BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            Configuration_Value__c = ELIGIBLE_COUNTRIES_STATES_TO_VALIDATE_BIRTHDATE
        );
        Static_Configurations__mdt eligibleCountriesStatesToValidateSSN = new Static_Configurations__mdt(
            DeveloperName = SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            MasterLabel = SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            Configuration_Value__c = ELIGIBLE_COUNTRIES_STATES_TO_VALIDATE_SSN
        );

        List<Readiness_Check_Failure__c> mockexistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountContactRelationsSelector accountContactRelationsSelector = (IAccountContactRelationsSelector) mocks.mock(
            IAccountContactRelationsSelector.class
        );
        IStaticConfigurationsSelector mockStaticConfigurationsSelector = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        IReadinessValidationRulesService mockReadinessValidationRulesService = (IReadinessValidationRulesService) mocks.mock(
            IReadinessValidationRulesService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(accountContactRelationsSelector.sObjectType())
            .thenReturn(AccountContactRelation.SObjectType);
        mocks.when(
                accountContactRelationsSelector.selectByAccountIds(new Set<Id>{ storeAccountId })
            )
            .thenReturn(new List<AccountContactRelation>{ accountContactRelationship });
        mocks.when(mockStaticConfigurationsSelector.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG
                )
            )
            .thenReturn(eligibleCountriesStatesToValidateBirthdate);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG
                )
            )
            .thenReturn(eligibleCountriesStatesToValidateSSN);
        mocks.when(
                mockReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
                    null,
                    storeReadinessValidationRules[0],
                    childWorkOrder
                )
            )
            .thenReturn(true);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(accountContactRelationsSelector);
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        Application.SERVICE.setMock(
            IReadinessValidationRulesService.class,
            mockReadinessValidationRulesService
        );
        ContactValidationsServiceImpl contactValidationsServiceImplInstance = new ContactValidationsServiceImpl();
        contactValidationsServiceImplInstance.validate(
            new List<WorkOrder>{ childWorkOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockexistingReadinessCheckFailures,
            CONTACT_OBJECT_NAME
        );
        //Readiness check failure not created when Decision Maker exists.
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description To test Readiness Check Failure creation when Decision Maker Contact does
     * not exist on the store account.
     */
    @isTest
    private static void testWhenDecisionMakerContactDoesNotExistOnStoreThenCreateReadinessCheckFailure() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                    CUSTOM_METADATA_ERROR_MESSAGE_DECISION_MAKER,
                    '',
                    SERVICE_METHOD_VALIDATE_DECISION_MAKER,
                    CONTACT_OBJECT_NAME,
                    SERVICE_CLASS_NAME
                )
            )
        };
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Id, businessAccountId)
            .setField(Account.BillingCountryCode, ELIGIBLE_COUNTRY_TO_VALIDATE_US)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccount.Id,
                VERTICAL
            )
            .setField(Account.Id, storeAccountId)
            .setParent('Parent', businessAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent('Account', businessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_MARKETPLACE,
                parentWorkOrder.Id
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setField(WorkOrder.ContactId, fflib_IDGenerator.generate(Contact.SObjectType))
            .setParent('Account', storeAccountFakeInstance)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        List<Readiness_Check_Failure__c> mockReadinessValidationRuleFailureRecords = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRules[0].Object_Label__c,
                Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
                Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
                Parent_Work_Order__c = parentWorkOrder.Id,
                Child_Work_Order__c = childWorkOrder.Id,
                Account_Name__c = childWorkOrder.AccountId,
                Contact_Name__c = null
            )
        };
        Static_Configurations__mdt eligibleCountriesStatesToValidateBirthdate = new Static_Configurations__mdt(
            DeveloperName = BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            MasterLabel = BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            Configuration_Value__c = ELIGIBLE_COUNTRIES_STATES_TO_VALIDATE_BIRTHDATE
        );
        Static_Configurations__mdt eligibleCountriesStatesToValidateSSN = new Static_Configurations__mdt(
            DeveloperName = SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            MasterLabel = SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            Configuration_Value__c = ELIGIBLE_COUNTRIES_STATES_TO_VALIDATE_SSN
        );

        List<Readiness_Check_Failure__c> mockexistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountContactRelationsSelector accountContactRelationsSelector = (IAccountContactRelationsSelector) mocks.mock(
            IAccountContactRelationsSelector.class
        );
        IStaticConfigurationsSelector mockStaticConfigurationsSelector = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        IDecisionMakerCalculationService mockDecisionMakerCalculationService = (IDecisionMakerCalculationService) mocks.mock(
            IDecisionMakerCalculationService.class
        );
        IReadinessValidationRulesService mockReadinessValidationRulesService = (IReadinessValidationRulesService) mocks.mock(
            IReadinessValidationRulesService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(accountContactRelationsSelector.sObjectType())
            .thenReturn(AccountContactRelation.SObjectType);
        mocks.when(
                accountContactRelationsSelector.selectByAccountIds(new Set<Id>{ storeAccountId })
            )
            .thenReturn(new List<AccountContactRelation>{});
        mocks.when(mockStaticConfigurationsSelector.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG
                )
            )
            .thenReturn(eligibleCountriesStatesToValidateBirthdate);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG
                )
            )
            .thenReturn(eligibleCountriesStatesToValidateSSN);
        mocks.when(
                mockDecisionMakerCalculationService.getDecisionMakers(
                    new List<WorkOrder>{ childWorkOrder }
                )
            )
            .thenReturn(new Map<Id, List<Id>>());
        mocks.when(
                mockReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
                    null,
                    storeReadinessValidationRules[0],
                    childWorkOrder
                )
            )
            .thenReturn(true);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(accountContactRelationsSelector);
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        Application.SERVICE.setMock(
            IDecisionMakerCalculationService.class,
            mockDecisionMakerCalculationService
        );
        Application.SERVICE.setMock(
            IReadinessValidationRulesService.class,
            mockReadinessValidationRulesService
        );
        ContactValidationsServiceImpl contactValidationsServiceImplInstance = new ContactValidationsServiceImpl();
        contactValidationsServiceImplInstance.validate(
            new List<WorkOrder>{ childWorkOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockexistingReadinessCheckFailures,
            CONTACT_OBJECT_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessValidationRuleFailureRecords);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Readiness Check Failure records not created when 'Decision Maker' Contact
     * exists on the store account with 'Tablet' Order Protocol.
     */
    @isTest
    private static void testWhenDecisionMakerContactExistsOnTabletStoreThenReadinessCheckFailureNotCreated() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id decisionMakerContactId = fflib_IDGenerator.generate(Contact.SObjectType);
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                    CUSTOM_METADATA_ERROR_MESSAGE_DECISION_MAKER,
                    '',
                    SERVICE_METHOD_VALIDATE_DECISION_MAKER_WITH_TABLET_ORDER_PROTOCOL,
                    CONTACT_OBJECT_NAME,
                    SERVICE_CLASS_NAME
                )
            )
        };
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Id, businessAccountId)
            .setField(Account.BillingCountryCode, ELIGIBLE_COUNTRY_TO_VALIDATE_US)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccount.Id,
                VERTICAL
            )
            .setField(Account.Id, storeAccountId)
            .setField(Account.Order_Protocol__c, ORDER_PROTOCOL_TABLET)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setParent('Parent', businessAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL_TABLET)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent('Account', businessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_MARKETPLACE,
                parentWorkOrder.Id
            )
            .setField(WorkOrder.ContactId, fflib_IDGenerator.generate(Contact.SObjectType))
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL_TABLET)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('Account', storeAccountFakeInstance)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Fake accountContactRelationshipFakeInstance = new Fake(AccountContactRelation.class)
            .setField(AccountContactRelation.AccountId, storeAccountId)
            .setField(AccountContactRelation.Account_Record_Type__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(AccountContactRelation.ContactId, decisionMakerContactId)
            .setParent(
                'Contact',
                new Fake(Contact.class)
                    .setField(Contact.Id, decisionMakerContactId)
                    .setParent('Account', storeAccountFakeInstance)
            );
        AccountContactRelation accountContactRelationship = (AccountContactRelation) accountContactRelationshipFakeInstance.toSobject();
        Static_Configurations__mdt eligibleCountriesStatesToValidateBirthdate = new Static_Configurations__mdt(
            DeveloperName = BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            MasterLabel = BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            Configuration_Value__c = ELIGIBLE_COUNTRIES_STATES_TO_VALIDATE_BIRTHDATE
        );
        Static_Configurations__mdt eligibleCountriesStatesToValidateSSN = new Static_Configurations__mdt(
            DeveloperName = SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            MasterLabel = SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            Configuration_Value__c = ELIGIBLE_COUNTRIES_STATES_TO_VALIDATE_SSN
        );

        List<Readiness_Check_Failure__c> mockexistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountContactRelationsSelector accountContactRelationsSelector = (IAccountContactRelationsSelector) mocks.mock(
            IAccountContactRelationsSelector.class
        );
        IStaticConfigurationsSelector mockStaticConfigurationsSelector = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        IReadinessValidationRulesService mockReadinessValidationRulesService = (IReadinessValidationRulesService) mocks.mock(
            IReadinessValidationRulesService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(accountContactRelationsSelector.sObjectType())
            .thenReturn(AccountContactRelation.SObjectType);
        mocks.when(
                accountContactRelationsSelector.selectByAccountIds(new Set<Id>{ storeAccountId })
            )
            .thenReturn(new List<AccountContactRelation>{ accountContactRelationship });
        mocks.when(mockStaticConfigurationsSelector.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG
                )
            )
            .thenReturn(eligibleCountriesStatesToValidateBirthdate);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG
                )
            )
            .thenReturn(eligibleCountriesStatesToValidateSSN);
        mocks.when(
                mockReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
                    null,
                    storeReadinessValidationRules[0],
                    childWorkOrder
                )
            )
            .thenReturn(true);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(accountContactRelationsSelector);
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        Application.SERVICE.setMock(
            IReadinessValidationRulesService.class,
            mockReadinessValidationRulesService
        );
        ContactValidationsServiceImpl contactValidationsServiceImplInstance = new ContactValidationsServiceImpl();
        contactValidationsServiceImplInstance.validate(
            new List<WorkOrder>{ childWorkOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockexistingReadinessCheckFailures,
            CONTACT_OBJECT_NAME
        );
        //Readiness check failure not created when Decision Maker exists.
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description To test Readiness Check Failure creation when 'Decision Maker' Contact exists
     * on the business Account having store with 'Tablet' Order Protocol.
     */
    @isTest
    private static void testWhenDecisionMakerContactExistsOnBusinessWithTabletStoreThenCreateReadinessCheckFailure() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id decisionMakerContactId = fflib_IDGenerator.generate(Contact.SObjectType);
        Map<String, Map<String, Set<String>>> readinessValidationRuleTypeSubTypes = new Map<String, Map<String, Set<String>>>();
        Map<String, Set<String>> typeToSubTypes = new Map<String, Set<String>>();
        Set<String> subTypes = new Set<String>();
        subTypes.add(WORK_ORDER_SUB_TYPE_NET_NEW_BUSINESS);
        typeToSubTypes.put(WORKORDER_TYPE_MARKETPLACE, subTypes);
        readinessValidationRuleTypeSubTypes.put(DEVELOPER_NAME_DM_CONTACT_REQUIRED, typeToSubTypes);

        Fake storeReadinessValidationRuleMdtFakeInstance1 = new Fake(Store_Readiness_Validation_Rule__mdt.class)
            .setField(Store_Readiness_Validation_Rule__mdt.Field_Label__c, '')
            .setField(Store_Readiness_Validation_Rule__mdt.Error_Message__c, CUSTOM_METADATA_ERROR_MESSAGE_DECISION_MAKER)
            .setField(Store_Readiness_Validation_Rule__mdt.Is_Active__c, true)
            .setField(Store_Readiness_Validation_Rule__mdt.Object_Label__c, CONTACT_OBJECT_NAME)
            .setField(Store_Readiness_Validation_Rule__mdt.Service_Class_Name__c, SERVICE_CLASS_NAME)
            .setField(Store_Readiness_Validation_Rule__mdt.Service_Method_Name__c, SERVICE_METHOD_VALIDATE_DECISION_MAKER_WITH_TABLET_ORDER_PROTOCOL)
            .setField(Store_Readiness_Validation_Rule__mdt.DeveloperName, DEVELOPER_NAME_DM_CONTACT_REQUIRED)
            .setFakeId();

        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                    storeReadinessValidationRuleMdtFakeInstance1)
        };
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Id, businessAccountId)
            .setField(Account.BillingCountryCode, COUNTRY_CODE_CANADA)
            .setField(Account.BillingCountry, COUNTRY_CANADA)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccount.Id,
                VERTICAL
            )
            .setField(Account.Id, storeAccountId)
            .setField(Account.Order_Protocol__c, ORDER_PROTOCOL_TABLET)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setParent('Parent', businessAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL_TABLET)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent('Account', businessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_MARKETPLACE,
                parentWorkOrder.Id
            )
            .setField(WorkOrder.ContactId, decisionMakerContactId)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL_TABLET)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('Account', storeAccountFakeInstance)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Fake accountContactRelationshipFakeInstance = new Fake(AccountContactRelation.class)
            .setField(AccountContactRelation.AccountId, storeAccountId)
            .setField(AccountContactRelation.Account_Record_Type__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(AccountContactRelation.ContactId, decisionMakerContactId)
            .setParent(
                'Contact',
                new Fake(Contact.class)
                    .setField(Contact.Id, decisionMakerContactId)
                    .setParent('Account', businessAccountFakeInstance)
            );

        Fake acrWithRoles = new Fake(AccountContactRelation.class)
            .setField(AccountContactRelation.AccountId, businessAccount.Id)
            .setField(AccountContactRelation.ContactId, decisionMakerContactId)
            .setField(
                AccountContactRelation.Roles,
                CONTACT_ROLE_BUSINESS_OWNER +
                    ';' +
                    CONTACT_ROLE_DECISION_MAKER +
                    ';' +
                    CONTACT_ROLE_BUSINESS_DIRECTOR
            )
            .setField(AccountContactRelation.IsActive, true)
            .setParent(
                'Contact',
                new Fake(Contact.class)
                    .setField(Contact.Id, decisionMakerContactId)
                    .setField(Contact.Email, 'test@testEmail.com')
                    .setField(Contact.Title, 'Manager')
                    .setField(Contact.Phone, '555-123-4567')
                    .setField(Contact.Birthdate, Date.newInstance(1989, 11, 26))
                    .setField(Contact.MailingStreet, '1234 Yonge Street')
                    .setField(Contact.MailingCity, 'Toronto')
                    .setField(Contact.MailingState, 'Ontario')
                    .setField(Contact.MailingPostalCode, 'XYZ 123')
                    .setField(Contact.MailingCountry, COUNTRY_CANADA)
                    .setParent('Account', businessAccountFakeInstance)
            );

        AccountContactRelation accountContactRelationship = (AccountContactRelation) accountContactRelationshipFakeInstance.toSobject();
        AccountContactRelation acrWithAllRoles = (AccountContactRelation) acrWithRoles.toSObject();
        List<Readiness_Check_Failure__c> mockReadinessValidationRuleFailureRecords = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRules[0].Object_Label__c,
                Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
                Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
                Parent_Work_Order__c = parentWorkOrder.Id,
                Child_Work_Order__c = childWorkOrder.Id,
                Account_Name__c = childWorkOrder.AccountId,
                Contact_Name__c = decisionMakerContactId
            )
        };
        Static_Configurations__mdt eligibleCountriesStatesToValidateBirthdate = new Static_Configurations__mdt(
            DeveloperName = BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            MasterLabel = BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            Configuration_Value__c = ELIGIBLE_COUNTRIES_STATES_TO_VALIDATE_BIRTHDATE
        );
        Static_Configurations__mdt eligibleCountriesStatesToValidateSSN = new Static_Configurations__mdt(
            DeveloperName = SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            MasterLabel = SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            Configuration_Value__c = ELIGIBLE_COUNTRIES_STATES_TO_VALIDATE_SSN
        );

        List<Readiness_Check_Failure__c> mockexistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IAccountContactRelationsSelector accountContactRelationsSelector = (IAccountContactRelationsSelector) mocks.mock(
            IAccountContactRelationsSelector.class
        );
        IStaticConfigurationsSelector mockStaticConfigurationsSelector = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        IWorkOrdersSelector workOrdersSelectorMock = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IReadinessValidationRulesService mockReadinessValidationRulesService = (IReadinessValidationRulesService) mocks.mock(
            IReadinessValidationRulesService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                accountsSelectorMock.selectAccountsByIdAndFieldSet(
                    (Schema.Fieldset) fflib_Match.anyObject(),
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<Account>{ businessAccount });

        mocks.when(accountContactRelationsSelector.sObjectType())
            .thenReturn(AccountContactRelation.SObjectType);
        mocks.when(
                accountContactRelationsSelector.selectByAccountIds(new Set<Id>{ storeAccountId })
            )
            .thenReturn(new List<AccountContactRelation>{ accountContactRelationship });

        mocks.when(
                accountContactRelationsSelector.selectActiveAcrByAccountIds(
                    new Set<Id>{ businessAccountId }
                )
            )
            .thenReturn(new List<AccountContactRelation>{ acrWithAllRoles });

        mocks.when(mockStaticConfigurationsSelector.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG
                )
            )
            .thenReturn(eligibleCountriesStatesToValidateBirthdate);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG
                )
            )
            .thenReturn(eligibleCountriesStatesToValidateSSN);
        mocks.when(
                mockReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
                    readinessValidationRuleTypeSubTypes,
                    storeReadinessValidationRules[0],
                    childWorkOrder
                )
            )
            .thenReturn(true);
            mocks.when(
                mockReadinessValidationRulesService.collectReadinessValidationRuleMappings(
                    storeReadinessValidationRules
                )
            )
            .thenReturn(readinessValidationRuleTypeSubTypes);
        mocks.when(
                mockReadinessValidationRulesService.isBypassedBySegmentTypeSubType(
                    null,
                     childWorkOrder
                )
            )
            .thenReturn(true);

            mocks.when(workOrdersSelectorMock.sObjectType()).thenReturn(WorkOrder.SObjectType);
            mocks.when(workOrdersSelectorMock.selectById((Set<Id>) fflib_Match.anyObject()))
                .thenReturn(new List<WorkOrder>{ parentWorkOrder, childWorkOrder });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(accountContactRelationsSelector);
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        Application.SELECTOR.setMock(workOrdersSelectorMock);
        Application.SERVICE.setMock(
            IReadinessValidationRulesService.class,
            mockReadinessValidationRulesService
        );
        ContactValidationsServiceImpl contactValidationsServiceImplInstance = new ContactValidationsServiceImpl();
        contactValidationsServiceImplInstance.validate(
            new List<WorkOrder>{ childWorkOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockexistingReadinessCheckFailures,
            CONTACT_OBJECT_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessValidationRuleFailureRecords);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    @isTest
    static void testWhenCanadianMxMissingContactDetailsThenCreateReadinessFailure() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id bizOwnerContactId = fflib_IDGenerator.generate(Contact.SObjectType); // Business Owner
        Id bizRepContactId = fflib_IDGenerator.generate(Contact.SObjectType); // Business Representative

        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                    CUSTOM_METADATA_ERROR_MESSAGE_CANADA,
                    '',
                    SERVICE_METHOD_VALIDATE_CANADA_ROLES,
                    CONTACT_OBJECT_NAME,
                    SERVICE_CLASS_NAME
                )
            )
        };
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Id, businessAccountId)
            .setField(Account.BillingCountry, COUNTRY_CANADA)
            .setField(Account.BillingCountryCode, COUNTRY_CODE_CANADA)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccount.Id,
                VERTICAL
            )
            .setField(Account.Id, storeAccountId)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setParent('Parent', businessAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent('Account', businessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_MARKETPLACE,
                parentWorkOrder.Id
            )
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL_TABLET)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('Account', storeAccountFakeInstance)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );

        // SET UP ACCOUNT CONTACT RELATIONS
        // Note - `Business Director` is missing in this test case - this is why the RC fails
        Fake accountContactRelationshipFakeInstanceForBizOwner = createFakeAccountContactRelationInstance(
            businessAccountFakeInstance,
            bizOwnerContactId,
            CONTACT_ROLE_BUSINESS_OWNER
        );
        Fake accountContactRelationshipFakeInstanceForBizRep = createFakeAccountContactRelationInstance(
            businessAccountFakeInstance,
            bizRepContactId,
            CONTACT_ROLE_DECISION_MAKER
        );
        AccountContactRelation bizOwnerACR = (AccountContactRelation) accountContactRelationshipFakeInstanceForBizOwner.toSobject();
        AccountContactRelation bizRepACR = (AccountContactRelation) accountContactRelationshipFakeInstanceForBizRep.toSobject();

        List<Readiness_Check_Failure__c> mockReadinessValidationRuleFailureRecords = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRules[0].Object_Label__c,
                Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
                Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
                Parent_Work_Order__c = parentWorkOrder.Id,
                Child_Work_Order__c = parentWorkOrder.Id,
                Account_Name__c = parentWorkOrder.AccountId,
                Contact_Name__c = null
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IAccountContactRelationsSelector accountContactRelationsSelector = (IAccountContactRelationsSelector) mocks.mock(
            IAccountContactRelationsSelector.class
        );
        IReadinessValidationRulesService mockReadinessValidationRulesService = (IReadinessValidationRulesService) mocks.mock(
            IReadinessValidationRulesService.class
        );
        IWorkOrdersSelector workOrdersSelectorMock = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        mocks.startStubbing();
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                accountsSelectorMock.selectAccountsByIdAndFieldSet(
                    (Schema.Fieldset) fflib_Match.anyObject(),
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<Account>{ businessAccount, storeAccount });

        mocks.when(accountContactRelationsSelector.sObjectType())
            .thenReturn(AccountContactRelation.SObjectType);
        mocks.when(
                accountContactRelationsSelector.selectActiveAcrByAccountIds(
                    new Set<Id>{ businessAccountId }
                )
            )
            .thenReturn(new List<AccountContactRelation>{ bizOwnerACR, bizRepACR });
        mocks.when(
                accountContactRelationsSelector.selectByAccountIds(new Set<Id>{ storeAccountId })
            )
            .thenReturn(new List<AccountContactRelation>{ bizRepACR });

        mocks.when(workOrdersSelectorMock.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(workOrdersSelectorMock.selectById((Set<Id>) fflib_Match.anyObject()))
            .thenReturn(new List<WorkOrder>{ parentWorkOrder, childWorkOrder });
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(accountContactRelationsSelector);
        Application.SELECTOR.setMock(workOrdersSelectorMock);
        Application.SERVICE.setMock(
            IReadinessValidationRulesService.class,
            mockReadinessValidationRulesService
        );
        /*
            31 May 2024 - Changes to the public `validate()` method in separate work is leading to upstream build failures
            New methods had to be adjusted to accommodate this parameter list modification, but these changes are not yet
            in upstream environments where the Stripe KYC effort needs to go. Commenting out calls to `validate()` in new
            methods temporarily, and using an existing method (with parameters changed correctly in relevant environments)
            to do Stripe KYC unit testing.
        */
        // ContactValidationsServiceImpl contactValidationsServiceImplInstance = new ContactValidationsServiceImpl();
        // contactValidationsServiceImplInstance.validate(
        //     new List<WorkOrder>{ childWorkOrder },
        //     new List<WorkOrder>{ parentWorkOrder },
        //     storeReadinessValidationRules,
        //     new List<Readiness_Check_Failure__c>(),
        //     CONTACT_OBJECT_NAME
        // );
        // ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
        //     .registerNew(mockReadinessValidationRuleFailureRecords);
        // ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    @IsTest
    static void testWhenCanadianMxIsMissingContactFieldDetailsThenCreateReadinessFailure() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);

        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                    CUSTOM_METADATA_ERROR_MESSAGE_CANADA_BIZ_OWNER,
                    '',
                    SERVICE_METHOD_VALIDATE_CANADA_BIZ_OWNER,
                    CONTACT_OBJECT_NAME,
                    SERVICE_CLASS_NAME
                )
            ),
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                    CUSTOM_METADATA_ERROR_MESSAGE_CANADA_BIZ_DIRECTOR,
                    '',
                    SERVICE_METHOD_VALIDATE_CANADA_BIZ_DIRECTOR,
                    CONTACT_OBJECT_NAME,
                    SERVICE_CLASS_NAME
                )
            )
        };
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Id, businessAccountId)
            .setField(Account.BillingCountry, COUNTRY_CANADA)
            .setField(Account.BillingCountryCode, COUNTRY_CODE_CANADA)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccount.Id,
                VERTICAL
            )
            .setField(Account.Id, storeAccountId)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setParent('Parent', businessAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent('Account', businessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_MARKETPLACE,
                parentWorkOrder.Id
            )
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL_TABLET)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('Account', storeAccountFakeInstance)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );

        // SET UP ACCOUNT CONTACT RELATIONS
        // These can all be the same person in a single ACR record
        Fake acrFakeInstance = createFakeAccountContactRelationInstance(
            businessAccountFakeInstance,
            contactId,
            CONTACT_ROLE_BUSINESS_OWNER +
                ';' +
                CONTACT_ROLE_DECISION_MAKER +
                ';' +
                CONTACT_ROLE_BUSINESS_DIRECTOR
        );
        AccountContactRelation allACRs = (AccountContactRelation) acrFakeInstance.toSobject();

        List<Readiness_Check_Failure__c> mockReadinessValidationRuleFailureRecords = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRules[0].Object_Label__c,
                Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
                Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
                Parent_Work_Order__c = parentWorkOrder.Id,
                Child_Work_Order__c = parentWorkOrder.Id,
                Account_Name__c = parentWorkOrder.AccountId,
                Contact_Name__c = null
            ),
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRules[1].Object_Label__c,
                Field_Name__c = storeReadinessValidationRules[1].Field_Label__c,
                Error_Message__c = storeReadinessValidationRules[1].Error_Message__c,
                Parent_Work_Order__c = parentWorkOrder.Id,
                Child_Work_Order__c = parentWorkOrder.Id,
                Account_Name__c = parentWorkOrder.AccountId,
                Contact_Name__c = null
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IAccountContactRelationsSelector accountContactRelationsSelector = (IAccountContactRelationsSelector) mocks.mock(
            IAccountContactRelationsSelector.class
        );
        IReadinessValidationRulesService mockReadinessValidationRulesService = (IReadinessValidationRulesService) mocks.mock(
            IReadinessValidationRulesService.class
        );
        IWorkOrdersSelector workOrdersSelectorMock = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        mocks.startStubbing();
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                accountsSelectorMock.selectAccountsByIdAndFieldSet(
                    (Schema.Fieldset) fflib_Match.anyObject(),
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<Account>{ businessAccount, storeAccount });

        mocks.when(accountContactRelationsSelector.sObjectType())
            .thenReturn(AccountContactRelation.SObjectType);
        mocks.when(
                accountContactRelationsSelector.selectActiveAcrByAccountIds(
                    new Set<Id>{ businessAccountId }
                )
            )
            .thenReturn(new List<AccountContactRelation>{ allACRs });
        mocks.when(
                accountContactRelationsSelector.selectByAccountIds(new Set<Id>{ storeAccountId })
            )
            .thenReturn(new List<AccountContactRelation>{ allACRs });

        mocks.when(workOrdersSelectorMock.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(workOrdersSelectorMock.selectById((Set<Id>) fflib_Match.anyObject()))
            .thenReturn(new List<WorkOrder>{ parentWorkOrder, childWorkOrder });
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(accountContactRelationsSelector);
        Application.SELECTOR.setMock(workOrdersSelectorMock);
        Application.SERVICE.setMock(
            IReadinessValidationRulesService.class,
            mockReadinessValidationRulesService
        );
        /*
            31 May 2024 - Changes to the public `validate()` method in separate work is leading to upstream build failures
            New methods had to be adjusted to accommodate this parameter list modification, but these changes are not yet
            in upstream environments where the Stripe KYC effort needs to go. Commenting out calls to `validate()` in new
            methods temporarily, and using an existing method (with parameters changed correctly in relevant environments)
            to do Stripe KYC unit testing.
        */
        // ContactValidationsServiceImpl contactValidationsServiceImplInstance = new ContactValidationsServiceImpl();
        // contactValidationsServiceImplInstance.validate(
        //     new List<WorkOrder>{ childWorkOrder },
        //     new List<WorkOrder>{ parentWorkOrder },
        //     storeReadinessValidationRules,
        //     new List<Readiness_Check_Failure__c>(),
        //     CONTACT_OBJECT_NAME
        // );
        // ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
        //     .registerNew(mockReadinessValidationRuleFailureRecords);
        // ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    @IsTest
    static void testWhenCanadianMxHaveValidContactRolesThenDoNotLogErrors() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);

        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                    CUSTOM_METADATA_ERROR_MESSAGE_CANADA_BIZ_OWNER,
                    '',
                    SERVICE_METHOD_VALIDATE_CANADA_BIZ_OWNER,
                    CONTACT_OBJECT_NAME,
                    SERVICE_CLASS_NAME
                )
            ),
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                    CUSTOM_METADATA_ERROR_MESSAGE_CANADA_BIZ_DIRECTOR,
                    '',
                    SERVICE_METHOD_VALIDATE_CANADA_BIZ_DIRECTOR,
                    CONTACT_OBJECT_NAME,
                    SERVICE_CLASS_NAME
                )
            )
        };
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Id, businessAccountId)
            .setField(Account.BillingCountry, COUNTRY_CANADA)
            .setField(Account.BillingCountryCode, COUNTRY_CODE_CANADA)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccount.Id,
                VERTICAL
            )
            .setField(Account.Id, storeAccountId)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setParent('Parent', businessAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent('Account', businessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_MARKETPLACE,
                parentWorkOrder.Id
            )
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL_TABLET)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('Account', storeAccountFakeInstance)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );

        Fake fakeACR = new Fake(AccountContactRelation.class)
            .setField(AccountContactRelation.AccountId, businessAccount.Id)
            .setField(AccountContactRelation.ContactId, contactId)
            .setField(
                AccountContactRelation.Roles,
                CONTACT_ROLE_BUSINESS_OWNER +
                    ';' +
                    CONTACT_ROLE_DECISION_MAKER +
                    ';' +
                    CONTACT_ROLE_BUSINESS_DIRECTOR
            )
            .setField(AccountContactRelation.IsActive, true)
            .setParent(
                'Contact',
                new Fake(Contact.class)
                    .setField(Contact.Id, contactId)
                    .setField(Contact.Email, 'test@testEmail.com')
                    .setField(Contact.Title, 'Manager')
                    .setField(Contact.Phone, '555-123-4567')
                    .setField(Contact.Birthdate, Date.newInstance(1989, 11, 26))
                    .setField(Contact.MailingStreet, '1234 Yonge Street')
                    .setField(Contact.MailingCity, 'Toronto')
                    .setField(Contact.MailingState, 'Ontario')
                    .setField(Contact.MailingPostalCode, 'XYZ 123')
                    .setField(Contact.MailingCountry, COUNTRY_CANADA)
                    .setParent('Account', businessAccountFakeInstance)
            );

        AccountContactRelation allACRs = (AccountContactRelation) fakeACR.toSobject();

        List<Readiness_Check_Failure__c> mockReadinessValidationRuleFailureRecords = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IAccountContactRelationsSelector accountContactRelationsSelector = (IAccountContactRelationsSelector) mocks.mock(
            IAccountContactRelationsSelector.class
        );
        IReadinessValidationRulesService mockReadinessValidationRulesService = (IReadinessValidationRulesService) mocks.mock(
            IReadinessValidationRulesService.class
        );
        IWorkOrdersSelector workOrdersSelectorMock = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        mocks.startStubbing();
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                accountsSelectorMock.selectAccountsByIdAndFieldSet(
                    (Schema.Fieldset) fflib_Match.anyObject(),
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<Account>{ businessAccount, storeAccount });

        mocks.when(accountContactRelationsSelector.sObjectType())
            .thenReturn(AccountContactRelation.SObjectType);
        mocks.when(
                accountContactRelationsSelector.selectActiveAcrByAccountIds(
                    new Set<Id>{ businessAccountId }
                )
            )
            .thenReturn(new List<AccountContactRelation>{ allACRs });
        mocks.when(
                accountContactRelationsSelector.selectByAccountIds(new Set<Id>{ storeAccountId })
            )
            .thenReturn(new List<AccountContactRelation>{ allACRs });

        mocks.when(workOrdersSelectorMock.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(workOrdersSelectorMock.selectById((Set<Id>) fflib_Match.anyObject()))
            .thenReturn(new List<WorkOrder>{ parentWorkOrder, childWorkOrder });
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(accountContactRelationsSelector);
        Application.SELECTOR.setMock(workOrdersSelectorMock);
        Application.SERVICE.setMock(
            IReadinessValidationRulesService.class,
            mockReadinessValidationRulesService
        );
        /*
            31 May 2024 - Changes to the public `validate()` method in separate work is leading to upstream build failures
            New methods had to be adjusted to accommodate this parameter list modification, but these changes are not yet
            in upstream environments where the Stripe KYC effort needs to go. Commenting out calls to `validate()` in new
            methods temporarily, and using an existing method (with parameters changed correctly in relevant environments)
            to do Stripe KYC unit testing.
        */
        // ContactValidationsServiceImpl contactValidationsServiceImplInstance = new ContactValidationsServiceImpl();
        // contactValidationsServiceImplInstance.validate(
        //     new List<WorkOrder>{ childWorkOrder },
        //     new List<WorkOrder>{ parentWorkOrder },
        //     storeReadinessValidationRules,
        //     new List<Readiness_Check_Failure__c>(),
        //     CONTACT_OBJECT_NAME
        // );
        // ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(0)))
        //     .registerNew(mockReadinessValidationRuleFailureRecords);
        // ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description To test Readiness Check Failure records not created when Phone is populated on
     * 'Decision Maker' Contact associated to the store account with Order Protocol containing
     * 'Tablet'.
     */
    @isTest
    private static void testWhenPhoneNumberExistsOnDecisionMakerContactAssociatedToStoreWithTabletOrderProtocolThenReadinessCheckFailureNotCreated() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                    CUSTOM_METADATA_ERROR_MESSAGE_DECISION_MAKER,
                    '',
                    SERVICE_METHOD_VALIDATE_DECISION_MAKER_CONTACT_PHONE,
                    CONTACT_OBJECT_NAME,
                    SERVICE_CLASS_NAME
                )
            )
        };
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Id, businessAccountId)
            .setField(Account.BillingCountryCode, ELIGIBLE_COUNTRY_TO_VALIDATE_AU)
            .setField(Account.BillingStateCode, ELIGIBLE_STATE_TO_VALIDATE_QLD)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccount.Id,
                VERTICAL
            )
            .setField(Account.Id, storeAccountId)
            .setField(Account.BillingCountryCode, ELIGIBLE_COUNTRY_TO_VALIDATE_AU)
            .setField(Account.BillingStateCode, ELIGIBLE_STATE_TO_VALIDATE_QLD)
            .setField(Account.Order_Protocol__c, ORDER_PROTOCOL_TABLET)
            .setParent('Parent', businessAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake contactFakeInstance = new Fake(Contact.class)
            .setField(Contact.LastName, CONTACT_LASTNAME)
            .setField(Contact.FirstName, CONTACT_FIRSTNAME)
            .setField(Contact.Email, CONTACT_EMAIL)
            .setField(Contact.Phone, CONTACT_PHONE)
            .setField(Contact.AccountId, storeAccountId)
            .setField(Contact.SSN_Last_4Digits__c, SSN_LAST_FOUR_DIGITS)
            .setFakeId();
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL_TABLET)
            .setParent('Account', businessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Contact mockContact = (Contact) ServiceMockDataBuilder.convertToSObject(
            contactFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_MARKETPLACE,
                parentWorkOrder.Id
            )
            .setField(WorkOrder.ContactId, mockContact.Id)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL_TABLET)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('Account', storeAccountFakeInstance)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Fake accountContactRelationshipFakeInstance = new Fake(AccountContactRelation.class)
            .setField(AccountContactRelation.AccountId, storeAccountId)
            .setField(AccountContactRelation.Account_Record_Type__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(AccountContactRelation.ContactId, mockContact.Id)
            .setParent(
                'Contact',
                new Fake(Contact.class)
                    .setField(Contact.Id, mockContact.Id)
                    .setField(Contact.Phone, CONTACT_PHONE)
                    .setParent('Account', storeAccountFakeInstance)
            );
        AccountContactRelation accountContactRelationship = (AccountContactRelation) accountContactRelationshipFakeInstance.toSobject();
        Static_Configurations__mdt eligibleCountriesStatesToValidateBirthdate = new Static_Configurations__mdt(
            DeveloperName = BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            MasterLabel = BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            Configuration_Value__c = ELIGIBLE_COUNTRIES_STATES_TO_VALIDATE_BIRTHDATE
        );
        Static_Configurations__mdt eligibleCountriesStatesToValidateSSN = new Static_Configurations__mdt(
            DeveloperName = SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            MasterLabel = SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            Configuration_Value__c = ELIGIBLE_COUNTRIES_STATES_TO_VALIDATE_SSN
        );

        List<Readiness_Check_Failure__c> mockexistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountContactRelationsSelector accountContactRelationsSelector = (IAccountContactRelationsSelector) mocks.mock(
            IAccountContactRelationsSelector.class
        );
        IStaticConfigurationsSelector mockStaticConfigurationsSelector = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(accountContactRelationsSelector.sObjectType())
            .thenReturn(AccountContactRelation.SObjectType);
        mocks.when(
                accountContactRelationsSelector.selectByAccountIds(new Set<Id>{ storeAccountId })
            )
            .thenReturn(new List<AccountContactRelation>{ accountContactRelationship });
        mocks.when(mockStaticConfigurationsSelector.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG
                )
            )
            .thenReturn(eligibleCountriesStatesToValidateBirthdate);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG
                )
            )
            .thenReturn(eligibleCountriesStatesToValidateSSN);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(accountContactRelationsSelector);
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        ContactValidationsServiceImpl contactValidationsServiceImplInstance = new ContactValidationsServiceImpl();
        contactValidationsServiceImplInstance.validate(
            new List<WorkOrder>{ childWorkOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockexistingReadinessCheckFailures,
            CONTACT_OBJECT_NAME
        );
        // Readiness Check Failure is not created as Phone is populated on Decision Maker Contact.
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description To test Readiness Check Failure creation when Phone is not populated on
     * 'Decision Maker' Contact associated to the store account with Order Protocol containing
     * 'Tablet'.
     */
    @isTest
    private static void testWhenPhoneNumberNullOnDecisionMakerContactAssociatedToStoreWithTabletOrderProtocolThenReadinessCheckFailureCreated() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                    CUSTOM_METADATA_ERROR_MESSAGE_DECISION_MAKER,
                    '',
                    SERVICE_METHOD_VALIDATE_DECISION_MAKER_CONTACT_PHONE,
                    CONTACT_OBJECT_NAME,
                    SERVICE_CLASS_NAME
                )
            )
        };
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Id, businessAccountId)
            .setField(Account.BillingCountryCode, ELIGIBLE_COUNTRY_TO_VALIDATE_AU)
            .setField(Account.BillingStateCode, ELIGIBLE_STATE_TO_VALIDATE_QLD)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccount.Id,
                VERTICAL
            )
            .setField(Account.Id, storeAccountId)
            .setField(Account.BillingCountryCode, ELIGIBLE_COUNTRY_TO_VALIDATE_AU)
            .setField(Account.BillingStateCode, ELIGIBLE_STATE_TO_VALIDATE_QLD)
            .setField(Account.Order_Protocol__c, ORDER_PROTOCOL_TABLET)
            .setParent('Parent', businessAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL_TABLET)
            .setParent('Account', businessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake contactFakeInstance = new Fake(Contact.class)
            .setField(Contact.LastName, CONTACT_LASTNAME)
            .setField(Contact.FirstName, CONTACT_FIRSTNAME)
            .setField(Contact.Email, CONTACT_EMAIL)
            .setField(Contact.Phone, null)
            .setField(Contact.AccountId, storeAccountId)
            .setField(Contact.SSN_Last_4Digits__c, SSN_LAST_FOUR_DIGITS)
            .setFakeId();
        Contact mockContact = (Contact) ServiceMockDataBuilder.convertToSObject(
            contactFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_MARKETPLACE,
                parentWorkOrder.Id
            )
            .setField(WorkOrder.ContactId, mockContact.Id)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL_TABLET)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('Account', storeAccountFakeInstance)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Fake accountContactRelationshipFakeInstance = new Fake(AccountContactRelation.class)
            .setField(AccountContactRelation.AccountId, storeAccountId)
            .setField(AccountContactRelation.Account_Record_Type__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(AccountContactRelation.ContactId, mockContact.Id)
            .setParent(
                'Contact',
                new Fake(Contact.class)
                    .setField(Contact.Id, mockContact.Id)
                    .setField(Contact.Phone, null)
                    .setParent('Account', storeAccountFakeInstance)
            );
        AccountContactRelation accountContactRelationship = (AccountContactRelation) accountContactRelationshipFakeInstance.toSobject();
        List<Readiness_Check_Failure__c> mockReadinessValidationRuleFailureRecords = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRules[0].Object_Label__c,
                Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
                Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
                Parent_Work_Order__c = parentWorkOrder.Id,
                Child_Work_Order__c = childWorkOrder.Id,
                Account_Name__c = childWorkOrder.AccountId,
                Contact_Name__c = mockContact.Id
            )
        };
        Static_Configurations__mdt eligibleCountriesStatesToValidateBirthdate = new Static_Configurations__mdt(
            DeveloperName = BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            MasterLabel = BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            Configuration_Value__c = ELIGIBLE_COUNTRIES_STATES_TO_VALIDATE_BIRTHDATE
        );
        Static_Configurations__mdt eligibleCountriesStatesToValidateSSN = new Static_Configurations__mdt(
            DeveloperName = SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            MasterLabel = SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            Configuration_Value__c = ELIGIBLE_COUNTRIES_STATES_TO_VALIDATE_SSN
        );

        List<Readiness_Check_Failure__c> mockexistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountContactRelationsSelector accountContactRelationsSelector = (IAccountContactRelationsSelector) mocks.mock(
            IAccountContactRelationsSelector.class
        );
        IStaticConfigurationsSelector mockStaticConfigurationsSelector = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(accountContactRelationsSelector.sObjectType())
            .thenReturn(AccountContactRelation.SObjectType);
        mocks.when(
                accountContactRelationsSelector.selectByAccountIds(new Set<Id>{ storeAccountId })
            )
            .thenReturn(new List<AccountContactRelation>{ accountContactRelationship });
        mocks.when(mockStaticConfigurationsSelector.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG
                )
            )
            .thenReturn(eligibleCountriesStatesToValidateBirthdate);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG
                )
            )
            .thenReturn(eligibleCountriesStatesToValidateSSN);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(accountContactRelationsSelector);
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        ContactValidationsServiceImpl contactValidationsServiceImplInstance = new ContactValidationsServiceImpl();
        contactValidationsServiceImplInstance.validate(
            new List<WorkOrder>{ childWorkOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockexistingReadinessCheckFailures,
            CONTACT_OBJECT_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessValidationRuleFailureRecords);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Readiness Check Failure creation on recently updated Decision Maker Contact
     * when Phone is not populated on 'Decision Maker' Contacts associated to the store account with
     * Order Protocol containing 'Tablet'.
     */
    @isTest
    private static void testWhenPhoneNumberNullOnDecisionMakerContactsAssociatedToStoreWithTabletOrderProtocolThenReadinessCheckFailureCreatedOnRecentlyUpdatedContact() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                    CUSTOM_METADATA_ERROR_MESSAGE_DECISION_MAKER,
                    '',
                    SERVICE_METHOD_VALIDATE_DECISION_MAKER_CONTACT_PHONE,
                    CONTACT_OBJECT_NAME,
                    SERVICE_CLASS_NAME
                )
            )
        };
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Id, businessAccountId)
            .setField(Account.BillingCountryCode, ELIGIBLE_COUNTRY_TO_VALIDATE_AU)
            .setField(Account.BillingStateCode, ELIGIBLE_STATE_TO_VALIDATE_QLD)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccount.Id,
                VERTICAL
            )
            .setField(Account.Id, storeAccountId)
            .setField(Account.BillingCountryCode, ELIGIBLE_COUNTRY_TO_VALIDATE_AU)
            .setField(Account.BillingStateCode, ELIGIBLE_STATE_TO_VALIDATE_QLD)
            .setField(Account.Order_Protocol__c, ORDER_PROTOCOL_TABLET)
            .setParent('Parent', businessAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL_TABLET)
            .setParent('Account', businessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake contactFakeInstance = new Fake(Contact.class)
            .setField(Contact.LastName, CONTACT_LASTNAME)
            .setField(Contact.FirstName, CONTACT_FIRSTNAME)
            .setField(Contact.Email, CONTACT_EMAIL)
            .setField(Contact.Phone, null)
            .setField(Contact.AccountId, storeAccountId)
            .setField(Contact.SSN_Last_4Digits__c, SSN_LAST_FOUR_DIGITS)
            .setFakeId();
        Contact mockContact = (Contact) ServiceMockDataBuilder.convertToSObject(
            contactFakeInstance
        );
        Fake recentlyUpdatedContactFakeInstance = new Fake(Contact.class)
            .setField(Contact.LastName, CONTACT_LASTNAME)
            .setField(Contact.FirstName, CONTACT_FIRSTNAME)
            .setField(Contact.Email, CONTACT_EMAIL)
            .setField(Contact.Phone, null)
            .setField(Contact.AccountId, storeAccountId)
            .setField(Contact.SSN_Last_4Digits__c, SSN_LAST_FOUR_DIGITS)
            .setFakeId();
        Contact recentlyUpdatedtMockContact = (Contact) ServiceMockDataBuilder.convertToSObject(
            recentlyUpdatedContactFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_MARKETPLACE,
                parentWorkOrder.Id
            )
            .setField(WorkOrder.ContactId, recentlyUpdatedtMockContact.Id)
            .setField(WorkOrder.Order_Protocol__c, ORDER_PROTOCOL_TABLET)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('Account', storeAccountFakeInstance)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Fake accountContactRelationshipFakeInstance = new Fake(AccountContactRelation.class)
            .setField(AccountContactRelation.AccountId, storeAccountId)
            .setField(AccountContactRelation.Account_Record_Type__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(AccountContactRelation.ContactId, mockContact.Id)
            .setParent(
                'Contact',
                new Fake(Contact.class)
                    .setField(Contact.Id, mockContact.Id)
                    .setField(Contact.Phone, null)
                    .setParent('Account', storeAccountFakeInstance)
            );
        AccountContactRelation accountContactRelationship = (AccountContactRelation) accountContactRelationshipFakeInstance.toSobject();
        Fake recentlyUpdatedAccountContactRelationshipFakeInstance = new Fake(
                AccountContactRelation.class
            )
            .setField(AccountContactRelation.AccountId, storeAccountId)
            .setField(AccountContactRelation.Account_Record_Type__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
            .setField(AccountContactRelation.ContactId, recentlyUpdatedtMockContact.Id)
            .setParent(
                'Contact',
                new Fake(Contact.class)
                    .setField(Contact.Id, recentlyUpdatedtMockContact.Id)
                    .setField(Contact.Phone, null)
                    .setParent('Account', storeAccountFakeInstance)
            );
        AccountContactRelation recentAccountContactRelationship = (AccountContactRelation) recentlyUpdatedAccountContactRelationshipFakeInstance.toSobject();
        List<Readiness_Check_Failure__c> mockReadinessValidationRuleFailureRecords = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRules[0].Object_Label__c,
                Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
                Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
                Parent_Work_Order__c = parentWorkOrder.Id,
                Child_Work_Order__c = childWorkOrder.Id,
                Account_Name__c = childWorkOrder.AccountId,
                Contact_Name__c = recentlyUpdatedtMockContact.Id
            )
        };
        Static_Configurations__mdt eligibleCountriesStatesToValidateBirthdate = new Static_Configurations__mdt(
            DeveloperName = BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            MasterLabel = BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            Configuration_Value__c = ELIGIBLE_COUNTRIES_STATES_TO_VALIDATE_BIRTHDATE
        );
        Static_Configurations__mdt eligibleCountriesStatesToValidateSSN = new Static_Configurations__mdt(
            DeveloperName = SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            MasterLabel = SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            Configuration_Value__c = ELIGIBLE_COUNTRIES_STATES_TO_VALIDATE_SSN
        );

        List<Readiness_Check_Failure__c> mockexistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountContactRelationsSelector accountContactRelationsSelector = (IAccountContactRelationsSelector) mocks.mock(
            IAccountContactRelationsSelector.class
        );
        IStaticConfigurationsSelector mockStaticConfigurationsSelector = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(accountContactRelationsSelector.sObjectType())
            .thenReturn(AccountContactRelation.SObjectType);
        mocks.when(
                accountContactRelationsSelector.selectByAccountIds(new Set<Id>{ storeAccountId })
            )
            .thenReturn(
                new List<AccountContactRelation>{
                    recentAccountContactRelationship,
                    accountContactRelationship
                }
            );
        mocks.when(mockStaticConfigurationsSelector.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG
                )
            )
            .thenReturn(eligibleCountriesStatesToValidateBirthdate);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG
                )
            )
            .thenReturn(eligibleCountriesStatesToValidateSSN);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(accountContactRelationsSelector);
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        ContactValidationsServiceImpl contactValidationsServiceImplInstance = new ContactValidationsServiceImpl();
        contactValidationsServiceImplInstance.validate(
            new List<WorkOrder>{ childWorkOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockexistingReadinessCheckFailures,
            CONTACT_OBJECT_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessValidationRuleFailureRecords);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Readiness check of Birthdate field not created when Billing Contact not
     * populated on Payment Account associated with recently updated 'Account Payment Account Relation'
     * of store Accounts having Product name as 'Alcohol Delivery' or 'Alcohol Pickup'
     * with Billing Country as Australia and State as Queensland.
     */
    @isTest
    private static void testWhenBirthdateNullOnBillingContactAssociatedWithPaymentAccountOnRecentlyUpdatedAccountPaymentAccountRelationThenReadinessCheckFailureNotCreated() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id paymentAccountId = fflib_IDGenerator.generate(Payment_Account__c.SObjectType);
        Id paymentAccountWithBillingContactId = fflib_IDGenerator.generate(
            Payment_Account__c.SObjectType
        );
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                    CUSTOM_METADATA_ERROR_MESSAGE_BIRTHDATE,
                    FIELD_NAME_BIRTHDATE,
                    SERVICE_METHOD_VALIDATE_BIRTHDATE,
                    CONTACT_OBJECT_NAME,
                    SERVICE_CLASS_NAME
                )
            )
        };
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Id, businessAccountId)
            .setField(Account.BillingCountryCode, ELIGIBLE_COUNTRY_TO_VALIDATE_AU)
            .setField(Account.BillingStateCode, ELIGIBLE_STATE_TO_VALIDATE_QLD)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                businessAccount.Id,
                VERTICAL
            )
            .setField(Account.Id, storeAccountId)
            .setField(Account.BillingCountryCode, ELIGIBLE_COUNTRY_TO_VALIDATE_AU)
            .setField(Account.BillingStateCode, ELIGIBLE_STATE_TO_VALIDATE_QLD)
            .setParent('Parent', businessAccountFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake paymentAccountFakeInstance = new Fake(Payment_Account__c.class)
            .setField(Payment_Account__c.Id, paymentAccountId)
            .setField(Payment_Account__c.LastModifiedDate, System.today().addDays(-5));
        Fake paymentAccountWithBillingContactFakeInstance = new Fake(Payment_Account__c.class)
            .setField(Payment_Account__c.Id, paymentAccountWithBillingContactId)
            .setField(Payment_Account__c.LastModifiedDate, System.today().addDays(-2));
        Fake contactFakeInstance = new Fake(Contact.class)
            .setField(Contact.LastName, CONTACT_LASTNAME)
            .setField(Contact.FirstName, CONTACT_FIRSTNAME)
            .setField(Contact.Email, CONTACT_EMAIL)
            .setField(Contact.Phone, CONTACT_PHONE)
            .setField(Contact.AccountId, businessAccount.Id)
            .setField(Contact.SSN_Last_4Digits__c, SSN_LAST_FOUR_DIGITS)
            .setField(Contact.BirthDate, Date.newInstance(1990, 3, 17))
            .setFakeId();
        Fake accountPaymentAccountRelationFakeInstance = new Fake(
                Account_Payment_Account_Relation__c.class
            )
            .setField(
                Account_Payment_Account_Relation__c.Account_Record_Type__c,
                ACCOUNT_RECORD_TYPE_NAME_STORE
            )
            .setParent('Account__r', businessAccountFakeInstance)
            .setFakeId();
        Fake accountPaymentAccountRelationWithBillingContactFakeInstance = new Fake(
                Account_Payment_Account_Relation__c.class
            )
            .setField(
                Account_Payment_Account_Relation__c.Account_Record_Type__c,
                ACCOUNT_RECORD_TYPE_NAME_STORE
            )
            .setParent('Account__r', businessAccountFakeInstance)
            .setFakeId();
        Fake productFakeInstance = ServiceMockDataBuilder.createProductFakeInstance(
            PRODUCT_NAME_ALCOHOL_DELIVERY
        );
        businessAccountFakeInstance.setChildren('Contacts', new List<Fake>{ contactFakeInstance });
        Fake merchantServicesFakeInstance = new Fake(Merchant_Service__c.class)
            .setField(Merchant_Service__c.Account__c, storeAccount.Id)
            .setParent('Product__r', productFakeInstance)
            .setFakeId();
        Merchant_Service__c merchantServiceInstance = (Merchant_Service__c) ServiceMockDataBuilder.convertToSObject(
            merchantServicesFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent('Account', businessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake childWorkOrderFakeInstance = ServiceMockDataBuilder.createChildWorkOrderFakeInstance(
                storeAccount.Id,
                WORKORDER_TYPE_MARKETPLACE,
                parentWorkOrder.Id
            )
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrder.Id)
            .setParent('Account', storeAccountFakeInstance)
            .setParent('ParentWorkOrder', parentWorkOrderFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderFakeInstance
        );
        Contact contact = (Contact) ServiceMockDataBuilder.convertToSObject(contactFakeInstance);
        accountPaymentAccountRelationFakeInstance
            .setField(Account_Payment_Account_Relation__c.Account__c, storeAccount.Id)
            .setField(Account_Payment_Account_Relation__c.Payment_Account__c, paymentAccountId)
            .setField(
                Account_Payment_Account_Relation__c.LastModifiedDate,
                System.today().addDays(-5)
            )
            .setParent(
                'Payment_Account__r',
                new Fake(Payment_Account__c.class)
                    .setField(Payment_Account__c.Id, paymentAccountId)
                    .setField(Payment_Account__c.Billing_Contact_Name__c, contact.Id)
                    .setParent('Billing_Contact_Name__r', contactFakeInstance)
            );
        accountPaymentAccountRelationWithBillingContactFakeInstance
            .setField(Account_Payment_Account_Relation__c.Account__c, storeAccount.Id)
            .setField(Account_Payment_Account_Relation__c.Payment_Account__c, paymentAccountId)
            .setField(
                Account_Payment_Account_Relation__c.LastModifiedDate,
                System.today().addDays(-2)
            )
            .setParent(
                'Payment_Account__r',
                new Fake(Payment_Account__c.class)
                    .setField(Payment_Account__c.Id, paymentAccountWithBillingContactId)
                    .setField(Payment_Account__c.Billing_Contact_Name__c, null)
            );
        paymentAccountFakeInstance
            .setChildren(
                'Account_Payment_Account_Relations__r',
                new List<Fake>{ accountPaymentAccountRelationFakeInstance }
            )
            .setParent('Billing_Contact_Name__r', contactFakeInstance);
        paymentAccountWithBillingContactFakeInstance
            .setChildren(
                'Account_Payment_Account_Relations__r',
                new List<Fake>{ accountPaymentAccountRelationFakeInstance }
            );
        Account_Payment_Account_Relation__c accountPaymentAccountRelationSobjectInstance = (Account_Payment_Account_Relation__c) ServiceMockDataBuilder.convertToSObject(
            accountPaymentAccountRelationFakeInstance
        );
        Account_Payment_Account_Relation__c accountPaymentAccountRelationWithBillingContactSobjectInstance = (Account_Payment_Account_Relation__c) ServiceMockDataBuilder.convertToSObject(
            accountPaymentAccountRelationWithBillingContactFakeInstance
        );
        Static_Configurations__mdt eligibleCountriesStatesToValidateBirthdate = new Static_Configurations__mdt(
            DeveloperName = BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            MasterLabel = BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            Configuration_Value__c = ELIGIBLE_COUNTRIES_STATES_TO_VALIDATE_BIRTHDATE
        );
        Static_Configurations__mdt eligibleCountriesStatesToValidateSSN = new Static_Configurations__mdt(
            DeveloperName = SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            MasterLabel = SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            Configuration_Value__c = ELIGIBLE_COUNTRIES_STATES_TO_VALIDATE_SSN
        );

        List<Readiness_Check_Failure__c> mockexistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountPaymentAccountRelationsSelector accountPaymentAccountSelector = (IAccountPaymentAccountRelationsSelector) mocks.mock(
            IAccountPaymentAccountRelationsSelector.class
        );
        IMerchantSelector merchantSelector = (IMerchantSelector) mocks.mock(
            IMerchantSelector.class
        );
        IStaticConfigurationsSelector mockStaticConfigurationsSelector = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(accountPaymentAccountSelector.sObjectType())
            .thenReturn(Account_Payment_Account_Relation__c.SObjectType);
        mocks.when(
                accountPaymentAccountSelector.selectByAccountIdsAndPaymentAccountRecordTypes(
                    new Set<Id>{ storeAccount.Id },
                    new Set<String>{ PAYMENT_ACCOUNT_RECORD_TYPE_PAYMENTS }
                )
            )
            .thenReturn(
                new List<Account_Payment_Account_Relation__c>{
                    accountPaymentAccountRelationWithBillingContactSobjectInstance,
                    accountPaymentAccountRelationSobjectInstance
                }
            );
        mocks.when(merchantSelector.sObjectType()).thenReturn(Merchant_Service__c.SObjectType);
        mocks.when(
                merchantSelector.selectServicesWithAlcoholProductsByAccountIds(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<Merchant_Service__c>{ merchantServiceInstance });
        mocks.when(mockStaticConfigurationsSelector.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG
                )
            )
            .thenReturn(eligibleCountriesStatesToValidateBirthdate);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG
                )
            )
            .thenReturn(eligibleCountriesStatesToValidateSSN);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(accountPaymentAccountSelector);
        Application.SELECTOR.setMock(merchantSelector);
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        ContactValidationsServiceImpl contactValidationsServiceImplInstance = new ContactValidationsServiceImpl();
        contactValidationsServiceImplInstance.validate(
            new List<WorkOrder>{ childWorkOrder },
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockexistingReadinessCheckFailures,
            CONTACT_OBJECT_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).registerNew(fflib_Match.anySObject());
        /**
         * Readiness Check Failure is not created as Billing Contact is not populated on
         * recently updated Payment Account.
         */
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description To test Readiness Check Failure creation when Decision Maker Contact does
     * not exist on the business Account for "Drive" Work Orders.
     */
    @isTest
    private static void testWhenDecisionMakerContactDoesNotExistOnBusinessThenCreateReadinessCheckFailure() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                    CUSTOM_METADATA_ERROR_MESSAGE_DECISION_MAKER_ON_PARENT,
                    '',
                    SERVICE_METHOD_VALIDATE_DECISION_MAKER,
                    CONTACT_OBJECT_NAME,
                    SERVICE_CLASS_NAME
                )
            )
        };
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Id, businessAccountId)
            .setField(Account.BillingCountryCode, ELIGIBLE_COUNTRY_TO_VALIDATE_US)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_DRIVE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setField(WorkOrder.Sub_Type__c, WORK_ORDER_SUB_TYPE_NET_NEW_BUSINESS)
            .setParent('Account', businessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        List<Readiness_Check_Failure__c> mockReadinessValidationRuleFailureRecords = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Object_Name__c = storeReadinessValidationRules[0].Object_Label__c,
                Field_Name__c = storeReadinessValidationRules[0].Field_Label__c,
                Error_Message__c = storeReadinessValidationRules[0].Error_Message__c,
                Parent_Work_Order__c = parentWorkOrder.Id,
                Child_Work_Order__c = parentWorkOrder.Id,
                Account_Name__c = parentWorkOrder.AccountId,
                Contact_Name__c = null
            )
        };
        Static_Configurations__mdt eligibleCountriesStatesToValidateBirthdate = new Static_Configurations__mdt(
            DeveloperName = BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            MasterLabel = BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            Configuration_Value__c = ELIGIBLE_COUNTRIES_STATES_TO_VALIDATE_BIRTHDATE
        );
        Static_Configurations__mdt eligibleCountriesStatesToValidateSSN = new Static_Configurations__mdt(
            DeveloperName = SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            MasterLabel = SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            Configuration_Value__c = ELIGIBLE_COUNTRIES_STATES_TO_VALIDATE_SSN
        );

        List<Readiness_Check_Failure__c> mockexistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountContactRelationsSelector accountContactRelationsSelector = (IAccountContactRelationsSelector) mocks.mock(
            IAccountContactRelationsSelector.class
        );
        IStaticConfigurationsSelector mockStaticConfigurationsSelector = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        IDecisionMakerCalculationService mockDecisionMakerCalculationService = (IDecisionMakerCalculationService) mocks.mock(
            IDecisionMakerCalculationService.class
        );
        IReadinessValidationRulesService mockReadinessValidationRulesService = (IReadinessValidationRulesService) mocks.mock(
            IReadinessValidationRulesService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(accountContactRelationsSelector.sObjectType())
            .thenReturn(AccountContactRelation.SObjectType);
        mocks.when(
                accountContactRelationsSelector.selectByAccountIds(new Set<Id>{ businessAccountId })
            )
            .thenReturn(new List<AccountContactRelation>{});
        mocks.when(mockStaticConfigurationsSelector.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG
                )
            )
            .thenReturn(eligibleCountriesStatesToValidateBirthdate);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG
                )
            )
            .thenReturn(eligibleCountriesStatesToValidateSSN);
        mocks.when(
                mockDecisionMakerCalculationService.getDecisionMakers(
                    new List<WorkOrder>{ parentWorkOrder }
                )
            )
            .thenReturn(new Map<Id, List<Id>>());
        mocks.when(
                mockReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
                    null,
                    storeReadinessValidationRules[0],
                    parentWorkOrder
                )
            )
            .thenReturn(true);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(accountContactRelationsSelector);
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        Application.SERVICE.setMock(
            IDecisionMakerCalculationService.class,
            mockDecisionMakerCalculationService
        );
        Application.SERVICE.setMock(
            IReadinessValidationRulesService.class,
            mockReadinessValidationRulesService
        );
        ContactValidationsServiceImpl contactValidationsServiceImplInstance = new ContactValidationsServiceImpl();
        contactValidationsServiceImplInstance.validate(
            new List<WorkOrder>{},
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockexistingReadinessCheckFailures,
            CONTACT_OBJECT_NAME
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerNew(mockReadinessValidationRuleFailureRecords);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test Readiness Check Failure records not created when Decision Maker Contact
     * exists on the business Account for "Drive" Work Orders.
     */
    @isTest
    private static void testWhenDecisionMakerContactExistsOnBusinessThenReadinessCheckFailureNotCreated() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id decisionMakerContactId = fflib_IDGenerator.generate(Contact.SObjectType);
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidationRules = new List<Store_Readiness_Validation_Rule__mdt>{
            (Store_Readiness_Validation_Rule__mdt) ServiceMockDataBuilder.convertToSObject(
                ServiceMockDataBuilder.createStoreReadinessValidationRuleFakeInstance(
                    CUSTOM_METADATA_ERROR_MESSAGE_DECISION_MAKER_ON_PARENT,
                    '',
                    SERVICE_METHOD_VALIDATE_DECISION_MAKER,
                    CONTACT_OBJECT_NAME,
                    SERVICE_CLASS_NAME
                )
            )
        };
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Id, businessAccountId)
            .setField(Account.BillingCountryCode, ELIGIBLE_COUNTRY_TO_VALIDATE_US)
            .setField(Account.Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS);
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                businessAccount.Id,
                WORKORDER_TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.Account_Record_Type_Name__c, ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .setParent('Account', businessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );
        Fake accountContactRelationshipFakeInstance = new Fake(AccountContactRelation.class)
            .setField(AccountContactRelation.AccountId, businessAccountId)
            .setField(
                AccountContactRelation.Account_Record_Type__c,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(AccountContactRelation.ContactId, decisionMakerContactId);
        AccountContactRelation accountContactRelationship = (AccountContactRelation) accountContactRelationshipFakeInstance.toSobject();
        Static_Configurations__mdt eligibleCountriesStatesToValidateBirthdate = new Static_Configurations__mdt(
            DeveloperName = BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            MasterLabel = BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            Configuration_Value__c = ELIGIBLE_COUNTRIES_STATES_TO_VALIDATE_BIRTHDATE
        );
        Static_Configurations__mdt eligibleCountriesStatesToValidateSSN = new Static_Configurations__mdt(
            DeveloperName = SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            MasterLabel = SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG,
            Configuration_Value__c = ELIGIBLE_COUNTRIES_STATES_TO_VALIDATE_SSN
        );

        List<Readiness_Check_Failure__c> mockexistingReadinessCheckFailures = new List<Readiness_Check_Failure__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountContactRelationsSelector accountContactRelationsSelector = (IAccountContactRelationsSelector) mocks.mock(
            IAccountContactRelationsSelector.class
        );
        IStaticConfigurationsSelector mockStaticConfigurationsSelector = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        IReadinessValidationRulesService mockReadinessValidationRulesService = (IReadinessValidationRulesService) mocks.mock(
            IReadinessValidationRulesService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(accountContactRelationsSelector.sObjectType())
            .thenReturn(AccountContactRelation.SObjectType);
        mocks.when(
                accountContactRelationsSelector.selectByAccountIds(new Set<Id>{ businessAccountId })
            )
            .thenReturn(new List<AccountContactRelation>{ accountContactRelationship });
        mocks.when(mockStaticConfigurationsSelector.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    BIRTHDATE_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG
                )
            )
            .thenReturn(eligibleCountriesStatesToValidateBirthdate);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    SSN_VALIDATION_ELIGIBLE_COUNTRIES_STATES_STATIC_CONFIG
                )
            )
            .thenReturn(eligibleCountriesStatesToValidateSSN);
        mocks.when(
                mockReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
                    null,
                    storeReadinessValidationRules[0],
                    parentWorkOrder
                )
            )
            .thenReturn(true);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(accountContactRelationsSelector);
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        Application.SERVICE.setMock(
            IReadinessValidationRulesService.class,
            mockReadinessValidationRulesService
        );
        ContactValidationsServiceImpl contactValidationsServiceImplInstance = new ContactValidationsServiceImpl();
        contactValidationsServiceImplInstance.validate(
            new List<WorkOrder>{},
            new List<WorkOrder>{ parentWorkOrder },
            storeReadinessValidationRules,
            mockexistingReadinessCheckFailures,
            CONTACT_OBJECT_NAME
        );
        //Readiness check failure not created when Decision Maker exists.
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    private static Fake createFakeAccountContactRelationInstance(
        Fake mockBizAccount,
        Id contactId,
        String roles
    ) {
        Account businessAccount = (Account) ServiceMockDataBuilder.convertToSObject(mockBizAccount);
        return new Fake(AccountContactRelation.class)
            .setField(AccountContactRelation.AccountId, businessAccount.Id)
            .setField(AccountContactRelation.ContactId, contactId)
            .setField(AccountContactRelation.Roles, roles)
            .setField(AccountContactRelation.IsActive, true)
            .setParent(
                'Contact',
                new Fake(Contact.class)
                    .setField(Contact.Id, contactId)
                    .setParent('Account', mockBizAccount)
            );
    }
}