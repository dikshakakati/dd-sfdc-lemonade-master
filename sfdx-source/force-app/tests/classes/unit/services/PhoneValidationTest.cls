/**
 * @author Deloitte
 * @date 19/04/2022
 * @description This is test class for PhoneValidation class
 */
@isTest
private class PhoneValidationTest {
    private static final String BYPASS_PHONE_VALIDATION = 'Bypass_Phone_Validation';
    private static final Id BUSNINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Business')
        .getRecordTypeId();
    private static final string INVALID_ASSERT_MESSAGE = 'InValid Phone Number Stamped';
    public static final String NINTEX_INTEGRATION_USER_IDENTIFIER = 'Nintex_Integration_user_identifier';
    private static final string NZ_COUNTRY_CODE = 'NZ';
	private static final string PHONE_NO = '+64123456';
    /**
     * @description To test the format of the phone number when the country code is appended based on the country.
     */
    @isTest
    private static void testWhenPhoneNumberUpdatedThenCountryCodeAppended() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Account newAccount = new Account(
            Id = Fake.generateId(Account.class),
            RecordTypeId = businessRecordTypeId,
            Name = 'Test Account ',
            BillingCountry = 'United States',
            BillingCountryCode = 'US'
        );
        Contact newContact = new Contact(
            Id = Fake.generateId(Contact.class),
            FirstName = 'First Name ',
            LastName = 'Last Name 1',
            Phone = '9897969594',
            AccountId = newAccount.Id
        );
        List<Country_Attributes_Mapping__mdt> testData = new List<Country_Attributes_Mapping__mdt>{
            new Country_Attributes_Mapping__mdt(
                MasterLabel = 'Country test ',
                DeveloperName = 'Country test ',
                Country__c = 'United States',
                Currency_Code__c = 'USD',
                Country_Code__c = 'US',
                Phone_Maximum_Digits__c = 10,
                Phone_Minimum_Digits__c = 10,
                Phone_Country_Code__c = '1'
            )
        };
        Map<String, Country_Attributes_Mapping__mdt> countryToCountryAttributes = new Map<String, Country_Attributes_Mapping__mdt>();
        Map<String, Country_Attributes_Mapping__mdt> phoneCodesToCountryAttributes = new Map<String, Country_Attributes_Mapping__mdt>();
        for (Country_Attributes_Mapping__mdt countryAttribute : testData) {
            countryToCountryAttributes.put(countryAttribute.Country_Code__c, countryAttribute);
            phoneCodesToCountryAttributes.put(
                countryAttribute.Phone_Country_Code__c,
                countryAttribute
            );
        }

