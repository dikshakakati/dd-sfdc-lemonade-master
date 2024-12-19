/**
* @author Aethereus
* @date 03/14/2023
* @description This is a test class created for CreateBrandAndBusinessIdController class.
*/
@isTest(SeeAllData=false)
private class CreateBrandAndBusinessIdControllerTest {
    private static final String ERROR_MESSAGE = 'Unexpected Error: Values do not match.';
    private static final String ACCOUNT_TYPE_CORPORATE = 'Corporate';
    private static final String DRIVE_WITH_MPBZID_YES = 'Yes';
    private static final String EXTERNAL_ID_DWH = '123456';
    private static final String EXTERNAL_ID_SOURCE_DRIVE = 'MDS';
    private static final String ACCOUNT_TYPE_FRANCHISEE = 'Franchisee';
    private static final String LICENSOR = 'Licensor';
    private static final String LICENSEE = 'Licensee';
    private static final String BUSINESS_VERTICAL_NAME = 'Business Vertical 1';
    private static final String DRIVE_DB = 'DriveDb';
    private static final String EMPTY_LIST_ASSERT_MESSAGE = 'Unexpected Result: Number of records returned does not match the expected outcome.';
    private static final String FIELDS_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected Result: Mismatch in field list.';
    private static final String MDS = 'MDS';
    private static final String MENU_UI_TYPE_RETAIL = 'Retail';
    private static final String OBJECT_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: The object type must be Business_Vertical__c.';
    private static final String PRIMARY_VERTICAL_ALCOHOL = 'Alcohol';
    private static final String PRODUCT_MARKETPLACE = 'Marketplace';
    private static final String VERTICAL_NAME = 'misc_retail_ui';
    private static final String RX_PRIMARY_VERTICAL = 'Rx';
    private static final String RESTAURANT ='Restaurant';
    private static final String REQUEST_STATUS_IN_PROGRESS ='In Progress';
    private static final String REQUEST_STAGE_IN_FLOW_INITIATED ='Flow Initiated';
    private static final String OPPORTUNITY_OBJ ='Opportunity';
    private static final String CONTRACT_OBJ ='Contract';
    private static final String STATUS_ACTIVATED = 'Activated';
    private static final String BUSINESS_REFERENCE_CURRENCY = 'USD';
    private static final String BUSINESS_REFERENCE_DEFAULT_TYPE = 'Corporate';




    private static final Id STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Store')
        .getRecordTypeId();
    private static final Id BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Business')
        .getRecordTypeId();

/**
* @description test method for unique reference check
*/
    @isTest
    private static void testWhenGetcheckIfBusinessReferenceUniqueCalledThenReturnMapWithDuplicateErrors() {
        Id storeAccountId = Fake.generateId(Account.class);
        Id franchiseAccountId = Fake.generateId(Account.class);
        Id parentAccountId = Fake.generateId(Account.class);

        Account newAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, storeAccountId)
            .setField(Account.Name, 'Mc Donald')
            .setField(Account.RecordTypeId, STORE_RECORD_TYPE_ID)
            .setField(Account.Franchise_Parent__c, franchiseAccountId)
            .setField(Account.ParentId, parentAccountId)
            .toSObject();

        Brand__c brand = (Brand__c) new Fake(Brand__c.class)
            .setField(Brand__c.Name, 'Pop tates')
            .setField(Brand__c.Brand_Owner__c, newAccount.Id)
            .setFakeId()
            .toSObject();

        Business_Vertical__c businessVertical = (Business_Vertical__c) new Fake(
                Business_Vertical__c.class
            )
            .setField(Business_Vertical__c.Name, BUSINESS_VERTICAL_NAME)
            .setField(Business_Vertical__c.Primary_Vertical__c, PRIMARY_VERTICAL_ALCOHOL)
            .setField(Business_Vertical__c.Menu_UI_Type__c, MENU_UI_TYPE_RETAIL)
            .setField(Business_Vertical__c.Product__c, PRODUCT_MARKETPLACE)
            .setField(Business_Vertical__c.Vertical_Name__c, VERTICAL_NAME)
            .setField(Business_Vertical__c.Active__c, true)
            .setFakeId()
            .toSObject();

        List<Business_Reference__c> businessReferenceList = new List<Business_Reference__c>{
            new Business_Reference__c(
                CurrencyIsoCode = BUSINESS_REFERENCE_CURRENCY,
                External_Id_Source__c = EXTERNAL_ID_SOURCE_DRIVE,
                Business_Vertical__c = businessVertical.Id,
                Brand__c = brand.Id,
                Business_Name__c = 'Test',
                Default_Type__c = BUSINESS_REFERENCE_DEFAULT_TYPE
            )
        };
        String jsonString = '[{"Business_Name__c":"Test","Business_Vertical__c":"'+businessVertical.Id+'","CurrencyIsoCode":"USD","Brand__c":"'+brand.Id +'","Default_Type__c":"Corporate","Integration_Status__c":"Ready For Integration","External_Id_Source__c":"MDS"}]';
        List<Business_Reference__c> brefList = (List<Business_Reference__c>) JSON.deserialize(jsonString, List<Business_Reference__c>.class);

       	String key = (String) businessVertical.Id+brand.Id+BUSINESS_REFERENCE_CURRENCY+EXTERNAL_ID_SOURCE_DRIVE+BUSINESS_REFERENCE_DEFAULT_TYPE;

            fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBusinessReferencesSelector businessReferenceSelectorMock = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );

        mocks.startStubbing();
        mocks.when(businessReferenceSelectorMock.sObjectType()).thenReturn(Business_Reference__c.SObjectType);
        mocks.when(businessReferenceSelectorMock.selectByBusinessReferenceUniqueIdentifierFields(brefList))
           .thenReturn(businessReferenceList);

        mocks.stopStubbing();
        Application.SELECTOR.setMock(businessReferenceSelectorMock);

        Test.startTest();

        Map<String,String> brefKeyToErroMapping = CreateBrandAndBusinessIdController.checkIfBusinessReferenceUnique(
           jsonString
        );
        Test.stopTest();
        System.assertEquals('This combination is already present in Database', brefKeyToErroMapping.get(key), ERROR_MESSAGE);

    }

 /**
* @description test method for unique reference check
*/
    @isTest
    private static void testWhenGetcheckIfBusinessReferenceUniqueCalledThenReturnMapWithDuplicateAndDatabaseError() {
        Id storeAccountId = Fake.generateId(Account.class);
        Id franchiseAccountId = Fake.generateId(Account.class);
        Id parentAccountId = Fake.generateId(Account.class);

        Account newAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, storeAccountId)
            .setField(Account.Name, 'Mc Donald')
            .setField(Account.RecordTypeId, STORE_RECORD_TYPE_ID)
            .setField(Account.Franchise_Parent__c, franchiseAccountId)
            .setField(Account.ParentId, parentAccountId)
            .toSObject();

        Brand__c brand = (Brand__c) new Fake(Brand__c.class)
            .setField(Brand__c.Name, 'Pop tates')
            .setField(Brand__c.Brand_Owner__c, newAccount.Id)
            .setFakeId()
            .toSObject();

        Business_Vertical__c businessVertical = (Business_Vertical__c) new Fake(
                Business_Vertical__c.class
            )
            .setField(Business_Vertical__c.Name, BUSINESS_VERTICAL_NAME)
            .setField(Business_Vertical__c.Primary_Vertical__c, PRIMARY_VERTICAL_ALCOHOL)
            .setField(Business_Vertical__c.Menu_UI_Type__c, MENU_UI_TYPE_RETAIL)
            .setField(Business_Vertical__c.Product__c, PRODUCT_MARKETPLACE)
            .setField(Business_Vertical__c.Vertical_Name__c, VERTICAL_NAME)
            .setField(Business_Vertical__c.Active__c, true)
            .setFakeId()
            .toSObject();

        List<Business_Reference__c> businessReferenceList = new List<Business_Reference__c>{
            new Business_Reference__c(
                CurrencyIsoCode = BUSINESS_REFERENCE_CURRENCY,
                External_Id_Source__c = EXTERNAL_ID_SOURCE_DRIVE,
                Business_Vertical__c = businessVertical.Id,
                Brand__c = brand.Id,
                Business_Name__c = 'Test',
                Default_Type__c = BUSINESS_REFERENCE_DEFAULT_TYPE
            )
        };
        String jsonString = '[{"Business_Name__c":"Test","Business_Vertical__c":"'+businessVertical.Id+'","CurrencyIsoCode":"USD","Brand__c":"'+brand.Id +'","Default_Type__c":"Corporate","Integration_Status__c":"Ready For Integration","External_Id_Source__c":"MDS"},{"Business_Name__c":"Test Duplicate","Business_Vertical__c":"'+businessVertical.Id+'","CurrencyIsoCode":"USD","Brand__c":"'+brand.Id +'","Default_Type__c":"Corporate","Integration_Status__c":"Ready For Integration","External_Id_Source__c":"MDS"}]';
        List<Business_Reference__c> brefList = (List<Business_Reference__c>) JSON.deserialize(jsonString, List<Business_Reference__c>.class);

       	String key = (String) businessVertical.Id+brand.Id+BUSINESS_REFERENCE_CURRENCY+EXTERNAL_ID_SOURCE_DRIVE+BUSINESS_REFERENCE_DEFAULT_TYPE;
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBusinessReferencesSelector businessReferenceSelectorMock = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );

        mocks.startStubbing();
        mocks.when(businessReferenceSelectorMock.sObjectType()).thenReturn(Business_Reference__c.SObjectType);
        mocks.when(businessReferenceSelectorMock.selectByBusinessReferenceUniqueIdentifierFields(brefList))
           .thenReturn(businessReferenceList);

        mocks.stopStubbing();
        Application.SELECTOR.setMock(businessReferenceSelectorMock);

        Test.startTest();

        Map<String,String> brefKeyToErroMapping = CreateBrandAndBusinessIdController.checkIfBusinessReferenceUnique(
           jsonString
        );
        Test.stopTest();
        System.assertEquals('You have already entered this combination & This combination is already present in Database', brefKeyToErroMapping.get(key), ERROR_MESSAGE);

    }


    /**
* @description test method to ValidateBrand
*/
    @isTest
    private static void testWhenValidateBrandCalledThenReturnBrandsMatchingWithName() {
        Id storeAccountId = Fake.generateId(Account.class);
        Id franchiseAccountId = Fake.generateId(Account.class);
        Id parentAccountId = Fake.generateId(Account.class);

        Account newAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, storeAccountId)
            .setField(Account.Name, 'Mc Donald')
            .setField(Account.RecordTypeId, STORE_RECORD_TYPE_ID)
            .setField(Account.Franchise_Parent__c, franchiseAccountId)
            .setField(Account.ParentId, parentAccountId)
            .toSObject();

        List<Brand__c> brandList = new List<Brand__c>();

        Brand__c brand = (Brand__c) new Fake(Brand__c.class)
            .setField(Brand__c.Name, 'Pop tates')
            .setField(Brand__c.Brand_Owner__c, newAccount.Id)
            .setFakeId()
            .toSObject();
        brandList.add(brand);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBrandsSelector brandSelectoreMock = (IBrandsSelector) mocks.mock(
            IBrandsSelector.class
        );

        List<String> brandNames = new List<String>{'Pop tates'};
            mocks.startStubbing();
        mocks.when(brandSelectoreMock.sObjectType()).thenReturn(Brand__c.SObjectType);
        mocks.when(brandSelectoreMock.getBrandsByBrandName(brandNames))
            .thenReturn(brandList);

        mocks.stopStubbing();
        Application.SELECTOR.setMock(brandSelectoreMock);
        List<Brand__c> brandsList = CreateBrandAndBusinessIdController.validateBrands(brandNames);
        System.assertEquals(1, brandsList.size(), ERROR_MESSAGE);

    }

    /**
* @description test validate brand Name
*/
    @isTest
    private static void testWhenCalledThenNotReturnBrandsWhenNameNotMatched() {
        Id storeAccountId = Fake.generateId(Account.class);
        Id franchiseAccountId = Fake.generateId(Account.class);
        Id parentAccountId = Fake.generateId(Account.class);

        Account newAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, storeAccountId)
            .setField(Account.Name, 'Mc Donald')
            .setField(Account.RecordTypeId, STORE_RECORD_TYPE_ID)
            .setField(Account.Franchise_Parent__c, franchiseAccountId)
            .setField(Account.ParentId, parentAccountId)
            .toSObject();

        List<Brand__c> brandList = new List<Brand__c>();
        List<Brand__c> emptyBrandList = new List<Brand__c>();

        Brand__c brand = (Brand__c) new Fake(Brand__c.class)
            .setField(Brand__c.Name, 'Pop tates')
            .setField(Brand__c.Brand_Owner__c, newAccount.Id)
            .setFakeId()
            .toSObject();
        brandList.add(brand);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBrandsSelector brandSelectoreMock = (IBrandsSelector) mocks.mock(
            IBrandsSelector.class
        );

        List<String> brandNames = new List<String>{'Mc D'};
            mocks.startStubbing();
        mocks.when(brandSelectoreMock.sObjectType()).thenReturn(Brand__c.SObjectType);
        mocks.when(brandSelectoreMock.getBrandsByBrandName (brandNames))
            .thenReturn(emptyBrandList);

        mocks.stopStubbing();
        Application.SELECTOR.setMock(brandSelectoreMock);
        List<Brand__c> brandsList = CreateBrandAndBusinessIdController.validateBrands(brandNames);
        System.assertEquals(0, brandsList.size(), ERROR_MESSAGE);

    }

    /**
* @description test method for fetchExistingAssociatedBrands
*/
    @isTest
    private static void testWhenFetchExistingAssociatedBrandsCalledThenReturnAssociatedBrands() {
        Id parentAccountId = Fake.generateId(Account.class);
        Brand__c brand = (Brand__c) new Fake(Brand__c.class)
            .setField(Brand__c.Name, 'KFC')
            .setFakeId()
            .toSObject();
        Account parentAccount = new Account(
            Id = parentAccountId,
            name = 'Mcdonald USA',
            RecordTypeId = BUSINESS_RECORD_TYPE_ID
        );
        List<Brand_Association__c> brandAssociationList = new List<Brand_Association__c>();
        Brand_Association__c brandAssociation = (Brand_Association__c) new Fake(
            Brand_Association__c.class
        )
            .setField(Brand_Association__c.Brand_Name__c, brand.Id)
            .setField(Brand_Association__c.Business_Account_Name__c, parentAccount.Id)
            .setFakeId()
            .toSObject();
        brandAssociationList.add(brandAssociation);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBrandAssociationsSelector brandAssociationsSelectorMock = (IBrandAssociationsSelector) mocks.mock(
            IBrandAssociationsSelector.class
        );

        mocks.startStubbing();
        mocks.when(brandAssociationsSelectorMock.sObjectType()).thenReturn(Brand_Association__c.SObjectType);
        mocks.when(brandAssociationsSelectorMock.selectBrandAssociationsByAccountIdAndIgnoringExternalSourceMds(parentAccount.Id))
            .thenReturn(brandAssociationList);

        mocks.stopStubbing();
        Application.SELECTOR.setMock(brandAssociationsSelectorMock);
        List<Brand_Association__c> returnedBrandAssociationList = CreateBrandAndBusinessIdController.fetchExistingAssociatedBrands(parentAccount.Id);
        System.assertEquals(1, returnedBrandAssociationList.size(), ERROR_MESSAGE);

}

     /**
* @description test method for fetchBGGroupIdsAssociatedWithAccount
*/
    @isTest
    private static void testWhenFetchBGGroupIdsCalledThenReturnAssociatedBizRefs() {
       Id storeAccountId = Fake.generateId(Account.class);
        Id franchiseAccountId = Fake.generateId(Account.class);
        Id parentAccountId = Fake.generateId(Account.class);

        Account newAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, storeAccountId)
            .setField(Account.Name, 'Mc Donald')
            .setField(Account.RecordTypeId, STORE_RECORD_TYPE_ID)
            .setField(Account.Franchise_Parent__c, franchiseAccountId)
            .setField(Account.ParentId, parentAccountId)
            .toSObject();

        Brand__c brand = (Brand__c) new Fake(Brand__c.class)
            .setField(Brand__c.Name, 'Pop tates')
            .setField(Brand__c.Brand_Owner__c, newAccount.Id)
            .setFakeId()
            .toSObject();

        Business_Vertical__c businessVertical = (Business_Vertical__c) new Fake(
                Business_Vertical__c.class
            )
            .setField(Business_Vertical__c.Name, BUSINESS_VERTICAL_NAME)
            .setField(Business_Vertical__c.Primary_Vertical__c, PRIMARY_VERTICAL_ALCOHOL)
            .setField(Business_Vertical__c.Menu_UI_Type__c, MENU_UI_TYPE_RETAIL)
            .setField(Business_Vertical__c.Product__c, PRODUCT_MARKETPLACE)
            .setField(Business_Vertical__c.Vertical_Name__c, VERTICAL_NAME)
            .setField(Business_Vertical__c.Active__c, true)
            .setFakeId()
            .toSObject();

        List<Business_Reference__c> businessReferenceList = new List<Business_Reference__c>{
            new Business_Reference__c(
                CurrencyIsoCode = BUSINESS_REFERENCE_CURRENCY,
                External_Id_Source__c = EXTERNAL_ID_SOURCE_DRIVE,
                Business_Vertical__c = businessVertical.Id,
                Brand__c = brand.Id,
                Business_Group_Id__c = '5674',
                Business_Name__c = 'Test',
                Default_Type__c = BUSINESS_REFERENCE_DEFAULT_TYPE
            )
        };


        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBusinessReferencesSelector businessReferenceSelectorMock = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );

        mocks.startStubbing();
        mocks.when(businessReferenceSelectorMock.sObjectType()).thenReturn(Business_Reference__c.SObjectType);
        mocks.when(businessReferenceSelectorMock.selectBGGroupIdByAccountId(parentAccountId))
            .thenReturn(businessReferenceList);

        mocks.stopStubbing();
        Application.SELECTOR.setMock(businessReferenceSelectorMock);
        List<Business_Reference__c> returnedBusinessReferenceList = CreateBrandAndBusinessIdController.fetchBGGroupIdsAssociatedWithAccount(parentAccountId);
        System.assertEquals(1, returnedBusinessReferenceList.size(), ERROR_MESSAGE);

    }


    /**
* @description test method for CreateBrand
*/
    @isTest
    private static void testWhenCreateBrandCalledThenReturnBrands(){
        Id parentAccountId = Fake.generateId(Account.class);

        Account parentAccount = new Account(
            Id = parentAccountId,
            name = 'Mcdonald USA',
            RecordTypeId = BUSINESS_RECORD_TYPE_ID
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        // Set up the Application class to use the mock UnitOfWork
        Application.UnitOfWork.setMock(mockUOW);
        Map<String,String> brandVsPriceRange = new Map<String,String>();
        brandVsPriceRange.put('Mac D','$');
        String brandVsPriceRangeJsonString =  JSON.serialize(brandVsPriceRange);

        // Act
        List<Brand__c> obr = CreateBrandAndBusinessIdController.insertBrands(brandVsPriceRangeJsonString, parentAccount.Id);

        // Assert
        System.assertNotEquals(null, obr,'Record not created');
        // Assert
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).registerNew(obr);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();

    }

    /**
* @description test method for CreateBrandAndBizRefs
*/
    @isTest
    private static void testWhenCreateBrandAndBizRefsCalledThenInsertBrandsWithRefs() {
        Id parentAccountId = Fake.generateId(Account.class);

          Business_Vertical__c businessVertical = (Business_Vertical__c) new Fake(
                Business_Vertical__c.class
            )
            .setField(Business_Vertical__c.Name, BUSINESS_VERTICAL_NAME)
            .setField(Business_Vertical__c.Primary_Vertical__c, PRIMARY_VERTICAL_ALCOHOL)
            .setField(Business_Vertical__c.Menu_UI_Type__c, MENU_UI_TYPE_RETAIL)
            .setField(Business_Vertical__c.Product__c, PRODUCT_MARKETPLACE)
            .setField(Business_Vertical__c.Vertical_Name__c, VERTICAL_NAME)
            .setField(Business_Vertical__c.Active__c, true)
            .setFakeId()
            .toSObject();

        Account parentAccount = new Account(
            Id = parentAccountId,
            name = 'Mcdonald USA',
            Segment__c ='Enterprise',
            BillingCountry = 'USA',
            RecordTypeId = BUSINESS_RECORD_TYPE_ID
        );

        Id opportunityId1 = fflib_IDGenerator.generate(Opportunity.SObjectType);
        List<Opportunity> opportunityRecords = new List<Opportunity>{
            new Opportunity(
                id = opportunityId1,
                Name = 'Test1',
                StageName = 'Pitching',
                Type = 'New',
                Accountid = parentAccount.Id,
                Probability = 30,
                Deal_Type__c = 'Standard',
                ForecastCategoryName = 'Pipeline',
                CloseDate = System.today().addDays(3)
            )
                };
                    List<Account> accountList = new List<Account>();
        accountList.add(parentAccount);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        // Set up the Application class to use the mock UnitOfWork
        String jsonString ='[{"brandName":"just one store","createBrandAssociations":true,"recordId":"'+opportunityRecords[0].Id+'","accountId":"'+parentAccount.ID+
            '","currencyOfAccount":"USD","bizRefList":[{"businessName":"biz ref234","businessVerticalId":"'+businessVertical.Id+'"}]}]';
        Set<String> queryFields = new Set<String> {'Id', 'Name', 'Owner.Name', 'Segment__c', 'Primary_Vertical__c', 'BillingCountry'};

        mocks.startStubbing();
        mocks.when(accountSelectorMock.SObjectType())
            .thenReturn(Account.SObjectType);
        mocks.when(
            accountSelectorMock.selectAccountWithOutFilterswithSetOfFieldsPassed(
                queryFields, new Set<Id>{parentAccount.Id})
        )
            .thenReturn(accountList);

        mocks.stopStubbing();

        Application.SELECTOR.setMock(accountSelectorMock);
        Application.UnitOfWork.setMock(mockUOW);
        BrandWrapper.CaseWithListOfBrandAndBizRefs wrapper = CreateBrandAndBusinessIdController.createBrandAndBizRefs(jsonString,true);
		System.assertNotEquals(null, wrapper,'wrapper is null');
        ((fflib_ISObjectUnitOfWork)mocks.verify(mockUOW,4)).commitwork();
    }

      /**
* @description test method for CreateBrandAndBizRefs
*/
    @isTest
    private static void testWhenCreateBrandAndBizRefsCalledFromContractThenInsertBrandsWithRefs() {
        Id parentAccountId = Fake.generateId(Account.class);

          Business_Vertical__c businessVertical = (Business_Vertical__c) new Fake(
                Business_Vertical__c.class
            )
            .setField(Business_Vertical__c.Name, BUSINESS_VERTICAL_NAME)
            .setField(Business_Vertical__c.Primary_Vertical__c, PRIMARY_VERTICAL_ALCOHOL)
            .setField(Business_Vertical__c.Menu_UI_Type__c, MENU_UI_TYPE_RETAIL)
            .setField(Business_Vertical__c.Product__c, PRODUCT_MARKETPLACE)
            .setField(Business_Vertical__c.Vertical_Name__c, VERTICAL_NAME)
            .setField(Business_Vertical__c.Active__c, true)
            .setFakeId()
            .toSObject();

        Account parentAccount = new Account(
            Id = parentAccountId,
            name = 'Mcdonald USA',
            Segment__c ='Enterprise',
            BillingCountry = 'USA',
            RecordTypeId = BUSINESS_RECORD_TYPE_ID
        );

        Id opportunityId1 = fflib_IDGenerator.generate(Opportunity.SObjectType);
        List<Opportunity> opportunityRecords = new List<Opportunity>{
            new Opportunity(
                id = opportunityId1,
                Name = 'Test1',
                StageName = 'Pitching',
                Type = 'New',
                Accountid = parentAccount.Id,
                Probability = 30,
                Deal_Type__c = 'Standard',
                ForecastCategoryName = 'Pipeline',
                CloseDate = System.today().addDays(3)
            )
                };
                    List<Account> accountList = new List<Account>();
        accountList.add(parentAccount);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        // Set up the Application class to use the mock UnitOfWork
        String jsonString ='[{"brandName":"just one store","createBrandAssociations":true,"relationShipType":"Licensee","opportunityId":"'+opportunityRecords[0].Id+'","accountId":"'+parentAccount.ID+
            '","currencyOfAccount":"USD","bizRefList":[{"businessName":"biz ref234","businessVerticalId":"'+businessVertical.Id+'"}]}]';
        Set<String> queryFields = new Set<String> {'Id', 'Name', 'Owner.Name', 'Segment__c', 'Primary_Vertical__c', 'BillingCountry'};

        mocks.startStubbing();
        mocks.when(accountSelectorMock.SObjectType())
            .thenReturn(Account.SObjectType);
        mocks.when(
            accountSelectorMock.selectAccountWithOutFilterswithSetOfFieldsPassed(
                queryFields, new Set<Id>{parentAccount.Id})
        )
            .thenReturn(accountList);

        mocks.stopStubbing();

        Application.SELECTOR.setMock(accountSelectorMock);
        Application.UnitOfWork.setMock(mockUOW);
        BrandWrapper.CaseWithListOfBrandAndBizRefs wrapper = CreateBrandAndBusinessIdController.createBrandAndBizRefs(jsonString,false);
		System.assertNotEquals(null, wrapper,'wrapper is null');


    }
