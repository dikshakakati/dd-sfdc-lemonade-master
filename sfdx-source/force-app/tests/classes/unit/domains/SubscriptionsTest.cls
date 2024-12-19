/**
 * @author Deloitte
 * @date 20/06/2023
 * @description This is test class for Subscriptions class
 */
@isTest(seeAllData=false)
public class SubscriptionsTest {
    private static final String AMENDMENT_WORK_ORDER_CREATION = 'AMENDMENT_WORK_ORDER_GENERATION';
    private static final String GENERIC_WORK_ORDER_CREATION = 'WORK_ORDER_GENERATION';
    private static final String INGESTION_LOG_PAYLOAD = '{"Mx Store Name":"KFC"}';
    private static final String INGESTION_LOG_STATUS_SUCCESS = 'Success';
    private static final String INTEGRATION_SOURCE_MX_PORTAL = 'Mx Portal';
    private static final String INTEGRATION_SOURCE_NINTEX = 'Nintex';
    private static final String INTEGRATION_SOURCE_SSMO = 'SSMO';
    private static final String INTEGRATION_SOURCE_SSOB = 'SSOB';
    private static final String INTEGRATION_TYPE_PACKAGE_SWITCH = 'Mx Portal Package Switch';
    private static final String INTEGRATION_TYPE_ONBOARDING_EVENT = 'Onboarding Event';
    private static final String INTEGRATION_SOURCE_RESSMO = 'RESSMO';
    private static final String SEGMENT_SMB = 'SMB';
    private static final String PRODUCT_NAME_BASIC = 'Basic Package';
    private static final String PRODUCT_FAMILY_MARKETPLACE = 'Marketplace';
    private static final String UNIQUE_IDENTIFIER = '942db671-92c3-3d7b-8b05-1e326f5e45f0';
    private static final Set<String> INBOUND_INGESTION_INTEGRATION_TYPES_INELIGIBLE_FOR_WORK_ORDER_CREATION = new Set<String>{
        INTEGRATION_TYPE_PACKAGE_SWITCH
    };

    /**
     * @description This is method used to test Subscriptions class
     */
    @isTest
    private static void testWhenClassInstantiatesThenRun() {
        List<SBQQ__Subscription__c> subscriptionList = new List<SBQQ__Subscription__c>();
        Subscriptions subscriptionObject = new Subscriptions(subscriptionList);
        Subscriptions.newInstance(subscriptionList);
        System.assertNotEquals(
            Subscriptions.newInstance(subscriptionList),
            subscriptionObject,
            'Unexpected result: both objects are similar.'
        );
    }

