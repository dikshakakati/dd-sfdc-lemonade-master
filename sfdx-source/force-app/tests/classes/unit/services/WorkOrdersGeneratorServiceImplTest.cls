/**
 * @author Deloitte
 * @date 06/07/2024
 * @description Test class for WorkOrderCreationTriggerServiceImpl class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 */
@isTest
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class WorkOrdersGeneratorServiceImplTest {
    private static final String ACTIVATED_CENTRALLY_YES = 'Yes';
    private static final String ADDRESS_COVERAGE_IN_COVERAGE = 'In Coverage';
    private static final String ADDRESS_VERIFICATION_STATUS_VERIFIED = 'Verified';
    private static final String AMENDMENT_WORK_ORDER_CREATION = 'AMENDMENT_WORK_ORDER_GENERATION';
    private static final String CORE_ORDER = 'Core';
    private static final String CREATION_SOURCE_MX_PORTAL = 'Mx Portal';
    private static final Date DATE_TODAY = System.today();
    private static final String DRIVE_FAMILY = 'Drive';
    private static final String EMAIL_ORDER_PROTOCOL = 'Email';
    private static final String EVENT_TOPIC_WORK_ORDER_GENERATION = 'WORK_ORDER_GENERATION';
    private static final String MARKETPLACE_TYPE = 'Marketplace';
    private static final String MENU_SET_UP_METHOD = 'None - Menu Setup Complete';
    private static final String MENU_TO_BE_COMPLETED_BY_DOORDASH = 'DoorDash Onboarding Team';
    private static final String ONBOARDING_SCENARIO_NET_NEW_MX_ONBOARDING = 'Net-New';
    private static final String ONBOARDING_SCENARIO_NEW_STORE_EXPANSION = 'NSE';
    private static final String ONBOARDING_SCENARIO_PRODUCT_ADDITION = 'Product Addition';
    private static final String PRODUCT_FAMILY_HARDWARE = 'Hardware';
    private static final String SSMO_CREATION_SOURCE = 'SSMO';
    private static final String SSOB_CREATION_SOURCE = 'SSOB';
    private static final String PHOTOSHOOT_REQUEST_YES = 'Yes';
    private static final String POS_ORDER_PROTOCOL = 'POS';
    private static final String SMB_SEGMENT_TYPE = 'SMB';
    private static final String SEPARATOR = System.Label.Separator;
    private static final String TYPE_AMENDMENT = 'Amendment';
    private static final Id STORE_ACCOUNT_RECORD_TYPE = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Store')
        .getRecordTypeId();
    private static final String ACTIVATED_CONTRACT_STATUS = 'Activated';
    private static final String STOREFRONT_TYPE = 'Storefront';
    private static final String TABLET_ORDER_PROTOCOL = 'Tablet';
    private static final String WORK_ORDER_TYPE_DRIVE = 'Drive';
    private static final String UNIQUE_IDENTIFIER = '942db671-92c3-3d7b-8b05-1e326f5e45f0';
    private static final String ASSERT_MESSAGE_OPPORTUNITY_NOT_MATCHING = 'Unexpected result: Opportunity Id is not matching';
    private static final String ASSERT_MESSAGE_MX_ONBOARDING_LINK_NOT_MATCHING = 'Unexpected result: Mx Onboarding Id is not matching';

    /**
     * @description To Test creation of Interface Transaction records when Onbaording
     * Activations Platform Events are fired for Marketplace WorkOrder Creation.
     */
    @isTest
    private static void testWhenOnboardingEventsFiredForMarketplaceWorkOrderCreationThenCreateInterfaceTransaction() {
        Id subscriptionId = fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType);
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id quoteId = fflib_IDGenerator.generate(SBQQ__Quote__c.SobjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SobjectType);
        Id productId = fflib_IDGenerator.generate(Product2.SobjectType);
        List<Onboarding_Activation__e> mockOnboardingEvents = new List<Onboarding_Activation__e>{
            new Onboarding_Activation__e(
                Payload__c = JSON.serialize(new Set<Id>{ String.valueOf(subscriptionId) }),
                Topic__c = EVENT_TOPIC_WORK_ORDER_GENERATION
            )
        };
        Account fakeStoreAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, fflib_IDGenerator.generate(Account.SobjectType))
            .setField(Account.Segment__c, SMB_SEGMENT_TYPE)
            .setField(Account.Unique_Identifier__c, UNIQUE_IDENTIFIER)
            .setField(Account.ParentId, parentAccountId)
            .setField(Account.Order_Protocol__c, POS_ORDER_PROTOCOL)
            .toSobject();
        Fake fakeQuote = new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id, quoteId)
            .setField(SBQQ__Quote__c.Unique_Identifier__c, UNIQUE_IDENTIFIER)
            .setField(SBQQ__Quote__c.Integration_Source__c, SSMO_CREATION_SOURCE);
        Fake fakeContract = new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.Status, ACTIVATED_CONTRACT_STATUS)
            .setField(Contract.SBQQ__Quote__c, quoteId)
            .setParent('SBQQ__Quote__r', fakeQuote)
            .setField(Contract.Unique_Identifier__c, UNIQUE_IDENTIFIER)
            .setParent(
                'SBQQ__Order__r',
                new Fake(Order.class).setField(Order.Unique_Identifier__c, UNIQUE_IDENTIFIER)
            );
        Fake fakeProduct = new Fake(Product2.class)
            .setField(Product2.Id, productId)
            .setField(Product2.Name, MARKETPLACE_TYPE)
            .setField(Product2.Work_Order_Type__c, MARKETPLACE_TYPE);

        List<SBQQ__Subscription__c> mockSubscription = new List<SBQQ__Subscription__c>{
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.Id, subscriptionId)
                .setField(SBQQ__Subscription__c.SBQQ__Account__c, parentAccountId)
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
                .setField(SBQQ__Subscription__c.SBQQ__Product__c, productId)
                .setField(SBQQ__Subscription__c.Integration_Source__c, SSMO_CREATION_SOURCE)
                .setParent('SBQQ__Product__r', fakeProduct)
                .setParent('SBQQ__Contract__r', fakeContract)
                .toSobject()
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountSelectorMocks = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        ISubscriptionsService subscriptionServiceMock = (ISubscriptionsService) mocks.mock(
            ISubscriptionsService.class
        );

        mocks.startStubbing();
        mocks.when(accountSelectorMocks.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountSelectorMocks.selectAccountsByMxOnboardingLinkIds(new Set<String>{}))
            .thenReturn(new List<Account>{});
        mocks.when(
                accountSelectorMocks.selectByUniqueIdentifiers(
                    new Set<Id>{ parentAccountId },
                    new Set<String>{ UNIQUE_IDENTIFIER }
                )
            )
            .thenReturn(new List<Account>{ fakeStoreAccount });
        mocks.when(
                subscriptionServiceMock.getSubscriptionsAndRelatedInformation(
                    new Set<Id>{ subscriptionId }
                )
            )
            .thenReturn(mockSubscription);
        mocks.when(subscriptionServiceMock.getExistingSubscriptionsForContracts(new Set<Id>{}))
            .thenReturn(new Map<Id, Set<String>>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(accountSelectorMocks);
        Application.SERVICE.setMock(ISubscriptionsService.class, subscriptionServiceMock);
        WorkOrdersGeneratorService.execute(mockOnboardingEvents);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To Test creation of Interface Transaction records when Onbaording
     * Activations Platform Events are fired for Storefront Work Order Creation.
     */
    @isTest
    private static void testWhenOnboardingEventsFiredForStorefrontWorkOrderCreationThenCreateInterfaceTransaction() {
        Id subscriptionId = fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType);
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id quoteId = fflib_IDGenerator.generate(SBQQ__Quote__c.SobjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SobjectType);
        Id productId = fflib_IDGenerator.generate(Product2.SobjectType);
        List<Onboarding_Activation__e> mockOnboardingEvents = new List<Onboarding_Activation__e>{
            new Onboarding_Activation__e(
                Payload__c = JSON.serialize(new Set<Id>{ String.valueOf(subscriptionId) }),
                Topic__c = EVENT_TOPIC_WORK_ORDER_GENERATION
            )
        };
        Account fakeStoreAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, fflib_IDGenerator.generate(Account.SobjectType))
            .setField(Account.Segment__c, SMB_SEGMENT_TYPE)
            .setField(Account.Unique_Identifier__c, UNIQUE_IDENTIFIER)
            .setField(Account.ParentId, parentAccountId)
            .setField(Account.Order_Protocol__c, EMAIL_ORDER_PROTOCOL)
            .toSobject();
        Fake fakeQuote = new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id, quoteId)
            .setField(SBQQ__Quote__c.Unique_Identifier__c, UNIQUE_IDENTIFIER)
            .setField(SBQQ__Quote__c.Integration_Source__c, SSMO_CREATION_SOURCE);
        Fake fakeContract = new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.Status, ACTIVATED_CONTRACT_STATUS)
            .setField(Contract.SBQQ__Quote__c, quoteId)
            .setParent('SBQQ__Quote__r', fakeQuote)
            .setField(Contract.Unique_Identifier__c, UNIQUE_IDENTIFIER)
            .setParent(
                'SBQQ__Order__r',
                new Fake(Order.class).setField(Order.Unique_Identifier__c, UNIQUE_IDENTIFIER)
            );
        Fake fakeProduct = new Fake(Product2.class)
            .setField(Product2.Id, productId)
            .setField(Product2.Name, STOREFRONT_TYPE)
            .setField(Product2.Work_Order_Type__c, MARKETPLACE_TYPE);

        List<SBQQ__Subscription__c> mockSubscription = new List<SBQQ__Subscription__c>{
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.Id, subscriptionId)
                .setField(SBQQ__Subscription__c.SBQQ__Account__c, parentAccountId)
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
                .setField(SBQQ__Subscription__c.SBQQ__Product__c, productId)
                .setField(SBQQ__Subscription__c.Integration_Source__c, SSMO_CREATION_SOURCE)
                .setParent('SBQQ__Product__r', fakeProduct)
                .setParent('SBQQ__Contract__r', fakeContract)
                .toSobject()
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountSelectorMocks = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        ISubscriptionsService subscriptionServiceMock = (ISubscriptionsService) mocks.mock(
            ISubscriptionsService.class
        );

        mocks.startStubbing();
        mocks.when(accountSelectorMocks.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountSelectorMocks.selectAccountsByMxOnboardingLinkIds(new Set<String>{}))
            .thenReturn(new List<Account>{});
        mocks.when(
                accountSelectorMocks.selectByUniqueIdentifiers(
                    new Set<Id>{ parentAccountId },
                    new Set<String>{ UNIQUE_IDENTIFIER }
                )
            )
            .thenReturn(new List<Account>{ fakeStoreAccount });
        mocks.when(
                subscriptionServiceMock.getSubscriptionsAndRelatedInformation(
                    new Set<Id>{ subscriptionId }
                )
            )
            .thenReturn(mockSubscription);
        mocks.when(subscriptionServiceMock.getExistingSubscriptionsForContracts(new Set<Id>{}))
            .thenReturn(new Map<Id, Set<String>>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(accountSelectorMocks);
        Application.SERVICE.setMock(ISubscriptionsService.class, subscriptionServiceMock);
        WorkOrdersGeneratorService.execute(mockOnboardingEvents);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To Test creation of Interface Transaction records when Onboarding
     * Activations Platform Events are fired for Marketing Kit Work Order creation.
     */
    @isTest
    private static void testWhenOnboardingEventsFiredForMarketingKitWorkOrderCreationThenCreateInterfaceTransaction() {
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        List<Onboarding_Activation__e> mockOnboardingEvents = new List<Onboarding_Activation__e>{
            new Onboarding_Activation__e(
                Payload__c = JSON.serialize(new Set<Id>{ String.valueOf(workPlanId) }),
                Topic__c = EVENT_TOPIC_WORK_ORDER_GENERATION
            )
        };
        Fake fakeWorkOrderInstance = new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, workOrderId)
            .setField(WorkOrder.Order_Protocol__c, EMAIL_ORDER_PROTOCOL)
            .setField(WorkOrder.AccountId, fflib_IDGenerator.generate(Account.SObjectType))
            .setField(WorkOrder.Opportunity__c, fflib_IDGenerator.generate(Opportunity.SObjectType))
            .setField(WorkOrder.Contract__c, fflib_IDGenerator.generate(Contract.SObjectType));
        WorkPlan fakeWorkPlan = (WorkPlan) new Fake(WorkPlan.class)
            .setField(WorkPlan.Id, workPlanId)
            .setField(WorkPlan.WorkOrderId, workOrderId)
            .setParent('WorkOrder', fakeWorkOrderInstance)
            .toSobject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkPlansSelector workPlansSelectorMock = (IWorkPlansSelector) mocks.mock(
            IWorkPlansSelector.class
        );
        IWorkOrdersSelector workOrdersSelectorMock = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        mocks.startStubbing();
        mocks.when(workPlansSelectorMock.SObjectType()).thenReturn(WorkPlan.SObjectType);
        mocks.when(
                workPlansSelectorMock.selectWorkPlansWithWorkOrderDetails(new Set<Id>{ workPlanId })
            )
            .thenReturn(new List<WorkPlan>{ fakeWorkPlan });
        mocks.when(workOrdersSelectorMock.SObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                workOrdersSelectorMock.selectMarketingKitWorkOrdersByOriginatingWorkOrder(
                    new Set<Id>{ workOrderId }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(workPlansSelectorMock);
        Application.SELECTOR.setMock(workOrdersSelectorMock);
        WorkOrdersGeneratorService.execute(mockOnboardingEvents);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To Test creation of Interface Transaction when Platform Events are fired for Amendments.
     */
    @isTest
    private static void testWhenOnboardingEventsFiredForAmendmentsThenCreateInterfaceTransactions() {
        Id pastSubscriptionId = fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType);
        Id newSubscriptionId = fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType);
        List<Onboarding_Activation__e> mockOnboardingEvents = new List<Onboarding_Activation__e>{
            new Onboarding_Activation__e(
                Payload__c = JSON.serialize(new Set<Id>{ String.valueOf(newSubscriptionId) }),
                Topic__c = AMENDMENT_WORK_ORDER_CREATION
            )
        };
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Fake fakeProduct = new Fake(Product2.class)
            .setField(Product2.Id, fflib_IDGenerator.generate(Product2.SObjectType))
            .setField(Product2.Name, MARKETPLACE_TYPE)
            .setField(Product2.Family, MARKETPLACE_TYPE);
        Fake fakeContract = new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setField(
                Contract.SBQQ__Opportunity__c,
                fflib_IDGenerator.generate(Opportunity.SObjectType)
            );
        SBQQ__Subscription__c pastSubscription = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, pastSubscriptionId)
            .setField(SBQQ__Subscription__c.Package__c, null)
            .setField(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setParent('SBQQ__Product__r', fakeProduct)
            .toSobject();
        SBQQ__Subscription__c newSubscription = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, newSubscriptionId)
            .setField(SBQQ__Subscription__c.Package__c, null)
            .setField(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setParent('SBQQ__Product__r', fakeProduct)
            .setParent('SBQQ__Contract__r', fakeContract)
            .toSobject();
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
                subscriptionSelectorMock.selectBySubscriptionIds(new Set<Id>{ newSubscriptionId })
            )
            .thenReturn(new List<SBQQ__Subscription__c>{ newSubscription });
        mocks.when(
                subscriptionSelectorMock.selectAmendedSubscriptions(
                    new Set<Id>{ contractId },
                    new Set<String>{ MARKETPLACE_TYPE },
                    new Set<Id>{ newSubscriptionId }
                )
            )
            .thenReturn(new List<SBQQ__Subscription__c>{ pastSubscription });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(subscriptionSelectorMock);
        Test.startTest();
        WorkOrdersGeneratorService.execute(mockOnboardingEvents);
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test interface transaction is not created when Onboarding Events are fired for SSOB
     * Marketplace Subscription.
     */
    @isTest
    private static void testWhenSSOBMarketplaceSubscriptionIsFiredThenDoNotCreateInterfaceTransactions() {
        Id subscriptionId = fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType);
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id quoteId = fflib_IDGenerator.generate(SBQQ__Quote__c.SobjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SobjectType);
        Id productId = fflib_IDGenerator.generate(Product2.SobjectType);
        List<Onboarding_Activation__e> mockOnboardingEvents = new List<Onboarding_Activation__e>{
            new Onboarding_Activation__e(
                Payload__c = JSON.serialize(new Set<Id>{ String.valueOf(subscriptionId) }),
                Topic__c = EVENT_TOPIC_WORK_ORDER_GENERATION
            )
        };
        Account fakeStoreAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, fflib_IDGenerator.generate(Account.SobjectType))
            .setField(Account.Segment__c, SMB_SEGMENT_TYPE)
            .setField(Account.Unique_Identifier__c, UNIQUE_IDENTIFIER)
            .setField(Account.ParentId, parentAccountId)
            .setField(Account.Order_Protocol__c, POS_ORDER_PROTOCOL)
            .toSobject();
        Fake fakeQuote = new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id, quoteId)
            .setField(SBQQ__Quote__c.Unique_Identifier__c, UNIQUE_IDENTIFIER)
            .setField(SBQQ__Quote__c.Integration_Source__c, SSOB_CREATION_SOURCE);
        Fake fakeContract = new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.Status, ACTIVATED_CONTRACT_STATUS)
            .setField(Contract.SBQQ__Quote__c, quoteId)
            .setParent('SBQQ__Quote__r', fakeQuote)
            .setField(Contract.Unique_Identifier__c, UNIQUE_IDENTIFIER)
            .setParent(
                'SBQQ__Order__r',
                new Fake(Order.class).setField(Order.Unique_Identifier__c, UNIQUE_IDENTIFIER)
            );
        Fake fakeProduct = new Fake(Product2.class)
            .setField(Product2.Id, productId)
            .setField(Product2.Name, MARKETPLACE_TYPE)
            .setField(Product2.Work_Order_Type__c, MARKETPLACE_TYPE);

        List<SBQQ__Subscription__c> mockSubscription = new List<SBQQ__Subscription__c>{
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.Id, subscriptionId)
                .setField(SBQQ__Subscription__c.SBQQ__Account__c, parentAccountId)
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
                .setField(SBQQ__Subscription__c.SBQQ__Product__c, productId)
                .setField(SBQQ__Subscription__c.Integration_Source__c, SSOB_CREATION_SOURCE)
                .setParent('SBQQ__Product__r', fakeProduct)
                .setParent('SBQQ__Contract__r', fakeContract)
                .toSobject()
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountSelectorMocks = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        ISubscriptionsService subscriptionServiceMock = (ISubscriptionsService) mocks.mock(
            ISubscriptionsService.class
        );

        mocks.startStubbing();
        mocks.when(accountSelectorMocks.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountSelectorMocks.selectAccountsByMxOnboardingLinkIds(new Set<String>{}))
            .thenReturn(new List<Account>{});
        mocks.when(
                accountSelectorMocks.selectByUniqueIdentifiers(
                    new Set<Id>{ parentAccountId },
                    new Set<String>{ UNIQUE_IDENTIFIER }
                )
            )
            .thenReturn(new List<Account>{ fakeStoreAccount });
        mocks.when(
                subscriptionServiceMock.getSubscriptionsAndRelatedInformation(
                    new Set<Id>{ subscriptionId }
                )
            )
            .thenReturn(mockSubscription);
        mocks.when(subscriptionServiceMock.getExistingSubscriptionsForContracts(new Set<Id>{}))
            .thenReturn(new Map<Id, Set<String>>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(accountSelectorMocks);
        Application.SERVICE.setMock(ISubscriptionsService.class, subscriptionServiceMock);
        WorkOrdersGeneratorService.execute(mockOnboardingEvents);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description To Test when platform events are fired for Amendments then
     * Interface Transaction should not be created.
     */
    @isTest
    private static void testWhenOnboardingEventsFiredForMarketingKitNonEmailOrNonPOSWorkOrderCreationThenDoNotCreateInterfaceTransactions() {
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        List<Onboarding_Activation__e> mockOnboardingEvents = new List<Onboarding_Activation__e>{
            new Onboarding_Activation__e(
                Payload__c = JSON.serialize(new Set<Id>{ String.valueOf(workPlanId) }),
                Topic__c = EVENT_TOPIC_WORK_ORDER_GENERATION
            )
        };
        Fake fakeWorkOrderInstance = new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, workOrderId)
            .setField(WorkOrder.Order_Protocol__c, TABLET_ORDER_PROTOCOL)
            .setField(WorkOrder.AccountId, fflib_IDGenerator.generate(Account.SObjectType))
            .setField(WorkOrder.Opportunity__c, fflib_IDGenerator.generate(Opportunity.SObjectType))
            .setField(WorkOrder.Contract__c, fflib_IDGenerator.generate(Contract.SObjectType));
        WorkPlan fakeWorkPlan = (WorkPlan) new Fake(WorkPlan.class)
            .setField(WorkPlan.Id, workPlanId)
            .setField(WorkPlan.WorkOrderId, workOrderId)
            .setParent('WorkOrder', fakeWorkOrderInstance)
            .toSobject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkPlansSelector workPlansSelectorMock = (IWorkPlansSelector) mocks.mock(
            IWorkPlansSelector.class
        );
        IWorkOrdersSelector workOrdersSelectorMock = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        mocks.startStubbing();
        mocks.when(workPlansSelectorMock.SObjectType()).thenReturn(WorkPlan.SObjectType);
        mocks.when(
                workPlansSelectorMock.selectWorkPlansWithWorkOrderDetails(new Set<Id>{ workPlanId })
            )
            .thenReturn(new List<WorkPlan>{ fakeWorkPlan });
        mocks.when(workOrdersSelectorMock.SObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                workOrdersSelectorMock.selectMarketingKitWorkOrdersByOriginatingWorkOrder(
                    new Set<Id>{ workOrderId }
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(workPlansSelectorMock);
        Application.SELECTOR.setMock(workOrdersSelectorMock);
        Test.startTest();
        WorkOrdersGeneratorService.execute(mockOnboardingEvents);
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description To test if only one interface Transaction is created when multiple Onboarding Events
     * are fired for Marketplace.
     */
    @isTest
    private static void testWhenMultipleOnboardingEventsFiredForMareketplaceThenCreateSingleInterfaceTransaction() {
        Id subscriptionId1 = fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType);
        Id subscriptionId2 = fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType);
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id quoteId = fflib_IDGenerator.generate(SBQQ__Quote__c.SobjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SobjectType);
        Id productId = fflib_IDGenerator.generate(Product2.SobjectType);
        List<Onboarding_Activation__e> mockOnboardingEvents = new List<Onboarding_Activation__e>{
            new Onboarding_Activation__e(
                Payload__c = JSON.serialize(
                    new Set<Id>{ String.valueOf(subscriptionId1), String.valueOf(subscriptionId2) }
                ),
                Topic__c = EVENT_TOPIC_WORK_ORDER_GENERATION
            )
        };
        Account fakeStoreAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, fflib_IDGenerator.generate(Account.SobjectType))
            .setField(Account.Segment__c, SMB_SEGMENT_TYPE)
            .setField(Account.Unique_Identifier__c, UNIQUE_IDENTIFIER)
            .setField(Account.ParentId, parentAccountId)
            .setField(Account.Order_Protocol__c, POS_ORDER_PROTOCOL)
            .toSobject();
        Fake fakeQuote = new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id, quoteId)
            .setField(SBQQ__Quote__c.Unique_Identifier__c, UNIQUE_IDENTIFIER)
            .setField(SBQQ__Quote__c.Integration_Source__c, SSMO_CREATION_SOURCE);
        Fake fakeContract = new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.Status, ACTIVATED_CONTRACT_STATUS)
            .setField(Contract.SBQQ__Quote__c, quoteId)
            .setParent('SBQQ__Quote__r', fakeQuote)
            .setField(Contract.Unique_Identifier__c, UNIQUE_IDENTIFIER)
            .setParent(
                'SBQQ__Order__r',
                new Fake(Order.class).setField(Order.Unique_Identifier__c, UNIQUE_IDENTIFIER)
            );
        Fake fakeProduct = new Fake(Product2.class)
            .setField(Product2.Id, productId)
            .setField(Product2.Name, MARKETPLACE_TYPE)
            .setField(Product2.Work_Order_Type__c, MARKETPLACE_TYPE);

        List<SBQQ__Subscription__c> mockSubscription = new List<SBQQ__Subscription__c>{
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.Id, subscriptionId1)
                .setField(SBQQ__Subscription__c.SBQQ__Account__c, parentAccountId)
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
                .setField(SBQQ__Subscription__c.SBQQ__Product__c, productId)
                .setField(SBQQ__Subscription__c.Integration_Source__c, SSMO_CREATION_SOURCE)
                .setParent('SBQQ__Product__r', fakeProduct)
                .setParent('SBQQ__Contract__r', fakeContract)
                .toSobject(),
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.Id, subscriptionId2)
                .setField(SBQQ__Subscription__c.SBQQ__Account__c, parentAccountId)
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
                .setField(SBQQ__Subscription__c.SBQQ__Product__c, productId)
                .setField(SBQQ__Subscription__c.Integration_Source__c, SSMO_CREATION_SOURCE)
                .setParent('SBQQ__Product__r', fakeProduct)
                .setParent('SBQQ__Contract__r', fakeContract)
                .toSobject()
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountSelectorMocks = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        ISubscriptionsService subscriptionServiceMock = (ISubscriptionsService) mocks.mock(
            ISubscriptionsService.class
        );

        mocks.startStubbing();
        mocks.when(accountSelectorMocks.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountSelectorMocks.selectAccountsByMxOnboardingLinkIds(new Set<String>{}))
            .thenReturn(new List<Account>{});
        mocks.when(
                accountSelectorMocks.selectByUniqueIdentifiers(
                    new Set<Id>{ parentAccountId },
                    new Set<String>{ UNIQUE_IDENTIFIER }
                )
            )
            .thenReturn(new List<Account>{ fakeStoreAccount });
        mocks.when(
                subscriptionServiceMock.getSubscriptionsAndRelatedInformation(
                    new Set<Id>{ subscriptionId1, subscriptionId2 }
                )
            )
            .thenReturn(mockSubscription);
        mocks.when(subscriptionServiceMock.getExistingSubscriptionsForContracts(new Set<Id>{}))
            .thenReturn(new Map<Id, Set<String>>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(accountSelectorMocks);
        Application.SERVICE.setMock(ISubscriptionsService.class, subscriptionServiceMock);
        Test.startTest();
        WorkOrdersGeneratorService.execute(mockOnboardingEvents);
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test when Onboarding Events Platform Event is fired for Net New Mx Onboarding
     * then create Interface Transaction.
     */
    @isTest
    private static void testWhenOnboardingEventsFiredForNetNewOnboardingThenCreateInterfaceTransaction() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id mxOnboardingLinkId = fflib_IDGenerator.generate(Mx_Onboarding_Link__c.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id quoteId = fflib_IDGenerator.generate(SBQQ__Quote__c.SobjectType);
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        List<Onboarding_Activation__e> mockOnboardingEvents = new List<Onboarding_Activation__e>{
            new Onboarding_Activation__e(
                Payload__c = JSON.serialize(new Set<Id>{ String.valueOf(mxOnboardingLinkId) }),
                Topic__c = EVENT_TOPIC_WORK_ORDER_GENERATION
            )
        };
        Fake orderInstance = new Fake(Order.class)
            .setField(Order.Id, fflib_IDGenerator.generate(Order.SObjectType))
            .setField(Order.AccountId, accountId)
            .setField(Order.OpportunityId, fflib_IDGenerator.generate(Opportunity.SObjectType));
        Fake contractInstance = new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.Status, ACTIVATED_CONTRACT_STATUS)
            .setField(Contract.SBQQ__Quote__c, quoteId)
            .setField(Contract.AccountId, accountId)
            .setParent('SBQQ__Order__r', orderInstance);
        Mx_Onboarding_Link__c mxOnboardingLinkFake = (Mx_Onboarding_Link__c) new Fake(
                Mx_Onboarding_Link__c.class
            )
            .setField(Mx_Onboarding_Link__c.Id, mxOnboardingLinkId)
            .setField(
                Mx_Onboarding_Link__c.Onboarding_Scenario__c,
                ONBOARDING_SCENARIO_NET_NEW_MX_ONBOARDING
            )
            .setField(Mx_Onboarding_Link__c.Contract__c, contractId)
            .setField(Mx_Onboarding_Link__c.Opportunity__c, opportunityId)
            .setField(Mx_Onboarding_Link__c.UUID__c, UNIQUE_IDENTIFIER)
            .setParent('Contract__r', contractInstance)
            .setChildren(
                'Business_Onboarding_Details__r',
                new List<Fake>{
                    new Fake(Business_Onboarding_Detail__c.class)
                        .setField(
                            Business_Onboarding_Detail__c.Id,
                            fflib_IDGenerator.generate(Business_Onboarding_Detail__c.SObjectType)
                        )
                        .setField(
                            Business_Onboarding_Detail__c.Activated_Centrally_AC__c,
                            ACTIVATED_CENTRALLY_YES
                        )
                        .setField(
                            Business_Onboarding_Detail__c.Mx_Requested_Photoshoot__c,
                            PHOTOSHOOT_REQUEST_YES
                        )
                        .setField(
                            Business_Onboarding_Detail__c.Order_Protocol__c,
                            EMAIL_ORDER_PROTOCOL
                        )
                        .setField(Business_Onboarding_Detail__c.Photoshoot_Date__c, DATE_TODAY)
                        .setField(
                            Business_Onboarding_Detail__c.Photoshoot_Time__c,
                            Time.newInstance(18, 30, 2, 20)
                        )
                        .setField(
                            Business_Onboarding_Detail__c.Proposed_Date_of_Activation__c,
                            DATE_TODAY
                        )
                }
            )
            .setChildren(
                'Store_Details__r',
                new List<Fake>{
                    new Fake(Store_Detail__c.class)
                        .setField(
                            Store_Detail__c.Id,
                            fflib_IDGenerator.generate(Business_Onboarding_Detail__c.SObjectType)
                        )
                        .setField(Store_Detail__c.Menu_Setup_Method__c, MENU_SET_UP_METHOD)
                        .setField(
                            Store_Detail__c.Menu_to_be_Completed_By__c,
                            MENU_TO_BE_COMPLETED_BY_DOORDASH
                        )
                }
            )
            .toSobject();
        WorkOrder fakeWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, fflib_IDGenerator.generate(WorkOrder.SObjectType))
            .setField(WorkOrder.AccountId, accountId)
            .setField(WorkOrder.Opportunity__c, opportunityId)
            .setField(WorkOrder.Contract__c, contractId)
            .setField(WorkOrder.Mx_Onboarding_Link__c, mxOnboardingLinkId)
            .toSobject();
        WorkOrder workOrderFake = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, fflib_IDGenerator.generate(WorkOrder.SObjectType))
            .setField(WorkOrder.AccountId, accountId)
            .setField(WorkOrder.Opportunity__c, opportunityId)
            .setField(WorkOrder.Contract__c, contractId)
            .toSobject();
        Map<Id, Set<String>> contractIdToSubscriptionsPresent = new Map<Id, Set<String>>{
            contractId => new Set<String>{ MARKETPLACE_TYPE }
        };
        Set<String> contractIdToWorkOrderToBeCreated = new Set<String>{
            contractId +
            SEPARATOR +
            MARKETPLACE_TYPE
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IMxOnboardingLinksSelector mxOnboardingLinksSelectorMock = (IMxOnboardingLinksSelector) mocks.mock(
            IMxOnboardingLinksSelector.class
        );
        IContractsSelector contractsSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        ISubscriptionsService subscriptionServiceMock = (ISubscriptionsService) mocks.mock(
            ISubscriptionsService.class
        );
        IContractsService contractsServiceMock = (IContractsService) mocks.mock(
            IContractsService.class
        );
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mxOnboardingLinksSelectorMock.sObjectType())
            .thenReturn(Mx_Onboarding_Link__c.SObjectType);
        mocks.when(contractsSelectorMock.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                accountSelectorMock.selectAccountsByMxOnboardingLinkIds(
                    new Set<String>{ UNIQUE_IDENTIFIER }
                )
            )
            .thenReturn(new List<Account>{});
        mocks.when(accountSelectorMock.selectByUniqueIdentifiers(new Set<Id>{}, new Set<String>()))
            .thenReturn(new List<Account>{});
        mocks.when(
                mxOnboardingLinksSelectorMock.selectByMxOnboardingLinkIds(
                    new Set<Id>{ mxOnboardingLinkId }
                )
            )
            .thenReturn(new List<Mx_Onboarding_Link__c>{ mxOnboardingLinkFake });
        mocks.when(subscriptionServiceMock.getSubscriptionsAndRelatedInformation(new Set<Id>{}))
            .thenReturn(new List<SBQQ__Subscription__c>());
        mocks.when(
                subscriptionServiceMock.getExistingSubscriptionsForContracts(
                    new Set<Id>{ contractId }
                )
            )
            .thenReturn(contractIdToSubscriptionsPresent);
        mocks.when(
                contractsServiceMock.getEligibleContractsForOnboardingInputsWorkOrderCreation(
                    new List<Mx_Onboarding_Link__c>{ mxOnboardingLinkFake },
                    contractIdToSubscriptionsPresent
                )
            )
            .thenReturn(contractIdToWorkOrderToBeCreated);
        mocks.when(
                contractsSelectorMock.selectAdsAndPromosContractsByAccountIds(
                    new Set<Id>{ accountId }
                )
            )
            .thenReturn(new List<Contract>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(mxOnboardingLinksSelectorMock);
        Application.SELECTOR.setMock(contractsSelectorMock);
        Application.SERVICE.setMock(ISubscriptionsService.class, subscriptionServiceMock);
        Application.SERVICE.setMock(IContractsService.class, contractsServiceMock);
        Test.startTest();
        WorkOrdersGeneratorService.execute(mockOnboardingEvents);
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        System.assertEquals(
            mxOnboardingLinkFake.Opportunity__c,
            fakeWorkOrder.Opportunity__c,
            ASSERT_MESSAGE_OPPORTUNITY_NOT_MATCHING
        );
        System.assertEquals(
            mxOnboardingLinkFake.Id,
            fakeWorkOrder.Mx_Onboarding_Link__c,
            ASSERT_MESSAGE_MX_ONBOARDING_LINK_NOT_MATCHING
        );
        System.assertEquals(
            null,
            workOrderFake.Mx_Onboarding_Link__c,
            ASSERT_MESSAGE_MX_ONBOARDING_LINK_NOT_MATCHING
        );
    }

    /**
     * @description To test when Onboarding Events Platform Event is fired for New Store Expansion
     * then create Interface Transaction.
     */
    @isTest
    private static void testWhenOnboardingEventsFiredForNewStoreExpansionThenCreateInterfaceTransaction() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id mxOnboardingLinkId = fflib_IDGenerator.generate(Mx_Onboarding_Link__c.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id quoteId = fflib_IDGenerator.generate(SBQQ__Quote__c.SobjectType);
        List<Onboarding_Activation__e> mockOnboardingEvents = new List<Onboarding_Activation__e>{
            new Onboarding_Activation__e(
                Payload__c = JSON.serialize(new Set<Id>{ String.valueOf(mxOnboardingLinkId) }),
                Topic__c = EVENT_TOPIC_WORK_ORDER_GENERATION
            )
        };
        Map<Id, Set<String>> contractIdToSubscriptionsPresent = new Map<Id, Set<String>>{
            contractId => new Set<String>{ MARKETPLACE_TYPE }
        };
        Set<String> contractIdToWorkOrderToBeCreated = new Set<String>{
            contractId +
            SEPARATOR +
            MARKETPLACE_TYPE
        };
        Fake orderInstance = new Fake(Order.class)
            .setField(Order.Id, fflib_IDGenerator.generate(Order.SObjectType))
            .setField(Order.AccountId, accountId)
            .setField(Order.OpportunityId, fflib_IDGenerator.generate(Opportunity.SObjectType));
        Fake contractInstance = new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.Status, ACTIVATED_CONTRACT_STATUS)
            .setField(Contract.SBQQ__Quote__c, quoteId)
            .setField(Contract.AccountId, accountId)
            .setParent('SBQQ__Order__r', orderInstance);
        Mx_Onboarding_Link__c mxOnboardingLinkFake = (Mx_Onboarding_Link__c) new Fake(
                Mx_Onboarding_Link__c.class
            )
            .setField(Mx_Onboarding_Link__c.Id, mxOnboardingLinkId)
            .setField(
                Mx_Onboarding_Link__c.Onboarding_Scenario__c,
                ONBOARDING_SCENARIO_NEW_STORE_EXPANSION
            )
            .setField(Mx_Onboarding_Link__c.Contract__c, contractId)
            .setField(Mx_Onboarding_Link__c.UUID__c, UNIQUE_IDENTIFIER)
            .setParent('Contract__r', contractInstance)
            .setChildren(
                'Business_Onboarding_Details__r',
                new List<Fake>{
                    new Fake(Business_Onboarding_Detail__c.class)
                        .setField(
                            Business_Onboarding_Detail__c.Id,
                            fflib_IDGenerator.generate(Business_Onboarding_Detail__c.SObjectType)
                        )
                        .setField(
                            Business_Onboarding_Detail__c.Activated_Centrally_AC__c,
                            ACTIVATED_CENTRALLY_YES
                        )
                        .setField(
                            Business_Onboarding_Detail__c.Mx_Requested_Photoshoot__c,
                            PHOTOSHOOT_REQUEST_YES
                        )
                        .setField(
                            Business_Onboarding_Detail__c.Order_Protocol__c,
                            EMAIL_ORDER_PROTOCOL
                        )
                        .setField(Business_Onboarding_Detail__c.Photoshoot_Date__c, DATE_TODAY)
                        .setField(
                            Business_Onboarding_Detail__c.Photoshoot_Time__c,
                            Time.newInstance(18, 30, 2, 20)
                        )
                        .setField(
                            Business_Onboarding_Detail__c.Proposed_Date_of_Activation__c,
                            DATE_TODAY
                        )
                }
            )
            .setChildren(
                'Store_Details__r',
                new List<Fake>{
                    new Fake(Store_Detail__c.class)
                        .setField(
                            Store_Detail__c.Id,
                            fflib_IDGenerator.generate(Business_Onboarding_Detail__c.SObjectType)
                        )
                        .setField(Store_Detail__c.Menu_Setup_Method__c, MENU_SET_UP_METHOD)
                        .setField(
                            Store_Detail__c.Menu_to_be_Completed_By__c,
                            MENU_TO_BE_COMPLETED_BY_DOORDASH
                        )
                }
            )
            .toSobject();
        Opportunity opportunityFake = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, fflib_IDGenerator.generate(Opportunity.SObjectType))
            .setField(Opportunity.AccountId, accountId)
            .setField(Opportunity.Name, 'Test Opp 1')
            .toSobject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IMxOnboardingLinksSelector mxOnboardingLinksSelectorMock = (IMxOnboardingLinksSelector) mocks.mock(
            IMxOnboardingLinksSelector.class
        );
        IOpportunitiesSelector opportunitiesSelectorMock = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );
        IContractsSelector contractsSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        ISubscriptionsService subscriptionServiceMock = (ISubscriptionsService) mocks.mock(
            ISubscriptionsService.class
        );
        IContractsService contractsServiceMock = (IContractsService) mocks.mock(
            IContractsService.class
        );
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mxOnboardingLinksSelectorMock.sObjectType())
            .thenReturn(Mx_Onboarding_Link__c.SObjectType);
        mocks.when(opportunitiesSelectorMock.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                accountSelectorMock.selectAccountsByMxOnboardingLinkIds(
                    new Set<String>{ UNIQUE_IDENTIFIER }
                )
            )
            .thenReturn(new List<Account>{});
        mocks.when(accountSelectorMock.selectByUniqueIdentifiers(new Set<Id>{}, new Set<String>()))
            .thenReturn(new List<Account>{});
        mocks.when(contractsSelectorMock.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(
                mxOnboardingLinksSelectorMock.selectByMxOnboardingLinkIds(
                    new Set<Id>{ mxOnboardingLinkId }
                )
            )
            .thenReturn(new List<Mx_Onboarding_Link__c>{ mxOnboardingLinkFake });
        mocks.when(subscriptionServiceMock.getSubscriptionsAndRelatedInformation(new Set<Id>{}))
            .thenReturn(new List<SBQQ__Subscription__c>());
        mocks.when(
                opportunitiesSelectorMock.selectNewStoreExpansionOpportunitiesByAccountIds(
                    new Set<Id>{ accountId }
                )
            )
            .thenReturn(new List<Opportunity>{ opportunityFake });
        mocks.when(
                subscriptionServiceMock.getExistingSubscriptionsForContracts(
                    new Set<Id>{ contractId }
                )
            )
            .thenReturn(contractIdToSubscriptionsPresent);
        mocks.when(
                contractsServiceMock.getEligibleContractsForOnboardingInputsWorkOrderCreation(
                    new List<Mx_Onboarding_Link__c>{ mxOnboardingLinkFake },
                    contractIdToSubscriptionsPresent
                )
            )
            .thenReturn(contractIdToWorkOrderToBeCreated);
        mocks.when(
                contractsSelectorMock.selectAdsAndPromosContractsByAccountIds(
                    new Set<Id>{ accountId }
                )
            )
            .thenReturn(new List<Contract>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(mxOnboardingLinksSelectorMock);
        Application.SELECTOR.setMock(opportunitiesSelectorMock);
        Application.SELECTOR.setMock(contractsSelectorMock);
        Application.SERVICE.setMock(ISubscriptionsService.class, subscriptionServiceMock);
        Application.SERVICE.setMock(IContractsService.class, contractsServiceMock);
        Test.startTest();
        WorkOrdersGeneratorService.execute(mockOnboardingEvents);
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test when Onboarding Events are fired for Net New Mx Onboarding then create
     * Interface Transaction for Drive Work Order.
     */
    @isTest
    private static void testWhenOnboardingEventsFiredForNetNewMxOnboardingThenCreateInterfaceTransactionDriveWorkOrder() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id mxOnboardingLinkId = fflib_IDGenerator.generate(Mx_Onboarding_Link__c.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id quoteId = fflib_IDGenerator.generate(SBQQ__Quote__c.SobjectType);
        List<Onboarding_Activation__e> mockOnboardingEvents = new List<Onboarding_Activation__e>{
            new Onboarding_Activation__e(
                Payload__c = JSON.serialize(new Set<Id>{ String.valueOf(mxOnboardingLinkId) }),
                Topic__c = EVENT_TOPIC_WORK_ORDER_GENERATION
            )
        };
        Map<Id, Set<String>> contractIdToSubscriptionsPresent = new Map<Id, Set<String>>{
            contractId => new Set<String>{ WORK_ORDER_TYPE_DRIVE }
        };
        Set<String> contractIdToWorkOrderToBeCreated = new Set<String>{
            contractId +
            SEPARATOR +
            WORK_ORDER_TYPE_DRIVE
        };
        Fake orderInstance = new Fake(Order.class)
            .setField(Order.Id, fflib_IDGenerator.generate(Order.SObjectType))
            .setField(Order.AccountId, accountId)
            .setField(Order.OpportunityId, fflib_IDGenerator.generate(Opportunity.SObjectType));
        Fake contractInstance = new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.Status, ACTIVATED_CONTRACT_STATUS)
            .setField(Contract.SBQQ__Quote__c, quoteId)
            .setField(Contract.AccountId, accountId)
            .setParent('SBQQ__Order__r', orderInstance);
        Mx_Onboarding_Link__c mxOnboardingLinkFake = (Mx_Onboarding_Link__c) new Fake(
                Mx_Onboarding_Link__c.class
            )
            .setField(Mx_Onboarding_Link__c.Id, mxOnboardingLinkId)
            .setField(
                Mx_Onboarding_Link__c.Onboarding_Scenario__c,
                ONBOARDING_SCENARIO_NET_NEW_MX_ONBOARDING
            )
            .setField(Mx_Onboarding_Link__c.Contract__c, contractId)
            .setField(Mx_Onboarding_Link__c.UUID__c, UNIQUE_IDENTIFIER)
            .setParent('Contract__r', contractInstance)
            .setChildren(
                'Business_Onboarding_Details__r',
                new List<Fake>{
                    new Fake(Business_Onboarding_Detail__c.class)
                        .setField(
                            Business_Onboarding_Detail__c.Id,
                            fflib_IDGenerator.generate(Business_Onboarding_Detail__c.SObjectType)
                        )
                        .setField(
                            Business_Onboarding_Detail__c.Activated_Centrally_AC__c,
                            ACTIVATED_CENTRALLY_YES
                        )
                        .setField(
                            Business_Onboarding_Detail__c.Mx_Requested_Photoshoot__c,
                            PHOTOSHOOT_REQUEST_YES
                        )
                        .setField(
                            Business_Onboarding_Detail__c.Order_Protocol__c,
                            EMAIL_ORDER_PROTOCOL
                        )
                        .setField(Business_Onboarding_Detail__c.Photoshoot_Date__c, DATE_TODAY)
                        .setField(
                            Business_Onboarding_Detail__c.Photoshoot_Time__c,
                            Time.newInstance(18, 30, 2, 20)
                        )
                        .setField(
                            Business_Onboarding_Detail__c.Proposed_Date_of_Activation__c,
                            DATE_TODAY
                        )
                }
            )
            .setChildren(
                'Store_Details__r',
                new List<Fake>{
                    new Fake(Store_Detail__c.class)
                        .setField(
                            Store_Detail__c.Id,
                            fflib_IDGenerator.generate(Business_Onboarding_Detail__c.SObjectType)
                        )
                        .setField(Store_Detail__c.Menu_Setup_Method__c, MENU_SET_UP_METHOD)
                        .setField(
                            Store_Detail__c.Menu_to_be_Completed_By__c,
                            MENU_TO_BE_COMPLETED_BY_DOORDASH
                        )
                }
            )
            .toSobject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IMxOnboardingLinksSelector mxOnboardingLinksSelectorMock = (IMxOnboardingLinksSelector) mocks.mock(
            IMxOnboardingLinksSelector.class
        );
        ISubscriptionsService subscriptionServiceMock = (ISubscriptionsService) mocks.mock(
            ISubscriptionsService.class
        );
        IContractsSelector contractsSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        IContractsService contractsServiceMock = (IContractsService) mocks.mock(
            IContractsService.class
        );
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mxOnboardingLinksSelectorMock.sObjectType())
            .thenReturn(Mx_Onboarding_Link__c.SObjectType);
        mocks.when(contractsSelectorMock.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                accountSelectorMock.selectAccountsByMxOnboardingLinkIds(
                    new Set<String>{ UNIQUE_IDENTIFIER }
                )
            )
            .thenReturn(new List<Account>{});
        mocks.when(accountSelectorMock.selectByUniqueIdentifiers(new Set<Id>{}, new Set<String>()))
            .thenReturn(new List<Account>{});
        mocks.when(
                mxOnboardingLinksSelectorMock.selectByMxOnboardingLinkIds(
                    new Set<Id>{ mxOnboardingLinkId }
                )
            )
            .thenReturn(new List<Mx_Onboarding_Link__c>{ mxOnboardingLinkFake });
        mocks.when(subscriptionServiceMock.getSubscriptionsAndRelatedInformation(new Set<Id>{}))
            .thenReturn(new List<SBQQ__Subscription__c>());
        mocks.when(
                subscriptionServiceMock.getExistingSubscriptionsForContracts(
                    new Set<Id>{ contractId }
                )
            )
            .thenReturn(contractIdToSubscriptionsPresent);
        mocks.when(
                contractsServiceMock.getEligibleContractsForOnboardingInputsWorkOrderCreation(
                    new List<Mx_Onboarding_Link__c>{ mxOnboardingLinkFake },
                    contractIdToSubscriptionsPresent
                )
            )
            .thenReturn(contractIdToWorkOrderToBeCreated);
        mocks.when(
                contractsSelectorMock.selectAdsAndPromosContractsByAccountIds(
                    new Set<Id>{ accountId }
                )
            )
            .thenReturn(new List<Contract>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(mxOnboardingLinksSelectorMock);
        Application.SELECTOR.setMock(contractsSelectorMock);
        Application.SERVICE.setMock(ISubscriptionsService.class, subscriptionServiceMock);
        Application.SERVICE.setMock(IContractsService.class, contractsServiceMock);
        Test.startTest();
        WorkOrdersGeneratorService.execute(mockOnboardingEvents);
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test when Onboarding Events are fired for Net New Mx Onboarding then create
     * Interface Transaction for Ads and Promos Work Order.
     */
    @isTest
    private static void testWhenOnboardingEventsFiredForNetNewMxOnboardingThenCreateInterfaceTransactionForAdsAndPromosWorkOrder() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id mxOnboardingLinkId = fflib_IDGenerator.generate(Mx_Onboarding_Link__c.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id quoteId = fflib_IDGenerator.generate(SBQQ__Quote__c.SobjectType);
        List<Onboarding_Activation__e> mockOnboardingEvents = new List<Onboarding_Activation__e>{
            new Onboarding_Activation__e(
                Payload__c = JSON.serialize(new Set<Id>{ String.valueOf(mxOnboardingLinkId) }),
                Topic__c = EVENT_TOPIC_WORK_ORDER_GENERATION
            )
        };
        Map<Id, Set<String>> contractIdToSubscriptionsPresent = new Map<Id, Set<String>>();
        Fake orderInstance = new Fake(Order.class)
            .setField(Order.Id, fflib_IDGenerator.generate(Order.SObjectType))
            .setField(Order.AccountId, accountId)
            .setField(Order.OpportunityId, fflib_IDGenerator.generate(Opportunity.SObjectType));
        Fake contractInstance = new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.Status, ACTIVATED_CONTRACT_STATUS)
            .setField(Contract.SBQQ__Quote__c, quoteId)
            .setField(Contract.AccountId, accountId)
            .setParent('SBQQ__Order__r', orderInstance);
        Contract fakeAdsAndPromosContract = (Contract) new Fake(Contract.class)
            .setField(Contract.Id, fflib_IDGenerator.generate(Contract.SObjectType))
            .setField(Contract.Status, ACTIVATED_CONTRACT_STATUS)
            .setField(Contract.SBQQ__Quote__c, quoteId)
            .setField(Contract.AccountId, accountId)
            .setField(
                Contract.SBQQ__Opportunity__c,
                fflib_IDGenerator.generate(Opportunity.SObjectType)
            )
            .toSobject();
        Mx_Onboarding_Link__c mxOnboardingLinkFake = (Mx_Onboarding_Link__c) new Fake(
                Mx_Onboarding_Link__c.class
            )
            .setField(Mx_Onboarding_Link__c.Id, mxOnboardingLinkId)
            .setField(
                Mx_Onboarding_Link__c.Onboarding_Scenario__c,
                ONBOARDING_SCENARIO_NET_NEW_MX_ONBOARDING
            )
            .setField(Mx_Onboarding_Link__c.Contract__c, contractId)
            .setField(Mx_Onboarding_Link__c.UUID__c, UNIQUE_IDENTIFIER)
            .setParent('Contract__r', contractInstance)
            .setChildren(
                'Business_Onboarding_Details__r',
                new List<Fake>{
                    new Fake(Business_Onboarding_Detail__c.class)
                        .setField(
                            Business_Onboarding_Detail__c.Id,
                            fflib_IDGenerator.generate(Business_Onboarding_Detail__c.SObjectType)
                        )
                        .setField(
                            Business_Onboarding_Detail__c.Activated_Centrally_AC__c,
                            ACTIVATED_CENTRALLY_YES
                        )
                        .setField(
                            Business_Onboarding_Detail__c.Mx_Requested_Photoshoot__c,
                            PHOTOSHOOT_REQUEST_YES
                        )
                        .setField(
                            Business_Onboarding_Detail__c.Order_Protocol__c,
                            EMAIL_ORDER_PROTOCOL
                        )
                        .setField(Business_Onboarding_Detail__c.Photoshoot_Date__c, DATE_TODAY)
                        .setField(
                            Business_Onboarding_Detail__c.Photoshoot_Time__c,
                            Time.newInstance(18, 30, 2, 20)
                        )
                        .setField(
                            Business_Onboarding_Detail__c.Proposed_Date_of_Activation__c,
                            DATE_TODAY
                        )
                }
            )
            .setChildren(
                'Store_Details__r',
                new List<Fake>{
                    new Fake(Store_Detail__c.class)
                        .setField(
                            Store_Detail__c.Id,
                            fflib_IDGenerator.generate(Business_Onboarding_Detail__c.SObjectType)
                        )
                        .setField(Store_Detail__c.Menu_Setup_Method__c, MENU_SET_UP_METHOD)
                        .setField(
                            Store_Detail__c.Menu_to_be_Completed_By__c,
                            MENU_TO_BE_COMPLETED_BY_DOORDASH
                        )
                }
            )
            .toSobject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IMxOnboardingLinksSelector mxOnboardingLinksSelectorMock = (IMxOnboardingLinksSelector) mocks.mock(
            IMxOnboardingLinksSelector.class
        );
        ISubscriptionsService subscriptionServiceMock = (ISubscriptionsService) mocks.mock(
            ISubscriptionsService.class
        );
        IContractsSelector contractsSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        IContractsService contractsServiceMock = (IContractsService) mocks.mock(
            IContractsService.class
        );
        mocks.startStubbing();
        mocks.when(mxOnboardingLinksSelectorMock.sObjectType())
            .thenReturn(Mx_Onboarding_Link__c.SObjectType);
        mocks.when(contractsSelectorMock.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                accountSelectorMock.selectAccountsByMxOnboardingLinkIds(
                    new Set<String>{ UNIQUE_IDENTIFIER }
                )
            )
            .thenReturn(new List<Account>{});
        mocks.when(accountSelectorMock.selectByUniqueIdentifiers(new Set<Id>{}, new Set<String>()))
            .thenReturn(new List<Account>{});
        mocks.when(
                mxOnboardingLinksSelectorMock.selectByMxOnboardingLinkIds(
                    new Set<Id>{ mxOnboardingLinkId }
                )
            )
            .thenReturn(new List<Mx_Onboarding_Link__c>{ mxOnboardingLinkFake });
        mocks.when(subscriptionServiceMock.getSubscriptionsAndRelatedInformation(new Set<Id>{}))
            .thenReturn(new List<SBQQ__Subscription__c>());
        mocks.when(
                subscriptionServiceMock.getExistingSubscriptionsForContracts(
                    new Set<Id>{ contractId }
                )
            )
            .thenReturn(contractIdToSubscriptionsPresent);
        mocks.when(
                contractsServiceMock.getEligibleContractsForOnboardingInputsWorkOrderCreation(
                    new List<Mx_Onboarding_Link__c>{ mxOnboardingLinkFake },
                    contractIdToSubscriptionsPresent
                )
            )
            .thenReturn(new Set<String>{});
        mocks.when(
                contractsSelectorMock.selectAdsAndPromosContractsByAccountIds(
                    new Set<Id>{ accountId }
                )
            )
            .thenReturn(new List<Contract>{ fakeAdsAndPromosContract });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(mxOnboardingLinksSelectorMock);
        Application.SELECTOR.setMock(contractsSelectorMock);
        Application.SERVICE.setMock(ISubscriptionsService.class, subscriptionServiceMock);
        Application.SERVICE.setMock(IContractsService.class, contractsServiceMock);
        Test.startTest();
        WorkOrdersGeneratorService.execute(mockOnboardingEvents);
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test when Onboarding Events are fired for New Store Expansion then create
     * Interface Transaction for Ads and Promos Work Order.
     */
    @isTest
    private static void testWhenOnboardingEventsFiredForNewStoreExpansionThenCreateInterfaceTransactionForAdsAndPromosWorkOrder() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id mxOnboardingLinkId = fflib_IDGenerator.generate(Mx_Onboarding_Link__c.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id quoteId = fflib_IDGenerator.generate(SBQQ__Quote__c.SobjectType);
        List<Onboarding_Activation__e> mockOnboardingEvents = new List<Onboarding_Activation__e>{
            new Onboarding_Activation__e(
                Payload__c = JSON.serialize(new Set<Id>{ String.valueOf(mxOnboardingLinkId) }),
                Topic__c = EVENT_TOPIC_WORK_ORDER_GENERATION
            )
        };
        Map<Id, Set<String>> contractIdToSubscriptionsPresent = new Map<Id, Set<String>>();
        Fake orderInstance = new Fake(Order.class)
            .setField(Order.Id, fflib_IDGenerator.generate(Order.SObjectType))
            .setField(Order.AccountId, accountId)
            .setField(Order.OpportunityId, fflib_IDGenerator.generate(Opportunity.SObjectType));
        Fake contractInstance = new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.Status, ACTIVATED_CONTRACT_STATUS)
            .setField(Contract.SBQQ__Quote__c, quoteId)
            .setField(Contract.AccountId, accountId)
            .setParent('SBQQ__Order__r', orderInstance);
        Contract fakeAdsAndPromosContract = (Contract) new Fake(Contract.class)
            .setField(Contract.Id, fflib_IDGenerator.generate(Contract.SObjectType))
            .setField(Contract.Status, ACTIVATED_CONTRACT_STATUS)
            .setField(Contract.SBQQ__Quote__c, quoteId)
            .setField(Contract.AccountId, accountId)
            .setField(
                Contract.SBQQ__Opportunity__c,
                fflib_IDGenerator.generate(Opportunity.SObjectType)
            )
            .toSobject();
        Mx_Onboarding_Link__c mxOnboardingLinkFake = (Mx_Onboarding_Link__c) new Fake(
                Mx_Onboarding_Link__c.class
            )
            .setField(Mx_Onboarding_Link__c.Id, mxOnboardingLinkId)
            .setField(
                Mx_Onboarding_Link__c.Onboarding_Scenario__c,
                ONBOARDING_SCENARIO_NEW_STORE_EXPANSION
            )
            .setField(Mx_Onboarding_Link__c.Contract__c, contractId)
            .setField(Mx_Onboarding_Link__c.UUID__c, UNIQUE_IDENTIFIER)
            .setParent('Contract__r', contractInstance)
            .setChildren(
                'Business_Onboarding_Details__r',
                new List<Fake>{
                    new Fake(Business_Onboarding_Detail__c.class)
                        .setField(
                            Business_Onboarding_Detail__c.Id,
                            fflib_IDGenerator.generate(Business_Onboarding_Detail__c.SObjectType)
                        )
                        .setField(
                            Business_Onboarding_Detail__c.Activated_Centrally_AC__c,
                            ACTIVATED_CENTRALLY_YES
                        )
                        .setField(
                            Business_Onboarding_Detail__c.Mx_Requested_Photoshoot__c,
                            PHOTOSHOOT_REQUEST_YES
                        )
                        .setField(
                            Business_Onboarding_Detail__c.Order_Protocol__c,
                            EMAIL_ORDER_PROTOCOL
                        )
                        .setField(Business_Onboarding_Detail__c.Photoshoot_Date__c, DATE_TODAY)
                        .setField(
                            Business_Onboarding_Detail__c.Photoshoot_Time__c,
                            Time.newInstance(18, 30, 2, 20)
                        )
                        .setField(
                            Business_Onboarding_Detail__c.Proposed_Date_of_Activation__c,
                            DATE_TODAY
                        )
                }
            )
            .setChildren(
                'Store_Details__r',
                new List<Fake>{
                    new Fake(Store_Detail__c.class)
                        .setField(
                            Store_Detail__c.Id,
                            fflib_IDGenerator.generate(Business_Onboarding_Detail__c.SObjectType)
                        )
                        .setField(Store_Detail__c.Menu_Setup_Method__c, MENU_SET_UP_METHOD)
                        .setField(
                            Store_Detail__c.Menu_to_be_Completed_By__c,
                            MENU_TO_BE_COMPLETED_BY_DOORDASH
                        )
                }
            )
            .toSobject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IMxOnboardingLinksSelector mxOnboardingLinksSelectorMock = (IMxOnboardingLinksSelector) mocks.mock(
            IMxOnboardingLinksSelector.class
        );
        ISubscriptionsService subscriptionServiceMock = (ISubscriptionsService) mocks.mock(
            ISubscriptionsService.class
        );
        IContractsSelector contractsSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        IContractsService contractsServiceMock = (IContractsService) mocks.mock(
            IContractsService.class
        );
        mocks.startStubbing();
        mocks.when(mxOnboardingLinksSelectorMock.sObjectType())
            .thenReturn(Mx_Onboarding_Link__c.SObjectType);
        mocks.when(contractsSelectorMock.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                accountSelectorMock.selectAccountsByMxOnboardingLinkIds(
                    new Set<String>{ UNIQUE_IDENTIFIER }
                )
            )
            .thenReturn(new List<Account>{});
        mocks.when(accountSelectorMock.selectByUniqueIdentifiers(new Set<Id>{}, new Set<String>()))
            .thenReturn(new List<Account>{});
        mocks.when(
                mxOnboardingLinksSelectorMock.selectByMxOnboardingLinkIds(
                    new Set<Id>{ mxOnboardingLinkId }
                )
            )
            .thenReturn(new List<Mx_Onboarding_Link__c>{ mxOnboardingLinkFake });
        mocks.when(subscriptionServiceMock.getSubscriptionsAndRelatedInformation(new Set<Id>{}))
            .thenReturn(new List<SBQQ__Subscription__c>());
        mocks.when(
                subscriptionServiceMock.getExistingSubscriptionsForContracts(
                    new Set<Id>{ contractId }
                )
            )
            .thenReturn(contractIdToSubscriptionsPresent);
        mocks.when(
                contractsServiceMock.getEligibleContractsForOnboardingInputsWorkOrderCreation(
                    new List<Mx_Onboarding_Link__c>{ mxOnboardingLinkFake },
                    contractIdToSubscriptionsPresent
                )
            )
            .thenReturn(new Set<String>{});
        mocks.when(
                contractsSelectorMock.selectAdsAndPromosContractsByAccountIds(
                    new Set<Id>{ accountId }
                )
            )
            .thenReturn(new List<Contract>{ fakeAdsAndPromosContract });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(mxOnboardingLinksSelectorMock);
        Application.SELECTOR.setMock(contractsSelectorMock);
        Application.SERVICE.setMock(ISubscriptionsService.class, subscriptionServiceMock);
        Application.SERVICE.setMock(IContractsService.class, contractsServiceMock);
        Test.startTest();
        WorkOrdersGeneratorService.execute(mockOnboardingEvents);
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test creation of Interface Transaction when Onboaording Activations
     * Platform Events are fired for Mx Portal Store Addition.
     */
    @isTest
    private static void testWhenOnboardingEventsFiredForMxPortalStoreAdditionThenCreateInterfaceTransaction() {
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id accountId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Map<Id, Set<String>> contractIdToSubscriptionsPresent = new Map<Id, Set<String>>{
            contractId => new Set<String>{ MARKETPLACE_TYPE }
        };
        List<Onboarding_Activation__e> mockOnboardingEvents = new List<Onboarding_Activation__e>{
            new Onboarding_Activation__e(
                Payload__c = JSON.serialize(new Set<Id>{ String.valueOf(opportunityId) }),
                Topic__c = EVENT_TOPIC_WORK_ORDER_GENERATION
            )
        };
        Account fakeStoreAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, fflib_IDGenerator.generate(Account.SobjectType))
            .setField(Account.Segment__c, SMB_SEGMENT_TYPE)
            .setField(Account.Unique_Identifier__c, UNIQUE_IDENTIFIER)
            .setField(Account.ParentId, accountId)
            .setField(Account.Order_Protocol__c, POS_ORDER_PROTOCOL)
            .toSobject();
        Opportunity fakeOpportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityId)
            .setField(Opportunity.AccountId, accountId)
            .setField(Opportunity.ContractId, contractId)
            .setField(Opportunity.Unique_Identifier__c, UNIQUE_IDENTIFIER)
            .toSobject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAccountsSelector accountSelectorMocks = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IOpportunitiesSelector opportunitiesSelectorMock = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );
        ISubscriptionsService subscriptionServiceMock = (ISubscriptionsService) mocks.mock(
            ISubscriptionsService.class
        );
        mocks.startStubbing();
        mocks.when(accountSelectorMocks.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(opportunitiesSelectorMock.SObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(opportunitiesSelectorMock.selectById(new Set<Id>{ opportunityId }))
            .thenReturn(new List<Opportunity>{ fakeOpportunity });
        mocks.when(accountSelectorMocks.selectAccountsByMxOnboardingLinkIds(new Set<String>{}))
            .thenReturn(new List<Account>{});
        mocks.when(
                accountSelectorMocks.selectByUniqueIdentifiers(
                    new Set<Id>{ accountId },
                    new Set<String>{ UNIQUE_IDENTIFIER }
                )
            )
            .thenReturn(new List<Account>{ fakeStoreAccount });
        mocks.when(accountSelectorMocks.selectByUniqueIdentifiers(new Set<Id>{}, new Set<String>{}))
            .thenReturn(new List<Account>{});
        mocks.when(
                subscriptionServiceMock.getExistingSubscriptionsForContracts(
                    new Set<Id>{ contractId }
                )
            )
            .thenReturn(contractIdToSubscriptionsPresent);
        mocks.when(subscriptionServiceMock.getSubscriptionsAndRelatedInformation(new Set<Id>{}))
            .thenReturn(new List<SBQQ__Subscription__c>{});
        mocks.when(subscriptionServiceMock.getExistingSubscriptionsForContracts(new Set<Id>{}))
            .thenReturn(new Map<Id, Set<String>>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(opportunitiesSelectorMock);
        Application.SELECTOR.setMock(accountSelectorMocks);
        Application.SERVICE.setMock(ISubscriptionsService.class, subscriptionServiceMock);
        Test.startTest();
        WorkOrdersGeneratorService.execute(mockOnboardingEvents);
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test when Onboarding Events are fired for Product Addition then create Interface Transaction
     * for Storefront Work Order.
     */
    @isTest
    private static void testWhenOnboardingEventsFiredForProductAdditionThenCreateInterfaceTransactionForStorefront() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id mxOnboardingLinkId = fflib_IDGenerator.generate(Mx_Onboarding_Link__c.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id quoteId = fflib_IDGenerator.generate(SBQQ__Quote__c.SobjectType);
        List<Onboarding_Activation__e> mockOnboardingEvents = new List<Onboarding_Activation__e>{
            new Onboarding_Activation__e(
                Payload__c = JSON.serialize(new Set<Id>{ String.valueOf(mxOnboardingLinkId) }),
                Topic__c = EVENT_TOPIC_WORK_ORDER_GENERATION
            )
        };
        Fake orderInstance = new Fake(Order.class)
            .setField(Order.Id, fflib_IDGenerator.generate(Order.SObjectType))
            .setField(Order.AccountId, accountId)
            .setField(Order.OpportunityId, fflib_IDGenerator.generate(Opportunity.SObjectType));
        Fake contractInstance = new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.Status, ACTIVATED_CONTRACT_STATUS)
            .setField(Contract.SBQQ__Quote__c, quoteId)
            .setField(Contract.AccountId, accountId)
            .setParent('SBQQ__Order__r', orderInstance);
        Mx_Onboarding_Link__c mxOnboardingLinkFake = (Mx_Onboarding_Link__c) new Fake(
                Mx_Onboarding_Link__c.class
            )
            .setField(Mx_Onboarding_Link__c.Id, mxOnboardingLinkId)
            .setField(
                Mx_Onboarding_Link__c.Onboarding_Scenario__c,
                ONBOARDING_SCENARIO_PRODUCT_ADDITION
            )
            .setField(Mx_Onboarding_Link__c.Contract__c, contractId)
            .setField(Mx_Onboarding_Link__c.UUID__c, UNIQUE_IDENTIFIER)
            .setParent('Contract__r', contractInstance)
            .setChildren(
                'Business_Onboarding_Details__r',
                new List<Fake>{
                    new Fake(Business_Onboarding_Detail__c.class)
                        .setField(
                            Business_Onboarding_Detail__c.Id,
                            fflib_IDGenerator.generate(Business_Onboarding_Detail__c.SObjectType)
                        )
                        .setField(
                            Business_Onboarding_Detail__c.Activated_Centrally_AC__c,
                            ACTIVATED_CENTRALLY_YES
                        )
                        .setField(
                            Business_Onboarding_Detail__c.Mx_Requested_Photoshoot__c,
                            PHOTOSHOOT_REQUEST_YES
                        )
                        .setField(
                            Business_Onboarding_Detail__c.Order_Protocol__c,
                            EMAIL_ORDER_PROTOCOL
                        )
                        .setField(Business_Onboarding_Detail__c.Photoshoot_Date__c, DATE_TODAY)
                        .setField(
                            Business_Onboarding_Detail__c.Photoshoot_Time__c,
                            Time.newInstance(18, 30, 2, 20)
                        )
                        .setField(
                            Business_Onboarding_Detail__c.Proposed_Date_of_Activation__c,
                            DATE_TODAY
                        )
                }
            )
            .setChildren(
                'Store_Details__r',
                new List<Fake>{
                    new Fake(Store_Detail__c.class)
                        .setField(
                            Store_Detail__c.Id,
                            fflib_IDGenerator.generate(Business_Onboarding_Detail__c.SObjectType)
                        )
                        .setField(Store_Detail__c.Menu_Setup_Method__c, MENU_SET_UP_METHOD)
                        .setField(
                            Store_Detail__c.Menu_to_be_Completed_By__c,
                            MENU_TO_BE_COMPLETED_BY_DOORDASH
                        )
                }
            )
            .toSobject();
        Map<Id, Set<String>> contractIdToSubscriptionsPresent = new Map<Id, Set<String>>{
            contractId => new Set<String>{ STOREFRONT_TYPE }
        };
        Set<String> contractIdToWorkOrderToBeCreated = new Set<String>{
            contractId +
            SEPARATOR +
            STOREFRONT_TYPE
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IMxOnboardingLinksSelector mxOnboardingLinksSelectorMock = (IMxOnboardingLinksSelector) mocks.mock(
            IMxOnboardingLinksSelector.class
        );
        IContractsSelector contractsSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        ISubscriptionsService subscriptionServiceMock = (ISubscriptionsService) mocks.mock(
            ISubscriptionsService.class
        );
        IContractsService contractsServiceMock = (IContractsService) mocks.mock(
            IContractsService.class
        );
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mxOnboardingLinksSelectorMock.sObjectType())
            .thenReturn(Mx_Onboarding_Link__c.SObjectType);
        mocks.when(contractsSelectorMock.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountSelectorMock.selectByUniqueIdentifiers(new Set<Id>{}, new Set<String>()))
            .thenReturn(new List<Account>{});
        mocks.when(
                accountSelectorMock.selectAccountsByMxOnboardingLinkIds(
                    new Set<String>{ UNIQUE_IDENTIFIER }
                )
            )
            .thenReturn(new List<Account>{});
        mocks.when(accountSelectorMock.selectByUniqueIdentifiers(new Set<Id>{}, new Set<String>()))
            .thenReturn(new List<Account>{});
        mocks.when(
                mxOnboardingLinksSelectorMock.selectByMxOnboardingLinkIds(
                    new Set<Id>{ mxOnboardingLinkId }
                )
            )
            .thenReturn(new List<Mx_Onboarding_Link__c>{ mxOnboardingLinkFake });
        mocks.when(subscriptionServiceMock.getSubscriptionsAndRelatedInformation(new Set<Id>{}))
            .thenReturn(new List<SBQQ__Subscription__c>());
        mocks.when(
                subscriptionServiceMock.getExistingSubscriptionsForContracts(
                    new Set<Id>{ contractId }
                )
            )
            .thenReturn(contractIdToSubscriptionsPresent);
        mocks.when(
                contractsServiceMock.getEligibleContractsForOnboardingInputsWorkOrderCreation(
                    new List<Mx_Onboarding_Link__c>{ mxOnboardingLinkFake },
                    contractIdToSubscriptionsPresent
                )
            )
            .thenReturn(contractIdToWorkOrderToBeCreated);
        mocks.when(contractsSelectorMock.selectAdsAndPromosContractsByAccountIds(new Set<Id>{}))
            .thenReturn(new List<Contract>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(mxOnboardingLinksSelectorMock);
        Application.SELECTOR.setMock(contractsSelectorMock);
        Application.SERVICE.setMock(ISubscriptionsService.class, subscriptionServiceMock);
        Application.SERVICE.setMock(IContractsService.class, contractsServiceMock);
        Test.startTest();
        WorkOrdersGeneratorService.execute(mockOnboardingEvents);
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test when Onboarding Events is fired for duplicate Marketing Kit Work Order Creation
     * the do not create Interface Transaction.
     */
    @isTest
    private static void testWhenOnboardingEventsFiredForDuplicateMarketingKitWorkOrderCreationThenDoNotCreateInterfaceTransaction() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id workPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        List<Onboarding_Activation__e> mockOnboardingEvents = new List<Onboarding_Activation__e>{
            new Onboarding_Activation__e(
                Payload__c = JSON.serialize(new Set<Id>{ String.valueOf(workPlanId) }),
                Topic__c = EVENT_TOPIC_WORK_ORDER_GENERATION
            )
        };
        Fake fakeWorkOrderInstance = new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, workOrderId)
            .setField(WorkOrder.Order_Protocol__c, EMAIL_ORDER_PROTOCOL)
            .setField(WorkOrder.AccountId, accountId)
            .setField(WorkOrder.Opportunity__c, opportunityId)
            .setField(WorkOrder.Contract__c, contractId);
        WorkPlan fakeWorkPlan = (WorkPlan) new Fake(WorkPlan.class)
            .setField(WorkPlan.Id, workPlanId)
            .setField(WorkPlan.WorkOrderId, workOrderId)
            .setParent('WorkOrder', fakeWorkOrderInstance)
            .toSobject();
        List<WorkOrder> fakeMarketingKitWorkOrders = new List<WorkOrder>{
            (WorkOrder) new Fake(WorkOrder.class)
                .setField(WorkOrder.Id, fflib_IDGenerator.generate(WorkOrder.SObjectType))
                .setField(WorkOrder.Order_Protocol__c, EMAIL_ORDER_PROTOCOL)
                .setField(WorkOrder.AccountId, accountId)
                .setField(WorkOrder.Opportunity__c, opportunityId)
                .setField(WorkOrder.Contract__c, contractId)
                .setField(WorkOrder.Originating_Work_Order__c, workOrderId)
                .toSobject()
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IWorkPlansSelector workPlansSelectorMock = (IWorkPlansSelector) mocks.mock(
            IWorkPlansSelector.class
        );
        IWorkOrdersSelector workOrdersSelectorMock = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        mocks.startStubbing();
        mocks.when(workPlansSelectorMock.SObjectType()).thenReturn(WorkPlan.SObjectType);
        mocks.when(
                workPlansSelectorMock.selectWorkPlansWithWorkOrderDetails(new Set<Id>{ workPlanId })
            )
            .thenReturn(new List<WorkPlan>{ fakeWorkPlan });
        mocks.when(workOrdersSelectorMock.SObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                workOrdersSelectorMock.selectMarketingKitWorkOrdersByOriginatingWorkOrder(
                    new Set<Id>{ workOrderId }
                )
            )
            .thenReturn(fakeMarketingKitWorkOrders);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(workPlansSelectorMock);
        Application.SELECTOR.setMock(workOrdersSelectorMock);
        Test.startTest();
        WorkOrdersGeneratorService.execute(mockOnboardingEvents);
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description To test when Onboarding Events Platform Event is fired for Net New Mx Onboarding
     * then create Interface Transaction.
     */
    @isTest
    private static void testWhenOnboardingEventsFiredForNetNewRESSMOOnboardingThenCreateInterfaceTransaction() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id mxOnboardingLinkId = fflib_IDGenerator.generate(Mx_Onboarding_Link__c.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id quoteId = fflib_IDGenerator.generate(SBQQ__Quote__c.SobjectType);
        List<Onboarding_Activation__e> mockOnboardingEvents = new List<Onboarding_Activation__e>{
            new Onboarding_Activation__e(
                Payload__c = JSON.serialize(new Set<Id>{ String.valueOf(mxOnboardingLinkId) }),
                Topic__c = EVENT_TOPIC_WORK_ORDER_GENERATION
            )
        };
        Fake orderInstance = new Fake(Order.class)
            .setField(Order.Id, fflib_IDGenerator.generate(Order.SObjectType))
            .setField(Order.AccountId, accountId)
            .setField(Order.OpportunityId, fflib_IDGenerator.generate(Opportunity.SObjectType));
        Fake contractInstance = new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.Status, ACTIVATED_CONTRACT_STATUS)
            .setField(Contract.SBQQ__Quote__c, quoteId)
            .setField(Contract.AccountId, accountId)
            .setParent('SBQQ__Order__r', orderInstance);

        Map<String, Object> objectMap = new Map<String, Object>();

        Map<String, Object> workOrderInformationObj = new Map<String, Object>();
        workOrderInformationObj.put('Activated_Centrally_AC__c', 'Yes');
        workOrderInformationObj.put('Order_Protocol__c', POS_ORDER_PROTOCOL);
        workOrderInformationObj.put('Menu_Setup_Method__c', MENU_SET_UP_METHOD);
        workOrderInformationObj.put('Menu_to_be_Completed_By__c', MENU_TO_BE_COMPLETED_BY_DOORDASH);
        workOrderInformationObj.put('Sales_Notes_for_Menu_Team__c', '');
        workOrderInformationObj.put('Business_ID__c', '123123');
        objectMap.put('workOrderInformation', workOrderInformationObj);
        Mx_Onboarding_Link__c mxOnboardingLinkFake = (Mx_Onboarding_Link__c) new Fake(
                Mx_Onboarding_Link__c.class
            )
            .setField(Mx_Onboarding_Link__c.Id, mxOnboardingLinkId)
            .setField(
                Mx_Onboarding_Link__c.Onboarding_Scenario__c,
                ONBOARDING_SCENARIO_NET_NEW_MX_ONBOARDING
            )
            .setField(Mx_Onboarding_Link__c.Contract__c, contractId)
            .setField(Mx_Onboarding_Link__c.Source__c, 'RESSMO')
            .setField(Mx_Onboarding_Link__c.Payload__c, JSON.serialize(objectMap))
            .setField(Mx_Onboarding_Link__c.UUID__c, UNIQUE_IDENTIFIER)
            .setParent('Contract__r', contractInstance)
            .toSobject();
        Map<Id, Set<String>> contractIdToSubscriptionsPresent = new Map<Id, Set<String>>{
            contractId => new Set<String>{ MARKETPLACE_TYPE }
        };
        Set<String> contractIdToWorkOrderToBeCreated = new Set<String>{
            contractId +
            SEPARATOR +
            MARKETPLACE_TYPE
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IMxOnboardingLinksSelector mxOnboardingLinksSelectorMock = (IMxOnboardingLinksSelector) mocks.mock(
            IMxOnboardingLinksSelector.class
        );
        IContractsSelector contractsSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        ISubscriptionsService subscriptionServiceMock = (ISubscriptionsService) mocks.mock(
            ISubscriptionsService.class
        );
        IContractsService contractsServiceMock = (IContractsService) mocks.mock(
            IContractsService.class
        );
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mxOnboardingLinksSelectorMock.sObjectType())
            .thenReturn(Mx_Onboarding_Link__c.SObjectType);
        mocks.when(contractsSelectorMock.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                accountSelectorMock.selectAccountsByMxOnboardingLinkIds(
                    new Set<String>{ UNIQUE_IDENTIFIER }
                )
            )
            .thenReturn(new List<Account>{});
        mocks.when(accountSelectorMock.selectByUniqueIdentifiers(new Set<Id>{}, new Set<String>()))
            .thenReturn(new List<Account>{});
        mocks.when(
                mxOnboardingLinksSelectorMock.selectByMxOnboardingLinkIds(
                    new Set<Id>{ mxOnboardingLinkId }
                )
            )
            .thenReturn(new List<Mx_Onboarding_Link__c>{ mxOnboardingLinkFake });
        mocks.when(subscriptionServiceMock.getSubscriptionsAndRelatedInformation(new Set<Id>{}))
            .thenReturn(new List<SBQQ__Subscription__c>());
        mocks.when(
                subscriptionServiceMock.getExistingSubscriptionsForContracts(
                    new Set<Id>{ contractId }
                )
            )
            .thenReturn(contractIdToSubscriptionsPresent);
        mocks.when(
                contractsServiceMock.getEligibleContractsForOnboardingInputsWorkOrderCreation(
                    new List<Mx_Onboarding_Link__c>{ mxOnboardingLinkFake },
                    contractIdToSubscriptionsPresent
                )
            )
            .thenReturn(contractIdToWorkOrderToBeCreated);
        mocks.when(
                contractsSelectorMock.selectAdsAndPromosContractsByAccountIds(
                    new Set<Id>{ accountId }
                )
            )
            .thenReturn(new List<Contract>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mxOnboardingLinksSelectorMock);
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(contractsSelectorMock);
        Application.SERVICE.setMock(ISubscriptionsService.class, subscriptionServiceMock);
        Application.SERVICE.setMock(IContractsService.class, contractsServiceMock);
        Test.startTest();
        WorkOrdersGeneratorService.execute(mockOnboardingEvents);
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test when Onboarding Events is fired for Onboarding Inputs Product Addition
     * scenario and Contract contains only storefront.
     */
    @isTest
    private static void testWhenOnboardingEventsFiredForProductAdditonAndContractContainsOnlyStorefrontProductsThenCreateInterfaceTransactionForStorefrontWorkOrder() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id mxOnboardingLinkId = fflib_IDGenerator.generate(Mx_Onboarding_Link__c.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id quoteId = fflib_IDGenerator.generate(SBQQ__Quote__c.SobjectType);
        List<Onboarding_Activation__e> mockOnboardingEvents = new List<Onboarding_Activation__e>{
            new Onboarding_Activation__e(
                Payload__c = JSON.serialize(new Set<Id>{ String.valueOf(mxOnboardingLinkId) }),
                Topic__c = EVENT_TOPIC_WORK_ORDER_GENERATION
            )
        };
        Account storeAccountFakeRecord = (Account) new Fake(Account.class)
            .setField(Account.Segment__c, SMB_SEGMENT_TYPE)
            .setField(Account.RecordTypeId, STORE_ACCOUNT_RECORD_TYPE)
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS_VERIFIED)
            .setField(Account.Coverage__c, ADDRESS_COVERAGE_IN_COVERAGE)
            .setField(Account.Mx_Onboarding_Link_Id__c, UNIQUE_IDENTIFIER)
            .toSobject();
        Fake orderInstance = new Fake(Order.class)
            .setField(Order.Id, fflib_IDGenerator.generate(Order.SObjectType))
            .setField(Order.AccountId, accountId)
            .setField(Order.OpportunityId, fflib_IDGenerator.generate(Opportunity.SObjectType));
        Fake contractInstance = new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.Status, ACTIVATED_CONTRACT_STATUS)
            .setField(Contract.SBQQ__Quote__c, quoteId)
            .setField(Contract.AccountId, accountId)
            .setParent('SBQQ__Order__r', orderInstance);
        Mx_Onboarding_Link__c mxOnboardingLinkFake = (Mx_Onboarding_Link__c) new Fake(
                Mx_Onboarding_Link__c.class
            )
            .setField(Mx_Onboarding_Link__c.Id, mxOnboardingLinkId)
            .setField(
                Mx_Onboarding_Link__c.Onboarding_Scenario__c,
                ONBOARDING_SCENARIO_PRODUCT_ADDITION
            )
            .setField(Mx_Onboarding_Link__c.Contract__c, contractId)
            .setField(Mx_Onboarding_Link__c.UUID__c, UNIQUE_IDENTIFIER)
            .setField(Mx_Onboarding_Link__c.Product_on_Contract__c, STOREFRONT_TYPE)
            .setParent('Contract__r', contractInstance)
            .setChildren(
                'Business_Onboarding_Details__r',
                new List<Fake>{
                    new Fake(Business_Onboarding_Detail__c.class)
                        .setField(
                            Business_Onboarding_Detail__c.Id,
                            fflib_IDGenerator.generate(Business_Onboarding_Detail__c.SObjectType)
                        )
                        .setField(
                            Business_Onboarding_Detail__c.Activated_Centrally_AC__c,
                            ACTIVATED_CENTRALLY_YES
                        )
                        .setField(
                            Business_Onboarding_Detail__c.Mx_Requested_Photoshoot__c,
                            PHOTOSHOOT_REQUEST_YES
                        )
                        .setField(
                            Business_Onboarding_Detail__c.Order_Protocol__c,
                            EMAIL_ORDER_PROTOCOL
                        )
                        .setField(Business_Onboarding_Detail__c.Photoshoot_Date__c, DATE_TODAY)
                        .setField(
                            Business_Onboarding_Detail__c.Photoshoot_Time__c,
                            Time.newInstance(18, 30, 2, 20)
                        )
                        .setField(
                            Business_Onboarding_Detail__c.Proposed_Date_of_Activation__c,
                            DATE_TODAY
                        )
                }
            )
            .setChildren(
                'Store_Details__r',
                new List<Fake>{
                    new Fake(Store_Detail__c.class)
                        .setField(
                            Store_Detail__c.Id,
                            fflib_IDGenerator.generate(Business_Onboarding_Detail__c.SObjectType)
                        )
                        .setField(Store_Detail__c.Menu_Setup_Method__c, MENU_SET_UP_METHOD)
                        .setField(
                            Store_Detail__c.Menu_to_be_Completed_By__c,
                            MENU_TO_BE_COMPLETED_BY_DOORDASH
                        )
                }
            )
            .toSobject();
        Map<Id, Set<String>> contractIdToSubscriptionsPresent = new Map<Id, Set<String>>{
            contractId => new Set<String>{ STOREFRONT_TYPE }
        };
        Set<String> contractIdToWorkOrderToBeCreated = new Set<String>{
            contractId +
            SEPARATOR +
            STOREFRONT_TYPE
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IMxOnboardingLinksSelector mxOnboardingLinksSelectorMock = (IMxOnboardingLinksSelector) mocks.mock(
            IMxOnboardingLinksSelector.class
        );
        IContractsSelector contractsSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        ISubscriptionsService subscriptionServiceMock = (ISubscriptionsService) mocks.mock(
            ISubscriptionsService.class
        );
        IContractsService contractsServiceMock = (IContractsService) mocks.mock(
            IContractsService.class
        );
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mxOnboardingLinksSelectorMock.sObjectType())
            .thenReturn(Mx_Onboarding_Link__c.SObjectType);
        mocks.when(contractsSelectorMock.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                accountSelectorMock.selectAccountsByMxOnboardingLinkIds(
                    new Set<String>{ UNIQUE_IDENTIFIER }
                )
            )
            .thenReturn(new List<Account>{ storeAccountFakeRecord });
        mocks.when(accountSelectorMock.selectByUniqueIdentifiers(new Set<Id>{}, new Set<String>()))
            .thenReturn(new List<Account>{});
        mocks.when(
                mxOnboardingLinksSelectorMock.selectByMxOnboardingLinkIds(
                    new Set<Id>{ mxOnboardingLinkId }
                )
            )
            .thenReturn(new List<Mx_Onboarding_Link__c>{ mxOnboardingLinkFake });
        mocks.when(subscriptionServiceMock.getSubscriptionsAndRelatedInformation(new Set<Id>{}))
            .thenReturn(new List<SBQQ__Subscription__c>());
        mocks.when(
                subscriptionServiceMock.getExistingSubscriptionsForContracts(
                    new Set<Id>{ contractId }
                )
            )
            .thenReturn(contractIdToSubscriptionsPresent);
        mocks.when(
                contractsServiceMock.getEligibleContractsForOnboardingInputsWorkOrderCreation(
                    new List<Mx_Onboarding_Link__c>{ mxOnboardingLinkFake },
                    contractIdToSubscriptionsPresent
                )
            )
            .thenReturn(contractIdToWorkOrderToBeCreated);
        mocks.when(contractsSelectorMock.selectAdsAndPromosContractsByAccountIds(new Set<Id>{}))
            .thenReturn(new List<Contract>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(mxOnboardingLinksSelectorMock);
        Application.SELECTOR.setMock(contractsSelectorMock);
        Application.SERVICE.setMock(ISubscriptionsService.class, subscriptionServiceMock);
        Application.SERVICE.setMock(IContractsService.class, contractsServiceMock);
        Test.startTest();
        WorkOrdersGeneratorService.execute(mockOnboardingEvents);
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To Test creation of Interface Transaction For Hardware Family Product.
     * when Platform Events are fired for Amendments.
     */
    @isTest
    private static void testWhenOnboardingEventsFiredForAmendmentsThenCreateInterfaceTransactionsForHardwareProductFamily() {
        Id newSubscriptionId = fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType);
        List<Onboarding_Activation__e> mockOnboardingEvents = new List<Onboarding_Activation__e>{
            new Onboarding_Activation__e(
                Payload__c = JSON.serialize(new Set<Id>{ String.valueOf(newSubscriptionId) }),
                Topic__c = AMENDMENT_WORK_ORDER_CREATION
            )
        };
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Fake fakeProduct = new Fake(Product2.class)
            .setField(Product2.Id, fflib_IDGenerator.generate(Product2.SObjectType))
            .setField(Product2.Name, PRODUCT_FAMILY_HARDWARE)
            .setField(Product2.Family, PRODUCT_FAMILY_HARDWARE);
        Fake fakeContract = new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setField(
                Contract.SBQQ__Opportunity__c,
                fflib_IDGenerator.generate(Opportunity.SObjectType)
            );
        Id quoteLineItemId = fflib_IDGenerator.generate(SBQQ__QuoteLine__c.SObjectType);
        Id amendedQuoteId = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType);
        SBQQ__Subscription__c newSubscription = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, newSubscriptionId)
            .setField(SBQQ__Subscription__c.Package__c, null)
            .setField(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setField(SBQQ__Subscription__c.SBQQ__QuoteLine__c, quoteLineItemId)
            .setParent('SBQQ__Product__r', fakeProduct)
            .setParent('SBQQ__Contract__r', fakeContract)
            .setParent(
                'SBQQ__QuoteLine__r',
                new Fake(SBQQ__QuoteLine__c.class)
                    .setField(SBQQ__QuoteLine__c.Id, quoteLineItemId)
                    .setField(SBQQ__QuoteLine__c.SBQQ__Quote__c, amendedQuoteId)
                    .setParent(
                        'SBQQ__Quote__r',
                        new Fake(SBQQ__Quote__c.class)
                            .setField(SBQQ__Quote__c.id, amendedQuoteId)
                            .setField(SBQQ__Quote__c.SBQQ__Type__c, TYPE_AMENDMENT)
                    )
            )
            .toSobject();
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
                subscriptionSelectorMock.selectBySubscriptionIds(new Set<Id>{ newSubscriptionId })
            )
            .thenReturn(new List<SBQQ__Subscription__c>{ newSubscription });
        mocks.when(
                subscriptionSelectorMock.selectAmendedSubscriptions(
                    new Set<Id>{ contractId },
                    new Set<String>{ PRODUCT_FAMILY_HARDWARE },
                    new Set<Id>{ newSubscriptionId }
                )
            )
            .thenReturn(new List<SBQQ__Subscription__c>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(subscriptionSelectorMock);
        Test.startTest();
        WorkOrdersGeneratorService.execute(mockOnboardingEvents);
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To Test creation of Interface Transaction record when Onbaording
     * Activations Platform Events are fired for Storefront Work Order Creation.
     */
    @isTest
    private static void testWhenOnboardingEventsFiredForMxPortalStorefrontWorkOrderCreationThenCreateInterfaceTransaction() {
        Id subscriptionId = fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType);
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id quoteId = fflib_IDGenerator.generate(SBQQ__Quote__c.SobjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SobjectType);
        Id productId = fflib_IDGenerator.generate(Product2.SobjectType);
        List<Onboarding_Activation__e> mockOnboardingEvents = new List<Onboarding_Activation__e>{
            new Onboarding_Activation__e(
                Payload__c = JSON.serialize(new Set<Id>{ String.valueOf(subscriptionId) }),
                Topic__c = EVENT_TOPIC_WORK_ORDER_GENERATION
            )
        };
        Account fakeStoreAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, fflib_IDGenerator.generate(Account.SobjectType))
            .setField(Account.Segment__c, SMB_SEGMENT_TYPE)
            .setField(Account.Unique_Identifier__c, UNIQUE_IDENTIFIER)
            .setField(Account.ParentId, parentAccountId)
            .setField(Account.Order_Protocol__c, EMAIL_ORDER_PROTOCOL)
            .toSobject();
        Fake fakeQuote = new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id, quoteId)
            .setField(SBQQ__Quote__c.Unique_Identifier__c, UNIQUE_IDENTIFIER)
            .setField(SBQQ__Quote__c.Integration_Source__c, CREATION_SOURCE_MX_PORTAL);
        Fake fakeContract = new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setField(Contract.Status, ACTIVATED_CONTRACT_STATUS)
            .setField(Contract.SBQQ__Quote__c, quoteId)
            .setParent('SBQQ__Quote__r', fakeQuote)
            .setField(Contract.Unique_Identifier__c, UNIQUE_IDENTIFIER)
            .setParent(
                'SBQQ__Order__r',
                new Fake(Order.class).setField(Order.Unique_Identifier__c, UNIQUE_IDENTIFIER)
            );
        Fake fakeProduct = new Fake(Product2.class)
            .setField(Product2.Id, productId)
            .setField(Product2.Name, STOREFRONT_TYPE)
            .setField(Product2.Work_Order_Type__c, STOREFRONT_TYPE);

        List<SBQQ__Subscription__c> mockSubscription = new List<SBQQ__Subscription__c>{
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.Id, subscriptionId)
                .setField(SBQQ__Subscription__c.SBQQ__Account__c, parentAccountId)
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
                .setField(SBQQ__Subscription__c.SBQQ__Product__c, productId)
                .setField(SBQQ__Subscription__c.Integration_Source__c, CREATION_SOURCE_MX_PORTAL)
                .setField(SBQQ__Subscription__c.Unique_Identifier__c, UNIQUE_IDENTIFIER)
                .setParent('SBQQ__Product__r', fakeProduct)
                .setParent('SBQQ__Contract__r', fakeContract)
                .toSobject()
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountSelectorMocks = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        ISubscriptionsService subscriptionServiceMock = (ISubscriptionsService) mocks.mock(
            ISubscriptionsService.class
        );

        mocks.startStubbing();
        mocks.when(accountSelectorMocks.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                accountSelectorMocks.selectByUniqueIdentifiers(
                    new Set<Id>{ parentAccountId },
                    new Set<String>{ UNIQUE_IDENTIFIER }
                )
            )
            .thenReturn(new List<Account>{ fakeStoreAccount });
        mocks.when(
                subscriptionServiceMock.getSubscriptionsAndRelatedInformation(
                    new Set<Id>{ subscriptionId }
                )
            )
            .thenReturn(mockSubscription);
        mocks.when(subscriptionServiceMock.getExistingSubscriptionsForContracts(new Set<Id>{}))
            .thenReturn(new Map<Id, Set<String>>{});
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(accountSelectorMocks);
        Application.SERVICE.setMock(ISubscriptionsService.class, subscriptionServiceMock);
        WorkOrdersGeneratorService.execute(mockOnboardingEvents);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To Test when Platform Event is fired for Rate Change Amendments then
     * create only one Interface Transaction.
     */
    @isTest
    private static void testWhenOnboardingEventsFiredForRatChangeAmendmentsThenCreateOnlyOneInterfaceTransaction() {
        Id subscriptionId1 = fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType);
        Id subscriptionId2 = fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType);
        Id subscriptionId3 = fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType);
        Id pastSubscriptionId = fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType);
        List<Onboarding_Activation__e> mockOnboardingEvents = new List<Onboarding_Activation__e>{
            new Onboarding_Activation__e(
                Payload__c = JSON.serialize(
                    new Set<Id>{
                        String.valueOf(subscriptionId1),
                        String.valueOf(subscriptionId2),
                        String.valueOf(subscriptionId3)
                    }
                ),
                Topic__c = AMENDMENT_WORK_ORDER_CREATION
            )
        };
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Fake fakeMarketplaceProduct = new Fake(Product2.class)
            .setField(Product2.Id, fflib_IDGenerator.generate(Product2.SObjectType))
            .setField(Product2.Name, MARKETPLACE_TYPE)
            .setField(Product2.Family, MARKETPLACE_TYPE);
        Fake fakeStorefrontProduct = new Fake(Product2.class)
            .setField(Product2.Id, fflib_IDGenerator.generate(Product2.SObjectType))
            .setField(Product2.Name, STOREFRONT_TYPE)
            .setField(Product2.Family, STOREFRONT_TYPE);
        Fake fakeHardwareProduct = new Fake(Product2.class)
            .setField(Product2.Id, fflib_IDGenerator.generate(Product2.SObjectType))
            .setField(Product2.Name, PRODUCT_FAMILY_HARDWARE)
            .setField(Product2.Family, PRODUCT_FAMILY_HARDWARE);
        Fake fakeContract = new Fake(Contract.class)
            .setField(Contract.Id, contractId)
            .setField(
                Contract.SBQQ__Opportunity__c,
                fflib_IDGenerator.generate(Opportunity.SObjectType)
            );
        Id quoteLineItemId = fflib_IDGenerator.generate(SBQQ__QuoteLine__c.SObjectType);
        Id amendedQuoteId = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType);

        List<SBQQ__Subscription__c> fakeSubscriptionRecords = new List<SBQQ__Subscription__c>{
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.Id, subscriptionId1)
                .setField(SBQQ__Subscription__c.Package__c, null)
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
                .setField(SBQQ__Subscription__c.SBQQ__QuoteLine__c, quoteLineItemId)
                .setParent('SBQQ__Product__r', fakeMarketplaceProduct)
                .setParent('SBQQ__Contract__r', fakeContract)
                .setParent(
                    'SBQQ__QuoteLine__r',
                    new Fake(SBQQ__QuoteLine__c.class)
                        .setField(SBQQ__QuoteLine__c.Id, quoteLineItemId)
                        .setField(SBQQ__QuoteLine__c.SBQQ__Quote__c, amendedQuoteId)
                        .setParent(
                            'SBQQ__Quote__r',
                            new Fake(SBQQ__Quote__c.class)
                                .setField(SBQQ__Quote__c.id, amendedQuoteId)
                                .setField(SBQQ__Quote__c.SBQQ__Type__c, TYPE_AMENDMENT)
                        )
                )
                .toSobject(),
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.Id, subscriptionId2)
                .setField(SBQQ__Subscription__c.Package__c, null)
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
                .setField(SBQQ__Subscription__c.SBQQ__QuoteLine__c, quoteLineItemId)
                .setParent('SBQQ__Product__r', fakeStorefrontProduct)
                .setParent('SBQQ__Contract__r', fakeContract)
                .setParent(
                    'SBQQ__QuoteLine__r',
                    new Fake(SBQQ__QuoteLine__c.class)
                        .setField(SBQQ__QuoteLine__c.Id, quoteLineItemId)
                        .setField(SBQQ__QuoteLine__c.SBQQ__Quote__c, amendedQuoteId)
                        .setParent(
                            'SBQQ__Quote__r',
                            new Fake(SBQQ__Quote__c.class)
                                .setField(SBQQ__Quote__c.id, amendedQuoteId)
                                .setField(SBQQ__Quote__c.SBQQ__Type__c, TYPE_AMENDMENT)
                        )
                )
                .toSobject(),
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.Id, subscriptionId3)
                .setField(SBQQ__Subscription__c.Package__c, null)
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
                .setField(SBQQ__Subscription__c.SBQQ__QuoteLine__c, quoteLineItemId)
                .setParent('SBQQ__Product__r', fakeHardwareProduct)
                .setParent('SBQQ__Contract__r', fakeContract)
                .setParent(
                    'SBQQ__QuoteLine__r',
                    new Fake(SBQQ__QuoteLine__c.class)
                        .setField(SBQQ__QuoteLine__c.Id, quoteLineItemId)
                        .setField(SBQQ__QuoteLine__c.SBQQ__Quote__c, amendedQuoteId)
                        .setParent(
                            'SBQQ__Quote__r',
                            new Fake(SBQQ__Quote__c.class)
                                .setField(SBQQ__Quote__c.id, amendedQuoteId)
                                .setField(SBQQ__Quote__c.SBQQ__Type__c, TYPE_AMENDMENT)
                        )
                )
                .toSobject()
        };
        SBQQ__Subscription__c pastSubscription = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, pastSubscriptionId)
            .setField(SBQQ__Subscription__c.Package__c, null)
            .setField(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setParent('SBQQ__Product__r', fakeMarketplaceProduct)
            .toSobject();
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
                subscriptionSelectorMock.selectBySubscriptionIds(
                    new Set<Id>{ subscriptionId1, subscriptionId2, subscriptionId3 }
                )
            )
            .thenReturn(fakeSubscriptionRecords);
        mocks.when(
                subscriptionSelectorMock.selectAmendedSubscriptions(
                    new Set<Id>{ contractId },
                    new Set<String>{ PRODUCT_FAMILY_HARDWARE, MARKETPLACE_TYPE, STOREFRONT_TYPE },
                    new Set<Id>{ subscriptionId1, subscriptionId2, subscriptionId3 }
                )
            )
            .thenReturn(new List<SBQQ__Subscription__c>{ pastSubscription });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(subscriptionSelectorMock);
        Test.startTest();
        WorkOrdersGeneratorService.execute(mockOnboardingEvents);
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew((Interface_Transaction__c) fflib_Match.anyObject());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }
}