/**
    * @description - test when exisiting brand is slelected from opportunity record which doesnt have a opportunity brand realtionship and business refernece details is enetered,
                     then businessReference is created , with Opportunity brand relationn ship record and case is also created
    * @author Soumya Dash | 05-22-2024
    **/
    @isTest
    private static void testWhenExisitingBrandIsSelectedAndCreateBrandAndBizMethodIsCalledThenOnlyBizRefIsCreatedAlongWithOpportunityBrandRelationship(){
        Id parentAccountId = Fake.generateId(Account.class);
        Account parentAccount = new Account(
            Id = parentAccountId,
            name ='KFC USA',
            RecordTypeId = BUSINESS_RECORD_TYPE_ID
        );
        List<Account> accountList = new List<Account>();
        accountList.add(parentAccount);


        List<Opportunity> opportunityRecord = new List<Opportunity>();
        Opportunity opp = (Opportunity)new Fake(Opportunity.class)
        .setField(Opportunity.Name,'Test1')
        .setField(Opportunity.StageName,'Pitching')
        .setField(Opportunity.Type,'New')
        .setField(Opportunity.Accountid,parentAccount.Id)
        .setField(Opportunity.Probability,30)
        .setField(Opportunity.ForecastCategoryName,'Pipeline')
        .setField(Opportunity.CloseDate,System.today().addDays(3))
        .setFakeId()
        .tosObject();
        opportunityRecord.add(opp);


        Brand__c brand = (Brand__c) new Fake(Brand__c.class)
        .setField(Brand__c.Name, 'KFC')
        .setFakeId()
        .toSObject();

        List<Brand_Association__c> brandAssociationList = new List<Brand_Association__c>();
        Brand_Association__c brandAssociation = (Brand_Association__c) new Fake(Brand_Association__c.class)
            .setField(Brand_Association__c.Brand_Name__c, brand.Id)
            .setField(Brand_Association__c.Business_Account_Name__c, parentAccount.Id)
            .setFakeId()
            .toSObject();
        brandAssociationList.add(brandAssociation);

        Business_Vertical__c businessVertical = (Business_Vertical__c) new Fake(Business_Vertical__c.class)
            .setField(Business_Vertical__c.Name, BUSINESS_VERTICAL_NAME)
            .setField(Business_Vertical__c.Primary_Vertical__c, PRIMARY_VERTICAL_ALCOHOL)
            .setField(Business_Vertical__c.Menu_UI_Type__c, MENU_UI_TYPE_RETAIL)
            .setField(Business_Vertical__c.Product__c, PRODUCT_MARKETPLACE)
            .setField(Business_Vertical__c.Vertical_Name__c, VERTICAL_NAME)
            .setField(Business_Vertical__c.Active__c, true)
            .setFakeId()
            .toSObject();

        String jsonString = '[{"brandId":"'+brand.Id+'","createBrandAssociations":false,"recordId":"'+opportunityRecord[0].Id+'","accountId":"'+parentAccount.ID+
        '","currencyOfAccount":"USD","bizRefList":[{"businessName":"biz ref234","businessVerticalId":"'+businessVertical.Id+'"}]}]';
        Set<String> queryFields = new Set<String> {'Id', 'Name', 'Owner.Name', 'Segment__c', 'Primary_Vertical__c', 'BillingCountry'};

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUow = (fflib_ISObjectUnitOfWork)mocks.mock(fflib_ISObjectUnitOfWork.class);
        IBrandAssociationsSelector mockBrandAssociationsSelector = (IBrandAssociationsSelector)mocks.mock(IBrandAssociationsSelector.class);
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        IOpportunityBrandRelationshipsSelector mockOpportunitySelector = (IOpportunityBrandRelationshipsSelector)mocks.mock(IOpportunityBrandRelationshipsSelector.class);

        mocks.startStubbing();
         mocks.when(accountSelectorMock.SObjectType())
           .thenReturn(Account.SObjectType);
         mocks.when(accountSelectorMock.selectAccountWithOutFilterswithSetOfFieldsPassed(queryFields, new Set<Id>{parentAccount.Id}))
           .thenReturn(accountList);
         mocks.when(mockBrandAssociationsSelector.sObjectType())
           .thenReturn(Brand_Association__c.sObjectType);
         mocks.when(mockBrandAssociationsSelector.selectByBrandsAndBusinessAccountIds(new set<Id>{brand.Id},new set<Id>{parentAccount.Id}))
            .thenReturn(brandAssociationList);
         mocks.when(mockOpportunitySelector.sObjectType())
            .thenReturn(Opportunity.sObjectType);
         mocks.when(mockOpportunitySelector.selectByOpportunityAndBrandAsscs(OpportunityRecord[0].Id,new set<Id>{brandAssociation.Id}))
            .thenReturn(new List<Opportunity_Brand_Relationship__c>());
        mocks.stopStubbing();

        Application.SELECTOR.setMock(mockBrandAssociationsSelector);
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(mockOpportunitySelector);
        Application.UNITOFWORK.setMock(mockUow);

        BrandWrapper.CaseWithListOfBrandAndBizRefs wrapper = CreateBrandAndBusinessIdController.createBrandAndBizRefs(jsonString,true);

        System.assertNotEquals(null, wrapper,'wrapper is null');
        ((fflib_ISObjectUnitOfWork)mocks.verify(mockUow,3)).commitWork();

    }


    /**
    * @description  - Test When exisiting brand is selected from contract and its contract brand association is not there then
                      business reference is created long with contract brand associaiton record.
    * @author Soumya Dash | 05-22-2024
    **/
    @isTest
    private static void testWhenCreateBrandAndBizRefIscalledWithExistingBrandAndFromContractThenBizRefAndContractBrandAssociationIsCreated(){
        Id parentAccountId = Fake.generateId(Account.class);
        Account parentAccount = new Account(
            Id = parentAccountId,
            name ='KFC USA',
            RecordTypeId = BUSINESS_RECORD_TYPE_ID
        );
        List<Account> accountList = new List<Account>();
        accountList.add(parentAccount);


        Contract contract = (Contract) new Fake(Contract.class)
                .setField(Contract.AccountId, parentAccount.ID)
                .setField(Contract.Status, STATUS_ACTIVATED)
                .setFakeId()
                .toSObject();


        Brand__c brand = (Brand__c) new Fake(Brand__c.class)
        .setField(Brand__c.Name, 'KFC')
        .setFakeId()
        .toSObject();

        List<Brand_Association__c> brandAssociationList = new List<Brand_Association__c>();
        Brand_Association__c brandAssociation = (Brand_Association__c) new Fake(Brand_Association__c.class)
            .setField(Brand_Association__c.Brand_Name__c, brand.Id)
            .setField(Brand_Association__c.Business_Account_Name__c, parentAccount.Id)
            .setFakeId()
            .toSObject();
        brandAssociationList.add(brandAssociation);

        Business_Vertical__c businessVertical = (Business_Vertical__c) new Fake(Business_Vertical__c.class)
            .setField(Business_Vertical__c.Name, BUSINESS_VERTICAL_NAME)
            .setField(Business_Vertical__c.Primary_Vertical__c, PRIMARY_VERTICAL_ALCOHOL)
            .setField(Business_Vertical__c.Menu_UI_Type__c, MENU_UI_TYPE_RETAIL)
            .setField(Business_Vertical__c.Product__c, PRODUCT_MARKETPLACE)
            .setField(Business_Vertical__c.Vertical_Name__c, VERTICAL_NAME)
            .setField(Business_Vertical__c.Active__c, true)
            .setFakeId()
            .toSObject();

        String jsonString = '[{"brandId":"'+brand.Id+'","createBrandAssociations":false,"recordId":"'+contract.Id+'","accountId":"'+parentAccount.ID+
        '","currencyOfAccount":"USD","bizRefList":[{"businessName":"biz ref234","businessVerticalId":"'+businessVertical.Id+'"}]}]';
        Set<String> queryFields = new Set<String> {'Id', 'Name', 'Owner.Name', 'Segment__c', 'Primary_Vertical__c', 'BillingCountry'};

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUow = (fflib_ISObjectUnitOfWork)mocks.mock(fflib_ISObjectUnitOfWork.class);
        IBrandAssociationsSelector mockBrandAssociationsSelector = (IBrandAssociationsSelector)mocks.mock(IBrandAssociationsSelector.class);
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        IContractBrandAssociationsSelector mockContractBrandSelector = (IContractBrandAssociationsSelector)mocks.mock(IContractBrandAssociationsSelector.class);

        mocks.startStubbing();
         mocks.when(accountSelectorMock.SObjectType())
           .thenReturn(Account.SObjectType);
         mocks.when(accountSelectorMock.selectAccountWithOutFilterswithSetOfFieldsPassed(queryFields, new Set<Id>{parentAccount.Id}))
           .thenReturn(accountList);
         mocks.when(mockBrandAssociationsSelector.sObjectType())
           .thenReturn(Brand_Association__c.sObjectType);
         mocks.when(mockBrandAssociationsSelector.selectByBrandsAndBusinessAccountIds(new set<Id>{brand.Id},new set<Id>{parentAccount.Id}))
            .thenReturn(brandAssociationList);
         mocks.when(mockContractBrandSelector.sObjectType())
            .thenReturn( Contract_Brand_Association__c.sObjectType);
         mocks.when(mockContractBrandSelector.selectByContractAndBrandAsscs(contract.Id,new set<Id>{brand.Id}))
            .thenReturn(new List<Contract_Brand_Association__c>());
        mocks.stopStubbing();

        Application.SELECTOR.setMock(mockBrandAssociationsSelector);
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(mockContractBrandSelector);
        Application.UNITOFWORK.setMock(mockUow);

        BrandWrapper.CaseWithListOfBrandAndBizRefs wrapper = CreateBrandAndBusinessIdController.createBrandAndBizRefs(jsonString,false);

        System.assertNotEquals(null, wrapper,'wrapper is null');
        ((fflib_ISObjectUnitOfWork)mocks.verify(mockUow,2)).commitWork();

    }