        //Act
        PhoneValidation.validationOnPhoneFields(
            newContact,
            Contact.Phone,
            countryToCountryAttributes,
            phoneCodesToCountryAttributes,
            'US'
        );
        //Assert
        System.assertEquals(newContact.phone, '+19897969594', 'Invalid Phone Number stamped');
    }

    /**
     * @description To test the format of the phone number when special characters are removed.
     */
    @isTest
    private static void testWhenPhoneNumberUpdatedThenSpecialCharacterRemoval() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Account newAccount = new Account(
            Id = Fake.generateId(Account.class),
            RecordTypeId = businessRecordTypeId,
            Name = 'Test Account 1',
            BillingCountry = 'Germany',
            BillingCountryCode = 'DE'
        );
        Contact newContact = new Contact(
            Id = Fake.generateId(Contact.class),
            FirstName = 'First Name 1',
            LastName = 'Last Name 1',
            Phone = '989.7969.59,4',
            AccountId = newAccount.Id
        );
        List<Country_Attributes_Mapping__mdt> testData = new List<Country_Attributes_Mapping__mdt>{
            new Country_Attributes_Mapping__mdt(
                MasterLabel = 'Country test ',
                DeveloperName = 'Country test ',
                Country__c = 'Germany',
                Currency_Code__c = 'EUR',
                Country_Code__c = 'DE',
                Phone_Maximum_Digits__c = 11,
                Phone_Minimum_Digits__c = 8,
                Phone_Country_Code__c = '49'
            )
        };
        Map<String, Country_Attributes_Mapping__mdt> countryToCountryAttributes = new Map<String, Country_Attributes_Mapping__mdt>();
        Map<String, Country_Attributes_Mapping__mdt> phoneCodesToCountryAttributes = new Map<String, Country_Attributes_Mapping__mdt>();
        for (Country_Attributes_Mapping__mdt countryAttribute : testData) {
            countryToCountryAttributes.put(countryAttribute.Country_Code__c, countryAttribute);
            phoneCodesToCountryAttributes.put(
                countryAttribute.Phone_Country_Code__c,
                countryAttribute
            );
        }

        //Act
        PhoneValidation.validationOnPhoneFields(
            newContact,
            Contact.Phone,
            countryToCountryAttributes,
            phoneCodesToCountryAttributes,
            'DE'
        );
        //Assert
        System.assertEquals(newContact.phone, '+499897969594', 'Invalid Phone Number stamped');
    }

    /**
     * @description To test the format of the phone number when validation error is thrown the validation error msg.
     */
    @isTest
    private static void testWhenPhoneNumberUpdatedThenSpecialCharacterValidtaionError() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Account newAccount = new Account(
            Id = Fake.generateId(Account.class),
            RecordTypeId = businessRecordTypeId,
            Name = 'Test Account 1',
            BillingCountry = 'United States',
            BillingCountryCode = 'US'
        );
        Contact newContact = new Contact(
            Id = Fake.generateId(Contact.class),
            FirstName = 'First Name 1',
            LastName = 'Last Name 1',
            Phone = '989.7969.59,4??',
            AccountId = newAccount.Id
        );
        List<Country_Attributes_Mapping__mdt> testData = new List<Country_Attributes_Mapping__mdt>{
            new Country_Attributes_Mapping__mdt(
                MasterLabel = 'Country test ',
                DeveloperName = 'Country test ',
                Country__c = 'United States',
                Currency_Code__c = 'USD',
                Country_Code__c = 'US',
                Phone_Maximum_Digits__c = 10,
                Phone_Minimum_Digits__c = 10,
                Phone_Country_Code__c = '1'
            )
        };
        Map<String, Country_Attributes_Mapping__mdt> countryToCountryAttributes = new Map<String, Country_Attributes_Mapping__mdt>();
        Map<String, Country_Attributes_Mapping__mdt> phoneCodesToCountryAttributes = new Map<String, Country_Attributes_Mapping__mdt>();
        for (Country_Attributes_Mapping__mdt countryAttribute : testData) {
            countryToCountryAttributes.put(countryAttribute.Country_Code__c, countryAttribute);
            phoneCodesToCountryAttributes.put(
                countryAttribute.Phone_Country_Code__c,
                countryAttribute
            );
        }

        //Act
        PhoneValidation.validationOnPhoneFields(
            newContact,
            Contact.Phone,
            countryToCountryAttributes,
            phoneCodesToCountryAttributes,
            'US'
        );
        //Assert
        System.assertEquals(
            newContact.getErrors()[0].getMessage(),
            'Please re-enter the phone number without any special characters',
            'Invalid Phone Number stamped'
        );
    }

    /**
     * @description To test the format of the phone number when zeros are removed after country code
     */
    @isTest
    private static void testWhenPhoneNumberUpdatedThenZerosRemoved() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Account newAccount = new Account(
            Id = Fake.generateId(Account.class),
            RecordTypeId = businessRecordTypeId,
            Name = 'Test Account 1',
            BillingCountry = 'United States',
            BillingCountryCode = 'US'
        );
        Contact newContact = new Contact(
            Id = Fake.generateId(Contact.class),
            FirstName = 'First Name 1',
            LastName = 'Last Name 1',
            Phone = '+109999988888',
            AccountId = newAccount.Id
        );

        List<Country_Attributes_Mapping__mdt> testData = new List<Country_Attributes_Mapping__mdt>{
            new Country_Attributes_Mapping__mdt(
                MasterLabel = 'Country test 1',
                DeveloperName = 'Country test 1',
                Country__c = 'United States',
                Currency_Code__c = 'USD',
                Country_Code__c = 'US',
                Phone_Maximum_Digits__c = 10,
                Phone_Minimum_Digits__c = 10,
                Phone_Country_Code__c = '1'
            )
        };
        Map<String, Country_Attributes_Mapping__mdt> countryToCountryAttributes = new Map<String, Country_Attributes_Mapping__mdt>();
        Map<String, Country_Attributes_Mapping__mdt> phoneCodesToCountryAttributes = new Map<String, Country_Attributes_Mapping__mdt>();
        for (Country_Attributes_Mapping__mdt countryAttribute : testData) {
            countryToCountryAttributes.put(countryAttribute.Country_Code__c, countryAttribute);
            phoneCodesToCountryAttributes.put(
                countryAttribute.Phone_Country_Code__c,
                countryAttribute
            );
        }

        //Act
        PhoneValidation.validationOnPhoneFields(
            newContact,
            Contact.Phone,
            countryToCountryAttributes,
            phoneCodesToCountryAttributes,
            'US'
        );
        //Assert
        System.assertEquals(newContact.phone, '+19999988888', 'Invalid Phone Number stamped');
    }

    /**
     * @description To test the format of the phone number when validation is thrown for US.
     */
    @isTest
    private static void testWhenPhoneNumberUpdatedThenValidateBasedOnCountryLimitForUS() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Account newAccount = new Account(
            Id = Fake.generateId(Account.class),
            RecordTypeId = businessRecordTypeId,
            Name = 'Test Account 1',
            BillingCountry = 'United States',
            BillingCountryCode = 'US'
        );
        Contact newContact = new Contact(
            Id = Fake.generateId(Contact.class),
            FirstName = 'First Name 1',
            LastName = 'Last Name 1',
            Phone = '9999988888776',
            AccountId = newAccount.Id
        );
        List<Country_Attributes_Mapping__mdt> testData = new List<Country_Attributes_Mapping__mdt>{
            new Country_Attributes_Mapping__mdt(
                MasterLabel = 'Country test 1',
                DeveloperName = 'Country test 1',
                Country__c = 'United States',
                Currency_Code__c = 'USD',
                Country_Code__c = 'US',
                Phone_Maximum_Digits__c = 10,
                Phone_Minimum_Digits__c = 10,
                Phone_Country_Code__c = '1'
            )
        };
        Map<String, Country_Attributes_Mapping__mdt> countryToCountryAttributes = new Map<String, Country_Attributes_Mapping__mdt>();
        Map<String, Country_Attributes_Mapping__mdt> phoneCodesToCountryAttributes = new Map<String, Country_Attributes_Mapping__mdt>();
        for (Country_Attributes_Mapping__mdt countryAttribute : testData) {
            countryToCountryAttributes.put(countryAttribute.Country_Code__c, countryAttribute);
            phoneCodesToCountryAttributes.put(
                countryAttribute.Phone_Country_Code__c,
                countryAttribute
            );
        }

        //Act
        PhoneValidation.validationOnPhoneFields(
            newContact,
            Contact.Phone,
            countryToCountryAttributes,
            phoneCodesToCountryAttributes,
            'US'
        );
        //Assert
        System.assertEquals(
            newContact.getErrors()[0].getMessage(),
            'US & Canada phone / mobile phone numbers should be max 10 digits with no special characters allowed.',
            'Invalid Phone Number stamped'
        );
    }

    /**
     * @description To test the format of the phone number when validation error is thrown for other countries.
     */
    @isTest
    private static void testWhenPhoneNumberUpdatedThenValidateBasedOnCountryLimitForOtherCountries() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Account newAccount = new Account(
            Id = Fake.generateId(Account.class),
            RecordTypeId = businessRecordTypeId,
            Name = 'Test Account 2',
            BillingCountry = 'Finland',
            BillingCountryCode = 'FI'
        );
        Contact newContact = new Contact(
            Id = Fake.generateId(Contact.class),
            FirstName = 'First Name 1',
            LastName = 'Last Name 1',
            Phone = '123456789123453456',
            AccountId = newAccount.Id
        );
        List<Country_Attributes_Mapping__mdt> testData = new List<Country_Attributes_Mapping__mdt>{
            new Country_Attributes_Mapping__mdt(
                MasterLabel = 'Country test 1',
                DeveloperName = 'Country test 1',
                Country__c = 'Finland',
                Currency_Code__c = 'EUR',
                Country_Code__c = 'FI',
                Phone_Maximum_Digits__c = 15,
                Phone_Country_Code__c = '358'
            )
        };
        Map<String, Country_Attributes_Mapping__mdt> countryToCountryAttributes = new Map<String, Country_Attributes_Mapping__mdt>();
        Map<String, Country_Attributes_Mapping__mdt> phoneCodesToCountryAttributes = new Map<String, Country_Attributes_Mapping__mdt>();
        for (Country_Attributes_Mapping__mdt countryAttribute : testData) {
            countryToCountryAttributes.put(countryAttribute.Country_Code__c, countryAttribute);
            phoneCodesToCountryAttributes.put(
                countryAttribute.Phone_Country_Code__c,
                countryAttribute
            );
        }

        //Act
        PhoneValidation.validationOnPhoneFields(
            newContact,
            Contact.Phone,
            countryToCountryAttributes,
            phoneCodesToCountryAttributes,
            'FI'
        );
        //Assert
        System.assertEquals(
            newContact.getErrors()[0].getMessage(),
            'The maximum number of digits allowed in your country is 15 digits for a phone number, Please re-enter the phone number',
            'Invalid Phone Number stamped'
        );
    }

    /**
     * @description To test the format of the phone number when validation error is thrown for other countries.
     */
    @isTest
    private static void testWhenPhoneNumberUpdatedOfAnAccountRecordThenValidateBasedOnCountryLimitForOtherCountries() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Account newAccount = new Account(
            Id = Fake.generateId(Account.class),
            RecordTypeId = businessRecordTypeId,
            Name = 'Test Account 2',
            BillingCountry = 'Germany',
            BillingCountryCode = 'DE',
            Phone = '123456789123453456'
        );

        List<Country_Attributes_Mapping__mdt> testData = new List<Country_Attributes_Mapping__mdt>{
            new Country_Attributes_Mapping__mdt(
                MasterLabel = 'Country test 1',
                DeveloperName = 'Country test 1',
                Country__c = 'Germany',
                Currency_Code__c = 'EUR',
                Country_Code__c = 'DE',
                Phone_Maximum_Digits__c = 11,
                Phone_Minimum_Digits__c = 8,
                Phone_Country_Code__c = '49'
            )
        };
        Map<String, Country_Attributes_Mapping__mdt> countryToCountryAttributes = new Map<String, Country_Attributes_Mapping__mdt>();
        Map<String, Country_Attributes_Mapping__mdt> phoneCodesToCountryAttributes = new Map<String, Country_Attributes_Mapping__mdt>();
        for (Country_Attributes_Mapping__mdt countryAttribute : testData) {
            countryToCountryAttributes.put(countryAttribute.Country_Code__c, countryAttribute);
            phoneCodesToCountryAttributes.put(
                countryAttribute.Phone_Country_Code__c,
                countryAttribute
            );
        }

        //Act
        PhoneValidation.validationOnPhoneFields(
            newAccount,
            Account.Phone,
            countryToCountryAttributes,
            phoneCodesToCountryAttributes,
            ''
        );

        //Assert
        System.assertEquals(
            newAccount.getErrors()[0].getMessage(),
            'Germany phone / mobile phone numbers should be min 8 & max 11 digits of the number itself. No special characters allowed.',
            'Invalid Phone Number stamped'
        );
    }

    /**
     * @description To test the format of the phone number when +7 country code.
     */
    @isTest
    private static void testWhenPhoneNumberUpdatedOfAnAccountRecordThenValidateBasedOnCountryCode() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Account newAccount = new Account(
            Id = Fake.generateId(Account.class),
            RecordTypeId = businessRecordTypeId,
            Name = 'Test Account 2',
            BillingCountry = 'Germany',
            BillingCountryCode = 'DE',
            Phone = '+7123456789'
        );

        List<Country_Attributes_Mapping__mdt> testData = new List<Country_Attributes_Mapping__mdt>{
            new Country_Attributes_Mapping__mdt(
                MasterLabel = 'Country test 1',
                DeveloperName = 'Country test 1',
                Country__c = 'Kazakhstan ',
                Currency_Code__c = 'EUR',
                Country_Code__c = 'KZ',
                Phone_Maximum_Digits__c = 11,
                Phone_Minimum_Digits__c = 8,
                Phone_Country_Code__c = '7'
            )
        };
        Map<String, Country_Attributes_Mapping__mdt> countryToCountryAttributes = new Map<String, Country_Attributes_Mapping__mdt>();
        Map<String, Country_Attributes_Mapping__mdt> phoneCodesToCountryAttributes = new Map<String, Country_Attributes_Mapping__mdt>();
        for (Country_Attributes_Mapping__mdt countryAttribute : testData) {
            countryToCountryAttributes.put(countryAttribute.Country_Code__c, countryAttribute);
            phoneCodesToCountryAttributes.put(
                countryAttribute.Phone_Country_Code__c,
                countryAttribute
            );
        }

        //Act
        PhoneValidation.validationOnPhoneFields(
            newAccount,
            Account.Phone,
            countryToCountryAttributes,
            phoneCodesToCountryAttributes,
            ''
        );

        //Assert
        System.assertEquals(newAccount.Phone, '+7123456789', 'Invalid Phone Number stamped');
    }

    /**
     * @description To test the format of the phone number when validation error is thrown for other countries.
     * The country code is not acceptable for the country on this account
     */
    @isTest
    private static void testWhenPhoneNumberUpdatedThenValidatingCountryCode() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Account newAccount = new Account(
            Id = Fake.generateId(Account.class),
            RecordTypeId = businessRecordTypeId,
            Name = 'Test Account 2',
            BillingCountry = 'Finland',
            BillingCountryCode = 'FI'
        );
        Contact newContact = new Contact(
            Id = Fake.generateId(Contact.class),
            FirstName = 'First Name 1',
            LastName = 'Last Name 1',
            Phone = '+23456789',
            AccountId = newAccount.Id
        );
        List<Country_Attributes_Mapping__mdt> testData = new List<Country_Attributes_Mapping__mdt>{
            new Country_Attributes_Mapping__mdt(
                MasterLabel = 'Country test 1',
                DeveloperName = 'Country test 1',
                Country__c = 'Finland',
                Currency_Code__c = 'EUR',
                Country_Code__c = 'FI',
                Phone_Maximum_Digits__c = 15,
                Phone_Country_Code__c = '358'
            )
        };
        Map<String, Country_Attributes_Mapping__mdt> countryToCountryAttributes = new Map<String, Country_Attributes_Mapping__mdt>();
        Map<String, Country_Attributes_Mapping__mdt> phoneCodesToCountryAttributes = new Map<String, Country_Attributes_Mapping__mdt>();
        for (Country_Attributes_Mapping__mdt countryAttribute : testData) {
            countryToCountryAttributes.put(countryAttribute.Country_Code__c, countryAttribute);
            phoneCodesToCountryAttributes.put(
                countryAttribute.Phone_Country_Code__c,
                countryAttribute
            );
        }

        //Act
        PhoneValidation.validationOnPhoneFields(
            newContact,
            Contact.Phone,
            countryToCountryAttributes,
            phoneCodesToCountryAttributes,
            'FI'
        );
        //Assert
        System.assertEquals(
            newContact.getErrors()[0].getMessage(),
            'The country code is not acceptable for the country on this contact. Please verify and enter appropriate country code.',
            'Invalid Phone Number stamped'
        );
    }

    /**
     * @description To test the format of the phone number when zeros are removed after country code
     */
    @isTest
    private static void testWhenPhoneNumberUpdatedWithTwoDigitCountryCodeThenZerosRemoved() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Account newAccount = new Account(
            Id = Fake.generateId(Account.class),
            RecordTypeId = businessRecordTypeId,
            Name = 'Test Account 1',
            BillingCountry = 'Germany',
            BillingCountryCode = 'DE'
        );
        Contact newContact = new Contact(
            Id = Fake.generateId(Contact.class),
            FirstName = 'First Name 1',
            LastName = 'Last Name 1',
            Phone = '+490999998888',
            AccountId = newAccount.Id
        );

        List<Country_Attributes_Mapping__mdt> testData = new List<Country_Attributes_Mapping__mdt>{
            new Country_Attributes_Mapping__mdt(
                MasterLabel = 'Country test 1',
                DeveloperName = 'Country test 1',
                Country__c = 'United States',
                Currency_Code__c = 'EUR',
                Country_Code__c = 'DE',
                Phone_Maximum_Digits__c = 9,
                Phone_Minimum_Digits__c = 11,
                Phone_Country_Code__c = '49'
            )
        };
        Map<String, Country_Attributes_Mapping__mdt> countryToCountryAttributes = new Map<String, Country_Attributes_Mapping__mdt>();
        Map<String, Country_Attributes_Mapping__mdt> phoneCodesToCountryAttributes = new Map<String, Country_Attributes_Mapping__mdt>();
        for (Country_Attributes_Mapping__mdt countryAttribute : testData) {
            countryToCountryAttributes.put(countryAttribute.Country_Code__c, countryAttribute);
            phoneCodesToCountryAttributes.put(
                countryAttribute.Phone_Country_Code__c,
                countryAttribute
            );
        }

        //Act
        PhoneValidation.validationOnPhoneFields(
            newContact,
            Contact.Phone,
            countryToCountryAttributes,
            phoneCodesToCountryAttributes,
            'DE'
        );
        //Assert
        System.assertEquals(newContact.phone, '+49999998888', 'Invalid Phone Number stamped');
    }

    /**
     * @description To test the format of the phone number when zeros are removed after country code
     */
    @isTest
    private static void testWhenPhoneNumberUpdatedWithThreeDigitCountryCodeThenZerosRemoved() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Account newAccount = new Account(
            Id = Fake.generateId(Account.class),
            RecordTypeId = businessRecordTypeId,
            Name = 'Test Account 1',
            BillingCountry = 'United States',
            BillingCountryCode = 'US'
        );
        Contact newContact = new Contact(
            Id = Fake.generateId(Contact.class),
            FirstName = 'First Name 1',
            LastName = 'Last Name 1',
            Phone = '+35800999998888',
            AccountId = newAccount.Id
        );

        List<Country_Attributes_Mapping__mdt> testData = new List<Country_Attributes_Mapping__mdt>{
            new Country_Attributes_Mapping__mdt(
                MasterLabel = 'Country test 1',
                DeveloperName = 'Country test 1',
                Country__c = 'Finland',
                Currency_Code__c = 'EUR',
                Country_Code__c = 'FI',
                Phone_Country_Code__c = '358'
            )
        };
        Map<String, Country_Attributes_Mapping__mdt> countryToCountryAttributes = new Map<String, Country_Attributes_Mapping__mdt>();
        Map<String, Country_Attributes_Mapping__mdt> phoneCodesToCountryAttributes = new Map<String, Country_Attributes_Mapping__mdt>();
        for (Country_Attributes_Mapping__mdt countryAttribute : testData) {
            countryToCountryAttributes.put(countryAttribute.Country_Code__c, countryAttribute);
            phoneCodesToCountryAttributes.put(
                countryAttribute.Phone_Country_Code__c,
                countryAttribute
            );
        }

        //Act
        PhoneValidation.validationOnPhoneFields(
            newContact,
            Contact.Phone,
            countryToCountryAttributes,
            phoneCodesToCountryAttributes,
            'FI'
        );
        //Assert
        System.assertEquals(newContact.phone, '+358999998888', 'Invalid Phone Number stamped');
    }

    /**
     * @description To test the format of the phone number when the country is Australia and the user is nintex integration user.
     */
    @isTest
    private static void testWhenPhoneNumberUpdatedWithNintexUserAndCountryIsAustraliaThenBypassValidation() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Account newAccount = new Account(
            Id = Fake.generateId(Account.class),
            RecordTypeId = businessRecordTypeId,
            Name = 'Test Account ',
            BillingCountry = 'Australia',
            BillingCountryCode = 'AU'
        );
        Contact newContact = new Contact(
            Id = Fake.generateId(Contact.class),
            FirstName = 'First Name ',
            LastName = 'Last Name 1',
            Phone = '123456',
            AccountId = newAccount.Id
        );
        List<Country_Attributes_Mapping__mdt> testData = new List<Country_Attributes_Mapping__mdt>{
            new Country_Attributes_Mapping__mdt(
                MasterLabel = 'Country test ',
                DeveloperName = 'Country test ',
                Country__c = 'Australia',
                Currency_Code__c = 'AUD',
                Country_Code__c = 'AU',
                Phone_Maximum_Digits__c = 11,
                Phone_Minimum_Digits__c = 8,
                Phone_Country_Code__c = '61'
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IFeatureManagementService featureManagementServiceMock = (IFeatureManagementService) mocks.mock(
            IFeatureManagementService.class
        );
        mocks.startStubbing();
        mocks.when(featureManagementServiceMock.checkPermission(NINTEX_INTEGRATION_USER_IDENTIFIER))
            .thenReturn(true);
        mocks.when(featureManagementServiceMock.checkPermission(BYPASS_PHONE_VALIDATION))
            .thenReturn(false);
        Application.SERVICE.setMock(IFeatureManagementService.class, featureManagementServiceMock);
        mocks.stopStubbing();
        Map<String, Country_Attributes_Mapping__mdt> countryToCountryAttributes = new Map<String, Country_Attributes_Mapping__mdt>();
        Map<String, Country_Attributes_Mapping__mdt> phoneCodesToCountryAttributes = new Map<String, Country_Attributes_Mapping__mdt>();
        for (Country_Attributes_Mapping__mdt countryAttribute : testData) {
            countryToCountryAttributes.put(countryAttribute.Country_Code__c, countryAttribute);
            phoneCodesToCountryAttributes.put(
                countryAttribute.Phone_Country_Code__c,
                countryAttribute
            );
        }

        //Act
        PhoneValidation.validationOnPhoneFields(
            newContact,
            Contact.Phone,
            countryToCountryAttributes,
            phoneCodesToCountryAttributes,
            'AU'
        );
        //Assert
        System.assertEquals(newContact.phone, '+61123456', 'InValid Phone Number Stamped');
    }

    /**
     * @description To test the format of the phone number when the country is Australia.
     */
    @isTest
    private static void testWhenPhoneNumberUpdatedWithoutNintexUserAndCountryIsAustraliaThenDoNotBypassValidation() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Account newAccount = new Account(
            Id = Fake.generateId(Account.class),
            RecordTypeId = businessRecordTypeId,
            Name = 'Test Account 2',
            BillingCountry = 'Australia',
            BillingCountryCode = 'AU',
            Phone = '123456'
        );

        List<Country_Attributes_Mapping__mdt> testData = new List<Country_Attributes_Mapping__mdt>{
            new Country_Attributes_Mapping__mdt(
                MasterLabel = 'Country test 1',
                DeveloperName = 'Country test 1',
                Country__c = 'Australia',
                Currency_Code__c = 'AUD',
                Country_Code__c = 'AU',
                Phone_Maximum_Digits__c = 11,
                Phone_Minimum_Digits__c = 8,
                Phone_Country_Code__c = '49'
            )
        };
        Map<String, Country_Attributes_Mapping__mdt> countryToCountryAttributes = new Map<String, Country_Attributes_Mapping__mdt>();
        Map<String, Country_Attributes_Mapping__mdt> phoneCodesToCountryAttributes = new Map<String, Country_Attributes_Mapping__mdt>();
        for (Country_Attributes_Mapping__mdt countryAttribute : testData) {
            countryToCountryAttributes.put(countryAttribute.Country_Code__c, countryAttribute);
            phoneCodesToCountryAttributes.put(
                countryAttribute.Phone_Country_Code__c,
                countryAttribute
            );
        }

        //Act
        PhoneValidation.validationOnPhoneFields(
            newAccount,
            Account.Phone,
            countryToCountryAttributes,
            phoneCodesToCountryAttributes,
            'AU'
        );

        //Assert
        System.assertEquals(
            newAccount.getErrors()[0].getMessage(),
            'Australia phone / mobile phone numbers should be min 8 & max 11 digits of the number itself. No special characters allowed.',
            'Invalid Phone Number stamped'
        );
    }

    /**
     * @description To test the format of the phone number when the country is New Zealand
     * and the user is nintex integration user.
     */
    @isTest
    private static void testWhenPhoneNumberUpdatedWithNintexUserAndCountryIsNewZealandThenBypassValidation() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Account newAccount = new Account(
            Id = Fake.generateId(Account.class),
            RecordTypeId = businessRecordTypeId,
            Name = 'Test Account ',
            BillingCountry = 'New Zealand',
            BillingCountryCode = 'NZ'
        );
        Contact newContact = new Contact(
            Id = Fake.generateId(Contact.class),
            FirstName = 'First Name ',
            LastName = 'Last Name 1',
            Phone = '123456',
            AccountId = newAccount.Id
        );
        List<Country_Attributes_Mapping__mdt> testData = new List<Country_Attributes_Mapping__mdt>{
            new Country_Attributes_Mapping__mdt(
                MasterLabel = 'Country test ',
                DeveloperName = 'Country test ',
                Country__c = 'New Zealand',
                Currency_Code__c = 'NZD',
                Country_Code__c = 'NZ',
                Phone_Maximum_Digits__c = 10,
                Phone_Minimum_Digits__c = 8,
                Phone_Country_Code__c = '64'
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IFeatureManagementService featureManagementServiceMock = (IFeatureManagementService) mocks.mock(
            IFeatureManagementService.class
        );
        mocks.startStubbing();
        mocks.when(featureManagementServiceMock.checkPermission(NINTEX_INTEGRATION_USER_IDENTIFIER))
            .thenReturn(true);
        mocks.when(featureManagementServiceMock.checkPermission(BYPASS_PHONE_VALIDATION))
            .thenReturn(false);
        Application.SERVICE.setMock(IFeatureManagementService.class, featureManagementServiceMock);
        mocks.stopStubbing();
        Map<String, Country_Attributes_Mapping__mdt> countryToCountryAttributes = new Map<String, Country_Attributes_Mapping__mdt>();
        Map<String, Country_Attributes_Mapping__mdt> phoneCodesToCountryAttributes = new Map<String, Country_Attributes_Mapping__mdt>();
        for (Country_Attributes_Mapping__mdt countryAttribute : testData) {
            countryToCountryAttributes.put(countryAttribute.Country_Code__c, countryAttribute);
            phoneCodesToCountryAttributes.put(
                countryAttribute.Phone_Country_Code__c,
                countryAttribute
            );
        }

        //Act
        PhoneValidation.validationOnPhoneFields(
            newContact,
            Contact.Phone,
            countryToCountryAttributes,
            phoneCodesToCountryAttributes,
            'NZ'
        );
        //AssertEquals
        System.assertEquals(newContact.phone, '+64123456', 'InValid Phone Number Stamped');
    }
     /**
     * @description To test the format of the phone number when the country is New Zealand
     * and the user is process automation user.
     */
    @isTest
    private static void testWhenPhoneNumberUpdatedWithProcessAutomationUserAndCountryIsNewZealandThenBypassValidation() {
        Account newAccount = new Account(
            Id = Fake.generateId(Account.class),
            RecordTypeId = BUSNINESS_RECORD_TYPE_ID,
            Name = 'Test Account ',
            BillingCountry = 'New Zealand',
            BillingCountryCode = 'NZ'
        );
        Contact newContact = new Contact(
            Id = Fake.generateId(Contact.class),
            FirstName = 'First Name ',
            LastName = 'Last Name 1',
            Phone = '123456',
            AccountId = newAccount.Id
        );
        List<Country_Attributes_Mapping__mdt> testData = new List<Country_Attributes_Mapping__mdt>{
            new Country_Attributes_Mapping__mdt(
                MasterLabel = 'Country test ',
                DeveloperName = 'Country test ',
                Country__c = 'New Zealand',
                Currency_Code__c = 'NZD',
                Country_Code__c = 'NZ',
                Phone_Maximum_Digits__c = 10,
                Phone_Minimum_Digits__c = 8,
                Phone_Country_Code__c = '64'
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IFeatureManagementService featureManagementServiceMock = (IFeatureManagementService) mocks.mock(
            IFeatureManagementService.class
        );
        mocks.startStubbing();
        mocks.when(featureManagementServiceMock.checkPermission(BYPASS_PHONE_VALIDATION))
            .thenReturn(true);
        Application.SERVICE.setMock(IFeatureManagementService.class, featureManagementServiceMock);
        mocks.stopStubbing();
        Map<String, Country_Attributes_Mapping__mdt> countryToCountryAttributes = new Map<String, Country_Attributes_Mapping__mdt>();
        Map<String, Country_Attributes_Mapping__mdt> phoneCodesToCountryAttributes = new Map<String, Country_Attributes_Mapping__mdt>();
        for (Country_Attributes_Mapping__mdt countryAttribute : testData) {
            countryToCountryAttributes.put(countryAttribute.Country_Code__c, countryAttribute);
            phoneCodesToCountryAttributes.put(
                countryAttribute.Phone_Country_Code__c,
                countryAttribute
            );
        }
        Test.startTest();
        PhoneValidation.validationOnPhoneFields(
            newContact,
            Contact.Phone,
            countryToCountryAttributes,
            phoneCodesToCountryAttributes,
            NZ_COUNTRY_CODE
        );
        Test.stopTest();
        //AssertEquals
        System.assertEquals(newContact.phone, PHONE_NO,INVALID_ASSERT_MESSAGE );
    }
}