/**
 * @author DoorDash
 * @date 2022-05-15
 * @description This is test class for Agreements class
 */
@isTest
public with sharing class AgreementsServiceImplTest {
    private static Id storeAccRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Store')
        .getRecordTypeId();
    private static Id businessAccRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Business')
        .getRecordTypeId();
    static final String STORE_AGREEMENT = 'Store Agreement';
    static final String BUSINESS_AGREEMENT = 'Business Agreement';
    static final String ACTIVE_STATUS = 'Active';
    static final String AGREED_TO_SERVICES_ALL = 'All';
    static final String AGREED_TO_SERVICES_DRIVE = 'Drive';
    private static final String AGREEMENT_EVENTS_CHUNK_SIZE = 'Agreement_Events_Chunk_Size';
    private static final Integer AGREEMENT_EVENTS_CHUNK_SIZE_RECORD = 50;
    private static final String UPDATE_ACTIVATION_ORDERS_AND_PRODUCTS_FOR_EXISTING_STORES = 'Update Activation Order And Products For Existing Process';
    private static final String EVENT_TOPIC_UPDATE_MERCHANT_SERVICES = 'Update_Merchant_Services';
    private static final String STATUS_CANCELLED = 'Cancelled';
    private static final String AGREEMENT_TYPE_STORE = 'Store Agreement'; //@JIRA #LEM-15980
    private static final String EVENT_TOPIC_CREATE_ACTIVATION_ORDER = 'Create_Activation_Order_Products';
    private static final Integer MAX_RECORD_PER_TRANSACTION = 1000; //LEM-15980
    private static final Integer AGREEMENT_CHUNK_SIZE = 100; //LEM-15980
    private static final String BUSINESS_ACCOUNT = 'Business';
    private static final String STORE_ACCOUNT = 'Store';
    private static final String EXTERNAL_ID_SOURCE_MDS = 'MDS';
    private static final String XREF_STATUS_ACTIVE = 'Active';
    private static final String AGREEMENT_NAME = 'Test Agreement';
    private static final String AGREEMENT_STATUS_PENDING = 'Pending';
    private static final String AGREEMENT_TYPE_FRANCHISE_AGREEMENT = 'Franchise Agreement';
    private static final String NAME_ACCOUNT = 'Test Acc';
    private static final String NAME_ACCOUNT_CHILD = 'Test Acc Child';
    private static final String UNITED_STATES = 'United States';
    private static final String BILLING_STREET = '123 Test Street';
    private static final String BILLING_CITY = 'Missoula';
    private static final String BILLING_CITY2 = 'New York';
    private static final String BILLING_STATE = 'Montana';
    private static final String BILLING_CODE = '59801';
    private static final String BILLING_CODE2 = '59802';
    private static final String ACCOUNT_SEGMENT = 'SMB';
    private static final String PRODUCT_NAME_MARKETPLACE = 'Marketplace';
    private static final String PRODUCT_CODE_10017 = '10017';
    private static final String PRIMARY_VERTICAL = 'Hot & Prepared';
    private static final String CONTRACTTYPE_CHURNEDMERCHANT = 'Churned Merchant';
    private static final String MX_AGREED_TO_PRODUCT_YES = 'Yes';
    private static final String TEST_ACCOUNT_NAME = 'TEST ACCOUNT LEGAL NAME';
    private static final string INVALID_ASSERT_MESSAGE = 'Unexpected results';

    /**
     * @description To test creation of Agreements from Contracts
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenContractISUpdatedThenCreateAgreements() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);

        Account storeAccount = new Account(
            Id = Fake.generateId(Account.class),
            Name = 'Test 1',
            RecordTypeId = storeAccRecordType
        );
        Account businessAccount = new Account(
            Id = Fake.generateId(Account.class),
            Name = 'Test 2',
            RecordTypeId = businessAccRecordType
        );

        Contract mockContract = (Contract) new Fake(Contract.class)
            .setField(Contract.Status, Contracts.ACTIVATED)
            .setField(Contract.SBQQ__Quote__c, quoteId)
            .setFakeId()
            .toSObject();
        Id subs1 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subs2 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subs3 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subs4 = Fake.generateId(SBQQ__Subscription__c.class);
        Id grp1 = Fake.generateId(SBQQ__QuoteLineGroup__c.class);
        Id grp2 = Fake.generateId(SBQQ__QuoteLineGroup__c.class);
        Id orderItem1 = Fake.generateId(OrderItem.class);
        Id orderItem2 = Fake.generateId(OrderItem.class);
        Id orderItem3 = Fake.generateId(OrderItem.class);
        Id orderItem4 = Fake.generateId(OrderItem.class);

        SBQQ__Subscription__c[] subs = new List<SBQQ__Subscription__c>{
            new SBQQ__Subscription__c(
                Id = subs1,
                SBQQ__OrderProduct__c = orderItem1,
                SBQQ__TerminatedDate__c = null
            ),
            new SBQQ__Subscription__c(
                Id = subs2,
                SBQQ__OrderProduct__c = orderItem2,
                SBQQ__TerminatedDate__c = null
            ),
            new SBQQ__Subscription__c(
                Id = subs3,
                SBQQ__OrderProduct__c = orderItem3,
                SBQQ__TerminatedDate__c = null
            ),
            new SBQQ__Subscription__c(
                Id = subs4,
                SBQQ__OrderProduct__c = orderItem4,
                SBQQ__TerminatedDate__c = null
            )
        };

        Map<Id, Set<String>> getNewAssociatedAccountIdMap = new Map<Id, Set<String>>();
        getNewAssociatedAccountIdMap.put(
            mockContract.Id,
            new Set<String>{ String.valueOf(storeAccount.Id), String.valueOf(businessAccount.Id) }
        );
        Map<Id, Map<Id, String>> associatedAccountIdGroupIdMapWithEntitlements = new Map<Id, Map<Id, String>>();
        Map<Id, String> innerMap1 = new Map<Id, String>();
        Map<Id, String> innerMap2 = new Map<Id, String>();
        List<Id> subRec1 = new List<Id>{ subs[0].Id, subs[1].Id };
        List<Id> subRec2 = new List<Id>{ subs[2].Id, subs[3].Id };
        innerMap1.put(grp1, String.join(subRec1, ','));
        innerMap2.put(grp2, String.join(subRec2, ','));
        associatedAccountIdGroupIdMapWithEntitlements.put(storeAccount.Id, innerMap1);
        associatedAccountIdGroupIdMapWithEntitlements.put(businessAccount.Id, innerMap2);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                accountSelectorMock.selectById(new Set<Id>{ storeAccount.Id, businessAccount.Id })
            )
            .thenReturn(new List<Account>{ storeAccount, businessAccount });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(accountSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);

        AgreementsService.createAgreementsfromContractsWithGroup(
            new List<Contract>{ mockContract },
            getNewAssociatedAccountIdMap,
            associatedAccountIdGroupIdMapWithEntitlements
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(new Agreement__c(
                        Name = 'Test 1 - ' + STORE_AGREEMENT,
                        Account__c = storeAccount.Id,
                        Group__c = grp1,
                        Contract__c = mockContract.Id,
                        Agreed_To_Services__c = AGREED_TO_SERVICES_ALL,
                        Status__c = ACTIVE_STATUS,
                        Type__c = STORE_AGREEMENT,
                        Start_Date__c = System.today(),
                        Source_Quote__c = quoteId,
                        CurrencyIsoCode = null,
                        Serialized_Entitlements_Data__c = String.join(SubRec1, ',')
                    ));
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(new Agreement__c(
                        Name = 'Test 2 - ' + BUSINESS_AGREEMENT,
                        Account__c = businessAccount.Id,
                        Group__c = grp2,
                        Contract__c = mockContract.Id,
                        Agreed_To_Services__c = AGREED_TO_SERVICES_DRIVE,
                        Status__c = ACTIVE_STATUS,
                        Type__c = BUSINESS_AGREEMENT,
                        Start_Date__c = System.today(),
                        Source_Quote__c = quoteId,
                        CurrencyIsoCode = null,
                        Serialized_Entitlements_Data__c = String.join(SubRec2, ',')
                    ));
    }

    /**
     * @description To test creation of Agreements from Contracts
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenContractISUpdatedThenCreateAgreementsNegative() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Contract mockContract = (Contract) new Fake(Contract.class)
            .setField(Contract.Status, Contracts.ACTIVATED)
            .setField(Contract.SBQQ__Quote__c, quoteId)
            .setFakeId()
            .toSObject();
        Map<Id, Map<Id, String>> associatedAccountIdGroupIdMapWithEntitlements = new Map<Id, Map<Id, String>>();
        Map<Id, Set<String>> getNewAssociatedAccountIdMap = new Map<Id, Set<String>>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);

        AgreementsService.createAgreementsfromContractsWithGroup(
            new List<Contract>{ mockContract },
            getNewAssociatedAccountIdMap,
            associatedAccountIdGroupIdMapWithEntitlements
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).registerNew(fflib_Match.anySObject());
    }


    /**
     * @description To test update of Agreements from Contract Associated Accounts
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenCaaIsInsertedThenUpdateAgreements() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id subs1 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subs2 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subs3 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subs4 = Fake.generateId(SBQQ__Subscription__c.class);
        Id grp1 = Fake.generateId(SBQQ__QuoteLineGroup__c.class);
        Id grp2 = Fake.generateId(SBQQ__QuoteLineGroup__c.class);
        Id orderItem1 = Fake.generateId(OrderItem.class);
        Id orderItem2 = Fake.generateId(OrderItem.class);
        Id orderItem3 = Fake.generateId(OrderItem.class);
        Id orderItem4 = Fake.generateId(OrderItem.class);
        Id storeAgreementId = Fake.generateId(Agreement__c.class);

        Contract mockContract = (Contract) new Fake(Contract.class)
            .setField(Contract.Status, Contracts.ACTIVATED)
            .setField(Contract.SBQQ__Quote__c, quoteId)
            .setFakeId()
            .toSObject();

        Account storeAccount = new Account(
            Id = Fake.generateId(Account.class),
            Name = 'Test 1',
            RecordTypeId = storeAccRecordType
        );

        Agreement__c storeAgreement = (Agreement__c) new Fake(Agreement__c.class)
            .setField(Agreement__c.Id, storeAgreementId)
            .setField(Agreement__c.Name, 'Test 1 - ' + STORE_AGREEMENT)
            .setField(Agreement__c.Account__c, storeAccount.Id)
            .setField(Agreement__c.Type__c, STORE_AGREEMENT)
            .setField(Agreement__c.Group__c, grp1)
            .setField(Agreement__c.Contract__c, mockContract.Id)
            .setField(Agreement__c.Agreed_To_Services__c, AGREED_TO_SERVICES_ALL)
            .setField(Agreement__c.Status__c, ACTIVE_STATUS)
            .setField(Agreement__c.Serialized_Entitlements_Data__c, '')
            .toSObject();

        SBQQ__Subscription__c[] subs = new List<SBQQ__Subscription__c>{
            new SBQQ__Subscription__c(
                Id = subs1,
                SBQQ__OrderProduct__c = orderItem1,
                SBQQ__TerminatedDate__c = null
            ),
            new SBQQ__Subscription__c(
                Id = subs2,
                SBQQ__OrderProduct__c = orderItem2,
                SBQQ__TerminatedDate__c = null
            ),
            new SBQQ__Subscription__c(
                Id = subs3,
                SBQQ__OrderProduct__c = orderItem3,
                SBQQ__TerminatedDate__c = null
            ),
            new SBQQ__Subscription__c(
                Id = subs4,
                SBQQ__OrderProduct__c = orderItem4,
                SBQQ__TerminatedDate__c = null
            )
        };

        Map<Id, Map<Id, String>> associatedAccountIdGroupIdMapWithEntitlements = new Map<Id, Map<Id, String>>();
        Map<Id, String> innerMap1 = new Map<Id, String>();
        Map<Id, String> innerMap2 = new Map<Id, String>();
        List<Id> subRec1 = new List<Id>{ subs[0].Id, subs[1].Id };
        List<Id> subRec2 = new List<Id>{ subs[2].Id, subs[3].Id };
        innerMap1.put(grp1, String.join(subRec1, ','));
        innerMap2.put(grp2, String.join(subRec2, ','));
        associatedAccountIdGroupIdMapWithEntitlements.put(storeAccount.Id, innerMap1);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAgreementsSelector agreementSelectorMock = (IAgreementsSelector) mocks.mock(
            IAgreementsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(agreementSelectorMock.sObjectType()).thenReturn(Agreement__c.SObjectType);
        mocks.when(
                agreementSelectorMock.selectActiveAgreementsByAccountIds(
                    new Set<Id>{ storeAccount.Id }
                )
            )
            .thenReturn(new List<Agreement__c>{ storeAgreement });
        mocks.stopStubbing();

        Application.SELECTOR.setMock(agreementSelectorMock);

        Application.UNITOFWORK.setMock(mockUOW);

        AgreementsService.updateAgreementsForExistingStoresWithGroups(
            associatedAccountIdGroupIdMapWithEntitlements
        );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Agreement__c.Id => storeAgreementId,
                            Agreement__c.Serialized_Entitlements_Data__c => String.join(
                                subRec1,
                                ','
                            )
                        }
                    }
                )
            );
    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenPublishAgreementActivationEventsForExistingProcessMethodCalledThenPublishEvent() {
        Id agreementId = fflib_IDGenerator.generate(Agreement__c.SObjectType);
        List<Agreement__c> agreementsList = new List<Agreement__c>{
            new Agreement__c(Id = agreementId, Status__c = ACTIVE_STATUS)
        };

        Static_Configurations__mdt agreementMetadta = new Static_Configurations__mdt(
            DeveloperName = AGREEMENT_EVENTS_CHUNK_SIZE,
            MasterLabel = AGREEMENT_EVENTS_CHUNK_SIZE,
            Configuration_Value__c = String.valueOf(AGREEMENT_EVENTS_CHUNK_SIZE_RECORD)
        );

        List<String> eventPayload = new List<String>{ JSON.serialize(new List<Id>{ agreementId }) };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        INotifierEventsPayloadGenerationService mockNotifierEventsPayloadGenerationService = (INotifierEventsPayloadGenerationService) mocks.mock(
            INotifierEventsPayloadGenerationService.class
        );
        IStaticConfigurationsSelector mockStaticConfigurationsSelector = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        mocks.startStubbing();
        mocks.when(
                mockNotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                    new Set<Id>{ agreementId },
                    AGREEMENT_EVENTS_CHUNK_SIZE_RECORD
                )
            )
            .thenReturn(eventPayload);
        mocks.when(mockStaticConfigurationsSelector.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(mockStaticConfigurationsSelector.getInstanceValue(AGREEMENT_EVENTS_CHUNK_SIZE))
            .thenReturn(agreementMetadta);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        Application.SERVICE.setMock(
            INotifierEventsPayloadGenerationService.class,
            mockNotifierEventsPayloadGenerationService
        );

        AgreementsService.publishAgreementActivationEvents(agreementsList, true);

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerPublishAfterSuccessTransaction(
                new Agreement_Activation_Event__e(
                    Agreement_Ids__c = JSON.serialize(new List<Id>{ agreementId }),
                    Topic__c = UPDATE_ACTIVATION_ORDERS_AND_PRODUCTS_FOR_EXISTING_STORES
                )
            );
    }

    /**
     * @description To Get deactivatedAgreements Account Ids
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAgreementsUpdatedThenFilterDeactivatedAgreementAccountIds() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id grp1 = Fake.generateId(SBQQ__QuoteLineGroup__c.class);
        Id storeAgreementId = Fake.generateId(Agreement__c.class);

        Contract mockContract = (Contract) new Fake(Contract.class)
            .setField(Contract.Status, Contracts.ACTIVATED)
            .setField(Contract.SBQQ__Quote__c, quoteId)
            .setFakeId()
            .toSObject();

        Account storeAccount = new Account(
            Id = Fake.generateId(Account.class),
            Name = 'Test 1',
            RecordTypeId = storeAccRecordType
        );

        Agreement__c storeAgreement = (Agreement__c) new Fake(Agreement__c.class)
            .setField(Agreement__c.Id, storeAgreementId)
            .setField(Agreement__c.Name, 'Test 1 - ' + STORE_AGREEMENT)
            .setField(Agreement__c.Account__c, storeAccount.Id)
            .setField(Agreement__c.Type__c, STORE_AGREEMENT)
            .setField(Agreement__c.Group__c, grp1)
            .setField(Agreement__c.Contract__c, mockContract.Id)
            .setField(Agreement__c.Agreed_To_Services__c, AGREED_TO_SERVICES_ALL)
            .setField(Agreement__c.Status__c, STATUS_CANCELLED)
            .setField(Agreement__c.Deactivation_Date__c, System.Today())
            .setField(Agreement__c.Serialized_Entitlements_Data__c, '')
            .toSObject();

        Set<Id> accountIds = AgreementsService.getDeactivatedAndCancelledAgreementAccountIds(
            new List<Agreement__c>{ storeAgreement }
        );

        System.assertEquals(
            new Set<Id>{ storeAccount.Id },
            accountIds,
            'Store Ids retured are not expected'
        );
    }

    /**
     * @description To test setMxAgreedToProductValueNoFromFlow call
     * @JIRA #LEM-15980
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenDeactivatedAgreementsPassedThenUpdateMxServicesBasedOnRecordsCount() {
        Id agreementId1 = fflib_IDGenerator.generate(Agreement__c.SObjectType);
        Id agreementId2 = fflib_IDGenerator.generate(Agreement__c.SObjectType);
        Id accountId1 = fflib_IDGenerator.generate(Account.SObjectType);
        Id accountId2 = fflib_IDGenerator.generate(Account.SObjectType);
        Id contractId1 = fflib_IDGenerator.generate(contract.SObjectType);

        List<Agreement__c> agreements = new List<Agreement__c>{
            new Agreement__c(
                Id = agreementId1,
                Type__c = AGREEMENT_TYPE_STORE,
                Status__c = STATUS_CANCELLED,
                Account__c = accountId1,
                Deactivation_Date__c = System.today()
            ),
            new Agreement__c(
                Id = agreementId2,
                Type__c = AGREEMENT_TYPE_STORE,
                Status__c = STATUS_CANCELLED,
                Account__c = accountId2,
                Deactivation_Date__c = System.today()
            )
        };

        Merchant_Service__c merchantServiceRecordMarketPlace1 = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setFakeId()
            .setField(Merchant_Service__c.Mx_Agreed_to_Product__c, 'No')
            .setParent('Account__r', new Fake(Account.class))
            .setParent('Subscription__r', new Fake(SBQQ__Subscription__c.class))
            .setParent(
                'Product__r',
                new Fake(Product2.class).setField(Product2.Family, 'Marketplace')
            )
            .toSObject();

        Merchant_Service__c merchantServiceRecordMarketPlace2 = (Merchant_Service__c) new Fake(
                Merchant_Service__c.class
            )
            .setFakeId()
            .setField(Merchant_Service__c.Mx_Agreed_to_Product__c, 'No')
            .setParent('Account__r', new Fake(Account.class))
            .setParent('Subscription__r', new Fake(SBQQ__Subscription__c.class))
            .setParent(
                'Product__r',
                new Fake(Product2.class).setField(Product2.Family, 'Marketplace')
            )
            .toSObject();

        List<Merchant_Service__c> existingServices1 = new List<Merchant_Service__c>{
            merchantServiceRecordMarketPlace1,
            merchantServiceRecordMarketPlace2
        };

        // Mock AgreementsService to return specific deactivated and cancelled agreement account IDs
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAgreementsService mockAgreementsService = (IAgreementsService) mocks.mock(
            IAgreementsService.class
        );

        // Mock MerchantSelector to return specific Merchant_Service__c records
        IMerchantSelector mockMerchantSelector = (IMerchantSelector) mocks.mock(
            IMerchantSelector.class
        );

        // Setup mocking for mockAgreementsService
        mocks.startStubbing();
        mocks.when(mockAgreementsService.getDeactivatedAndCancelledAgreementAccountIds(agreements))
            .thenReturn(new Set<Id>{ accountId1 });

        // Setup mocking for mockMerchantSelector
        mocks.when(mockMerchantSelector.SObjectType()).thenReturn(Merchant_Service__c.SObjectType);
        mocks.when(
                mockMerchantSelector.selectActiveServicesByAccountIds(
                    new Set<Id>{ accountId1 },
                    new Set<Id>{ contractId1 }
                )
            )
            .thenReturn(existingServices1);
        mocks.stopStubbing();

        // Apply the mocks to the application
        Application.SERVICE.setMock(IAgreementsService.class, mockAgreementsService);
        Application.SELECTOR.setMock(mockMerchantSelector);

        // Invoke the method to be tested
        AgreementsService.updateMxServicesBasedOnRecordsCount(agreements, false);

        // Verify that the unit of work registered the updates
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        ((fflib_ISObjectUnitOfWork) mocks.verify(uow, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(uow, 1))
            .registerPublishAfterSuccessTransaction(
                new Agreement_Activation_Event__e(
                    Agreement_Ids__c = JSON.serialize(new List<Id>{ agreementId1, agreementId2 }),
                    Topic__c = EVENT_TOPIC_UPDATE_MERCHANT_SERVICES
                )
            );
    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenPublishAgreementActivationEventsMethodCalledThenPublishEvent() {
        Id agreementId = fflib_IDGenerator.generate(Agreement__c.SObjectType);
        List<Agreement__c> agreementsList = new List<Agreement__c>{
            new Agreement__c(Id = agreementId, Status__c = ACTIVE_STATUS)
        };

        Static_Configurations__mdt agreementMetadta = new Static_Configurations__mdt(
            DeveloperName = AGREEMENT_EVENTS_CHUNK_SIZE,
            MasterLabel = AGREEMENT_EVENTS_CHUNK_SIZE,
            Configuration_Value__c = String.valueOf(AGREEMENT_EVENTS_CHUNK_SIZE_RECORD)
        );

        List<String> eventPayload = new List<String>{ JSON.serialize(new List<Id>{ agreementId }) };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        INotifierEventsPayloadGenerationService mockNotifierEventsPayloadGenerationService = (INotifierEventsPayloadGenerationService) mocks.mock(
            INotifierEventsPayloadGenerationService.class
        );
        IStaticConfigurationsSelector mockStaticConfigurationsSelector = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        mocks.startStubbing();
        mocks.when(
                mockNotifierEventsPayloadGenerationService.generateChunkedPayloadsBySobjectIds(
                    new Set<Id>{ agreementId },
                    AGREEMENT_EVENTS_CHUNK_SIZE_RECORD
                )
            )
            .thenReturn(eventPayload);
        mocks.when(mockStaticConfigurationsSelector.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(mockStaticConfigurationsSelector.getInstanceValue(AGREEMENT_EVENTS_CHUNK_SIZE))
            .thenReturn(agreementMetadta);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockStaticConfigurationsSelector);
        Application.SERVICE.setMock(
            INotifierEventsPayloadGenerationService.class,
            mockNotifierEventsPayloadGenerationService
        );

        AgreementsService.publishAgreementActivationEvents(agreementsList, false);

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerPublishAfterSuccessTransaction(
                new Agreement_Activation_Event__e(
                    Agreement_Ids__c = JSON.serialize(new List<Id>{ agreementId }),
                    Topic__c = EVENT_TOPIC_CREATE_ACTIVATION_ORDER
                )
            );
    }

    /**
     * @description To test setMxAgreedToProductValueNoFromFlow call
     * @JIRA #LEM-15980
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAgreementsUpdatedThenFilterDeactivatedAgreementAccountId() {
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id grp1 = Fake.generateId(SBQQ__QuoteLineGroup__c.class);
        Id storeAgreementId = Fake.generateId(Agreement__c.class);

        Contract mockContract = (Contract) new Fake(Contract.class)
            .setField(Contract.Status, Contracts.ACTIVATED)
            .setField(Contract.SBQQ__Quote__c, quoteId)
            .setFakeId()
            .toSObject();

        Account storeAccount = new Account(
            Id = Fake.generateId(Account.class),
            Name = 'Test 1',
            RecordTypeId = storeAccRecordType
        );

        Agreement__c storeAgreement = (Agreement__c) new Fake(Agreement__c.class)
            .setField(Agreement__c.Id, storeAgreementId)
            .setField(Agreement__c.Name, 'Test 1 - ' + STORE_AGREEMENT)
            .setField(Agreement__c.Account__c, storeAccount.Id)
            .setField(Agreement__c.Type__c, STORE_AGREEMENT)
            .setField(Agreement__c.Group__c, grp1)
            .setField(Agreement__c.Contract__c, mockContract.Id)
            .setField(Agreement__c.Agreed_To_Services__c, AGREED_TO_SERVICES_ALL)
            .setField(Agreement__c.Status__c, STATUS_CANCELLED)
            .setField(Agreement__c.Deactivation_Date__c, System.Today())
            .setField(Agreement__c.Serialized_Entitlements_Data__c, '')
            .toSObject();

        AgreementsService.updateMxServicesBasedOnRecordsCount(
            new List<Agreement__c>{ storeAgreement },
            false
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        // Verify that the unit of work registered the updates
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        ((fflib_ISObjectUnitOfWork) mocks.verify(uow, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(uow, 1))
            .registerPublishAfterSuccessTransaction(
                new Agreement_Activation_Event__e(
                    Agreement_Ids__c = JSON.serialize(new List<Id>{ storeAgreement.Id }),
                    Topic__c = EVENT_TOPIC_UPDATE_MERCHANT_SERVICES
                )
            );
    }
    /**
     * @description It is used to test weather Agreements Records are
     * Deleted for Churned Merchant Contract Type.
     * @JIRA #LEM-23780
     */
    @isTest
    private static void testWhenChurnedMxAgreementsByContractIdsThenDeleteAgreements() {
        Id contractId = Fake.generateId(Contract.class);
        Id storeAccountId = Fake.generateId(Account.class);
        Id storeAgreementId = Fake.generateId(Agreement__c.class);

        Agreement__c storeAgreement = (Agreement__c) new Fake(Agreement__c.class)
            .setField(Agreement__c.Id, storeAgreementId)
            .setField(Agreement__c.Name, 'Test 1 - ' + STORE_AGREEMENT)
            .setField(Agreement__c.Account__c, storeAccountId)
            .setField(Agreement__c.Type__c, STORE_AGREEMENT)
            .setField(Agreement__c.Contract__c, contractId)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        IAgreementsSelector agreementsSelectorMock = (IAgreementsSelector) mocks.mock(
            IAgreementsSelector.class
        );
        IXrefAndBizRefService mockXrefAndBizRefService = (IXrefAndBizRefService) mocks.mock(
            IXrefAndBizRefService.class
        );
        mocks.startStubbing();
        mocks.when(agreementsSelectorMock.sObjectType()).thenReturn(Agreement__c.SObjectType);
        mocks.when(
                agreementsSelectorMock.selectChurnedMxAgreementsByContractIds(
                    new Set<Id>{ contractId }
                )
            )
            .thenReturn(new List<Agreement__c>{ storeAgreement });
        mocks.when(
                mockXrefAndBizRefService.deactivateChurnedMxXrefs(
                    (Set<Id>) fflib_Match.anyObject(),
                    (fflib_ISObjectUnitOfWork) fflib_Match.anyObject()
                )
            )
            .thenReturn(mockUOW);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(agreementsSelectorMock);
        Application.SERVICE.setMock(IXrefAndBizRefService.class, mockXrefAndBizRefService);
        Test.startTest();
        fflib_ISObjectUnitOfWork uow = AgreementsService.deleteChurnedMxAgreements(
            new Set<Id>{ contractId }
        );
        Test.stopTest();
        System.assertEquals(mockUOW, uow, INVALID_ASSERT_MESSAGE);
    }

    /**
    * @description test method for RegisterAgreement will commit based on the static variable and source
    * @author VenkateshDD | 11-11-2024
    **/
    @isTest
    private static void testWhenRegisterAgreementThenCommitIfApplicable(){

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);

        Agreement__c agreement = new Agreement__c();

        AgreementsServiceImpl srvcImpl = new AgreementsServiceImpl();

        String ssmoString = '{"Integration_Source__c": "SSMO"}';
        Contract ssmoContract = (Contract) JSON.deserialize(ssmoString, Contract.class);
        String ressmoString = '{"Integration_Source__c": "RESSMO"}';
        Contract ressmoContract = (Contract) JSON.deserialize(ressmoString, Contract.class);

        srvcImpl.registerAgreement(agreement, 'key1', mockUOW, ssmoContract);
        Assert.isTrue(AgreementsServiceImpl.alreadyProcessedContractsWithStore.contains('key1'), 'once registered it should add to processed set');
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).registerNew(agreement);
        srvcImpl.registerAgreement(agreement, 'key1', mockUOW, ressmoContract);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).registerNew(agreement);
        srvcImpl.registerAgreement(agreement, 'key2', mockUOW, ressmoContract);
        Assert.isTrue(AgreementsServiceImpl.alreadyProcessedContractsWithStore.contains('key2'), 'once registered it should add to processed set');
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).registerNew(agreement);
        srvcImpl.registerAgreement(agreement, 'key2', mockUOW, ressmoContract);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).registerNew(agreement);
    }
}