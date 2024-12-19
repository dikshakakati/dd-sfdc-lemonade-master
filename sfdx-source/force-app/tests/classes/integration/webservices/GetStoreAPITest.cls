@IsTest(seeAllData=false)
private class GetStoreAPITest {
    private static final String COO_GET_STORE_API_MAX_STORE_NUMBER = 'COO_Get_Store_API_Max_Store_Number';
    private static final String STORES_ROW_LIMIT_ON_ADD_STORES_QUICK_ACTION_STATIC_CONFIG = 'Stores_RowLimit_On_AddStores_QuickAction';
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final String VERTICAL = 'Floral';
    private static final String CORPORATE = 'Corporate';
    private static final String ENTERPRISE = 'Enterprise';
    private static final String FRANCHISE = 'Franchise';
    private static final String MENU_UI_RETAIL = 'Retail';
    private static final String COUNTRY_US = 'US';
    private static final String CONTACT_EMAIL = 'testEmail@sampleEmail.com';
    private static final String CONTACT_FIRSTNAME = 'Bianca';
    private static final String CONTACT_LASTNAME = 'Fausten';
    private static final String DECISION_MAKER_CONTACT = 'Decision Maker';
    private static final String STATUS_ACTIVE = 'Active';
    private static final String STATUS_SUCCESS = 'Success';
    private static final String CONTRACT_TYPE_MARKETPLACE = 'Marketplace';
    private static final String EXTERNAL_ID_SOURCE_MDS = 'MDS';
    private static final String ASSERT_MESSAGE_BLANK_STRING_EXPECTED = 'There should be an error message stating that blank string are not accepted.';
    private static final String ASSERT_MESSAGE_NULL_RESPONSE_NOT_EXPECTED = 'The response should not be null';
    private static final String ASSERT_MESSAGE_STORE_EXPECTED = 'There should be a store entry in the JSON returned';
    private static final String ASSERT_MESSAGE_COO_EXPECTED = 'There should be a coo entry in the JSON returned';
    private static final String ASSERT_MESSAGE_ERROR_STORE_NOT_FOUND = 'There should be an error message in the json stating that the store was not found';
    private static final String ASSERT_MESSAGE_TOO_MANY_STORES = 'There should be an error message in the '
                                                              + 'number of stores requested is beyond the maximum number stored in the custom metadata.';

    @isTest
    static void testWhenGetStoreWhenInvalidStoreNumberThenReturnErrorString() {
        String responseJSON = GetStoreAPI.getRecords('');
        System.assertNotEquals(null, responseJSON, ASSERT_MESSAGE_NULL_RESPONSE_NOT_EXPECTED);
        System.assertEquals('BLANK STRING NOT ACCEPTED', responseJSON,
                            ASSERT_MESSAGE_BLANK_STRING_EXPECTED);
    }

