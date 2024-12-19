/**
 * @description This is a test class created to test the ManageEntitlementsScreenController
 * @author Deloitte
 * @date 23/12/2023
 */
@isTest(SeeAllData=false)
public with sharing class ManageEntitlementsScreenControllerTest {
    private static final String ACCOUNT_TYPE_BUSINESS = 'Business';
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    private static final String PROVISIONING_STATUS_NOT_STARTED = 'Not Started';
    private static final String STRING_ACCOUNT_ID_COUNT = 'accountIdCount';
    private static final String STRING_ERROR_MESSAGE = 'No error messages was not thrown as expected';
    private static final String STRING_ID = 'Id';
    private static final String TYPE_MARKETPLACE = 'Marketplace';

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenManagePricingThenContractIsPassed() {
        Id contractId = Fake.generateId(Contract.class);
        Id accountId1 = Fake.generateId(Account.class);
        Id accountId2 = Fake.generateId(Account.class);
        Id contractingAccountId = Fake.generateId(Account.class);
        Id groupId1 = Fake.generateId(SBQQ__QuoteLineGroup__c.class);
        Id orderId1 = Fake.generateId(Order.class);
        Id orderItemId1 = Fake.generateId(OrderItem.class);
        Id orderItemId2 = Fake.generateId(OrderItem.class);
        Id orderItemId3 = Fake.generateId(OrderItem.class);
        Id subscriptionId1 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subscriptionId2 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subscriptionId3 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subscriptionId4 = Fake.generateId(SBQQ__Subscription__c.class);
        Id opportunityRecordId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id quoteId = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType);
        Id prod1 = Fake.generateId(Product2.class);
        Id prod2 = Fake.generateId(Product2.class);
        Id prod3 = Fake.generateId(Product2.class);
        Id prod4 = Fake.generateId(Product2.class);

        Fake fakeContractInstance = new Fake(Contract.class)
            .setField(Contract.Name, 'Contract1')
            .setField(Contract.Id, contractId)
            .setField(Contract.SBQQ__Order__c, orderId1)
            .setField(Contract.AccountId, contractingAccountId);

        Fake quoteFakeInstance = new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id, quoteId)
            .setField(SBQQ__Quote__c.SBQQ__Opportunity2__c, opportunityRecordId)
            .setField(SBQQ__Quote__c.SBQQ__Primary__c, 'true')
            .setField(SBQQ__Quote__c.Opt_In_Opt_Out_Decision__c, 'Opt-Out')
            .setField(SBQQ__Quote__c.Opt_In_Opt_Out_Response_Time_in_Days__c, '14')
            .setField(SBQQ__Quote__c.Opt_Out_Save_Period_days__c, '1')
            .setField(SBQQ__Quote__c.Opt_In_Out_Responsible_Party__c, 'DoorDash');

        Fake fakegroup1 = new Fake(SBQQ__QuoteLineGroup__c.class)
            .setField(SBQQ__QuoteLineGroup__c.Id, groupId1)
            .setField(SBQQ__QuoteLineGroup__c.Name, 'Fake 6')
            .setField(SBQQ__QuoteLineGroup__c.SBQQ__Number__c, 1)
            .setField(SBQQ__QuoteLineGroup__c.SBQQ__ListTotal__c, 100)
            .setField(SBQQ__QuoteLineGroup__c.SBQQ__CustomerTotal__c, 12)
            .setField(SBQQ__QuoteLineGroup__c.SBQQ__NetTotal__c, 12)
            .setParent('SBQQ__Quote__r', quoteFakeInstance);

        List<Id> groupList = new List<Id>{ groupId1 };
        SBQQ__Subscription__c subscription1 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId1)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId1)
            .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId1)
            .setfield(SBQQ__Subscription__c.SBQQ__RequiredById__c, null)
            .setfield(SBQQ__Subscription__c.SBQQ__ProductName__c, 'Marketplace')
            .setParent('Quote_Line_Group__r', fakegroup1)
            .setParent('SBQQ__Contract__r', fakeContractInstance)
            .setParent(
                'SBQQ__Product__r',
                new Fake(Product2.class)
                    .setField(Product2.Id, prod1)
                    .setField(Product2.Name, 'Marketplace')
                    .setField(Product2.Package_Eligible_For_Entitlement__c, true)
            )
            .toSObject();
        SBQQ__Subscription__c subscription2 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId2)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId2)
            .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId1)
            .setfield(SBQQ__Subscription__c.SBQQ__RequiredById__c, prod1)
            .setfield(SBQQ__Subscription__c.SBQQ__ProductName__c, 'Dashpass')
            .setParent('Quote_Line_Group__r', fakegroup1)
            .setParent('SBQQ__Contract__r', fakeContractInstance)
            .setParent(
                'SBQQ__Product__r',
                new Fake(Product2.class)
                    .setField(Product2.Id, prod2)
                    .setField(Product2.Name, 'Dashpass')
                    .setField(Product2.Package_Eligible_For_Entitlement__c, false)
            )
            .toSObject();
        SBQQ__Subscription__c subscription3 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId3)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId3)
            .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId1)
            .setfield(SBQQ__Subscription__c.SBQQ__RequiredById__c, null)
            .setfield(SBQQ__Subscription__c.SBQQ__ProductName__c, 'Storefront')
            .setParent('Quote_Line_Group__r', fakegroup1)
            .setParent('SBQQ__Contract__r', fakeContractInstance)
            .setParent(
                'SBQQ__Product__r',
                new Fake(Product2.class)
                    .setField(Product2.Id, prod3)
                    .setField(Product2.Name, 'Storefront')
                    .setField(Product2.Package_Eligible_For_Entitlement__c, true)
            )
            .toSObject();
        SBQQ__Subscription__c subscription4 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId4)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId3)
            .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId1)
            .setfield(SBQQ__Subscription__c.SBQQ__RequiredById__c, prod3)
            .setfield(SBQQ__Subscription__c.SBQQ__ProductName__c, 'Dashpass')
            .setParent('Quote_Line_Group__r', fakegroup1)
            .setParent('SBQQ__Contract__r', fakeContractInstance)
            .setParent(
                'SBQQ__Product__r',
                new Fake(Product2.class)
                    .setField(Product2.Id, prod4)
                    .setField(Product2.Name, 'Dashpass')
                    .setField(Product2.Package_Eligible_For_Entitlement__c, false)
            )
            .toSObject();
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>{
            subscription1,
            subscription2,
            subscription3,
            subscription4
        };
        String mapofSelectedAccounts = accountId1 + ',' + accountId2;
        List<ManageEntitlementsSelectionWrapper> managePricingGroupsWrapperList = new List<ManageEntitlementsSelectionWrapper>();
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        ISubscriptionSelector subscriptionSelectorMock = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );
        mocks.startStubbing();
        mocks.when(subscriptionSelectorMock.sObjectType())
            .thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(subscriptionSelectorMock.selectSubscriptionRecordsByGroup(groupList))
            .thenReturn(subList);
        mocks.when(subscriptionSelectorMock.selectQuoteLineGroupOnSubscription(contractId))
            .thenReturn(groupId1);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(subscriptionSelectorMock);
        managePricingGroupsWrapperList = ManageEntitlementsScreenController.selectExistingSubscriptionsWithGroup(
            mapofSelectedAccounts,
            contractId
        );
        System.assertEquals(managePricingGroupsWrapperList.size(), 1, 'WrapperList is not equal');
    }

    /**
     * @description This method is used to test uploadFile
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenFileIsUploadedThenCallTheService() {
        Id contractId = Fake.generateId(Contract.class);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IContentVersionService contentVersionService = (IContentVersionService) mocks.mock(
            IContentVersionService.class
        );
        Application.SERVICE.setMock(IContentVersionService.class, contentVersionService);

        String blobdata = 'Id,Type,Recordtype';
        String testFileName = 'test.csv';

        ManageEntitlementsScreenController.uploadFile(blobdata, testFileName, contractId);

        ((IContentVersionService) mocks.verify(contentVersionService, 1))
            .createContentVersion(blobdata, testFileName, contractId);
    }

    /**
     * @description This method is used to test processSubmitButtonData
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenSubmitThenProcessRecords() {
        Id contractId = Fake.generateId(Contract.class);
        Id accountId1 = Fake.generateId(Account.class);
        Id accountId2 = Fake.generateId(Account.class);
        Id groupId1 = Fake.generateId(SBQQ__QuoteLineGroup__c.class);
        String accountIdsString1 = String.valueOf(accountId1) + ',' + String.valueOf(accountId2);
        List<AssociatedAccountsWrapper> associatedAccountsWrapperList = new List<AssociatedAccountsWrapper>();
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        associatedAccountsWrapperList.add(
            new AssociatedAccountsWrapper(groupId1, accountIdsString1, contractId, true, null)
        );
        String jsonStr = JSON.serialize(associatedAccountsWrapperList);
        ManageEntitlementsScreenController.processSubmitButtonData(jsonStr, contractId, true);
        ((IContracts) mocks.verify(
                Contracts.newInstance(new List<Contract>{ new Contract(Id = contractId) }),
                1
            ))
            .setAssociatedAccountsWithGroups(associatedAccountsWrapperList, true, 'No');
    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenContractIdPassedThenGetAllSubscription() {
        Id contractId = Fake.generateId(Contract.class);
        Id contractingAccountId = Fake.generateId(Account.class);
        Id groupId1 = Fake.generateId(SBQQ__QuoteLineGroup__c.class);
        Id orderId1 = Fake.generateId(Order.class);
        Id orderItemId1 = Fake.generateId(OrderItem.class);
        Id orderItemId2 = Fake.generateId(OrderItem.class);
        Id orderItemId3 = Fake.generateId(OrderItem.class);
        Id subscriptionId1 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subscriptionId2 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subscriptionId3 = Fake.generateId(SBQQ__Subscription__c.class);
        Id opportunityRecordId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id quoteId = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType);
        Id prod1 = Fake.generateId(Product2.class);
        Id prod2 = Fake.generateId(Product2.class);
        Id prod3 = Fake.generateId(Product2.class);

        Fake fakeContractInstance = new Fake(Contract.class)
            .setField(Contract.Name, 'Contract1')
            .setField(Contract.Id, contractId)
            .setField(Contract.SBQQ__Order__c, orderId1)
            .setField(Contract.AccountId, contractingAccountId);

        Fake quoteFakeInstance = new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id, quoteId)
            .setField(SBQQ__Quote__c.SBQQ__Opportunity2__c, opportunityRecordId)
            .setField(SBQQ__Quote__c.SBQQ__Primary__c, 'true')
            .setField(SBQQ__Quote__c.Opt_In_Opt_Out_Decision__c, 'Opt-Out')
            .setField(SBQQ__Quote__c.Opt_In_Opt_Out_Response_Time_in_Days__c, '14')
            .setField(SBQQ__Quote__c.Opt_Out_Save_Period_days__c, '1')
            .setField(SBQQ__Quote__c.Opt_In_Out_Responsible_Party__c, 'DoorDash');

        Fake fakegroup1 = new Fake(SBQQ__QuoteLineGroup__c.class)
            .setField(SBQQ__QuoteLineGroup__c.Id, groupId1)
            .setField(SBQQ__QuoteLineGroup__c.Name, 'Fake 6')
            .setField(SBQQ__QuoteLineGroup__c.SBQQ__Number__c, 1)
            .setField(SBQQ__QuoteLineGroup__c.SBQQ__ListTotal__c, 100)
            .setField(SBQQ__QuoteLineGroup__c.SBQQ__CustomerTotal__c, 12)
            .setField(SBQQ__QuoteLineGroup__c.SBQQ__NetTotal__c, 12)
            .setParent('SBQQ__Quote__r', quoteFakeInstance);

        SBQQ__Subscription__c subscription1 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId1)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId1)
            .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId1)
            .setfield(SBQQ__Subscription__c.SBQQ__RequiredById__c, '')
            .setParent('Quote_Line_Group__r', fakegroup1)
            .setParent('SBQQ__Contract__r', fakeContractInstance)
            .setParent(
                'SBQQ__Product__r',
                new Fake(Product2.class)
                    .setField(Product2.Id, prod1)
                    .setField(Product2.Name, 'Marketplace')
                    .setField(Product2.Package_Eligible_For_Entitlement__c, true)
            )
            .toSObject();
        SBQQ__Subscription__c subscription2 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId2)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId2)
            .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId1)
            .setfield(SBQQ__Subscription__c.SBQQ__RequiredById__c, prod1)
            .setParent('Quote_Line_Group__r', fakegroup1)
            .setParent('SBQQ__Contract__r', fakeContractInstance)
            .setParent(
                'SBQQ__Product__r',
                new Fake(Product2.class)
                    .setField(Product2.Id, prod2)
                    .setField(Product2.Name, 'Dashpass')
                    .setField(Product2.Package_Eligible_For_Entitlement__c, false)
            )
            .toSObject();
        SBQQ__Subscription__c subscription3 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId3)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId3)
            .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId1)
            .setfield(SBQQ__Subscription__c.SBQQ__RequiredById__c, prod1)
            .setParent('Quote_Line_Group__r', fakegroup1)
            .setParent('SBQQ__Contract__r', fakeContractInstance)
            .setParent(
                'SBQQ__Product__r',
                new Fake(Product2.class)
                    .setField(Product2.Id, prod3)
                    .setField(Product2.Name, 'Dashpass')
                    .setField(Product2.Package_Eligible_For_Entitlement__c, false)
            )
            .toSObject();
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>{
            subscription1,
            subscription2,
            subscription3
        };

        List<Id> groupList = new List<Id>{ groupId1 };

        List<SBQQ__Subscription__c> subscriptionList = new List<SBQQ__Subscription__c>();
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        ISubscriptionSelector subscriptionSelectorMock = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );
        mocks.startStubbing();
        mocks.when(subscriptionSelectorMock.sObjectType())
            .thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(subscriptionSelectorMock.selectQuoteLineGroupOnSubscription(contractId))
            .thenReturn(groupId1);
        mocks.when(subscriptionSelectorMock.selectSubscriptionRecordsByGroup(groupList))
            .thenReturn(subList);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(subscriptionSelectorMock);
        subscriptionList = ManageEntitlementsScreenController.getAllSubscriptionFromContract(
            contractId
        );
        System.assertEquals(subscriptionList.size(), 3, 'Subscription List is not equal');
    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAccountsAndPackagesArePassedThenSelectWorkOrdersByAccountId() {
        Id contractId = Fake.generateId(Contract.class);
        Id accountId1 = Fake.generateId(Account.class);
        Id accountId2 = Fake.generateId(Account.class);
        Id contractingAccountId = Fake.generateId(Account.class);
        Id groupId1 = Fake.generateId(SBQQ__QuoteLineGroup__c.class);
        Id orderId1 = Fake.generateId(Order.class);
        Id orderItemId2 = Fake.generateId(OrderItem.class);
        Id orderItemId3 = Fake.generateId(OrderItem.class);
        Id subscriptionId1 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subscriptionId2 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subscriptionId3 = Fake.generateId(SBQQ__Subscription__c.class);
        Id opportunityRecordId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id quoteId = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType);
        Id prod1 = Fake.generateId(Product2.class);
        Id prod2 = Fake.generateId(Product2.class);
        Id prod3 = Fake.generateId(Product2.class);
        String mapofSelectedAccounts = accountId1 + ',' + accountId2;

        Contract mockContract = (Contract) new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.AccountId, contractingAccountId)
            .setParent(
                'Account',
                new Fake(Account.class).setField(Account.Id, contractingAccountId)
            )
            .toSObject();

        Account account1 = (Account) new Fake(Account.class)
            .setField(Account.Id, accountId1)
            .toSobject();

        Account account2 = (Account) new Fake(Account.class)
            .setField(Account.Id, accountId2)
            .toSobject();
        List<Account> franchiseeStoreAccounts = new List<Account>();
        List<Account> nonFranchiseeStoreAccounts = new List<Account>();
        nonFranchiseeStoreAccounts.add(account1);
        nonFranchiseeStoreAccounts.add(account2);

        Fake fakeContractInstance = new Fake(Contract.class)
            .setField(Contract.Name, 'Contract1')
            .setField(Contract.Id, contractId)
            .setField(Contract.SBQQ__Order__c, orderId1)
            .setField(Contract.AccountId, contractingAccountId);

        Fake quoteFakeInstance = new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id, quoteId)
            .setField(SBQQ__Quote__c.SBQQ__Opportunity2__c, opportunityRecordId)
            .setField(SBQQ__Quote__c.SBQQ__Primary__c, 'true')
            .setField(SBQQ__Quote__c.Opt_In_Opt_Out_Decision__c, 'Opt-Out')
            .setField(SBQQ__Quote__c.Opt_In_Opt_Out_Response_Time_in_Days__c, '14')
            .setField(SBQQ__Quote__c.Opt_Out_Save_Period_days__c, '1')
            .setField(SBQQ__Quote__c.Opt_In_Out_Responsible_Party__c, 'DoorDash');

        Fake fakegroup1 = new Fake(SBQQ__QuoteLineGroup__c.class)
            .setField(SBQQ__QuoteLineGroup__c.Id, groupId1)
            .setField(SBQQ__QuoteLineGroup__c.Name, 'Fake 6')
            .setField(SBQQ__QuoteLineGroup__c.SBQQ__Number__c, 1)
            .setField(SBQQ__QuoteLineGroup__c.SBQQ__ListTotal__c, 100)
            .setField(SBQQ__QuoteLineGroup__c.SBQQ__CustomerTotal__c, 12)
            .setField(SBQQ__QuoteLineGroup__c.SBQQ__NetTotal__c, 12)
            .setParent('SBQQ__Quote__r', quoteFakeInstance);

        SBQQ__Subscription__c subscription2 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId2)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId2)
            .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId1)
            .setfield(SBQQ__Subscription__c.SBQQ__RequiredById__c, prod1)
            .setParent('Quote_Line_Group__r', fakegroup1)
            .setParent('SBQQ__Contract__r', fakeContractInstance)
            .setParent(
                'SBQQ__Product__r',
                new Fake(Product2.class)
                    .setField(Product2.Id, prod2)
                    .setField(Product2.Name, 'Dashpass')
                    .setField(Product2.Package_Eligible_For_Entitlement__c, false)
            )
            .toSObject();

        SBQQ__Subscription__c subscription3 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId3)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId3)
            .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId1)
            .setfield(SBQQ__Subscription__c.SBQQ__RequiredById__c, prod1)
            .setParent('Quote_Line_Group__r', fakegroup1)
            .setParent('SBQQ__Contract__r', fakeContractInstance)
            .setParent(
                'SBQQ__Product__r',
                new Fake(Product2.class)
                    .setField(Product2.Id, prod3)
                    .setField(Product2.Name, 'Delivery')
                    .setField(Product2.Package_Eligible_For_Entitlement__c, false)
            )
            .toSObject();

        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                contractingAccountId,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Provisioning_Status__c, PROVISIONING_STATUS_NOT_STARTED);

        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );

        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>{
            subscription2,
            subscription3
        };

        Set<Id> selectedPackagesIdsSet = new Set<Id>{ subscriptionId1 };
        List<Account> accountList = new List<Account>{ account1, account2 };
        List<Id> storeIds = new List<Id>{ accountId1, accountId2 };
        List<String> selectedPackages = new List<String>{ subscriptionId1 };
        Map<String, String> workOrderTypeAndSubTypesMap = new Map<String, String>();
        workOrderTypeAndSubTypesMap.put('Marketplace', null);
        Boolean isBusinessAccount = false;
        String errorMessage;

        List<Aggregate> corporateCount = new List<Aggregate>{
            new Aggregate().put('Id', null).put('accountIdCount', 0)
        };
        ManageEntitlementsScreenController.ResultVariableWrapper booleanWrapper = new ManageEntitlementsScreenController.ResultVariableWrapper(
            false,
            false,
            false,
            true
        );
        Set<Id> accountIdSet = new Set<Id>{ accountId1, accountId2 };

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        ICcpWorkOrderValidationsService ccpWorkOrderValidationsService = (ICcpWorkOrderValidationsService) mocks.mock(
            ICcpWorkOrderValidationsService.class
        );

        ISubscriptionSelector subscriptionSelectorMock = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );

        IContractsSelector contractsSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );

        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );

        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        mocks.startStubbing();

        mocks.when(contractsSelectorMock.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(contractsSelectorMock.selectById(new Set<Id>{ contractId }))
            .thenReturn(new List<Contract>{ mockContract });

        mocks.when(
                ccpWorkOrderValidationsService.validateWorkOrders(
                    subList,
                    workOrderTypeAndSubTypesMap,
                    isBusinessAccount,
                    booleanWrapper
                )
            )
            .thenReturn('Marketplace');

        mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(mockAccountsSelector.selectAccountsWithParentDetailsById(new Set<Id>(storeIds)))
            .thenReturn(accountList);
        mocks.when(mockAccountsSelector.selectCountOfAccounts(accountIdSet))
            .thenReturn(corporateCount);
        mocks.when(mockAccountsSelector.selectFranchiseeStoreAccountsById(accountIdSet))
            .thenReturn(franchiseeStoreAccounts);
        mocks.when(subscriptionSelectorMock.sObjectType())
            .thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(subscriptionSelectorMock.querySubscriptionRecords(selectedPackagesIdsSet))
            .thenReturn(subList);

        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrdersSelector.selectByAccountIds(new Set<Id>{ contractingAccountId }))
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });

        mocks.stopStubbing();
        String contractIdString = String.valueOf(contractId);
        Application.SELECTOR.setMock(subscriptionSelectorMock);
        Application.SELECTOR.setMock(contractsSelectorMock);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockAccountsSelector);
        Application.SERVICE.setMock(
            ICcpWorkOrderValidationsService.class,
            ccpWorkOrderValidationsService
        );
        try {
            ManageEntitlementsScreenController.selectWorkOrdersByAccountId(
                mapofSelectedAccounts,
                contractIdString,
                selectedPackages,
                JSON.serialize(booleanWrapper)
            );
        } catch (Exception ex) {
            errorMessage = ex.getMessage();
        }

        System.assert(errorMessage == null, 'Exception Messages was not thrown as expected');
    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenFranchiseAccountsAndPackagesArePassedThenDontThrowWorkorderValidation() {
        Id contractId = Fake.generateId(Contract.class);
        Id accountId1 = Fake.generateId(Account.class);
        Id accountId2 = Fake.generateId(Account.class);
        Id contractingAccountId = Fake.generateId(Account.class);
        Id groupId1 = Fake.generateId(SBQQ__QuoteLineGroup__c.class);
        Id orderId1 = Fake.generateId(Order.class);
        Id orderItemId2 = Fake.generateId(OrderItem.class);
        Id orderItemId3 = Fake.generateId(OrderItem.class);
        Id subscriptionId1 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subscriptionId2 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subscriptionId3 = Fake.generateId(SBQQ__Subscription__c.class);
        Id opportunityRecordId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id quoteId = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType);
        Id prod1 = Fake.generateId(Product2.class);
        Id prod2 = Fake.generateId(Product2.class);
        Id prod3 = Fake.generateId(Product2.class);
        String mapofSelectedAccounts = accountId1 + ',' + accountId2;

        Contract mockContract = (Contract) new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.AccountId, contractingAccountId)
            .setParent(
                'Account',
                new Fake(Account.class).setField(Account.Id, contractingAccountId)
            )
            .toSObject();

        Account account1 = (Account) new Fake(Account.class)
            .setField(Account.Id, accountId1)
            .toSobject();

        Account account2 = (Account) new Fake(Account.class)
            .setField(Account.Id, accountId2)
            .toSobject();
        List<Account> franchiseeStoreAccounts = new List<Account>();
        franchiseeStoreAccounts.add(account1);
        franchiseeStoreAccounts.add(account2);

        Fake fakeContractInstance = new Fake(Contract.class)
            .setField(Contract.Name, 'Contract1')
            .setField(Contract.Id, contractId)
            .setField(Contract.SBQQ__Order__c, orderId1)
            .setField(Contract.AccountId, contractingAccountId);

        Fake quoteFakeInstance = new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id, quoteId)
            .setField(SBQQ__Quote__c.SBQQ__Opportunity2__c, opportunityRecordId)
            .setField(SBQQ__Quote__c.SBQQ__Primary__c, 'true')
            .setField(SBQQ__Quote__c.Opt_In_Opt_Out_Decision__c, 'Opt-Out')
            .setField(SBQQ__Quote__c.Opt_In_Opt_Out_Response_Time_in_Days__c, '14')
            .setField(SBQQ__Quote__c.Opt_Out_Save_Period_days__c, '1')
            .setField(SBQQ__Quote__c.Opt_In_Out_Responsible_Party__c, 'DoorDash');

        Fake fakegroup1 = new Fake(SBQQ__QuoteLineGroup__c.class)
            .setField(SBQQ__QuoteLineGroup__c.Id, groupId1)
            .setField(SBQQ__QuoteLineGroup__c.Name, 'Fake 6')
            .setField(SBQQ__QuoteLineGroup__c.SBQQ__Number__c, 1)
            .setField(SBQQ__QuoteLineGroup__c.SBQQ__ListTotal__c, 100)
            .setField(SBQQ__QuoteLineGroup__c.SBQQ__CustomerTotal__c, 12)
            .setField(SBQQ__QuoteLineGroup__c.SBQQ__NetTotal__c, 12)
            .setParent('SBQQ__Quote__r', quoteFakeInstance);

        SBQQ__Subscription__c subscription2 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId2)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId2)
            .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId1)
            .setfield(SBQQ__Subscription__c.SBQQ__RequiredById__c, prod1)
            .setParent('Quote_Line_Group__r', fakegroup1)
            .setParent('SBQQ__Contract__r', fakeContractInstance)
            .setParent(
                'SBQQ__Product__r',
                new Fake(Product2.class)
                    .setField(Product2.Id, prod2)
                    .setField(Product2.Name, 'Dashpass')
                    .setField(Product2.Package_Eligible_For_Entitlement__c, false)
            )
            .toSObject();

        SBQQ__Subscription__c subscription3 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId3)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId3)
            .setfield(SBQQ__Subscription__c.Quote_Line_Group__c, groupId1)
            .setfield(SBQQ__Subscription__c.SBQQ__RequiredById__c, prod1)
            .setParent('Quote_Line_Group__r', fakegroup1)
            .setParent('SBQQ__Contract__r', fakeContractInstance)
            .setParent(
                'SBQQ__Product__r',
                new Fake(Product2.class)
                    .setField(Product2.Id, prod3)
                    .setField(Product2.Name, 'Delivery')
                    .setField(Product2.Package_Eligible_For_Entitlement__c, false)
            )
            .toSObject();

        Fake parentWorkOrderFakeInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                contractingAccountId,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Provisioning_Status__c, PROVISIONING_STATUS_NOT_STARTED);

        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            parentWorkOrderFakeInstance
        );

        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>{
            subscription2,
            subscription3
        };

        Set<Id> selectedPackagesIdsSet = new Set<Id>{ subscriptionId1 };
        List<Account> accountList = new List<Account>{ account1, account2 };
        List<Id> storeIds = new List<Id>{ accountId1, accountId2 };
        List<String> selectedPackages = new List<String>{ subscriptionId1 };
        Map<String, String> workOrderTypeAndSubTypesMap = new Map<String, String>();
        workOrderTypeAndSubTypesMap.put('Marketplace', null);
        Boolean isBusinessAccount = false;
        Boolean isProcessingExistingAccounts = true;
        String errorMessage;

        List<Aggregate> corporateCount = new List<Aggregate>{
            new Aggregate().put('Id', null).put('accountIdCount', 0)
        };
        ManageEntitlementsScreenController.ResultVariableWrapper booleanWrapper = new ManageEntitlementsScreenController.ResultVariableWrapper(
            false,
            false,
            false,
            true
        );
        booleanWrapper.isProcessingExistingAccounts = false;
        booleanWrapper.isProcessingNewAndCoo = false;
        booleanWrapper.isProcessingOnlyCoo = false;
        booleanWrapper.isProcessingOnlyNew = true;

        Set<Id> accountIdSet = new Set<Id>{ accountId1, accountId2 };

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        ICcpWorkOrderValidationsService ccpWorkOrderValidationsService = (ICcpWorkOrderValidationsService) mocks.mock(
            ICcpWorkOrderValidationsService.class
        );

        ISubscriptionSelector subscriptionSelectorMock = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );

        IContractsSelector contractsSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );

        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );

        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        mocks.startStubbing();

        mocks.when(contractsSelectorMock.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(contractsSelectorMock.selectById(new Set<Id>{ contractId }))
            .thenReturn(new List<Contract>{ mockContract });

        mocks.when(
                ccpWorkOrderValidationsService.validateWorkOrders(
                    subList,
                    workOrderTypeAndSubTypesMap,
                    isBusinessAccount,
                    booleanWrapper
                )
            )
            .thenReturn('Marketplace');

        mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(mockAccountsSelector.selectAccountsWithParentDetailsById(new Set<Id>(storeIds)))
            .thenReturn(accountList);
        mocks.when(mockAccountsSelector.selectCountOfAccounts(accountIdSet))
            .thenReturn(corporateCount);
        mocks.when(mockAccountsSelector.selectFranchiseeStoreAccountsById(accountIdSet))
            .thenReturn(franchiseeStoreAccounts);
        mocks.when(subscriptionSelectorMock.sObjectType())
            .thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(subscriptionSelectorMock.querySubscriptionRecords(selectedPackagesIdsSet))
            .thenReturn(subList);

        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrdersSelector.selectByAccountIds(new Set<Id>{ contractingAccountId }))
            .thenReturn(new List<WorkOrder>{ parentWorkOrder });

        mocks.stopStubbing();
        String contractIdString = String.valueOf(contractId);
        Application.SELECTOR.setMock(subscriptionSelectorMock);
        Application.SELECTOR.setMock(contractsSelectorMock);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockAccountsSelector);
        Application.SERVICE.setMock(
            ICcpWorkOrderValidationsService.class,
            ccpWorkOrderValidationsService
        );
        ManageEntitlementsScreenController.ResultVariableWrapper variableWrapper = new ManageEntitlementsScreenController.ResultVariableWrapper(
            false,
            false,
            false,
            true
        );

        try {
            ManageEntitlementsScreenController.selectWorkOrdersByAccountId(
                mapofSelectedAccounts,
                contractIdString,
                selectedPackages,
                JSON.serialize(variableWrapper)
            );
        } catch (Exception ex) {
            errorMessage = ex.getMessage();
        }

        System.assertEquals(errorMessage, null, 'Error should not be thrown');
    }

    /**
     * @description To test whether no error message is thrown when Business Account Ids
     * are uploaded via Manage Store for Drive Work Order
     */
    @isTest
    private static void testWhenBusinessAccountIdsArePassedThenThrowNoError() {
        Id contractId = Fake.generateId(Contract.class);
        Id accountId1 = Fake.generateId(Account.class);
        Id accountId2 = Fake.generateId(Account.class);
        Id contractingAccountId = Fake.generateId(Account.class);
        Id subscriptionId = Fake.generateId(SBQQ__Subscription__c.class);

        String mapofSelectedAccounts = accountId1 + ',' + accountId2;
		String contractIdString = String.valueOf(contractId);
        String errorMessage;

        Contract mockContract = (Contract) new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.AccountId, contractingAccountId)
            .setParent(
                'Account',
                new Fake(Account.class).setField(Account.Id, contractingAccountId)
            )
            .toSObject();

        Account account1 = (Account) new Fake(Account.class)
            .setField(Account.Id, accountId1)
            .setField(Account.RecordType.Name, ACCOUNT_TYPE_BUSINESS)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .toSobject();

        Account account2 = (Account) new Fake(Account.class)
            .setField(Account.Id, accountId2)
            .setField(Account.RecordType.Name, ACCOUNT_TYPE_BUSINESS)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .toSobject();

        List<Account> accountList = new List<Account>{ account1, account2 };
        List<Id> storeIds = new List<Id>{ accountId1, accountId2 };
        List<String> selectedPackages = new List<String>{ subscriptionId };
        List<Account> franchiseeStoreAccounts = new List<Account>();
        Set<Id> accountIdSet = new Set<Id>{ accountId1, accountId2 };
        List<Aggregate> corporateCount = new List<Aggregate>{
            new Aggregate().put(STRING_ID, null).put(STRING_ACCOUNT_ID_COUNT, 2)
        };
        ManageEntitlementsScreenController.ResultVariableWrapper booleanWrapper = new ManageEntitlementsScreenController.ResultVariableWrapper(
            false,
            false,
            false,
            false
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IContractsSelector contractsSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );

        mocks.startStubbing();
        mocks.when(contractsSelectorMock.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(contractsSelectorMock.selectById(new Set<Id>{ contractId }))
            .thenReturn(new List<Contract>{ mockContract });
        mocks.when(mockAccountsSelector.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(mockAccountsSelector.selectAccountsWithParentDetailsById(new Set<Id>(storeIds)))
            .thenReturn(accountList);
        mocks.when(mockAccountsSelector.selectCountOfAccounts(accountIdSet))
            .thenReturn(corporateCount);
        mocks.when(mockAccountsSelector.selectFranchiseeStoreAccountsById(accountIdSet))
            .thenReturn(franchiseeStoreAccounts);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(contractsSelectorMock);
        Application.SELECTOR.setMock(mockAccountsSelector);

        try {
            Test.startTest();
            ManageEntitlementsScreenController.selectWorkOrdersByAccountId(
                mapofSelectedAccounts,
                contractIdString,
                selectedPackages,
                JSON.serialize(booleanWrapper)
            );
            Test.stoptest();
        } catch (Exception ex) {
            errorMessage = ex.getMessage();
        }
		System.assertEquals(null, errorMessage, STRING_ERROR_MESSAGE);
    }

}