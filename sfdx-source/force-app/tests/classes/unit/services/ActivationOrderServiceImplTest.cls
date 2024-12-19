/**
 * @description This is the test class for ActivationOrderServiceImpl.
 * @author atg
 * @date 05/27/2022
 */
@isTest
public with sharing class ActivationOrderServiceImplTest {
    private static final String ORDERITEM_BUNDLEROOT_PRODUCTCODE_MARKETPLACEDELIVERY = '10017';
    private static final String ORDERITEM_PRODUCTCODE_MARKETPLACEDELIVERY =
        ORDERITEM_BUNDLEROOT_PRODUCTCODE_MARKETPLACEDELIVERY + '-10033';

    public static final String ACTIVE = 'Active';
    public static final String STATUS_DRAFT = 'Draft';
    public static final String CONTRACTING_METHOD = 'By Subscription End Date';
    public static final String ACTIVATION_ORDER_TYPE = 'Activation_Order';
    public static final Schema.Fieldset ORDER_ITEM_FIELD_SET = SObjectType.OrderItem.FieldSets.Activation_Order_Item_List;
    public static final String MX_AGREED_YES = 'Yes';
    public static final String MX_AGREED_NO = 'No';
    public static final String MARKETPLACE = 'Marketplace';
    public static final String ACTIVATED = 'Activated';
    private static final String XREF_EXTERNAL_SOURCE_DRIVE = 'DriveDb';
    private static final String XREF_EXTERNAL_SOURCE_MARKETPLACE = 'MDS';
    private static final String INTEGRATION_STATUS_SUCCESS = 'Success';
    private static final String LAST_COMPLETED_STEP_CONFIGURATION = 'Business Configuration Created';

    /**
     * @description Tests when Parent is updated it reflects in Account record
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenActivateOrdersThenAgreementUpdated() {
        Id agreement1Id = Fake.generateId(Agreement__c.class);
        Id agreement2Id = Fake.generateId(Agreement__c.class);
        Id agreement3Id = Fake.generateId(Agreement__c.class);
        Id agreement4Id = Fake.generateId(Agreement__c.class);
        Id quoteLineGroupId = Fake.generateId(SBQQ__QuoteLineGroup__c.class);
        //agreement5 and agreement6 will be added with no Id, to simulate insert Context.

        Id accountId = Fake.generateId(Account.class);
        Id contractId = Fake.generateId(Contract.class);
        Id packageId1 = Fake.generateId(SBQQ__Subscription__c.class);
        Id productId1 = Fake.generateId(SBQQ__Subscription__c.class);
        Id productId2 = Fake.generateId(SBQQ__Subscription__c.class);
        String jsonStr =
            '{"selected":[{"productSubId":[{"productName":"DoubleDash","productId":"' +
            productId1 +
            '"},{"productName":"Alcohol Delivery","productId":"' +
            productId2 +
            '"}],"packageName":"Marketplace","packageId":"' +
            packageId1 +
            '"}],"deselected":[{"selectedPackageId":"' +
            packageId1 +
            '","productDeselected":[]}]}';

        Fake opportunityRecordFake = new Fake(Opportunity.class)
            .setField(Opportunity.Name, 'Test opportunity 1')
            .setField(Opportunity.LastModifiedDate, Date.today() - 120)
            .setField(Opportunity.AccountId, accountId)
            .setField(Opportunity.Deselected_Marketplace_Offerings__c, 'Pickup')
            .setField(
                Opportunity.Packages_with_Products__c,
                '{"packageDetails":[{"packageName":"Marketplace","products":"Pickup"},{"packageName":"Storefront","products":""}]}'
            )
            .setFakeId();

        Agreement__c agreement1 = (Agreement__c) new Fake(Agreement__c.class)
            .setField(Agreement__c.Status__c, ACTIVE)
            .setField(Agreement__c.Id, agreement1Id)
            .setField(Agreement__c.Account__c, accountId)
            .setField(Agreement__c.Contract__c, contractId)
            .setField(Agreement__c.Activation_Order_Created__c, false)
            .setField(Agreement__c.Group__c, quoteLineGroupId)
            .setField(Agreement__c.Serialized_Entitlements_Data__c, jsonStr)
            .setParent('Opportunity__r', opportunityRecordFake)
            .toSObject();

        Agreement__c agreement2 = (Agreement__c) new Fake(Agreement__c.class)
            .setField(Agreement__c.Status__c, ACTIVE)
            .setField(Agreement__c.Id, agreement2Id)
            .setField(Agreement__c.Account__c, null)
            .setField(Agreement__c.Contract__c, contractId)
            .setField(Agreement__c.Activation_Order_Created__c, false)
            .setField(Agreement__c.Group__c, quoteLineGroupId)
            .setField(Agreement__c.Serialized_Entitlements_Data__c, jsonStr)
            .setParent('Opportunity__r', opportunityRecordFake)
            .toSObject();
        Agreement__c agreement3 = (Agreement__c) new Fake(Agreement__c.class)
            .setField(Agreement__c.Status__c, ACTIVE)
            .setField(Agreement__c.Id, agreement3Id)
            .setField(Agreement__c.Account__c, accountId)
            .setField(Agreement__c.Contract__c, null)
            .setField(Agreement__c.Activation_Order_Created__c, false)
            .setField(Agreement__c.Group__c, quoteLineGroupId)
            .setField(Agreement__c.Serialized_Entitlements_Data__c, jsonStr)
            .setParent('Opportunity__r', opportunityRecordFake)
            .toSObject();
        Agreement__c agreement4 = (Agreement__c) new Fake(Agreement__c.class)
            .setField(Agreement__c.Status__c, ACTIVE)
            .setField(Agreement__c.Id, agreement4Id)
            .setField(Agreement__c.Account__c, accountId)
            .setField(Agreement__c.Contract__c, contractId)
            .setField(Agreement__c.Activation_Order_Created__c, true)
            .setField(Agreement__c.Group__c, quoteLineGroupId)
            .setField(Agreement__c.Serialized_Entitlements_Data__c, jsonStr)
            .setParent('Opportunity__r', opportunityRecordFake)
            .toSObject();
        Agreement__c agreement5 = (Agreement__c) new Fake(Agreement__c.class)
            .setField(Agreement__c.Status__c, 'Draft')
            .setField(Agreement__c.Id, null)
            .setField(Agreement__c.Account__c, accountId)
            .setField(Agreement__c.Contract__c, contractId)
            .setField(Agreement__c.Activation_Order_Created__c, false)
            .setField(Agreement__c.Group__c, quoteLineGroupId)
            .setField(Agreement__c.Serialized_Entitlements_Data__c, jsonStr)
            .setParent('Opportunity__r', opportunityRecordFake)
            .toSObject();
        Agreement__c agreement6 = (Agreement__c) new Fake(Agreement__c.class)
            .setField(Agreement__c.Status__c, ACTIVE)
            .setField(Agreement__c.Id, null)
            .setField(Agreement__c.Account__c, accountId)
            .setField(Agreement__c.Contract__c, contractId)
            .setField(Agreement__c.Activation_Order_Created__c, false)
            .setField(Agreement__c.Group__c, quoteLineGroupId)
            .setField(Agreement__c.Serialized_Entitlements_Data__c, jsonStr)
            .setParent('Opportunity__r', opportunityRecordFake)
            .toSObject();

        List<Agreement__c> agreementList = new List<Agreement__c>{
            agreement1,
            agreement2,
            agreement3,
            agreement4,
            agreement5,
            agreement6
        };
        Set<Id> processedAgreementIdSet = new Set<Id>{
            agreement1.Id,
            agreement4.Id,
            agreement6.Id
        };
        List<Agreement__c> processedAgreementList = new List<Agreement__c>{
            agreement1,
            agreement4,
            agreement6
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAgreementsSelector selectorMock = (IAgreementsSelector) mocks.mock(
            IAgreementsSelector.class
        );
        IActivationOrderCreationService creationServiceMock = (IActivationOrderCreationService) mocks.mock(
            IActivationOrderCreationService.class
        );
        IAccountsService mockAccountService = (IAccountsService) mocks.mock(IAccountsService.class);

        mocks.startStubbing();
        mocks.when(selectorMock.SObjectType()).thenReturn(Agreement__c.SObjectType);
        mocks.when(selectorMock.selectOpportunityInfoByIds(processedAgreementIdSet))
            .thenReturn(processedAgreementList);
        mocks.when(
                creationServiceMock.createActivationOrdersForAccountContractMap(
                    (Map<String, Id>) fflib_Match.anyObject(),
                    (Map<Id, Id>) fflib_Match.anyObject(),
                    (Map<Id, Map<String, String>>) fflib_Match.anyObject(),
                    (Map<Id, String>) fflib_Match.anyObject(),
                    (Map<Id, Boolean>) fflib_Match.anyObject(),
                    (Map<Id, Map<String, List<String>>>) fflib_Match.anyObject(),
                    (fflib_ISObjectUnitOfWork) fflib_Match.eq(mockUOW)
                )
            )
            .thenReturn(false);
        mocks.stopStubbing();

        Application.SERVICE.setMock(IActivationOrderCreationService.class, creationServiceMock);
        Application.SELECTOR.setMock(selectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IAccountsService.class, mockAccountService);

        ActivationOrdersService.createActivationOrdersAndProducts(agreementList, false);

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        //Make sure the agreement with correct parameters are updated
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Agreement__c.Id => agreement1Id,
                        Agreement__c.Activation_Order_Created__c => true
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Agreement__c.Id => null,
                        Agreement__c.Activation_Order_Created__c => true
                    }
                )
            );
        //Make sure agreements that should not process are not processed
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Agreement__c.Id => agreement2Id,
                        Agreement__c.Activation_Order_Created__c => false
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Agreement__c.Id => agreement3Id,
                        Agreement__c.Activation_Order_Created__c => false
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Agreement__c.Id => agreement4Id,
                        Agreement__c.Activation_Order_Created__c => true
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Agreement__c.Id => null,
                        Agreement__c.Activation_Order_Created__c => false,
                        Agreement__c.Status__c => 'Draft'
                    }
                )
            );
        ((IAccountsService) mocks.verify(mockAccountService, 1))
            .updateFieldsOnAccount(new Set<Id>{ accountId });
    }

    /**
     * @description Tests when Contracts are Amended then Activation Orders, OrderItems, and Merchact Services are created
     * in sub process
     */
    @IsTest
    public static void testWhenContractAmendedCallThenOrdersAndItemsAndServicesCreated() {
        Id agreement1Id = Fake.generateId(Agreement__c.class);

        Id accountId = Fake.generateId(Account.class);
        Id contractId = Fake.generateId(Contract.class);
        Id orderId1 = Fake.generateId(Order.class);
        Id orderItemId1 = Fake.generateId(OrderItem.class);
        Id orderItemId2 = Fake.generateId(OrderItem.class);
        Id orderItemId3 = Fake.generateId(OrderItem.class);
        Id subscriptionId1 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subscriptionId2 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subscriptionId3 = Fake.generateId(SBQQ__Subscription__c.class);
        Id merchantServiceId = Fake.generateId(Merchant_Service__c.class);
        Id productId = Fake.generateId(Product2.class);

        Agreement__c agreement1 = new Agreement__c(
            Id = agreement1Id,
            Status__c = ACTIVE,
            Account__c = accountId,
            Contract__c = contractId,
            Activation_Order_Created__c = false
        );

        //This variable cannot be named contract, because that causes a compiler error on this line:         mocks.when(contractSelectorMock.SObjectType()).thenReturn(Contract.SObjectType);
        Contract contract1 = new Contract(Id = contractId, SBQQ__Order__c = orderId1);

        Order order1 = new Order(Id = orderId1);
        OrderItem orderItem1 = new OrderItem(
            Id = orderItemId1,
            OrderId = orderId1,
            Product2Id = productId
        );
        OrderItem orderItem2 = new OrderItem(
            Id = orderItemId2,
            OrderId = orderId1,
            SBQQ__BundleRoot__c = orderItemId1
        );
        OrderItem orderItem3 = new OrderItem(
            Id = orderItemId3,
            OrderId = orderId1,
            SBQQ__RequiredBy__c = orderItemId1
        );
        List<Order> orderWithOrderItems = (List<Order>) fflib_ApexMocksUtils.makeRelationship(
            List<Order>.class,
            new List<Order>{ order1 },
            OrderItem.OrderId,
            new List<List<OrderItem>>{ new List<OrderItem>{ orderItem1, orderItem2, orderItem3 } }
        );
        system.assertNotEquals(orderWithOrderItems.size(), 0, 'makeRelationship failed');

        List<Agreement__c> agreementList = new List<Agreement__c>{ agreement1 };
        SBQQ__Subscription__c subscription1 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId1)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId1)
            .toSObject();
        SBQQ__Subscription__c subscription2 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId2)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId2)
            .toSObject();
        SBQQ__Subscription__c subscription3 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId3)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId3)
            .toSObject();
        List<SBQQ__Subscription__c> subscriptionList = new List<SBQQ__Subscription__c>{
            subscription1,
            subscription2,
            subscription3
        };

        Merchant_Service__c existingService = new Merchant_Service__c(
            Id = merchantServiceId,
            Account__c = accountId,
            Product__c = productId
        );

        List<OrderItem> orderItemList = new List<OrderItem>{ orderItem1, orderItem2, orderItem3 };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IContractsSelector contractSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        ISubscriptionSelector subscriptionSelectorMock = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );
        IOrderItemsSelector orderItemSelectorMock = (IOrderItemsSelector) mocks.mock(
            IOrderItemsSelector.class
        );
        IMerchantSelector servicesSelectorMock = (IMerchantSelector) mocks.mock(
            IMerchantSelector.class
        );
        IAgreementsSelector agreementsSelectorMock = (IAgreementsSelector) mocks.mock(
            IAgreementsSelector.class
        );
        IActivationOrderCreationService creationServiceMock = (IActivationOrderCreationService) mocks.mock(
            IActivationOrderCreationService.class
        );

        mocks.startStubbing();
        mocks.when(contractSelectorMock.SObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(contractSelectorMock.selectById(new Set<Id>{ contractId }))
            .thenReturn(new List<Contract>{ contract1 });
        mocks.when(subscriptionSelectorMock.SObjectType())
            .thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(
                subscriptionSelectorMock.selectActiveSubscriptionsList(
                    new Set<Id>{ contractId },
                    false
                )
            )
            .thenReturn(subscriptionList);
        mocks.when(orderItemSelectorMock.SObjectType()).thenReturn(OrderItem.SObjectType);
        //Mocks class not working when the parameter is a FieldSet, so we have to match the parameters on any object.
        //mocks.when(orderItemSelectorMock.selectOrderItemFieldSetById((Schema.Fieldset)fieldSet, (Set<Id>)orderItemIdSubscriptionIdMap.keySet())).thenReturn(orderItemList);
        mocks.when(
                orderItemSelectorMock.selectOrderItemFieldSetById(
                    (Schema.Fieldset) fflib_Match.anyObject(),
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(orderItemList);
        mocks.when(servicesSelectorMock.SObjectType()).thenReturn(Merchant_Service__c.SObjectType);
        mocks.when(
                servicesSelectorMock.queryMerchantRecordsWithAccountIds(new Set<Id>{ accountId })
            )
            .thenReturn(new List<Merchant_Service__c>{ existingService });
        mocks.when(agreementsSelectorMock.SObjectType()).thenReturn(Agreement__c.SObjectType);
        mocks.when(
                agreementsSelectorMock.selectActiveAgreementsByContractIds(
                    new Set<Id>{ contractId }
                )
            )
            .thenReturn(agreementList);
        mocks.when(
                creationServiceMock.createActivationOrdersForAccountContractMap(
                    (Map<String, Id>) fflib_Match.anyObject(),
                    (Map<Id, Id>) fflib_Match.anyObject(),
                    (Map<Id, Map<String, String>>) fflib_Match.anyObject(),
                    (Map<Id, String>) fflib_Match.anyObject(),
                    (Map<Id, Boolean>) fflib_Match.anyObject(),
                    (Map<Id, Map<String, List<String>>>) fflib_Match.anyObject(),
                    (fflib_ISObjectUnitOfWork) fflib_Match.eq(mockUOW)
                )
            )
            .thenReturn(false);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(contractSelectorMock);
        Application.SELECTOR.setMock(subscriptionSelectorMock);
        Application.SELECTOR.setMock(orderItemSelectorMock);
        Application.SELECTOR.setMock(servicesSelectorMock);
        Application.SELECTOR.setMock(agreementsSelectorMock);
        Application.SERVICE.setMock(IActivationOrderCreationService.class, creationServiceMock);
        Application.UNITOFWORK.setMock(mockUOW);

        ActivationOrdersService.createActivationOrdersAndProductsOnContractAmendment(
            new Set<Id>{ contractId }
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();

        //This field set should have fields in it, or the copying or OrderItems will be incomplete.
        List<Schema.FieldSetMember> fieldSetMemberList = ORDER_ITEM_FIELD_SET.getFields();
        system.assertNotEquals(
            fieldSetMemberList.size(),
            0,
            'Make sure field set has fields in it.'
        );
    }

    /**
     * @description Tests when IntegratedFranchise then Activation Orders, OrderItems, and Merchact Services are created
     */
    @IsTest
    public static void testWhenIntegratedFranchiseCallThenOrderAndItemsAndServicesCreated() {
        Id accountId = Fake.generateId(Account.class);
        Id opportunityId = Fake.generateId(Opportunity.class);
        Id contractId = Fake.generateId(Contract.class);
        Id orderId1 = Fake.generateId(Order.class);
        Id orderItemId1 = Fake.generateId(OrderItem.class);
        Id orderItemId2 = Fake.generateId(OrderItem.class);
        Id orderItemId3 = Fake.generateId(OrderItem.class);
        Id subscriptionId1 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subscriptionId2 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subscriptionId3 = Fake.generateId(SBQQ__Subscription__c.class);
        Id merchantServiceId = Fake.generateId(Merchant_Service__c.class);
        Id productId = Fake.generateId(Product2.class);

        //This variable cannot be named contract, because that causes a compiler error on this line:         mocks.when(contractSelectorMock.SObjectType()).thenReturn(Contract.SObjectType);
        Contract contract1 = new Contract(Id = contractId, SBQQ__Order__c = orderId1);

        Order order1 = new Order(Id = orderId1);
        OrderItem orderItem1 = new OrderItem(
            Id = orderItemId1,
            OrderId = orderId1,
            Product2Id = productId
        );
        OrderItem orderItem2 = new OrderItem(
            Id = orderItemId2,
            OrderId = orderId1,
            SBQQ__BundleRoot__c = orderItemId1
        );
        OrderItem orderItem3 = new OrderItem(
            Id = orderItemId3,
            OrderId = orderId1,
            SBQQ__RequiredBy__c = orderItemId1
        );
        List<Order> orderWithOrderItems = (List<Order>) fflib_ApexMocksUtils.makeRelationship(
            List<Order>.class,
            new List<Order>{ order1 },
            OrderItem.OrderId,
            new List<List<OrderItem>>{ new List<OrderItem>{ orderItem1, orderItem2, orderItem3 } }
        );
        system.assertNotEquals(orderWithOrderItems.size(), 0, 'makeRelationship failed');

        SBQQ__Subscription__c subscription1 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId1)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId1)
            .toSObject();
        SBQQ__Subscription__c subscription2 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId2)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId2)
            .toSObject();
        SBQQ__Subscription__c subscription3 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId3)
            .setfield(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setfield(SBQQ__Subscription__c.SBQQ__OrderProduct__c, orderItemId3)
            .toSObject();
        List<SBQQ__Subscription__c> subscriptionList = new List<SBQQ__Subscription__c>{
            subscription1,
            subscription2,
            subscription3
        };

        Merchant_Service__c existingService = new Merchant_Service__c(
            Id = merchantServiceId,
            Account__c = accountId,
            Product__c = productId
        );

        List<OrderItem> orderItemList = new List<OrderItem>{ orderItem1, orderItem2, orderItem3 };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IContractsSelector contractSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        ISubscriptionSelector subscriptionSelectorMock = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );
        IOrderItemsSelector orderItemSelectorMock = (IOrderItemsSelector) mocks.mock(
            IOrderItemsSelector.class
        );
        IMerchantSelector servicesSelectorMock = (IMerchantSelector) mocks.mock(
            IMerchantSelector.class
        );
        IActivationOrderCreationService creationServiceMock = (IActivationOrderCreationService) mocks.mock(
            IActivationOrderCreationService.class
        );

        mocks.startStubbing();
        mocks.when(contractSelectorMock.SObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(contractSelectorMock.selectById(new Set<Id>{ contractId }))
            .thenReturn(new List<Contract>{ contract1 });
        mocks.when(subscriptionSelectorMock.SObjectType())
            .thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(
                subscriptionSelectorMock.selectActiveSubscriptionsList(
                    new Set<Id>{ contractId },
                    true
                )
            )
            .thenReturn(subscriptionList);
        mocks.when(orderItemSelectorMock.SObjectType()).thenReturn(OrderItem.SObjectType);
        //Mocks class not working when the parameter is a FieldSet, so we have to match the parameters on any object.
        //mocks.when(orderItemSelectorMock.selectOrderItemFieldSetById((Schema.Fieldset)fieldSet, (Set<Id>)orderItemIdSubscriptionIdMap.keySet())).thenReturn(orderItemList);
        mocks.when(
                orderItemSelectorMock.selectOrderItemFieldSetById(
                    (Schema.Fieldset) fflib_Match.anyObject(),
                    (Set<Id>) fflib_Match.anyObject()
                )
            )
            .thenReturn(orderItemList);
        mocks.when(servicesSelectorMock.SObjectType()).thenReturn(Merchant_Service__c.SObjectType);
        mocks.when(
                servicesSelectorMock.queryMerchantRecordsWithAccountIds(new Set<Id>{ accountId })
            )
            .thenReturn(new List<Merchant_Service__c>{ existingService });
        mocks.when(
                creationServiceMock.createActivationOrdersForAccountContractMap(
                    (Map<String, Id>) fflib_Match.anyObject(),
                    (Map<Id, Id>) fflib_Match.anyObject(),
                    (Map<Id, Map<String, String>>) fflib_Match.anyObject(),
                    (Map<Id, String>) fflib_Match.anyObject(),
                    (Map<Id, Boolean>) fflib_Match.anyObject(),
                    (Map<Id, Map<String, List<String>>>) fflib_Match.anyObject(),
                    (fflib_ISObjectUnitOfWork) fflib_Match.eq(mockUOW)
                )
            )
            .thenReturn(false);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(contractSelectorMock);
        Application.SELECTOR.setMock(subscriptionSelectorMock);
        Application.SELECTOR.setMock(orderItemSelectorMock);
        Application.SELECTOR.setMock(servicesSelectorMock);
        Application.SERVICE.setMock(IActivationOrderCreationService.class, creationServiceMock);
        Application.UNITOFWORK.setMock(mockUOW);

        Map<String, Id> accountIdToContractIdMap = new Map<String, Id>();
        accountIdToContractIdMap.put(
            String.valueof(accountId) + '-' + String.valueof(opportunityId),
            contractId
        );

        boolean uowCommitted = ActivationOrdersService.createActivationOrdersAndProductsForIntegratedFranchise(
            accountIdToContractIdMap,
            mockUOW
        );
        System.assertEquals(true, uowCommitted, 'uow should have been committed.');

        // Verify that commitWork method is called at least once
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
        //((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description Tests Activation of Order Prodcucts when Xref goes to Success
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenActivateOrderProductsOnXrefSuccessThenOrderItemsUpdated() {
        Id primaryOrderItemId = Fake.generateId(OrderItem.class);
        Id marketplaceOrderItemId = Fake.generateId(OrderItem.class);
        Id driveOrderItemId = Fake.generateId(OrderItem.class);
        Id marketplaceOrderId = Fake.generateId(Order.class);
        Id driveOrderId = Fake.generateId(Order.class);
        Id marketplaceAccountId = Fake.generateId(Account.class);
        Id driveAccountId = Fake.generateId(Account.class);
        Id subRateChangeReqId = Fake.generateId(Subscription_Rate_Change__c.class);
        Id subscriptionId1 = fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType);
        Id rateChangeReqId = Fake.generateId(Rate_Change_Request__c.class);
        Id contractId = Fake.generateId(Contract.class);

        Date marketplaceDate = System.today().addDays(3);
        Date driveDate = System.today();
        Date driveOrderStartDate = System.today() + 5;
        Date srcEffectiveDate = System.today();

        Xref__c marketplaceXref = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.External_ID_Source__c, XREF_EXTERNAL_SOURCE_MARKETPLACE)
            .setField(Xref__c.Salesforce_Account_Name__c, marketplaceAccountId)
            .toSObject();

        Xref__c driveXref = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.External_ID_Source__c, XREF_EXTERNAL_SOURCE_DRIVE)
            .setField(Xref__c.Salesforce_Account_Name__c, driveAccountId)
            .toSObject();

        Subscription_Rate_Change__c subRateChange = (Subscription_Rate_Change__c) new Fake(
                Subscription_Rate_Change__c.class
            )
            .setFakeId()
            .setField(Subscription_Rate_Change__c.Id, subRateChangeReqId)
            .setField(Subscription_Rate_Change__c.Rate_Change_Request__c, rateChangeReqId)
            .setField(Subscription_Rate_Change__c.Subscription__c, subscriptionId1)
            .setParent(
                'Rate_Change_Request__r',
                new Fake(Rate_Change_Request__c.class)
                    .setField(Rate_Change_Request__c.Id, rateChangeReqId)
                    .setField(Rate_Change_Request__c.Effective_Date__c, srcEffectiveDate)
            )
            .toSObject();

        Merchant_Service__c marketplaceService = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setFakeId()
            .setField(Merchant_Service__c.Order_Product__c, marketplaceOrderItemId)
            .setField(Merchant_Service__c.Active_Rates_Applied__c, true)
            .setField(Merchant_Service__c.Subscription__c, subscriptionId1)
            .setParent(
                'Order_Product__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, marketplaceOrderItemId)
                    .setField(OrderItem.SBQQ__Status__c, STATUS_DRAFT)
                    .setParent(
                        'Order',
                        new Fake(Order.class).setField(Order.Id, marketplaceOrderId)
                    )
            )
            .setParent(
                'Subscription__r',
                new Fake(SBQQ__Subscription__c.class)
                    .setField(SBQQ__Subscription__c.Id, subscriptionId1)
                    .setField(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
                    .setField(SBQQ__Subscription__c.SBQQ__OrderProduct__c, primaryOrderItemId)
                    .setField(SBQQ__Subscription__c.Subscription_Rate_Change__c, subRateChange.Id)
                    .setParent(
                        'Subscription_Rate_Change__r',
                        new Fake(Subscription_Rate_Change__c.class)
                            .setField(Subscription_Rate_Change__c.Id, subRateChangeReqId)
                            .setField(
                                Subscription_Rate_Change__c.Rate_Change_Request__c,
                                rateChangeReqId
                            )
                            .setField(Subscription_Rate_Change__c.Subscription__c, subscriptionId1)
                            .setParent(
                                'Rate_Change_Request__r',
                                new Fake(Rate_Change_Request__c.class)
                                    .setField(Rate_Change_Request__c.Id, rateChangeReqId)
                                    .setField(
                                        Rate_Change_Request__c.Effective_Date__c,
                                        srcEffectiveDate
                                    )
                            )
                    )
            )
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Id, marketplaceAccountId)
                    .setField(Account.Proposed_Date_of_Activation__c, marketplaceDate)
            )
            .toSObject();

        Merchant_Service__c driveService = (Merchant_Service__c) new Fake(Merchant_Service__c.class)
            .setFakeId()
            .setField(Merchant_Service__c.Order_Product__c, driveOrderItemId)
            .setParent(
                'Order_Product__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, driveOrderItemId)
                    .setField(OrderItem.SBQQ__Status__c, STATUS_DRAFT)
                    .setParent(
                        'Order',
                        new Fake(Order.class)
                            .setField(Order.Id, driveOrderId)
                            .setField(Order.EffectiveDate, driveOrderStartDate)
                    )
            )
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Id, driveAccountId)
                    .setField(Account.Proposed_Date_of_Activation__c, null)
            )
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IMerchantSelector selectorMock = (IMerchantSelector) mocks.mock(IMerchantSelector.class);

        mocks.startStubbing();
        mocks.when(selectorMock.SObjectType()).thenReturn(Merchant_Service__c.SObjectType);
        mocks.when(
                selectorMock.queryActiveMarketplaceServicesWithDraftOrderProductsByAccountId(
                    new Set<Id>{ marketplaceAccountId }
                )
            )
            .thenReturn(new List<Merchant_Service__c>{ marketplaceService });
        mocks.when(
                selectorMock.queryActiveDriveServicesWithDraftOrderProductsByAccountId(
                    new Set<Id>{ driveAccountId }
                )
            )
            .thenReturn(new List<Merchant_Service__c>{ driveService });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(selectorMock);
        Application.UNITOFWORK.setMock(mockUOW);

        ActivationOrdersService.activateOrderProductsOnXrefSuccess(
            new List<Xref__c>{ marketplaceXref, driveXref }
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        //Make sure the Services are updated
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        OrderItem.Id => marketplaceOrderItemId,
                        OrderItem.SBQQ__Status__c => ACTIVATED,
                        OrderItem.ServiceDate => srcEffectiveDate
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        OrderItem.Id => driveOrderItemId,
                        OrderItem.SBQQ__Status__c => ACTIVATED,
                        OrderItem.ServiceDate => driveDate
                    }
                )
            );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Order.Id => marketplaceOrderId,
                        Order.EffectiveDate => srcEffectiveDate
                    }
                )
            );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Order.Id => driveOrderId,
                        Order.EffectiveDate => driveDate
                    }
                )
            );
    }

    /**
     * @description Tests Activation of Order Products when Business Reference goes to Success
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenActivateOrderProductsOnBusinessReferenceSuccessThenOrderItemsUpdated() {
        Id driveBusinessReferenceId1 = Fake.generateId(Business_Reference__c.class);
        Id driveBusinessReferenceId2 = Fake.generateId(Business_Reference__c.class);
        Id driveOrderItemId = Fake.generateId(OrderItem.class);
        Id driveOrderId1 = Fake.generateId(Order.class);
        Id driveAccountId = Fake.generateId(Account.class);
        Id driveOrderItemId2 = Fake.generateId(OrderItem.class);
        Id driveOrderId2 = Fake.generateId(Order.class);
        Id driveAccountId2 = Fake.generateId(Account.class);
        Date driveDate = System.today();

        Business_Reference__c driveBusinessReference1 = (Business_Reference__c) new Fake(
                Business_Reference__c.class
            )
            .setField(Business_Reference__c.External_ID_Source__c, XREF_EXTERNAL_SOURCE_DRIVE)
            .setField(Business_Reference__c.Integration_Status__c, INTEGRATION_STATUS_SUCCESS)
            .setField(
                Business_Reference__c.Last_Completed_Step__c,
                LAST_COMPLETED_STEP_CONFIGURATION
            )
            .setField(Business_Reference__c.Id, driveBusinessReferenceId1)
            .toSObject();

        Business_Reference__c driveBusinessReference2 = (Business_Reference__c) new Fake(
                Business_Reference__c.class
            )
            .setField(Business_Reference__c.External_ID_Source__c, XREF_EXTERNAL_SOURCE_DRIVE)
            .setField(Business_Reference__c.Integration_Status__c, INTEGRATION_STATUS_SUCCESS)
            .setField(Business_Reference__c.Last_Completed_Step__c, '')
            .setField(Business_Reference__c.Id, driveBusinessReferenceId2)
            .toSObject();

        Xref__c driveXref = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.External_ID_Source__c, XREF_EXTERNAL_SOURCE_DRIVE)
            .setField(Xref__c.Salesforce_Account_Name__c, driveAccountId)
            .toSObject();
        Xref__c driveXref2 = (Xref__c) new Fake(Xref__c.class)
            .setField(Xref__c.External_ID_Source__c, XREF_EXTERNAL_SOURCE_DRIVE)
            .setField(Xref__c.Salesforce_Account_Name__c, driveAccountId2)
            .toSObject();

        Merchant_Service__c driveService = (Merchant_Service__c) new Fake(Merchant_Service__c.class)
            .setFakeId()
            .setField(Merchant_Service__c.Order_Product__c, driveOrderItemId)
            .setParent(
                'Order_Product__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, driveOrderItemId)
                    .setField(OrderItem.SBQQ__Status__c, STATUS_DRAFT)
                    .setParent('Order', new Fake(Order.class).setField(Order.Id, driveOrderId1))
            )
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Id, driveAccountId)
                    .setField(Account.Proposed_Date_of_Activation__c, null)
            )
            .toSObject();
        Merchant_Service__c driveService2 = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setFakeId()
            .setField(Merchant_Service__c.Order_Product__c, driveOrderItemId2)
            .setParent(
                'Order_Product__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, driveOrderItemId2)
                    .setField(OrderItem.SBQQ__Status__c, STATUS_DRAFT)
                    .setParent('Order', new Fake(Order.class).setField(Order.Id, driveOrderId2))
            )
            .setParent(
                'Account__r',
                new Fake(Account.class)
                    .setField(Account.Id, driveAccountId2)
                    .setField(Account.Proposed_Date_of_Activation__c, null)
            )
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IMerchantSelector selectorMock = (IMerchantSelector) mocks.mock(IMerchantSelector.class);
        IXrefsSelector xrefSelectorMock = (IXrefsSelector) mocks.mock(IXrefsSelector.class);

        mocks.startStubbing();
        mocks.when(selectorMock.SObjectType()).thenReturn(Merchant_Service__c.SObjectType);
        mocks.when(
                selectorMock.queryActiveDriveServicesWithDraftOrderProductsByAccountId(
                    new Set<Id>{ driveAccountId, driveAccountId2 }
                )
            )
            .thenReturn(new List<Merchant_Service__c>{ driveService, driveService2 });
        mocks.when(xrefSelectorMock.SObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                xrefSelectorMock.selectAllMatchingBusinessReferenceForDriveDb(
                    new Set<Id>{ driveBusinessReferenceId1, driveBusinessReferenceId2 }
                )
            )
            .thenReturn(new List<Xref__c>{ driveXref, driveXref2 });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(selectorMock);
        Application.SELECTOR.setMock(xrefSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);

        ActivationOrdersService.activateOrderProductsOnBusinessReferenceSuccess(
            new List<Business_Reference__c>{ driveBusinessReference1, driveBusinessReference2 }
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        //Make sure the Services are updated
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        OrderItem.Id => driveOrderItemId,
                        OrderItem.SBQQ__Status__c => ACTIVATED,
                        OrderItem.ServiceDate => driveDate
                    }
                )
            );
        //Requirement on LEM-3510 changed, so both services should now be updated.
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        OrderItem.Id => driveOrderItemId2,
                        OrderItem.SBQQ__Status__c => ACTIVATED,
                        OrderItem.ServiceDate => driveDate
                    }
                )
            );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Order.Id => driveOrderId1,
                        Order.EffectiveDate => driveDate
                    }
                )
            );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Order.Id => driveOrderId2,
                        Order.EffectiveDate => driveDate
                    }
                )
            );
    }

    /**
     * @description Tests when Parent is updated it reflects in Account record
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenAgreementsEntitlementsUpdatedThenServicesAreUpdatedForExistingFlow() {
        Id agreement1Id = Fake.generateId(Agreement__c.class);
        Id quoteLineGroupId = Fake.generateId(SBQQ__QuoteLineGroup__c.class);
        Id accountId = Fake.generateId(Account.class);
        Id businessAccountId = Fake.generateId(Account.class);
        Id contractId = Fake.generateId(Contract.class);
        Id packageId1 = Fake.generateId(SBQQ__Subscription__c.class);
        Id productId1 = Fake.generateId(SBQQ__Subscription__c.class);
        Id productId2 = Fake.generateId(SBQQ__Subscription__c.class);
        Id serviceProductId1 = Fake.generateId(Merchant_Service__c.class);
        Id serviceProductId2 = Fake.generateId(Merchant_Service__c.class);
        Id servicePackageId1 = Fake.generateId(Merchant_Service__c.class);
        Id orderItemId1 = Fake.generateId(OrderItem.class);
        Id orderItemId2 = Fake.generateId(OrderItem.class);
        Id orderItemIdPackage1 = Fake.generateId(OrderItem.class);

        String jsonStr =
            '{"selected":[{"productSubId":[{"productName":"DoubleDash","productId":"' +
            productId1 +
            '"},{"productName":"Alcohol Delivery","productId":"' +
            productId2 +
            '"}],"packageName":"Marketplace","packageId":"' +
            packageId1 +
            '"}],"deselected":[{"selectedPackageId":"' +
            packageId1 +
            '","productDeselected":[]}]}';
        Fake opportunityRecordFake = new Fake(Opportunity.class)
            .setField(Opportunity.Name, 'Test opportunity 1')
            .setField(Opportunity.LastModifiedDate, Date.today() - 120)
            .setField(Opportunity.AccountId, accountId)
            .setFakeId();
        Agreement__c agreement1 = (Agreement__c) new Fake(Agreement__c.class)
            .setField(Agreement__c.Status__c, ACTIVE)
            .setField(Agreement__c.Id, agreement1Id)
            .setField(Agreement__c.Account__c, accountId)
            .setField(Agreement__c.Contract__c, contractId)
            .setField(Agreement__c.Activation_Order_Created__c, false)
            .setField(Agreement__c.Group__c, quoteLineGroupId)
            .setField(Agreement__c.Serialized_Entitlements_Data__c, jsonStr)
            .setParent('Opportunity__r', opportunityRecordFake)
            .toSObject();
        Merchant_Service__c marketplacePackageService = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setField(Merchant_Service__c.Id, servicePackageId1)
            .setField(Merchant_Service__c.Account__c, accountId)
            .setField(Merchant_Service__c.Order_Product__c, orderItemIdPackage1)
            .setField(Merchant_Service__c.Subscription__c, packageId1)
            .setField(Merchant_Service__c.Mx_Agreed_To_Product__c, 'No')
            .setField(Merchant_Service__c.Group__c, quoteLineGroupId)
            .setParent(
                'Subscription__r',
                new Fake(SBQQ__Subscription__c.class)
                    .setField(SBQQ__Subscription__c.Id, packageId1)
                    .setField(SBQQ__Subscription__c.SBQQ__RootId__c, packageId1)
                    .setField(SBQQ__Subscription__c.SBQQ__RequiredById__c, null)
                    .setField(SBQQ__Subscription__c.SBQQ__Account__c, businessAccountId)
            )
            .setParent(
                'Order_Product__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, orderItemIdPackage1)
                    .setField(OrderItem.Existing_Store_Processed__c, false)
            )
            .toSObject();
        Merchant_Service__c marketplaceProductService1 = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setField(Merchant_Service__c.Id, serviceProductId1)
            .setField(Merchant_Service__c.Account__c, accountId)
            .setField(Merchant_Service__c.Order_Product__c, orderItemId1)
            .setField(Merchant_Service__c.Subscription__c, productId1)
            .setField(Merchant_Service__c.Mx_Agreed_To_Product__c, 'No')
            .setField(Merchant_Service__c.Group__c, quoteLineGroupId)
            .setParent(
                'Subscription__r',
                new Fake(SBQQ__Subscription__c.class)
                    .setField(SBQQ__Subscription__c.Id, productId1)
                    .setField(SBQQ__Subscription__c.SBQQ__RootId__c, packageId1)
                    .setField(SBQQ__Subscription__c.SBQQ__RequiredById__c, packageId1)
                    .setField(SBQQ__Subscription__c.SBQQ__Account__c, businessAccountId)
            )
            .setParent(
                'Order_Product__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, orderItemId1)
                    .setField(OrderItem.Existing_Store_Processed__c, false)
            )
            .toSObject();
        Merchant_Service__c marketplaceProductService2 = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setField(Merchant_Service__c.Id, serviceProductId2)
            .setField(Merchant_Service__c.Account__c, accountId)
            .setField(Merchant_Service__c.Order_Product__c, orderItemId2)
            .setField(Merchant_Service__c.Subscription__c, productId2)
            .setField(Merchant_Service__c.Mx_Agreed_To_Product__c, 'No')
            .setField(Merchant_Service__c.Group__c, quoteLineGroupId)
            .setParent(
                'Subscription__r',
                new Fake(SBQQ__Subscription__c.class)
                    .setField(SBQQ__Subscription__c.Id, productId2)
                    .setField(SBQQ__Subscription__c.SBQQ__RootId__c, packageId1)
                    .setField(SBQQ__Subscription__c.SBQQ__RequiredById__c, packageId1)
                    .setField(SBQQ__Subscription__c.SBQQ__Account__c, businessAccountId)
            )
            .setParent(
                'Order_Product__r',
                new Fake(OrderItem.class)
                    .setField(OrderItem.Id, orderItemId2)
                    .setField(OrderItem.Existing_Store_Processed__c, false)
            )
            .toSObject();
        List<Merchant_Service__c> servicesList = new List<Merchant_Service__c>{
            marketplacePackageService,
            marketplaceProductService1,
            marketplaceProductService2
        };
        List<Agreement__c> agreementList = new List<Agreement__c>{ agreement1 };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAccountsService mockAccountService = (IAccountsService) mocks.mock(
            IAccountsService.class
        );
        IMerchantSelector selectorMock = (IMerchantSelector) mocks.mock(IMerchantSelector.class);
        mocks.startStubbing();
        mocks.when(selectorMock.SObjectType()).thenReturn(Merchant_Service__c.SObjectType);
        mocks.when(selectorMock.queryMerchantRecordsWithAccountIds(new Set<Id>{ accountId }))
            .thenReturn(servicesList);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IAccountsService.class, mockAccountService);
        ActivationOrdersService.updateMerchantServicesbasedOnEntitlements(agreementList);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((IAccountsService) mocks.verify(mockAccountService, 1))
            .updateFieldsOnAccount(new Set<Id>{ accountId });
        //Make sure the agreement with correct parameters are updated
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Merchant_Service__c.Id => servicePackageId1,
                        Merchant_Service__c.Mx_Agreed_To_Product__c => MX_AGREED_YES
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Merchant_Service__c.Id => serviceProductId1,
                        Merchant_Service__c.Mx_Agreed_To_Product__c => MX_AGREED_YES
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Merchant_Service__c.Id => serviceProductId2,
                        Merchant_Service__c.Mx_Agreed_To_Product__c => MX_AGREED_YES
                    }
                )
            );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        OrderItem.Id => orderItemId1,
                        OrderItem.Existing_Store_Processed__c => true
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        OrderItem.Id => orderItemId2,
                        OrderItem.Existing_Store_Processed__c => true
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        OrderItem.Id => orderItemIdPackage1,
                        OrderItem.Existing_Store_Processed__c => true
                    }
                )
            );
    }
}