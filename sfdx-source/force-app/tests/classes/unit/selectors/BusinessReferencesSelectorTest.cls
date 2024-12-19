/**
 * @description This is test class for BusinessReferencesSelector class
 */
@isTest
public with sharing class BusinessReferencesSelectorTest {
    private static final String ACCOUNT_NAME = 'Mock Account';
    private static final String ACCOUNT_PRIMARY_VERTICAL_GIFTS = 'Gifts';
    private static final String ACCOUNT_PRIMARY_VERTICAL_ALCOHOL = 'Alcohol';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    private static final string ASSERT_MESSAGE_BUSINESS_REFERENCE_SIZE = 'Unexpected results: Business Referece records are not filtered.';
    private static final String EMPTY_LIST_ASSERT_MESSAGE = 'Unexpected Result: Number of records returned does not match the expected outcome.';
    private static final String BRAND_NAME = 'Mock Brand';
    private static final String BUSINESS_ACCOUNT_NAME = 'Test Business Account';
    private static final String BUSINESS_REFERENCE_ID_DO_NOT_MATCH_ASSERT_MESSAGE = 'Unexpected result: Business Reference Id does not match';
    private static final String BUSINESS_VERTICAL_NAME = 'Mock Business Vertical';
    private static final String CURRENCY_ISO_CAD = 'CAD';
    private static final String CURRENCY_ISO_USD = 'USD';
    private static final String DEFAULT_TYPE_CORPORATE = 'Corporate';
    private static final String EXTERNAL_DB_SOURCE_DRIVE = 'DriveDb';
    private static final String EXTERNAL_ID_MOCK = '123456';
    private static final String EXTERNAL_ID_SOURCE_MDS = 'MDS';
    private static final String INTEGRATION_STATUS_SUCCESS = 'Success';
    private static final string INVALID_ASSERT_MESSAGE = 'Unexpected results';
    private static final String MENU_UI_TYPE = 'Restaurant';
    private static final string MOCK_BUSINESS_ID = '13346';
    private static final string MOCK_EXTERNAL_ID = '1234567';
    private static final String ORDER_PROTOCOL_EMAIL = 'Email';
    private static final String PRODUCT_DRIVE = 'Drive';
    private static final String STORE_ACCOUNT_NAME = 'Test Store Account';
    private static final String UNIQUE_IDENTIFIER = '92108a53-e8d9-4a0c-9193-9152aeb86fe4';
    private static final String VERTICAL_NAME = 'misc_retail_ui';
    private static final String WORK_ORDER_MENU_TO_BE_COMPLETED_BY = 'Merchant';
    private static final String WORK_ORDER_STATUS = 'Planning';
    private static final String WORKORDER_ACTIVATED_CENTRALLY_YES = 'Yes';
    private static final String WORK_ORDER_TYPE_MARKETPLACE = 'Marketplace';
    private static final String XREF_EXTERNAL_ID_SOURCE = 'MDS';
    private static final String XREF_STATUS_ACTIVE = 'Active';
    private static final String RECORD_FOUND = 'Record Found';
    private static final String COUNT_OF_RECORDS_RETURNED_NOT_MATCHING = '2 Business References are expected to be returned for the given criteria';
    private static final String LATEST_RECORD_IS_NOT_RETURNED = 'Latest Business Reference record is expected to be returned';

    /**
     * @description This method used to test BusinessReferencesSelector class.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        BusinessReferencesSelector selector = new BusinessReferencesSelector();
        List<Schema.SObjectField> fieldList = selector.getSObjectFieldList();
        Schema.SObjectType typeOfObj = selector.getSObjectType();
        System.assertEquals(
            new List<Schema.SObjectField>{
                Business_Reference__c.Id,
                Business_Reference__c.CurrencyISOCode,
                Business_Reference__c.Created_Source_Id__c,
                Business_Reference__c.External_Id_Source__c,
                Business_Reference__c.Business_Name__c,
                Business_Reference__c.Default_Type__c,
                Business_Reference__c.Integration_Status__c,
                Business_Reference__c.Last_Completed_Step__c,
                Business_Reference__c.External_Id__c,
                Business_Reference__c.Menu_UI_Type__c,
                Business_Reference__c.Primary_Vertical__c,
                Business_Reference__c.Business_Vertical__c,
                Business_Reference__c.Brand__c,
                Business_Reference__c.Business_Group_Id__c
            },
            fieldList,
            ' Mismatch in field list'
        );
        System.assertEquals(
            Schema.Business_Reference__c.SObjectType,
            typeOfObj,
            'The object type must be Business Reference'
        );
    }

    /**
     * @description This method used to test selectByUniqueIdentifier method
     */
    @isTest
    public static void testWhenDuplicateInOriginalListInsertedThenFailDuplicate() {
        Id businessAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Account corporateAccountWithBrand = new Account(
            Name = 'McDonalds US',
            RecordTypeId = businessAccountRecordTypeId,
            Type = 'Corporate',
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert corporateAccountWithBrand;
        Brand__c brandKFC = new Brand__c(
            Name = 'KFC',
            Brand_Owner__c = corporateAccountWithBrand.Id
        );
        insert brandKFC;

        List<Business_Vertical__c> businessVerticals = new List<Business_Vertical__c>{
            new Business_Vertical__c(
                Name = 'Alcohol_Drive',
                Menu_UI_Type__c = 'Restaurant',
                Primary_Vertical__c = 'Alcohol',
                Product__c = 'Drive',
                Vertical_Name__c = 'misc_retail_ui'
            ),
            new Business_Vertical__c(
                Name = 'Grocery_Drive',
                Menu_UI_Type__c = 'Restaurant',
                Primary_Vertical__c = 'Grocery',
                Product__c = 'Drive',
                Vertical_Name__c = 'misc_retail_ui'
            )
        };
        insert businessVerticals;

        List<Business_Reference__c> businessReferences = new List<Business_Reference__c>{
            new Business_Reference__c(
                CurrencyIsoCode = 'USD',
                External_Id_Source__c = EXTERNAL_DB_SOURCE_DRIVE,
                Brand__c = brandKFC.Id,
                Business_Vertical__c = businessVerticals[0].Id,
                Default_Type__c = 'Corporate'
            ),
            new Business_Reference__c(
                CurrencyIsoCode = 'USD',
                External_Id_Source__c = EXTERNAL_DB_SOURCE_DRIVE,
                Business_Vertical__c = businessVerticals[0].Id,
                Brand__c = brandKFC.Id,
                Default_Type__c = 'Corporate'
            )
        };

        List<Database.SaveResult> saveResults = Database.insert(businessReferences, false);

        System.assert(!saveResults[1].isSuccess(), 'Unexpected Result: insert succeeded.');
    }

    /**
     * @description This method used to test selectByUniqueIdentifier method
     */
    @isTest
    public static void testWhenDuplicateInsertedAfterThenFailDuplicate() {
        Id businessAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Account corporateAccountWithBrand = new Account(
            Name = 'McDonalds US',
            RecordTypeId = businessAccountRecordTypeId,
            Type = 'Corporate',
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert corporateAccountWithBrand;
        Brand__c brandKFC = new Brand__c(
            Name = 'KFC',
            Brand_Owner__c = corporateAccountWithBrand.Id
        );
        insert brandKFC;

        List<Business_Vertical__c> businessVerticals = new List<Business_Vertical__c>{
            new Business_Vertical__c(
                Name = 'Alcohol_Drive',
                Menu_UI_Type__c = 'Restaurant',
                Primary_Vertical__c = 'Alcohol',
                Product__c = 'Drive',
                Vertical_Name__c = 'misc_retail_ui'
            ),
            new Business_Vertical__c(
                Name = 'Grocery_Drive',
                Menu_UI_Type__c = 'Restaurant',
                Primary_Vertical__c = 'Grocery',
                Product__c = 'Drive',
                Vertical_Name__c = 'misc_retail_ui'
            )
        };
        insert businessVerticals;

        List<Business_Reference__c> businessReferences1 = new List<Business_Reference__c>{
            new Business_Reference__c(
                CurrencyIsoCode = 'USD',
                External_Id_Source__c = EXTERNAL_DB_SOURCE_DRIVE,
                Brand__c = brandKFC.Id,
                Business_Vertical__c = businessVerticals[0].Id,
                Default_Type__c = 'Corporate'
            )
        };
        insert businessReferences1;

        List<Business_Reference__c> businessReferences2 = new List<Business_Reference__c>{
            new Business_Reference__c(
                CurrencyIsoCode = 'USD',
                External_Id_Source__c = EXTERNAL_DB_SOURCE_DRIVE,
                Brand__c = brandKFC.Id,
                Business_Vertical__c = businessVerticals[0].Id,
                Default_Type__c = 'Corporate'
            )
        };

        List<Database.SaveResult> saveResults = Database.insert(businessReferences2, false);

        System.assert(!saveResults[0].isSuccess(), 'Unexpected Result: insert succeeded.');
    }

    /**
     * @description This method used to test selectByPrimaryVerticals method on Business References
     */
    @isTest
    public static void testWhenPrimaryVerticalsArePassedThenReturnBusinessReferences() {
        List<Business_Vertical__c> businessVerticals = new List<Business_Vertical__c>{
            new Business_Vertical__c(
                Name = 'Alcohol_Drive',
                Menu_UI_Type__c = 'Restaurant',
                Primary_Vertical__c = 'Alcohol',
                Product__c = 'Drive',
                Vertical_Name__c = 'misc_retail_ui'
            ),
            new Business_Vertical__c(
                Name = 'Grocery_Drive',
                Menu_UI_Type__c = 'Restaurant',
                Primary_Vertical__c = 'Grocery',
                Product__c = 'Drive',
                Vertical_Name__c = 'misc_retail_ui'
            )
        };
        insert businessVerticals;
        List<Business_Reference__c> businessReferences = new List<Business_Reference__c>{
            new Business_Reference__c(
                CurrencyIsoCode = 'USD',
                External_Id_Source__c = EXTERNAL_DB_SOURCE_DRIVE,
                Business_Name__c = 'Test Business Name',
                Default_Type__c = 'Corporate',
                Primary_Vertical__c = ACCOUNT_PRIMARY_VERTICAL_GIFTS,
                Business_Vertical__c = businessVerticals[0].Id
            ),
            new Business_Reference__c(
                CurrencyIsoCode = 'USD',
                External_Id_Source__c = EXTERNAL_DB_SOURCE_DRIVE,
                Business_Name__c = 'Test Business Name',
                Default_Type__c = 'Franchise',
                Primary_Vertical__c = ACCOUNT_PRIMARY_VERTICAL_ALCOHOL,
                Business_Vertical__c = businessVerticals[1].Id
            )
        };
        insert businessReferences;

        Set<String> accountsPrimaryVerticals = new Set<String>{
            businessVerticals[0].Id,
            businessVerticals[1].Id
        };
        BusinessReferencesSelector businessRefSelectorTest = new BusinessReferencesSelector();
        List<Business_Reference__c> businessReferencesList = businessRefSelectorTest.selectByBusinessVerticals(
            accountsPrimaryVerticals
        );
        System.assertEquals(2, businessReferencesList.size(), 'Returns only 1 business Reference');
    }

    /**
     * @description This method used to test When Xref Status is updated Then we return Business Reference
     */
    @isTest
    public static void testWhenXrefStatusIsUpdatedThenReturnBusinessReferences() {
        List<Business_Reference__c> businessReferences = new List<Business_Reference__c>{
            new Business_Reference__c(
                CurrencyIsoCode = 'USD',
                External_Id_Source__c = EXTERNAL_DB_SOURCE_DRIVE,
                Business_Name__c = 'Test Business Name',
                Default_Type__c = 'Corporate',
                Primary_Vertical__c = ACCOUNT_PRIMARY_VERTICAL_GIFTS
            ),
            new Business_Reference__c(
                CurrencyIsoCode = 'USD',
                External_Id_Source__c = EXTERNAL_DB_SOURCE_DRIVE,
                Business_Name__c = 'Test Business Name',
                Default_Type__c = 'Franchise',
                Primary_Vertical__c = ACCOUNT_PRIMARY_VERTICAL_ALCOHOL
            )
        };
        insert businessReferences;
        Set<Id> busRefIdSet = new Set<Id>{ businessReferences[0].Id, businessReferences[1].Id };
        BusinessReferencesSelector businessRefSelectorTest = new BusinessReferencesSelector();
        List<Business_Reference__c> businessReferencesList = businessRefSelectorTest.selectByBusRefId(
            busRefIdSet
        );
        System.assertEquals(2, businessReferencesList.size(), 'Returns only 1 business Reference');
    }

    /**
     * @description This method used to test selectByGraveyardId method on Business References
     */
    @isTest
    public static void testWhenGraveyardIdsArePassedThenReturnBusinessReferences() {
        List<Business_Reference__c> businessReferences = new List<Business_Reference__c>{
            new Business_Reference__c(
                CurrencyIsoCode = 'USD',
                External_Id__c = '123456',
                External_Id_Source__c = EXTERNAL_DB_SOURCE_DRIVE,
                Business_Name__c = 'Test Business Name',
                Default_Type__c = 'Corporate',
                Primary_Vertical__c = ACCOUNT_PRIMARY_VERTICAL_GIFTS
            ),
            new Business_Reference__c(
                CurrencyIsoCode = 'USD',
                External_Id__c = '123456',
                External_Id_Source__c = EXTERNAL_DB_SOURCE_DRIVE,
                Business_Name__c = 'Test Business Name',
                Default_Type__c = 'COO Graveyard',
                Primary_Vertical__c = ACCOUNT_PRIMARY_VERTICAL_ALCOHOL
            )
        };
        insert businessReferences;

        Set<String> graveyardIdSet = new Set<String>{ '123456' };
        BusinessReferencesSelector businessRefSelectorTest = new BusinessReferencesSelector();
        List<Business_Reference__c> businessReferencesList = businessRefSelectorTest.selectByGraveyardIds(
            graveyardIdSet
        );
        System.assertEquals(
            1,
            businessReferencesList.size(),
            'Should Return only 1 business Reference'
        );
    }

    /**
     * @description This method used to test selectBydIdAndIntegrationStatus method on Business References
     */
    @isTest
    public static void testWhenBusinessReferenceIdsAndIntegrationStatusPassedThenReturnBusinessReferences() {
        String successString = 'Success';
        String failureString = 'Failure';
        String newString = 'New';
        List<Business_Reference__c> businessReferences = new List<Business_Reference__c>{
            new Business_Reference__c(
                CurrencyIsoCode = 'USD',
                External_Id_Source__c = EXTERNAL_DB_SOURCE_DRIVE,
                Business_Name__c = 'Test Business Name',
                Default_Type__c = 'Corporate',
                Primary_Vertical__c = ACCOUNT_PRIMARY_VERTICAL_GIFTS,
                Integration_status__c = successString
            ),
            new Business_Reference__c(
                CurrencyIsoCode = 'USD',
                External_Id_Source__c = EXTERNAL_DB_SOURCE_DRIVE,
                Business_Name__c = 'Test Business Name',
                Default_Type__c = 'Franchise',
                Primary_Vertical__c = ACCOUNT_PRIMARY_VERTICAL_ALCOHOL,
                Integration_status__c = failureString
            ),
            new Business_Reference__c(
                CurrencyIsoCode = 'USD',
                External_Id_Source__c = EXTERNAL_DB_SOURCE_DRIVE,
                Business_Name__c = 'Test Business Name1',
                Default_Type__c = 'Franchise',
                Primary_Vertical__c = ACCOUNT_PRIMARY_VERTICAL_ALCOHOL,
                Integration_status__c = newString
            )
        };
        fflib_SObjectDomain.getTriggerEvent(BusinessReferenceHandler.class).disableAll();
        insert businessReferences;
        fflib_SObjectDomain.getTriggerEvent(BusinessReferenceHandler.class).enableAll();

        Set<Id> businessreferenceIds = new Set<Id>{
            businessReferences[0].Id,
            businessReferences[1].Id,
            businessReferences[2].Id
        };
        Set<String> integrationStatus = new Set<String>{ successString, failureString };
        BusinessReferencesSelector businessRefSelectorTest = new BusinessReferencesSelector();
        List<Business_Reference__c> businessReferencesList = businessRefSelectorTest.selectBydIdAndIntegrationStatus(
            businessreferenceIds,
            integrationStatus
        );
        System.assertEquals(
            2,
            businessReferencesList.size(),
            '2 Business reference records should be returned'
        );
    }

    @isTest
    static void testWhenBusinessReferenceNameIsPassedThenReturnBusinessReferences() {
        List<Business_Vertical__c> businessVerticals = new List<Business_Vertical__c>{
            new Business_Vertical__c(
                Name = 'Test',
                Menu_UI_Type__c = 'Restaurant',
                Primary_Vertical__c = 'Alcohol',
                Product__c = 'Drive',
                Vertical_Name__c = 'misc_retail_ui'
            )
        };
        insert businessVerticals;
        Business_Reference__c busRef = new Business_Reference__c(
            CurrencyIsoCode = 'USD',
            External_Id__c = '123456',
            External_Id_Source__c = 'MDS',
            Business_Name__c = 'Test Business Name',
            Default_Type__c = 'COO Graveyard',
            Primary_Vertical__c = ACCOUNT_PRIMARY_VERTICAL_ALCOHOL,
            Business_Vertical__c = businessVerticals[0].Id
        );
        insert busRef;
        Test.startTest();
        Map<Id, Business_Reference__c> businessReferenceMap = new Map<Id, Business_Reference__c>(
            BusinessReferencesSelector.newInstance()
                .selectByBusRefName(new List<String>{ 'Test Business Name' })
        );
        Test.stopTest();
        System.assertEquals(
            1,
            businessReferenceMap.size(),
            '1 Business References are expected to be returned for the given criteria'
        );
        System.assert(
            businessReferenceMap.containsKey(busRef.Id),
            'This Business reference should be returned'
        );
    }
    @isTest
    static void testWhenExternalIdPassedInThenReturnBusinessReference() {
        List<Business_Vertical__c> businessVerticals = new List<Business_Vertical__c>{
            new Business_Vertical__c(
                Name = 'Test',
                Menu_UI_Type__c = 'Restaurant',
                Primary_Vertical__c = 'Alcohol',
                Product__c = 'Drive',
                Vertical_Name__c = 'misc_retail_ui'
            )
        };
        insert businessVerticals;
        Business_Reference__c busRef = new Business_Reference__c(
            CurrencyIsoCode = 'USD',
            External_Id__c = '123456',
            External_Id_Source__c = 'MDS',
            Business_Name__c = 'Test Business Name',
            Default_Type__c = 'COO Graveyard',
            Primary_Vertical__c = ACCOUNT_PRIMARY_VERTICAL_ALCOHOL,
            Business_Vertical__c = businessVerticals[0].Id
        );
        insert busRef;
        Business_Reference__c businessReference1 = new Business_Reference__c(
            CurrencyIsoCode = 'USD',
            External_Id__c = '123456',
            External_Id_Source__c = 'MDS',
            Business_Name__c = 'Test Business Name',
            Default_Type__c = 'COO Graveyard',
            Primary_Vertical__c = ACCOUNT_PRIMARY_VERTICAL_ALCOHOL,
            Business_Vertical__c = businessVerticals[0].Id
        );
        insert businessReference1;
        Test.startTest();
        List<Business_Reference__c> businessReferences = BusinessReferencesSelector.newInstance()
            .selectBusRefByExternalId(new Set<String>{ '123456' });
        Test.stopTest();
        System.assertEquals(2, businessReferences.size(), COUNT_OF_RECORDS_RETURNED_NOT_MATCHING);
        System.assertEquals(
            businessReference1.Id,
            businessReferences[1].Id,
            LATEST_RECORD_IS_NOT_RETURNED
        );
    }

    /**
     * @description This method used to test selectByBusRefNameAndIntegrationStatusAndDefaultType
     */
    @isTest
    static void testWhenBusRefNameAndIntegrationStatusAndDefaultTypePassedInThenReturnBusinessReference() {
        //LEM-16588 - Inserting account to associate with Brand inserted below
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Account[] businessAccounts = new List<Account>{
            new Account(
                Name = 'Test Account',
                RecordTypeId = accRecordTypeBusiness,
                Segment__c = ACCOUNT_SEGMENT_SMB
            )
        };
        insert businessAccounts;
        List<Business_Vertical__c> businessVerticals = new List<Business_Vertical__c>{
            new Business_Vertical__c(
                Name = 'Test',
                Menu_UI_Type__c = 'Restaurant',
                Primary_Vertical__c = 'Alcohol',
                Product__c = 'Drive',
                Vertical_Name__c = 'misc_retail_ui'
            )
        };
        insert businessVerticals;
        //LEM-16588
        Brand__c[] brands = new List<Brand__c>{
            new Brand__c(Name = 'Test Brand', Brand_Owner__c = businessAccounts[0].Id)
        };
        insert brands;
        Business_Reference__c busRef = new Business_Reference__c(
            CurrencyIsoCode = 'USD',
            External_Id__c = '123456',
            External_Id_Source__c = 'MDS',
            Business_Name__c = 'Test Business Name',
            Default_Type__c = 'Corporate',
            Menu_UI_Type__c = 'Retail',
            Integration_Status__c = 'Success',
            Business_Vertical__c = businessVerticals[0].Id,
            Brand__c = brands[0].Id
        );

        insert busRef;
        Test.startTest();
        Map<Id, Business_Reference__c> businessReferenceMap = new Map<Id, Business_Reference__c>(
            BusinessReferencesSelector.newInstance()
                .selectByBusRefNameAndIntegrationStatusAndDefaultType(
                    new Set<String>{ brands[0].Name },
                    new Set<String>{ 'Success' },
                    new Set<String>{ 'Corporate' }
                )
        );
        Test.stopTest();
        System.assertEquals(
            1,
            businessReferenceMap.size(),
            '1 Business References are expected to be returned for the given criteria'
        );
        System.assert(
            businessReferenceMap.containsKey(busRef.Id),
            'This Business reference should be returned'
        );
    }

    /**
     * @description This method used to test selectByDefaultTypeAndExternalIdSource
     */
    @isTest
    static void testWhenBussinessRefExternalIDAndDefaultTypeAndExternalIDSourcePassedInThenReturnBusinessReference() {
        Business_Reference__c busRef = new Business_Reference__c(
            CurrencyIsoCode = 'USD',
            External_Id__c = '123456',
            External_Id_Source__c = EXTERNAL_ID_SOURCE_MDS,
            Business_Name__c = 'Test Business Name',
            Default_Type__c = DEFAULT_TYPE_CORPORATE,
            Menu_UI_Type__c = 'Retail',
            Integration_Status__c = 'Success'
        );

        insert busRef;
        Test.startTest();
        Map<Id, Business_Reference__c> businessReferenceMap = new Map<Id, Business_Reference__c>(
            BusinessReferencesSelector.newInstance()
                .selectByDefaultTypeAndExternalIdSource(
                    new Set<String>{ '123456' },
                    new Set<String>{ DEFAULT_TYPE_CORPORATE },
                    new Set<String>{ EXTERNAL_ID_SOURCE_MDS }
                )
        );
        Test.stopTest();
        System.assertEquals(
            1,
            businessReferenceMap.size(),
            '1 Business References are expected to be returned for the given criteria'
        );
        System.assert(
            businessReferenceMap.containsKey(busRef.Id),
            'This Business reference should be returned'
        );
    }

    /**
     * @description This method used to test selectByBusRefNameAndIntegrationStatusAndDefaultType
     */
    @isTest
    static void testWhenBrandIdPassedAlongWithDefaultTypesAndCurrencyThenReturnValidData() {
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Account[] businessAccounts = new List<Account>{
            new Account(
                Name = 'Name1',
                RecordTypeId = accRecordTypeBusiness,
                Segment__c = ACCOUNT_SEGMENT_SMB
            )
        };
        insert businessAccounts;

        Brand__c[] brands = new List<Brand__c>{
            new Brand__c(Name = 'B1', Brand_Owner__c = businessAccounts[0].Id),
            new Brand__c(Name = 'B2', Brand_Owner__c = businessAccounts[0].Id)
        };
        insert brands;

        List<Business_Vertical__c> businessVerticals = new List<Business_Vertical__c>{
            new Business_Vertical__c(
                Name = 'Test',
                Menu_UI_Type__c = 'Restaurant',
                Primary_Vertical__c = 'Alcohol',
                Product__c = 'Drive',
                Vertical_Name__c = 'misc_retail_ui'
            )
        };
        insert businessVerticals;
        List<Business_Reference__c> bizRefsToInsert = new List<Business_Reference__c>();
        bizRefsToInsert.add(
            new Business_Reference__c(
                CurrencyIsoCode = 'USD',
                External_Id__c = '123456',
                External_Id_Source__c = 'MDS',
                Business_Name__c = 'Test Business Name',
                Default_Type__c = 'Corporate',
                Menu_UI_Type__c = 'Retail',
                Integration_Status__c = 'Success',
                Business_Vertical__c = businessVerticals[0].Id,
                Brand__c = brands[0].Id
            )
        );
        bizRefsToInsert.add(
            new Business_Reference__c(
                CurrencyIsoCode = 'CAD',
                External_Id__c = '123456',
                External_Id_Source__c = 'MDS',
                Business_Name__c = 'Test Business Name',
                Default_Type__c = 'Corporate',
                Menu_UI_Type__c = 'Retail',
                Integration_Status__c = 'Success',
                Business_Vertical__c = businessVerticals[0].Id,
                Brand__c = brands[0].Id
            )
        );

        insert bizRefsToInsert;
        Test.startTest();
        List<Business_Reference__c> brs0 = BusinessReferencesSelector.newInstance()
            .selectBizRefsOfGivenBrandDefaultTypesAndCurrencies(
                brands[0].Id,
                new Set<String>{ 'Corporate' },
                new Set<String>{ 'USD' }
            );

        List<Business_Reference__c> brs1 = BusinessReferencesSelector.newInstance()
            .selectBizRefsOfGivenBrandDefaultTypesAndCurrencies(
                brands[0].Id,
                new Set<String>{ 'Corporate' },
                new Set<String>{ 'CAD' }
            );

        List<Business_Reference__c> brs2 = BusinessReferencesSelector.newInstance()
            .selectBizRefsOfGivenBrandDefaultTypesAndCurrencies(
                brands[1].Id,
                new Set<String>{ 'Corporate' },
                new Set<String>{ 'CAD' }
            );
        Test.stopTest();
        System.assertEquals(
            1,
            brs0.size(),
            '1 Business References is expected to be returned for the given criteria'
        );
        System.assertEquals(
            bizRefsToInsert[0].Id,
            brs0[0].Id,
            'Business Reference mismatch please check the brand, Default Type and Currency'
        );

        System.assertEquals(
            1,
            brs1.size(),
            '1 Business References is expected to be returned for the given criteria'
        );
        System.assertEquals(
            bizRefsToInsert[1].Id,
            brs1[0].Id,
            'Business Reference mismatch please check the brand, Default Type and Currency'
        );

        System.assertEquals(
            0,
            brs2.size(),
            '0 Business References is expected to be returned for the given criteria'
        );
    }

    /**
     * @description This method used to test selectByBusRefCreatedSourceId.
     */
    @isTest
    static void testWhenCreatedSourceIdThenReturnBusinessReference() {
        Integer year = system.today().year();
        String month = '5';
        String day = '17';
        String calculatedCloseDate = year + '-' + month + '-' + day;
        Date opportunityCloseDate = Date.valueOf(calculatedCloseDate);

        List<Business_Vertical__c> businessVerticals = new List<Business_Vertical__c>{
            new Business_Vertical__c(
                Name = 'Test',
                Menu_UI_Type__c = 'Restaurant',
                Primary_Vertical__c = 'Alcohol',
                Product__c = 'Drive',
                Vertical_Name__c = 'misc_retail_ui'
            )
        };
        insert businessVerticals;
        Opportunity oppty = new Opportunity(
            Name = 'Test1',
            StageName = 'Needs Analysis',
            CloseDate = opportunityCloseDate
        );
        insert oppty;

        Business_Reference__c busRef = new Business_Reference__c(
            CurrencyIsoCode = 'USD',
            External_Id__c = '123456',
            External_Id_Source__c = 'MDS',
            Business_Name__c = 'Test Business Name',
            Default_Type__c = 'COO Graveyard',
            Created_Source_Id__c = oppty.Id,
            Primary_Vertical__c = ACCOUNT_PRIMARY_VERTICAL_ALCOHOL,
            Business_Vertical__c = businessVerticals[0].Id
        );

        insert busRef;
        String recrordId = busRef.Created_Source_Id__c;
        Test.startTest();
        Map<Id, Business_Reference__c> businessReferenceMap = new Map<Id, Business_Reference__c>(
            BusinessReferencesSelector.newInstance().selectBySourceIds(new List<Id>{ recrordId })
        );
        List<Business_Reference__c> businessReferences = BusinessReferencesSelector.newInstance()
            .selectByIds(new Set<Id>{ busRef.Id });

        Test.stopTest();
        System.assertEquals(
            1,
            businessReferenceMap.size(),
            '1 Business References are expected to be returned for the given criteria'
        );

        System.assertEquals(
            1,
            businessReferences.size(),
            '1 Business Reference is expected to be returned for the given Id'
        );
        System.assertEquals(
            busRef.Id,
            businessReferences[0].Id,
            'The returned Business Reference should be the one that was inserted'
        );
    }

    @isTest
    static void testWhenExternalIdAndDefaultTypePassedInThenReturnCorporateBusinessReference() {
        List<Business_Vertical__c> businessVerticals = new List<Business_Vertical__c>{
            new Business_Vertical__c(
                Name = 'Test',
                Menu_UI_Type__c = 'Restaurant',
                Primary_Vertical__c = 'Alcohol',
                Product__c = 'Drive',
                Vertical_Name__c = 'misc_retail_ui'
            )
        };
        insert businessVerticals;
        Business_Reference__c busRef = new Business_Reference__c(
            CurrencyIsoCode = 'USD',
            External_Id__c = '123456',
            External_Id_Source__c = 'MDS',
            Business_Name__c = 'Test Business Name',
            Default_Type__c = 'Corporate',
            Primary_Vertical__c = ACCOUNT_PRIMARY_VERTICAL_ALCOHOL,
            Business_Vertical__c = businessVerticals[0].Id
        );

        Business_Reference__c busRef1 = new Business_Reference__c(
            CurrencyIsoCode = 'USD',
            External_Id__c = '1234567',
            External_Id_Source__c = 'MDS',
            Business_Name__c = 'Test Business Name1',
            Default_Type__c = 'COO Graveyard',
            Primary_Vertical__c = ACCOUNT_PRIMARY_VERTICAL_ALCOHOL,
            Business_Vertical__c = businessVerticals[0].Id
        );

        insert new List<Business_Reference__c>{ busRef, busRef1 };
        Test.startTest();
        Map<Id, Business_Reference__c> businessReferenceMap = new Map<Id, Business_Reference__c>(
            BusinessReferencesSelector.newInstance()
                .selectBusRefByExternalIdAndDefaultType(
                    new Set<String>{ '123456' },
                    new Set<String>{ 'Corporate', 'COO Graveyard' }
                )
        );
        Test.stopTest();
        System.assertEquals(
            1,
            businessReferenceMap.size(),
            '1 Business References are expected to be returned for the given criteria'
        );
        System.assert(
            businessReferenceMap.containsKey(busRef.Id),
            'This Business reference should be returned'
        );
    }

    /**
     * @description It is used to test when unique identifier passed then brands are returned or not.
     */
    @isTest
    static void testWhenUniqueIdentifiersPassedInThenReturnBusinessReference() {
        List<Business_Vertical__c> businessVerticals = new List<Business_Vertical__c>{
            new Business_Vertical__c(
                Name = 'Test',
                Menu_UI_Type__c = 'Restaurant',
                Primary_Vertical__c = 'Alcohol',
                Product__c = 'Drive',
                Vertical_Name__c = 'misc_retail_ui'
            )
        };
        insert businessVerticals;
        Business_Reference__c businessReference = new Business_Reference__c(
            CurrencyIsoCode = 'USD',
            External_Id__c = '123456',
            Unique_Identifier__c = UNIQUE_IDENTIFIER,
            External_Id_Source__c = 'MDS',
            Business_Name__c = 'Test Business Name',
            Default_Type__c = 'Corporate',
            Menu_UI_Type__c = 'Retail',
            Integration_Status__c = 'Success',
            Business_Vertical__c = businessVerticals[0].Id
        );
        insert businessReference;
        Test.startTest();
        List<Business_Reference__c> businessReferences = BusinessReferencesSelector.newInstance()
            .selectBusinessReferenceByUniqueIdentifiers(new Set<String>{ UNIQUE_IDENTIFIER });

        Test.stopTest();
        System.assertEquals(1, businessReferences.size(), INVALID_ASSERT_MESSAGE);
    }

    /**
     * @description This method used to test selectBrandAssociationsByAccountIdAndIgnoringExternalSourceMds method
     */
    @isTest
    private static void testWhenSelectBGGroupIdByAccountIdThenOnlyRelatedBGGroupIDAreReturned() {
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Account[] businessAccounts01 = new List<Account>{
            new Account(
                Name = 'Name1',
                RecordTypeId = accRecordTypeBusiness,
                Segment__c = ACCOUNT_SEGMENT_SMB
            )
        };
        insert businessAccounts01;

        Account[] businessAccounts02 = new List<Account>{
            new Account(
                Name = 'Name2',
                RecordTypeId = accRecordTypeBusiness,
                Segment__c = ACCOUNT_SEGMENT_SMB
            )
        };
        insert businessAccounts02;

        Brand__c[] brands = new List<Brand__c>{
            new Brand__c(Name = 'B1', Brand_Owner__c = businessAccounts01[0].Id),
            new Brand__c(Name = 'B2', Brand_Owner__c = businessAccounts01[0].Id)
        };
        insert brands;

        List<Business_Vertical__c> businessVerticals = new List<Business_Vertical__c>{
            new Business_Vertical__c(
                Name = 'Test',
                Menu_UI_Type__c = 'Restaurant',
                Primary_Vertical__c = 'Alcohol',
                Product__c = 'Drive',
                Vertical_Name__c = 'misc_retail_ui'
            )
        };
        insert businessVerticals;
        List<Business_Reference__c> bizRefsToInsert = new List<Business_Reference__c>();
        bizRefsToInsert.add(
            new Business_Reference__c(
                CurrencyIsoCode = 'USD',
                External_Id__c = '123456',
                External_Id_Source__c = 'MDS',
                Business_Name__c = 'Test Business Name',
                Default_Type__c = 'Corporate',
                Menu_UI_Type__c = 'Retail',
                Integration_Status__c = 'Success',
                Business_Vertical__c = businessVerticals[0].Id,
                Business_Group_Id__c = '234',
                Brand__c = brands[0].Id
            )
        );
        bizRefsToInsert.add(
            new Business_Reference__c(
                CurrencyIsoCode = 'CAD',
                External_Id__c = '123456',
                External_Id_Source__c = 'MDS',
                Business_Name__c = 'Test Business Name',
                Default_Type__c = 'Corporate',
                Menu_UI_Type__c = 'Retail',
                Integration_Status__c = 'Success',
                Business_Group_Id__c = '634',
                Business_Vertical__c = businessVerticals[0].Id,
                Brand__c = brands[0].Id
            )
        );

        insert bizRefsToInsert;
        Test.startTest();
        List<Business_Reference__c> brs0 = BusinessReferencesSelector.newInstance()
            .selectBGGroupIdByAccountId(businessAccounts01[0].Id);

        List<Business_Reference__c> brs1 = BusinessReferencesSelector.newInstance()
            .selectBGGroupIdByAccountId(businessAccounts02[0].Id);

        Test.stopTest();
        System.assertEquals(
            0,
            brs1.size(),
            '0 Business References is expected to be returned for the given criteria'
        );

        System.assertEquals(
            2,
            brs0.size(),
            '2 Business References is expected to be returned for the given criteria'
        );
    }

    /**
     * @description To test Business references are filtered and returned based on passed
     * Business Vertical Ids, Brand Names and Currency ISO from store.
     */
    @isTest
    private static void testWhenBusinessVerticalAndBrandNamesPassedWithCurrencyISOThenReturnFilteredBusinessReferences() {
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
            .getRecordTypeId();
        Account[] businessAccounts01 = new List<Account>{
            new Account(
                Name = ACCOUNT_NAME,
                RecordTypeId = accRecordTypeBusiness,
                Segment__c = ACCOUNT_SEGMENT_SMB
            )
        };
        insert businessAccounts01;
        Brand__c[] brands = new List<Brand__c>{
            new Brand__c(Name = BRAND_NAME, Brand_Owner__c = businessAccounts01[0].Id)
        };
        insert brands;
        List<Business_Vertical__c> businessVerticals = new List<Business_Vertical__c>{
            new Business_Vertical__c(
                Name = BUSINESS_VERTICAL_NAME,
                Menu_UI_Type__c = MENU_UI_TYPE,
                Primary_Vertical__c = ACCOUNT_PRIMARY_VERTICAL_ALCOHOL,
                Product__c = PRODUCT_DRIVE,
                Vertical_Name__c = VERTICAL_NAME
            )
        };
        insert businessVerticals;
        List<Business_Reference__c> bizRefsToInsert = new List<Business_Reference__c>();
        bizRefsToInsert.add(
            new Business_Reference__c(
                CurrencyIsoCode = CURRENCY_ISO_USD,
                External_Id__c = EXTERNAL_ID_MOCK,
                External_Id_Source__c = EXTERNAL_ID_SOURCE_MDS,
                Business_Name__c = ACCOUNT_NAME,
                Default_Type__c = DEFAULT_TYPE_CORPORATE,
                Menu_UI_Type__c = MENU_UI_TYPE,
                Integration_Status__c = INTEGRATION_STATUS_SUCCESS,
                Business_Vertical__c = businessVerticals[0].Id,
                Business_Group_Id__c = EXTERNAL_ID_MOCK,
                Brand__c = brands[0].Id
            )
        );
        bizRefsToInsert.add(
            new Business_Reference__c(
                CurrencyIsoCode = CURRENCY_ISO_CAD,
                External_Id__c = EXTERNAL_ID_MOCK,
                External_Id_Source__c = EXTERNAL_ID_SOURCE_MDS,
                Business_Name__c = ACCOUNT_NAME,
                Default_Type__c = DEFAULT_TYPE_CORPORATE,
                Menu_UI_Type__c = MENU_UI_TYPE,
                Integration_Status__c = INTEGRATION_STATUS_SUCCESS,
                Business_Group_Id__c = EXTERNAL_ID_MOCK,
                Business_Vertical__c = businessVerticals[0].Id,
                Brand__c = brands[0].Id
            )
        );
        insert bizRefsToInsert;
        Test.startTest();
        List<Business_Reference__c> businessReferences = BusinessReferencesSelector.newInstance()
            .selectByBusinessVerticalsBrandNamesAndCurrencyISOCodes(
                new Set<String>{ businessVerticals[0].Id },
                new Set<String>{ brands[0].Name },
                new Set<String>{ CURRENCY_ISO_USD }
            );
        Test.stopTest();
        System.assertEquals(1, businessReferences.size(), ASSERT_MESSAGE_BUSINESS_REFERENCE_SIZE);
    }

    /**
     * @description This method used to test selectByOldBGGroupIdandBizId method
     */
    @IsTest
    static void testWhenSelectByBizIdAndThenReturnBusinessReference() {
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Account[] businessAccounts01 = new List<Account>{
            new Account(
                Name = 'Name1',
                RecordTypeId = accRecordTypeBusiness,
                Segment__c = ACCOUNT_SEGMENT_SMB
            )
        };
        insert businessAccounts01;

        Account[] businessAccounts02 = new List<Account>{
            new Account(
                Name = 'Name2',
                RecordTypeId = accRecordTypeBusiness,
                Segment__c = ACCOUNT_SEGMENT_SMB
            )
        };
        insert businessAccounts02;

        Brand__c[] brands = new List<Brand__c>{
            new Brand__c(Name = 'B1', Brand_Owner__c = businessAccounts01[0].Id),
            new Brand__c(Name = 'B2', Brand_Owner__c = businessAccounts01[0].Id)
        };
        insert brands;

        List<Business_Vertical__c> businessVerticals = new List<Business_Vertical__c>{
            new Business_Vertical__c(
                Name = 'Test',
                Menu_UI_Type__c = 'Restaurant',
                Primary_Vertical__c = 'Alcohol',
                Product__c = 'Drive',
                Vertical_Name__c = 'misc_retail_ui'
            )
        };
        insert businessVerticals;
        List<Business_Reference__c> bizRefsToInsert = new List<Business_Reference__c>();
        bizRefsToInsert.add(
            new Business_Reference__c(
                CurrencyIsoCode = 'USD',
                External_Id__c = '123456',
                External_Id_Source__c = 'MDS',
                Business_Name__c = 'Test Business Name',
                Default_Type__c = 'Corporate',
                Menu_UI_Type__c = 'Retail',
                Integration_Status__c = 'Success',
                Business_Vertical__c = businessVerticals[0].Id,
                Business_Group_Id__c = '234',
                Brand__c = brands[0].Id
            )
        );

        insert bizRefsToInsert;

        Test.startTest();
        BusinessReferencesSelector selector = new BusinessReferencesSelector();
        List<Business_Reference__c> result = selector.selectByBizId('123456');
        System.assertEquals(
            1,
            result.size(),
            'Expected to find 1 Business References with the given External ID'
        );
        Test.stopTest();
    }

    @isTest
    static void testWhenExternalIdAndDefaultTypePassedInThenReturnGraveyardBusinessReference() {
        List<Business_Vertical__c> businessVerticals = new List<Business_Vertical__c>{
            new Business_Vertical__c(
                Name = 'Test',
                Menu_UI_Type__c = 'Restaurant',
                Primary_Vertical__c = 'Alcohol',
                Product__c = 'Drive',
                Vertical_Name__c = 'misc_retail_ui'
            )
        };
        insert businessVerticals;
        Business_Reference__c busRef = new Business_Reference__c(
            CurrencyIsoCode = 'USD',
            External_Id__c = '123456',
            External_Id_Source__c = 'MDS',
            Business_Name__c = 'Test Business Name',
            Default_Type__c = 'Corporate',
            Primary_Vertical__c = ACCOUNT_PRIMARY_VERTICAL_ALCOHOL,
            Business_Vertical__c = businessVerticals[0].Id
        );

        Business_Reference__c busRef1 = new Business_Reference__c(
            CurrencyIsoCode = 'USD',
            External_Id__c = '1234567',
            External_Id_Source__c = 'MDS',
            Business_Name__c = 'Test Business Name1',
            Default_Type__c = 'COO Graveyard',
            Primary_Vertical__c = ACCOUNT_PRIMARY_VERTICAL_ALCOHOL,
            Business_Vertical__c = businessVerticals[0].Id
        );

        insert new List<Business_Reference__c>{ busRef, busRef1 };
        Test.startTest();
        Map<Id, Business_Reference__c> businessReferenceMap = new Map<Id, Business_Reference__c>(
            BusinessReferencesSelector.newInstance()
                .selectBusRefByExternalIdAndDefaultType(
                    new Set<String>{ '1234567' },
                    new Set<String>{ 'Corporate', 'COO Graveyard' }
                )
        );
        Test.stopTest();
        System.assertEquals(
            1,
            businessReferenceMap.size(),
            '1 Business References are expected to be returned for the given criteria'
        );
        System.assert(
            businessReferenceMap.containsKey(busRef1.Id),
            'This Business reference should be returned'
        );
    }

    /**
     * @description It is used for querying Business References with Integration Status as 'Success'
     * by matching businessIds.
     */
    @isTest
    private static void testWhenBusinessIdsAndAccountIdsPassedThenReturnMatchingBusinessReferences() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Account parentAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordTypeId = businessRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert parentAccount;

        Account storeAccount = new Account(
            Name = STORE_ACCOUNT_NAME,
            ParentId = parentAccount.Id,
            RecordTypeId = storeRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert storeAccount;
        Contract contract = new Contract(AccountId = storeAccount.Id);
        insert contract;
        Business_Reference__c businessReference = new Business_Reference__c(
            CurrencyIsoCode = CURRENCY_ISO_USD,
            External_Id__c = MOCK_BUSINESS_ID,
            External_Id_Source__c = EXTERNAL_ID_SOURCE_MDS,
            Business_Name__c = BUSINESS_ACCOUNT_NAME,
            Default_Type__c = DEFAULT_TYPE_CORPORATE,
            Integration_Status__c = INTEGRATION_STATUS_SUCCESS,
            Primary_Vertical__c = ACCOUNT_PRIMARY_VERTICAL_ALCOHOL
        );
        insert businessReference;
        List<WorkOrder> workOrders = new List<WorkOrder>();
        WorkOrder parentWorkOrder = new WorkOrder(
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            AccountId = parentAccount.Id,
            Contract__c = contract.Id,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Order_Protocol__c = ORDER_PROTOCOL_EMAIL,
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE_MARKETPLACE,
            Proposed_Date_of_Activation__c = System.today() + 7,
            Business_Id__c = MOCK_BUSINESS_ID
        );

        workOrders.add(parentWorkOrder);
        insert workOrders;
        Test.startTest();
        List<Business_Reference__c> businessReferenceList = BusinessReferencesSelector.newInstance()
            .selectMDSBusinessReferencesWithSuccessIntegrationStatusByBusinessIds(
                new Set<String>{ workOrders[0].Business_Id__c }
            );
        Test.stopTest();
        System.assertEquals(1, businessReferenceList.size(), EMPTY_LIST_ASSERT_MESSAGE);
        System.assertEquals(
            businessReference.Id,
            businessReferenceList[0].Id,
            BUSINESS_REFERENCE_ID_DO_NOT_MATCH_ASSERT_MESSAGE
        );
    }

    /**
     * @description It is used for querying Business References with Integration Status as 'Success'
     * by matching businessIds.
     */
    @isTest
    private static void testWhenBusinessIdsAndAccountIdsPassedThenNoBusinessReferencesReturned() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Account parentAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordTypeId = businessRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert parentAccount;

        Account storeAccount = new Account(
            Name = STORE_ACCOUNT_NAME,
            ParentId = parentAccount.Id,
            RecordTypeId = storeRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert storeAccount;
        Contract contract = new Contract(AccountId = storeAccount.Id);
        insert contract;
        Business_Reference__c businessReference = new Business_Reference__c(
            CurrencyIsoCode = CURRENCY_ISO_USD,
            External_Id__c = MOCK_EXTERNAL_ID,
            External_Id_Source__c = EXTERNAL_ID_SOURCE_MDS,
            Business_Name__c = BUSINESS_ACCOUNT_NAME,
            Default_Type__c = DEFAULT_TYPE_CORPORATE,
            Integration_Status__c = INTEGRATION_STATUS_SUCCESS,
            Primary_Vertical__c = ACCOUNT_PRIMARY_VERTICAL_ALCOHOL
        );
        insert businessReference;
        List<WorkOrder> workOrders = new List<WorkOrder>();
        WorkOrder parentWorkOrder = new WorkOrder(
            Activated_Centrally_AC__c = WORKORDER_ACTIVATED_CENTRALLY_YES,
            AccountId = parentAccount.Id,
            Contract__c = contract.Id,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Order_Protocol__c = ORDER_PROTOCOL_EMAIL,
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE_MARKETPLACE,
            Proposed_Date_of_Activation__c = System.today() + 7,
            Business_Id__c = MOCK_BUSINESS_ID
        );

        workOrders.add(parentWorkOrder);
        insert workOrders;
        Test.startTest();
        List<Business_Reference__c> businessReferenceList = BusinessReferencesSelector.newInstance()
            .selectMDSBusinessReferencesWithSuccessIntegrationStatusByBusinessIds(
                new Set<String>{ workOrders[0].Business_Id__c }
            );
        Test.stopTest();
        System.assertEquals(0, businessReferenceList.size(), INVALID_ASSERT_MESSAGE);
    }

    /**
     * @description @jira LEM-17697
     **/
    @isTest
    private static void testWhenSelectByBusinessVerticalBrandCurrencyExternalIdDefaultTypeThenReturnBusinessReference() {
        Id businessAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Account corporateAccountWithBrand = new Account(
            Name = 'McDonalds US',
            RecordTypeId = businessAccountRecordTypeId,
            Type = 'Corporate',
            Segment__c = 'SMB'
        );
        insert corporateAccountWithBrand;
        Brand__c brandKFC = new Brand__c(
            Name = 'KFC',
            Brand_Owner__c = corporateAccountWithBrand.Id
        );
        insert brandKFC;

        List<Business_Vertical__c> businessVerticals = new List<Business_Vertical__c>{
            new Business_Vertical__c(
                Name = 'Test',
                Menu_UI_Type__c = 'Restaurant',
                Primary_Vertical__c = 'Alcohol',
                Product__c = 'Drive',
                Vertical_Name__c = 'misc_retail_ui'
            )
        };
        insert businessVerticals;
        Business_Reference__c testBusinessReference = new Business_Reference__c(
            Business_Vertical__c = businessVerticals[0].Id,
            Brand__c = brandKFC.Id,
            CurrencyIsoCode = 'USD',
            External_Id_Source__c = 'MDS',
            Default_Type__c = 'Corporate'
        );
        insert testBusinessReference;
        Set<String> busVerticals = new Set<String>{ businessVerticals[0].Id };
        Set<String> brands = new Set<String>{ brandKFC.Id };
        Set<String> currencyCodes = new Set<String>{ 'USD' };

        // Call the method
        List<Business_Reference__c> result = BusinessReferencesSelector.newInstance()
            .selectByBusinessVerticalBrandCurrencyExternalIdDefaultType(
                busVerticals,
                brands,
                currencyCodes
            );
        // Verify the result
        Assert.areEqual(1, result.size(), RECORD_FOUND);
    }

    /**
     * @description Tests the basic functionality of selectAllBusinessIdsInAccountHierarchy
     * with a simple parent-child account hierarchy.
     * Scenario:
     * - Creates a parent account and a child account
     * - Creates a business reference associated with the child account
     * - Calls selectAllBusinessIdsInAccountHierarchy with the parent account ID
     * - Verifies that the method returns the correct business reference information
     */
    @isTest
    private static void testWhenAccountHierarchyProvidedThenReturnAllRelatedBusinessReferences() {
        // Get Record Type IDs
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();

        // Setup test data
        Account parentAccount = new Account(
            Name = 'Parent Account',
            RecordTypeId = businessRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT_SMB,
            BillingStreet = '123 Business St',
            BillingCity = 'Business City',
            BillingStateCode = 'NY',
            BillingPostalCode = '12345',
            BillingCountryCode = 'US'
        );
        insert parentAccount;

        Account childAccount = new Account(
            Name = 'Child Account',
            ParentId = parentAccount.Id,
            RecordTypeId = storeRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT_SMB,
            BillingStreet = '456 Store Ave',
            BillingCity = 'Store City',
            BillingStateCode = 'NY',
            BillingPostalCode = '67890',
            BillingCountryCode = 'US'
        );
        insert childAccount;

        Business_Vertical__c businessVertical = new Business_Vertical__c(
            Name = 'Test Vertical',
            Menu_UI_Type__c = 'Restaurant',
            Primary_Vertical__c = 'Alcohol',
            Product__c = 'Drive',
            Vertical_Name__c = 'misc_retail_ui'
        );
        insert businessVertical;

        Business_Reference__c businessReference = new Business_Reference__c(
            External_Id__c = '12345',
            External_Id_Source__c = 'MDS',
            Business_Name__c = 'Test Business',
            Business_Vertical__c = businessVertical.Id
        );
        insert businessReference;

        Xref__c xref = new Xref__c(
            Salesforce_Account_Name__c = childAccount.Id,
            Business_Reference__c = businessReference.Id,
            External_ID__c = '55555',
            External_ID_Source__c = 'MDS'
        );
        insert xref;

        // Execute test
        Test.startTest();
        Aggregate[] results = new BusinessReferencesSelector()
            .selectAllBusinessIdsInAccountHierarchy(new List<String>{ parentAccount.Id });
        Test.stopTest();

        // Verify results
        System.assertEquals(1, results.size(), 'Expected one aggregate result');
        Aggregate result = results[0];

        System.assertEquals(
            businessReference.Id,
            result.get('BusinessReferenceId'),
            'Business Reference Id mismatch'
        );
        System.assertEquals(
            businessReference.External_Id__c,
            result.get('BusinessReferenceExternalId'),
            'External Id mismatch'
        );
        System.assertEquals(
            businessReference.External_Id_Source__c,
            result.get('BusinessReferenceExternalIdSource'),
            'External Id Source mismatch'
        );
        System.assertEquals(
            businessReference.Business_Name__c,
            result.get('BusinessReferenceBusinessName'),
            'Business Name mismatch'
        );
        System.assertEquals(
            businessVertical.Vertical_Name__c,
            result.get('BusinessReferenceVerticalName'),
            'Business Vertical Name mismatch'
        );
        System.assertEquals(childAccount.Id, result.get('AccountId'), 'Account Id mismatch');
        System.assertEquals(
            parentAccount.Id,
            result.get('ParentAccountId1'),
            'Parent Account Id mismatch'
        );
    }

    /**
     * @description Tests a more complex scenario of selectAllBusinessIdsInAccountHierarchy
     * with a three-level account hierarchy and multiple business references.
     * Scenario:
     * - Creates a grandparent account, parent account, and child account
     * - Creates two business references, one associated with the child account and one with the parent account
     * - Calls selectAllBusinessIdsInAccountHierarchy with the grandparent account ID
     * - Verifies that the method returns correct information for both business references
     */
    @isTest
    private static void testWhenMultiLevelAccountHierarchyProvidedThenReturnAllRelatedBusinessReferences() {
        // Setup test data
        // Get Record Type IDs
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();

        Account grandparentAccount = new Account(
            Name = 'Grandparent Account',
            Segment__c = ACCOUNT_SEGMENT_SMB,
            BillingStreet = '123 Business St',
            BillingCity = 'Business City',
            BillingStateCode = 'NY',
            BillingPostalCode = '12345',
            BillingCountryCode = 'US',
            RecordTypeId = businessRecordTypeId
        );
        insert grandparentAccount;

        Account parentAccount = new Account(
            Name = 'Parent Account',
            ParentId = grandparentAccount.Id,
            Segment__c = ACCOUNT_SEGMENT_SMB,
            BillingStreet = '123 Business St',
            BillingCity = 'Business City',
            BillingStateCode = 'NY',
            BillingPostalCode = '12345',
            BillingCountryCode = 'US',
            RecordTypeId = businessRecordTypeId
        );
        insert parentAccount;

        Account childAccount = new Account(
            Name = 'Child Account',
            ParentId = parentAccount.Id,
            Segment__c = ACCOUNT_SEGMENT_SMB,
            BillingStreet = '456 Store Ave',
            BillingCity = 'Store City',
            BillingStateCode = 'NY',
            BillingPostalCode = '67890',
            BillingCountryCode = 'US',
            RecordTypeId = storeRecordTypeId
        );
        insert childAccount;

        Business_Vertical__c businessVertical = new Business_Vertical__c(
            Name = 'Test Vertical',
            Menu_UI_Type__c = 'Restaurant',
            Primary_Vertical__c = 'Alcohol',
            Product__c = 'Drive',
            Vertical_Name__c = 'misc_retail_ui'
        );
        insert businessVertical;

        Business_Reference__c businessReference1 = new Business_Reference__c(
            External_Id__c = '12345',
            External_Id_Source__c = 'MDS',
            Business_Name__c = 'Test Business 1',
            Business_Vertical__c = businessVertical.Id
        );
        Business_Reference__c businessReference2 = new Business_Reference__c(
            External_Id__c = '67890',
            External_Id_Source__c = 'MDS',
            Business_Name__c = 'Test Business 2',
            Business_Vertical__c = businessVertical.Id
        );
        insert new List<Business_Reference__c>{ businessReference1, businessReference2 };

        Xref__c xref1 = new Xref__c(
            Salesforce_Account_Name__c = childAccount.Id,
            Business_Reference__c = businessReference1.Id,
            External_Id__c = '55555',
            External_ID_Source__c = 'MDS'
        );
        Xref__c xref2 = new Xref__c(
            Salesforce_Account_Name__c = parentAccount.Id,
            Business_Reference__c = businessReference2.Id,
            External_Id__c = '66666',
            External_ID_Source__c = 'MDS'
        );
        insert new List<Xref__c>{ xref1, xref2 };

        // Execute test
        Test.startTest();
        List<Aggregate> results = new BusinessReferencesSelector()
            .selectAllBusinessIdsInAccountHierarchy(new List<String>{ grandparentAccount.Id });
        Test.stopTest();

        // Verify results
        System.assertEquals(2, results.size(), 'Expected two aggregate results');

        // Create a map of results using External_Id__c as the key
        Map<String, Aggregate> resultMap = new Map<String, Aggregate>();
        for (Aggregate result : results) {
            resultMap.put((String) result.get('BusinessReferenceExternalId'), result);
        }

        // Verify first result
        Aggregate result1 = resultMap.get('12345');
        System.assertNotEquals(null, result1, 'Result for External_Id__c 12345 not found');
        System.assertEquals(
            businessReference1.Id,
            result1.get('BusinessReferenceId'),
            'Business Reference 1 Id mismatch'
        );
        System.assertEquals(
            businessReference1.External_Id__c,
            result1.get('BusinessReferenceExternalId'),
            'External Id 1 mismatch'
        );
        System.assertEquals(childAccount.Id, result1.get('AccountId'), 'Child Account Id mismatch');
        System.assertEquals(
            parentAccount.Id,
            result1.get('ParentAccountId1'),
            'Parent Account Id mismatch'
        );
        System.assertEquals(
            grandparentAccount.Id,
            result1.get('ParentAccountId2'),
            'Grandparent Account Id mismatch'
        );

        // Verify second result
        Aggregate result2 = resultMap.get('67890');
        System.assertNotEquals(null, result2, 'Result for External_Id__c 67890 not found');
        System.assertEquals(
            businessReference2.Id,
            result2.get('BusinessReferenceId'),
            'Business Reference 2 Id mismatch'
        );
        System.assertEquals(
            businessReference2.External_Id__c,
            result2.get('BusinessReferenceExternalId'),
            'External Id 2 mismatch'
        );
        System.assertEquals(
            parentAccount.Id,
            result2.get('AccountId'),
            'Parent Account Id mismatch'
        );
        System.assertEquals(
            grandparentAccount.Id,
            result2.get('ParentAccountId1'),
            'Grandparent Account Id mismatch'
        );
    }
}