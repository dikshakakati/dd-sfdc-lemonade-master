/**
 * @author deloitte
 * @date 13-Feb-2024
 * @description Test class for the BulkCorporateOnboardingEntitlementCtrl class.
 **/
@isTest
public class BulkCorporateOnboardingEntitlmntCtrTest {
    private static final String REQUEST_STAGE_PAYMENT_ACCOUNT = 'Payment Account';
    private static final String REQUEST_STATUS_IN_PROGRESS = 'In Progress';
    private static final String REQUEST_STAGE_FINAL_ERROR_CHECK = 'Final Error Check';
    private static final String REQUEST_STAGE_DECISION_MAKER = 'Decision Maker';

    @isTest
    private static void testWhenContractIsPassedThenReturnExistingSubscriptions() {
        Id flowRequestId = Fake.generateId(Process_Flow_Request__c.class);
        Id contractId = Fake.generateId(Contract.class);
        Id accountId1 = Fake.generateId(Account.class);

        List<BulkCorporateOnboardingWrappers.StoreInfo> stores = new List<BulkCorporateOnboardingWrappers.StoreInfo>{
            new BulkCorporateOnboardingWrappers.StoreInfo(accountId1, null, null)
        };


        Process_Flow_Request__c flowRequest = new Process_Flow_Request__c(
            Id = flowRequestId,
            Serialized_Object_Data__c = BulkCorporateOnboardingRequestService.packStoreInfos(stores)
        );

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
            .setParent('Quote_Line_Group__r', fakegroup1)
            .setParent('SBQQ__Contract__r', fakeContractInstance)
            .setParent(
                'SBQQ__Product__r',
                new Fake(Product2.class)
                    .setField(Product2.Id, prod1)
                    .setField(Product2.Name, 'Marketplace')
                    .setField(Product2.Package_Eligible_For_Entitlement__c, true)
                    .setField(Product2.Family, 'Marketplace')
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
                    .setField(Product2.Family, 'Marketplace')
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
            .setParent('Quote_Line_Group__r', fakegroup1)
            .setParent('SBQQ__Contract__r', fakeContractInstance)
            .setParent(
                'SBQQ__Product__r',
                new Fake(Product2.class)
                    .setField(Product2.Id, prod3)
                    .setField(Product2.Name, 'Storefront')
                    .setField(Product2.Package_Eligible_For_Entitlement__c, true)
                    .setField(Product2.Family, 'Storefront')
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
            .setParent('Quote_Line_Group__r', fakegroup1)
            .setParent('SBQQ__Contract__r', fakeContractInstance)
            .setParent(
                'SBQQ__Product__r',
                new Fake(Product2.class)
                    .setField(Product2.Id, prod4)
                    .setField(Product2.Name, 'Dashpass')
                    .setField(Product2.Package_Eligible_For_Entitlement__c, false)
                    .setField(Product2.Family, 'Marketplace')
            )
            .toSObject();
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>{
            subscription1,
            subscription2,
            subscription3,
            subscription4
        };
        List<ManageEntitlementsSelectionWrapper> manageEntitlementSelectionWrapperList = new List<ManageEntitlementsSelectionWrapper>();
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        ISubscriptionSelector subscriptionSelectorMock = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );
        IProcessFlowRequestsSelector pfrSelectorMock = (IProcessFlowRequestsSelector) mocks.mock(
            IProcessFlowRequestsSelector.class
        );
        mocks.startStubbing();
        mocks.when(subscriptionSelectorMock.sObjectType())
            .thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(subscriptionSelectorMock.selectSubscriptionRecordsByGroup(groupList))
            .thenReturn(subList);
        mocks.when(subscriptionSelectorMock.selectQuoteLineGroupOnSubscription(contractId))
            .thenReturn(groupId1);
        mocks.when(pfrSelectorMock.sObjectType()).thenReturn(Process_Flow_Request__c.SObjectType);
        mocks.when(pfrSelectorMock.selectById(new Set<Id>{ flowRequestId }))
            .thenReturn(new List<Process_Flow_Request__c>{ flowRequest });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(subscriptionSelectorMock);
        Application.SELECTOR.setMock(pfrSelectorMock);
        manageEntitlementSelectionWrapperList = BulkCorporateOnboardingEntitlementCtrl.selectExistingSubscriptionsWithGroup(
            contractId,
            flowRequestId
        );
        System.assertEquals(
            manageEntitlementSelectionWrapperList.size(),
            1,
            'WrapperList is not equal'
        );
    }

    /**
     * @description This method is used to test process Next CCP button
     */
    @isTest
    private static void testWhenSubmitThenProcessRecords() {
        Id flowRequestId = Fake.generateId(Process_Flow_Request__c.class);
        Id contractId = Fake.generateId(Contract.class);
        Id accountId1 = Fake.generateId(Account.class);

        List<BulkCorporateOnboardingWrappers.StoreInfo> stores = new List<BulkCorporateOnboardingWrappers.StoreInfo>{
            new BulkCorporateOnboardingWrappers.StoreInfo(accountId1, null, null)
        };

        List<Account> storeAccounts = new List<Account>{
            new Account(Id = accountId1, Bulk_Corporate_Onboarding_Request__c = flowRequestId)
        };

        Process_Flow_Request__c flowRequest = new Process_Flow_Request__c(
            Id = flowRequestId,
            Serialized_Object_Data__c = BulkCorporateOnboardingRequestService.packStoreInfos(stores)
        );

        Id groupId1 = Fake.generateId(SBQQ__QuoteLineGroup__c.class);

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IProcessFlowRequestsSelector pfrSelectorMock = (IProcessFlowRequestsSelector) mocks.mock(
            IProcessFlowRequestsSelector.class
        );
        ISubscriptionSelector subscriptionSelectorMock = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );

        mocks.startStubbing();
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.getStoresByBulkOnboardingRequestId(flowRequestId))
            .thenReturn(storeAccounts);
        mocks.when(subscriptionSelectorMock.sObjectType())
            .thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(pfrSelectorMock.sObjectType()).thenReturn(Process_Flow_Request__c.SObjectType);
        mocks.when(pfrSelectorMock.selectById(new Set<Id>{ flowRequestId }))
            .thenReturn(new List<Process_Flow_Request__c>{ flowRequest });
        mocks.when(subscriptionSelectorMock.selectQuoteLineGroupOnSubscription(contractId))
            .thenReturn(groupId1);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(pfrSelectorMock);
        Application.SELECTOR.setMock(subscriptionSelectorMock);

