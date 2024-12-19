/**
 * @author Deloitte
 * @date 28/02/2022
 * @description This is test class for AccountsSelector class.
 * Suppressed Warnings for CyclomaticComplexity to avoid PMD failure
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.CyclomaticComplexity,PMD.NcssTypeCount')
public class AccountsSelectorTest {
    private static final String ACCOUNT_PARTNERSHIP_STATUS = 'Prospective Partner';
    private static final String ACCOUNT_BILLING_CITY = 'Missoula';
    private static final String ACCOUNT_BILLING_CITY_DRAWIN = 'Darwin';
    private static final String ACCOUNT_BILLING_COUNTRY = 'United States';
    private static final String ACCOUNT_BILLING_COUNTRY_AUSTRALIA = 'Australia';
    private static final String ACCOUNT_BILLING_POSTAL_CODE = '1234';
    private static final String ACCOUNT_BILLING_POSTAL_CODE_AUSTRALIA = '2890';
    private static final String ACCOUNT_BILLING_STATE = 'California';
    private static final String ACCOUNT_BILLING_STATE_VICTORIA = 'Victoria';
    private static final String ACCOUNT_BILLING_STREET = '221B Baker Street';
    private static final String ACCOUNT_BILLING_STREET_AUSTRALIA = 'AUSTRALIAN DEFENCE FORCES';
    private static final String ACCOUNT_BILLING_STREET_NORTH = 'North Baker Street';
    private static final String ACCOUNT_BILLING_STREET_SOUTH = 'South Baker Street';
    private static final String ACCOUNT_EXPERIENCE_STOREFRONT = 'Storefront';
    private static final String ACCOUNT_PRIMARY_VERTICAL_GIFTS = 'Gifts';
    private static final String ACCOUNT_SEGMENT_ENTERPRISE = 'Enterprise';
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    private static final String ACCOUNT_MEDAL_RANK_PLATINUM = 'Platinum';
    private static final String ACCOUNT_MEDAL_RANK_SILVER = 'Silver';
    private static final String ACCOUNT_MEDAL_RANK_GOLD = 'Gold';
    private static final String ACCOUNT_TYPE_FRANCHISEE = 'Franchisee';
    private static final String ACCOUNT_TYPE_CORPORATE = 'Corporate';
    private static final String ACCOUNT_MENU_UI_TYPE_RETAIL = 'Retail';
    private static final Schema.Fieldset FIELDS_TO_SHOW_ON_DUPLICATE_ACCOUNT_PAGE = SObjectType.Account.FieldSets.Bulk_Onboarding_Duplicate_Account_Fields;
    private static final String STATUS_ACTIVE = 'Active';
    private static final String ASSERT_MESSAGE_ACCOUNT_ID = 'Unexpected result: Account Id is not matching';
    private static final String ASSERT_MESSAGE_COUNT_MISMATCH = 'Unexpected result: Number of Accounts returned does not match the expected count';
    private static final String ASSERT_MESSAGE_COUNT_DOES_NOT_MATCH = 'Unexpected result: Number of stores returned does not match the expected count';
    private static final String ASSERT_MESSAGE_RECORD_TYPE_ID = 'Unexpected result: Record Type Id is not matching';
    private static final String ASSERT_MESSAGE_ACCOUNT_MISMATCH = 'Unexpected result: Account is not matching';
    private static final String ASSERT_MESSAGE_MEDAL_RANK_MISMATCH = 'Unexpected result: Medal Rank is not retrieved as expected';
    private static final String ASSERT_MESSAGE_COUNT_OF_MEDAL_RANK_MISMATCH = 'Unexpected result: Medal Rank count is not matching';
    private static final String BUSINESS_ACCOUNT_NAME = 'Test Business Account';
    private static final String BUSINESS_RECORD_TYPE_NAME = 'Business';
    private static final String CHILD_BUSINESS_ACCOUNT_NAME_AUS = 'Test Child Business AUS';
    private static final String CHILD_BUSINESS_ACCOUNT_NAME_CA = 'Test Child Business CA';
    private static final String CHILD_BUSINESS_ACCOUNT_NAME_US = 'Test Child Business US';
    private static final String FRANCHISE_ACCOUNT_NAME = 'Pizza Hut';
    private static final String IN_COVERAGE = 'In Coverage';
    private static final Integer NUMBER_OF_STORES = 2;
    private static final String NINTEX_USER_ALIAS = 'ninUser';
    private static final String NINTEX_USER_EMAIL_ID = 'nintexUser@testorg.com';
    private static final String NINTEX_USER_USERNAME = System.Label.NintexUsername + '.test';
    private static final String ONBOARDING_WORK_PLAN_TEMPLATE = 'Onboarding';
    private static final String ORDER_PROTOCOL_EMAIL = 'Email';
    private static final String PARENT_CORPORATE_ACCOUNT_NAME = 'Test Business Parent';
    private static final String PARENT_FRANCHISE_ACCOUNT_NAME = 'Test Yum Brands';
    private static final String RATE_CHANGE_ACTIVATION_STATUS = 'New';
    private static final String RATE_CHANGE_STATUS = 'Approved';
    private static final String STORE_ACCOUNT_DRIVE_NINTEX_ID = 'AccountsSelectorTestDriveNintexId';
    private static final String STORE_ACCOUNT_MARKETPLACE_NINTEX_ID = 'AccountsSelectorTestMarketPlaceNintexId';
    private static final String STORE_ACCOUNT_NO_NINTEX_ID = 'AccountsSelectorTestMarketPlaceNoNintexId';
    private static final String STORE_ACCOUNT_NAME = 'Test Store Account';
    private static final String STORE_ACCOUNT_NAME_DOMINO = 'Domino Account';
    private static final String STORE_ACCOUNT_LEGAL_BUSINESS_NAME = 'Test Legal Account ';
    private static final String STORE_RECORD_TYPE_NAME = 'Store';
    private static final Id STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Store')
        .getRecordTypeId();
    private static final String USER_ENCODING = 'UTF-8';
    private static final String USER_LAST_NAME = 'Testing';
    private static final String USER_LOCALE = 'en_US';
    private static final String USER_TIMEZONE = 'America/Los_Angeles';
    private static final String VERIFIED_STATUS = 'Verified';
    private static final String WORK_ORDER_AC = 'Yes';
    private static final String WORK_ORDER_MENU_TO_BE_COMPLETED_BY = 'Merchant';
    private static final String WORK_ORDER_STATUS = 'Planning';
    private static final String WORK_ORDER_TEMPLATE_ENTRY = 'Onboarding Marketplace';
    private static final String WORK_ORDER_TYPE_MARKETPLACE = 'Marketplace';
    private static final String WORK_ORDER_TYPE = 'COO';
    private static final String WORK_STEP_TEMPLATE_NAME = 'Review & Triage';
    private static final String XREF_PRESENT_ON_STORE_ACCOUNT_ASSERT_MESSAGE = 'Unexpected result: no Xrefs found on store Account';
    private static final String ONE_XREF_PRESENT_ON_STORE_ACCOUNT_ASSERT_MESSAGE = 'Unexpected result: exactly 1 Xrefs expected on store Account';
    private static final String XREF_EXTERNAL_ID_SOURCE = 'MDS';
    private static final String XREF_EXTERNALID_SOURCE_DRIVE = 'DriveDb';
    private static final String XREF_STATUS_ACTIVE = 'Active';
    private static final String XREF_STATUS_INACTIVE = 'Inactive';
    private static final String EMPTY_LIST_ASSERT_MESSAGE = 'Unexpected Result: number of records returned does not match the expected outcome';
    private static final Schema.Fieldset FIELDS_TO_QUERY = SObjectType.Account.FieldSets.Encrypted_Fields;
    private static final Schema.Fieldset FIELDS_TO_QUERY_FOR_STORE = SObjectType.Account.FieldSets.Store_Account_Information;
    private static final String AGREEMENT_TYPE_FRANCHISE_AGREEMENT = 'Franchise Agreement';
    private static final String CHILD_ACCOUNTS_DO_PRESENT_MATCH_ASSERT_MESSAGE = 'Unexpected result: Child Accounts does not present';
    private static final String PAYMENT_ACCOUNTS_DO_PRESENT_MATCH_ASSERT_MESSAGE = 'Unexpected result: Payment Accounts does not present';
    private static final String OPPORTUNITIES_DO_PRESENT_MATCH_ASSERT_MESSAGE = 'Unexpected result: Opportunities does not present';
    private static final String INITIATIVES_DO_PRESENT_MATCH_ASSERT_MESSAGE = 'Unexpected result: Initiatives does not present';
    private static final String WORK_ORDER_NOT_PRESENT_ASSERT_MESSAGE = 'Unexpected result: Work Orders does not present';
    private static final String SERVICE_PRESENT_ON_STORE_ACCOUNT_ASSERT_MESSAGE = 'Unexpected result: no Merchant_Service__c found on store Account';
    private static final String ACR_PRESENT_ON_STORE_ACCOUNT_ASSERT_MESSAGE = 'Unexpected result: no AccountContactRelation found on store Account';
    private static final String PAYMENT_ACCOUNT_PRESENT_ON_STORE_ACCOUNT_ASSERT_MESSAGE = 'Unexpected result: no Payment Accouont found on store Account';
    private static final String CONTRACT_PRESENT_ON_STORE_ACCOUNT_ASSERT_MESSAGE = 'Unexpected result: no Contract found on store Account';
    private static final String CONTROL_OF_PRICE_DOORDASH = 'DoorDash';
    private static final String CONTROL_OF_PRICE_MERCHANT = 'Merchant';
    private static final String ADDRESS_ID = '1234567';
    private static final String MERCHANT_SUPPLIED_ID = '3456';
    private static final String POS_INTEGRATION_TYPE = 'albertsons';
    private static final Id BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Business')
        .getRecordTypeId();
    private static final String UNIQUE_IDENTIFIER = '92108a53-e8d9-4a0c-9193-9152aeb86fe4';
    private static final String UNIQUE_IDENTIFIER2 = '92108a53-e8d9-4a0c-9193-9152aeb86fe5';
    private static final String MISMATCH_IN_ACR_COUNT_ERROR_MESSAGE = 'Unexpected Error: The Account Contact Relations were not fetched as expected.';
    private static final String MISMATCH_IN_LATEST_OPP_ERROR_MESSAGE = 'Unexpected Error:The latest Opportunity does not match';
    private static final String BA_PRESENT_ON_STORE_ACCOUNT_ASSERT_MESSAGE = 'Unexpected result: no Brand Associations found on Account';

    /**
     * @description To setup Work Order template relevant test data.
     */
    @testSetup
    @SuppressWarnings('PMD.UnusedLocalVariable')
    private static void setupData() {
        Work_Order_Template__c workOrderTemplate = new Work_Order_Template__c(
            Name = WORK_ORDER_TYPE_MARKETPLACE,
            Type__c = WORK_ORDER_TYPE_MARKETPLACE
        );
        insert workOrderTemplate;
        WorkPlanTemplate onboardingWorkPlanTemplate = new WorkPlanTemplate(
            Name = ONBOARDING_WORK_PLAN_TEMPLATE,
            Type__c = ONBOARDING_WORK_PLAN_TEMPLATE,
            isActive = true
        );
        insert onboardingWorkPlanTemplate;
        WorkStepTemplate reviewTriageWorkStepTemplate = new WorkStepTemplate(
            Name = WORK_STEP_TEMPLATE_NAME,
            IsActive = true
        );
        insert reviewTriageWorkStepTemplate;
        WorkPlanTemplateEntry workPlanTemplateEntry = new WorkPlanTemplateEntry(
            WorkPlanTemplateId = onboardingWorkPlanTemplate.Id,
            WorkStepTemplateId = reviewTriageWorkStepTemplate.Id,
            ExecutionOrder = 1,
            Active__c = true
        );
        insert workPlanTemplateEntry;
        Work_Order_Template_Entry__c workOrderTemplateEntry = new Work_Order_Template_Entry__c(
            Name = WORK_ORDER_TEMPLATE_ENTRY,
            Work_Order_Template__c = workOrderTemplate.Id,
            Work_Plan_Template__c = onboardingWorkPlanTemplate.Id
        );
        insert workOrderTemplateEntry;

        //Set up CPQ Data
        SBQQ.TriggerControl.disable();

        Product2 product = CPQTestDataFactory.createProduct(true);
        PricebookEntry pbe = CPQTestDataFactory.createPriceBookEntry(product, 'USD', true);
        Product2 cashOnDeliveryProduct = CPQTestDataFactory.createCoDProduct(false);
        cashOnDeliveryProduct.Family = 'Drive';
        insert cashOnDeliveryProduct;
        PricebookEntry pbeCoD = CPQTestDataFactory.createPriceBookEntry(
            cashOnDeliveryProduct,
            'USD',
            true
        );
        Product2 product2 = CPQTestDataFactory.createProduct(false);
        product2.Family = 'Drive Promotion';
        insert product2;
        PricebookEntry pbe2 = CPQTestDataFactory.createPriceBookEntry(product2, 'USD', true);

        Account testAccount = TestDataFactory.createAccount(false);
        testAccount.Segment__c = ACCOUNT_SEGMENT_SMB;
        insert testAccount;
        Opportunity testOpp = CPQTestDataFactory.createOpportunity(testAccount.Id, false);
        testOpp.Estimated_Number_of_Stores__c = 1;
        insert testOpp;
        SBQQ__Quote__c quote = CPQTestDataFactory.createQuote(testOpp, testAccount, null, true);
        SBQQ__QuoteLine__c quoteLine = CPQTestDataFactory.createQuoteLine(product, quote, true);
        SBQQ__QuoteLine__c quoteLineCoD = CPQTestDataFactory.createQuoteLine(
            cashOnDeliveryProduct,
            quote,
            true
        );
        SBQQ__QuoteLine__c quoteLine2 = CPQTestDataFactory.createQuoteLine(product2, quote, true);

        Order order = CPQTestDataFactory.createOrder(testAccount, testOpp, quote, false);
        order.SBQQ__Quote__c = null; //null out quote so order is not activated.
        insert order;

        OrderItem orderItem = CPQTestDataFactory.createOrderItem(order, quoteLine, pbe.Id, true);
        OrderItem orderItem2 = CPQTestDataFactory.createOrderItem(order, quoteLine2, pbe2.Id, true);

        Contract contract = CPQTestDataFactory.createContract(testAccount.Id, true);

        SBQQ__Subscription__c subRec = new SBQQ__Subscription__c();
        subRec.SBQQ__Product__c = product.Id;
        subRec.SBQQ__Contract__c = contract.Id;
        subRec.SBQQ__Account__c = testAccount.Id;
        subRec.SBQQ__Quantity__c = 200;
        subRec.SBQQ__OrderProduct__c = orderItem.Id;
        insert subRec;

        SBQQ__Subscription__c subRec2 = new SBQQ__Subscription__c();
        subRec2.SBQQ__Product__c = product2.Id;
        subRec2.SBQQ__Contract__c = contract.Id;
        subRec2.SBQQ__Account__c = testAccount.Id;
        subRec2.SBQQ__Quantity__c = 200;
        subRec2.SBQQ__OrderProduct__c = orderItem2.Id;
        insert subRec2;

        SBQQ.TriggerControl.enable();
    }

    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        Account testAccount1 = new Account(
            Name = 'Test Account 1',
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert testAccount1;
        Account testAccount2 = new Account(
            Name = 'Test Account 2',
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert testAccount2;
        Account testAccount3 = new Account(
            Name = 'Test Account 3',
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert testAccount3;
        Test.startTest();
        AccountsSelector accountsInstance = new AccountsSelector();
        List<Account> accounts = accountsInstance.selectById(
            new Set<Id>{ testAccount1.Id, testAccount2.Id }
        );
        System.assertEquals(accounts.size(), 2, 'The list should Contain 2 Accounts');

        Schema.SObjectType typeOfObj = accountsInstance.getSObjectType();
        System.assertEquals(
            Schema.Account.SObjectType,
            typeOfObj,
            'The object type must be Account'
        );
        List<Schema.SObjectField> fieldList = accountsInstance.getSObjectFieldList();
        Test.stopTest();
        System.assertEquals(
            new List<Schema.SObjectField>{
                Account.Id,
                Account.Name,
                Account.Account_Lifecycle_Status__c,
                Account.Activated_Centrally_AC__c,
                Account.Activation_Status__c,
                Account.AccountSource,
                Account.BillingCountryCode,
                Account.BillingStateCode,
                Account.BillingStreet,
                Account.BillingCity,
                Account.BillingPostalCode,
                Account.BillingCountry,
                Account.BillingState,
                Account.Brand__c,
                Account.Converted_Lead_Id__c,
                Account.Change_of_Ownership_Effective_Date__c,
                Account.CurrencyIsoCode,
                Account.Deck_Rank__c,
                Account.Description,
                Account.Disallow_PDOA_Override__c,
                Account.Drive_Nintex_Id__c,
                Account.Encrypted_Tax_Id__c,
                Account.Franchise_Parent__c,
                Account.Marketplace_Nintex_Id__c,
                Account.Menu_Setup_Method__c,
                Account.Menu_to_be_Completed_By__c,
                Account.Merchant_Supplied_ID__c,
                Account.Most_Recent_Nintex_Use_Case__c,
                Account.NDA_Expiration_Date__c,
                Account.NDA_Status__c,
                Account.Order_Protocol__c,
                Account.OwnerId,
                Account.ParentId,
                Account.Partnership_Status__c,
                Account.Primary_Vertical__c,
                Account.Proposed_Date_of_Activation__c,
                Account.Proposed_Date_of_Menu__c,
                Account.Proposed_Date_of_Tablet__c,
                Account.Proposed_Date_of_Implementation__c,
                Account.RecordTypeId,
                Account.Starting_Point_ID__c,
                Account.Sales_Notes_for_Menu_Team__c,
                Account.Segment__c,
                Account.SubMarket__c,
                Account.TaxID__c,
                Account.Type,
                Account.Ultimate_Parent_Account__c,
                Account.User_Sets_PDOM_Value__c,
                Account.User_Sets_PDOT_Value__c,
                Account.Is_MDS_Activated__c,
                Account.Is_Lead_Converted_To_Existing_Account__c,
                Account.Integration_Go_Live__c,
                Account.POS_Integration_Type__c,
                Account.POS_Integration_ID__c,
                Account.Control_of_Price__c,
                Account.Experience__c,
                Account.Show_MP_Bz_Id_Update_Banner__c,
                Account.Business_Vertical__c,
                Account.RecordType.Name,
                Account.Record_Type_Name__c,
                Account.Owner.Name,
                Account.Owner.Id,
                Account.Brand__r.Name,
                Account.Brand__r.Id,
                Account.Total_Number_Of_Stores__c,
                Account.Franchise_Parent__r.Additional_Verticals__c,
                Account.Alcohol_Addendum_Signed__c,
                Account.Time_Zone_Backend__c,
                Account.Services_Fees__c,
                Account.SubMarket__r.Name,
                Account.Unique_Identifier__c,
                Account.Legal_Business_Name__c,
                Account.Is_Additional_Store__c,
                Account.Price_Range__c,
                Account.Phone,
                Account.Order_Protocol_Email__c,
                Account.POS_System__c,
                Account.Menu_URL__c
            },
            fieldList,
            ' Mismatch in field list'
        );
    }

    @isTest
    private static void testWhenAccountIdsAreProvidedThenAccountsAreReceived() {
        List<Account> accountRecs = new List<Account>{
            new Account(name = 'TestAccount1', Segment__c = ACCOUNT_SEGMENT_SMB),
            new Account(name = 'TestAccount2', Segment__c = ACCOUNT_SEGMENT_SMB)
        };
        insert accountRecs;
        Set<String> accountIds = new Set<String>{
            String.valueOf(accountRecs[0].Id),
            String.valueOf(accountRecs[1].Id)
        };
        Test.startTest();
        AccountsSelector accountsInstance = new AccountsSelector();
        List<Account> accountList = accountsInstance.selectById(accountIds);
        Test.stopTest();
        System.assertEquals(accountList.size() != null, true, 'account map is empty');
        System.assertEquals(accountList.size() == 2, true, 'account map is empty');
    }

    @isTest
    private static void testWhenAccountIdsAreProvidedThenAccountsAreReceivedForBatchMode() {
        List<Account> accountRecs = new List<Account>{
            new Account(name = 'TestAccount1', Segment__c = ACCOUNT_SEGMENT_SMB),
            new Account(name = 'TestAccount2', Segment__c = ACCOUNT_SEGMENT_SMB)
        };
        insert accountRecs;

        Set<Id> accountIds = new Set<Id>{ accountRecs[0].Id, accountRecs[1].Id };
        Test.startTest();
        AccountsSelector accountsInstance = new AccountsSelector();
        Database.QueryLocator queryLocator = accountsInstance.selectByIdsForBatchProcess(
            accountIds
        );
        List<Account> accountsFromBatch = Database.query(queryLocator.getQuery());
        Test.stopTest();
        System.assertEquals(
            accountsFromBatch.size() == 2,
            true,
            'accounts from batch query are not returned as expected'
        );
    }

    @isTest
    private static void testWhenAccountIdsAndActivationsAreProvidedThenAccountsAreReceived() {
        List<Account> accountRecs = new List<Account>{
            new Account(name = 'TestAccount1', Segment__c = ACCOUNT_SEGMENT_SMB),
            new Account(name = 'TestAccount2', Segment__c = ACCOUNT_SEGMENT_SMB)
        };
        insert accountRecs;
        Set<Id> accountIds = new Set<Id>{ accountRecs[0].Id, accountRecs[1].Id };
        AccountsSelector accountsInstance = new AccountsSelector();
        Test.startTest();
        List<Account> accountList = accountsInstance.selectById(accountIds, true);
        Test.stopTest();
        System.assertEquals(accountList.size() != null, true, 'account map is empty');
        System.assertEquals(accountList.size() == 2, true, 'account map is empty');
    }

    @isTest
    private static void testWhenSelectByOpportunityThenReturnParentAccountsForTheGivenOpportunities() {
        Test.startTest();
        List<Account> accountRecs = new List<Account>{
            new Account(name = 'TestAccount1', Segment__c = ACCOUNT_SEGMENT_SMB),
            new Account(name = 'TestAccount2', Segment__c = ACCOUNT_SEGMENT_SMB)
        };
        insert accountRecs;

        List<Opportunity> opportunitiesRec = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(3),
                Deal_Type__c = 'Standard',
                Opportunity_Sub_Type__c = 'Former Partner',
                AccountId = accountRecs[0].Id
            ),
            new Opportunity(
                Name = 'Test2',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(3),
                Deal_Type__c = 'Standard',
                Opportunity_Sub_Type__c = 'Former Partner',
                AccountId = accountRecs[1].Id
            )
        };
        AccountsSelector accountsInstance = new AccountsSelector();
        List<Account> accountList = accountsInstance.selectByOpportunity(opportunitiesRec);
        AccountsSelector.newInstance();
        Test.stopTest();
        System.assertEquals(accountList.size() != null, true, 'account map is empty');
    }

    /**
     * @description This is test class for AccountsSelectors method to query child accounts.
     */
    @isTest
    private static void testWhenSelectChildAccountsThenReturnAccountsWithGivenParentIds() {
        Test.startTest();
        Account testAccount1 = new Account(
            Name = 'Test Account 1',
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert testAccount1;

        Account testAccount2 = new Account(
            Name = 'Test Account 2',
            ParentId = testAccount1.Id,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert testAccount2;
        AccountsSelector accountsInstance = new AccountsSelector();
        List<Account> accounts = accountsInstance.selectChildAccounts(
            new Set<Id>{ testAccount1.Id, testAccount2.Id }
        );
        Test.stopTest();
        System.assertEquals(1, accounts.size(), 'The list size does not match');
    }

    /**
     * @description To test query on Account to retrieve store Accounts having parent as corporate account
     */
    @isTest
    private static void testWhenParentCorporateAccountsThenStoreAccountsReturned() {
        Test.startTest();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Account mcDonaldCorporate = new Account(
            Name = 'Parent Account',
            RecordTypeId = businessRecordTypeId,
            Type = 'Corporate',
            Primary_Vertical__c = 'CPG',
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert mcDonaldCorporate;
        Account mcDonaldStore = new Account(
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = ACCOUNT_BILLING_STATE,
            Name = STORE_ACCOUNT_NAME,
            ParentId = mcDonaldCorporate.Id,
            RecordTypeId = storeRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert mcDonaldStore;
        AccountsSelector accountsInstance = new AccountsSelector();
        List<Account> storeAccountsHavingCorporateParent = accountsInstance.getStoreAccountsWithParentCorporate(
            new Set<Id>{ mcDonaldStore.Id }
        );
        Test.stopTest();
        System.assertEquals(
            1,
            storeAccountsHavingCorporateParent.size(),
            'The list size does not match'
        );
        System.assertEquals(
            storeRecordTypeId,
            storeAccountsHavingCorporateParent[0].RecordTypeId,
            'Retrieved accounts are not of store type'
        );
    }

    /**
     * @description To test query on Account to retrieve store Accounts related to business Accounts
     * having associated franchise Parent and related Xref's external source as Drive DB.
     */
    @isTest
    private static void testWhenParentCorporateAccountsProvidedThenDriveStoreAccountsWithFranchiseParentReturned() {
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Test.startTest();
        Account corporateParent = new Account(
            Name = 'Parent Account',
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert corporateParent;
        Account franchiseParent = new Account(
            Name = 'Franchise Parent Account',
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert franchiseParent;
        Account storeAccount = new Account(
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = ACCOUNT_BILLING_STATE,
            Name = STORE_ACCOUNT_NAME,
            ParentId = corporateParent.Id,
            RecordTypeId = storeRecordTypeId,
            Franchise_Parent__c = franchiseParent.Id,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert storeAccount;
        Business_Reference__c businessReference = new Business_Reference__c(
            CurrencyIsoCode = 'USD',
            External_Id_Source__c = XREF_EXTERNALID_SOURCE_DRIVE,
            Business_Name__c = 'Test Business Name',
            Default_Type__c = 'Corporate',
            External_Id__c = 'External Id'
        );
        insert businessReference;
        Xref__c xref = new Xref__c(
            External_ID_Source__c = XREF_EXTERNALID_SOURCE_DRIVE,
            Salesforce_Account_Name__c = storeAccount.Id,
            External_ID__c = storeAccount.Id,
            Xref_Status__c = XREF_STATUS_ACTIVE,
            Business_Reference__c = businessReference.Id
        );
        insert xref;
        Contract testContract = new Contract(
            Name = 'Test Contract1',
            AccountId = corporateParent.Id
        );
        insert testContract;
        Agreement__c agreement = new Agreement__c(
            Name = 'Agreement1',
            Account__c = franchiseParent.Id,
            Contract__c = testContract.Id,
            Type__c = AGREEMENT_TYPE_FRANCHISE_AGREEMENT,
            Status__c = XREF_STATUS_ACTIVE
        );
        insert agreement;
        AccountsSelector accountsInstance = new AccountsSelector();
        List<Account> accounts = accountsInstance.selectStoreAccountsByParentIds(
            new Set<String>{ corporateParent.Id },
            XREF_EXTERNALID_SOURCE_DRIVE,
            testContract.Id
        );
        Test.stopTest();
        System.assertEquals(1, accounts.size(), 'The list size does not match');
    }

    /**
     * @description To test query on Account to retrieve store Accounts related to business Accounts
     * having associated franchise Parent and related Xref's external source as MDS.
     */
    @isTest
    private static void testWhenParentCorporateAccountsProvidedThenMDSStoreAccountsWithFranchiseParentReturned() {
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Test.startTest();
        Account corporateParent = new Account(
            Name = 'Parent Account',
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert corporateParent;
        Account franchiseParent = new Account(
            Name = 'Franchise Parent Account',
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert franchiseParent;
        Account storeAccount = new Account(
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = ACCOUNT_BILLING_STATE,
            Name = STORE_ACCOUNT_NAME,
            ParentId = corporateParent.Id,
            RecordTypeId = storeRecordTypeId,
            Franchise_Parent__c = franchiseParent.Id,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert storeAccount;
        Business_Reference__c businessReference = new Business_Reference__c(
            CurrencyIsoCode = 'USD',
            External_Id_Source__c = XREF_EXTERNAL_ID_SOURCE,
            Business_Name__c = 'Test Business Name',
            Default_Type__c = 'Corporate',
            External_Id__c = 'External Id'
        );
        insert businessReference;
        Xref__c xref = new Xref__c(
            External_ID_Source__c = XREF_EXTERNAL_ID_SOURCE,
            Salesforce_Account_Name__c = storeAccount.Id,
            External_ID__c = storeAccount.Id,
            Xref_Status__c = XREF_STATUS_ACTIVE,
            Business_Reference__c = businessReference.Id
        );
        insert xref;
        Contract testContract = new Contract(
            Name = 'Test Contract1',
            AccountId = corporateParent.Id
        );
        insert testContract;
        Agreement__c agreement = new Agreement__c(
            Name = 'Agreement1',
            Account__c = franchiseParent.Id,
            Contract__c = testContract.Id,
            Type__c = AGREEMENT_TYPE_FRANCHISE_AGREEMENT,
            Status__c = XREF_STATUS_ACTIVE
        );
        insert agreement;
        List<Account> accounts = new AccountsSelector()
            .selectStoreAccountsByParentIds(
                new Set<String>{ corporateParent.Id },
                XREF_EXTERNAL_ID_SOURCE,
                testContract.Id
            );
        Test.stopTest();
        System.assertEquals(1, accounts.size(), 'The list size does not match');
    }

    /**
     * @description This method tests if all Accounts with past NDA Dates are queries or not.
     */
    @isTest
    private static void testWhenAccountHasExpiredNdaThenItIsFetched() {
        Test.startTest();
        Account expiredAccount = new Account(
            Name = 'Test Account Batch 1',
            NDA_Expiration_Date__c = Date.today() - 1,
            NDA_Status__c = 'Active',
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert expiredAccount;

        Account activeAccount = new Account(
            Name = 'Test Account Batch 2',
            NDA_Expiration_Date__c = Date.today() + 1,
            NDA_Status__c = 'Active',
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert activeAccount;

        AccountsSelector accountsSelectorForIntegrationTest = new AccountsSelector();
        Database.QueryLocator queryAccount = accountsSelectorForIntegrationTest.selectAccountsWithExpiredNda();

        Database.QueryLocatorIterator iteratorOnAccount = queryAccount.iterator();

        Account fetchedAccount = new Account();

        while (iteratorOnAccount.hasNext()) {
            fetchedAccount = (Account) iteratorOnAccount.next();
        }
        Test.stopTest();
        System.assertEquals(
            'Test Account Batch 1',
            fetchedAccount.Name,
            'The expected Account was not fetched'
        );
    }

    /**
     * @description This is test class for AccountsSelectors method to query child accounts.
     */
    @isTest
    private static void testWhenSelectNonFranchiseAccountsThenReturnAccountsWithSubTypeNotEqualToFranchisee() {
        List<Account> accountRecs = new List<Account>{
            new Account(
                name = 'TestAccount1',
                Type = 'Franchisee',
                Segment__c = ACCOUNT_SEGMENT_SMB
            ),
            new Account(name = 'TestAccount2', Segment__c = ACCOUNT_SEGMENT_SMB),
            new Account(name = 'TestAccount3', Segment__c = ACCOUNT_SEGMENT_SMB)
        };
        insert accountRecs;
        Set<Id> accountIds = new Set<Id>{ accountRecs[0].Id, accountRecs[1].Id, accountRecs[2].Id };
        AccountsSelector accountsInstance = new AccountsSelector();
        List<Account> accounts = accountsInstance.selectNonFranchiseeAccountsById(accountIds);
        System.assertEquals(2, accounts.size(), 'The list size does not match');
    }

    /**
     * @description This is test class for getting sum of all child store count
     */
    @isTest
    private static void testWhenSelectSumOfChildStoreCountThenCountSumOfStoreCount() {
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Test.startTest();
        Account grandParentAccount = new Account(
            Name = 'Grand Parent Account1',
            RecordTypeId = accRecordTypeBusiness,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert grandParentAccount;

        List<Account> parentAccounts = new List<Account>{
            new Account(
                Name = 'Parent Account1',
                ParentId = grandParentAccount.Id,
                RecordTypeId = accRecordTypeBusiness,
                Corporate_Owned_Store_Count__c = 2,
                Franchise_Owned_Store_Count__c = 1,
                Segment__c = ACCOUNT_SEGMENT_SMB
            ),
            new Account(
                Name = 'Parent Account2',
                ParentId = grandParentAccount.Id,
                RecordTypeId = accRecordTypeBusiness,
                Corporate_Owned_Store_Count__c = 3,
                Franchise_Owned_Store_Count__c = 2,
                Segment__c = ACCOUNT_SEGMENT_SMB
            )
        };
        insert parentAccounts;

        Set<Id> parentIds = new Set<Id>{ grandParentAccount.Id };
        AccountsSelector accountsInstance = new AccountsSelector();

        Aggregate[] accountSumOfChildStoreCount = accountsInstance.selectSumOfChildStoreCount(
            parentIds
        );
        Test.stopTest();
        System.assertEquals(
            3,
            accountSumOfChildStoreCount[0].get('franchiseCount'),
            'Franchise count does not match'
        );
        System.assertEquals(
            5,
            accountSumOfChildStoreCount[0].get('corporateCount'),
            'Corporate count does not match'
        );
    }

    /**
     * @description This is test class for getting count of franchise owned via parent
     */
    @isTest
    private static void testWhenSelectFranchiseOwnedViaParentCountThenCountDirectFranchiseCountViaParent() {
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id accRecordTypeStore = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Test.startTest();
        List<Account> parentAccounts = new List<Account>{
            new Account(
                Name = 'Parent Account1',
                RecordTypeId = accRecordTypeBusiness,
                Segment__c = ACCOUNT_SEGMENT_SMB
            ),
            new Account(
                Name = 'Franchise Account2',
                RecordTypeId = accRecordTypeBusiness,
                Segment__c = ACCOUNT_SEGMENT_SMB
            )
        };
        insert parentAccounts;

        List<Account> storeAccounts = new List<Account>{
            new Account(
                Name = 'Account1',
                ParentId = parentAccounts[0].Id,
                Franchise_Parent__c = parentAccounts[1].Id,
                RecordTypeId = accRecordTypeStore,
                BillingStreet = 'abc street',
                BillingCountry = 'United States',
                BillingState = 'New Jersey',
                BillingCity = 'test',
                BillingPostalCode = '12345',
                Segment__c = ACCOUNT_SEGMENT_SMB
            ),
            new Account(
                Name = 'Account2',
                ParentId = parentAccounts[0].Id,
                RecordTypeId = accRecordTypeStore,
                BillingStreet = 'abc street',
                BillingCountry = 'United States',
                BillingState = 'New Jersey',
                BillingCity = 'test',
                BillingPostalCode = '12345',
                Segment__c = ACCOUNT_SEGMENT_SMB
            )
        };
        insert storeAccounts;

        Set<Id> parentIds = new Set<Id>{ parentAccounts[0].Id, parentAccounts[1].Id };
        AccountsSelector accountsInstance = new AccountsSelector();

        Aggregate[] franchiseOwnedViaParentCount = accountsInstance.selectFranchiseOwnedViaParentCount(
            parentIds
        );
        Test.stopTest();

        System.assertEquals(1, franchiseOwnedViaParentCount.size(), 'List size does not match');
        System.assertEquals(
            parentAccounts[0].Id,
            franchiseOwnedViaParentCount[0].get('Id'),
            'Id does not match'
        );
        System.assertEquals(
            1,
            franchiseOwnedViaParentCount[0].get('countIds'),
            'Franchise count does not match'
        );
    }

    /**
     * @description This is test class for getting count of franchise owner via franchise parent
     */
    @isTest
    private static void testWhenSelectFranchiseOwnedViaFranchiseCountThenCountDirectFranchiseCountViaFranchise() {
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id accRecordTypeStore = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Test.startTest();
        List<Account> parentAccounts = new List<Account>{
            new Account(
                Name = 'Parent Account1',
                RecordTypeId = accRecordTypeBusiness,
                Segment__c = ACCOUNT_SEGMENT_SMB
            ),
            new Account(
                Name = 'Franchise Account2',
                RecordTypeId = accRecordTypeBusiness,
                Segment__c = ACCOUNT_SEGMENT_SMB
            )
        };
        insert parentAccounts;

        List<Account> storeAccounts = new List<Account>{
            new Account(
                Name = 'Account1',
                ParentId = parentAccounts[0].Id,
                Franchise_Parent__c = parentAccounts[1].Id,
                RecordTypeId = accRecordTypeStore,
                BillingStreet = 'abc street',
                BillingCountry = 'United States',
                BillingState = 'New Jersey',
                BillingCity = 'test',
                BillingPostalCode = '12345',
                Segment__c = ACCOUNT_SEGMENT_SMB
            ),
            new Account(
                Name = 'Account2',
                ParentId = parentAccounts[0].Id,
                RecordTypeId = accRecordTypeStore,
                BillingStreet = 'abc street',
                BillingCountry = 'United States',
                BillingState = 'New Jersey',
                BillingCity = 'test',
                BillingPostalCode = '12345',
                Segment__c = ACCOUNT_SEGMENT_SMB
            )
        };
        insert storeAccounts;

        Set<Id> parentIds = new Set<Id>{ parentAccounts[0].Id, parentAccounts[1].Id };
        AccountsSelector accountsInstance = new AccountsSelector();

        Aggregate[] franchiseOwnedViaFranchiseCount = accountsInstance.selectFranchiseOwnedViaFranchiseCount(
            parentIds
        );
        Test.stopTest();

        System.assertEquals(1, franchiseOwnedViaFranchiseCount.size(), 'List size does not match');
        System.assertEquals(
            parentAccounts[1].Id,
            franchiseOwnedViaFranchiseCount[0].get('Id'),
            'Id does not match'
        );
        System.assertEquals(
            1,
            franchiseOwnedViaFranchiseCount[0].get('countIds'),
            'Franchise count does not match'
        );
    }

    /**
     * @description This is test class for getting count of corporate accounts
     */
    @isTest
    private static void testWhenSelectCorporateCountThenCountDirectCorporateCount() {
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id accRecordTypeStore = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Test.startTest();
        List<Account> parentAccounts = new List<Account>{
            new Account(
                Name = 'Parent Account1',
                RecordTypeId = accRecordTypeBusiness,
                Type = '',
                Partnership_Status__c = '',
                Account_Lifecycle_Status__c = '',
                Primary_Vertical__c = 'Alcohol',
                Segment__c = ACCOUNT_SEGMENT_SMB
            ),
            new Account(
                Name = 'Franchise Account2',
                RecordTypeId = accRecordTypeBusiness,
                Type = '',
                Partnership_Status__c = '',
                Account_Lifecycle_Status__c = '',
                Primary_Vertical__c = 'Alcohol',
                Segment__c = ACCOUNT_SEGMENT_SMB
            )
        };
        insert parentAccounts;

        List<Account> storeAccounts = new List<Account>{
            new Account(
                Name = 'Account1',
                ParentId = parentAccounts[0].Id,
                Franchise_Parent__c = parentAccounts[1].Id,
                RecordTypeId = accRecordTypeStore,
                BillingStreet = 'abc street',
                BillingCountry = 'United States',
                BillingState = 'New Jersey',
                BillingCity = 'test',
                BillingPostalCode = '12345',
                Segment__c = ACCOUNT_SEGMENT_SMB
            ),
            new Account(
                Name = 'Account2',
                ParentId = parentAccounts[0].Id,
                RecordTypeId = accRecordTypeStore,
                BillingStreet = 'abc street',
                BillingCountry = 'United States',
                BillingState = 'New Jersey',
                BillingCity = 'test',
                BillingPostalCode = '12345',
                Segment__c = ACCOUNT_SEGMENT_SMB
            )
        };
        insert storeAccounts;

        Set<Id> parentIds = new Set<Id>{ parentAccounts[0].Id, parentAccounts[1].Id };
        AccountsSelector accountsInstance = new AccountsSelector();

        Aggregate[] corporateCount = accountsInstance.selectCorporateCount(parentIds);
        Test.stopTest();

        System.assertEquals(1, corporateCount.size(), 'List size does not match');
        System.assertEquals(parentAccounts[0].Id, corporateCount[0].get('Id'), 'Id does not match');
        System.assertEquals(1, corporateCount[0].get('countIds'), 'Franchise count does not match');
    }

    /**
     * @description This is test class for AccountsSelectors method to query child accounts
     */
    @isTest
    private static void testWhenSelectParentAccountsThenReturnAccountsWithMerchantVerticalValue() {
        Test.startTest();
        Account testAccount1 = new Account(
            name = 'TestAccount1',
            Primary_Vertical__c = 'Convenience',
            Additional_Verticals__c = 'Convenience;Grocery',
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert testAccount1;

        Account testAccount2 = new Account(
            Name = 'Test Account 2',
            ParentId = testAccount1.Id,
            Primary_Vertical__c = 'Convenience',
            Additional_Verticals__c = 'Alcohol ;Floral',
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert testAccount2;

        AccountsSelector accountsInstance = new AccountsSelector();
        List<Account> accounts = accountsInstance.selectChildMerchantVerticals(
            new Set<Id>{ testAccount1.Id }
        );
        Test.stopTest();
        System.assertEquals(1, accounts.size(), 'The list size does not match');
    }

    /**
     * @description It is used to test if Store Accounts with Primary Verticals are retrieved when
     * Parent Account Ids are passed.
     */
    @isTest
    private static void testWhenSelectParentAccountsThenReturnStoreAccountsWithMerchantVerticalValue() {
        Account mcDBusiness = new Account(
            name = 'McDonalds Business',
            Primary_Vertical__c = 'Convenience',
            Additional_Verticals__c = 'Convenience;Grocery',
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert mcDBusiness;

        Account mcDStoreAccount = new Account(
            ParentId = mcDBusiness.Id,
            Primary_Vertical__c = 'Hot & Prepared',
            Name = STORE_ACCOUNT_NAME,
            RecordTypeId = STORE_RECORD_TYPE_ID,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert mcDStoreAccount;

        AccountsSelector accountsInstance = new AccountsSelector();
        Test.startTest();
        List<Account> accounts = accountsInstance.selectStoreAccountsWithPrimaryVerticalByParentAccount(
            new Set<Id>{ mcDBusiness.Id }
        );
        Test.stopTest();
        System.assertEquals(1, accounts.size(), 'The list size does not match');
    }

    /**
     * @description This test class querying account with Bussiness record type and Account life
     * cycle status not equal to In Pursuit.
     */
    @isTest
    private static void testWhenSelectBusinessAccountsThenReturnAccountsWithAccountLifeCycleStatusNotEqualToInPursuit() {
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id accRecordTypeStore = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Test.startTest();
        List<Account> accountRecs = new List<Account>{
            new Account(
                name = 'TestAccount1',
                RecordtypeId = accRecordTypeBusiness,
                Account_Lifecycle_Status__c = 'Unvetted',
                BillingCountry = 'United States',
                BillingStreet = '123 Test Street',
                BillingCity = 'Missoula',
                BillingState = 'Montana',
                BillingPostalCode = '59801',
                Segment__c = ACCOUNT_SEGMENT_SMB
            ),
            new Account(
                name = 'TestAccount2',
                RecordtypeId = accRecordTypeStore,
                Account_Lifecycle_Status__c = 'Unvetted',
                BillingStreet = '123 Test Street',
                BillingCity = 'Missoula',
                BillingPostalCode = '59801',
                BillingCountry = 'United States',
                BillingState = 'Montana',
                Segment__c = ACCOUNT_SEGMENT_SMB
            ),
            new Account(
                name = 'TestAccount3',
                RecordtypeId = accRecordTypeBusiness,
                Account_Lifecycle_Status__c = 'In Pursuit',
                BillingCountry = 'United States',
                BillingStreet = '123 Test Street',
                BillingCity = 'Missoula',
                BillingState = 'Montana',
                BillingPostalCode = '59801',
                Segment__c = ACCOUNT_SEGMENT_SMB
            )
        };
        insert accountRecs;
        Set<Id> accountIds = new Set<Id>{ accountRecs[0].Id, accountRecs[1].Id, accountRecs[2].Id };
        AccountsSelector accountsInstance = new AccountsSelector();
        List<Account> accounts = accountsInstance.selectUnverifiedBusinessAccountsById(accountIds);
        Test.stopTest();
        System.assertEquals(1, accounts.size(), 'The list size does not match');
        System.assertEquals(
            accounts[0].Account_Lifecycle_Status__c,
            'Unvetted',
            'The list size does not match'
        );
    }

    /**
     * @description This test class querying account with Bussiness record type and Account life cycle status equal to In Pursuit.
     */
    @isTest
    private static void testWhenSelectBusinessAccountsThenReturnAccountsWithAccountLifeCycleStatusEqualToInPursuit() {
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id accRecordTypeStore = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Test.startTest();
        List<Account> accountRecs = new List<Account>{
            new Account(
                name = 'TestAccount1',
                RecordtypeId = accRecordTypeBusiness,
                Account_Lifecycle_Status__c = 'Unvetted',
                BillingCountry = 'United States',
                BillingStreet = '123 Test Street',
                BillingCity = 'Missoula',
                BillingState = 'Montana',
                BillingPostalCode = '59801',
                Segment__c = ACCOUNT_SEGMENT_SMB
            ),
            new Account(
                name = 'TestAccount2',
                RecordtypeId = accRecordTypeStore,
                Account_Lifecycle_Status__c = 'In Pursuit',
                BillingStreet = '123 Test Street',
                BillingCity = 'Missoula',
                BillingPostalCode = '59801',
                BillingCountry = 'United States',
                BillingState = 'Montana',
                Segment__c = ACCOUNT_SEGMENT_SMB
            ),
            new Account(
                name = 'TestAccount3',
                RecordtypeId = accRecordTypeBusiness,
                Account_Lifecycle_Status__c = 'In Pursuit',
                BillingCountry = 'United States',
                BillingStreet = '123 Test Street',
                BillingCity = 'Missoula',
                BillingState = 'Montana',
                BillingPostalCode = '59801',
                Segment__c = ACCOUNT_SEGMENT_SMB
            )
        };
        insert accountRecs;
        Set<Id> accountIds = new Set<Id>{ accountRecs[0].Id, accountRecs[1].Id, accountRecs[2].Id };
        AccountsSelector accountsInstance = new AccountsSelector();
        List<Account> accounts = accountsInstance.selectInPursuitBusinessAccountsById(accountIds);
        Test.stopTest();
        System.assertEquals(1, accounts.size(), 'The list size does not match');
        System.assertEquals(
            accounts[0].Account_Lifecycle_Status__c,
            'In Pursuit',
            'The list size does not match'
        );
    }

    /**
     * @description This is test class for getting count of business accounts with partnership status
     */
    @isTest
    private static void testWhenSelectCountOfChildrenBusinessAccountsByPartnershipStatusThenCountPartnershipStatus() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Id channelPartnerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Channel_Partner')
            .getRecordTypeId();
        Test.startTest();
        List<Account> parentAccounts = new List<Account>{
            new Account(
                Name = 'Parent Account1',
                RecordTypeId = businessRecordTypeId,
                Segment__c = ACCOUNT_SEGMENT_SMB
            ),
            new Account(
                Name = 'Parent Account2',
                RecordTypeId = businessRecordTypeId,
                Segment__c = ACCOUNT_SEGMENT_SMB
            )
        };
        insert parentAccounts;

        List<Account> businessAndStoreAccounts = new List<Account>{
            new Account(
                Name = 'Account1',
                ParentId = parentAccounts[0].Id,
                Partnership_Status__c = 'Prospective Partner',
                RecordTypeId = businessRecordTypeId,
                Segment__c = ACCOUNT_SEGMENT_SMB
            ),
            new Account(
                Name = 'Account2',
                ParentId = parentAccounts[1].Id,
                Partnership_Status__c = 'Existing Partner',
                RecordTypeId = businessRecordTypeId,
                Segment__c = ACCOUNT_SEGMENT_SMB
            ),
            new Account(
                Name = 'Account3',
                ParentId = parentAccounts[0].Id,
                Activation_Status__c = 'Deactivated',
                RecordTypeId = storeRecordTypeId,
                BillingStreet = 'abc street',
                BillingCity = 'Missoula',
                BillingPostalCode = '59801',
                BillingCountry = 'United States',
                BillingState = 'Montana',
                Segment__c = ACCOUNT_SEGMENT_SMB
            ),
            new Account(
                Name = 'Account4',
                ParentId = parentAccounts[1].Id,
                Activation_Status__c = 'Active',
                RecordTypeId = storeRecordTypeId,
                BillingStreet = '123 Test Street',
                BillingCity = 'Missoula',
                BillingPostalCode = '59801',
                BillingCountry = 'United States',
                BillingState = 'Montana',
                Segment__c = ACCOUNT_SEGMENT_SMB
            ),
            new Account(
                Name = 'Account5',
                Partnership_Status__c = 'Existing Partner',
                RecordTypeId = businessRecordTypeId,
                Segment__c = ACCOUNT_SEGMENT_SMB
            ),
            new Account(
                Name = 'Account6',
                ParentId = parentAccounts[1].Id,
                Partnership_Status__c = 'Existing Partner',
                RecordTypeId = channelPartnerRecordTypeId,
                Segment__c = ACCOUNT_SEGMENT_SMB
            )
        };
        insert businessAndStoreAccounts;

        Set<Id> parentIds = new Set<Id>{ parentAccounts[0].Id, parentAccounts[1].Id };
        AccountsSelector accountsInstance = new AccountsSelector();

        Aggregate[] countOfAccountWithPartnershipStatus = accountsInstance.selectCountOfChildrenBusinessAccountsByPartnershipStatus(
            parentIds
        );
        Set<String> statusesRetrieved = new Set<String>();
        for (Aggregate eachAggregate : countOfAccountWithPartnershipStatus) {
            statusesRetrieved.add((String) eachAggregate.get('status'));
        }
        Test.stopTest();

        System.assertEquals(
            1,
            countOfAccountWithPartnershipStatus[0].get('countIds'),
            'Count does not match'
        );
        System.assertEquals(
            true,
            statusesRetrieved.contains('Prospective Partner'),
            'Business Accounts of status Prospective Partner were not retrieved as expected.'
        );
        System.assertEquals(
            1,
            countOfAccountWithPartnershipStatus[1].get('countIds'),
            'Count does not match'
        );
        System.assertEquals(
            true,
            statusesRetrieved.contains('Existing Partner'),
            'Business Accounts of status Existing Partner were not retrieved as expected.'
        );
    }

    /**
     * @description This is test class for getting count of store accounts grouped by activation
     * status and parent Ids.
     */
    @isTest
    private static void testWhenSelectCountOfChildrenStoreAccountsByActivationStatusThenCountPartnershipStatus() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Id channelPartnerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Channel_Partner')
            .getRecordTypeId();
        Test.startTest();
        List<Account> parentAccounts = new List<Account>{
            new Account(
                Name = 'Parent Account1',
                RecordTypeId = businessRecordTypeId,
                Segment__c = ACCOUNT_SEGMENT_SMB
            ),
            new Account(
                Name = 'Parent Account2',
                RecordTypeId = businessRecordTypeId,
                Segment__c = ACCOUNT_SEGMENT_SMB
            )
        };
        insert parentAccounts;

        List<Account> businessAndStoreAccounts = new List<Account>{
            new Account(
                Name = 'Account1',
                ParentId = parentAccounts[0].Id,
                Partnership_Status__c = 'Prospective Partner',
                RecordTypeId = businessRecordTypeId,
                Segment__c = ACCOUNT_SEGMENT_SMB
            ),
            new Account(
                Name = 'Account2',
                ParentId = parentAccounts[1].Id,
                Partnership_Status__c = 'Existing Partner',
                RecordTypeId = businessRecordTypeId,
                Segment__c = ACCOUNT_SEGMENT_SMB
            ),
            new Account(
                Name = 'Account3',
                ParentId = parentAccounts[0].Id,
                Activation_Status__c = 'Deactivated',
                RecordTypeId = storeRecordTypeId,
                BillingStreet = '123 Test Street',
                BillingCity = 'Missoula',
                BillingPostalCode = '59801',
                BillingCountry = 'United States',
                BillingState = 'Montana',
                Segment__c = ACCOUNT_SEGMENT_SMB
            ),
            new Account(
                Name = 'Account4',
                ParentId = parentAccounts[1].Id,
                Activation_Status__c = 'Active',
                RecordTypeId = storeRecordTypeId,
                BillingStreet = '123 Test Street',
                BillingCity = 'Missoula',
                BillingPostalCode = '59801',
                BillingCountry = 'United States',
                BillingState = 'Montana',
                Segment__c = ACCOUNT_SEGMENT_SMB
            ),
            new Account(
                Name = 'Account5',
                Partnership_Status__c = 'Existing Partner',
                RecordTypeId = businessRecordTypeId,
                Segment__c = ACCOUNT_SEGMENT_SMB
            ),
            new Account(
                Name = 'Account6',
                ParentId = parentAccounts[1].Id,
                Partnership_Status__c = 'Existing Partner',
                RecordTypeId = channelPartnerRecordTypeId,
                Segment__c = ACCOUNT_SEGMENT_SMB
            )
        };
        insert businessAndStoreAccounts;

        Set<Id> parentIds = new Set<Id>{ parentAccounts[0].Id, parentAccounts[1].Id };
        AccountsSelector accountsInstance = new AccountsSelector();

        Aggregate[] countOfAccountWithActivationStatus = accountsInstance.selectCountOfChildrenStoreAccountsByActivationStatus(
            parentIds
        );
        Set<Id> parentIdsRetrieved = new Set<Id>();
        Set<String> statusesRetrieved = new Set<String>();
        for (Aggregate eachAggregate : countOfAccountWithActivationStatus) {
            parentIdsRetrieved.add((Id) eachAggregate.get('Id'));
            statusesRetrieved.add((String) eachAggregate.get('status'));
        }
        Test.stopTest();

        System.assertEquals(
            true,
            parentIdsRetrieved.contains(parentAccounts[0].Id),
            'Expected parent is not in set'
        );
        System.assertEquals(
            true,
            parentIdsRetrieved.contains(parentAccounts[1].Id),
            'Expected parent is not in set'
        );
        System.assertEquals(
            1,
            countOfAccountWithActivationStatus[0].get('countIds'),
            'Count does not match'
        );
        System.assertEquals(
            true,
            statusesRetrieved.contains('Deactivated'),
            'Store Accounts of status Deactivated were not retrieved as expected.'
        );
        System.assertEquals(
            1,
            countOfAccountWithActivationStatus[1].get('countIds'),
            'Count does not match'
        );
        System.assertEquals(
            true,
            statusesRetrieved.contains('Active'),
            'Store Accounts of status Active were not retrieved as expected.'
        );
    }

    /**
     * @description To test related Contact & Xref object details from Account.
     * @JIRA# LEM-1158
     */
    @isTest
    private static void testWhenStoreIdThenSelectChildContactsAndXrefs() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Test.startTest();

        Account parentAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordTypeId = businessRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert parentAccount;
        Account storeAccount = new Account(
            Name = STORE_ACCOUNT_NAME,
            ParentId = parentAccount.Id,
            Partnership_Status__c = ACCOUNT_PARTNERSHIP_STATUS,
            RecordTypeId = storeRecordTypeId,
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = ACCOUNT_BILLING_STATE,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert storeAccount;
        Xref__c xref = new Xref__c(
            External_ID_Source__c = XREF_EXTERNAL_ID_SOURCE,
            Salesforce_Account_Name__c = storeAccount.Id,
            External_ID__c = storeAccount.Id,
            Xref_Status__c = XREF_STATUS_ACTIVE
        );
        insert xref;
        AccountsSelector accountsInstance = new AccountsSelector();
        List<Account> storeAccountDetails = accountsInstance.selectRelatedChildsById(
            new Set<Id>{ storeAccount.Id }
        );
        Test.stopTest();

        System.assertEquals(
            false,
            storeAccountDetails[0].Xrefs__r.isEmpty(),
            XREF_PRESENT_ON_STORE_ACCOUNT_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test related records from Account.
     * @JIRA# LEM-6405
     */
    @isTest
    private static void testWhenStoreIdThenSelectChildRecords() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Id paymentAccountRecordTypeId = Schema.SObjectType.Payment_Account__c.getRecordTypeInfosByDeveloperName()
            .get('Payments')
            .getRecordTypeId();

        Test.startTest();
        Account parentAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordTypeId = businessRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert parentAccount;
        Account storeAccount = new Account(
            Name = STORE_ACCOUNT_NAME,
            ParentId = parentAccount.Id,
            Partnership_Status__c = ACCOUNT_PARTNERSHIP_STATUS,
            RecordTypeId = storeRecordTypeId,
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = ACCOUNT_BILLING_STATE,
            Address_Id__c = '12345',
            Alcohol_Addendum_Signed__c = false,
            Legal_Business_Name__c = 'Legal Name LLC',
            Menu_UI_Type__c = ACCOUNT_MENU_UI_TYPE_RETAIL,
            Primary_Vertical__c = ACCOUNT_PRIMARY_VERTICAL_GIFTS,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert storeAccount;
        Xref__c xref = new Xref__c(
            External_ID_Source__c = XREF_EXTERNAL_ID_SOURCE,
            Salesforce_Account_Name__c = storeAccount.Id,
            External_ID__c = '223344',
            Xref_Status__c = XREF_STATUS_ACTIVE,
            Unified_Store_ID__c = '12345678'
        );
        Xref__c xref2 = new Xref__c(
            External_ID_Source__c = XREF_EXTERNAL_ID_SOURCE,
            Salesforce_Account_Name__c = storeAccount.Id,
            External_ID__c = '223344',
            Xref_Status__c = XREF_STATUS_INACTIVE,
            Unified_Store_ID__c = '12345678'
        );
        insert new List<Xref__c>{ xref, xref2 };
        SBQQ__Subscription__c subscription = new SBQQ__Subscription__c(SBQQ__Quantity__c = 1);
        insert subscription;
        Merchant_Service__c mxService = new Merchant_Service__c(
            Account__c = storeAccount.Id,
            Status__c = STATUS_ACTIVE,
            Product_Name__c = 'Test123',
            Subscription__c = subscription.Id
        );
        insert mxService;
        Contact contact = new Contact(
            AccountId = storeAccount.Id,
            FirstName = 'TestFirst',
            LastName = 'TestLast',
            Email = 'test@testemail.com'
        );
        insert contact;

        Payment_Account__c paymentAccount = new Payment_Account__c(
            RecordtypeId = paymentAccountRecordTypeId,
            Business_Account__c = parentAccount.Id,
            Bank_Account_Number__c = '752948359734',
            RoutingNumber__c = '873549457',
            Entity_Type__c = 'Company',
            Billing_Contact_Name__c = contact.Id
        );
        insert paymentAccount;

        Account_Payment_Account_Relation__c childPaymentAccountRelation = new Account_Payment_Account_Relation__c(
            Payment_Account__c = paymentAccount.id,
            Account__c = storeAccount.Id
        );
        insert childPaymentAccountRelation;

        Contract contract = new Contract(AccountId = storeAccount.Id);
        insert contract;

        AccountsSelector accountsInstance = new AccountsSelector();
        List<Account> storeAccountDetails = accountsInstance.selectRelatedChildsById(
            new Set<Id>{ storeAccount.Id }
        );
        Test.stopTest();
        System.assertEquals(
            false,
            storeAccountDetails[0].Xrefs__r.isEmpty(),
            XREF_PRESENT_ON_STORE_ACCOUNT_ASSERT_MESSAGE
        );
        System.assertEquals(
            1,
            storeAccountDetails[0].Xrefs__r.size(),
            ONE_XREF_PRESENT_ON_STORE_ACCOUNT_ASSERT_MESSAGE
        );
        System.assertEquals(
            false,
            storeAccountDetails[0].Services__r.isEmpty(),
            SERVICE_PRESENT_ON_STORE_ACCOUNT_ASSERT_MESSAGE
        );
        System.assertEquals(
            false,
            storeAccountDetails[0].AccountContactRelations.isEmpty(),
            ACR_PRESENT_ON_STORE_ACCOUNT_ASSERT_MESSAGE
        );
        System.assertEquals(
            false,
            storeAccountDetails[0].Account_Payment_Account_Relations__r.isEmpty(),
            PAYMENT_ACCOUNT_PRESENT_ON_STORE_ACCOUNT_ASSERT_MESSAGE
        );
        System.assertEquals(
            false,
            storeAccountDetails[0].Contracts.isEmpty(),
            CONTRACT_PRESENT_ON_STORE_ACCOUNT_ASSERT_MESSAGE
        );
    }

    /**
     * @description This test class is used to test getSelectedAccount method
     */
    @isTest
    private static void testWhenGetSelectedAccountThenReturnAccountDetails() {
        Test.startTest();
        List<Account> accountRecs = new List<Account>{
            new Account(
                Name = 'TestAccount1',
                Account_Lifecycle_Status__c = 'Unvetted',
                BillingCountry = 'United States',
                BillingStreet = '123 Test Street',
                BillingCity = 'Missoula',
                BillingState = 'Montana',
                BillingPostalCode = '59801',
                Segment__c = ACCOUNT_SEGMENT_SMB
            )
        };
        insert accountRecs;
        Set<String> fieldsToQuery = new Set<String>{
            'Id',
            'Account_Lifecycle_Status__c',
            'BillingCountry',
            'Name'
        };
        List<Id> recordIds = new List<Id>{ accountRecs[0].Id };
        AccountsSelector accountsInstance = new AccountsSelector();
        List<Account> accounts = accountsInstance.selectFilteredAccount(fieldsToQuery, recordIds);
        Test.stopTest();
        System.assertEquals(1, accounts.size(), 'The list size does not match');
        System.assertEquals(accounts[0].Name, 'TestAccount1', 'The value does not match');
        System.assertEquals(
            accounts[0].Account_Lifecycle_Status__c,
            'Unvetted',
            'The value does not match'
        );
        System.assertNotEquals(accounts[0].Id, null, 'The value does not match');
        System.assertEquals(
            accounts[0].BillingCountry,
            'United States',
            'The value does not match'
        );
    }

    /**
     * @description This test class is used to test selectHierachyChildAccounts method
     */
    @isTest
    private static void testWhenSelectHierachyChildAccountsThenReturnAccountDetails() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Id channelPartnerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Channel_Partner')
            .getRecordTypeId();
        Test.startTest();
        List<Account> parentAccounts = new List<Account>{
            new Account(
                Name = 'Test Parent',
                RecordTypeId = businessRecordTypeId,
                BillingCountry = 'United States',
                BillingStreet = '123 Test Street',
                BillingCity = 'Missoula',
                BillingState = 'Montana',
                BillingPostalCode = '59801',
                Segment__c = ACCOUNT_SEGMENT_SMB
            )
        };
        insert parentAccounts;

        List<Account> childAccounts = new List<Account>{
            new Account(
                Name = 'Test Child 1',
                RecordTypeId = businessRecordTypeId,
                ParentId = parentAccounts[0].Id,
                BillingCountry = 'United States',
                BillingStreet = '123 Test Street',
                BillingCity = 'Missoula',
                BillingState = 'Montana',
                BillingPostalCode = '59801',
                Segment__c = ACCOUNT_SEGMENT_SMB
            ),
            new Account(
                Name = 'Test Child 2',
                RecordTypeId = storeRecordTypeId,
                ParentId = parentAccounts[0].Id,
                BillingStreet = '123 Test Street',
                BillingCity = 'Missoula',
                BillingPostalCode = '59801',
                BillingCountry = 'United States',
                BillingState = 'Montana',
                Segment__c = ACCOUNT_SEGMENT_SMB
            ),
            new Account(
                Name = 'Test Child 3',
                RecordTypeId = storeRecordTypeId,
                Franchise_Parent__c = parentAccounts[0].Id,
                BillingStreet = '123 Test Street',
                BillingCity = 'Missoula',
                BillingPostalCode = '59801',
                BillingCountry = 'United States',
                BillingState = 'Montana',
                Segment__c = ACCOUNT_SEGMENT_SMB
            ),
            new Account(
                Name = 'Test Child 4',
                RecordTypeId = channelPartnerRecordTypeId,
                ParentId = parentAccounts[0].Id,
                BillingCountry = 'United States',
                BillingStreet = '123 Test Street',
                BillingCity = 'Missoula',
                BillingState = 'Montana',
                BillingPostalCode = '59801',
                Segment__c = ACCOUNT_SEGMENT_SMB
            )
        };
        insert childAccounts;
        Map<String, SObjectField> fieldMap = Account.getSObjectType().getDescribe().fields.getMap();
        Schema.SObjectField parentSObjectField = fieldMap.get('ParentId');

        Set<String> fieldsToQuery = new Set<String>{
            'Id',
            'BillingCountry',
            'Name',
            'RecordType.DeveloperName'
        };
        List<Id> recordIds = new List<Id>{ parentAccounts[0].Id };
        AccountsSelector accountsInstance = new AccountsSelector();
        List<Account> accounts = accountsInstance.selectHierachyChildAccounts(
            fieldsToQuery,
            parentSObjectField,
            recordIds
        );
        Test.stopTest();

        System.assertEquals(2, accounts.size(), 'The list size does not match');
        System.assertEquals(accounts[0].Name, 'Test Child 1', 'The value does not match');
        System.assertEquals(
            accounts[0].BillingCountry,
            'United States',
            'The value does not match'
        );
        System.assertNotEquals(accounts[0].Id, null, 'The value does not match');
        System.assertEquals(
            accounts[0].RecordType.DeveloperName,
            BUSINESS_RECORD_TYPE_NAME,
            'The value does not match'
        );
        System.assertEquals(
            accounts[1].BillingCountry,
            'United States',
            'The value does not match'
        );
        System.assertNotEquals(accounts[1].Id, null, 'The value does not match');
        System.assertEquals(
            accounts[1].RecordType.DeveloperName,
            STORE_RECORD_TYPE_NAME,
            'The value does not match'
        );
    }

    /**
     * @description This method tests if all Accounts with past NDA Dates are queries or not.
     */
    @isTest
    private static void testWhenTopsDownAutomationThenAccountFieldsFetched() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Test.startTest();

        Account parentAccount = new Account(
            Name = 'TestAccount1',
            Segment__c = 'SMB',
            RecordTypeId = businessRecordTypeId
        );
        insert parentAccount;

        Account childAccount = new Account(
            Name = 'Test Account 2',
            ParentId = parentAccount.Id,
            Ultimate_Parent_Account__c = parentAccount.Id,
            Segment__c = 'Mid-Market',
            RecordTypeId = storeRecordTypeId,
            BillingCountry = 'United States',
            BillingState = 'California',
            BillingPostalCode = '12345',
            BillingCity = 'ABC',
            BillingStreet = 'street'
        );
        insert childAccount;

        AccountsSelector accountsSelectorForIntegrationTest = new AccountsSelector();
        Database.QueryLocator queryAccount = accountsSelectorForIntegrationTest.selectAccountAttributesForTopDownAutomationBatch();

        Database.QueryLocatorIterator iteratorOnAccount = queryAccount.iterator();

        Account fetchedAccount = new Account();
        List<Account> accountRecord = new List<Account>();
        while (iteratorOnAccount.hasNext()) {
            fetchedAccount = (Account) iteratorOnAccount.next();
            accountRecord.add(fetchedAccount);
        }
        Test.stopTest();

        System.assertEquals('SMB', accountRecord[1].Segment__c, 'Invalid segment');
    }
    /**
     * @description This is test class for AccountsSelectors method to query child accounts
     */
    @isTest
    private static void testWhenSelectAccountsThenReturnStoreAccounts() {
        Id storeAccRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();
        Id businessAccRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Test.startTest();

        List<Account> accountsList = new List<Account>{
            new Account(
                Name = 'Test 1',
                RecordTypeId = storeAccRecordType,
                BillingStreet = '123 Test Street',
                BillingCity = 'Missoula',
                BillingPostalCode = '59801',
                BillingCountry = 'United States',
                BillingState = 'Montana',
                Segment__c = ACCOUNT_SEGMENT_SMB
            ),
            new Account(
                Name = 'Test 2',
                RecordTypeId = businessAccRecordType,
                BillingStreet = '121213 Test Street',
                BillingCity = 'Missoula',
                BillingPostalCode = '50801',
                BillingCountry = 'United States',
                BillingState = 'Montana',
                Segment__c = ACCOUNT_SEGMENT_SMB
            )
        };

        insert accountsList;

        Set<Id> accountIDset = new Set<Id>{ accountsList[0].Id, accountsList[1].Id };
        AccountsSelector accountsInstance = new AccountsSelector();
        List<Account> accounts = accountsInstance.selectStoreAccountsById(accountIDset);
        Test.stopTest();
        System.assertEquals(1, accounts.size(), 'Returns only 1 store Account');
    }

    /**
     * @description To test query on Account to fetch in-coverage verified store Accounts
     * and associated Xrefs which are related to the passed business Account and
     * doesn't have any child WorkOrders associated with the passed parent Work Order.
     * @JIRA# LEM-2013
     */
    @isTest
    private static void testWhenBusinessIdsAndParentWorkOrderIdPassedThenFetchVerifiedStoreDetailsAndChildXrefs() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Test.startTest();
        Account parentAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordTypeId = businessRecordTypeId,
            Corporate_Owned_Store_Count__c = 1,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert parentAccount;
        Account storeAccount = new Account(
            Address_Verification_Status__c = VERIFIED_STATUS,
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = ACCOUNT_BILLING_STATE,
            Coverage__c = IN_COVERAGE,
            Name = STORE_ACCOUNT_NAME,
            ParentId = parentAccount.Id,
            Partnership_Status__c = ACCOUNT_PARTNERSHIP_STATUS,
            RecordTypeId = storeRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert storeAccount;
        Contract contract = new Contract(AccountId = storeAccount.Id);
        insert contract;
        Xref__c xref = new Xref__c(
            External_ID_Source__c = XREF_EXTERNAL_ID_SOURCE,
            Salesforce_Account_Name__c = storeAccount.Id,
            External_ID__c = storeAccount.Id,
            Xref_Status__c = XREF_STATUS_ACTIVE
        );
        insert xref;
        WorkOrder parentWorkOrder = new WorkOrder(
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            AccountId = parentAccount.Id,
            Contract__c = contract.Id,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Order_Protocol__c = ORDER_PROTOCOL_EMAIL,
            Proposed_Date_of_Activation__c = System.today() + 7,
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE_MARKETPLACE
        );
        insert parentWorkOrder;
        Schema.SObjectField parentField = Account.ParentId;
        AccountsSelector accountsInstance = new AccountsSelector();
        List<Account> verifiedStores = accountsInstance.selectVerifiedStoreAccountsByBusinessId(
            new Set<Id>{ parentAccount.Id },
            parentWorkOrder.Id,
            parentField
        );
        Test.stopTest();
        System.assertEquals(storeAccount.Id, verifiedStores[0].Id, ASSERT_MESSAGE_ACCOUNT_ID);
        System.assertEquals(
            false,
            verifiedStores[0].Xrefs__r.isEmpty(),
            XREF_PRESENT_ON_STORE_ACCOUNT_ASSERT_MESSAGE
        );
    }

    /**
     * @description This is test class for AccountsSelectors method to query store Accounts
     * by nintextIds
     */
    @isTest
    private static void testWhenSelectAccountsThenReturnStoreAccountsWithNinTexIds() {
        Id storeAccRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Test.startTest();

        List<Account> accountsList = new List<Account>{
            new Account(
                Name = 'Test 1',
                RecordTypeId = storeAccRecordType,
                Marketplace_Nintex_Id__c = '12345678',
                Drive_Nintex_Id__c = null,
                BillingStreet = ACCOUNT_BILLING_STREET,
                BillingCity = ACCOUNT_BILLING_CITY,
                BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
                BillingCountry = ACCOUNT_BILLING_COUNTRY,
                BillingState = ACCOUNT_BILLING_STATE,
                Segment__c = ACCOUNT_SEGMENT_SMB
            ),
            new Account(
                Name = 'Test 2',
                RecordTypeId = businessRecordTypeId,
                Marketplace_Nintex_Id__c = '12345678',
                Drive_Nintex_Id__c = null,
                BillingStreet = ACCOUNT_BILLING_STREET,
                BillingCity = ACCOUNT_BILLING_CITY,
                BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
                BillingCountry = ACCOUNT_BILLING_COUNTRY,
                BillingState = ACCOUNT_BILLING_STATE,
                Segment__c = ACCOUNT_SEGMENT_SMB
            ),
            new Account(
                Name = 'Test 3',
                RecordTypeId = storeAccRecordType,
                Marketplace_Nintex_Id__c = null,
                Drive_Nintex_Id__c = '12345678',
                BillingStreet = ACCOUNT_BILLING_STREET,
                BillingCity = ACCOUNT_BILLING_CITY,
                BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
                BillingCountry = ACCOUNT_BILLING_COUNTRY,
                BillingState = ACCOUNT_BILLING_STATE,
                Segment__c = ACCOUNT_SEGMENT_SMB
            ),
            new Account(
                Name = 'Test 4',
                RecordTypeId = businessRecordTypeId,
                Marketplace_Nintex_Id__c = null,
                Drive_Nintex_Id__c = '12345678',
                BillingStreet = ACCOUNT_BILLING_STREET,
                BillingCity = ACCOUNT_BILLING_CITY,
                BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
                BillingCountry = ACCOUNT_BILLING_COUNTRY,
                BillingState = ACCOUNT_BILLING_STATE,
                Segment__c = ACCOUNT_SEGMENT_SMB
            )
        };

        insert accountsList;

        Set<String> nintextIds = new Set<String>{ '12345678' };
        AccountsSelector accountsInstance = new AccountsSelector();
        List<Account> accounts = accountsInstance.selectStoreAccountsByMarketplaceNintextIds(
            nintextIds
        );
        Test.stopTest();

        System.assertEquals(1, accounts.size(), 'Returns only 1 store Account');
        List<Account> driveaccounts = accountsInstance.selectStoreAccountsByDriveNintextIds(
            nintextIds
        );
        System.assertEquals(1, driveaccounts.size(), 'Returns only 1 store Account');
    }

    /**
     * @description To test store accounts are selected by Marketplace/Drive Nintex Id
     * based on the passed Nintex Ids.
     */
    @isTest
    private static void testWhenDriveOrMarketplaceNintexIdsPassedThenStoreAccountsReturned() {
        Account businessAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        businessAccount.Segment__c = ACCOUNT_SEGMENT_SMB;
        insert businessAccount;
        User nintexUser = new User(
            Alias = NINTEX_USER_ALIAS,
            Email = NINTEX_USER_EMAIL_ID,
            EmailEncodingKey = USER_ENCODING,
            LastName = USER_LAST_NAME,
            LanguageLocaleKey = USER_LOCALE,
            LocaleSidKey = USER_LOCALE,
            ProfileId = UserInfo.getProfileId(),
            TimeZoneSidKey = USER_TIMEZONE,
            UserName = NINTEX_USER_USERNAME
        );
        Test.startTest();
        System.runAs(nintexUser) {
            Account storeAccountWithDriveNintexId = ServiceIntegrationDataBuilder.createStoreAccountInstance(
                businessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_GIFTS
            );
            storeAccountWithDriveNintexId.Name = STORE_ACCOUNT_DRIVE_NINTEX_ID;
            storeAccountWithDriveNintexId.BillingStreet = ACCOUNT_BILLING_STREET;
            storeAccountWithDriveNintexId.Drive_Nintex_Id__c = STORE_ACCOUNT_DRIVE_NINTEX_ID;
            storeAccountWithDriveNintexId.Segment__c = ACCOUNT_SEGMENT_SMB;
            insert storeAccountWithDriveNintexId;
            Account storeAccountWithMarketplaceNintexId = ServiceIntegrationDataBuilder.createStoreAccountInstance(
                businessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_GIFTS
            );
            storeAccountWithMarketplaceNintexId.Name = STORE_ACCOUNT_MARKETPLACE_NINTEX_ID;
            storeAccountWithMarketplaceNintexId.BillingStreet = ACCOUNT_BILLING_STREET_SOUTH;
            storeAccountWithMarketplaceNintexId.Marketplace_Nintex_Id__c = STORE_ACCOUNT_MARKETPLACE_NINTEX_ID;
            storeAccountWithMarketplaceNintexId.Segment__c = ACCOUNT_SEGMENT_SMB;
            insert storeAccountWithMarketplaceNintexId;
            Account storeAccountWithNoNintexId = ServiceIntegrationDataBuilder.createStoreAccountInstance(
                businessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL_GIFTS
            );
            storeAccountWithNoNintexId.Name = STORE_ACCOUNT_NO_NINTEX_ID;
            storeAccountWithNoNintexId.BillingStreet = ACCOUNT_BILLING_STREET_NORTH;
            storeAccountWithNoNintexId.Segment__c = ACCOUNT_SEGMENT_SMB;
            insert storeAccountWithNoNintexId;
        }
        AccountsSelector accountsSelectorInstance = new AccountsSelector();
        List<Account> queryResult = accountsSelectorInstance.selectStoreAccountsByMarketplaceOrDriveNintexIds(
            new Set<String>{ STORE_ACCOUNT_DRIVE_NINTEX_ID, STORE_ACCOUNT_MARKETPLACE_NINTEX_ID }
        );
        Test.stopTest();
        System.assertEquals(
            NUMBER_OF_STORES,
            queryResult.size(),
            ASSERT_MESSAGE_COUNT_DOES_NOT_MATCH
        );
    }

    /**
     * @description To test query on Account when encrypted FieldSet
     * and Account Ids are passed.
     **/
    @isTest
    private static void testWhenFieldSetAndAccountIdsArePassedThenReturnAccountFieldsUsingFieldSet() {
        Test.startTest();
        Account newAccount = new Account(
            Name = 'Test Account',
            TaxID__c = '123456789',
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert newAccount;
        List<SObject> sObjects = ((IEncryptedDataSelector) Application.Selector.newInstance(
                newAccount.Id.getSobjectType()
            ))
            .selectEncryptedData((Schema.FieldSet) FIELDS_TO_QUERY, new Set<Id>{ newAccount.Id });
        Test.stopTest();
        System.assertEquals(1, sObjects.size(), EMPTY_LIST_ASSERT_MESSAGE);
    }
    /**
     * @description This is test class for AccountsSelectors method to query Accounts
     *              With Brand Name
     */
    @isTest
    private static void testWhenSelectAccountsThenReturnAccountsWithLegalNameAccounts() {
        Id storeAccRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();
        Id businessAccRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Test.startTest();
        List<Account> accountsList = new List<Account>{
            new Account(
                Name = 'Test 1',
                RecordTypeId = storeAccRecordType,
                BillingStreet = '123 Test Street',
                BillingCity = 'Missoula',
                BillingPostalCode = '59801',
                BillingCountry = 'United States',
                BillingState = 'Montana',
                Legal_Business_Name__c = 'Test 1 LLC',
                Segment__c = ACCOUNT_SEGMENT_SMB
            ),
            new Account(
                Name = 'Test 2',
                RecordTypeId = businessAccRecordType,
                BillingStreet = '121213 Test Street',
                BillingCity = 'Missoula',
                BillingPostalCode = '50801',
                BillingCountry = 'United States',
                BillingState = 'Montana',
                Legal_Business_Name__c = 'Test 2 LLC',
                Segment__c = ACCOUNT_SEGMENT_SMB
            )
        };

        insert accountsList;

        Set<Id> accountIdSet = new Set<Id>{ accountsList[0].Id, accountsList[1].Id };
        AccountsSelector accountsInstance = new AccountsSelector();
        List<Account> accounts = accountsInstance.selectAccountsWithBrandName(accountIdSet);
        Test.stopTest();
        System.assertEquals(2, accounts.size(), 'Returns only 1 store Account');
    }

    /**
     * @description To test Accounts if they have active Xrefs for non-Drive.
     * @JIRA# LEM-2013
     */
    @isTest
    private static void testWhenAccountIdsPassedThenFetchAccountsWithXrefs() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Test.startTest();
        Account parentAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordTypeId = businessRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert parentAccount;
        Account storeAccount = new Account(
            Address_Verification_Status__c = VERIFIED_STATUS,
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = ACCOUNT_BILLING_STATE,
            Coverage__c = IN_COVERAGE,
            Data_Verification_Status__c = VERIFIED_STATUS,
            Name = STORE_ACCOUNT_NAME,
            Legal_Business_Name__c = STORE_ACCOUNT_LEGAL_BUSINESS_NAME,
            ParentId = parentAccount.Id,
            Partnership_Status__c = ACCOUNT_PARTNERSHIP_STATUS,
            RecordTypeId = storeRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert storeAccount;
        Contract contract = new Contract(AccountId = storeAccount.Id);
        insert contract;
        Xref__c xref = new Xref__c(
            External_ID_Source__c = XREF_EXTERNAL_ID_SOURCE,
            Salesforce_Account_Name__c = storeAccount.Id,
            External_ID__c = storeAccount.Id,
            Xref_Status__c = XREF_STATUS_ACTIVE
        );
        insert xref;

        Set<Id> accountIdSet = new Set<Id>{ storeAccount.Id, parentAccount.Id };
        AccountsSelector accountsInstance = new AccountsSelector();
        List<Account> accounts = accountsInstance.selectAccountsWithXrefs(accountIdSet);
        Test.stopTest();

        System.assertEquals(2, accounts.size(), 'Returns only 1 store Account');
    }

    /**
     * @description To test Accounts if they have active Inactive Xrefs for MDS
     * @JIRA# LEM-5777
     */
    @isTest
    private static void testWhenAccountIdsPassedThenFetchAccountsWithInactiveXrefs() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Test.startTest();
        Account parentAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordTypeId = businessRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert parentAccount;
        Account storeAccount = new Account(
            Address_Verification_Status__c = VERIFIED_STATUS,
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = ACCOUNT_BILLING_STATE,
            Coverage__c = IN_COVERAGE,
            Data_Verification_Status__c = VERIFIED_STATUS,
            Name = STORE_ACCOUNT_NAME,
            Legal_Business_Name__c = STORE_ACCOUNT_LEGAL_BUSINESS_NAME,
            ParentId = parentAccount.Id,
            Partnership_Status__c = ACCOUNT_PARTNERSHIP_STATUS,
            RecordTypeId = storeRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert storeAccount;
        Contract contract = new Contract(AccountId = storeAccount.Id);
        insert contract;
        DateTime currentDate = System.now();
        Xref__c activeXref = new Xref__c(
            External_ID_Source__c = XREF_EXTERNAL_ID_SOURCE,
            Salesforce_Account_Name__c = storeAccount.Id,
            External_ID__c = storeAccount.Id,
            Xref_Status__c = XREF_STATUS_ACTIVE
        );
        Xref__c inactiveXref1 = new Xref__c(
            External_ID_Source__c = XREF_EXTERNAL_ID_SOURCE,
            Salesforce_Account_Name__c = storeAccount.Id,
            External_ID__c = storeAccount.Id,
            Xref_Status__c = AccountsSelector.XREF_STATUS_INACTIVE,
            Createddate = currentDate
        );
        Xref__c inactiveXref2 = new Xref__c(
            External_ID_Source__c = XREF_EXTERNAL_ID_SOURCE,
            Salesforce_Account_Name__c = storeAccount.Id,
            External_ID__c = storeAccount.Id,
            Xref_Status__c = AccountsSelector.XREF_STATUS_INACTIVE,
            Createddate = System.now().addDays(-2)
        );
        insert new List<xref__c>{ activeXref, inactiveXref1, inactiveXref2 };

        Set<Id> accountIdSet = new Set<Id>{ storeAccount.Id };
        AccountsSelector accountsInstance = new AccountsSelector();
        List<Account> accounts = accountsInstance.selectAccountsWithInActiveXrefs(accountIdSet);
        List<xref__c> xrefList = new List<xref__c>();
        for (Account acc : accounts) {
            xrefList.addAll(acc.Xrefs__r);
        }
        Test.stopTest();
        System.assertEquals(1, xrefList.size(), 'Only 1 Inactive xref should be returned');
        System.assertEquals(
            AccountsSelector.XREF_STATUS_INACTIVE,
            xrefList[0].Xref_Status__c,
            'Xref status should be inactive'
        );
        System.assertEquals(
            currentDate,
            xrefList[0].Createddate,
            'Xref createdate should be todays date'
        );
    }

    /**
     * @description To test query on Account to fetch in-coverage verified store Accounts
     * and associated Xrefs which are related to the passed business Account and
     * doesn't have any child WorkOrders associated with the passed parent Work Order and
     * store Account Id is less than passed lastReturnedId.
     */
    @isTest
    private static void testWhenLastReturnedIdAndParentWorkOrderIdPassedThenFetchVerifiedStoreDetailsAndChildXrefs() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Test.startTest();
        Account parentAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordTypeId = businessRecordTypeId,
            Corporate_Owned_Store_Count__c = 1,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert parentAccount;
        Account storeAccount = new Account(
            Address_Verification_Status__c = VERIFIED_STATUS,
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = ACCOUNT_BILLING_STATE,
            Coverage__c = IN_COVERAGE,
            Name = STORE_ACCOUNT_NAME,
            ParentId = parentAccount.Id,
            Partnership_Status__c = ACCOUNT_PARTNERSHIP_STATUS,
            RecordTypeId = storeRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert storeAccount;
        Account verifiedStoreAccount = new Account(
            Address_Verification_Status__c = VERIFIED_STATUS,
            BillingStreet = ACCOUNT_BILLING_STREET_AUSTRALIA,
            BillingCity = ACCOUNT_BILLING_CITY_DRAWIN,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE_AUSTRALIA,
            BillingCountry = ACCOUNT_BILLING_COUNTRY_AUSTRALIA,
            BillingState = ACCOUNT_BILLING_STATE_VICTORIA,
            Coverage__c = IN_COVERAGE,
            Name = STORE_ACCOUNT_NAME_DOMINO,
            ParentId = parentAccount.Id,
            Partnership_Status__c = ACCOUNT_PARTNERSHIP_STATUS,
            RecordTypeId = storeRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert verifiedStoreAccount;
        Contract contract = new Contract(AccountId = storeAccount.Id);
        insert contract;
        Xref__c xref = new Xref__c(
            External_ID_Source__c = XREF_EXTERNAL_ID_SOURCE,
            Salesforce_Account_Name__c = storeAccount.Id,
            External_ID__c = storeAccount.Id,
            Xref_Status__c = XREF_STATUS_ACTIVE
        );
        insert xref;
        WorkOrder parentWorkOrder = new WorkOrder(
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            AccountId = parentAccount.Id,
            Contract__c = contract.Id,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Order_Protocol__c = ORDER_PROTOCOL_EMAIL,
            Proposed_Date_of_Activation__c = System.today() + 7,
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE_MARKETPLACE
        );
        insert parentWorkOrder;
        Schema.SObjectField parentField = Account.ParentId;
        AccountsSelector accountsInstance = new AccountsSelector();
        List<Account> verifiedStores = accountsInstance.selectVerifiedStoreAccountsById(
            new Set<Id>{ parentAccount.Id },
            parentWorkOrder.Id,
            parentField,
            verifiedStoreAccount.Id
        );
        Test.stopTest();
        System.assertEquals(storeAccount.Id, verifiedStores[0].Id, ASSERT_MESSAGE_ACCOUNT_ID);
        System.assertEquals(
            false,
            verifiedStores[0].Xrefs__r.isEmpty(),
            XREF_PRESENT_ON_STORE_ACCOUNT_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test query on Account to fetch in-coverage verified store Accounts
     * and associated Xrefs which are related to the passed business Account and
     * doesn't have any child WorkOrders associated with the passed parent Work Order and
     * store Account's Name or Address matches with the passed searchKey.
     */
    @isTest
    private static void testWhenBusinessIdsAndSearchKeyPassedThenFetchVerifiedStoreDetailsAndChildXrefs() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        String searchKey = 'Test';
        Test.startTest();
        Account parentAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordTypeId = businessRecordTypeId,
            Corporate_Owned_Store_Count__c = 1,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert parentAccount;
        Account storeAccount = new Account(
            Address_Verification_Status__c = VERIFIED_STATUS,
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = ACCOUNT_BILLING_STATE,
            Coverage__c = IN_COVERAGE,
            Name = STORE_ACCOUNT_NAME,
            ParentId = parentAccount.Id,
            Partnership_Status__c = ACCOUNT_PARTNERSHIP_STATUS,
            RecordTypeId = storeRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert storeAccount;
        Contract contract = new Contract(AccountId = storeAccount.Id);
        insert contract;
        Xref__c xref = new Xref__c(
            External_ID_Source__c = XREF_EXTERNAL_ID_SOURCE,
            Salesforce_Account_Name__c = storeAccount.Id,
            External_ID__c = storeAccount.Id,
            Xref_Status__c = XREF_STATUS_ACTIVE
        );
        insert xref;
        WorkOrder parentWorkOrder = new WorkOrder(
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            AccountId = parentAccount.Id,
            Contract__c = contract.Id,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Order_Protocol__c = ORDER_PROTOCOL_EMAIL,
            Proposed_Date_of_Activation__c = System.today() + 7,
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE_MARKETPLACE
        );
        insert parentWorkOrder;
        Schema.SObjectField parentField = Account.ParentId;
        AccountsSelector accountsInstance = new AccountsSelector();
        List<Account> verifiedStores = accountsInstance.selectVerifiedStoreAccountsByBusinessIdAndSearchKey(
            new Set<Id>{ parentAccount.Id },
            parentWorkOrder.Id,
            parentField,
            searchKey,
            new Set<Id>{ storeAccount.Id }
        );
        Test.stopTest();
        System.assertEquals(storeAccount.Id, verifiedStores[0].Id, ASSERT_MESSAGE_ACCOUNT_ID);
        System.assertEquals(
            false,
            verifiedStores[0].Xrefs__r.isEmpty(),
            XREF_PRESENT_ON_STORE_ACCOUNT_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test query on Account to fetch in-coverage verified store Accounts
     * and associated Xrefs which are related to the passed business Account and
     * doesn't have any child WorkOrders associated with th passed parent Work Order.
     * @JIRA# LEM-2013
     */
    @isTest
    private static void testWhenProcessAccountChildRecordsThenFetchChildObjectRecords() {
        Id businessAccRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Id paymentAccInvoiceRecordType = Schema.SObjectType.Payment_Account__c.getRecordTypeInfosByName()
            .get('Invoice')
            .getRecordTypeId();
        Test.startTest();
        List<Account> parentAccounts = new List<Account>{
            new Account(
                Name = 'Parent 1',
                Is_Merged__c = true,
                Corporate_Owned_Store_Count__c = 1,
                Segment__c = 'SMB'
            ),
            new Account(
                Name = 'Parent 2',
                Is_Merged__c = true,
                Corporate_Owned_Store_Count__c = 1,
                Segment__c = 'SMB'
            ),
            new Account(Name = 'Utimate Parent', Segment__c = ACCOUNT_SEGMENT_SMB)
        };
        insert parentAccounts;

        List<Account> childAccounts = new List<Account>{
            new Account(
                Name = 'Account1',
                ParentId = parentAccounts[0].Id,
                Franchise_Parent__c = parentAccounts[1].Id,
                Segment__c = 'SMB',
                Primary_Vertical__c = 'Alcohol',
                Ultimate_Parent_Account__c = parentAccounts[2].Id
            ),
            new Account(
                Name = 'Account2',
                ParentId = parentAccounts[1].Id,
                RecordTypeId = businessAccRecordType,
                Segment__c = ACCOUNT_SEGMENT_SMB
            ),
            new Account(
                Name = 'Account3',
                ParentId = parentAccounts[0].Id,
                Segment__c = ACCOUNT_SEGMENT_SMB
            ),
            new Account(
                Name = 'Account4',
                ParentId = parentAccounts[2].Id,
                Segment__c = ACCOUNT_SEGMENT_SMB
            )
        };
        insert childAccounts;

        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(Id = pricebookId, IsActive = true);
        update standardPricebook;

        List<Opportunity> opportunities = new List<Opportunity>{
            new Opportunity(
                Name = 'Test1',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5),
                AccountId = parentAccounts[0].Id,
                Pricebook2Id = pricebookId,
                Deal_Type__c = 'Standard',
                Opportunity_Sub_Type__c = 'Former Partner',
                Is_Parent_Account_Merged__c = false,
                Estimated_Number_of_Stores__c = 2
            ),
            new Opportunity(
                Name = 'Test2',
                StageName = 'Needs Analysis',
                CloseDate = System.today().addDays(5),
                AccountId = parentAccounts[1].Id,
                Deal_Type__c = 'Standard',
                Opportunity_Sub_Type__c = 'Net New Partner',
                Pricebook2Id = pricebookId,
                Estimated_Number_of_Stores__c = 2
            )
        };
        insert opportunities;

        List<Initiative__c> initatives = new List<Initiative__c>{
            new Initiative__c(
                Type__c = 'Business Review',
                Name = 'Initiative 1',
                Start_Date__c = System.today().addDays(3),
                Account__c = parentAccounts[0].Id,
                Status__c = 'Not Started'
            ),
            new Initiative__c(
                Type__c = 'Business Review',
                Name = 'Initiative 2',
                Start_Date__c = System.today().addDays(3),
                Account__c = parentAccounts[0].Id,
                Status__c = 'Not Started'
            )
        };
        insert initatives;

        List<Payment_Account__c> paymentAccounts = new List<Payment_Account__c>{
            new Payment_Account__c(
                RecordTypeId = paymentAccInvoiceRecordType,
                Business_Account__c = parentAccounts[0].Id,
                CurrencyIsoCode = 'AZN'
            ),
            new Payment_Account__c(
                RecordTypeId = paymentAccInvoiceRecordType,
                Business_Account__c = parentAccounts[1].Id,
                CurrencyIsoCode = 'AUD'
            )
        };
        insert paymentAccounts;
        List<WorkOrder> workOrders = new List<WorkOrder>{
            new WorkOrder(
                Activated_Centrally_AC__c = WORK_ORDER_AC,
                AccountId = parentAccounts[0].Id,
                Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
                Order_Protocol__c = ORDER_PROTOCOL_EMAIL,
                Proposed_Date_of_Activation__c = System.today() + 7,
                Status = WORK_ORDER_STATUS,
                Type__c = WORK_ORDER_TYPE_MARKETPLACE
            ),
            new WorkOrder(
                Activated_Centrally_AC__c = WORK_ORDER_AC,
                AccountId = parentAccounts[1].Id,
                Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
                Order_Protocol__c = ORDER_PROTOCOL_EMAIL,
                Proposed_Date_of_Activation__c = System.today() + 7,
                Status = WORK_ORDER_STATUS,
                Type__c = WORK_ORDER_TYPE_MARKETPLACE
            )
        };
        insert workOrders;
        AccountsSelector accountsInstance = new AccountsSelector();
        Database.QueryLocator queryAccount = accountsInstance.selectRelatedChildRecordsByAccountsWithIsMergedEnabled();
        Test.stopTest();

        Database.QueryLocatorIterator iteratorOnAccount = queryAccount.iterator();

        Account fetchedAccount = new Account();
        List<Account> accountRecord = new List<Account>();
        while (iteratorOnAccount.hasNext()) {
            fetchedAccount = (Account) iteratorOnAccount.next();
            accountRecord.add(fetchedAccount);
        }
        System.assertEquals(accountRecord.size(), 2, ASSERT_MESSAGE_ACCOUNT_ID);
        System.assertEquals(
            false,
            accountRecord[0].Opportunities.isEmpty(),
            OPPORTUNITIES_DO_PRESENT_MATCH_ASSERT_MESSAGE
        );

        System.assertEquals(
            false,
            accountRecord[0].Initiatives__r.isEmpty(),
            INITIATIVES_DO_PRESENT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            false,
            accountRecord[0].ChildAccounts.isEmpty(),
            CHILD_ACCOUNTS_DO_PRESENT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            false,
            accountRecord[0].Payment_Accounts__r.isEmpty(),
            PAYMENT_ACCOUNTS_DO_PRESENT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            false,
            accountRecord[0].WorkOrders.isEmpty(),
            WORK_ORDER_NOT_PRESENT_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test query on Account to retrieve store Accounts related to franchise Accounts.
     */
    @isTest
    private static void testWhenFranchiseParentIdsPassedThenRelatedStoreAccountsReturned() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Test.startTest();
        Account parentAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordTypeId = businessRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert parentAccount;
        Account franchiseParent = new Account(
            Name = FRANCHISE_ACCOUNT_NAME,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert franchiseParent;
        Account storeAccount = new Account(
            Address_Verification_Status__c = VERIFIED_STATUS,
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = ACCOUNT_BILLING_STATE,
            Coverage__c = IN_COVERAGE,
            Franchise_Parent__c = franchiseParent.Id,
            Name = STORE_ACCOUNT_NAME,
            ParentId = parentAccount.Id,
            Partnership_Status__c = ACCOUNT_PARTNERSHIP_STATUS,
            RecordTypeId = STORE_RECORD_TYPE_ID,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert storeAccount;
        Set<Id> franchiseAccountIds = new Set<Id>{ franchiseParent.Id };
        Database.QueryLocator storesQueryLocator = AccountsSelector.newInstance()
            .selectStoreAccountsByFranchiseParentIds(franchiseAccountIds);
        List<Account> accountQueryResult = Database.query(storesQueryLocator.getQuery());
        Test.stopTest();
        System.assertEquals(1, accountQueryResult.size(), ASSERT_MESSAGE_COUNT_DOES_NOT_MATCH);
        System.assertEquals(
            STORE_RECORD_TYPE_ID,
            accountQueryResult[0].RecordTypeId,
            ASSERT_MESSAGE_RECORD_TYPE_ID
        );
    }

    /**
     * @description To test query on Account where the passed franchise Accounts does not have associated
     * stores Accounts.
     */
    @isTest
    private static void testWhenFranchiseParentIdsPassedThenRelatedStoreAccountsNotReturned() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Test.startTest();

        Account parentAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordTypeId = businessRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert parentAccount;
        Account franchiseParent = new Account(
            Name = FRANCHISE_ACCOUNT_NAME,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert franchiseParent;
        Account storeAccount = new Account(
            Address_Verification_Status__c = VERIFIED_STATUS,
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = ACCOUNT_BILLING_STATE,
            Coverage__c = IN_COVERAGE,
            Name = STORE_ACCOUNT_NAME,
            ParentId = parentAccount.Id,
            Partnership_Status__c = ACCOUNT_PARTNERSHIP_STATUS,
            RecordTypeId = STORE_RECORD_TYPE_ID,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert storeAccount;
        Set<Id> franchiseAccountIds = new Set<Id>{ franchiseParent.Id };
        Database.QueryLocator storesQueryLocator = AccountsSelector.newInstance()
            .selectStoreAccountsByFranchiseParentIds(franchiseAccountIds);
        List<Account> accountQueryResult = Database.query(storesQueryLocator.getQuery());
        Test.stopTest();
        System.assertEquals(0, accountQueryResult.size(), ASSERT_MESSAGE_COUNT_DOES_NOT_MATCH);
    }

    /**
     * @description To test query on Account to fetch business Accounts in corporate hierarchy
     * by using the passed parent Ids and 'ParentId' as parent field.
     */
    @isTest
    private static void testWhenParentIdFieldAndParentIdsProvidedThenBusinessAccountsReceived() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Test.startTest();

        Account ultimateParentAccount = new Account(
            Name = PARENT_CORPORATE_ACCOUNT_NAME,
            RecordTypeId = businessRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert ultimateParentAccount;
        Account parentAccount = new Account(
            Name = PARENT_CORPORATE_ACCOUNT_NAME,
            ParentId = ultimateParentAccount.Id,
            RecordTypeId = businessRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert parentAccount;
        List<Account> accountsToInsert = new List<Account>{
            new Account(
                Name = CHILD_BUSINESS_ACCOUNT_NAME_US,
                ParentId = parentAccount.Id,
                RecordTypeId = businessRecordTypeId,
                Segment__c = ACCOUNT_SEGMENT_SMB
            ),
            new Account(
                Name = CHILD_BUSINESS_ACCOUNT_NAME_AUS,
                ParentId = parentAccount.Id,
                RecordTypeId = businessRecordTypeId,
                Segment__c = ACCOUNT_SEGMENT_SMB
            )
        };
        insert accountsToInsert;
        Schema.SObjectField parentField = Account.ParentId;
        AccountsSelector accountsInstance = new AccountsSelector();
        List<Account> accounts = accountsInstance.selectBusinessAccountsByParentIds(
            parentField,
            new Set<Id>{ ultimateParentAccount.Id, parentAccount.Id }
        );
        Test.stopTest();
        System.assertEquals(3, accounts.size(), ASSERT_MESSAGE_COUNT_MISMATCH);
    }

    /**
     * @description It is used to get the accounts by the given fieldset and Ids.
     */
    @isTest
    private static void testWhenAccountIdsAndFieldSetProvidedThenAccountsReturned() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Account parentAccount = new Account(
            Name = PARENT_CORPORATE_ACCOUNT_NAME,
            RecordTypeId = businessRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert parentAccount;
        Account storeAccount = new Account(
            Name = STORE_ACCOUNT_NAME,
            RecordTypeId = storeRecordTypeId,
            ParentId = parentAccount.Id,
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingState = ACCOUNT_BILLING_STATE,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert storeAccount;
        Test.startTest();
        List<Account> accounts = AccountsSelector.newInstance()
            .selectAccountsByIdAndFieldSet(
                (Schema.FieldSet) FIELDS_TO_SHOW_ON_DUPLICATE_ACCOUNT_PAGE,
                new Set<Id>{ storeAccount.Id }
            );
        Test.stopTest();
        System.assertEquals(1, accounts.size(), ASSERT_MESSAGE_COUNT_MISMATCH);
    }

    /**
     * @description To test query on Account to fetch business Accounts in franchise hierarchy
     * by using the passed parent Ids and 'Franchise Parent' as parent field.
     */
    @isTest
    private static void testWhenFranchiseParentFieldAndParentIdsProvidedThenBusinessAccountsReceived() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Schema.SObjectField parentField = Account.Franchise_Parent__c;
        Test.startTest();
        Account ultimateParentAccount = new Account(
            Name = PARENT_FRANCHISE_ACCOUNT_NAME,
            Type = ACCOUNT_TYPE_FRANCHISEE,
            RecordTypeId = businessRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert ultimateParentAccount;
        Account parentAccount = new Account(
            Name = FRANCHISE_ACCOUNT_NAME,
            Franchise_Parent__c = ultimateParentAccount.Id,
            Type = ACCOUNT_TYPE_FRANCHISEE,
            RecordTypeId = businessRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert parentAccount;
        List<Account> accountsToInsert = new List<Account>{
            new Account(
                Name = CHILD_BUSINESS_ACCOUNT_NAME_US,
                Franchise_Parent__c = parentAccount.Id,
                RecordTypeId = businessRecordTypeId,
                Segment__c = ACCOUNT_SEGMENT_SMB
            ),
            new Account(
                Name = CHILD_BUSINESS_ACCOUNT_NAME_AUS,
                Franchise_Parent__c = parentAccount.Id,
                RecordTypeId = businessRecordTypeId,
                Segment__c = ACCOUNT_SEGMENT_SMB
            ),
            new Account(
                Name = CHILD_BUSINESS_ACCOUNT_NAME_CA,
                Franchise_Parent__c = ultimateParentAccount.Id,
                RecordTypeId = businessRecordTypeId,
                Segment__c = ACCOUNT_SEGMENT_SMB
            )
        };
        insert accountsToInsert;
        AccountsSelector accountsInstance = new AccountsSelector();
        List<Account> accounts = accountsInstance.selectBusinessAccountsByParentIds(
            parentField,
            new Set<Id>{ ultimateParentAccount.Id, parentAccount.Id }
        );
        Test.stopTest();
        System.assertEquals(4, accounts.size(), ASSERT_MESSAGE_COUNT_MISMATCH);
    }

    /**
     * @description To test query on Account to fetch corporate Accounts in hierarchy
     * by using the passed parent Ids
     */
    @isTest
    private static void testWhenParentIdsProvidedThenCorporateAccountsReceived() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Test.startTest();

        Account ultimateParentAccount = new Account(
            Name = PARENT_FRANCHISE_ACCOUNT_NAME,
            Type = ACCOUNT_TYPE_CORPORATE,
            RecordTypeId = businessRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert ultimateParentAccount;
        Account parentAccount = new Account(
            Name = FRANCHISE_ACCOUNT_NAME,
            Type = ACCOUNT_TYPE_CORPORATE,
            RecordTypeId = businessRecordTypeId,
            ParentId = ultimateParentAccount.id,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert parentAccount;
        List<Account> accountsToInsert = new List<Account>{
            new Account(
                Name = CHILD_BUSINESS_ACCOUNT_NAME_US,
                RecordTypeId = businessRecordTypeId,
                ParentId = parentAccount.id,
                Type = ACCOUNT_TYPE_CORPORATE,
                Segment__c = ACCOUNT_SEGMENT_SMB
            ),
            new Account(
                Name = CHILD_BUSINESS_ACCOUNT_NAME_AUS,
                RecordTypeId = businessRecordTypeId,
                ParentId = parentAccount.id,
                Type = ACCOUNT_TYPE_CORPORATE,
                Segment__c = ACCOUNT_SEGMENT_SMB
            ),
            new Account(
                Name = CHILD_BUSINESS_ACCOUNT_NAME_CA,
                RecordTypeId = businessRecordTypeId,
                ParentId = parentAccount.id,
                Type = ACCOUNT_TYPE_FRANCHISEE,
                Segment__c = ACCOUNT_SEGMENT_SMB
            )
        };
        insert accountsToInsert;
        AccountsSelector accountsInstance = new AccountsSelector();
        List<Account> accounts = accountsInstance.selectAllChildCorporateAccountsWithParent(
            new Set<String>{ ultimateParentAccount.Id }
        );
        Test.stopTest();
        System.assertEquals(4, accounts.size(), ASSERT_MESSAGE_COUNT_MISMATCH);
    }

    /**
     * @description To test Accounts have active services then return accounts with services
     */
    @isTest
    private static void testWhenAccountIdsPassedThenFetchAccountsWithActiveServices() {
        Test.startTest();
        List<Account> accList = [SELECT id FROM Account LIMIT 1];

        List<SBQQ__Subscription__c> subsList = [
            SELECT id, SBQQ__OrderProduct__c
            FROM SBQQ__Subscription__c
        ];

        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();

        Account storeAccount1 = new Account(
            Name = 'Store Account 1',
            RecordTypeId = storeRecordTypeId,
            Segment__c = 'SMB',
            Primary_Vertical__c = 'Alcohol',
            BillingCountry = 'United States',
            BillingState = 'California',
            BillingCity = 'New Jersey',
            BillingStreet = 'ABC Street',
            BillingPostalCode = '12345',
            ParentId = accList[0].id
        );
        insert storeAccount1;

        Merchant_Service__c ms1 = new Merchant_Service__c();
        ms1.Account__c = storeAccount1.Id;
        ms1.Order_Product__c = subsList[0].SBQQ__OrderProduct__c;
        ms1.Mx_Agreed_to_Product__c = 'Yes';
        ms1.Subscription__c = subsList[0].Id;
        insert ms1;

        Merchant_Service__c ms2 = new Merchant_Service__c();
        ms2.Account__c = storeAccount1.Id;
        ms2.Order_Product__c = subsList[1].SBQQ__OrderProduct__c;
        ms2.Mx_Agreed_to_Product__c = 'No';
        ms2.Subscription__c = subsList[1].Id;
        insert ms2;

        Set<Id> storeIds = new Set<Id>{ storeAccount1.Id };
        List<Account> storeList = [
            SELECT id, (SELECT Id, Account__c, Active__c FROM Services__r)
            FROM Account
            WHERE Id IN :storeIds
        ];

        AccountsSelector accountsInstance = new AccountsSelector();
        List<Account> accounts = accountsInstance
            .selectAccountsWithActiveServices(new Set<id>{ storeList[0].id });
        Test.stopTest();
        System.assertEquals(1, accounts.size(), ASSERT_MESSAGE_COUNT_MISMATCH);
        System.assertEquals(1, accounts[0].Services__r.size(), ASSERT_MESSAGE_COUNT_MISMATCH);
    }

    /**
     * @description To test query on Account to fetch its associated Franchise Role Account Team Members
     */
    @isTest
    private static void testWhenSelectByAccountIdThenCall() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Test.startTest();

        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        List<User> users = new List<user>{
            new User(
                Alias = 'test',
                Email = 'testUser1@test.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'TestLastName',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = testProfile.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = 'userEmail4306@test.com'
            ),
            new User(
                Alias = 'test2',
                Email = 'testUser1@test.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'TestLastName',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = testProfile.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = 'userEmail43063@test.com'
            )
        };
        insert users;
        Account franchiseParent = new Account(
            Name = 'Franchise Parent Account',
            RecordTypeId = businessRecordTypeId,
            Type = ACCOUNT_TYPE_CORPORATE,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert franchiseParent;
        List<AccountTeamMember> accountTeamMembers = new List<AccountTeamMember>{
            new AccountTeamMember(
                TeamMemberRole = 'Franchise Representative',
                UserId = users[0].Id,
                AccountId = franchiseParent.id
            ),
            new AccountTeamMember(
                TeamMemberRole = 'Team Lead',
                UserId = users[1].Id,
                AccountId = franchiseParent.id
            )
        };
        insert accountTeamMembers;

        AccountsSelector accountsInstance = new AccountsSelector();

        List<Account> accounts = accountsInstance.selectAccountWithAccTeamMembers(
            new Set<Id>{ franchiseParent.Id }
        );
        Test.stopTest();
        System.assertEquals(1, accounts.size(), 'Accounts Size should be 1.');
        System.assertEquals(1, accounts[0].accountTeamMembers.size(), 'Accounts Size should be 1.');
    }

    /**
     * @description To test query on Account to retrieve store Accounts related to the Names and Address Ids.
     */
    @isTest
    private static void testWhenAccountNamesAndAddressIdsArePassedThenReturnMatchingAccounts() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Account parentAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            Address_Id__c = ADDRESS_ID,
            RecordTypeId = businessRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert parentAccount;
        Test.startTest();
        List<Account> accounts = AccountsSelector.newInstance()
            .selectBusinessAccountsWithNameAndAddressId(
                new Set<String>{ BUSINESS_ACCOUNT_NAME },
                new Set<String>{ ADDRESS_ID }
            );
        Test.stopTest();
        System.assertEquals(1, accounts.size(), ASSERT_MESSAGE_COUNT_DOES_NOT_MATCH);
    }

    /**
     * @description To test query on Account to retrieve store Accounts related to the given
     * Business Account Ids.
     */
    @isTest
    private static void testWhenFranchiseAccountsArePassedThenReturnStoreAccounts() {
        Id storeAccRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();
        Id businessAccRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Test.startTest();
        Account mcDonaldCorporate = new Account(
            Name = 'Parent Account',
            RecordTypeId = businessAccRecordType,
            Type = 'Corporate',
            Primary_Vertical__c = 'CPG',
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert mcDonaldCorporate;

        List<Account> franchiseAccountsList = new List<Account>{
            new Account(
                Name = 'Test 1',
                RecordTypeId = businessAccRecordType,
                BillingStreet = '123 Test Street',
                BillingCity = 'Missoula',
                BillingPostalCode = '59801',
                BillingCountry = 'United States',
                BillingState = 'Montana',
                Segment__c = ACCOUNT_SEGMENT_SMB
            ),
            new Account(
                Name = 'Test 2',
                RecordTypeId = businessAccRecordType,
                BillingStreet = '121213 Test Street',
                BillingCity = 'Missoula',
                BillingPostalCode = '50801',
                BillingCountry = 'United States',
                BillingState = 'Montana',
                Segment__c = ACCOUNT_SEGMENT_SMB
            )
        };

        insert franchiseAccountsList;

        List<Account> storeAccountsList = new List<Account>{
            new Account(
                Name = 'Test 3',
                RecordTypeId = storeAccRecordType,
                BillingStreet = '345 Test Street',
                BillingCity = 'Missoula',
                BillingPostalCode = '59889',
                BillingCountry = 'United States',
                BillingState = 'Montana',
                Franchise_Parent__c = franchiseAccountsList[0].Id,
                Segment__c = ACCOUNT_SEGMENT_SMB
            ),
            new Account(
                Name = 'Test 4',
                RecordTypeId = storeAccRecordType,
                BillingStreet = '5679 Test Street',
                BillingCity = 'Missoula',
                BillingPostalCode = '50812',
                BillingCountry = 'United States',
                BillingState = 'Montana',
                Franchise_Parent__c = franchiseAccountsList[1].Id,
                Segment__c = ACCOUNT_SEGMENT_SMB
            )
        };

        insert storeAccountsList;

        Set<Id> accountIDset = new Set<Id>{
            franchiseAccountsList[0].Id,
            franchiseAccountsList[1].Id
        };
        AccountsSelector accountsInstance = new AccountsSelector();
        List<Account> accounts = accountsInstance.getCorporateAccountIdsByFranchiseAccount(
            accountIDset
        );
        Test.stopTest();
        System.assertEquals(2, accounts.size(), 'Returns only 2 store Account');
    }

    @IsTest
    static void testWhenRetrievingByFlowRequestThenReturnStores() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id storeAccRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();
        Test.startTest();

        Account parentAccount = new Account(
            Name = 'Test Business',
            RecordTypeId = businessRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert parentAccount;

        Contract contract = new Contract(AccountId = parentAccount.Id);
        insert contract;

        Process_Flow_Request__c processFlowRequest = new Process_Flow_Request__c(
            Contract__c = contract.Id,
            Stage__c = 'Work Order Type Selection',
            Status__c = 'In Progress'
        );
        insert processFlowRequest;

        List<Account> storeAccountsList = new List<Account>{
            new Account(
                Name = 'Test Store',
                RecordTypeId = storeAccRecordType,
                BillingStreet = '345 Test Street',
                BillingCity = 'Missoula',
                BillingPostalCode = '59889',
                BillingCountry = 'United States',
                BillingState = 'Montana',
                Bulk_Corporate_Onboarding_Request__c = processFlowRequest.Id,
                Segment__c = ACCOUNT_SEGMENT_SMB
            )
        };
        insert storeAccountsList;
        List<Account> returnedStores = AccountsSelector.newInstance()
            .getStoresByBulkOnboardingRequestId(processFlowRequest.Id);
        Test.stopTest();

        System.assertEquals(1, returnedStores.size(), 'One Store should be returned');
    }

    /**
     * @description It is used to test if the Ultimate Parent Account returns the corporate
     * hierarchy.
     */
    @isTest
    private static void testWhenUltimateParentAccountIdPassedThenReturnHierarchy() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Account ultimateParentAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordTypeId = businessRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert ultimateParentAccount;
        Account businessAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME + ' McD QLD',
            RecordTypeId = businessRecordTypeId,
            Ultimate_Parent_account__c = ultimatePArentAccount.Id,
            ParentId = ultimateParentAccount.Id,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert businessAccount;
        Test.startTest();
        List<Account> accounts = AccountsSelector.newInstance()
            .getCorporateAccountHierarchyByUltimateParentAccount(
                new Set<String>{ 'ParentId' },
                new List<Id>{ ultimateParentAccount.Id }
            );
        Test.stopTest();
        System.assertEquals(1, accounts.size(), ASSERT_MESSAGE_COUNT_DOES_NOT_MATCH);
    }

    /**
     * @description To test when Parent Work Order Id is passed the related Stores and Xrefs details
     * received.
     * @JIRA# LEM-11509
     */
    @isTest
    private static void testWhenParentWorkOrderIdPassedThenStoreDetailsAndXrefs() {
        Test.startTest();
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Account parentAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            Segment__c = 'Enterprise',
            RecordTypeId = businessRecordTypeId
        );
        insert parentAccount;
        Account storeAccount = new Account(
            Name = STORE_ACCOUNT_NAME,
            ParentId = parentAccount.Id,
            Menu_UI_Type__c = ACCOUNT_MENU_UI_TYPE_RETAIL,
            Merchant_Supplied_ID__c = MERCHANT_SUPPLIED_ID,
            POS_Integration_Type__c = POS_INTEGRATION_TYPE,
            RecordTypeId = storeRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert storeAccount;
        Xref__c xref = new Xref__c(
            External_ID_Source__c = XREF_EXTERNAL_ID_SOURCE,
            Salesforce_Account_Name__c = storeAccount.Id,
            External_ID__c = storeAccount.Id,
            Xref_Status__c = XREF_STATUS_ACTIVE
        );
        insert xref;
        WorkOrder parentWorkOrder = new WorkOrder(
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            AccountId = parentAccount.Id,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Order_Protocol__c = ORDER_PROTOCOL_EMAIL,
            Proposed_Date_of_Activation__c = System.today() + 7,
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE_MARKETPLACE
        );
        insert parentWorkOrder;
        WorkOrder childWorkOrder = new WorkOrder(
            Activated_Centrally_AC__c = WORK_ORDER_AC,
            AccountId = storeAccount.Id,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Order_Protocol__c = ORDER_PROTOCOL_EMAIL,
            Proposed_Date_of_Activation__c = System.today() + 7,
            Status = WORK_ORDER_STATUS,
            Type__c = WORK_ORDER_TYPE_MARKETPLACE,
            ParentWorkOrderId = parentWorkOrder.Id
        );
        insert childWorkOrder;
        AccountsSelector accountsInstance = new AccountsSelector();
        List<Account> storeAccounts = accountsInstance.selectRelatedStoreAccountsInformation(
            (Schema.FieldSet) FIELDS_TO_QUERY_FOR_STORE,
            new Set<Id>{ parentWorkOrder.Id }
        );
        Test.stopTest();
        System.assertEquals(storeAccount.Id, storeAccounts[0].Id, ASSERT_MESSAGE_ACCOUNT_ID);
        System.assertEquals(
            false,
            storeAccounts[0].Xrefs__r.isEmpty(),
            XREF_PRESENT_ON_STORE_ACCOUNT_ASSERT_MESSAGE
        );
    }

    /**
     * @description To validate selection of child accounts for trickle down
     * @JIRA# LEM-11918
     */
    @isTest
    private static void testWhenSelectChildAccountsForTrickleDownThenChildAccountsReturned() {
        Test.startTest();
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id accRecordTypeStore = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        List<User> users = new List<user>{
            new User(
                Alias = 'test',
                Email = 'testUser1@test.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'TestLastName',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = testProfile.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = 'User' + Math.random() * 100 + '@test.com'
            ),
            new User(
                Alias = 'test2',
                Email = 'testUser1@test.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'TestLastName',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = testProfile.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = 'User' + Math.random() * 100 + '@test.com'
            )
        };
        insert users;
        Account testUSCorporateBusinessAccount = new Account(
            Name = 'US Corporate Business Account',
            RecordTypeId = accRecordTypeBusiness,
            Type = ACCOUNT_TYPE_CORPORATE,
            OwnerId = users[0].Id,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert testUSCorporateBusinessAccount;
        Account testAUSCorporateBusinessAccount = new Account(
            Name = 'AUS CorporateBusiness Account',
            RecordTypeId = accRecordTypeBusiness,
            parentId = testUSCorporateBusinessAccount.Id,
            Type = ACCOUNT_TYPE_CORPORATE,
            OwnerId = users[1].Id,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert testAUSCorporateBusinessAccount;
        List<Account> childStoreAccounts = new List<Account>{
            new Account(
                Name = 'US Store Account',
                ParentId = testUSCorporateBusinessAccount.Id,
                RecordTypeId = accRecordTypeStore,
                OwnerId = users[0].Id,
                Segment__c = ACCOUNT_SEGMENT_SMB
            ),
            new Account(
                Name = 'AUS Store Account',
                ParentId = testUSCorporateBusinessAccount.Id,
                RecordTypeId = accRecordTypeStore,
                OwnerId = users[1].Id,
                Segment__c = ACCOUNT_SEGMENT_SMB
            )
        };
        insert childStoreAccounts;
        Set<Id> corporateAccountIds = new Set<Id>{ testUSCorporateBusinessAccount.Id };
        List<Account> childAccountsReturned = AccountsSelector.newInstance()
            .selectChildAccountsForAccountFieldsTrickleDown(corporateAccountIds, 10);
        Test.stopTest();
        System.assertEquals(3, childAccountsReturned.size(), ASSERT_MESSAGE_COUNT_MISMATCH);
    }

    /**
     * @description To validate the negative scenario of aggregate query to get count of all child accounts with
     * non matching parent account's owner
     * @JIRA# LEM-11918
     */
    @isTest
    private static void testWhenSelectCountOfNonMatchingAccountFieldsFranchiseChildAccountsThenCountChildAccounts() {
        Test.startTest();
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id accRecordTypeStore = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        List<User> users = new List<user>{
            new User(
                Alias = 'test',
                Email = 'testUser1@test.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'TestLastName',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = testProfile.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = 'User' + Math.random() * 100 + '@test.com'
            ),
            new User(
                Alias = 'test2',
                Email = 'testUser1@test.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'TestLastName',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = testProfile.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = 'User' + Math.random() * 100 + '@test.com'
            )
        };
        insert users;
        Account corporateBusinessAccount = new Account(
            Name = 'Corporate Business Account',
            RecordTypeId = accRecordTypeBusiness,
            Type = ACCOUNT_TYPE_CORPORATE,
            OwnerId = users[0].Id,
            Control_of_Price__c = CONTROL_OF_PRICE_DOORDASH,
            Segment__c = ACCOUNT_SEGMENT_ENTERPRISE
        );
        insert corporateBusinessAccount;
        Account franchiseBusinessAccount = new Account(
            Name = 'Franchise Business Account',
            RecordTypeId = accRecordTypeBusiness,
            Type = ACCOUNT_TYPE_FRANCHISEE,
            OwnerId = users[0].Id,
            Control_of_Price__c = CONTROL_OF_PRICE_DOORDASH,
            Segment__c = ACCOUNT_SEGMENT_ENTERPRISE
        );
        insert franchiseBusinessAccount;

        List<Account> childStoreAccounts = new List<Account>{
            new Account(
                Name = 'US Store Account',
                ParentId = corporateBusinessAccount.Id,
                RecordTypeId = accRecordTypeStore,
                Franchise_Parent__c = franchiseBusinessAccount.Id,
                OwnerId = users[0].Id,
                Control_of_Price__c = CONTROL_OF_PRICE_DOORDASH,
                Segment__c = ACCOUNT_SEGMENT_ENTERPRISE
            ),
            new Account(
                Name = 'AUS Store Account',
                ParentId = corporateBusinessAccount.Id,
                Franchise_Parent__c = franchiseBusinessAccount.Id,
                RecordTypeId = accRecordTypeStore,
                OwnerId = users[0].Id,
                Control_of_Price__c = CONTROL_OF_PRICE_DOORDASH,
                Segment__c = ACCOUNT_SEGMENT_ENTERPRISE
            )
        };
        insert childStoreAccounts;
        Set<Id> corporateAccountIds = new Set<Id>{ corporateBusinessAccount.Id };
        Aggregate[] sumOfNonMatchingAccountOwnerAccountsForTrickleDown = AccountsSelector.newInstance()
            .selectCountOfNonMatchingParentAccountFieldsAccounts(corporateAccountIds);
        List<Account> childAccountsReturned = AccountsSelector.newInstance()
            .selectChildAccountsForAccountFieldsTrickleDown(corporateAccountIds, 10);
        Test.stopTest();
        System.assertEquals(2, childAccountsReturned.size(), ASSERT_MESSAGE_COUNT_MISMATCH);
        System.assertEquals(
            0,
            sumOfNonMatchingAccountOwnerAccountsForTrickleDown.size(),
            ASSERT_MESSAGE_COUNT_MISMATCH
        );
    }

    /**
     * @description To test when CorporateAccounts IDs are provided, then it should return franchise accounts
     */
    @isTest
    private static void testWhenCorporateAccountsThenReturnFranchiseAccounts() {
        Test.startTest();
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id accRecordTypeStore = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        List<User> users = new List<user>{
            new User(
                Alias = 'test',
                Email = 'testUser1@test.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'TestLastName',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = testProfile.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = 'User' + Math.random() * 100 + '@test.com'
            ),
            new User(
                Alias = 'test2',
                Email = 'testUser1@test.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'TestLastName',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = testProfile.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = 'User' + Math.random() * 100 + '@test.com'
            )
        };
        insert users;
        Account corporateBusinessAccount = new Account(
            Name = 'Corporate Business Account',
            RecordTypeId = accRecordTypeBusiness,
            Type = ACCOUNT_TYPE_CORPORATE,
            OwnerId = users[0].Id,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert corporateBusinessAccount;
        Account franchiseBusinessAccount = new Account(
            Name = 'Franchise Business Account',
            RecordTypeId = accRecordTypeBusiness,
            Type = ACCOUNT_TYPE_FRANCHISEE,
            OwnerId = users[0].Id,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert franchiseBusinessAccount;

        List<Account> childStoreAccounts = new List<Account>{
            new Account(
                Name = 'US Store Account',
                ParentId = corporateBusinessAccount.Id,
                RecordTypeId = accRecordTypeStore,
                Franchise_Parent__c = franchiseBusinessAccount.Id,
                OwnerId = users[0].Id,
                Segment__c = ACCOUNT_SEGMENT_SMB
            ),
            new Account(
                Name = 'AUS Store Account',
                ParentId = corporateBusinessAccount.Id,
                Franchise_Parent__c = franchiseBusinessAccount.Id,
                RecordTypeId = accRecordTypeStore,
                OwnerId = users[0].Id,
                Segment__c = ACCOUNT_SEGMENT_SMB
            )
        };
        insert childStoreAccounts;
        List<Account> franchiseAccountsReturned = AccountsSelector.newInstance()
            .selectFranchiseAccountsForCorporateAccounts(
                new Set<ID>{ corporateBusinessAccount.ID }
            );
        Test.stopTest();
        System.assertEquals(
            accRecordTypeStore,
            franchiseAccountsReturned[0].RecordTypeId,
            ASSERT_MESSAGE_ACCOUNT_MISMATCH
        );
    }

    /**
     * @description This method tests if all Accounts are queried as expected.
     */
    @isTest
    private static void testWhenPassedStoreIdsThenStoreAccontsAreFetched() {
        Id storeAccRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();

        Account storeAccount = new Account(
            Name = 'Test 1',
            RecordTypeId = storeAccRecordType,
            BillingStreet = '345 Test Street',
            BillingCity = 'Missoula',
            BillingPostalCode = '59889',
            BillingCountry = 'United States',
            BillingState = 'Montana',
            Segment__c = ACCOUNT_SEGMENT_SMB
        );

        AccountsSelector accountsSelectorForIntegrationTest = new AccountsSelector();
        Database.QueryLocator queryStoreAccount = accountsSelectorForIntegrationTest.getStoreAccountsById(
            new Set<Id>{ storeAccount.Id }
        );

        Database.QueryLocatorIterator iteratorOnAccount = queryStoreAccount.iterator();

        Account fetchedAccount = new Account();

        while (iteratorOnAccount.hasNext()) {
            fetchedAccount = (Account) iteratorOnAccount.next();
        }

        System.assertEquals(
            storeAccount.Id,
            fetchedAccount.Id,
            'The expected Account was not fetched'
        );
    }

    /**
     * @description To validate the selector returning the exact accounts with the given Ids and fieldset.
     * @JIRA# LEM-12957
     */
    @isTest
    private static void testWhenSelectAccountWithOutFiltersWithSetOfFieldsPassedThenReturnValidaData() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Account parentAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordTypeId = businessRecordTypeId,
            Corporate_Owned_Store_Count__c = 1,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert parentAccount;
        Account storeAccount = new Account(
            Address_Verification_Status__c = VERIFIED_STATUS,
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = ACCOUNT_BILLING_STATE,
            Coverage__c = IN_COVERAGE,
            Name = STORE_ACCOUNT_NAME,
            ParentId = parentAccount.Id,
            Partnership_Status__c = ACCOUNT_PARTNERSHIP_STATUS,
            RecordTypeId = storeRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert storeAccount;
        Test.startTest();
        List<Account> accounts01 = AccountsSelector.newInstance()
            .selectAccountWithOutFilterswithSetOfFieldsPassed(
                new Set<String>{ 'Id', 'Name' },
                new Set<Id>{ parentAccount.Id, storeAccount.Id }
            );
        List<Account> accounts02 = AccountsSelector.newInstance()
            .selectAccountWithOutFilterswithSetOfFieldsPassed(
                new Set<String>{ 'Id', 'Name' },
                new Set<Id>{ parentAccount.Id }
            );
        List<Account> accounts03 = AccountsSelector.newInstance()
            .selectAccountWithOutFilterswithSetOfFieldsPassed(
                new Set<String>{ 'Id', 'Name' },
                new Set<Id>{ storeAccount.Id }
            );
        List<Account> accounts04 = AccountsSelector.newInstance()
            .selectAccountWithOutFilterswithSetOfFieldsPassed(
                new Set<String>{ 'Id', 'Name' },
                new Set<Id>{ null }
            );
        Test.stopTest();

        System.assertEquals(accounts01.size(), 2, 'Not returning matched data');
        System.assertEquals(accounts02.size(), 1, 'Not returning matched data');
        System.assertEquals(accounts02[0].Id, parentAccount.Id, 'Not returning expected data');
        System.assertEquals(accounts03.size(), 1, 'Not returning matched data');
        System.assertEquals(accounts03[0].Id, storeAccount.Id, 'Not returning expected data');
        System.assertEquals(accounts04.size(), 0, 'Not returning matched data');
    }

    /**
     * @description This is test class for getting sum of all business accounts
     */
    @isTest
    private static void testWhenSelectBusinessAccountsThenCountSumOfBusinessCount() {
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Account grandParentAccount = new Account(
            Name = 'Grand Parent Account1',
            RecordTypeId = accRecordTypeBusiness,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert grandParentAccount;

        List<Account> parentAccounts = new List<Account>{
            new Account(
                Name = 'Parent Account1',
                ParentId = grandParentAccount.Id,
                RecordTypeId = accRecordTypeBusiness,
                Corporate_Owned_Store_Count__c = 2,
                Franchise_Owned_Store_Count__c = 1,
                Segment__c = ACCOUNT_SEGMENT_SMB
            ),
            new Account(
                Name = 'Parent Account2',
                ParentId = grandParentAccount.Id,
                RecordTypeId = accRecordTypeBusiness,
                Corporate_Owned_Store_Count__c = 3,
                Franchise_Owned_Store_Count__c = 2,
                Segment__c = ACCOUNT_SEGMENT_SMB
            )
        };
        insert parentAccounts;
        Set<Id> accountIdSet = new Set<Id>{ parentAccounts[0].Id, parentAccounts[1].Id };
        AccountsSelector accountsInstance = new AccountsSelector();

        Aggregate[] sumOfBusinessAccountsCount = accountsInstance.selectCountOfAccounts(
            accountIdSet
        );

        System.assertEquals(
            2,
            sumOfBusinessAccountsCount[0].get('accountIdCount'),
            'Business accounts count does not match'
        );
    }

    /**
     * @description This is test class for getting count of franchise owned via parent
     */
    @isTest
    private static void testWhenSelectFranchiseStoresOwnedViaParentCountThenReturnAccounts() {
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id accRecordTypeStore = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Test.startTest();
        List<Account> parentAccounts = new List<Account>{
            new Account(
                Name = 'Parent Account1',
                RecordTypeId = accRecordTypeBusiness,
                Segment__c = ACCOUNT_SEGMENT_SMB
            ),
            new Account(
                Name = 'Franchise Account2',
                RecordTypeId = accRecordTypeBusiness,
                Segment__c = ACCOUNT_SEGMENT_SMB
            )
        };
        insert parentAccounts;

        List<Account> storeAccounts = new List<Account>{
            new Account(
                Name = 'Account1',
                ParentId = parentAccounts[0].Id,
                Franchise_Parent__c = parentAccounts[1].Id,
                RecordTypeId = accRecordTypeStore,
                BillingStreet = 'abc street',
                BillingCountry = 'United States',
                BillingState = 'New Jersey',
                BillingCity = 'test',
                BillingPostalCode = '12345',
                Segment__c = ACCOUNT_SEGMENT_SMB
            ),
            new Account(
                Name = 'Account2',
                ParentId = parentAccounts[0].Id,
                RecordTypeId = accRecordTypeStore,
                BillingStreet = 'abc street',
                BillingCountry = 'United States',
                BillingState = 'New Jersey',
                BillingCity = 'test',
                BillingPostalCode = '12345',
                Segment__c = ACCOUNT_SEGMENT_SMB
            )
        };
        insert storeAccounts;

        Set<Id> storeAccountIds = new Set<Id>{ storeAccounts[0].Id, storeAccounts[1].Id };
        AccountsSelector accountsInstance = new AccountsSelector();

        List<Account> franchiseOwnedStoresViaParentCount = accountsInstance.selectFranchiseeStoreAccountsById(
            storeAccountIds
        );
        Test.stopTest();

        System.assertEquals(
            1,
            franchiseOwnedStoresViaParentCount.size(),
            'List size does not match'
        );
    }

    /**
     * @description retrive the store accounts along with their active and valid Xrefs
     * @jira# LEM-12911
     */
    @isTest
    private static void testWhenGetStoreAccountsThenValidActiveXrefs() {
        Test.startTest();
        Id storeAccRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();
        List<Account> accountsList = new List<Account>{
            new Account(
                Name = 'Test 1',
                RecordTypeId = storeAccRecordType,
                BillingStreet = '123 Test Street',
                BillingCity = 'Missoula',
                BillingPostalCode = '59801',
                BillingCountry = 'United States',
                BillingState = 'Montana',
                Segment__c = ACCOUNT_SEGMENT_SMB
            )
        };

        insert accountsList;
        Set<Id> accountIDset = new Set<Id>{ accountsList[0].Id };
        AccountsSelector accountsInstance = new AccountsSelector();
        List<Account> accounts = accountsInstance.getStoreAccountsWithValidActiveXrefs(
            accountIDset
        );
        Test.stopTest();

        System.assertEquals(1, accounts.size(), 'Returns only 1 store Account');
    }

    /**
     * @description To validate the query returns Franchisee accounts based on
     * passed Corporate parent account Ids.
     */
    @isTest
    private static void testWhenCorporateParentIdsPassedThenReturnChildFranchiseeAccounts() {
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(BUSINESS_RECORD_TYPE_NAME)
            .getRecordTypeId();
        Account corporateBusinessAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordTypeId = accRecordTypeBusiness,
            Type = ACCOUNT_TYPE_CORPORATE,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert corporateBusinessAccount;
        Account franchiseBusinessAccount = new Account(
            Name = FRANCHISE_ACCOUNT_NAME,
            ParentId = corporateBusinessAccount.Id,
            RecordTypeId = accRecordTypeBusiness,
            Type = ACCOUNT_TYPE_FRANCHISEE,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert franchiseBusinessAccount;
        Test.startTest();
        List<Account> accounts = AccountsSelector.newInstance()
            .selectFranchiseAccountsForCorporateAccounts(
                new Set<Id>{ corporateBusinessAccount.Id }
            );
        Test.stopTest();
        System.assertEquals(1, accounts.size(), ASSERT_MESSAGE_COUNT_DOES_NOT_MATCH);
    }

    /**
     * @description This is test class for getting count of business accounts with partnership status
     */
    @isTest
    private static void testWhenSelectCountOfStoreAccountsByMedalRankThenCountMedalRank() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Test.startTest();
        List<Account> parentAccounts = new List<Account>{
            new Account(
                Name = BUSINESS_ACCOUNT_NAME,
                RecordTypeId = businessRecordTypeId,
                Segment__c = ACCOUNT_SEGMENT_SMB
            ),
            new Account(
                Name = BUSINESS_ACCOUNT_NAME,
                RecordTypeId = businessRecordTypeId,
                Segment__c = ACCOUNT_SEGMENT_SMB
            )
        };
        insert parentAccounts;
        List<Account> storeAccounts = new List<Account>{
            new Account(
                Name = STORE_ACCOUNT_NAME,
                ParentId = parentAccounts[0].Id,
                Medal_Rank__c = ACCOUNT_MEDAL_RANK_PLATINUM,
                RecordTypeId = storeRecordTypeId,
                BillingStreet = ACCOUNT_BILLING_STREET,
                BillingCity = ACCOUNT_BILLING_CITY,
                BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
                BillingCountry = ACCOUNT_BILLING_COUNTRY,
                BillingState = ACCOUNT_BILLING_STATE,
                Segment__c = ACCOUNT_SEGMENT_SMB
            ),
            new Account(
                Name = STORE_ACCOUNT_NAME,
                ParentId = parentAccounts[1].Id,
                Medal_Rank__c = ACCOUNT_MEDAL_RANK_GOLD,
                RecordTypeId = storeRecordTypeId,
                BillingStreet = ACCOUNT_BILLING_STREET,
                BillingCity = ACCOUNT_BILLING_CITY,
                BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
                BillingCountry = ACCOUNT_BILLING_COUNTRY,
                BillingState = ACCOUNT_BILLING_STATE,
                Segment__c = ACCOUNT_SEGMENT_SMB
            ),
            new Account(
                Name = STORE_ACCOUNT_NAME,
                ParentId = parentAccounts[1].Id,
                Medal_Rank__c = ACCOUNT_MEDAL_RANK_SILVER,
                RecordTypeId = storeRecordTypeId,
                BillingStreet = ACCOUNT_BILLING_STREET,
                BillingCity = ACCOUNT_BILLING_CITY,
                BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
                BillingCountry = ACCOUNT_BILLING_COUNTRY,
                BillingState = ACCOUNT_BILLING_STATE,
                Segment__c = ACCOUNT_SEGMENT_SMB
            )
        };
        insert storeAccounts;
        Set<Id> parentIds = new Set<Id>{ parentAccounts[0].Id, parentAccounts[1].Id };
        AccountsSelector accountsInstance = new AccountsSelector();
        Aggregate[] countOfAccountWithMedalRank = accountsInstance.selectCountOfStoreAccountsByMedalRank(
            parentIds
        );
        Test.stopTest();
        Set<String> medalRanksRetrieved = new Set<String>();
        for (Aggregate eachAggregate : countOfAccountWithMedalRank) {
            medalRanksRetrieved.add((String) eachAggregate.get('medalRank'));
        }
        System.assertEquals(
            1,
            countOfAccountWithMedalRank[0].get('countIds'),
            ASSERT_MESSAGE_COUNT_OF_MEDAL_RANK_MISMATCH
        );
        System.assertEquals(
            true,
            medalRanksRetrieved.contains(ACCOUNT_MEDAL_RANK_GOLD),
            ASSERT_MESSAGE_MEDAL_RANK_MISMATCH
        );
        System.assertEquals(
            1,
            countOfAccountWithMedalRank[1].get('countIds'),
            ASSERT_MESSAGE_COUNT_OF_MEDAL_RANK_MISMATCH
        );
        System.assertEquals(
            true,
            medalRanksRetrieved.contains(ACCOUNT_MEDAL_RANK_PLATINUM),
            ASSERT_MESSAGE_MEDAL_RANK_MISMATCH
        );
    }
    /**
     * @description To test query on Account to fetch Accounts with associated
     * account contact relations using the passed Account Ids and Contact Ids.
     */
    @isTest
    private static void testWhenAccountIdsAndContactIdsPassedThenReturnAccountContactRelationsRecords() {
        List<Contact> contactsToInsert = new List<Contact>();
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Test.startTest();
        Account parentAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordTypeId = businessRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert parentAccount;
        Contact contact = new Contact(
            AccountId = parentAccount.Id,
            FirstName = 'TestFirst',
            LastName = 'TestLast',
            Email = 'test@testemail.com'
        );
        contactsToInsert.add(contact);
        Contact contact1 = new Contact(
            AccountId = parentAccount.Id,
            FirstName = 'TestFirst1',
            LastName = 'TestLast1',
            Email = 'test@testemail1.com'
        );
        contactsToInsert.add(contact1);
        insert contactsToInsert;
        AccountsSelector accountsInstance = new AccountsSelector();
        List<Account> accounts = accountsInstance.selectAccountAndRelatedContactRelationsByAccountAndContactIds(
            new Set<Id>{ parentAccount.Id },
            new List<Id>{ contact.Id }
        );
        Test.stopTest();
        System.assertEquals(accounts.size(), 1, ASSERT_MESSAGE_ACCOUNT_ID);
        System.assertEquals(
            1,
            accounts[0].AccountContactRelations.size(),
            MISMATCH_IN_ACR_COUNT_ERROR_MESSAGE
        );
        System.assertEquals(
            false,
            accounts[0].AccountContactRelations.isEmpty(),
            ACR_PRESENT_ON_STORE_ACCOUNT_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test query on Account to fetch Accounts with associated
     * account contact relations using the passed ultimate Account Ids and Contact Ids.
     */
    @isTest
    private static void testWhenUltimateParentAccountIdsPassedThenReturnAssociatedObjectRecords() {
        List<Contact> contactsToInsert = new List<Contact>();
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Test.startTest();
        Account parentAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordTypeId = businessRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert parentAccount;
        Account childAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME + '1',
            ParentId = parentAccount.Id,
            Ultimate_Parent_Account__c = parentAccount.Id,
            RecordTypeId = businessRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT_SMB,
            Partnership_Status__c = 'Former Partner'
        );
        insert childAccount;
        Contact contact = new Contact(
            AccountId = childAccount.Id,
            FirstName = 'TestFirst',
            LastName = 'TestLast',
            Email = 'test@testemail.com'
        );
        contactsToInsert.add(contact);
        Contact contact1 = new Contact(
            AccountId = childAccount.Id,
            FirstName = 'TestFirst1',
            LastName = 'TestLast1',
            Email = 'test@testemail1.com'
        );
        contactsToInsert.add(contact1);
        insert contactsToInsert;
        AccountsSelector accountsInstance = new AccountsSelector();
        List<Account> accounts = accountsInstance.selectAccountsByUltimateParentAccountIds(
            new Set<Id>{ parentAccount.Id },
            new List<Id>{ contact.Id }
        );
        Test.stopTest();
        System.assertEquals(accounts.size(), 1, ASSERT_MESSAGE_ACCOUNT_ID);
        System.assertEquals(
            false,
            accounts[0].AccountContactRelations.isEmpty(),
            ACR_PRESENT_ON_STORE_ACCOUNT_ASSERT_MESSAGE
        );
        System.assertEquals(
            1,
            accounts[0].AccountContactRelations.size(),
            MISMATCH_IN_ACR_COUNT_ERROR_MESSAGE
        );
    }
    /**
     * @description To test query on Account to fetch Accounts with associated opportunities
     * using the passed Account Ids.
     */
    @isTest
    private static void testWhenAccountIdsAndContactIdsPassedThenReturnOpportunityRecords() {
        List<Opportunity> opportunitiesToInsert = new List<Opportunity>();
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Test.startTest();
        Account parentAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordTypeId = businessRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert parentAccount;
        Opportunity testOpp1 = CPQTestDataFactory.createOpportunity(parentAccount.Id, false);
        testOpp1.Estimated_Number_of_Stores__c = 1;
        opportunitiesToInsert.add(testOpp1);
        Opportunity testOpp2 = CPQTestDataFactory.createOpportunity(parentAccount.Id, false);
        testOpp2.Estimated_Number_of_Stores__c = 1;
        opportunitiesToInsert.add(testOpp2);
        insert opportunitiesToInsert;
        testOpp1.Estimated_Number_of_Stores__c = 2;
        update testOpp1;

        AccountsSelector accountsInstance = new AccountsSelector();
        List<Account> accounts = accountsInstance.selectAccountAndRelatedOpportunitiesByAccountIds(
            new Set<Id>{ parentAccount.Id }
        );
        Test.stopTest();
        System.assertEquals(accounts.size(), 1, ASSERT_MESSAGE_ACCOUNT_ID);
        System.assertEquals(
            false,
            accounts[0].Opportunities.isEmpty(),
            OPPORTUNITIES_DO_PRESENT_MATCH_ASSERT_MESSAGE
        );
        System.assertEquals(
            testOpp1.Id,
            accounts[0].Opportunities[0].Id,
            MISMATCH_IN_LATEST_OPP_ERROR_MESSAGE
        );
    }

    /**
     * @JIRA LEM-14284
     * @description It is used to test if the Accounts have MX Tag Association name as TopMX.
     */
    @isTest(SeeAllData=false)
    private static void testWhenAccountHaveMxTagAssociationThenQueryMxTag() {
        List<Account> accountRecs = new List<Account>{
            new Account(name = 'TestAccount1', Segment__c = ACCOUNT_SEGMENT_SMB),
            new Account(name = 'TestAccount2', Segment__c = ACCOUNT_SEGMENT_SMB)
        };
        insert accountRecs;

        List<MxTag__c> mxTagRec = new List<MxTag__c>{
            new MxTag__c(Name = 'Top MX', Status__c = 'Active')
        };
        insert mxTagRec;

        List<Mx_Tag_Association__c> mxTagAssocRec = new List<Mx_Tag_Association__c>{
            new Mx_Tag_Association__c(Account__c = accountRecs[0].Id, MxTag__c = mxTagRec[0].Id)
        };
        insert mxTagAssocRec;

        Test.startTest();
        List<Account> accounts = AccountsSelector.newInstance()
            .selectAccountsWithMxTagAssociation(new Set<Id>{ accountRecs[0].Id });
        Test.stopTest();
        System.assertEquals(1, accounts.size(), ASSERT_MESSAGE_COUNT_DOES_NOT_MATCH);
    }

    /**
     * @description It is used to test if the Account returns based on uniqueIdentifier and recordtype
     */
    @isTest
    private static void testWhenUUIDWithRecordTypePassedThenAccountsReturned() {
        insert new Account(
            Name = 'US test Account',
            RecordTypeId = BUSINESS_RECORD_TYPE_ID,
            Unique_Identifier__c = UNIQUE_IDENTIFIER,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        Test.startTest();
        List<Account> accounts = AccountsSelector.newInstance()
            .selectAccountsByUniqueIdentifiersAndRecordType(
                new Set<String>{ UNIQUE_IDENTIFIER },
                BUSINESS_RECORD_TYPE_ID
            );
        Test.stopTest();
        System.assertEquals(1, accounts.size(), ASSERT_MESSAGE_COUNT_DOES_NOT_MATCH);
    }

    /**
     * @description It is used to retrive associated store accounts when Parent Account
     * and UUID is passed.
     */
    @isTest
    private static void testWhenParentAccountIdsAndUuidsPassedThenReturnStoreAccounts() {
        String uuid = '1234567';
        Account parentAccount = new Account(Name = 'Parent', Segment__c = ACCOUNT_SEGMENT_SMB);
        insert parentAccount;

        Account storeAccount = new Account(
            Name = 'Store Account',
            ParentId = parentAccount.Id,
            Unique_Identifier__c = uuid,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert storeAccount;
        Test.startTest();
        List<Account> accounts = AccountsSelector.newInstance()
            .selectByUniqueIdentifiers(new Set<Id>{ parentAccount.Id }, new Set<String>{ uuid });
        Test.stopTest();
        System.assertEquals(1, accounts.size(), ASSERT_MESSAGE_COUNT_DOES_NOT_MATCH);
    }

    /**
     * @description To test query on Account to fetch Accounts with associated brands
     * using the passed Account Ids.
     */
    @isTest
    private static void testWhenAccountIdsPassedThenReturnAccountsWithBrandAssociations() {
        Id businessAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        List<Account> businessAccounts = new List<Account>{
            new Account(
                Name = BUSINESS_ACCOUNT_NAME,
                RecordTypeId = businessAccountRecordTypeId,
                Segment__c = ACCOUNT_SEGMENT_SMB
            ),
            new Account(
                Name = STORE_ACCOUNT_NAME_DOMINO,
                RecordTypeId = businessAccountRecordTypeId,
                Segment__c = ACCOUNT_SEGMENT_SMB
            )
        };
        insert businessAccounts;

        List<Brand__c> brands = new List<Brand__c>{
            new Brand__c(Name = 'MC Donald', Brand_Owner__c = businessAccounts[0].Id),
            new Brand__c(Name = 'Dominos', Brand_Owner__c = businessAccounts[1].Id)
        };
        insert brands;
        Set<Id> businessIds = new Set<Id>{ businessAccounts[0].Id, businessAccounts[1].Id };
        AccountsSelector accountsInstance = new AccountsSelector();
        List<Account> accounts = accountsInstance.getAccountsWithBrandAssociationsbyAccountIds(
            businessIds
        );
        System.assertEquals(accounts.size(), 2, ASSERT_MESSAGE_COUNT_MISMATCH);
        System.assertEquals(
            accounts[0].Brand_Associations__r.size(),
            1,
            BA_PRESENT_ON_STORE_ACCOUNT_ASSERT_MESSAGE
        );
        System.assertEquals(
            accounts[1].Brand_Associations__r.size(),
            1,
            BA_PRESENT_ON_STORE_ACCOUNT_ASSERT_MESSAGE
        );
    }
    /**
     * @description To test query on Account to not fetch Accounts with associated brands
     * using the passed Account Ids.
     */
    @isTest
    private static void testWhenAccountIdsPassedThenDontReturnAccountsWithBrandAssociations() {
        Id businessAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        List<Account> businessAccounts = new List<Account>{
            new Account(
                Name = BUSINESS_ACCOUNT_NAME,
                RecordTypeId = businessAccountRecordTypeId,
                Segment__c = ACCOUNT_SEGMENT_SMB
            ),
            new Account(
                Name = STORE_ACCOUNT_NAME_DOMINO,
                RecordTypeId = businessAccountRecordTypeId,
                Segment__c = ACCOUNT_SEGMENT_SMB
            )
        };
        insert businessAccounts;
        Set<Id> businessIds = new Set<Id>{ businessAccounts[0].Id };
        AccountsSelector accountsInstance = new AccountsSelector();
        List<Account> accounts = accountsInstance.getAccountsWithBrandAssociationsbyAccountIds(
            businessIds
        );
        System.assertEquals(accounts.size(), 1, ASSERT_MESSAGE_COUNT_MISMATCH);
        System.assertEquals(
            accounts[0].Brand_Associations__r.size(),
            0,
            BA_PRESENT_ON_STORE_ACCOUNT_ASSERT_MESSAGE
        );
    }

    /**
     * @description To validate store account details and related record details are returned when
     * store account Ids are passed.
     */
    @isTest
    private static void testWhenStoreAccountIdsReceivedThenReturnAccountDetails() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Test.startTest();
        List<Account> parentAccounts = new List<Account>{
            new Account(
                Name = BUSINESS_ACCOUNT_NAME,
                RecordTypeId = businessRecordTypeId,
                Segment__c = ACCOUNT_SEGMENT_SMB
            )
        };
        insert parentAccounts;
        List<Account> storeAccounts = new List<Account>{
            new Account(
                Name = STORE_ACCOUNT_NAME,
                ParentId = parentAccounts[0].Id,
                Medal_Rank__c = ACCOUNT_MEDAL_RANK_PLATINUM,
                RecordTypeId = storeRecordTypeId,
                BillingStreet = ACCOUNT_BILLING_STREET,
                BillingCity = ACCOUNT_BILLING_CITY,
                BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
                BillingCountry = ACCOUNT_BILLING_COUNTRY,
                BillingState = ACCOUNT_BILLING_STATE,
                Segment__c = ACCOUNT_SEGMENT_SMB
            )
        };
        insert storeAccounts;
        AccountsSelector accountsInstance = new AccountsSelector();
        Account storeAccout = accountsInstance.selectStoreAccountsAndRelatedEntitiesByAccountIds(
            new Set<Id>{ storeAccounts[0].Id }
        )[0];
        Test.stopTest();
        System.assertEquals(storeAccounts[0].Id, storeAccout.Id, ASSERT_MESSAGE_ACCOUNT_ID);
    }

    /**
     * @description : This method tests the behavior of the selectAccountByIdWithXrefPaymentAccount method in the AccountsSelector class.
     * It verifies that when an account with a specific ID is provided, along with related Xref and Account_Payment_Account_Relation records,
     * the method returns the expected account details, including the associated Xref and Account_Payment_Account_Relation records.
     *
     * Test Steps :
     * 1. Create test records for Account, Xref, Contact, and Payment_Account__c objects.
     * 2. Insert the test records into the database.
     * 3. Call the selectAccountByIdWithXrefPaymentAccount method with the account ID and related object fields to retrieve the account details.
     * 4. Perform assertions to verify the correctness of the returned account details.
     *
     * Expected Results:
     * - The method should return a list of Account records with size 1.
     * - The returned Account record should have the same ID as the provided account ID.
     * - The returned Account record should have a related Xref record with size 1.
     * - The related Xref record should have the same ID as the xref2 record.
     * - The returned Account record should have a related Account_Payment_Account_Relation record with size 1.
     * - The related Account_Payment_Account_Relation record should have the same ID as the childPaymentAccountRelation record.
     * - The related Account_Payment_Account_Relation record should have the same Payment_Account__c value as the paymentAccount record.
     */
    @IsTest
    static void testWhenAccountByIdWithXrefPaymentAccountThenReturnTheAccountWithChilds() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Id paymentAccountRecordTypeId = Schema.SObjectType.Payment_Account__c.getRecordTypeInfosByDeveloperName()
            .get('Payments')
            .getRecordTypeId();

        Test.startTest();
        Account parentAccount = new Account(
            Name = BUSINESS_ACCOUNT_NAME,
            RecordTypeId = businessRecordTypeId,
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert parentAccount;
        Account storeAccount = new Account(
            Name = STORE_ACCOUNT_NAME,
            ParentId = parentAccount.Id,
            Partnership_Status__c = ACCOUNT_PARTNERSHIP_STATUS,
            RecordTypeId = storeRecordTypeId,
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = ACCOUNT_BILLING_STATE,
            Address_Id__c = '12345',
            Alcohol_Addendum_Signed__c = false,
            Legal_Business_Name__c = 'Legal Name LLC',
            Menu_UI_Type__c = ACCOUNT_MENU_UI_TYPE_RETAIL,
            Primary_Vertical__c = ACCOUNT_PRIMARY_VERTICAL_GIFTS
        );
        insert storeAccount;
        Business_Reference__c businessReference = new Business_Reference__c(
            CurrencyIsoCode = 'USD',
            External_Id_Source__c = XREF_EXTERNALID_SOURCE_DRIVE,
            Business_Name__c = 'Test Buziness Name',
            Default_Type__c = 'Corporate',
            External_Id__c = 'External Id1234'
        );
        insert businessReference;
        Xref__c xref = new Xref__c(
            External_ID_Source__c = XREF_EXTERNAL_ID_SOURCE,
            Salesforce_Account_Name__c = storeAccount.Id,
            External_ID__c = '223344',
            Xref_Status__c = XREF_STATUS_ACTIVE,
            Unified_Store_ID__c = '12345678',
            Business_Reference__c = businessReference.Id
        );
        Xref__c xref2 = new Xref__c(
            External_ID_Source__c = XREF_EXTERNAL_ID_SOURCE,
            Salesforce_Account_Name__c = storeAccount.Id,
            External_ID__c = '223344',
            Xref_Status__c = XREF_STATUS_INACTIVE,
            Unified_Store_ID__c = '12345678',
            Business_Reference__c = businessReference.Id
        );
        insert new List<Xref__c>{ xref, xref2 };
        Contact contact = new Contact(
            AccountId = storeAccount.Id,
            FirstName = 'TestFirst',
            LastName = 'TestLast',
            Email = 'test@testemail.com'
        );
        insert contact;
        Payment_Account__c paymentAccount = new Payment_Account__c(
            RecordtypeId = paymentAccountRecordTypeId,
            Business_Account__c = parentAccount.Id,
            Bank_Account_Number__c = '752948359734',
            RoutingNumber__c = '873549457',
            Entity_Type__c = 'Company',
            Billing_Contact_Name__c = contact.Id
        );
        insert paymentAccount;

        Account_Payment_Account_Relation__c childPaymentAccountRelation = new Account_Payment_Account_Relation__c(
            Payment_Account__c = paymentAccount.id,
            Account__c = storeAccount.Id
        );
        insert childPaymentAccountRelation;

        List<Account> storeAccountDetails = AccountsSelector.newInstance()
            .selectAccountByIdWithXrefPaymentAccount(
                new Set<Id>{ storeAccount.Id },
                new Map<String, Set<String>>{
                    'Account' => new Set<String>{ 'Id' },
                    'Xref' => new Set<String>{ 'Id' },
                    'Account_Payment_Account_Relation' => new Set<String>{
                        'Payment_Account__c',
                        'Id'
                    }
                }
            );

        Test.stopTest();

        Assert.areEqual(1, storeAccountDetails.size(), 'Account size doesn"t match');
        Assert.areEqual(
            storeAccount.Id,
            storeAccountDetails[0].Id,
            'Account Id is not the one given'
        );
        Assert.areEqual(1, storeAccountDetails[0].Xrefs__r.size(), 'Xref size doesn"t match');
        Assert.areEqual(
            xref2.Id,
            storeAccountDetails[0].Xrefs__r[0].Id,
            'Xref is not the one required'
        );
        Assert.areEqual(
            1,
            storeAccountDetails[0].Account_Payment_Account_Relations__r.size(),
            'Account Payment Relations Doesn"t match'
        );
        Assert.areEqual(
            childPaymentAccountRelation.Id,
            storeAccountDetails[0].Account_Payment_Account_Relations__r[0].Id,
            'Not the expected Account Payment Account RelationShip'
        );
        Assert.areEqual(
            paymentAccount.Id,
            storeAccountDetails[0].Account_Payment_Account_Relations__r[0].Payment_Account__c,
            'Not the expected Account Payment Account RelationShip'
        );
    }

    /**
     * @description - test when business id is provided select its latest created store.
     * @author Soumya Dash | 06-28-2024
     **/
    @isTest
    private static void testWhenBusinessAccountThenSelectLastCreatedStoreDetails() {
        Map<String, Set<String>> sObjectToFields = new Map<String, Set<String>>{
            'Account' => new Set<String>{ 'Order_Protocol__c', 'POS_System__c', 'Menu_URL__c' },
            'Contact' => new Set<String>{ '' }
        };
        Account businessAccount = new Account(
            Name = 'Test Business',
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert businessAccount;

        Account storeAccount = new Account(
            Name = 'Test Store',
            ParentId = businessAccount.Id,
            Address_Verification_Status__c = 'Verified',
            Coverage__c = 'In Coverage',
            Order_Protocol__c = 'POS',
            POS_System__c = 'Abacus',
            Menu_URL__c = 'www.menu.com'
        );
        insert storeAccount;

        Xref__c xref = new Xref__c(
            External_ID_Source__c = XREF_EXTERNAL_ID_SOURCE,
            Salesforce_Account_Name__c = storeAccount.Id,
            External_ID__c = '223344',
            Xref_Status__c = XREF_STATUS_INACTIVE,
            Unified_Store_ID__c = '12345678'
        );
        insert xref;

        Test.startTest();
        IAccountsSelector accountSelector = AccountsSelector.newInstance();
        List<Account> acc = accountSelector.selectByBusinessAccountIdAndgetStoreDetails(
            businessAccount.Id,
            sObjectToFields
        );
        Test.stopTest();
        Assert.areNotEqual(0, acc.size(), 'account was not retrieved');
        Assert.areEqual('POS', acc[0].Order_Protocol__c, 'order protocol didnt match');
        Assert.areEqual(0, acc[0].Xrefs__r.size(), 'Should select only active xref');
    }

    /**
     * @description - test when store id is provided select its store
     * @author SamikshaDD | 07-08-2024
     **/
    @isTest
    private static void testWhenStoreAccountThenSelectStoreDetails() {
        Map<String, Set<String>> sObjectToFields = new Map<String, Set<String>>{
            'Account' => new Set<String>{ 'Order_Protocol__c', 'POS_System__c', 'Menu_URL__c' },
            'Contact' => new Set<String>{ '' }
        };
        Account businessAccount = new Account(
            Name = 'Test Business',
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert businessAccount;

        Account storeAccount = new Account(
            Name = 'Test Store',
            ParentId = businessAccount.Id,
            Order_Protocol__c = 'Email',
            Menu_URL__c = 'www.menu.com',
            Address_Verification_Status__c = 'Verified',
            Coverage__c = 'In Coverage',
            POS_System__c = 'Abacus',
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert storeAccount;

        Test.startTest();
        IAccountsSelector accountSelector = AccountsSelector.newInstance();
        List<Account> acc = accountSelector.selectByStoreAccountIdAndgetStoreDetails(
            storeAccount.Id,
            businessAccount.Id,
            sObjectToFields
        );
        Test.stopTest();
        Assert.areNotEqual(0, acc.size(), 'Account was not retrieved');
    }

    /**
     * @description To validate Store Account details are returned when Parent Account Ids
     * and Experience are passed.
     */
    @isTest
    private static void testWhenParentAccountIdsAndExperienceReceivedThenReturnStoreAccountDetails() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(BUSINESS_RECORD_TYPE_NAME)
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(STORE_RECORD_TYPE_NAME)
            .getRecordTypeId();
        Test.startTest();
        List<Account> parentAccounts = new List<Account>{
            new Account(
                Name = BUSINESS_ACCOUNT_NAME,
                RecordTypeId = businessRecordTypeId,
                Segment__c = ACCOUNT_SEGMENT_SMB
            )
        };
        insert parentAccounts;
        List<Account> storeAccounts = new List<Account>{
            new Account(
                Name = STORE_ACCOUNT_NAME,
                ParentId = parentAccounts[0].Id,
                Experience__c = ACCOUNT_EXPERIENCE_STOREFRONT,
                RecordTypeId = storeRecordTypeId,
                BillingStreet = ACCOUNT_BILLING_STREET,
                BillingCity = ACCOUNT_BILLING_CITY,
                BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
                BillingCountry = ACCOUNT_BILLING_COUNTRY,
                BillingState = ACCOUNT_BILLING_STATE,
                Segment__c = ACCOUNT_SEGMENT_SMB
            )
        };
        insert storeAccounts;
        AccountsSelector accountsInstance = new AccountsSelector();
        Account storeAccout = accountsInstance.selectStoreAccountsByParentIdsAndExperience(
            new Set<Id>{ parentAccounts[0].Id },
            ACCOUNT_EXPERIENCE_STOREFRONT
        )[0];
        Test.stopTest();
        System.assertEquals(storeAccounts[0].Id, storeAccout.Id, ASSERT_MESSAGE_ACCOUNT_ID);
    }

    /**
     * @description test When Account By Id Then Return Xref
     * @author SamikshaDD | 07-12-2024
     **/
    @isTest
    private static void testWhenAccountByIdThenReturnXref() {
        Account storeAccount = new Account(
            Unique_Identifier__c = '1122',
            Name = 'test Store Account',
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert storeAccount;

        Xref__c xref = new Xref__c(
            External_Id__c = '12345',
            Salesforce_Account_Name__c = storeAccount.Id,
            External_ID_Source__c = XREF_EXTERNAL_ID_SOURCE
        );
        insert xref;

        Set<String> accountFieldSet = new Set<String>();
        accountFieldSet.add('Unique_Identifier__c');

        Set<String> xRefFieldSet = new Set<String>();
        xRefFieldSet.add('External_Id__c');

        Map<String, Set<String>> sobjectToSetOfField = new Map<String, Set<String>>();
        sobjectToSetOfField.put('Account', accountFieldSet);
        sobjectToSetOfField.put('Xref', xRefFieldSet);

        Test.startTest();
        List<Account> accounts = AccountsSelector.newInstance()
            .selectAccountByIdWithXref(new Set<Id>{ storeAccount.Id }, sobjectToSetOfField);
        Test.stopTest();

        Assert.areEqual(xref.Id, accounts[0].Xrefs__r[0].Id, 'Xref Id is not the one expected');
    }

    /**
     * @description This method tests the behavior of selecting a store account by UUID with Xrefs.
     * It creates test data including a corporate parent account, a franchise parent account,
     * a store account, a business reference, and an Xref record. Then, it calls the
     * selectStoreAccountByUUIDWithXrefs method of the AccountsSelector class and verifies
     * that the expected store account is returned.
     */
    @isTest
    private static void testWhenSelectStoreAccountByUUIDWithXrefsThenReturnStoreWithXref() {
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Test.startTest();
        Account corporateParent = new Account(
            Name = 'Parent Account',
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert corporateParent;
        Account franchiseParent = new Account(
            Name = 'Franchise Parent Account',
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert franchiseParent;
        Account storeAccount = new Account(
            BillingStreet = ACCOUNT_BILLING_STREET,
            BillingCity = ACCOUNT_BILLING_CITY,
            BillingPostalCode = ACCOUNT_BILLING_POSTAL_CODE,
            BillingCountry = ACCOUNT_BILLING_COUNTRY,
            BillingState = ACCOUNT_BILLING_STATE,
            Name = STORE_ACCOUNT_NAME,
            ParentId = corporateParent.Id,
            RecordTypeId = storeRecordTypeId,
            Franchise_Parent__c = franchiseParent.Id,
            Segment__c = ACCOUNT_SEGMENT_SMB,
            Unique_Identifier__c = 'uuid'
        );
        insert storeAccount;
        Business_Reference__c businessReference = new Business_Reference__c(
            CurrencyIsoCode = 'USD',
            External_Id_Source__c = XREF_EXTERNALID_SOURCE_DRIVE,
            Business_Name__c = 'Test Business Name',
            Default_Type__c = 'Corporate',
            External_Id__c = 'External Id'
        );
        insert businessReference;
        Xref__c xref = new Xref__c(
            External_ID_Source__c = XREF_EXTERNALID_SOURCE_DRIVE,
            Salesforce_Account_Name__c = storeAccount.Id,
            External_ID__c = storeAccount.Id,
            Xref_Status__c = XREF_STATUS_ACTIVE,
            Business_Reference__c = businessReference.Id
        );
        insert xref;

        List<Account> accs = AccountsSelector.newInstance()
            .selectStoreAccountByUUIDWithXrefs(
                new Set<String>{ storeAccount.Unique_Identifier__c },
                new Set<String>{ businessReference.External_Id__c }
            );

        Assert.areEqual(1, accs.size(), 'Account size doesn"t match');
        Assert.areEqual(
            storeAccount.Unique_Identifier__c,
            accs[0].Unique_Identifier__c,
            'Account Id is not the one given'
        );
        Assert.areEqual(1, accs[0].Xrefs__r.size(), 'Xref size doesn"t match');
        Assert.areEqual(xref.Id, accs[0].Xrefs__r[0].Id, 'Xref is not the one required');
    }

    /**
     * @description To test query on Account to retrieve store Accounts related to the given
     * Business Account Ids.
     */
    @isTest
    private static void testWhenSelectStoreAccountsByParentIdThenReturnStoreAccounts() {
        Id storeAccRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();
        Id businessAccRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Test.startTest();
        Account mcDonaldCorporate = new Account(
            Name = 'Parent Account',
            RecordTypeId = businessAccRecordType,
            Type = 'Corporate',
            Primary_Vertical__c = 'CPG',
            Segment__c = 'SMB'
        );
        insert mcDonaldCorporate;

        List<Account> franchiseAccountsList = new List<Account>{
            new Account(
                Name = 'Test 1',
                RecordTypeId = businessAccRecordType,
                BillingStreet = '123 Test Street',
                BillingCity = 'Missoula',
                BillingPostalCode = '59801',
                BillingCountry = 'United States',
                BillingState = 'Montana',
                Segment__c = 'SMB'
            ),
            new Account(
                Name = 'Test 2',
                RecordTypeId = businessAccRecordType,
                BillingStreet = '121213 Test Street',
                BillingCity = 'Missoula',
                BillingPostalCode = '50801',
                BillingCountry = 'United States',
                BillingState = 'Montana',
                Segment__c = 'SMB'
            )
        };

        insert franchiseAccountsList;

        List<Account> storeAccountsList = new List<Account>{
            new Account(
                Name = 'Test 3',
                RecordTypeId = storeAccRecordType,
                BillingStreet = '345 Test Street',
                BillingCity = 'Missoula',
                BillingPostalCode = '59889',
                BillingCountry = 'United States',
                BillingState = 'Montana',
                ParentId = mcDonaldCorporate.Id,
                Segment__c = 'SMB'
            ),
            new Account(
                Name = 'Test 4',
                RecordTypeId = storeAccRecordType,
                BillingStreet = '5679 Test Street',
                BillingCity = 'Missoula',
                BillingPostalCode = '50812',
                BillingCountry = 'United States',
                BillingState = 'Montana',
                ParentId = mcDonaldCorporate.Id,
                Segment__c = 'SMB'
            )
        };

        insert storeAccountsList;

        AccountsSelector accountsInstance = new AccountsSelector();
        List<Account> accounts = accountsInstance.selectStoreAccountsByParentId(
            mcDonaldCorporate.Id
        );
        Test.stopTest();
        System.assertEquals(2, accounts.size(), 'Unexpected store account size');
    }

    /**
     * @description To test query storeAccounts based on Business Account
     */
    @isTest
    private static void testWhenBusinessAccountThenGetStoreAccounts() {
        Account businessAccount = new Account(Name = 'Test Business', Segment__c = 'SMB');
        insert businessAccount;
        Account storeAccount1 = new Account(
            Name = 'Test Store one ',
            ParentId = businessAccount.Id,
            Address_Verification_Status__c = 'Verified',
            Coverage__c = 'In Coverage',
            CreatedDate = DateTime.now().addDays(-1),
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert storeAccount1;
        Account storeAccount2 = new Account(
            Name = 'Test Store two',
            ParentId = businessAccount.Id,
            Address_Verification_Status__c = 'Verified',
            Coverage__c = 'In Coverage',
            CreatedDate = DateTime.now(),
            Segment__c = ACCOUNT_SEGMENT_SMB
        );
        insert storeAccount2;
        List<Account> result = new AccountsSelector()
            .getStoreAccountbyBusinessAccountId(businessAccount.Id);
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(2, result.size(), 'There should be 2 store accounts');
    }
}