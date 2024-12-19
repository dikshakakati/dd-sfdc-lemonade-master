/**
 * @author DoorDash
 * @date 02/09/2024
 * @description Test class for XrefAndBizRefMatchingServiceImpl
 */
@isTest(seeAllData=false)
public with sharing class XrefAndBizRefMatchingServiceImplTest {
    private static final String ASSERT_MESSAGE_BUSINESS_REFERENCE_MISMATCH = 'Unexpected Result: Business Reference is not matched.';
    private static final String DEFAULT_TYPE_CORPORATE = 'Corporate';
    private static final String CURRENCY_CODE_USD = 'USD';
    private static final String BUSINESS_NAME = 'Taco Bell';
    private static final String BRAND_NAME = 'US Taco Bell';
    private static final String BRAND_NAME_CANDA = 'CA Taco Bell';
    private static final String EXTERNAL_ID_SOURCE_MARKET_PLACE = 'Marketplace';
    private static final String EXPEREINCE_DOORDASH = 'DoorDash';
    private static final String BVID_NAME_RX = 'Rx';
    private static final String ACCOUNT_PRIMARY_VERTICAL_RESTAURENT = 'Rx';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ADDRESS_VERIFICATION_STATUS = 'Verified';
    private static final String IN_COVERAGE = 'In Coverage';
    private static final String ACCOUNT_DATA_VERIFICATION_STATUS = 'Verified';

    /**
     * @description Test formation businessreference matching is correct.
     */
    @isTest
    public static void testWhenBusinessNameIsSmallLetterThenReturnCapitalLettersInTheKey() {
        Id businessVerticalId = fflib_IDGenerator.generate(Business_Vertical__c.SObjectType);

        Fake businessVerticalRxFakeInstance = new Fake(Business_Vertical__c.class)
            .setField(Business_Vertical__c.Name, BVID_NAME_RX)
            .setField(Business_Vertical__c.Id, businessVerticalId);

        Id brandId = fflib_IDGenerator.generate(Brand__c.SObjectType);
        Fake brandFakeInstance = new Fake(Brand__c.class)
            .setField(Brand__c.Price_Range__c, null)
            .setField(Brand__c.Name, BRAND_NAME)
            .setField(Brand__c.Id, brandId);
        Brand__c brandInstance = (Brand__c) ServiceMockDataBuilder.convertToSObject(
            brandFakeInstance
        );

        Business_Reference__c businessRef1 = (Business_Reference__c) new Fake(
                Business_Reference__c.class
            )
            .setField(Business_Reference__c.CurrencyIsoCode, CURRENCY_CODE_USD)
            .setField(Business_Reference__c.External_Id_Source__c, EXTERNAL_ID_SOURCE_MARKET_PLACE)
            .setField(Business_Reference__c.Default_Type__c, DEFAULT_TYPE_CORPORATE)
            .setField(Business_Reference__c.Business_Name__c, BUSINESS_NAME)
            .setField(Business_Reference__c.Business_Vertical__c, businessVerticalId)
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance)
            .setField(Business_Reference__c.Brand__c, brandInstance.Id)
            .setField(Business_Reference__c.Brand__c, brandId)
            .setParent('Brand__r', brandFakeInstance)
            .setFakeId()
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IBusinessReferencesSelector businessRefSelectorMock = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );

        mocks.startStubbing();
        mocks.when(businessRefSelectorMock.sObjectType())
            .thenReturn(Business_Reference__c.SObjectType);
        mocks.when(
                businessRefSelectorMock.selectByBusinessVerticals(
                    new Set<String>{ businessVerticalId }
                )
            )
            .thenReturn(new List<Business_Reference__c>{ businessRef1 });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(businessRefSelectorMock);
        Map<String, Business_Reference__c> businessRefMap = XrefAndBizRefMatchingService.getBusinessReferencesByMatchingKey(
            new Set<String>{ businessVerticalId }
        );
        String expectedKey =
            CURRENCY_CODE_USD +
            businessVerticalId +
            EXTERNAL_ID_SOURCE_MARKET_PLACE +
            DEFAULT_TYPE_CORPORATE +
            BRAND_NAME.toUpperCase();
        System.assert(
            businessRefMap.containsKey(expectedKey),
            'Business reference return Map key is not set as expected' +
                expectedKey +
                '-->businessRefMap' +
                businessRefMap
        );
    }
    /**
     * @description test bizref matching logic is working as expected.
     */
    @isTest
    static void testWhenCollectionOfAccountReceivedThenReturnResponseIfBizrefFound() {
        Id storeId = fflib_IDGenerator.generate(Account.SObjectType);
        Id businessVerticalId = fflib_IDGenerator.generate(Business_Vertical__c.SObjectType);

        Fake businessVerticalRxFakeInstance = new Fake(Business_Vertical__c.class)
            .setField(Business_Vertical__c.Name, BVID_NAME_RX)
            .setField(Business_Vertical__c.Id, businessVerticalId);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_RESTAURENT,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        parentBusinessAccountFakeInstance.setField(Account.Business_Vertical__c, businessVerticalId)
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance);
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Id brandId = fflib_IDGenerator.generate(Brand__c.SObjectType);
        Fake brandFakeInstance = new Fake(Brand__c.class)
            .setField(Brand__c.Brand_Owner__c, parentBusinessAccount.Id)
            .setField(Brand__c.Price_Range__c, null)
            .setField(Brand__c.Name, BRAND_NAME)
            .setField(Brand__c.Id, brandId);
        Brand__c brandInstance = (Brand__c) ServiceMockDataBuilder.convertToSObject(
            brandFakeInstance
        );
        Business_Reference__c businessRef1 = (Business_Reference__c) new Fake(
                Business_Reference__c.class
            )
            .setField(Business_Reference__c.Business_Vertical__c, businessVerticalId)
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance)
            .setField(Business_Reference__c.Brand__c, brandInstance.Id)
            .setField(Business_Reference__c.Brand__c, brandId)
            .setField(Business_Reference__c.Default_Type__c, DEFAULT_TYPE_CORPORATE)
            .setParent('Brand__r', brandFakeInstance)
            .setFakeId()
            .toSObject();
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_RESTAURENT
            )
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(Account.Data_Verification_Status__c, ACCOUNT_DATA_VERIFICATION_STATUS)
            .setField(Account.Id, storeId)
            .setField(Account.Experience__c, EXPEREINCE_DOORDASH)
            .setField(Account.currencyIsoCode, CURRENCY_CODE_USD)
            .setField(Account.Proposed_Date_of_Activation__c, System.today())
            .setField(Account.Business_Vertical__c, businessVerticalId)
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance)
            .setParent('Brand__r', brandFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );
        IBusinessReferencesSelector businessRefSelectorMock = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );

        mocks.startStubbing();
        mocks.when(businessRefSelectorMock.sObjectType())
            .thenReturn(Business_Reference__c.SObjectType);
        mocks.when(
                businessRefSelectorMock.selectByBusinessVerticalsBrandNamesAndCurrencyISOCodes(
                    new Set<String>{ businessVerticalId },
                    new Set<String>{ BRAND_NAME },
                    new Set<String>{ CURRENCY_CODE_USD }
                )
            )
            .thenReturn(new List<Business_Reference__c>{ businessRef1 });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(businessRefSelectorMock);
        Application.UNITOFWORK.setMock(uowMock);

        Map<Id, String> accountIdToErrorMessage = XrefAndBizRefMatchingService.findMatchingBizRefForReadinesCheck(
            new List<Account>{ storeAccount }
        );
        System.assert(
            accountIdToErrorMessage.containsKey(storeAccount.Id),
            'Business reference matching not working as expected. Expected to find the Bizref but Bizref not found'
        );
    }

    /**
     * @description test when matching biz ref not found then throw an error.
     */
    @isTest
    static void testWhenCollectionOfAccountReceivedThenReturnErrorIfMatchingBizRefNotFound() {
        Id storeId = fflib_IDGenerator.generate(Account.SObjectType);
        Id businessVerticalId = fflib_IDGenerator.generate(Business_Vertical__c.SObjectType);

        Fake businessVerticalRxFakeInstance = new Fake(Business_Vertical__c.class)
            .setField(Business_Vertical__c.Name, BVID_NAME_RX)
            .setField(Business_Vertical__c.Id, businessVerticalId);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_RESTAURENT,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        parentBusinessAccountFakeInstance.setField(Account.Business_Vertical__c, businessVerticalId)
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance);
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Id brandId = fflib_IDGenerator.generate(Brand__c.SObjectType);
        Fake brandFakeInstance = new Fake(Brand__c.class)
            .setField(Brand__c.Brand_Owner__c, parentBusinessAccount.Id)
            .setField(Brand__c.Price_Range__c, null)
            .setField(Brand__c.Name, BRAND_NAME)
            .setField(Brand__c.Id, brandId);

        Id brandIdCanada = fflib_IDGenerator.generate(Brand__c.SObjectType);
        Fake brandFakeInstanceCanada = new Fake(Brand__c.class)
            .setField(Brand__c.Brand_Owner__c, parentBusinessAccount.Id)
            .setField(Brand__c.Price_Range__c, null)
            .setField(Brand__c.Name, BRAND_NAME_CANDA)
            .setField(Brand__c.Id, brandId);
        Brand__c brandInstanceCanada = (Brand__c) ServiceMockDataBuilder.convertToSObject(
            brandFakeInstanceCanada
        );

        Business_Reference__c businessRef1 = (Business_Reference__c) new Fake(
                Business_Reference__c.class
            )
            .setField(Business_Reference__c.Business_Vertical__c, businessVerticalId)
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance)
            .setField(Business_Reference__c.Brand__c, brandInstanceCanada.Id)
            .setField(Business_Reference__c.Brand__c, brandIdCanada)
            .setField(Business_Reference__c.Default_Type__c, DEFAULT_TYPE_CORPORATE)
            .setParent('Brand__r', brandFakeInstanceCanada)
            .setFakeId()
            .toSObject();
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_RESTAURENT
            )
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(Account.Data_Verification_Status__c, ACCOUNT_DATA_VERIFICATION_STATUS)
            .setField(Account.Id, storeId)
            .setField(Account.Experience__c, EXPEREINCE_DOORDASH)
            .setField(Account.currencyIsoCode, CURRENCY_CODE_USD)
            .setField(Account.Proposed_Date_of_Activation__c, System.today())
            .setField(Account.Business_Vertical__c, businessVerticalId)
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance)
            .setParent('Brand__r', brandFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_SObjectUnitOfWork uowMock = (fflib_SObjectUnitOfWork) mocks.mock(
            fflib_SObjectUnitOfWork.class
        );
        IBusinessReferencesSelector businessRefSelectorMock = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );

        mocks.startStubbing();
        mocks.when(businessRefSelectorMock.sObjectType())
            .thenReturn(Business_Reference__c.SObjectType);
        mocks.when(
                businessRefSelectorMock.selectByBusinessVerticalsBrandNamesAndCurrencyISOCodes(
                    new Set<String>{ businessVerticalId },
                    new Set<String>{ BRAND_NAME },
                    new Set<String>{ CURRENCY_CODE_USD }
                )
            )
            .thenReturn(new List<Business_Reference__c>{ businessRef1 });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(businessRefSelectorMock);
        Application.UNITOFWORK.setMock(uowMock);

        Map<Id, String> accountIdToErrorMessage = XrefAndBizRefMatchingService.findMatchingBizRefForReadinesCheck(
            new List<Account>{ storeAccount }
        );
        XrefAndBizRefMatchingService.getBizRefMatchingErrorDisplayMessage(
            storeAccount,
            EXPEREINCE_DOORDASH
        );
        String errorMessage = accountIdToErrorMessage.containsKey(storeAccount.Id)
            ? accountIdToErrorMessage.get(storeAccount.Id)
            : 'Matching logic not working as expected';
        System.assert(
            errorMessage.contains('A Business Reference with the following criteria'),
            'Expected not to find the bizref but bizref found. Bizref matching not working as expected'
        );
    }

    /**
     * @description To test maching Business Reference is returned based on the passed
     * Store Account details.
     */
    @isTest
    public static void testWhenStoreAccountsReceivedThenReturnMatchingBusinessReference() {
        Id businessVerticalId = fflib_IDGenerator.generate(Business_Vertical__c.SObjectType);
        Fake businessVerticalRxFakeInstance = new Fake(Business_Vertical__c.class)
            .setField(Business_Vertical__c.Name, BVID_NAME_RX)
            .setField(Business_Vertical__c.Id, businessVerticalId);
        Id brandId = fflib_IDGenerator.generate(Brand__c.SObjectType);
        Fake brandFakeInstance = new Fake(Brand__c.class)
            .setField(Brand__c.Price_Range__c, null)
            .setField(Brand__c.Name, BRAND_NAME)
            .setField(Brand__c.Id, brandId);
        Brand__c brandInstance = (Brand__c) ServiceMockDataBuilder.convertToSObject(
            brandFakeInstance
        );
        Business_Reference__c businessRef1 = (Business_Reference__c) new Fake(
                Business_Reference__c.class
            )
            .setField(Business_Reference__c.CurrencyIsoCode, CURRENCY_CODE_USD)
            .setField(Business_Reference__c.External_Id_Source__c, EXTERNAL_ID_SOURCE_MARKET_PLACE)
            .setField(Business_Reference__c.Default_Type__c, DEFAULT_TYPE_CORPORATE)
            .setField(Business_Reference__c.Business_Name__c, BUSINESS_NAME)
            .setField(Business_Reference__c.Business_Vertical__c, businessVerticalId)
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance)
            .setField(Business_Reference__c.Brand__c, brandInstance.Id)
            .setField(Business_Reference__c.Brand__c, brandId)
            .setParent('Brand__r', brandFakeInstance)
            .setFakeId()
            .toSObject();

        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL_RESTAURENT,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        parentBusinessAccountFakeInstance.setField(Account.Business_Vertical__c, businessVerticalId)
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance);
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Id storeId = fflib_IDGenerator.generate(Account.SObjectType);
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_RESTAURENT
            )
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(Account.Data_Verification_Status__c, ACCOUNT_DATA_VERIFICATION_STATUS)
            .setField(Account.Id, storeId)
            .setField(Account.Experience__c, EXPEREINCE_DOORDASH)
            .setField(Account.currencyIsoCode, CURRENCY_CODE_USD)
            .setField(Account.Proposed_Date_of_Activation__c, System.today())
            .setField(Account.Business_Vertical__c, businessVerticalId)
            .setParent('Business_Vertical__r', businessVerticalRxFakeInstance)
            .setParent('Brand__r', brandFakeInstance);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBusinessReferencesSelector businessRefSelectorMock = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        mocks.startStubbing();
        mocks.when(businessRefSelectorMock.sObjectType())
            .thenReturn(Business_Reference__c.SObjectType);
        mocks.when(
                businessRefSelectorMock.selectByBusinessVerticalsBrandNamesAndCurrencyISOCodes(
                    new Set<String>{ businessVerticalId },
                    new Set<String>{ BRAND_NAME },
                    new Set<String>{ CURRENCY_CODE_USD }
                )
            )
            .thenReturn(new List<Business_Reference__c>{ businessRef1 });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(businessRefSelectorMock);
        Map<String, Business_Reference__c> businessRefMap = XrefAndBizRefMatchingService.getBusinessReferencesByMatchingKey(
            new List<Account>{ storeAccount }
        );
        String expectedKey =
            CURRENCY_CODE_USD +
            businessVerticalId +
            EXTERNAL_ID_SOURCE_MARKET_PLACE +
            DEFAULT_TYPE_CORPORATE +
            BRAND_NAME.toUpperCase();
        System.assertEquals(
            businessRef1.Id,
            businessRefMap.get(expectedKey).Id,
            ASSERT_MESSAGE_BUSINESS_REFERENCE_MISMATCH
        );
    }
}