/**
* @description - Test When Existing Brand is selected from opportunity and its Opportunity Brand Realtionship record is present,
                 then the brand Association Id is removed from further processing
* @author Soumya Dash | 05-22-2024
**/
@isTest
private static void testWhenExisitngOpportunityBrandRelationshipIsAvilableThenRemoveItsBrandAssociationIdFromTheSet(){
    Id opportunityId = Fake.GenerateId(Opportunity.class);
    Id brandAssociationId1 = Fake.GenerateId(Brand_Association__c.class);
    Id brandAssociationId2 = Fake.GenerateId(Brand_Association__c.class);
    set<Id> brandAssociationIds = new set<Id>{brandAssociationId1,brandAssociationId2};

    Opportunity_Brand_Relationship__c obr = (Opportunity_Brand_Relationship__c)new Fake(Opportunity_Brand_Relationship__c.class)
            .setField(Opportunity_Brand_Relationship__c.Brand__c,brandAssociationId1)
            .setField(Opportunity_Brand_Relationship__c.Opportunity__c,opportunityId)
            .setFakeId()
            .toSOBject();
    List<Opportunity_Brand_Relationship__c> obrList = new List<Opportunity_Brand_Relationship__c>{obr};

    fflib_ApexMocks mocks = new fflib_ApexMocks();
    IOpportunityBrandRelationshipsSelector mockOpportunityBrandRelationshipSelector = (IOpportunityBrandRelationshipsSelector)mocks.mock(IOpportunityBrandRelationshipsSelector.class);

    mocks.startStubbing();
     mocks.when(mockOpportunityBrandRelationshipSelector.sObjectType())
       .thenReturn(Opportunity_Brand_Relationship__c.sObjectType);
     mocks.when(mockOpportunityBrandRelationshipSelector.selectByOpportunityAndBrandAsscs(opportunityId,brandAssociationIds))
       .thenReturn(obrList);
    mocks.stopStubbing();

    Application.SELECTOR.setMock(mockOpportunityBrandRelationshipSelector);
    CreateBrandAndBusinessIdController.removeExistingBrandAssociationsIfOBRAlreadyExists(brandAssociationIds,opportunityId);

    System.assertEquals(false,brandAssociationIds.contains(brandAssociationId1),'This Brand Association Id should be removed');
    System.assertEquals(1,brandAssociationIds.size(),'one Id should be removed');
}