        String jsonStr = JSON.serialize(
            '{"selected":[{"packageId":"a21O20000004LXJIA2","packageName":"Marketplace","productSubId":[{"productId":"a21O20000006sLtIAI","productName":"Pickup"},{"productId":"a21O20000006sP7IAI","productName":"Dashpass"},{"productId":"a21O20000006tRdIAI","productName":"Delivery"},{"productId":"a21O20000006tTFIAY","productName":"Cx Delivery Fee"}]},{"packageId":"a21O20000004LXNIA2","packageName":"Drive","productSubId":[]},{"packageId":"a21O20000004LXMIA2","packageName":"Caviar","productSubId":[{"productId":"a21O20000006vJlIAI","productName":"Regulatory Fee"},{"productId":"a21O20000006vEvIAI","productName":"Caviar Weblinks"}]}],"deselected":[{"selectedPackageId":"a21O20000004LXJIA2","productDeselected":[]},{"selectedPackageId":"a21O20000004LXNIA2","productDeselected":[]},{"selectedPackageId":"a21O20000004LXMIA2","productDeselected":[]}]}'
        );
        Test.startTest();
        Process_Flow_Request__c updatedFlowRequest = BulkCorporateOnboardingEntitlementCtrl.saveEntitlementsSelectionDeselection(
            jsonStr,
            flowRequestId,
            contractId,
            false,
            true
        );
        Test.stopTest();

