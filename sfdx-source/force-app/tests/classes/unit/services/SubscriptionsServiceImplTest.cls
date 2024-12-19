/**
 * @author Deloitte
 * @date 06/07/2024
 * @description Test class for SubscriptionsServiceImpl class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 */
@isTest
private class SubscriptionsServiceImplTest {
    private static final String SSMO_CREATION_SOURCE = 'SSMO';
    private static final String POS_ORDER_PROTOCOL = 'POS';
    private static final String SMB_SEGMENT_TYPE = 'SMB';
    private static final String PRODUCT_FAMILY_MARKETPLACE = 'Marketplace';
    private static final String INCORRECT_DATA_RETURNED = 'Incorrect Subcription Returned';
    private static final String ACTIVATED_CONTRACT_STATUS = 'Activated';
    private static final String STOREFRONT_TYPE = 'Storefront';

    /**
     * @description To test if subscription records are returned with associated
     * Accounts,Contacts and Opportunites when subscription Ids are passed.
     */
    @isTest
    private static void testWhenSubscriptionIdsArePassedThenReturnSubscriptions() {
        Id subscriptionId = fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType);
        Account mockAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            Creation_Source__c = SSMO_CREATION_SOURCE,
            Order_Protocol__c = POS_ORDER_PROTOCOL,
            Segment__c = SMB_SEGMENT_TYPE
        );
        SBQQ__Quote__c mockQuote = new SBQQ__Quote__c(
            Id = fflib_IDGenerator.generate(SBQQ__Quote__c.SobjectType),
            Unique_Identifier__c = '123455677'
        );
        Contract mockContract = new Contract(
            Id = fflib_IDGenerator.generate(Contract.SobjectType),
            AccountId = mockAccount.Id,
            Status = ACTIVATED_CONTRACT_STATUS,
            SBQQ__Quote__c = mockQuote.Id
        );
        Product2 mockProduct = new Product2(
            Id = fflib_IDGenerator.generate(Product2.SobjectType),
            Name = STOREFRONT_TYPE,
            Platform__c = STOREFRONT_TYPE
        );
        List<SBQQ__Subscription__c> mockSubscription = new List<SBQQ__Subscription__c>{
            new SBQQ__Subscription__c(
                Id = subscriptionId,
                SBQQ__Account__c = mockAccount.Id,
                SBQQ__Contract__c = mockContract.Id,
                SBQQ__Product__c = mockProduct.Id
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        ISubscriptionSelector subscriptionSelectorMock = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );
        mocks.startStubbing();
        mocks.when(subscriptionSelectorMock.SObjectType())
            .thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(
                subscriptionSelectorMock.getSubscriptionsForWorkOrderCreation(
                    new Set<Id>{ subscriptionId }
                )
            )
            .thenReturn(mockSubscription);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(subscriptionSelectorMock);
        List<SBQQ__Subscription__c> subcriptionsReturned = new SubscriptionsServiceImpl()
            .getSubscriptionsAndRelatedInformation(new Set<Id>{ subscriptionId });
        System.assertEquals(subcriptionsReturned, mockSubscription, INCORRECT_DATA_RETURNED);
    }

    /**
     * @description To test when contractIds are passed then return the related Subscriptions.
     */
    @isTest
    private static void testWhenContractIdsPassedThenReturnRelatedSubscriptions() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Fake fakeProductInstance1 = new Fake(Product2.class)
            .setFakeId()
            .setField(Product2.Name, PRODUCT_FAMILY_MARKETPLACE)
            .setField(Product2.Family, PRODUCT_FAMILY_MARKETPLACE)
            .setField(Product2.Work_Order_Type__c, PRODUCT_FAMILY_MARKETPLACE);
        Fake fakeProductInstance2 = new Fake(Product2.class)
            .setFakeId()
            .setField(Product2.Name, STOREFRONT_TYPE)
            .setField(Product2.Family, PRODUCT_FAMILY_MARKETPLACE)
            .setField(Product2.Work_Order_Type__c, STOREFRONT_TYPE);
        List<SBQQ__Subscription__c> fakeSubscriptions = new List<SBQQ__Subscription__c>{
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.SBQQ__Account__c, accountId)
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
                .setParent('SBQQ__Product__r', fakeProductInstance1)
                .setFakeId()
                .toSobject(),
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.SBQQ__Account__c, accountId)
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
                .setParent('SBQQ__Product__r', fakeProductInstance2)
                .setFakeId()
                .toSobject()
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ISubscriptionSelector subscriptionSelectorMock = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );
        mocks.startStubbing();
        mocks.when(subscriptionSelectorMock.SObjectType())
            .thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(
                subscriptionSelectorMock.selectActiveSubscriptionsList(
                    new Set<Id>{ contractId },
                    false
                )
            )
            .thenReturn(fakeSubscriptions);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(subscriptionSelectorMock);
        Test.startTest();
        Map<Id, Set<String>> contractIdToSubscriptionsReturned = SubscriptionsService.getExistingSubscriptionsForContracts(
            new Set<Id>{ contractId }
        );
        System.assertEquals(
            contractIdToSubscriptionsReturned.get(contractId).size(),
            2,
            INCORRECT_DATA_RETURNED
        );
        Test.stopTest();
    }
}