/**
* @description - Test WHen exisiting  brand is selected from contract and its contract brand association record is present ,
                 then the brand Id is removed from further processing
* @author Soumya Dash | 05-22-2024
**/
@isTest
private static void testWhenExistingContractBrandAssociationisAvilableThenRemoveBrandId(){
    Id contractId = Fake.GenerateId(Contract.class);
    Id opportunityId = Fake.GenerateId(Opportunity.class);
    Id brandId1 = Fake.GenerateId(Brand__c.class);
    Id brandId2 = Fake.GenerateId(Brand__c.class);
    set<Id> brandIds = new set<Id>{brandId1,brandId2};

    Contract_Brand_Association__c cba = (Contract_Brand_Association__c)new Fake(Contract_Brand_Association__c.class)
            .setField(Contract_Brand_Association__c.Brand__c,brandId1)
            .setField(Contract_Brand_Association__c.Contract__c,contractId)
            .setField(Contract_Brand_Association__c.Opportunity__c,opportunityId)
            .setFakeId()
            .toSOBject();
    List<Contract_Brand_Association__c> cbaList = new List<Contract_Brand_Association__c>{cba};

    fflib_ApexMocks mocks = new fflib_ApexMocks();
    IContractBrandAssociationsSelector mockContractBrandAssociationSelector = (IContractBrandAssociationsSelector)mocks.mock(IContractBrandAssociationsSelector.class);

    mocks.startStubbing();
     mocks.when(mockContractBrandAssociationSelector.sObjectType())
       .thenReturn( Contract_Brand_Association__c.sObjectType);
     mocks.when(mockContractBrandAssociationSelector.selectByContractAndBrandAsscs(contractId,brandIds))
       .thenReturn(cbaList);
    mocks.stopStubbing();

    Application.SELECTOR.setMock(mockContractBrandAssociationSelector);
    CreateBrandAndBusinessIdController.removeExistingBrandAssociationsIfCBAAlreadyExists(brandIds,contractId);

    System.assertEquals(false,brandIds.contains(brandId1),'This Brand Id Should be removed');
    System.assertEquals(1,brandIds.size(),'one Id should be removed');
}
      /**
* @description test method for CreateFlowRequest
*/
    @isTest
    private static void testWhenCreateFlowRequestCalledforOpportunityThenReturnFlowRequest() {
        Id parentAccountId = Fake.generateId(Account.class);

        Account parentAccount = new Account(
            Id = parentAccountId,
            name = 'Mcdonald USA',
            RecordTypeId = BUSINESS_RECORD_TYPE_ID
        );

           Id opportunityId1 = fflib_IDGenerator.generate(Opportunity.SObjectType);
        List<Opportunity> opportunityRecords = new List<Opportunity>{
            new Opportunity(
                id = opportunityId1,
                Name = 'Test1',
                StageName = 'Pitching',
                Type = 'New',
                Accountid = parentAccount.Id,
                Probability = 30,
                Deal_Type__c = 'Standard',
                ForecastCategoryName = 'Pipeline',
                CloseDate = System.today().addDays(3)
            )
                };


        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        // Set up the Application class to use the mock UnitOfWork
        Application.UnitOfWork.setMock(mockUOW);

        // Act
       Process_Flow_Request__c processRequest = CreateBrandAndBusinessIdController.createFlowRequest(opportunityRecords[0].Id,OPPORTUNITY_OBJ );

        // Assert
        System.assertNotEquals(null, processRequest,'process reqeust is empty');

        // Assert
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).registerNew(processRequest);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();

    }



      /**
* @description test method for CreateFlowRequest
*/
    @isTest
    private static void testWhenCreateFlowRequestforContractCalledThenReturnFlowRequest() {
        Id parentAccountId = Fake.generateId(Account.class);
        String kfcContractId = fflib_IDGenerator.generate(Contract.SObjectType);


        Account parentAccount = new Account(
            Id = parentAccountId,
            name = 'Mcdonald USA',
            RecordTypeId = BUSINESS_RECORD_TYPE_ID
        );

           List<Contract> contracts = new List<Contract>{
            (Contract) new Fake(Contract.class)
                .setField(Contract.Id, kfcContractId)
                .setField(Contract.AccountId, parentAccount.ID)
                .setField(Contract.Status, STATUS_ACTIVATED)
                .toSObject()

        };


        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        // Set up the Application class to use the mock UnitOfWork
        Application.UnitOfWork.setMock(mockUOW);

        // Act
       Process_Flow_Request__c processRequest = CreateBrandAndBusinessIdController.createFlowRequest(contracts[0].Id,CONTRACT_OBJ );

        // Assert
        System.assertNotEquals(null, processRequest,'Process Requst is null');

        // Assert
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).registerNew(processRequest);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();

    }

     @isTest
    private static void testWhenUpdateFlowRequestStatusCalledThenReturnUpdatedFlowRequestForContract() {
        Id parentAccountId = Fake.generateId(Account.class);
        String kfcContractId = fflib_IDGenerator.generate(Contract.SObjectType);

        Account parentAccount = new Account(
            Id = parentAccountId,
            name = 'Mcdonald USA',
            RecordTypeId = BUSINESS_RECORD_TYPE_ID
        );

        List<Contract> contracts = new List<Contract>{
            (Contract) new Fake(Contract.class)
                .setField(Contract.Id, kfcContractId)
                .setField(Contract.AccountId, parentAccount.ID)
                .setField(Contract.Status, STATUS_ACTIVATED)
                .toSObject()

        };

            List<Process_Flow_Request__c> processRequest = new List<Process_Flow_Request__c>{
                (Process_Flow_Request__c) new Fake(Process_Flow_Request__c.class)
            .setField(Process_Flow_Request__c.Contract__c, contracts[0].Id)
            .setField(Process_Flow_Request__c.Stage__c, REQUEST_STAGE_IN_FLOW_INITIATED)
            .setField(Process_Flow_Request__c.Status__c, REQUEST_STATUS_IN_PROGRESS)
            .setFakeId()
            .toSObject()
          };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IProcessFlowRequestsSelector processFlowSelectorMock = (IProcessFlowRequestsSelector) mocks.mock(
            IProcessFlowRequestsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        String jsonData = 'Record created';

        mocks.startStubbing();
        mocks.when(processFlowSelectorMock.SObjectType())
            .thenReturn(Process_Flow_Request__c.SObjectType);
        mocks.when(
            processFlowSelectorMock.selectOpenBrandAndBusinessRequestsForContractAndUser(contracts[0].Id))
            .thenReturn(processRequest);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(processFlowSelectorMock);
        Application.UnitOfWork.setMock(mockUOW);
       Process_Flow_Request__c incomingProcessRequest = CreateBrandAndBusinessIdController.updateFlowRequestStatus(contracts[0].Id,CONTRACT_OBJ,jsonData );
		System.assertNotEquals(null, incomingProcessRequest,'Request is null');


    }

    @isTest
    private static void testWhenContractRecordIdPassedThenReturnBusinessReferences() {
        Id parentAccountId = Fake.generateId(Account.class);
        String kfcContractId = fflib_IDGenerator.generate(Contract.SObjectType);

        Account parentAccount = new Account(
            Id = parentAccountId,
            name ='KFC USA',
            RecordTypeId = BUSINESS_RECORD_TYPE_ID
        );
        List<Account> accountList = new List<Account>();
        accountList.add(parentAccount);

         List<Contract> contracts = new List<Contract>{
            (Contract) new Fake(Contract.class)
                .setField(Contract.Id, kfcContractId)
                .setField(Contract.AccountId, parentAccount.ID)
                .toSObject()

        };

        List<Opportunity> opportunityRecord = new List<Opportunity>();
        Opportunity opp = (Opportunity)new Fake(Opportunity.class)
        .setField(Opportunity.Name,'Test1')
        .setField(Opportunity.StageName,'Pitching')
        .setField(Opportunity.Type,'New')
        .setField(Opportunity.Accountid,parentAccount.Id)
        .setField(Opportunity.Probability,30)
        .setField(Opportunity.ForecastCategoryName,'Pipeline')
        .setField(Opportunity.CloseDate,System.today().addDays(3))
        .setField(Opportunity.ContractId,contracts[0].Id)
        .setFakeId()
        .tosObject();
        opportunityRecord.add(opp);

        List<Business_Reference__c> businessReferences = new List<Business_Reference__c>{
            (Business_Reference__c) new Fake(Business_Reference__c.class)
                .setField(Business_Reference__c.Id, fflib_IDGenerator.generate(Business_Reference__c.SObjectType))
                .toSObject()
        };


        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBusinessReferencesSelector businessReferenceSelectorMock = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        IOpportunitiesSelector opportunitySelectorMock = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );

        mocks.startStubbing();
        mocks.when(businessReferenceSelectorMock.sObjectType()).thenReturn(Business_Reference__c.SObjectType);
        mocks.when(businessReferenceSelectorMock.selectBySourceIds(new List<Id>{contracts[0].Id}))
           .thenReturn(businessReferences);

        mocks.when(opportunitySelectorMock.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(opportunitySelectorMock.selectOpportunitiesByContractId(contracts[0].Id))
           .thenReturn(opportunityRecord);

        mocks.stopStubbing();
        Application.SELECTOR.setMock(businessReferenceSelectorMock);
        Application.SELECTOR.setMock(opportunitySelectorMock);

        List<Business_Reference__c> result = CreateBrandAndBusinessIdController.getBusinessReferencesBySourceId(contracts[0].Id);

        System.assertNotEquals(1, result.size(), 'The returned list should contain one record');
    }

     @isTest
    private static void testWhenOpportunityRecordIdPassedThenReturnBusinessReferences() {
        Id parentAccountId = Fake.generateId(Account.class);
        String kfcContractId = fflib_IDGenerator.generate(Contract.SObjectType);

        Account parentAccount = new Account(
            Id = parentAccountId,
            name ='KFC USA',
            RecordTypeId = BUSINESS_RECORD_TYPE_ID
        );
        List<Account> accountList = new List<Account>();
        accountList.add(parentAccount);


        List<Opportunity> opportunityRecord = new List<Opportunity>();
        Opportunity opp = (Opportunity)new Fake(Opportunity.class)
        .setField(Opportunity.Name,'Test1')
        .setField(Opportunity.StageName,'Pitching')
        .setField(Opportunity.Type,'New')
        .setField(Opportunity.Accountid,parentAccount.Id)
        .setField(Opportunity.Probability,30)
        .setField(Opportunity.ForecastCategoryName,'Pipeline')
        .setField(Opportunity.CloseDate,System.today().addDays(3))
        .setFakeId()
        .tosObject();
        opportunityRecord.add(opp);

          List<Contract> contracts = new List<Contract>{
            (Contract) new Fake(Contract.class)
                .setField(Contract.Id, kfcContractId)
                .setField(Contract.AccountId, parentAccount.ID)
                .setField(Contract.SBQQ__Opportunity__c, opportunityRecord[0].ID)
                .toSObject()

        };

        List<Business_Reference__c> businessReferences = new List<Business_Reference__c>{
            (Business_Reference__c) new Fake(Business_Reference__c.class)
                .setField(Business_Reference__c.Id, fflib_IDGenerator.generate(Business_Reference__c.SObjectType))
                .toSObject()
        };


        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBusinessReferencesSelector businessReferenceSelectorMock = (IBusinessReferencesSelector) mocks.mock(
            IBusinessReferencesSelector.class
        );
        IContractsSelector contractSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );

        mocks.startStubbing();
        mocks.when(businessReferenceSelectorMock.sObjectType()).thenReturn(Business_Reference__c.SObjectType);
        mocks.when(businessReferenceSelectorMock.selectBySourceIds(new List<Id>{opportunityRecord[0].ID}))
           .thenReturn(businessReferences);

        mocks.when(contractSelectorMock.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(contractSelectorMock.selectContractsByOpportunityId(opportunityRecord[0].ID))
           .thenReturn(contracts);

        mocks.stopStubbing();
        Application.SELECTOR.setMock(businessReferenceSelectorMock);
        Application.SELECTOR.setMock(contractSelectorMock);

        List<Business_Reference__c> result = CreateBrandAndBusinessIdController.getBusinessReferencesBySourceId(opportunityRecord[0].ID);

        System.assertNotEquals(1, result.size(), 'The returned list should contain one record');
    }

     @isTest
    private static void testWhenGetBusinessVerticalsThenReturnBusinessVerticals() {
         Business_Vertical__c businessVertical = new Business_Vertical__c(
            Name = 'Business Vertical 1',
            Primary_Vertical__c = PRIMARY_VERTICAL_ALCOHOL,
            Menu_UI_Type__c = MENU_UI_TYPE_RETAIL,
            Product__c = PRODUCT_MARKETPLACE,
            Vertical_Name__c = VERTICAL_NAME
        );
        insert businessVertical;

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IBusinessVerticalsSelector mockBusinessVerticalsSelector = (IBusinessVerticalsSelector) mocks.mock(
            IBusinessVerticalsSelector.class
        );

        mocks.startStubbing();
        mocks.when(mockBusinessVerticalsSelector.selectById(new Set<Id>{businessVertical.Id}))
            .thenReturn(businessVertical);

        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockBusinessVerticalsSelector);
        Business_Vertical__c result = CreateBrandAndBusinessIdController.getBusinessVerticals(businessVertical.Id);

        System.assertEquals(businessVertical.Product__c, result.Product__c, 'Method return same business vertical');
    }

}