    @isTest
    static void testWhenGetStoreWithStoreNumberThatDoesNotExistThenReturnErrorString() {
        Static_Configurations__mdt maxStoresConfiguration = new Static_Configurations__mdt(
            DeveloperName = COO_GET_STORE_API_MAX_STORE_NUMBER,
            MasterLabel = COO_GET_STORE_API_MAX_STORE_NUMBER,
            Configuration_Value__c = '10'
        );
        Static_Configurations__mdt storesRowLimitConfiguration = new Static_Configurations__mdt(
            DeveloperName = STORES_ROW_LIMIT_ON_ADD_STORES_QUICK_ACTION_STATIC_CONFIG,
            MasterLabel = STORES_ROW_LIMIT_ON_ADD_STORES_QUICK_ACTION_STATIC_CONFIG,
            Configuration_Value__c = '10'
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStaticConfigurationsSelector mockStaticConfigurationsSelector = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockStaticConfigurationsSelector.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    COO_GET_STORE_API_MAX_STORE_NUMBER
                )
            )
            .thenReturn(maxStoresConfiguration);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    STORES_ROW_LIMIT_ON_ADD_STORES_QUICK_ACTION_STATIC_CONFIG
                )
            )
            .thenReturn(storesRowLimitConfiguration);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);

        String responseJSON = GetStoreAPI.getRecords('0000000');
        System.assertNotEquals(null, responseJSON, ASSERT_MESSAGE_NULL_RESPONSE_NOT_EXPECTED);
        System.assertEquals(true, responseJSON.contains('Store not found'), ASSERT_MESSAGE_ERROR_STORE_NOT_FOUND);
    }

    @isTest
    static void testWhenGetStoreWithTooManyStoreNumbersThenReturnErrorString() {
        Static_Configurations__mdt maxStoresConfiguration = new Static_Configurations__mdt(
            DeveloperName = COO_GET_STORE_API_MAX_STORE_NUMBER,
            MasterLabel = COO_GET_STORE_API_MAX_STORE_NUMBER,
            Configuration_Value__c = '10'
        );

        Integer maxStoreNumber = Integer.valueOf(maxStoresConfiguration.Configuration_Value__c);
        String storeIds = '';
        for (Integer i = 0; i < maxStoreNumber + 2; i++) {
            storeIds += String.valueOf(i) + ',';
        }
        storeIds = storeIds.removeEnd(',');

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStaticConfigurationsSelector mockStaticConfigurationsSelector = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockStaticConfigurationsSelector.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    COO_GET_STORE_API_MAX_STORE_NUMBER
                )
            )
            .thenReturn(maxStoresConfiguration);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);

        String responseJSON = GetStoreAPI.getRecords(storeIds);
        System.assertNotEquals(null, responseJSON, ASSERT_MESSAGE_NULL_RESPONSE_NOT_EXPECTED);
        System.assertEquals(true, responseJSON.contains('SERVICE DOES NOT ACCEPT MORE THAN '), ASSERT_MESSAGE_TOO_MANY_STORES);
    }

    @isTest
    private static void testWhenGetStoreWithOneStoreNumberThenReturnStoreJson() {
        Id storeAccountId = Fake.generateId(Account.class);
        Id businessAccountId = Fake.generateId(Account.class);
        String externalId1 = '1234567';
        String externalId2 = '2345678';
        Id xrefId1 = Fake.generateId(Xref__c.class);
        Id xrefId2 = Fake.generateId(Xref__c.class);
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
        Id contractId = Fake.generateId(Contract.class);
        Id mxServiceId = Fake.generateId(Merchant_Service__c.class);

        Xref__c xref = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Salesforce_Account_Name__c, storeAccountId)
            .setField(Xref__c.External_ID__c, externalId1)
            .setField(Xref__c.External_ID_Source__c, EXTERNAL_ID_SOURCE_MDS)
            .setField(Xref__c.Id, xrefId1)
            .toSObject();

        Account businessAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, businessAccountId)
            .setField(Account.BillingCountryCode, 'US')
            .toSObject();

        Account storeAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, storeAccountId)
            .setField(Account.BillingCountryCode, COUNTRY_US)
            .setField(Account.Type, FRANCHISE)
            .setField(Account.Legal_Business_Name__c, 'Legal Name')
            .setField(Account.Merchant_Supplied_ID__c, '1928983')
            .setField(Account.Segment__c, ENTERPRISE)
            .setField(Account.Primary_Vertical__c, VERTICAL)
            .setField(Account.Address_Id__c, '11223344')
            .setField(Account.Alcohol_Addendum_Signed__c, false)
            .setField(Account.Menu_UI_Type__c, MENU_UI_RETAIL)
            .setField(Account.ParentId, businessAccountId)
            .setField(Account.BillingCountryCode, 'US')
            .setParent('Parent', new Fake(Account.class)
                        .setField(Account.Id, businessAccountId)
                        .setField(Account.Type, CORPORATE)
                        .setField(Account.BillingCountryCode, 'US')
                      )
            .setChildren(
                'Contacts',
                new List<Fake> {
                    new Fake(Contact.class)
                        .setField(Contact.LastName, CONTACT_LASTNAME)
                        .setField(Contact.FirstName, CONTACT_FIRSTNAME)
                        .setField(Contact.Email, CONTACT_EMAIL)
                        .setField(Contact.AccountId, storeAccountId)
                        .setField(Contact.Id, contactId)
                    }
                )
            .setChildren(
                'AccountContactRelations',
                new List<Fake>{
                    new Fake(AccountContactRelation.class)
                        .setField(AccountContactRelation.AccountId, storeAccountId)
                        .setField(AccountContactRelation.Account_Record_Type__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
                        .setField(AccountContactRelation.ContactId, contactId)
                        .setField(AccountContactRelation.Roles, DECISION_MAKER_CONTACT)
                        .setParent(
                            'Contact',
                            new Fake(Contact.class)
                                .setField(Contact.Id, contactId)
                                .setField(Contact.Phone, null)
                        )
                        .setParent(
                            'Account',
                            new Fake(Account.class)
                            .setField(Account.Id, storeAccountId)
                        )
                }
            )
            .setChildren(
                'Xrefs__r',
                new List<Fake>{
                    new Fake(Xref__c.class)
                        .setField(Xref__c.Salesforce_Account_Name__c, storeAccountId)
                        .setField(Xref__c.External_ID__c, externalId1)
                        .setField(Xref__c.External_ID_Source__c, EXTERNAL_ID_SOURCE_MDS)
                        .setField(Xref__c.Id, xrefId1),
                    new Fake(Xref__c.class)
                        .setField(Xref__c.Salesforce_Account_Name__c, storeAccountId)
                        .setField(Xref__c.External_ID__c, externalId2)
                        .setField(Xref__c.External_ID_Source__c, EXTERNAL_ID_SOURCE_MDS)
                        .setField(Xref__c.Id, xrefId2)
                }
            )
            .setChildren(
                'Contracts',
                new List<Fake>{
                    new Fake(Contract.class)
                    .setField(Contract.Contract_Type__c, CONTRACT_TYPE_MARKETPLACE)
                    .setField(Contract.Name, 'Contract1')
                    .setField(Contract.Id, contractId)
                    .setField(Contract.Status, STATUS_ACTIVE)
                    .setField(Contract.StartDate, Date.newInstance(2023, 1, 30))
                    .setParent(
                        'Account',
                        new Fake(Account.class)
                            .setField(Account.Id, storeAccountId)
                    )
                }
            )
            .setChildren(
                'Agreements__r',
                new List<Fake>{
                    new Fake(Agreement__c.class)
                    .setField(Agreement__c.Account__c, storeAccountId)
                    .setField(Agreement__c.Contract__c, contractId)
                    .setParent(
                        'Contract__r',
                        new Fake(Contract.class)
                            .setField(Contract.Contract_Type__c, CONTRACT_TYPE_MARKETPLACE)
                            .setField(Contract.Name, 'Contract2')
                            .setField(Contract.Id, contractId)
                            .setField(Contract.Status, STATUS_ACTIVE)
                            .setField(Contract.StartDate, Date.newInstance(2023, 1, 30))
                    )
                }
            )
            .setChildren(
                'Services__r',
                new List<Fake>{
                    new Fake(Merchant_Service__c.class)
                    .setField(Merchant_Service__c.Id, mxServiceId)
                    .setField(Merchant_Service__c.Status__c, STATUS_ACTIVE)
                    .setField(Merchant_Service__c.Mx_Agreed_to_Product__c, 'Yes')
                }
            )
            .toSObject();

        Static_Configurations__mdt maxStoresConfiguration = new Static_Configurations__mdt(
            DeveloperName = COO_GET_STORE_API_MAX_STORE_NUMBER,
            MasterLabel = COO_GET_STORE_API_MAX_STORE_NUMBER,
            Configuration_Value__c = '10'
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        IXrefsSelector mockXrefSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IAccountsSelector mockAccountSelector = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        IStaticConfigurationsSelector mockStaticConfigurationsSelector = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );

        mocks.startStubbing();
        mocks.when(mockXrefSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(mockXrefSelector.selectXrefByExternalIdOnly(new List<String>{externalId1}))
            .thenReturn(new List<XRef__c>{ xref });

        mocks.when(mockAccountSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(mockAccountSelector.selectRelatedChildsById(new Set<Id>{ storeAccount.Id }))
            .thenReturn(new List<Account>{ storeAccount });
        mocks.when(mockAccountSelector.selectRelatedChildsById(new Set<Id>{ businessAccount.Id}))
                .thenReturn(new List<Account>{ businessAccount });
        mocks.when(mockStaticConfigurationsSelector.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    COO_GET_STORE_API_MAX_STORE_NUMBER
                )
            )
            .thenReturn(maxStoresConfiguration);
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockXrefSelector);
        Application.SELECTOR.setMock(mockAccountSelector);
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);

        String responseJSON = GetStoreAPI.getRecords(externalId1);
        System.assertNotEquals(null, responseJSON, ASSERT_MESSAGE_NULL_RESPONSE_NOT_EXPECTED);
        System.assertEquals(true, responseJSON.contains(externalId1), ASSERT_MESSAGE_STORE_EXPECTED);
    }


    /**
     * @description This tests the scenario where a store has multiple XRef__c records, for both
     *              Franchise and Corporate Default Types. The expected behavior is that Business
     *              References for both Corporate and Franchise types will be matched and populated
     *              in the defaultCorporateBusinessId and defaultFranchiseBusinessId
     */
    @isTest
    private static void testWhenGetStoreWithMultipleXRefsThenReturnAppropriateBusinessIds() {
        Id storeAccountId = Fake.generateId(Account.class);
        Id businessAccountId = Fake.generateId(Account.class);
        String externalId1 = '1234567';
        String externalId2 = '2345678';
        String businessId1 = '1111111111';
        String businessId2 = '2222222222';
        Id xrefId1 = Fake.generateId(Xref__c.class);
        Id xrefId2 = Fake.generateId(Xref__c.class);
        Id businessReferenceId1 = Fake.generateId(Business_Reference__c.class);
        Id brandId = Fake.generateId(Brand__c.class);
        String brandName = 'Test Brand';

        Xref__c xref = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Salesforce_Account_Name__c, storeAccountId)
            .setField(Xref__c.External_ID__c, externalId1)
            .setParent(
                    'Business_Reference__r',
                    new Fake(Business_Reference__c.class)
                    .setField(Business_Reference__c.Id, businessReferenceId1)
                    .setField(Business_Reference__c.Default_Type__c, FRANCHISE)
                    .setField(Business_Reference__c.CurrencyIsoCode, 'USD')
            )
            .toSObject();

        Brand__c brand = (Brand__c) new Fake(Brand__c.class)
            .setField(Brand__c.Name, brandName)
            .setField(Brand__c.Id, brandId)
            .toSObject();
        Account businessAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, businessAccountId)
            .toSObject();

        Account storeAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, storeAccountId)
            .setField(Account.BillingCountryCode, COUNTRY_US)
            .setField(Account.Type, FRANCHISE)
            .setField(Account.Legal_Business_Name__c, 'Legal Name')
            .setField(Account.Merchant_Supplied_ID__c, '1928983')
            .setField(Account.Segment__c, ENTERPRISE)
            .setField(Account.Primary_Vertical__c, VERTICAL)
            .setField(Account.Address_Id__c, '11223344')
            .setField(Account.Alcohol_Addendum_Signed__c, false)
            .setField(Account.Menu_UI_Type__c, MENU_UI_RETAIL)
            .setField(Account.ParentId, businessAccountId)
            .setField(Account.Brand__c, brand.Id)
            .setField(Account.BillingCountryCode, 'US')
            .setChildren(
                'Xrefs__r',
                new List<Fake>{
                    new Fake(Xref__c.class)
                        .setField(Xref__c.Salesforce_Account_Name__c, storeAccountId)
                        .setField(Xref__c.External_ID__c, externalId1)
                        .setField(Xref__c.External_ID_Source__c, EXTERNAL_ID_SOURCE_MDS)
                        .setField(Xref__c.Id, xrefId1),
                    new Fake(Xref__c.class)
                        .setField(Xref__c.Salesforce_Account_Name__c, storeAccountId)
                        .setField(Xref__c.External_ID__c, externalId2)
                        .setField(Xref__c.External_ID_Source__c, EXTERNAL_ID_SOURCE_MDS)
                        .setField(Xref__c.Id, xrefId2)
                }
            )
            .setParent(
                'Brand__r',
                new Fake(Brand__c.class)
                .setField(Brand__c.Id, brandId)
                .setField(Brand__c.Name, brandName)
            )
            .toSObject();

        //Added External_Id_Source__c & Brand associations for the BizRefs as a part of LEM-16588
        Business_Reference__c businessRef1 = (Business_Reference__c) new Fake(
                Business_Reference__c.class
            )
            .setField(Business_Reference__c.Menu_UI_Type__c, MENU_UI_RETAIL)
            .setField(Business_Reference__c.Primary_Vertical__c, VERTICAL)
            .setField(Business_Reference__c.Integration_Status__c, STATUS_SUCCESS)
            .setField(Business_Reference__c.Business_Name__c, brandName)
            .setField(Business_Reference__c.Default_Type__c, CORPORATE)
            .setField(Business_Reference__c.External_Id__c, businessId1)
            .setField(Business_Reference__c.CurrencyIsoCode, 'USD')
            .setField(Business_Reference__c.External_ID_Source__c, EXTERNAL_ID_SOURCE_MDS)
            .setField(Business_Reference__c.Brand__c, brand.Id)
            .setParent(
                'Brand__r',
                new Fake(Brand__c.class)
                .setField(Brand__c.Id, brandId)
                .setField(Brand__c.Name, brandName)
            )
            .setFakeId()
            .toSObject();

        Business_Reference__c businessRef2 = (Business_Reference__c) new Fake(
                Business_Reference__c.class
            )
            .setField(Business_Reference__c.Menu_UI_Type__c, MENU_UI_RETAIL)
            .setField(Business_Reference__c.Primary_Vertical__c, VERTICAL)
            .setField(Business_Reference__c.Integration_Status__c, STATUS_SUCCESS)
            .setField(Business_Reference__c.Business_Name__c, brandName)
            .setField(Business_Reference__c.Default_Type__c, FRANCHISE)
            .setField(Business_Reference__c.External_Id__c, businessId2)
            .setField(Business_Reference__c.CurrencyIsoCode, 'USD')
            .setField(Business_Reference__c.External_ID_Source__c, EXTERNAL_ID_SOURCE_MDS)
            .setField(Business_Reference__c.Brand__c, brand.Id)
            .setParent(
                'Brand__r',
                new Fake(Brand__c.class)
                .setField(Brand__c.Id, brandId)
                .setField(Brand__c.Name, brandName)
            )
            .setFakeId()
            .toSObject();
        Static_Configurations__mdt maxStoresConfiguration = new Static_Configurations__mdt(
            DeveloperName = COO_GET_STORE_API_MAX_STORE_NUMBER,
            MasterLabel = COO_GET_STORE_API_MAX_STORE_NUMBER,
            Configuration_Value__c = '10'
        );

        List<Country_Attributes_Mapping__mdt> countryAttributes = new List<Country_Attributes_Mapping__mdt>{
            new Country_Attributes_Mapping__mdt(
                MasterLabel = 'Canada',
                DeveloperName = 'Canada',
                Country__c = 'Canada',
                Currency__c = 'Canadian Dollar',
                Currency_Code__c = 'CAD',
                Country_Code__c = 'CA'
            ),
            new Country_Attributes_Mapping__mdt(
                MasterLabel = 'United States',
                DeveloperName = 'United States',
                Country__c = 'United States',
                Currency__c = 'United States dollar',
                Currency_Code__c = 'USD',
                Country_Code__c = 'US'
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        IXrefsSelector mockXrefSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IAccountsSelector mockAccountSelector = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        IBusinessReferencesSelector businessRefSelectorMock = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        IStaticConfigurationsSelector mockStaticConfigurationsSelector = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        ICountryAttributesMappingSelector mockCountryAttributeSelector = (ICountryAttributesMappingSelector) mocks.mock(
            ICountryAttributesMappingSelector.class
        );

        mocks.startStubbing();
        mocks.when(mockXrefSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(mockXrefSelector.selectXrefByExternalIdOnly(new List<String>{externalId1}))
            .thenReturn(new List<XRef__c>{ xref });
        Set<Id> storeIdSet = new Set<Id>{ storeAccount.Id };
        mocks.when(mockAccountSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(mockAccountSelector.selectRelatedChildsById(storeIdSet))
                .thenReturn(new List<Account>{ storeAccount });
        mocks.when(mockAccountSelector.selectRelatedChildsById(new Set<Id>{ businessAccount.Id}))
                .thenReturn(new List<Account>{ businessAccount });
        mocks.when(businessRefSelectorMock.sObjectType())
            .thenReturn(Business_Reference__c.SObjectType);
        mocks.when(
            businessRefSelectorMock.selectByBusRefNameAndIntegrationStatusAndDefaultType(
                new Set<String>{ storeAccount.Brand__r.Name },
                new Set<String>{ STATUS_SUCCESS },
                new Set<String>{ CORPORATE, FRANCHISE }
                )
            )
            .thenReturn(new List<Business_Reference__c>{ businessRef1, businessRef2 });
        mocks.when(mockStaticConfigurationsSelector.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    COO_GET_STORE_API_MAX_STORE_NUMBER
                )
            )
            .thenReturn(maxStoresConfiguration);
        mocks.when(mockCountryAttributeSelector.sObjectType())
            .thenReturn(Country_Attributes_Mapping__mdt.SObjectType);
        mocks.when(mockCountryAttributeSelector.getAllValues())
                .thenReturn(countryAttributes);
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockXrefSelector);
        Application.SELECTOR.setMock(mockAccountSelector);
        Application.SELECTOR.setMock(businessRefSelectorMock);
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        Application.SELECTOR.setMock(mockCountryAttributeSelector);

        String responseJSON = GetStoreAPI.getRecords(externalId1);
        System.assertNotEquals(null, responseJSON, ASSERT_MESSAGE_NULL_RESPONSE_NOT_EXPECTED);
        String defaultCorporateBusinessId = '"default_corporate_business_id" : "'+ businessId1 + '"';
        String defaultFranchiseBusinessId = '"default_franchise_business_id" : "'+ businessId2 + '"';
        System.assertEquals(true, responseJSON.contains(defaultCorporateBusinessId),
                            'Expecting defaultCorporateBusinessId to be populated with ' + businessId1);
        System.assertEquals(true, responseJSON.contains(defaultFranchiseBusinessId),
                            'Expecting defaultFranchiseBusinessId to be populated with ' + businessId2);

    }

    /**
     * @description For global accounts, this scenario tests when there are multiple Corporate and Franchise Business
     *              References in various countries. The correct one should be returned
     *              LEM-9796
     * @author Nathalie Mendezona
     * @date 2023-09-07
     */
    @isTest
    private static void testWhenGetStoreWithMultipleCountriesInBusinessReferencesThenReturnAppropriateBusinessIds() {
        Id storeAccountId = Fake.generateId(Account.class);
        Id businessAccountId = Fake.generateId(Account.class);
        String externalId1 = '1234567';
        String externalId2 = '2345678';
        String businessId1 = '1111111111';
        String businessId2 = '2222222222';
        String businessId3 = '3333333333';
        String businessId4 = '4444444444';
        Id xrefId1 = Fake.generateId(Xref__c.class);
        Id xrefId2 = Fake.generateId(Xref__c.class);
        Id businessReferenceId1 = Fake.generateId(Business_Reference__c.class);

        Id brandId = Fake.generateId(Brand__c.class);
        String brandName = 'Test Brand';

        Xref__c xref = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Salesforce_Account_Name__c, storeAccountId)
            .setField(Xref__c.External_ID__c, externalId1)
            .setParent(
                    'Business_Reference__r',
                    new Fake(Business_Reference__c.class)
                    .setField(Business_Reference__c.Id, businessReferenceId1)
                    .setField(Business_Reference__c.Default_Type__c, FRANCHISE)
                    .setField(Business_Reference__c.CurrencyIsoCode, 'CAD')
            )
            .toSObject();

        Brand__c brand = (Brand__c) new Fake(Brand__c.class)
            .setField(Brand__c.Name, brandName)
            .setField(Brand__c.Id, brandId)
            .toSObject();
        Account businessAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, businessAccountId)
            .toSObject();

        Account storeAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, storeAccountId)
            .setField(Account.BillingCountryCode, COUNTRY_US)
            .setField(Account.Type, FRANCHISE)
            .setField(Account.Legal_Business_Name__c, 'Legal Name')
            .setField(Account.Merchant_Supplied_ID__c, '1928983')
            .setField(Account.Segment__c, ENTERPRISE)
            .setField(Account.Primary_Vertical__c, VERTICAL)
            .setField(Account.Address_Id__c, '11223344')
            .setField(Account.Alcohol_Addendum_Signed__c, false)
            .setField(Account.Menu_UI_Type__c, MENU_UI_RETAIL)
            .setField(Account.ParentId, businessAccountId)
            .setField(Account.Brand__c, brand.Id)
            .setField(Account.BillingCountryCode, 'CA')
            .setChildren(
                'Xrefs__r',
                new List<Fake>{
                    new Fake(Xref__c.class)
                        .setField(Xref__c.Salesforce_Account_Name__c, storeAccountId)
                        .setField(Xref__c.External_ID__c, externalId1)
                        .setField(Xref__c.External_ID_Source__c, EXTERNAL_ID_SOURCE_MDS)
                        .setField(Xref__c.Id, xrefId1),
                    new Fake(Xref__c.class)
                        .setField(Xref__c.Salesforce_Account_Name__c, storeAccountId)
                        .setField(Xref__c.External_ID__c, externalId2)
                        .setField(Xref__c.External_ID_Source__c, EXTERNAL_ID_SOURCE_MDS)
                        .setField(Xref__c.Id, xrefId2)
                        .setField(XRef__c.BusinessID__c, businessId2)
                }
            )
            .setParent(
                'Brand__r',
                new Fake(Brand__c.class)
                .setField(Brand__c.Id, brandId)
                .setField(Brand__c.Name, brandName)
            )
            .toSObject();

        //Added External_Id_Source__c & Brand associations for the BizRefs as a part of LEM-16588
        List<Business_Reference__c> businessReferences = new List<Business_Reference__c> {
            (Business_Reference__c) new Fake(Business_Reference__c.class)
                .setField(Business_Reference__c.Menu_UI_Type__c, MENU_UI_RETAIL)
                .setField(Business_Reference__c.Primary_Vertical__c, VERTICAL)
                .setField(Business_Reference__c.Integration_Status__c, STATUS_SUCCESS)
                .setField(Business_Reference__c.Business_Name__c, brandName)
                .setField(Business_Reference__c.Default_Type__c, CORPORATE)
                .setField(Business_Reference__c.External_Id__c, businessId1)
                .setField(Business_Reference__c.CurrencyIsoCode, 'USD')
                .setField(Business_Reference__c.External_ID_Source__c, EXTERNAL_ID_SOURCE_MDS)
                .setField(Business_Reference__c.Brand__c, brand.Id)
                .setParent(
                    'Brand__r',
                    new Fake(Brand__c.class)
                    .setField(Brand__c.Id, brandId)
                    .setField(Brand__c.Name, brandName)
                )
                .setFakeId()
                .toSObject(),
            (Business_Reference__c) new Fake(Business_Reference__c.class)
                .setField(Business_Reference__c.Menu_UI_Type__c, MENU_UI_RETAIL)
                .setField(Business_Reference__c.Primary_Vertical__c, VERTICAL)
                .setField(Business_Reference__c.Integration_Status__c, STATUS_SUCCESS)
                .setField(Business_Reference__c.Business_Name__c, brandName)
                .setField(Business_Reference__c.Default_Type__c, FRANCHISE)
                .setField(Business_Reference__c.External_Id__c, businessId2)
                .setField(Business_Reference__c.CurrencyIsoCode, 'USD')
                .setField(Business_Reference__c.External_ID_Source__c, EXTERNAL_ID_SOURCE_MDS)
                .setField(Business_Reference__c.Brand__c, brand.Id)
                .setParent(
                    'Brand__r',
                    new Fake(Brand__c.class)
                    .setField(Brand__c.Id, brandId)
                    .setField(Brand__c.Name, brandName)
                )
                .setFakeId()
                .toSObject(),
            (Business_Reference__c) new Fake(Business_Reference__c.class)
                .setField(Business_Reference__c.Menu_UI_Type__c, MENU_UI_RETAIL)
                .setField(Business_Reference__c.Primary_Vertical__c, VERTICAL)
                .setField(Business_Reference__c.Integration_Status__c, STATUS_SUCCESS)
                .setField(Business_Reference__c.Business_Name__c, brandName)
                .setField(Business_Reference__c.Default_Type__c, CORPORATE)
                .setField(Business_Reference__c.External_Id__c, businessId3)
                .setField(Business_Reference__c.CurrencyIsoCode, 'CAD')
                .setField(Business_Reference__c.External_ID_Source__c, EXTERNAL_ID_SOURCE_MDS)
                .setField(Business_Reference__c.Brand__c, brand.Id)
                .setParent(
                    'Brand__r',
                    new Fake(Brand__c.class)
                    .setField(Brand__c.Id, brandId)
                    .setField(Brand__c.Name, brandName)
                )
                .setFakeId()
                .toSObject(),
            (Business_Reference__c) new Fake(Business_Reference__c.class)
                .setField(Business_Reference__c.Menu_UI_Type__c, MENU_UI_RETAIL)
                .setField(Business_Reference__c.Primary_Vertical__c, VERTICAL)
                .setField(Business_Reference__c.Integration_Status__c, STATUS_SUCCESS)
                .setField(Business_Reference__c.Business_Name__c, brandName)
                .setField(Business_Reference__c.Default_Type__c, FRANCHISE)
                .setField(Business_Reference__c.External_Id__c, businessId4)
                .setField(Business_Reference__c.CurrencyIsoCode, 'CAD')
                .setField(Business_Reference__c.External_ID_Source__c, EXTERNAL_ID_SOURCE_MDS)
                .setField(Business_Reference__c.Brand__c, brand.Id)
                .setParent(
                    'Brand__r',
                    new Fake(Brand__c.class)
                    .setField(Brand__c.Id, brandId)
                    .setField(Brand__c.Name, brandName)
                )
                .setFakeId()
                .toSObject()
        };
        Static_Configurations__mdt maxStoresConfiguration = new Static_Configurations__mdt(
            DeveloperName = COO_GET_STORE_API_MAX_STORE_NUMBER,
            MasterLabel = COO_GET_STORE_API_MAX_STORE_NUMBER,
            Configuration_Value__c = '10'
        );

        List<Country_Attributes_Mapping__mdt> countryAttributes = new List<Country_Attributes_Mapping__mdt>{
            new Country_Attributes_Mapping__mdt(
                MasterLabel = 'Canada',
                DeveloperName = 'Canada',
                Country__c = 'Canada',
                Currency__c = 'Canadian Dollar',
                Currency_Code__c = 'CAD',
                Country_Code__c = 'CA'
            ),
            new Country_Attributes_Mapping__mdt(
                MasterLabel = 'United States',
                DeveloperName = 'United States',
                Country__c = 'United States',
                Currency__c = 'United States dollar',
                Currency_Code__c = 'USD',
                Country_Code__c = 'US'
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        IXrefsSelector mockXrefSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IAccountsSelector mockAccountSelector = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        IBusinessReferencesSelector businessRefSelectorMock = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        IStaticConfigurationsSelector mockStaticConfigurationsSelector = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        ICountryAttributesMappingSelector mockCountryAttributeSelector = (ICountryAttributesMappingSelector) mocks.mock(
            ICountryAttributesMappingSelector.class
        );

        mocks.startStubbing();
        mocks.when(mockXrefSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(mockXrefSelector.selectXrefByExternalIdOnly(new List<String>{externalId1}))
            .thenReturn(new List<XRef__c>{ xref });
        Set<Id> storeIdSet = new Set<Id>{ storeAccount.Id };
        mocks.when(mockAccountSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(mockAccountSelector.selectRelatedChildsById(storeIdSet))
                .thenReturn(new List<Account>{ storeAccount });
        mocks.when(mockAccountSelector.selectRelatedChildsById(new Set<Id>{ businessAccount.Id}))
                .thenReturn(new List<Account>{ businessAccount });
        mocks.when(businessRefSelectorMock.sObjectType())
            .thenReturn(Business_Reference__c.SObjectType);
        mocks.when(
            businessRefSelectorMock.selectByBusRefNameAndIntegrationStatusAndDefaultType(
                new Set<String>{ storeAccount.Brand__r.Name },
                new Set<String>{ STATUS_SUCCESS },
                new Set<String>{ CORPORATE, FRANCHISE }
                )
            )
            .thenReturn(businessReferences);
        mocks.when(mockStaticConfigurationsSelector.sObjectType()).thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    COO_GET_STORE_API_MAX_STORE_NUMBER
                )
            )
            .thenReturn(maxStoresConfiguration);
        mocks.when(mockCountryAttributeSelector.sObjectType()).thenReturn(Country_Attributes_Mapping__mdt.SObjectType);
        mocks.when(mockCountryAttributeSelector.getAllValues()).thenReturn(countryAttributes);
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockXrefSelector);
        Application.SELECTOR.setMock(mockAccountSelector);
        Application.SELECTOR.setMock(businessRefSelectorMock);
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        Application.SELECTOR.setMock(mockCountryAttributeSelector);

        String responseJSON = GetStoreAPI.getRecords(externalId1);
        System.assertNotEquals(null, responseJSON, ASSERT_MESSAGE_NULL_RESPONSE_NOT_EXPECTED);
        String defaultCorporateBusinessId = '"default_corporate_business_id" : "'+ businessId3 + '"';
        String defaultFranchiseBusinessId = '"default_franchise_business_id" : "'+ businessId4 + '"';
        System.assertEquals(true, responseJSON.contains(defaultCorporateBusinessId),
                            'Expecting defaultCorporateBusinessId to be populated with ' + businessId3);
        System.assertEquals(true, responseJSON.contains(defaultFranchiseBusinessId),
                            'Expecting defaultFranchiseBusinessId to be populated with ' + businessId4);

    }

    @isTest
    private static void testWhenStoreWithOpenCOOsThenReturnCOOList() {
        Id storeAccountId = Fake.generateId(Account.class);
        Id businessAccountId = Fake.generateId(Account.class);
        String externalId1 = '1234567';
        String externalId2 = '2345678';
        Id xrefId1 = Fake.generateId(Xref__c.class);
        Id xrefId2 = Fake.generateId(Xref__c.class);
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
        Id contractId = Fake.generateId(Contract.class);
        Id mxServiceId = Fake.generateId(Merchant_Service__c.class);
        Id irId = Fake.generateId(Integration_Request__c.class);
        Id woId = Fake.generateId(WorkOrder.class);

        Xref__c xref = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.Salesforce_Account_Name__c, storeAccountId)
            .setField(Xref__c.External_ID__c, externalId1)
            .setField(Xref__c.External_ID_Source__c, EXTERNAL_ID_SOURCE_MDS)
            .setField(Xref__c.Id, xrefId1)
            .toSObject();

        Account businessAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, businessAccountId)
            .setField(Account.BillingCountryCode, 'US')
            .toSObject();

        Account storeAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, storeAccountId)
            .setField(Account.BillingCountryCode, COUNTRY_US)
            .setField(Account.Type, FRANCHISE)
            .setField(Account.Legal_Business_Name__c, 'Legal Name')
            .setField(Account.Merchant_Supplied_ID__c, '1928983')
            .setField(Account.Segment__c, ENTERPRISE)
            .setField(Account.Primary_Vertical__c, VERTICAL)
            .setField(Account.Address_Id__c, '11223344')
            .setField(Account.Alcohol_Addendum_Signed__c, false)
            .setField(Account.Menu_UI_Type__c, MENU_UI_RETAIL)
            .setField(Account.ParentId, businessAccountId)
            .setField(Account.BillingCountryCode, 'US')
            .setParent('Parent', new Fake(Account.class)
                        .setField(Account.Id, businessAccountId)
                        .setField(Account.Type, CORPORATE)
                        .setField(Account.BillingCountryCode, 'US')
                      )
            .setChildren(
                'Contacts',
                new List<Fake> {
                    new Fake(Contact.class)
                        .setField(Contact.LastName, CONTACT_LASTNAME)
                        .setField(Contact.FirstName, CONTACT_FIRSTNAME)
                        .setField(Contact.Email, CONTACT_EMAIL)
                        .setField(Contact.AccountId, storeAccountId)
                        .setField(Contact.Id, contactId)
                    }
                )
            .setChildren(
                'AccountContactRelations',
                new List<Fake>{
                    new Fake(AccountContactRelation.class)
                        .setField(AccountContactRelation.AccountId, storeAccountId)
                        .setField(AccountContactRelation.Account_Record_Type__c, ACCOUNT_RECORD_TYPE_NAME_STORE)
                        .setField(AccountContactRelation.ContactId, contactId)
                        .setField(AccountContactRelation.Roles, DECISION_MAKER_CONTACT)
                        .setParent(
                            'Contact',
                            new Fake(Contact.class)
                                .setField(Contact.Id, contactId)
                                .setField(Contact.Phone, null)
                        )
                        .setParent(
                            'Account',
                            new Fake(Account.class)
                            .setField(Account.Id, storeAccountId)
                        )
                }
            )
            .setChildren(
                'Xrefs__r',
                new List<Fake>{
                    new Fake(Xref__c.class)
                        .setField(Xref__c.Salesforce_Account_Name__c, storeAccountId)
                        .setField(Xref__c.External_ID__c, externalId1)
                        .setField(Xref__c.External_ID_Source__c, EXTERNAL_ID_SOURCE_MDS)
                        .setField(Xref__c.Id, xrefId1),
                    new Fake(Xref__c.class)
                        .setField(Xref__c.Salesforce_Account_Name__c, storeAccountId)
                        .setField(Xref__c.External_ID__c, externalId2)
                        .setField(Xref__c.External_ID_Source__c, EXTERNAL_ID_SOURCE_MDS)
                        .setField(Xref__c.Id, xrefId2)
                }
            )
            .setChildren(
                'Contracts',
                new List<Fake>{
                    new Fake(Contract.class)
                    .setField(Contract.Contract_Type__c, CONTRACT_TYPE_MARKETPLACE)
                    .setField(Contract.Name, 'Contract1')
                    .setField(Contract.Id, contractId)
                    .setField(Contract.Status, STATUS_ACTIVE)
                    .setField(Contract.StartDate, Date.newInstance(2023, 1, 30))
                    .setParent(
                        'Account',
                        new Fake(Account.class)
                            .setField(Account.Id, storeAccountId)
                    )
                }
            )
            .setChildren(
                'Agreements__r',
                new List<Fake>{
                    new Fake(Agreement__c.class)
                    .setField(Agreement__c.Account__c, storeAccountId)
                    .setField(Agreement__c.Contract__c, contractId)
                    .setParent(
                        'Contract__r',
                        new Fake(Contract.class)
                            .setField(Contract.Contract_Type__c, CONTRACT_TYPE_MARKETPLACE)
                            .setField(Contract.Name, 'Contract2')
                            .setField(Contract.Id, contractId)
                            .setField(Contract.Status, STATUS_ACTIVE)
                            .setField(Contract.StartDate, Date.newInstance(2023, 1, 30))
                    )
                }
            )
            .setChildren(
                'Services__r',
                new List<Fake>{
                    new Fake(Merchant_Service__c.class)
                    .setField(Merchant_Service__c.Id, mxServiceId)
                    .setField(Merchant_Service__c.Status__c, STATUS_ACTIVE)
                    .setField(Merchant_Service__c.Mx_Agreed_to_Product__c, 'Yes')
                }
            )
            .setChildren(
                'Integration_Requests__r',
                new List<Fake>{
                    new Fake(Integration_Request__c.class)
                    .setField(Integration_Request__c.Id, irId)
                    .setField(Integration_Request__c.Activation_Date__c, system.today())
                    .setField(Integration_Request__c.Integration_Type__c, 'COO Same Store')
                    .setField(Integration_Request__c.Sfdc_Org__c, 'Lemonade')
                    .setField(Integration_Request__c.Stage_Status__c, '')
                    .setParent(
                        'Account__r',
                        new Fake(Account.class)
                            .setField(Account.Id, storeAccountId)
                    )
                }
            )
            .setChildren(
                'WorkOrders',
                new List<Fake>{
                    new Fake(WorkOrder.class)
                    .setField(WorkOrder.Id, woId)
                    .setField(WorkOrder.Type__c, 'COO')
                    .setParent(
                        'Account',
                        new Fake(Account.class)
                            .setField(Account.Id, storeAccountId)
                            .setField(Account.Change_of_Ownership_Effective_Date__c, system.today())
                    )
                }
            )
            .toSObject();

        Static_Configurations__mdt maxStoresConfiguration = new Static_Configurations__mdt(
            DeveloperName = COO_GET_STORE_API_MAX_STORE_NUMBER,
            MasterLabel = COO_GET_STORE_API_MAX_STORE_NUMBER,
            Configuration_Value__c = '10'
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        IXrefsSelector mockXrefSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        IAccountsSelector mockAccountSelector = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        IStaticConfigurationsSelector mockStaticConfigurationsSelector = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        IIntegrationRequestsSelector irSelector = (IIntegrationRequestsSelector) mocks.mock(
            IIntegrationRequestsSelector.class
        );

        mocks.startStubbing();
        mocks.when(mockXrefSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(mockXrefSelector.selectXrefByExternalIdOnly(new List<String>{externalId1}))
            .thenReturn(new List<XRef__c>{ xref });
            mocks.when(irSelector.sObjectType()).thenReturn(Integration_Request__c.SObjectType);

        mocks.when(mockAccountSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(mockAccountSelector.selectRelatedChildsById(new Set<Id>{ storeAccount.Id }))
            .thenReturn(new List<Account>{ storeAccount });
        mocks.when(mockAccountSelector.selectRelatedChildsById(new Set<Id>{ businessAccount.Id}))
                .thenReturn(new List<Account>{ businessAccount });
        mocks.when(mockStaticConfigurationsSelector.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                mockStaticConfigurationsSelector.getInstanceValue(
                    COO_GET_STORE_API_MAX_STORE_NUMBER
                )
            )
            .thenReturn(maxStoresConfiguration);
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockXrefSelector);
        Application.SELECTOR.setMock(irSelector);
        Application.SELECTOR.setMock(mockAccountSelector);
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);

        String responseJSON = GetStoreAPI.getRecords(externalId1);
        System.assertNotEquals(null, responseJSON, ASSERT_MESSAGE_NULL_RESPONSE_NOT_EXPECTED);
        System.assertEquals(true, responseJSON.contains(externalId1), ASSERT_MESSAGE_STORE_EXPECTED);
        System.assertEquals(true, responseJSON.contains(irId), ASSERT_MESSAGE_COO_EXPECTED);
        System.assertEquals(true, responseJSON.contains(woId), ASSERT_MESSAGE_COO_EXPECTED);
    }
}