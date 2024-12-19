/**
 * @description This is the test class for SubscriptionRateChangeServiceImpl
 * @author Deloitte
 * @date 15/09/2023
 */
@isTest
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
public class SubscriptionRateChangeServiceImplTest {
    @isTest
    private static void testWhenPrimaryOrdersAreUpdatedThenSubscriptionRateChangesAreUpdated() {
        String primaryOrderRecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName()
            .get('Primary_Order')
            .getRecordTypeId();

        Id accountId = Fake.generateId(Account.class);
        Id contractId = Fake.generateId(Contract.class);
        Id subscriptionId1 = fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType);
        Id rateChangeReqId = Fake.generateId(Rate_Change_Request__c.class);
        Id subRateChangeReqId = Fake.generateId(Subscription_Rate_Change__c.class);
        Id orderId1 = Fake.generateId(Order.class);
        Id orderItemId1 = Fake.generateId(OrderItem.class);
        Id productId1 = Fake.generateId(Product2.class);

        OrderItem orderItem1 = (OrderItem) new Fake(OrderItem.class)
            .setField(OrderItem.Id, orderItemId1)
            .setField(OrderItem.Active_fee__c, '15')
            .setField(OrderItem.Active_Commission__c, '64')
            .setField(OrderItem.OrderId, orderId1)
            .setField(OrderItem.Product2Id, productId1)
            .setParent(
                'Order',
                new Fake(Order.class)
                    .setField(Order.Id, orderId1)
                    .setField(Order.RecordTypeId, primaryOrderRecordTypeId)
            )
            .toSObject();

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
            .setField(SBQQ__Subscription__c.Active_fee__c, '15')
            .setField(SBQQ__Subscription__c.Active_Commission__c, '64')
            .setField(SBQQ__Subscription__c.Subscription_Rate_Change__c, subRateChangeReqId)
            .setParent(
                'SBQQ__OrderProduct__r',
                new Fake(Order.class)
                    .setField(OrderItem.Id, orderItemId1)
                    .setField(OrderItem.Active_fee__c, '15')
                    .setField(OrderItem.Active_Commission__c, '64')
            )
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

        List<OrderItem> orderItems = new List<OrderItem>();
        orderItems.add(orderItem1);

        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();
        subscriptions.add(subscription);

        List<Subscription_Rate_Change__c> subscriptionRateChangeRequests = new List<Subscription_Rate_Change__c>();
        subscriptionRateChangeRequests.add(subscriptionRateChangeRequest);

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        ISubscriptionSelector subscriptionSelectorMock = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );

        ISubscriptionRateChangeSelector rateChangeSelectorMock = (ISubscriptionRateChangeSelector) mocks.mock(
            ISubscriptionRateChangeSelector.class
        );

        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        mocks.startStubbing();
        mocks.when(subscriptionSelectorMock.sObjectType())
            .thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(
                subscriptionSelectorMock.selectSubscriptionRecordsByPrimaryOrderProduct(
                    new Set<Id>{ orderItemId1 }
                )
            )
            .thenReturn(subscriptions);
        mocks.when(rateChangeSelectorMock.sObjectType())
            .thenReturn(Subscription_Rate_Change__c.SObjectType);
        mocks.when(rateChangeSelectorMock.selectById(new Set<Id>{ subRateChangeReqId }))
            .thenReturn(subscriptionRateChangeRequests);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(subscriptionSelectorMock);
        Application.SELECTOR.setMock(rateChangeSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);

        Test.startTest();
        SubscriptionRateChangeService.setSubscriptionRateChangeComplete(orderItems);
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Subscription_Rate_Change__c.Id => subRateChangeReqId,
                            Subscription_Rate_Change__c.Update_Complete__c => true
                        }
                    }
                )
            );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }
}