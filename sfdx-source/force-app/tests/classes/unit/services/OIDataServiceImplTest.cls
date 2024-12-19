/**
 * @author Deloitte
 * @date 06/11/2024
 * @description Test class for OIDataServiceImpl class.
 */
@isTest(seeAllData=false)
@SuppressWarnings('PMD.MethodNamingConventions')
private class OIDataServiceImplTest {
    private static final String ACTIVATED_CENTRALLY_API_NAME = 'Activated_Centrally_AC__c';
    private static final String ADDRESS_CITY = 'Trenton';
    private static final String ADDRESS_STREET = '10 Hamilton Ave';
    private static final String ADDRESS_POSTAL_CODE = '08611';
    private static final String ASSERT_MESSAGE_MX_ONBOARDING_LINK = 'Unexpected result: Mx Onboarding Link record is not matching';
    private static final String BRAND_NAME_TEST_BRAND = 'TEST BRAND';
    private static final String BUSINESS_NAME_TEST = 'Test';
    private static final String OPPORTUNITY_STAGE_CONTRACTING = 'Contracting';
    private static final String STATUS_ACTIVATED = 'Activated';
    private static final Date CONTACT_DATE_OF_BIRTH = Date.newInstance(2000, 12, 9);
    private static final String CONTACT_EMAIL = 'tigerwoods@test.com';
    private static final String CONTACT_FIRST_NAME = 'Tiger';
    private static final String CONTACT_LAST_NAME = 'Woods';
    private static final String CONTACT_PHONE = '999-999-9999';
    private static final String COUNTRY_CODE_US = 'US';
    private static final String EMPTY_STRING = '';
    private static final String FORM_LANGUAGE_FRENCH = 'fr';
    private static final String FORM_TYPE_MX_FORM = 'Mx FORM';
    private static final String QUERY_VALUE = '15';
    private static final String QUERY_ROW_VALUE = '2000';
    private static final String QUERIES_ALLOWED_LIMIT_STATIC_CONFIG = 'Queries_Allowed_Limit';
    private static final String QUERY_ROWS_ALLOWED_LIMIT_STATIC_CONFIG = 'Query_Rows_Allowed_Limit';
    private static final String VIRTUAL_ACCOUNT_TYPE = 'Virtual';
    private static final String CUSTOM_METADATA_DEVELOPER_NAME = 'Marketplace_Marketplace';
    private static final String CUSTOM_METADATA_MASTER_LABEL = 'Marketplace Marketplace';
    private static final String DELAY_TABLET_SHIPMENT_API_NAME = 'Delay_Tablet_Shipment__c';
    private static final String EVENT_TOPIC_OI_DATA_CREATION = 'OI_DATA_PROCESSING';
    private static final Schema.Fieldset FIELDS_TO_QUERY = SObjectType.Account.FieldSets.Address_Matching_Criteria;
    private static final String NO = 'No';
    private static final String METADATA_VALUE = 'test.test.com';
    private static final String MX_FORM_FRENCH_URL = 'fr/?formId=';
    private static final String MX_ONBOARDING_ONE_TIME_LINK = 'www.salesforce.com/test';
    private static final String MX_STATE_TO_MX_FORM_LANGUAGE_STATIC_CONFIG = 'MxStateToMxFormLanguageMapping';
    private static final String MX_STATE_TO_MX_FORM_LANGUAGE_STATIC_CONFIG_VALUE = '{"Quebec": "fr"}';
    private static final String ONBOARDING_SCENARIO = 'Net-New Mx Onboarding';
    private static final String ONBOARDING_SCENARIO_NET_NEW_MX_ONBOARDING = 'Net-New';
    private static final String ONBOARDING_SCENARIO_PRODUCT_ADDITION = 'Product Addition';
    private static final String ONBOARDING_SCENARIO_NSE = 'NSE';
    private static final String ONE_TIME_MX_LINK_STATIC_CONFIG = 'One_Time_Mx_Link';
    private static final String PHOTOSHOOT_DATE_API_NAME = 'Photoshoot_Date__c';
    private static final String PHOTOSHOOT_TIME_API_NAME = 'Photoshoot_Time__c';
    private static final String PRIMARY_VERTICAL_RX = 'Rx';
    private static final String PROVINCE_QUEBEC = 'Quebec';
    private static final String SECTION_NAME_BUSINESS_DETAILS = 'Business Details';
    private static final String SECTION_NAME_CUSTOM_LABEL = 'Mx_Form_Business_Details_Section_Name';
    private static final Id STORE_ACCOUNT_RECORD_TYPE = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Store')
        .getRecordTypeId();
    private static final String STORE_DETAILS_ACCESSIBILITIES = '{"needToClimb":false,"hasElevatorsOrRamps":false}';
    private static final String SEGMENT_SMB = 'SMB';
    private static final String STATUS_ACTIVE = 'Active';
    private static final String STATUS_SUCCESS = 'Success';
    private static final String STATE_CODE_CAN = 'CAN';
    private static final String STATE_CODE_NY = 'NY';
    private static final String YES = 'Yes';
    private static final String ORDER_PROTOCOL_EMAIL = 'Email';
    private static final String PACKAGE_MARKETPLACE = 'Marketplace';
    private static final String SOURCE_ONBOARDING_INPUTS = 'Onboarding Inputs';
    private static final String PAYMENT_METHOD_WITHHOLDING = 'Withholding';
    private static final String ASSERT_MESSAGE_CONTRACTINFOWRAPPER = 'Unexpected result: ContractInfoWrapper is not matching';
    private static final String CUSTOM_METADATA_DEV_NAME = 'Account_Details_All';
    private static final String CUSTOM_METADATA_FORM_TYPE = 'SALES FORM';
    private static final String CUSTOM_METADATA_ONBOARDING_SCENERIO = 'Net-New';
    private static final String CUSTOM_METADATA_ORDER_PROTOCOL = 'Tablet';
    private static final Integer CUSTOM_METADATA_ORDER = 1;
    private static final String CUSTOM_METADATA_PRODUCT_ON_CONTRACT = 'Marketplace';
    private static final String CUSTOM_METADATA_REP_FILLING_ON_MX_BEHALF = 'Yes';
    private static final String CUSTOM_METADATA_SECTION = 'ABC';
    private static final String ASSERT_MESSAGE_OISECTION_ATTRIBUTE_WRAPPER_BLANK = 'Retrieved record should not be null';
    private static final String ASSERT_MESSAGE_OISECTION_ATTRIBUTE_WRAPPER = 'Unexpected result: OISECTION_ATTRIBUTE_WRAPPER is not matching';
    private static final String ACTIVATED = 'Activated';
    private static final String UNIQUE_IDENTIFIER = '942db671-92c3-3d7b-8b05-1e326f5e45f0';
    private static final String VERTICAL_NAME_RESTAURANT = 'Restaurant';
    private static final String US_BILLING_COUNTRY = 'United States';
    private static final String AGREEMENT_STATUS_ACTIVE = 'Active';
    private static final String AGREEMENT_TYPE_STORE_AGREEMENT = 'Store Agreement';
    private static final String ACCOUNT_NAME = 'Test Mock Account';
    private static final String PICKLIST_FIELD_TYPE = 'Picklist';
    private static final String DATE_FIELD_TYPE = 'Date';
    private static final String TIME_FIELD_TYPE = 'Time';
    private static final String ADDRESS_STATE_FIELD_TYPE = 'AddressState';
    private static final String MOCK_TIME = '00:45:00.000';
    private static final String MOCK_DATE = '2024-06-12';
    private static final String MOCK_STATE = 'Mock State';
    private static final String ADDRESS_STATE_API_NAME = 'Address__StateCode__s';
    private static final String MX_REQUESTED_PHOTOSHOOT_API_NAME = 'Mx_Requested_Photoshoot__c';
    private static final String MX_REQUESTED_PHOTOSHOOT_VALUE = 'Submit your own professional photos';
    private static List<Onboarding_Activation__e> mockOnboardingEvents;
    private static Fake businessOnboardingDetailsInstance;
    private static Fake storeDetailsInstance1;
    private static Fake mxOnboardingLinkInstance;
    private static Fake agreementInstance;
    private static Fake accountInstance;
    private static Id mxOnboardingLinkId;
    private static Fake storeAccountInstance1;
    private static Id brandId;
    private static final string PROVINICAL_TAX_ID = '4465465';
    private static final string TAX_ID = '345678889';