    /**
     * @description To validate if subscription is inserted then SubscriptionService
     * Should be called to Group
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenSubscriptionIsInsertedThenCallSubscriptiionServiceToUpdateGroup() {
        Id sub1 = Fake.generateId(SBQQ__Subscription__c.class);
        Id qli1 = Fake.generateId(SBQQ__QuoteLine__c.class);
        Id sub2 = Fake.generateId(SBQQ__Subscription__c.class);
        Id qli2 = Fake.generateId(SBQQ__QuoteLine__c.class);
        Id group1 = Fake.generateId(SBQQ__QuoteLineGroup__c.class);
        Id group2 = Fake.generateId(SBQQ__QuoteLineGroup__c.class);
        String strId = Id.valueOf(group1);

        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>{
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.id, sub1)
                .setField(SBQQ__Subscription__c.SBQQ__QuoteLine__c, qli1)
                .toSobject(),
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.id, sub2)
                .setField(SBQQ__Subscription__c.SBQQ__QuoteLine__c, qli2)
                .toSobject()
        };
        List<SBQQ__QuoteLine__c> qliList = new List<SBQQ__QuoteLine__c>{
            (SBQQ__QuoteLine__c) new Fake(SBQQ__QuoteLine__c.class)
                .setField(SBQQ__QuoteLine__c.Id, qli1)
                .setField(SBQQ__QuoteLine__c.SBQQ__Group__c, group1)
                .toSobject(),
            (SBQQ__QuoteLine__c) new Fake(SBQQ__QuoteLine__c.class)
                .setField(SBQQ__QuoteLine__c.Id, qli2)
                .setField(SBQQ__QuoteLine__c.SBQQ__Group__c, group2)
                .setParent(
                    'SBQQ__Group__r',
                    new Fake(SBQQ__QuoteLineGroup__c.class)
                        .setField(SBQQ__QuoteLineGroup__c.Id, group2)
                        .setField(SBQQ__QuoteLineGroup__c.CCP_Unique_Group_Id__c, strId)
                )
                .toSobject()
        };

        Set<Id> qliId = new Set<Id>{ qli1, qli2 };
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IQuoteLineItemsSelector qlSelectorMock = (IQuoteLineItemsSelector) mocks.mock(
            IQuoteLineItemsSelector.class
        );

        mocks.startStubbing();
        mocks.when(qlSelectorMock.sObjectType()).thenReturn(SBQQ__QuoteLine__c.SObjectType);
        mocks.when(qlSelectorMock.selectQuoteLineGroupFields(qliId)).thenReturn(qliList);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(qlSelectorMock);
        //Act
        Subscriptions.newInstance(subList).populateQuoteLineGroup();
        //Assert
        system.assertEquals(subList[0].Quote_Line_Group__c, group1, 'Group missmatch');
        system.assertEquals(subList[1].Quote_Line_Group__c, group1, 'Group missmatch');
    }

    /**
     * @description To validate if subscription is inserted then contractService
     * Should be called to update MSA/ Ads Promo Indicator to Contract Name.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenSubscriptionIsInsertedThenCallContractServiceToUpdateContractName() {
        Id subs1 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subs2 = Fake.generateId(SBQQ__Subscription__c.class);
        Id con1 = Fake.generateId(Contract.class);
        Id con2 = Fake.generateId(Contract.class);

        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>{
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.id, subs1)
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, con1)
                .setField(SBQQ__Subscription__c.SBQQ__Quantity__c, 1)
                .toSobject(),
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
                .setField(SBQQ__Subscription__c.id, subs2)
                .setField(SBQQ__Subscription__c.SBQQ__Contract__c, con2)
                .setField(SBQQ__Subscription__c.SBQQ__Quantity__c, 1)
                .toSobject()
        };
        List<Contract> contracts = new List<Contract>{
            (Contract) new Fake(Contract.class)
                .setField(Contract.Id, con1)
                .setField(Contract.Contract_Name__c, 'Con1')
                .toSobject(),
            (Contract) new Fake(Contract.class)
                .setField(Contract.Id, con2)
                .setField(Contract.Contract_Name__c, 'Con2')
                .toSobject()
        };
        Set<Id> contractIds = new Set<Id>{ con1, con2 };
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IContractsSelector contractSelectorMock = (IContractsSelector) mocks.mock(
            IContractsSelector.class
        );
        IContractsService mockContractService = (IContractsService) mocks.mock(
            IContractsService.class
        );

        mocks.startStubbing();
        mocks.when(contractSelectorMock.sObjectType()).thenReturn(Contract.SObjectType);
        mocks.when(contractSelectorMock.selectById(contractIds)).thenReturn(contracts);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(contractSelectorMock);
        Application.SERVICE.setMock(IContractsService.class, mockContractService);
        //Act
        Subscriptions.newInstance(subList).callContractServiceToUpdateContractName();
        //Assert
        ((IContractsService) mocks.verify(mockContractService, 1))
            .stampMsaOrAdsPromoOntheContract(new Map<Id, String>{ con1 => 'Con1', con2 => 'Con2' });
    }

    /**
     * @description To test when a Subcriptions are created for SSMO and SSOB then Work Order
     * creation is initiated.
     * Suppressed Warnings since mock verify method is equivalent of System.assert statement.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenSubcriptionsCreatedForSSMOThenWorkOrderCreation() {
        Id accountId = Fake.generateId(Account.class);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id subscriptionId = fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType);
        SBQQ__Subscription__c fakeSubscription = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId)
            .SetField(SBQQ__Subscription__c.Integration_Source__c, INTEGRATION_SOURCE_SSMO)
            .SetField(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .SetField(SBQQ__Subscription__c.Unique_Identifier__c, UNIQUE_IDENTIFIER)
            .setParent(
                'SBQQ__Contract__r',
                new Fake(Contract.class)
                    .setField(Contract.Id, contractId)
                    .setField(Contract.AccountId, accountId)
                    .setParent(
                        'Account',
                        new Fake(Account.class)
                            .setField(Account.id, accountId)
                            .setField(Account.Segment__c, SEGMENT_SMB)
                    )
            )
            .toSobject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ISubscriptionSelector subscriptionSelectorMock = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );
        IInboundIngestionLogsSelector inboundIngestionLogsSelectorMock = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );
        mocks.startStubbing();
        mocks.when(subscriptionSelectorMock.SObjectType())
            .thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(inboundIngestionLogsSelectorMock.SObjectType())
            .thenReturn(Inbound_Ingestion_Log__c.SObjectType);
        mocks.when(subscriptionSelectorMock.selectBySubscriptionIds(new Set<Id>{ subscriptionId }))
            .thenReturn(new List<SBQQ__Subscription__c>{ fakeSubscription });
        mocks.when(
                inboundIngestionLogsSelectorMock.selectInboundIngestionLogsByUniqueIdentifiers(
                    INBOUND_INGESTION_INTEGRATION_TYPES_INELIGIBLE_FOR_WORK_ORDER_CREATION,
                    new Set<String>{ UNIQUE_IDENTIFIER }
                )
            )
            .thenReturn(new List<Inbound_Ingestion_Log__c>{});
        mocks.stopStubbing();
        Application.SELECTOR.setMock(subscriptionSelectorMock);
        Application.SELECTOR.setMock(inboundIngestionLogsSelectorMock);
        IWorkOrderCreationTriggerService workOrderCreationTriggerServiceMock = (IWorkOrderCreationTriggerService) mocks.mock(
            IWorkOrderCreationTriggerService.class
        );
        Application.SERVICE.setMock(
            IWorkOrderCreationTriggerService.class,
            workOrderCreationTriggerServiceMock
        );
        Test.startTest();
        Subscriptions.newInstance(new List<SBQQ__Subscription__c>{ fakeSubscription })
            .evaluateAndInitalizeForWorkOrderCreation();
        Test.stopTest();
        ((IWorkOrderCreationTriggerService) mocks.verify(workOrderCreationTriggerServiceMock, 1))
            .initiateWorkOrderCreation(
                new Set<Id>{ fakeSubscription.Id },
                GENERIC_WORK_ORDER_CREATION
            );
    }

    /**
     * @description To test when Subscriptions are inserted and creation Source is Mx Portal then
     * initiate Work Order creation.
     * Suppressed Warnings since mock verify method is equivalent of System.assert statement.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenSubscriptionsInsertedAndCreationSourceIsMxPortalThenInitiateWorkOrderCreation() {
        Id accountId = Fake.generateId(Account.class);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id subscriptionId = fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType);
        SBQQ__Subscription__c fakeSubscription = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId)
            .SetField(SBQQ__Subscription__c.Integration_Source__c, INTEGRATION_SOURCE_MX_PORTAL)
            .SetField(SBQQ__Subscription__c.Unique_Identifier__c, UNIQUE_IDENTIFIER)
            .setParent(
                'SBQQ__Contract__r',
                new Fake(Contract.class)
                    .setField(Contract.Id, contractId)
                    .setField(Contract.AccountId, accountId)
                    .setParent(
                        'Account',
                        new Fake(Account.class)
                            .setField(Account.id, accountId)
                            .setField(Account.Segment__c, SEGMENT_SMB)
                    )
            )
            .toSobject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ISubscriptionSelector subscriptionSelectorMock = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );
        IInboundIngestionLogsSelector inboundIngestionLogsSelectorMock = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );
        mocks.startStubbing();
        mocks.when(subscriptionSelectorMock.SObjectType())
            .thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(inboundIngestionLogsSelectorMock.SObjectType())
            .thenReturn(Inbound_Ingestion_Log__c.SObjectType);
        mocks.when(subscriptionSelectorMock.selectBySubscriptionIds(new Set<Id>{ subscriptionId }))
            .thenReturn(new List<SBQQ__Subscription__c>{ fakeSubscription });
        mocks.when(
                inboundIngestionLogsSelectorMock.selectInboundIngestionLogsByUniqueIdentifiers(
                    INBOUND_INGESTION_INTEGRATION_TYPES_INELIGIBLE_FOR_WORK_ORDER_CREATION,
                    new Set<String>{ UNIQUE_IDENTIFIER }
                )
            )
            .thenReturn(new List<Inbound_Ingestion_Log__c>{});
        mocks.stopStubbing();
        Application.SELECTOR.setMock(subscriptionSelectorMock);
        Application.SELECTOR.setMock(inboundIngestionLogsSelectorMock);
        IWorkOrderCreationTriggerService workOrderCreationTriggerServiceMock = (IWorkOrderCreationTriggerService) mocks.mock(
            IWorkOrderCreationTriggerService.class
        );
        Application.SERVICE.setMock(
            IWorkOrderCreationTriggerService.class,
            workOrderCreationTriggerServiceMock
        );
        Test.startTest();
        Subscriptions.newInstance(new List<SBQQ__Subscription__c>{ fakeSubscription })
            .evaluateAndInitalizeForWorkOrderCreation();
        Test.stopTest();
        ((IWorkOrderCreationTriggerService) mocks.verify(workOrderCreationTriggerServiceMock, 1))
            .initiateWorkOrderCreation(
                new Set<Id>{ fakeSubscription.Id },
                GENERIC_WORK_ORDER_CREATION
            );
    }

    /**
     * @description To test when Subscriptions are inserted and creation Source is other than Mx Portal, SSMO,
     * SSOB then do not Initiate Work Order Creation.
     * Suppressed Warnings since mock verify method is equivalent of System.assert statement.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenSubscriptionsInsertedForNonMxPortalSSMOSSOBCreationSourceThenDoNotInitiateWorkOrderCreation() {
        SBQQ__Subscription__c fakeSubscription = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(
                SBQQ__Subscription__c.Id,
                fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType)
            )
            .SetField(SBQQ__Subscription__c.Integration_Source__c, INTEGRATION_SOURCE_NINTEX)
            .toSobject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrderCreationTriggerService workOrderCreationTriggerServiceMock = (IWorkOrderCreationTriggerService) mocks.mock(
            IWorkOrderCreationTriggerService.class
        );
        Application.SERVICE.setMock(
            IWorkOrderCreationTriggerService.class,
            workOrderCreationTriggerServiceMock
        );
        Test.startTest();
        Subscriptions.newInstance(new List<SBQQ__Subscription__c>{ fakeSubscription })
            .evaluateAndInitalizeForWorkOrderCreation();
        Test.stopTest();
        ((IWorkOrderCreationTriggerService) mocks.verify(workOrderCreationTriggerServiceMock, 0))
            .initiateWorkOrderCreation(
                new Set<Id>{ fakeSubscription.Id },
                GENERIC_WORK_ORDER_CREATION
            );
    }

    /**
     * @description To test when Subscriptions are inserted and creation Source is other than Mx Portal, SSMO,
     * SSOB then initiate Amendment Work Order Creation.
     * Suppressed Warnings since mock verify method is equivalent of System.assert statement.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenSubscriptionsInsertedForNonMxPortalSSMOSSOBCreationSourceThenInitiateAmedmentWorkOrderCreation() {
        Id accountId = Fake.generateId(Account.class);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id subscriptionId = fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType);
        SBQQ__Subscription__c fakeSubscription = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId)
            .SetField(SBQQ__Subscription__c.Segment__c, SEGMENT_SMB)
            .SetField(SBQQ__Subscription__c.Integration_Source__c, INTEGRATION_SOURCE_NINTEX)
            .setParent(
                'SBQQ__Contract__r',
                new Fake(Contract.class)
                    .setField(Contract.Id, contractId)
                    .setField(Contract.AccountId, accountId)
                    .setParent(
                        'Account',
                        new Fake(Account.class)
                            .setField(Account.id, accountId)
                            .setField(Account.Segment__c, SEGMENT_SMB)
                    )
            )
            .toSobject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ISubscriptionSelector subscriptionSelectorMock = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );
        mocks.startStubbing();
        mocks.when(subscriptionSelectorMock.SObjectType())
            .thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(subscriptionSelectorMock.selectBySubscriptionIds(new Set<Id>{ subscriptionId }))
            .thenReturn(new List<SBQQ__Subscription__c>{ fakeSubscription });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(subscriptionSelectorMock);
        IWorkOrderCreationTriggerService workOrderCreationTriggerServiceMock = (IWorkOrderCreationTriggerService) mocks.mock(
            IWorkOrderCreationTriggerService.class
        );
        Application.SERVICE.setMock(
            IWorkOrderCreationTriggerService.class,
            workOrderCreationTriggerServiceMock
        );
        Test.startTest();
        Subscriptions.newInstance(new List<SBQQ__Subscription__c>{ fakeSubscription })
            .evaluateAndInitalizeForWorkOrderCreation();
        Test.stopTest();
        ((IWorkOrderCreationTriggerService) mocks.verify(workOrderCreationTriggerServiceMock, 1))
            .initiateWorkOrderCreation(
                new Set<Id>{ fakeSubscription.Id },
                AMENDMENT_WORK_ORDER_CREATION
            );
    }

    /**
     * @description To test when Subscriptions are inserted for 'Mx Portal Package' Switch then do not
     * initiate Work Order Creation.
     * Suppressed Warnings since mock verify method is equivalent of System.assert statement.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenSubcriptionsInsertedForMxPortalPackageSwitchThenDoNotInitiateWorkOrderCreation() {
        Id accountId = Fake.generateId(Account.class);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id subscriptionId = fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType);
        Inbound_Ingestion_Log__c ingestionLogFake = (Inbound_Ingestion_Log__c) new Fake(
                Inbound_Ingestion_Log__c.class
            )
            .setField(Inbound_Ingestion_Log__c.Payload__c, INGESTION_LOG_PAYLOAD)
            .setField(Inbound_Ingestion_Log__c.Status__c, INGESTION_LOG_STATUS_SUCCESS)
            .setField(Inbound_Ingestion_Log__c.UUID__c, UNIQUE_IDENTIFIER)
            .setField(Inbound_Ingestion_Log__c.Integration_Type__c, INTEGRATION_TYPE_PACKAGE_SWITCH)
            .setFakeId()
            .toSObject();
        SBQQ__Subscription__c fakeSubscription = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId)
            .SetField(SBQQ__Subscription__c.Integration_Source__c, INTEGRATION_SOURCE_MX_PORTAL)
            .SetField(SBQQ__Subscription__c.Unique_Identifier__c, UNIQUE_IDENTIFIER)
            .setParent(
                'SBQQ__Contract__r',
                new Fake(Contract.class)
                    .setField(Contract.Id, contractId)
                    .setField(Contract.AccountId, accountId)
                    .setParent(
                        'Account',
                        new Fake(Account.class)
                            .setField(Account.id, accountId)
                            .setField(Account.Segment__c, SEGMENT_SMB)
                    )
            )
            .toSobject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ISubscriptionSelector subscriptionSelectorMock = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );
        IInboundIngestionLogsSelector inboundIngestionLogsSelectorMock = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );
        mocks.startStubbing();
        mocks.when(subscriptionSelectorMock.SObjectType())
            .thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(inboundIngestionLogsSelectorMock.SObjectType())
            .thenReturn(Inbound_Ingestion_Log__c.SObjectType);
        mocks.when(subscriptionSelectorMock.selectBySubscriptionIds(new Set<Id>{ subscriptionId }))
            .thenReturn(new List<SBQQ__Subscription__c>{ fakeSubscription });
        mocks.when(
                inboundIngestionLogsSelectorMock.selectInboundIngestionLogsByUniqueIdentifiers(
                    INBOUND_INGESTION_INTEGRATION_TYPES_INELIGIBLE_FOR_WORK_ORDER_CREATION,
                    new Set<String>{ UNIQUE_IDENTIFIER }
                )
            )
            .thenReturn(new List<Inbound_Ingestion_Log__c>{ ingestionLogFake });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(subscriptionSelectorMock);
        Application.SELECTOR.setMock(inboundIngestionLogsSelectorMock);
        IWorkOrderCreationTriggerService workOrderCreationTriggerServiceMock = (IWorkOrderCreationTriggerService) mocks.mock(
            IWorkOrderCreationTriggerService.class
        );
        Application.SERVICE.setMock(
            IWorkOrderCreationTriggerService.class,
            workOrderCreationTriggerServiceMock
        );
        Test.startTest();
        Subscriptions.newInstance(new List<SBQQ__Subscription__c>{ fakeSubscription })
            .evaluateAndInitalizeForWorkOrderCreation();
        Test.stopTest();
        ((IWorkOrderCreationTriggerService) mocks.verify(workOrderCreationTriggerServiceMock, 0))
            .initiateWorkOrderCreation(
                new Set<Id>{ fakeSubscription.Id },
                GENERIC_WORK_ORDER_CREATION
            );
    }

    /**
     * @description To test when Subscriptions are inserted for 'RESSMO' inititate Work order creation
     * Suppressed Warnings since mock verify method is equivalent of System.assert statement.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenSubcriptionsInsertedForRESSMOThenInitiateWorkOrderGeneration() {
        Id accountId = Fake.generateId(Account.class);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id subscriptionId = fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType);
        Inbound_Ingestion_Log__c ingestionLogFake = (Inbound_Ingestion_Log__c) new Fake(
                Inbound_Ingestion_Log__c.class
            )
            .setField(Inbound_Ingestion_Log__c.Payload__c, INGESTION_LOG_PAYLOAD)
            .setField(Inbound_Ingestion_Log__c.Status__c, INGESTION_LOG_STATUS_SUCCESS)
            .setField(Inbound_Ingestion_Log__c.UUID__c, UNIQUE_IDENTIFIER)
            .setField(
                Inbound_Ingestion_Log__c.Integration_Type__c,
                INTEGRATION_TYPE_ONBOARDING_EVENT
            )
            .setFakeId()
            .toSObject();
        SBQQ__Subscription__c fakeSubscription = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.Id, subscriptionId)
            .SetField(SBQQ__Subscription__c.Integration_Source__c, INTEGRATION_SOURCE_RESSMO)
            .setParent(
                'SBQQ__Contract__r',
                new Fake(Contract.class)
                    .setField(Contract.Id, contractId)
                    .setField(Contract.AccountId, accountId)
                    .setParent(
                        'Account',
                        new Fake(Account.class)
                            .setField(Account.id, accountId)
                            .setField(Account.Segment__c, SEGMENT_SMB)
                    )
            )
            .toSobject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ISubscriptionSelector subscriptionSelectorMock = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );
        IInboundIngestionLogsSelector inboundIngestionLogsSelectorMock = (IInboundIngestionLogsSelector) mocks.mock(
            IInboundIngestionLogsSelector.class
        );
        mocks.startStubbing();
        mocks.when(subscriptionSelectorMock.SObjectType())
            .thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(inboundIngestionLogsSelectorMock.SObjectType())
            .thenReturn(Inbound_Ingestion_Log__c.SObjectType);
        mocks.when(subscriptionSelectorMock.selectBySubscriptionIds(new Set<Id>{ subscriptionId }))
            .thenReturn(new List<SBQQ__Subscription__c>{ fakeSubscription });
        mocks.when(
                inboundIngestionLogsSelectorMock.selectInboundIngestionLogsByUniqueIdentifiers(
                    INBOUND_INGESTION_INTEGRATION_TYPES_INELIGIBLE_FOR_WORK_ORDER_CREATION,
                    new Set<String>{ UNIQUE_IDENTIFIER }
                )
            )
            .thenReturn(new List<Inbound_Ingestion_Log__c>{ ingestionLogFake });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(subscriptionSelectorMock);
        Application.SELECTOR.setMock(inboundIngestionLogsSelectorMock);
        IWorkOrderCreationTriggerService workOrderCreationTriggerServiceMock = (IWorkOrderCreationTriggerService) mocks.mock(
            IWorkOrderCreationTriggerService.class
        );
        Application.SERVICE.setMock(
            IWorkOrderCreationTriggerService.class,
            workOrderCreationTriggerServiceMock
        );
        Test.startTest();
        Subscriptions.newInstance(new List<SBQQ__Subscription__c>{ fakeSubscription })
            .evaluateAndInitalizeForWorkOrderCreation();
        Test.stopTest();
        ((IWorkOrderCreationTriggerService) mocks.verify(workOrderCreationTriggerServiceMock, 1))
            .initiateWorkOrderCreation(
                new Set<Id>{ fakeSubscription.Id },
                GENERIC_WORK_ORDER_CREATION
            );
    }

    /**
     * @description It is used to validate if contract is updated when active subscriptions are passed
     * with product families.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenSubscriptionIsInsertedOrUpdatedThenUpdateContractProductFamily() {
        Id mockSubscriptionId1 = Fake.generateId(SBQQ__Subscription__c.class);
        Id mockSubscriptionId2 = Fake.generateId(SBQQ__Subscription__c.class);
        Id mockContract1 = Fake.generateId(Contract.class);
        Id mockContract2 = Fake.generateId(Contract.class);
        Id productId1 = Fake.generateId(Product2.class);
        List<Product2> productList = new List<Product2>();

        Product2 product1 = (Product2) new Fake(Product2.class)
            .setField(Product2.Id, productId1)
            .setField(Product2.Name, PRODUCT_NAME_BASIC)
            .setField(Product2.Family, PRODUCT_FAMILY_MARKETPLACE)
            .toSObject();
        productList.add(product1);

        SBQQ__Subscription__c mockSubscription1 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.id, mockSubscriptionId1)
            .setField(SBQQ__Subscription__c.SBQQ__Contract__c, mockContract1)
            .setField(SBQQ__Subscription__c.SBQQ__Quantity__c, 1)
            .setField(
                SBQQ__Subscription__c.SBQQ__QuoteLine__r.SBQQ__Quote__r.Segment__c,
                SEGMENT_SMB
            )
            .setField(SBQQ__Subscription__c.SBQQ__TerminatedDate__c, null)
            .setParent(
                'SBQQ__Product__r',
                new Fake(Product2.class)
                    .setField(Product2.Id, productList[0].id)
                    .setField(Product2.Name, PRODUCT_NAME_BASIC)
                    .setField(Product2.Family, PRODUCT_FAMILY_MARKETPLACE)
            )
            .toSObject();
        SBQQ__Subscription__c mockSubscription2 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.id, mockSubscriptionId2)
            .setField(SBQQ__Subscription__c.SBQQ__Contract__c, mockContract2)
            .setField(SBQQ__Subscription__c.SBQQ__Quantity__c, 1)
            .setField(SBQQ__Subscription__c.SBQQ__Product__c, productList[0].id)
            .setField(
                SBQQ__Subscription__c.SBQQ__QuoteLine__r.SBQQ__Quote__r.Segment__c,
                SEGMENT_SMB
            )
            .setField(SBQQ__Subscription__c.SBQQ__TerminatedDate__c, null)
            .toSObject();
        Set<Id> contractIds = new Set<Id>{ mockContract1, mockContract2 };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        ISubscriptionSelector subscriptionSelectorMock = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );
        mocks.startStubbing();
        mocks.when(subscriptionSelectorMock.sObjectType())
            .thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(subscriptionSelectorMock.getSubscriptionsByContractIds(contractIds))
            .thenReturn(new List<SBQQ__Subscription__c>{ mockSubscription1, mockSubscription2 });
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(subscriptionSelectorMock);
        Test.startTest();
        Subscriptions.newInstance(
                new List<SBQQ__Subscription__c>{ mockSubscription1, mockSubscription2 }
            )
            .updateContractWithSubscritionProductFamily();
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description It is used to validate if contract is not updated when inactive subscriptions are
     * passed without contractIds.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenSubscriptionIsInsertedOrUpdatedWithoutContractThenDoNotUpdateContractProductFamily() {
        Id mockSubscriptionId1 = Fake.generateId(SBQQ__Subscription__c.class);
        Id mockSubscriptionId2 = Fake.generateId(SBQQ__Subscription__c.class);
        Id mockContract1 = Fake.generateId(Contract.class);
        Id mockContract2 = Fake.generateId(Contract.class);
        Id productId1 = Fake.generateId(Product2.class);
        List<Product2> productList = new List<Product2>();

        Product2 product1 = (Product2) new Fake(Product2.class)
            .setField(Product2.Id, productId1)
            .setField(Product2.Name, PRODUCT_NAME_BASIC)
            .setField(Product2.Family, PRODUCT_FAMILY_MARKETPLACE)
            .toSObject();
        productList.add(product1);

        SBQQ__Subscription__c mockSubscription1 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.id, mockSubscriptionId1)
            .setField(SBQQ__Subscription__c.SBQQ__Contract__c, null)
            .setField(SBQQ__Subscription__c.SBQQ__Quantity__c, 1)
            .setField(
                SBQQ__Subscription__c.SBQQ__QuoteLine__r.SBQQ__Quote__r.Segment__c,
                SEGMENT_SMB
            )
            .setField(SBQQ__Subscription__c.SBQQ__TerminatedDate__c, null)
            .setParent(
                'SBQQ__Product__r',
                new Fake(Product2.class)
                    .setField(Product2.Id, productList[0].id)
                    .setField(Product2.Name, PRODUCT_NAME_BASIC)
                    .setField(Product2.Family, PRODUCT_FAMILY_MARKETPLACE)
            )
            .toSObject();
        SBQQ__Subscription__c mockSubscription2 = (SBQQ__Subscription__c) new Fake(
                SBQQ__Subscription__c.class
            )
            .setField(SBQQ__Subscription__c.id, mockSubscriptionId2)
            .setField(SBQQ__Subscription__c.SBQQ__Contract__c, null)
            .setField(SBQQ__Subscription__c.SBQQ__Quantity__c, 1)
            .setField(SBQQ__Subscription__c.SBQQ__Product__c, productList[0].id)
            .setField(
                SBQQ__Subscription__c.SBQQ__QuoteLine__r.SBQQ__Quote__r.Segment__c,
                SEGMENT_SMB
            )
            .setField(SBQQ__Subscription__c.SBQQ__TerminatedDate__c, null)
            .toSObject();
        Set<Id> contractIds = new Set<Id>{ mockContract1, mockContract2 };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        ISubscriptionSelector subscriptionSelectorMock = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );
        mocks.startStubbing();
        mocks.when(subscriptionSelectorMock.sObjectType())
            .thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(subscriptionSelectorMock.getSubscriptionsByContractIds(contractIds))
            .thenReturn(new List<SBQQ__Subscription__c>{ mockSubscription1, mockSubscription2 });
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(subscriptionSelectorMock);
        Test.startTest();
        Subscriptions.newInstance(
                new List<SBQQ__Subscription__c>{ mockSubscription1, mockSubscription2 }
            )
            .updateContractWithSubscritionProductFamily();
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }
}