        System.assertEquals(
            REQUEST_STAGE_PAYMENT_ACCOUNT,
            updatedFlowRequest.Stage__c,
            'Stage not Updated'
        );
    }

    @isTest
    private static void testWhenContractIsPassedThenReturnAllSubscriptions() {
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
            .setParent('Quote_Line_Group__r', fakegroup1)
            .setParent('SBQQ__Contract__r', fakeContractInstance)
            .setParent(
                'SBQQ__Product__r',
                new Fake(Product2.class)
                    .setField(Product2.Id, prod1)
                    .setField(Product2.Name, 'Marketplace')
                    .setField(Product2.Package_Eligible_For_Entitlement__c, true)
                    .setField(Product2.Family, 'Marketplace')
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
                    .setField(Product2.Family, 'Marketplace')
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
            .setParent('Quote_Line_Group__r', fakegroup1)
            .setParent('SBQQ__Contract__r', fakeContractInstance)
            .setParent(
                'SBQQ__Product__r',
                new Fake(Product2.class)
                    .setField(Product2.Id, prod3)
                    .setField(Product2.Name, 'Storefront')
                    .setField(Product2.Package_Eligible_For_Entitlement__c, true)
                    .setField(Product2.Family, 'Storefront')
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
            .setParent('Quote_Line_Group__r', fakegroup1)
            .setParent('SBQQ__Contract__r', fakeContractInstance)
            .setParent(
                'SBQQ__Product__r',
                new Fake(Product2.class)
                    .setField(Product2.Id, prod4)
                    .setField(Product2.Name, 'Dashpass')
                    .setField(Product2.Package_Eligible_For_Entitlement__c, false)
                    .setField(Product2.Family, 'Marketplace')
            )
            .toSObject();
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>{
            subscription1,
            subscription2,
            subscription3,
            subscription4
        };
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
        List<SBQQ__Subscription__c> allSubsList = BulkCorporateOnboardingEntitlementCtrl.getAllSubscriptionFromContract(
            contractId
        );
        System.assertEquals(
            allSubsList.size(),
            subList.size(),
            'Subscription records are not equal'
        );
    }

    @isTest
    static void testWhenCsvIsProcessedDecisionMakerAndPaymentAccountisPopulatedlThenUpdatetheStageToFinalErrorCheck() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        Id flowRequestId = Fake.generateId(Process_Flow_Request__c.class);
        Id decisionMakerId = Fake.generateId(Contact.class);
        Id paymentAccountId = Fake.generateId(Payment_Account__c.class);
        List<Account> stores = new List<Account>{
            new Account(
                Id = Fake.generateId(Account.class),
                Bulk_Corporate_Onboarding_Request__c = flowRequestId
            ),
            new Account(
                Id = Fake.generateId(Account.class),
                Bulk_Corporate_Onboarding_Request__c = flowRequestId
            ),
            new Account(
                Id = Fake.generateId(Account.class),
                Bulk_Corporate_Onboarding_Request__c = flowRequestId
            )
        };
        Id groupId1 = Fake.generateId(SBQQ__QuoteLineGroup__c.class);
        Id contractId = Fake.generateId(Contract.class);

        List<BulkCorporateOnboardingWrappers.StoreInfo> storeInfos = new List<BulkCorporateOnboardingWrappers.StoreInfo>{
            new BulkCorporateOnboardingWrappers.StoreInfo(
                stores[0].Id,
                paymentAccountId,
                decisionMakerId
            ),
            new BulkCorporateOnboardingWrappers.StoreInfo(
                stores[1].Id,
                paymentAccountId,
                decisionMakerId
            ),
            new BulkCorporateOnboardingWrappers.StoreInfo(
                stores[2].Id,
                paymentAccountId,
                decisionMakerId
            )
        };

        Process_Flow_Request__c flowRequest = new Process_Flow_Request__c(
            Id = flowRequestId,
            Status__c = REQUEST_STATUS_IN_PROGRESS,
            Serialized_Object_Data__c = BulkCorporateOnboardingRequestService.packStoreInfos(
                storeInfos
            )
        );

        // Mock the selector and register it
        IProcessFlowRequestsSelector pfrSelectorMock = (IProcessFlowRequestsSelector) mocks.mock(
            IProcessFlowRequestsSelector.class
        );
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        ISubscriptionSelector subscriptionSelectorMock = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );

        mocks.startStubbing();
        mocks.when(subscriptionSelectorMock.sObjectType()).thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(subscriptionSelectorMock.selectQuoteLineGroupOnSubscription(contractId)).thenReturn(groupId1);
        mocks.when(pfrSelectorMock.sObjectType()).thenReturn(Process_Flow_Request__c.SObjectType);
        mocks.when(pfrSelectorMock.selectById(new Set<Id>{ flowRequestId }))
            .thenReturn(new List<Process_Flow_Request__c>{ flowRequest });
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.getStoresByBulkOnboardingRequestId(flowRequestId))
            .thenReturn(stores);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(pfrSelectorMock);
        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(subscriptionSelectorMock);
        String jsonStr = JSON.serialize(
            '{"selected":[{"packageId":"a21O20000004LXJIA2","packageName":"Marketplace","productSubId":[{"productId":"a21O20000006sLtIAI","productName":"Pickup"},{"productId":"a21O20000006sP7IAI","productName":"Dashpass"},{"productId":"a21O20000006tRdIAI","productName":"Delivery"},{"productId":"a21O20000006tTFIAY","productName":"Cx Delivery Fee"}]},{"packageId":"a21O20000004LXNIA2","packageName":"Drive","productSubId":[]},{"packageId":"a21O20000004LXMIA2","packageName":"Caviar","productSubId":[{"productId":"a21O20000006vJlIAI","productName":"Regulatory Fee"},{"productId":"a21O20000006vEvIAI","productName":"Caviar Weblinks"}]}],"deselected":[{"selectedPackageId":"a21O20000004LXJIA2","productDeselected":[]},{"selectedPackageId":"a21O20000004LXNIA2","productDeselected":[]},{"selectedPackageId":"a21O20000004LXMIA2","productDeselected":[]}]}'
        );

        Test.startTest();
        flowRequest = BulkCorporateOnboardingEntitlementCtrl.saveEntitlementsSelectionDeselection(
            jsonStr,
            flowRequestId,
            contractId,
            false,
            true
        );
        Test.stopTest();

        System.assertEquals(
            REQUEST_STAGE_FINAL_ERROR_CHECK,
            flowRequest.Stage__c,
            'The Stage should be set to ' + REQUEST_STAGE_FINAL_ERROR_CHECK
        );
    }

    @isTest
    static void testWhenCsvIsProcessedPaymentAccountNotNullDecisionMakerNullThenUpdateTheStageToDecisionMaker() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        Id flowRequestId = Fake.generateId(Process_Flow_Request__c.class);
        Id paymentAccountId = Fake.generateId(Payment_Account__c.class);
        List<Account> stores = new List<Account>{
            new Account(
                Id = Fake.generateId(Account.class),
                Bulk_Corporate_Onboarding_Request__c = flowRequestId
            ),
            new Account(
                Id = Fake.generateId(Account.class),
                Bulk_Corporate_Onboarding_Request__c = flowRequestId
            ),
            new Account(
                Id = Fake.generateId(Account.class),
                Bulk_Corporate_Onboarding_Request__c = flowRequestId
            )
        };
        Id groupId1 = Fake.generateId(SBQQ__QuoteLineGroup__c.class);
        Id contractId = Fake.generateId(Contract.class);

        List<BulkCorporateOnboardingWrappers.StoreInfo> storeInfos = new List<BulkCorporateOnboardingWrappers.StoreInfo>{
            new BulkCorporateOnboardingWrappers.StoreInfo(stores[0].Id, paymentAccountId, null),
            new BulkCorporateOnboardingWrappers.StoreInfo(stores[1].Id, paymentAccountId, null),
            new BulkCorporateOnboardingWrappers.StoreInfo(stores[2].Id, paymentAccountId, null)
        };

        Process_Flow_Request__c flowRequest = new Process_Flow_Request__c(
            Id = flowRequestId,
            Status__c = REQUEST_STATUS_IN_PROGRESS,
            Serialized_Object_Data__c = BulkCorporateOnboardingRequestService.packStoreInfos(
                storeInfos
            )
        );

        // Mock the selector and register it
        IProcessFlowRequestsSelector pfrSelectorMock = (IProcessFlowRequestsSelector) mocks.mock(
            IProcessFlowRequestsSelector.class
        );
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        ISubscriptionSelector subscriptionSelectorMock = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );

        mocks.startStubbing();
        mocks.when(subscriptionSelectorMock.sObjectType())
            .thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(subscriptionSelectorMock.selectQuoteLineGroupOnSubscription(contractId))
            .thenReturn(groupId1);
        mocks.when(pfrSelectorMock.sObjectType()).thenReturn(Process_Flow_Request__c.SObjectType);
        mocks.when(pfrSelectorMock.selectById(new Set<Id>{ flowRequestId }))
            .thenReturn(new List<Process_Flow_Request__c>{ flowRequest });
        mocks.when(accountsSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.getStoresByBulkOnboardingRequestId(flowRequestId))
            .thenReturn(stores);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(pfrSelectorMock);
        Application.SELECTOR.setMock(accountsSelectorMock);
        Application.SELECTOR.setMock(subscriptionSelectorMock);
        String jsonStr = JSON.serialize(
            '{"selected":[{"packageId":"a21O20000004LXJIA2","packageName":"Marketplace","productSubId":[{"productId":"a21O20000006sLtIAI","productName":"Pickup"},{"productId":"a21O20000006sP7IAI","productName":"Dashpass"},{"productId":"a21O20000006tRdIAI","productName":"Delivery"},{"productId":"a21O20000006tTFIAY","productName":"Cx Delivery Fee"}]},{"packageId":"a21O20000004LXNIA2","packageName":"Drive","productSubId":[]},{"packageId":"a21O20000004LXMIA2","packageName":"Caviar","productSubId":[{"productId":"a21O20000006vJlIAI","productName":"Regulatory Fee"},{"productId":"a21O20000006vEvIAI","productName":"Caviar Weblinks"}]}],"deselected":[{"selectedPackageId":"a21O20000004LXJIA2","productDeselected":[]},{"selectedPackageId":"a21O20000004LXNIA2","productDeselected":[]},{"selectedPackageId":"a21O20000004LXMIA2","productDeselected":[]}]}'
        );

        Test.startTest();
        flowRequest = BulkCorporateOnboardingEntitlementCtrl.saveEntitlementsSelectionDeselection(
            jsonStr,
            flowRequestId,
            contractId,
            false,
            true
        );
        Test.stopTest();

        System.assertEquals(
            REQUEST_STAGE_DECISION_MAKER,
            flowRequest.Stage__c,
            'The Stage should be set to ' + REQUEST_STAGE_DECISION_MAKER
        );
    }
}