    /**
     * @description To setup relevant test data.
     */
    private static void setupdata() {
        Id storeAccountId1 = fflib_IDGenerator.generate(Account.SObjectType);
        brandId = fflib_IDGenerator.generate(Brand__c.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id agreementId = Fake.generateId(Agreement__c.class);
        Business_Vertical__c vertical = new Business_Vertical__c(
            Name = VERTICAL_NAME_RESTAURANT,
            Vertical_Name__c = VERTICAL_NAME_RESTAURANT,
            Product__c = PACKAGE_MARKETPLACE,
            Menu_UI_Type__c = VERTICAL_NAME_RESTAURANT,
            Primary_Vertical__c = PRIMARY_VERTICAL_RX
        );
        insert vertical;
        accountInstance = new Fake(Account.class)
            .setField(Account.Name, BUSINESS_NAME_TEST)
            .setField(Account.Segment__c, SEGMENT_SMB);
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        String payload =
            '{"primaryVertical":"Rx","paymentMethod":"Withholding",' +
            '"packageName":"Marketplace","orderProtocol":"Email","isSelfDelivery":true,' +
            '"isActivateCentrallyValue":"Yes","hasAlcoholPackage":null,"contractId":"' +
            contractId +
            '",' +
            '"brandName":"' +
            brandId +
            '","billingCountry":"United States","accountName":"A1 MKT New",' +
            '"accountId":"' +
            accountId +
            '"}';

        mxOnboardingLinkId = fflib_IDGenerator.generate(Mx_Onboarding_Link__c.SObjectType);
        mockOnboardingEvents = new List<Onboarding_Activation__e>{
            new Onboarding_Activation__e(
                Payload__c = JSON.serialize(new Set<Id>{ String.valueOf(mxOnboardingLinkId) }),
                Topic__c = EVENT_TOPIC_OI_DATA_CREATION
            )
        };
        storeAccountInstance1 = new Fake(Account.class)
            .setField(Account.Id, storeAccountId1)
            .setField(Account.Segment__c, SEGMENT_SMB)
            .setField(Account.RecordTypeId, STORE_ACCOUNT_RECORD_TYPE)
            .setField(Account.ParentId, accountId)
            .setField(Account.Mx_Onboarding_Link_Id__c, UNIQUE_IDENTIFIER)
            .setField(Account.BillingStreet, ADDRESS_STREET)
            .setField(Account.BillingCity, ADDRESS_CITY)
            .setField(Account.BillingStateCode, STATE_CODE_NY)
            .setField(Account.BillingCountry, US_BILLING_COUNTRY)
            .setField(Account.BillingPostalCode, ADDRESS_POSTAL_CODE);

        businessOnboardingDetailsInstance = new Fake(Business_Onboarding_Detail__c.class)
            .setField(
                Business_Onboarding_Detail__c.Id,
                fflib_IDGenerator.generate(Business_Onboarding_Detail__c.SObjectType)
            )
            .setField(Business_Onboarding_Detail__c.Legal_Business_Name__c, BUSINESS_NAME_TEST)
            .setField(Business_Onboarding_Detail__c.Brand__c, brandId)
            .setField(
                Business_Onboarding_Detail__c.Photoshoot_Contact_First_Name__c,
                CONTACT_FIRST_NAME
            )
            .setField(
                Business_Onboarding_Detail__c.Photoshoot_Contact_Last_Name__c,
                CONTACT_LAST_NAME
            )
            .setField(Business_Onboarding_Detail__c.Photoshoot_Contact_Email__c, CONTACT_EMAIL)
            .setField(Business_Onboarding_Detail__c.Photoshoot_Contact_Phone__c, CONTACT_PHONE)
            .setField(
                Business_Onboarding_Detail__c.Representative_First_Name__c,
                CONTACT_FIRST_NAME
            )
            .setField(Business_Onboarding_Detail__c.Representative_Last_Name__c, CONTACT_LAST_NAME)
            .setField(
                Business_Onboarding_Detail__c.Representative_Date_of_Birth__c,
                CONTACT_DATE_OF_BIRTH
            )
            .setField(Business_Onboarding_Detail__c.Representative_Email__c, CONTACT_EMAIL)
            .setField(
                Business_Onboarding_Detail__c.Business_Owner_First_Name__c,
                CONTACT_FIRST_NAME
            )
            .setField(Business_Onboarding_Detail__c.Business_Owner_Last_Name__c, CONTACT_LAST_NAME)
            .setField(Business_Onboarding_Detail__c.Business_Owner_DOB__c, CONTACT_DATE_OF_BIRTH)
            .setField(Business_Onboarding_Detail__c.Business_Owner_Email__c, CONTACT_EMAIL)
            .setField(
                Business_Onboarding_Detail__c.Business_Owner_Address__CountryCode__s,
                COUNTRY_CODE_US
            )
            .setField(
                Business_Onboarding_Detail__c.Business_Owner_Address__StateCode__s,
                STATE_CODE_CAN
            )
            .setField(
                Business_Onboarding_Detail__c.Business_Owner_Address__Street__s,
                ADDRESS_STREET
            )
            .setField(Business_Onboarding_Detail__c.Business_Owner_Address__City__s, ADDRESS_CITY)
            .setField(
                Business_Onboarding_Detail__c.Business_Owner_Address__PostalCode__s,
                ADDRESS_POSTAL_CODE
            )
            .setField(
                Business_Onboarding_Detail__c.Billing_Contact_First_Name__c,
                CONTACT_FIRST_NAME
            )
            .setField(Business_Onboarding_Detail__c.Billing_Contact_Last_Name__c, CONTACT_LAST_NAME)
            .setField(Business_Onboarding_Detail__c.Billing_Contact_Phone__c, CONTACT_PHONE)
            .setField(Business_Onboarding_Detail__c.Billing_Contact_Email__c, CONTACT_EMAIL)
            .setField(
                Business_Onboarding_Detail__c.Business_Director_First_Name__c,
                CONTACT_FIRST_NAME
            )
            .setField(
                Business_Onboarding_Detail__c.Business_Director_Last_Name__c,
                CONTACT_LAST_NAME
            )
            .setField(Business_Onboarding_Detail__c.Business_Director_Email__c, CONTACT_EMAIL);
        storeDetailsInstance1 = new Fake(Store_Detail__c.class)
            .setField(Store_Detail__c.Id, fflib_IDGenerator.generate(Store_Detail__c.SObjectType))
            .setField(Store_Detail__c.DM_Email__c, CONTACT_EMAIL)
            .setField(Store_Detail__c.DM_First_Name__c, CONTACT_FIRST_NAME)
            .setField(Store_Detail__c.DM_Last_Name__c, CONTACT_LAST_NAME)
            .setField(Store_Detail__c.DM_Phone__c, CONTACT_PHONE)
            .setField(Store_Detail__c.Accessibilities__c, STORE_DETAILS_ACCESSIBILITIES)
            .setField(Store_Detail__c.Account_Type__c, VIRTUAL_ACCOUNT_TYPE)
            .setField(Store_Detail__c.Address__Street__s, ADDRESS_STREET)
            .setField(Store_Detail__c.Address__City__s, ADDRESS_CITY)
            .setField(Store_Detail__c.Address__StateCode__s, ADDRESS_POSTAL_CODE)
            .setField(Store_Detail__c.Address__CountryCode__s, COUNTRY_CODE_US)
            .setField(Store_Detail__c.Tax_Id__c, TAX_ID)
            .setField(Store_Detail__c.Provincial_Tax_ID__c, PROVINICAL_TAX_ID)
            .setField(Store_Detail__c.Legal_Business_Name__c, BUSINESS_NAME_TEST);
        mxOnboardingLinkInstance = new Fake(Mx_Onboarding_Link__c.class)
            .setField(Mx_Onboarding_Link__c.Id, mxOnboardingLinkId)
            .setField(
                Mx_Onboarding_Link__c.Onboarding_Scenario__c,
                ONBOARDING_SCENARIO_NET_NEW_MX_ONBOARDING
            )
            .setField(Mx_Onboarding_Link__c.Contract__c, contractId)
            .setField(Mx_Onboarding_Link__c.Business_Account__c, accountId)
            .setField(Mx_Onboarding_Link__c.Payload__c, payload)
            .setField(Mx_Onboarding_Link__c.One_Time_Mx_Link__c, MX_ONBOARDING_ONE_TIME_LINK)
            .setField(Mx_Onboarding_Link__c.UUID__c, UNIQUE_IDENTIFIER);
        agreementInstance = new Fake(Agreement__c.class)
            .setField(Agreement__c.Id, agreementId)
            .setField(Agreement__c.Status__c, AGREEMENT_STATUS_ACTIVE)
            .setField(Agreement__c.Account__c, storeAccountId1)
            .setField(Agreement__c.Contract__c, contractId)
            .setField(Agreement__c.Type__c, AGREEMENT_TYPE_STORE_AGREEMENT);
    }

    /**
     * @description To fetch OISectionAttributeWrapper details based on the list of products selected.
     */
    @isTest
    private static void testWhenFetchOIMetadataRecordsThenReturnOISectionAttributeWrapper() {
        String productsOnContract = CUSTOM_METADATA_PRODUCT_ON_CONTRACT;
        String onboardingScenario;
        String repCollectingOnMxBehalf;
        Map<String, Country_Attributes_Mapping__mdt> countryAttributes = new Map<String, Country_Attributes_Mapping__mdt>();
        String formType;
        List<OISectionCondition__mdt> customMetadataMocks = new List<OISectionCondition__mdt>{
            new OISectionCondition__mdt(
                DeveloperName = CUSTOM_METADATA_DEV_NAME,
                Alcohol__c = true,
                Form_Type__c = CUSTOM_METADATA_FORM_TYPE,
                Products_on_Contract__c = CUSTOM_METADATA_PRODUCT_ON_CONTRACT
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOISectionConditionsSelector mockOISectionConditionsSelector = (IOISectionConditionsSelector) mocks.mock(
            IOISectionConditionsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockOISectionConditionsSelector.sObjectType())
            .thenReturn(OISectionCondition__mdt.SObjectType);
        mocks.when(
                mockOISectionConditionsSelector.fetchOIMetadataRecords(
                    productsOnContract,
                    onboardingScenario,
                    repCollectingOnMxBehalf,
                    formType
                )
            )
            .thenReturn(customMetadataMocks);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockOISectionConditionsSelector);
        Test.startTest();
        OISectionAttributeWrapper oISectionAttributeWrapperReturned = OIDataService.fetchOIMetadataRecords(
            productsOnContract,
            onboardingScenario,
            repCollectingOnMxBehalf,
            formType
        );
        countryAttributes = OIDataService.fetchCountryAttributesMetadata();
        Test.stopTest();
        System.assertNotEquals(
            null,
            oISectionAttributeWrapperReturned,
            ASSERT_MESSAGE_OISECTION_ATTRIBUTE_WRAPPER_BLANK
        );
        System.assertEquals(
            oISectionAttributeWrapperReturned.oISectionConditions[0].DeveloperName,
            customMetadataMocks[0].DeveloperName,
            ASSERT_MESSAGE_OISECTION_ATTRIBUTE_WRAPPER
        );
        System.assert(
            oISectionAttributeWrapperReturned.oISectionConditions[0].Alcohol__c,
            ASSERT_MESSAGE_OISECTION_ATTRIBUTE_WRAPPER
        );
        System.assertEquals(
            oISectionAttributeWrapperReturned.oISectionConditions[0].Form_Type__c,
            customMetadataMocks[0].Form_Type__c,
            ASSERT_MESSAGE_OISECTION_ATTRIBUTE_WRAPPER
        );
    }

    /**
     * @description To test fetching of Contract info based on Contract Id.
     */
    @isTest
    private static void testWhenFetchContractDetailsThenReturnContractInfoWrapperRecord() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Contract childContract = (Contract) new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.Status, ACTIVATED)
            .setField(Contract.AccountId, businessAccountId)
            .setParent(
                'Account',
                new Fake(Account.class)
                    .setField(Account.Order_Protocol__c, ORDER_PROTOCOL_EMAIL)
                    .setField(Account.Related_Contract__c, contractId)
                    .setField(Account.Name, ACCOUNT_NAME)
                    .setField(Account.Id, businessAccountId)
            )
            .setChildren(
                'SBQQ__Subscriptions__r',
                new List<Fake>{
                    new Fake(SBQQ__Subscription__c.class)
                        .setField(SBQQ__Subscription__c.Package__c, PACKAGE_MARKETPLACE)
                        .setField(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
                        .setField(
                            SBQQ__Subscription__c.id,
                            Fake.generateId(SBQQ__Subscription__c.class)
                        )
                }
            )
            .toSObject();
        List<OIPackageProductMapping__mdt> customMetadataMocks = new List<OIPackageProductMapping__mdt>{
            new OIPackageProductMapping__mdt(
                DeveloperName = CUSTOM_METADATA_DEVELOPER_NAME,
                MasterLabel = CUSTOM_METADATA_MASTER_LABEL,
                Package__c = PACKAGE_MARKETPLACE,
                Product_Category__c = PACKAGE_MARKETPLACE
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IContractsSelector mockContractsSelector = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        OIPackageProductMappingsSelector mockOIPackageProductMappingsSelector = (OIPackageProductMappingsSelector) mocks.mock(
            OIPackageProductMappingsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockContractsSelector.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(
                mockContractsSelector.selectContractsWithSubscriptions(new Set<Id>{ contractId })
            )
            .thenReturn(new List<Contract>{ childContract });
        mocks.when(mockOIPackageProductMappingsSelector.sObjectType())
            .thenReturn(OIPackageProductMapping__mdt.SObjectType);
        mocks.when(mockOIPackageProductMappingsSelector.getAllMappings())
            .thenReturn(customMetadataMocks);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockContractsSelector);
        Application.SELECTOR.setMock(mockOIPackageProductMappingsSelector);
        Test.startTest();
        ContractInfoWrapper contractInfoWrapperReturned = OIDataService.fetchContractDetails(
            contractId,
            ONBOARDING_SCENARIO
        );
        Test.stopTest();
        System.assert(
            contractInfoWrapperReturned.isMarketplace,
            ASSERT_MESSAGE_CONTRACTINFOWRAPPER
        );
        System.assert(contractInfoWrapperReturned.isEmail, ASSERT_MESSAGE_CONTRACTINFOWRAPPER);
    }

    /**
     * @description To test insertion of Mx Onboarding Link record based on wrapper values.
     */
    @isTest
    private static void testWhenSaveMxOnboardingLinkRecordThenReturnMxOnboardingLinkRecord() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Boolean recordSave;
        Id mxOnboardingLinkId = fflib_IDGenerator.generate(Mx_Onboarding_Link__c.SObjectType);
        OIMainDataWrapper oiMainDataWrapperToPass = new OIMainDataWrapper(
            businessAccountId,
            contractId
        );
        oiMainDataWrapperToPass.isMxInputRequired = true;
        oiMainDataWrapperToPass.onboardingScenario = ONBOARDING_SCENARIO;
        List<OIFieldWrapper> businessInfoWrappers = new List<OIFieldWrapper>{
            new OIFieldWrapper(ACTIVATED_CENTRALLY_API_NAME, YES, PICKLIST_FIELD_TYPE),
            new OIFieldWrapper(PHOTOSHOOT_DATE_API_NAME, MOCK_DATE, DATE_FIELD_TYPE),
            new OIFieldWrapper(PHOTOSHOOT_TIME_API_NAME, MOCK_TIME, TIME_FIELD_TYPE),
            new OIFieldWrapper(ADDRESS_STATE_API_NAME, MOCK_STATE, ADDRESS_STATE_FIELD_TYPE),
            new OIFieldWrapper(
                MX_REQUESTED_PHOTOSHOOT_API_NAME,
                MX_REQUESTED_PHOTOSHOOT_VALUE,
                PICKLIST_FIELD_TYPE
            )
        };
        oiMainDataWrapperToPass.businessInfoWrappers = businessInfoWrappers;
        List<OIFieldWrapper> storeInfoWrappers = new List<OIFieldWrapper>{
            new OIFieldWrapper(DELAY_TABLET_SHIPMENT_API_NAME, YES, PICKLIST_FIELD_TYPE)
        };
        Id parentAccId = fflib_IDGenerator.generate(Account.SObjectType);
        List<StoreDataWrapper> storeDataWrappers = new List<StoreDataWrapper>{
            new StoreDataWrapper(1, storeInfoWrappers, parentAccId)
        };
        oiMainDataWrapperToPass.storeDataWrappers = storeDataWrappers;
        oiMainDataWrapperToPass.repCollectingOnMxBehalf = NO;
        OIFormPayloadWrapper payloadWrapper = new OIFormPayloadWrapper(contractId);
        payloadWrapper.accountId = businessAccountId;
        payloadWrapper.accountName = ACCOUNT_NAME;
        payloadWrapper.packageName = CUSTOM_METADATA_PRODUCT_ON_CONTRACT;
        payloadWrapper.paymentMethod = PAYMENT_METHOD_WITHHOLDING;
        oiMainDataWrapperToPass.payload = payloadWrapper;
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IStaticConfigurationsSelector mockStaticConfigurations = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockStaticConfigurations.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(mockStaticConfigurations.getInstanceValue(ONE_TIME_MX_LINK_STATIC_CONFIG))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = ONE_TIME_MX_LINK_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(mockStaticConfigurations.getInstanceValue(QUERIES_ALLOWED_LIMIT_STATIC_CONFIG))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = QUERIES_ALLOWED_LIMIT_STATIC_CONFIG,
                    Configuration_Value__c = QUERY_VALUE
                )
            );
        mocks.when(
                mockStaticConfigurations.getInstanceValue(QUERY_ROWS_ALLOWED_LIMIT_STATIC_CONFIG)
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = QUERY_ROWS_ALLOWED_LIMIT_STATIC_CONFIG,
                    Configuration_Value__c = QUERY_ROW_VALUE
                )
            );
        mocks.when(
                mockStaticConfigurations.getInstanceValue(
                    MX_STATE_TO_MX_FORM_LANGUAGE_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = MX_STATE_TO_MX_FORM_LANGUAGE_STATIC_CONFIG,
                    Configuration_Value__c = MX_STATE_TO_MX_FORM_LANGUAGE_STATIC_CONFIG_VALUE
                )
            );
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockStaticConfigurations);
        String oiMainDataWrapperJSON = JSON.serialize(
            new List<OIMainDataWrapper>{ oiMainDataWrapperToPass }
        );
        Test.startTest();
        Mx_Onboarding_Link__c mxOnboardingLink = OIDataService.saveMxOnboardingLinkRecord(
            oiMainDataWrapperJSON
        );
        recordSave = OIDataService.saveMxFormDetails(oiMainDataWrapperJSON, mxOnboardingLinkId);
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 5)).commitWork();
        System.assertEquals(
            ONBOARDING_SCENARIO,
            mxOnboardingLink.Onboarding_Scenario__c,
            ASSERT_MESSAGE_MX_ONBOARDING_LINK
        );
        System.assertEquals(
            STATUS_ACTIVE,
            mxOnboardingLink.Status__c,
            ASSERT_MESSAGE_MX_ONBOARDING_LINK
        );
    }

    /**
     * @description This method test the positive scenario for fetching Active MxOnboarding Link based on the contract Id.
     */
    @isTest
    private static void testWhenGetActiveMxOnboardingLinkThenReturnMxOnboardingLinkRecord() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id mxOnboardingLinkId = fflib_IDGenerator.generate(Mx_Onboarding_Link__c.SObjectType);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IStaticConfigurationsSelector mockStaticConfigurations = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        IMxOnboardingLinksSelector mxOnboardingLinksSelector = (IMxOnboardingLinksSelector) mocks.mock(
            IMxOnboardingLinksSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockStaticConfigurations.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(mockStaticConfigurations.getInstanceValue(ONE_TIME_MX_LINK_STATIC_CONFIG))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = ONE_TIME_MX_LINK_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(mockStaticConfigurations.getInstanceValue(QUERIES_ALLOWED_LIMIT_STATIC_CONFIG))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = QUERIES_ALLOWED_LIMIT_STATIC_CONFIG,
                    Configuration_Value__c = QUERY_VALUE
                )
            );
        mocks.when(
                mockStaticConfigurations.getInstanceValue(QUERY_ROWS_ALLOWED_LIMIT_STATIC_CONFIG)
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = QUERY_ROWS_ALLOWED_LIMIT_STATIC_CONFIG,
                    Configuration_Value__c = QUERY_ROW_VALUE
                )
            );
        mocks.when(
                mockStaticConfigurations.getInstanceValue(
                    MX_STATE_TO_MX_FORM_LANGUAGE_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = MX_STATE_TO_MX_FORM_LANGUAGE_STATIC_CONFIG,
                    Configuration_Value__c = MX_STATE_TO_MX_FORM_LANGUAGE_STATIC_CONFIG_VALUE
                )
            );
        mocks.when(mxOnboardingLinksSelector.sObjectType())
            .thenReturn(Mx_Onboarding_Link__c.SObjectType);
        mocks.when(mxOnboardingLinksSelector.selectByContractIds(new Set<Id>{ contractId }))
            .thenReturn(
                new List<Mx_Onboarding_Link__c>{
                    new Mx_Onboarding_Link__c(
                        Id = mxOnboardingLinkId,
                        Business_Account__c = businessAccountId,
                        Contract__c = contractId,
                        Onboarding_Scenario__c = ONBOARDING_SCENARIO,
                        Rep_Collecting_On_Mx_Behalf__c = NO,
                        Expiration_Date_Time__c = System.today().addDays(10),
                        Status__c = STATUS_ACTIVE,
                        Record_Creation_Status__c = STATUS_SUCCESS
                    )
                }
            );
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockStaticConfigurations);
        Application.SELECTOR.setMock(mxOnboardingLinksSelector);
        Test.startTest();
        Mx_Onboarding_Link__c mxOnboardingLink = OIDataService.getActiveMxOnboardingLink(
            contractId
        );
        Test.stopTest();
        System.assertEquals(
            contractId,
            mxOnboardingLink.Contract__c,
            ASSERT_MESSAGE_MX_ONBOARDING_LINK
        );
        System.assertEquals(
            ONBOARDING_SCENARIO,
            mxOnboardingLink.Onboarding_Scenario__c,
            ASSERT_MESSAGE_MX_ONBOARDING_LINK
        );
        System.assertEquals(
            STATUS_ACTIVE,
            mxOnboardingLink.Status__c,
            ASSERT_MESSAGE_MX_ONBOARDING_LINK
        );
        System.assertEquals(
            STATUS_SUCCESS,
            mxOnboardingLink.Record_Creation_Status__c,
            ASSERT_MESSAGE_MX_ONBOARDING_LINK
        );
    }

    /**
     * @description Test scenarios where same contact details are used across all contact information.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenSameContactIsUsedForAllRolesThenCreateSingleContactInfoWrapper() {
        Schema.SObjectField parentField = Account.ParentId;
        setupdata();
        mxOnboardingLinkInstance.setChildren(
                'Business_Onboarding_Details__r',
                new List<Fake>{ businessOnboardingDetailsInstance }
            )
            .setChildren('Store_Details__r', new List<Fake>{ storeDetailsInstance1 });
        List<Mx_Onboarding_Link__c> mxOnboardingLinkFakeRecords = new List<Mx_Onboarding_Link__c>{
            (Mx_Onboarding_Link__c) mxOnboardingLinkInstance.toSobject()
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IMxOnboardingLinksSelector mxOnboardingLinksSelectorMock = (IMxOnboardingLinksSelector) mocks.mock(
            IMxOnboardingLinksSelector.class
        );
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        ContactAndAcrCreateService contactAndAcrCreateServiceMock = (ContactAndAcrCreateService) mocks.mock(
            ContactAndAcrCreateService.class
        );
        mocks.startStubbing();
        mocks.when(mxOnboardingLinksSelectorMock.sObjectType())
            .thenReturn(Mx_Onboarding_Link__c.SObjectType);
        mocks.when(
                mxOnboardingLinksSelectorMock.selectByMxOnboardingLinkIds(
                    new Set<Id>{ mxOnboardingLinkId }
                )
            )
            .thenReturn(mxOnboardingLinkFakeRecords);
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                accountsSelectorMock.selectAccountsByMxOnboardingLinkIds(
                    new Set<String>{ UNIQUE_IDENTIFIER }
                )
            )
            .thenReturn(new List<Account>{});
        mocks.when(
                accountsSelectorMock.selectBusinessAccountsByParentIds(
                    parentField,
                    new Set<Id>{ mxOnboardingLinkFakeRecords[0].Business_Account__c }
                )
            )
            .thenReturn(new List<Account>{});
        mocks.when(
                accountsSelectorMock.selectMatchingAccounts(
                    (Schema.FieldSet) fflib_Match.anyObject(),
                    (Set<String>) fflib_Match.anyObject(),
                    (Set<Id>) fflib_Match.anyObject(),
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(new List<Account>{ (Account) storeAccountInstance1.toSObject() });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mxOnboardingLinksSelectorMock);
        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SERVICE.setMock(
            ContactAndAcrCreateService.class,
            contactAndAcrCreateServiceMock
        );
        ContactDto.contactInfo contactInfo = new ContactDto.contactInfo();
        contactInfo.firstName = CONTACT_FIRST_NAME;
        contactInfo.lastName = CONTACT_LAST_NAME;
        contactInfo.email = CONTACT_EMAIL;
        contactInfo.phone = CONTACT_PHONE;
        contactInfo.ssn = '';
        contactInfo.dateOfBirth = CONTACT_DATE_OF_BIRTH;
        contactInfo.mobilePhone = '';
        contactInfo.address = new ContactDto.Address();
        contactInfo.address.city = ADDRESS_CITY;
        contactInfo.address.country = COUNTRY_CODE_US;
        contactInfo.address.postalCode = ADDRESS_POSTAL_CODE;
        contactInfo.address.state = STATE_CODE_CAN;
        contactInfo.address.street = ADDRESS_STREET;
        contactInfo.source = SOURCE_ONBOARDING_INPUTS;
        Test.startTest();
        OIDataService.fetchCountryStatePicklistValues();
        OIDataService.execute(mockOnboardingEvents);
        ContactAndAcrCreateService.processContactsPayloadSync(
            new List<String>{ JSON.serialize(contactInfo) }
        );
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 11)).commitWork();
    }

    /**
     * @description Test scenarios where only Sales inputs are needed.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenNoMxInputIsNeeded() {
        Schema.SObjectField parentField = Account.ParentId;
        setupdata();
        mxOnboardingLinkInstance.setField(Mx_Onboarding_Link__c.One_Time_Mx_Link__c, null);
        mxOnboardingLinkInstance.setChildren(
                'Business_Onboarding_Details__r',
                new List<Fake>{ businessOnboardingDetailsInstance }
            )
            .setChildren('Store_Details__r', new List<Fake>{ storeDetailsInstance1 });
        List<Mx_Onboarding_Link__c> mxOnboardingLinkFakeRecords = new List<Mx_Onboarding_Link__c>{
            (Mx_Onboarding_Link__c) mxOnboardingLinkInstance.toSobject()
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IMxOnboardingLinksSelector mxOnboardingLinksSelectorMock = (IMxOnboardingLinksSelector) mocks.mock(
            IMxOnboardingLinksSelector.class
        );
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IAgreementsSelector agreementsSelectorMock = (IAgreementsSelector) mocks.mock(
            IAgreementsSelector.class
        );
        ContactAndAcrCreateService contactAndAcrCreateServiceMock = (ContactAndAcrCreateService) mocks.mock(
            ContactAndAcrCreateService.class
        );
        mocks.startStubbing();
        mocks.when(mxOnboardingLinksSelectorMock.sObjectType())
            .thenReturn(Mx_Onboarding_Link__c.SObjectType);
        mocks.when(
                mxOnboardingLinksSelectorMock.selectByMxOnboardingLinkIds(
                    new Set<Id>{ mxOnboardingLinkId }
                )
            )
            .thenReturn(mxOnboardingLinkFakeRecords);
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                accountsSelectorMock.selectAccountsByMxOnboardingLinkIds(
                    new Set<String>{ UNIQUE_IDENTIFIER }
                )
            )
            .thenReturn(new List<Account>{});
        mocks.when(
                accountsSelectorMock.selectBusinessAccountsByParentIds(
                    parentField,
                    new Set<Id>{ mxOnboardingLinkFakeRecords[0].Business_Account__c }
                )
            )
            .thenReturn(new List<Account>{});
        mocks.when(agreementsSelectorMock.sObjectType()).thenReturn(Agreement__c.SObjectType);
        mocks.when(
                agreementsSelectorMock.selectActiveStoreAgreementsByContractIds(
                    new Set<Id>{ mxOnboardingLinkFakeRecords[0].Contract__c }
                )
            )
            .thenReturn(new List<Agreement__c>{ (Agreement__c) agreementInstance.toSObject() });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mxOnboardingLinksSelectorMock);
        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(agreementsSelectorMock);
        Application.SERVICE.setMock(
            ContactAndAcrCreateService.class,
            contactAndAcrCreateServiceMock
        );
        Test.startTest();
        OIDataService.execute(mockOnboardingEvents);
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 8)).commitWork();
    }

    /**
     * @description To test fetching of Opportunity info based on Contract Id.
     */
    @isTest
    private static void testWhenFetchOpportunityDetailsThenReturnOpportunityId() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id quoteId = fflib_IDGenerator.generate(SBQQ__Quote__c.SobjectType);
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);

        Contract fakeContract = (Contract) new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.Status, STATUS_ACTIVATED)
            .setField(Contract.SBQQ__Quote__c, quoteId)
            .setField(Contract.Unique_Identifier__c, UNIQUE_IDENTIFIER)
            .setField(Contract.SBQQ__Opportunity__c, opportunityId)
            .setParent(
                'Account',
                new Fake(Account.class)
                    .setField(Account.Name, BUSINESS_NAME_TEST)
                    .setField(Account.Id, businessAccountId)
            )
            .setParent(
                'SBQQ__Order__r',
                new Fake(Order.class).setField(Order.Unique_Identifier__c, UNIQUE_IDENTIFIER)
            )
            .toSObject();

        Opportunity opportunityRecord = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.Name, 'Test opportunity 1')
            .setField(Opportunity.AccountId, businessAccountId)
            .setField(Opportunity.ContractId, contractId)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_CONTRACTING)
            .setField(Contract.SBQQ__Quote__c, quoteId)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IContractsSelector mockContractsSelector = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        IOpportunitiesSelector mockOpportunitySelector = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );

        mocks.startStubbing();
        mocks.when(mockContractsSelector.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(mockContractsSelector.selectById(new Set<Id>{ contractId }))
            .thenReturn(new List<Contract>{ fakeContract });

        mocks.when(mockOpportunitySelector.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(
                mockOpportunitySelector.selectBySubTypeAndAccount(new Set<Id>{ businessAccountId })
            )
            .thenReturn(new List<Opportunity>{ opportunityRecord });

        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockContractsSelector);
        Application.SELECTOR.setMock(mockOpportunitySelector);
        Test.startTest();
        OIDataService.fetchOpportunityBasedOnOnboardingScenario(
            contractId,
            businessAccountId,
            ONBOARDING_SCENARIO_NSE
        );
        OIDataService.fetchOpportunityBasedOnOnboardingScenario(
            contractId,
            businessAccountId,
            ONBOARDING_SCENARIO_PRODUCT_ADDITION
        );
        Test.stopTest();
        System.assertEquals(
            fakeContract.SBQQ__Opportunity__c,
            opportunityId,
            ASSERT_MESSAGE_MX_ONBOARDING_LINK
        );
    }

    /**
     * @description To test Mx Form URL is defaulted with French language
     * when Account's Billing Province is 'Quebec'.
     */
    @isTest
    private static void testWhenAccountProvinceQuebecThenGenerateFrenchURL() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Boolean recordSave;
        Id mxOnboardingLinkId = fflib_IDGenerator.generate(Mx_Onboarding_Link__c.SObjectType);
        OIMainDataWrapper oiMainDataWrapperToPass = new OIMainDataWrapper(
            businessAccountId,
            contractId
        );
        oiMainDataWrapperToPass.isMxInputRequired = true;
        oiMainDataWrapperToPass.onboardingScenario = ONBOARDING_SCENARIO;
        List<OIFieldWrapper> businessInfoWrappers = new List<OIFieldWrapper>{
            new OIFieldWrapper(ACTIVATED_CENTRALLY_API_NAME, YES, PICKLIST_FIELD_TYPE),
            new OIFieldWrapper(PHOTOSHOOT_DATE_API_NAME, MOCK_DATE, DATE_FIELD_TYPE),
            new OIFieldWrapper(PHOTOSHOOT_TIME_API_NAME, MOCK_TIME, TIME_FIELD_TYPE),
            new OIFieldWrapper(ADDRESS_STATE_API_NAME, MOCK_STATE, ADDRESS_STATE_FIELD_TYPE),
            new OIFieldWrapper(
                MX_REQUESTED_PHOTOSHOOT_API_NAME,
                MX_REQUESTED_PHOTOSHOOT_VALUE,
                PICKLIST_FIELD_TYPE
            )
        };
        oiMainDataWrapperToPass.businessInfoWrappers = businessInfoWrappers;
        List<OIFieldWrapper> storeInfoWrappers = new List<OIFieldWrapper>{
            new OIFieldWrapper(DELAY_TABLET_SHIPMENT_API_NAME, YES, PICKLIST_FIELD_TYPE)
        };
        Id parentAccId = fflib_IDGenerator.generate(Account.SObjectType);
        List<StoreDataWrapper> storeDataWrappers = new List<StoreDataWrapper>{
            new StoreDataWrapper(1, storeInfoWrappers, parentAccId)
        };
        oiMainDataWrapperToPass.storeDataWrappers = storeDataWrappers;
        oiMainDataWrapperToPass.repCollectingOnMxBehalf = NO;
        OIFormPayloadWrapper payloadWrapper = new OIFormPayloadWrapper(contractId);
        payloadWrapper.accountId = businessAccountId;
        payloadWrapper.accountName = ACCOUNT_NAME;
        payloadWrapper.billingState = PROVINCE_QUEBEC;
        payloadWrapper.packageName = CUSTOM_METADATA_PRODUCT_ON_CONTRACT;
        payloadWrapper.paymentMethod = PAYMENT_METHOD_WITHHOLDING;
        oiMainDataWrapperToPass.payload = payloadWrapper;
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IStaticConfigurationsSelector mockStaticConfigurations = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockStaticConfigurations.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(mockStaticConfigurations.getInstanceValue(ONE_TIME_MX_LINK_STATIC_CONFIG))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = ONE_TIME_MX_LINK_STATIC_CONFIG,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.when(mockStaticConfigurations.getInstanceValue(QUERIES_ALLOWED_LIMIT_STATIC_CONFIG))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = QUERIES_ALLOWED_LIMIT_STATIC_CONFIG,
                    Configuration_Value__c = QUERY_VALUE
                )
            );
        mocks.when(
                mockStaticConfigurations.getInstanceValue(QUERY_ROWS_ALLOWED_LIMIT_STATIC_CONFIG)
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = QUERY_ROWS_ALLOWED_LIMIT_STATIC_CONFIG,
                    Configuration_Value__c = QUERY_ROW_VALUE
                )
            );
        mocks.when(
                mockStaticConfigurations.getInstanceValue(
                    MX_STATE_TO_MX_FORM_LANGUAGE_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = MX_STATE_TO_MX_FORM_LANGUAGE_STATIC_CONFIG,
                    Configuration_Value__c = MX_STATE_TO_MX_FORM_LANGUAGE_STATIC_CONFIG_VALUE
                )
            );
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockStaticConfigurations);
        String oiMainDataWrapperJSON = JSON.serialize(
            new List<OIMainDataWrapper>{ oiMainDataWrapperToPass }
        );
        Test.startTest();
        Mx_Onboarding_Link__c mxOnboardingLink = OIDataService.saveMxOnboardingLinkRecord(
            oiMainDataWrapperJSON
        );
        recordSave = OIDataService.saveMxFormDetails(oiMainDataWrapperJSON, mxOnboardingLinkId);
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 5)).commitWork();
        System.assertEquals(
            true,
            mxOnboardingLink.One_Time_Mx_Link__c.contains(MX_FORM_FRENCH_URL),
            ASSERT_MESSAGE_MX_ONBOARDING_LINK
        );
    }

    /**
     * @description To test Custom Metadata records are translated to 'French'
     * when requested for French Mx Form.
     */
    @isTest
    private static void testWhenFetchOIMetadataRecordsForFrenchMxFormThenReturnTranslatedOISectionAttributeWrapper() {
        String productsOnContract = CUSTOM_METADATA_PRODUCT_ON_CONTRACT;
        String onboardingScenario;
        String repCollectingOnMxBehalf;
        Map<String, Country_Attributes_Mapping__mdt> countryAttributes = new Map<String, Country_Attributes_Mapping__mdt>();
        List<OISectionCondition__mdt> customMetadataMocks = new List<OISectionCondition__mdt>{
            new OISectionCondition__mdt(
                DeveloperName = CUSTOM_METADATA_DEV_NAME,
                Section__c = SECTION_NAME_BUSINESS_DETAILS,
                Alcohol__c = true,
                Form_Type__c = CUSTOM_METADATA_FORM_TYPE,
                Products_on_Contract__c = CUSTOM_METADATA_PRODUCT_ON_CONTRACT
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOISectionConditionsSelector mockOISectionConditionsSelector = (IOISectionConditionsSelector) mocks.mock(
            IOISectionConditionsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockOISectionConditionsSelector.sObjectType())
            .thenReturn(OISectionCondition__mdt.SObjectType);
        mocks.when(
                mockOISectionConditionsSelector.fetchOIMetadataRecords(
                    productsOnContract,
                    onboardingScenario,
                    repCollectingOnMxBehalf,
                    FORM_TYPE_MX_FORM
                )
            )
            .thenReturn(customMetadataMocks);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockOISectionConditionsSelector);
        Test.startTest();
        OISectionAttributeWrapper oISectionAttributeWrapperReturned = OIDataService.fetchOIMetadataRecords(
            productsOnContract,
            onboardingScenario,
            repCollectingOnMxBehalf,
            FORM_TYPE_MX_FORM,
            FORM_LANGUAGE_FRENCH
        );
        countryAttributes = OIDataService.fetchCountryAttributesMetadata();
        Test.stopTest();
        System.assertEquals(
            oISectionAttributeWrapperReturned.oISectionConditions[0].Section__c,
            System.Label.get(EMPTY_STRING, SECTION_NAME_CUSTOM_LABEL, FORM_LANGUAGE_FRENCH),
            ASSERT_MESSAGE_OISECTION_ATTRIBUTE_WRAPPER
        );
    }
}