/**
 * @description This is test class for Subscription Rate Change Trigger handler class
 * @author Deloitte
 * @date 13-09-2023
 */
@isTest(seeAllData=false)
public class SubscriptionRateChangesHandlerTest {
    private static final String APPROVED = 'Approved';
    private static final String NEW_RATE_CHANGE = 'New';
    private static final Date TODAY_DATE = System.today();

    /**
     * @description This method is used to test Subscription Rate Change TriggerHandler
     */
    @isTest
    private static void testWhenClassInstantiatesThenCheck() {
        List<Subscription_Rate_Change__c> subscriptionChangeRequestList = new List<Subscription_Rate_Change__c>();
        SubscriptionRateChangesHandler subscriptionRateChangeHandlerObject = new SubscriptionRateChangesHandler(
            subscriptionChangeRequestList
        );
        SubscriptionRateChangesHandler.Constructor objConstructor = new SubscriptionRateChangesHandler.Constructor();
        objConstructor.construct(subscriptionChangeRequestList);
        System.assertNotEquals(
            subscriptionRateChangeHandlerObject,
            objConstructor.construct(subscriptionChangeRequestList),
            'Unexpected result: both constructs are similar.'
        );
    }

    /**
     * @description To test method call on Subscription Rate Change insert
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenInsertSubscriptionRateChangeThenCallUpdateSubscriptionActiveRatesFromSRC() {
        //ARRANGE
        Id subscriptionId1 = fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType);
        Id rateChangeReqId = Fake.generateId(Rate_Change_Request__c.class);
        Id subRateChangeReqId = Fake.generateId(Subscription_Rate_Change__c.class);
        Id contractId = Fake.generateId(Contract.class);
        Id caseId = Fake.generateId(Case.class);

        Subscription_Rate_Change__c subscriptionRateChangeRequest = (Subscription_Rate_Change__c) new Fake(
                Subscription_Rate_Change__c.class
            )
            .setField(Subscription_Rate_Change__c.Id, subRateChangeReqId)
            .setField(Subscription_Rate_Change__c.Rate_Change_Request__c, rateChangeReqId)
            .setField(Subscription_Rate_Change__c.Updated_Active_Fee__c, '53')
            .setField(Subscription_Rate_Change__c.Updated_Active_Commission__c, '43')
            .setField(Subscription_Rate_Change__c.Subscription__c, subscriptionId1)
            .setField(Subscription_Rate_Change__c.Update_complete__c, false)
            .setParent(
                'Rate_Change_Request__r',
                new Fake(Rate_Change_Request__c.class)
                    .setField(Rate_Change_Request__c.Id, rateChangeReqId)
                    .setField(Rate_Change_Request__c.Contract__c, contractId)
                    .setField(Rate_Change_Request__c.Effective_Date__c, TODAY_DATE)
                    .setField(Rate_Change_Request__c.S_O_Support_Request_Link__c, caseId)
                    .setField(Rate_Change_Request__c.Activation_Status__c, NEW_RATE_CHANGE)
                    .setField(Rate_Change_Request__c.Status__c, APPROVED)
            )
            .toSObject();

        List<Subscription_Rate_Change__c> subscriptionRateChangeRequests = new List<Subscription_Rate_Change__c>();
        subscriptionRateChangeRequests.add(subscriptionRateChangeRequest);

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        ISubscriptionRateChangeSelector subscriptionRateChangeSelectorMock = (ISubscriptionRateChangeSelector) mocks.mock(
            ISubscriptionRateChangeSelector.class
        );
        mocks.startStubbing();
        mocks.when(subscriptionRateChangeSelectorMock.sObjectType())
            .thenReturn(Subscription_Rate_Change__c.SObjectType);
        mocks.when(subscriptionRateChangeSelectorMock.selectById(new Set<Id>{ subRateChangeReqId }))
            .thenReturn(subscriptionRateChangeRequests);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(subscriptionRateChangeSelectorMock);

        ISubscriptionService subscriptionMock = (ISubscriptionService) mocks.mock(
            ISubscriptionService.class
        );

        Application.SERVICE.setMock(ISubscriptionService.class, subscriptionMock);

        fflib_SObjectDomain.Test.Database.onInsert(
            new List<Subscription_Rate_Change__c>{ subscriptionRateChangeRequest }
        );
        fflib_SObjectDomain.triggerHandler(SubscriptionRateChangesHandler.class);

        ((ISubscriptionService) mocks.verify(subscriptionMock, 1))
            .updateSubscriptionActiveRatesFromSRC(subscriptionRateChangeRequests);
    }

    /**
     * @description To test method call on Subscription Rate Change update
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenUpdateSubscriptionRateChangeThenCallSetRCRCComplete() {
        //ARRANGE
        Id subscriptionId1 = fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType);
        Id rateChangeReqId = Fake.generateId(Rate_Change_Request__c.class);
        Id subRateChangeReqId = Fake.generateId(Subscription_Rate_Change__c.class);

        Subscription_Rate_Change__c[] oldRateChanges = new List<Subscription_Rate_Change__c>{
            new Subscription_Rate_Change__c(
                Id = subRateChangeReqId,
                Rate_Change_Request__c = rateChangeReqId,
                Update_Complete__c = false,
                Updated_Active_Fee__c = 34,
                Updated_Active_Commission__c = 32,
                Subscription__c = subscriptionId1
            )
        };

        Subscription_Rate_Change__c[] newRateChanges = new List<Subscription_Rate_Change__c>{
            new Subscription_Rate_Change__c(
                Id = subRateChangeReqId,
                Rate_Change_Request__c = rateChangeReqId,
                Update_Complete__c = true,
                Updated_Active_Fee__c = 34,
                Updated_Active_Commission__c = 32,
                Subscription__c = subscriptionId1
            )
        };

        List<Subscription_Rate_Change__c> subscriptionRateChangeRequests = new List<Subscription_Rate_Change__c>();
        subscriptionRateChangeRequests.addAll(newRateChanges);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IRateChangeRequestService rateChangeRequestsMock = (IRateChangeRequestService) mocks.mock(
            IRateChangeRequestService.class
        );

        Application.SERVICE.setMock(IRateChangeRequestService.class, rateChangeRequestsMock);

        fflib_SObjectDomain.Test.Database.onUpdate(
            newRateChanges,
            new Map<Id, SObject>(oldRateChanges)
        );
        fflib_SObjectDomain.triggerHandler(SubscriptionRateChangesHandler.class);

        ((IRateChangeRequestService) mocks.verify(rateChangeRequestsMock, 1))
            .setRateChangeRequestComplete(subscriptionRateChangeRequests);
    }
}