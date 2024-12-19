/**
 * @author Deloitte
 * @date 14/09/2023
 * @description Test class for SubscriptionServiceImpl class.
 */
@isTest(seeAllData=false)
public class SubscriptionServiceImplTest {
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenSubscriptionRateChangesAreInsertedThenSubscriptionsAreUpdated() {
        Id accountId = Fake.generateId(Account.class);
        Id contractId = Fake.generateId(Contract.class);
        Id subscriptionId1 = fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType);
        Id rateChangeReqId = Fake.generateId(Rate_Change_Request__c.class);
        Id subRateChangeReqId = Fake.generateId(Subscription_Rate_Change__c.class);
        Id orderItemId1 = Fake.generateId(OrderItem.class);

        Account accountAssociatedWithSubscription = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Parent 1')
            .setField(Account.Type, 'Corporate')
            .setField(Account.Id, accountId)
            .toSObject();

        SBQQ__Subscription__c subscription = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId1)
            .setField(SBQQ__Subscription__c.SBQQ__ProductName__c, 'Alcohol Delivery')
            .setField(SBQQ__Subscription__c.SBQQ__Account__c, accountAssociatedWithSubscription.Id)
            .setField(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId1)
            .setField(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setField(SBQQ__Subscription__c.Active_fee__c, '25')
            .setField(SBQQ__Subscription__c.Active_Commission__c, '74')
            .toSObject();

        Subscription_Rate_Change__c subscriptionRateChangeRequest = (Subscription_Rate_Change__c) new Fake(
                Subscription_Rate_Change__c.class
            )
            .setField(Subscription_Rate_Change__c.Id, subRateChangeReqId)
            .setField(Subscription_Rate_Change__c.Rate_Change_Request__c, rateChangeReqId)
            .setField(Subscription_Rate_Change__c.Updated_Active_Fee__c, '15')
            .setField(Subscription_Rate_Change__c.Updated_Active_Commission__c, '64')
            .setField(Subscription_Rate_Change__c.Subscription__c, subscriptionId1)
            .setField(Subscription_Rate_Change__c.Update_complete__c, false)
            .toSObject();

        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();
        subscriptions.add(subscription);

        List<Subscription_Rate_Change__c> subscriptionRateChangeRequests = new List<Subscription_Rate_Change__c>();
        subscriptionRateChangeRequests.add(subscriptionRateChangeRequest);

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        ISubscriptionSelector subscriptionSelectorMock = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );

        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        mocks.startStubbing();
        mocks.when(subscriptionSelectorMock.sObjectType())
            .thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(
                subscriptionSelectorMock.querySubscriptionRecords(new Set<Id>{ subscriptionId1 })
            )
            .thenReturn(subscriptions);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(subscriptionSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);

        Test.startTest();
        SubscriptionService.updateSubscriptionActiveRatesFromSRC(subscriptionRateChangeRequests);
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            SBQQ__Subscription__c.Id => subscriptionId1,
                            SBQQ__Subscription__c.Active_fee__c => 15,
                            SBQQ__Subscription__c.Active_Commission__c => 64,
                            SBQQ__Subscription__c.Subscription_Rate_Change__c => subRateChangeReqId
                        }
                    }
                )
            );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenSubscriptionRateChangesAreInsertedThenSubscriptionsAreUpdatedAlongWithPendingSRC() {
        Id accountId = Fake.generateId(Account.class);
        Id contractId = Fake.generateId(Contract.class);
        Id subscriptionId1 = fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType);
        Id rateChangeReqId = Fake.generateId(Rate_Change_Request__c.class);
        Id subRateChangeReqId = Fake.generateId(Subscription_Rate_Change__c.class);
        Id orderItemId1 = Fake.generateId(OrderItem.class);

        Account accountAssociatedWithSubscription = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Parent 1')
            .setField(Account.Type, 'Corporate')
            .setField(Account.Id, accountId)
            .toSObject();

        SBQQ__Subscription__c subscription = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId1)
            .setField(SBQQ__Subscription__c.SBQQ__ProductName__c, 'Alcohol Delivery')
            .setField(SBQQ__Subscription__c.SBQQ__Account__c, accountAssociatedWithSubscription.Id)
            .setField(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId1)
            .setField(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setField(SBQQ__Subscription__c.Active_fee__c, '25')
            .setField(SBQQ__Subscription__c.Active_Commission__c, '74')
            .toSObject();

        Subscription_Rate_Change__c subscriptionRateChangeRequest = (Subscription_Rate_Change__c) new Fake(
                Subscription_Rate_Change__c.class
            )
            .setField(Subscription_Rate_Change__c.Id, subRateChangeReqId)
            .setField(Subscription_Rate_Change__c.Rate_Change_Request__c, rateChangeReqId)
            .setField(Subscription_Rate_Change__c.Updated_Active_Fee__c, '15')
            .setField(Subscription_Rate_Change__c.Updated_Active_Commission__c, '64')
            .setField(Subscription_Rate_Change__c.Subscription__c, subscriptionId1)
            .setField(Subscription_Rate_Change__c.Update_complete__c, false)
            .toSObject();

        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();
        subscriptions.add(subscription);

        List<Subscription_Rate_Change__c> subscriptionRateChangeRequests = new List<Subscription_Rate_Change__c>();
        subscriptionRateChangeRequests.add(subscriptionRateChangeRequest);

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        ISubscriptionSelector subscriptionSelectorMock = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );

        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        mocks.startStubbing();
        mocks.when(subscriptionSelectorMock.sObjectType())
            .thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(
                subscriptionSelectorMock.querySubscriptionRecords(new Set<Id>{ subscriptionId1 })
            )
            .thenReturn(subscriptions);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(subscriptionSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);

        Test.startTest();
        SubscriptionService.updateSubscriptionActiveRatesFromSRC(subscriptionRateChangeRequests);
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            SBQQ__Subscription__c.Id => subscriptionId1,
                            SBQQ__Subscription__c.Active_fee__c => 15,
                            SBQQ__Subscription__c.Active_Commission__c => 64,
                            SBQQ__Subscription__c.Subscription_Rate_Change__c => subRateChangeReqId
                        }
                    }
                )
            );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }
}