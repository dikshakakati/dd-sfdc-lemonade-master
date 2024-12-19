/**
 * @author Deloitte
 * @date 25/07/2022
 * @description Test Class for MerchantPopUpResponseController
 */
@isTest(seeAllData=false)
private class MerchantPopUpResponseControllerTest {
    private static final String EXTERNAL_ID_SOURCE = 'DriveDB';
    private static final String LICENSOR = 'Licensor';
    private static final String DAYS_TO_ADD_TO_OPPORTUNITY_CLOSE_DATE = '90 Days';
    private static final String PRIMARY_VERTICAL_ALCOHOL = 'Alcohol';
    private static final String PRODUCT_MARKETPLACE = 'Marketplace';
    private static final String VERTICAL_NAME = 'misc_retail_ui';
    private static final String BUSINESS_VERTICAL_NAME1 = 'Business Vertical 1';
    private static final String BUSINESS_VERTICAL_NAME2 = 'Business Vertical 2';
    private static final String MENU_UI_TYPE_RETAIL = 'Retail';

    @isTest
    private static void testWhenUrlsAreRequiredThenControllerFetchesUrlMappings() {
        List<Nintex_URL_Mapping__mdt> customMetadataMocks = new List<Nintex_URL_Mapping__mdt>{
            new Nintex_URL_Mapping__mdt(
                MasterLabel = 'Franchise US',
                DeveloperName = 'Franchise_US',
                URL__c = 'https://www.google.com'
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        INintexUrlMappingSelector mockNintexUrlMappingSelector = (INintexUrlMappingSelector) mocks.mock(
            INintexUrlMappingSelector.class
        );
        Map<String, String> expectedMapping = new Map<String, String>();
        expectedMapping.put('Franchise_US', 'https://www.google.com');

        Map<String, String> resultantMapping = new Map<String, String>();

        mocks.startStubbing();
        mocks.when(mockNintexUrlMappingSelector.SObjectType())
            .thenReturn(Nintex_URL_Mapping__mdt.SObjectType);
        mocks.when(mockNintexUrlMappingSelector.getAllValues()).thenReturn(customMetadataMocks);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockNintexUrlMappingSelector);

        resultantMapping = MerchantPopUpResponseController.fetchUrls();

        System.assertEquals(
            expectedMapping,
            resultantMapping,
            'The expected list of URL Mappings were not fetched in the controller.'
        );
    }

    /**
     * @description To test whether the Account Relationship records of type Franchise are retrieved for the provided Corporate Business Account.
     */
    @isTest
    private static void testWhenCorporateAccountIdIsPassedThenAllAccountRelationshipsRetrieved() {
        Id corporateAccount = fflib_IDGenerator.generate(Account.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        List<Account> childAccounts = new List<Account>{
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType)),
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType))
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );

        mocks.startStubbing();
        mocks.when(mockAccountsSelector.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                mockAccountsSelector.selectStoreAccountsByParentIds(
                    new Set<String>{ corporateAccount },
                    EXTERNAL_ID_SOURCE,
                    contractId
                )
            )
            .thenReturn(childAccounts);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockAccountsSelector);

        List<Account> retrievedChildAccounts = MerchantPopUpResponseController.getFranchiseAccounts(
            corporateAccount,
            EXTERNAL_ID_SOURCE,
            contractId
        );

        System.assertEquals(
            childAccounts,
            retrievedChildAccounts,
            'The expected list of Relationships were not fetched in the controller.'
        );
    }

    /**
     * @description To test whether the Subscription Records with CoD Product are retrieved for the given Contract
     */
    @isTest
    private static void testWhenContractIdIsPassedThenAllSubscriptionsWithCoDProductsAreRetrieved() {
        Id contractWithCoDSubscriptions = fflib_IDGenerator.generate(Contract.SObjectType);
        Id contractWithoutCoDSubscriptions = fflib_IDGenerator.generate(Contract.SObjectType);
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>{
            new SBQQ__Subscription__c(
                Id = fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType)
            ),
            new SBQQ__Subscription__c(
                Id = fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType)
            )
        };
        List<SBQQ__Subscription__c> noSubscriptions = new List<SBQQ__Subscription__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        ISubscriptionSelector mockSubscriptionsSelector = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );

        mocks.startStubbing();
        mocks.when(mockSubscriptionsSelector.SObjectType())
            .thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(
                mockSubscriptionsSelector.selectByContractAndCoDProduct(
                    new Set<String>{ contractWithCoDSubscriptions }
                )
            )
            .thenReturn(subscriptions);
        mocks.when(
                mockSubscriptionsSelector.selectByContractAndCoDProduct(
                    new Set<String>{ contractWithoutCoDSubscriptions }
                )
            )
            .thenReturn(noSubscriptions);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockSubscriptionsSelector);

        Boolean haveSubscriptionsBeenRetrieved1 = MerchantPopUpResponseController.getSubscriptionsWithCoDProduct(
            contractWithCoDSubscriptions
        );
        Boolean haveSubscriptionsBeenRetrieved2 = MerchantPopUpResponseController.getSubscriptionsWithCoDProduct(
            contractWithoutCoDSubscriptions
        );

        System.assertEquals(
            true,
            haveSubscriptionsBeenRetrieved1,
            'The expected list of Subscriptions were not fetched in the controller.'
        );
        System.assertEquals(
            false,
            haveSubscriptionsBeenRetrieved2,
            'The expected list of Subscriptions were not fetched in the controller.'
        );
    }

    /**
     * @description To test whether the Subscription Records with CoD Product are retrieved for the given Contract
     */
    @isTest
    private static void testWhenContractIdIsPassedThenAllSubscriptionsWithDriveProductsAreRetrieved() {
        Id contractWithDriveSubscriptions = fflib_IDGenerator.generate(Contract.SObjectType);
        Id contractWithoutDriveSubscriptions = fflib_IDGenerator.generate(Contract.SObjectType);
        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>{
            new SBQQ__Subscription__c(
                Id = fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType)
            ),
            new SBQQ__Subscription__c(
                Id = fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType)
            )
        };
        List<SBQQ__Subscription__c> noSubscriptions = new List<SBQQ__Subscription__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        ISubscriptionSelector mockSubscriptionsSelector = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );

        mocks.startStubbing();
        mocks.when(mockSubscriptionsSelector.SObjectType())
            .thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(
                mockSubscriptionsSelector.selectByContractAndDriveProduct(
                    new Set<String>{ contractWithDriveSubscriptions }
                )
            )
            .thenReturn(subscriptions);
        mocks.when(
                mockSubscriptionsSelector.selectByContractAndDriveProduct(
                    new Set<String>{ contractWithoutDriveSubscriptions }
                )
            )
            .thenReturn(noSubscriptions);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockSubscriptionsSelector);

        List<SBQQ__Subscription__c> retrievedSusbcriptions = MerchantPopUpResponseController.getDriveSubscriptions(
            contractWithDriveSubscriptions
        );
        List<SBQQ__Subscription__c> emptySubscriptions = MerchantPopUpResponseController.getDriveSubscriptions(
            contractWithoutDriveSubscriptions
        );

        System.assertEquals(
            2,
            retrievedSusbcriptions.size(),
            'The expected list of Subscriptions were not fetched in the controller'
        );
        System.assertEquals(
            0,
            emptySubscriptions.size(),
            'The expected list of Subscriptions were not fetched in the controller'
        );
    }

    /**
     * @description To test whether Opportunity service is called for Opportunity creation when Franchise Accounts are passed.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenFranchiseAccountsReceivedThenOpportunityServiceCalled() {
        List<Id> selectedFranchiseAccountIds = new List<Id>{
            fflib_IDGenerator.generate(Account.SObjectType),
            fflib_IDGenerator.generate(Account.SObjectType)
        };
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        String daysToAdd = DAYS_TO_ADD_TO_OPPORTUNITY_CLOSE_DATE;

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunitiesService serviceMock = (IOpportunitiesService) mocks.mock(
            IOpportunitiesService.class
        );
        Application.SERVICE.setMock(IOpportunitiesService.class, serviceMock);
        MerchantPopUpResponseController.createOpportunities(
            selectedFranchiseAccountIds,
            contractId,
            EXTERNAL_ID_SOURCE,
            daysToAdd
        );
        ((IOpportunitiesService) mocks.verify(serviceMock, 1))
            .createOpportunitiesOnFranchiseAccounts(
                selectedFranchiseAccountIds,
                contractId,
                EXTERNAL_ID_SOURCE,
                daysToAdd
            );
    }

    @isTest
    private static void testWhenGetAllFieldsCalledWithFieldSetAndObjectApiNameThenConfiguredFieldsReturned() {
        List<String> listOfFields = MerchantPopUpResponseController.getFields(
            'Merchant_Pop_Up_Response__c',
            'Rate_Change_Use_Case'
        );
        System.assertEquals(
            'Form_Language__c',
            listOfFields[0],
            'Unexpected Error:Field Name is not matching'
        );
    }

    /**
     * @description To test whether the Subscription Records with Product(Delivery, Pickup, DashPass) are retrieved for the given Contract
     */
    @isTest
    private static void testWhenContractIdIsPassedThenSubscribedProductsAreRetrieved() {
        Id subscriptionId1 = fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType);
        Id subscriptionId2 = fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType);
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Account accountAssociatedWithSubscription = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Parent 1')
            .setField(Account.Type, 'Franchisee')
            .setField(Account.Id, accountId)
            .toSObject();
        Id contractWithSubscriptions = fflib_IDGenerator.generate(Contract.SObjectType);
        Id contractWithoutSubscriptions = fflib_IDGenerator.generate(Contract.SObjectType);

        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>{
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.Id, subscriptionId1)
                .setField(SBQQ__Subscription__c.SBQQ__ProductName__c, 'Dashpass')
                .setField(
                    SBQQ__Subscription__c.SBQQ__Account__c,
                    accountAssociatedWithSubscription.Id
                )
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, contractWithSubscriptions)
                .toSObject(),
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.Id, subscriptionId2)
                .setField(SBQQ__Subscription__c.SBQQ__ProductName__c, 'Pickup')
                .setField(
                    SBQQ__Subscription__c.SBQQ__Account__c,
                    accountAssociatedWithSubscription.Id
                )
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, contractWithSubscriptions)
                .toSObject()
        };
        List<SBQQ__Subscription__c> noSubscriptions = new List<SBQQ__Subscription__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        ISubscriptionSelector mockSubscriptionsSelector = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );

        mocks.startStubbing();
        mocks.when(mockSubscriptionsSelector.SObjectType())
            .thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(
                mockSubscriptionsSelector.selectByContractAndProducts(
                    new Set<String>{ contractWithSubscriptions }
                )
            )
            .thenReturn(subscriptions);
        mocks.when(
                mockSubscriptionsSelector.selectByContractAndProducts(
                    new Set<String>{ contractWithoutSubscriptions }
                )
            )
            .thenReturn(noSubscriptions);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockSubscriptionsSelector);

        List<String> retrievedProducts = MerchantPopUpResponseController.getSubscriptionsForOptionalProductSelection(
            contractWithSubscriptions
        );
        List<String> emptyProducts = MerchantPopUpResponseController.getSubscriptionsForOptionalProductSelection(
            contractWithoutSubscriptions
        );

        System.assertEquals(
            2,
            retrievedProducts.size(),
            'The expected list of products were not fetched in the controller.'
        );
        System.assertEquals(
            0,
            emptyProducts.size(),
            'The expected list of products were not fetched in the controller.'
        );
    }

    /**
     * @description To test whether the Contract has Alcohol Products subscriptions.
     */
    @isTest
    private static void testWhenContractHasAlcoholProductsSubscriptionThenReturnTrue() {
        Id subscriptionId1 = fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType);
        Id subscriptionId2 = fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType);
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Account accountAssociatedWithSubscription = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Parent 1')
            .setField(Account.Type, 'Franchisee')
            .setField(Account.Id, accountId)
            .toSObject();
        Id contractWithAlcoholSubscriptions = fflib_IDGenerator.generate(Contract.SObjectType);
        Id contractWithoutAlcoholSubscriptions = fflib_IDGenerator.generate(Contract.SObjectType);

        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>{
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.Id, subscriptionId1)
                .setField(SBQQ__Subscription__c.SBQQ__ProductName__c, 'Alcohol Delivery')
                .setField(
                    SBQQ__Subscription__c.SBQQ__Account__c,
                    accountAssociatedWithSubscription.Id
                )
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, contractWithAlcoholSubscriptions)
                .toSObject(),
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.Id, subscriptionId2)
                .setField(SBQQ__Subscription__c.SBQQ__ProductName__c, 'Alcohol Pickup')
                .setField(
                    SBQQ__Subscription__c.SBQQ__Account__c,
                    accountAssociatedWithSubscription.Id
                )
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, contractWithAlcoholSubscriptions)
                .toSObject(),
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.Id, subscriptionId2)
                .setField(SBQQ__Subscription__c.SBQQ__ProductName__c, 'Marketplace')
                .setField(
                    SBQQ__Subscription__c.SBQQ__Account__c,
                    accountAssociatedWithSubscription.Id
                )
                .setField(
                    SBQQ__Subscription__c.SBQQ__Contract__c,
                    contractWithoutAlcoholSubscriptions
                )
                .toSObject()
        };
        List<SBQQ__Subscription__c> noSubscriptions = new List<SBQQ__Subscription__c>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        ISubscriptionSelector mockSubscriptionsSelector = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );

        mocks.startStubbing();
        mocks.when(mockSubscriptionsSelector.SObjectType())
            .thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(
                mockSubscriptionsSelector.selectCorporateSubscriptionsByContractIdsAndAlcoholProducts(
                    new Set<String>{ contractWithAlcoholSubscriptions }
                )
            )
            .thenReturn(subscriptions);
        mocks.when(
                mockSubscriptionsSelector.selectCorporateSubscriptionsByContractIdsAndAlcoholProducts(
                    new Set<String>{ contractWithoutAlcoholSubscriptions }
                )
            )
            .thenReturn(noSubscriptions);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockSubscriptionsSelector);

        Boolean haveSubscriptionsBeenRetrieved1 = MerchantPopUpResponseController.hasAlcoholProductsSubscription(
            contractWithAlcoholSubscriptions
        );
        Boolean haveSubscriptionsBeenRetrieved2 = MerchantPopUpResponseController.hasAlcoholProductsSubscription(
            contractWithoutAlcoholSubscriptions
        );

        System.assertEquals(
            true,
            haveSubscriptionsBeenRetrieved1,
            'The expected list of Subscriptions were not fetched in the controller.'
        );
        System.assertEquals(
            false,
            haveSubscriptionsBeenRetrieved2,
            'The expected list of Subscriptions were not fetched in the controller.'
        );
    }

    /**
     * @description This method is used to test if record Id of the Response is computed each time a Response is passed to getEncryptedId method.
     */
    @isTest
    private static void testWhenResponseIsInsertedThenEncryptedComputationIsInitiated() {
        Merchant_Response_Encryption__c encryptionSetting = new Merchant_Response_Encryption__c();
        encryptionSetting.Encryption_Key__c = '3';
        encryptionSetting.Encryption_Algorithm__c = 'HmacSHA256';
        insert encryptionSetting;
        Merchant_Pop_Up_Response__c merchantResponse = new Merchant_Pop_Up_Response__c(
            Form_Type__c = 'Drive'
        );
        List<Id> listOfIds = new List<Id>();
        insert merchantResponse;
        listOfIds.add(merchantResponse.Id);
        String encryptedID = MerchantPopUpResponseController.getEncryptedId(merchantResponse.Id);
        List<String> encryptedIDs = MerchantPopUpResponseController.getEncryptedId(listOfIds);
        System.assertEquals(true, String.Isnotblank(encryptedID), 'The encryptedID is blank.');
        System.assertEquals(true, String.Isnotblank(encryptedIDs[0]), 'The encryptedIDs is blank.');
    }

    /**
     * @description To test query on Account to fetch corporate Accounts in hierarchy
     * by using the passed parent Ids
     */
    @isTest
    private static void testWhenCorporateAccountIdIsPassedThenAllChildCorporatesRetrieved() {
        Id corporateAccount = fflib_IDGenerator.generate(Account.SObjectType);
        List<Account> childAccounts = new List<Account>{
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Type = 'Corporate'),
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Type = 'Corporate')
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );

        mocks.startStubbing();
        mocks.when(mockAccountsSelector.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                mockAccountsSelector.selectAllChildCorporateAccountsWithParent(
                    new Set<String>{ corporateAccount }
                )
            )
            .thenReturn(childAccounts);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockAccountsSelector);

        List<Account> retrievedChildAccounts = MerchantPopUpResponseController.getCorporateAccounts(
            (String) corporateAccount
        );

        System.assertEquals(
            childAccounts,
            retrievedChildAccounts,
            'The expected list of Relationships were not fetched in the controller.'
        );
    }

    /**
     * @description It is used to test whether fetching Nintex_COO_Store_No_Match_Exception_Log queue member emails in a string.
     */
    @isTest
    private static void testWhenToGetEmailsOfAQueueThenAllEmailsInAString() {
        String queueName = 'Nintex_COO_Store_No_Match_Exception_Log';
        Id userFakeId1 = fflib_IDGenerator.generate(User.SObjectType);
        Id userFakeId2 = fflib_IDGenerator.generate(User.SObjectType);

        List<GroupMember> members = new List<GroupMember>{
            new GroupMember(
                Id = fflib_IDGenerator.generate(GroupMember.SObjectType),
                UserOrGroupId = userFakeId1
            ),
            new GroupMember(
                Id = fflib_IDGenerator.generate(GroupMember.SObjectType),
                UserOrGroupId = userFakeId2
            )
        };
        List<User> users = new List<user>{
            new User(Id = userFakeId1, Email = 'test1@user.com'),
            new User(Id = userFakeId2, Email = 'test2@user.com')
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IGroupMembersSelector mockGroupMemberSelector = (IGroupMembersSelector) mocks.mock(
            IGroupMembersSelector.class
        );
        IUsersSelector mockUsersSelector = (IUsersSelector) mocks.mock(IUsersSelector.class);

        mocks.startStubbing();
        mocks.when(mockGroupMemberSelector.SObjectType()).thenReturn(GroupMember.SObjectType);
        mocks.when(mockGroupMemberSelector.selectGroupMembersByQueueName(queueName))
            .thenReturn(members);
        mocks.when(mockUsersSelector.SObjectType()).thenReturn(User.SObjectType);

        mocks.when(mockUsersSelector.selectUsersById(new Set<Id>{ userFakeId1, userFakeId2 }))
            .thenReturn(users);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockGroupMemberSelector);
        Application.SELECTOR.setMock(mockUsersSelector);

        String stringOfEmails = MerchantPopUpResponseController.getEmailsOfQueueMembers();
        System.assertEquals(
            stringOfEmails,
            ';test1@user.com;test2@user.com',
            'The expected string of emails were not fetched in the controller.'
        );
    }

    /**
     * @description To test whether Business Vertical is fetched for Marketplace Merchant Pop-up
     */
    @isTest
    private static void testWhenBusinessVerticalThenMarketplaceInMerchantpopup() {
        List<Business_Vertical__c> businessVerticals = new List<Business_Vertical__c>();
        Business_Vertical__c businessVertical1 = new Business_Vertical__c(
            Name = BUSINESS_VERTICAL_NAME1,
            Primary_Vertical__c = PRIMARY_VERTICAL_ALCOHOL,
            Menu_UI_Type__c = MENU_UI_TYPE_RETAIL,
            Product__c = PRODUCT_MARKETPLACE,
            Vertical_Name__c = VERTICAL_NAME
        );
        insert businessVertical1;
        Business_Vertical__c businessVertical2 = new Business_Vertical__c(
            Name = BUSINESS_VERTICAL_NAME2,
            Primary_Vertical__c = PRIMARY_VERTICAL_ALCOHOL,
            Menu_UI_Type__c = MENU_UI_TYPE_RETAIL,
            Product__c = PRODUCT_MARKETPLACE,
            Vertical_Name__c = VERTICAL_NAME
        );
        insert businessVertical2;
        businessVerticals.add(businessVertical1);
        businessVerticals.add(businessVertical2);

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IBusinessVerticalsSelector mockBusinessVerticalsSelector = (IBusinessVerticalsSelector) mocks.mock(
            IBusinessVerticalsSelector.class
        );

        mocks.startStubbing();
        mocks.when(mockBusinessVerticalsSelector.selectBusinessVerticalRecords())
            .thenReturn(businessVerticals);

        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockBusinessVerticalsSelector);

        List<Business_Vertical__c> retrievedBusinessVertical = MerchantPopUpResponseController.getBusinessVerticals();
        System.assertEquals(
            2,
            retrievedBusinessVertical.size(),
            'The expected list of Business Verticals were not fetched in the controller.'
        );
    }

    /**
     * @description To test whether method used to fetch Menu UI Type related to the selected Business Vertical
     */
    @isTest
    private static void testWhenBusinessVerticalThenFetchMenuUI() {
        Business_Vertical__c businessVertical = new Business_Vertical__c(
            Name = BUSINESS_VERTICAL_NAME1,
            Primary_Vertical__c = PRIMARY_VERTICAL_ALCOHOL,
            Menu_UI_Type__c = MENU_UI_TYPE_RETAIL,
            Product__c = PRODUCT_MARKETPLACE,
            Vertical_Name__c = VERTICAL_NAME
        );
        insert businessVertical;
        Merchant_Pop_Up_Response__c merchantResponse = new Merchant_Pop_Up_Response__c(
            Form_Type__c = PRODUCT_MARKETPLACE
        );
        insert merchantResponse;
        String menuUIType = MerchantPopUpResponseController.getMenuUITypeByBusinessVerticals(
            businessVertical.Id
        );
        System.assertEquals(
            MENU_UI_TYPE_RETAIL,
            menuUIType,
            'The expected Menu UI Type were not fetched in the controller.'
        );
    }
}